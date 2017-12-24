
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
  80006d:	68 20 26 80 00       	push   $0x802620
  800072:	e8 a9 04 00 00       	call   800520 <cprintf>

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
  80009c:	68 e8 26 80 00       	push   $0x8026e8
  8000a1:	e8 7a 04 00 00       	call   800520 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 2f 26 80 00       	push   $0x80262f
  8000b3:	e8 68 04 00 00       	call   800520 <cprintf>
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
  8000d8:	68 24 27 80 00       	push   $0x802724
  8000dd:	e8 3e 04 00 00       	call   800520 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 46 26 80 00       	push   $0x802646
  8000ef:	e8 2c 04 00 00       	call   800520 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 5c 26 80 00       	push   $0x80265c
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 ba 09 00 00       	call   800ac5 <strcat>
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
  80011e:	68 68 26 80 00       	push   $0x802668
  800123:	56                   	push   %esi
  800124:	e8 9c 09 00 00       	call   800ac5 <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 90 09 00 00       	call   800ac5 <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 69 26 80 00       	push   $0x802669
  80013d:	56                   	push   %esi
  80013e:	e8 82 09 00 00       	call   800ac5 <strcat>
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
  800158:	68 6b 26 80 00       	push   $0x80266b
  80015d:	e8 be 03 00 00       	call   800520 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 6f 26 80 00 	movl   $0x80266f,(%esp)
  800169:	e8 b2 03 00 00       	call   800520 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 bf 10 00 00       	call   801239 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 81 26 80 00       	push   $0x802681
  80018c:	6a 37                	push   $0x37
  80018e:	68 8e 26 80 00       	push   $0x80268e
  800193:	e8 af 02 00 00       	call   800447 <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 9a 26 80 00       	push   $0x80269a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 8e 26 80 00       	push   $0x80268e
  8001a9:	e8 99 02 00 00       	call   800447 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 cf 10 00 00       	call   801289 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 b4 26 80 00       	push   $0x8026b4
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 8e 26 80 00       	push   $0x80268e
  8001ce:	e8 74 02 00 00       	call   800447 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 bc 26 80 00       	push   $0x8026bc
  8001db:	e8 40 03 00 00       	call   800520 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 d0 26 80 00       	push   $0x8026d0
  8001ea:	68 cf 26 80 00       	push   $0x8026cf
  8001ef:	e8 1f 1c 00 00       	call   801e13 <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 d3 26 80 00       	push   $0x8026d3
  800204:	e8 17 03 00 00       	call   800520 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 cb 1f 00 00       	call   8021e2 <wait>
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
  80022c:	68 53 27 80 00       	push   $0x802753
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 6c 08 00 00       	call   800aa5 <strcpy>
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
  800272:	e8 c0 09 00 00       	call   800c37 <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 6b 0b 00 00       	call   800dec <sys_cputs>
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
  8002a8:	e8 dc 0b 00 00       	call   800e89 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 58 0b 00 00       	call   800e0a <sys_cgetc>
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
  8002e4:	e8 03 0b 00 00       	call   800dec <sys_cputs>
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
  8002fc:	e8 74 10 00 00       	call   801375 <read>
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
  800326:	e8 e4 0d 00 00       	call   80110f <fd_lookup>
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
  80034f:	e8 6c 0d 00 00       	call   8010c0 <fd_alloc>
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
  80036a:	e8 39 0b 00 00       	call   800ea8 <sys_page_alloc>
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
  800391:	e8 03 0d 00 00       	call   801099 <fd2num>
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
  8003b2:	e8 b3 0a 00 00       	call   800e6a <sys_getenvid>
  8003b7:	8b 3d 90 67 80 00    	mov    0x806790,%edi
  8003bd:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8003c2:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8003c7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8003cc:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8003cf:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8003d5:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8003d8:	39 c8                	cmp    %ecx,%eax
  8003da:	0f 44 fb             	cmove  %ebx,%edi
  8003dd:	b9 01 00 00 00       	mov    $0x1,%ecx
  8003e2:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8003e5:	83 c2 01             	add    $0x1,%edx
  8003e8:	83 c3 7c             	add    $0x7c,%ebx
  8003eb:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8003f1:	75 d9                	jne    8003cc <libmain+0x2d>
  8003f3:	89 f0                	mov    %esi,%eax
  8003f5:	84 c0                	test   %al,%al
  8003f7:	74 06                	je     8003ff <libmain+0x60>
  8003f9:	89 3d 90 67 80 00    	mov    %edi,0x806790
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003ff:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800403:	7e 0a                	jle    80040f <libmain+0x70>
		binaryname = argv[0];
  800405:	8b 45 0c             	mov    0xc(%ebp),%eax
  800408:	8b 00                	mov    (%eax),%eax
  80040a:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  80040f:	83 ec 08             	sub    $0x8,%esp
  800412:	ff 75 0c             	pushl  0xc(%ebp)
  800415:	ff 75 08             	pushl  0x8(%ebp)
  800418:	e8 41 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  80041d:	e8 0b 00 00 00       	call   80042d <exit>
}
  800422:	83 c4 10             	add    $0x10,%esp
  800425:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800428:	5b                   	pop    %ebx
  800429:	5e                   	pop    %esi
  80042a:	5f                   	pop    %edi
  80042b:	5d                   	pop    %ebp
  80042c:	c3                   	ret    

0080042d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80042d:	55                   	push   %ebp
  80042e:	89 e5                	mov    %esp,%ebp
  800430:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800433:	e8 2c 0e 00 00       	call   801264 <close_all>
	sys_env_destroy(0);
  800438:	83 ec 0c             	sub    $0xc,%esp
  80043b:	6a 00                	push   $0x0
  80043d:	e8 e7 09 00 00       	call   800e29 <sys_env_destroy>
}
  800442:	83 c4 10             	add    $0x10,%esp
  800445:	c9                   	leave  
  800446:	c3                   	ret    

00800447 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800447:	55                   	push   %ebp
  800448:	89 e5                	mov    %esp,%ebp
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80044c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80044f:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  800455:	e8 10 0a 00 00       	call   800e6a <sys_getenvid>
  80045a:	83 ec 0c             	sub    $0xc,%esp
  80045d:	ff 75 0c             	pushl  0xc(%ebp)
  800460:	ff 75 08             	pushl  0x8(%ebp)
  800463:	56                   	push   %esi
  800464:	50                   	push   %eax
  800465:	68 6c 27 80 00       	push   $0x80276c
  80046a:	e8 b1 00 00 00       	call   800520 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80046f:	83 c4 18             	add    $0x18,%esp
  800472:	53                   	push   %ebx
  800473:	ff 75 10             	pushl  0x10(%ebp)
  800476:	e8 54 00 00 00       	call   8004cf <vcprintf>
	cprintf("\n");
  80047b:	c7 04 24 58 2c 80 00 	movl   $0x802c58,(%esp)
  800482:	e8 99 00 00 00       	call   800520 <cprintf>
  800487:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80048a:	cc                   	int3   
  80048b:	eb fd                	jmp    80048a <_panic+0x43>

0080048d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80048d:	55                   	push   %ebp
  80048e:	89 e5                	mov    %esp,%ebp
  800490:	53                   	push   %ebx
  800491:	83 ec 04             	sub    $0x4,%esp
  800494:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800497:	8b 13                	mov    (%ebx),%edx
  800499:	8d 42 01             	lea    0x1(%edx),%eax
  80049c:	89 03                	mov    %eax,(%ebx)
  80049e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004a1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004a5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004aa:	75 1a                	jne    8004c6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	68 ff 00 00 00       	push   $0xff
  8004b4:	8d 43 08             	lea    0x8(%ebx),%eax
  8004b7:	50                   	push   %eax
  8004b8:	e8 2f 09 00 00       	call   800dec <sys_cputs>
		b->idx = 0;
  8004bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004c3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004c6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004cd:	c9                   	leave  
  8004ce:	c3                   	ret    

008004cf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004cf:	55                   	push   %ebp
  8004d0:	89 e5                	mov    %esp,%ebp
  8004d2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004d8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004df:	00 00 00 
	b.cnt = 0;
  8004e2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004e9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004ec:	ff 75 0c             	pushl  0xc(%ebp)
  8004ef:	ff 75 08             	pushl  0x8(%ebp)
  8004f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004f8:	50                   	push   %eax
  8004f9:	68 8d 04 80 00       	push   $0x80048d
  8004fe:	e8 54 01 00 00       	call   800657 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800503:	83 c4 08             	add    $0x8,%esp
  800506:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80050c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800512:	50                   	push   %eax
  800513:	e8 d4 08 00 00       	call   800dec <sys_cputs>

	return b.cnt;
}
  800518:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80051e:	c9                   	leave  
  80051f:	c3                   	ret    

00800520 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800526:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800529:	50                   	push   %eax
  80052a:	ff 75 08             	pushl  0x8(%ebp)
  80052d:	e8 9d ff ff ff       	call   8004cf <vcprintf>
	va_end(ap);

	return cnt;
}
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	57                   	push   %edi
  800538:	56                   	push   %esi
  800539:	53                   	push   %ebx
  80053a:	83 ec 1c             	sub    $0x1c,%esp
  80053d:	89 c7                	mov    %eax,%edi
  80053f:	89 d6                	mov    %edx,%esi
  800541:	8b 45 08             	mov    0x8(%ebp),%eax
  800544:	8b 55 0c             	mov    0xc(%ebp),%edx
  800547:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80054d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800550:	bb 00 00 00 00       	mov    $0x0,%ebx
  800555:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800558:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80055b:	39 d3                	cmp    %edx,%ebx
  80055d:	72 05                	jb     800564 <printnum+0x30>
  80055f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800562:	77 45                	ja     8005a9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800564:	83 ec 0c             	sub    $0xc,%esp
  800567:	ff 75 18             	pushl  0x18(%ebp)
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800570:	53                   	push   %ebx
  800571:	ff 75 10             	pushl  0x10(%ebp)
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	ff 75 e4             	pushl  -0x1c(%ebp)
  80057a:	ff 75 e0             	pushl  -0x20(%ebp)
  80057d:	ff 75 dc             	pushl  -0x24(%ebp)
  800580:	ff 75 d8             	pushl  -0x28(%ebp)
  800583:	e8 f8 1d 00 00       	call   802380 <__udivdi3>
  800588:	83 c4 18             	add    $0x18,%esp
  80058b:	52                   	push   %edx
  80058c:	50                   	push   %eax
  80058d:	89 f2                	mov    %esi,%edx
  80058f:	89 f8                	mov    %edi,%eax
  800591:	e8 9e ff ff ff       	call   800534 <printnum>
  800596:	83 c4 20             	add    $0x20,%esp
  800599:	eb 18                	jmp    8005b3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	56                   	push   %esi
  80059f:	ff 75 18             	pushl  0x18(%ebp)
  8005a2:	ff d7                	call   *%edi
  8005a4:	83 c4 10             	add    $0x10,%esp
  8005a7:	eb 03                	jmp    8005ac <printnum+0x78>
  8005a9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005ac:	83 eb 01             	sub    $0x1,%ebx
  8005af:	85 db                	test   %ebx,%ebx
  8005b1:	7f e8                	jg     80059b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	56                   	push   %esi
  8005b7:	83 ec 04             	sub    $0x4,%esp
  8005ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c0:	ff 75 dc             	pushl  -0x24(%ebp)
  8005c3:	ff 75 d8             	pushl  -0x28(%ebp)
  8005c6:	e8 e5 1e 00 00       	call   8024b0 <__umoddi3>
  8005cb:	83 c4 14             	add    $0x14,%esp
  8005ce:	0f be 80 8f 27 80 00 	movsbl 0x80278f(%eax),%eax
  8005d5:	50                   	push   %eax
  8005d6:	ff d7                	call   *%edi
}
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005de:	5b                   	pop    %ebx
  8005df:	5e                   	pop    %esi
  8005e0:	5f                   	pop    %edi
  8005e1:	5d                   	pop    %ebp
  8005e2:	c3                   	ret    

008005e3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005e3:	55                   	push   %ebp
  8005e4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005e6:	83 fa 01             	cmp    $0x1,%edx
  8005e9:	7e 0e                	jle    8005f9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005eb:	8b 10                	mov    (%eax),%edx
  8005ed:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005f0:	89 08                	mov    %ecx,(%eax)
  8005f2:	8b 02                	mov    (%edx),%eax
  8005f4:	8b 52 04             	mov    0x4(%edx),%edx
  8005f7:	eb 22                	jmp    80061b <getuint+0x38>
	else if (lflag)
  8005f9:	85 d2                	test   %edx,%edx
  8005fb:	74 10                	je     80060d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005fd:	8b 10                	mov    (%eax),%edx
  8005ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800602:	89 08                	mov    %ecx,(%eax)
  800604:	8b 02                	mov    (%edx),%eax
  800606:	ba 00 00 00 00       	mov    $0x0,%edx
  80060b:	eb 0e                	jmp    80061b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80060d:	8b 10                	mov    (%eax),%edx
  80060f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800612:	89 08                	mov    %ecx,(%eax)
  800614:	8b 02                	mov    (%edx),%eax
  800616:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80061b:	5d                   	pop    %ebp
  80061c:	c3                   	ret    

0080061d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80061d:	55                   	push   %ebp
  80061e:	89 e5                	mov    %esp,%ebp
  800620:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800623:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800627:	8b 10                	mov    (%eax),%edx
  800629:	3b 50 04             	cmp    0x4(%eax),%edx
  80062c:	73 0a                	jae    800638 <sprintputch+0x1b>
		*b->buf++ = ch;
  80062e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800631:	89 08                	mov    %ecx,(%eax)
  800633:	8b 45 08             	mov    0x8(%ebp),%eax
  800636:	88 02                	mov    %al,(%edx)
}
  800638:	5d                   	pop    %ebp
  800639:	c3                   	ret    

0080063a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80063a:	55                   	push   %ebp
  80063b:	89 e5                	mov    %esp,%ebp
  80063d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800640:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800643:	50                   	push   %eax
  800644:	ff 75 10             	pushl  0x10(%ebp)
  800647:	ff 75 0c             	pushl  0xc(%ebp)
  80064a:	ff 75 08             	pushl  0x8(%ebp)
  80064d:	e8 05 00 00 00       	call   800657 <vprintfmt>
	va_end(ap);
}
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	57                   	push   %edi
  80065b:	56                   	push   %esi
  80065c:	53                   	push   %ebx
  80065d:	83 ec 2c             	sub    $0x2c,%esp
  800660:	8b 75 08             	mov    0x8(%ebp),%esi
  800663:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800666:	8b 7d 10             	mov    0x10(%ebp),%edi
  800669:	eb 12                	jmp    80067d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80066b:	85 c0                	test   %eax,%eax
  80066d:	0f 84 89 03 00 00    	je     8009fc <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	50                   	push   %eax
  800678:	ff d6                	call   *%esi
  80067a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80067d:	83 c7 01             	add    $0x1,%edi
  800680:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800684:	83 f8 25             	cmp    $0x25,%eax
  800687:	75 e2                	jne    80066b <vprintfmt+0x14>
  800689:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80068d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800694:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80069b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8006a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a7:	eb 07                	jmp    8006b0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006ac:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b0:	8d 47 01             	lea    0x1(%edi),%eax
  8006b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b6:	0f b6 07             	movzbl (%edi),%eax
  8006b9:	0f b6 c8             	movzbl %al,%ecx
  8006bc:	83 e8 23             	sub    $0x23,%eax
  8006bf:	3c 55                	cmp    $0x55,%al
  8006c1:	0f 87 1a 03 00 00    	ja     8009e1 <vprintfmt+0x38a>
  8006c7:	0f b6 c0             	movzbl %al,%eax
  8006ca:	ff 24 85 e0 28 80 00 	jmp    *0x8028e0(,%eax,4)
  8006d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006d4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8006d8:	eb d6                	jmp    8006b0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006e5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8006e8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8006ec:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8006ef:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8006f2:	83 fa 09             	cmp    $0x9,%edx
  8006f5:	77 39                	ja     800730 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006f7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006fa:	eb e9                	jmp    8006e5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 48 04             	lea    0x4(%eax),%ecx
  800702:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800705:	8b 00                	mov    (%eax),%eax
  800707:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80070d:	eb 27                	jmp    800736 <vprintfmt+0xdf>
  80070f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800712:	85 c0                	test   %eax,%eax
  800714:	b9 00 00 00 00       	mov    $0x0,%ecx
  800719:	0f 49 c8             	cmovns %eax,%ecx
  80071c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800722:	eb 8c                	jmp    8006b0 <vprintfmt+0x59>
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800727:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80072e:	eb 80                	jmp    8006b0 <vprintfmt+0x59>
  800730:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800733:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800736:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80073a:	0f 89 70 ff ff ff    	jns    8006b0 <vprintfmt+0x59>
				width = precision, precision = -1;
  800740:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800743:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800746:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80074d:	e9 5e ff ff ff       	jmp    8006b0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800752:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800755:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800758:	e9 53 ff ff ff       	jmp    8006b0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	8d 50 04             	lea    0x4(%eax),%edx
  800763:	89 55 14             	mov    %edx,0x14(%ebp)
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	ff 30                	pushl  (%eax)
  80076c:	ff d6                	call   *%esi
			break;
  80076e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800771:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800774:	e9 04 ff ff ff       	jmp    80067d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800779:	8b 45 14             	mov    0x14(%ebp),%eax
  80077c:	8d 50 04             	lea    0x4(%eax),%edx
  80077f:	89 55 14             	mov    %edx,0x14(%ebp)
  800782:	8b 00                	mov    (%eax),%eax
  800784:	99                   	cltd   
  800785:	31 d0                	xor    %edx,%eax
  800787:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800789:	83 f8 0f             	cmp    $0xf,%eax
  80078c:	7f 0b                	jg     800799 <vprintfmt+0x142>
  80078e:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  800795:	85 d2                	test   %edx,%edx
  800797:	75 18                	jne    8007b1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800799:	50                   	push   %eax
  80079a:	68 a7 27 80 00       	push   $0x8027a7
  80079f:	53                   	push   %ebx
  8007a0:	56                   	push   %esi
  8007a1:	e8 94 fe ff ff       	call   80063a <printfmt>
  8007a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007ac:	e9 cc fe ff ff       	jmp    80067d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8007b1:	52                   	push   %edx
  8007b2:	68 71 2b 80 00       	push   $0x802b71
  8007b7:	53                   	push   %ebx
  8007b8:	56                   	push   %esi
  8007b9:	e8 7c fe ff ff       	call   80063a <printfmt>
  8007be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c4:	e9 b4 fe ff ff       	jmp    80067d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cc:	8d 50 04             	lea    0x4(%eax),%edx
  8007cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8007d4:	85 ff                	test   %edi,%edi
  8007d6:	b8 a0 27 80 00       	mov    $0x8027a0,%eax
  8007db:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8007de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007e2:	0f 8e 94 00 00 00    	jle    80087c <vprintfmt+0x225>
  8007e8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8007ec:	0f 84 98 00 00 00    	je     80088a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007f2:	83 ec 08             	sub    $0x8,%esp
  8007f5:	ff 75 d0             	pushl  -0x30(%ebp)
  8007f8:	57                   	push   %edi
  8007f9:	e8 86 02 00 00       	call   800a84 <strnlen>
  8007fe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800801:	29 c1                	sub    %eax,%ecx
  800803:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800806:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800809:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80080d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800810:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800813:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800815:	eb 0f                	jmp    800826 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800817:	83 ec 08             	sub    $0x8,%esp
  80081a:	53                   	push   %ebx
  80081b:	ff 75 e0             	pushl  -0x20(%ebp)
  80081e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800820:	83 ef 01             	sub    $0x1,%edi
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	85 ff                	test   %edi,%edi
  800828:	7f ed                	jg     800817 <vprintfmt+0x1c0>
  80082a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80082d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800830:	85 c9                	test   %ecx,%ecx
  800832:	b8 00 00 00 00       	mov    $0x0,%eax
  800837:	0f 49 c1             	cmovns %ecx,%eax
  80083a:	29 c1                	sub    %eax,%ecx
  80083c:	89 75 08             	mov    %esi,0x8(%ebp)
  80083f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800842:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800845:	89 cb                	mov    %ecx,%ebx
  800847:	eb 4d                	jmp    800896 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800849:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80084d:	74 1b                	je     80086a <vprintfmt+0x213>
  80084f:	0f be c0             	movsbl %al,%eax
  800852:	83 e8 20             	sub    $0x20,%eax
  800855:	83 f8 5e             	cmp    $0x5e,%eax
  800858:	76 10                	jbe    80086a <vprintfmt+0x213>
					putch('?', putdat);
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	ff 75 0c             	pushl  0xc(%ebp)
  800860:	6a 3f                	push   $0x3f
  800862:	ff 55 08             	call   *0x8(%ebp)
  800865:	83 c4 10             	add    $0x10,%esp
  800868:	eb 0d                	jmp    800877 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	ff 75 0c             	pushl  0xc(%ebp)
  800870:	52                   	push   %edx
  800871:	ff 55 08             	call   *0x8(%ebp)
  800874:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800877:	83 eb 01             	sub    $0x1,%ebx
  80087a:	eb 1a                	jmp    800896 <vprintfmt+0x23f>
  80087c:	89 75 08             	mov    %esi,0x8(%ebp)
  80087f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800882:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800885:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800888:	eb 0c                	jmp    800896 <vprintfmt+0x23f>
  80088a:	89 75 08             	mov    %esi,0x8(%ebp)
  80088d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800890:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800893:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800896:	83 c7 01             	add    $0x1,%edi
  800899:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80089d:	0f be d0             	movsbl %al,%edx
  8008a0:	85 d2                	test   %edx,%edx
  8008a2:	74 23                	je     8008c7 <vprintfmt+0x270>
  8008a4:	85 f6                	test   %esi,%esi
  8008a6:	78 a1                	js     800849 <vprintfmt+0x1f2>
  8008a8:	83 ee 01             	sub    $0x1,%esi
  8008ab:	79 9c                	jns    800849 <vprintfmt+0x1f2>
  8008ad:	89 df                	mov    %ebx,%edi
  8008af:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008b5:	eb 18                	jmp    8008cf <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	53                   	push   %ebx
  8008bb:	6a 20                	push   $0x20
  8008bd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008bf:	83 ef 01             	sub    $0x1,%edi
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	eb 08                	jmp    8008cf <vprintfmt+0x278>
  8008c7:	89 df                	mov    %ebx,%edi
  8008c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008cf:	85 ff                	test   %edi,%edi
  8008d1:	7f e4                	jg     8008b7 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d6:	e9 a2 fd ff ff       	jmp    80067d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008db:	83 fa 01             	cmp    $0x1,%edx
  8008de:	7e 16                	jle    8008f6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8008e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e3:	8d 50 08             	lea    0x8(%eax),%edx
  8008e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e9:	8b 50 04             	mov    0x4(%eax),%edx
  8008ec:	8b 00                	mov    (%eax),%eax
  8008ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008f4:	eb 32                	jmp    800928 <vprintfmt+0x2d1>
	else if (lflag)
  8008f6:	85 d2                	test   %edx,%edx
  8008f8:	74 18                	je     800912 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8008fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fd:	8d 50 04             	lea    0x4(%eax),%edx
  800900:	89 55 14             	mov    %edx,0x14(%ebp)
  800903:	8b 00                	mov    (%eax),%eax
  800905:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800908:	89 c1                	mov    %eax,%ecx
  80090a:	c1 f9 1f             	sar    $0x1f,%ecx
  80090d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800910:	eb 16                	jmp    800928 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800912:	8b 45 14             	mov    0x14(%ebp),%eax
  800915:	8d 50 04             	lea    0x4(%eax),%edx
  800918:	89 55 14             	mov    %edx,0x14(%ebp)
  80091b:	8b 00                	mov    (%eax),%eax
  80091d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800920:	89 c1                	mov    %eax,%ecx
  800922:	c1 f9 1f             	sar    $0x1f,%ecx
  800925:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800928:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80092b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80092e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800933:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800937:	79 74                	jns    8009ad <vprintfmt+0x356>
				putch('-', putdat);
  800939:	83 ec 08             	sub    $0x8,%esp
  80093c:	53                   	push   %ebx
  80093d:	6a 2d                	push   $0x2d
  80093f:	ff d6                	call   *%esi
				num = -(long long) num;
  800941:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800944:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800947:	f7 d8                	neg    %eax
  800949:	83 d2 00             	adc    $0x0,%edx
  80094c:	f7 da                	neg    %edx
  80094e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800951:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800956:	eb 55                	jmp    8009ad <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800958:	8d 45 14             	lea    0x14(%ebp),%eax
  80095b:	e8 83 fc ff ff       	call   8005e3 <getuint>
			base = 10;
  800960:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800965:	eb 46                	jmp    8009ad <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800967:	8d 45 14             	lea    0x14(%ebp),%eax
  80096a:	e8 74 fc ff ff       	call   8005e3 <getuint>
			base = 8;
  80096f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800974:	eb 37                	jmp    8009ad <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800976:	83 ec 08             	sub    $0x8,%esp
  800979:	53                   	push   %ebx
  80097a:	6a 30                	push   $0x30
  80097c:	ff d6                	call   *%esi
			putch('x', putdat);
  80097e:	83 c4 08             	add    $0x8,%esp
  800981:	53                   	push   %ebx
  800982:	6a 78                	push   $0x78
  800984:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800986:	8b 45 14             	mov    0x14(%ebp),%eax
  800989:	8d 50 04             	lea    0x4(%eax),%edx
  80098c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80098f:	8b 00                	mov    (%eax),%eax
  800991:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800996:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800999:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80099e:	eb 0d                	jmp    8009ad <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8009a3:	e8 3b fc ff ff       	call   8005e3 <getuint>
			base = 16;
  8009a8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009ad:	83 ec 0c             	sub    $0xc,%esp
  8009b0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8009b4:	57                   	push   %edi
  8009b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8009b8:	51                   	push   %ecx
  8009b9:	52                   	push   %edx
  8009ba:	50                   	push   %eax
  8009bb:	89 da                	mov    %ebx,%edx
  8009bd:	89 f0                	mov    %esi,%eax
  8009bf:	e8 70 fb ff ff       	call   800534 <printnum>
			break;
  8009c4:	83 c4 20             	add    $0x20,%esp
  8009c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009ca:	e9 ae fc ff ff       	jmp    80067d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009cf:	83 ec 08             	sub    $0x8,%esp
  8009d2:	53                   	push   %ebx
  8009d3:	51                   	push   %ecx
  8009d4:	ff d6                	call   *%esi
			break;
  8009d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009dc:	e9 9c fc ff ff       	jmp    80067d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009e1:	83 ec 08             	sub    $0x8,%esp
  8009e4:	53                   	push   %ebx
  8009e5:	6a 25                	push   $0x25
  8009e7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	eb 03                	jmp    8009f1 <vprintfmt+0x39a>
  8009ee:	83 ef 01             	sub    $0x1,%edi
  8009f1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8009f5:	75 f7                	jne    8009ee <vprintfmt+0x397>
  8009f7:	e9 81 fc ff ff       	jmp    80067d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8009fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5f                   	pop    %edi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	83 ec 18             	sub    $0x18,%esp
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a13:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a17:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a21:	85 c0                	test   %eax,%eax
  800a23:	74 26                	je     800a4b <vsnprintf+0x47>
  800a25:	85 d2                	test   %edx,%edx
  800a27:	7e 22                	jle    800a4b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a29:	ff 75 14             	pushl  0x14(%ebp)
  800a2c:	ff 75 10             	pushl  0x10(%ebp)
  800a2f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a32:	50                   	push   %eax
  800a33:	68 1d 06 80 00       	push   $0x80061d
  800a38:	e8 1a fc ff ff       	call   800657 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a40:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a46:	83 c4 10             	add    $0x10,%esp
  800a49:	eb 05                	jmp    800a50 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a50:	c9                   	leave  
  800a51:	c3                   	ret    

00800a52 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a58:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a5b:	50                   	push   %eax
  800a5c:	ff 75 10             	pushl  0x10(%ebp)
  800a5f:	ff 75 0c             	pushl  0xc(%ebp)
  800a62:	ff 75 08             	pushl  0x8(%ebp)
  800a65:	e8 9a ff ff ff       	call   800a04 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
  800a77:	eb 03                	jmp    800a7c <strlen+0x10>
		n++;
  800a79:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a7c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a80:	75 f7                	jne    800a79 <strlen+0xd>
		n++;
	return n;
}
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a92:	eb 03                	jmp    800a97 <strnlen+0x13>
		n++;
  800a94:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a97:	39 c2                	cmp    %eax,%edx
  800a99:	74 08                	je     800aa3 <strnlen+0x1f>
  800a9b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a9f:	75 f3                	jne    800a94 <strnlen+0x10>
  800aa1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	53                   	push   %ebx
  800aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aaf:	89 c2                	mov    %eax,%edx
  800ab1:	83 c2 01             	add    $0x1,%edx
  800ab4:	83 c1 01             	add    $0x1,%ecx
  800ab7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800abb:	88 5a ff             	mov    %bl,-0x1(%edx)
  800abe:	84 db                	test   %bl,%bl
  800ac0:	75 ef                	jne    800ab1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	53                   	push   %ebx
  800ac9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800acc:	53                   	push   %ebx
  800acd:	e8 9a ff ff ff       	call   800a6c <strlen>
  800ad2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ad5:	ff 75 0c             	pushl  0xc(%ebp)
  800ad8:	01 d8                	add    %ebx,%eax
  800ada:	50                   	push   %eax
  800adb:	e8 c5 ff ff ff       	call   800aa5 <strcpy>
	return dst;
}
  800ae0:	89 d8                	mov    %ebx,%eax
  800ae2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae5:	c9                   	leave  
  800ae6:	c3                   	ret    

00800ae7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
  800aec:	8b 75 08             	mov    0x8(%ebp),%esi
  800aef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af2:	89 f3                	mov    %esi,%ebx
  800af4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800af7:	89 f2                	mov    %esi,%edx
  800af9:	eb 0f                	jmp    800b0a <strncpy+0x23>
		*dst++ = *src;
  800afb:	83 c2 01             	add    $0x1,%edx
  800afe:	0f b6 01             	movzbl (%ecx),%eax
  800b01:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b04:	80 39 01             	cmpb   $0x1,(%ecx)
  800b07:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b0a:	39 da                	cmp    %ebx,%edx
  800b0c:	75 ed                	jne    800afb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b0e:	89 f0                	mov    %esi,%eax
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	8b 75 08             	mov    0x8(%ebp),%esi
  800b1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1f:	8b 55 10             	mov    0x10(%ebp),%edx
  800b22:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b24:	85 d2                	test   %edx,%edx
  800b26:	74 21                	je     800b49 <strlcpy+0x35>
  800b28:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b2c:	89 f2                	mov    %esi,%edx
  800b2e:	eb 09                	jmp    800b39 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b30:	83 c2 01             	add    $0x1,%edx
  800b33:	83 c1 01             	add    $0x1,%ecx
  800b36:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b39:	39 c2                	cmp    %eax,%edx
  800b3b:	74 09                	je     800b46 <strlcpy+0x32>
  800b3d:	0f b6 19             	movzbl (%ecx),%ebx
  800b40:	84 db                	test   %bl,%bl
  800b42:	75 ec                	jne    800b30 <strlcpy+0x1c>
  800b44:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b46:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b49:	29 f0                	sub    %esi,%eax
}
  800b4b:	5b                   	pop    %ebx
  800b4c:	5e                   	pop    %esi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b55:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b58:	eb 06                	jmp    800b60 <strcmp+0x11>
		p++, q++;
  800b5a:	83 c1 01             	add    $0x1,%ecx
  800b5d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b60:	0f b6 01             	movzbl (%ecx),%eax
  800b63:	84 c0                	test   %al,%al
  800b65:	74 04                	je     800b6b <strcmp+0x1c>
  800b67:	3a 02                	cmp    (%edx),%al
  800b69:	74 ef                	je     800b5a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b6b:	0f b6 c0             	movzbl %al,%eax
  800b6e:	0f b6 12             	movzbl (%edx),%edx
  800b71:	29 d0                	sub    %edx,%eax
}
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	53                   	push   %ebx
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7f:	89 c3                	mov    %eax,%ebx
  800b81:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b84:	eb 06                	jmp    800b8c <strncmp+0x17>
		n--, p++, q++;
  800b86:	83 c0 01             	add    $0x1,%eax
  800b89:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b8c:	39 d8                	cmp    %ebx,%eax
  800b8e:	74 15                	je     800ba5 <strncmp+0x30>
  800b90:	0f b6 08             	movzbl (%eax),%ecx
  800b93:	84 c9                	test   %cl,%cl
  800b95:	74 04                	je     800b9b <strncmp+0x26>
  800b97:	3a 0a                	cmp    (%edx),%cl
  800b99:	74 eb                	je     800b86 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b9b:	0f b6 00             	movzbl (%eax),%eax
  800b9e:	0f b6 12             	movzbl (%edx),%edx
  800ba1:	29 d0                	sub    %edx,%eax
  800ba3:	eb 05                	jmp    800baa <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ba5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800baa:	5b                   	pop    %ebx
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb7:	eb 07                	jmp    800bc0 <strchr+0x13>
		if (*s == c)
  800bb9:	38 ca                	cmp    %cl,%dl
  800bbb:	74 0f                	je     800bcc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bbd:	83 c0 01             	add    $0x1,%eax
  800bc0:	0f b6 10             	movzbl (%eax),%edx
  800bc3:	84 d2                	test   %dl,%dl
  800bc5:	75 f2                	jne    800bb9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800bc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bd8:	eb 03                	jmp    800bdd <strfind+0xf>
  800bda:	83 c0 01             	add    $0x1,%eax
  800bdd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800be0:	38 ca                	cmp    %cl,%dl
  800be2:	74 04                	je     800be8 <strfind+0x1a>
  800be4:	84 d2                	test   %dl,%dl
  800be6:	75 f2                	jne    800bda <strfind+0xc>
			break;
	return (char *) s;
}
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bf3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bf6:	85 c9                	test   %ecx,%ecx
  800bf8:	74 36                	je     800c30 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bfa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c00:	75 28                	jne    800c2a <memset+0x40>
  800c02:	f6 c1 03             	test   $0x3,%cl
  800c05:	75 23                	jne    800c2a <memset+0x40>
		c &= 0xFF;
  800c07:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c0b:	89 d3                	mov    %edx,%ebx
  800c0d:	c1 e3 08             	shl    $0x8,%ebx
  800c10:	89 d6                	mov    %edx,%esi
  800c12:	c1 e6 18             	shl    $0x18,%esi
  800c15:	89 d0                	mov    %edx,%eax
  800c17:	c1 e0 10             	shl    $0x10,%eax
  800c1a:	09 f0                	or     %esi,%eax
  800c1c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c1e:	89 d8                	mov    %ebx,%eax
  800c20:	09 d0                	or     %edx,%eax
  800c22:	c1 e9 02             	shr    $0x2,%ecx
  800c25:	fc                   	cld    
  800c26:	f3 ab                	rep stos %eax,%es:(%edi)
  800c28:	eb 06                	jmp    800c30 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2d:	fc                   	cld    
  800c2e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c30:	89 f8                	mov    %edi,%eax
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c42:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c45:	39 c6                	cmp    %eax,%esi
  800c47:	73 35                	jae    800c7e <memmove+0x47>
  800c49:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c4c:	39 d0                	cmp    %edx,%eax
  800c4e:	73 2e                	jae    800c7e <memmove+0x47>
		s += n;
		d += n;
  800c50:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c53:	89 d6                	mov    %edx,%esi
  800c55:	09 fe                	or     %edi,%esi
  800c57:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c5d:	75 13                	jne    800c72 <memmove+0x3b>
  800c5f:	f6 c1 03             	test   $0x3,%cl
  800c62:	75 0e                	jne    800c72 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c64:	83 ef 04             	sub    $0x4,%edi
  800c67:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c6a:	c1 e9 02             	shr    $0x2,%ecx
  800c6d:	fd                   	std    
  800c6e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c70:	eb 09                	jmp    800c7b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c72:	83 ef 01             	sub    $0x1,%edi
  800c75:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c78:	fd                   	std    
  800c79:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c7b:	fc                   	cld    
  800c7c:	eb 1d                	jmp    800c9b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c7e:	89 f2                	mov    %esi,%edx
  800c80:	09 c2                	or     %eax,%edx
  800c82:	f6 c2 03             	test   $0x3,%dl
  800c85:	75 0f                	jne    800c96 <memmove+0x5f>
  800c87:	f6 c1 03             	test   $0x3,%cl
  800c8a:	75 0a                	jne    800c96 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c8c:	c1 e9 02             	shr    $0x2,%ecx
  800c8f:	89 c7                	mov    %eax,%edi
  800c91:	fc                   	cld    
  800c92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c94:	eb 05                	jmp    800c9b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c96:	89 c7                	mov    %eax,%edi
  800c98:	fc                   	cld    
  800c99:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ca2:	ff 75 10             	pushl  0x10(%ebp)
  800ca5:	ff 75 0c             	pushl  0xc(%ebp)
  800ca8:	ff 75 08             	pushl  0x8(%ebp)
  800cab:	e8 87 ff ff ff       	call   800c37 <memmove>
}
  800cb0:	c9                   	leave  
  800cb1:	c3                   	ret    

00800cb2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cba:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbd:	89 c6                	mov    %eax,%esi
  800cbf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc2:	eb 1a                	jmp    800cde <memcmp+0x2c>
		if (*s1 != *s2)
  800cc4:	0f b6 08             	movzbl (%eax),%ecx
  800cc7:	0f b6 1a             	movzbl (%edx),%ebx
  800cca:	38 d9                	cmp    %bl,%cl
  800ccc:	74 0a                	je     800cd8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800cce:	0f b6 c1             	movzbl %cl,%eax
  800cd1:	0f b6 db             	movzbl %bl,%ebx
  800cd4:	29 d8                	sub    %ebx,%eax
  800cd6:	eb 0f                	jmp    800ce7 <memcmp+0x35>
		s1++, s2++;
  800cd8:	83 c0 01             	add    $0x1,%eax
  800cdb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cde:	39 f0                	cmp    %esi,%eax
  800ce0:	75 e2                	jne    800cc4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ce2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	53                   	push   %ebx
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cf2:	89 c1                	mov    %eax,%ecx
  800cf4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cfb:	eb 0a                	jmp    800d07 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cfd:	0f b6 10             	movzbl (%eax),%edx
  800d00:	39 da                	cmp    %ebx,%edx
  800d02:	74 07                	je     800d0b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d04:	83 c0 01             	add    $0x1,%eax
  800d07:	39 c8                	cmp    %ecx,%eax
  800d09:	72 f2                	jb     800cfd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d0b:	5b                   	pop    %ebx
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d1a:	eb 03                	jmp    800d1f <strtol+0x11>
		s++;
  800d1c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d1f:	0f b6 01             	movzbl (%ecx),%eax
  800d22:	3c 20                	cmp    $0x20,%al
  800d24:	74 f6                	je     800d1c <strtol+0xe>
  800d26:	3c 09                	cmp    $0x9,%al
  800d28:	74 f2                	je     800d1c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d2a:	3c 2b                	cmp    $0x2b,%al
  800d2c:	75 0a                	jne    800d38 <strtol+0x2a>
		s++;
  800d2e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d31:	bf 00 00 00 00       	mov    $0x0,%edi
  800d36:	eb 11                	jmp    800d49 <strtol+0x3b>
  800d38:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d3d:	3c 2d                	cmp    $0x2d,%al
  800d3f:	75 08                	jne    800d49 <strtol+0x3b>
		s++, neg = 1;
  800d41:	83 c1 01             	add    $0x1,%ecx
  800d44:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d49:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d4f:	75 15                	jne    800d66 <strtol+0x58>
  800d51:	80 39 30             	cmpb   $0x30,(%ecx)
  800d54:	75 10                	jne    800d66 <strtol+0x58>
  800d56:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d5a:	75 7c                	jne    800dd8 <strtol+0xca>
		s += 2, base = 16;
  800d5c:	83 c1 02             	add    $0x2,%ecx
  800d5f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d64:	eb 16                	jmp    800d7c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d66:	85 db                	test   %ebx,%ebx
  800d68:	75 12                	jne    800d7c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d6a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d6f:	80 39 30             	cmpb   $0x30,(%ecx)
  800d72:	75 08                	jne    800d7c <strtol+0x6e>
		s++, base = 8;
  800d74:	83 c1 01             	add    $0x1,%ecx
  800d77:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d81:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d84:	0f b6 11             	movzbl (%ecx),%edx
  800d87:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d8a:	89 f3                	mov    %esi,%ebx
  800d8c:	80 fb 09             	cmp    $0x9,%bl
  800d8f:	77 08                	ja     800d99 <strtol+0x8b>
			dig = *s - '0';
  800d91:	0f be d2             	movsbl %dl,%edx
  800d94:	83 ea 30             	sub    $0x30,%edx
  800d97:	eb 22                	jmp    800dbb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d99:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d9c:	89 f3                	mov    %esi,%ebx
  800d9e:	80 fb 19             	cmp    $0x19,%bl
  800da1:	77 08                	ja     800dab <strtol+0x9d>
			dig = *s - 'a' + 10;
  800da3:	0f be d2             	movsbl %dl,%edx
  800da6:	83 ea 57             	sub    $0x57,%edx
  800da9:	eb 10                	jmp    800dbb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800dab:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dae:	89 f3                	mov    %esi,%ebx
  800db0:	80 fb 19             	cmp    $0x19,%bl
  800db3:	77 16                	ja     800dcb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800db5:	0f be d2             	movsbl %dl,%edx
  800db8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800dbb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800dbe:	7d 0b                	jge    800dcb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800dc0:	83 c1 01             	add    $0x1,%ecx
  800dc3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dc7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800dc9:	eb b9                	jmp    800d84 <strtol+0x76>

	if (endptr)
  800dcb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dcf:	74 0d                	je     800dde <strtol+0xd0>
		*endptr = (char *) s;
  800dd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd4:	89 0e                	mov    %ecx,(%esi)
  800dd6:	eb 06                	jmp    800dde <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dd8:	85 db                	test   %ebx,%ebx
  800dda:	74 98                	je     800d74 <strtol+0x66>
  800ddc:	eb 9e                	jmp    800d7c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800dde:	89 c2                	mov    %eax,%edx
  800de0:	f7 da                	neg    %edx
  800de2:	85 ff                	test   %edi,%edi
  800de4:	0f 45 c2             	cmovne %edx,%eax
}
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df2:	b8 00 00 00 00       	mov    $0x0,%eax
  800df7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfd:	89 c3                	mov    %eax,%ebx
  800dff:	89 c7                	mov    %eax,%edi
  800e01:	89 c6                	mov    %eax,%esi
  800e03:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_cgetc>:

int
sys_cgetc(void)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e10:	ba 00 00 00 00       	mov    $0x0,%edx
  800e15:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1a:	89 d1                	mov    %edx,%ecx
  800e1c:	89 d3                	mov    %edx,%ebx
  800e1e:	89 d7                	mov    %edx,%edi
  800e20:	89 d6                	mov    %edx,%esi
  800e22:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e37:	b8 03 00 00 00       	mov    $0x3,%eax
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	89 cb                	mov    %ecx,%ebx
  800e41:	89 cf                	mov    %ecx,%edi
  800e43:	89 ce                	mov    %ecx,%esi
  800e45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7e 17                	jle    800e62 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	50                   	push   %eax
  800e4f:	6a 03                	push   $0x3
  800e51:	68 9f 2a 80 00       	push   $0x802a9f
  800e56:	6a 23                	push   $0x23
  800e58:	68 bc 2a 80 00       	push   $0x802abc
  800e5d:	e8 e5 f5 ff ff       	call   800447 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e70:	ba 00 00 00 00       	mov    $0x0,%edx
  800e75:	b8 02 00 00 00       	mov    $0x2,%eax
  800e7a:	89 d1                	mov    %edx,%ecx
  800e7c:	89 d3                	mov    %edx,%ebx
  800e7e:	89 d7                	mov    %edx,%edi
  800e80:	89 d6                	mov    %edx,%esi
  800e82:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_yield>:

void
sys_yield(void)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e94:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e99:	89 d1                	mov    %edx,%ecx
  800e9b:	89 d3                	mov    %edx,%ebx
  800e9d:	89 d7                	mov    %edx,%edi
  800e9f:	89 d6                	mov    %edx,%esi
  800ea1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
  800eae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb1:	be 00 00 00 00       	mov    $0x0,%esi
  800eb6:	b8 04 00 00 00       	mov    $0x4,%eax
  800ebb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebe:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec4:	89 f7                	mov    %esi,%edi
  800ec6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	7e 17                	jle    800ee3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecc:	83 ec 0c             	sub    $0xc,%esp
  800ecf:	50                   	push   %eax
  800ed0:	6a 04                	push   $0x4
  800ed2:	68 9f 2a 80 00       	push   $0x802a9f
  800ed7:	6a 23                	push   $0x23
  800ed9:	68 bc 2a 80 00       	push   $0x802abc
  800ede:	e8 64 f5 ff ff       	call   800447 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ee3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee6:	5b                   	pop    %ebx
  800ee7:	5e                   	pop    %esi
  800ee8:	5f                   	pop    %edi
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	57                   	push   %edi
  800eef:	56                   	push   %esi
  800ef0:	53                   	push   %ebx
  800ef1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef4:	b8 05 00 00 00       	mov    $0x5,%eax
  800ef9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efc:	8b 55 08             	mov    0x8(%ebp),%edx
  800eff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f05:	8b 75 18             	mov    0x18(%ebp),%esi
  800f08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	7e 17                	jle    800f25 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0e:	83 ec 0c             	sub    $0xc,%esp
  800f11:	50                   	push   %eax
  800f12:	6a 05                	push   $0x5
  800f14:	68 9f 2a 80 00       	push   $0x802a9f
  800f19:	6a 23                	push   $0x23
  800f1b:	68 bc 2a 80 00       	push   $0x802abc
  800f20:	e8 22 f5 ff ff       	call   800447 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	57                   	push   %edi
  800f31:	56                   	push   %esi
  800f32:	53                   	push   %ebx
  800f33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3b:	b8 06 00 00 00       	mov    $0x6,%eax
  800f40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f43:	8b 55 08             	mov    0x8(%ebp),%edx
  800f46:	89 df                	mov    %ebx,%edi
  800f48:	89 de                	mov    %ebx,%esi
  800f4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	7e 17                	jle    800f67 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f50:	83 ec 0c             	sub    $0xc,%esp
  800f53:	50                   	push   %eax
  800f54:	6a 06                	push   $0x6
  800f56:	68 9f 2a 80 00       	push   $0x802a9f
  800f5b:	6a 23                	push   $0x23
  800f5d:	68 bc 2a 80 00       	push   $0x802abc
  800f62:	e8 e0 f4 ff ff       	call   800447 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6a:	5b                   	pop    %ebx
  800f6b:	5e                   	pop    %esi
  800f6c:	5f                   	pop    %edi
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    

00800f6f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	57                   	push   %edi
  800f73:	56                   	push   %esi
  800f74:	53                   	push   %ebx
  800f75:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7d:	b8 08 00 00 00       	mov    $0x8,%eax
  800f82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f85:	8b 55 08             	mov    0x8(%ebp),%edx
  800f88:	89 df                	mov    %ebx,%edi
  800f8a:	89 de                	mov    %ebx,%esi
  800f8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	7e 17                	jle    800fa9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f92:	83 ec 0c             	sub    $0xc,%esp
  800f95:	50                   	push   %eax
  800f96:	6a 08                	push   $0x8
  800f98:	68 9f 2a 80 00       	push   $0x802a9f
  800f9d:	6a 23                	push   $0x23
  800f9f:	68 bc 2a 80 00       	push   $0x802abc
  800fa4:	e8 9e f4 ff ff       	call   800447 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fac:	5b                   	pop    %ebx
  800fad:	5e                   	pop    %esi
  800fae:	5f                   	pop    %edi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    

00800fb1 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	57                   	push   %edi
  800fb5:	56                   	push   %esi
  800fb6:	53                   	push   %ebx
  800fb7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbf:	b8 09 00 00 00       	mov    $0x9,%eax
  800fc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fca:	89 df                	mov    %ebx,%edi
  800fcc:	89 de                	mov    %ebx,%esi
  800fce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	7e 17                	jle    800feb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd4:	83 ec 0c             	sub    $0xc,%esp
  800fd7:	50                   	push   %eax
  800fd8:	6a 09                	push   $0x9
  800fda:	68 9f 2a 80 00       	push   $0x802a9f
  800fdf:	6a 23                	push   $0x23
  800fe1:	68 bc 2a 80 00       	push   $0x802abc
  800fe6:	e8 5c f4 ff ff       	call   800447 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800feb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fee:	5b                   	pop    %ebx
  800fef:	5e                   	pop    %esi
  800ff0:	5f                   	pop    %edi
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    

00800ff3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	57                   	push   %edi
  800ff7:	56                   	push   %esi
  800ff8:	53                   	push   %ebx
  800ff9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801001:	b8 0a 00 00 00       	mov    $0xa,%eax
  801006:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801009:	8b 55 08             	mov    0x8(%ebp),%edx
  80100c:	89 df                	mov    %ebx,%edi
  80100e:	89 de                	mov    %ebx,%esi
  801010:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801012:	85 c0                	test   %eax,%eax
  801014:	7e 17                	jle    80102d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	50                   	push   %eax
  80101a:	6a 0a                	push   $0xa
  80101c:	68 9f 2a 80 00       	push   $0x802a9f
  801021:	6a 23                	push   $0x23
  801023:	68 bc 2a 80 00       	push   $0x802abc
  801028:	e8 1a f4 ff ff       	call   800447 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80102d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801030:	5b                   	pop    %ebx
  801031:	5e                   	pop    %esi
  801032:	5f                   	pop    %edi
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	57                   	push   %edi
  801039:	56                   	push   %esi
  80103a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103b:	be 00 00 00 00       	mov    $0x0,%esi
  801040:	b8 0c 00 00 00       	mov    $0xc,%eax
  801045:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801048:	8b 55 08             	mov    0x8(%ebp),%edx
  80104b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80104e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801051:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
  80105e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801061:	b9 00 00 00 00       	mov    $0x0,%ecx
  801066:	b8 0d 00 00 00       	mov    $0xd,%eax
  80106b:	8b 55 08             	mov    0x8(%ebp),%edx
  80106e:	89 cb                	mov    %ecx,%ebx
  801070:	89 cf                	mov    %ecx,%edi
  801072:	89 ce                	mov    %ecx,%esi
  801074:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801076:	85 c0                	test   %eax,%eax
  801078:	7e 17                	jle    801091 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107a:	83 ec 0c             	sub    $0xc,%esp
  80107d:	50                   	push   %eax
  80107e:	6a 0d                	push   $0xd
  801080:	68 9f 2a 80 00       	push   $0x802a9f
  801085:	6a 23                	push   $0x23
  801087:	68 bc 2a 80 00       	push   $0x802abc
  80108c:	e8 b6 f3 ff ff       	call   800447 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801091:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801094:	5b                   	pop    %ebx
  801095:	5e                   	pop    %esi
  801096:	5f                   	pop    %edi
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    

00801099 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80109c:	8b 45 08             	mov    0x8(%ebp),%eax
  80109f:	05 00 00 00 30       	add    $0x30000000,%eax
  8010a4:	c1 e8 0c             	shr    $0xc,%eax
}
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    

008010a9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8010af:	05 00 00 00 30       	add    $0x30000000,%eax
  8010b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010b9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010be:	5d                   	pop    %ebp
  8010bf:	c3                   	ret    

008010c0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010cb:	89 c2                	mov    %eax,%edx
  8010cd:	c1 ea 16             	shr    $0x16,%edx
  8010d0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010d7:	f6 c2 01             	test   $0x1,%dl
  8010da:	74 11                	je     8010ed <fd_alloc+0x2d>
  8010dc:	89 c2                	mov    %eax,%edx
  8010de:	c1 ea 0c             	shr    $0xc,%edx
  8010e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010e8:	f6 c2 01             	test   $0x1,%dl
  8010eb:	75 09                	jne    8010f6 <fd_alloc+0x36>
			*fd_store = fd;
  8010ed:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f4:	eb 17                	jmp    80110d <fd_alloc+0x4d>
  8010f6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010fb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801100:	75 c9                	jne    8010cb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801102:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801108:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    

0080110f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801115:	83 f8 1f             	cmp    $0x1f,%eax
  801118:	77 36                	ja     801150 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80111a:	c1 e0 0c             	shl    $0xc,%eax
  80111d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801122:	89 c2                	mov    %eax,%edx
  801124:	c1 ea 16             	shr    $0x16,%edx
  801127:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112e:	f6 c2 01             	test   $0x1,%dl
  801131:	74 24                	je     801157 <fd_lookup+0x48>
  801133:	89 c2                	mov    %eax,%edx
  801135:	c1 ea 0c             	shr    $0xc,%edx
  801138:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113f:	f6 c2 01             	test   $0x1,%dl
  801142:	74 1a                	je     80115e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801144:	8b 55 0c             	mov    0xc(%ebp),%edx
  801147:	89 02                	mov    %eax,(%edx)
	return 0;
  801149:	b8 00 00 00 00       	mov    $0x0,%eax
  80114e:	eb 13                	jmp    801163 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801150:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801155:	eb 0c                	jmp    801163 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801157:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80115c:	eb 05                	jmp    801163 <fd_lookup+0x54>
  80115e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	83 ec 08             	sub    $0x8,%esp
  80116b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116e:	ba 48 2b 80 00       	mov    $0x802b48,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801173:	eb 13                	jmp    801188 <dev_lookup+0x23>
  801175:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801178:	39 08                	cmp    %ecx,(%eax)
  80117a:	75 0c                	jne    801188 <dev_lookup+0x23>
			*dev = devtab[i];
  80117c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801181:	b8 00 00 00 00       	mov    $0x0,%eax
  801186:	eb 2e                	jmp    8011b6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801188:	8b 02                	mov    (%edx),%eax
  80118a:	85 c0                	test   %eax,%eax
  80118c:	75 e7                	jne    801175 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80118e:	a1 90 67 80 00       	mov    0x806790,%eax
  801193:	8b 40 48             	mov    0x48(%eax),%eax
  801196:	83 ec 04             	sub    $0x4,%esp
  801199:	51                   	push   %ecx
  80119a:	50                   	push   %eax
  80119b:	68 cc 2a 80 00       	push   $0x802acc
  8011a0:	e8 7b f3 ff ff       	call   800520 <cprintf>
	*dev = 0;
  8011a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011b6:	c9                   	leave  
  8011b7:	c3                   	ret    

008011b8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	56                   	push   %esi
  8011bc:	53                   	push   %ebx
  8011bd:	83 ec 10             	sub    $0x10,%esp
  8011c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8011c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011d0:	c1 e8 0c             	shr    $0xc,%eax
  8011d3:	50                   	push   %eax
  8011d4:	e8 36 ff ff ff       	call   80110f <fd_lookup>
  8011d9:	83 c4 08             	add    $0x8,%esp
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 05                	js     8011e5 <fd_close+0x2d>
	    || fd != fd2)
  8011e0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011e3:	74 0c                	je     8011f1 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011e5:	84 db                	test   %bl,%bl
  8011e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ec:	0f 44 c2             	cmove  %edx,%eax
  8011ef:	eb 41                	jmp    801232 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011f1:	83 ec 08             	sub    $0x8,%esp
  8011f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f7:	50                   	push   %eax
  8011f8:	ff 36                	pushl  (%esi)
  8011fa:	e8 66 ff ff ff       	call   801165 <dev_lookup>
  8011ff:	89 c3                	mov    %eax,%ebx
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	78 1a                	js     801222 <fd_close+0x6a>
		if (dev->dev_close)
  801208:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80120e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801213:	85 c0                	test   %eax,%eax
  801215:	74 0b                	je     801222 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801217:	83 ec 0c             	sub    $0xc,%esp
  80121a:	56                   	push   %esi
  80121b:	ff d0                	call   *%eax
  80121d:	89 c3                	mov    %eax,%ebx
  80121f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801222:	83 ec 08             	sub    $0x8,%esp
  801225:	56                   	push   %esi
  801226:	6a 00                	push   $0x0
  801228:	e8 00 fd ff ff       	call   800f2d <sys_page_unmap>
	return r;
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	89 d8                	mov    %ebx,%eax
}
  801232:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801235:	5b                   	pop    %ebx
  801236:	5e                   	pop    %esi
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80123f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801242:	50                   	push   %eax
  801243:	ff 75 08             	pushl  0x8(%ebp)
  801246:	e8 c4 fe ff ff       	call   80110f <fd_lookup>
  80124b:	83 c4 08             	add    $0x8,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 10                	js     801262 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801252:	83 ec 08             	sub    $0x8,%esp
  801255:	6a 01                	push   $0x1
  801257:	ff 75 f4             	pushl  -0xc(%ebp)
  80125a:	e8 59 ff ff ff       	call   8011b8 <fd_close>
  80125f:	83 c4 10             	add    $0x10,%esp
}
  801262:	c9                   	leave  
  801263:	c3                   	ret    

00801264 <close_all>:

void
close_all(void)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	53                   	push   %ebx
  801268:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80126b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801270:	83 ec 0c             	sub    $0xc,%esp
  801273:	53                   	push   %ebx
  801274:	e8 c0 ff ff ff       	call   801239 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801279:	83 c3 01             	add    $0x1,%ebx
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	83 fb 20             	cmp    $0x20,%ebx
  801282:	75 ec                	jne    801270 <close_all+0xc>
		close(i);
}
  801284:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801287:	c9                   	leave  
  801288:	c3                   	ret    

00801289 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	57                   	push   %edi
  80128d:	56                   	push   %esi
  80128e:	53                   	push   %ebx
  80128f:	83 ec 2c             	sub    $0x2c,%esp
  801292:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801295:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	ff 75 08             	pushl  0x8(%ebp)
  80129c:	e8 6e fe ff ff       	call   80110f <fd_lookup>
  8012a1:	83 c4 08             	add    $0x8,%esp
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	0f 88 c1 00 00 00    	js     80136d <dup+0xe4>
		return r;
	close(newfdnum);
  8012ac:	83 ec 0c             	sub    $0xc,%esp
  8012af:	56                   	push   %esi
  8012b0:	e8 84 ff ff ff       	call   801239 <close>

	newfd = INDEX2FD(newfdnum);
  8012b5:	89 f3                	mov    %esi,%ebx
  8012b7:	c1 e3 0c             	shl    $0xc,%ebx
  8012ba:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012c0:	83 c4 04             	add    $0x4,%esp
  8012c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012c6:	e8 de fd ff ff       	call   8010a9 <fd2data>
  8012cb:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012cd:	89 1c 24             	mov    %ebx,(%esp)
  8012d0:	e8 d4 fd ff ff       	call   8010a9 <fd2data>
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012db:	89 f8                	mov    %edi,%eax
  8012dd:	c1 e8 16             	shr    $0x16,%eax
  8012e0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012e7:	a8 01                	test   $0x1,%al
  8012e9:	74 37                	je     801322 <dup+0x99>
  8012eb:	89 f8                	mov    %edi,%eax
  8012ed:	c1 e8 0c             	shr    $0xc,%eax
  8012f0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012f7:	f6 c2 01             	test   $0x1,%dl
  8012fa:	74 26                	je     801322 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801303:	83 ec 0c             	sub    $0xc,%esp
  801306:	25 07 0e 00 00       	and    $0xe07,%eax
  80130b:	50                   	push   %eax
  80130c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80130f:	6a 00                	push   $0x0
  801311:	57                   	push   %edi
  801312:	6a 00                	push   $0x0
  801314:	e8 d2 fb ff ff       	call   800eeb <sys_page_map>
  801319:	89 c7                	mov    %eax,%edi
  80131b:	83 c4 20             	add    $0x20,%esp
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 2e                	js     801350 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801322:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801325:	89 d0                	mov    %edx,%eax
  801327:	c1 e8 0c             	shr    $0xc,%eax
  80132a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801331:	83 ec 0c             	sub    $0xc,%esp
  801334:	25 07 0e 00 00       	and    $0xe07,%eax
  801339:	50                   	push   %eax
  80133a:	53                   	push   %ebx
  80133b:	6a 00                	push   $0x0
  80133d:	52                   	push   %edx
  80133e:	6a 00                	push   $0x0
  801340:	e8 a6 fb ff ff       	call   800eeb <sys_page_map>
  801345:	89 c7                	mov    %eax,%edi
  801347:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80134a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80134c:	85 ff                	test   %edi,%edi
  80134e:	79 1d                	jns    80136d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801350:	83 ec 08             	sub    $0x8,%esp
  801353:	53                   	push   %ebx
  801354:	6a 00                	push   $0x0
  801356:	e8 d2 fb ff ff       	call   800f2d <sys_page_unmap>
	sys_page_unmap(0, nva);
  80135b:	83 c4 08             	add    $0x8,%esp
  80135e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801361:	6a 00                	push   $0x0
  801363:	e8 c5 fb ff ff       	call   800f2d <sys_page_unmap>
	return r;
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	89 f8                	mov    %edi,%eax
}
  80136d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5f                   	pop    %edi
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    

00801375 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	53                   	push   %ebx
  801379:	83 ec 14             	sub    $0x14,%esp
  80137c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801382:	50                   	push   %eax
  801383:	53                   	push   %ebx
  801384:	e8 86 fd ff ff       	call   80110f <fd_lookup>
  801389:	83 c4 08             	add    $0x8,%esp
  80138c:	89 c2                	mov    %eax,%edx
  80138e:	85 c0                	test   %eax,%eax
  801390:	78 6d                	js     8013ff <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801392:	83 ec 08             	sub    $0x8,%esp
  801395:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139c:	ff 30                	pushl  (%eax)
  80139e:	e8 c2 fd ff ff       	call   801165 <dev_lookup>
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	78 4c                	js     8013f6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013ad:	8b 42 08             	mov    0x8(%edx),%eax
  8013b0:	83 e0 03             	and    $0x3,%eax
  8013b3:	83 f8 01             	cmp    $0x1,%eax
  8013b6:	75 21                	jne    8013d9 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013b8:	a1 90 67 80 00       	mov    0x806790,%eax
  8013bd:	8b 40 48             	mov    0x48(%eax),%eax
  8013c0:	83 ec 04             	sub    $0x4,%esp
  8013c3:	53                   	push   %ebx
  8013c4:	50                   	push   %eax
  8013c5:	68 0d 2b 80 00       	push   $0x802b0d
  8013ca:	e8 51 f1 ff ff       	call   800520 <cprintf>
		return -E_INVAL;
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013d7:	eb 26                	jmp    8013ff <read+0x8a>
	}
	if (!dev->dev_read)
  8013d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013dc:	8b 40 08             	mov    0x8(%eax),%eax
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	74 17                	je     8013fa <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013e3:	83 ec 04             	sub    $0x4,%esp
  8013e6:	ff 75 10             	pushl  0x10(%ebp)
  8013e9:	ff 75 0c             	pushl  0xc(%ebp)
  8013ec:	52                   	push   %edx
  8013ed:	ff d0                	call   *%eax
  8013ef:	89 c2                	mov    %eax,%edx
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	eb 09                	jmp    8013ff <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f6:	89 c2                	mov    %eax,%edx
  8013f8:	eb 05                	jmp    8013ff <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013fa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8013ff:	89 d0                	mov    %edx,%eax
  801401:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801404:	c9                   	leave  
  801405:	c3                   	ret    

00801406 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	57                   	push   %edi
  80140a:	56                   	push   %esi
  80140b:	53                   	push   %ebx
  80140c:	83 ec 0c             	sub    $0xc,%esp
  80140f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801412:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801415:	bb 00 00 00 00       	mov    $0x0,%ebx
  80141a:	eb 21                	jmp    80143d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80141c:	83 ec 04             	sub    $0x4,%esp
  80141f:	89 f0                	mov    %esi,%eax
  801421:	29 d8                	sub    %ebx,%eax
  801423:	50                   	push   %eax
  801424:	89 d8                	mov    %ebx,%eax
  801426:	03 45 0c             	add    0xc(%ebp),%eax
  801429:	50                   	push   %eax
  80142a:	57                   	push   %edi
  80142b:	e8 45 ff ff ff       	call   801375 <read>
		if (m < 0)
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	85 c0                	test   %eax,%eax
  801435:	78 10                	js     801447 <readn+0x41>
			return m;
		if (m == 0)
  801437:	85 c0                	test   %eax,%eax
  801439:	74 0a                	je     801445 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80143b:	01 c3                	add    %eax,%ebx
  80143d:	39 f3                	cmp    %esi,%ebx
  80143f:	72 db                	jb     80141c <readn+0x16>
  801441:	89 d8                	mov    %ebx,%eax
  801443:	eb 02                	jmp    801447 <readn+0x41>
  801445:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801447:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144a:	5b                   	pop    %ebx
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    

0080144f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	53                   	push   %ebx
  801453:	83 ec 14             	sub    $0x14,%esp
  801456:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801459:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145c:	50                   	push   %eax
  80145d:	53                   	push   %ebx
  80145e:	e8 ac fc ff ff       	call   80110f <fd_lookup>
  801463:	83 c4 08             	add    $0x8,%esp
  801466:	89 c2                	mov    %eax,%edx
  801468:	85 c0                	test   %eax,%eax
  80146a:	78 68                	js     8014d4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146c:	83 ec 08             	sub    $0x8,%esp
  80146f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801472:	50                   	push   %eax
  801473:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801476:	ff 30                	pushl  (%eax)
  801478:	e8 e8 fc ff ff       	call   801165 <dev_lookup>
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	85 c0                	test   %eax,%eax
  801482:	78 47                	js     8014cb <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801484:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801487:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80148b:	75 21                	jne    8014ae <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80148d:	a1 90 67 80 00       	mov    0x806790,%eax
  801492:	8b 40 48             	mov    0x48(%eax),%eax
  801495:	83 ec 04             	sub    $0x4,%esp
  801498:	53                   	push   %ebx
  801499:	50                   	push   %eax
  80149a:	68 29 2b 80 00       	push   $0x802b29
  80149f:	e8 7c f0 ff ff       	call   800520 <cprintf>
		return -E_INVAL;
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ac:	eb 26                	jmp    8014d4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b1:	8b 52 0c             	mov    0xc(%edx),%edx
  8014b4:	85 d2                	test   %edx,%edx
  8014b6:	74 17                	je     8014cf <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014b8:	83 ec 04             	sub    $0x4,%esp
  8014bb:	ff 75 10             	pushl  0x10(%ebp)
  8014be:	ff 75 0c             	pushl  0xc(%ebp)
  8014c1:	50                   	push   %eax
  8014c2:	ff d2                	call   *%edx
  8014c4:	89 c2                	mov    %eax,%edx
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	eb 09                	jmp    8014d4 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cb:	89 c2                	mov    %eax,%edx
  8014cd:	eb 05                	jmp    8014d4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014d4:	89 d0                	mov    %edx,%eax
  8014d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <seek>:

int
seek(int fdnum, off_t offset)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014e4:	50                   	push   %eax
  8014e5:	ff 75 08             	pushl  0x8(%ebp)
  8014e8:	e8 22 fc ff ff       	call   80110f <fd_lookup>
  8014ed:	83 c4 08             	add    $0x8,%esp
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	78 0e                	js     801502 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014fa:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801502:	c9                   	leave  
  801503:	c3                   	ret    

00801504 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	53                   	push   %ebx
  801508:	83 ec 14             	sub    $0x14,%esp
  80150b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801511:	50                   	push   %eax
  801512:	53                   	push   %ebx
  801513:	e8 f7 fb ff ff       	call   80110f <fd_lookup>
  801518:	83 c4 08             	add    $0x8,%esp
  80151b:	89 c2                	mov    %eax,%edx
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 65                	js     801586 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801521:	83 ec 08             	sub    $0x8,%esp
  801524:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801527:	50                   	push   %eax
  801528:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152b:	ff 30                	pushl  (%eax)
  80152d:	e8 33 fc ff ff       	call   801165 <dev_lookup>
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	85 c0                	test   %eax,%eax
  801537:	78 44                	js     80157d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801539:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801540:	75 21                	jne    801563 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801542:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801547:	8b 40 48             	mov    0x48(%eax),%eax
  80154a:	83 ec 04             	sub    $0x4,%esp
  80154d:	53                   	push   %ebx
  80154e:	50                   	push   %eax
  80154f:	68 ec 2a 80 00       	push   $0x802aec
  801554:	e8 c7 ef ff ff       	call   800520 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801561:	eb 23                	jmp    801586 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801563:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801566:	8b 52 18             	mov    0x18(%edx),%edx
  801569:	85 d2                	test   %edx,%edx
  80156b:	74 14                	je     801581 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80156d:	83 ec 08             	sub    $0x8,%esp
  801570:	ff 75 0c             	pushl  0xc(%ebp)
  801573:	50                   	push   %eax
  801574:	ff d2                	call   *%edx
  801576:	89 c2                	mov    %eax,%edx
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	eb 09                	jmp    801586 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	eb 05                	jmp    801586 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801581:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801586:	89 d0                	mov    %edx,%eax
  801588:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158b:	c9                   	leave  
  80158c:	c3                   	ret    

0080158d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80158d:	55                   	push   %ebp
  80158e:	89 e5                	mov    %esp,%ebp
  801590:	53                   	push   %ebx
  801591:	83 ec 14             	sub    $0x14,%esp
  801594:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801597:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159a:	50                   	push   %eax
  80159b:	ff 75 08             	pushl  0x8(%ebp)
  80159e:	e8 6c fb ff ff       	call   80110f <fd_lookup>
  8015a3:	83 c4 08             	add    $0x8,%esp
  8015a6:	89 c2                	mov    %eax,%edx
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 58                	js     801604 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b2:	50                   	push   %eax
  8015b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b6:	ff 30                	pushl  (%eax)
  8015b8:	e8 a8 fb ff ff       	call   801165 <dev_lookup>
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 37                	js     8015fb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015cb:	74 32                	je     8015ff <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015cd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015d0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015d7:	00 00 00 
	stat->st_isdir = 0;
  8015da:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015e1:	00 00 00 
	stat->st_dev = dev;
  8015e4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015ea:	83 ec 08             	sub    $0x8,%esp
  8015ed:	53                   	push   %ebx
  8015ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8015f1:	ff 50 14             	call   *0x14(%eax)
  8015f4:	89 c2                	mov    %eax,%edx
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	eb 09                	jmp    801604 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fb:	89 c2                	mov    %eax,%edx
  8015fd:	eb 05                	jmp    801604 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015ff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801604:	89 d0                	mov    %edx,%eax
  801606:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801609:	c9                   	leave  
  80160a:	c3                   	ret    

0080160b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	56                   	push   %esi
  80160f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801610:	83 ec 08             	sub    $0x8,%esp
  801613:	6a 00                	push   $0x0
  801615:	ff 75 08             	pushl  0x8(%ebp)
  801618:	e8 e3 01 00 00       	call   801800 <open>
  80161d:	89 c3                	mov    %eax,%ebx
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	85 c0                	test   %eax,%eax
  801624:	78 1b                	js     801641 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801626:	83 ec 08             	sub    $0x8,%esp
  801629:	ff 75 0c             	pushl  0xc(%ebp)
  80162c:	50                   	push   %eax
  80162d:	e8 5b ff ff ff       	call   80158d <fstat>
  801632:	89 c6                	mov    %eax,%esi
	close(fd);
  801634:	89 1c 24             	mov    %ebx,(%esp)
  801637:	e8 fd fb ff ff       	call   801239 <close>
	return r;
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	89 f0                	mov    %esi,%eax
}
  801641:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801644:	5b                   	pop    %ebx
  801645:	5e                   	pop    %esi
  801646:	5d                   	pop    %ebp
  801647:	c3                   	ret    

00801648 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	56                   	push   %esi
  80164c:	53                   	push   %ebx
  80164d:	89 c6                	mov    %eax,%esi
  80164f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801651:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801658:	75 12                	jne    80166c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80165a:	83 ec 0c             	sub    $0xc,%esp
  80165d:	6a 01                	push   $0x1
  80165f:	e8 a1 0c 00 00       	call   802305 <ipc_find_env>
  801664:	a3 00 50 80 00       	mov    %eax,0x805000
  801669:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80166c:	6a 07                	push   $0x7
  80166e:	68 00 70 80 00       	push   $0x807000
  801673:	56                   	push   %esi
  801674:	ff 35 00 50 80 00    	pushl  0x805000
  80167a:	e8 24 0c 00 00       	call   8022a3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80167f:	83 c4 0c             	add    $0xc,%esp
  801682:	6a 00                	push   $0x0
  801684:	53                   	push   %ebx
  801685:	6a 00                	push   $0x0
  801687:	e8 a5 0b 00 00       	call   802231 <ipc_recv>
}
  80168c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168f:	5b                   	pop    %ebx
  801690:	5e                   	pop    %esi
  801691:	5d                   	pop    %ebp
  801692:	c3                   	ret    

00801693 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801699:	8b 45 08             	mov    0x8(%ebp),%eax
  80169c:	8b 40 0c             	mov    0xc(%eax),%eax
  80169f:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8016a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a7:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b1:	b8 02 00 00 00       	mov    $0x2,%eax
  8016b6:	e8 8d ff ff ff       	call   801648 <fsipc>
}
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c9:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d3:	b8 06 00 00 00       	mov    $0x6,%eax
  8016d8:	e8 6b ff ff ff       	call   801648 <fsipc>
}
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	53                   	push   %ebx
  8016e3:	83 ec 04             	sub    $0x4,%esp
  8016e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ef:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8016fe:	e8 45 ff ff ff       	call   801648 <fsipc>
  801703:	85 c0                	test   %eax,%eax
  801705:	78 2c                	js     801733 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801707:	83 ec 08             	sub    $0x8,%esp
  80170a:	68 00 70 80 00       	push   $0x807000
  80170f:	53                   	push   %ebx
  801710:	e8 90 f3 ff ff       	call   800aa5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801715:	a1 80 70 80 00       	mov    0x807080,%eax
  80171a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801720:	a1 84 70 80 00       	mov    0x807084,%eax
  801725:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801733:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801736:	c9                   	leave  
  801737:	c3                   	ret    

00801738 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	83 ec 0c             	sub    $0xc,%esp
  80173e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801741:	8b 55 08             	mov    0x8(%ebp),%edx
  801744:	8b 52 0c             	mov    0xc(%edx),%edx
  801747:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80174d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801752:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801757:	0f 47 c2             	cmova  %edx,%eax
  80175a:	a3 04 70 80 00       	mov    %eax,0x807004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80175f:	50                   	push   %eax
  801760:	ff 75 0c             	pushl  0xc(%ebp)
  801763:	68 08 70 80 00       	push   $0x807008
  801768:	e8 ca f4 ff ff       	call   800c37 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	b8 04 00 00 00       	mov    $0x4,%eax
  801777:	e8 cc fe ff ff       	call   801648 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	56                   	push   %esi
  801782:	53                   	push   %ebx
  801783:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801786:	8b 45 08             	mov    0x8(%ebp),%eax
  801789:	8b 40 0c             	mov    0xc(%eax),%eax
  80178c:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801791:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801797:	ba 00 00 00 00       	mov    $0x0,%edx
  80179c:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a1:	e8 a2 fe ff ff       	call   801648 <fsipc>
  8017a6:	89 c3                	mov    %eax,%ebx
  8017a8:	85 c0                	test   %eax,%eax
  8017aa:	78 4b                	js     8017f7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017ac:	39 c6                	cmp    %eax,%esi
  8017ae:	73 16                	jae    8017c6 <devfile_read+0x48>
  8017b0:	68 58 2b 80 00       	push   $0x802b58
  8017b5:	68 5f 2b 80 00       	push   $0x802b5f
  8017ba:	6a 7c                	push   $0x7c
  8017bc:	68 74 2b 80 00       	push   $0x802b74
  8017c1:	e8 81 ec ff ff       	call   800447 <_panic>
	assert(r <= PGSIZE);
  8017c6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017cb:	7e 16                	jle    8017e3 <devfile_read+0x65>
  8017cd:	68 7f 2b 80 00       	push   $0x802b7f
  8017d2:	68 5f 2b 80 00       	push   $0x802b5f
  8017d7:	6a 7d                	push   $0x7d
  8017d9:	68 74 2b 80 00       	push   $0x802b74
  8017de:	e8 64 ec ff ff       	call   800447 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e3:	83 ec 04             	sub    $0x4,%esp
  8017e6:	50                   	push   %eax
  8017e7:	68 00 70 80 00       	push   $0x807000
  8017ec:	ff 75 0c             	pushl  0xc(%ebp)
  8017ef:	e8 43 f4 ff ff       	call   800c37 <memmove>
	return r;
  8017f4:	83 c4 10             	add    $0x10,%esp
}
  8017f7:	89 d8                	mov    %ebx,%eax
  8017f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fc:	5b                   	pop    %ebx
  8017fd:	5e                   	pop    %esi
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	53                   	push   %ebx
  801804:	83 ec 20             	sub    $0x20,%esp
  801807:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80180a:	53                   	push   %ebx
  80180b:	e8 5c f2 ff ff       	call   800a6c <strlen>
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801818:	7f 67                	jg     801881 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80181a:	83 ec 0c             	sub    $0xc,%esp
  80181d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801820:	50                   	push   %eax
  801821:	e8 9a f8 ff ff       	call   8010c0 <fd_alloc>
  801826:	83 c4 10             	add    $0x10,%esp
		return r;
  801829:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 57                	js     801886 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80182f:	83 ec 08             	sub    $0x8,%esp
  801832:	53                   	push   %ebx
  801833:	68 00 70 80 00       	push   $0x807000
  801838:	e8 68 f2 ff ff       	call   800aa5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80183d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801840:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801845:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801848:	b8 01 00 00 00       	mov    $0x1,%eax
  80184d:	e8 f6 fd ff ff       	call   801648 <fsipc>
  801852:	89 c3                	mov    %eax,%ebx
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	85 c0                	test   %eax,%eax
  801859:	79 14                	jns    80186f <open+0x6f>
		fd_close(fd, 0);
  80185b:	83 ec 08             	sub    $0x8,%esp
  80185e:	6a 00                	push   $0x0
  801860:	ff 75 f4             	pushl  -0xc(%ebp)
  801863:	e8 50 f9 ff ff       	call   8011b8 <fd_close>
		return r;
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	89 da                	mov    %ebx,%edx
  80186d:	eb 17                	jmp    801886 <open+0x86>
	}

	return fd2num(fd);
  80186f:	83 ec 0c             	sub    $0xc,%esp
  801872:	ff 75 f4             	pushl  -0xc(%ebp)
  801875:	e8 1f f8 ff ff       	call   801099 <fd2num>
  80187a:	89 c2                	mov    %eax,%edx
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	eb 05                	jmp    801886 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801881:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801886:	89 d0                	mov    %edx,%eax
  801888:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188b:	c9                   	leave  
  80188c:	c3                   	ret    

0080188d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801893:	ba 00 00 00 00       	mov    $0x0,%edx
  801898:	b8 08 00 00 00       	mov    $0x8,%eax
  80189d:	e8 a6 fd ff ff       	call   801648 <fsipc>
}
  8018a2:	c9                   	leave  
  8018a3:	c3                   	ret    

008018a4 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	57                   	push   %edi
  8018a8:	56                   	push   %esi
  8018a9:	53                   	push   %ebx
  8018aa:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018b0:	6a 00                	push   $0x0
  8018b2:	ff 75 08             	pushl  0x8(%ebp)
  8018b5:	e8 46 ff ff ff       	call   801800 <open>
  8018ba:	89 c7                	mov    %eax,%edi
  8018bc:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018c2:	83 c4 10             	add    $0x10,%esp
  8018c5:	85 c0                	test   %eax,%eax
  8018c7:	0f 88 89 04 00 00    	js     801d56 <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018cd:	83 ec 04             	sub    $0x4,%esp
  8018d0:	68 00 02 00 00       	push   $0x200
  8018d5:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018db:	50                   	push   %eax
  8018dc:	57                   	push   %edi
  8018dd:	e8 24 fb ff ff       	call   801406 <readn>
  8018e2:	83 c4 10             	add    $0x10,%esp
  8018e5:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018ea:	75 0c                	jne    8018f8 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8018ec:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018f3:	45 4c 46 
  8018f6:	74 33                	je     80192b <spawn+0x87>
		close(fd);
  8018f8:	83 ec 0c             	sub    $0xc,%esp
  8018fb:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801901:	e8 33 f9 ff ff       	call   801239 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801906:	83 c4 0c             	add    $0xc,%esp
  801909:	68 7f 45 4c 46       	push   $0x464c457f
  80190e:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801914:	68 8b 2b 80 00       	push   $0x802b8b
  801919:	e8 02 ec ff ff       	call   800520 <cprintf>
		return -E_NOT_EXEC;
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801926:	e9 de 04 00 00       	jmp    801e09 <spawn+0x565>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80192b:	b8 07 00 00 00       	mov    $0x7,%eax
  801930:	cd 30                	int    $0x30
  801932:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801938:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80193e:	85 c0                	test   %eax,%eax
  801940:	0f 88 1b 04 00 00    	js     801d61 <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801946:	89 c6                	mov    %eax,%esi
  801948:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80194e:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801951:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801957:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80195d:	b9 11 00 00 00       	mov    $0x11,%ecx
  801962:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801964:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80196a:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801970:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801975:	be 00 00 00 00       	mov    $0x0,%esi
  80197a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80197d:	eb 13                	jmp    801992 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80197f:	83 ec 0c             	sub    $0xc,%esp
  801982:	50                   	push   %eax
  801983:	e8 e4 f0 ff ff       	call   800a6c <strlen>
  801988:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80198c:	83 c3 01             	add    $0x1,%ebx
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801999:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80199c:	85 c0                	test   %eax,%eax
  80199e:	75 df                	jne    80197f <spawn+0xdb>
  8019a0:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019a6:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019ac:	bf 00 10 40 00       	mov    $0x401000,%edi
  8019b1:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019b3:	89 fa                	mov    %edi,%edx
  8019b5:	83 e2 fc             	and    $0xfffffffc,%edx
  8019b8:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019bf:	29 c2                	sub    %eax,%edx
  8019c1:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019c7:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019ca:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019cf:	0f 86 a2 03 00 00    	jbe    801d77 <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019d5:	83 ec 04             	sub    $0x4,%esp
  8019d8:	6a 07                	push   $0x7
  8019da:	68 00 00 40 00       	push   $0x400000
  8019df:	6a 00                	push   $0x0
  8019e1:	e8 c2 f4 ff ff       	call   800ea8 <sys_page_alloc>
  8019e6:	83 c4 10             	add    $0x10,%esp
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	0f 88 90 03 00 00    	js     801d81 <spawn+0x4dd>
  8019f1:	be 00 00 00 00       	mov    $0x0,%esi
  8019f6:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8019fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ff:	eb 30                	jmp    801a31 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a01:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a07:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801a0d:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801a10:	83 ec 08             	sub    $0x8,%esp
  801a13:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a16:	57                   	push   %edi
  801a17:	e8 89 f0 ff ff       	call   800aa5 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a1c:	83 c4 04             	add    $0x4,%esp
  801a1f:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a22:	e8 45 f0 ff ff       	call   800a6c <strlen>
  801a27:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a2b:	83 c6 01             	add    $0x1,%esi
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a37:	7f c8                	jg     801a01 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a39:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a3f:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a45:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a4c:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a52:	74 19                	je     801a6d <spawn+0x1c9>
  801a54:	68 18 2c 80 00       	push   $0x802c18
  801a59:	68 5f 2b 80 00       	push   $0x802b5f
  801a5e:	68 f2 00 00 00       	push   $0xf2
  801a63:	68 a5 2b 80 00       	push   $0x802ba5
  801a68:	e8 da e9 ff ff       	call   800447 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a6d:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801a73:	89 f8                	mov    %edi,%eax
  801a75:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a7a:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801a7d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a83:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a86:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801a8c:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a92:	83 ec 0c             	sub    $0xc,%esp
  801a95:	6a 07                	push   $0x7
  801a97:	68 00 d0 bf ee       	push   $0xeebfd000
  801a9c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aa2:	68 00 00 40 00       	push   $0x400000
  801aa7:	6a 00                	push   $0x0
  801aa9:	e8 3d f4 ff ff       	call   800eeb <sys_page_map>
  801aae:	89 c3                	mov    %eax,%ebx
  801ab0:	83 c4 20             	add    $0x20,%esp
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	0f 88 3c 03 00 00    	js     801df7 <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801abb:	83 ec 08             	sub    $0x8,%esp
  801abe:	68 00 00 40 00       	push   $0x400000
  801ac3:	6a 00                	push   $0x0
  801ac5:	e8 63 f4 ff ff       	call   800f2d <sys_page_unmap>
  801aca:	89 c3                	mov    %eax,%ebx
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	0f 88 20 03 00 00    	js     801df7 <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ad7:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801add:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ae4:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801aea:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801af1:	00 00 00 
  801af4:	e9 88 01 00 00       	jmp    801c81 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801af9:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801aff:	83 38 01             	cmpl   $0x1,(%eax)
  801b02:	0f 85 6b 01 00 00    	jne    801c73 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b08:	89 c2                	mov    %eax,%edx
  801b0a:	8b 40 18             	mov    0x18(%eax),%eax
  801b0d:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b13:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b16:	83 f8 01             	cmp    $0x1,%eax
  801b19:	19 c0                	sbb    %eax,%eax
  801b1b:	83 e0 fe             	and    $0xfffffffe,%eax
  801b1e:	83 c0 07             	add    $0x7,%eax
  801b21:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b27:	89 d0                	mov    %edx,%eax
  801b29:	8b 7a 04             	mov    0x4(%edx),%edi
  801b2c:	89 f9                	mov    %edi,%ecx
  801b2e:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b34:	8b 7a 10             	mov    0x10(%edx),%edi
  801b37:	8b 52 14             	mov    0x14(%edx),%edx
  801b3a:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801b40:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b43:	89 f0                	mov    %esi,%eax
  801b45:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b4a:	74 14                	je     801b60 <spawn+0x2bc>
		va -= i;
  801b4c:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b4e:	01 c2                	add    %eax,%edx
  801b50:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801b56:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b58:	29 c1                	sub    %eax,%ecx
  801b5a:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b60:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b65:	e9 f7 00 00 00       	jmp    801c61 <spawn+0x3bd>
		if (i >= filesz) {
  801b6a:	39 fb                	cmp    %edi,%ebx
  801b6c:	72 27                	jb     801b95 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b6e:	83 ec 04             	sub    $0x4,%esp
  801b71:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b77:	56                   	push   %esi
  801b78:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b7e:	e8 25 f3 ff ff       	call   800ea8 <sys_page_alloc>
  801b83:	83 c4 10             	add    $0x10,%esp
  801b86:	85 c0                	test   %eax,%eax
  801b88:	0f 89 c7 00 00 00    	jns    801c55 <spawn+0x3b1>
  801b8e:	89 c3                	mov    %eax,%ebx
  801b90:	e9 fd 01 00 00       	jmp    801d92 <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b95:	83 ec 04             	sub    $0x4,%esp
  801b98:	6a 07                	push   $0x7
  801b9a:	68 00 00 40 00       	push   $0x400000
  801b9f:	6a 00                	push   $0x0
  801ba1:	e8 02 f3 ff ff       	call   800ea8 <sys_page_alloc>
  801ba6:	83 c4 10             	add    $0x10,%esp
  801ba9:	85 c0                	test   %eax,%eax
  801bab:	0f 88 d7 01 00 00    	js     801d88 <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801bb1:	83 ec 08             	sub    $0x8,%esp
  801bb4:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bba:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801bc0:	50                   	push   %eax
  801bc1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bc7:	e8 0f f9 ff ff       	call   8014db <seek>
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	85 c0                	test   %eax,%eax
  801bd1:	0f 88 b5 01 00 00    	js     801d8c <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bd7:	83 ec 04             	sub    $0x4,%esp
  801bda:	89 f8                	mov    %edi,%eax
  801bdc:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801be2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801be7:	ba 00 10 00 00       	mov    $0x1000,%edx
  801bec:	0f 47 c2             	cmova  %edx,%eax
  801bef:	50                   	push   %eax
  801bf0:	68 00 00 40 00       	push   $0x400000
  801bf5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bfb:	e8 06 f8 ff ff       	call   801406 <readn>
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	85 c0                	test   %eax,%eax
  801c05:	0f 88 85 01 00 00    	js     801d90 <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c0b:	83 ec 0c             	sub    $0xc,%esp
  801c0e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c14:	56                   	push   %esi
  801c15:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c1b:	68 00 00 40 00       	push   $0x400000
  801c20:	6a 00                	push   $0x0
  801c22:	e8 c4 f2 ff ff       	call   800eeb <sys_page_map>
  801c27:	83 c4 20             	add    $0x20,%esp
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	79 15                	jns    801c43 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801c2e:	50                   	push   %eax
  801c2f:	68 b1 2b 80 00       	push   $0x802bb1
  801c34:	68 25 01 00 00       	push   $0x125
  801c39:	68 a5 2b 80 00       	push   $0x802ba5
  801c3e:	e8 04 e8 ff ff       	call   800447 <_panic>
			sys_page_unmap(0, UTEMP);
  801c43:	83 ec 08             	sub    $0x8,%esp
  801c46:	68 00 00 40 00       	push   $0x400000
  801c4b:	6a 00                	push   $0x0
  801c4d:	e8 db f2 ff ff       	call   800f2d <sys_page_unmap>
  801c52:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c55:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c5b:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c61:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c67:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801c6d:	0f 82 f7 fe ff ff    	jb     801b6a <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c73:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c7a:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c81:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c88:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c8e:	0f 8c 65 fe ff ff    	jl     801af9 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c94:	83 ec 0c             	sub    $0xc,%esp
  801c97:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c9d:	e8 97 f5 ff ff       	call   801239 <close>
  801ca2:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801caa:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	c1 e8 16             	shr    $0x16,%eax
  801cb5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cbc:	a8 01                	test   $0x1,%al
  801cbe:	74 42                	je     801d02 <spawn+0x45e>
  801cc0:	89 d8                	mov    %ebx,%eax
  801cc2:	c1 e8 0c             	shr    $0xc,%eax
  801cc5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ccc:	f6 c2 01             	test   $0x1,%dl
  801ccf:	74 31                	je     801d02 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801cd1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801cd8:	f6 c6 04             	test   $0x4,%dh
  801cdb:	74 25                	je     801d02 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801cdd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ce4:	83 ec 0c             	sub    $0xc,%esp
  801ce7:	25 07 0e 00 00       	and    $0xe07,%eax
  801cec:	50                   	push   %eax
  801ced:	53                   	push   %ebx
  801cee:	56                   	push   %esi
  801cef:	53                   	push   %ebx
  801cf0:	6a 00                	push   $0x0
  801cf2:	e8 f4 f1 ff ff       	call   800eeb <sys_page_map>
			if (r < 0) {
  801cf7:	83 c4 20             	add    $0x20,%esp
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	0f 88 b1 00 00 00    	js     801db3 <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801d02:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d08:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801d0e:	75 a0                	jne    801cb0 <spawn+0x40c>
  801d10:	e9 b3 00 00 00       	jmp    801dc8 <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801d15:	50                   	push   %eax
  801d16:	68 ce 2b 80 00       	push   $0x802bce
  801d1b:	68 86 00 00 00       	push   $0x86
  801d20:	68 a5 2b 80 00       	push   $0x802ba5
  801d25:	e8 1d e7 ff ff       	call   800447 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d2a:	83 ec 08             	sub    $0x8,%esp
  801d2d:	6a 02                	push   $0x2
  801d2f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d35:	e8 35 f2 ff ff       	call   800f6f <sys_env_set_status>
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	79 2b                	jns    801d6c <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  801d41:	50                   	push   %eax
  801d42:	68 e8 2b 80 00       	push   $0x802be8
  801d47:	68 89 00 00 00       	push   $0x89
  801d4c:	68 a5 2b 80 00       	push   $0x802ba5
  801d51:	e8 f1 e6 ff ff       	call   800447 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d56:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d5c:	e9 a8 00 00 00       	jmp    801e09 <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d61:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d67:	e9 9d 00 00 00       	jmp    801e09 <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d6c:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d72:	e9 92 00 00 00       	jmp    801e09 <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d77:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801d7c:	e9 88 00 00 00       	jmp    801e09 <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	e9 81 00 00 00       	jmp    801e09 <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d88:	89 c3                	mov    %eax,%ebx
  801d8a:	eb 06                	jmp    801d92 <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d8c:	89 c3                	mov    %eax,%ebx
  801d8e:	eb 02                	jmp    801d92 <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d90:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801d92:	83 ec 0c             	sub    $0xc,%esp
  801d95:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d9b:	e8 89 f0 ff ff       	call   800e29 <sys_env_destroy>
	close(fd);
  801da0:	83 c4 04             	add    $0x4,%esp
  801da3:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801da9:	e8 8b f4 ff ff       	call   801239 <close>
	return r;
  801dae:	83 c4 10             	add    $0x10,%esp
  801db1:	eb 56                	jmp    801e09 <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801db3:	50                   	push   %eax
  801db4:	68 ff 2b 80 00       	push   $0x802bff
  801db9:	68 82 00 00 00       	push   $0x82
  801dbe:	68 a5 2b 80 00       	push   $0x802ba5
  801dc3:	e8 7f e6 ff ff       	call   800447 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801dc8:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801dcf:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801dd2:	83 ec 08             	sub    $0x8,%esp
  801dd5:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ddb:	50                   	push   %eax
  801ddc:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801de2:	e8 ca f1 ff ff       	call   800fb1 <sys_env_set_trapframe>
  801de7:	83 c4 10             	add    $0x10,%esp
  801dea:	85 c0                	test   %eax,%eax
  801dec:	0f 89 38 ff ff ff    	jns    801d2a <spawn+0x486>
  801df2:	e9 1e ff ff ff       	jmp    801d15 <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801df7:	83 ec 08             	sub    $0x8,%esp
  801dfa:	68 00 00 40 00       	push   $0x400000
  801dff:	6a 00                	push   $0x0
  801e01:	e8 27 f1 ff ff       	call   800f2d <sys_page_unmap>
  801e06:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e09:	89 d8                	mov    %ebx,%eax
  801e0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e0e:	5b                   	pop    %ebx
  801e0f:	5e                   	pop    %esi
  801e10:	5f                   	pop    %edi
  801e11:	5d                   	pop    %ebp
  801e12:	c3                   	ret    

00801e13 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e13:	55                   	push   %ebp
  801e14:	89 e5                	mov    %esp,%ebp
  801e16:	56                   	push   %esi
  801e17:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e18:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e1b:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e20:	eb 03                	jmp    801e25 <spawnl+0x12>
		argc++;
  801e22:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e25:	83 c2 04             	add    $0x4,%edx
  801e28:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e2c:	75 f4                	jne    801e22 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e2e:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e35:	83 e2 f0             	and    $0xfffffff0,%edx
  801e38:	29 d4                	sub    %edx,%esp
  801e3a:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e3e:	c1 ea 02             	shr    $0x2,%edx
  801e41:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e48:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e4d:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e54:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e5b:	00 
  801e5c:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e63:	eb 0a                	jmp    801e6f <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e65:	83 c0 01             	add    $0x1,%eax
  801e68:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e6c:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e6f:	39 d0                	cmp    %edx,%eax
  801e71:	75 f2                	jne    801e65 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e73:	83 ec 08             	sub    $0x8,%esp
  801e76:	56                   	push   %esi
  801e77:	ff 75 08             	pushl  0x8(%ebp)
  801e7a:	e8 25 fa ff ff       	call   8018a4 <spawn>
}
  801e7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e82:	5b                   	pop    %ebx
  801e83:	5e                   	pop    %esi
  801e84:	5d                   	pop    %ebp
  801e85:	c3                   	ret    

00801e86 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	56                   	push   %esi
  801e8a:	53                   	push   %ebx
  801e8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e8e:	83 ec 0c             	sub    $0xc,%esp
  801e91:	ff 75 08             	pushl  0x8(%ebp)
  801e94:	e8 10 f2 ff ff       	call   8010a9 <fd2data>
  801e99:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e9b:	83 c4 08             	add    $0x8,%esp
  801e9e:	68 40 2c 80 00       	push   $0x802c40
  801ea3:	53                   	push   %ebx
  801ea4:	e8 fc eb ff ff       	call   800aa5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ea9:	8b 46 04             	mov    0x4(%esi),%eax
  801eac:	2b 06                	sub    (%esi),%eax
  801eae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801eb4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ebb:	00 00 00 
	stat->st_dev = &devpipe;
  801ebe:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801ec5:	47 80 00 
	return 0;
}
  801ec8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ecd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed0:	5b                   	pop    %ebx
  801ed1:	5e                   	pop    %esi
  801ed2:	5d                   	pop    %ebp
  801ed3:	c3                   	ret    

00801ed4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	53                   	push   %ebx
  801ed8:	83 ec 0c             	sub    $0xc,%esp
  801edb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ede:	53                   	push   %ebx
  801edf:	6a 00                	push   $0x0
  801ee1:	e8 47 f0 ff ff       	call   800f2d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ee6:	89 1c 24             	mov    %ebx,(%esp)
  801ee9:	e8 bb f1 ff ff       	call   8010a9 <fd2data>
  801eee:	83 c4 08             	add    $0x8,%esp
  801ef1:	50                   	push   %eax
  801ef2:	6a 00                	push   $0x0
  801ef4:	e8 34 f0 ff ff       	call   800f2d <sys_page_unmap>
}
  801ef9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801efc:	c9                   	leave  
  801efd:	c3                   	ret    

00801efe <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	57                   	push   %edi
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
  801f04:	83 ec 1c             	sub    $0x1c,%esp
  801f07:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f0a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f0c:	a1 90 67 80 00       	mov    0x806790,%eax
  801f11:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f14:	83 ec 0c             	sub    $0xc,%esp
  801f17:	ff 75 e0             	pushl  -0x20(%ebp)
  801f1a:	e8 1f 04 00 00       	call   80233e <pageref>
  801f1f:	89 c3                	mov    %eax,%ebx
  801f21:	89 3c 24             	mov    %edi,(%esp)
  801f24:	e8 15 04 00 00       	call   80233e <pageref>
  801f29:	83 c4 10             	add    $0x10,%esp
  801f2c:	39 c3                	cmp    %eax,%ebx
  801f2e:	0f 94 c1             	sete   %cl
  801f31:	0f b6 c9             	movzbl %cl,%ecx
  801f34:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f37:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801f3d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f40:	39 ce                	cmp    %ecx,%esi
  801f42:	74 1b                	je     801f5f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f44:	39 c3                	cmp    %eax,%ebx
  801f46:	75 c4                	jne    801f0c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f48:	8b 42 58             	mov    0x58(%edx),%eax
  801f4b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f4e:	50                   	push   %eax
  801f4f:	56                   	push   %esi
  801f50:	68 47 2c 80 00       	push   $0x802c47
  801f55:	e8 c6 e5 ff ff       	call   800520 <cprintf>
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	eb ad                	jmp    801f0c <_pipeisclosed+0xe>
	}
}
  801f5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f65:	5b                   	pop    %ebx
  801f66:	5e                   	pop    %esi
  801f67:	5f                   	pop    %edi
  801f68:	5d                   	pop    %ebp
  801f69:	c3                   	ret    

00801f6a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	57                   	push   %edi
  801f6e:	56                   	push   %esi
  801f6f:	53                   	push   %ebx
  801f70:	83 ec 28             	sub    $0x28,%esp
  801f73:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f76:	56                   	push   %esi
  801f77:	e8 2d f1 ff ff       	call   8010a9 <fd2data>
  801f7c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f7e:	83 c4 10             	add    $0x10,%esp
  801f81:	bf 00 00 00 00       	mov    $0x0,%edi
  801f86:	eb 4b                	jmp    801fd3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f88:	89 da                	mov    %ebx,%edx
  801f8a:	89 f0                	mov    %esi,%eax
  801f8c:	e8 6d ff ff ff       	call   801efe <_pipeisclosed>
  801f91:	85 c0                	test   %eax,%eax
  801f93:	75 48                	jne    801fdd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f95:	e8 ef ee ff ff       	call   800e89 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f9a:	8b 43 04             	mov    0x4(%ebx),%eax
  801f9d:	8b 0b                	mov    (%ebx),%ecx
  801f9f:	8d 51 20             	lea    0x20(%ecx),%edx
  801fa2:	39 d0                	cmp    %edx,%eax
  801fa4:	73 e2                	jae    801f88 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fa9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fad:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fb0:	89 c2                	mov    %eax,%edx
  801fb2:	c1 fa 1f             	sar    $0x1f,%edx
  801fb5:	89 d1                	mov    %edx,%ecx
  801fb7:	c1 e9 1b             	shr    $0x1b,%ecx
  801fba:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fbd:	83 e2 1f             	and    $0x1f,%edx
  801fc0:	29 ca                	sub    %ecx,%edx
  801fc2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fc6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fca:	83 c0 01             	add    $0x1,%eax
  801fcd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd0:	83 c7 01             	add    $0x1,%edi
  801fd3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fd6:	75 c2                	jne    801f9a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fd8:	8b 45 10             	mov    0x10(%ebp),%eax
  801fdb:	eb 05                	jmp    801fe2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fdd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fe2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe5:	5b                   	pop    %ebx
  801fe6:	5e                   	pop    %esi
  801fe7:	5f                   	pop    %edi
  801fe8:	5d                   	pop    %ebp
  801fe9:	c3                   	ret    

00801fea <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	57                   	push   %edi
  801fee:	56                   	push   %esi
  801fef:	53                   	push   %ebx
  801ff0:	83 ec 18             	sub    $0x18,%esp
  801ff3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ff6:	57                   	push   %edi
  801ff7:	e8 ad f0 ff ff       	call   8010a9 <fd2data>
  801ffc:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	bb 00 00 00 00       	mov    $0x0,%ebx
  802006:	eb 3d                	jmp    802045 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802008:	85 db                	test   %ebx,%ebx
  80200a:	74 04                	je     802010 <devpipe_read+0x26>
				return i;
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	eb 44                	jmp    802054 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802010:	89 f2                	mov    %esi,%edx
  802012:	89 f8                	mov    %edi,%eax
  802014:	e8 e5 fe ff ff       	call   801efe <_pipeisclosed>
  802019:	85 c0                	test   %eax,%eax
  80201b:	75 32                	jne    80204f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80201d:	e8 67 ee ff ff       	call   800e89 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802022:	8b 06                	mov    (%esi),%eax
  802024:	3b 46 04             	cmp    0x4(%esi),%eax
  802027:	74 df                	je     802008 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802029:	99                   	cltd   
  80202a:	c1 ea 1b             	shr    $0x1b,%edx
  80202d:	01 d0                	add    %edx,%eax
  80202f:	83 e0 1f             	and    $0x1f,%eax
  802032:	29 d0                	sub    %edx,%eax
  802034:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802039:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80203c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80203f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802042:	83 c3 01             	add    $0x1,%ebx
  802045:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802048:	75 d8                	jne    802022 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80204a:	8b 45 10             	mov    0x10(%ebp),%eax
  80204d:	eb 05                	jmp    802054 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80204f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802054:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802057:	5b                   	pop    %ebx
  802058:	5e                   	pop    %esi
  802059:	5f                   	pop    %edi
  80205a:	5d                   	pop    %ebp
  80205b:	c3                   	ret    

0080205c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80205c:	55                   	push   %ebp
  80205d:	89 e5                	mov    %esp,%ebp
  80205f:	56                   	push   %esi
  802060:	53                   	push   %ebx
  802061:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802064:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802067:	50                   	push   %eax
  802068:	e8 53 f0 ff ff       	call   8010c0 <fd_alloc>
  80206d:	83 c4 10             	add    $0x10,%esp
  802070:	89 c2                	mov    %eax,%edx
  802072:	85 c0                	test   %eax,%eax
  802074:	0f 88 2c 01 00 00    	js     8021a6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80207a:	83 ec 04             	sub    $0x4,%esp
  80207d:	68 07 04 00 00       	push   $0x407
  802082:	ff 75 f4             	pushl  -0xc(%ebp)
  802085:	6a 00                	push   $0x0
  802087:	e8 1c ee ff ff       	call   800ea8 <sys_page_alloc>
  80208c:	83 c4 10             	add    $0x10,%esp
  80208f:	89 c2                	mov    %eax,%edx
  802091:	85 c0                	test   %eax,%eax
  802093:	0f 88 0d 01 00 00    	js     8021a6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802099:	83 ec 0c             	sub    $0xc,%esp
  80209c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80209f:	50                   	push   %eax
  8020a0:	e8 1b f0 ff ff       	call   8010c0 <fd_alloc>
  8020a5:	89 c3                	mov    %eax,%ebx
  8020a7:	83 c4 10             	add    $0x10,%esp
  8020aa:	85 c0                	test   %eax,%eax
  8020ac:	0f 88 e2 00 00 00    	js     802194 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b2:	83 ec 04             	sub    $0x4,%esp
  8020b5:	68 07 04 00 00       	push   $0x407
  8020ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8020bd:	6a 00                	push   $0x0
  8020bf:	e8 e4 ed ff ff       	call   800ea8 <sys_page_alloc>
  8020c4:	89 c3                	mov    %eax,%ebx
  8020c6:	83 c4 10             	add    $0x10,%esp
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	0f 88 c3 00 00 00    	js     802194 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020d1:	83 ec 0c             	sub    $0xc,%esp
  8020d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8020d7:	e8 cd ef ff ff       	call   8010a9 <fd2data>
  8020dc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020de:	83 c4 0c             	add    $0xc,%esp
  8020e1:	68 07 04 00 00       	push   $0x407
  8020e6:	50                   	push   %eax
  8020e7:	6a 00                	push   $0x0
  8020e9:	e8 ba ed ff ff       	call   800ea8 <sys_page_alloc>
  8020ee:	89 c3                	mov    %eax,%ebx
  8020f0:	83 c4 10             	add    $0x10,%esp
  8020f3:	85 c0                	test   %eax,%eax
  8020f5:	0f 88 89 00 00 00    	js     802184 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020fb:	83 ec 0c             	sub    $0xc,%esp
  8020fe:	ff 75 f0             	pushl  -0x10(%ebp)
  802101:	e8 a3 ef ff ff       	call   8010a9 <fd2data>
  802106:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80210d:	50                   	push   %eax
  80210e:	6a 00                	push   $0x0
  802110:	56                   	push   %esi
  802111:	6a 00                	push   $0x0
  802113:	e8 d3 ed ff ff       	call   800eeb <sys_page_map>
  802118:	89 c3                	mov    %eax,%ebx
  80211a:	83 c4 20             	add    $0x20,%esp
  80211d:	85 c0                	test   %eax,%eax
  80211f:	78 55                	js     802176 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802121:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802127:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80212c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802136:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  80213c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80213f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802141:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802144:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80214b:	83 ec 0c             	sub    $0xc,%esp
  80214e:	ff 75 f4             	pushl  -0xc(%ebp)
  802151:	e8 43 ef ff ff       	call   801099 <fd2num>
  802156:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802159:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80215b:	83 c4 04             	add    $0x4,%esp
  80215e:	ff 75 f0             	pushl  -0x10(%ebp)
  802161:	e8 33 ef ff ff       	call   801099 <fd2num>
  802166:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802169:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80216c:	83 c4 10             	add    $0x10,%esp
  80216f:	ba 00 00 00 00       	mov    $0x0,%edx
  802174:	eb 30                	jmp    8021a6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802176:	83 ec 08             	sub    $0x8,%esp
  802179:	56                   	push   %esi
  80217a:	6a 00                	push   $0x0
  80217c:	e8 ac ed ff ff       	call   800f2d <sys_page_unmap>
  802181:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802184:	83 ec 08             	sub    $0x8,%esp
  802187:	ff 75 f0             	pushl  -0x10(%ebp)
  80218a:	6a 00                	push   $0x0
  80218c:	e8 9c ed ff ff       	call   800f2d <sys_page_unmap>
  802191:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802194:	83 ec 08             	sub    $0x8,%esp
  802197:	ff 75 f4             	pushl  -0xc(%ebp)
  80219a:	6a 00                	push   $0x0
  80219c:	e8 8c ed ff ff       	call   800f2d <sys_page_unmap>
  8021a1:	83 c4 10             	add    $0x10,%esp
  8021a4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021a6:	89 d0                	mov    %edx,%eax
  8021a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ab:	5b                   	pop    %ebx
  8021ac:	5e                   	pop    %esi
  8021ad:	5d                   	pop    %ebp
  8021ae:	c3                   	ret    

008021af <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021b8:	50                   	push   %eax
  8021b9:	ff 75 08             	pushl  0x8(%ebp)
  8021bc:	e8 4e ef ff ff       	call   80110f <fd_lookup>
  8021c1:	83 c4 10             	add    $0x10,%esp
  8021c4:	85 c0                	test   %eax,%eax
  8021c6:	78 18                	js     8021e0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021c8:	83 ec 0c             	sub    $0xc,%esp
  8021cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ce:	e8 d6 ee ff ff       	call   8010a9 <fd2data>
	return _pipeisclosed(fd, p);
  8021d3:	89 c2                	mov    %eax,%edx
  8021d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d8:	e8 21 fd ff ff       	call   801efe <_pipeisclosed>
  8021dd:	83 c4 10             	add    $0x10,%esp
}
  8021e0:	c9                   	leave  
  8021e1:	c3                   	ret    

008021e2 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
  8021e5:	56                   	push   %esi
  8021e6:	53                   	push   %ebx
  8021e7:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8021ea:	85 f6                	test   %esi,%esi
  8021ec:	75 16                	jne    802204 <wait+0x22>
  8021ee:	68 5f 2c 80 00       	push   $0x802c5f
  8021f3:	68 5f 2b 80 00       	push   $0x802b5f
  8021f8:	6a 09                	push   $0x9
  8021fa:	68 6a 2c 80 00       	push   $0x802c6a
  8021ff:	e8 43 e2 ff ff       	call   800447 <_panic>
	e = &envs[ENVX(envid)];
  802204:	89 f3                	mov    %esi,%ebx
  802206:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80220c:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80220f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802215:	eb 05                	jmp    80221c <wait+0x3a>
		sys_yield();
  802217:	e8 6d ec ff ff       	call   800e89 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80221c:	8b 43 48             	mov    0x48(%ebx),%eax
  80221f:	39 c6                	cmp    %eax,%esi
  802221:	75 07                	jne    80222a <wait+0x48>
  802223:	8b 43 54             	mov    0x54(%ebx),%eax
  802226:	85 c0                	test   %eax,%eax
  802228:	75 ed                	jne    802217 <wait+0x35>
		sys_yield();
}
  80222a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5d                   	pop    %ebp
  802230:	c3                   	ret    

00802231 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802231:	55                   	push   %ebp
  802232:	89 e5                	mov    %esp,%ebp
  802234:	56                   	push   %esi
  802235:	53                   	push   %ebx
  802236:	8b 75 08             	mov    0x8(%ebp),%esi
  802239:	8b 45 0c             	mov    0xc(%ebp),%eax
  80223c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80223f:	85 c0                	test   %eax,%eax
  802241:	75 12                	jne    802255 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802243:	83 ec 0c             	sub    $0xc,%esp
  802246:	68 00 00 c0 ee       	push   $0xeec00000
  80224b:	e8 08 ee ff ff       	call   801058 <sys_ipc_recv>
  802250:	83 c4 10             	add    $0x10,%esp
  802253:	eb 0c                	jmp    802261 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802255:	83 ec 0c             	sub    $0xc,%esp
  802258:	50                   	push   %eax
  802259:	e8 fa ed ff ff       	call   801058 <sys_ipc_recv>
  80225e:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802261:	85 f6                	test   %esi,%esi
  802263:	0f 95 c1             	setne  %cl
  802266:	85 db                	test   %ebx,%ebx
  802268:	0f 95 c2             	setne  %dl
  80226b:	84 d1                	test   %dl,%cl
  80226d:	74 09                	je     802278 <ipc_recv+0x47>
  80226f:	89 c2                	mov    %eax,%edx
  802271:	c1 ea 1f             	shr    $0x1f,%edx
  802274:	84 d2                	test   %dl,%dl
  802276:	75 24                	jne    80229c <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802278:	85 f6                	test   %esi,%esi
  80227a:	74 0a                	je     802286 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  80227c:	a1 90 67 80 00       	mov    0x806790,%eax
  802281:	8b 40 74             	mov    0x74(%eax),%eax
  802284:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802286:	85 db                	test   %ebx,%ebx
  802288:	74 0a                	je     802294 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  80228a:	a1 90 67 80 00       	mov    0x806790,%eax
  80228f:	8b 40 78             	mov    0x78(%eax),%eax
  802292:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802294:	a1 90 67 80 00       	mov    0x806790,%eax
  802299:	8b 40 70             	mov    0x70(%eax),%eax
}
  80229c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80229f:	5b                   	pop    %ebx
  8022a0:	5e                   	pop    %esi
  8022a1:	5d                   	pop    %ebp
  8022a2:	c3                   	ret    

008022a3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022a3:	55                   	push   %ebp
  8022a4:	89 e5                	mov    %esp,%ebp
  8022a6:	57                   	push   %edi
  8022a7:	56                   	push   %esi
  8022a8:	53                   	push   %ebx
  8022a9:	83 ec 0c             	sub    $0xc,%esp
  8022ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8022b5:	85 db                	test   %ebx,%ebx
  8022b7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022bc:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8022bf:	ff 75 14             	pushl  0x14(%ebp)
  8022c2:	53                   	push   %ebx
  8022c3:	56                   	push   %esi
  8022c4:	57                   	push   %edi
  8022c5:	e8 6b ed ff ff       	call   801035 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8022ca:	89 c2                	mov    %eax,%edx
  8022cc:	c1 ea 1f             	shr    $0x1f,%edx
  8022cf:	83 c4 10             	add    $0x10,%esp
  8022d2:	84 d2                	test   %dl,%dl
  8022d4:	74 17                	je     8022ed <ipc_send+0x4a>
  8022d6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022d9:	74 12                	je     8022ed <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8022db:	50                   	push   %eax
  8022dc:	68 75 2c 80 00       	push   $0x802c75
  8022e1:	6a 47                	push   $0x47
  8022e3:	68 83 2c 80 00       	push   $0x802c83
  8022e8:	e8 5a e1 ff ff       	call   800447 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8022ed:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022f0:	75 07                	jne    8022f9 <ipc_send+0x56>
			sys_yield();
  8022f2:	e8 92 eb ff ff       	call   800e89 <sys_yield>
  8022f7:	eb c6                	jmp    8022bf <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8022f9:	85 c0                	test   %eax,%eax
  8022fb:	75 c2                	jne    8022bf <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8022fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802300:	5b                   	pop    %ebx
  802301:	5e                   	pop    %esi
  802302:	5f                   	pop    %edi
  802303:	5d                   	pop    %ebp
  802304:	c3                   	ret    

00802305 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802305:	55                   	push   %ebp
  802306:	89 e5                	mov    %esp,%ebp
  802308:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80230b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802310:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802313:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802319:	8b 52 50             	mov    0x50(%edx),%edx
  80231c:	39 ca                	cmp    %ecx,%edx
  80231e:	75 0d                	jne    80232d <ipc_find_env+0x28>
			return envs[i].env_id;
  802320:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802323:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802328:	8b 40 48             	mov    0x48(%eax),%eax
  80232b:	eb 0f                	jmp    80233c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80232d:	83 c0 01             	add    $0x1,%eax
  802330:	3d 00 04 00 00       	cmp    $0x400,%eax
  802335:	75 d9                	jne    802310 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802337:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80233c:	5d                   	pop    %ebp
  80233d:	c3                   	ret    

0080233e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80233e:	55                   	push   %ebp
  80233f:	89 e5                	mov    %esp,%ebp
  802341:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802344:	89 d0                	mov    %edx,%eax
  802346:	c1 e8 16             	shr    $0x16,%eax
  802349:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802350:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802355:	f6 c1 01             	test   $0x1,%cl
  802358:	74 1d                	je     802377 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80235a:	c1 ea 0c             	shr    $0xc,%edx
  80235d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802364:	f6 c2 01             	test   $0x1,%dl
  802367:	74 0e                	je     802377 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802369:	c1 ea 0c             	shr    $0xc,%edx
  80236c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802373:	ef 
  802374:	0f b7 c0             	movzwl %ax,%eax
}
  802377:	5d                   	pop    %ebp
  802378:	c3                   	ret    
  802379:	66 90                	xchg   %ax,%ax
  80237b:	66 90                	xchg   %ax,%ax
  80237d:	66 90                	xchg   %ax,%ax
  80237f:	90                   	nop

00802380 <__udivdi3>:
  802380:	55                   	push   %ebp
  802381:	57                   	push   %edi
  802382:	56                   	push   %esi
  802383:	53                   	push   %ebx
  802384:	83 ec 1c             	sub    $0x1c,%esp
  802387:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80238b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80238f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802393:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802397:	85 f6                	test   %esi,%esi
  802399:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80239d:	89 ca                	mov    %ecx,%edx
  80239f:	89 f8                	mov    %edi,%eax
  8023a1:	75 3d                	jne    8023e0 <__udivdi3+0x60>
  8023a3:	39 cf                	cmp    %ecx,%edi
  8023a5:	0f 87 c5 00 00 00    	ja     802470 <__udivdi3+0xf0>
  8023ab:	85 ff                	test   %edi,%edi
  8023ad:	89 fd                	mov    %edi,%ebp
  8023af:	75 0b                	jne    8023bc <__udivdi3+0x3c>
  8023b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b6:	31 d2                	xor    %edx,%edx
  8023b8:	f7 f7                	div    %edi
  8023ba:	89 c5                	mov    %eax,%ebp
  8023bc:	89 c8                	mov    %ecx,%eax
  8023be:	31 d2                	xor    %edx,%edx
  8023c0:	f7 f5                	div    %ebp
  8023c2:	89 c1                	mov    %eax,%ecx
  8023c4:	89 d8                	mov    %ebx,%eax
  8023c6:	89 cf                	mov    %ecx,%edi
  8023c8:	f7 f5                	div    %ebp
  8023ca:	89 c3                	mov    %eax,%ebx
  8023cc:	89 d8                	mov    %ebx,%eax
  8023ce:	89 fa                	mov    %edi,%edx
  8023d0:	83 c4 1c             	add    $0x1c,%esp
  8023d3:	5b                   	pop    %ebx
  8023d4:	5e                   	pop    %esi
  8023d5:	5f                   	pop    %edi
  8023d6:	5d                   	pop    %ebp
  8023d7:	c3                   	ret    
  8023d8:	90                   	nop
  8023d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	39 ce                	cmp    %ecx,%esi
  8023e2:	77 74                	ja     802458 <__udivdi3+0xd8>
  8023e4:	0f bd fe             	bsr    %esi,%edi
  8023e7:	83 f7 1f             	xor    $0x1f,%edi
  8023ea:	0f 84 98 00 00 00    	je     802488 <__udivdi3+0x108>
  8023f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	89 c5                	mov    %eax,%ebp
  8023f9:	29 fb                	sub    %edi,%ebx
  8023fb:	d3 e6                	shl    %cl,%esi
  8023fd:	89 d9                	mov    %ebx,%ecx
  8023ff:	d3 ed                	shr    %cl,%ebp
  802401:	89 f9                	mov    %edi,%ecx
  802403:	d3 e0                	shl    %cl,%eax
  802405:	09 ee                	or     %ebp,%esi
  802407:	89 d9                	mov    %ebx,%ecx
  802409:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80240d:	89 d5                	mov    %edx,%ebp
  80240f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802413:	d3 ed                	shr    %cl,%ebp
  802415:	89 f9                	mov    %edi,%ecx
  802417:	d3 e2                	shl    %cl,%edx
  802419:	89 d9                	mov    %ebx,%ecx
  80241b:	d3 e8                	shr    %cl,%eax
  80241d:	09 c2                	or     %eax,%edx
  80241f:	89 d0                	mov    %edx,%eax
  802421:	89 ea                	mov    %ebp,%edx
  802423:	f7 f6                	div    %esi
  802425:	89 d5                	mov    %edx,%ebp
  802427:	89 c3                	mov    %eax,%ebx
  802429:	f7 64 24 0c          	mull   0xc(%esp)
  80242d:	39 d5                	cmp    %edx,%ebp
  80242f:	72 10                	jb     802441 <__udivdi3+0xc1>
  802431:	8b 74 24 08          	mov    0x8(%esp),%esi
  802435:	89 f9                	mov    %edi,%ecx
  802437:	d3 e6                	shl    %cl,%esi
  802439:	39 c6                	cmp    %eax,%esi
  80243b:	73 07                	jae    802444 <__udivdi3+0xc4>
  80243d:	39 d5                	cmp    %edx,%ebp
  80243f:	75 03                	jne    802444 <__udivdi3+0xc4>
  802441:	83 eb 01             	sub    $0x1,%ebx
  802444:	31 ff                	xor    %edi,%edi
  802446:	89 d8                	mov    %ebx,%eax
  802448:	89 fa                	mov    %edi,%edx
  80244a:	83 c4 1c             	add    $0x1c,%esp
  80244d:	5b                   	pop    %ebx
  80244e:	5e                   	pop    %esi
  80244f:	5f                   	pop    %edi
  802450:	5d                   	pop    %ebp
  802451:	c3                   	ret    
  802452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802458:	31 ff                	xor    %edi,%edi
  80245a:	31 db                	xor    %ebx,%ebx
  80245c:	89 d8                	mov    %ebx,%eax
  80245e:	89 fa                	mov    %edi,%edx
  802460:	83 c4 1c             	add    $0x1c,%esp
  802463:	5b                   	pop    %ebx
  802464:	5e                   	pop    %esi
  802465:	5f                   	pop    %edi
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    
  802468:	90                   	nop
  802469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802470:	89 d8                	mov    %ebx,%eax
  802472:	f7 f7                	div    %edi
  802474:	31 ff                	xor    %edi,%edi
  802476:	89 c3                	mov    %eax,%ebx
  802478:	89 d8                	mov    %ebx,%eax
  80247a:	89 fa                	mov    %edi,%edx
  80247c:	83 c4 1c             	add    $0x1c,%esp
  80247f:	5b                   	pop    %ebx
  802480:	5e                   	pop    %esi
  802481:	5f                   	pop    %edi
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    
  802484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802488:	39 ce                	cmp    %ecx,%esi
  80248a:	72 0c                	jb     802498 <__udivdi3+0x118>
  80248c:	31 db                	xor    %ebx,%ebx
  80248e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802492:	0f 87 34 ff ff ff    	ja     8023cc <__udivdi3+0x4c>
  802498:	bb 01 00 00 00       	mov    $0x1,%ebx
  80249d:	e9 2a ff ff ff       	jmp    8023cc <__udivdi3+0x4c>
  8024a2:	66 90                	xchg   %ax,%ax
  8024a4:	66 90                	xchg   %ax,%ax
  8024a6:	66 90                	xchg   %ax,%ax
  8024a8:	66 90                	xchg   %ax,%ax
  8024aa:	66 90                	xchg   %ax,%ax
  8024ac:	66 90                	xchg   %ax,%ax
  8024ae:	66 90                	xchg   %ax,%ax

008024b0 <__umoddi3>:
  8024b0:	55                   	push   %ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	53                   	push   %ebx
  8024b4:	83 ec 1c             	sub    $0x1c,%esp
  8024b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024c7:	85 d2                	test   %edx,%edx
  8024c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024d1:	89 f3                	mov    %esi,%ebx
  8024d3:	89 3c 24             	mov    %edi,(%esp)
  8024d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024da:	75 1c                	jne    8024f8 <__umoddi3+0x48>
  8024dc:	39 f7                	cmp    %esi,%edi
  8024de:	76 50                	jbe    802530 <__umoddi3+0x80>
  8024e0:	89 c8                	mov    %ecx,%eax
  8024e2:	89 f2                	mov    %esi,%edx
  8024e4:	f7 f7                	div    %edi
  8024e6:	89 d0                	mov    %edx,%eax
  8024e8:	31 d2                	xor    %edx,%edx
  8024ea:	83 c4 1c             	add    $0x1c,%esp
  8024ed:	5b                   	pop    %ebx
  8024ee:	5e                   	pop    %esi
  8024ef:	5f                   	pop    %edi
  8024f0:	5d                   	pop    %ebp
  8024f1:	c3                   	ret    
  8024f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024f8:	39 f2                	cmp    %esi,%edx
  8024fa:	89 d0                	mov    %edx,%eax
  8024fc:	77 52                	ja     802550 <__umoddi3+0xa0>
  8024fe:	0f bd ea             	bsr    %edx,%ebp
  802501:	83 f5 1f             	xor    $0x1f,%ebp
  802504:	75 5a                	jne    802560 <__umoddi3+0xb0>
  802506:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80250a:	0f 82 e0 00 00 00    	jb     8025f0 <__umoddi3+0x140>
  802510:	39 0c 24             	cmp    %ecx,(%esp)
  802513:	0f 86 d7 00 00 00    	jbe    8025f0 <__umoddi3+0x140>
  802519:	8b 44 24 08          	mov    0x8(%esp),%eax
  80251d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802521:	83 c4 1c             	add    $0x1c,%esp
  802524:	5b                   	pop    %ebx
  802525:	5e                   	pop    %esi
  802526:	5f                   	pop    %edi
  802527:	5d                   	pop    %ebp
  802528:	c3                   	ret    
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	85 ff                	test   %edi,%edi
  802532:	89 fd                	mov    %edi,%ebp
  802534:	75 0b                	jne    802541 <__umoddi3+0x91>
  802536:	b8 01 00 00 00       	mov    $0x1,%eax
  80253b:	31 d2                	xor    %edx,%edx
  80253d:	f7 f7                	div    %edi
  80253f:	89 c5                	mov    %eax,%ebp
  802541:	89 f0                	mov    %esi,%eax
  802543:	31 d2                	xor    %edx,%edx
  802545:	f7 f5                	div    %ebp
  802547:	89 c8                	mov    %ecx,%eax
  802549:	f7 f5                	div    %ebp
  80254b:	89 d0                	mov    %edx,%eax
  80254d:	eb 99                	jmp    8024e8 <__umoddi3+0x38>
  80254f:	90                   	nop
  802550:	89 c8                	mov    %ecx,%eax
  802552:	89 f2                	mov    %esi,%edx
  802554:	83 c4 1c             	add    $0x1c,%esp
  802557:	5b                   	pop    %ebx
  802558:	5e                   	pop    %esi
  802559:	5f                   	pop    %edi
  80255a:	5d                   	pop    %ebp
  80255b:	c3                   	ret    
  80255c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802560:	8b 34 24             	mov    (%esp),%esi
  802563:	bf 20 00 00 00       	mov    $0x20,%edi
  802568:	89 e9                	mov    %ebp,%ecx
  80256a:	29 ef                	sub    %ebp,%edi
  80256c:	d3 e0                	shl    %cl,%eax
  80256e:	89 f9                	mov    %edi,%ecx
  802570:	89 f2                	mov    %esi,%edx
  802572:	d3 ea                	shr    %cl,%edx
  802574:	89 e9                	mov    %ebp,%ecx
  802576:	09 c2                	or     %eax,%edx
  802578:	89 d8                	mov    %ebx,%eax
  80257a:	89 14 24             	mov    %edx,(%esp)
  80257d:	89 f2                	mov    %esi,%edx
  80257f:	d3 e2                	shl    %cl,%edx
  802581:	89 f9                	mov    %edi,%ecx
  802583:	89 54 24 04          	mov    %edx,0x4(%esp)
  802587:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80258b:	d3 e8                	shr    %cl,%eax
  80258d:	89 e9                	mov    %ebp,%ecx
  80258f:	89 c6                	mov    %eax,%esi
  802591:	d3 e3                	shl    %cl,%ebx
  802593:	89 f9                	mov    %edi,%ecx
  802595:	89 d0                	mov    %edx,%eax
  802597:	d3 e8                	shr    %cl,%eax
  802599:	89 e9                	mov    %ebp,%ecx
  80259b:	09 d8                	or     %ebx,%eax
  80259d:	89 d3                	mov    %edx,%ebx
  80259f:	89 f2                	mov    %esi,%edx
  8025a1:	f7 34 24             	divl   (%esp)
  8025a4:	89 d6                	mov    %edx,%esi
  8025a6:	d3 e3                	shl    %cl,%ebx
  8025a8:	f7 64 24 04          	mull   0x4(%esp)
  8025ac:	39 d6                	cmp    %edx,%esi
  8025ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025b2:	89 d1                	mov    %edx,%ecx
  8025b4:	89 c3                	mov    %eax,%ebx
  8025b6:	72 08                	jb     8025c0 <__umoddi3+0x110>
  8025b8:	75 11                	jne    8025cb <__umoddi3+0x11b>
  8025ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025be:	73 0b                	jae    8025cb <__umoddi3+0x11b>
  8025c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025c4:	1b 14 24             	sbb    (%esp),%edx
  8025c7:	89 d1                	mov    %edx,%ecx
  8025c9:	89 c3                	mov    %eax,%ebx
  8025cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025cf:	29 da                	sub    %ebx,%edx
  8025d1:	19 ce                	sbb    %ecx,%esi
  8025d3:	89 f9                	mov    %edi,%ecx
  8025d5:	89 f0                	mov    %esi,%eax
  8025d7:	d3 e0                	shl    %cl,%eax
  8025d9:	89 e9                	mov    %ebp,%ecx
  8025db:	d3 ea                	shr    %cl,%edx
  8025dd:	89 e9                	mov    %ebp,%ecx
  8025df:	d3 ee                	shr    %cl,%esi
  8025e1:	09 d0                	or     %edx,%eax
  8025e3:	89 f2                	mov    %esi,%edx
  8025e5:	83 c4 1c             	add    $0x1c,%esp
  8025e8:	5b                   	pop    %ebx
  8025e9:	5e                   	pop    %esi
  8025ea:	5f                   	pop    %edi
  8025eb:	5d                   	pop    %ebp
  8025ec:	c3                   	ret    
  8025ed:	8d 76 00             	lea    0x0(%esi),%esi
  8025f0:	29 f9                	sub    %edi,%ecx
  8025f2:	19 d6                	sbb    %edx,%esi
  8025f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025fc:	e9 18 ff ff ff       	jmp    802519 <__umoddi3+0x69>
