
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
  80006d:	68 60 26 80 00       	push   $0x802660
  800072:	e8 c1 04 00 00       	call   800538 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 30 80 00       	push   $0x803000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 28 27 80 00       	push   $0x802728
  8000a1:	e8 92 04 00 00       	call   800538 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 6f 26 80 00       	push   $0x80266f
  8000b3:	e8 80 04 00 00       	call   800538 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 20 50 80 00       	push   $0x805020
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 64 27 80 00       	push   $0x802764
  8000dd:	e8 56 04 00 00       	call   800538 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 86 26 80 00       	push   $0x802686
  8000ef:	e8 44 04 00 00       	call   800538 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 9c 26 80 00       	push   $0x80269c
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 d2 09 00 00       	call   800add <strcat>
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
  80011e:	68 a8 26 80 00       	push   $0x8026a8
  800123:	56                   	push   %esi
  800124:	e8 b4 09 00 00       	call   800add <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 a8 09 00 00       	call   800add <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 a9 26 80 00       	push   $0x8026a9
  80013d:	56                   	push   %esi
  80013e:	e8 9a 09 00 00       	call   800add <strcat>
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
  800158:	68 ab 26 80 00       	push   $0x8026ab
  80015d:	e8 d6 03 00 00       	call   800538 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 af 26 80 00 	movl   $0x8026af,(%esp)
  800169:	e8 ca 03 00 00       	call   800538 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 f7 10 00 00       	call   801271 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 c1 26 80 00       	push   $0x8026c1
  80018c:	6a 37                	push   $0x37
  80018e:	68 ce 26 80 00       	push   $0x8026ce
  800193:	e8 c7 02 00 00       	call   80045f <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 da 26 80 00       	push   $0x8026da
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 ce 26 80 00       	push   $0x8026ce
  8001a9:	e8 b1 02 00 00       	call   80045f <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 07 11 00 00       	call   8012c1 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 f4 26 80 00       	push   $0x8026f4
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 ce 26 80 00       	push   $0x8026ce
  8001ce:	e8 8c 02 00 00       	call   80045f <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 fc 26 80 00       	push   $0x8026fc
  8001db:	e8 58 03 00 00       	call   800538 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 10 27 80 00       	push   $0x802710
  8001ea:	68 0f 27 80 00       	push   $0x80270f
  8001ef:	e8 57 1c 00 00       	call   801e4b <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 13 27 80 00       	push   $0x802713
  800204:	e8 2f 03 00 00       	call   800538 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 03 20 00 00       	call   80221a <wait>
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
  80022c:	68 93 27 80 00       	push   $0x802793
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 84 08 00 00       	call   800abd <strcpy>
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
  800272:	e8 d8 09 00 00       	call   800c4f <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 83 0b 00 00       	call   800e04 <sys_cputs>
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
  8002a8:	e8 f4 0b 00 00       	call   800ea1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 70 0b 00 00       	call   800e22 <sys_cgetc>
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
  8002e4:	e8 1b 0b 00 00       	call   800e04 <sys_cputs>
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
  8002fc:	e8 ac 10 00 00       	call   8013ad <read>
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
  800326:	e8 1c 0e 00 00       	call   801147 <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 47 80 00    	mov    0x804770,%edx
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
  80034f:	e8 a4 0d 00 00       	call   8010f8 <fd_alloc>
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
  80036a:	e8 51 0b 00 00       	call   800ec0 <sys_page_alloc>
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
  800378:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 3b 0d 00 00       	call   8010d1 <fd2num>
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
  8003a2:	57                   	push   %edi
  8003a3:	56                   	push   %esi
  8003a4:	53                   	push   %ebx
  8003a5:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8003a8:	c7 05 90 67 80 00 00 	movl   $0x0,0x806790
  8003af:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8003b2:	e8 cb 0a 00 00       	call   800e82 <sys_getenvid>
  8003b7:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	50                   	push   %eax
  8003bd:	68 a0 27 80 00       	push   $0x8027a0
  8003c2:	e8 71 01 00 00       	call   800538 <cprintf>
  8003c7:	8b 3d 90 67 80 00    	mov    0x806790,%edi
  8003cd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8003d2:	83 c4 10             	add    $0x10,%esp
  8003d5:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8003da:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8003df:	89 c1                	mov    %eax,%ecx
  8003e1:	c1 e1 07             	shl    $0x7,%ecx
  8003e4:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8003eb:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8003ee:	39 cb                	cmp    %ecx,%ebx
  8003f0:	0f 44 fa             	cmove  %edx,%edi
  8003f3:	b9 01 00 00 00       	mov    $0x1,%ecx
  8003f8:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8003fb:	83 c0 01             	add    $0x1,%eax
  8003fe:	81 c2 84 00 00 00    	add    $0x84,%edx
  800404:	3d 00 04 00 00       	cmp    $0x400,%eax
  800409:	75 d4                	jne    8003df <libmain+0x40>
  80040b:	89 f0                	mov    %esi,%eax
  80040d:	84 c0                	test   %al,%al
  80040f:	74 06                	je     800417 <libmain+0x78>
  800411:	89 3d 90 67 80 00    	mov    %edi,0x806790
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800417:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80041b:	7e 0a                	jle    800427 <libmain+0x88>
		binaryname = argv[0];
  80041d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800420:	8b 00                	mov    (%eax),%eax
  800422:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	ff 75 0c             	pushl  0xc(%ebp)
  80042d:	ff 75 08             	pushl  0x8(%ebp)
  800430:	e8 29 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  800435:	e8 0b 00 00 00       	call   800445 <exit>
}
  80043a:	83 c4 10             	add    $0x10,%esp
  80043d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800440:	5b                   	pop    %ebx
  800441:	5e                   	pop    %esi
  800442:	5f                   	pop    %edi
  800443:	5d                   	pop    %ebp
  800444:	c3                   	ret    

00800445 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80044b:	e8 4c 0e 00 00       	call   80129c <close_all>
	sys_env_destroy(0);
  800450:	83 ec 0c             	sub    $0xc,%esp
  800453:	6a 00                	push   $0x0
  800455:	e8 e7 09 00 00       	call   800e41 <sys_env_destroy>
}
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	c9                   	leave  
  80045e:	c3                   	ret    

0080045f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80045f:	55                   	push   %ebp
  800460:	89 e5                	mov    %esp,%ebp
  800462:	56                   	push   %esi
  800463:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800464:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800467:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  80046d:	e8 10 0a 00 00       	call   800e82 <sys_getenvid>
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	ff 75 0c             	pushl  0xc(%ebp)
  800478:	ff 75 08             	pushl  0x8(%ebp)
  80047b:	56                   	push   %esi
  80047c:	50                   	push   %eax
  80047d:	68 cc 27 80 00       	push   $0x8027cc
  800482:	e8 b1 00 00 00       	call   800538 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800487:	83 c4 18             	add    $0x18,%esp
  80048a:	53                   	push   %ebx
  80048b:	ff 75 10             	pushl  0x10(%ebp)
  80048e:	e8 54 00 00 00       	call   8004e7 <vcprintf>
	cprintf("\n");
  800493:	c7 04 24 b8 2c 80 00 	movl   $0x802cb8,(%esp)
  80049a:	e8 99 00 00 00       	call   800538 <cprintf>
  80049f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004a2:	cc                   	int3   
  8004a3:	eb fd                	jmp    8004a2 <_panic+0x43>

008004a5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004a5:	55                   	push   %ebp
  8004a6:	89 e5                	mov    %esp,%ebp
  8004a8:	53                   	push   %ebx
  8004a9:	83 ec 04             	sub    $0x4,%esp
  8004ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004af:	8b 13                	mov    (%ebx),%edx
  8004b1:	8d 42 01             	lea    0x1(%edx),%eax
  8004b4:	89 03                	mov    %eax,(%ebx)
  8004b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004b9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004bd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004c2:	75 1a                	jne    8004de <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	68 ff 00 00 00       	push   $0xff
  8004cc:	8d 43 08             	lea    0x8(%ebx),%eax
  8004cf:	50                   	push   %eax
  8004d0:	e8 2f 09 00 00       	call   800e04 <sys_cputs>
		b->idx = 0;
  8004d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004db:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004de:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004e5:	c9                   	leave  
  8004e6:	c3                   	ret    

008004e7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004f0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004f7:	00 00 00 
	b.cnt = 0;
  8004fa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800501:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800504:	ff 75 0c             	pushl  0xc(%ebp)
  800507:	ff 75 08             	pushl  0x8(%ebp)
  80050a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800510:	50                   	push   %eax
  800511:	68 a5 04 80 00       	push   $0x8004a5
  800516:	e8 54 01 00 00       	call   80066f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80051b:	83 c4 08             	add    $0x8,%esp
  80051e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800524:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80052a:	50                   	push   %eax
  80052b:	e8 d4 08 00 00       	call   800e04 <sys_cputs>

	return b.cnt;
}
  800530:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800536:	c9                   	leave  
  800537:	c3                   	ret    

00800538 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800538:	55                   	push   %ebp
  800539:	89 e5                	mov    %esp,%ebp
  80053b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80053e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800541:	50                   	push   %eax
  800542:	ff 75 08             	pushl  0x8(%ebp)
  800545:	e8 9d ff ff ff       	call   8004e7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80054a:	c9                   	leave  
  80054b:	c3                   	ret    

0080054c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	57                   	push   %edi
  800550:	56                   	push   %esi
  800551:	53                   	push   %ebx
  800552:	83 ec 1c             	sub    $0x1c,%esp
  800555:	89 c7                	mov    %eax,%edi
  800557:	89 d6                	mov    %edx,%esi
  800559:	8b 45 08             	mov    0x8(%ebp),%eax
  80055c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80055f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800562:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800565:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800568:	bb 00 00 00 00       	mov    $0x0,%ebx
  80056d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800570:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800573:	39 d3                	cmp    %edx,%ebx
  800575:	72 05                	jb     80057c <printnum+0x30>
  800577:	39 45 10             	cmp    %eax,0x10(%ebp)
  80057a:	77 45                	ja     8005c1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80057c:	83 ec 0c             	sub    $0xc,%esp
  80057f:	ff 75 18             	pushl  0x18(%ebp)
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800588:	53                   	push   %ebx
  800589:	ff 75 10             	pushl  0x10(%ebp)
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800592:	ff 75 e0             	pushl  -0x20(%ebp)
  800595:	ff 75 dc             	pushl  -0x24(%ebp)
  800598:	ff 75 d8             	pushl  -0x28(%ebp)
  80059b:	e8 20 1e 00 00       	call   8023c0 <__udivdi3>
  8005a0:	83 c4 18             	add    $0x18,%esp
  8005a3:	52                   	push   %edx
  8005a4:	50                   	push   %eax
  8005a5:	89 f2                	mov    %esi,%edx
  8005a7:	89 f8                	mov    %edi,%eax
  8005a9:	e8 9e ff ff ff       	call   80054c <printnum>
  8005ae:	83 c4 20             	add    $0x20,%esp
  8005b1:	eb 18                	jmp    8005cb <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	56                   	push   %esi
  8005b7:	ff 75 18             	pushl  0x18(%ebp)
  8005ba:	ff d7                	call   *%edi
  8005bc:	83 c4 10             	add    $0x10,%esp
  8005bf:	eb 03                	jmp    8005c4 <printnum+0x78>
  8005c1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005c4:	83 eb 01             	sub    $0x1,%ebx
  8005c7:	85 db                	test   %ebx,%ebx
  8005c9:	7f e8                	jg     8005b3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	56                   	push   %esi
  8005cf:	83 ec 04             	sub    $0x4,%esp
  8005d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8005db:	ff 75 d8             	pushl  -0x28(%ebp)
  8005de:	e8 0d 1f 00 00       	call   8024f0 <__umoddi3>
  8005e3:	83 c4 14             	add    $0x14,%esp
  8005e6:	0f be 80 ef 27 80 00 	movsbl 0x8027ef(%eax),%eax
  8005ed:	50                   	push   %eax
  8005ee:	ff d7                	call   *%edi
}
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f6:	5b                   	pop    %ebx
  8005f7:	5e                   	pop    %esi
  8005f8:	5f                   	pop    %edi
  8005f9:	5d                   	pop    %ebp
  8005fa:	c3                   	ret    

008005fb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005fb:	55                   	push   %ebp
  8005fc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005fe:	83 fa 01             	cmp    $0x1,%edx
  800601:	7e 0e                	jle    800611 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800603:	8b 10                	mov    (%eax),%edx
  800605:	8d 4a 08             	lea    0x8(%edx),%ecx
  800608:	89 08                	mov    %ecx,(%eax)
  80060a:	8b 02                	mov    (%edx),%eax
  80060c:	8b 52 04             	mov    0x4(%edx),%edx
  80060f:	eb 22                	jmp    800633 <getuint+0x38>
	else if (lflag)
  800611:	85 d2                	test   %edx,%edx
  800613:	74 10                	je     800625 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800615:	8b 10                	mov    (%eax),%edx
  800617:	8d 4a 04             	lea    0x4(%edx),%ecx
  80061a:	89 08                	mov    %ecx,(%eax)
  80061c:	8b 02                	mov    (%edx),%eax
  80061e:	ba 00 00 00 00       	mov    $0x0,%edx
  800623:	eb 0e                	jmp    800633 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800625:	8b 10                	mov    (%eax),%edx
  800627:	8d 4a 04             	lea    0x4(%edx),%ecx
  80062a:	89 08                	mov    %ecx,(%eax)
  80062c:	8b 02                	mov    (%edx),%eax
  80062e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800633:	5d                   	pop    %ebp
  800634:	c3                   	ret    

00800635 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800635:	55                   	push   %ebp
  800636:	89 e5                	mov    %esp,%ebp
  800638:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80063b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80063f:	8b 10                	mov    (%eax),%edx
  800641:	3b 50 04             	cmp    0x4(%eax),%edx
  800644:	73 0a                	jae    800650 <sprintputch+0x1b>
		*b->buf++ = ch;
  800646:	8d 4a 01             	lea    0x1(%edx),%ecx
  800649:	89 08                	mov    %ecx,(%eax)
  80064b:	8b 45 08             	mov    0x8(%ebp),%eax
  80064e:	88 02                	mov    %al,(%edx)
}
  800650:	5d                   	pop    %ebp
  800651:	c3                   	ret    

00800652 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
  800655:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800658:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80065b:	50                   	push   %eax
  80065c:	ff 75 10             	pushl  0x10(%ebp)
  80065f:	ff 75 0c             	pushl  0xc(%ebp)
  800662:	ff 75 08             	pushl  0x8(%ebp)
  800665:	e8 05 00 00 00       	call   80066f <vprintfmt>
	va_end(ap);
}
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	c9                   	leave  
  80066e:	c3                   	ret    

0080066f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
  800672:	57                   	push   %edi
  800673:	56                   	push   %esi
  800674:	53                   	push   %ebx
  800675:	83 ec 2c             	sub    $0x2c,%esp
  800678:	8b 75 08             	mov    0x8(%ebp),%esi
  80067b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80067e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800681:	eb 12                	jmp    800695 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800683:	85 c0                	test   %eax,%eax
  800685:	0f 84 89 03 00 00    	je     800a14 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	50                   	push   %eax
  800690:	ff d6                	call   *%esi
  800692:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800695:	83 c7 01             	add    $0x1,%edi
  800698:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069c:	83 f8 25             	cmp    $0x25,%eax
  80069f:	75 e2                	jne    800683 <vprintfmt+0x14>
  8006a1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8006a5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8006ac:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006b3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8006ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bf:	eb 07                	jmp    8006c8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006c4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c8:	8d 47 01             	lea    0x1(%edi),%eax
  8006cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ce:	0f b6 07             	movzbl (%edi),%eax
  8006d1:	0f b6 c8             	movzbl %al,%ecx
  8006d4:	83 e8 23             	sub    $0x23,%eax
  8006d7:	3c 55                	cmp    $0x55,%al
  8006d9:	0f 87 1a 03 00 00    	ja     8009f9 <vprintfmt+0x38a>
  8006df:	0f b6 c0             	movzbl %al,%eax
  8006e2:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
  8006e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006ec:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8006f0:	eb d6                	jmp    8006c8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006fd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800700:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800704:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800707:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80070a:	83 fa 09             	cmp    $0x9,%edx
  80070d:	77 39                	ja     800748 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80070f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800712:	eb e9                	jmp    8006fd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 48 04             	lea    0x4(%eax),%ecx
  80071a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80071d:	8b 00                	mov    (%eax),%eax
  80071f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800722:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800725:	eb 27                	jmp    80074e <vprintfmt+0xdf>
  800727:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80072a:	85 c0                	test   %eax,%eax
  80072c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800731:	0f 49 c8             	cmovns %eax,%ecx
  800734:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800737:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80073a:	eb 8c                	jmp    8006c8 <vprintfmt+0x59>
  80073c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80073f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800746:	eb 80                	jmp    8006c8 <vprintfmt+0x59>
  800748:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80074b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80074e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800752:	0f 89 70 ff ff ff    	jns    8006c8 <vprintfmt+0x59>
				width = precision, precision = -1;
  800758:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80075b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80075e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800765:	e9 5e ff ff ff       	jmp    8006c8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80076a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800770:	e9 53 ff ff ff       	jmp    8006c8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8d 50 04             	lea    0x4(%eax),%edx
  80077b:	89 55 14             	mov    %edx,0x14(%ebp)
  80077e:	83 ec 08             	sub    $0x8,%esp
  800781:	53                   	push   %ebx
  800782:	ff 30                	pushl  (%eax)
  800784:	ff d6                	call   *%esi
			break;
  800786:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800789:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80078c:	e9 04 ff ff ff       	jmp    800695 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 50 04             	lea    0x4(%eax),%edx
  800797:	89 55 14             	mov    %edx,0x14(%ebp)
  80079a:	8b 00                	mov    (%eax),%eax
  80079c:	99                   	cltd   
  80079d:	31 d0                	xor    %edx,%eax
  80079f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007a1:	83 f8 0f             	cmp    $0xf,%eax
  8007a4:	7f 0b                	jg     8007b1 <vprintfmt+0x142>
  8007a6:	8b 14 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%edx
  8007ad:	85 d2                	test   %edx,%edx
  8007af:	75 18                	jne    8007c9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8007b1:	50                   	push   %eax
  8007b2:	68 07 28 80 00       	push   $0x802807
  8007b7:	53                   	push   %ebx
  8007b8:	56                   	push   %esi
  8007b9:	e8 94 fe ff ff       	call   800652 <printfmt>
  8007be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007c4:	e9 cc fe ff ff       	jmp    800695 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8007c9:	52                   	push   %edx
  8007ca:	68 d1 2b 80 00       	push   $0x802bd1
  8007cf:	53                   	push   %ebx
  8007d0:	56                   	push   %esi
  8007d1:	e8 7c fe ff ff       	call   800652 <printfmt>
  8007d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007dc:	e9 b4 fe ff ff       	jmp    800695 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8d 50 04             	lea    0x4(%eax),%edx
  8007e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ea:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8007ec:	85 ff                	test   %edi,%edi
  8007ee:	b8 00 28 80 00       	mov    $0x802800,%eax
  8007f3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8007f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007fa:	0f 8e 94 00 00 00    	jle    800894 <vprintfmt+0x225>
  800800:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800804:	0f 84 98 00 00 00    	je     8008a2 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80080a:	83 ec 08             	sub    $0x8,%esp
  80080d:	ff 75 d0             	pushl  -0x30(%ebp)
  800810:	57                   	push   %edi
  800811:	e8 86 02 00 00       	call   800a9c <strnlen>
  800816:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800819:	29 c1                	sub    %eax,%ecx
  80081b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80081e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800821:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800825:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800828:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80082b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80082d:	eb 0f                	jmp    80083e <vprintfmt+0x1cf>
					putch(padc, putdat);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	53                   	push   %ebx
  800833:	ff 75 e0             	pushl  -0x20(%ebp)
  800836:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800838:	83 ef 01             	sub    $0x1,%edi
  80083b:	83 c4 10             	add    $0x10,%esp
  80083e:	85 ff                	test   %edi,%edi
  800840:	7f ed                	jg     80082f <vprintfmt+0x1c0>
  800842:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800845:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800848:	85 c9                	test   %ecx,%ecx
  80084a:	b8 00 00 00 00       	mov    $0x0,%eax
  80084f:	0f 49 c1             	cmovns %ecx,%eax
  800852:	29 c1                	sub    %eax,%ecx
  800854:	89 75 08             	mov    %esi,0x8(%ebp)
  800857:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80085a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80085d:	89 cb                	mov    %ecx,%ebx
  80085f:	eb 4d                	jmp    8008ae <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800861:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800865:	74 1b                	je     800882 <vprintfmt+0x213>
  800867:	0f be c0             	movsbl %al,%eax
  80086a:	83 e8 20             	sub    $0x20,%eax
  80086d:	83 f8 5e             	cmp    $0x5e,%eax
  800870:	76 10                	jbe    800882 <vprintfmt+0x213>
					putch('?', putdat);
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	ff 75 0c             	pushl  0xc(%ebp)
  800878:	6a 3f                	push   $0x3f
  80087a:	ff 55 08             	call   *0x8(%ebp)
  80087d:	83 c4 10             	add    $0x10,%esp
  800880:	eb 0d                	jmp    80088f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800882:	83 ec 08             	sub    $0x8,%esp
  800885:	ff 75 0c             	pushl  0xc(%ebp)
  800888:	52                   	push   %edx
  800889:	ff 55 08             	call   *0x8(%ebp)
  80088c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80088f:	83 eb 01             	sub    $0x1,%ebx
  800892:	eb 1a                	jmp    8008ae <vprintfmt+0x23f>
  800894:	89 75 08             	mov    %esi,0x8(%ebp)
  800897:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80089a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80089d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8008a0:	eb 0c                	jmp    8008ae <vprintfmt+0x23f>
  8008a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8008a5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008ab:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8008ae:	83 c7 01             	add    $0x1,%edi
  8008b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008b5:	0f be d0             	movsbl %al,%edx
  8008b8:	85 d2                	test   %edx,%edx
  8008ba:	74 23                	je     8008df <vprintfmt+0x270>
  8008bc:	85 f6                	test   %esi,%esi
  8008be:	78 a1                	js     800861 <vprintfmt+0x1f2>
  8008c0:	83 ee 01             	sub    $0x1,%esi
  8008c3:	79 9c                	jns    800861 <vprintfmt+0x1f2>
  8008c5:	89 df                	mov    %ebx,%edi
  8008c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008cd:	eb 18                	jmp    8008e7 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008cf:	83 ec 08             	sub    $0x8,%esp
  8008d2:	53                   	push   %ebx
  8008d3:	6a 20                	push   $0x20
  8008d5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008d7:	83 ef 01             	sub    $0x1,%edi
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	eb 08                	jmp    8008e7 <vprintfmt+0x278>
  8008df:	89 df                	mov    %ebx,%edi
  8008e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008e7:	85 ff                	test   %edi,%edi
  8008e9:	7f e4                	jg     8008cf <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ee:	e9 a2 fd ff ff       	jmp    800695 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008f3:	83 fa 01             	cmp    $0x1,%edx
  8008f6:	7e 16                	jle    80090e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8008f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fb:	8d 50 08             	lea    0x8(%eax),%edx
  8008fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800901:	8b 50 04             	mov    0x4(%eax),%edx
  800904:	8b 00                	mov    (%eax),%eax
  800906:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800909:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80090c:	eb 32                	jmp    800940 <vprintfmt+0x2d1>
	else if (lflag)
  80090e:	85 d2                	test   %edx,%edx
  800910:	74 18                	je     80092a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800912:	8b 45 14             	mov    0x14(%ebp),%eax
  800915:	8d 50 04             	lea    0x4(%eax),%edx
  800918:	89 55 14             	mov    %edx,0x14(%ebp)
  80091b:	8b 00                	mov    (%eax),%eax
  80091d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800920:	89 c1                	mov    %eax,%ecx
  800922:	c1 f9 1f             	sar    $0x1f,%ecx
  800925:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800928:	eb 16                	jmp    800940 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80092a:	8b 45 14             	mov    0x14(%ebp),%eax
  80092d:	8d 50 04             	lea    0x4(%eax),%edx
  800930:	89 55 14             	mov    %edx,0x14(%ebp)
  800933:	8b 00                	mov    (%eax),%eax
  800935:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800938:	89 c1                	mov    %eax,%ecx
  80093a:	c1 f9 1f             	sar    $0x1f,%ecx
  80093d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800940:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800943:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800946:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80094b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80094f:	79 74                	jns    8009c5 <vprintfmt+0x356>
				putch('-', putdat);
  800951:	83 ec 08             	sub    $0x8,%esp
  800954:	53                   	push   %ebx
  800955:	6a 2d                	push   $0x2d
  800957:	ff d6                	call   *%esi
				num = -(long long) num;
  800959:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80095c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80095f:	f7 d8                	neg    %eax
  800961:	83 d2 00             	adc    $0x0,%edx
  800964:	f7 da                	neg    %edx
  800966:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800969:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80096e:	eb 55                	jmp    8009c5 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800970:	8d 45 14             	lea    0x14(%ebp),%eax
  800973:	e8 83 fc ff ff       	call   8005fb <getuint>
			base = 10;
  800978:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80097d:	eb 46                	jmp    8009c5 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80097f:	8d 45 14             	lea    0x14(%ebp),%eax
  800982:	e8 74 fc ff ff       	call   8005fb <getuint>
			base = 8;
  800987:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80098c:	eb 37                	jmp    8009c5 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80098e:	83 ec 08             	sub    $0x8,%esp
  800991:	53                   	push   %ebx
  800992:	6a 30                	push   $0x30
  800994:	ff d6                	call   *%esi
			putch('x', putdat);
  800996:	83 c4 08             	add    $0x8,%esp
  800999:	53                   	push   %ebx
  80099a:	6a 78                	push   $0x78
  80099c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80099e:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a1:	8d 50 04             	lea    0x4(%eax),%edx
  8009a4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009a7:	8b 00                	mov    (%eax),%eax
  8009a9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8009ae:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009b1:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8009b6:	eb 0d                	jmp    8009c5 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8009bb:	e8 3b fc ff ff       	call   8005fb <getuint>
			base = 16;
  8009c0:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009c5:	83 ec 0c             	sub    $0xc,%esp
  8009c8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8009cc:	57                   	push   %edi
  8009cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8009d0:	51                   	push   %ecx
  8009d1:	52                   	push   %edx
  8009d2:	50                   	push   %eax
  8009d3:	89 da                	mov    %ebx,%edx
  8009d5:	89 f0                	mov    %esi,%eax
  8009d7:	e8 70 fb ff ff       	call   80054c <printnum>
			break;
  8009dc:	83 c4 20             	add    $0x20,%esp
  8009df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009e2:	e9 ae fc ff ff       	jmp    800695 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009e7:	83 ec 08             	sub    $0x8,%esp
  8009ea:	53                   	push   %ebx
  8009eb:	51                   	push   %ecx
  8009ec:	ff d6                	call   *%esi
			break;
  8009ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009f4:	e9 9c fc ff ff       	jmp    800695 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009f9:	83 ec 08             	sub    $0x8,%esp
  8009fc:	53                   	push   %ebx
  8009fd:	6a 25                	push   $0x25
  8009ff:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a01:	83 c4 10             	add    $0x10,%esp
  800a04:	eb 03                	jmp    800a09 <vprintfmt+0x39a>
  800a06:	83 ef 01             	sub    $0x1,%edi
  800a09:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a0d:	75 f7                	jne    800a06 <vprintfmt+0x397>
  800a0f:	e9 81 fc ff ff       	jmp    800695 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a17:	5b                   	pop    %ebx
  800a18:	5e                   	pop    %esi
  800a19:	5f                   	pop    %edi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	83 ec 18             	sub    $0x18,%esp
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a28:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a2b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a2f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a32:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a39:	85 c0                	test   %eax,%eax
  800a3b:	74 26                	je     800a63 <vsnprintf+0x47>
  800a3d:	85 d2                	test   %edx,%edx
  800a3f:	7e 22                	jle    800a63 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a41:	ff 75 14             	pushl  0x14(%ebp)
  800a44:	ff 75 10             	pushl  0x10(%ebp)
  800a47:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a4a:	50                   	push   %eax
  800a4b:	68 35 06 80 00       	push   $0x800635
  800a50:	e8 1a fc ff ff       	call   80066f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a55:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a58:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a5e:	83 c4 10             	add    $0x10,%esp
  800a61:	eb 05                	jmp    800a68 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a63:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a68:	c9                   	leave  
  800a69:	c3                   	ret    

00800a6a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a70:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a73:	50                   	push   %eax
  800a74:	ff 75 10             	pushl  0x10(%ebp)
  800a77:	ff 75 0c             	pushl  0xc(%ebp)
  800a7a:	ff 75 08             	pushl  0x8(%ebp)
  800a7d:	e8 9a ff ff ff       	call   800a1c <vsnprintf>
	va_end(ap);

	return rc;
}
  800a82:	c9                   	leave  
  800a83:	c3                   	ret    

00800a84 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8f:	eb 03                	jmp    800a94 <strlen+0x10>
		n++;
  800a91:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a94:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a98:	75 f7                	jne    800a91 <strlen+0xd>
		n++;
	return n;
}
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aa5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aaa:	eb 03                	jmp    800aaf <strnlen+0x13>
		n++;
  800aac:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aaf:	39 c2                	cmp    %eax,%edx
  800ab1:	74 08                	je     800abb <strnlen+0x1f>
  800ab3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800ab7:	75 f3                	jne    800aac <strnlen+0x10>
  800ab9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	53                   	push   %ebx
  800ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ac7:	89 c2                	mov    %eax,%edx
  800ac9:	83 c2 01             	add    $0x1,%edx
  800acc:	83 c1 01             	add    $0x1,%ecx
  800acf:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ad3:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ad6:	84 db                	test   %bl,%bl
  800ad8:	75 ef                	jne    800ac9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ada:	5b                   	pop    %ebx
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <strcat>:

char *
strcat(char *dst, const char *src)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	53                   	push   %ebx
  800ae1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ae4:	53                   	push   %ebx
  800ae5:	e8 9a ff ff ff       	call   800a84 <strlen>
  800aea:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800aed:	ff 75 0c             	pushl  0xc(%ebp)
  800af0:	01 d8                	add    %ebx,%eax
  800af2:	50                   	push   %eax
  800af3:	e8 c5 ff ff ff       	call   800abd <strcpy>
	return dst;
}
  800af8:	89 d8                	mov    %ebx,%eax
  800afa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    

00800aff <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
  800b04:	8b 75 08             	mov    0x8(%ebp),%esi
  800b07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0a:	89 f3                	mov    %esi,%ebx
  800b0c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b0f:	89 f2                	mov    %esi,%edx
  800b11:	eb 0f                	jmp    800b22 <strncpy+0x23>
		*dst++ = *src;
  800b13:	83 c2 01             	add    $0x1,%edx
  800b16:	0f b6 01             	movzbl (%ecx),%eax
  800b19:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b1c:	80 39 01             	cmpb   $0x1,(%ecx)
  800b1f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b22:	39 da                	cmp    %ebx,%edx
  800b24:	75 ed                	jne    800b13 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b26:	89 f0                	mov    %esi,%eax
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	8b 75 08             	mov    0x8(%ebp),%esi
  800b34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b37:	8b 55 10             	mov    0x10(%ebp),%edx
  800b3a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b3c:	85 d2                	test   %edx,%edx
  800b3e:	74 21                	je     800b61 <strlcpy+0x35>
  800b40:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b44:	89 f2                	mov    %esi,%edx
  800b46:	eb 09                	jmp    800b51 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b48:	83 c2 01             	add    $0x1,%edx
  800b4b:	83 c1 01             	add    $0x1,%ecx
  800b4e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b51:	39 c2                	cmp    %eax,%edx
  800b53:	74 09                	je     800b5e <strlcpy+0x32>
  800b55:	0f b6 19             	movzbl (%ecx),%ebx
  800b58:	84 db                	test   %bl,%bl
  800b5a:	75 ec                	jne    800b48 <strlcpy+0x1c>
  800b5c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b5e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b61:	29 f0                	sub    %esi,%eax
}
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b70:	eb 06                	jmp    800b78 <strcmp+0x11>
		p++, q++;
  800b72:	83 c1 01             	add    $0x1,%ecx
  800b75:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b78:	0f b6 01             	movzbl (%ecx),%eax
  800b7b:	84 c0                	test   %al,%al
  800b7d:	74 04                	je     800b83 <strcmp+0x1c>
  800b7f:	3a 02                	cmp    (%edx),%al
  800b81:	74 ef                	je     800b72 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b83:	0f b6 c0             	movzbl %al,%eax
  800b86:	0f b6 12             	movzbl (%edx),%edx
  800b89:	29 d0                	sub    %edx,%eax
}
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	53                   	push   %ebx
  800b91:	8b 45 08             	mov    0x8(%ebp),%eax
  800b94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b97:	89 c3                	mov    %eax,%ebx
  800b99:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b9c:	eb 06                	jmp    800ba4 <strncmp+0x17>
		n--, p++, q++;
  800b9e:	83 c0 01             	add    $0x1,%eax
  800ba1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ba4:	39 d8                	cmp    %ebx,%eax
  800ba6:	74 15                	je     800bbd <strncmp+0x30>
  800ba8:	0f b6 08             	movzbl (%eax),%ecx
  800bab:	84 c9                	test   %cl,%cl
  800bad:	74 04                	je     800bb3 <strncmp+0x26>
  800baf:	3a 0a                	cmp    (%edx),%cl
  800bb1:	74 eb                	je     800b9e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb3:	0f b6 00             	movzbl (%eax),%eax
  800bb6:	0f b6 12             	movzbl (%edx),%edx
  800bb9:	29 d0                	sub    %edx,%eax
  800bbb:	eb 05                	jmp    800bc2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bcf:	eb 07                	jmp    800bd8 <strchr+0x13>
		if (*s == c)
  800bd1:	38 ca                	cmp    %cl,%dl
  800bd3:	74 0f                	je     800be4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bd5:	83 c0 01             	add    $0x1,%eax
  800bd8:	0f b6 10             	movzbl (%eax),%edx
  800bdb:	84 d2                	test   %dl,%dl
  800bdd:	75 f2                	jne    800bd1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800bdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bf0:	eb 03                	jmp    800bf5 <strfind+0xf>
  800bf2:	83 c0 01             	add    $0x1,%eax
  800bf5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bf8:	38 ca                	cmp    %cl,%dl
  800bfa:	74 04                	je     800c00 <strfind+0x1a>
  800bfc:	84 d2                	test   %dl,%dl
  800bfe:	75 f2                	jne    800bf2 <strfind+0xc>
			break;
	return (char *) s;
}
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c0b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c0e:	85 c9                	test   %ecx,%ecx
  800c10:	74 36                	je     800c48 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c12:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c18:	75 28                	jne    800c42 <memset+0x40>
  800c1a:	f6 c1 03             	test   $0x3,%cl
  800c1d:	75 23                	jne    800c42 <memset+0x40>
		c &= 0xFF;
  800c1f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c23:	89 d3                	mov    %edx,%ebx
  800c25:	c1 e3 08             	shl    $0x8,%ebx
  800c28:	89 d6                	mov    %edx,%esi
  800c2a:	c1 e6 18             	shl    $0x18,%esi
  800c2d:	89 d0                	mov    %edx,%eax
  800c2f:	c1 e0 10             	shl    $0x10,%eax
  800c32:	09 f0                	or     %esi,%eax
  800c34:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c36:	89 d8                	mov    %ebx,%eax
  800c38:	09 d0                	or     %edx,%eax
  800c3a:	c1 e9 02             	shr    $0x2,%ecx
  800c3d:	fc                   	cld    
  800c3e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c40:	eb 06                	jmp    800c48 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c45:	fc                   	cld    
  800c46:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c48:	89 f8                	mov    %edi,%eax
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	8b 45 08             	mov    0x8(%ebp),%eax
  800c57:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c5d:	39 c6                	cmp    %eax,%esi
  800c5f:	73 35                	jae    800c96 <memmove+0x47>
  800c61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c64:	39 d0                	cmp    %edx,%eax
  800c66:	73 2e                	jae    800c96 <memmove+0x47>
		s += n;
		d += n;
  800c68:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6b:	89 d6                	mov    %edx,%esi
  800c6d:	09 fe                	or     %edi,%esi
  800c6f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c75:	75 13                	jne    800c8a <memmove+0x3b>
  800c77:	f6 c1 03             	test   $0x3,%cl
  800c7a:	75 0e                	jne    800c8a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c7c:	83 ef 04             	sub    $0x4,%edi
  800c7f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c82:	c1 e9 02             	shr    $0x2,%ecx
  800c85:	fd                   	std    
  800c86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c88:	eb 09                	jmp    800c93 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c8a:	83 ef 01             	sub    $0x1,%edi
  800c8d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c90:	fd                   	std    
  800c91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c93:	fc                   	cld    
  800c94:	eb 1d                	jmp    800cb3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c96:	89 f2                	mov    %esi,%edx
  800c98:	09 c2                	or     %eax,%edx
  800c9a:	f6 c2 03             	test   $0x3,%dl
  800c9d:	75 0f                	jne    800cae <memmove+0x5f>
  800c9f:	f6 c1 03             	test   $0x3,%cl
  800ca2:	75 0a                	jne    800cae <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ca4:	c1 e9 02             	shr    $0x2,%ecx
  800ca7:	89 c7                	mov    %eax,%edi
  800ca9:	fc                   	cld    
  800caa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cac:	eb 05                	jmp    800cb3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cae:	89 c7                	mov    %eax,%edi
  800cb0:	fc                   	cld    
  800cb1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800cba:	ff 75 10             	pushl  0x10(%ebp)
  800cbd:	ff 75 0c             	pushl  0xc(%ebp)
  800cc0:	ff 75 08             	pushl  0x8(%ebp)
  800cc3:	e8 87 ff ff ff       	call   800c4f <memmove>
}
  800cc8:	c9                   	leave  
  800cc9:	c3                   	ret    

00800cca <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd5:	89 c6                	mov    %eax,%esi
  800cd7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cda:	eb 1a                	jmp    800cf6 <memcmp+0x2c>
		if (*s1 != *s2)
  800cdc:	0f b6 08             	movzbl (%eax),%ecx
  800cdf:	0f b6 1a             	movzbl (%edx),%ebx
  800ce2:	38 d9                	cmp    %bl,%cl
  800ce4:	74 0a                	je     800cf0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ce6:	0f b6 c1             	movzbl %cl,%eax
  800ce9:	0f b6 db             	movzbl %bl,%ebx
  800cec:	29 d8                	sub    %ebx,%eax
  800cee:	eb 0f                	jmp    800cff <memcmp+0x35>
		s1++, s2++;
  800cf0:	83 c0 01             	add    $0x1,%eax
  800cf3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf6:	39 f0                	cmp    %esi,%eax
  800cf8:	75 e2                	jne    800cdc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cfa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	53                   	push   %ebx
  800d07:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d0a:	89 c1                	mov    %eax,%ecx
  800d0c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d0f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d13:	eb 0a                	jmp    800d1f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d15:	0f b6 10             	movzbl (%eax),%edx
  800d18:	39 da                	cmp    %ebx,%edx
  800d1a:	74 07                	je     800d23 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d1c:	83 c0 01             	add    $0x1,%eax
  800d1f:	39 c8                	cmp    %ecx,%eax
  800d21:	72 f2                	jb     800d15 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d23:	5b                   	pop    %ebx
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d32:	eb 03                	jmp    800d37 <strtol+0x11>
		s++;
  800d34:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d37:	0f b6 01             	movzbl (%ecx),%eax
  800d3a:	3c 20                	cmp    $0x20,%al
  800d3c:	74 f6                	je     800d34 <strtol+0xe>
  800d3e:	3c 09                	cmp    $0x9,%al
  800d40:	74 f2                	je     800d34 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d42:	3c 2b                	cmp    $0x2b,%al
  800d44:	75 0a                	jne    800d50 <strtol+0x2a>
		s++;
  800d46:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d49:	bf 00 00 00 00       	mov    $0x0,%edi
  800d4e:	eb 11                	jmp    800d61 <strtol+0x3b>
  800d50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d55:	3c 2d                	cmp    $0x2d,%al
  800d57:	75 08                	jne    800d61 <strtol+0x3b>
		s++, neg = 1;
  800d59:	83 c1 01             	add    $0x1,%ecx
  800d5c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d61:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d67:	75 15                	jne    800d7e <strtol+0x58>
  800d69:	80 39 30             	cmpb   $0x30,(%ecx)
  800d6c:	75 10                	jne    800d7e <strtol+0x58>
  800d6e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d72:	75 7c                	jne    800df0 <strtol+0xca>
		s += 2, base = 16;
  800d74:	83 c1 02             	add    $0x2,%ecx
  800d77:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d7c:	eb 16                	jmp    800d94 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d7e:	85 db                	test   %ebx,%ebx
  800d80:	75 12                	jne    800d94 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d82:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d87:	80 39 30             	cmpb   $0x30,(%ecx)
  800d8a:	75 08                	jne    800d94 <strtol+0x6e>
		s++, base = 8;
  800d8c:	83 c1 01             	add    $0x1,%ecx
  800d8f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d94:	b8 00 00 00 00       	mov    $0x0,%eax
  800d99:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d9c:	0f b6 11             	movzbl (%ecx),%edx
  800d9f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800da2:	89 f3                	mov    %esi,%ebx
  800da4:	80 fb 09             	cmp    $0x9,%bl
  800da7:	77 08                	ja     800db1 <strtol+0x8b>
			dig = *s - '0';
  800da9:	0f be d2             	movsbl %dl,%edx
  800dac:	83 ea 30             	sub    $0x30,%edx
  800daf:	eb 22                	jmp    800dd3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800db1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800db4:	89 f3                	mov    %esi,%ebx
  800db6:	80 fb 19             	cmp    $0x19,%bl
  800db9:	77 08                	ja     800dc3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800dbb:	0f be d2             	movsbl %dl,%edx
  800dbe:	83 ea 57             	sub    $0x57,%edx
  800dc1:	eb 10                	jmp    800dd3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800dc3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dc6:	89 f3                	mov    %esi,%ebx
  800dc8:	80 fb 19             	cmp    $0x19,%bl
  800dcb:	77 16                	ja     800de3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800dcd:	0f be d2             	movsbl %dl,%edx
  800dd0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800dd3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800dd6:	7d 0b                	jge    800de3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800dd8:	83 c1 01             	add    $0x1,%ecx
  800ddb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ddf:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800de1:	eb b9                	jmp    800d9c <strtol+0x76>

	if (endptr)
  800de3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de7:	74 0d                	je     800df6 <strtol+0xd0>
		*endptr = (char *) s;
  800de9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dec:	89 0e                	mov    %ecx,(%esi)
  800dee:	eb 06                	jmp    800df6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800df0:	85 db                	test   %ebx,%ebx
  800df2:	74 98                	je     800d8c <strtol+0x66>
  800df4:	eb 9e                	jmp    800d94 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800df6:	89 c2                	mov    %eax,%edx
  800df8:	f7 da                	neg    %edx
  800dfa:	85 ff                	test   %edi,%edi
  800dfc:	0f 45 c2             	cmovne %edx,%eax
}
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e12:	8b 55 08             	mov    0x8(%ebp),%edx
  800e15:	89 c3                	mov    %eax,%ebx
  800e17:	89 c7                	mov    %eax,%edi
  800e19:	89 c6                	mov    %eax,%esi
  800e1b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e28:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e32:	89 d1                	mov    %edx,%ecx
  800e34:	89 d3                	mov    %edx,%ebx
  800e36:	89 d7                	mov    %edx,%edi
  800e38:	89 d6                	mov    %edx,%esi
  800e3a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
  800e47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e4f:	b8 03 00 00 00       	mov    $0x3,%eax
  800e54:	8b 55 08             	mov    0x8(%ebp),%edx
  800e57:	89 cb                	mov    %ecx,%ebx
  800e59:	89 cf                	mov    %ecx,%edi
  800e5b:	89 ce                	mov    %ecx,%esi
  800e5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	7e 17                	jle    800e7a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e63:	83 ec 0c             	sub    $0xc,%esp
  800e66:	50                   	push   %eax
  800e67:	6a 03                	push   $0x3
  800e69:	68 ff 2a 80 00       	push   $0x802aff
  800e6e:	6a 23                	push   $0x23
  800e70:	68 1c 2b 80 00       	push   $0x802b1c
  800e75:	e8 e5 f5 ff ff       	call   80045f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e88:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e92:	89 d1                	mov    %edx,%ecx
  800e94:	89 d3                	mov    %edx,%ebx
  800e96:	89 d7                	mov    %edx,%edi
  800e98:	89 d6                	mov    %edx,%esi
  800e9a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e9c:	5b                   	pop    %ebx
  800e9d:	5e                   	pop    %esi
  800e9e:	5f                   	pop    %edi
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <sys_yield>:

void
sys_yield(void)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	57                   	push   %edi
  800ea5:	56                   	push   %esi
  800ea6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea7:	ba 00 00 00 00       	mov    $0x0,%edx
  800eac:	b8 0b 00 00 00       	mov    $0xb,%eax
  800eb1:	89 d1                	mov    %edx,%ecx
  800eb3:	89 d3                	mov    %edx,%ebx
  800eb5:	89 d7                	mov    %edx,%edi
  800eb7:	89 d6                	mov    %edx,%esi
  800eb9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ebb:	5b                   	pop    %ebx
  800ebc:	5e                   	pop    %esi
  800ebd:	5f                   	pop    %edi
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	57                   	push   %edi
  800ec4:	56                   	push   %esi
  800ec5:	53                   	push   %ebx
  800ec6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec9:	be 00 00 00 00       	mov    $0x0,%esi
  800ece:	b8 04 00 00 00       	mov    $0x4,%eax
  800ed3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800edc:	89 f7                	mov    %esi,%edi
  800ede:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	7e 17                	jle    800efb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee4:	83 ec 0c             	sub    $0xc,%esp
  800ee7:	50                   	push   %eax
  800ee8:	6a 04                	push   $0x4
  800eea:	68 ff 2a 80 00       	push   $0x802aff
  800eef:	6a 23                	push   $0x23
  800ef1:	68 1c 2b 80 00       	push   $0x802b1c
  800ef6:	e8 64 f5 ff ff       	call   80045f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800efb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efe:	5b                   	pop    %ebx
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	57                   	push   %edi
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0c:	b8 05 00 00 00       	mov    $0x5,%eax
  800f11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f14:	8b 55 08             	mov    0x8(%ebp),%edx
  800f17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f1d:	8b 75 18             	mov    0x18(%ebp),%esi
  800f20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f22:	85 c0                	test   %eax,%eax
  800f24:	7e 17                	jle    800f3d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f26:	83 ec 0c             	sub    $0xc,%esp
  800f29:	50                   	push   %eax
  800f2a:	6a 05                	push   $0x5
  800f2c:	68 ff 2a 80 00       	push   $0x802aff
  800f31:	6a 23                	push   $0x23
  800f33:	68 1c 2b 80 00       	push   $0x802b1c
  800f38:	e8 22 f5 ff ff       	call   80045f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f53:	b8 06 00 00 00       	mov    $0x6,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	89 df                	mov    %ebx,%edi
  800f60:	89 de                	mov    %ebx,%esi
  800f62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f64:	85 c0                	test   %eax,%eax
  800f66:	7e 17                	jle    800f7f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f68:	83 ec 0c             	sub    $0xc,%esp
  800f6b:	50                   	push   %eax
  800f6c:	6a 06                	push   $0x6
  800f6e:	68 ff 2a 80 00       	push   $0x802aff
  800f73:	6a 23                	push   $0x23
  800f75:	68 1c 2b 80 00       	push   $0x802b1c
  800f7a:	e8 e0 f4 ff ff       	call   80045f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f82:	5b                   	pop    %ebx
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	57                   	push   %edi
  800f8b:	56                   	push   %esi
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f95:	b8 08 00 00 00       	mov    $0x8,%eax
  800f9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa0:	89 df                	mov    %ebx,%edi
  800fa2:	89 de                	mov    %ebx,%esi
  800fa4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	7e 17                	jle    800fc1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800faa:	83 ec 0c             	sub    $0xc,%esp
  800fad:	50                   	push   %eax
  800fae:	6a 08                	push   $0x8
  800fb0:	68 ff 2a 80 00       	push   $0x802aff
  800fb5:	6a 23                	push   $0x23
  800fb7:	68 1c 2b 80 00       	push   $0x802b1c
  800fbc:	e8 9e f4 ff ff       	call   80045f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc4:	5b                   	pop    %ebx
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	57                   	push   %edi
  800fcd:	56                   	push   %esi
  800fce:	53                   	push   %ebx
  800fcf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd7:	b8 09 00 00 00       	mov    $0x9,%eax
  800fdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe2:	89 df                	mov    %ebx,%edi
  800fe4:	89 de                	mov    %ebx,%esi
  800fe6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	7e 17                	jle    801003 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fec:	83 ec 0c             	sub    $0xc,%esp
  800fef:	50                   	push   %eax
  800ff0:	6a 09                	push   $0x9
  800ff2:	68 ff 2a 80 00       	push   $0x802aff
  800ff7:	6a 23                	push   $0x23
  800ff9:	68 1c 2b 80 00       	push   $0x802b1c
  800ffe:	e8 5c f4 ff ff       	call   80045f <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801006:	5b                   	pop    %ebx
  801007:	5e                   	pop    %esi
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	57                   	push   %edi
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
  801011:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801014:	bb 00 00 00 00       	mov    $0x0,%ebx
  801019:	b8 0a 00 00 00       	mov    $0xa,%eax
  80101e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801021:	8b 55 08             	mov    0x8(%ebp),%edx
  801024:	89 df                	mov    %ebx,%edi
  801026:	89 de                	mov    %ebx,%esi
  801028:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80102a:	85 c0                	test   %eax,%eax
  80102c:	7e 17                	jle    801045 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102e:	83 ec 0c             	sub    $0xc,%esp
  801031:	50                   	push   %eax
  801032:	6a 0a                	push   $0xa
  801034:	68 ff 2a 80 00       	push   $0x802aff
  801039:	6a 23                	push   $0x23
  80103b:	68 1c 2b 80 00       	push   $0x802b1c
  801040:	e8 1a f4 ff ff       	call   80045f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801045:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801048:	5b                   	pop    %ebx
  801049:	5e                   	pop    %esi
  80104a:	5f                   	pop    %edi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    

0080104d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	57                   	push   %edi
  801051:	56                   	push   %esi
  801052:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801053:	be 00 00 00 00       	mov    $0x0,%esi
  801058:	b8 0c 00 00 00       	mov    $0xc,%eax
  80105d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801060:	8b 55 08             	mov    0x8(%ebp),%edx
  801063:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801066:	8b 7d 14             	mov    0x14(%ebp),%edi
  801069:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	53                   	push   %ebx
  801076:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801079:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801083:	8b 55 08             	mov    0x8(%ebp),%edx
  801086:	89 cb                	mov    %ecx,%ebx
  801088:	89 cf                	mov    %ecx,%edi
  80108a:	89 ce                	mov    %ecx,%esi
  80108c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80108e:	85 c0                	test   %eax,%eax
  801090:	7e 17                	jle    8010a9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	50                   	push   %eax
  801096:	6a 0d                	push   $0xd
  801098:	68 ff 2a 80 00       	push   $0x802aff
  80109d:	6a 23                	push   $0x23
  80109f:	68 1c 2b 80 00       	push   $0x802b1c
  8010a4:	e8 b6 f3 ff ff       	call   80045f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ac:	5b                   	pop    %ebx
  8010ad:	5e                   	pop    %esi
  8010ae:	5f                   	pop    %edi
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    

008010b1 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	57                   	push   %edi
  8010b5:	56                   	push   %esi
  8010b6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010bc:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c4:	89 cb                	mov    %ecx,%ebx
  8010c6:	89 cf                	mov    %ecx,%edi
  8010c8:	89 ce                	mov    %ecx,%esi
  8010ca:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  8010cc:	5b                   	pop    %ebx
  8010cd:	5e                   	pop    %esi
  8010ce:	5f                   	pop    %edi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d7:	05 00 00 00 30       	add    $0x30000000,%eax
  8010dc:	c1 e8 0c             	shr    $0xc,%eax
}
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e7:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010f1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fe:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801103:	89 c2                	mov    %eax,%edx
  801105:	c1 ea 16             	shr    $0x16,%edx
  801108:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80110f:	f6 c2 01             	test   $0x1,%dl
  801112:	74 11                	je     801125 <fd_alloc+0x2d>
  801114:	89 c2                	mov    %eax,%edx
  801116:	c1 ea 0c             	shr    $0xc,%edx
  801119:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801120:	f6 c2 01             	test   $0x1,%dl
  801123:	75 09                	jne    80112e <fd_alloc+0x36>
			*fd_store = fd;
  801125:	89 01                	mov    %eax,(%ecx)
			return 0;
  801127:	b8 00 00 00 00       	mov    $0x0,%eax
  80112c:	eb 17                	jmp    801145 <fd_alloc+0x4d>
  80112e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801133:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801138:	75 c9                	jne    801103 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80113a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801140:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    

00801147 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80114d:	83 f8 1f             	cmp    $0x1f,%eax
  801150:	77 36                	ja     801188 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801152:	c1 e0 0c             	shl    $0xc,%eax
  801155:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80115a:	89 c2                	mov    %eax,%edx
  80115c:	c1 ea 16             	shr    $0x16,%edx
  80115f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801166:	f6 c2 01             	test   $0x1,%dl
  801169:	74 24                	je     80118f <fd_lookup+0x48>
  80116b:	89 c2                	mov    %eax,%edx
  80116d:	c1 ea 0c             	shr    $0xc,%edx
  801170:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801177:	f6 c2 01             	test   $0x1,%dl
  80117a:	74 1a                	je     801196 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80117c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117f:	89 02                	mov    %eax,(%edx)
	return 0;
  801181:	b8 00 00 00 00       	mov    $0x0,%eax
  801186:	eb 13                	jmp    80119b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801188:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118d:	eb 0c                	jmp    80119b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80118f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801194:	eb 05                	jmp    80119b <fd_lookup+0x54>
  801196:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	83 ec 08             	sub    $0x8,%esp
  8011a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a6:	ba a8 2b 80 00       	mov    $0x802ba8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ab:	eb 13                	jmp    8011c0 <dev_lookup+0x23>
  8011ad:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011b0:	39 08                	cmp    %ecx,(%eax)
  8011b2:	75 0c                	jne    8011c0 <dev_lookup+0x23>
			*dev = devtab[i];
  8011b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011be:	eb 2e                	jmp    8011ee <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011c0:	8b 02                	mov    (%edx),%eax
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	75 e7                	jne    8011ad <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011c6:	a1 90 67 80 00       	mov    0x806790,%eax
  8011cb:	8b 40 50             	mov    0x50(%eax),%eax
  8011ce:	83 ec 04             	sub    $0x4,%esp
  8011d1:	51                   	push   %ecx
  8011d2:	50                   	push   %eax
  8011d3:	68 2c 2b 80 00       	push   $0x802b2c
  8011d8:	e8 5b f3 ff ff       	call   800538 <cprintf>
	*dev = 0;
  8011dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ee:	c9                   	leave  
  8011ef:	c3                   	ret    

008011f0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	56                   	push   %esi
  8011f4:	53                   	push   %ebx
  8011f5:	83 ec 10             	sub    $0x10,%esp
  8011f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801201:	50                   	push   %eax
  801202:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801208:	c1 e8 0c             	shr    $0xc,%eax
  80120b:	50                   	push   %eax
  80120c:	e8 36 ff ff ff       	call   801147 <fd_lookup>
  801211:	83 c4 08             	add    $0x8,%esp
  801214:	85 c0                	test   %eax,%eax
  801216:	78 05                	js     80121d <fd_close+0x2d>
	    || fd != fd2)
  801218:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80121b:	74 0c                	je     801229 <fd_close+0x39>
		return (must_exist ? r : 0);
  80121d:	84 db                	test   %bl,%bl
  80121f:	ba 00 00 00 00       	mov    $0x0,%edx
  801224:	0f 44 c2             	cmove  %edx,%eax
  801227:	eb 41                	jmp    80126a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801229:	83 ec 08             	sub    $0x8,%esp
  80122c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122f:	50                   	push   %eax
  801230:	ff 36                	pushl  (%esi)
  801232:	e8 66 ff ff ff       	call   80119d <dev_lookup>
  801237:	89 c3                	mov    %eax,%ebx
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 1a                	js     80125a <fd_close+0x6a>
		if (dev->dev_close)
  801240:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801243:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801246:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80124b:	85 c0                	test   %eax,%eax
  80124d:	74 0b                	je     80125a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80124f:	83 ec 0c             	sub    $0xc,%esp
  801252:	56                   	push   %esi
  801253:	ff d0                	call   *%eax
  801255:	89 c3                	mov    %eax,%ebx
  801257:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80125a:	83 ec 08             	sub    $0x8,%esp
  80125d:	56                   	push   %esi
  80125e:	6a 00                	push   $0x0
  801260:	e8 e0 fc ff ff       	call   800f45 <sys_page_unmap>
	return r;
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	89 d8                	mov    %ebx,%eax
}
  80126a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80126d:	5b                   	pop    %ebx
  80126e:	5e                   	pop    %esi
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801277:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127a:	50                   	push   %eax
  80127b:	ff 75 08             	pushl  0x8(%ebp)
  80127e:	e8 c4 fe ff ff       	call   801147 <fd_lookup>
  801283:	83 c4 08             	add    $0x8,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 10                	js     80129a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	6a 01                	push   $0x1
  80128f:	ff 75 f4             	pushl  -0xc(%ebp)
  801292:	e8 59 ff ff ff       	call   8011f0 <fd_close>
  801297:	83 c4 10             	add    $0x10,%esp
}
  80129a:	c9                   	leave  
  80129b:	c3                   	ret    

0080129c <close_all>:

void
close_all(void)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	53                   	push   %ebx
  8012a0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012a8:	83 ec 0c             	sub    $0xc,%esp
  8012ab:	53                   	push   %ebx
  8012ac:	e8 c0 ff ff ff       	call   801271 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012b1:	83 c3 01             	add    $0x1,%ebx
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	83 fb 20             	cmp    $0x20,%ebx
  8012ba:	75 ec                	jne    8012a8 <close_all+0xc>
		close(i);
}
  8012bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bf:	c9                   	leave  
  8012c0:	c3                   	ret    

008012c1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	57                   	push   %edi
  8012c5:	56                   	push   %esi
  8012c6:	53                   	push   %ebx
  8012c7:	83 ec 2c             	sub    $0x2c,%esp
  8012ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012d0:	50                   	push   %eax
  8012d1:	ff 75 08             	pushl  0x8(%ebp)
  8012d4:	e8 6e fe ff ff       	call   801147 <fd_lookup>
  8012d9:	83 c4 08             	add    $0x8,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	0f 88 c1 00 00 00    	js     8013a5 <dup+0xe4>
		return r;
	close(newfdnum);
  8012e4:	83 ec 0c             	sub    $0xc,%esp
  8012e7:	56                   	push   %esi
  8012e8:	e8 84 ff ff ff       	call   801271 <close>

	newfd = INDEX2FD(newfdnum);
  8012ed:	89 f3                	mov    %esi,%ebx
  8012ef:	c1 e3 0c             	shl    $0xc,%ebx
  8012f2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012f8:	83 c4 04             	add    $0x4,%esp
  8012fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012fe:	e8 de fd ff ff       	call   8010e1 <fd2data>
  801303:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801305:	89 1c 24             	mov    %ebx,(%esp)
  801308:	e8 d4 fd ff ff       	call   8010e1 <fd2data>
  80130d:	83 c4 10             	add    $0x10,%esp
  801310:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801313:	89 f8                	mov    %edi,%eax
  801315:	c1 e8 16             	shr    $0x16,%eax
  801318:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80131f:	a8 01                	test   $0x1,%al
  801321:	74 37                	je     80135a <dup+0x99>
  801323:	89 f8                	mov    %edi,%eax
  801325:	c1 e8 0c             	shr    $0xc,%eax
  801328:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80132f:	f6 c2 01             	test   $0x1,%dl
  801332:	74 26                	je     80135a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801334:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	25 07 0e 00 00       	and    $0xe07,%eax
  801343:	50                   	push   %eax
  801344:	ff 75 d4             	pushl  -0x2c(%ebp)
  801347:	6a 00                	push   $0x0
  801349:	57                   	push   %edi
  80134a:	6a 00                	push   $0x0
  80134c:	e8 b2 fb ff ff       	call   800f03 <sys_page_map>
  801351:	89 c7                	mov    %eax,%edi
  801353:	83 c4 20             	add    $0x20,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	78 2e                	js     801388 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80135a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80135d:	89 d0                	mov    %edx,%eax
  80135f:	c1 e8 0c             	shr    $0xc,%eax
  801362:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801369:	83 ec 0c             	sub    $0xc,%esp
  80136c:	25 07 0e 00 00       	and    $0xe07,%eax
  801371:	50                   	push   %eax
  801372:	53                   	push   %ebx
  801373:	6a 00                	push   $0x0
  801375:	52                   	push   %edx
  801376:	6a 00                	push   $0x0
  801378:	e8 86 fb ff ff       	call   800f03 <sys_page_map>
  80137d:	89 c7                	mov    %eax,%edi
  80137f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801382:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801384:	85 ff                	test   %edi,%edi
  801386:	79 1d                	jns    8013a5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	53                   	push   %ebx
  80138c:	6a 00                	push   $0x0
  80138e:	e8 b2 fb ff ff       	call   800f45 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801393:	83 c4 08             	add    $0x8,%esp
  801396:	ff 75 d4             	pushl  -0x2c(%ebp)
  801399:	6a 00                	push   $0x0
  80139b:	e8 a5 fb ff ff       	call   800f45 <sys_page_unmap>
	return r;
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	89 f8                	mov    %edi,%eax
}
  8013a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a8:	5b                   	pop    %ebx
  8013a9:	5e                   	pop    %esi
  8013aa:	5f                   	pop    %edi
  8013ab:	5d                   	pop    %ebp
  8013ac:	c3                   	ret    

008013ad <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	53                   	push   %ebx
  8013b1:	83 ec 14             	sub    $0x14,%esp
  8013b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ba:	50                   	push   %eax
  8013bb:	53                   	push   %ebx
  8013bc:	e8 86 fd ff ff       	call   801147 <fd_lookup>
  8013c1:	83 c4 08             	add    $0x8,%esp
  8013c4:	89 c2                	mov    %eax,%edx
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 6d                	js     801437 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d0:	50                   	push   %eax
  8013d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d4:	ff 30                	pushl  (%eax)
  8013d6:	e8 c2 fd ff ff       	call   80119d <dev_lookup>
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 4c                	js     80142e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013e5:	8b 42 08             	mov    0x8(%edx),%eax
  8013e8:	83 e0 03             	and    $0x3,%eax
  8013eb:	83 f8 01             	cmp    $0x1,%eax
  8013ee:	75 21                	jne    801411 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f0:	a1 90 67 80 00       	mov    0x806790,%eax
  8013f5:	8b 40 50             	mov    0x50(%eax),%eax
  8013f8:	83 ec 04             	sub    $0x4,%esp
  8013fb:	53                   	push   %ebx
  8013fc:	50                   	push   %eax
  8013fd:	68 6d 2b 80 00       	push   $0x802b6d
  801402:	e8 31 f1 ff ff       	call   800538 <cprintf>
		return -E_INVAL;
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80140f:	eb 26                	jmp    801437 <read+0x8a>
	}
	if (!dev->dev_read)
  801411:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801414:	8b 40 08             	mov    0x8(%eax),%eax
  801417:	85 c0                	test   %eax,%eax
  801419:	74 17                	je     801432 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80141b:	83 ec 04             	sub    $0x4,%esp
  80141e:	ff 75 10             	pushl  0x10(%ebp)
  801421:	ff 75 0c             	pushl  0xc(%ebp)
  801424:	52                   	push   %edx
  801425:	ff d0                	call   *%eax
  801427:	89 c2                	mov    %eax,%edx
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	eb 09                	jmp    801437 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142e:	89 c2                	mov    %eax,%edx
  801430:	eb 05                	jmp    801437 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801432:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801437:	89 d0                	mov    %edx,%eax
  801439:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143c:	c9                   	leave  
  80143d:	c3                   	ret    

0080143e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	57                   	push   %edi
  801442:	56                   	push   %esi
  801443:	53                   	push   %ebx
  801444:	83 ec 0c             	sub    $0xc,%esp
  801447:	8b 7d 08             	mov    0x8(%ebp),%edi
  80144a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80144d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801452:	eb 21                	jmp    801475 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801454:	83 ec 04             	sub    $0x4,%esp
  801457:	89 f0                	mov    %esi,%eax
  801459:	29 d8                	sub    %ebx,%eax
  80145b:	50                   	push   %eax
  80145c:	89 d8                	mov    %ebx,%eax
  80145e:	03 45 0c             	add    0xc(%ebp),%eax
  801461:	50                   	push   %eax
  801462:	57                   	push   %edi
  801463:	e8 45 ff ff ff       	call   8013ad <read>
		if (m < 0)
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	85 c0                	test   %eax,%eax
  80146d:	78 10                	js     80147f <readn+0x41>
			return m;
		if (m == 0)
  80146f:	85 c0                	test   %eax,%eax
  801471:	74 0a                	je     80147d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801473:	01 c3                	add    %eax,%ebx
  801475:	39 f3                	cmp    %esi,%ebx
  801477:	72 db                	jb     801454 <readn+0x16>
  801479:	89 d8                	mov    %ebx,%eax
  80147b:	eb 02                	jmp    80147f <readn+0x41>
  80147d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80147f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801482:	5b                   	pop    %ebx
  801483:	5e                   	pop    %esi
  801484:	5f                   	pop    %edi
  801485:	5d                   	pop    %ebp
  801486:	c3                   	ret    

00801487 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	53                   	push   %ebx
  80148b:	83 ec 14             	sub    $0x14,%esp
  80148e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801491:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801494:	50                   	push   %eax
  801495:	53                   	push   %ebx
  801496:	e8 ac fc ff ff       	call   801147 <fd_lookup>
  80149b:	83 c4 08             	add    $0x8,%esp
  80149e:	89 c2                	mov    %eax,%edx
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 68                	js     80150c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a4:	83 ec 08             	sub    $0x8,%esp
  8014a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014aa:	50                   	push   %eax
  8014ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ae:	ff 30                	pushl  (%eax)
  8014b0:	e8 e8 fc ff ff       	call   80119d <dev_lookup>
  8014b5:	83 c4 10             	add    $0x10,%esp
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	78 47                	js     801503 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c3:	75 21                	jne    8014e6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c5:	a1 90 67 80 00       	mov    0x806790,%eax
  8014ca:	8b 40 50             	mov    0x50(%eax),%eax
  8014cd:	83 ec 04             	sub    $0x4,%esp
  8014d0:	53                   	push   %ebx
  8014d1:	50                   	push   %eax
  8014d2:	68 89 2b 80 00       	push   $0x802b89
  8014d7:	e8 5c f0 ff ff       	call   800538 <cprintf>
		return -E_INVAL;
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e4:	eb 26                	jmp    80150c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e9:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ec:	85 d2                	test   %edx,%edx
  8014ee:	74 17                	je     801507 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014f0:	83 ec 04             	sub    $0x4,%esp
  8014f3:	ff 75 10             	pushl  0x10(%ebp)
  8014f6:	ff 75 0c             	pushl  0xc(%ebp)
  8014f9:	50                   	push   %eax
  8014fa:	ff d2                	call   *%edx
  8014fc:	89 c2                	mov    %eax,%edx
  8014fe:	83 c4 10             	add    $0x10,%esp
  801501:	eb 09                	jmp    80150c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801503:	89 c2                	mov    %eax,%edx
  801505:	eb 05                	jmp    80150c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801507:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80150c:	89 d0                	mov    %edx,%eax
  80150e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801511:	c9                   	leave  
  801512:	c3                   	ret    

00801513 <seek>:

int
seek(int fdnum, off_t offset)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801519:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80151c:	50                   	push   %eax
  80151d:	ff 75 08             	pushl  0x8(%ebp)
  801520:	e8 22 fc ff ff       	call   801147 <fd_lookup>
  801525:	83 c4 08             	add    $0x8,%esp
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 0e                	js     80153a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80152c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80152f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801532:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801535:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153a:	c9                   	leave  
  80153b:	c3                   	ret    

0080153c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	53                   	push   %ebx
  801540:	83 ec 14             	sub    $0x14,%esp
  801543:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801546:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	53                   	push   %ebx
  80154b:	e8 f7 fb ff ff       	call   801147 <fd_lookup>
  801550:	83 c4 08             	add    $0x8,%esp
  801553:	89 c2                	mov    %eax,%edx
  801555:	85 c0                	test   %eax,%eax
  801557:	78 65                	js     8015be <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801559:	83 ec 08             	sub    $0x8,%esp
  80155c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155f:	50                   	push   %eax
  801560:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801563:	ff 30                	pushl  (%eax)
  801565:	e8 33 fc ff ff       	call   80119d <dev_lookup>
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	85 c0                	test   %eax,%eax
  80156f:	78 44                	js     8015b5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801571:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801574:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801578:	75 21                	jne    80159b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80157a:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80157f:	8b 40 50             	mov    0x50(%eax),%eax
  801582:	83 ec 04             	sub    $0x4,%esp
  801585:	53                   	push   %ebx
  801586:	50                   	push   %eax
  801587:	68 4c 2b 80 00       	push   $0x802b4c
  80158c:	e8 a7 ef ff ff       	call   800538 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801599:	eb 23                	jmp    8015be <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80159b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159e:	8b 52 18             	mov    0x18(%edx),%edx
  8015a1:	85 d2                	test   %edx,%edx
  8015a3:	74 14                	je     8015b9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015a5:	83 ec 08             	sub    $0x8,%esp
  8015a8:	ff 75 0c             	pushl  0xc(%ebp)
  8015ab:	50                   	push   %eax
  8015ac:	ff d2                	call   *%edx
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	eb 09                	jmp    8015be <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b5:	89 c2                	mov    %eax,%edx
  8015b7:	eb 05                	jmp    8015be <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015be:	89 d0                	mov    %edx,%eax
  8015c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c3:	c9                   	leave  
  8015c4:	c3                   	ret    

008015c5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 14             	sub    $0x14,%esp
  8015cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d2:	50                   	push   %eax
  8015d3:	ff 75 08             	pushl  0x8(%ebp)
  8015d6:	e8 6c fb ff ff       	call   801147 <fd_lookup>
  8015db:	83 c4 08             	add    $0x8,%esp
  8015de:	89 c2                	mov    %eax,%edx
  8015e0:	85 c0                	test   %eax,%eax
  8015e2:	78 58                	js     80163c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e4:	83 ec 08             	sub    $0x8,%esp
  8015e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ea:	50                   	push   %eax
  8015eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ee:	ff 30                	pushl  (%eax)
  8015f0:	e8 a8 fb ff ff       	call   80119d <dev_lookup>
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	78 37                	js     801633 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ff:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801603:	74 32                	je     801637 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801605:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801608:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80160f:	00 00 00 
	stat->st_isdir = 0;
  801612:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801619:	00 00 00 
	stat->st_dev = dev;
  80161c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	53                   	push   %ebx
  801626:	ff 75 f0             	pushl  -0x10(%ebp)
  801629:	ff 50 14             	call   *0x14(%eax)
  80162c:	89 c2                	mov    %eax,%edx
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	eb 09                	jmp    80163c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801633:	89 c2                	mov    %eax,%edx
  801635:	eb 05                	jmp    80163c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801637:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80163c:	89 d0                	mov    %edx,%eax
  80163e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801641:	c9                   	leave  
  801642:	c3                   	ret    

00801643 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	56                   	push   %esi
  801647:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	6a 00                	push   $0x0
  80164d:	ff 75 08             	pushl  0x8(%ebp)
  801650:	e8 e3 01 00 00       	call   801838 <open>
  801655:	89 c3                	mov    %eax,%ebx
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	85 c0                	test   %eax,%eax
  80165c:	78 1b                	js     801679 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80165e:	83 ec 08             	sub    $0x8,%esp
  801661:	ff 75 0c             	pushl  0xc(%ebp)
  801664:	50                   	push   %eax
  801665:	e8 5b ff ff ff       	call   8015c5 <fstat>
  80166a:	89 c6                	mov    %eax,%esi
	close(fd);
  80166c:	89 1c 24             	mov    %ebx,(%esp)
  80166f:	e8 fd fb ff ff       	call   801271 <close>
	return r;
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	89 f0                	mov    %esi,%eax
}
  801679:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5e                   	pop    %esi
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	56                   	push   %esi
  801684:	53                   	push   %ebx
  801685:	89 c6                	mov    %eax,%esi
  801687:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801689:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801690:	75 12                	jne    8016a4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801692:	83 ec 0c             	sub    $0xc,%esp
  801695:	6a 01                	push   $0x1
  801697:	e8 a6 0c 00 00       	call   802342 <ipc_find_env>
  80169c:	a3 00 50 80 00       	mov    %eax,0x805000
  8016a1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016a4:	6a 07                	push   $0x7
  8016a6:	68 00 70 80 00       	push   $0x807000
  8016ab:	56                   	push   %esi
  8016ac:	ff 35 00 50 80 00    	pushl  0x805000
  8016b2:	e8 29 0c 00 00       	call   8022e0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016b7:	83 c4 0c             	add    $0xc,%esp
  8016ba:	6a 00                	push   $0x0
  8016bc:	53                   	push   %ebx
  8016bd:	6a 00                	push   $0x0
  8016bf:	e8 a7 0b 00 00       	call   80226b <ipc_recv>
}
  8016c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c7:	5b                   	pop    %ebx
  8016c8:	5e                   	pop    %esi
  8016c9:	5d                   	pop    %ebp
  8016ca:	c3                   	ret    

008016cb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d7:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8016dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016df:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e9:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ee:	e8 8d ff ff ff       	call   801680 <fsipc>
}
  8016f3:	c9                   	leave  
  8016f4:	c3                   	ret    

008016f5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801701:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801706:	ba 00 00 00 00       	mov    $0x0,%edx
  80170b:	b8 06 00 00 00       	mov    $0x6,%eax
  801710:	e8 6b ff ff ff       	call   801680 <fsipc>
}
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	53                   	push   %ebx
  80171b:	83 ec 04             	sub    $0x4,%esp
  80171e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801721:	8b 45 08             	mov    0x8(%ebp),%eax
  801724:	8b 40 0c             	mov    0xc(%eax),%eax
  801727:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80172c:	ba 00 00 00 00       	mov    $0x0,%edx
  801731:	b8 05 00 00 00       	mov    $0x5,%eax
  801736:	e8 45 ff ff ff       	call   801680 <fsipc>
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 2c                	js     80176b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	68 00 70 80 00       	push   $0x807000
  801747:	53                   	push   %ebx
  801748:	e8 70 f3 ff ff       	call   800abd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80174d:	a1 80 70 80 00       	mov    0x807080,%eax
  801752:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801758:	a1 84 70 80 00       	mov    0x807084,%eax
  80175d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	83 ec 0c             	sub    $0xc,%esp
  801776:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801779:	8b 55 08             	mov    0x8(%ebp),%edx
  80177c:	8b 52 0c             	mov    0xc(%edx),%edx
  80177f:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801785:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80178a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80178f:	0f 47 c2             	cmova  %edx,%eax
  801792:	a3 04 70 80 00       	mov    %eax,0x807004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801797:	50                   	push   %eax
  801798:	ff 75 0c             	pushl  0xc(%ebp)
  80179b:	68 08 70 80 00       	push   $0x807008
  8017a0:	e8 aa f4 ff ff       	call   800c4f <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8017a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017aa:	b8 04 00 00 00       	mov    $0x4,%eax
  8017af:	e8 cc fe ff ff       	call   801680 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8017b4:	c9                   	leave  
  8017b5:	c3                   	ret    

008017b6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	56                   	push   %esi
  8017ba:	53                   	push   %ebx
  8017bb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017be:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c4:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8017c9:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d4:	b8 03 00 00 00       	mov    $0x3,%eax
  8017d9:	e8 a2 fe ff ff       	call   801680 <fsipc>
  8017de:	89 c3                	mov    %eax,%ebx
  8017e0:	85 c0                	test   %eax,%eax
  8017e2:	78 4b                	js     80182f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017e4:	39 c6                	cmp    %eax,%esi
  8017e6:	73 16                	jae    8017fe <devfile_read+0x48>
  8017e8:	68 b8 2b 80 00       	push   $0x802bb8
  8017ed:	68 bf 2b 80 00       	push   $0x802bbf
  8017f2:	6a 7c                	push   $0x7c
  8017f4:	68 d4 2b 80 00       	push   $0x802bd4
  8017f9:	e8 61 ec ff ff       	call   80045f <_panic>
	assert(r <= PGSIZE);
  8017fe:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801803:	7e 16                	jle    80181b <devfile_read+0x65>
  801805:	68 df 2b 80 00       	push   $0x802bdf
  80180a:	68 bf 2b 80 00       	push   $0x802bbf
  80180f:	6a 7d                	push   $0x7d
  801811:	68 d4 2b 80 00       	push   $0x802bd4
  801816:	e8 44 ec ff ff       	call   80045f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80181b:	83 ec 04             	sub    $0x4,%esp
  80181e:	50                   	push   %eax
  80181f:	68 00 70 80 00       	push   $0x807000
  801824:	ff 75 0c             	pushl  0xc(%ebp)
  801827:	e8 23 f4 ff ff       	call   800c4f <memmove>
	return r;
  80182c:	83 c4 10             	add    $0x10,%esp
}
  80182f:	89 d8                	mov    %ebx,%eax
  801831:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801834:	5b                   	pop    %ebx
  801835:	5e                   	pop    %esi
  801836:	5d                   	pop    %ebp
  801837:	c3                   	ret    

00801838 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	53                   	push   %ebx
  80183c:	83 ec 20             	sub    $0x20,%esp
  80183f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801842:	53                   	push   %ebx
  801843:	e8 3c f2 ff ff       	call   800a84 <strlen>
  801848:	83 c4 10             	add    $0x10,%esp
  80184b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801850:	7f 67                	jg     8018b9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801858:	50                   	push   %eax
  801859:	e8 9a f8 ff ff       	call   8010f8 <fd_alloc>
  80185e:	83 c4 10             	add    $0x10,%esp
		return r;
  801861:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801863:	85 c0                	test   %eax,%eax
  801865:	78 57                	js     8018be <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	53                   	push   %ebx
  80186b:	68 00 70 80 00       	push   $0x807000
  801870:	e8 48 f2 ff ff       	call   800abd <strcpy>
	fsipcbuf.open.req_omode = mode;
  801875:	8b 45 0c             	mov    0xc(%ebp),%eax
  801878:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80187d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801880:	b8 01 00 00 00       	mov    $0x1,%eax
  801885:	e8 f6 fd ff ff       	call   801680 <fsipc>
  80188a:	89 c3                	mov    %eax,%ebx
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	85 c0                	test   %eax,%eax
  801891:	79 14                	jns    8018a7 <open+0x6f>
		fd_close(fd, 0);
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	6a 00                	push   $0x0
  801898:	ff 75 f4             	pushl  -0xc(%ebp)
  80189b:	e8 50 f9 ff ff       	call   8011f0 <fd_close>
		return r;
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	89 da                	mov    %ebx,%edx
  8018a5:	eb 17                	jmp    8018be <open+0x86>
	}

	return fd2num(fd);
  8018a7:	83 ec 0c             	sub    $0xc,%esp
  8018aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ad:	e8 1f f8 ff ff       	call   8010d1 <fd2num>
  8018b2:	89 c2                	mov    %eax,%edx
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	eb 05                	jmp    8018be <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018b9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018be:	89 d0                	mov    %edx,%eax
  8018c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d5:	e8 a6 fd ff ff       	call   801680 <fsipc>
}
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	57                   	push   %edi
  8018e0:	56                   	push   %esi
  8018e1:	53                   	push   %ebx
  8018e2:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018e8:	6a 00                	push   $0x0
  8018ea:	ff 75 08             	pushl  0x8(%ebp)
  8018ed:	e8 46 ff ff ff       	call   801838 <open>
  8018f2:	89 c7                	mov    %eax,%edi
  8018f4:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	0f 88 89 04 00 00    	js     801d8e <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801905:	83 ec 04             	sub    $0x4,%esp
  801908:	68 00 02 00 00       	push   $0x200
  80190d:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801913:	50                   	push   %eax
  801914:	57                   	push   %edi
  801915:	e8 24 fb ff ff       	call   80143e <readn>
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	3d 00 02 00 00       	cmp    $0x200,%eax
  801922:	75 0c                	jne    801930 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801924:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80192b:	45 4c 46 
  80192e:	74 33                	je     801963 <spawn+0x87>
		close(fd);
  801930:	83 ec 0c             	sub    $0xc,%esp
  801933:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801939:	e8 33 f9 ff ff       	call   801271 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80193e:	83 c4 0c             	add    $0xc,%esp
  801941:	68 7f 45 4c 46       	push   $0x464c457f
  801946:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80194c:	68 eb 2b 80 00       	push   $0x802beb
  801951:	e8 e2 eb ff ff       	call   800538 <cprintf>
		return -E_NOT_EXEC;
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  80195e:	e9 de 04 00 00       	jmp    801e41 <spawn+0x565>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801963:	b8 07 00 00 00       	mov    $0x7,%eax
  801968:	cd 30                	int    $0x30
  80196a:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801970:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801976:	85 c0                	test   %eax,%eax
  801978:	0f 88 1b 04 00 00    	js     801d99 <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80197e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801983:	89 c2                	mov    %eax,%edx
  801985:	c1 e2 07             	shl    $0x7,%edx
  801988:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80198e:	8d b4 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%esi
  801995:	b9 11 00 00 00       	mov    $0x11,%ecx
  80199a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80199c:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019a2:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019a8:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8019ad:	be 00 00 00 00       	mov    $0x0,%esi
  8019b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019b5:	eb 13                	jmp    8019ca <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8019b7:	83 ec 0c             	sub    $0xc,%esp
  8019ba:	50                   	push   %eax
  8019bb:	e8 c4 f0 ff ff       	call   800a84 <strlen>
  8019c0:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019c4:	83 c3 01             	add    $0x1,%ebx
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019d1:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	75 df                	jne    8019b7 <spawn+0xdb>
  8019d8:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019de:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019e4:	bf 00 10 40 00       	mov    $0x401000,%edi
  8019e9:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019eb:	89 fa                	mov    %edi,%edx
  8019ed:	83 e2 fc             	and    $0xfffffffc,%edx
  8019f0:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019f7:	29 c2                	sub    %eax,%edx
  8019f9:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019ff:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a02:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a07:	0f 86 a2 03 00 00    	jbe    801daf <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a0d:	83 ec 04             	sub    $0x4,%esp
  801a10:	6a 07                	push   $0x7
  801a12:	68 00 00 40 00       	push   $0x400000
  801a17:	6a 00                	push   $0x0
  801a19:	e8 a2 f4 ff ff       	call   800ec0 <sys_page_alloc>
  801a1e:	83 c4 10             	add    $0x10,%esp
  801a21:	85 c0                	test   %eax,%eax
  801a23:	0f 88 90 03 00 00    	js     801db9 <spawn+0x4dd>
  801a29:	be 00 00 00 00       	mov    $0x0,%esi
  801a2e:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a37:	eb 30                	jmp    801a69 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a39:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a3f:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801a45:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801a48:	83 ec 08             	sub    $0x8,%esp
  801a4b:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a4e:	57                   	push   %edi
  801a4f:	e8 69 f0 ff ff       	call   800abd <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a54:	83 c4 04             	add    $0x4,%esp
  801a57:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a5a:	e8 25 f0 ff ff       	call   800a84 <strlen>
  801a5f:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a63:	83 c6 01             	add    $0x1,%esi
  801a66:	83 c4 10             	add    $0x10,%esp
  801a69:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a6f:	7f c8                	jg     801a39 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a71:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a77:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a7d:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a84:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a8a:	74 19                	je     801aa5 <spawn+0x1c9>
  801a8c:	68 78 2c 80 00       	push   $0x802c78
  801a91:	68 bf 2b 80 00       	push   $0x802bbf
  801a96:	68 f2 00 00 00       	push   $0xf2
  801a9b:	68 05 2c 80 00       	push   $0x802c05
  801aa0:	e8 ba e9 ff ff       	call   80045f <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801aa5:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801aab:	89 f8                	mov    %edi,%eax
  801aad:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801ab2:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801ab5:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801abb:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801abe:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801ac4:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801aca:	83 ec 0c             	sub    $0xc,%esp
  801acd:	6a 07                	push   $0x7
  801acf:	68 00 d0 bf ee       	push   $0xeebfd000
  801ad4:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ada:	68 00 00 40 00       	push   $0x400000
  801adf:	6a 00                	push   $0x0
  801ae1:	e8 1d f4 ff ff       	call   800f03 <sys_page_map>
  801ae6:	89 c3                	mov    %eax,%ebx
  801ae8:	83 c4 20             	add    $0x20,%esp
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	0f 88 3c 03 00 00    	js     801e2f <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801af3:	83 ec 08             	sub    $0x8,%esp
  801af6:	68 00 00 40 00       	push   $0x400000
  801afb:	6a 00                	push   $0x0
  801afd:	e8 43 f4 ff ff       	call   800f45 <sys_page_unmap>
  801b02:	89 c3                	mov    %eax,%ebx
  801b04:	83 c4 10             	add    $0x10,%esp
  801b07:	85 c0                	test   %eax,%eax
  801b09:	0f 88 20 03 00 00    	js     801e2f <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b0f:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b15:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b1c:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b22:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b29:	00 00 00 
  801b2c:	e9 88 01 00 00       	jmp    801cb9 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801b31:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b37:	83 38 01             	cmpl   $0x1,(%eax)
  801b3a:	0f 85 6b 01 00 00    	jne    801cab <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b40:	89 c2                	mov    %eax,%edx
  801b42:	8b 40 18             	mov    0x18(%eax),%eax
  801b45:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b4b:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b4e:	83 f8 01             	cmp    $0x1,%eax
  801b51:	19 c0                	sbb    %eax,%eax
  801b53:	83 e0 fe             	and    $0xfffffffe,%eax
  801b56:	83 c0 07             	add    $0x7,%eax
  801b59:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b5f:	89 d0                	mov    %edx,%eax
  801b61:	8b 7a 04             	mov    0x4(%edx),%edi
  801b64:	89 f9                	mov    %edi,%ecx
  801b66:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b6c:	8b 7a 10             	mov    0x10(%edx),%edi
  801b6f:	8b 52 14             	mov    0x14(%edx),%edx
  801b72:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801b78:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b7b:	89 f0                	mov    %esi,%eax
  801b7d:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b82:	74 14                	je     801b98 <spawn+0x2bc>
		va -= i;
  801b84:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b86:	01 c2                	add    %eax,%edx
  801b88:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801b8e:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b90:	29 c1                	sub    %eax,%ecx
  801b92:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b98:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b9d:	e9 f7 00 00 00       	jmp    801c99 <spawn+0x3bd>
		if (i >= filesz) {
  801ba2:	39 fb                	cmp    %edi,%ebx
  801ba4:	72 27                	jb     801bcd <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801ba6:	83 ec 04             	sub    $0x4,%esp
  801ba9:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801baf:	56                   	push   %esi
  801bb0:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801bb6:	e8 05 f3 ff ff       	call   800ec0 <sys_page_alloc>
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	0f 89 c7 00 00 00    	jns    801c8d <spawn+0x3b1>
  801bc6:	89 c3                	mov    %eax,%ebx
  801bc8:	e9 fd 01 00 00       	jmp    801dca <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bcd:	83 ec 04             	sub    $0x4,%esp
  801bd0:	6a 07                	push   $0x7
  801bd2:	68 00 00 40 00       	push   $0x400000
  801bd7:	6a 00                	push   $0x0
  801bd9:	e8 e2 f2 ff ff       	call   800ec0 <sys_page_alloc>
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	85 c0                	test   %eax,%eax
  801be3:	0f 88 d7 01 00 00    	js     801dc0 <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801be9:	83 ec 08             	sub    $0x8,%esp
  801bec:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bf2:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801bf8:	50                   	push   %eax
  801bf9:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bff:	e8 0f f9 ff ff       	call   801513 <seek>
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	85 c0                	test   %eax,%eax
  801c09:	0f 88 b5 01 00 00    	js     801dc4 <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c0f:	83 ec 04             	sub    $0x4,%esp
  801c12:	89 f8                	mov    %edi,%eax
  801c14:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c1a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c1f:	ba 00 10 00 00       	mov    $0x1000,%edx
  801c24:	0f 47 c2             	cmova  %edx,%eax
  801c27:	50                   	push   %eax
  801c28:	68 00 00 40 00       	push   $0x400000
  801c2d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c33:	e8 06 f8 ff ff       	call   80143e <readn>
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	0f 88 85 01 00 00    	js     801dc8 <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c43:	83 ec 0c             	sub    $0xc,%esp
  801c46:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c4c:	56                   	push   %esi
  801c4d:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c53:	68 00 00 40 00       	push   $0x400000
  801c58:	6a 00                	push   $0x0
  801c5a:	e8 a4 f2 ff ff       	call   800f03 <sys_page_map>
  801c5f:	83 c4 20             	add    $0x20,%esp
  801c62:	85 c0                	test   %eax,%eax
  801c64:	79 15                	jns    801c7b <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801c66:	50                   	push   %eax
  801c67:	68 11 2c 80 00       	push   $0x802c11
  801c6c:	68 25 01 00 00       	push   $0x125
  801c71:	68 05 2c 80 00       	push   $0x802c05
  801c76:	e8 e4 e7 ff ff       	call   80045f <_panic>
			sys_page_unmap(0, UTEMP);
  801c7b:	83 ec 08             	sub    $0x8,%esp
  801c7e:	68 00 00 40 00       	push   $0x400000
  801c83:	6a 00                	push   $0x0
  801c85:	e8 bb f2 ff ff       	call   800f45 <sys_page_unmap>
  801c8a:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c8d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c93:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c99:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c9f:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801ca5:	0f 82 f7 fe ff ff    	jb     801ba2 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801cab:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801cb2:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801cb9:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801cc0:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801cc6:	0f 8c 65 fe ff ff    	jl     801b31 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801ccc:	83 ec 0c             	sub    $0xc,%esp
  801ccf:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cd5:	e8 97 f5 ff ff       	call   801271 <close>
  801cda:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801cdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ce2:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801ce8:	89 d8                	mov    %ebx,%eax
  801cea:	c1 e8 16             	shr    $0x16,%eax
  801ced:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cf4:	a8 01                	test   $0x1,%al
  801cf6:	74 42                	je     801d3a <spawn+0x45e>
  801cf8:	89 d8                	mov    %ebx,%eax
  801cfa:	c1 e8 0c             	shr    $0xc,%eax
  801cfd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d04:	f6 c2 01             	test   $0x1,%dl
  801d07:	74 31                	je     801d3a <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801d09:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801d10:	f6 c6 04             	test   $0x4,%dh
  801d13:	74 25                	je     801d3a <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801d15:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d1c:	83 ec 0c             	sub    $0xc,%esp
  801d1f:	25 07 0e 00 00       	and    $0xe07,%eax
  801d24:	50                   	push   %eax
  801d25:	53                   	push   %ebx
  801d26:	56                   	push   %esi
  801d27:	53                   	push   %ebx
  801d28:	6a 00                	push   $0x0
  801d2a:	e8 d4 f1 ff ff       	call   800f03 <sys_page_map>
			if (r < 0) {
  801d2f:	83 c4 20             	add    $0x20,%esp
  801d32:	85 c0                	test   %eax,%eax
  801d34:	0f 88 b1 00 00 00    	js     801deb <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801d3a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d40:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801d46:	75 a0                	jne    801ce8 <spawn+0x40c>
  801d48:	e9 b3 00 00 00       	jmp    801e00 <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801d4d:	50                   	push   %eax
  801d4e:	68 2e 2c 80 00       	push   $0x802c2e
  801d53:	68 86 00 00 00       	push   $0x86
  801d58:	68 05 2c 80 00       	push   $0x802c05
  801d5d:	e8 fd e6 ff ff       	call   80045f <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d62:	83 ec 08             	sub    $0x8,%esp
  801d65:	6a 02                	push   $0x2
  801d67:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d6d:	e8 15 f2 ff ff       	call   800f87 <sys_env_set_status>
  801d72:	83 c4 10             	add    $0x10,%esp
  801d75:	85 c0                	test   %eax,%eax
  801d77:	79 2b                	jns    801da4 <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  801d79:	50                   	push   %eax
  801d7a:	68 48 2c 80 00       	push   $0x802c48
  801d7f:	68 89 00 00 00       	push   $0x89
  801d84:	68 05 2c 80 00       	push   $0x802c05
  801d89:	e8 d1 e6 ff ff       	call   80045f <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d8e:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d94:	e9 a8 00 00 00       	jmp    801e41 <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d99:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d9f:	e9 9d 00 00 00       	jmp    801e41 <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801da4:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801daa:	e9 92 00 00 00       	jmp    801e41 <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801daf:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801db4:	e9 88 00 00 00       	jmp    801e41 <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801db9:	89 c3                	mov    %eax,%ebx
  801dbb:	e9 81 00 00 00       	jmp    801e41 <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801dc0:	89 c3                	mov    %eax,%ebx
  801dc2:	eb 06                	jmp    801dca <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801dc4:	89 c3                	mov    %eax,%ebx
  801dc6:	eb 02                	jmp    801dca <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801dc8:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801dca:	83 ec 0c             	sub    $0xc,%esp
  801dcd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dd3:	e8 69 f0 ff ff       	call   800e41 <sys_env_destroy>
	close(fd);
  801dd8:	83 c4 04             	add    $0x4,%esp
  801ddb:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801de1:	e8 8b f4 ff ff       	call   801271 <close>
	return r;
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	eb 56                	jmp    801e41 <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801deb:	50                   	push   %eax
  801dec:	68 5f 2c 80 00       	push   $0x802c5f
  801df1:	68 82 00 00 00       	push   $0x82
  801df6:	68 05 2c 80 00       	push   $0x802c05
  801dfb:	e8 5f e6 ff ff       	call   80045f <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e00:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e07:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e0a:	83 ec 08             	sub    $0x8,%esp
  801e0d:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e13:	50                   	push   %eax
  801e14:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e1a:	e8 aa f1 ff ff       	call   800fc9 <sys_env_set_trapframe>
  801e1f:	83 c4 10             	add    $0x10,%esp
  801e22:	85 c0                	test   %eax,%eax
  801e24:	0f 89 38 ff ff ff    	jns    801d62 <spawn+0x486>
  801e2a:	e9 1e ff ff ff       	jmp    801d4d <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e2f:	83 ec 08             	sub    $0x8,%esp
  801e32:	68 00 00 40 00       	push   $0x400000
  801e37:	6a 00                	push   $0x0
  801e39:	e8 07 f1 ff ff       	call   800f45 <sys_page_unmap>
  801e3e:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e41:	89 d8                	mov    %ebx,%eax
  801e43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e46:	5b                   	pop    %ebx
  801e47:	5e                   	pop    %esi
  801e48:	5f                   	pop    %edi
  801e49:	5d                   	pop    %ebp
  801e4a:	c3                   	ret    

00801e4b <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	56                   	push   %esi
  801e4f:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e50:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e53:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e58:	eb 03                	jmp    801e5d <spawnl+0x12>
		argc++;
  801e5a:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e5d:	83 c2 04             	add    $0x4,%edx
  801e60:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e64:	75 f4                	jne    801e5a <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e66:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e6d:	83 e2 f0             	and    $0xfffffff0,%edx
  801e70:	29 d4                	sub    %edx,%esp
  801e72:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e76:	c1 ea 02             	shr    $0x2,%edx
  801e79:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e80:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e85:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e8c:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e93:	00 
  801e94:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e96:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9b:	eb 0a                	jmp    801ea7 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e9d:	83 c0 01             	add    $0x1,%eax
  801ea0:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ea4:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ea7:	39 d0                	cmp    %edx,%eax
  801ea9:	75 f2                	jne    801e9d <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801eab:	83 ec 08             	sub    $0x8,%esp
  801eae:	56                   	push   %esi
  801eaf:	ff 75 08             	pushl  0x8(%ebp)
  801eb2:	e8 25 fa ff ff       	call   8018dc <spawn>
}
  801eb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eba:	5b                   	pop    %ebx
  801ebb:	5e                   	pop    %esi
  801ebc:	5d                   	pop    %ebp
  801ebd:	c3                   	ret    

00801ebe <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	56                   	push   %esi
  801ec2:	53                   	push   %ebx
  801ec3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ec6:	83 ec 0c             	sub    $0xc,%esp
  801ec9:	ff 75 08             	pushl  0x8(%ebp)
  801ecc:	e8 10 f2 ff ff       	call   8010e1 <fd2data>
  801ed1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ed3:	83 c4 08             	add    $0x8,%esp
  801ed6:	68 a0 2c 80 00       	push   $0x802ca0
  801edb:	53                   	push   %ebx
  801edc:	e8 dc eb ff ff       	call   800abd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ee1:	8b 46 04             	mov    0x4(%esi),%eax
  801ee4:	2b 06                	sub    (%esi),%eax
  801ee6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801eec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ef3:	00 00 00 
	stat->st_dev = &devpipe;
  801ef6:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801efd:	47 80 00 
	return 0;
}
  801f00:	b8 00 00 00 00       	mov    $0x0,%eax
  801f05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f08:	5b                   	pop    %ebx
  801f09:	5e                   	pop    %esi
  801f0a:	5d                   	pop    %ebp
  801f0b:	c3                   	ret    

00801f0c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	53                   	push   %ebx
  801f10:	83 ec 0c             	sub    $0xc,%esp
  801f13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f16:	53                   	push   %ebx
  801f17:	6a 00                	push   $0x0
  801f19:	e8 27 f0 ff ff       	call   800f45 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f1e:	89 1c 24             	mov    %ebx,(%esp)
  801f21:	e8 bb f1 ff ff       	call   8010e1 <fd2data>
  801f26:	83 c4 08             	add    $0x8,%esp
  801f29:	50                   	push   %eax
  801f2a:	6a 00                	push   $0x0
  801f2c:	e8 14 f0 ff ff       	call   800f45 <sys_page_unmap>
}
  801f31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f34:	c9                   	leave  
  801f35:	c3                   	ret    

00801f36 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f36:	55                   	push   %ebp
  801f37:	89 e5                	mov    %esp,%ebp
  801f39:	57                   	push   %edi
  801f3a:	56                   	push   %esi
  801f3b:	53                   	push   %ebx
  801f3c:	83 ec 1c             	sub    $0x1c,%esp
  801f3f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f42:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f44:	a1 90 67 80 00       	mov    0x806790,%eax
  801f49:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f4c:	83 ec 0c             	sub    $0xc,%esp
  801f4f:	ff 75 e0             	pushl  -0x20(%ebp)
  801f52:	e8 2b 04 00 00       	call   802382 <pageref>
  801f57:	89 c3                	mov    %eax,%ebx
  801f59:	89 3c 24             	mov    %edi,(%esp)
  801f5c:	e8 21 04 00 00       	call   802382 <pageref>
  801f61:	83 c4 10             	add    $0x10,%esp
  801f64:	39 c3                	cmp    %eax,%ebx
  801f66:	0f 94 c1             	sete   %cl
  801f69:	0f b6 c9             	movzbl %cl,%ecx
  801f6c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f6f:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801f75:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801f78:	39 ce                	cmp    %ecx,%esi
  801f7a:	74 1b                	je     801f97 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f7c:	39 c3                	cmp    %eax,%ebx
  801f7e:	75 c4                	jne    801f44 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f80:	8b 42 60             	mov    0x60(%edx),%eax
  801f83:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f86:	50                   	push   %eax
  801f87:	56                   	push   %esi
  801f88:	68 a7 2c 80 00       	push   $0x802ca7
  801f8d:	e8 a6 e5 ff ff       	call   800538 <cprintf>
  801f92:	83 c4 10             	add    $0x10,%esp
  801f95:	eb ad                	jmp    801f44 <_pipeisclosed+0xe>
	}
}
  801f97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9d:	5b                   	pop    %ebx
  801f9e:	5e                   	pop    %esi
  801f9f:	5f                   	pop    %edi
  801fa0:	5d                   	pop    %ebp
  801fa1:	c3                   	ret    

00801fa2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	57                   	push   %edi
  801fa6:	56                   	push   %esi
  801fa7:	53                   	push   %ebx
  801fa8:	83 ec 28             	sub    $0x28,%esp
  801fab:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fae:	56                   	push   %esi
  801faf:	e8 2d f1 ff ff       	call   8010e1 <fd2data>
  801fb4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb6:	83 c4 10             	add    $0x10,%esp
  801fb9:	bf 00 00 00 00       	mov    $0x0,%edi
  801fbe:	eb 4b                	jmp    80200b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fc0:	89 da                	mov    %ebx,%edx
  801fc2:	89 f0                	mov    %esi,%eax
  801fc4:	e8 6d ff ff ff       	call   801f36 <_pipeisclosed>
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	75 48                	jne    802015 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fcd:	e8 cf ee ff ff       	call   800ea1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fd2:	8b 43 04             	mov    0x4(%ebx),%eax
  801fd5:	8b 0b                	mov    (%ebx),%ecx
  801fd7:	8d 51 20             	lea    0x20(%ecx),%edx
  801fda:	39 d0                	cmp    %edx,%eax
  801fdc:	73 e2                	jae    801fc0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fe1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fe5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fe8:	89 c2                	mov    %eax,%edx
  801fea:	c1 fa 1f             	sar    $0x1f,%edx
  801fed:	89 d1                	mov    %edx,%ecx
  801fef:	c1 e9 1b             	shr    $0x1b,%ecx
  801ff2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ff5:	83 e2 1f             	and    $0x1f,%edx
  801ff8:	29 ca                	sub    %ecx,%edx
  801ffa:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ffe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802002:	83 c0 01             	add    $0x1,%eax
  802005:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802008:	83 c7 01             	add    $0x1,%edi
  80200b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80200e:	75 c2                	jne    801fd2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802010:	8b 45 10             	mov    0x10(%ebp),%eax
  802013:	eb 05                	jmp    80201a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802015:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80201a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80201d:	5b                   	pop    %ebx
  80201e:	5e                   	pop    %esi
  80201f:	5f                   	pop    %edi
  802020:	5d                   	pop    %ebp
  802021:	c3                   	ret    

00802022 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	57                   	push   %edi
  802026:	56                   	push   %esi
  802027:	53                   	push   %ebx
  802028:	83 ec 18             	sub    $0x18,%esp
  80202b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80202e:	57                   	push   %edi
  80202f:	e8 ad f0 ff ff       	call   8010e1 <fd2data>
  802034:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802036:	83 c4 10             	add    $0x10,%esp
  802039:	bb 00 00 00 00       	mov    $0x0,%ebx
  80203e:	eb 3d                	jmp    80207d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802040:	85 db                	test   %ebx,%ebx
  802042:	74 04                	je     802048 <devpipe_read+0x26>
				return i;
  802044:	89 d8                	mov    %ebx,%eax
  802046:	eb 44                	jmp    80208c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802048:	89 f2                	mov    %esi,%edx
  80204a:	89 f8                	mov    %edi,%eax
  80204c:	e8 e5 fe ff ff       	call   801f36 <_pipeisclosed>
  802051:	85 c0                	test   %eax,%eax
  802053:	75 32                	jne    802087 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802055:	e8 47 ee ff ff       	call   800ea1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80205a:	8b 06                	mov    (%esi),%eax
  80205c:	3b 46 04             	cmp    0x4(%esi),%eax
  80205f:	74 df                	je     802040 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802061:	99                   	cltd   
  802062:	c1 ea 1b             	shr    $0x1b,%edx
  802065:	01 d0                	add    %edx,%eax
  802067:	83 e0 1f             	and    $0x1f,%eax
  80206a:	29 d0                	sub    %edx,%eax
  80206c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802071:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802074:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802077:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80207a:	83 c3 01             	add    $0x1,%ebx
  80207d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802080:	75 d8                	jne    80205a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802082:	8b 45 10             	mov    0x10(%ebp),%eax
  802085:	eb 05                	jmp    80208c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802087:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80208c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    

00802094 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	56                   	push   %esi
  802098:	53                   	push   %ebx
  802099:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80209c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209f:	50                   	push   %eax
  8020a0:	e8 53 f0 ff ff       	call   8010f8 <fd_alloc>
  8020a5:	83 c4 10             	add    $0x10,%esp
  8020a8:	89 c2                	mov    %eax,%edx
  8020aa:	85 c0                	test   %eax,%eax
  8020ac:	0f 88 2c 01 00 00    	js     8021de <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b2:	83 ec 04             	sub    $0x4,%esp
  8020b5:	68 07 04 00 00       	push   $0x407
  8020ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8020bd:	6a 00                	push   $0x0
  8020bf:	e8 fc ed ff ff       	call   800ec0 <sys_page_alloc>
  8020c4:	83 c4 10             	add    $0x10,%esp
  8020c7:	89 c2                	mov    %eax,%edx
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	0f 88 0d 01 00 00    	js     8021de <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020d1:	83 ec 0c             	sub    $0xc,%esp
  8020d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020d7:	50                   	push   %eax
  8020d8:	e8 1b f0 ff ff       	call   8010f8 <fd_alloc>
  8020dd:	89 c3                	mov    %eax,%ebx
  8020df:	83 c4 10             	add    $0x10,%esp
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	0f 88 e2 00 00 00    	js     8021cc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ea:	83 ec 04             	sub    $0x4,%esp
  8020ed:	68 07 04 00 00       	push   $0x407
  8020f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f5:	6a 00                	push   $0x0
  8020f7:	e8 c4 ed ff ff       	call   800ec0 <sys_page_alloc>
  8020fc:	89 c3                	mov    %eax,%ebx
  8020fe:	83 c4 10             	add    $0x10,%esp
  802101:	85 c0                	test   %eax,%eax
  802103:	0f 88 c3 00 00 00    	js     8021cc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802109:	83 ec 0c             	sub    $0xc,%esp
  80210c:	ff 75 f4             	pushl  -0xc(%ebp)
  80210f:	e8 cd ef ff ff       	call   8010e1 <fd2data>
  802114:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802116:	83 c4 0c             	add    $0xc,%esp
  802119:	68 07 04 00 00       	push   $0x407
  80211e:	50                   	push   %eax
  80211f:	6a 00                	push   $0x0
  802121:	e8 9a ed ff ff       	call   800ec0 <sys_page_alloc>
  802126:	89 c3                	mov    %eax,%ebx
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	85 c0                	test   %eax,%eax
  80212d:	0f 88 89 00 00 00    	js     8021bc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802133:	83 ec 0c             	sub    $0xc,%esp
  802136:	ff 75 f0             	pushl  -0x10(%ebp)
  802139:	e8 a3 ef ff ff       	call   8010e1 <fd2data>
  80213e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802145:	50                   	push   %eax
  802146:	6a 00                	push   $0x0
  802148:	56                   	push   %esi
  802149:	6a 00                	push   $0x0
  80214b:	e8 b3 ed ff ff       	call   800f03 <sys_page_map>
  802150:	89 c3                	mov    %eax,%ebx
  802152:	83 c4 20             	add    $0x20,%esp
  802155:	85 c0                	test   %eax,%eax
  802157:	78 55                	js     8021ae <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802159:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  80215f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802162:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802167:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80216e:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802174:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802177:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802179:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80217c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802183:	83 ec 0c             	sub    $0xc,%esp
  802186:	ff 75 f4             	pushl  -0xc(%ebp)
  802189:	e8 43 ef ff ff       	call   8010d1 <fd2num>
  80218e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802191:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802193:	83 c4 04             	add    $0x4,%esp
  802196:	ff 75 f0             	pushl  -0x10(%ebp)
  802199:	e8 33 ef ff ff       	call   8010d1 <fd2num>
  80219e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021a1:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8021a4:	83 c4 10             	add    $0x10,%esp
  8021a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8021ac:	eb 30                	jmp    8021de <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021ae:	83 ec 08             	sub    $0x8,%esp
  8021b1:	56                   	push   %esi
  8021b2:	6a 00                	push   $0x0
  8021b4:	e8 8c ed ff ff       	call   800f45 <sys_page_unmap>
  8021b9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021bc:	83 ec 08             	sub    $0x8,%esp
  8021bf:	ff 75 f0             	pushl  -0x10(%ebp)
  8021c2:	6a 00                	push   $0x0
  8021c4:	e8 7c ed ff ff       	call   800f45 <sys_page_unmap>
  8021c9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021cc:	83 ec 08             	sub    $0x8,%esp
  8021cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8021d2:	6a 00                	push   $0x0
  8021d4:	e8 6c ed ff ff       	call   800f45 <sys_page_unmap>
  8021d9:	83 c4 10             	add    $0x10,%esp
  8021dc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021de:	89 d0                	mov    %edx,%eax
  8021e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021e3:	5b                   	pop    %ebx
  8021e4:	5e                   	pop    %esi
  8021e5:	5d                   	pop    %ebp
  8021e6:	c3                   	ret    

008021e7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021e7:	55                   	push   %ebp
  8021e8:	89 e5                	mov    %esp,%ebp
  8021ea:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021f0:	50                   	push   %eax
  8021f1:	ff 75 08             	pushl  0x8(%ebp)
  8021f4:	e8 4e ef ff ff       	call   801147 <fd_lookup>
  8021f9:	83 c4 10             	add    $0x10,%esp
  8021fc:	85 c0                	test   %eax,%eax
  8021fe:	78 18                	js     802218 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802200:	83 ec 0c             	sub    $0xc,%esp
  802203:	ff 75 f4             	pushl  -0xc(%ebp)
  802206:	e8 d6 ee ff ff       	call   8010e1 <fd2data>
	return _pipeisclosed(fd, p);
  80220b:	89 c2                	mov    %eax,%edx
  80220d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802210:	e8 21 fd ff ff       	call   801f36 <_pipeisclosed>
  802215:	83 c4 10             	add    $0x10,%esp
}
  802218:	c9                   	leave  
  802219:	c3                   	ret    

0080221a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80221a:	55                   	push   %ebp
  80221b:	89 e5                	mov    %esp,%ebp
  80221d:	56                   	push   %esi
  80221e:	53                   	push   %ebx
  80221f:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802222:	85 f6                	test   %esi,%esi
  802224:	75 16                	jne    80223c <wait+0x22>
  802226:	68 bf 2c 80 00       	push   $0x802cbf
  80222b:	68 bf 2b 80 00       	push   $0x802bbf
  802230:	6a 09                	push   $0x9
  802232:	68 ca 2c 80 00       	push   $0x802cca
  802237:	e8 23 e2 ff ff       	call   80045f <_panic>
	e = &envs[ENVX(envid)];
  80223c:	89 f0                	mov    %esi,%eax
  80223e:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802243:	89 c2                	mov    %eax,%edx
  802245:	c1 e2 07             	shl    $0x7,%edx
  802248:	8d 9c 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%ebx
  80224f:	eb 05                	jmp    802256 <wait+0x3c>
		sys_yield();
  802251:	e8 4b ec ff ff       	call   800ea1 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802256:	8b 43 50             	mov    0x50(%ebx),%eax
  802259:	39 c6                	cmp    %eax,%esi
  80225b:	75 07                	jne    802264 <wait+0x4a>
  80225d:	8b 43 5c             	mov    0x5c(%ebx),%eax
  802260:	85 c0                	test   %eax,%eax
  802262:	75 ed                	jne    802251 <wait+0x37>
		sys_yield();
}
  802264:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5d                   	pop    %ebp
  80226a:	c3                   	ret    

0080226b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80226b:	55                   	push   %ebp
  80226c:	89 e5                	mov    %esp,%ebp
  80226e:	56                   	push   %esi
  80226f:	53                   	push   %ebx
  802270:	8b 75 08             	mov    0x8(%ebp),%esi
  802273:	8b 45 0c             	mov    0xc(%ebp),%eax
  802276:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802279:	85 c0                	test   %eax,%eax
  80227b:	75 12                	jne    80228f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80227d:	83 ec 0c             	sub    $0xc,%esp
  802280:	68 00 00 c0 ee       	push   $0xeec00000
  802285:	e8 e6 ed ff ff       	call   801070 <sys_ipc_recv>
  80228a:	83 c4 10             	add    $0x10,%esp
  80228d:	eb 0c                	jmp    80229b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80228f:	83 ec 0c             	sub    $0xc,%esp
  802292:	50                   	push   %eax
  802293:	e8 d8 ed ff ff       	call   801070 <sys_ipc_recv>
  802298:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80229b:	85 f6                	test   %esi,%esi
  80229d:	0f 95 c1             	setne  %cl
  8022a0:	85 db                	test   %ebx,%ebx
  8022a2:	0f 95 c2             	setne  %dl
  8022a5:	84 d1                	test   %dl,%cl
  8022a7:	74 09                	je     8022b2 <ipc_recv+0x47>
  8022a9:	89 c2                	mov    %eax,%edx
  8022ab:	c1 ea 1f             	shr    $0x1f,%edx
  8022ae:	84 d2                	test   %dl,%dl
  8022b0:	75 27                	jne    8022d9 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8022b2:	85 f6                	test   %esi,%esi
  8022b4:	74 0a                	je     8022c0 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  8022b6:	a1 90 67 80 00       	mov    0x806790,%eax
  8022bb:	8b 40 7c             	mov    0x7c(%eax),%eax
  8022be:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8022c0:	85 db                	test   %ebx,%ebx
  8022c2:	74 0d                	je     8022d1 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  8022c4:	a1 90 67 80 00       	mov    0x806790,%eax
  8022c9:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8022cf:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8022d1:	a1 90 67 80 00       	mov    0x806790,%eax
  8022d6:	8b 40 78             	mov    0x78(%eax),%eax
}
  8022d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022dc:	5b                   	pop    %ebx
  8022dd:	5e                   	pop    %esi
  8022de:	5d                   	pop    %ebp
  8022df:	c3                   	ret    

008022e0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022e0:	55                   	push   %ebp
  8022e1:	89 e5                	mov    %esp,%ebp
  8022e3:	57                   	push   %edi
  8022e4:	56                   	push   %esi
  8022e5:	53                   	push   %ebx
  8022e6:	83 ec 0c             	sub    $0xc,%esp
  8022e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8022f2:	85 db                	test   %ebx,%ebx
  8022f4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022f9:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8022fc:	ff 75 14             	pushl  0x14(%ebp)
  8022ff:	53                   	push   %ebx
  802300:	56                   	push   %esi
  802301:	57                   	push   %edi
  802302:	e8 46 ed ff ff       	call   80104d <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802307:	89 c2                	mov    %eax,%edx
  802309:	c1 ea 1f             	shr    $0x1f,%edx
  80230c:	83 c4 10             	add    $0x10,%esp
  80230f:	84 d2                	test   %dl,%dl
  802311:	74 17                	je     80232a <ipc_send+0x4a>
  802313:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802316:	74 12                	je     80232a <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802318:	50                   	push   %eax
  802319:	68 d5 2c 80 00       	push   $0x802cd5
  80231e:	6a 47                	push   $0x47
  802320:	68 e3 2c 80 00       	push   $0x802ce3
  802325:	e8 35 e1 ff ff       	call   80045f <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80232a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80232d:	75 07                	jne    802336 <ipc_send+0x56>
			sys_yield();
  80232f:	e8 6d eb ff ff       	call   800ea1 <sys_yield>
  802334:	eb c6                	jmp    8022fc <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802336:	85 c0                	test   %eax,%eax
  802338:	75 c2                	jne    8022fc <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80233a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5f                   	pop    %edi
  802340:	5d                   	pop    %ebp
  802341:	c3                   	ret    

00802342 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802342:	55                   	push   %ebp
  802343:	89 e5                	mov    %esp,%ebp
  802345:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802348:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80234d:	89 c2                	mov    %eax,%edx
  80234f:	c1 e2 07             	shl    $0x7,%edx
  802352:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  802359:	8b 52 58             	mov    0x58(%edx),%edx
  80235c:	39 ca                	cmp    %ecx,%edx
  80235e:	75 11                	jne    802371 <ipc_find_env+0x2f>
			return envs[i].env_id;
  802360:	89 c2                	mov    %eax,%edx
  802362:	c1 e2 07             	shl    $0x7,%edx
  802365:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80236c:	8b 40 50             	mov    0x50(%eax),%eax
  80236f:	eb 0f                	jmp    802380 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802371:	83 c0 01             	add    $0x1,%eax
  802374:	3d 00 04 00 00       	cmp    $0x400,%eax
  802379:	75 d2                	jne    80234d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80237b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802380:	5d                   	pop    %ebp
  802381:	c3                   	ret    

00802382 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802382:	55                   	push   %ebp
  802383:	89 e5                	mov    %esp,%ebp
  802385:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802388:	89 d0                	mov    %edx,%eax
  80238a:	c1 e8 16             	shr    $0x16,%eax
  80238d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802394:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802399:	f6 c1 01             	test   $0x1,%cl
  80239c:	74 1d                	je     8023bb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80239e:	c1 ea 0c             	shr    $0xc,%edx
  8023a1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023a8:	f6 c2 01             	test   $0x1,%dl
  8023ab:	74 0e                	je     8023bb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023ad:	c1 ea 0c             	shr    $0xc,%edx
  8023b0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023b7:	ef 
  8023b8:	0f b7 c0             	movzwl %ax,%eax
}
  8023bb:	5d                   	pop    %ebp
  8023bc:	c3                   	ret    
  8023bd:	66 90                	xchg   %ax,%ax
  8023bf:	90                   	nop

008023c0 <__udivdi3>:
  8023c0:	55                   	push   %ebp
  8023c1:	57                   	push   %edi
  8023c2:	56                   	push   %esi
  8023c3:	53                   	push   %ebx
  8023c4:	83 ec 1c             	sub    $0x1c,%esp
  8023c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023d7:	85 f6                	test   %esi,%esi
  8023d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023dd:	89 ca                	mov    %ecx,%edx
  8023df:	89 f8                	mov    %edi,%eax
  8023e1:	75 3d                	jne    802420 <__udivdi3+0x60>
  8023e3:	39 cf                	cmp    %ecx,%edi
  8023e5:	0f 87 c5 00 00 00    	ja     8024b0 <__udivdi3+0xf0>
  8023eb:	85 ff                	test   %edi,%edi
  8023ed:	89 fd                	mov    %edi,%ebp
  8023ef:	75 0b                	jne    8023fc <__udivdi3+0x3c>
  8023f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023f6:	31 d2                	xor    %edx,%edx
  8023f8:	f7 f7                	div    %edi
  8023fa:	89 c5                	mov    %eax,%ebp
  8023fc:	89 c8                	mov    %ecx,%eax
  8023fe:	31 d2                	xor    %edx,%edx
  802400:	f7 f5                	div    %ebp
  802402:	89 c1                	mov    %eax,%ecx
  802404:	89 d8                	mov    %ebx,%eax
  802406:	89 cf                	mov    %ecx,%edi
  802408:	f7 f5                	div    %ebp
  80240a:	89 c3                	mov    %eax,%ebx
  80240c:	89 d8                	mov    %ebx,%eax
  80240e:	89 fa                	mov    %edi,%edx
  802410:	83 c4 1c             	add    $0x1c,%esp
  802413:	5b                   	pop    %ebx
  802414:	5e                   	pop    %esi
  802415:	5f                   	pop    %edi
  802416:	5d                   	pop    %ebp
  802417:	c3                   	ret    
  802418:	90                   	nop
  802419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802420:	39 ce                	cmp    %ecx,%esi
  802422:	77 74                	ja     802498 <__udivdi3+0xd8>
  802424:	0f bd fe             	bsr    %esi,%edi
  802427:	83 f7 1f             	xor    $0x1f,%edi
  80242a:	0f 84 98 00 00 00    	je     8024c8 <__udivdi3+0x108>
  802430:	bb 20 00 00 00       	mov    $0x20,%ebx
  802435:	89 f9                	mov    %edi,%ecx
  802437:	89 c5                	mov    %eax,%ebp
  802439:	29 fb                	sub    %edi,%ebx
  80243b:	d3 e6                	shl    %cl,%esi
  80243d:	89 d9                	mov    %ebx,%ecx
  80243f:	d3 ed                	shr    %cl,%ebp
  802441:	89 f9                	mov    %edi,%ecx
  802443:	d3 e0                	shl    %cl,%eax
  802445:	09 ee                	or     %ebp,%esi
  802447:	89 d9                	mov    %ebx,%ecx
  802449:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80244d:	89 d5                	mov    %edx,%ebp
  80244f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802453:	d3 ed                	shr    %cl,%ebp
  802455:	89 f9                	mov    %edi,%ecx
  802457:	d3 e2                	shl    %cl,%edx
  802459:	89 d9                	mov    %ebx,%ecx
  80245b:	d3 e8                	shr    %cl,%eax
  80245d:	09 c2                	or     %eax,%edx
  80245f:	89 d0                	mov    %edx,%eax
  802461:	89 ea                	mov    %ebp,%edx
  802463:	f7 f6                	div    %esi
  802465:	89 d5                	mov    %edx,%ebp
  802467:	89 c3                	mov    %eax,%ebx
  802469:	f7 64 24 0c          	mull   0xc(%esp)
  80246d:	39 d5                	cmp    %edx,%ebp
  80246f:	72 10                	jb     802481 <__udivdi3+0xc1>
  802471:	8b 74 24 08          	mov    0x8(%esp),%esi
  802475:	89 f9                	mov    %edi,%ecx
  802477:	d3 e6                	shl    %cl,%esi
  802479:	39 c6                	cmp    %eax,%esi
  80247b:	73 07                	jae    802484 <__udivdi3+0xc4>
  80247d:	39 d5                	cmp    %edx,%ebp
  80247f:	75 03                	jne    802484 <__udivdi3+0xc4>
  802481:	83 eb 01             	sub    $0x1,%ebx
  802484:	31 ff                	xor    %edi,%edi
  802486:	89 d8                	mov    %ebx,%eax
  802488:	89 fa                	mov    %edi,%edx
  80248a:	83 c4 1c             	add    $0x1c,%esp
  80248d:	5b                   	pop    %ebx
  80248e:	5e                   	pop    %esi
  80248f:	5f                   	pop    %edi
  802490:	5d                   	pop    %ebp
  802491:	c3                   	ret    
  802492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802498:	31 ff                	xor    %edi,%edi
  80249a:	31 db                	xor    %ebx,%ebx
  80249c:	89 d8                	mov    %ebx,%eax
  80249e:	89 fa                	mov    %edi,%edx
  8024a0:	83 c4 1c             	add    $0x1c,%esp
  8024a3:	5b                   	pop    %ebx
  8024a4:	5e                   	pop    %esi
  8024a5:	5f                   	pop    %edi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    
  8024a8:	90                   	nop
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	89 d8                	mov    %ebx,%eax
  8024b2:	f7 f7                	div    %edi
  8024b4:	31 ff                	xor    %edi,%edi
  8024b6:	89 c3                	mov    %eax,%ebx
  8024b8:	89 d8                	mov    %ebx,%eax
  8024ba:	89 fa                	mov    %edi,%edx
  8024bc:	83 c4 1c             	add    $0x1c,%esp
  8024bf:	5b                   	pop    %ebx
  8024c0:	5e                   	pop    %esi
  8024c1:	5f                   	pop    %edi
  8024c2:	5d                   	pop    %ebp
  8024c3:	c3                   	ret    
  8024c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024c8:	39 ce                	cmp    %ecx,%esi
  8024ca:	72 0c                	jb     8024d8 <__udivdi3+0x118>
  8024cc:	31 db                	xor    %ebx,%ebx
  8024ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024d2:	0f 87 34 ff ff ff    	ja     80240c <__udivdi3+0x4c>
  8024d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024dd:	e9 2a ff ff ff       	jmp    80240c <__udivdi3+0x4c>
  8024e2:	66 90                	xchg   %ax,%ax
  8024e4:	66 90                	xchg   %ax,%ax
  8024e6:	66 90                	xchg   %ax,%ax
  8024e8:	66 90                	xchg   %ax,%ax
  8024ea:	66 90                	xchg   %ax,%ax
  8024ec:	66 90                	xchg   %ax,%ax
  8024ee:	66 90                	xchg   %ax,%ax

008024f0 <__umoddi3>:
  8024f0:	55                   	push   %ebp
  8024f1:	57                   	push   %edi
  8024f2:	56                   	push   %esi
  8024f3:	53                   	push   %ebx
  8024f4:	83 ec 1c             	sub    $0x1c,%esp
  8024f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802503:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802507:	85 d2                	test   %edx,%edx
  802509:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80250d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802511:	89 f3                	mov    %esi,%ebx
  802513:	89 3c 24             	mov    %edi,(%esp)
  802516:	89 74 24 04          	mov    %esi,0x4(%esp)
  80251a:	75 1c                	jne    802538 <__umoddi3+0x48>
  80251c:	39 f7                	cmp    %esi,%edi
  80251e:	76 50                	jbe    802570 <__umoddi3+0x80>
  802520:	89 c8                	mov    %ecx,%eax
  802522:	89 f2                	mov    %esi,%edx
  802524:	f7 f7                	div    %edi
  802526:	89 d0                	mov    %edx,%eax
  802528:	31 d2                	xor    %edx,%edx
  80252a:	83 c4 1c             	add    $0x1c,%esp
  80252d:	5b                   	pop    %ebx
  80252e:	5e                   	pop    %esi
  80252f:	5f                   	pop    %edi
  802530:	5d                   	pop    %ebp
  802531:	c3                   	ret    
  802532:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802538:	39 f2                	cmp    %esi,%edx
  80253a:	89 d0                	mov    %edx,%eax
  80253c:	77 52                	ja     802590 <__umoddi3+0xa0>
  80253e:	0f bd ea             	bsr    %edx,%ebp
  802541:	83 f5 1f             	xor    $0x1f,%ebp
  802544:	75 5a                	jne    8025a0 <__umoddi3+0xb0>
  802546:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80254a:	0f 82 e0 00 00 00    	jb     802630 <__umoddi3+0x140>
  802550:	39 0c 24             	cmp    %ecx,(%esp)
  802553:	0f 86 d7 00 00 00    	jbe    802630 <__umoddi3+0x140>
  802559:	8b 44 24 08          	mov    0x8(%esp),%eax
  80255d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802561:	83 c4 1c             	add    $0x1c,%esp
  802564:	5b                   	pop    %ebx
  802565:	5e                   	pop    %esi
  802566:	5f                   	pop    %edi
  802567:	5d                   	pop    %ebp
  802568:	c3                   	ret    
  802569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802570:	85 ff                	test   %edi,%edi
  802572:	89 fd                	mov    %edi,%ebp
  802574:	75 0b                	jne    802581 <__umoddi3+0x91>
  802576:	b8 01 00 00 00       	mov    $0x1,%eax
  80257b:	31 d2                	xor    %edx,%edx
  80257d:	f7 f7                	div    %edi
  80257f:	89 c5                	mov    %eax,%ebp
  802581:	89 f0                	mov    %esi,%eax
  802583:	31 d2                	xor    %edx,%edx
  802585:	f7 f5                	div    %ebp
  802587:	89 c8                	mov    %ecx,%eax
  802589:	f7 f5                	div    %ebp
  80258b:	89 d0                	mov    %edx,%eax
  80258d:	eb 99                	jmp    802528 <__umoddi3+0x38>
  80258f:	90                   	nop
  802590:	89 c8                	mov    %ecx,%eax
  802592:	89 f2                	mov    %esi,%edx
  802594:	83 c4 1c             	add    $0x1c,%esp
  802597:	5b                   	pop    %ebx
  802598:	5e                   	pop    %esi
  802599:	5f                   	pop    %edi
  80259a:	5d                   	pop    %ebp
  80259b:	c3                   	ret    
  80259c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025a0:	8b 34 24             	mov    (%esp),%esi
  8025a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025a8:	89 e9                	mov    %ebp,%ecx
  8025aa:	29 ef                	sub    %ebp,%edi
  8025ac:	d3 e0                	shl    %cl,%eax
  8025ae:	89 f9                	mov    %edi,%ecx
  8025b0:	89 f2                	mov    %esi,%edx
  8025b2:	d3 ea                	shr    %cl,%edx
  8025b4:	89 e9                	mov    %ebp,%ecx
  8025b6:	09 c2                	or     %eax,%edx
  8025b8:	89 d8                	mov    %ebx,%eax
  8025ba:	89 14 24             	mov    %edx,(%esp)
  8025bd:	89 f2                	mov    %esi,%edx
  8025bf:	d3 e2                	shl    %cl,%edx
  8025c1:	89 f9                	mov    %edi,%ecx
  8025c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025cb:	d3 e8                	shr    %cl,%eax
  8025cd:	89 e9                	mov    %ebp,%ecx
  8025cf:	89 c6                	mov    %eax,%esi
  8025d1:	d3 e3                	shl    %cl,%ebx
  8025d3:	89 f9                	mov    %edi,%ecx
  8025d5:	89 d0                	mov    %edx,%eax
  8025d7:	d3 e8                	shr    %cl,%eax
  8025d9:	89 e9                	mov    %ebp,%ecx
  8025db:	09 d8                	or     %ebx,%eax
  8025dd:	89 d3                	mov    %edx,%ebx
  8025df:	89 f2                	mov    %esi,%edx
  8025e1:	f7 34 24             	divl   (%esp)
  8025e4:	89 d6                	mov    %edx,%esi
  8025e6:	d3 e3                	shl    %cl,%ebx
  8025e8:	f7 64 24 04          	mull   0x4(%esp)
  8025ec:	39 d6                	cmp    %edx,%esi
  8025ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025f2:	89 d1                	mov    %edx,%ecx
  8025f4:	89 c3                	mov    %eax,%ebx
  8025f6:	72 08                	jb     802600 <__umoddi3+0x110>
  8025f8:	75 11                	jne    80260b <__umoddi3+0x11b>
  8025fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025fe:	73 0b                	jae    80260b <__umoddi3+0x11b>
  802600:	2b 44 24 04          	sub    0x4(%esp),%eax
  802604:	1b 14 24             	sbb    (%esp),%edx
  802607:	89 d1                	mov    %edx,%ecx
  802609:	89 c3                	mov    %eax,%ebx
  80260b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80260f:	29 da                	sub    %ebx,%edx
  802611:	19 ce                	sbb    %ecx,%esi
  802613:	89 f9                	mov    %edi,%ecx
  802615:	89 f0                	mov    %esi,%eax
  802617:	d3 e0                	shl    %cl,%eax
  802619:	89 e9                	mov    %ebp,%ecx
  80261b:	d3 ea                	shr    %cl,%edx
  80261d:	89 e9                	mov    %ebp,%ecx
  80261f:	d3 ee                	shr    %cl,%esi
  802621:	09 d0                	or     %edx,%eax
  802623:	89 f2                	mov    %esi,%edx
  802625:	83 c4 1c             	add    $0x1c,%esp
  802628:	5b                   	pop    %ebx
  802629:	5e                   	pop    %esi
  80262a:	5f                   	pop    %edi
  80262b:	5d                   	pop    %ebp
  80262c:	c3                   	ret    
  80262d:	8d 76 00             	lea    0x0(%esi),%esi
  802630:	29 f9                	sub    %edi,%ecx
  802632:	19 d6                	sbb    %edx,%esi
  802634:	89 74 24 04          	mov    %esi,0x4(%esp)
  802638:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80263c:	e9 18 ff ff ff       	jmp    802559 <__umoddi3+0x69>
