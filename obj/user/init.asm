
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 6e 03 00 00       	call   80039f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800043:	ba 00 00 00 00       	mov    $0x0,%edx
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004e:	0f af ca             	imul   %edx,%ecx
  800051:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800053:	83 c2 01             	add    $0x1,%edx
  800056:	39 da                	cmp    %ebx,%edx
  800058:	7c f0                	jl     80004a <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  80005a:	5b                   	pop    %ebx
  80005b:	5e                   	pop    %esi
  80005c:	5d                   	pop    %ebp
  80005d:	c3                   	ret    

0080005e <umain>:

void
umain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006d:	68 e0 29 80 00       	push   $0x8029e0
  800072:	e8 84 04 00 00       	call   8004fb <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 40 80 00       	push   $0x804000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 a8 2a 80 00       	push   $0x802aa8
  8000a1:	e8 55 04 00 00       	call   8004fb <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 ef 29 80 00       	push   $0x8029ef
  8000b3:	e8 43 04 00 00       	call   8004fb <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 20 60 80 00       	push   $0x806020
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 e4 2a 80 00       	push   $0x802ae4
  8000dd:	e8 19 04 00 00       	call   8004fb <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 06 2a 80 00       	push   $0x802a06
  8000ef:	e8 07 04 00 00       	call   8004fb <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 1c 2a 80 00       	push   $0x802a1c
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 95 09 00 00       	call   800aa0 <strcat>
	for (i = 0; i < argc; i++) {
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800113:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800119:	eb 2e                	jmp    800149 <umain+0xeb>
		strcat(args, " '");
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	68 28 2a 80 00       	push   $0x802a28
  800123:	56                   	push   %esi
  800124:	e8 77 09 00 00       	call   800aa0 <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 6b 09 00 00       	call   800aa0 <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 29 2a 80 00       	push   $0x802a29
  80013d:	56                   	push   %esi
  80013e:	e8 5d 09 00 00       	call   800aa0 <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80014c:	7c cd                	jl     80011b <umain+0xbd>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	68 2b 2a 80 00       	push   $0x802a2b
  80015d:	e8 99 03 00 00       	call   8004fb <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 2f 2a 80 00 	movl   $0x802a2f,(%esp)
  800169:	e8 8d 03 00 00       	call   8004fb <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 ce 13 00 00       	call   801548 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 41 2a 80 00       	push   $0x802a41
  80018c:	6a 37                	push   $0x37
  80018e:	68 4e 2a 80 00       	push   $0x802a4e
  800193:	e8 8a 02 00 00       	call   800422 <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 5a 2a 80 00       	push   $0x802a5a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 4e 2a 80 00       	push   $0x802a4e
  8001a9:	e8 74 02 00 00       	call   800422 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 de 13 00 00       	call   801598 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 74 2a 80 00       	push   $0x802a74
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 4e 2a 80 00       	push   $0x802a4e
  8001ce:	e8 4f 02 00 00       	call   800422 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 7c 2a 80 00       	push   $0x802a7c
  8001db:	e8 1b 03 00 00       	call   8004fb <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 90 2a 80 00       	push   $0x802a90
  8001ea:	68 8f 2a 80 00       	push   $0x802a8f
  8001ef:	e8 31 1f 00 00       	call   802125 <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 93 2a 80 00       	push   $0x802a93
  800204:	e8 f2 02 00 00       	call   8004fb <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 e6 22 00 00       	call   8024fd <wait>
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb b7                	jmp    8001d3 <umain+0x175>

0080021c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80021f:	b8 00 00 00 00       	mov    $0x0,%eax
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80022c:	68 13 2b 80 00       	push   $0x802b13
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 47 08 00 00       	call   800a80 <strcpy>
	return 0;
}
  800239:	b8 00 00 00 00       	mov    $0x0,%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80024c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800251:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800257:	eb 2d                	jmp    800286 <devcons_write+0x46>
		m = n - tot;
  800259:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80025e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800261:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800266:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800269:	83 ec 04             	sub    $0x4,%esp
  80026c:	53                   	push   %ebx
  80026d:	03 45 0c             	add    0xc(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	57                   	push   %edi
  800272:	e8 9b 09 00 00       	call   800c12 <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 46 0b 00 00       	call   800dc7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800281:	01 de                	add    %ebx,%esi
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	89 f0                	mov    %esi,%eax
  800288:	3b 75 10             	cmp    0x10(%ebp),%esi
  80028b:	72 cc                	jb     800259 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80028d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8002a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002a4:	74 2a                	je     8002d0 <devcons_read+0x3b>
  8002a6:	eb 05                	jmp    8002ad <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002a8:	e8 b7 0b 00 00       	call   800e64 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 33 0b 00 00       	call   800de5 <sys_cgetc>
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	74 f2                	je     8002a8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	78 16                	js     8002d0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002ba:	83 f8 04             	cmp    $0x4,%eax
  8002bd:	74 0c                	je     8002cb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8002bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c2:	88 02                	mov    %al,(%edx)
	return 1;
  8002c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8002c9:	eb 05                	jmp    8002d0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002cb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002de:	6a 01                	push   $0x1
  8002e0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 de 0a 00 00       	call   800dc7 <sys_cputs>
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <getchar>:

int
getchar(void)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8002f4:	6a 01                	push   $0x1
  8002f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	6a 00                	push   $0x0
  8002fc:	e8 83 13 00 00       	call   801684 <read>
	if (r < 0)
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	85 c0                	test   %eax,%eax
  800306:	78 0f                	js     800317 <getchar+0x29>
		return r;
	if (r < 1)
  800308:	85 c0                	test   %eax,%eax
  80030a:	7e 06                	jle    800312 <getchar+0x24>
		return -E_EOF;
	return c;
  80030c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800310:	eb 05                	jmp    800317 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800312:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80031f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800322:	50                   	push   %eax
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 f3 10 00 00       	call   80141e <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 57 80 00    	mov    0x805770,%edx
  80033b:	39 10                	cmp    %edx,(%eax)
  80033d:	0f 94 c0             	sete   %al
  800340:	0f b6 c0             	movzbl %al,%eax
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <opencons>:

int
opencons(void)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 7b 10 00 00       	call   8013cf <fd_alloc>
  800354:	83 c4 10             	add    $0x10,%esp
		return r;
  800357:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800359:	85 c0                	test   %eax,%eax
  80035b:	78 3e                	js     80039b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80035d:	83 ec 04             	sub    $0x4,%esp
  800360:	68 07 04 00 00       	push   $0x407
  800365:	ff 75 f4             	pushl  -0xc(%ebp)
  800368:	6a 00                	push   $0x0
  80036a:	e8 14 0b 00 00       	call   800e83 <sys_page_alloc>
  80036f:	83 c4 10             	add    $0x10,%esp
		return r;
  800372:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	78 23                	js     80039b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800378:	8b 15 70 57 80 00    	mov    0x805770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 12 10 00 00       	call   8013a8 <fd2num>
  800396:	89 c2                	mov    %eax,%edx
  800398:	83 c4 10             	add    $0x10,%esp
}
  80039b:	89 d0                	mov    %edx,%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8003aa:	e8 96 0a 00 00       	call   800e45 <sys_getenvid>
  8003af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003b4:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8003ba:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003bf:	a3 90 77 80 00       	mov    %eax,0x807790
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c4:	85 db                	test   %ebx,%ebx
  8003c6:	7e 07                	jle    8003cf <libmain+0x30>
		binaryname = argv[0];
  8003c8:	8b 06                	mov    (%esi),%eax
  8003ca:	a3 8c 57 80 00       	mov    %eax,0x80578c

	// call user main routine
	umain(argc, argv);
  8003cf:	83 ec 08             	sub    $0x8,%esp
  8003d2:	56                   	push   %esi
  8003d3:	53                   	push   %ebx
  8003d4:	e8 85 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  8003d9:	e8 2a 00 00 00       	call   800408 <exit>
}
  8003de:	83 c4 10             	add    $0x10,%esp
  8003e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e4:	5b                   	pop    %ebx
  8003e5:	5e                   	pop    %esi
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8003ee:	a1 94 77 80 00       	mov    0x807794,%eax
	func();
  8003f3:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8003f5:	e8 4b 0a 00 00       	call   800e45 <sys_getenvid>
  8003fa:	83 ec 0c             	sub    $0xc,%esp
  8003fd:	50                   	push   %eax
  8003fe:	e8 91 0c 00 00       	call   801094 <sys_thread_free>
}
  800403:	83 c4 10             	add    $0x10,%esp
  800406:	c9                   	leave  
  800407:	c3                   	ret    

00800408 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80040e:	e8 60 11 00 00       	call   801573 <close_all>
	sys_env_destroy(0);
  800413:	83 ec 0c             	sub    $0xc,%esp
  800416:	6a 00                	push   $0x0
  800418:	e8 e7 09 00 00       	call   800e04 <sys_env_destroy>
}
  80041d:	83 c4 10             	add    $0x10,%esp
  800420:	c9                   	leave  
  800421:	c3                   	ret    

00800422 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
  800425:	56                   	push   %esi
  800426:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800427:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80042a:	8b 35 8c 57 80 00    	mov    0x80578c,%esi
  800430:	e8 10 0a 00 00       	call   800e45 <sys_getenvid>
  800435:	83 ec 0c             	sub    $0xc,%esp
  800438:	ff 75 0c             	pushl  0xc(%ebp)
  80043b:	ff 75 08             	pushl  0x8(%ebp)
  80043e:	56                   	push   %esi
  80043f:	50                   	push   %eax
  800440:	68 2c 2b 80 00       	push   $0x802b2c
  800445:	e8 b1 00 00 00       	call   8004fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80044a:	83 c4 18             	add    $0x18,%esp
  80044d:	53                   	push   %ebx
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	e8 54 00 00 00       	call   8004aa <vcprintf>
	cprintf("\n");
  800456:	c7 04 24 94 30 80 00 	movl   $0x803094,(%esp)
  80045d:	e8 99 00 00 00       	call   8004fb <cprintf>
  800462:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800465:	cc                   	int3   
  800466:	eb fd                	jmp    800465 <_panic+0x43>

00800468 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	53                   	push   %ebx
  80046c:	83 ec 04             	sub    $0x4,%esp
  80046f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800472:	8b 13                	mov    (%ebx),%edx
  800474:	8d 42 01             	lea    0x1(%edx),%eax
  800477:	89 03                	mov    %eax,(%ebx)
  800479:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80047c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800480:	3d ff 00 00 00       	cmp    $0xff,%eax
  800485:	75 1a                	jne    8004a1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	68 ff 00 00 00       	push   $0xff
  80048f:	8d 43 08             	lea    0x8(%ebx),%eax
  800492:	50                   	push   %eax
  800493:	e8 2f 09 00 00       	call   800dc7 <sys_cputs>
		b->idx = 0;
  800498:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80049e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004a1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004a8:	c9                   	leave  
  8004a9:	c3                   	ret    

008004aa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004ba:	00 00 00 
	b.cnt = 0;
  8004bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004c4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004c7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ca:	ff 75 08             	pushl  0x8(%ebp)
  8004cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004d3:	50                   	push   %eax
  8004d4:	68 68 04 80 00       	push   $0x800468
  8004d9:	e8 54 01 00 00       	call   800632 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004de:	83 c4 08             	add    $0x8,%esp
  8004e1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004e7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ed:	50                   	push   %eax
  8004ee:	e8 d4 08 00 00       	call   800dc7 <sys_cputs>

	return b.cnt;
}
  8004f3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004f9:	c9                   	leave  
  8004fa:	c3                   	ret    

008004fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800501:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800504:	50                   	push   %eax
  800505:	ff 75 08             	pushl  0x8(%ebp)
  800508:	e8 9d ff ff ff       	call   8004aa <vcprintf>
	va_end(ap);

	return cnt;
}
  80050d:	c9                   	leave  
  80050e:	c3                   	ret    

0080050f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80050f:	55                   	push   %ebp
  800510:	89 e5                	mov    %esp,%ebp
  800512:	57                   	push   %edi
  800513:	56                   	push   %esi
  800514:	53                   	push   %ebx
  800515:	83 ec 1c             	sub    $0x1c,%esp
  800518:	89 c7                	mov    %eax,%edi
  80051a:	89 d6                	mov    %edx,%esi
  80051c:	8b 45 08             	mov    0x8(%ebp),%eax
  80051f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800522:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800525:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800528:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80052b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800530:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800533:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800536:	39 d3                	cmp    %edx,%ebx
  800538:	72 05                	jb     80053f <printnum+0x30>
  80053a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80053d:	77 45                	ja     800584 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80053f:	83 ec 0c             	sub    $0xc,%esp
  800542:	ff 75 18             	pushl  0x18(%ebp)
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80054b:	53                   	push   %ebx
  80054c:	ff 75 10             	pushl  0x10(%ebp)
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	ff 75 e4             	pushl  -0x1c(%ebp)
  800555:	ff 75 e0             	pushl  -0x20(%ebp)
  800558:	ff 75 dc             	pushl  -0x24(%ebp)
  80055b:	ff 75 d8             	pushl  -0x28(%ebp)
  80055e:	e8 dd 21 00 00       	call   802740 <__udivdi3>
  800563:	83 c4 18             	add    $0x18,%esp
  800566:	52                   	push   %edx
  800567:	50                   	push   %eax
  800568:	89 f2                	mov    %esi,%edx
  80056a:	89 f8                	mov    %edi,%eax
  80056c:	e8 9e ff ff ff       	call   80050f <printnum>
  800571:	83 c4 20             	add    $0x20,%esp
  800574:	eb 18                	jmp    80058e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	56                   	push   %esi
  80057a:	ff 75 18             	pushl  0x18(%ebp)
  80057d:	ff d7                	call   *%edi
  80057f:	83 c4 10             	add    $0x10,%esp
  800582:	eb 03                	jmp    800587 <printnum+0x78>
  800584:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800587:	83 eb 01             	sub    $0x1,%ebx
  80058a:	85 db                	test   %ebx,%ebx
  80058c:	7f e8                	jg     800576 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	56                   	push   %esi
  800592:	83 ec 04             	sub    $0x4,%esp
  800595:	ff 75 e4             	pushl  -0x1c(%ebp)
  800598:	ff 75 e0             	pushl  -0x20(%ebp)
  80059b:	ff 75 dc             	pushl  -0x24(%ebp)
  80059e:	ff 75 d8             	pushl  -0x28(%ebp)
  8005a1:	e8 ca 22 00 00       	call   802870 <__umoddi3>
  8005a6:	83 c4 14             	add    $0x14,%esp
  8005a9:	0f be 80 4f 2b 80 00 	movsbl 0x802b4f(%eax),%eax
  8005b0:	50                   	push   %eax
  8005b1:	ff d7                	call   *%edi
}
  8005b3:	83 c4 10             	add    $0x10,%esp
  8005b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b9:	5b                   	pop    %ebx
  8005ba:	5e                   	pop    %esi
  8005bb:	5f                   	pop    %edi
  8005bc:	5d                   	pop    %ebp
  8005bd:	c3                   	ret    

008005be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005be:	55                   	push   %ebp
  8005bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005c1:	83 fa 01             	cmp    $0x1,%edx
  8005c4:	7e 0e                	jle    8005d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005c6:	8b 10                	mov    (%eax),%edx
  8005c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005cb:	89 08                	mov    %ecx,(%eax)
  8005cd:	8b 02                	mov    (%edx),%eax
  8005cf:	8b 52 04             	mov    0x4(%edx),%edx
  8005d2:	eb 22                	jmp    8005f6 <getuint+0x38>
	else if (lflag)
  8005d4:	85 d2                	test   %edx,%edx
  8005d6:	74 10                	je     8005e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005d8:	8b 10                	mov    (%eax),%edx
  8005da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005dd:	89 08                	mov    %ecx,(%eax)
  8005df:	8b 02                	mov    (%edx),%eax
  8005e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e6:	eb 0e                	jmp    8005f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005e8:	8b 10                	mov    (%eax),%edx
  8005ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ed:	89 08                	mov    %ecx,(%eax)
  8005ef:	8b 02                	mov    (%edx),%eax
  8005f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005f6:	5d                   	pop    %ebp
  8005f7:	c3                   	ret    

008005f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
  8005fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800602:	8b 10                	mov    (%eax),%edx
  800604:	3b 50 04             	cmp    0x4(%eax),%edx
  800607:	73 0a                	jae    800613 <sprintputch+0x1b>
		*b->buf++ = ch;
  800609:	8d 4a 01             	lea    0x1(%edx),%ecx
  80060c:	89 08                	mov    %ecx,(%eax)
  80060e:	8b 45 08             	mov    0x8(%ebp),%eax
  800611:	88 02                	mov    %al,(%edx)
}
  800613:	5d                   	pop    %ebp
  800614:	c3                   	ret    

00800615 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800615:	55                   	push   %ebp
  800616:	89 e5                	mov    %esp,%ebp
  800618:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80061e:	50                   	push   %eax
  80061f:	ff 75 10             	pushl  0x10(%ebp)
  800622:	ff 75 0c             	pushl  0xc(%ebp)
  800625:	ff 75 08             	pushl  0x8(%ebp)
  800628:	e8 05 00 00 00       	call   800632 <vprintfmt>
	va_end(ap);
}
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	c9                   	leave  
  800631:	c3                   	ret    

00800632 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800632:	55                   	push   %ebp
  800633:	89 e5                	mov    %esp,%ebp
  800635:	57                   	push   %edi
  800636:	56                   	push   %esi
  800637:	53                   	push   %ebx
  800638:	83 ec 2c             	sub    $0x2c,%esp
  80063b:	8b 75 08             	mov    0x8(%ebp),%esi
  80063e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800641:	8b 7d 10             	mov    0x10(%ebp),%edi
  800644:	eb 12                	jmp    800658 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800646:	85 c0                	test   %eax,%eax
  800648:	0f 84 89 03 00 00    	je     8009d7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	50                   	push   %eax
  800653:	ff d6                	call   *%esi
  800655:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800658:	83 c7 01             	add    $0x1,%edi
  80065b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80065f:	83 f8 25             	cmp    $0x25,%eax
  800662:	75 e2                	jne    800646 <vprintfmt+0x14>
  800664:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800668:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80066f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800676:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80067d:	ba 00 00 00 00       	mov    $0x0,%edx
  800682:	eb 07                	jmp    80068b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800684:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800687:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068b:	8d 47 01             	lea    0x1(%edi),%eax
  80068e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800691:	0f b6 07             	movzbl (%edi),%eax
  800694:	0f b6 c8             	movzbl %al,%ecx
  800697:	83 e8 23             	sub    $0x23,%eax
  80069a:	3c 55                	cmp    $0x55,%al
  80069c:	0f 87 1a 03 00 00    	ja     8009bc <vprintfmt+0x38a>
  8006a2:	0f b6 c0             	movzbl %al,%eax
  8006a5:	ff 24 85 a0 2c 80 00 	jmp    *0x802ca0(,%eax,4)
  8006ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006af:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8006b3:	eb d6                	jmp    80068b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006c0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8006c3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8006c7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8006ca:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8006cd:	83 fa 09             	cmp    $0x9,%edx
  8006d0:	77 39                	ja     80070b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006d2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006d5:	eb e9                	jmp    8006c0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8d 48 04             	lea    0x4(%eax),%ecx
  8006dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006e0:	8b 00                	mov    (%eax),%eax
  8006e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006e8:	eb 27                	jmp    800711 <vprintfmt+0xdf>
  8006ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f4:	0f 49 c8             	cmovns %eax,%ecx
  8006f7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006fd:	eb 8c                	jmp    80068b <vprintfmt+0x59>
  8006ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800702:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800709:	eb 80                	jmp    80068b <vprintfmt+0x59>
  80070b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80070e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800711:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800715:	0f 89 70 ff ff ff    	jns    80068b <vprintfmt+0x59>
				width = precision, precision = -1;
  80071b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80071e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800721:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800728:	e9 5e ff ff ff       	jmp    80068b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80072d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800730:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800733:	e9 53 ff ff ff       	jmp    80068b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800738:	8b 45 14             	mov    0x14(%ebp),%eax
  80073b:	8d 50 04             	lea    0x4(%eax),%edx
  80073e:	89 55 14             	mov    %edx,0x14(%ebp)
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	53                   	push   %ebx
  800745:	ff 30                	pushl  (%eax)
  800747:	ff d6                	call   *%esi
			break;
  800749:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80074f:	e9 04 ff ff ff       	jmp    800658 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8d 50 04             	lea    0x4(%eax),%edx
  80075a:	89 55 14             	mov    %edx,0x14(%ebp)
  80075d:	8b 00                	mov    (%eax),%eax
  80075f:	99                   	cltd   
  800760:	31 d0                	xor    %edx,%eax
  800762:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800764:	83 f8 0f             	cmp    $0xf,%eax
  800767:	7f 0b                	jg     800774 <vprintfmt+0x142>
  800769:	8b 14 85 00 2e 80 00 	mov    0x802e00(,%eax,4),%edx
  800770:	85 d2                	test   %edx,%edx
  800772:	75 18                	jne    80078c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800774:	50                   	push   %eax
  800775:	68 67 2b 80 00       	push   $0x802b67
  80077a:	53                   	push   %ebx
  80077b:	56                   	push   %esi
  80077c:	e8 94 fe ff ff       	call   800615 <printfmt>
  800781:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800784:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800787:	e9 cc fe ff ff       	jmp    800658 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80078c:	52                   	push   %edx
  80078d:	68 ad 2f 80 00       	push   $0x802fad
  800792:	53                   	push   %ebx
  800793:	56                   	push   %esi
  800794:	e8 7c fe ff ff       	call   800615 <printfmt>
  800799:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079f:	e9 b4 fe ff ff       	jmp    800658 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8d 50 04             	lea    0x4(%eax),%edx
  8007aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ad:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8007af:	85 ff                	test   %edi,%edi
  8007b1:	b8 60 2b 80 00       	mov    $0x802b60,%eax
  8007b6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8007b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007bd:	0f 8e 94 00 00 00    	jle    800857 <vprintfmt+0x225>
  8007c3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8007c7:	0f 84 98 00 00 00    	je     800865 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	ff 75 d0             	pushl  -0x30(%ebp)
  8007d3:	57                   	push   %edi
  8007d4:	e8 86 02 00 00       	call   800a5f <strnlen>
  8007d9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007dc:	29 c1                	sub    %eax,%ecx
  8007de:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007e1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8007e4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007eb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007ee:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007f0:	eb 0f                	jmp    800801 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8007f2:	83 ec 08             	sub    $0x8,%esp
  8007f5:	53                   	push   %ebx
  8007f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8007f9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007fb:	83 ef 01             	sub    $0x1,%edi
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	85 ff                	test   %edi,%edi
  800803:	7f ed                	jg     8007f2 <vprintfmt+0x1c0>
  800805:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800808:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80080b:	85 c9                	test   %ecx,%ecx
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
  800812:	0f 49 c1             	cmovns %ecx,%eax
  800815:	29 c1                	sub    %eax,%ecx
  800817:	89 75 08             	mov    %esi,0x8(%ebp)
  80081a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80081d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800820:	89 cb                	mov    %ecx,%ebx
  800822:	eb 4d                	jmp    800871 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800824:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800828:	74 1b                	je     800845 <vprintfmt+0x213>
  80082a:	0f be c0             	movsbl %al,%eax
  80082d:	83 e8 20             	sub    $0x20,%eax
  800830:	83 f8 5e             	cmp    $0x5e,%eax
  800833:	76 10                	jbe    800845 <vprintfmt+0x213>
					putch('?', putdat);
  800835:	83 ec 08             	sub    $0x8,%esp
  800838:	ff 75 0c             	pushl  0xc(%ebp)
  80083b:	6a 3f                	push   $0x3f
  80083d:	ff 55 08             	call   *0x8(%ebp)
  800840:	83 c4 10             	add    $0x10,%esp
  800843:	eb 0d                	jmp    800852 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800845:	83 ec 08             	sub    $0x8,%esp
  800848:	ff 75 0c             	pushl  0xc(%ebp)
  80084b:	52                   	push   %edx
  80084c:	ff 55 08             	call   *0x8(%ebp)
  80084f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800852:	83 eb 01             	sub    $0x1,%ebx
  800855:	eb 1a                	jmp    800871 <vprintfmt+0x23f>
  800857:	89 75 08             	mov    %esi,0x8(%ebp)
  80085a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80085d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800860:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800863:	eb 0c                	jmp    800871 <vprintfmt+0x23f>
  800865:	89 75 08             	mov    %esi,0x8(%ebp)
  800868:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80086b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80086e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800871:	83 c7 01             	add    $0x1,%edi
  800874:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800878:	0f be d0             	movsbl %al,%edx
  80087b:	85 d2                	test   %edx,%edx
  80087d:	74 23                	je     8008a2 <vprintfmt+0x270>
  80087f:	85 f6                	test   %esi,%esi
  800881:	78 a1                	js     800824 <vprintfmt+0x1f2>
  800883:	83 ee 01             	sub    $0x1,%esi
  800886:	79 9c                	jns    800824 <vprintfmt+0x1f2>
  800888:	89 df                	mov    %ebx,%edi
  80088a:	8b 75 08             	mov    0x8(%ebp),%esi
  80088d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800890:	eb 18                	jmp    8008aa <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800892:	83 ec 08             	sub    $0x8,%esp
  800895:	53                   	push   %ebx
  800896:	6a 20                	push   $0x20
  800898:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80089a:	83 ef 01             	sub    $0x1,%edi
  80089d:	83 c4 10             	add    $0x10,%esp
  8008a0:	eb 08                	jmp    8008aa <vprintfmt+0x278>
  8008a2:	89 df                	mov    %ebx,%edi
  8008a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008aa:	85 ff                	test   %edi,%edi
  8008ac:	7f e4                	jg     800892 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008b1:	e9 a2 fd ff ff       	jmp    800658 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008b6:	83 fa 01             	cmp    $0x1,%edx
  8008b9:	7e 16                	jle    8008d1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8008bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008be:	8d 50 08             	lea    0x8(%eax),%edx
  8008c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c4:	8b 50 04             	mov    0x4(%eax),%edx
  8008c7:	8b 00                	mov    (%eax),%eax
  8008c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008cf:	eb 32                	jmp    800903 <vprintfmt+0x2d1>
	else if (lflag)
  8008d1:	85 d2                	test   %edx,%edx
  8008d3:	74 18                	je     8008ed <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8008d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d8:	8d 50 04             	lea    0x4(%eax),%edx
  8008db:	89 55 14             	mov    %edx,0x14(%ebp)
  8008de:	8b 00                	mov    (%eax),%eax
  8008e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008e3:	89 c1                	mov    %eax,%ecx
  8008e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8008e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008eb:	eb 16                	jmp    800903 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8008ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f0:	8d 50 04             	lea    0x4(%eax),%edx
  8008f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f6:	8b 00                	mov    (%eax),%eax
  8008f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008fb:	89 c1                	mov    %eax,%ecx
  8008fd:	c1 f9 1f             	sar    $0x1f,%ecx
  800900:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800903:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800906:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800909:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80090e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800912:	79 74                	jns    800988 <vprintfmt+0x356>
				putch('-', putdat);
  800914:	83 ec 08             	sub    $0x8,%esp
  800917:	53                   	push   %ebx
  800918:	6a 2d                	push   $0x2d
  80091a:	ff d6                	call   *%esi
				num = -(long long) num;
  80091c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80091f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800922:	f7 d8                	neg    %eax
  800924:	83 d2 00             	adc    $0x0,%edx
  800927:	f7 da                	neg    %edx
  800929:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80092c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800931:	eb 55                	jmp    800988 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800933:	8d 45 14             	lea    0x14(%ebp),%eax
  800936:	e8 83 fc ff ff       	call   8005be <getuint>
			base = 10;
  80093b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800940:	eb 46                	jmp    800988 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800942:	8d 45 14             	lea    0x14(%ebp),%eax
  800945:	e8 74 fc ff ff       	call   8005be <getuint>
			base = 8;
  80094a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80094f:	eb 37                	jmp    800988 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800951:	83 ec 08             	sub    $0x8,%esp
  800954:	53                   	push   %ebx
  800955:	6a 30                	push   $0x30
  800957:	ff d6                	call   *%esi
			putch('x', putdat);
  800959:	83 c4 08             	add    $0x8,%esp
  80095c:	53                   	push   %ebx
  80095d:	6a 78                	push   $0x78
  80095f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800961:	8b 45 14             	mov    0x14(%ebp),%eax
  800964:	8d 50 04             	lea    0x4(%eax),%edx
  800967:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80096a:	8b 00                	mov    (%eax),%eax
  80096c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800971:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800974:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800979:	eb 0d                	jmp    800988 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80097b:	8d 45 14             	lea    0x14(%ebp),%eax
  80097e:	e8 3b fc ff ff       	call   8005be <getuint>
			base = 16;
  800983:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800988:	83 ec 0c             	sub    $0xc,%esp
  80098b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80098f:	57                   	push   %edi
  800990:	ff 75 e0             	pushl  -0x20(%ebp)
  800993:	51                   	push   %ecx
  800994:	52                   	push   %edx
  800995:	50                   	push   %eax
  800996:	89 da                	mov    %ebx,%edx
  800998:	89 f0                	mov    %esi,%eax
  80099a:	e8 70 fb ff ff       	call   80050f <printnum>
			break;
  80099f:	83 c4 20             	add    $0x20,%esp
  8009a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009a5:	e9 ae fc ff ff       	jmp    800658 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009aa:	83 ec 08             	sub    $0x8,%esp
  8009ad:	53                   	push   %ebx
  8009ae:	51                   	push   %ecx
  8009af:	ff d6                	call   *%esi
			break;
  8009b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009b7:	e9 9c fc ff ff       	jmp    800658 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009bc:	83 ec 08             	sub    $0x8,%esp
  8009bf:	53                   	push   %ebx
  8009c0:	6a 25                	push   $0x25
  8009c2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009c4:	83 c4 10             	add    $0x10,%esp
  8009c7:	eb 03                	jmp    8009cc <vprintfmt+0x39a>
  8009c9:	83 ef 01             	sub    $0x1,%edi
  8009cc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8009d0:	75 f7                	jne    8009c9 <vprintfmt+0x397>
  8009d2:	e9 81 fc ff ff       	jmp    800658 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8009d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5f                   	pop    %edi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	83 ec 18             	sub    $0x18,%esp
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009fc:	85 c0                	test   %eax,%eax
  8009fe:	74 26                	je     800a26 <vsnprintf+0x47>
  800a00:	85 d2                	test   %edx,%edx
  800a02:	7e 22                	jle    800a26 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a04:	ff 75 14             	pushl  0x14(%ebp)
  800a07:	ff 75 10             	pushl  0x10(%ebp)
  800a0a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a0d:	50                   	push   %eax
  800a0e:	68 f8 05 80 00       	push   $0x8005f8
  800a13:	e8 1a fc ff ff       	call   800632 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a18:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a1b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a21:	83 c4 10             	add    $0x10,%esp
  800a24:	eb 05                	jmp    800a2b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a26:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    

00800a2d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a33:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a36:	50                   	push   %eax
  800a37:	ff 75 10             	pushl  0x10(%ebp)
  800a3a:	ff 75 0c             	pushl  0xc(%ebp)
  800a3d:	ff 75 08             	pushl  0x8(%ebp)
  800a40:	e8 9a ff ff ff       	call   8009df <vsnprintf>
	va_end(ap);

	return rc;
}
  800a45:	c9                   	leave  
  800a46:	c3                   	ret    

00800a47 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a52:	eb 03                	jmp    800a57 <strlen+0x10>
		n++;
  800a54:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a57:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a5b:	75 f7                	jne    800a54 <strlen+0xd>
		n++;
	return n;
}
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a65:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a68:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6d:	eb 03                	jmp    800a72 <strnlen+0x13>
		n++;
  800a6f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a72:	39 c2                	cmp    %eax,%edx
  800a74:	74 08                	je     800a7e <strnlen+0x1f>
  800a76:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a7a:	75 f3                	jne    800a6f <strnlen+0x10>
  800a7c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	53                   	push   %ebx
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a8a:	89 c2                	mov    %eax,%edx
  800a8c:	83 c2 01             	add    $0x1,%edx
  800a8f:	83 c1 01             	add    $0x1,%ecx
  800a92:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a96:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a99:	84 db                	test   %bl,%bl
  800a9b:	75 ef                	jne    800a8c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	53                   	push   %ebx
  800aa4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa7:	53                   	push   %ebx
  800aa8:	e8 9a ff ff ff       	call   800a47 <strlen>
  800aad:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ab0:	ff 75 0c             	pushl  0xc(%ebp)
  800ab3:	01 d8                	add    %ebx,%eax
  800ab5:	50                   	push   %eax
  800ab6:	e8 c5 ff ff ff       	call   800a80 <strcpy>
	return dst;
}
  800abb:	89 d8                	mov    %ebx,%eax
  800abd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
  800ac7:	8b 75 08             	mov    0x8(%ebp),%esi
  800aca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acd:	89 f3                	mov    %esi,%ebx
  800acf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ad2:	89 f2                	mov    %esi,%edx
  800ad4:	eb 0f                	jmp    800ae5 <strncpy+0x23>
		*dst++ = *src;
  800ad6:	83 c2 01             	add    $0x1,%edx
  800ad9:	0f b6 01             	movzbl (%ecx),%eax
  800adc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800adf:	80 39 01             	cmpb   $0x1,(%ecx)
  800ae2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae5:	39 da                	cmp    %ebx,%edx
  800ae7:	75 ed                	jne    800ad6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ae9:	89 f0                	mov    %esi,%eax
  800aeb:	5b                   	pop    %ebx
  800aec:	5e                   	pop    %esi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	8b 75 08             	mov    0x8(%ebp),%esi
  800af7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afa:	8b 55 10             	mov    0x10(%ebp),%edx
  800afd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aff:	85 d2                	test   %edx,%edx
  800b01:	74 21                	je     800b24 <strlcpy+0x35>
  800b03:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b07:	89 f2                	mov    %esi,%edx
  800b09:	eb 09                	jmp    800b14 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b0b:	83 c2 01             	add    $0x1,%edx
  800b0e:	83 c1 01             	add    $0x1,%ecx
  800b11:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b14:	39 c2                	cmp    %eax,%edx
  800b16:	74 09                	je     800b21 <strlcpy+0x32>
  800b18:	0f b6 19             	movzbl (%ecx),%ebx
  800b1b:	84 db                	test   %bl,%bl
  800b1d:	75 ec                	jne    800b0b <strlcpy+0x1c>
  800b1f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b21:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b24:	29 f0                	sub    %esi,%eax
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b30:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b33:	eb 06                	jmp    800b3b <strcmp+0x11>
		p++, q++;
  800b35:	83 c1 01             	add    $0x1,%ecx
  800b38:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b3b:	0f b6 01             	movzbl (%ecx),%eax
  800b3e:	84 c0                	test   %al,%al
  800b40:	74 04                	je     800b46 <strcmp+0x1c>
  800b42:	3a 02                	cmp    (%edx),%al
  800b44:	74 ef                	je     800b35 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b46:	0f b6 c0             	movzbl %al,%eax
  800b49:	0f b6 12             	movzbl (%edx),%edx
  800b4c:	29 d0                	sub    %edx,%eax
}
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	53                   	push   %ebx
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5a:	89 c3                	mov    %eax,%ebx
  800b5c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b5f:	eb 06                	jmp    800b67 <strncmp+0x17>
		n--, p++, q++;
  800b61:	83 c0 01             	add    $0x1,%eax
  800b64:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b67:	39 d8                	cmp    %ebx,%eax
  800b69:	74 15                	je     800b80 <strncmp+0x30>
  800b6b:	0f b6 08             	movzbl (%eax),%ecx
  800b6e:	84 c9                	test   %cl,%cl
  800b70:	74 04                	je     800b76 <strncmp+0x26>
  800b72:	3a 0a                	cmp    (%edx),%cl
  800b74:	74 eb                	je     800b61 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b76:	0f b6 00             	movzbl (%eax),%eax
  800b79:	0f b6 12             	movzbl (%edx),%edx
  800b7c:	29 d0                	sub    %edx,%eax
  800b7e:	eb 05                	jmp    800b85 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b85:	5b                   	pop    %ebx
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b92:	eb 07                	jmp    800b9b <strchr+0x13>
		if (*s == c)
  800b94:	38 ca                	cmp    %cl,%dl
  800b96:	74 0f                	je     800ba7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b98:	83 c0 01             	add    $0x1,%eax
  800b9b:	0f b6 10             	movzbl (%eax),%edx
  800b9e:	84 d2                	test   %dl,%dl
  800ba0:	75 f2                	jne    800b94 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	8b 45 08             	mov    0x8(%ebp),%eax
  800baf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb3:	eb 03                	jmp    800bb8 <strfind+0xf>
  800bb5:	83 c0 01             	add    $0x1,%eax
  800bb8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bbb:	38 ca                	cmp    %cl,%dl
  800bbd:	74 04                	je     800bc3 <strfind+0x1a>
  800bbf:	84 d2                	test   %dl,%dl
  800bc1:	75 f2                	jne    800bb5 <strfind+0xc>
			break;
	return (char *) s;
}
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bd1:	85 c9                	test   %ecx,%ecx
  800bd3:	74 36                	je     800c0b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bdb:	75 28                	jne    800c05 <memset+0x40>
  800bdd:	f6 c1 03             	test   $0x3,%cl
  800be0:	75 23                	jne    800c05 <memset+0x40>
		c &= 0xFF;
  800be2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be6:	89 d3                	mov    %edx,%ebx
  800be8:	c1 e3 08             	shl    $0x8,%ebx
  800beb:	89 d6                	mov    %edx,%esi
  800bed:	c1 e6 18             	shl    $0x18,%esi
  800bf0:	89 d0                	mov    %edx,%eax
  800bf2:	c1 e0 10             	shl    $0x10,%eax
  800bf5:	09 f0                	or     %esi,%eax
  800bf7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bf9:	89 d8                	mov    %ebx,%eax
  800bfb:	09 d0                	or     %edx,%eax
  800bfd:	c1 e9 02             	shr    $0x2,%ecx
  800c00:	fc                   	cld    
  800c01:	f3 ab                	rep stos %eax,%es:(%edi)
  800c03:	eb 06                	jmp    800c0b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c08:	fc                   	cld    
  800c09:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c0b:	89 f8                	mov    %edi,%eax
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c20:	39 c6                	cmp    %eax,%esi
  800c22:	73 35                	jae    800c59 <memmove+0x47>
  800c24:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c27:	39 d0                	cmp    %edx,%eax
  800c29:	73 2e                	jae    800c59 <memmove+0x47>
		s += n;
		d += n;
  800c2b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2e:	89 d6                	mov    %edx,%esi
  800c30:	09 fe                	or     %edi,%esi
  800c32:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c38:	75 13                	jne    800c4d <memmove+0x3b>
  800c3a:	f6 c1 03             	test   $0x3,%cl
  800c3d:	75 0e                	jne    800c4d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c3f:	83 ef 04             	sub    $0x4,%edi
  800c42:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c45:	c1 e9 02             	shr    $0x2,%ecx
  800c48:	fd                   	std    
  800c49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4b:	eb 09                	jmp    800c56 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c4d:	83 ef 01             	sub    $0x1,%edi
  800c50:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c53:	fd                   	std    
  800c54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c56:	fc                   	cld    
  800c57:	eb 1d                	jmp    800c76 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c59:	89 f2                	mov    %esi,%edx
  800c5b:	09 c2                	or     %eax,%edx
  800c5d:	f6 c2 03             	test   $0x3,%dl
  800c60:	75 0f                	jne    800c71 <memmove+0x5f>
  800c62:	f6 c1 03             	test   $0x3,%cl
  800c65:	75 0a                	jne    800c71 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c67:	c1 e9 02             	shr    $0x2,%ecx
  800c6a:	89 c7                	mov    %eax,%edi
  800c6c:	fc                   	cld    
  800c6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6f:	eb 05                	jmp    800c76 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c71:	89 c7                	mov    %eax,%edi
  800c73:	fc                   	cld    
  800c74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c7d:	ff 75 10             	pushl  0x10(%ebp)
  800c80:	ff 75 0c             	pushl  0xc(%ebp)
  800c83:	ff 75 08             	pushl  0x8(%ebp)
  800c86:	e8 87 ff ff ff       	call   800c12 <memmove>
}
  800c8b:	c9                   	leave  
  800c8c:	c3                   	ret    

00800c8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	8b 45 08             	mov    0x8(%ebp),%eax
  800c95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c98:	89 c6                	mov    %eax,%esi
  800c9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c9d:	eb 1a                	jmp    800cb9 <memcmp+0x2c>
		if (*s1 != *s2)
  800c9f:	0f b6 08             	movzbl (%eax),%ecx
  800ca2:	0f b6 1a             	movzbl (%edx),%ebx
  800ca5:	38 d9                	cmp    %bl,%cl
  800ca7:	74 0a                	je     800cb3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ca9:	0f b6 c1             	movzbl %cl,%eax
  800cac:	0f b6 db             	movzbl %bl,%ebx
  800caf:	29 d8                	sub    %ebx,%eax
  800cb1:	eb 0f                	jmp    800cc2 <memcmp+0x35>
		s1++, s2++;
  800cb3:	83 c0 01             	add    $0x1,%eax
  800cb6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb9:	39 f0                	cmp    %esi,%eax
  800cbb:	75 e2                	jne    800c9f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	53                   	push   %ebx
  800cca:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ccd:	89 c1                	mov    %eax,%ecx
  800ccf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cd6:	eb 0a                	jmp    800ce2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd8:	0f b6 10             	movzbl (%eax),%edx
  800cdb:	39 da                	cmp    %ebx,%edx
  800cdd:	74 07                	je     800ce6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cdf:	83 c0 01             	add    $0x1,%eax
  800ce2:	39 c8                	cmp    %ecx,%eax
  800ce4:	72 f2                	jb     800cd8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ce6:	5b                   	pop    %ebx
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf5:	eb 03                	jmp    800cfa <strtol+0x11>
		s++;
  800cf7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cfa:	0f b6 01             	movzbl (%ecx),%eax
  800cfd:	3c 20                	cmp    $0x20,%al
  800cff:	74 f6                	je     800cf7 <strtol+0xe>
  800d01:	3c 09                	cmp    $0x9,%al
  800d03:	74 f2                	je     800cf7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d05:	3c 2b                	cmp    $0x2b,%al
  800d07:	75 0a                	jne    800d13 <strtol+0x2a>
		s++;
  800d09:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d0c:	bf 00 00 00 00       	mov    $0x0,%edi
  800d11:	eb 11                	jmp    800d24 <strtol+0x3b>
  800d13:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d18:	3c 2d                	cmp    $0x2d,%al
  800d1a:	75 08                	jne    800d24 <strtol+0x3b>
		s++, neg = 1;
  800d1c:	83 c1 01             	add    $0x1,%ecx
  800d1f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d24:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d2a:	75 15                	jne    800d41 <strtol+0x58>
  800d2c:	80 39 30             	cmpb   $0x30,(%ecx)
  800d2f:	75 10                	jne    800d41 <strtol+0x58>
  800d31:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d35:	75 7c                	jne    800db3 <strtol+0xca>
		s += 2, base = 16;
  800d37:	83 c1 02             	add    $0x2,%ecx
  800d3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d3f:	eb 16                	jmp    800d57 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d41:	85 db                	test   %ebx,%ebx
  800d43:	75 12                	jne    800d57 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d45:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d4a:	80 39 30             	cmpb   $0x30,(%ecx)
  800d4d:	75 08                	jne    800d57 <strtol+0x6e>
		s++, base = 8;
  800d4f:	83 c1 01             	add    $0x1,%ecx
  800d52:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d57:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d5f:	0f b6 11             	movzbl (%ecx),%edx
  800d62:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d65:	89 f3                	mov    %esi,%ebx
  800d67:	80 fb 09             	cmp    $0x9,%bl
  800d6a:	77 08                	ja     800d74 <strtol+0x8b>
			dig = *s - '0';
  800d6c:	0f be d2             	movsbl %dl,%edx
  800d6f:	83 ea 30             	sub    $0x30,%edx
  800d72:	eb 22                	jmp    800d96 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d74:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d77:	89 f3                	mov    %esi,%ebx
  800d79:	80 fb 19             	cmp    $0x19,%bl
  800d7c:	77 08                	ja     800d86 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d7e:	0f be d2             	movsbl %dl,%edx
  800d81:	83 ea 57             	sub    $0x57,%edx
  800d84:	eb 10                	jmp    800d96 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d86:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d89:	89 f3                	mov    %esi,%ebx
  800d8b:	80 fb 19             	cmp    $0x19,%bl
  800d8e:	77 16                	ja     800da6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d90:	0f be d2             	movsbl %dl,%edx
  800d93:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d96:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d99:	7d 0b                	jge    800da6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d9b:	83 c1 01             	add    $0x1,%ecx
  800d9e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800da2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800da4:	eb b9                	jmp    800d5f <strtol+0x76>

	if (endptr)
  800da6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800daa:	74 0d                	je     800db9 <strtol+0xd0>
		*endptr = (char *) s;
  800dac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800daf:	89 0e                	mov    %ecx,(%esi)
  800db1:	eb 06                	jmp    800db9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800db3:	85 db                	test   %ebx,%ebx
  800db5:	74 98                	je     800d4f <strtol+0x66>
  800db7:	eb 9e                	jmp    800d57 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800db9:	89 c2                	mov    %eax,%edx
  800dbb:	f7 da                	neg    %edx
  800dbd:	85 ff                	test   %edi,%edi
  800dbf:	0f 45 c2             	cmovne %edx,%eax
}
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5f                   	pop    %edi
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800dcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	89 c3                	mov    %eax,%ebx
  800dda:	89 c7                	mov    %eax,%edi
  800ddc:	89 c6                	mov    %eax,%esi
  800dde:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	ba 00 00 00 00       	mov    $0x0,%edx
  800df0:	b8 01 00 00 00       	mov    $0x1,%eax
  800df5:	89 d1                	mov    %edx,%ecx
  800df7:	89 d3                	mov    %edx,%ebx
  800df9:	89 d7                	mov    %edx,%edi
  800dfb:	89 d6                	mov    %edx,%esi
  800dfd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
  800e0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e12:	b8 03 00 00 00       	mov    $0x3,%eax
  800e17:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1a:	89 cb                	mov    %ecx,%ebx
  800e1c:	89 cf                	mov    %ecx,%edi
  800e1e:	89 ce                	mov    %ecx,%esi
  800e20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e22:	85 c0                	test   %eax,%eax
  800e24:	7e 17                	jle    800e3d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e26:	83 ec 0c             	sub    $0xc,%esp
  800e29:	50                   	push   %eax
  800e2a:	6a 03                	push   $0x3
  800e2c:	68 5f 2e 80 00       	push   $0x802e5f
  800e31:	6a 23                	push   $0x23
  800e33:	68 7c 2e 80 00       	push   $0x802e7c
  800e38:	e8 e5 f5 ff ff       	call   800422 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	57                   	push   %edi
  800e49:	56                   	push   %esi
  800e4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e50:	b8 02 00 00 00       	mov    $0x2,%eax
  800e55:	89 d1                	mov    %edx,%ecx
  800e57:	89 d3                	mov    %edx,%ebx
  800e59:	89 d7                	mov    %edx,%edi
  800e5b:	89 d6                	mov    %edx,%esi
  800e5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <sys_yield>:

void
sys_yield(void)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	57                   	push   %edi
  800e68:	56                   	push   %esi
  800e69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e74:	89 d1                	mov    %edx,%ecx
  800e76:	89 d3                	mov    %edx,%ebx
  800e78:	89 d7                	mov    %edx,%edi
  800e7a:	89 d6                	mov    %edx,%esi
  800e7c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
  800e89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8c:	be 00 00 00 00       	mov    $0x0,%esi
  800e91:	b8 04 00 00 00       	mov    $0x4,%eax
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9f:	89 f7                	mov    %esi,%edi
  800ea1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	7e 17                	jle    800ebe <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea7:	83 ec 0c             	sub    $0xc,%esp
  800eaa:	50                   	push   %eax
  800eab:	6a 04                	push   $0x4
  800ead:	68 5f 2e 80 00       	push   $0x802e5f
  800eb2:	6a 23                	push   $0x23
  800eb4:	68 7c 2e 80 00       	push   $0x802e7c
  800eb9:	e8 64 f5 ff ff       	call   800422 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ebe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800edd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ee0:	8b 75 18             	mov    0x18(%ebp),%esi
  800ee3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	7e 17                	jle    800f00 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	50                   	push   %eax
  800eed:	6a 05                	push   $0x5
  800eef:	68 5f 2e 80 00       	push   $0x802e5f
  800ef4:	6a 23                	push   $0x23
  800ef6:	68 7c 2e 80 00       	push   $0x802e7c
  800efb:	e8 22 f5 ff ff       	call   800422 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
  800f0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f16:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f21:	89 df                	mov    %ebx,%edi
  800f23:	89 de                	mov    %ebx,%esi
  800f25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f27:	85 c0                	test   %eax,%eax
  800f29:	7e 17                	jle    800f42 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	50                   	push   %eax
  800f2f:	6a 06                	push   $0x6
  800f31:	68 5f 2e 80 00       	push   $0x802e5f
  800f36:	6a 23                	push   $0x23
  800f38:	68 7c 2e 80 00       	push   $0x802e7c
  800f3d:	e8 e0 f4 ff ff       	call   800422 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	57                   	push   %edi
  800f4e:	56                   	push   %esi
  800f4f:	53                   	push   %ebx
  800f50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f58:	b8 08 00 00 00       	mov    $0x8,%eax
  800f5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f60:	8b 55 08             	mov    0x8(%ebp),%edx
  800f63:	89 df                	mov    %ebx,%edi
  800f65:	89 de                	mov    %ebx,%esi
  800f67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	7e 17                	jle    800f84 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6d:	83 ec 0c             	sub    $0xc,%esp
  800f70:	50                   	push   %eax
  800f71:	6a 08                	push   $0x8
  800f73:	68 5f 2e 80 00       	push   $0x802e5f
  800f78:	6a 23                	push   $0x23
  800f7a:	68 7c 2e 80 00       	push   $0x802e7c
  800f7f:	e8 9e f4 ff ff       	call   800422 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f87:	5b                   	pop    %ebx
  800f88:	5e                   	pop    %esi
  800f89:	5f                   	pop    %edi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    

00800f8c <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	57                   	push   %edi
  800f90:	56                   	push   %esi
  800f91:	53                   	push   %ebx
  800f92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9a:	b8 09 00 00 00       	mov    $0x9,%eax
  800f9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa5:	89 df                	mov    %ebx,%edi
  800fa7:	89 de                	mov    %ebx,%esi
  800fa9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fab:	85 c0                	test   %eax,%eax
  800fad:	7e 17                	jle    800fc6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	50                   	push   %eax
  800fb3:	6a 09                	push   $0x9
  800fb5:	68 5f 2e 80 00       	push   $0x802e5f
  800fba:	6a 23                	push   $0x23
  800fbc:	68 7c 2e 80 00       	push   $0x802e7c
  800fc1:	e8 5c f4 ff ff       	call   800422 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc9:	5b                   	pop    %ebx
  800fca:	5e                   	pop    %esi
  800fcb:	5f                   	pop    %edi
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fe1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe7:	89 df                	mov    %ebx,%edi
  800fe9:	89 de                	mov    %ebx,%esi
  800feb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fed:	85 c0                	test   %eax,%eax
  800fef:	7e 17                	jle    801008 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	50                   	push   %eax
  800ff5:	6a 0a                	push   $0xa
  800ff7:	68 5f 2e 80 00       	push   $0x802e5f
  800ffc:	6a 23                	push   $0x23
  800ffe:	68 7c 2e 80 00       	push   $0x802e7c
  801003:	e8 1a f4 ff ff       	call   800422 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801008:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801016:	be 00 00 00 00       	mov    $0x0,%esi
  80101b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801020:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801023:	8b 55 08             	mov    0x8(%ebp),%edx
  801026:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801029:	8b 7d 14             	mov    0x14(%ebp),%edi
  80102c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	57                   	push   %edi
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
  801039:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801041:	b8 0d 00 00 00       	mov    $0xd,%eax
  801046:	8b 55 08             	mov    0x8(%ebp),%edx
  801049:	89 cb                	mov    %ecx,%ebx
  80104b:	89 cf                	mov    %ecx,%edi
  80104d:	89 ce                	mov    %ecx,%esi
  80104f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801051:	85 c0                	test   %eax,%eax
  801053:	7e 17                	jle    80106c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801055:	83 ec 0c             	sub    $0xc,%esp
  801058:	50                   	push   %eax
  801059:	6a 0d                	push   $0xd
  80105b:	68 5f 2e 80 00       	push   $0x802e5f
  801060:	6a 23                	push   $0x23
  801062:	68 7c 2e 80 00       	push   $0x802e7c
  801067:	e8 b6 f3 ff ff       	call   800422 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80106c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106f:	5b                   	pop    %ebx
  801070:	5e                   	pop    %esi
  801071:	5f                   	pop    %edi
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    

00801074 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	57                   	push   %edi
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801084:	8b 55 08             	mov    0x8(%ebp),%edx
  801087:	89 cb                	mov    %ecx,%ebx
  801089:	89 cf                	mov    %ecx,%edi
  80108b:	89 ce                	mov    %ecx,%esi
  80108d:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80109f:	b8 0f 00 00 00       	mov    $0xf,%eax
  8010a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a7:	89 cb                	mov    %ecx,%ebx
  8010a9:	89 cf                	mov    %ecx,%edi
  8010ab:	89 ce                	mov    %ecx,%esi
  8010ad:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	53                   	push   %ebx
  8010b8:	83 ec 04             	sub    $0x4,%esp
  8010bb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010be:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8010c0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8010c4:	74 11                	je     8010d7 <pgfault+0x23>
  8010c6:	89 d8                	mov    %ebx,%eax
  8010c8:	c1 e8 0c             	shr    $0xc,%eax
  8010cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d2:	f6 c4 08             	test   $0x8,%ah
  8010d5:	75 14                	jne    8010eb <pgfault+0x37>
		panic("faulting access");
  8010d7:	83 ec 04             	sub    $0x4,%esp
  8010da:	68 8a 2e 80 00       	push   $0x802e8a
  8010df:	6a 1e                	push   $0x1e
  8010e1:	68 9a 2e 80 00       	push   $0x802e9a
  8010e6:	e8 37 f3 ff ff       	call   800422 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8010eb:	83 ec 04             	sub    $0x4,%esp
  8010ee:	6a 07                	push   $0x7
  8010f0:	68 00 f0 7f 00       	push   $0x7ff000
  8010f5:	6a 00                	push   $0x0
  8010f7:	e8 87 fd ff ff       	call   800e83 <sys_page_alloc>
	if (r < 0) {
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	85 c0                	test   %eax,%eax
  801101:	79 12                	jns    801115 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  801103:	50                   	push   %eax
  801104:	68 a5 2e 80 00       	push   $0x802ea5
  801109:	6a 2c                	push   $0x2c
  80110b:	68 9a 2e 80 00       	push   $0x802e9a
  801110:	e8 0d f3 ff ff       	call   800422 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  801115:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80111b:	83 ec 04             	sub    $0x4,%esp
  80111e:	68 00 10 00 00       	push   $0x1000
  801123:	53                   	push   %ebx
  801124:	68 00 f0 7f 00       	push   $0x7ff000
  801129:	e8 4c fb ff ff       	call   800c7a <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  80112e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801135:	53                   	push   %ebx
  801136:	6a 00                	push   $0x0
  801138:	68 00 f0 7f 00       	push   $0x7ff000
  80113d:	6a 00                	push   $0x0
  80113f:	e8 82 fd ff ff       	call   800ec6 <sys_page_map>
	if (r < 0) {
  801144:	83 c4 20             	add    $0x20,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	79 12                	jns    80115d <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80114b:	50                   	push   %eax
  80114c:	68 a5 2e 80 00       	push   $0x802ea5
  801151:	6a 33                	push   $0x33
  801153:	68 9a 2e 80 00       	push   $0x802e9a
  801158:	e8 c5 f2 ff ff       	call   800422 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  80115d:	83 ec 08             	sub    $0x8,%esp
  801160:	68 00 f0 7f 00       	push   $0x7ff000
  801165:	6a 00                	push   $0x0
  801167:	e8 9c fd ff ff       	call   800f08 <sys_page_unmap>
	if (r < 0) {
  80116c:	83 c4 10             	add    $0x10,%esp
  80116f:	85 c0                	test   %eax,%eax
  801171:	79 12                	jns    801185 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  801173:	50                   	push   %eax
  801174:	68 a5 2e 80 00       	push   $0x802ea5
  801179:	6a 37                	push   $0x37
  80117b:	68 9a 2e 80 00       	push   $0x802e9a
  801180:	e8 9d f2 ff ff       	call   800422 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  801185:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801188:	c9                   	leave  
  801189:	c3                   	ret    

0080118a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	57                   	push   %edi
  80118e:	56                   	push   %esi
  80118f:	53                   	push   %ebx
  801190:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  801193:	68 b4 10 80 00       	push   $0x8010b4
  801198:	e8 b5 13 00 00       	call   802552 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80119d:	b8 07 00 00 00       	mov    $0x7,%eax
  8011a2:	cd 30                	int    $0x30
  8011a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8011a7:	83 c4 10             	add    $0x10,%esp
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	79 17                	jns    8011c5 <fork+0x3b>
		panic("fork fault %e");
  8011ae:	83 ec 04             	sub    $0x4,%esp
  8011b1:	68 be 2e 80 00       	push   $0x802ebe
  8011b6:	68 84 00 00 00       	push   $0x84
  8011bb:	68 9a 2e 80 00       	push   $0x802e9a
  8011c0:	e8 5d f2 ff ff       	call   800422 <_panic>
  8011c5:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8011c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011cb:	75 24                	jne    8011f1 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011cd:	e8 73 fc ff ff       	call   800e45 <sys_getenvid>
  8011d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011d7:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8011dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011e2:	a3 90 77 80 00       	mov    %eax,0x807790
		return 0;
  8011e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ec:	e9 64 01 00 00       	jmp    801355 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8011f1:	83 ec 04             	sub    $0x4,%esp
  8011f4:	6a 07                	push   $0x7
  8011f6:	68 00 f0 bf ee       	push   $0xeebff000
  8011fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011fe:	e8 80 fc ff ff       	call   800e83 <sys_page_alloc>
  801203:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801206:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80120b:	89 d8                	mov    %ebx,%eax
  80120d:	c1 e8 16             	shr    $0x16,%eax
  801210:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801217:	a8 01                	test   $0x1,%al
  801219:	0f 84 fc 00 00 00    	je     80131b <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80121f:	89 d8                	mov    %ebx,%eax
  801221:	c1 e8 0c             	shr    $0xc,%eax
  801224:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80122b:	f6 c2 01             	test   $0x1,%dl
  80122e:	0f 84 e7 00 00 00    	je     80131b <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801234:	89 c6                	mov    %eax,%esi
  801236:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801239:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801240:	f6 c6 04             	test   $0x4,%dh
  801243:	74 39                	je     80127e <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801245:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80124c:	83 ec 0c             	sub    $0xc,%esp
  80124f:	25 07 0e 00 00       	and    $0xe07,%eax
  801254:	50                   	push   %eax
  801255:	56                   	push   %esi
  801256:	57                   	push   %edi
  801257:	56                   	push   %esi
  801258:	6a 00                	push   $0x0
  80125a:	e8 67 fc ff ff       	call   800ec6 <sys_page_map>
		if (r < 0) {
  80125f:	83 c4 20             	add    $0x20,%esp
  801262:	85 c0                	test   %eax,%eax
  801264:	0f 89 b1 00 00 00    	jns    80131b <fork+0x191>
		    	panic("sys page map fault %e");
  80126a:	83 ec 04             	sub    $0x4,%esp
  80126d:	68 cc 2e 80 00       	push   $0x802ecc
  801272:	6a 54                	push   $0x54
  801274:	68 9a 2e 80 00       	push   $0x802e9a
  801279:	e8 a4 f1 ff ff       	call   800422 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80127e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801285:	f6 c2 02             	test   $0x2,%dl
  801288:	75 0c                	jne    801296 <fork+0x10c>
  80128a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801291:	f6 c4 08             	test   $0x8,%ah
  801294:	74 5b                	je     8012f1 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801296:	83 ec 0c             	sub    $0xc,%esp
  801299:	68 05 08 00 00       	push   $0x805
  80129e:	56                   	push   %esi
  80129f:	57                   	push   %edi
  8012a0:	56                   	push   %esi
  8012a1:	6a 00                	push   $0x0
  8012a3:	e8 1e fc ff ff       	call   800ec6 <sys_page_map>
		if (r < 0) {
  8012a8:	83 c4 20             	add    $0x20,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	79 14                	jns    8012c3 <fork+0x139>
		    	panic("sys page map fault %e");
  8012af:	83 ec 04             	sub    $0x4,%esp
  8012b2:	68 cc 2e 80 00       	push   $0x802ecc
  8012b7:	6a 5b                	push   $0x5b
  8012b9:	68 9a 2e 80 00       	push   $0x802e9a
  8012be:	e8 5f f1 ff ff       	call   800422 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8012c3:	83 ec 0c             	sub    $0xc,%esp
  8012c6:	68 05 08 00 00       	push   $0x805
  8012cb:	56                   	push   %esi
  8012cc:	6a 00                	push   $0x0
  8012ce:	56                   	push   %esi
  8012cf:	6a 00                	push   $0x0
  8012d1:	e8 f0 fb ff ff       	call   800ec6 <sys_page_map>
		if (r < 0) {
  8012d6:	83 c4 20             	add    $0x20,%esp
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	79 3e                	jns    80131b <fork+0x191>
		    	panic("sys page map fault %e");
  8012dd:	83 ec 04             	sub    $0x4,%esp
  8012e0:	68 cc 2e 80 00       	push   $0x802ecc
  8012e5:	6a 5f                	push   $0x5f
  8012e7:	68 9a 2e 80 00       	push   $0x802e9a
  8012ec:	e8 31 f1 ff ff       	call   800422 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8012f1:	83 ec 0c             	sub    $0xc,%esp
  8012f4:	6a 05                	push   $0x5
  8012f6:	56                   	push   %esi
  8012f7:	57                   	push   %edi
  8012f8:	56                   	push   %esi
  8012f9:	6a 00                	push   $0x0
  8012fb:	e8 c6 fb ff ff       	call   800ec6 <sys_page_map>
		if (r < 0) {
  801300:	83 c4 20             	add    $0x20,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	79 14                	jns    80131b <fork+0x191>
		    	panic("sys page map fault %e");
  801307:	83 ec 04             	sub    $0x4,%esp
  80130a:	68 cc 2e 80 00       	push   $0x802ecc
  80130f:	6a 64                	push   $0x64
  801311:	68 9a 2e 80 00       	push   $0x802e9a
  801316:	e8 07 f1 ff ff       	call   800422 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80131b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801321:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801327:	0f 85 de fe ff ff    	jne    80120b <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80132d:	a1 90 77 80 00       	mov    0x807790,%eax
  801332:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  801338:	83 ec 08             	sub    $0x8,%esp
  80133b:	50                   	push   %eax
  80133c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80133f:	57                   	push   %edi
  801340:	e8 89 fc ff ff       	call   800fce <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801345:	83 c4 08             	add    $0x8,%esp
  801348:	6a 02                	push   $0x2
  80134a:	57                   	push   %edi
  80134b:	e8 fa fb ff ff       	call   800f4a <sys_env_set_status>
	
	return envid;
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801355:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801358:	5b                   	pop    %ebx
  801359:	5e                   	pop    %esi
  80135a:	5f                   	pop    %edi
  80135b:	5d                   	pop    %ebp
  80135c:	c3                   	ret    

0080135d <sfork>:

envid_t
sfork(void)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801360:	b8 00 00 00 00       	mov    $0x0,%eax
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    

00801367 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	56                   	push   %esi
  80136b:	53                   	push   %ebx
  80136c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80136f:	89 1d 94 77 80 00    	mov    %ebx,0x807794
	cprintf("in fork.c thread create. func: %x\n", func);
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	53                   	push   %ebx
  801379:	68 e4 2e 80 00       	push   $0x802ee4
  80137e:	e8 78 f1 ff ff       	call   8004fb <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801383:	c7 04 24 e8 03 80 00 	movl   $0x8003e8,(%esp)
  80138a:	e8 e5 fc ff ff       	call   801074 <sys_thread_create>
  80138f:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801391:	83 c4 08             	add    $0x8,%esp
  801394:	53                   	push   %ebx
  801395:	68 e4 2e 80 00       	push   $0x802ee4
  80139a:	e8 5c f1 ff ff       	call   8004fb <cprintf>
	return id;
}
  80139f:	89 f0                	mov    %esi,%eax
  8013a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a4:	5b                   	pop    %ebx
  8013a5:	5e                   	pop    %esi
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ae:	05 00 00 00 30       	add    $0x30000000,%eax
  8013b3:	c1 e8 0c             	shr    $0xc,%eax
}
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    

008013b8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013be:	05 00 00 00 30       	add    $0x30000000,%eax
  8013c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013c8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    

008013cf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013da:	89 c2                	mov    %eax,%edx
  8013dc:	c1 ea 16             	shr    $0x16,%edx
  8013df:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013e6:	f6 c2 01             	test   $0x1,%dl
  8013e9:	74 11                	je     8013fc <fd_alloc+0x2d>
  8013eb:	89 c2                	mov    %eax,%edx
  8013ed:	c1 ea 0c             	shr    $0xc,%edx
  8013f0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013f7:	f6 c2 01             	test   $0x1,%dl
  8013fa:	75 09                	jne    801405 <fd_alloc+0x36>
			*fd_store = fd;
  8013fc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801403:	eb 17                	jmp    80141c <fd_alloc+0x4d>
  801405:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80140a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80140f:	75 c9                	jne    8013da <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801411:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801417:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801424:	83 f8 1f             	cmp    $0x1f,%eax
  801427:	77 36                	ja     80145f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801429:	c1 e0 0c             	shl    $0xc,%eax
  80142c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801431:	89 c2                	mov    %eax,%edx
  801433:	c1 ea 16             	shr    $0x16,%edx
  801436:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80143d:	f6 c2 01             	test   $0x1,%dl
  801440:	74 24                	je     801466 <fd_lookup+0x48>
  801442:	89 c2                	mov    %eax,%edx
  801444:	c1 ea 0c             	shr    $0xc,%edx
  801447:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80144e:	f6 c2 01             	test   $0x1,%dl
  801451:	74 1a                	je     80146d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801453:	8b 55 0c             	mov    0xc(%ebp),%edx
  801456:	89 02                	mov    %eax,(%edx)
	return 0;
  801458:	b8 00 00 00 00       	mov    $0x0,%eax
  80145d:	eb 13                	jmp    801472 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80145f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801464:	eb 0c                	jmp    801472 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801466:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146b:	eb 05                	jmp    801472 <fd_lookup+0x54>
  80146d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    

00801474 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80147d:	ba 84 2f 80 00       	mov    $0x802f84,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801482:	eb 13                	jmp    801497 <dev_lookup+0x23>
  801484:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801487:	39 08                	cmp    %ecx,(%eax)
  801489:	75 0c                	jne    801497 <dev_lookup+0x23>
			*dev = devtab[i];
  80148b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80148e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801490:	b8 00 00 00 00       	mov    $0x0,%eax
  801495:	eb 2e                	jmp    8014c5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801497:	8b 02                	mov    (%edx),%eax
  801499:	85 c0                	test   %eax,%eax
  80149b:	75 e7                	jne    801484 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80149d:	a1 90 77 80 00       	mov    0x807790,%eax
  8014a2:	8b 40 7c             	mov    0x7c(%eax),%eax
  8014a5:	83 ec 04             	sub    $0x4,%esp
  8014a8:	51                   	push   %ecx
  8014a9:	50                   	push   %eax
  8014aa:	68 08 2f 80 00       	push   $0x802f08
  8014af:	e8 47 f0 ff ff       	call   8004fb <cprintf>
	*dev = 0;
  8014b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014c5:	c9                   	leave  
  8014c6:	c3                   	ret    

008014c7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	56                   	push   %esi
  8014cb:	53                   	push   %ebx
  8014cc:	83 ec 10             	sub    $0x10,%esp
  8014cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d8:	50                   	push   %eax
  8014d9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014df:	c1 e8 0c             	shr    $0xc,%eax
  8014e2:	50                   	push   %eax
  8014e3:	e8 36 ff ff ff       	call   80141e <fd_lookup>
  8014e8:	83 c4 08             	add    $0x8,%esp
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	78 05                	js     8014f4 <fd_close+0x2d>
	    || fd != fd2)
  8014ef:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014f2:	74 0c                	je     801500 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014f4:	84 db                	test   %bl,%bl
  8014f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fb:	0f 44 c2             	cmove  %edx,%eax
  8014fe:	eb 41                	jmp    801541 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801500:	83 ec 08             	sub    $0x8,%esp
  801503:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801506:	50                   	push   %eax
  801507:	ff 36                	pushl  (%esi)
  801509:	e8 66 ff ff ff       	call   801474 <dev_lookup>
  80150e:	89 c3                	mov    %eax,%ebx
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	85 c0                	test   %eax,%eax
  801515:	78 1a                	js     801531 <fd_close+0x6a>
		if (dev->dev_close)
  801517:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80151d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801522:	85 c0                	test   %eax,%eax
  801524:	74 0b                	je     801531 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801526:	83 ec 0c             	sub    $0xc,%esp
  801529:	56                   	push   %esi
  80152a:	ff d0                	call   *%eax
  80152c:	89 c3                	mov    %eax,%ebx
  80152e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801531:	83 ec 08             	sub    $0x8,%esp
  801534:	56                   	push   %esi
  801535:	6a 00                	push   $0x0
  801537:	e8 cc f9 ff ff       	call   800f08 <sys_page_unmap>
	return r;
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	89 d8                	mov    %ebx,%eax
}
  801541:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801544:	5b                   	pop    %ebx
  801545:	5e                   	pop    %esi
  801546:	5d                   	pop    %ebp
  801547:	c3                   	ret    

00801548 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80154e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	ff 75 08             	pushl  0x8(%ebp)
  801555:	e8 c4 fe ff ff       	call   80141e <fd_lookup>
  80155a:	83 c4 08             	add    $0x8,%esp
  80155d:	85 c0                	test   %eax,%eax
  80155f:	78 10                	js     801571 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801561:	83 ec 08             	sub    $0x8,%esp
  801564:	6a 01                	push   $0x1
  801566:	ff 75 f4             	pushl  -0xc(%ebp)
  801569:	e8 59 ff ff ff       	call   8014c7 <fd_close>
  80156e:	83 c4 10             	add    $0x10,%esp
}
  801571:	c9                   	leave  
  801572:	c3                   	ret    

00801573 <close_all>:

void
close_all(void)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	53                   	push   %ebx
  801577:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80157a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80157f:	83 ec 0c             	sub    $0xc,%esp
  801582:	53                   	push   %ebx
  801583:	e8 c0 ff ff ff       	call   801548 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801588:	83 c3 01             	add    $0x1,%ebx
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	83 fb 20             	cmp    $0x20,%ebx
  801591:	75 ec                	jne    80157f <close_all+0xc>
		close(i);
}
  801593:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801596:	c9                   	leave  
  801597:	c3                   	ret    

00801598 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	57                   	push   %edi
  80159c:	56                   	push   %esi
  80159d:	53                   	push   %ebx
  80159e:	83 ec 2c             	sub    $0x2c,%esp
  8015a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015a4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	ff 75 08             	pushl  0x8(%ebp)
  8015ab:	e8 6e fe ff ff       	call   80141e <fd_lookup>
  8015b0:	83 c4 08             	add    $0x8,%esp
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	0f 88 c1 00 00 00    	js     80167c <dup+0xe4>
		return r;
	close(newfdnum);
  8015bb:	83 ec 0c             	sub    $0xc,%esp
  8015be:	56                   	push   %esi
  8015bf:	e8 84 ff ff ff       	call   801548 <close>

	newfd = INDEX2FD(newfdnum);
  8015c4:	89 f3                	mov    %esi,%ebx
  8015c6:	c1 e3 0c             	shl    $0xc,%ebx
  8015c9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015cf:	83 c4 04             	add    $0x4,%esp
  8015d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015d5:	e8 de fd ff ff       	call   8013b8 <fd2data>
  8015da:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015dc:	89 1c 24             	mov    %ebx,(%esp)
  8015df:	e8 d4 fd ff ff       	call   8013b8 <fd2data>
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015ea:	89 f8                	mov    %edi,%eax
  8015ec:	c1 e8 16             	shr    $0x16,%eax
  8015ef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015f6:	a8 01                	test   $0x1,%al
  8015f8:	74 37                	je     801631 <dup+0x99>
  8015fa:	89 f8                	mov    %edi,%eax
  8015fc:	c1 e8 0c             	shr    $0xc,%eax
  8015ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801606:	f6 c2 01             	test   $0x1,%dl
  801609:	74 26                	je     801631 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80160b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801612:	83 ec 0c             	sub    $0xc,%esp
  801615:	25 07 0e 00 00       	and    $0xe07,%eax
  80161a:	50                   	push   %eax
  80161b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80161e:	6a 00                	push   $0x0
  801620:	57                   	push   %edi
  801621:	6a 00                	push   $0x0
  801623:	e8 9e f8 ff ff       	call   800ec6 <sys_page_map>
  801628:	89 c7                	mov    %eax,%edi
  80162a:	83 c4 20             	add    $0x20,%esp
  80162d:	85 c0                	test   %eax,%eax
  80162f:	78 2e                	js     80165f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801631:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801634:	89 d0                	mov    %edx,%eax
  801636:	c1 e8 0c             	shr    $0xc,%eax
  801639:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801640:	83 ec 0c             	sub    $0xc,%esp
  801643:	25 07 0e 00 00       	and    $0xe07,%eax
  801648:	50                   	push   %eax
  801649:	53                   	push   %ebx
  80164a:	6a 00                	push   $0x0
  80164c:	52                   	push   %edx
  80164d:	6a 00                	push   $0x0
  80164f:	e8 72 f8 ff ff       	call   800ec6 <sys_page_map>
  801654:	89 c7                	mov    %eax,%edi
  801656:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801659:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80165b:	85 ff                	test   %edi,%edi
  80165d:	79 1d                	jns    80167c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	53                   	push   %ebx
  801663:	6a 00                	push   $0x0
  801665:	e8 9e f8 ff ff       	call   800f08 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80166a:	83 c4 08             	add    $0x8,%esp
  80166d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801670:	6a 00                	push   $0x0
  801672:	e8 91 f8 ff ff       	call   800f08 <sys_page_unmap>
	return r;
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	89 f8                	mov    %edi,%eax
}
  80167c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167f:	5b                   	pop    %ebx
  801680:	5e                   	pop    %esi
  801681:	5f                   	pop    %edi
  801682:	5d                   	pop    %ebp
  801683:	c3                   	ret    

00801684 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	53                   	push   %ebx
  801688:	83 ec 14             	sub    $0x14,%esp
  80168b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801691:	50                   	push   %eax
  801692:	53                   	push   %ebx
  801693:	e8 86 fd ff ff       	call   80141e <fd_lookup>
  801698:	83 c4 08             	add    $0x8,%esp
  80169b:	89 c2                	mov    %eax,%edx
  80169d:	85 c0                	test   %eax,%eax
  80169f:	78 6d                	js     80170e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a1:	83 ec 08             	sub    $0x8,%esp
  8016a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a7:	50                   	push   %eax
  8016a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ab:	ff 30                	pushl  (%eax)
  8016ad:	e8 c2 fd ff ff       	call   801474 <dev_lookup>
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	78 4c                	js     801705 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016bc:	8b 42 08             	mov    0x8(%edx),%eax
  8016bf:	83 e0 03             	and    $0x3,%eax
  8016c2:	83 f8 01             	cmp    $0x1,%eax
  8016c5:	75 21                	jne    8016e8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c7:	a1 90 77 80 00       	mov    0x807790,%eax
  8016cc:	8b 40 7c             	mov    0x7c(%eax),%eax
  8016cf:	83 ec 04             	sub    $0x4,%esp
  8016d2:	53                   	push   %ebx
  8016d3:	50                   	push   %eax
  8016d4:	68 49 2f 80 00       	push   $0x802f49
  8016d9:	e8 1d ee ff ff       	call   8004fb <cprintf>
		return -E_INVAL;
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e6:	eb 26                	jmp    80170e <read+0x8a>
	}
	if (!dev->dev_read)
  8016e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016eb:	8b 40 08             	mov    0x8(%eax),%eax
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	74 17                	je     801709 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016f2:	83 ec 04             	sub    $0x4,%esp
  8016f5:	ff 75 10             	pushl  0x10(%ebp)
  8016f8:	ff 75 0c             	pushl  0xc(%ebp)
  8016fb:	52                   	push   %edx
  8016fc:	ff d0                	call   *%eax
  8016fe:	89 c2                	mov    %eax,%edx
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	eb 09                	jmp    80170e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801705:	89 c2                	mov    %eax,%edx
  801707:	eb 05                	jmp    80170e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801709:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80170e:	89 d0                	mov    %edx,%eax
  801710:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	57                   	push   %edi
  801719:	56                   	push   %esi
  80171a:	53                   	push   %ebx
  80171b:	83 ec 0c             	sub    $0xc,%esp
  80171e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801721:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801724:	bb 00 00 00 00       	mov    $0x0,%ebx
  801729:	eb 21                	jmp    80174c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80172b:	83 ec 04             	sub    $0x4,%esp
  80172e:	89 f0                	mov    %esi,%eax
  801730:	29 d8                	sub    %ebx,%eax
  801732:	50                   	push   %eax
  801733:	89 d8                	mov    %ebx,%eax
  801735:	03 45 0c             	add    0xc(%ebp),%eax
  801738:	50                   	push   %eax
  801739:	57                   	push   %edi
  80173a:	e8 45 ff ff ff       	call   801684 <read>
		if (m < 0)
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	78 10                	js     801756 <readn+0x41>
			return m;
		if (m == 0)
  801746:	85 c0                	test   %eax,%eax
  801748:	74 0a                	je     801754 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80174a:	01 c3                	add    %eax,%ebx
  80174c:	39 f3                	cmp    %esi,%ebx
  80174e:	72 db                	jb     80172b <readn+0x16>
  801750:	89 d8                	mov    %ebx,%eax
  801752:	eb 02                	jmp    801756 <readn+0x41>
  801754:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801756:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801759:	5b                   	pop    %ebx
  80175a:	5e                   	pop    %esi
  80175b:	5f                   	pop    %edi
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    

0080175e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	53                   	push   %ebx
  801762:	83 ec 14             	sub    $0x14,%esp
  801765:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801768:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176b:	50                   	push   %eax
  80176c:	53                   	push   %ebx
  80176d:	e8 ac fc ff ff       	call   80141e <fd_lookup>
  801772:	83 c4 08             	add    $0x8,%esp
  801775:	89 c2                	mov    %eax,%edx
  801777:	85 c0                	test   %eax,%eax
  801779:	78 68                	js     8017e3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177b:	83 ec 08             	sub    $0x8,%esp
  80177e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801781:	50                   	push   %eax
  801782:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801785:	ff 30                	pushl  (%eax)
  801787:	e8 e8 fc ff ff       	call   801474 <dev_lookup>
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	85 c0                	test   %eax,%eax
  801791:	78 47                	js     8017da <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801793:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801796:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80179a:	75 21                	jne    8017bd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80179c:	a1 90 77 80 00       	mov    0x807790,%eax
  8017a1:	8b 40 7c             	mov    0x7c(%eax),%eax
  8017a4:	83 ec 04             	sub    $0x4,%esp
  8017a7:	53                   	push   %ebx
  8017a8:	50                   	push   %eax
  8017a9:	68 65 2f 80 00       	push   $0x802f65
  8017ae:	e8 48 ed ff ff       	call   8004fb <cprintf>
		return -E_INVAL;
  8017b3:	83 c4 10             	add    $0x10,%esp
  8017b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017bb:	eb 26                	jmp    8017e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c0:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c3:	85 d2                	test   %edx,%edx
  8017c5:	74 17                	je     8017de <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017c7:	83 ec 04             	sub    $0x4,%esp
  8017ca:	ff 75 10             	pushl  0x10(%ebp)
  8017cd:	ff 75 0c             	pushl  0xc(%ebp)
  8017d0:	50                   	push   %eax
  8017d1:	ff d2                	call   *%edx
  8017d3:	89 c2                	mov    %eax,%edx
  8017d5:	83 c4 10             	add    $0x10,%esp
  8017d8:	eb 09                	jmp    8017e3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017da:	89 c2                	mov    %eax,%edx
  8017dc:	eb 05                	jmp    8017e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017e3:	89 d0                	mov    %edx,%eax
  8017e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e8:	c9                   	leave  
  8017e9:	c3                   	ret    

008017ea <seek>:

int
seek(int fdnum, off_t offset)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017f0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017f3:	50                   	push   %eax
  8017f4:	ff 75 08             	pushl  0x8(%ebp)
  8017f7:	e8 22 fc ff ff       	call   80141e <fd_lookup>
  8017fc:	83 c4 08             	add    $0x8,%esp
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 0e                	js     801811 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801803:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801806:	8b 55 0c             	mov    0xc(%ebp),%edx
  801809:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80180c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801811:	c9                   	leave  
  801812:	c3                   	ret    

00801813 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	53                   	push   %ebx
  801817:	83 ec 14             	sub    $0x14,%esp
  80181a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801820:	50                   	push   %eax
  801821:	53                   	push   %ebx
  801822:	e8 f7 fb ff ff       	call   80141e <fd_lookup>
  801827:	83 c4 08             	add    $0x8,%esp
  80182a:	89 c2                	mov    %eax,%edx
  80182c:	85 c0                	test   %eax,%eax
  80182e:	78 65                	js     801895 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801830:	83 ec 08             	sub    $0x8,%esp
  801833:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801836:	50                   	push   %eax
  801837:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183a:	ff 30                	pushl  (%eax)
  80183c:	e8 33 fc ff ff       	call   801474 <dev_lookup>
  801841:	83 c4 10             	add    $0x10,%esp
  801844:	85 c0                	test   %eax,%eax
  801846:	78 44                	js     80188c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801848:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80184f:	75 21                	jne    801872 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801851:	a1 90 77 80 00       	mov    0x807790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801856:	8b 40 7c             	mov    0x7c(%eax),%eax
  801859:	83 ec 04             	sub    $0x4,%esp
  80185c:	53                   	push   %ebx
  80185d:	50                   	push   %eax
  80185e:	68 28 2f 80 00       	push   $0x802f28
  801863:	e8 93 ec ff ff       	call   8004fb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801870:	eb 23                	jmp    801895 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801872:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801875:	8b 52 18             	mov    0x18(%edx),%edx
  801878:	85 d2                	test   %edx,%edx
  80187a:	74 14                	je     801890 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80187c:	83 ec 08             	sub    $0x8,%esp
  80187f:	ff 75 0c             	pushl  0xc(%ebp)
  801882:	50                   	push   %eax
  801883:	ff d2                	call   *%edx
  801885:	89 c2                	mov    %eax,%edx
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	eb 09                	jmp    801895 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80188c:	89 c2                	mov    %eax,%edx
  80188e:	eb 05                	jmp    801895 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801890:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801895:	89 d0                	mov    %edx,%eax
  801897:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	53                   	push   %ebx
  8018a0:	83 ec 14             	sub    $0x14,%esp
  8018a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a9:	50                   	push   %eax
  8018aa:	ff 75 08             	pushl  0x8(%ebp)
  8018ad:	e8 6c fb ff ff       	call   80141e <fd_lookup>
  8018b2:	83 c4 08             	add    $0x8,%esp
  8018b5:	89 c2                	mov    %eax,%edx
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	78 58                	js     801913 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018bb:	83 ec 08             	sub    $0x8,%esp
  8018be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c1:	50                   	push   %eax
  8018c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c5:	ff 30                	pushl  (%eax)
  8018c7:	e8 a8 fb ff ff       	call   801474 <dev_lookup>
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	78 37                	js     80190a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018da:	74 32                	je     80190e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018dc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018df:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018e6:	00 00 00 
	stat->st_isdir = 0;
  8018e9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018f0:	00 00 00 
	stat->st_dev = dev;
  8018f3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018f9:	83 ec 08             	sub    $0x8,%esp
  8018fc:	53                   	push   %ebx
  8018fd:	ff 75 f0             	pushl  -0x10(%ebp)
  801900:	ff 50 14             	call   *0x14(%eax)
  801903:	89 c2                	mov    %eax,%edx
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	eb 09                	jmp    801913 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80190a:	89 c2                	mov    %eax,%edx
  80190c:	eb 05                	jmp    801913 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80190e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801913:	89 d0                	mov    %edx,%eax
  801915:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801918:	c9                   	leave  
  801919:	c3                   	ret    

0080191a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	56                   	push   %esi
  80191e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80191f:	83 ec 08             	sub    $0x8,%esp
  801922:	6a 00                	push   $0x0
  801924:	ff 75 08             	pushl  0x8(%ebp)
  801927:	e8 e3 01 00 00       	call   801b0f <open>
  80192c:	89 c3                	mov    %eax,%ebx
  80192e:	83 c4 10             	add    $0x10,%esp
  801931:	85 c0                	test   %eax,%eax
  801933:	78 1b                	js     801950 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801935:	83 ec 08             	sub    $0x8,%esp
  801938:	ff 75 0c             	pushl  0xc(%ebp)
  80193b:	50                   	push   %eax
  80193c:	e8 5b ff ff ff       	call   80189c <fstat>
  801941:	89 c6                	mov    %eax,%esi
	close(fd);
  801943:	89 1c 24             	mov    %ebx,(%esp)
  801946:	e8 fd fb ff ff       	call   801548 <close>
	return r;
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	89 f0                	mov    %esi,%eax
}
  801950:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801953:	5b                   	pop    %ebx
  801954:	5e                   	pop    %esi
  801955:	5d                   	pop    %ebp
  801956:	c3                   	ret    

00801957 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	56                   	push   %esi
  80195b:	53                   	push   %ebx
  80195c:	89 c6                	mov    %eax,%esi
  80195e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801960:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801967:	75 12                	jne    80197b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801969:	83 ec 0c             	sub    $0xc,%esp
  80196c:	6a 01                	push   $0x1
  80196e:	e8 4b 0d 00 00       	call   8026be <ipc_find_env>
  801973:	a3 00 60 80 00       	mov    %eax,0x806000
  801978:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80197b:	6a 07                	push   $0x7
  80197d:	68 00 80 80 00       	push   $0x808000
  801982:	56                   	push   %esi
  801983:	ff 35 00 60 80 00    	pushl  0x806000
  801989:	e8 ce 0c 00 00       	call   80265c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80198e:	83 c4 0c             	add    $0xc,%esp
  801991:	6a 00                	push   $0x0
  801993:	53                   	push   %ebx
  801994:	6a 00                	push   $0x0
  801996:	e8 46 0c 00 00       	call   8025e1 <ipc_recv>
}
  80199b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199e:	5b                   	pop    %ebx
  80199f:	5e                   	pop    %esi
  8019a0:	5d                   	pop    %ebp
  8019a1:	c3                   	ret    

008019a2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ae:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  8019b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b6:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8019c5:	e8 8d ff ff ff       	call   801957 <fsipc>
}
  8019ca:	c9                   	leave  
  8019cb:	c3                   	ret    

008019cc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d8:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  8019dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8019e7:	e8 6b ff ff ff       	call   801957 <fsipc>
}
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	53                   	push   %ebx
  8019f2:	83 ec 04             	sub    $0x4,%esp
  8019f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fe:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a03:	ba 00 00 00 00       	mov    $0x0,%edx
  801a08:	b8 05 00 00 00       	mov    $0x5,%eax
  801a0d:	e8 45 ff ff ff       	call   801957 <fsipc>
  801a12:	85 c0                	test   %eax,%eax
  801a14:	78 2c                	js     801a42 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a16:	83 ec 08             	sub    $0x8,%esp
  801a19:	68 00 80 80 00       	push   $0x808000
  801a1e:	53                   	push   %ebx
  801a1f:	e8 5c f0 ff ff       	call   800a80 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a24:	a1 80 80 80 00       	mov    0x808080,%eax
  801a29:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a2f:	a1 84 80 80 00       	mov    0x808084,%eax
  801a34:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a3a:	83 c4 10             	add    $0x10,%esp
  801a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a45:	c9                   	leave  
  801a46:	c3                   	ret    

00801a47 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a50:	8b 55 08             	mov    0x8(%ebp),%edx
  801a53:	8b 52 0c             	mov    0xc(%edx),%edx
  801a56:	89 15 00 80 80 00    	mov    %edx,0x808000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a5c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a61:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a66:	0f 47 c2             	cmova  %edx,%eax
  801a69:	a3 04 80 80 00       	mov    %eax,0x808004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a6e:	50                   	push   %eax
  801a6f:	ff 75 0c             	pushl  0xc(%ebp)
  801a72:	68 08 80 80 00       	push   $0x808008
  801a77:	e8 96 f1 ff ff       	call   800c12 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a7c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a81:	b8 04 00 00 00       	mov    $0x4,%eax
  801a86:	e8 cc fe ff ff       	call   801957 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	56                   	push   %esi
  801a91:	53                   	push   %ebx
  801a92:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a95:	8b 45 08             	mov    0x8(%ebp),%eax
  801a98:	8b 40 0c             	mov    0xc(%eax),%eax
  801a9b:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  801aa0:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aa6:	ba 00 00 00 00       	mov    $0x0,%edx
  801aab:	b8 03 00 00 00       	mov    $0x3,%eax
  801ab0:	e8 a2 fe ff ff       	call   801957 <fsipc>
  801ab5:	89 c3                	mov    %eax,%ebx
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	78 4b                	js     801b06 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801abb:	39 c6                	cmp    %eax,%esi
  801abd:	73 16                	jae    801ad5 <devfile_read+0x48>
  801abf:	68 94 2f 80 00       	push   $0x802f94
  801ac4:	68 9b 2f 80 00       	push   $0x802f9b
  801ac9:	6a 7c                	push   $0x7c
  801acb:	68 b0 2f 80 00       	push   $0x802fb0
  801ad0:	e8 4d e9 ff ff       	call   800422 <_panic>
	assert(r <= PGSIZE);
  801ad5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ada:	7e 16                	jle    801af2 <devfile_read+0x65>
  801adc:	68 bb 2f 80 00       	push   $0x802fbb
  801ae1:	68 9b 2f 80 00       	push   $0x802f9b
  801ae6:	6a 7d                	push   $0x7d
  801ae8:	68 b0 2f 80 00       	push   $0x802fb0
  801aed:	e8 30 e9 ff ff       	call   800422 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801af2:	83 ec 04             	sub    $0x4,%esp
  801af5:	50                   	push   %eax
  801af6:	68 00 80 80 00       	push   $0x808000
  801afb:	ff 75 0c             	pushl  0xc(%ebp)
  801afe:	e8 0f f1 ff ff       	call   800c12 <memmove>
	return r;
  801b03:	83 c4 10             	add    $0x10,%esp
}
  801b06:	89 d8                	mov    %ebx,%eax
  801b08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b0b:	5b                   	pop    %ebx
  801b0c:	5e                   	pop    %esi
  801b0d:	5d                   	pop    %ebp
  801b0e:	c3                   	ret    

00801b0f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	53                   	push   %ebx
  801b13:	83 ec 20             	sub    $0x20,%esp
  801b16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b19:	53                   	push   %ebx
  801b1a:	e8 28 ef ff ff       	call   800a47 <strlen>
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b27:	7f 67                	jg     801b90 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b29:	83 ec 0c             	sub    $0xc,%esp
  801b2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2f:	50                   	push   %eax
  801b30:	e8 9a f8 ff ff       	call   8013cf <fd_alloc>
  801b35:	83 c4 10             	add    $0x10,%esp
		return r;
  801b38:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	78 57                	js     801b95 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b3e:	83 ec 08             	sub    $0x8,%esp
  801b41:	53                   	push   %ebx
  801b42:	68 00 80 80 00       	push   $0x808000
  801b47:	e8 34 ef ff ff       	call   800a80 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4f:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b54:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b57:	b8 01 00 00 00       	mov    $0x1,%eax
  801b5c:	e8 f6 fd ff ff       	call   801957 <fsipc>
  801b61:	89 c3                	mov    %eax,%ebx
  801b63:	83 c4 10             	add    $0x10,%esp
  801b66:	85 c0                	test   %eax,%eax
  801b68:	79 14                	jns    801b7e <open+0x6f>
		fd_close(fd, 0);
  801b6a:	83 ec 08             	sub    $0x8,%esp
  801b6d:	6a 00                	push   $0x0
  801b6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b72:	e8 50 f9 ff ff       	call   8014c7 <fd_close>
		return r;
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	89 da                	mov    %ebx,%edx
  801b7c:	eb 17                	jmp    801b95 <open+0x86>
	}

	return fd2num(fd);
  801b7e:	83 ec 0c             	sub    $0xc,%esp
  801b81:	ff 75 f4             	pushl  -0xc(%ebp)
  801b84:	e8 1f f8 ff ff       	call   8013a8 <fd2num>
  801b89:	89 c2                	mov    %eax,%edx
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	eb 05                	jmp    801b95 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b90:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b95:	89 d0                	mov    %edx,%eax
  801b97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9a:	c9                   	leave  
  801b9b:	c3                   	ret    

00801b9c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba7:	b8 08 00 00 00       	mov    $0x8,%eax
  801bac:	e8 a6 fd ff ff       	call   801957 <fsipc>
}
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    

00801bb3 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	57                   	push   %edi
  801bb7:	56                   	push   %esi
  801bb8:	53                   	push   %ebx
  801bb9:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801bbf:	6a 00                	push   $0x0
  801bc1:	ff 75 08             	pushl  0x8(%ebp)
  801bc4:	e8 46 ff ff ff       	call   801b0f <open>
  801bc9:	89 c7                	mov    %eax,%edi
  801bcb:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	0f 88 8c 04 00 00    	js     802068 <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801bdc:	83 ec 04             	sub    $0x4,%esp
  801bdf:	68 00 02 00 00       	push   $0x200
  801be4:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801bea:	50                   	push   %eax
  801beb:	57                   	push   %edi
  801bec:	e8 24 fb ff ff       	call   801715 <readn>
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	3d 00 02 00 00       	cmp    $0x200,%eax
  801bf9:	75 0c                	jne    801c07 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801bfb:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c02:	45 4c 46 
  801c05:	74 33                	je     801c3a <spawn+0x87>
		close(fd);
  801c07:	83 ec 0c             	sub    $0xc,%esp
  801c0a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c10:	e8 33 f9 ff ff       	call   801548 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c15:	83 c4 0c             	add    $0xc,%esp
  801c18:	68 7f 45 4c 46       	push   $0x464c457f
  801c1d:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801c23:	68 c7 2f 80 00       	push   $0x802fc7
  801c28:	e8 ce e8 ff ff       	call   8004fb <cprintf>
		return -E_NOT_EXEC;
  801c2d:	83 c4 10             	add    $0x10,%esp
  801c30:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801c35:	e9 e1 04 00 00       	jmp    80211b <spawn+0x568>
  801c3a:	b8 07 00 00 00       	mov    $0x7,%eax
  801c3f:	cd 30                	int    $0x30
  801c41:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801c47:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	0f 88 1e 04 00 00    	js     802073 <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801c55:	89 c6                	mov    %eax,%esi
  801c57:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801c5d:	69 f6 b0 00 00 00    	imul   $0xb0,%esi,%esi
  801c63:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801c69:	81 c6 34 00 c0 ee    	add    $0xeec00034,%esi
  801c6f:	b9 11 00 00 00       	mov    $0x11,%ecx
  801c74:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801c76:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801c7c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c82:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801c87:	be 00 00 00 00       	mov    $0x0,%esi
  801c8c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c8f:	eb 13                	jmp    801ca4 <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801c91:	83 ec 0c             	sub    $0xc,%esp
  801c94:	50                   	push   %eax
  801c95:	e8 ad ed ff ff       	call   800a47 <strlen>
  801c9a:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c9e:	83 c3 01             	add    $0x1,%ebx
  801ca1:	83 c4 10             	add    $0x10,%esp
  801ca4:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801cab:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	75 df                	jne    801c91 <spawn+0xde>
  801cb2:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801cb8:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801cbe:	bf 00 10 40 00       	mov    $0x401000,%edi
  801cc3:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801cc5:	89 fa                	mov    %edi,%edx
  801cc7:	83 e2 fc             	and    $0xfffffffc,%edx
  801cca:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801cd1:	29 c2                	sub    %eax,%edx
  801cd3:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801cd9:	8d 42 f8             	lea    -0x8(%edx),%eax
  801cdc:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801ce1:	0f 86 a2 03 00 00    	jbe    802089 <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ce7:	83 ec 04             	sub    $0x4,%esp
  801cea:	6a 07                	push   $0x7
  801cec:	68 00 00 40 00       	push   $0x400000
  801cf1:	6a 00                	push   $0x0
  801cf3:	e8 8b f1 ff ff       	call   800e83 <sys_page_alloc>
  801cf8:	83 c4 10             	add    $0x10,%esp
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	0f 88 90 03 00 00    	js     802093 <spawn+0x4e0>
  801d03:	be 00 00 00 00       	mov    $0x0,%esi
  801d08:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d11:	eb 30                	jmp    801d43 <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801d13:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801d19:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801d1f:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801d22:	83 ec 08             	sub    $0x8,%esp
  801d25:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d28:	57                   	push   %edi
  801d29:	e8 52 ed ff ff       	call   800a80 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801d2e:	83 c4 04             	add    $0x4,%esp
  801d31:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d34:	e8 0e ed ff ff       	call   800a47 <strlen>
  801d39:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d3d:	83 c6 01             	add    $0x1,%esi
  801d40:	83 c4 10             	add    $0x10,%esp
  801d43:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801d49:	7f c8                	jg     801d13 <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801d4b:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d51:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801d57:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801d5e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801d64:	74 19                	je     801d7f <spawn+0x1cc>
  801d66:	68 54 30 80 00       	push   $0x803054
  801d6b:	68 9b 2f 80 00       	push   $0x802f9b
  801d70:	68 f2 00 00 00       	push   $0xf2
  801d75:	68 e1 2f 80 00       	push   $0x802fe1
  801d7a:	e8 a3 e6 ff ff       	call   800422 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801d7f:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801d85:	89 f8                	mov    %edi,%eax
  801d87:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801d8c:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801d8f:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d95:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801d98:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801d9e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801da4:	83 ec 0c             	sub    $0xc,%esp
  801da7:	6a 07                	push   $0x7
  801da9:	68 00 d0 bf ee       	push   $0xeebfd000
  801dae:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801db4:	68 00 00 40 00       	push   $0x400000
  801db9:	6a 00                	push   $0x0
  801dbb:	e8 06 f1 ff ff       	call   800ec6 <sys_page_map>
  801dc0:	89 c3                	mov    %eax,%ebx
  801dc2:	83 c4 20             	add    $0x20,%esp
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	0f 88 3c 03 00 00    	js     802109 <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801dcd:	83 ec 08             	sub    $0x8,%esp
  801dd0:	68 00 00 40 00       	push   $0x400000
  801dd5:	6a 00                	push   $0x0
  801dd7:	e8 2c f1 ff ff       	call   800f08 <sys_page_unmap>
  801ddc:	89 c3                	mov    %eax,%ebx
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	85 c0                	test   %eax,%eax
  801de3:	0f 88 20 03 00 00    	js     802109 <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801de9:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801def:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801df6:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801dfc:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801e03:	00 00 00 
  801e06:	e9 88 01 00 00       	jmp    801f93 <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  801e0b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801e11:	83 38 01             	cmpl   $0x1,(%eax)
  801e14:	0f 85 6b 01 00 00    	jne    801f85 <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e1a:	89 c2                	mov    %eax,%edx
  801e1c:	8b 40 18             	mov    0x18(%eax),%eax
  801e1f:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e25:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801e28:	83 f8 01             	cmp    $0x1,%eax
  801e2b:	19 c0                	sbb    %eax,%eax
  801e2d:	83 e0 fe             	and    $0xfffffffe,%eax
  801e30:	83 c0 07             	add    $0x7,%eax
  801e33:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e39:	89 d0                	mov    %edx,%eax
  801e3b:	8b 7a 04             	mov    0x4(%edx),%edi
  801e3e:	89 f9                	mov    %edi,%ecx
  801e40:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801e46:	8b 7a 10             	mov    0x10(%edx),%edi
  801e49:	8b 52 14             	mov    0x14(%edx),%edx
  801e4c:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801e52:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801e55:	89 f0                	mov    %esi,%eax
  801e57:	25 ff 0f 00 00       	and    $0xfff,%eax
  801e5c:	74 14                	je     801e72 <spawn+0x2bf>
		va -= i;
  801e5e:	29 c6                	sub    %eax,%esi
		memsz += i;
  801e60:	01 c2                	add    %eax,%edx
  801e62:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801e68:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801e6a:	29 c1                	sub    %eax,%ecx
  801e6c:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e72:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e77:	e9 f7 00 00 00       	jmp    801f73 <spawn+0x3c0>
		if (i >= filesz) {
  801e7c:	39 fb                	cmp    %edi,%ebx
  801e7e:	72 27                	jb     801ea7 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801e80:	83 ec 04             	sub    $0x4,%esp
  801e83:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801e89:	56                   	push   %esi
  801e8a:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801e90:	e8 ee ef ff ff       	call   800e83 <sys_page_alloc>
  801e95:	83 c4 10             	add    $0x10,%esp
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	0f 89 c7 00 00 00    	jns    801f67 <spawn+0x3b4>
  801ea0:	89 c3                	mov    %eax,%ebx
  801ea2:	e9 fd 01 00 00       	jmp    8020a4 <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ea7:	83 ec 04             	sub    $0x4,%esp
  801eaa:	6a 07                	push   $0x7
  801eac:	68 00 00 40 00       	push   $0x400000
  801eb1:	6a 00                	push   $0x0
  801eb3:	e8 cb ef ff ff       	call   800e83 <sys_page_alloc>
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	0f 88 d7 01 00 00    	js     80209a <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ec3:	83 ec 08             	sub    $0x8,%esp
  801ec6:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ecc:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801ed2:	50                   	push   %eax
  801ed3:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ed9:	e8 0c f9 ff ff       	call   8017ea <seek>
  801ede:	83 c4 10             	add    $0x10,%esp
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	0f 88 b5 01 00 00    	js     80209e <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ee9:	83 ec 04             	sub    $0x4,%esp
  801eec:	89 f8                	mov    %edi,%eax
  801eee:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801ef4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ef9:	ba 00 10 00 00       	mov    $0x1000,%edx
  801efe:	0f 47 c2             	cmova  %edx,%eax
  801f01:	50                   	push   %eax
  801f02:	68 00 00 40 00       	push   $0x400000
  801f07:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f0d:	e8 03 f8 ff ff       	call   801715 <readn>
  801f12:	83 c4 10             	add    $0x10,%esp
  801f15:	85 c0                	test   %eax,%eax
  801f17:	0f 88 85 01 00 00    	js     8020a2 <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f1d:	83 ec 0c             	sub    $0xc,%esp
  801f20:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f26:	56                   	push   %esi
  801f27:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f2d:	68 00 00 40 00       	push   $0x400000
  801f32:	6a 00                	push   $0x0
  801f34:	e8 8d ef ff ff       	call   800ec6 <sys_page_map>
  801f39:	83 c4 20             	add    $0x20,%esp
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	79 15                	jns    801f55 <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  801f40:	50                   	push   %eax
  801f41:	68 ed 2f 80 00       	push   $0x802fed
  801f46:	68 25 01 00 00       	push   $0x125
  801f4b:	68 e1 2f 80 00       	push   $0x802fe1
  801f50:	e8 cd e4 ff ff       	call   800422 <_panic>
			sys_page_unmap(0, UTEMP);
  801f55:	83 ec 08             	sub    $0x8,%esp
  801f58:	68 00 00 40 00       	push   $0x400000
  801f5d:	6a 00                	push   $0x0
  801f5f:	e8 a4 ef ff ff       	call   800f08 <sys_page_unmap>
  801f64:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f67:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801f6d:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801f73:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801f79:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801f7f:	0f 82 f7 fe ff ff    	jb     801e7c <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f85:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801f8c:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801f93:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801f9a:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801fa0:	0f 8c 65 fe ff ff    	jl     801e0b <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801fa6:	83 ec 0c             	sub    $0xc,%esp
  801fa9:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801faf:	e8 94 f5 ff ff       	call   801548 <close>
  801fb4:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801fb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fbc:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801fc2:	89 d8                	mov    %ebx,%eax
  801fc4:	c1 e8 16             	shr    $0x16,%eax
  801fc7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fce:	a8 01                	test   $0x1,%al
  801fd0:	74 42                	je     802014 <spawn+0x461>
  801fd2:	89 d8                	mov    %ebx,%eax
  801fd4:	c1 e8 0c             	shr    $0xc,%eax
  801fd7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801fde:	f6 c2 01             	test   $0x1,%dl
  801fe1:	74 31                	je     802014 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801fe3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801fea:	f6 c6 04             	test   $0x4,%dh
  801fed:	74 25                	je     802014 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801fef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ff6:	83 ec 0c             	sub    $0xc,%esp
  801ff9:	25 07 0e 00 00       	and    $0xe07,%eax
  801ffe:	50                   	push   %eax
  801fff:	53                   	push   %ebx
  802000:	56                   	push   %esi
  802001:	53                   	push   %ebx
  802002:	6a 00                	push   $0x0
  802004:	e8 bd ee ff ff       	call   800ec6 <sys_page_map>
			if (r < 0) {
  802009:	83 c4 20             	add    $0x20,%esp
  80200c:	85 c0                	test   %eax,%eax
  80200e:	0f 88 b1 00 00 00    	js     8020c5 <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802014:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80201a:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802020:	75 a0                	jne    801fc2 <spawn+0x40f>
  802022:	e9 b3 00 00 00       	jmp    8020da <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802027:	50                   	push   %eax
  802028:	68 0a 30 80 00       	push   $0x80300a
  80202d:	68 86 00 00 00       	push   $0x86
  802032:	68 e1 2f 80 00       	push   $0x802fe1
  802037:	e8 e6 e3 ff ff       	call   800422 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80203c:	83 ec 08             	sub    $0x8,%esp
  80203f:	6a 02                	push   $0x2
  802041:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802047:	e8 fe ee ff ff       	call   800f4a <sys_env_set_status>
  80204c:	83 c4 10             	add    $0x10,%esp
  80204f:	85 c0                	test   %eax,%eax
  802051:	79 2b                	jns    80207e <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  802053:	50                   	push   %eax
  802054:	68 24 30 80 00       	push   $0x803024
  802059:	68 89 00 00 00       	push   $0x89
  80205e:	68 e1 2f 80 00       	push   $0x802fe1
  802063:	e8 ba e3 ff ff       	call   800422 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802068:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  80206e:	e9 a8 00 00 00       	jmp    80211b <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802073:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802079:	e9 9d 00 00 00       	jmp    80211b <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80207e:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802084:	e9 92 00 00 00       	jmp    80211b <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802089:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  80208e:	e9 88 00 00 00       	jmp    80211b <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802093:	89 c3                	mov    %eax,%ebx
  802095:	e9 81 00 00 00       	jmp    80211b <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80209a:	89 c3                	mov    %eax,%ebx
  80209c:	eb 06                	jmp    8020a4 <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80209e:	89 c3                	mov    %eax,%ebx
  8020a0:	eb 02                	jmp    8020a4 <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8020a2:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8020a4:	83 ec 0c             	sub    $0xc,%esp
  8020a7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020ad:	e8 52 ed ff ff       	call   800e04 <sys_env_destroy>
	close(fd);
  8020b2:	83 c4 04             	add    $0x4,%esp
  8020b5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8020bb:	e8 88 f4 ff ff       	call   801548 <close>
	return r;
  8020c0:	83 c4 10             	add    $0x10,%esp
  8020c3:	eb 56                	jmp    80211b <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  8020c5:	50                   	push   %eax
  8020c6:	68 3b 30 80 00       	push   $0x80303b
  8020cb:	68 82 00 00 00       	push   $0x82
  8020d0:	68 e1 2f 80 00       	push   $0x802fe1
  8020d5:	e8 48 e3 ff ff       	call   800422 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8020da:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8020e1:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8020e4:	83 ec 08             	sub    $0x8,%esp
  8020e7:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8020ed:	50                   	push   %eax
  8020ee:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020f4:	e8 93 ee ff ff       	call   800f8c <sys_env_set_trapframe>
  8020f9:	83 c4 10             	add    $0x10,%esp
  8020fc:	85 c0                	test   %eax,%eax
  8020fe:	0f 89 38 ff ff ff    	jns    80203c <spawn+0x489>
  802104:	e9 1e ff ff ff       	jmp    802027 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802109:	83 ec 08             	sub    $0x8,%esp
  80210c:	68 00 00 40 00       	push   $0x400000
  802111:	6a 00                	push   $0x0
  802113:	e8 f0 ed ff ff       	call   800f08 <sys_page_unmap>
  802118:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80211b:	89 d8                	mov    %ebx,%eax
  80211d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802120:	5b                   	pop    %ebx
  802121:	5e                   	pop    %esi
  802122:	5f                   	pop    %edi
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    

00802125 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802125:	55                   	push   %ebp
  802126:	89 e5                	mov    %esp,%ebp
  802128:	56                   	push   %esi
  802129:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80212a:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80212d:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802132:	eb 03                	jmp    802137 <spawnl+0x12>
		argc++;
  802134:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802137:	83 c2 04             	add    $0x4,%edx
  80213a:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  80213e:	75 f4                	jne    802134 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802140:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802147:	83 e2 f0             	and    $0xfffffff0,%edx
  80214a:	29 d4                	sub    %edx,%esp
  80214c:	8d 54 24 03          	lea    0x3(%esp),%edx
  802150:	c1 ea 02             	shr    $0x2,%edx
  802153:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  80215a:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  80215c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80215f:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802166:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  80216d:	00 
  80216e:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802170:	b8 00 00 00 00       	mov    $0x0,%eax
  802175:	eb 0a                	jmp    802181 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802177:	83 c0 01             	add    $0x1,%eax
  80217a:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  80217e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802181:	39 d0                	cmp    %edx,%eax
  802183:	75 f2                	jne    802177 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802185:	83 ec 08             	sub    $0x8,%esp
  802188:	56                   	push   %esi
  802189:	ff 75 08             	pushl  0x8(%ebp)
  80218c:	e8 22 fa ff ff       	call   801bb3 <spawn>
}
  802191:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    

00802198 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	56                   	push   %esi
  80219c:	53                   	push   %ebx
  80219d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021a0:	83 ec 0c             	sub    $0xc,%esp
  8021a3:	ff 75 08             	pushl  0x8(%ebp)
  8021a6:	e8 0d f2 ff ff       	call   8013b8 <fd2data>
  8021ab:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8021ad:	83 c4 08             	add    $0x8,%esp
  8021b0:	68 7c 30 80 00       	push   $0x80307c
  8021b5:	53                   	push   %ebx
  8021b6:	e8 c5 e8 ff ff       	call   800a80 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021bb:	8b 46 04             	mov    0x4(%esi),%eax
  8021be:	2b 06                	sub    (%esi),%eax
  8021c0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8021c6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021cd:	00 00 00 
	stat->st_dev = &devpipe;
  8021d0:	c7 83 88 00 00 00 ac 	movl   $0x8057ac,0x88(%ebx)
  8021d7:	57 80 00 
	return 0;
}
  8021da:	b8 00 00 00 00       	mov    $0x0,%eax
  8021df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021e2:	5b                   	pop    %ebx
  8021e3:	5e                   	pop    %esi
  8021e4:	5d                   	pop    %ebp
  8021e5:	c3                   	ret    

008021e6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021e6:	55                   	push   %ebp
  8021e7:	89 e5                	mov    %esp,%ebp
  8021e9:	53                   	push   %ebx
  8021ea:	83 ec 0c             	sub    $0xc,%esp
  8021ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021f0:	53                   	push   %ebx
  8021f1:	6a 00                	push   $0x0
  8021f3:	e8 10 ed ff ff       	call   800f08 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021f8:	89 1c 24             	mov    %ebx,(%esp)
  8021fb:	e8 b8 f1 ff ff       	call   8013b8 <fd2data>
  802200:	83 c4 08             	add    $0x8,%esp
  802203:	50                   	push   %eax
  802204:	6a 00                	push   $0x0
  802206:	e8 fd ec ff ff       	call   800f08 <sys_page_unmap>
}
  80220b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80220e:	c9                   	leave  
  80220f:	c3                   	ret    

00802210 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	57                   	push   %edi
  802214:	56                   	push   %esi
  802215:	53                   	push   %ebx
  802216:	83 ec 1c             	sub    $0x1c,%esp
  802219:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80221c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80221e:	a1 90 77 80 00       	mov    0x807790,%eax
  802223:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802229:	83 ec 0c             	sub    $0xc,%esp
  80222c:	ff 75 e0             	pushl  -0x20(%ebp)
  80222f:	e8 cc 04 00 00       	call   802700 <pageref>
  802234:	89 c3                	mov    %eax,%ebx
  802236:	89 3c 24             	mov    %edi,(%esp)
  802239:	e8 c2 04 00 00       	call   802700 <pageref>
  80223e:	83 c4 10             	add    $0x10,%esp
  802241:	39 c3                	cmp    %eax,%ebx
  802243:	0f 94 c1             	sete   %cl
  802246:	0f b6 c9             	movzbl %cl,%ecx
  802249:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80224c:	8b 15 90 77 80 00    	mov    0x807790,%edx
  802252:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  802258:	39 ce                	cmp    %ecx,%esi
  80225a:	74 1e                	je     80227a <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  80225c:	39 c3                	cmp    %eax,%ebx
  80225e:	75 be                	jne    80221e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802260:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  802266:	ff 75 e4             	pushl  -0x1c(%ebp)
  802269:	50                   	push   %eax
  80226a:	56                   	push   %esi
  80226b:	68 83 30 80 00       	push   $0x803083
  802270:	e8 86 e2 ff ff       	call   8004fb <cprintf>
  802275:	83 c4 10             	add    $0x10,%esp
  802278:	eb a4                	jmp    80221e <_pipeisclosed+0xe>
	}
}
  80227a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80227d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802280:	5b                   	pop    %ebx
  802281:	5e                   	pop    %esi
  802282:	5f                   	pop    %edi
  802283:	5d                   	pop    %ebp
  802284:	c3                   	ret    

00802285 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
  802288:	57                   	push   %edi
  802289:	56                   	push   %esi
  80228a:	53                   	push   %ebx
  80228b:	83 ec 28             	sub    $0x28,%esp
  80228e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802291:	56                   	push   %esi
  802292:	e8 21 f1 ff ff       	call   8013b8 <fd2data>
  802297:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802299:	83 c4 10             	add    $0x10,%esp
  80229c:	bf 00 00 00 00       	mov    $0x0,%edi
  8022a1:	eb 4b                	jmp    8022ee <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8022a3:	89 da                	mov    %ebx,%edx
  8022a5:	89 f0                	mov    %esi,%eax
  8022a7:	e8 64 ff ff ff       	call   802210 <_pipeisclosed>
  8022ac:	85 c0                	test   %eax,%eax
  8022ae:	75 48                	jne    8022f8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022b0:	e8 af eb ff ff       	call   800e64 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022b5:	8b 43 04             	mov    0x4(%ebx),%eax
  8022b8:	8b 0b                	mov    (%ebx),%ecx
  8022ba:	8d 51 20             	lea    0x20(%ecx),%edx
  8022bd:	39 d0                	cmp    %edx,%eax
  8022bf:	73 e2                	jae    8022a3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022c4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8022c8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8022cb:	89 c2                	mov    %eax,%edx
  8022cd:	c1 fa 1f             	sar    $0x1f,%edx
  8022d0:	89 d1                	mov    %edx,%ecx
  8022d2:	c1 e9 1b             	shr    $0x1b,%ecx
  8022d5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8022d8:	83 e2 1f             	and    $0x1f,%edx
  8022db:	29 ca                	sub    %ecx,%edx
  8022dd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8022e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8022e5:	83 c0 01             	add    $0x1,%eax
  8022e8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022eb:	83 c7 01             	add    $0x1,%edi
  8022ee:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022f1:	75 c2                	jne    8022b5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8022f6:	eb 05                	jmp    8022fd <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022f8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802300:	5b                   	pop    %ebx
  802301:	5e                   	pop    %esi
  802302:	5f                   	pop    %edi
  802303:	5d                   	pop    %ebp
  802304:	c3                   	ret    

00802305 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802305:	55                   	push   %ebp
  802306:	89 e5                	mov    %esp,%ebp
  802308:	57                   	push   %edi
  802309:	56                   	push   %esi
  80230a:	53                   	push   %ebx
  80230b:	83 ec 18             	sub    $0x18,%esp
  80230e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802311:	57                   	push   %edi
  802312:	e8 a1 f0 ff ff       	call   8013b8 <fd2data>
  802317:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802319:	83 c4 10             	add    $0x10,%esp
  80231c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802321:	eb 3d                	jmp    802360 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802323:	85 db                	test   %ebx,%ebx
  802325:	74 04                	je     80232b <devpipe_read+0x26>
				return i;
  802327:	89 d8                	mov    %ebx,%eax
  802329:	eb 44                	jmp    80236f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80232b:	89 f2                	mov    %esi,%edx
  80232d:	89 f8                	mov    %edi,%eax
  80232f:	e8 dc fe ff ff       	call   802210 <_pipeisclosed>
  802334:	85 c0                	test   %eax,%eax
  802336:	75 32                	jne    80236a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802338:	e8 27 eb ff ff       	call   800e64 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80233d:	8b 06                	mov    (%esi),%eax
  80233f:	3b 46 04             	cmp    0x4(%esi),%eax
  802342:	74 df                	je     802323 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802344:	99                   	cltd   
  802345:	c1 ea 1b             	shr    $0x1b,%edx
  802348:	01 d0                	add    %edx,%eax
  80234a:	83 e0 1f             	and    $0x1f,%eax
  80234d:	29 d0                	sub    %edx,%eax
  80234f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802354:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802357:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80235a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80235d:	83 c3 01             	add    $0x1,%ebx
  802360:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802363:	75 d8                	jne    80233d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802365:	8b 45 10             	mov    0x10(%ebp),%eax
  802368:	eb 05                	jmp    80236f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80236a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80236f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802372:	5b                   	pop    %ebx
  802373:	5e                   	pop    %esi
  802374:	5f                   	pop    %edi
  802375:	5d                   	pop    %ebp
  802376:	c3                   	ret    

00802377 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802377:	55                   	push   %ebp
  802378:	89 e5                	mov    %esp,%ebp
  80237a:	56                   	push   %esi
  80237b:	53                   	push   %ebx
  80237c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80237f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802382:	50                   	push   %eax
  802383:	e8 47 f0 ff ff       	call   8013cf <fd_alloc>
  802388:	83 c4 10             	add    $0x10,%esp
  80238b:	89 c2                	mov    %eax,%edx
  80238d:	85 c0                	test   %eax,%eax
  80238f:	0f 88 2c 01 00 00    	js     8024c1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802395:	83 ec 04             	sub    $0x4,%esp
  802398:	68 07 04 00 00       	push   $0x407
  80239d:	ff 75 f4             	pushl  -0xc(%ebp)
  8023a0:	6a 00                	push   $0x0
  8023a2:	e8 dc ea ff ff       	call   800e83 <sys_page_alloc>
  8023a7:	83 c4 10             	add    $0x10,%esp
  8023aa:	89 c2                	mov    %eax,%edx
  8023ac:	85 c0                	test   %eax,%eax
  8023ae:	0f 88 0d 01 00 00    	js     8024c1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8023b4:	83 ec 0c             	sub    $0xc,%esp
  8023b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8023ba:	50                   	push   %eax
  8023bb:	e8 0f f0 ff ff       	call   8013cf <fd_alloc>
  8023c0:	89 c3                	mov    %eax,%ebx
  8023c2:	83 c4 10             	add    $0x10,%esp
  8023c5:	85 c0                	test   %eax,%eax
  8023c7:	0f 88 e2 00 00 00    	js     8024af <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023cd:	83 ec 04             	sub    $0x4,%esp
  8023d0:	68 07 04 00 00       	push   $0x407
  8023d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8023d8:	6a 00                	push   $0x0
  8023da:	e8 a4 ea ff ff       	call   800e83 <sys_page_alloc>
  8023df:	89 c3                	mov    %eax,%ebx
  8023e1:	83 c4 10             	add    $0x10,%esp
  8023e4:	85 c0                	test   %eax,%eax
  8023e6:	0f 88 c3 00 00 00    	js     8024af <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023ec:	83 ec 0c             	sub    $0xc,%esp
  8023ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8023f2:	e8 c1 ef ff ff       	call   8013b8 <fd2data>
  8023f7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023f9:	83 c4 0c             	add    $0xc,%esp
  8023fc:	68 07 04 00 00       	push   $0x407
  802401:	50                   	push   %eax
  802402:	6a 00                	push   $0x0
  802404:	e8 7a ea ff ff       	call   800e83 <sys_page_alloc>
  802409:	89 c3                	mov    %eax,%ebx
  80240b:	83 c4 10             	add    $0x10,%esp
  80240e:	85 c0                	test   %eax,%eax
  802410:	0f 88 89 00 00 00    	js     80249f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802416:	83 ec 0c             	sub    $0xc,%esp
  802419:	ff 75 f0             	pushl  -0x10(%ebp)
  80241c:	e8 97 ef ff ff       	call   8013b8 <fd2data>
  802421:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802428:	50                   	push   %eax
  802429:	6a 00                	push   $0x0
  80242b:	56                   	push   %esi
  80242c:	6a 00                	push   $0x0
  80242e:	e8 93 ea ff ff       	call   800ec6 <sys_page_map>
  802433:	89 c3                	mov    %eax,%ebx
  802435:	83 c4 20             	add    $0x20,%esp
  802438:	85 c0                	test   %eax,%eax
  80243a:	78 55                	js     802491 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80243c:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  802442:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802445:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802447:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80244a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802451:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  802457:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80245a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80245c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80245f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802466:	83 ec 0c             	sub    $0xc,%esp
  802469:	ff 75 f4             	pushl  -0xc(%ebp)
  80246c:	e8 37 ef ff ff       	call   8013a8 <fd2num>
  802471:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802474:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802476:	83 c4 04             	add    $0x4,%esp
  802479:	ff 75 f0             	pushl  -0x10(%ebp)
  80247c:	e8 27 ef ff ff       	call   8013a8 <fd2num>
  802481:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802484:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802487:	83 c4 10             	add    $0x10,%esp
  80248a:	ba 00 00 00 00       	mov    $0x0,%edx
  80248f:	eb 30                	jmp    8024c1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802491:	83 ec 08             	sub    $0x8,%esp
  802494:	56                   	push   %esi
  802495:	6a 00                	push   $0x0
  802497:	e8 6c ea ff ff       	call   800f08 <sys_page_unmap>
  80249c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80249f:	83 ec 08             	sub    $0x8,%esp
  8024a2:	ff 75 f0             	pushl  -0x10(%ebp)
  8024a5:	6a 00                	push   $0x0
  8024a7:	e8 5c ea ff ff       	call   800f08 <sys_page_unmap>
  8024ac:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8024af:	83 ec 08             	sub    $0x8,%esp
  8024b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8024b5:	6a 00                	push   $0x0
  8024b7:	e8 4c ea ff ff       	call   800f08 <sys_page_unmap>
  8024bc:	83 c4 10             	add    $0x10,%esp
  8024bf:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8024c1:	89 d0                	mov    %edx,%eax
  8024c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024c6:	5b                   	pop    %ebx
  8024c7:	5e                   	pop    %esi
  8024c8:	5d                   	pop    %ebp
  8024c9:	c3                   	ret    

008024ca <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024ca:	55                   	push   %ebp
  8024cb:	89 e5                	mov    %esp,%ebp
  8024cd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024d3:	50                   	push   %eax
  8024d4:	ff 75 08             	pushl  0x8(%ebp)
  8024d7:	e8 42 ef ff ff       	call   80141e <fd_lookup>
  8024dc:	83 c4 10             	add    $0x10,%esp
  8024df:	85 c0                	test   %eax,%eax
  8024e1:	78 18                	js     8024fb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024e3:	83 ec 0c             	sub    $0xc,%esp
  8024e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8024e9:	e8 ca ee ff ff       	call   8013b8 <fd2data>
	return _pipeisclosed(fd, p);
  8024ee:	89 c2                	mov    %eax,%edx
  8024f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024f3:	e8 18 fd ff ff       	call   802210 <_pipeisclosed>
  8024f8:	83 c4 10             	add    $0x10,%esp
}
  8024fb:	c9                   	leave  
  8024fc:	c3                   	ret    

008024fd <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8024fd:	55                   	push   %ebp
  8024fe:	89 e5                	mov    %esp,%ebp
  802500:	56                   	push   %esi
  802501:	53                   	push   %ebx
  802502:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802505:	85 f6                	test   %esi,%esi
  802507:	75 16                	jne    80251f <wait+0x22>
  802509:	68 9b 30 80 00       	push   $0x80309b
  80250e:	68 9b 2f 80 00       	push   $0x802f9b
  802513:	6a 09                	push   $0x9
  802515:	68 a6 30 80 00       	push   $0x8030a6
  80251a:	e8 03 df ff ff       	call   800422 <_panic>
	e = &envs[ENVX(envid)];
  80251f:	89 f3                	mov    %esi,%ebx
  802521:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802527:	69 db b0 00 00 00    	imul   $0xb0,%ebx,%ebx
  80252d:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802533:	eb 05                	jmp    80253a <wait+0x3d>
		sys_yield();
  802535:	e8 2a e9 ff ff       	call   800e64 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80253a:	8b 43 7c             	mov    0x7c(%ebx),%eax
  80253d:	39 c6                	cmp    %eax,%esi
  80253f:	75 0a                	jne    80254b <wait+0x4e>
  802541:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
  802547:	85 c0                	test   %eax,%eax
  802549:	75 ea                	jne    802535 <wait+0x38>
		sys_yield();
}
  80254b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80254e:	5b                   	pop    %ebx
  80254f:	5e                   	pop    %esi
  802550:	5d                   	pop    %ebp
  802551:	c3                   	ret    

00802552 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802552:	55                   	push   %ebp
  802553:	89 e5                	mov    %esp,%ebp
  802555:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802558:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  80255f:	75 2a                	jne    80258b <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802561:	83 ec 04             	sub    $0x4,%esp
  802564:	6a 07                	push   $0x7
  802566:	68 00 f0 bf ee       	push   $0xeebff000
  80256b:	6a 00                	push   $0x0
  80256d:	e8 11 e9 ff ff       	call   800e83 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802572:	83 c4 10             	add    $0x10,%esp
  802575:	85 c0                	test   %eax,%eax
  802577:	79 12                	jns    80258b <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802579:	50                   	push   %eax
  80257a:	68 a3 2a 80 00       	push   $0x802aa3
  80257f:	6a 23                	push   $0x23
  802581:	68 b1 30 80 00       	push   $0x8030b1
  802586:	e8 97 de ff ff       	call   800422 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80258b:	8b 45 08             	mov    0x8(%ebp),%eax
  80258e:	a3 00 90 80 00       	mov    %eax,0x809000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802593:	83 ec 08             	sub    $0x8,%esp
  802596:	68 bd 25 80 00       	push   $0x8025bd
  80259b:	6a 00                	push   $0x0
  80259d:	e8 2c ea ff ff       	call   800fce <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8025a2:	83 c4 10             	add    $0x10,%esp
  8025a5:	85 c0                	test   %eax,%eax
  8025a7:	79 12                	jns    8025bb <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8025a9:	50                   	push   %eax
  8025aa:	68 a3 2a 80 00       	push   $0x802aa3
  8025af:	6a 2c                	push   $0x2c
  8025b1:	68 b1 30 80 00       	push   $0x8030b1
  8025b6:	e8 67 de ff ff       	call   800422 <_panic>
	}
}
  8025bb:	c9                   	leave  
  8025bc:	c3                   	ret    

008025bd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8025bd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8025be:	a1 00 90 80 00       	mov    0x809000,%eax
	call *%eax
  8025c3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8025c5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8025c8:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8025cc:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8025d1:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8025d5:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8025d7:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8025da:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8025db:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8025de:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8025df:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8025e0:	c3                   	ret    

008025e1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025e1:	55                   	push   %ebp
  8025e2:	89 e5                	mov    %esp,%ebp
  8025e4:	56                   	push   %esi
  8025e5:	53                   	push   %ebx
  8025e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8025e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8025ef:	85 c0                	test   %eax,%eax
  8025f1:	75 12                	jne    802605 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8025f3:	83 ec 0c             	sub    $0xc,%esp
  8025f6:	68 00 00 c0 ee       	push   $0xeec00000
  8025fb:	e8 33 ea ff ff       	call   801033 <sys_ipc_recv>
  802600:	83 c4 10             	add    $0x10,%esp
  802603:	eb 0c                	jmp    802611 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802605:	83 ec 0c             	sub    $0xc,%esp
  802608:	50                   	push   %eax
  802609:	e8 25 ea ff ff       	call   801033 <sys_ipc_recv>
  80260e:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802611:	85 f6                	test   %esi,%esi
  802613:	0f 95 c1             	setne  %cl
  802616:	85 db                	test   %ebx,%ebx
  802618:	0f 95 c2             	setne  %dl
  80261b:	84 d1                	test   %dl,%cl
  80261d:	74 09                	je     802628 <ipc_recv+0x47>
  80261f:	89 c2                	mov    %eax,%edx
  802621:	c1 ea 1f             	shr    $0x1f,%edx
  802624:	84 d2                	test   %dl,%dl
  802626:	75 2d                	jne    802655 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802628:	85 f6                	test   %esi,%esi
  80262a:	74 0d                	je     802639 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80262c:	a1 90 77 80 00       	mov    0x807790,%eax
  802631:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  802637:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802639:	85 db                	test   %ebx,%ebx
  80263b:	74 0d                	je     80264a <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80263d:	a1 90 77 80 00       	mov    0x807790,%eax
  802642:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  802648:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80264a:	a1 90 77 80 00       	mov    0x807790,%eax
  80264f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  802655:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802658:	5b                   	pop    %ebx
  802659:	5e                   	pop    %esi
  80265a:	5d                   	pop    %ebp
  80265b:	c3                   	ret    

0080265c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80265c:	55                   	push   %ebp
  80265d:	89 e5                	mov    %esp,%ebp
  80265f:	57                   	push   %edi
  802660:	56                   	push   %esi
  802661:	53                   	push   %ebx
  802662:	83 ec 0c             	sub    $0xc,%esp
  802665:	8b 7d 08             	mov    0x8(%ebp),%edi
  802668:	8b 75 0c             	mov    0xc(%ebp),%esi
  80266b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80266e:	85 db                	test   %ebx,%ebx
  802670:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802675:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802678:	ff 75 14             	pushl  0x14(%ebp)
  80267b:	53                   	push   %ebx
  80267c:	56                   	push   %esi
  80267d:	57                   	push   %edi
  80267e:	e8 8d e9 ff ff       	call   801010 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802683:	89 c2                	mov    %eax,%edx
  802685:	c1 ea 1f             	shr    $0x1f,%edx
  802688:	83 c4 10             	add    $0x10,%esp
  80268b:	84 d2                	test   %dl,%dl
  80268d:	74 17                	je     8026a6 <ipc_send+0x4a>
  80268f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802692:	74 12                	je     8026a6 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802694:	50                   	push   %eax
  802695:	68 bf 30 80 00       	push   $0x8030bf
  80269a:	6a 47                	push   $0x47
  80269c:	68 cd 30 80 00       	push   $0x8030cd
  8026a1:	e8 7c dd ff ff       	call   800422 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8026a6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026a9:	75 07                	jne    8026b2 <ipc_send+0x56>
			sys_yield();
  8026ab:	e8 b4 e7 ff ff       	call   800e64 <sys_yield>
  8026b0:	eb c6                	jmp    802678 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8026b2:	85 c0                	test   %eax,%eax
  8026b4:	75 c2                	jne    802678 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8026b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026b9:	5b                   	pop    %ebx
  8026ba:	5e                   	pop    %esi
  8026bb:	5f                   	pop    %edi
  8026bc:	5d                   	pop    %ebp
  8026bd:	c3                   	ret    

008026be <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026be:	55                   	push   %ebp
  8026bf:	89 e5                	mov    %esp,%ebp
  8026c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8026c4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026c9:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  8026cf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026d5:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8026db:	39 ca                	cmp    %ecx,%edx
  8026dd:	75 10                	jne    8026ef <ipc_find_env+0x31>
			return envs[i].env_id;
  8026df:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8026e5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8026ea:	8b 40 7c             	mov    0x7c(%eax),%eax
  8026ed:	eb 0f                	jmp    8026fe <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026ef:	83 c0 01             	add    $0x1,%eax
  8026f2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026f7:	75 d0                	jne    8026c9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026fe:	5d                   	pop    %ebp
  8026ff:	c3                   	ret    

00802700 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802700:	55                   	push   %ebp
  802701:	89 e5                	mov    %esp,%ebp
  802703:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802706:	89 d0                	mov    %edx,%eax
  802708:	c1 e8 16             	shr    $0x16,%eax
  80270b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802712:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802717:	f6 c1 01             	test   $0x1,%cl
  80271a:	74 1d                	je     802739 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80271c:	c1 ea 0c             	shr    $0xc,%edx
  80271f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802726:	f6 c2 01             	test   $0x1,%dl
  802729:	74 0e                	je     802739 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80272b:	c1 ea 0c             	shr    $0xc,%edx
  80272e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802735:	ef 
  802736:	0f b7 c0             	movzwl %ax,%eax
}
  802739:	5d                   	pop    %ebp
  80273a:	c3                   	ret    
  80273b:	66 90                	xchg   %ax,%ax
  80273d:	66 90                	xchg   %ax,%ax
  80273f:	90                   	nop

00802740 <__udivdi3>:
  802740:	55                   	push   %ebp
  802741:	57                   	push   %edi
  802742:	56                   	push   %esi
  802743:	53                   	push   %ebx
  802744:	83 ec 1c             	sub    $0x1c,%esp
  802747:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80274b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80274f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802753:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802757:	85 f6                	test   %esi,%esi
  802759:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80275d:	89 ca                	mov    %ecx,%edx
  80275f:	89 f8                	mov    %edi,%eax
  802761:	75 3d                	jne    8027a0 <__udivdi3+0x60>
  802763:	39 cf                	cmp    %ecx,%edi
  802765:	0f 87 c5 00 00 00    	ja     802830 <__udivdi3+0xf0>
  80276b:	85 ff                	test   %edi,%edi
  80276d:	89 fd                	mov    %edi,%ebp
  80276f:	75 0b                	jne    80277c <__udivdi3+0x3c>
  802771:	b8 01 00 00 00       	mov    $0x1,%eax
  802776:	31 d2                	xor    %edx,%edx
  802778:	f7 f7                	div    %edi
  80277a:	89 c5                	mov    %eax,%ebp
  80277c:	89 c8                	mov    %ecx,%eax
  80277e:	31 d2                	xor    %edx,%edx
  802780:	f7 f5                	div    %ebp
  802782:	89 c1                	mov    %eax,%ecx
  802784:	89 d8                	mov    %ebx,%eax
  802786:	89 cf                	mov    %ecx,%edi
  802788:	f7 f5                	div    %ebp
  80278a:	89 c3                	mov    %eax,%ebx
  80278c:	89 d8                	mov    %ebx,%eax
  80278e:	89 fa                	mov    %edi,%edx
  802790:	83 c4 1c             	add    $0x1c,%esp
  802793:	5b                   	pop    %ebx
  802794:	5e                   	pop    %esi
  802795:	5f                   	pop    %edi
  802796:	5d                   	pop    %ebp
  802797:	c3                   	ret    
  802798:	90                   	nop
  802799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027a0:	39 ce                	cmp    %ecx,%esi
  8027a2:	77 74                	ja     802818 <__udivdi3+0xd8>
  8027a4:	0f bd fe             	bsr    %esi,%edi
  8027a7:	83 f7 1f             	xor    $0x1f,%edi
  8027aa:	0f 84 98 00 00 00    	je     802848 <__udivdi3+0x108>
  8027b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8027b5:	89 f9                	mov    %edi,%ecx
  8027b7:	89 c5                	mov    %eax,%ebp
  8027b9:	29 fb                	sub    %edi,%ebx
  8027bb:	d3 e6                	shl    %cl,%esi
  8027bd:	89 d9                	mov    %ebx,%ecx
  8027bf:	d3 ed                	shr    %cl,%ebp
  8027c1:	89 f9                	mov    %edi,%ecx
  8027c3:	d3 e0                	shl    %cl,%eax
  8027c5:	09 ee                	or     %ebp,%esi
  8027c7:	89 d9                	mov    %ebx,%ecx
  8027c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027cd:	89 d5                	mov    %edx,%ebp
  8027cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027d3:	d3 ed                	shr    %cl,%ebp
  8027d5:	89 f9                	mov    %edi,%ecx
  8027d7:	d3 e2                	shl    %cl,%edx
  8027d9:	89 d9                	mov    %ebx,%ecx
  8027db:	d3 e8                	shr    %cl,%eax
  8027dd:	09 c2                	or     %eax,%edx
  8027df:	89 d0                	mov    %edx,%eax
  8027e1:	89 ea                	mov    %ebp,%edx
  8027e3:	f7 f6                	div    %esi
  8027e5:	89 d5                	mov    %edx,%ebp
  8027e7:	89 c3                	mov    %eax,%ebx
  8027e9:	f7 64 24 0c          	mull   0xc(%esp)
  8027ed:	39 d5                	cmp    %edx,%ebp
  8027ef:	72 10                	jb     802801 <__udivdi3+0xc1>
  8027f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8027f5:	89 f9                	mov    %edi,%ecx
  8027f7:	d3 e6                	shl    %cl,%esi
  8027f9:	39 c6                	cmp    %eax,%esi
  8027fb:	73 07                	jae    802804 <__udivdi3+0xc4>
  8027fd:	39 d5                	cmp    %edx,%ebp
  8027ff:	75 03                	jne    802804 <__udivdi3+0xc4>
  802801:	83 eb 01             	sub    $0x1,%ebx
  802804:	31 ff                	xor    %edi,%edi
  802806:	89 d8                	mov    %ebx,%eax
  802808:	89 fa                	mov    %edi,%edx
  80280a:	83 c4 1c             	add    $0x1c,%esp
  80280d:	5b                   	pop    %ebx
  80280e:	5e                   	pop    %esi
  80280f:	5f                   	pop    %edi
  802810:	5d                   	pop    %ebp
  802811:	c3                   	ret    
  802812:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802818:	31 ff                	xor    %edi,%edi
  80281a:	31 db                	xor    %ebx,%ebx
  80281c:	89 d8                	mov    %ebx,%eax
  80281e:	89 fa                	mov    %edi,%edx
  802820:	83 c4 1c             	add    $0x1c,%esp
  802823:	5b                   	pop    %ebx
  802824:	5e                   	pop    %esi
  802825:	5f                   	pop    %edi
  802826:	5d                   	pop    %ebp
  802827:	c3                   	ret    
  802828:	90                   	nop
  802829:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802830:	89 d8                	mov    %ebx,%eax
  802832:	f7 f7                	div    %edi
  802834:	31 ff                	xor    %edi,%edi
  802836:	89 c3                	mov    %eax,%ebx
  802838:	89 d8                	mov    %ebx,%eax
  80283a:	89 fa                	mov    %edi,%edx
  80283c:	83 c4 1c             	add    $0x1c,%esp
  80283f:	5b                   	pop    %ebx
  802840:	5e                   	pop    %esi
  802841:	5f                   	pop    %edi
  802842:	5d                   	pop    %ebp
  802843:	c3                   	ret    
  802844:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802848:	39 ce                	cmp    %ecx,%esi
  80284a:	72 0c                	jb     802858 <__udivdi3+0x118>
  80284c:	31 db                	xor    %ebx,%ebx
  80284e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802852:	0f 87 34 ff ff ff    	ja     80278c <__udivdi3+0x4c>
  802858:	bb 01 00 00 00       	mov    $0x1,%ebx
  80285d:	e9 2a ff ff ff       	jmp    80278c <__udivdi3+0x4c>
  802862:	66 90                	xchg   %ax,%ax
  802864:	66 90                	xchg   %ax,%ax
  802866:	66 90                	xchg   %ax,%ax
  802868:	66 90                	xchg   %ax,%ax
  80286a:	66 90                	xchg   %ax,%ax
  80286c:	66 90                	xchg   %ax,%ax
  80286e:	66 90                	xchg   %ax,%ax

00802870 <__umoddi3>:
  802870:	55                   	push   %ebp
  802871:	57                   	push   %edi
  802872:	56                   	push   %esi
  802873:	53                   	push   %ebx
  802874:	83 ec 1c             	sub    $0x1c,%esp
  802877:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80287b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80287f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802883:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802887:	85 d2                	test   %edx,%edx
  802889:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80288d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802891:	89 f3                	mov    %esi,%ebx
  802893:	89 3c 24             	mov    %edi,(%esp)
  802896:	89 74 24 04          	mov    %esi,0x4(%esp)
  80289a:	75 1c                	jne    8028b8 <__umoddi3+0x48>
  80289c:	39 f7                	cmp    %esi,%edi
  80289e:	76 50                	jbe    8028f0 <__umoddi3+0x80>
  8028a0:	89 c8                	mov    %ecx,%eax
  8028a2:	89 f2                	mov    %esi,%edx
  8028a4:	f7 f7                	div    %edi
  8028a6:	89 d0                	mov    %edx,%eax
  8028a8:	31 d2                	xor    %edx,%edx
  8028aa:	83 c4 1c             	add    $0x1c,%esp
  8028ad:	5b                   	pop    %ebx
  8028ae:	5e                   	pop    %esi
  8028af:	5f                   	pop    %edi
  8028b0:	5d                   	pop    %ebp
  8028b1:	c3                   	ret    
  8028b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028b8:	39 f2                	cmp    %esi,%edx
  8028ba:	89 d0                	mov    %edx,%eax
  8028bc:	77 52                	ja     802910 <__umoddi3+0xa0>
  8028be:	0f bd ea             	bsr    %edx,%ebp
  8028c1:	83 f5 1f             	xor    $0x1f,%ebp
  8028c4:	75 5a                	jne    802920 <__umoddi3+0xb0>
  8028c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8028ca:	0f 82 e0 00 00 00    	jb     8029b0 <__umoddi3+0x140>
  8028d0:	39 0c 24             	cmp    %ecx,(%esp)
  8028d3:	0f 86 d7 00 00 00    	jbe    8029b0 <__umoddi3+0x140>
  8028d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8028e1:	83 c4 1c             	add    $0x1c,%esp
  8028e4:	5b                   	pop    %ebx
  8028e5:	5e                   	pop    %esi
  8028e6:	5f                   	pop    %edi
  8028e7:	5d                   	pop    %ebp
  8028e8:	c3                   	ret    
  8028e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028f0:	85 ff                	test   %edi,%edi
  8028f2:	89 fd                	mov    %edi,%ebp
  8028f4:	75 0b                	jne    802901 <__umoddi3+0x91>
  8028f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8028fb:	31 d2                	xor    %edx,%edx
  8028fd:	f7 f7                	div    %edi
  8028ff:	89 c5                	mov    %eax,%ebp
  802901:	89 f0                	mov    %esi,%eax
  802903:	31 d2                	xor    %edx,%edx
  802905:	f7 f5                	div    %ebp
  802907:	89 c8                	mov    %ecx,%eax
  802909:	f7 f5                	div    %ebp
  80290b:	89 d0                	mov    %edx,%eax
  80290d:	eb 99                	jmp    8028a8 <__umoddi3+0x38>
  80290f:	90                   	nop
  802910:	89 c8                	mov    %ecx,%eax
  802912:	89 f2                	mov    %esi,%edx
  802914:	83 c4 1c             	add    $0x1c,%esp
  802917:	5b                   	pop    %ebx
  802918:	5e                   	pop    %esi
  802919:	5f                   	pop    %edi
  80291a:	5d                   	pop    %ebp
  80291b:	c3                   	ret    
  80291c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802920:	8b 34 24             	mov    (%esp),%esi
  802923:	bf 20 00 00 00       	mov    $0x20,%edi
  802928:	89 e9                	mov    %ebp,%ecx
  80292a:	29 ef                	sub    %ebp,%edi
  80292c:	d3 e0                	shl    %cl,%eax
  80292e:	89 f9                	mov    %edi,%ecx
  802930:	89 f2                	mov    %esi,%edx
  802932:	d3 ea                	shr    %cl,%edx
  802934:	89 e9                	mov    %ebp,%ecx
  802936:	09 c2                	or     %eax,%edx
  802938:	89 d8                	mov    %ebx,%eax
  80293a:	89 14 24             	mov    %edx,(%esp)
  80293d:	89 f2                	mov    %esi,%edx
  80293f:	d3 e2                	shl    %cl,%edx
  802941:	89 f9                	mov    %edi,%ecx
  802943:	89 54 24 04          	mov    %edx,0x4(%esp)
  802947:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80294b:	d3 e8                	shr    %cl,%eax
  80294d:	89 e9                	mov    %ebp,%ecx
  80294f:	89 c6                	mov    %eax,%esi
  802951:	d3 e3                	shl    %cl,%ebx
  802953:	89 f9                	mov    %edi,%ecx
  802955:	89 d0                	mov    %edx,%eax
  802957:	d3 e8                	shr    %cl,%eax
  802959:	89 e9                	mov    %ebp,%ecx
  80295b:	09 d8                	or     %ebx,%eax
  80295d:	89 d3                	mov    %edx,%ebx
  80295f:	89 f2                	mov    %esi,%edx
  802961:	f7 34 24             	divl   (%esp)
  802964:	89 d6                	mov    %edx,%esi
  802966:	d3 e3                	shl    %cl,%ebx
  802968:	f7 64 24 04          	mull   0x4(%esp)
  80296c:	39 d6                	cmp    %edx,%esi
  80296e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802972:	89 d1                	mov    %edx,%ecx
  802974:	89 c3                	mov    %eax,%ebx
  802976:	72 08                	jb     802980 <__umoddi3+0x110>
  802978:	75 11                	jne    80298b <__umoddi3+0x11b>
  80297a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80297e:	73 0b                	jae    80298b <__umoddi3+0x11b>
  802980:	2b 44 24 04          	sub    0x4(%esp),%eax
  802984:	1b 14 24             	sbb    (%esp),%edx
  802987:	89 d1                	mov    %edx,%ecx
  802989:	89 c3                	mov    %eax,%ebx
  80298b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80298f:	29 da                	sub    %ebx,%edx
  802991:	19 ce                	sbb    %ecx,%esi
  802993:	89 f9                	mov    %edi,%ecx
  802995:	89 f0                	mov    %esi,%eax
  802997:	d3 e0                	shl    %cl,%eax
  802999:	89 e9                	mov    %ebp,%ecx
  80299b:	d3 ea                	shr    %cl,%edx
  80299d:	89 e9                	mov    %ebp,%ecx
  80299f:	d3 ee                	shr    %cl,%esi
  8029a1:	09 d0                	or     %edx,%eax
  8029a3:	89 f2                	mov    %esi,%edx
  8029a5:	83 c4 1c             	add    $0x1c,%esp
  8029a8:	5b                   	pop    %ebx
  8029a9:	5e                   	pop    %esi
  8029aa:	5f                   	pop    %edi
  8029ab:	5d                   	pop    %ebp
  8029ac:	c3                   	ret    
  8029ad:	8d 76 00             	lea    0x0(%esi),%esi
  8029b0:	29 f9                	sub    %edi,%ecx
  8029b2:	19 d6                	sbb    %edx,%esi
  8029b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029bc:	e9 18 ff ff ff       	jmp    8028d9 <__umoddi3+0x69>
