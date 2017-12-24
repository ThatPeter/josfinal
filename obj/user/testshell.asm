
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 2e 18 00 00       	call   80187d <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 24 18 00 00       	call   80187d <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 40 2a 80 00 	movl   $0x802a40,(%esp)
  800060:	e8 a0 05 00 00       	call   800605 <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 ab 2a 80 00 	movl   $0x802aab,(%esp)
  80006c:	e8 94 05 00 00       	call   800605 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 4e 0e 00 00       	call   800ed1 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 85 16 00 00       	call   801717 <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 ba 2a 80 00       	push   $0x802aba
  8000a1:	e8 5f 05 00 00       	call   800605 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 19 0e 00 00       	call   800ed1 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 50 16 00 00       	call   801717 <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 b5 2a 80 00       	push   $0x802ab5
  8000d6:	e8 2a 05 00 00       	call   800605 <cprintf>
	exit();
  8000db:	e8 32 04 00 00       	call   800512 <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 e0 14 00 00       	call   8015db <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 d4 14 00 00       	call   8015db <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 c8 2a 80 00       	push   $0x802ac8
  80011b:	e8 82 1a 00 00       	call   801ba2 <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 d5 2a 80 00       	push   $0x802ad5
  80012f:	6a 13                	push   $0x13
  800131:	68 eb 2a 80 00       	push   $0x802aeb
  800136:	e8 f1 03 00 00       	call   80052c <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 b7 22 00 00       	call   8023fe <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 fc 2a 80 00       	push   $0x802afc
  800154:	6a 15                	push   $0x15
  800156:	68 eb 2a 80 00       	push   $0x802aeb
  80015b:	e8 cc 03 00 00       	call   80052c <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi
	
	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 64 2a 80 00       	push   $0x802a64
  80016b:	e8 95 04 00 00       	call   800605 <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 df 10 00 00       	call   801254 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 05 2b 80 00       	push   $0x802b05
  800182:	6a 1a                	push   $0x1a
  800184:	68 eb 2a 80 00       	push   $0x802aeb
  800189:	e8 9e 03 00 00       	call   80052c <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 8e 14 00 00       	call   80162b <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 83 14 00 00       	call   80162b <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 2b 14 00 00       	call   8015db <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 23 14 00 00       	call   8015db <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 0e 2b 80 00       	push   $0x802b0e
  8001bf:	68 d2 2a 80 00       	push   $0x802ad2
  8001c4:	68 11 2b 80 00       	push   $0x802b11
  8001c9:	e8 e7 1f 00 00       	call   8021b5 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 15 2b 80 00       	push   $0x802b15
  8001dd:	6a 21                	push   $0x21
  8001df:	68 eb 2a 80 00       	push   $0x802aeb
  8001e4:	e8 43 03 00 00       	call   80052c <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 e8 13 00 00       	call   8015db <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 dc 13 00 00       	call   8015db <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 7d 23 00 00       	call   802584 <wait>
		exit();
  800207:	e8 06 03 00 00       	call   800512 <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 c3 13 00 00       	call   8015db <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 bb 13 00 00       	call   8015db <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 1f 2b 80 00       	push   $0x802b1f
  800230:	e8 6d 19 00 00       	call   801ba2 <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 88 2a 80 00       	push   $0x802a88
  800245:	6a 2c                	push   $0x2c
  800247:	68 eb 2a 80 00       	push   $0x802aeb
  80024c:	e8 db 02 00 00       	call   80052c <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 ab 14 00 00       	call   801717 <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 98 14 00 00       	call   801717 <read>
		
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 2d 2b 80 00       	push   $0x802b2d
  80028c:	6a 34                	push   $0x34
  80028e:	68 eb 2a 80 00       	push   $0x802aeb
  800293:	e8 94 02 00 00       	call   80052c <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 47 2b 80 00       	push   $0x802b47
  8002a2:	6a 36                	push   $0x36
  8002a4:	68 eb 2a 80 00       	push   $0x802aeb
  8002a9:	e8 7e 02 00 00       	call   80052c <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 61 2b 80 00       	push   $0x802b61
  8002f0:	e8 10 03 00 00       	call   800605 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 76 2b 80 00       	push   $0x802b76
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 6c 08 00 00       	call   800b8a <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 c0 09 00 00       	call   800d1c <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 6b 0b 00 00       	call   800ed1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 dc 0b 00 00       	call   800f6e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 58 0b 00 00       	call   800eef <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 03 0b 00 00       	call   800ed1 <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 31 13 00 00       	call   801717 <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 a1 10 00 00       	call   8014b1 <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 29 10 00 00       	call   801462 <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 39 0b 00 00       	call   800f8d <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 c0 0f 00 00       	call   80143b <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	57                   	push   %edi
  800488:	56                   	push   %esi
  800489:	53                   	push   %ebx
  80048a:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80048d:	c7 05 04 50 80 00 00 	movl   $0x0,0x805004
  800494:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800497:	e8 b3 0a 00 00       	call   800f4f <sys_getenvid>
  80049c:	8b 3d 04 50 80 00    	mov    0x805004,%edi
  8004a2:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8004a7:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8004ac:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8004b1:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8004b4:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8004ba:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8004bd:	39 c8                	cmp    %ecx,%eax
  8004bf:	0f 44 fb             	cmove  %ebx,%edi
  8004c2:	b9 01 00 00 00       	mov    $0x1,%ecx
  8004c7:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8004ca:	83 c2 01             	add    $0x1,%edx
  8004cd:	83 c3 7c             	add    $0x7c,%ebx
  8004d0:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8004d6:	75 d9                	jne    8004b1 <libmain+0x2d>
  8004d8:	89 f0                	mov    %esi,%eax
  8004da:	84 c0                	test   %al,%al
  8004dc:	74 06                	je     8004e4 <libmain+0x60>
  8004de:	89 3d 04 50 80 00    	mov    %edi,0x805004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004e4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8004e8:	7e 0a                	jle    8004f4 <libmain+0x70>
		binaryname = argv[0];
  8004ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ed:	8b 00                	mov    (%eax),%eax
  8004ef:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	ff 75 0c             	pushl  0xc(%ebp)
  8004fa:	ff 75 08             	pushl  0x8(%ebp)
  8004fd:	e8 e9 fb ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  800502:	e8 0b 00 00 00       	call   800512 <exit>
}
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80050d:	5b                   	pop    %ebx
  80050e:	5e                   	pop    %esi
  80050f:	5f                   	pop    %edi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800518:	e8 e9 10 00 00       	call   801606 <close_all>
	sys_env_destroy(0);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	6a 00                	push   $0x0
  800522:	e8 e7 09 00 00       	call   800f0e <sys_env_destroy>
}
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	c9                   	leave  
  80052b:	c3                   	ret    

0080052c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	56                   	push   %esi
  800530:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800531:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800534:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  80053a:	e8 10 0a 00 00       	call   800f4f <sys_getenvid>
  80053f:	83 ec 0c             	sub    $0xc,%esp
  800542:	ff 75 0c             	pushl  0xc(%ebp)
  800545:	ff 75 08             	pushl  0x8(%ebp)
  800548:	56                   	push   %esi
  800549:	50                   	push   %eax
  80054a:	68 8c 2b 80 00       	push   $0x802b8c
  80054f:	e8 b1 00 00 00       	call   800605 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800554:	83 c4 18             	add    $0x18,%esp
  800557:	53                   	push   %ebx
  800558:	ff 75 10             	pushl  0x10(%ebp)
  80055b:	e8 54 00 00 00       	call   8005b4 <vcprintf>
	cprintf("\n");
  800560:	c7 04 24 b8 2a 80 00 	movl   $0x802ab8,(%esp)
  800567:	e8 99 00 00 00       	call   800605 <cprintf>
  80056c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80056f:	cc                   	int3   
  800570:	eb fd                	jmp    80056f <_panic+0x43>

00800572 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
  800575:	53                   	push   %ebx
  800576:	83 ec 04             	sub    $0x4,%esp
  800579:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80057c:	8b 13                	mov    (%ebx),%edx
  80057e:	8d 42 01             	lea    0x1(%edx),%eax
  800581:	89 03                	mov    %eax,(%ebx)
  800583:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800586:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80058a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80058f:	75 1a                	jne    8005ab <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800591:	83 ec 08             	sub    $0x8,%esp
  800594:	68 ff 00 00 00       	push   $0xff
  800599:	8d 43 08             	lea    0x8(%ebx),%eax
  80059c:	50                   	push   %eax
  80059d:	e8 2f 09 00 00       	call   800ed1 <sys_cputs>
		b->idx = 0;
  8005a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8005a8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8005ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8005af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005b2:	c9                   	leave  
  8005b3:	c3                   	ret    

008005b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005b4:	55                   	push   %ebp
  8005b5:	89 e5                	mov    %esp,%ebp
  8005b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8005bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005c4:	00 00 00 
	b.cnt = 0;
  8005c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005d1:	ff 75 0c             	pushl  0xc(%ebp)
  8005d4:	ff 75 08             	pushl  0x8(%ebp)
  8005d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005dd:	50                   	push   %eax
  8005de:	68 72 05 80 00       	push   $0x800572
  8005e3:	e8 54 01 00 00       	call   80073c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005e8:	83 c4 08             	add    $0x8,%esp
  8005eb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005f7:	50                   	push   %eax
  8005f8:	e8 d4 08 00 00       	call   800ed1 <sys_cputs>

	return b.cnt;
}
  8005fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800603:	c9                   	leave  
  800604:	c3                   	ret    

00800605 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800605:	55                   	push   %ebp
  800606:	89 e5                	mov    %esp,%ebp
  800608:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80060b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80060e:	50                   	push   %eax
  80060f:	ff 75 08             	pushl  0x8(%ebp)
  800612:	e8 9d ff ff ff       	call   8005b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800617:	c9                   	leave  
  800618:	c3                   	ret    

00800619 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800619:	55                   	push   %ebp
  80061a:	89 e5                	mov    %esp,%ebp
  80061c:	57                   	push   %edi
  80061d:	56                   	push   %esi
  80061e:	53                   	push   %ebx
  80061f:	83 ec 1c             	sub    $0x1c,%esp
  800622:	89 c7                	mov    %eax,%edi
  800624:	89 d6                	mov    %edx,%esi
  800626:	8b 45 08             	mov    0x8(%ebp),%eax
  800629:	8b 55 0c             	mov    0xc(%ebp),%edx
  80062c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800632:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800635:	bb 00 00 00 00       	mov    $0x0,%ebx
  80063a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80063d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800640:	39 d3                	cmp    %edx,%ebx
  800642:	72 05                	jb     800649 <printnum+0x30>
  800644:	39 45 10             	cmp    %eax,0x10(%ebp)
  800647:	77 45                	ja     80068e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800649:	83 ec 0c             	sub    $0xc,%esp
  80064c:	ff 75 18             	pushl  0x18(%ebp)
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800655:	53                   	push   %ebx
  800656:	ff 75 10             	pushl  0x10(%ebp)
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065f:	ff 75 e0             	pushl  -0x20(%ebp)
  800662:	ff 75 dc             	pushl  -0x24(%ebp)
  800665:	ff 75 d8             	pushl  -0x28(%ebp)
  800668:	e8 43 21 00 00       	call   8027b0 <__udivdi3>
  80066d:	83 c4 18             	add    $0x18,%esp
  800670:	52                   	push   %edx
  800671:	50                   	push   %eax
  800672:	89 f2                	mov    %esi,%edx
  800674:	89 f8                	mov    %edi,%eax
  800676:	e8 9e ff ff ff       	call   800619 <printnum>
  80067b:	83 c4 20             	add    $0x20,%esp
  80067e:	eb 18                	jmp    800698 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	56                   	push   %esi
  800684:	ff 75 18             	pushl  0x18(%ebp)
  800687:	ff d7                	call   *%edi
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	eb 03                	jmp    800691 <printnum+0x78>
  80068e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800691:	83 eb 01             	sub    $0x1,%ebx
  800694:	85 db                	test   %ebx,%ebx
  800696:	7f e8                	jg     800680 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	56                   	push   %esi
  80069c:	83 ec 04             	sub    $0x4,%esp
  80069f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8006a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8006ab:	e8 30 22 00 00       	call   8028e0 <__umoddi3>
  8006b0:	83 c4 14             	add    $0x14,%esp
  8006b3:	0f be 80 af 2b 80 00 	movsbl 0x802baf(%eax),%eax
  8006ba:	50                   	push   %eax
  8006bb:	ff d7                	call   *%edi
}
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c3:	5b                   	pop    %ebx
  8006c4:	5e                   	pop    %esi
  8006c5:	5f                   	pop    %edi
  8006c6:	5d                   	pop    %ebp
  8006c7:	c3                   	ret    

008006c8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006cb:	83 fa 01             	cmp    $0x1,%edx
  8006ce:	7e 0e                	jle    8006de <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8006d0:	8b 10                	mov    (%eax),%edx
  8006d2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006d5:	89 08                	mov    %ecx,(%eax)
  8006d7:	8b 02                	mov    (%edx),%eax
  8006d9:	8b 52 04             	mov    0x4(%edx),%edx
  8006dc:	eb 22                	jmp    800700 <getuint+0x38>
	else if (lflag)
  8006de:	85 d2                	test   %edx,%edx
  8006e0:	74 10                	je     8006f2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006e2:	8b 10                	mov    (%eax),%edx
  8006e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006e7:	89 08                	mov    %ecx,(%eax)
  8006e9:	8b 02                	mov    (%edx),%eax
  8006eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f0:	eb 0e                	jmp    800700 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006f2:	8b 10                	mov    (%eax),%edx
  8006f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006f7:	89 08                	mov    %ecx,(%eax)
  8006f9:	8b 02                	mov    (%edx),%eax
  8006fb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800708:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80070c:	8b 10                	mov    (%eax),%edx
  80070e:	3b 50 04             	cmp    0x4(%eax),%edx
  800711:	73 0a                	jae    80071d <sprintputch+0x1b>
		*b->buf++ = ch;
  800713:	8d 4a 01             	lea    0x1(%edx),%ecx
  800716:	89 08                	mov    %ecx,(%eax)
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	88 02                	mov    %al,(%edx)
}
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800725:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800728:	50                   	push   %eax
  800729:	ff 75 10             	pushl  0x10(%ebp)
  80072c:	ff 75 0c             	pushl  0xc(%ebp)
  80072f:	ff 75 08             	pushl  0x8(%ebp)
  800732:	e8 05 00 00 00       	call   80073c <vprintfmt>
	va_end(ap);
}
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    

0080073c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	57                   	push   %edi
  800740:	56                   	push   %esi
  800741:	53                   	push   %ebx
  800742:	83 ec 2c             	sub    $0x2c,%esp
  800745:	8b 75 08             	mov    0x8(%ebp),%esi
  800748:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80074b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80074e:	eb 12                	jmp    800762 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800750:	85 c0                	test   %eax,%eax
  800752:	0f 84 89 03 00 00    	je     800ae1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	53                   	push   %ebx
  80075c:	50                   	push   %eax
  80075d:	ff d6                	call   *%esi
  80075f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800762:	83 c7 01             	add    $0x1,%edi
  800765:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800769:	83 f8 25             	cmp    $0x25,%eax
  80076c:	75 e2                	jne    800750 <vprintfmt+0x14>
  80076e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800772:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800779:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800780:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800787:	ba 00 00 00 00       	mov    $0x0,%edx
  80078c:	eb 07                	jmp    800795 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800791:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800795:	8d 47 01             	lea    0x1(%edi),%eax
  800798:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80079b:	0f b6 07             	movzbl (%edi),%eax
  80079e:	0f b6 c8             	movzbl %al,%ecx
  8007a1:	83 e8 23             	sub    $0x23,%eax
  8007a4:	3c 55                	cmp    $0x55,%al
  8007a6:	0f 87 1a 03 00 00    	ja     800ac6 <vprintfmt+0x38a>
  8007ac:	0f b6 c0             	movzbl %al,%eax
  8007af:	ff 24 85 00 2d 80 00 	jmp    *0x802d00(,%eax,4)
  8007b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007b9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8007bd:	eb d6                	jmp    800795 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007ca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8007cd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8007d1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8007d4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8007d7:	83 fa 09             	cmp    $0x9,%edx
  8007da:	77 39                	ja     800815 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007dc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007df:	eb e9                	jmp    8007ca <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8d 48 04             	lea    0x4(%eax),%ecx
  8007e7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007ea:	8b 00                	mov    (%eax),%eax
  8007ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007f2:	eb 27                	jmp    80081b <vprintfmt+0xdf>
  8007f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fe:	0f 49 c8             	cmovns %eax,%ecx
  800801:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800804:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800807:	eb 8c                	jmp    800795 <vprintfmt+0x59>
  800809:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80080c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800813:	eb 80                	jmp    800795 <vprintfmt+0x59>
  800815:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800818:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80081b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80081f:	0f 89 70 ff ff ff    	jns    800795 <vprintfmt+0x59>
				width = precision, precision = -1;
  800825:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800828:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80082b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800832:	e9 5e ff ff ff       	jmp    800795 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800837:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80083d:	e9 53 ff ff ff       	jmp    800795 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8d 50 04             	lea    0x4(%eax),%edx
  800848:	89 55 14             	mov    %edx,0x14(%ebp)
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	53                   	push   %ebx
  80084f:	ff 30                	pushl  (%eax)
  800851:	ff d6                	call   *%esi
			break;
  800853:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800856:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800859:	e9 04 ff ff ff       	jmp    800762 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80085e:	8b 45 14             	mov    0x14(%ebp),%eax
  800861:	8d 50 04             	lea    0x4(%eax),%edx
  800864:	89 55 14             	mov    %edx,0x14(%ebp)
  800867:	8b 00                	mov    (%eax),%eax
  800869:	99                   	cltd   
  80086a:	31 d0                	xor    %edx,%eax
  80086c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80086e:	83 f8 0f             	cmp    $0xf,%eax
  800871:	7f 0b                	jg     80087e <vprintfmt+0x142>
  800873:	8b 14 85 60 2e 80 00 	mov    0x802e60(,%eax,4),%edx
  80087a:	85 d2                	test   %edx,%edx
  80087c:	75 18                	jne    800896 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80087e:	50                   	push   %eax
  80087f:	68 c7 2b 80 00       	push   $0x802bc7
  800884:	53                   	push   %ebx
  800885:	56                   	push   %esi
  800886:	e8 94 fe ff ff       	call   80071f <printfmt>
  80088b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800891:	e9 cc fe ff ff       	jmp    800762 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800896:	52                   	push   %edx
  800897:	68 fd 2f 80 00       	push   $0x802ffd
  80089c:	53                   	push   %ebx
  80089d:	56                   	push   %esi
  80089e:	e8 7c fe ff ff       	call   80071f <printfmt>
  8008a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008a9:	e9 b4 fe ff ff       	jmp    800762 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b1:	8d 50 04             	lea    0x4(%eax),%edx
  8008b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8008b9:	85 ff                	test   %edi,%edi
  8008bb:	b8 c0 2b 80 00       	mov    $0x802bc0,%eax
  8008c0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8008c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008c7:	0f 8e 94 00 00 00    	jle    800961 <vprintfmt+0x225>
  8008cd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8008d1:	0f 84 98 00 00 00    	je     80096f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008d7:	83 ec 08             	sub    $0x8,%esp
  8008da:	ff 75 d0             	pushl  -0x30(%ebp)
  8008dd:	57                   	push   %edi
  8008de:	e8 86 02 00 00       	call   800b69 <strnlen>
  8008e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008e6:	29 c1                	sub    %eax,%ecx
  8008e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008eb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008ee:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008f8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008fa:	eb 0f                	jmp    80090b <vprintfmt+0x1cf>
					putch(padc, putdat);
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	53                   	push   %ebx
  800900:	ff 75 e0             	pushl  -0x20(%ebp)
  800903:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800905:	83 ef 01             	sub    $0x1,%edi
  800908:	83 c4 10             	add    $0x10,%esp
  80090b:	85 ff                	test   %edi,%edi
  80090d:	7f ed                	jg     8008fc <vprintfmt+0x1c0>
  80090f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800912:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800915:	85 c9                	test   %ecx,%ecx
  800917:	b8 00 00 00 00       	mov    $0x0,%eax
  80091c:	0f 49 c1             	cmovns %ecx,%eax
  80091f:	29 c1                	sub    %eax,%ecx
  800921:	89 75 08             	mov    %esi,0x8(%ebp)
  800924:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800927:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80092a:	89 cb                	mov    %ecx,%ebx
  80092c:	eb 4d                	jmp    80097b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80092e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800932:	74 1b                	je     80094f <vprintfmt+0x213>
  800934:	0f be c0             	movsbl %al,%eax
  800937:	83 e8 20             	sub    $0x20,%eax
  80093a:	83 f8 5e             	cmp    $0x5e,%eax
  80093d:	76 10                	jbe    80094f <vprintfmt+0x213>
					putch('?', putdat);
  80093f:	83 ec 08             	sub    $0x8,%esp
  800942:	ff 75 0c             	pushl  0xc(%ebp)
  800945:	6a 3f                	push   $0x3f
  800947:	ff 55 08             	call   *0x8(%ebp)
  80094a:	83 c4 10             	add    $0x10,%esp
  80094d:	eb 0d                	jmp    80095c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80094f:	83 ec 08             	sub    $0x8,%esp
  800952:	ff 75 0c             	pushl  0xc(%ebp)
  800955:	52                   	push   %edx
  800956:	ff 55 08             	call   *0x8(%ebp)
  800959:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80095c:	83 eb 01             	sub    $0x1,%ebx
  80095f:	eb 1a                	jmp    80097b <vprintfmt+0x23f>
  800961:	89 75 08             	mov    %esi,0x8(%ebp)
  800964:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800967:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80096a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80096d:	eb 0c                	jmp    80097b <vprintfmt+0x23f>
  80096f:	89 75 08             	mov    %esi,0x8(%ebp)
  800972:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800975:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800978:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80097b:	83 c7 01             	add    $0x1,%edi
  80097e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800982:	0f be d0             	movsbl %al,%edx
  800985:	85 d2                	test   %edx,%edx
  800987:	74 23                	je     8009ac <vprintfmt+0x270>
  800989:	85 f6                	test   %esi,%esi
  80098b:	78 a1                	js     80092e <vprintfmt+0x1f2>
  80098d:	83 ee 01             	sub    $0x1,%esi
  800990:	79 9c                	jns    80092e <vprintfmt+0x1f2>
  800992:	89 df                	mov    %ebx,%edi
  800994:	8b 75 08             	mov    0x8(%ebp),%esi
  800997:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80099a:	eb 18                	jmp    8009b4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80099c:	83 ec 08             	sub    $0x8,%esp
  80099f:	53                   	push   %ebx
  8009a0:	6a 20                	push   $0x20
  8009a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009a4:	83 ef 01             	sub    $0x1,%edi
  8009a7:	83 c4 10             	add    $0x10,%esp
  8009aa:	eb 08                	jmp    8009b4 <vprintfmt+0x278>
  8009ac:	89 df                	mov    %ebx,%edi
  8009ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009b4:	85 ff                	test   %edi,%edi
  8009b6:	7f e4                	jg     80099c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009bb:	e9 a2 fd ff ff       	jmp    800762 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009c0:	83 fa 01             	cmp    $0x1,%edx
  8009c3:	7e 16                	jle    8009db <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8009c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c8:	8d 50 08             	lea    0x8(%eax),%edx
  8009cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ce:	8b 50 04             	mov    0x4(%eax),%edx
  8009d1:	8b 00                	mov    (%eax),%eax
  8009d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8009d9:	eb 32                	jmp    800a0d <vprintfmt+0x2d1>
	else if (lflag)
  8009db:	85 d2                	test   %edx,%edx
  8009dd:	74 18                	je     8009f7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8009df:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e2:	8d 50 04             	lea    0x4(%eax),%edx
  8009e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009e8:	8b 00                	mov    (%eax),%eax
  8009ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009ed:	89 c1                	mov    %eax,%ecx
  8009ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8009f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009f5:	eb 16                	jmp    800a0d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8009f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fa:	8d 50 04             	lea    0x4(%eax),%edx
  8009fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800a00:	8b 00                	mov    (%eax),%eax
  800a02:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a05:	89 c1                	mov    %eax,%ecx
  800a07:	c1 f9 1f             	sar    $0x1f,%ecx
  800a0a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a0d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a10:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a13:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a18:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a1c:	79 74                	jns    800a92 <vprintfmt+0x356>
				putch('-', putdat);
  800a1e:	83 ec 08             	sub    $0x8,%esp
  800a21:	53                   	push   %ebx
  800a22:	6a 2d                	push   $0x2d
  800a24:	ff d6                	call   *%esi
				num = -(long long) num;
  800a26:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a29:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800a2c:	f7 d8                	neg    %eax
  800a2e:	83 d2 00             	adc    $0x0,%edx
  800a31:	f7 da                	neg    %edx
  800a33:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800a36:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a3b:	eb 55                	jmp    800a92 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a3d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a40:	e8 83 fc ff ff       	call   8006c8 <getuint>
			base = 10;
  800a45:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a4a:	eb 46                	jmp    800a92 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a4c:	8d 45 14             	lea    0x14(%ebp),%eax
  800a4f:	e8 74 fc ff ff       	call   8006c8 <getuint>
			base = 8;
  800a54:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a59:	eb 37                	jmp    800a92 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800a5b:	83 ec 08             	sub    $0x8,%esp
  800a5e:	53                   	push   %ebx
  800a5f:	6a 30                	push   $0x30
  800a61:	ff d6                	call   *%esi
			putch('x', putdat);
  800a63:	83 c4 08             	add    $0x8,%esp
  800a66:	53                   	push   %ebx
  800a67:	6a 78                	push   $0x78
  800a69:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a6b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6e:	8d 50 04             	lea    0x4(%eax),%edx
  800a71:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a74:	8b 00                	mov    (%eax),%eax
  800a76:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a7b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a7e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a83:	eb 0d                	jmp    800a92 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a85:	8d 45 14             	lea    0x14(%ebp),%eax
  800a88:	e8 3b fc ff ff       	call   8006c8 <getuint>
			base = 16;
  800a8d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a92:	83 ec 0c             	sub    $0xc,%esp
  800a95:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a99:	57                   	push   %edi
  800a9a:	ff 75 e0             	pushl  -0x20(%ebp)
  800a9d:	51                   	push   %ecx
  800a9e:	52                   	push   %edx
  800a9f:	50                   	push   %eax
  800aa0:	89 da                	mov    %ebx,%edx
  800aa2:	89 f0                	mov    %esi,%eax
  800aa4:	e8 70 fb ff ff       	call   800619 <printnum>
			break;
  800aa9:	83 c4 20             	add    $0x20,%esp
  800aac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aaf:	e9 ae fc ff ff       	jmp    800762 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ab4:	83 ec 08             	sub    $0x8,%esp
  800ab7:	53                   	push   %ebx
  800ab8:	51                   	push   %ecx
  800ab9:	ff d6                	call   *%esi
			break;
  800abb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800abe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ac1:	e9 9c fc ff ff       	jmp    800762 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ac6:	83 ec 08             	sub    $0x8,%esp
  800ac9:	53                   	push   %ebx
  800aca:	6a 25                	push   $0x25
  800acc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ace:	83 c4 10             	add    $0x10,%esp
  800ad1:	eb 03                	jmp    800ad6 <vprintfmt+0x39a>
  800ad3:	83 ef 01             	sub    $0x1,%edi
  800ad6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ada:	75 f7                	jne    800ad3 <vprintfmt+0x397>
  800adc:	e9 81 fc ff ff       	jmp    800762 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800ae1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5f                   	pop    %edi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	83 ec 18             	sub    $0x18,%esp
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800af5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800af8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800afc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800aff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b06:	85 c0                	test   %eax,%eax
  800b08:	74 26                	je     800b30 <vsnprintf+0x47>
  800b0a:	85 d2                	test   %edx,%edx
  800b0c:	7e 22                	jle    800b30 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b0e:	ff 75 14             	pushl  0x14(%ebp)
  800b11:	ff 75 10             	pushl  0x10(%ebp)
  800b14:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b17:	50                   	push   %eax
  800b18:	68 02 07 80 00       	push   $0x800702
  800b1d:	e8 1a fc ff ff       	call   80073c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b22:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b25:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b2b:	83 c4 10             	add    $0x10,%esp
  800b2e:	eb 05                	jmp    800b35 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b30:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b3d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b40:	50                   	push   %eax
  800b41:	ff 75 10             	pushl  0x10(%ebp)
  800b44:	ff 75 0c             	pushl  0xc(%ebp)
  800b47:	ff 75 08             	pushl  0x8(%ebp)
  800b4a:	e8 9a ff ff ff       	call   800ae9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    

00800b51 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b57:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5c:	eb 03                	jmp    800b61 <strlen+0x10>
		n++;
  800b5e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b61:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b65:	75 f7                	jne    800b5e <strlen+0xd>
		n++;
	return n;
}
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	eb 03                	jmp    800b7c <strnlen+0x13>
		n++;
  800b79:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b7c:	39 c2                	cmp    %eax,%edx
  800b7e:	74 08                	je     800b88 <strnlen+0x1f>
  800b80:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b84:	75 f3                	jne    800b79 <strnlen+0x10>
  800b86:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	53                   	push   %ebx
  800b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b94:	89 c2                	mov    %eax,%edx
  800b96:	83 c2 01             	add    $0x1,%edx
  800b99:	83 c1 01             	add    $0x1,%ecx
  800b9c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ba0:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ba3:	84 db                	test   %bl,%bl
  800ba5:	75 ef                	jne    800b96 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <strcat>:

char *
strcat(char *dst, const char *src)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	53                   	push   %ebx
  800bae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bb1:	53                   	push   %ebx
  800bb2:	e8 9a ff ff ff       	call   800b51 <strlen>
  800bb7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800bba:	ff 75 0c             	pushl  0xc(%ebp)
  800bbd:	01 d8                	add    %ebx,%eax
  800bbf:	50                   	push   %eax
  800bc0:	e8 c5 ff ff ff       	call   800b8a <strcpy>
	return dst;
}
  800bc5:	89 d8                	mov    %ebx,%eax
  800bc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bca:	c9                   	leave  
  800bcb:	c3                   	ret    

00800bcc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
  800bd1:	8b 75 08             	mov    0x8(%ebp),%esi
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	89 f3                	mov    %esi,%ebx
  800bd9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bdc:	89 f2                	mov    %esi,%edx
  800bde:	eb 0f                	jmp    800bef <strncpy+0x23>
		*dst++ = *src;
  800be0:	83 c2 01             	add    $0x1,%edx
  800be3:	0f b6 01             	movzbl (%ecx),%eax
  800be6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800be9:	80 39 01             	cmpb   $0x1,(%ecx)
  800bec:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bef:	39 da                	cmp    %ebx,%edx
  800bf1:	75 ed                	jne    800be0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bf3:	89 f0                	mov    %esi,%eax
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
  800bfe:	8b 75 08             	mov    0x8(%ebp),%esi
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	8b 55 10             	mov    0x10(%ebp),%edx
  800c07:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c09:	85 d2                	test   %edx,%edx
  800c0b:	74 21                	je     800c2e <strlcpy+0x35>
  800c0d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c11:	89 f2                	mov    %esi,%edx
  800c13:	eb 09                	jmp    800c1e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c15:	83 c2 01             	add    $0x1,%edx
  800c18:	83 c1 01             	add    $0x1,%ecx
  800c1b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c1e:	39 c2                	cmp    %eax,%edx
  800c20:	74 09                	je     800c2b <strlcpy+0x32>
  800c22:	0f b6 19             	movzbl (%ecx),%ebx
  800c25:	84 db                	test   %bl,%bl
  800c27:	75 ec                	jne    800c15 <strlcpy+0x1c>
  800c29:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c2b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c2e:	29 f0                	sub    %esi,%eax
}
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c3d:	eb 06                	jmp    800c45 <strcmp+0x11>
		p++, q++;
  800c3f:	83 c1 01             	add    $0x1,%ecx
  800c42:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c45:	0f b6 01             	movzbl (%ecx),%eax
  800c48:	84 c0                	test   %al,%al
  800c4a:	74 04                	je     800c50 <strcmp+0x1c>
  800c4c:	3a 02                	cmp    (%edx),%al
  800c4e:	74 ef                	je     800c3f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c50:	0f b6 c0             	movzbl %al,%eax
  800c53:	0f b6 12             	movzbl (%edx),%edx
  800c56:	29 d0                	sub    %edx,%eax
}
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	53                   	push   %ebx
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c61:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c64:	89 c3                	mov    %eax,%ebx
  800c66:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c69:	eb 06                	jmp    800c71 <strncmp+0x17>
		n--, p++, q++;
  800c6b:	83 c0 01             	add    $0x1,%eax
  800c6e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c71:	39 d8                	cmp    %ebx,%eax
  800c73:	74 15                	je     800c8a <strncmp+0x30>
  800c75:	0f b6 08             	movzbl (%eax),%ecx
  800c78:	84 c9                	test   %cl,%cl
  800c7a:	74 04                	je     800c80 <strncmp+0x26>
  800c7c:	3a 0a                	cmp    (%edx),%cl
  800c7e:	74 eb                	je     800c6b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c80:	0f b6 00             	movzbl (%eax),%eax
  800c83:	0f b6 12             	movzbl (%edx),%edx
  800c86:	29 d0                	sub    %edx,%eax
  800c88:	eb 05                	jmp    800c8f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c8a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c8f:	5b                   	pop    %ebx
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	8b 45 08             	mov    0x8(%ebp),%eax
  800c98:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c9c:	eb 07                	jmp    800ca5 <strchr+0x13>
		if (*s == c)
  800c9e:	38 ca                	cmp    %cl,%dl
  800ca0:	74 0f                	je     800cb1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ca2:	83 c0 01             	add    $0x1,%eax
  800ca5:	0f b6 10             	movzbl (%eax),%edx
  800ca8:	84 d2                	test   %dl,%dl
  800caa:	75 f2                	jne    800c9e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800cac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cbd:	eb 03                	jmp    800cc2 <strfind+0xf>
  800cbf:	83 c0 01             	add    $0x1,%eax
  800cc2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cc5:	38 ca                	cmp    %cl,%dl
  800cc7:	74 04                	je     800ccd <strfind+0x1a>
  800cc9:	84 d2                	test   %dl,%dl
  800ccb:	75 f2                	jne    800cbf <strfind+0xc>
			break;
	return (char *) s;
}
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cd8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cdb:	85 c9                	test   %ecx,%ecx
  800cdd:	74 36                	je     800d15 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cdf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ce5:	75 28                	jne    800d0f <memset+0x40>
  800ce7:	f6 c1 03             	test   $0x3,%cl
  800cea:	75 23                	jne    800d0f <memset+0x40>
		c &= 0xFF;
  800cec:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cf0:	89 d3                	mov    %edx,%ebx
  800cf2:	c1 e3 08             	shl    $0x8,%ebx
  800cf5:	89 d6                	mov    %edx,%esi
  800cf7:	c1 e6 18             	shl    $0x18,%esi
  800cfa:	89 d0                	mov    %edx,%eax
  800cfc:	c1 e0 10             	shl    $0x10,%eax
  800cff:	09 f0                	or     %esi,%eax
  800d01:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800d03:	89 d8                	mov    %ebx,%eax
  800d05:	09 d0                	or     %edx,%eax
  800d07:	c1 e9 02             	shr    $0x2,%ecx
  800d0a:	fc                   	cld    
  800d0b:	f3 ab                	rep stos %eax,%es:(%edi)
  800d0d:	eb 06                	jmp    800d15 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d12:	fc                   	cld    
  800d13:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d15:	89 f8                	mov    %edi,%eax
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	8b 45 08             	mov    0x8(%ebp),%eax
  800d24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d27:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d2a:	39 c6                	cmp    %eax,%esi
  800d2c:	73 35                	jae    800d63 <memmove+0x47>
  800d2e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d31:	39 d0                	cmp    %edx,%eax
  800d33:	73 2e                	jae    800d63 <memmove+0x47>
		s += n;
		d += n;
  800d35:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d38:	89 d6                	mov    %edx,%esi
  800d3a:	09 fe                	or     %edi,%esi
  800d3c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d42:	75 13                	jne    800d57 <memmove+0x3b>
  800d44:	f6 c1 03             	test   $0x3,%cl
  800d47:	75 0e                	jne    800d57 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d49:	83 ef 04             	sub    $0x4,%edi
  800d4c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d4f:	c1 e9 02             	shr    $0x2,%ecx
  800d52:	fd                   	std    
  800d53:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d55:	eb 09                	jmp    800d60 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d57:	83 ef 01             	sub    $0x1,%edi
  800d5a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d5d:	fd                   	std    
  800d5e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d60:	fc                   	cld    
  800d61:	eb 1d                	jmp    800d80 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d63:	89 f2                	mov    %esi,%edx
  800d65:	09 c2                	or     %eax,%edx
  800d67:	f6 c2 03             	test   $0x3,%dl
  800d6a:	75 0f                	jne    800d7b <memmove+0x5f>
  800d6c:	f6 c1 03             	test   $0x3,%cl
  800d6f:	75 0a                	jne    800d7b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d71:	c1 e9 02             	shr    $0x2,%ecx
  800d74:	89 c7                	mov    %eax,%edi
  800d76:	fc                   	cld    
  800d77:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d79:	eb 05                	jmp    800d80 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d7b:	89 c7                	mov    %eax,%edi
  800d7d:	fc                   	cld    
  800d7e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d87:	ff 75 10             	pushl  0x10(%ebp)
  800d8a:	ff 75 0c             	pushl  0xc(%ebp)
  800d8d:	ff 75 08             	pushl  0x8(%ebp)
  800d90:	e8 87 ff ff ff       	call   800d1c <memmove>
}
  800d95:	c9                   	leave  
  800d96:	c3                   	ret    

00800d97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
  800d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da2:	89 c6                	mov    %eax,%esi
  800da4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800da7:	eb 1a                	jmp    800dc3 <memcmp+0x2c>
		if (*s1 != *s2)
  800da9:	0f b6 08             	movzbl (%eax),%ecx
  800dac:	0f b6 1a             	movzbl (%edx),%ebx
  800daf:	38 d9                	cmp    %bl,%cl
  800db1:	74 0a                	je     800dbd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800db3:	0f b6 c1             	movzbl %cl,%eax
  800db6:	0f b6 db             	movzbl %bl,%ebx
  800db9:	29 d8                	sub    %ebx,%eax
  800dbb:	eb 0f                	jmp    800dcc <memcmp+0x35>
		s1++, s2++;
  800dbd:	83 c0 01             	add    $0x1,%eax
  800dc0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dc3:	39 f0                	cmp    %esi,%eax
  800dc5:	75 e2                	jne    800da9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dcc:	5b                   	pop    %ebx
  800dcd:	5e                   	pop    %esi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	53                   	push   %ebx
  800dd4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800dd7:	89 c1                	mov    %eax,%ecx
  800dd9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ddc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800de0:	eb 0a                	jmp    800dec <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800de2:	0f b6 10             	movzbl (%eax),%edx
  800de5:	39 da                	cmp    %ebx,%edx
  800de7:	74 07                	je     800df0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800de9:	83 c0 01             	add    $0x1,%eax
  800dec:	39 c8                	cmp    %ecx,%eax
  800dee:	72 f2                	jb     800de2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800df0:	5b                   	pop    %ebx
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dff:	eb 03                	jmp    800e04 <strtol+0x11>
		s++;
  800e01:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e04:	0f b6 01             	movzbl (%ecx),%eax
  800e07:	3c 20                	cmp    $0x20,%al
  800e09:	74 f6                	je     800e01 <strtol+0xe>
  800e0b:	3c 09                	cmp    $0x9,%al
  800e0d:	74 f2                	je     800e01 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e0f:	3c 2b                	cmp    $0x2b,%al
  800e11:	75 0a                	jne    800e1d <strtol+0x2a>
		s++;
  800e13:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e16:	bf 00 00 00 00       	mov    $0x0,%edi
  800e1b:	eb 11                	jmp    800e2e <strtol+0x3b>
  800e1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e22:	3c 2d                	cmp    $0x2d,%al
  800e24:	75 08                	jne    800e2e <strtol+0x3b>
		s++, neg = 1;
  800e26:	83 c1 01             	add    $0x1,%ecx
  800e29:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e2e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e34:	75 15                	jne    800e4b <strtol+0x58>
  800e36:	80 39 30             	cmpb   $0x30,(%ecx)
  800e39:	75 10                	jne    800e4b <strtol+0x58>
  800e3b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e3f:	75 7c                	jne    800ebd <strtol+0xca>
		s += 2, base = 16;
  800e41:	83 c1 02             	add    $0x2,%ecx
  800e44:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e49:	eb 16                	jmp    800e61 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e4b:	85 db                	test   %ebx,%ebx
  800e4d:	75 12                	jne    800e61 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e4f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e54:	80 39 30             	cmpb   $0x30,(%ecx)
  800e57:	75 08                	jne    800e61 <strtol+0x6e>
		s++, base = 8;
  800e59:	83 c1 01             	add    $0x1,%ecx
  800e5c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e61:	b8 00 00 00 00       	mov    $0x0,%eax
  800e66:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e69:	0f b6 11             	movzbl (%ecx),%edx
  800e6c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e6f:	89 f3                	mov    %esi,%ebx
  800e71:	80 fb 09             	cmp    $0x9,%bl
  800e74:	77 08                	ja     800e7e <strtol+0x8b>
			dig = *s - '0';
  800e76:	0f be d2             	movsbl %dl,%edx
  800e79:	83 ea 30             	sub    $0x30,%edx
  800e7c:	eb 22                	jmp    800ea0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e7e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e81:	89 f3                	mov    %esi,%ebx
  800e83:	80 fb 19             	cmp    $0x19,%bl
  800e86:	77 08                	ja     800e90 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e88:	0f be d2             	movsbl %dl,%edx
  800e8b:	83 ea 57             	sub    $0x57,%edx
  800e8e:	eb 10                	jmp    800ea0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e90:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e93:	89 f3                	mov    %esi,%ebx
  800e95:	80 fb 19             	cmp    $0x19,%bl
  800e98:	77 16                	ja     800eb0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e9a:	0f be d2             	movsbl %dl,%edx
  800e9d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ea0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ea3:	7d 0b                	jge    800eb0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ea5:	83 c1 01             	add    $0x1,%ecx
  800ea8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800eac:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800eae:	eb b9                	jmp    800e69 <strtol+0x76>

	if (endptr)
  800eb0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eb4:	74 0d                	je     800ec3 <strtol+0xd0>
		*endptr = (char *) s;
  800eb6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800eb9:	89 0e                	mov    %ecx,(%esi)
  800ebb:	eb 06                	jmp    800ec3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ebd:	85 db                	test   %ebx,%ebx
  800ebf:	74 98                	je     800e59 <strtol+0x66>
  800ec1:	eb 9e                	jmp    800e61 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ec3:	89 c2                	mov    %eax,%edx
  800ec5:	f7 da                	neg    %edx
  800ec7:	85 ff                	test   %edi,%edi
  800ec9:	0f 45 c2             	cmovne %edx,%eax
}
  800ecc:	5b                   	pop    %ebx
  800ecd:	5e                   	pop    %esi
  800ece:	5f                   	pop    %edi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	57                   	push   %edi
  800ed5:	56                   	push   %esi
  800ed6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed7:	b8 00 00 00 00       	mov    $0x0,%eax
  800edc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee2:	89 c3                	mov    %eax,%ebx
  800ee4:	89 c7                	mov    %eax,%edi
  800ee6:	89 c6                	mov    %eax,%esi
  800ee8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800eea:	5b                   	pop    %ebx
  800eeb:	5e                   	pop    %esi
  800eec:	5f                   	pop    %edi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <sys_cgetc>:

int
sys_cgetc(void)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	57                   	push   %edi
  800ef3:	56                   	push   %esi
  800ef4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef5:	ba 00 00 00 00       	mov    $0x0,%edx
  800efa:	b8 01 00 00 00       	mov    $0x1,%eax
  800eff:	89 d1                	mov    %edx,%ecx
  800f01:	89 d3                	mov    %edx,%ebx
  800f03:	89 d7                	mov    %edx,%edi
  800f05:	89 d6                	mov    %edx,%esi
  800f07:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f09:	5b                   	pop    %ebx
  800f0a:	5e                   	pop    %esi
  800f0b:	5f                   	pop    %edi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1c:	b8 03 00 00 00       	mov    $0x3,%eax
  800f21:	8b 55 08             	mov    0x8(%ebp),%edx
  800f24:	89 cb                	mov    %ecx,%ebx
  800f26:	89 cf                	mov    %ecx,%edi
  800f28:	89 ce                	mov    %ecx,%esi
  800f2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	7e 17                	jle    800f47 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f30:	83 ec 0c             	sub    $0xc,%esp
  800f33:	50                   	push   %eax
  800f34:	6a 03                	push   $0x3
  800f36:	68 bf 2e 80 00       	push   $0x802ebf
  800f3b:	6a 23                	push   $0x23
  800f3d:	68 dc 2e 80 00       	push   $0x802edc
  800f42:	e8 e5 f5 ff ff       	call   80052c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4a:	5b                   	pop    %ebx
  800f4b:	5e                   	pop    %esi
  800f4c:	5f                   	pop    %edi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f55:	ba 00 00 00 00       	mov    $0x0,%edx
  800f5a:	b8 02 00 00 00       	mov    $0x2,%eax
  800f5f:	89 d1                	mov    %edx,%ecx
  800f61:	89 d3                	mov    %edx,%ebx
  800f63:	89 d7                	mov    %edx,%edi
  800f65:	89 d6                	mov    %edx,%esi
  800f67:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	5f                   	pop    %edi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    

00800f6e <sys_yield>:

void
sys_yield(void)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f74:	ba 00 00 00 00       	mov    $0x0,%edx
  800f79:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f7e:	89 d1                	mov    %edx,%ecx
  800f80:	89 d3                	mov    %edx,%ebx
  800f82:	89 d7                	mov    %edx,%edi
  800f84:	89 d6                	mov    %edx,%esi
  800f86:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	57                   	push   %edi
  800f91:	56                   	push   %esi
  800f92:	53                   	push   %ebx
  800f93:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f96:	be 00 00 00 00       	mov    $0x0,%esi
  800f9b:	b8 04 00 00 00       	mov    $0x4,%eax
  800fa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa9:	89 f7                	mov    %esi,%edi
  800fab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fad:	85 c0                	test   %eax,%eax
  800faf:	7e 17                	jle    800fc8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb1:	83 ec 0c             	sub    $0xc,%esp
  800fb4:	50                   	push   %eax
  800fb5:	6a 04                	push   $0x4
  800fb7:	68 bf 2e 80 00       	push   $0x802ebf
  800fbc:	6a 23                	push   $0x23
  800fbe:	68 dc 2e 80 00       	push   $0x802edc
  800fc3:	e8 64 f5 ff ff       	call   80052c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5f                   	pop    %edi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	53                   	push   %ebx
  800fd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd9:	b8 05 00 00 00       	mov    $0x5,%eax
  800fde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fea:	8b 75 18             	mov    0x18(%ebp),%esi
  800fed:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	7e 17                	jle    80100a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	50                   	push   %eax
  800ff7:	6a 05                	push   $0x5
  800ff9:	68 bf 2e 80 00       	push   $0x802ebf
  800ffe:	6a 23                	push   $0x23
  801000:	68 dc 2e 80 00       	push   $0x802edc
  801005:	e8 22 f5 ff ff       	call   80052c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80100a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100d:	5b                   	pop    %ebx
  80100e:	5e                   	pop    %esi
  80100f:	5f                   	pop    %edi
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    

00801012 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
  801018:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801020:	b8 06 00 00 00       	mov    $0x6,%eax
  801025:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801028:	8b 55 08             	mov    0x8(%ebp),%edx
  80102b:	89 df                	mov    %ebx,%edi
  80102d:	89 de                	mov    %ebx,%esi
  80102f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801031:	85 c0                	test   %eax,%eax
  801033:	7e 17                	jle    80104c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801035:	83 ec 0c             	sub    $0xc,%esp
  801038:	50                   	push   %eax
  801039:	6a 06                	push   $0x6
  80103b:	68 bf 2e 80 00       	push   $0x802ebf
  801040:	6a 23                	push   $0x23
  801042:	68 dc 2e 80 00       	push   $0x802edc
  801047:	e8 e0 f4 ff ff       	call   80052c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80104c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	57                   	push   %edi
  801058:	56                   	push   %esi
  801059:	53                   	push   %ebx
  80105a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801062:	b8 08 00 00 00       	mov    $0x8,%eax
  801067:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106a:	8b 55 08             	mov    0x8(%ebp),%edx
  80106d:	89 df                	mov    %ebx,%edi
  80106f:	89 de                	mov    %ebx,%esi
  801071:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801073:	85 c0                	test   %eax,%eax
  801075:	7e 17                	jle    80108e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	50                   	push   %eax
  80107b:	6a 08                	push   $0x8
  80107d:	68 bf 2e 80 00       	push   $0x802ebf
  801082:	6a 23                	push   $0x23
  801084:	68 dc 2e 80 00       	push   $0x802edc
  801089:	e8 9e f4 ff ff       	call   80052c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80108e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801091:	5b                   	pop    %ebx
  801092:	5e                   	pop    %esi
  801093:	5f                   	pop    %edi
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	57                   	push   %edi
  80109a:	56                   	push   %esi
  80109b:	53                   	push   %ebx
  80109c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a4:	b8 09 00 00 00       	mov    $0x9,%eax
  8010a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8010af:	89 df                	mov    %ebx,%edi
  8010b1:	89 de                	mov    %ebx,%esi
  8010b3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	7e 17                	jle    8010d0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b9:	83 ec 0c             	sub    $0xc,%esp
  8010bc:	50                   	push   %eax
  8010bd:	6a 09                	push   $0x9
  8010bf:	68 bf 2e 80 00       	push   $0x802ebf
  8010c4:	6a 23                	push   $0x23
  8010c6:	68 dc 2e 80 00       	push   $0x802edc
  8010cb:	e8 5c f4 ff ff       	call   80052c <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d3:	5b                   	pop    %ebx
  8010d4:	5e                   	pop    %esi
  8010d5:	5f                   	pop    %edi
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    

008010d8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	57                   	push   %edi
  8010dc:	56                   	push   %esi
  8010dd:	53                   	push   %ebx
  8010de:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f1:	89 df                	mov    %ebx,%edi
  8010f3:	89 de                	mov    %ebx,%esi
  8010f5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	7e 17                	jle    801112 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	50                   	push   %eax
  8010ff:	6a 0a                	push   $0xa
  801101:	68 bf 2e 80 00       	push   $0x802ebf
  801106:	6a 23                	push   $0x23
  801108:	68 dc 2e 80 00       	push   $0x802edc
  80110d:	e8 1a f4 ff ff       	call   80052c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801115:	5b                   	pop    %ebx
  801116:	5e                   	pop    %esi
  801117:	5f                   	pop    %edi
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	57                   	push   %edi
  80111e:	56                   	push   %esi
  80111f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801120:	be 00 00 00 00       	mov    $0x0,%esi
  801125:	b8 0c 00 00 00       	mov    $0xc,%eax
  80112a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112d:	8b 55 08             	mov    0x8(%ebp),%edx
  801130:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801133:	8b 7d 14             	mov    0x14(%ebp),%edi
  801136:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801138:	5b                   	pop    %ebx
  801139:	5e                   	pop    %esi
  80113a:	5f                   	pop    %edi
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	57                   	push   %edi
  801141:	56                   	push   %esi
  801142:	53                   	push   %ebx
  801143:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801146:	b9 00 00 00 00       	mov    $0x0,%ecx
  80114b:	b8 0d 00 00 00       	mov    $0xd,%eax
  801150:	8b 55 08             	mov    0x8(%ebp),%edx
  801153:	89 cb                	mov    %ecx,%ebx
  801155:	89 cf                	mov    %ecx,%edi
  801157:	89 ce                	mov    %ecx,%esi
  801159:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80115b:	85 c0                	test   %eax,%eax
  80115d:	7e 17                	jle    801176 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80115f:	83 ec 0c             	sub    $0xc,%esp
  801162:	50                   	push   %eax
  801163:	6a 0d                	push   $0xd
  801165:	68 bf 2e 80 00       	push   $0x802ebf
  80116a:	6a 23                	push   $0x23
  80116c:	68 dc 2e 80 00       	push   $0x802edc
  801171:	e8 b6 f3 ff ff       	call   80052c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801176:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801179:	5b                   	pop    %ebx
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	53                   	push   %ebx
  801182:	83 ec 04             	sub    $0x4,%esp
  801185:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801188:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  80118a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80118e:	74 11                	je     8011a1 <pgfault+0x23>
  801190:	89 d8                	mov    %ebx,%eax
  801192:	c1 e8 0c             	shr    $0xc,%eax
  801195:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80119c:	f6 c4 08             	test   $0x8,%ah
  80119f:	75 14                	jne    8011b5 <pgfault+0x37>
		panic("faulting access");
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	68 ea 2e 80 00       	push   $0x802eea
  8011a9:	6a 1d                	push   $0x1d
  8011ab:	68 fa 2e 80 00       	push   $0x802efa
  8011b0:	e8 77 f3 ff ff       	call   80052c <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	6a 07                	push   $0x7
  8011ba:	68 00 f0 7f 00       	push   $0x7ff000
  8011bf:	6a 00                	push   $0x0
  8011c1:	e8 c7 fd ff ff       	call   800f8d <sys_page_alloc>
	if (r < 0) {
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	79 12                	jns    8011df <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  8011cd:	50                   	push   %eax
  8011ce:	68 05 2f 80 00       	push   $0x802f05
  8011d3:	6a 2b                	push   $0x2b
  8011d5:	68 fa 2e 80 00       	push   $0x802efa
  8011da:	e8 4d f3 ff ff       	call   80052c <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  8011df:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  8011e5:	83 ec 04             	sub    $0x4,%esp
  8011e8:	68 00 10 00 00       	push   $0x1000
  8011ed:	53                   	push   %ebx
  8011ee:	68 00 f0 7f 00       	push   $0x7ff000
  8011f3:	e8 8c fb ff ff       	call   800d84 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  8011f8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8011ff:	53                   	push   %ebx
  801200:	6a 00                	push   $0x0
  801202:	68 00 f0 7f 00       	push   $0x7ff000
  801207:	6a 00                	push   $0x0
  801209:	e8 c2 fd ff ff       	call   800fd0 <sys_page_map>
	if (r < 0) {
  80120e:	83 c4 20             	add    $0x20,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	79 12                	jns    801227 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  801215:	50                   	push   %eax
  801216:	68 05 2f 80 00       	push   $0x802f05
  80121b:	6a 32                	push   $0x32
  80121d:	68 fa 2e 80 00       	push   $0x802efa
  801222:	e8 05 f3 ff ff       	call   80052c <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  801227:	83 ec 08             	sub    $0x8,%esp
  80122a:	68 00 f0 7f 00       	push   $0x7ff000
  80122f:	6a 00                	push   $0x0
  801231:	e8 dc fd ff ff       	call   801012 <sys_page_unmap>
	if (r < 0) {
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	85 c0                	test   %eax,%eax
  80123b:	79 12                	jns    80124f <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80123d:	50                   	push   %eax
  80123e:	68 05 2f 80 00       	push   $0x802f05
  801243:	6a 36                	push   $0x36
  801245:	68 fa 2e 80 00       	push   $0x802efa
  80124a:	e8 dd f2 ff ff       	call   80052c <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80124f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801252:	c9                   	leave  
  801253:	c3                   	ret    

00801254 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	57                   	push   %edi
  801258:	56                   	push   %esi
  801259:	53                   	push   %ebx
  80125a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80125d:	68 7e 11 80 00       	push   $0x80117e
  801262:	e8 6c 13 00 00       	call   8025d3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801267:	b8 07 00 00 00       	mov    $0x7,%eax
  80126c:	cd 30                	int    $0x30
  80126e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	85 c0                	test   %eax,%eax
  801276:	79 17                	jns    80128f <fork+0x3b>
		panic("fork fault %e");
  801278:	83 ec 04             	sub    $0x4,%esp
  80127b:	68 1e 2f 80 00       	push   $0x802f1e
  801280:	68 83 00 00 00       	push   $0x83
  801285:	68 fa 2e 80 00       	push   $0x802efa
  80128a:	e8 9d f2 ff ff       	call   80052c <_panic>
  80128f:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801291:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801295:	75 21                	jne    8012b8 <fork+0x64>
		thisenv = &envs[ENVX(sys_getenvid())];
  801297:	e8 b3 fc ff ff       	call   800f4f <sys_getenvid>
  80129c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012a9:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  8012ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b3:	e9 61 01 00 00       	jmp    801419 <fork+0x1c5>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8012b8:	83 ec 04             	sub    $0x4,%esp
  8012bb:	6a 07                	push   $0x7
  8012bd:	68 00 f0 bf ee       	push   $0xeebff000
  8012c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012c5:	e8 c3 fc ff ff       	call   800f8d <sys_page_alloc>
  8012ca:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8012cd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8012d2:	89 d8                	mov    %ebx,%eax
  8012d4:	c1 e8 16             	shr    $0x16,%eax
  8012d7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012de:	a8 01                	test   $0x1,%al
  8012e0:	0f 84 fc 00 00 00    	je     8013e2 <fork+0x18e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  8012e6:	89 d8                	mov    %ebx,%eax
  8012e8:	c1 e8 0c             	shr    $0xc,%eax
  8012eb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8012f2:	f6 c2 01             	test   $0x1,%dl
  8012f5:	0f 84 e7 00 00 00    	je     8013e2 <fork+0x18e>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  8012fb:	89 c6                	mov    %eax,%esi
  8012fd:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801300:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801307:	f6 c6 04             	test   $0x4,%dh
  80130a:	74 39                	je     801345 <fork+0xf1>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80130c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801313:	83 ec 0c             	sub    $0xc,%esp
  801316:	25 07 0e 00 00       	and    $0xe07,%eax
  80131b:	50                   	push   %eax
  80131c:	56                   	push   %esi
  80131d:	57                   	push   %edi
  80131e:	56                   	push   %esi
  80131f:	6a 00                	push   $0x0
  801321:	e8 aa fc ff ff       	call   800fd0 <sys_page_map>
		if (r < 0) {
  801326:	83 c4 20             	add    $0x20,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	0f 89 b1 00 00 00    	jns    8013e2 <fork+0x18e>
		    	panic("sys page map fault %e");
  801331:	83 ec 04             	sub    $0x4,%esp
  801334:	68 2c 2f 80 00       	push   $0x802f2c
  801339:	6a 53                	push   $0x53
  80133b:	68 fa 2e 80 00       	push   $0x802efa
  801340:	e8 e7 f1 ff ff       	call   80052c <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801345:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80134c:	f6 c2 02             	test   $0x2,%dl
  80134f:	75 0c                	jne    80135d <fork+0x109>
  801351:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801358:	f6 c4 08             	test   $0x8,%ah
  80135b:	74 5b                	je     8013b8 <fork+0x164>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80135d:	83 ec 0c             	sub    $0xc,%esp
  801360:	68 05 08 00 00       	push   $0x805
  801365:	56                   	push   %esi
  801366:	57                   	push   %edi
  801367:	56                   	push   %esi
  801368:	6a 00                	push   $0x0
  80136a:	e8 61 fc ff ff       	call   800fd0 <sys_page_map>
		if (r < 0) {
  80136f:	83 c4 20             	add    $0x20,%esp
  801372:	85 c0                	test   %eax,%eax
  801374:	79 14                	jns    80138a <fork+0x136>
		    	panic("sys page map fault %e");
  801376:	83 ec 04             	sub    $0x4,%esp
  801379:	68 2c 2f 80 00       	push   $0x802f2c
  80137e:	6a 5a                	push   $0x5a
  801380:	68 fa 2e 80 00       	push   $0x802efa
  801385:	e8 a2 f1 ff ff       	call   80052c <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80138a:	83 ec 0c             	sub    $0xc,%esp
  80138d:	68 05 08 00 00       	push   $0x805
  801392:	56                   	push   %esi
  801393:	6a 00                	push   $0x0
  801395:	56                   	push   %esi
  801396:	6a 00                	push   $0x0
  801398:	e8 33 fc ff ff       	call   800fd0 <sys_page_map>
		if (r < 0) {
  80139d:	83 c4 20             	add    $0x20,%esp
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	79 3e                	jns    8013e2 <fork+0x18e>
		    	panic("sys page map fault %e");
  8013a4:	83 ec 04             	sub    $0x4,%esp
  8013a7:	68 2c 2f 80 00       	push   $0x802f2c
  8013ac:	6a 5e                	push   $0x5e
  8013ae:	68 fa 2e 80 00       	push   $0x802efa
  8013b3:	e8 74 f1 ff ff       	call   80052c <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8013b8:	83 ec 0c             	sub    $0xc,%esp
  8013bb:	6a 05                	push   $0x5
  8013bd:	56                   	push   %esi
  8013be:	57                   	push   %edi
  8013bf:	56                   	push   %esi
  8013c0:	6a 00                	push   $0x0
  8013c2:	e8 09 fc ff ff       	call   800fd0 <sys_page_map>
		if (r < 0) {
  8013c7:	83 c4 20             	add    $0x20,%esp
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	79 14                	jns    8013e2 <fork+0x18e>
		    	panic("sys page map fault %e");
  8013ce:	83 ec 04             	sub    $0x4,%esp
  8013d1:	68 2c 2f 80 00       	push   $0x802f2c
  8013d6:	6a 63                	push   $0x63
  8013d8:	68 fa 2e 80 00       	push   $0x802efa
  8013dd:	e8 4a f1 ff ff       	call   80052c <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8013e2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013e8:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8013ee:	0f 85 de fe ff ff    	jne    8012d2 <fork+0x7e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8013f4:	a1 04 50 80 00       	mov    0x805004,%eax
  8013f9:	8b 40 64             	mov    0x64(%eax),%eax
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	50                   	push   %eax
  801400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801403:	57                   	push   %edi
  801404:	e8 cf fc ff ff       	call   8010d8 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801409:	83 c4 08             	add    $0x8,%esp
  80140c:	6a 02                	push   $0x2
  80140e:	57                   	push   %edi
  80140f:	e8 40 fc ff ff       	call   801054 <sys_env_set_status>
	
	return envid;
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801419:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80141c:	5b                   	pop    %ebx
  80141d:	5e                   	pop    %esi
  80141e:	5f                   	pop    %edi
  80141f:	5d                   	pop    %ebp
  801420:	c3                   	ret    

00801421 <sfork>:

// Challenge!
int
sfork(void)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801427:	68 42 2f 80 00       	push   $0x802f42
  80142c:	68 a1 00 00 00       	push   $0xa1
  801431:	68 fa 2e 80 00       	push   $0x802efa
  801436:	e8 f1 f0 ff ff       	call   80052c <_panic>

0080143b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80143e:	8b 45 08             	mov    0x8(%ebp),%eax
  801441:	05 00 00 00 30       	add    $0x30000000,%eax
  801446:	c1 e8 0c             	shr    $0xc,%eax
}
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    

0080144b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80144e:	8b 45 08             	mov    0x8(%ebp),%eax
  801451:	05 00 00 00 30       	add    $0x30000000,%eax
  801456:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80145b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    

00801462 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801468:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80146d:	89 c2                	mov    %eax,%edx
  80146f:	c1 ea 16             	shr    $0x16,%edx
  801472:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801479:	f6 c2 01             	test   $0x1,%dl
  80147c:	74 11                	je     80148f <fd_alloc+0x2d>
  80147e:	89 c2                	mov    %eax,%edx
  801480:	c1 ea 0c             	shr    $0xc,%edx
  801483:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80148a:	f6 c2 01             	test   $0x1,%dl
  80148d:	75 09                	jne    801498 <fd_alloc+0x36>
			*fd_store = fd;
  80148f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801491:	b8 00 00 00 00       	mov    $0x0,%eax
  801496:	eb 17                	jmp    8014af <fd_alloc+0x4d>
  801498:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80149d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014a2:	75 c9                	jne    80146d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014a4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014aa:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014af:	5d                   	pop    %ebp
  8014b0:	c3                   	ret    

008014b1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014b7:	83 f8 1f             	cmp    $0x1f,%eax
  8014ba:	77 36                	ja     8014f2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014bc:	c1 e0 0c             	shl    $0xc,%eax
  8014bf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014c4:	89 c2                	mov    %eax,%edx
  8014c6:	c1 ea 16             	shr    $0x16,%edx
  8014c9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014d0:	f6 c2 01             	test   $0x1,%dl
  8014d3:	74 24                	je     8014f9 <fd_lookup+0x48>
  8014d5:	89 c2                	mov    %eax,%edx
  8014d7:	c1 ea 0c             	shr    $0xc,%edx
  8014da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014e1:	f6 c2 01             	test   $0x1,%dl
  8014e4:	74 1a                	je     801500 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e9:	89 02                	mov    %eax,(%edx)
	return 0;
  8014eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f0:	eb 13                	jmp    801505 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f7:	eb 0c                	jmp    801505 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014fe:	eb 05                	jmp    801505 <fd_lookup+0x54>
  801500:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801505:	5d                   	pop    %ebp
  801506:	c3                   	ret    

00801507 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	83 ec 08             	sub    $0x8,%esp
  80150d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801510:	ba d4 2f 80 00       	mov    $0x802fd4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801515:	eb 13                	jmp    80152a <dev_lookup+0x23>
  801517:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80151a:	39 08                	cmp    %ecx,(%eax)
  80151c:	75 0c                	jne    80152a <dev_lookup+0x23>
			*dev = devtab[i];
  80151e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801521:	89 01                	mov    %eax,(%ecx)
			return 0;
  801523:	b8 00 00 00 00       	mov    $0x0,%eax
  801528:	eb 2e                	jmp    801558 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80152a:	8b 02                	mov    (%edx),%eax
  80152c:	85 c0                	test   %eax,%eax
  80152e:	75 e7                	jne    801517 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801530:	a1 04 50 80 00       	mov    0x805004,%eax
  801535:	8b 40 48             	mov    0x48(%eax),%eax
  801538:	83 ec 04             	sub    $0x4,%esp
  80153b:	51                   	push   %ecx
  80153c:	50                   	push   %eax
  80153d:	68 58 2f 80 00       	push   $0x802f58
  801542:	e8 be f0 ff ff       	call   800605 <cprintf>
	*dev = 0;
  801547:	8b 45 0c             	mov    0xc(%ebp),%eax
  80154a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801558:	c9                   	leave  
  801559:	c3                   	ret    

0080155a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80155a:	55                   	push   %ebp
  80155b:	89 e5                	mov    %esp,%ebp
  80155d:	56                   	push   %esi
  80155e:	53                   	push   %ebx
  80155f:	83 ec 10             	sub    $0x10,%esp
  801562:	8b 75 08             	mov    0x8(%ebp),%esi
  801565:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801568:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156b:	50                   	push   %eax
  80156c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801572:	c1 e8 0c             	shr    $0xc,%eax
  801575:	50                   	push   %eax
  801576:	e8 36 ff ff ff       	call   8014b1 <fd_lookup>
  80157b:	83 c4 08             	add    $0x8,%esp
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 05                	js     801587 <fd_close+0x2d>
	    || fd != fd2)
  801582:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801585:	74 0c                	je     801593 <fd_close+0x39>
		return (must_exist ? r : 0);
  801587:	84 db                	test   %bl,%bl
  801589:	ba 00 00 00 00       	mov    $0x0,%edx
  80158e:	0f 44 c2             	cmove  %edx,%eax
  801591:	eb 41                	jmp    8015d4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801593:	83 ec 08             	sub    $0x8,%esp
  801596:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	ff 36                	pushl  (%esi)
  80159c:	e8 66 ff ff ff       	call   801507 <dev_lookup>
  8015a1:	89 c3                	mov    %eax,%ebx
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	85 c0                	test   %eax,%eax
  8015a8:	78 1a                	js     8015c4 <fd_close+0x6a>
		if (dev->dev_close)
  8015aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ad:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015b0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	74 0b                	je     8015c4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015b9:	83 ec 0c             	sub    $0xc,%esp
  8015bc:	56                   	push   %esi
  8015bd:	ff d0                	call   *%eax
  8015bf:	89 c3                	mov    %eax,%ebx
  8015c1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015c4:	83 ec 08             	sub    $0x8,%esp
  8015c7:	56                   	push   %esi
  8015c8:	6a 00                	push   $0x0
  8015ca:	e8 43 fa ff ff       	call   801012 <sys_page_unmap>
	return r;
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	89 d8                	mov    %ebx,%eax
}
  8015d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d7:	5b                   	pop    %ebx
  8015d8:	5e                   	pop    %esi
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    

008015db <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	ff 75 08             	pushl  0x8(%ebp)
  8015e8:	e8 c4 fe ff ff       	call   8014b1 <fd_lookup>
  8015ed:	83 c4 08             	add    $0x8,%esp
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 10                	js     801604 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	6a 01                	push   $0x1
  8015f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8015fc:	e8 59 ff ff ff       	call   80155a <fd_close>
  801601:	83 c4 10             	add    $0x10,%esp
}
  801604:	c9                   	leave  
  801605:	c3                   	ret    

00801606 <close_all>:

void
close_all(void)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	53                   	push   %ebx
  80160a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80160d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801612:	83 ec 0c             	sub    $0xc,%esp
  801615:	53                   	push   %ebx
  801616:	e8 c0 ff ff ff       	call   8015db <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80161b:	83 c3 01             	add    $0x1,%ebx
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	83 fb 20             	cmp    $0x20,%ebx
  801624:	75 ec                	jne    801612 <close_all+0xc>
		close(i);
}
  801626:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801629:	c9                   	leave  
  80162a:	c3                   	ret    

0080162b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	57                   	push   %edi
  80162f:	56                   	push   %esi
  801630:	53                   	push   %ebx
  801631:	83 ec 2c             	sub    $0x2c,%esp
  801634:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801637:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80163a:	50                   	push   %eax
  80163b:	ff 75 08             	pushl  0x8(%ebp)
  80163e:	e8 6e fe ff ff       	call   8014b1 <fd_lookup>
  801643:	83 c4 08             	add    $0x8,%esp
  801646:	85 c0                	test   %eax,%eax
  801648:	0f 88 c1 00 00 00    	js     80170f <dup+0xe4>
		return r;
	close(newfdnum);
  80164e:	83 ec 0c             	sub    $0xc,%esp
  801651:	56                   	push   %esi
  801652:	e8 84 ff ff ff       	call   8015db <close>

	newfd = INDEX2FD(newfdnum);
  801657:	89 f3                	mov    %esi,%ebx
  801659:	c1 e3 0c             	shl    $0xc,%ebx
  80165c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801662:	83 c4 04             	add    $0x4,%esp
  801665:	ff 75 e4             	pushl  -0x1c(%ebp)
  801668:	e8 de fd ff ff       	call   80144b <fd2data>
  80166d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80166f:	89 1c 24             	mov    %ebx,(%esp)
  801672:	e8 d4 fd ff ff       	call   80144b <fd2data>
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80167d:	89 f8                	mov    %edi,%eax
  80167f:	c1 e8 16             	shr    $0x16,%eax
  801682:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801689:	a8 01                	test   $0x1,%al
  80168b:	74 37                	je     8016c4 <dup+0x99>
  80168d:	89 f8                	mov    %edi,%eax
  80168f:	c1 e8 0c             	shr    $0xc,%eax
  801692:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801699:	f6 c2 01             	test   $0x1,%dl
  80169c:	74 26                	je     8016c4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80169e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016a5:	83 ec 0c             	sub    $0xc,%esp
  8016a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8016ad:	50                   	push   %eax
  8016ae:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016b1:	6a 00                	push   $0x0
  8016b3:	57                   	push   %edi
  8016b4:	6a 00                	push   $0x0
  8016b6:	e8 15 f9 ff ff       	call   800fd0 <sys_page_map>
  8016bb:	89 c7                	mov    %eax,%edi
  8016bd:	83 c4 20             	add    $0x20,%esp
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 2e                	js     8016f2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016c7:	89 d0                	mov    %edx,%eax
  8016c9:	c1 e8 0c             	shr    $0xc,%eax
  8016cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016d3:	83 ec 0c             	sub    $0xc,%esp
  8016d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8016db:	50                   	push   %eax
  8016dc:	53                   	push   %ebx
  8016dd:	6a 00                	push   $0x0
  8016df:	52                   	push   %edx
  8016e0:	6a 00                	push   $0x0
  8016e2:	e8 e9 f8 ff ff       	call   800fd0 <sys_page_map>
  8016e7:	89 c7                	mov    %eax,%edi
  8016e9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016ec:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016ee:	85 ff                	test   %edi,%edi
  8016f0:	79 1d                	jns    80170f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016f2:	83 ec 08             	sub    $0x8,%esp
  8016f5:	53                   	push   %ebx
  8016f6:	6a 00                	push   $0x0
  8016f8:	e8 15 f9 ff ff       	call   801012 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016fd:	83 c4 08             	add    $0x8,%esp
  801700:	ff 75 d4             	pushl  -0x2c(%ebp)
  801703:	6a 00                	push   $0x0
  801705:	e8 08 f9 ff ff       	call   801012 <sys_page_unmap>
	return r;
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	89 f8                	mov    %edi,%eax
}
  80170f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801712:	5b                   	pop    %ebx
  801713:	5e                   	pop    %esi
  801714:	5f                   	pop    %edi
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    

00801717 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	53                   	push   %ebx
  80171b:	83 ec 14             	sub    $0x14,%esp
  80171e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801721:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801724:	50                   	push   %eax
  801725:	53                   	push   %ebx
  801726:	e8 86 fd ff ff       	call   8014b1 <fd_lookup>
  80172b:	83 c4 08             	add    $0x8,%esp
  80172e:	89 c2                	mov    %eax,%edx
  801730:	85 c0                	test   %eax,%eax
  801732:	78 6d                	js     8017a1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801734:	83 ec 08             	sub    $0x8,%esp
  801737:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173a:	50                   	push   %eax
  80173b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173e:	ff 30                	pushl  (%eax)
  801740:	e8 c2 fd ff ff       	call   801507 <dev_lookup>
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	85 c0                	test   %eax,%eax
  80174a:	78 4c                	js     801798 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80174c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80174f:	8b 42 08             	mov    0x8(%edx),%eax
  801752:	83 e0 03             	and    $0x3,%eax
  801755:	83 f8 01             	cmp    $0x1,%eax
  801758:	75 21                	jne    80177b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80175a:	a1 04 50 80 00       	mov    0x805004,%eax
  80175f:	8b 40 48             	mov    0x48(%eax),%eax
  801762:	83 ec 04             	sub    $0x4,%esp
  801765:	53                   	push   %ebx
  801766:	50                   	push   %eax
  801767:	68 99 2f 80 00       	push   $0x802f99
  80176c:	e8 94 ee ff ff       	call   800605 <cprintf>
		return -E_INVAL;
  801771:	83 c4 10             	add    $0x10,%esp
  801774:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801779:	eb 26                	jmp    8017a1 <read+0x8a>
	}
	if (!dev->dev_read)
  80177b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177e:	8b 40 08             	mov    0x8(%eax),%eax
  801781:	85 c0                	test   %eax,%eax
  801783:	74 17                	je     80179c <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801785:	83 ec 04             	sub    $0x4,%esp
  801788:	ff 75 10             	pushl  0x10(%ebp)
  80178b:	ff 75 0c             	pushl  0xc(%ebp)
  80178e:	52                   	push   %edx
  80178f:	ff d0                	call   *%eax
  801791:	89 c2                	mov    %eax,%edx
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	eb 09                	jmp    8017a1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801798:	89 c2                	mov    %eax,%edx
  80179a:	eb 05                	jmp    8017a1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80179c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8017a1:	89 d0                	mov    %edx,%eax
  8017a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a6:	c9                   	leave  
  8017a7:	c3                   	ret    

008017a8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	57                   	push   %edi
  8017ac:	56                   	push   %esi
  8017ad:	53                   	push   %ebx
  8017ae:	83 ec 0c             	sub    $0xc,%esp
  8017b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017b4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017bc:	eb 21                	jmp    8017df <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017be:	83 ec 04             	sub    $0x4,%esp
  8017c1:	89 f0                	mov    %esi,%eax
  8017c3:	29 d8                	sub    %ebx,%eax
  8017c5:	50                   	push   %eax
  8017c6:	89 d8                	mov    %ebx,%eax
  8017c8:	03 45 0c             	add    0xc(%ebp),%eax
  8017cb:	50                   	push   %eax
  8017cc:	57                   	push   %edi
  8017cd:	e8 45 ff ff ff       	call   801717 <read>
		if (m < 0)
  8017d2:	83 c4 10             	add    $0x10,%esp
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	78 10                	js     8017e9 <readn+0x41>
			return m;
		if (m == 0)
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	74 0a                	je     8017e7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017dd:	01 c3                	add    %eax,%ebx
  8017df:	39 f3                	cmp    %esi,%ebx
  8017e1:	72 db                	jb     8017be <readn+0x16>
  8017e3:	89 d8                	mov    %ebx,%eax
  8017e5:	eb 02                	jmp    8017e9 <readn+0x41>
  8017e7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ec:	5b                   	pop    %ebx
  8017ed:	5e                   	pop    %esi
  8017ee:	5f                   	pop    %edi
  8017ef:	5d                   	pop    %ebp
  8017f0:	c3                   	ret    

008017f1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	53                   	push   %ebx
  8017f5:	83 ec 14             	sub    $0x14,%esp
  8017f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017fe:	50                   	push   %eax
  8017ff:	53                   	push   %ebx
  801800:	e8 ac fc ff ff       	call   8014b1 <fd_lookup>
  801805:	83 c4 08             	add    $0x8,%esp
  801808:	89 c2                	mov    %eax,%edx
  80180a:	85 c0                	test   %eax,%eax
  80180c:	78 68                	js     801876 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80180e:	83 ec 08             	sub    $0x8,%esp
  801811:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801814:	50                   	push   %eax
  801815:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801818:	ff 30                	pushl  (%eax)
  80181a:	e8 e8 fc ff ff       	call   801507 <dev_lookup>
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	85 c0                	test   %eax,%eax
  801824:	78 47                	js     80186d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801826:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801829:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80182d:	75 21                	jne    801850 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80182f:	a1 04 50 80 00       	mov    0x805004,%eax
  801834:	8b 40 48             	mov    0x48(%eax),%eax
  801837:	83 ec 04             	sub    $0x4,%esp
  80183a:	53                   	push   %ebx
  80183b:	50                   	push   %eax
  80183c:	68 b5 2f 80 00       	push   $0x802fb5
  801841:	e8 bf ed ff ff       	call   800605 <cprintf>
		return -E_INVAL;
  801846:	83 c4 10             	add    $0x10,%esp
  801849:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80184e:	eb 26                	jmp    801876 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801850:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801853:	8b 52 0c             	mov    0xc(%edx),%edx
  801856:	85 d2                	test   %edx,%edx
  801858:	74 17                	je     801871 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80185a:	83 ec 04             	sub    $0x4,%esp
  80185d:	ff 75 10             	pushl  0x10(%ebp)
  801860:	ff 75 0c             	pushl  0xc(%ebp)
  801863:	50                   	push   %eax
  801864:	ff d2                	call   *%edx
  801866:	89 c2                	mov    %eax,%edx
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	eb 09                	jmp    801876 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80186d:	89 c2                	mov    %eax,%edx
  80186f:	eb 05                	jmp    801876 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801871:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801876:	89 d0                	mov    %edx,%eax
  801878:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187b:	c9                   	leave  
  80187c:	c3                   	ret    

0080187d <seek>:

int
seek(int fdnum, off_t offset)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801883:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801886:	50                   	push   %eax
  801887:	ff 75 08             	pushl  0x8(%ebp)
  80188a:	e8 22 fc ff ff       	call   8014b1 <fd_lookup>
  80188f:	83 c4 08             	add    $0x8,%esp
  801892:	85 c0                	test   %eax,%eax
  801894:	78 0e                	js     8018a4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801896:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801899:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80189f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    

008018a6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	53                   	push   %ebx
  8018aa:	83 ec 14             	sub    $0x14,%esp
  8018ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b3:	50                   	push   %eax
  8018b4:	53                   	push   %ebx
  8018b5:	e8 f7 fb ff ff       	call   8014b1 <fd_lookup>
  8018ba:	83 c4 08             	add    $0x8,%esp
  8018bd:	89 c2                	mov    %eax,%edx
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	78 65                	js     801928 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c3:	83 ec 08             	sub    $0x8,%esp
  8018c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c9:	50                   	push   %eax
  8018ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018cd:	ff 30                	pushl  (%eax)
  8018cf:	e8 33 fc ff ff       	call   801507 <dev_lookup>
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	78 44                	js     80191f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018de:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018e2:	75 21                	jne    801905 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018e4:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018e9:	8b 40 48             	mov    0x48(%eax),%eax
  8018ec:	83 ec 04             	sub    $0x4,%esp
  8018ef:	53                   	push   %ebx
  8018f0:	50                   	push   %eax
  8018f1:	68 78 2f 80 00       	push   $0x802f78
  8018f6:	e8 0a ed ff ff       	call   800605 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801903:	eb 23                	jmp    801928 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801905:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801908:	8b 52 18             	mov    0x18(%edx),%edx
  80190b:	85 d2                	test   %edx,%edx
  80190d:	74 14                	je     801923 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	ff 75 0c             	pushl  0xc(%ebp)
  801915:	50                   	push   %eax
  801916:	ff d2                	call   *%edx
  801918:	89 c2                	mov    %eax,%edx
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	eb 09                	jmp    801928 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80191f:	89 c2                	mov    %eax,%edx
  801921:	eb 05                	jmp    801928 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801923:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801928:	89 d0                	mov    %edx,%eax
  80192a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192d:	c9                   	leave  
  80192e:	c3                   	ret    

0080192f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	53                   	push   %ebx
  801933:	83 ec 14             	sub    $0x14,%esp
  801936:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801939:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80193c:	50                   	push   %eax
  80193d:	ff 75 08             	pushl  0x8(%ebp)
  801940:	e8 6c fb ff ff       	call   8014b1 <fd_lookup>
  801945:	83 c4 08             	add    $0x8,%esp
  801948:	89 c2                	mov    %eax,%edx
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 58                	js     8019a6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80194e:	83 ec 08             	sub    $0x8,%esp
  801951:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801954:	50                   	push   %eax
  801955:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801958:	ff 30                	pushl  (%eax)
  80195a:	e8 a8 fb ff ff       	call   801507 <dev_lookup>
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	85 c0                	test   %eax,%eax
  801964:	78 37                	js     80199d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801966:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801969:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80196d:	74 32                	je     8019a1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80196f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801972:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801979:	00 00 00 
	stat->st_isdir = 0;
  80197c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801983:	00 00 00 
	stat->st_dev = dev;
  801986:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80198c:	83 ec 08             	sub    $0x8,%esp
  80198f:	53                   	push   %ebx
  801990:	ff 75 f0             	pushl  -0x10(%ebp)
  801993:	ff 50 14             	call   *0x14(%eax)
  801996:	89 c2                	mov    %eax,%edx
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	eb 09                	jmp    8019a6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80199d:	89 c2                	mov    %eax,%edx
  80199f:	eb 05                	jmp    8019a6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019a1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019a6:	89 d0                	mov    %edx,%eax
  8019a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ab:	c9                   	leave  
  8019ac:	c3                   	ret    

008019ad <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	56                   	push   %esi
  8019b1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019b2:	83 ec 08             	sub    $0x8,%esp
  8019b5:	6a 00                	push   $0x0
  8019b7:	ff 75 08             	pushl  0x8(%ebp)
  8019ba:	e8 e3 01 00 00       	call   801ba2 <open>
  8019bf:	89 c3                	mov    %eax,%ebx
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	78 1b                	js     8019e3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019c8:	83 ec 08             	sub    $0x8,%esp
  8019cb:	ff 75 0c             	pushl  0xc(%ebp)
  8019ce:	50                   	push   %eax
  8019cf:	e8 5b ff ff ff       	call   80192f <fstat>
  8019d4:	89 c6                	mov    %eax,%esi
	close(fd);
  8019d6:	89 1c 24             	mov    %ebx,(%esp)
  8019d9:	e8 fd fb ff ff       	call   8015db <close>
	return r;
  8019de:	83 c4 10             	add    $0x10,%esp
  8019e1:	89 f0                	mov    %esi,%eax
}
  8019e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e6:	5b                   	pop    %ebx
  8019e7:	5e                   	pop    %esi
  8019e8:	5d                   	pop    %ebp
  8019e9:	c3                   	ret    

008019ea <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	56                   	push   %esi
  8019ee:	53                   	push   %ebx
  8019ef:	89 c6                	mov    %eax,%esi
  8019f1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019f3:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019fa:	75 12                	jne    801a0e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019fc:	83 ec 0c             	sub    $0xc,%esp
  8019ff:	6a 01                	push   $0x1
  801a01:	e8 30 0d 00 00       	call   802736 <ipc_find_env>
  801a06:	a3 00 50 80 00       	mov    %eax,0x805000
  801a0b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a0e:	6a 07                	push   $0x7
  801a10:	68 00 60 80 00       	push   $0x806000
  801a15:	56                   	push   %esi
  801a16:	ff 35 00 50 80 00    	pushl  0x805000
  801a1c:	e8 b3 0c 00 00       	call   8026d4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a21:	83 c4 0c             	add    $0xc,%esp
  801a24:	6a 00                	push   $0x0
  801a26:	53                   	push   %ebx
  801a27:	6a 00                	push   $0x0
  801a29:	e8 34 0c 00 00       	call   802662 <ipc_recv>
}
  801a2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a31:	5b                   	pop    %ebx
  801a32:	5e                   	pop    %esi
  801a33:	5d                   	pop    %ebp
  801a34:	c3                   	ret    

00801a35 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a41:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a49:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a53:	b8 02 00 00 00       	mov    $0x2,%eax
  801a58:	e8 8d ff ff ff       	call   8019ea <fsipc>
}
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a65:	8b 45 08             	mov    0x8(%ebp),%eax
  801a68:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6b:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a70:	ba 00 00 00 00       	mov    $0x0,%edx
  801a75:	b8 06 00 00 00       	mov    $0x6,%eax
  801a7a:	e8 6b ff ff ff       	call   8019ea <fsipc>
}
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    

00801a81 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	53                   	push   %ebx
  801a85:	83 ec 04             	sub    $0x4,%esp
  801a88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a91:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a96:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9b:	b8 05 00 00 00       	mov    $0x5,%eax
  801aa0:	e8 45 ff ff ff       	call   8019ea <fsipc>
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 2c                	js     801ad5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801aa9:	83 ec 08             	sub    $0x8,%esp
  801aac:	68 00 60 80 00       	push   $0x806000
  801ab1:	53                   	push   %ebx
  801ab2:	e8 d3 f0 ff ff       	call   800b8a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ab7:	a1 80 60 80 00       	mov    0x806080,%eax
  801abc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ac2:	a1 84 60 80 00       	mov    0x806084,%eax
  801ac7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ad5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad8:	c9                   	leave  
  801ad9:	c3                   	ret    

00801ada <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	83 ec 0c             	sub    $0xc,%esp
  801ae0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ae3:	8b 55 08             	mov    0x8(%ebp),%edx
  801ae6:	8b 52 0c             	mov    0xc(%edx),%edx
  801ae9:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801aef:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801af4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801af9:	0f 47 c2             	cmova  %edx,%eax
  801afc:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b01:	50                   	push   %eax
  801b02:	ff 75 0c             	pushl  0xc(%ebp)
  801b05:	68 08 60 80 00       	push   $0x806008
  801b0a:	e8 0d f2 ff ff       	call   800d1c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b14:	b8 04 00 00 00       	mov    $0x4,%eax
  801b19:	e8 cc fe ff ff       	call   8019ea <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	56                   	push   %esi
  801b24:	53                   	push   %ebx
  801b25:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b28:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b2e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b33:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b39:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3e:	b8 03 00 00 00       	mov    $0x3,%eax
  801b43:	e8 a2 fe ff ff       	call   8019ea <fsipc>
  801b48:	89 c3                	mov    %eax,%ebx
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	78 4b                	js     801b99 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b4e:	39 c6                	cmp    %eax,%esi
  801b50:	73 16                	jae    801b68 <devfile_read+0x48>
  801b52:	68 e4 2f 80 00       	push   $0x802fe4
  801b57:	68 eb 2f 80 00       	push   $0x802feb
  801b5c:	6a 7c                	push   $0x7c
  801b5e:	68 00 30 80 00       	push   $0x803000
  801b63:	e8 c4 e9 ff ff       	call   80052c <_panic>
	assert(r <= PGSIZE);
  801b68:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b6d:	7e 16                	jle    801b85 <devfile_read+0x65>
  801b6f:	68 0b 30 80 00       	push   $0x80300b
  801b74:	68 eb 2f 80 00       	push   $0x802feb
  801b79:	6a 7d                	push   $0x7d
  801b7b:	68 00 30 80 00       	push   $0x803000
  801b80:	e8 a7 e9 ff ff       	call   80052c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b85:	83 ec 04             	sub    $0x4,%esp
  801b88:	50                   	push   %eax
  801b89:	68 00 60 80 00       	push   $0x806000
  801b8e:	ff 75 0c             	pushl  0xc(%ebp)
  801b91:	e8 86 f1 ff ff       	call   800d1c <memmove>
	return r;
  801b96:	83 c4 10             	add    $0x10,%esp
}
  801b99:	89 d8                	mov    %ebx,%eax
  801b9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9e:	5b                   	pop    %ebx
  801b9f:	5e                   	pop    %esi
  801ba0:	5d                   	pop    %ebp
  801ba1:	c3                   	ret    

00801ba2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	53                   	push   %ebx
  801ba6:	83 ec 20             	sub    $0x20,%esp
  801ba9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bac:	53                   	push   %ebx
  801bad:	e8 9f ef ff ff       	call   800b51 <strlen>
  801bb2:	83 c4 10             	add    $0x10,%esp
  801bb5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bba:	7f 67                	jg     801c23 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bbc:	83 ec 0c             	sub    $0xc,%esp
  801bbf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc2:	50                   	push   %eax
  801bc3:	e8 9a f8 ff ff       	call   801462 <fd_alloc>
  801bc8:	83 c4 10             	add    $0x10,%esp
		return r;
  801bcb:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	78 57                	js     801c28 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bd1:	83 ec 08             	sub    $0x8,%esp
  801bd4:	53                   	push   %ebx
  801bd5:	68 00 60 80 00       	push   $0x806000
  801bda:	e8 ab ef ff ff       	call   800b8a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be2:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801be7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bea:	b8 01 00 00 00       	mov    $0x1,%eax
  801bef:	e8 f6 fd ff ff       	call   8019ea <fsipc>
  801bf4:	89 c3                	mov    %eax,%ebx
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	79 14                	jns    801c11 <open+0x6f>
		fd_close(fd, 0);
  801bfd:	83 ec 08             	sub    $0x8,%esp
  801c00:	6a 00                	push   $0x0
  801c02:	ff 75 f4             	pushl  -0xc(%ebp)
  801c05:	e8 50 f9 ff ff       	call   80155a <fd_close>
		return r;
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	89 da                	mov    %ebx,%edx
  801c0f:	eb 17                	jmp    801c28 <open+0x86>
	}

	return fd2num(fd);
  801c11:	83 ec 0c             	sub    $0xc,%esp
  801c14:	ff 75 f4             	pushl  -0xc(%ebp)
  801c17:	e8 1f f8 ff ff       	call   80143b <fd2num>
  801c1c:	89 c2                	mov    %eax,%edx
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	eb 05                	jmp    801c28 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c23:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c28:	89 d0                	mov    %edx,%eax
  801c2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c2d:	c9                   	leave  
  801c2e:	c3                   	ret    

00801c2f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c35:	ba 00 00 00 00       	mov    $0x0,%edx
  801c3a:	b8 08 00 00 00       	mov    $0x8,%eax
  801c3f:	e8 a6 fd ff ff       	call   8019ea <fsipc>
}
  801c44:	c9                   	leave  
  801c45:	c3                   	ret    

00801c46 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	57                   	push   %edi
  801c4a:	56                   	push   %esi
  801c4b:	53                   	push   %ebx
  801c4c:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c52:	6a 00                	push   $0x0
  801c54:	ff 75 08             	pushl  0x8(%ebp)
  801c57:	e8 46 ff ff ff       	call   801ba2 <open>
  801c5c:	89 c7                	mov    %eax,%edi
  801c5e:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c64:	83 c4 10             	add    $0x10,%esp
  801c67:	85 c0                	test   %eax,%eax
  801c69:	0f 88 89 04 00 00    	js     8020f8 <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c6f:	83 ec 04             	sub    $0x4,%esp
  801c72:	68 00 02 00 00       	push   $0x200
  801c77:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c7d:	50                   	push   %eax
  801c7e:	57                   	push   %edi
  801c7f:	e8 24 fb ff ff       	call   8017a8 <readn>
  801c84:	83 c4 10             	add    $0x10,%esp
  801c87:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c8c:	75 0c                	jne    801c9a <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801c8e:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c95:	45 4c 46 
  801c98:	74 33                	je     801ccd <spawn+0x87>
		close(fd);
  801c9a:	83 ec 0c             	sub    $0xc,%esp
  801c9d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ca3:	e8 33 f9 ff ff       	call   8015db <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801ca8:	83 c4 0c             	add    $0xc,%esp
  801cab:	68 7f 45 4c 46       	push   $0x464c457f
  801cb0:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801cb6:	68 17 30 80 00       	push   $0x803017
  801cbb:	e8 45 e9 ff ff       	call   800605 <cprintf>
		return -E_NOT_EXEC;
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801cc8:	e9 de 04 00 00       	jmp    8021ab <spawn+0x565>
  801ccd:	b8 07 00 00 00       	mov    $0x7,%eax
  801cd2:	cd 30                	int    $0x30
  801cd4:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801cda:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801ce0:	85 c0                	test   %eax,%eax
  801ce2:	0f 88 1b 04 00 00    	js     802103 <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801ce8:	89 c6                	mov    %eax,%esi
  801cea:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801cf0:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801cf3:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801cf9:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801cff:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d06:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d0c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d12:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d17:	be 00 00 00 00       	mov    $0x0,%esi
  801d1c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d1f:	eb 13                	jmp    801d34 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801d21:	83 ec 0c             	sub    $0xc,%esp
  801d24:	50                   	push   %eax
  801d25:	e8 27 ee ff ff       	call   800b51 <strlen>
  801d2a:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d2e:	83 c3 01             	add    $0x1,%ebx
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d3b:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	75 df                	jne    801d21 <spawn+0xdb>
  801d42:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801d48:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d4e:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d53:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d55:	89 fa                	mov    %edi,%edx
  801d57:	83 e2 fc             	and    $0xfffffffc,%edx
  801d5a:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d61:	29 c2                	sub    %eax,%edx
  801d63:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d69:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d6c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d71:	0f 86 a2 03 00 00    	jbe    802119 <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d77:	83 ec 04             	sub    $0x4,%esp
  801d7a:	6a 07                	push   $0x7
  801d7c:	68 00 00 40 00       	push   $0x400000
  801d81:	6a 00                	push   $0x0
  801d83:	e8 05 f2 ff ff       	call   800f8d <sys_page_alloc>
  801d88:	83 c4 10             	add    $0x10,%esp
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	0f 88 90 03 00 00    	js     802123 <spawn+0x4dd>
  801d93:	be 00 00 00 00       	mov    $0x0,%esi
  801d98:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801da1:	eb 30                	jmp    801dd3 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801da3:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801da9:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801daf:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801db2:	83 ec 08             	sub    $0x8,%esp
  801db5:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801db8:	57                   	push   %edi
  801db9:	e8 cc ed ff ff       	call   800b8a <strcpy>
		string_store += strlen(argv[i]) + 1;
  801dbe:	83 c4 04             	add    $0x4,%esp
  801dc1:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801dc4:	e8 88 ed ff ff       	call   800b51 <strlen>
  801dc9:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801dcd:	83 c6 01             	add    $0x1,%esi
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801dd9:	7f c8                	jg     801da3 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801ddb:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801de1:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801de7:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801dee:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801df4:	74 19                	je     801e0f <spawn+0x1c9>
  801df6:	68 a4 30 80 00       	push   $0x8030a4
  801dfb:	68 eb 2f 80 00       	push   $0x802feb
  801e00:	68 f2 00 00 00       	push   $0xf2
  801e05:	68 31 30 80 00       	push   $0x803031
  801e0a:	e8 1d e7 ff ff       	call   80052c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e0f:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801e15:	89 f8                	mov    %edi,%eax
  801e17:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e1c:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801e1f:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e25:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e28:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801e2e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e34:	83 ec 0c             	sub    $0xc,%esp
  801e37:	6a 07                	push   $0x7
  801e39:	68 00 d0 bf ee       	push   $0xeebfd000
  801e3e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e44:	68 00 00 40 00       	push   $0x400000
  801e49:	6a 00                	push   $0x0
  801e4b:	e8 80 f1 ff ff       	call   800fd0 <sys_page_map>
  801e50:	89 c3                	mov    %eax,%ebx
  801e52:	83 c4 20             	add    $0x20,%esp
  801e55:	85 c0                	test   %eax,%eax
  801e57:	0f 88 3c 03 00 00    	js     802199 <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e5d:	83 ec 08             	sub    $0x8,%esp
  801e60:	68 00 00 40 00       	push   $0x400000
  801e65:	6a 00                	push   $0x0
  801e67:	e8 a6 f1 ff ff       	call   801012 <sys_page_unmap>
  801e6c:	89 c3                	mov    %eax,%ebx
  801e6e:	83 c4 10             	add    $0x10,%esp
  801e71:	85 c0                	test   %eax,%eax
  801e73:	0f 88 20 03 00 00    	js     802199 <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e79:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801e7f:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e86:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e8c:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801e93:	00 00 00 
  801e96:	e9 88 01 00 00       	jmp    802023 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801e9b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ea1:	83 38 01             	cmpl   $0x1,(%eax)
  801ea4:	0f 85 6b 01 00 00    	jne    802015 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801eaa:	89 c2                	mov    %eax,%edx
  801eac:	8b 40 18             	mov    0x18(%eax),%eax
  801eaf:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801eb5:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801eb8:	83 f8 01             	cmp    $0x1,%eax
  801ebb:	19 c0                	sbb    %eax,%eax
  801ebd:	83 e0 fe             	and    $0xfffffffe,%eax
  801ec0:	83 c0 07             	add    $0x7,%eax
  801ec3:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ec9:	89 d0                	mov    %edx,%eax
  801ecb:	8b 7a 04             	mov    0x4(%edx),%edi
  801ece:	89 f9                	mov    %edi,%ecx
  801ed0:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801ed6:	8b 7a 10             	mov    0x10(%edx),%edi
  801ed9:	8b 52 14             	mov    0x14(%edx),%edx
  801edc:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801ee2:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801ee5:	89 f0                	mov    %esi,%eax
  801ee7:	25 ff 0f 00 00       	and    $0xfff,%eax
  801eec:	74 14                	je     801f02 <spawn+0x2bc>
		va -= i;
  801eee:	29 c6                	sub    %eax,%esi
		memsz += i;
  801ef0:	01 c2                	add    %eax,%edx
  801ef2:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801ef8:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801efa:	29 c1                	sub    %eax,%ecx
  801efc:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f02:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f07:	e9 f7 00 00 00       	jmp    802003 <spawn+0x3bd>
		if (i >= filesz) {
  801f0c:	39 fb                	cmp    %edi,%ebx
  801f0e:	72 27                	jb     801f37 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f10:	83 ec 04             	sub    $0x4,%esp
  801f13:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f19:	56                   	push   %esi
  801f1a:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f20:	e8 68 f0 ff ff       	call   800f8d <sys_page_alloc>
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	0f 89 c7 00 00 00    	jns    801ff7 <spawn+0x3b1>
  801f30:	89 c3                	mov    %eax,%ebx
  801f32:	e9 fd 01 00 00       	jmp    802134 <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f37:	83 ec 04             	sub    $0x4,%esp
  801f3a:	6a 07                	push   $0x7
  801f3c:	68 00 00 40 00       	push   $0x400000
  801f41:	6a 00                	push   $0x0
  801f43:	e8 45 f0 ff ff       	call   800f8d <sys_page_alloc>
  801f48:	83 c4 10             	add    $0x10,%esp
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	0f 88 d7 01 00 00    	js     80212a <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f53:	83 ec 08             	sub    $0x8,%esp
  801f56:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f5c:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801f62:	50                   	push   %eax
  801f63:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f69:	e8 0f f9 ff ff       	call   80187d <seek>
  801f6e:	83 c4 10             	add    $0x10,%esp
  801f71:	85 c0                	test   %eax,%eax
  801f73:	0f 88 b5 01 00 00    	js     80212e <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f79:	83 ec 04             	sub    $0x4,%esp
  801f7c:	89 f8                	mov    %edi,%eax
  801f7e:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801f84:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f89:	ba 00 10 00 00       	mov    $0x1000,%edx
  801f8e:	0f 47 c2             	cmova  %edx,%eax
  801f91:	50                   	push   %eax
  801f92:	68 00 00 40 00       	push   $0x400000
  801f97:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f9d:	e8 06 f8 ff ff       	call   8017a8 <readn>
  801fa2:	83 c4 10             	add    $0x10,%esp
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	0f 88 85 01 00 00    	js     802132 <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801fad:	83 ec 0c             	sub    $0xc,%esp
  801fb0:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fb6:	56                   	push   %esi
  801fb7:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801fbd:	68 00 00 40 00       	push   $0x400000
  801fc2:	6a 00                	push   $0x0
  801fc4:	e8 07 f0 ff ff       	call   800fd0 <sys_page_map>
  801fc9:	83 c4 20             	add    $0x20,%esp
  801fcc:	85 c0                	test   %eax,%eax
  801fce:	79 15                	jns    801fe5 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801fd0:	50                   	push   %eax
  801fd1:	68 3d 30 80 00       	push   $0x80303d
  801fd6:	68 25 01 00 00       	push   $0x125
  801fdb:	68 31 30 80 00       	push   $0x803031
  801fe0:	e8 47 e5 ff ff       	call   80052c <_panic>
			sys_page_unmap(0, UTEMP);
  801fe5:	83 ec 08             	sub    $0x8,%esp
  801fe8:	68 00 00 40 00       	push   $0x400000
  801fed:	6a 00                	push   $0x0
  801fef:	e8 1e f0 ff ff       	call   801012 <sys_page_unmap>
  801ff4:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ff7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ffd:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802003:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802009:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  80200f:	0f 82 f7 fe ff ff    	jb     801f0c <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802015:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  80201c:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802023:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80202a:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802030:	0f 8c 65 fe ff ff    	jl     801e9b <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802036:	83 ec 0c             	sub    $0xc,%esp
  802039:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80203f:	e8 97 f5 ff ff       	call   8015db <close>
  802044:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802047:	bb 00 00 00 00       	mov    $0x0,%ebx
  80204c:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  802052:	89 d8                	mov    %ebx,%eax
  802054:	c1 e8 16             	shr    $0x16,%eax
  802057:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80205e:	a8 01                	test   $0x1,%al
  802060:	74 42                	je     8020a4 <spawn+0x45e>
  802062:	89 d8                	mov    %ebx,%eax
  802064:	c1 e8 0c             	shr    $0xc,%eax
  802067:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80206e:	f6 c2 01             	test   $0x1,%dl
  802071:	74 31                	je     8020a4 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  802073:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  80207a:	f6 c6 04             	test   $0x4,%dh
  80207d:	74 25                	je     8020a4 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  80207f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802086:	83 ec 0c             	sub    $0xc,%esp
  802089:	25 07 0e 00 00       	and    $0xe07,%eax
  80208e:	50                   	push   %eax
  80208f:	53                   	push   %ebx
  802090:	56                   	push   %esi
  802091:	53                   	push   %ebx
  802092:	6a 00                	push   $0x0
  802094:	e8 37 ef ff ff       	call   800fd0 <sys_page_map>
			if (r < 0) {
  802099:	83 c4 20             	add    $0x20,%esp
  80209c:	85 c0                	test   %eax,%eax
  80209e:	0f 88 b1 00 00 00    	js     802155 <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  8020a4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8020aa:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8020b0:	75 a0                	jne    802052 <spawn+0x40c>
  8020b2:	e9 b3 00 00 00       	jmp    80216a <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8020b7:	50                   	push   %eax
  8020b8:	68 5a 30 80 00       	push   $0x80305a
  8020bd:	68 86 00 00 00       	push   $0x86
  8020c2:	68 31 30 80 00       	push   $0x803031
  8020c7:	e8 60 e4 ff ff       	call   80052c <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8020cc:	83 ec 08             	sub    $0x8,%esp
  8020cf:	6a 02                	push   $0x2
  8020d1:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020d7:	e8 78 ef ff ff       	call   801054 <sys_env_set_status>
  8020dc:	83 c4 10             	add    $0x10,%esp
  8020df:	85 c0                	test   %eax,%eax
  8020e1:	79 2b                	jns    80210e <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  8020e3:	50                   	push   %eax
  8020e4:	68 74 30 80 00       	push   $0x803074
  8020e9:	68 89 00 00 00       	push   $0x89
  8020ee:	68 31 30 80 00       	push   $0x803031
  8020f3:	e8 34 e4 ff ff       	call   80052c <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8020f8:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8020fe:	e9 a8 00 00 00       	jmp    8021ab <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802103:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802109:	e9 9d 00 00 00       	jmp    8021ab <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80210e:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802114:	e9 92 00 00 00       	jmp    8021ab <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802119:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  80211e:	e9 88 00 00 00       	jmp    8021ab <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802123:	89 c3                	mov    %eax,%ebx
  802125:	e9 81 00 00 00       	jmp    8021ab <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80212a:	89 c3                	mov    %eax,%ebx
  80212c:	eb 06                	jmp    802134 <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80212e:	89 c3                	mov    %eax,%ebx
  802130:	eb 02                	jmp    802134 <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802132:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802134:	83 ec 0c             	sub    $0xc,%esp
  802137:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80213d:	e8 cc ed ff ff       	call   800f0e <sys_env_destroy>
	close(fd);
  802142:	83 c4 04             	add    $0x4,%esp
  802145:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80214b:	e8 8b f4 ff ff       	call   8015db <close>
	return r;
  802150:	83 c4 10             	add    $0x10,%esp
  802153:	eb 56                	jmp    8021ab <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802155:	50                   	push   %eax
  802156:	68 8b 30 80 00       	push   $0x80308b
  80215b:	68 82 00 00 00       	push   $0x82
  802160:	68 31 30 80 00       	push   $0x803031
  802165:	e8 c2 e3 ff ff       	call   80052c <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  80216a:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802171:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802174:	83 ec 08             	sub    $0x8,%esp
  802177:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80217d:	50                   	push   %eax
  80217e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802184:	e8 0d ef ff ff       	call   801096 <sys_env_set_trapframe>
  802189:	83 c4 10             	add    $0x10,%esp
  80218c:	85 c0                	test   %eax,%eax
  80218e:	0f 89 38 ff ff ff    	jns    8020cc <spawn+0x486>
  802194:	e9 1e ff ff ff       	jmp    8020b7 <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802199:	83 ec 08             	sub    $0x8,%esp
  80219c:	68 00 00 40 00       	push   $0x400000
  8021a1:	6a 00                	push   $0x0
  8021a3:	e8 6a ee ff ff       	call   801012 <sys_page_unmap>
  8021a8:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8021ab:	89 d8                	mov    %ebx,%eax
  8021ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021b0:	5b                   	pop    %ebx
  8021b1:	5e                   	pop    %esi
  8021b2:	5f                   	pop    %edi
  8021b3:	5d                   	pop    %ebp
  8021b4:	c3                   	ret    

008021b5 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8021b5:	55                   	push   %ebp
  8021b6:	89 e5                	mov    %esp,%ebp
  8021b8:	56                   	push   %esi
  8021b9:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021ba:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8021bd:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021c2:	eb 03                	jmp    8021c7 <spawnl+0x12>
		argc++;
  8021c4:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021c7:	83 c2 04             	add    $0x4,%edx
  8021ca:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8021ce:	75 f4                	jne    8021c4 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8021d0:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8021d7:	83 e2 f0             	and    $0xfffffff0,%edx
  8021da:	29 d4                	sub    %edx,%esp
  8021dc:	8d 54 24 03          	lea    0x3(%esp),%edx
  8021e0:	c1 ea 02             	shr    $0x2,%edx
  8021e3:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8021ea:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8021ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021ef:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8021f6:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8021fd:	00 
  8021fe:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802200:	b8 00 00 00 00       	mov    $0x0,%eax
  802205:	eb 0a                	jmp    802211 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802207:	83 c0 01             	add    $0x1,%eax
  80220a:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  80220e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802211:	39 d0                	cmp    %edx,%eax
  802213:	75 f2                	jne    802207 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802215:	83 ec 08             	sub    $0x8,%esp
  802218:	56                   	push   %esi
  802219:	ff 75 08             	pushl  0x8(%ebp)
  80221c:	e8 25 fa ff ff       	call   801c46 <spawn>
}
  802221:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    

00802228 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802228:	55                   	push   %ebp
  802229:	89 e5                	mov    %esp,%ebp
  80222b:	56                   	push   %esi
  80222c:	53                   	push   %ebx
  80222d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802230:	83 ec 0c             	sub    $0xc,%esp
  802233:	ff 75 08             	pushl  0x8(%ebp)
  802236:	e8 10 f2 ff ff       	call   80144b <fd2data>
  80223b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80223d:	83 c4 08             	add    $0x8,%esp
  802240:	68 cc 30 80 00       	push   $0x8030cc
  802245:	53                   	push   %ebx
  802246:	e8 3f e9 ff ff       	call   800b8a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80224b:	8b 46 04             	mov    0x4(%esi),%eax
  80224e:	2b 06                	sub    (%esi),%eax
  802250:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802256:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80225d:	00 00 00 
	stat->st_dev = &devpipe;
  802260:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802267:	40 80 00 
	return 0;
}
  80226a:	b8 00 00 00 00       	mov    $0x0,%eax
  80226f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802272:	5b                   	pop    %ebx
  802273:	5e                   	pop    %esi
  802274:	5d                   	pop    %ebp
  802275:	c3                   	ret    

00802276 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802276:	55                   	push   %ebp
  802277:	89 e5                	mov    %esp,%ebp
  802279:	53                   	push   %ebx
  80227a:	83 ec 0c             	sub    $0xc,%esp
  80227d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802280:	53                   	push   %ebx
  802281:	6a 00                	push   $0x0
  802283:	e8 8a ed ff ff       	call   801012 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802288:	89 1c 24             	mov    %ebx,(%esp)
  80228b:	e8 bb f1 ff ff       	call   80144b <fd2data>
  802290:	83 c4 08             	add    $0x8,%esp
  802293:	50                   	push   %eax
  802294:	6a 00                	push   $0x0
  802296:	e8 77 ed ff ff       	call   801012 <sys_page_unmap>
}
  80229b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80229e:	c9                   	leave  
  80229f:	c3                   	ret    

008022a0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	57                   	push   %edi
  8022a4:	56                   	push   %esi
  8022a5:	53                   	push   %ebx
  8022a6:	83 ec 1c             	sub    $0x1c,%esp
  8022a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8022ac:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8022ae:	a1 04 50 80 00       	mov    0x805004,%eax
  8022b3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8022b6:	83 ec 0c             	sub    $0xc,%esp
  8022b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8022bc:	e8 ae 04 00 00       	call   80276f <pageref>
  8022c1:	89 c3                	mov    %eax,%ebx
  8022c3:	89 3c 24             	mov    %edi,(%esp)
  8022c6:	e8 a4 04 00 00       	call   80276f <pageref>
  8022cb:	83 c4 10             	add    $0x10,%esp
  8022ce:	39 c3                	cmp    %eax,%ebx
  8022d0:	0f 94 c1             	sete   %cl
  8022d3:	0f b6 c9             	movzbl %cl,%ecx
  8022d6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8022d9:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8022df:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8022e2:	39 ce                	cmp    %ecx,%esi
  8022e4:	74 1b                	je     802301 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8022e6:	39 c3                	cmp    %eax,%ebx
  8022e8:	75 c4                	jne    8022ae <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022ea:	8b 42 58             	mov    0x58(%edx),%eax
  8022ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8022f0:	50                   	push   %eax
  8022f1:	56                   	push   %esi
  8022f2:	68 d3 30 80 00       	push   $0x8030d3
  8022f7:	e8 09 e3 ff ff       	call   800605 <cprintf>
  8022fc:	83 c4 10             	add    $0x10,%esp
  8022ff:	eb ad                	jmp    8022ae <_pipeisclosed+0xe>
	}
}
  802301:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802304:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802307:	5b                   	pop    %ebx
  802308:	5e                   	pop    %esi
  802309:	5f                   	pop    %edi
  80230a:	5d                   	pop    %ebp
  80230b:	c3                   	ret    

0080230c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80230c:	55                   	push   %ebp
  80230d:	89 e5                	mov    %esp,%ebp
  80230f:	57                   	push   %edi
  802310:	56                   	push   %esi
  802311:	53                   	push   %ebx
  802312:	83 ec 28             	sub    $0x28,%esp
  802315:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802318:	56                   	push   %esi
  802319:	e8 2d f1 ff ff       	call   80144b <fd2data>
  80231e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802320:	83 c4 10             	add    $0x10,%esp
  802323:	bf 00 00 00 00       	mov    $0x0,%edi
  802328:	eb 4b                	jmp    802375 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80232a:	89 da                	mov    %ebx,%edx
  80232c:	89 f0                	mov    %esi,%eax
  80232e:	e8 6d ff ff ff       	call   8022a0 <_pipeisclosed>
  802333:	85 c0                	test   %eax,%eax
  802335:	75 48                	jne    80237f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802337:	e8 32 ec ff ff       	call   800f6e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80233c:	8b 43 04             	mov    0x4(%ebx),%eax
  80233f:	8b 0b                	mov    (%ebx),%ecx
  802341:	8d 51 20             	lea    0x20(%ecx),%edx
  802344:	39 d0                	cmp    %edx,%eax
  802346:	73 e2                	jae    80232a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802348:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80234b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80234f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802352:	89 c2                	mov    %eax,%edx
  802354:	c1 fa 1f             	sar    $0x1f,%edx
  802357:	89 d1                	mov    %edx,%ecx
  802359:	c1 e9 1b             	shr    $0x1b,%ecx
  80235c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80235f:	83 e2 1f             	and    $0x1f,%edx
  802362:	29 ca                	sub    %ecx,%edx
  802364:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802368:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80236c:	83 c0 01             	add    $0x1,%eax
  80236f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802372:	83 c7 01             	add    $0x1,%edi
  802375:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802378:	75 c2                	jne    80233c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80237a:	8b 45 10             	mov    0x10(%ebp),%eax
  80237d:	eb 05                	jmp    802384 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80237f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802384:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802387:	5b                   	pop    %ebx
  802388:	5e                   	pop    %esi
  802389:	5f                   	pop    %edi
  80238a:	5d                   	pop    %ebp
  80238b:	c3                   	ret    

0080238c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80238c:	55                   	push   %ebp
  80238d:	89 e5                	mov    %esp,%ebp
  80238f:	57                   	push   %edi
  802390:	56                   	push   %esi
  802391:	53                   	push   %ebx
  802392:	83 ec 18             	sub    $0x18,%esp
  802395:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802398:	57                   	push   %edi
  802399:	e8 ad f0 ff ff       	call   80144b <fd2data>
  80239e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023a0:	83 c4 10             	add    $0x10,%esp
  8023a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023a8:	eb 3d                	jmp    8023e7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023aa:	85 db                	test   %ebx,%ebx
  8023ac:	74 04                	je     8023b2 <devpipe_read+0x26>
				return i;
  8023ae:	89 d8                	mov    %ebx,%eax
  8023b0:	eb 44                	jmp    8023f6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023b2:	89 f2                	mov    %esi,%edx
  8023b4:	89 f8                	mov    %edi,%eax
  8023b6:	e8 e5 fe ff ff       	call   8022a0 <_pipeisclosed>
  8023bb:	85 c0                	test   %eax,%eax
  8023bd:	75 32                	jne    8023f1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023bf:	e8 aa eb ff ff       	call   800f6e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023c4:	8b 06                	mov    (%esi),%eax
  8023c6:	3b 46 04             	cmp    0x4(%esi),%eax
  8023c9:	74 df                	je     8023aa <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023cb:	99                   	cltd   
  8023cc:	c1 ea 1b             	shr    $0x1b,%edx
  8023cf:	01 d0                	add    %edx,%eax
  8023d1:	83 e0 1f             	and    $0x1f,%eax
  8023d4:	29 d0                	sub    %edx,%eax
  8023d6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8023db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023de:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8023e1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023e4:	83 c3 01             	add    $0x1,%ebx
  8023e7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023ea:	75 d8                	jne    8023c4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8023ef:	eb 05                	jmp    8023f6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023f1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023f9:	5b                   	pop    %ebx
  8023fa:	5e                   	pop    %esi
  8023fb:	5f                   	pop    %edi
  8023fc:	5d                   	pop    %ebp
  8023fd:	c3                   	ret    

008023fe <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023fe:	55                   	push   %ebp
  8023ff:	89 e5                	mov    %esp,%ebp
  802401:	56                   	push   %esi
  802402:	53                   	push   %ebx
  802403:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802406:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802409:	50                   	push   %eax
  80240a:	e8 53 f0 ff ff       	call   801462 <fd_alloc>
  80240f:	83 c4 10             	add    $0x10,%esp
  802412:	89 c2                	mov    %eax,%edx
  802414:	85 c0                	test   %eax,%eax
  802416:	0f 88 2c 01 00 00    	js     802548 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80241c:	83 ec 04             	sub    $0x4,%esp
  80241f:	68 07 04 00 00       	push   $0x407
  802424:	ff 75 f4             	pushl  -0xc(%ebp)
  802427:	6a 00                	push   $0x0
  802429:	e8 5f eb ff ff       	call   800f8d <sys_page_alloc>
  80242e:	83 c4 10             	add    $0x10,%esp
  802431:	89 c2                	mov    %eax,%edx
  802433:	85 c0                	test   %eax,%eax
  802435:	0f 88 0d 01 00 00    	js     802548 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80243b:	83 ec 0c             	sub    $0xc,%esp
  80243e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802441:	50                   	push   %eax
  802442:	e8 1b f0 ff ff       	call   801462 <fd_alloc>
  802447:	89 c3                	mov    %eax,%ebx
  802449:	83 c4 10             	add    $0x10,%esp
  80244c:	85 c0                	test   %eax,%eax
  80244e:	0f 88 e2 00 00 00    	js     802536 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802454:	83 ec 04             	sub    $0x4,%esp
  802457:	68 07 04 00 00       	push   $0x407
  80245c:	ff 75 f0             	pushl  -0x10(%ebp)
  80245f:	6a 00                	push   $0x0
  802461:	e8 27 eb ff ff       	call   800f8d <sys_page_alloc>
  802466:	89 c3                	mov    %eax,%ebx
  802468:	83 c4 10             	add    $0x10,%esp
  80246b:	85 c0                	test   %eax,%eax
  80246d:	0f 88 c3 00 00 00    	js     802536 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802473:	83 ec 0c             	sub    $0xc,%esp
  802476:	ff 75 f4             	pushl  -0xc(%ebp)
  802479:	e8 cd ef ff ff       	call   80144b <fd2data>
  80247e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802480:	83 c4 0c             	add    $0xc,%esp
  802483:	68 07 04 00 00       	push   $0x407
  802488:	50                   	push   %eax
  802489:	6a 00                	push   $0x0
  80248b:	e8 fd ea ff ff       	call   800f8d <sys_page_alloc>
  802490:	89 c3                	mov    %eax,%ebx
  802492:	83 c4 10             	add    $0x10,%esp
  802495:	85 c0                	test   %eax,%eax
  802497:	0f 88 89 00 00 00    	js     802526 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80249d:	83 ec 0c             	sub    $0xc,%esp
  8024a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8024a3:	e8 a3 ef ff ff       	call   80144b <fd2data>
  8024a8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8024af:	50                   	push   %eax
  8024b0:	6a 00                	push   $0x0
  8024b2:	56                   	push   %esi
  8024b3:	6a 00                	push   $0x0
  8024b5:	e8 16 eb ff ff       	call   800fd0 <sys_page_map>
  8024ba:	89 c3                	mov    %eax,%ebx
  8024bc:	83 c4 20             	add    $0x20,%esp
  8024bf:	85 c0                	test   %eax,%eax
  8024c1:	78 55                	js     802518 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024c3:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024cc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024d8:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024e1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024e6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024ed:	83 ec 0c             	sub    $0xc,%esp
  8024f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8024f3:	e8 43 ef ff ff       	call   80143b <fd2num>
  8024f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024fb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8024fd:	83 c4 04             	add    $0x4,%esp
  802500:	ff 75 f0             	pushl  -0x10(%ebp)
  802503:	e8 33 ef ff ff       	call   80143b <fd2num>
  802508:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80250b:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80250e:	83 c4 10             	add    $0x10,%esp
  802511:	ba 00 00 00 00       	mov    $0x0,%edx
  802516:	eb 30                	jmp    802548 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802518:	83 ec 08             	sub    $0x8,%esp
  80251b:	56                   	push   %esi
  80251c:	6a 00                	push   $0x0
  80251e:	e8 ef ea ff ff       	call   801012 <sys_page_unmap>
  802523:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802526:	83 ec 08             	sub    $0x8,%esp
  802529:	ff 75 f0             	pushl  -0x10(%ebp)
  80252c:	6a 00                	push   $0x0
  80252e:	e8 df ea ff ff       	call   801012 <sys_page_unmap>
  802533:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802536:	83 ec 08             	sub    $0x8,%esp
  802539:	ff 75 f4             	pushl  -0xc(%ebp)
  80253c:	6a 00                	push   $0x0
  80253e:	e8 cf ea ff ff       	call   801012 <sys_page_unmap>
  802543:	83 c4 10             	add    $0x10,%esp
  802546:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802548:	89 d0                	mov    %edx,%eax
  80254a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80254d:	5b                   	pop    %ebx
  80254e:	5e                   	pop    %esi
  80254f:	5d                   	pop    %ebp
  802550:	c3                   	ret    

00802551 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802551:	55                   	push   %ebp
  802552:	89 e5                	mov    %esp,%ebp
  802554:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802557:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80255a:	50                   	push   %eax
  80255b:	ff 75 08             	pushl  0x8(%ebp)
  80255e:	e8 4e ef ff ff       	call   8014b1 <fd_lookup>
  802563:	83 c4 10             	add    $0x10,%esp
  802566:	85 c0                	test   %eax,%eax
  802568:	78 18                	js     802582 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80256a:	83 ec 0c             	sub    $0xc,%esp
  80256d:	ff 75 f4             	pushl  -0xc(%ebp)
  802570:	e8 d6 ee ff ff       	call   80144b <fd2data>
	return _pipeisclosed(fd, p);
  802575:	89 c2                	mov    %eax,%edx
  802577:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80257a:	e8 21 fd ff ff       	call   8022a0 <_pipeisclosed>
  80257f:	83 c4 10             	add    $0x10,%esp
}
  802582:	c9                   	leave  
  802583:	c3                   	ret    

00802584 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802584:	55                   	push   %ebp
  802585:	89 e5                	mov    %esp,%ebp
  802587:	56                   	push   %esi
  802588:	53                   	push   %ebx
  802589:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80258c:	85 f6                	test   %esi,%esi
  80258e:	75 16                	jne    8025a6 <wait+0x22>
  802590:	68 eb 30 80 00       	push   $0x8030eb
  802595:	68 eb 2f 80 00       	push   $0x802feb
  80259a:	6a 09                	push   $0x9
  80259c:	68 f6 30 80 00       	push   $0x8030f6
  8025a1:	e8 86 df ff ff       	call   80052c <_panic>
	e = &envs[ENVX(envid)];
  8025a6:	89 f3                	mov    %esi,%ebx
  8025a8:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025ae:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8025b1:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8025b7:	eb 05                	jmp    8025be <wait+0x3a>
		sys_yield();
  8025b9:	e8 b0 e9 ff ff       	call   800f6e <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025be:	8b 43 48             	mov    0x48(%ebx),%eax
  8025c1:	39 c6                	cmp    %eax,%esi
  8025c3:	75 07                	jne    8025cc <wait+0x48>
  8025c5:	8b 43 54             	mov    0x54(%ebx),%eax
  8025c8:	85 c0                	test   %eax,%eax
  8025ca:	75 ed                	jne    8025b9 <wait+0x35>
		sys_yield();
}
  8025cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025cf:	5b                   	pop    %ebx
  8025d0:	5e                   	pop    %esi
  8025d1:	5d                   	pop    %ebp
  8025d2:	c3                   	ret    

008025d3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8025d3:	55                   	push   %ebp
  8025d4:	89 e5                	mov    %esp,%ebp
  8025d6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8025d9:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8025e0:	75 2a                	jne    80260c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8025e2:	83 ec 04             	sub    $0x4,%esp
  8025e5:	6a 07                	push   $0x7
  8025e7:	68 00 f0 bf ee       	push   $0xeebff000
  8025ec:	6a 00                	push   $0x0
  8025ee:	e8 9a e9 ff ff       	call   800f8d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8025f3:	83 c4 10             	add    $0x10,%esp
  8025f6:	85 c0                	test   %eax,%eax
  8025f8:	79 12                	jns    80260c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8025fa:	50                   	push   %eax
  8025fb:	68 01 31 80 00       	push   $0x803101
  802600:	6a 23                	push   $0x23
  802602:	68 05 31 80 00       	push   $0x803105
  802607:	e8 20 df ff ff       	call   80052c <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80260c:	8b 45 08             	mov    0x8(%ebp),%eax
  80260f:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802614:	83 ec 08             	sub    $0x8,%esp
  802617:	68 3e 26 80 00       	push   $0x80263e
  80261c:	6a 00                	push   $0x0
  80261e:	e8 b5 ea ff ff       	call   8010d8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802623:	83 c4 10             	add    $0x10,%esp
  802626:	85 c0                	test   %eax,%eax
  802628:	79 12                	jns    80263c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80262a:	50                   	push   %eax
  80262b:	68 01 31 80 00       	push   $0x803101
  802630:	6a 2c                	push   $0x2c
  802632:	68 05 31 80 00       	push   $0x803105
  802637:	e8 f0 de ff ff       	call   80052c <_panic>
	}
}
  80263c:	c9                   	leave  
  80263d:	c3                   	ret    

0080263e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80263e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80263f:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802644:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802646:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802649:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80264d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802652:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802656:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802658:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80265b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80265c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80265f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802660:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802661:	c3                   	ret    

00802662 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802662:	55                   	push   %ebp
  802663:	89 e5                	mov    %esp,%ebp
  802665:	56                   	push   %esi
  802666:	53                   	push   %ebx
  802667:	8b 75 08             	mov    0x8(%ebp),%esi
  80266a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80266d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802670:	85 c0                	test   %eax,%eax
  802672:	75 12                	jne    802686 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802674:	83 ec 0c             	sub    $0xc,%esp
  802677:	68 00 00 c0 ee       	push   $0xeec00000
  80267c:	e8 bc ea ff ff       	call   80113d <sys_ipc_recv>
  802681:	83 c4 10             	add    $0x10,%esp
  802684:	eb 0c                	jmp    802692 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802686:	83 ec 0c             	sub    $0xc,%esp
  802689:	50                   	push   %eax
  80268a:	e8 ae ea ff ff       	call   80113d <sys_ipc_recv>
  80268f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802692:	85 f6                	test   %esi,%esi
  802694:	0f 95 c1             	setne  %cl
  802697:	85 db                	test   %ebx,%ebx
  802699:	0f 95 c2             	setne  %dl
  80269c:	84 d1                	test   %dl,%cl
  80269e:	74 09                	je     8026a9 <ipc_recv+0x47>
  8026a0:	89 c2                	mov    %eax,%edx
  8026a2:	c1 ea 1f             	shr    $0x1f,%edx
  8026a5:	84 d2                	test   %dl,%dl
  8026a7:	75 24                	jne    8026cd <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8026a9:	85 f6                	test   %esi,%esi
  8026ab:	74 0a                	je     8026b7 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  8026ad:	a1 04 50 80 00       	mov    0x805004,%eax
  8026b2:	8b 40 74             	mov    0x74(%eax),%eax
  8026b5:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8026b7:	85 db                	test   %ebx,%ebx
  8026b9:	74 0a                	je     8026c5 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  8026bb:	a1 04 50 80 00       	mov    0x805004,%eax
  8026c0:	8b 40 78             	mov    0x78(%eax),%eax
  8026c3:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8026c5:	a1 04 50 80 00       	mov    0x805004,%eax
  8026ca:	8b 40 70             	mov    0x70(%eax),%eax
}
  8026cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026d0:	5b                   	pop    %ebx
  8026d1:	5e                   	pop    %esi
  8026d2:	5d                   	pop    %ebp
  8026d3:	c3                   	ret    

008026d4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026d4:	55                   	push   %ebp
  8026d5:	89 e5                	mov    %esp,%ebp
  8026d7:	57                   	push   %edi
  8026d8:	56                   	push   %esi
  8026d9:	53                   	push   %ebx
  8026da:	83 ec 0c             	sub    $0xc,%esp
  8026dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026e0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8026e6:	85 db                	test   %ebx,%ebx
  8026e8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8026ed:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8026f0:	ff 75 14             	pushl  0x14(%ebp)
  8026f3:	53                   	push   %ebx
  8026f4:	56                   	push   %esi
  8026f5:	57                   	push   %edi
  8026f6:	e8 1f ea ff ff       	call   80111a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8026fb:	89 c2                	mov    %eax,%edx
  8026fd:	c1 ea 1f             	shr    $0x1f,%edx
  802700:	83 c4 10             	add    $0x10,%esp
  802703:	84 d2                	test   %dl,%dl
  802705:	74 17                	je     80271e <ipc_send+0x4a>
  802707:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80270a:	74 12                	je     80271e <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80270c:	50                   	push   %eax
  80270d:	68 13 31 80 00       	push   $0x803113
  802712:	6a 47                	push   $0x47
  802714:	68 21 31 80 00       	push   $0x803121
  802719:	e8 0e de ff ff       	call   80052c <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80271e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802721:	75 07                	jne    80272a <ipc_send+0x56>
			sys_yield();
  802723:	e8 46 e8 ff ff       	call   800f6e <sys_yield>
  802728:	eb c6                	jmp    8026f0 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80272a:	85 c0                	test   %eax,%eax
  80272c:	75 c2                	jne    8026f0 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80272e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802731:	5b                   	pop    %ebx
  802732:	5e                   	pop    %esi
  802733:	5f                   	pop    %edi
  802734:	5d                   	pop    %ebp
  802735:	c3                   	ret    

00802736 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802736:	55                   	push   %ebp
  802737:	89 e5                	mov    %esp,%ebp
  802739:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80273c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802741:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802744:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80274a:	8b 52 50             	mov    0x50(%edx),%edx
  80274d:	39 ca                	cmp    %ecx,%edx
  80274f:	75 0d                	jne    80275e <ipc_find_env+0x28>
			return envs[i].env_id;
  802751:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802754:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802759:	8b 40 48             	mov    0x48(%eax),%eax
  80275c:	eb 0f                	jmp    80276d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80275e:	83 c0 01             	add    $0x1,%eax
  802761:	3d 00 04 00 00       	cmp    $0x400,%eax
  802766:	75 d9                	jne    802741 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802768:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80276d:	5d                   	pop    %ebp
  80276e:	c3                   	ret    

0080276f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80276f:	55                   	push   %ebp
  802770:	89 e5                	mov    %esp,%ebp
  802772:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802775:	89 d0                	mov    %edx,%eax
  802777:	c1 e8 16             	shr    $0x16,%eax
  80277a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802781:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802786:	f6 c1 01             	test   $0x1,%cl
  802789:	74 1d                	je     8027a8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80278b:	c1 ea 0c             	shr    $0xc,%edx
  80278e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802795:	f6 c2 01             	test   $0x1,%dl
  802798:	74 0e                	je     8027a8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80279a:	c1 ea 0c             	shr    $0xc,%edx
  80279d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8027a4:	ef 
  8027a5:	0f b7 c0             	movzwl %ax,%eax
}
  8027a8:	5d                   	pop    %ebp
  8027a9:	c3                   	ret    
  8027aa:	66 90                	xchg   %ax,%ax
  8027ac:	66 90                	xchg   %ax,%ax
  8027ae:	66 90                	xchg   %ax,%ax

008027b0 <__udivdi3>:
  8027b0:	55                   	push   %ebp
  8027b1:	57                   	push   %edi
  8027b2:	56                   	push   %esi
  8027b3:	53                   	push   %ebx
  8027b4:	83 ec 1c             	sub    $0x1c,%esp
  8027b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8027bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8027bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8027c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027c7:	85 f6                	test   %esi,%esi
  8027c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027cd:	89 ca                	mov    %ecx,%edx
  8027cf:	89 f8                	mov    %edi,%eax
  8027d1:	75 3d                	jne    802810 <__udivdi3+0x60>
  8027d3:	39 cf                	cmp    %ecx,%edi
  8027d5:	0f 87 c5 00 00 00    	ja     8028a0 <__udivdi3+0xf0>
  8027db:	85 ff                	test   %edi,%edi
  8027dd:	89 fd                	mov    %edi,%ebp
  8027df:	75 0b                	jne    8027ec <__udivdi3+0x3c>
  8027e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027e6:	31 d2                	xor    %edx,%edx
  8027e8:	f7 f7                	div    %edi
  8027ea:	89 c5                	mov    %eax,%ebp
  8027ec:	89 c8                	mov    %ecx,%eax
  8027ee:	31 d2                	xor    %edx,%edx
  8027f0:	f7 f5                	div    %ebp
  8027f2:	89 c1                	mov    %eax,%ecx
  8027f4:	89 d8                	mov    %ebx,%eax
  8027f6:	89 cf                	mov    %ecx,%edi
  8027f8:	f7 f5                	div    %ebp
  8027fa:	89 c3                	mov    %eax,%ebx
  8027fc:	89 d8                	mov    %ebx,%eax
  8027fe:	89 fa                	mov    %edi,%edx
  802800:	83 c4 1c             	add    $0x1c,%esp
  802803:	5b                   	pop    %ebx
  802804:	5e                   	pop    %esi
  802805:	5f                   	pop    %edi
  802806:	5d                   	pop    %ebp
  802807:	c3                   	ret    
  802808:	90                   	nop
  802809:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802810:	39 ce                	cmp    %ecx,%esi
  802812:	77 74                	ja     802888 <__udivdi3+0xd8>
  802814:	0f bd fe             	bsr    %esi,%edi
  802817:	83 f7 1f             	xor    $0x1f,%edi
  80281a:	0f 84 98 00 00 00    	je     8028b8 <__udivdi3+0x108>
  802820:	bb 20 00 00 00       	mov    $0x20,%ebx
  802825:	89 f9                	mov    %edi,%ecx
  802827:	89 c5                	mov    %eax,%ebp
  802829:	29 fb                	sub    %edi,%ebx
  80282b:	d3 e6                	shl    %cl,%esi
  80282d:	89 d9                	mov    %ebx,%ecx
  80282f:	d3 ed                	shr    %cl,%ebp
  802831:	89 f9                	mov    %edi,%ecx
  802833:	d3 e0                	shl    %cl,%eax
  802835:	09 ee                	or     %ebp,%esi
  802837:	89 d9                	mov    %ebx,%ecx
  802839:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80283d:	89 d5                	mov    %edx,%ebp
  80283f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802843:	d3 ed                	shr    %cl,%ebp
  802845:	89 f9                	mov    %edi,%ecx
  802847:	d3 e2                	shl    %cl,%edx
  802849:	89 d9                	mov    %ebx,%ecx
  80284b:	d3 e8                	shr    %cl,%eax
  80284d:	09 c2                	or     %eax,%edx
  80284f:	89 d0                	mov    %edx,%eax
  802851:	89 ea                	mov    %ebp,%edx
  802853:	f7 f6                	div    %esi
  802855:	89 d5                	mov    %edx,%ebp
  802857:	89 c3                	mov    %eax,%ebx
  802859:	f7 64 24 0c          	mull   0xc(%esp)
  80285d:	39 d5                	cmp    %edx,%ebp
  80285f:	72 10                	jb     802871 <__udivdi3+0xc1>
  802861:	8b 74 24 08          	mov    0x8(%esp),%esi
  802865:	89 f9                	mov    %edi,%ecx
  802867:	d3 e6                	shl    %cl,%esi
  802869:	39 c6                	cmp    %eax,%esi
  80286b:	73 07                	jae    802874 <__udivdi3+0xc4>
  80286d:	39 d5                	cmp    %edx,%ebp
  80286f:	75 03                	jne    802874 <__udivdi3+0xc4>
  802871:	83 eb 01             	sub    $0x1,%ebx
  802874:	31 ff                	xor    %edi,%edi
  802876:	89 d8                	mov    %ebx,%eax
  802878:	89 fa                	mov    %edi,%edx
  80287a:	83 c4 1c             	add    $0x1c,%esp
  80287d:	5b                   	pop    %ebx
  80287e:	5e                   	pop    %esi
  80287f:	5f                   	pop    %edi
  802880:	5d                   	pop    %ebp
  802881:	c3                   	ret    
  802882:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802888:	31 ff                	xor    %edi,%edi
  80288a:	31 db                	xor    %ebx,%ebx
  80288c:	89 d8                	mov    %ebx,%eax
  80288e:	89 fa                	mov    %edi,%edx
  802890:	83 c4 1c             	add    $0x1c,%esp
  802893:	5b                   	pop    %ebx
  802894:	5e                   	pop    %esi
  802895:	5f                   	pop    %edi
  802896:	5d                   	pop    %ebp
  802897:	c3                   	ret    
  802898:	90                   	nop
  802899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028a0:	89 d8                	mov    %ebx,%eax
  8028a2:	f7 f7                	div    %edi
  8028a4:	31 ff                	xor    %edi,%edi
  8028a6:	89 c3                	mov    %eax,%ebx
  8028a8:	89 d8                	mov    %ebx,%eax
  8028aa:	89 fa                	mov    %edi,%edx
  8028ac:	83 c4 1c             	add    $0x1c,%esp
  8028af:	5b                   	pop    %ebx
  8028b0:	5e                   	pop    %esi
  8028b1:	5f                   	pop    %edi
  8028b2:	5d                   	pop    %ebp
  8028b3:	c3                   	ret    
  8028b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028b8:	39 ce                	cmp    %ecx,%esi
  8028ba:	72 0c                	jb     8028c8 <__udivdi3+0x118>
  8028bc:	31 db                	xor    %ebx,%ebx
  8028be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8028c2:	0f 87 34 ff ff ff    	ja     8027fc <__udivdi3+0x4c>
  8028c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8028cd:	e9 2a ff ff ff       	jmp    8027fc <__udivdi3+0x4c>
  8028d2:	66 90                	xchg   %ax,%ax
  8028d4:	66 90                	xchg   %ax,%ax
  8028d6:	66 90                	xchg   %ax,%ax
  8028d8:	66 90                	xchg   %ax,%ax
  8028da:	66 90                	xchg   %ax,%ax
  8028dc:	66 90                	xchg   %ax,%ax
  8028de:	66 90                	xchg   %ax,%ax

008028e0 <__umoddi3>:
  8028e0:	55                   	push   %ebp
  8028e1:	57                   	push   %edi
  8028e2:	56                   	push   %esi
  8028e3:	53                   	push   %ebx
  8028e4:	83 ec 1c             	sub    $0x1c,%esp
  8028e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8028eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8028ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028f7:	85 d2                	test   %edx,%edx
  8028f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802901:	89 f3                	mov    %esi,%ebx
  802903:	89 3c 24             	mov    %edi,(%esp)
  802906:	89 74 24 04          	mov    %esi,0x4(%esp)
  80290a:	75 1c                	jne    802928 <__umoddi3+0x48>
  80290c:	39 f7                	cmp    %esi,%edi
  80290e:	76 50                	jbe    802960 <__umoddi3+0x80>
  802910:	89 c8                	mov    %ecx,%eax
  802912:	89 f2                	mov    %esi,%edx
  802914:	f7 f7                	div    %edi
  802916:	89 d0                	mov    %edx,%eax
  802918:	31 d2                	xor    %edx,%edx
  80291a:	83 c4 1c             	add    $0x1c,%esp
  80291d:	5b                   	pop    %ebx
  80291e:	5e                   	pop    %esi
  80291f:	5f                   	pop    %edi
  802920:	5d                   	pop    %ebp
  802921:	c3                   	ret    
  802922:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802928:	39 f2                	cmp    %esi,%edx
  80292a:	89 d0                	mov    %edx,%eax
  80292c:	77 52                	ja     802980 <__umoddi3+0xa0>
  80292e:	0f bd ea             	bsr    %edx,%ebp
  802931:	83 f5 1f             	xor    $0x1f,%ebp
  802934:	75 5a                	jne    802990 <__umoddi3+0xb0>
  802936:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80293a:	0f 82 e0 00 00 00    	jb     802a20 <__umoddi3+0x140>
  802940:	39 0c 24             	cmp    %ecx,(%esp)
  802943:	0f 86 d7 00 00 00    	jbe    802a20 <__umoddi3+0x140>
  802949:	8b 44 24 08          	mov    0x8(%esp),%eax
  80294d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802951:	83 c4 1c             	add    $0x1c,%esp
  802954:	5b                   	pop    %ebx
  802955:	5e                   	pop    %esi
  802956:	5f                   	pop    %edi
  802957:	5d                   	pop    %ebp
  802958:	c3                   	ret    
  802959:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802960:	85 ff                	test   %edi,%edi
  802962:	89 fd                	mov    %edi,%ebp
  802964:	75 0b                	jne    802971 <__umoddi3+0x91>
  802966:	b8 01 00 00 00       	mov    $0x1,%eax
  80296b:	31 d2                	xor    %edx,%edx
  80296d:	f7 f7                	div    %edi
  80296f:	89 c5                	mov    %eax,%ebp
  802971:	89 f0                	mov    %esi,%eax
  802973:	31 d2                	xor    %edx,%edx
  802975:	f7 f5                	div    %ebp
  802977:	89 c8                	mov    %ecx,%eax
  802979:	f7 f5                	div    %ebp
  80297b:	89 d0                	mov    %edx,%eax
  80297d:	eb 99                	jmp    802918 <__umoddi3+0x38>
  80297f:	90                   	nop
  802980:	89 c8                	mov    %ecx,%eax
  802982:	89 f2                	mov    %esi,%edx
  802984:	83 c4 1c             	add    $0x1c,%esp
  802987:	5b                   	pop    %ebx
  802988:	5e                   	pop    %esi
  802989:	5f                   	pop    %edi
  80298a:	5d                   	pop    %ebp
  80298b:	c3                   	ret    
  80298c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802990:	8b 34 24             	mov    (%esp),%esi
  802993:	bf 20 00 00 00       	mov    $0x20,%edi
  802998:	89 e9                	mov    %ebp,%ecx
  80299a:	29 ef                	sub    %ebp,%edi
  80299c:	d3 e0                	shl    %cl,%eax
  80299e:	89 f9                	mov    %edi,%ecx
  8029a0:	89 f2                	mov    %esi,%edx
  8029a2:	d3 ea                	shr    %cl,%edx
  8029a4:	89 e9                	mov    %ebp,%ecx
  8029a6:	09 c2                	or     %eax,%edx
  8029a8:	89 d8                	mov    %ebx,%eax
  8029aa:	89 14 24             	mov    %edx,(%esp)
  8029ad:	89 f2                	mov    %esi,%edx
  8029af:	d3 e2                	shl    %cl,%edx
  8029b1:	89 f9                	mov    %edi,%ecx
  8029b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029bb:	d3 e8                	shr    %cl,%eax
  8029bd:	89 e9                	mov    %ebp,%ecx
  8029bf:	89 c6                	mov    %eax,%esi
  8029c1:	d3 e3                	shl    %cl,%ebx
  8029c3:	89 f9                	mov    %edi,%ecx
  8029c5:	89 d0                	mov    %edx,%eax
  8029c7:	d3 e8                	shr    %cl,%eax
  8029c9:	89 e9                	mov    %ebp,%ecx
  8029cb:	09 d8                	or     %ebx,%eax
  8029cd:	89 d3                	mov    %edx,%ebx
  8029cf:	89 f2                	mov    %esi,%edx
  8029d1:	f7 34 24             	divl   (%esp)
  8029d4:	89 d6                	mov    %edx,%esi
  8029d6:	d3 e3                	shl    %cl,%ebx
  8029d8:	f7 64 24 04          	mull   0x4(%esp)
  8029dc:	39 d6                	cmp    %edx,%esi
  8029de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029e2:	89 d1                	mov    %edx,%ecx
  8029e4:	89 c3                	mov    %eax,%ebx
  8029e6:	72 08                	jb     8029f0 <__umoddi3+0x110>
  8029e8:	75 11                	jne    8029fb <__umoddi3+0x11b>
  8029ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8029ee:	73 0b                	jae    8029fb <__umoddi3+0x11b>
  8029f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8029f4:	1b 14 24             	sbb    (%esp),%edx
  8029f7:	89 d1                	mov    %edx,%ecx
  8029f9:	89 c3                	mov    %eax,%ebx
  8029fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8029ff:	29 da                	sub    %ebx,%edx
  802a01:	19 ce                	sbb    %ecx,%esi
  802a03:	89 f9                	mov    %edi,%ecx
  802a05:	89 f0                	mov    %esi,%eax
  802a07:	d3 e0                	shl    %cl,%eax
  802a09:	89 e9                	mov    %ebp,%ecx
  802a0b:	d3 ea                	shr    %cl,%edx
  802a0d:	89 e9                	mov    %ebp,%ecx
  802a0f:	d3 ee                	shr    %cl,%esi
  802a11:	09 d0                	or     %edx,%eax
  802a13:	89 f2                	mov    %esi,%edx
  802a15:	83 c4 1c             	add    $0x1c,%esp
  802a18:	5b                   	pop    %ebx
  802a19:	5e                   	pop    %esi
  802a1a:	5f                   	pop    %edi
  802a1b:	5d                   	pop    %ebp
  802a1c:	c3                   	ret    
  802a1d:	8d 76 00             	lea    0x0(%esi),%esi
  802a20:	29 f9                	sub    %edi,%ecx
  802a22:	19 d6                	sbb    %edx,%esi
  802a24:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a2c:	e9 18 ff ff ff       	jmp    802949 <__umoddi3+0x69>
