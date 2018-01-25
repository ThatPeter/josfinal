
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
  80006d:	68 c0 29 80 00       	push   $0x8029c0
  800072:	e8 85 04 00 00       	call   8004fc <cprintf>

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
  80009c:	68 88 2a 80 00       	push   $0x802a88
  8000a1:	e8 56 04 00 00       	call   8004fc <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 cf 29 80 00       	push   $0x8029cf
  8000b3:	e8 44 04 00 00       	call   8004fc <cprintf>
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
  8000d8:	68 c4 2a 80 00       	push   $0x802ac4
  8000dd:	e8 1a 04 00 00       	call   8004fc <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 e6 29 80 00       	push   $0x8029e6
  8000ef:	e8 08 04 00 00       	call   8004fc <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 fc 29 80 00       	push   $0x8029fc
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 96 09 00 00       	call   800aa1 <strcat>
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
  80011e:	68 08 2a 80 00       	push   $0x802a08
  800123:	56                   	push   %esi
  800124:	e8 78 09 00 00       	call   800aa1 <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 6c 09 00 00       	call   800aa1 <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 09 2a 80 00       	push   $0x802a09
  80013d:	56                   	push   %esi
  80013e:	e8 5e 09 00 00       	call   800aa1 <strcat>
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
  800158:	68 0b 2a 80 00       	push   $0x802a0b
  80015d:	e8 9a 03 00 00       	call   8004fc <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 0f 2a 80 00 	movl   $0x802a0f,(%esp)
  800169:	e8 8e 03 00 00       	call   8004fc <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 cd 13 00 00       	call   801547 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 21 2a 80 00       	push   $0x802a21
  80018c:	6a 37                	push   $0x37
  80018e:	68 2e 2a 80 00       	push   $0x802a2e
  800193:	e8 8b 02 00 00       	call   800423 <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 3a 2a 80 00       	push   $0x802a3a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 2e 2a 80 00       	push   $0x802a2e
  8001a9:	e8 75 02 00 00       	call   800423 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 dd 13 00 00       	call   801597 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 54 2a 80 00       	push   $0x802a54
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 2e 2a 80 00       	push   $0x802a2e
  8001ce:	e8 50 02 00 00       	call   800423 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 5c 2a 80 00       	push   $0x802a5c
  8001db:	e8 1c 03 00 00       	call   8004fc <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 70 2a 80 00       	push   $0x802a70
  8001ea:	68 6f 2a 80 00       	push   $0x802a6f
  8001ef:	e8 2d 1f 00 00       	call   802121 <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 73 2a 80 00       	push   $0x802a73
  800204:	e8 f3 02 00 00       	call   8004fc <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 d9 22 00 00       	call   8024f0 <wait>
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
  80022c:	68 f3 2a 80 00       	push   $0x802af3
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 48 08 00 00       	call   800a81 <strcpy>
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
  800272:	e8 9c 09 00 00       	call   800c13 <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 47 0b 00 00       	call   800dc8 <sys_cputs>
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
  8002a8:	e8 b8 0b 00 00       	call   800e65 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 34 0b 00 00       	call   800de6 <sys_cgetc>
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
  8002e4:	e8 df 0a 00 00       	call   800dc8 <sys_cputs>
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
  8002fc:	e8 82 13 00 00       	call   801683 <read>
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
  800326:	e8 f2 10 00 00       	call   80141d <fd_lookup>
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
  80034f:	e8 7a 10 00 00       	call   8013ce <fd_alloc>
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
  80036a:	e8 15 0b 00 00       	call   800e84 <sys_page_alloc>
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
  800391:	e8 11 10 00 00       	call   8013a7 <fd2num>
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
  8003aa:	e8 97 0a 00 00       	call   800e46 <sys_getenvid>
  8003af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003b4:	89 c2                	mov    %eax,%edx
  8003b6:	c1 e2 07             	shl    $0x7,%edx
  8003b9:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8003c0:	a3 90 77 80 00       	mov    %eax,0x807790
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c5:	85 db                	test   %ebx,%ebx
  8003c7:	7e 07                	jle    8003d0 <libmain+0x31>
		binaryname = argv[0];
  8003c9:	8b 06                	mov    (%esi),%eax
  8003cb:	a3 8c 57 80 00       	mov    %eax,0x80578c

	// call user main routine
	umain(argc, argv);
  8003d0:	83 ec 08             	sub    $0x8,%esp
  8003d3:	56                   	push   %esi
  8003d4:	53                   	push   %ebx
  8003d5:	e8 84 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  8003da:	e8 2a 00 00 00       	call   800409 <exit>
}
  8003df:	83 c4 10             	add    $0x10,%esp
  8003e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e5:	5b                   	pop    %ebx
  8003e6:	5e                   	pop    %esi
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8003ef:	a1 94 77 80 00       	mov    0x807794,%eax
	func();
  8003f4:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8003f6:	e8 4b 0a 00 00       	call   800e46 <sys_getenvid>
  8003fb:	83 ec 0c             	sub    $0xc,%esp
  8003fe:	50                   	push   %eax
  8003ff:	e8 91 0c 00 00       	call   801095 <sys_thread_free>
}
  800404:	83 c4 10             	add    $0x10,%esp
  800407:	c9                   	leave  
  800408:	c3                   	ret    

00800409 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80040f:	e8 5e 11 00 00       	call   801572 <close_all>
	sys_env_destroy(0);
  800414:	83 ec 0c             	sub    $0xc,%esp
  800417:	6a 00                	push   $0x0
  800419:	e8 e7 09 00 00       	call   800e05 <sys_env_destroy>
}
  80041e:	83 c4 10             	add    $0x10,%esp
  800421:	c9                   	leave  
  800422:	c3                   	ret    

00800423 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	56                   	push   %esi
  800427:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800428:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80042b:	8b 35 8c 57 80 00    	mov    0x80578c,%esi
  800431:	e8 10 0a 00 00       	call   800e46 <sys_getenvid>
  800436:	83 ec 0c             	sub    $0xc,%esp
  800439:	ff 75 0c             	pushl  0xc(%ebp)
  80043c:	ff 75 08             	pushl  0x8(%ebp)
  80043f:	56                   	push   %esi
  800440:	50                   	push   %eax
  800441:	68 0c 2b 80 00       	push   $0x802b0c
  800446:	e8 b1 00 00 00       	call   8004fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80044b:	83 c4 18             	add    $0x18,%esp
  80044e:	53                   	push   %ebx
  80044f:	ff 75 10             	pushl  0x10(%ebp)
  800452:	e8 54 00 00 00       	call   8004ab <vcprintf>
	cprintf("\n");
  800457:	c7 04 24 74 30 80 00 	movl   $0x803074,(%esp)
  80045e:	e8 99 00 00 00       	call   8004fc <cprintf>
  800463:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800466:	cc                   	int3   
  800467:	eb fd                	jmp    800466 <_panic+0x43>

00800469 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800469:	55                   	push   %ebp
  80046a:	89 e5                	mov    %esp,%ebp
  80046c:	53                   	push   %ebx
  80046d:	83 ec 04             	sub    $0x4,%esp
  800470:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800473:	8b 13                	mov    (%ebx),%edx
  800475:	8d 42 01             	lea    0x1(%edx),%eax
  800478:	89 03                	mov    %eax,(%ebx)
  80047a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80047d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800481:	3d ff 00 00 00       	cmp    $0xff,%eax
  800486:	75 1a                	jne    8004a2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	68 ff 00 00 00       	push   $0xff
  800490:	8d 43 08             	lea    0x8(%ebx),%eax
  800493:	50                   	push   %eax
  800494:	e8 2f 09 00 00       	call   800dc8 <sys_cputs>
		b->idx = 0;
  800499:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80049f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004a2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004a9:	c9                   	leave  
  8004aa:	c3                   	ret    

008004ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ab:	55                   	push   %ebp
  8004ac:	89 e5                	mov    %esp,%ebp
  8004ae:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004b4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004bb:	00 00 00 
	b.cnt = 0;
  8004be:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004c5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004c8:	ff 75 0c             	pushl  0xc(%ebp)
  8004cb:	ff 75 08             	pushl  0x8(%ebp)
  8004ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004d4:	50                   	push   %eax
  8004d5:	68 69 04 80 00       	push   $0x800469
  8004da:	e8 54 01 00 00       	call   800633 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004df:	83 c4 08             	add    $0x8,%esp
  8004e2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004e8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 d4 08 00 00       	call   800dc8 <sys_cputs>

	return b.cnt;
}
  8004f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004fa:	c9                   	leave  
  8004fb:	c3                   	ret    

008004fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004fc:	55                   	push   %ebp
  8004fd:	89 e5                	mov    %esp,%ebp
  8004ff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800502:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800505:	50                   	push   %eax
  800506:	ff 75 08             	pushl  0x8(%ebp)
  800509:	e8 9d ff ff ff       	call   8004ab <vcprintf>
	va_end(ap);

	return cnt;
}
  80050e:	c9                   	leave  
  80050f:	c3                   	ret    

00800510 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	57                   	push   %edi
  800514:	56                   	push   %esi
  800515:	53                   	push   %ebx
  800516:	83 ec 1c             	sub    $0x1c,%esp
  800519:	89 c7                	mov    %eax,%edi
  80051b:	89 d6                	mov    %edx,%esi
  80051d:	8b 45 08             	mov    0x8(%ebp),%eax
  800520:	8b 55 0c             	mov    0xc(%ebp),%edx
  800523:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800526:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800529:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80052c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800531:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800534:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800537:	39 d3                	cmp    %edx,%ebx
  800539:	72 05                	jb     800540 <printnum+0x30>
  80053b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80053e:	77 45                	ja     800585 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800540:	83 ec 0c             	sub    $0xc,%esp
  800543:	ff 75 18             	pushl  0x18(%ebp)
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80054c:	53                   	push   %ebx
  80054d:	ff 75 10             	pushl  0x10(%ebp)
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	ff 75 e4             	pushl  -0x1c(%ebp)
  800556:	ff 75 e0             	pushl  -0x20(%ebp)
  800559:	ff 75 dc             	pushl  -0x24(%ebp)
  80055c:	ff 75 d8             	pushl  -0x28(%ebp)
  80055f:	e8 cc 21 00 00       	call   802730 <__udivdi3>
  800564:	83 c4 18             	add    $0x18,%esp
  800567:	52                   	push   %edx
  800568:	50                   	push   %eax
  800569:	89 f2                	mov    %esi,%edx
  80056b:	89 f8                	mov    %edi,%eax
  80056d:	e8 9e ff ff ff       	call   800510 <printnum>
  800572:	83 c4 20             	add    $0x20,%esp
  800575:	eb 18                	jmp    80058f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	56                   	push   %esi
  80057b:	ff 75 18             	pushl  0x18(%ebp)
  80057e:	ff d7                	call   *%edi
  800580:	83 c4 10             	add    $0x10,%esp
  800583:	eb 03                	jmp    800588 <printnum+0x78>
  800585:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800588:	83 eb 01             	sub    $0x1,%ebx
  80058b:	85 db                	test   %ebx,%ebx
  80058d:	7f e8                	jg     800577 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	56                   	push   %esi
  800593:	83 ec 04             	sub    $0x4,%esp
  800596:	ff 75 e4             	pushl  -0x1c(%ebp)
  800599:	ff 75 e0             	pushl  -0x20(%ebp)
  80059c:	ff 75 dc             	pushl  -0x24(%ebp)
  80059f:	ff 75 d8             	pushl  -0x28(%ebp)
  8005a2:	e8 b9 22 00 00       	call   802860 <__umoddi3>
  8005a7:	83 c4 14             	add    $0x14,%esp
  8005aa:	0f be 80 2f 2b 80 00 	movsbl 0x802b2f(%eax),%eax
  8005b1:	50                   	push   %eax
  8005b2:	ff d7                	call   *%edi
}
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005ba:	5b                   	pop    %ebx
  8005bb:	5e                   	pop    %esi
  8005bc:	5f                   	pop    %edi
  8005bd:	5d                   	pop    %ebp
  8005be:	c3                   	ret    

008005bf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005bf:	55                   	push   %ebp
  8005c0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005c2:	83 fa 01             	cmp    $0x1,%edx
  8005c5:	7e 0e                	jle    8005d5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005c7:	8b 10                	mov    (%eax),%edx
  8005c9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005cc:	89 08                	mov    %ecx,(%eax)
  8005ce:	8b 02                	mov    (%edx),%eax
  8005d0:	8b 52 04             	mov    0x4(%edx),%edx
  8005d3:	eb 22                	jmp    8005f7 <getuint+0x38>
	else if (lflag)
  8005d5:	85 d2                	test   %edx,%edx
  8005d7:	74 10                	je     8005e9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005d9:	8b 10                	mov    (%eax),%edx
  8005db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005de:	89 08                	mov    %ecx,(%eax)
  8005e0:	8b 02                	mov    (%edx),%eax
  8005e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e7:	eb 0e                	jmp    8005f7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005e9:	8b 10                	mov    (%eax),%edx
  8005eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ee:	89 08                	mov    %ecx,(%eax)
  8005f0:	8b 02                	mov    (%edx),%eax
  8005f2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005f7:	5d                   	pop    %ebp
  8005f8:	c3                   	ret    

008005f9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005f9:	55                   	push   %ebp
  8005fa:	89 e5                	mov    %esp,%ebp
  8005fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800603:	8b 10                	mov    (%eax),%edx
  800605:	3b 50 04             	cmp    0x4(%eax),%edx
  800608:	73 0a                	jae    800614 <sprintputch+0x1b>
		*b->buf++ = ch;
  80060a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80060d:	89 08                	mov    %ecx,(%eax)
  80060f:	8b 45 08             	mov    0x8(%ebp),%eax
  800612:	88 02                	mov    %al,(%edx)
}
  800614:	5d                   	pop    %ebp
  800615:	c3                   	ret    

00800616 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800616:	55                   	push   %ebp
  800617:	89 e5                	mov    %esp,%ebp
  800619:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80061c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80061f:	50                   	push   %eax
  800620:	ff 75 10             	pushl  0x10(%ebp)
  800623:	ff 75 0c             	pushl  0xc(%ebp)
  800626:	ff 75 08             	pushl  0x8(%ebp)
  800629:	e8 05 00 00 00       	call   800633 <vprintfmt>
	va_end(ap);
}
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	c9                   	leave  
  800632:	c3                   	ret    

00800633 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	57                   	push   %edi
  800637:	56                   	push   %esi
  800638:	53                   	push   %ebx
  800639:	83 ec 2c             	sub    $0x2c,%esp
  80063c:	8b 75 08             	mov    0x8(%ebp),%esi
  80063f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800642:	8b 7d 10             	mov    0x10(%ebp),%edi
  800645:	eb 12                	jmp    800659 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800647:	85 c0                	test   %eax,%eax
  800649:	0f 84 89 03 00 00    	je     8009d8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	50                   	push   %eax
  800654:	ff d6                	call   *%esi
  800656:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800659:	83 c7 01             	add    $0x1,%edi
  80065c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800660:	83 f8 25             	cmp    $0x25,%eax
  800663:	75 e2                	jne    800647 <vprintfmt+0x14>
  800665:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800669:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800670:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800677:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80067e:	ba 00 00 00 00       	mov    $0x0,%edx
  800683:	eb 07                	jmp    80068c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800685:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800688:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068c:	8d 47 01             	lea    0x1(%edi),%eax
  80068f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800692:	0f b6 07             	movzbl (%edi),%eax
  800695:	0f b6 c8             	movzbl %al,%ecx
  800698:	83 e8 23             	sub    $0x23,%eax
  80069b:	3c 55                	cmp    $0x55,%al
  80069d:	0f 87 1a 03 00 00    	ja     8009bd <vprintfmt+0x38a>
  8006a3:	0f b6 c0             	movzbl %al,%eax
  8006a6:	ff 24 85 80 2c 80 00 	jmp    *0x802c80(,%eax,4)
  8006ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006b0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8006b4:	eb d6                	jmp    80068c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006c1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8006c4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8006c8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8006cb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8006ce:	83 fa 09             	cmp    $0x9,%edx
  8006d1:	77 39                	ja     80070c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006d3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006d6:	eb e9                	jmp    8006c1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 48 04             	lea    0x4(%eax),%ecx
  8006de:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006e1:	8b 00                	mov    (%eax),%eax
  8006e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006e9:	eb 27                	jmp    800712 <vprintfmt+0xdf>
  8006eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f5:	0f 49 c8             	cmovns %eax,%ecx
  8006f8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006fe:	eb 8c                	jmp    80068c <vprintfmt+0x59>
  800700:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800703:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80070a:	eb 80                	jmp    80068c <vprintfmt+0x59>
  80070c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80070f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800712:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800716:	0f 89 70 ff ff ff    	jns    80068c <vprintfmt+0x59>
				width = precision, precision = -1;
  80071c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80071f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800722:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800729:	e9 5e ff ff ff       	jmp    80068c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80072e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800731:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800734:	e9 53 ff ff ff       	jmp    80068c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800739:	8b 45 14             	mov    0x14(%ebp),%eax
  80073c:	8d 50 04             	lea    0x4(%eax),%edx
  80073f:	89 55 14             	mov    %edx,0x14(%ebp)
  800742:	83 ec 08             	sub    $0x8,%esp
  800745:	53                   	push   %ebx
  800746:	ff 30                	pushl  (%eax)
  800748:	ff d6                	call   *%esi
			break;
  80074a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800750:	e9 04 ff ff ff       	jmp    800659 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800755:	8b 45 14             	mov    0x14(%ebp),%eax
  800758:	8d 50 04             	lea    0x4(%eax),%edx
  80075b:	89 55 14             	mov    %edx,0x14(%ebp)
  80075e:	8b 00                	mov    (%eax),%eax
  800760:	99                   	cltd   
  800761:	31 d0                	xor    %edx,%eax
  800763:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800765:	83 f8 0f             	cmp    $0xf,%eax
  800768:	7f 0b                	jg     800775 <vprintfmt+0x142>
  80076a:	8b 14 85 e0 2d 80 00 	mov    0x802de0(,%eax,4),%edx
  800771:	85 d2                	test   %edx,%edx
  800773:	75 18                	jne    80078d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800775:	50                   	push   %eax
  800776:	68 47 2b 80 00       	push   $0x802b47
  80077b:	53                   	push   %ebx
  80077c:	56                   	push   %esi
  80077d:	e8 94 fe ff ff       	call   800616 <printfmt>
  800782:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800785:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800788:	e9 cc fe ff ff       	jmp    800659 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80078d:	52                   	push   %edx
  80078e:	68 8d 2f 80 00       	push   $0x802f8d
  800793:	53                   	push   %ebx
  800794:	56                   	push   %esi
  800795:	e8 7c fe ff ff       	call   800616 <printfmt>
  80079a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a0:	e9 b4 fe ff ff       	jmp    800659 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8d 50 04             	lea    0x4(%eax),%edx
  8007ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ae:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8007b0:	85 ff                	test   %edi,%edi
  8007b2:	b8 40 2b 80 00       	mov    $0x802b40,%eax
  8007b7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8007ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007be:	0f 8e 94 00 00 00    	jle    800858 <vprintfmt+0x225>
  8007c4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8007c8:	0f 84 98 00 00 00    	je     800866 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	ff 75 d0             	pushl  -0x30(%ebp)
  8007d4:	57                   	push   %edi
  8007d5:	e8 86 02 00 00       	call   800a60 <strnlen>
  8007da:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007dd:	29 c1                	sub    %eax,%ecx
  8007df:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007e2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8007e5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007ec:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007ef:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007f1:	eb 0f                	jmp    800802 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8007f3:	83 ec 08             	sub    $0x8,%esp
  8007f6:	53                   	push   %ebx
  8007f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8007fa:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007fc:	83 ef 01             	sub    $0x1,%edi
  8007ff:	83 c4 10             	add    $0x10,%esp
  800802:	85 ff                	test   %edi,%edi
  800804:	7f ed                	jg     8007f3 <vprintfmt+0x1c0>
  800806:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800809:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80080c:	85 c9                	test   %ecx,%ecx
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
  800813:	0f 49 c1             	cmovns %ecx,%eax
  800816:	29 c1                	sub    %eax,%ecx
  800818:	89 75 08             	mov    %esi,0x8(%ebp)
  80081b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80081e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800821:	89 cb                	mov    %ecx,%ebx
  800823:	eb 4d                	jmp    800872 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800825:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800829:	74 1b                	je     800846 <vprintfmt+0x213>
  80082b:	0f be c0             	movsbl %al,%eax
  80082e:	83 e8 20             	sub    $0x20,%eax
  800831:	83 f8 5e             	cmp    $0x5e,%eax
  800834:	76 10                	jbe    800846 <vprintfmt+0x213>
					putch('?', putdat);
  800836:	83 ec 08             	sub    $0x8,%esp
  800839:	ff 75 0c             	pushl  0xc(%ebp)
  80083c:	6a 3f                	push   $0x3f
  80083e:	ff 55 08             	call   *0x8(%ebp)
  800841:	83 c4 10             	add    $0x10,%esp
  800844:	eb 0d                	jmp    800853 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	ff 75 0c             	pushl  0xc(%ebp)
  80084c:	52                   	push   %edx
  80084d:	ff 55 08             	call   *0x8(%ebp)
  800850:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800853:	83 eb 01             	sub    $0x1,%ebx
  800856:	eb 1a                	jmp    800872 <vprintfmt+0x23f>
  800858:	89 75 08             	mov    %esi,0x8(%ebp)
  80085b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80085e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800861:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800864:	eb 0c                	jmp    800872 <vprintfmt+0x23f>
  800866:	89 75 08             	mov    %esi,0x8(%ebp)
  800869:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80086c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80086f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800872:	83 c7 01             	add    $0x1,%edi
  800875:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800879:	0f be d0             	movsbl %al,%edx
  80087c:	85 d2                	test   %edx,%edx
  80087e:	74 23                	je     8008a3 <vprintfmt+0x270>
  800880:	85 f6                	test   %esi,%esi
  800882:	78 a1                	js     800825 <vprintfmt+0x1f2>
  800884:	83 ee 01             	sub    $0x1,%esi
  800887:	79 9c                	jns    800825 <vprintfmt+0x1f2>
  800889:	89 df                	mov    %ebx,%edi
  80088b:	8b 75 08             	mov    0x8(%ebp),%esi
  80088e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800891:	eb 18                	jmp    8008ab <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800893:	83 ec 08             	sub    $0x8,%esp
  800896:	53                   	push   %ebx
  800897:	6a 20                	push   $0x20
  800899:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80089b:	83 ef 01             	sub    $0x1,%edi
  80089e:	83 c4 10             	add    $0x10,%esp
  8008a1:	eb 08                	jmp    8008ab <vprintfmt+0x278>
  8008a3:	89 df                	mov    %ebx,%edi
  8008a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ab:	85 ff                	test   %edi,%edi
  8008ad:	7f e4                	jg     800893 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008b2:	e9 a2 fd ff ff       	jmp    800659 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008b7:	83 fa 01             	cmp    $0x1,%edx
  8008ba:	7e 16                	jle    8008d2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8008bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bf:	8d 50 08             	lea    0x8(%eax),%edx
  8008c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c5:	8b 50 04             	mov    0x4(%eax),%edx
  8008c8:	8b 00                	mov    (%eax),%eax
  8008ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008cd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008d0:	eb 32                	jmp    800904 <vprintfmt+0x2d1>
	else if (lflag)
  8008d2:	85 d2                	test   %edx,%edx
  8008d4:	74 18                	je     8008ee <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8008d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d9:	8d 50 04             	lea    0x4(%eax),%edx
  8008dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008df:	8b 00                	mov    (%eax),%eax
  8008e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008e4:	89 c1                	mov    %eax,%ecx
  8008e6:	c1 f9 1f             	sar    $0x1f,%ecx
  8008e9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008ec:	eb 16                	jmp    800904 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8008ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f1:	8d 50 04             	lea    0x4(%eax),%edx
  8008f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f7:	8b 00                	mov    (%eax),%eax
  8008f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008fc:	89 c1                	mov    %eax,%ecx
  8008fe:	c1 f9 1f             	sar    $0x1f,%ecx
  800901:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800904:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800907:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80090a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80090f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800913:	79 74                	jns    800989 <vprintfmt+0x356>
				putch('-', putdat);
  800915:	83 ec 08             	sub    $0x8,%esp
  800918:	53                   	push   %ebx
  800919:	6a 2d                	push   $0x2d
  80091b:	ff d6                	call   *%esi
				num = -(long long) num;
  80091d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800920:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800923:	f7 d8                	neg    %eax
  800925:	83 d2 00             	adc    $0x0,%edx
  800928:	f7 da                	neg    %edx
  80092a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80092d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800932:	eb 55                	jmp    800989 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800934:	8d 45 14             	lea    0x14(%ebp),%eax
  800937:	e8 83 fc ff ff       	call   8005bf <getuint>
			base = 10;
  80093c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800941:	eb 46                	jmp    800989 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800943:	8d 45 14             	lea    0x14(%ebp),%eax
  800946:	e8 74 fc ff ff       	call   8005bf <getuint>
			base = 8;
  80094b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800950:	eb 37                	jmp    800989 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800952:	83 ec 08             	sub    $0x8,%esp
  800955:	53                   	push   %ebx
  800956:	6a 30                	push   $0x30
  800958:	ff d6                	call   *%esi
			putch('x', putdat);
  80095a:	83 c4 08             	add    $0x8,%esp
  80095d:	53                   	push   %ebx
  80095e:	6a 78                	push   $0x78
  800960:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800962:	8b 45 14             	mov    0x14(%ebp),%eax
  800965:	8d 50 04             	lea    0x4(%eax),%edx
  800968:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80096b:	8b 00                	mov    (%eax),%eax
  80096d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800972:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800975:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80097a:	eb 0d                	jmp    800989 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80097c:	8d 45 14             	lea    0x14(%ebp),%eax
  80097f:	e8 3b fc ff ff       	call   8005bf <getuint>
			base = 16;
  800984:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800989:	83 ec 0c             	sub    $0xc,%esp
  80098c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800990:	57                   	push   %edi
  800991:	ff 75 e0             	pushl  -0x20(%ebp)
  800994:	51                   	push   %ecx
  800995:	52                   	push   %edx
  800996:	50                   	push   %eax
  800997:	89 da                	mov    %ebx,%edx
  800999:	89 f0                	mov    %esi,%eax
  80099b:	e8 70 fb ff ff       	call   800510 <printnum>
			break;
  8009a0:	83 c4 20             	add    $0x20,%esp
  8009a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009a6:	e9 ae fc ff ff       	jmp    800659 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009ab:	83 ec 08             	sub    $0x8,%esp
  8009ae:	53                   	push   %ebx
  8009af:	51                   	push   %ecx
  8009b0:	ff d6                	call   *%esi
			break;
  8009b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009b8:	e9 9c fc ff ff       	jmp    800659 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009bd:	83 ec 08             	sub    $0x8,%esp
  8009c0:	53                   	push   %ebx
  8009c1:	6a 25                	push   $0x25
  8009c3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009c5:	83 c4 10             	add    $0x10,%esp
  8009c8:	eb 03                	jmp    8009cd <vprintfmt+0x39a>
  8009ca:	83 ef 01             	sub    $0x1,%edi
  8009cd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8009d1:	75 f7                	jne    8009ca <vprintfmt+0x397>
  8009d3:	e9 81 fc ff ff       	jmp    800659 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8009d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5f                   	pop    %edi
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	83 ec 18             	sub    $0x18,%esp
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009ef:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009f3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009fd:	85 c0                	test   %eax,%eax
  8009ff:	74 26                	je     800a27 <vsnprintf+0x47>
  800a01:	85 d2                	test   %edx,%edx
  800a03:	7e 22                	jle    800a27 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a05:	ff 75 14             	pushl  0x14(%ebp)
  800a08:	ff 75 10             	pushl  0x10(%ebp)
  800a0b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a0e:	50                   	push   %eax
  800a0f:	68 f9 05 80 00       	push   $0x8005f9
  800a14:	e8 1a fc ff ff       	call   800633 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a19:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a1c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a22:	83 c4 10             	add    $0x10,%esp
  800a25:	eb 05                	jmp    800a2c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a27:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a2c:	c9                   	leave  
  800a2d:	c3                   	ret    

00800a2e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a34:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a37:	50                   	push   %eax
  800a38:	ff 75 10             	pushl  0x10(%ebp)
  800a3b:	ff 75 0c             	pushl  0xc(%ebp)
  800a3e:	ff 75 08             	pushl  0x8(%ebp)
  800a41:	e8 9a ff ff ff       	call   8009e0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a46:	c9                   	leave  
  800a47:	c3                   	ret    

00800a48 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a53:	eb 03                	jmp    800a58 <strlen+0x10>
		n++;
  800a55:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a58:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a5c:	75 f7                	jne    800a55 <strlen+0xd>
		n++;
	return n;
}
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a66:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a69:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6e:	eb 03                	jmp    800a73 <strnlen+0x13>
		n++;
  800a70:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a73:	39 c2                	cmp    %eax,%edx
  800a75:	74 08                	je     800a7f <strnlen+0x1f>
  800a77:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a7b:	75 f3                	jne    800a70 <strnlen+0x10>
  800a7d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	53                   	push   %ebx
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a8b:	89 c2                	mov    %eax,%edx
  800a8d:	83 c2 01             	add    $0x1,%edx
  800a90:	83 c1 01             	add    $0x1,%ecx
  800a93:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a97:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a9a:	84 db                	test   %bl,%bl
  800a9c:	75 ef                	jne    800a8d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a9e:	5b                   	pop    %ebx
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	53                   	push   %ebx
  800aa5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa8:	53                   	push   %ebx
  800aa9:	e8 9a ff ff ff       	call   800a48 <strlen>
  800aae:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ab1:	ff 75 0c             	pushl  0xc(%ebp)
  800ab4:	01 d8                	add    %ebx,%eax
  800ab6:	50                   	push   %eax
  800ab7:	e8 c5 ff ff ff       	call   800a81 <strcpy>
	return dst;
}
  800abc:	89 d8                	mov    %ebx,%eax
  800abe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    

00800ac3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
  800ac8:	8b 75 08             	mov    0x8(%ebp),%esi
  800acb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ace:	89 f3                	mov    %esi,%ebx
  800ad0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ad3:	89 f2                	mov    %esi,%edx
  800ad5:	eb 0f                	jmp    800ae6 <strncpy+0x23>
		*dst++ = *src;
  800ad7:	83 c2 01             	add    $0x1,%edx
  800ada:	0f b6 01             	movzbl (%ecx),%eax
  800add:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ae0:	80 39 01             	cmpb   $0x1,(%ecx)
  800ae3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae6:	39 da                	cmp    %ebx,%edx
  800ae8:	75 ed                	jne    800ad7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aea:	89 f0                	mov    %esi,%eax
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	8b 75 08             	mov    0x8(%ebp),%esi
  800af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afb:	8b 55 10             	mov    0x10(%ebp),%edx
  800afe:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b00:	85 d2                	test   %edx,%edx
  800b02:	74 21                	je     800b25 <strlcpy+0x35>
  800b04:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b08:	89 f2                	mov    %esi,%edx
  800b0a:	eb 09                	jmp    800b15 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b0c:	83 c2 01             	add    $0x1,%edx
  800b0f:	83 c1 01             	add    $0x1,%ecx
  800b12:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b15:	39 c2                	cmp    %eax,%edx
  800b17:	74 09                	je     800b22 <strlcpy+0x32>
  800b19:	0f b6 19             	movzbl (%ecx),%ebx
  800b1c:	84 db                	test   %bl,%bl
  800b1e:	75 ec                	jne    800b0c <strlcpy+0x1c>
  800b20:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b22:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b25:	29 f0                	sub    %esi,%eax
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b31:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b34:	eb 06                	jmp    800b3c <strcmp+0x11>
		p++, q++;
  800b36:	83 c1 01             	add    $0x1,%ecx
  800b39:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b3c:	0f b6 01             	movzbl (%ecx),%eax
  800b3f:	84 c0                	test   %al,%al
  800b41:	74 04                	je     800b47 <strcmp+0x1c>
  800b43:	3a 02                	cmp    (%edx),%al
  800b45:	74 ef                	je     800b36 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b47:	0f b6 c0             	movzbl %al,%eax
  800b4a:	0f b6 12             	movzbl (%edx),%edx
  800b4d:	29 d0                	sub    %edx,%eax
}
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	53                   	push   %ebx
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5b:	89 c3                	mov    %eax,%ebx
  800b5d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b60:	eb 06                	jmp    800b68 <strncmp+0x17>
		n--, p++, q++;
  800b62:	83 c0 01             	add    $0x1,%eax
  800b65:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b68:	39 d8                	cmp    %ebx,%eax
  800b6a:	74 15                	je     800b81 <strncmp+0x30>
  800b6c:	0f b6 08             	movzbl (%eax),%ecx
  800b6f:	84 c9                	test   %cl,%cl
  800b71:	74 04                	je     800b77 <strncmp+0x26>
  800b73:	3a 0a                	cmp    (%edx),%cl
  800b75:	74 eb                	je     800b62 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b77:	0f b6 00             	movzbl (%eax),%eax
  800b7a:	0f b6 12             	movzbl (%edx),%edx
  800b7d:	29 d0                	sub    %edx,%eax
  800b7f:	eb 05                	jmp    800b86 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b93:	eb 07                	jmp    800b9c <strchr+0x13>
		if (*s == c)
  800b95:	38 ca                	cmp    %cl,%dl
  800b97:	74 0f                	je     800ba8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b99:	83 c0 01             	add    $0x1,%eax
  800b9c:	0f b6 10             	movzbl (%eax),%edx
  800b9f:	84 d2                	test   %dl,%dl
  800ba1:	75 f2                	jne    800b95 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ba3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb4:	eb 03                	jmp    800bb9 <strfind+0xf>
  800bb6:	83 c0 01             	add    $0x1,%eax
  800bb9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bbc:	38 ca                	cmp    %cl,%dl
  800bbe:	74 04                	je     800bc4 <strfind+0x1a>
  800bc0:	84 d2                	test   %dl,%dl
  800bc2:	75 f2                	jne    800bb6 <strfind+0xc>
			break;
	return (char *) s;
}
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bd2:	85 c9                	test   %ecx,%ecx
  800bd4:	74 36                	je     800c0c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bdc:	75 28                	jne    800c06 <memset+0x40>
  800bde:	f6 c1 03             	test   $0x3,%cl
  800be1:	75 23                	jne    800c06 <memset+0x40>
		c &= 0xFF;
  800be3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be7:	89 d3                	mov    %edx,%ebx
  800be9:	c1 e3 08             	shl    $0x8,%ebx
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	c1 e6 18             	shl    $0x18,%esi
  800bf1:	89 d0                	mov    %edx,%eax
  800bf3:	c1 e0 10             	shl    $0x10,%eax
  800bf6:	09 f0                	or     %esi,%eax
  800bf8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bfa:	89 d8                	mov    %ebx,%eax
  800bfc:	09 d0                	or     %edx,%eax
  800bfe:	c1 e9 02             	shr    $0x2,%ecx
  800c01:	fc                   	cld    
  800c02:	f3 ab                	rep stos %eax,%es:(%edi)
  800c04:	eb 06                	jmp    800c0c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c09:	fc                   	cld    
  800c0a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c0c:	89 f8                	mov    %edi,%eax
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c21:	39 c6                	cmp    %eax,%esi
  800c23:	73 35                	jae    800c5a <memmove+0x47>
  800c25:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c28:	39 d0                	cmp    %edx,%eax
  800c2a:	73 2e                	jae    800c5a <memmove+0x47>
		s += n;
		d += n;
  800c2c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2f:	89 d6                	mov    %edx,%esi
  800c31:	09 fe                	or     %edi,%esi
  800c33:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c39:	75 13                	jne    800c4e <memmove+0x3b>
  800c3b:	f6 c1 03             	test   $0x3,%cl
  800c3e:	75 0e                	jne    800c4e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c40:	83 ef 04             	sub    $0x4,%edi
  800c43:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c46:	c1 e9 02             	shr    $0x2,%ecx
  800c49:	fd                   	std    
  800c4a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4c:	eb 09                	jmp    800c57 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c4e:	83 ef 01             	sub    $0x1,%edi
  800c51:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c54:	fd                   	std    
  800c55:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c57:	fc                   	cld    
  800c58:	eb 1d                	jmp    800c77 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c5a:	89 f2                	mov    %esi,%edx
  800c5c:	09 c2                	or     %eax,%edx
  800c5e:	f6 c2 03             	test   $0x3,%dl
  800c61:	75 0f                	jne    800c72 <memmove+0x5f>
  800c63:	f6 c1 03             	test   $0x3,%cl
  800c66:	75 0a                	jne    800c72 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c68:	c1 e9 02             	shr    $0x2,%ecx
  800c6b:	89 c7                	mov    %eax,%edi
  800c6d:	fc                   	cld    
  800c6e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c70:	eb 05                	jmp    800c77 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c72:	89 c7                	mov    %eax,%edi
  800c74:	fc                   	cld    
  800c75:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c7e:	ff 75 10             	pushl  0x10(%ebp)
  800c81:	ff 75 0c             	pushl  0xc(%ebp)
  800c84:	ff 75 08             	pushl  0x8(%ebp)
  800c87:	e8 87 ff ff ff       	call   800c13 <memmove>
}
  800c8c:	c9                   	leave  
  800c8d:	c3                   	ret    

00800c8e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	8b 45 08             	mov    0x8(%ebp),%eax
  800c96:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c99:	89 c6                	mov    %eax,%esi
  800c9b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c9e:	eb 1a                	jmp    800cba <memcmp+0x2c>
		if (*s1 != *s2)
  800ca0:	0f b6 08             	movzbl (%eax),%ecx
  800ca3:	0f b6 1a             	movzbl (%edx),%ebx
  800ca6:	38 d9                	cmp    %bl,%cl
  800ca8:	74 0a                	je     800cb4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800caa:	0f b6 c1             	movzbl %cl,%eax
  800cad:	0f b6 db             	movzbl %bl,%ebx
  800cb0:	29 d8                	sub    %ebx,%eax
  800cb2:	eb 0f                	jmp    800cc3 <memcmp+0x35>
		s1++, s2++;
  800cb4:	83 c0 01             	add    $0x1,%eax
  800cb7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cba:	39 f0                	cmp    %esi,%eax
  800cbc:	75 e2                	jne    800ca0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	53                   	push   %ebx
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cce:	89 c1                	mov    %eax,%ecx
  800cd0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cd7:	eb 0a                	jmp    800ce3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd9:	0f b6 10             	movzbl (%eax),%edx
  800cdc:	39 da                	cmp    %ebx,%edx
  800cde:	74 07                	je     800ce7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ce0:	83 c0 01             	add    $0x1,%eax
  800ce3:	39 c8                	cmp    %ecx,%eax
  800ce5:	72 f2                	jb     800cd9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf6:	eb 03                	jmp    800cfb <strtol+0x11>
		s++;
  800cf8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cfb:	0f b6 01             	movzbl (%ecx),%eax
  800cfe:	3c 20                	cmp    $0x20,%al
  800d00:	74 f6                	je     800cf8 <strtol+0xe>
  800d02:	3c 09                	cmp    $0x9,%al
  800d04:	74 f2                	je     800cf8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d06:	3c 2b                	cmp    $0x2b,%al
  800d08:	75 0a                	jne    800d14 <strtol+0x2a>
		s++;
  800d0a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d0d:	bf 00 00 00 00       	mov    $0x0,%edi
  800d12:	eb 11                	jmp    800d25 <strtol+0x3b>
  800d14:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d19:	3c 2d                	cmp    $0x2d,%al
  800d1b:	75 08                	jne    800d25 <strtol+0x3b>
		s++, neg = 1;
  800d1d:	83 c1 01             	add    $0x1,%ecx
  800d20:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d25:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d2b:	75 15                	jne    800d42 <strtol+0x58>
  800d2d:	80 39 30             	cmpb   $0x30,(%ecx)
  800d30:	75 10                	jne    800d42 <strtol+0x58>
  800d32:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d36:	75 7c                	jne    800db4 <strtol+0xca>
		s += 2, base = 16;
  800d38:	83 c1 02             	add    $0x2,%ecx
  800d3b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d40:	eb 16                	jmp    800d58 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d42:	85 db                	test   %ebx,%ebx
  800d44:	75 12                	jne    800d58 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d46:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d4b:	80 39 30             	cmpb   $0x30,(%ecx)
  800d4e:	75 08                	jne    800d58 <strtol+0x6e>
		s++, base = 8;
  800d50:	83 c1 01             	add    $0x1,%ecx
  800d53:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d58:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d60:	0f b6 11             	movzbl (%ecx),%edx
  800d63:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d66:	89 f3                	mov    %esi,%ebx
  800d68:	80 fb 09             	cmp    $0x9,%bl
  800d6b:	77 08                	ja     800d75 <strtol+0x8b>
			dig = *s - '0';
  800d6d:	0f be d2             	movsbl %dl,%edx
  800d70:	83 ea 30             	sub    $0x30,%edx
  800d73:	eb 22                	jmp    800d97 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d75:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d78:	89 f3                	mov    %esi,%ebx
  800d7a:	80 fb 19             	cmp    $0x19,%bl
  800d7d:	77 08                	ja     800d87 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d7f:	0f be d2             	movsbl %dl,%edx
  800d82:	83 ea 57             	sub    $0x57,%edx
  800d85:	eb 10                	jmp    800d97 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d87:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d8a:	89 f3                	mov    %esi,%ebx
  800d8c:	80 fb 19             	cmp    $0x19,%bl
  800d8f:	77 16                	ja     800da7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d91:	0f be d2             	movsbl %dl,%edx
  800d94:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d97:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d9a:	7d 0b                	jge    800da7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d9c:	83 c1 01             	add    $0x1,%ecx
  800d9f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800da3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800da5:	eb b9                	jmp    800d60 <strtol+0x76>

	if (endptr)
  800da7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dab:	74 0d                	je     800dba <strtol+0xd0>
		*endptr = (char *) s;
  800dad:	8b 75 0c             	mov    0xc(%ebp),%esi
  800db0:	89 0e                	mov    %ecx,(%esi)
  800db2:	eb 06                	jmp    800dba <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800db4:	85 db                	test   %ebx,%ebx
  800db6:	74 98                	je     800d50 <strtol+0x66>
  800db8:	eb 9e                	jmp    800d58 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800dba:	89 c2                	mov    %eax,%edx
  800dbc:	f7 da                	neg    %edx
  800dbe:	85 ff                	test   %edi,%edi
  800dc0:	0f 45 c2             	cmovne %edx,%eax
}
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dce:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	89 c3                	mov    %eax,%ebx
  800ddb:	89 c7                	mov    %eax,%edi
  800ddd:	89 c6                	mov    %eax,%esi
  800ddf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dec:	ba 00 00 00 00       	mov    $0x0,%edx
  800df1:	b8 01 00 00 00       	mov    $0x1,%eax
  800df6:	89 d1                	mov    %edx,%ecx
  800df8:	89 d3                	mov    %edx,%ebx
  800dfa:	89 d7                	mov    %edx,%edi
  800dfc:	89 d6                	mov    %edx,%esi
  800dfe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
  800e0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e13:	b8 03 00 00 00       	mov    $0x3,%eax
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 cb                	mov    %ecx,%ebx
  800e1d:	89 cf                	mov    %ecx,%edi
  800e1f:	89 ce                	mov    %ecx,%esi
  800e21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e23:	85 c0                	test   %eax,%eax
  800e25:	7e 17                	jle    800e3e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	50                   	push   %eax
  800e2b:	6a 03                	push   $0x3
  800e2d:	68 3f 2e 80 00       	push   $0x802e3f
  800e32:	6a 23                	push   $0x23
  800e34:	68 5c 2e 80 00       	push   $0x802e5c
  800e39:	e8 e5 f5 ff ff       	call   800423 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e51:	b8 02 00 00 00       	mov    $0x2,%eax
  800e56:	89 d1                	mov    %edx,%ecx
  800e58:	89 d3                	mov    %edx,%ebx
  800e5a:	89 d7                	mov    %edx,%edi
  800e5c:	89 d6                	mov    %edx,%esi
  800e5e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sys_yield>:

void
sys_yield(void)
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
  800e6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e70:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e75:	89 d1                	mov    %edx,%ecx
  800e77:	89 d3                	mov    %edx,%ebx
  800e79:	89 d7                	mov    %edx,%edi
  800e7b:	89 d6                	mov    %edx,%esi
  800e7d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
  800e8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8d:	be 00 00 00 00       	mov    $0x0,%esi
  800e92:	b8 04 00 00 00       	mov    $0x4,%eax
  800e97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea0:	89 f7                	mov    %esi,%edi
  800ea2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	7e 17                	jle    800ebf <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	50                   	push   %eax
  800eac:	6a 04                	push   $0x4
  800eae:	68 3f 2e 80 00       	push   $0x802e3f
  800eb3:	6a 23                	push   $0x23
  800eb5:	68 5c 2e 80 00       	push   $0x802e5c
  800eba:	e8 64 f5 ff ff       	call   800423 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ebf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec2:	5b                   	pop    %ebx
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	57                   	push   %edi
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
  800ecd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed8:	8b 55 08             	mov    0x8(%ebp),%edx
  800edb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ede:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ee1:	8b 75 18             	mov    0x18(%ebp),%esi
  800ee4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	7e 17                	jle    800f01 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eea:	83 ec 0c             	sub    $0xc,%esp
  800eed:	50                   	push   %eax
  800eee:	6a 05                	push   $0x5
  800ef0:	68 3f 2e 80 00       	push   $0x802e3f
  800ef5:	6a 23                	push   $0x23
  800ef7:	68 5c 2e 80 00       	push   $0x802e5c
  800efc:	e8 22 f5 ff ff       	call   800423 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	57                   	push   %edi
  800f0d:	56                   	push   %esi
  800f0e:	53                   	push   %ebx
  800f0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f17:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f22:	89 df                	mov    %ebx,%edi
  800f24:	89 de                	mov    %ebx,%esi
  800f26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	7e 17                	jle    800f43 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2c:	83 ec 0c             	sub    $0xc,%esp
  800f2f:	50                   	push   %eax
  800f30:	6a 06                	push   $0x6
  800f32:	68 3f 2e 80 00       	push   $0x802e3f
  800f37:	6a 23                	push   $0x23
  800f39:	68 5c 2e 80 00       	push   $0x802e5c
  800f3e:	e8 e0 f4 ff ff       	call   800423 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	57                   	push   %edi
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
  800f51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f59:	b8 08 00 00 00       	mov    $0x8,%eax
  800f5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f61:	8b 55 08             	mov    0x8(%ebp),%edx
  800f64:	89 df                	mov    %ebx,%edi
  800f66:	89 de                	mov    %ebx,%esi
  800f68:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	7e 17                	jle    800f85 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6e:	83 ec 0c             	sub    $0xc,%esp
  800f71:	50                   	push   %eax
  800f72:	6a 08                	push   $0x8
  800f74:	68 3f 2e 80 00       	push   $0x802e3f
  800f79:	6a 23                	push   $0x23
  800f7b:	68 5c 2e 80 00       	push   $0x802e5c
  800f80:	e8 9e f4 ff ff       	call   800423 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800f96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9b:	b8 09 00 00 00       	mov    $0x9,%eax
  800fa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa6:	89 df                	mov    %ebx,%edi
  800fa8:	89 de                	mov    %ebx,%esi
  800faa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fac:	85 c0                	test   %eax,%eax
  800fae:	7e 17                	jle    800fc7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb0:	83 ec 0c             	sub    $0xc,%esp
  800fb3:	50                   	push   %eax
  800fb4:	6a 09                	push   $0x9
  800fb6:	68 3f 2e 80 00       	push   $0x802e3f
  800fbb:	6a 23                	push   $0x23
  800fbd:	68 5c 2e 80 00       	push   $0x802e5c
  800fc2:	e8 5c f4 ff ff       	call   800423 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fca:	5b                   	pop    %ebx
  800fcb:	5e                   	pop    %esi
  800fcc:	5f                   	pop    %edi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	57                   	push   %edi
  800fd3:	56                   	push   %esi
  800fd4:	53                   	push   %ebx
  800fd5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fe2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe8:	89 df                	mov    %ebx,%edi
  800fea:	89 de                	mov    %ebx,%esi
  800fec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	7e 17                	jle    801009 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff2:	83 ec 0c             	sub    $0xc,%esp
  800ff5:	50                   	push   %eax
  800ff6:	6a 0a                	push   $0xa
  800ff8:	68 3f 2e 80 00       	push   $0x802e3f
  800ffd:	6a 23                	push   $0x23
  800fff:	68 5c 2e 80 00       	push   $0x802e5c
  801004:	e8 1a f4 ff ff       	call   800423 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801009:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100c:	5b                   	pop    %ebx
  80100d:	5e                   	pop    %esi
  80100e:	5f                   	pop    %edi
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    

00801011 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	57                   	push   %edi
  801015:	56                   	push   %esi
  801016:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801017:	be 00 00 00 00       	mov    $0x0,%esi
  80101c:	b8 0c 00 00 00       	mov    $0xc,%eax
  801021:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801024:	8b 55 08             	mov    0x8(%ebp),%edx
  801027:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80102a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80102d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5f                   	pop    %edi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	57                   	push   %edi
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
  80103a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801042:	b8 0d 00 00 00       	mov    $0xd,%eax
  801047:	8b 55 08             	mov    0x8(%ebp),%edx
  80104a:	89 cb                	mov    %ecx,%ebx
  80104c:	89 cf                	mov    %ecx,%edi
  80104e:	89 ce                	mov    %ecx,%esi
  801050:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801052:	85 c0                	test   %eax,%eax
  801054:	7e 17                	jle    80106d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801056:	83 ec 0c             	sub    $0xc,%esp
  801059:	50                   	push   %eax
  80105a:	6a 0d                	push   $0xd
  80105c:	68 3f 2e 80 00       	push   $0x802e3f
  801061:	6a 23                	push   $0x23
  801063:	68 5c 2e 80 00       	push   $0x802e5c
  801068:	e8 b6 f3 ff ff       	call   800423 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80106d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5f                   	pop    %edi
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	57                   	push   %edi
  801079:	56                   	push   %esi
  80107a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801080:	b8 0e 00 00 00       	mov    $0xe,%eax
  801085:	8b 55 08             	mov    0x8(%ebp),%edx
  801088:	89 cb                	mov    %ecx,%ebx
  80108a:	89 cf                	mov    %ecx,%edi
  80108c:	89 ce                	mov    %ecx,%esi
  80108e:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010a0:	b8 0f 00 00 00       	mov    $0xf,%eax
  8010a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a8:	89 cb                	mov    %ecx,%ebx
  8010aa:	89 cf                	mov    %ecx,%edi
  8010ac:	89 ce                	mov    %ecx,%esi
  8010ae:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8010b0:	5b                   	pop    %ebx
  8010b1:	5e                   	pop    %esi
  8010b2:	5f                   	pop    %edi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 04             	sub    $0x4,%esp
  8010bc:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010bf:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8010c1:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8010c5:	74 11                	je     8010d8 <pgfault+0x23>
  8010c7:	89 d8                	mov    %ebx,%eax
  8010c9:	c1 e8 0c             	shr    $0xc,%eax
  8010cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d3:	f6 c4 08             	test   $0x8,%ah
  8010d6:	75 14                	jne    8010ec <pgfault+0x37>
		panic("faulting access");
  8010d8:	83 ec 04             	sub    $0x4,%esp
  8010db:	68 6a 2e 80 00       	push   $0x802e6a
  8010e0:	6a 1e                	push   $0x1e
  8010e2:	68 7a 2e 80 00       	push   $0x802e7a
  8010e7:	e8 37 f3 ff ff       	call   800423 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8010ec:	83 ec 04             	sub    $0x4,%esp
  8010ef:	6a 07                	push   $0x7
  8010f1:	68 00 f0 7f 00       	push   $0x7ff000
  8010f6:	6a 00                	push   $0x0
  8010f8:	e8 87 fd ff ff       	call   800e84 <sys_page_alloc>
	if (r < 0) {
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	85 c0                	test   %eax,%eax
  801102:	79 12                	jns    801116 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  801104:	50                   	push   %eax
  801105:	68 85 2e 80 00       	push   $0x802e85
  80110a:	6a 2c                	push   $0x2c
  80110c:	68 7a 2e 80 00       	push   $0x802e7a
  801111:	e8 0d f3 ff ff       	call   800423 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  801116:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80111c:	83 ec 04             	sub    $0x4,%esp
  80111f:	68 00 10 00 00       	push   $0x1000
  801124:	53                   	push   %ebx
  801125:	68 00 f0 7f 00       	push   $0x7ff000
  80112a:	e8 4c fb ff ff       	call   800c7b <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  80112f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801136:	53                   	push   %ebx
  801137:	6a 00                	push   $0x0
  801139:	68 00 f0 7f 00       	push   $0x7ff000
  80113e:	6a 00                	push   $0x0
  801140:	e8 82 fd ff ff       	call   800ec7 <sys_page_map>
	if (r < 0) {
  801145:	83 c4 20             	add    $0x20,%esp
  801148:	85 c0                	test   %eax,%eax
  80114a:	79 12                	jns    80115e <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80114c:	50                   	push   %eax
  80114d:	68 85 2e 80 00       	push   $0x802e85
  801152:	6a 33                	push   $0x33
  801154:	68 7a 2e 80 00       	push   $0x802e7a
  801159:	e8 c5 f2 ff ff       	call   800423 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  80115e:	83 ec 08             	sub    $0x8,%esp
  801161:	68 00 f0 7f 00       	push   $0x7ff000
  801166:	6a 00                	push   $0x0
  801168:	e8 9c fd ff ff       	call   800f09 <sys_page_unmap>
	if (r < 0) {
  80116d:	83 c4 10             	add    $0x10,%esp
  801170:	85 c0                	test   %eax,%eax
  801172:	79 12                	jns    801186 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  801174:	50                   	push   %eax
  801175:	68 85 2e 80 00       	push   $0x802e85
  80117a:	6a 37                	push   $0x37
  80117c:	68 7a 2e 80 00       	push   $0x802e7a
  801181:	e8 9d f2 ff ff       	call   800423 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  801186:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801189:	c9                   	leave  
  80118a:	c3                   	ret    

0080118b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
  80118e:	57                   	push   %edi
  80118f:	56                   	push   %esi
  801190:	53                   	push   %ebx
  801191:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  801194:	68 b5 10 80 00       	push   $0x8010b5
  801199:	e8 a3 13 00 00       	call   802541 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80119e:	b8 07 00 00 00       	mov    $0x7,%eax
  8011a3:	cd 30                	int    $0x30
  8011a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	79 17                	jns    8011c6 <fork+0x3b>
		panic("fork fault %e");
  8011af:	83 ec 04             	sub    $0x4,%esp
  8011b2:	68 9e 2e 80 00       	push   $0x802e9e
  8011b7:	68 84 00 00 00       	push   $0x84
  8011bc:	68 7a 2e 80 00       	push   $0x802e7a
  8011c1:	e8 5d f2 ff ff       	call   800423 <_panic>
  8011c6:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8011c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011cc:	75 25                	jne    8011f3 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011ce:	e8 73 fc ff ff       	call   800e46 <sys_getenvid>
  8011d3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011d8:	89 c2                	mov    %eax,%edx
  8011da:	c1 e2 07             	shl    $0x7,%edx
  8011dd:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8011e4:	a3 90 77 80 00       	mov    %eax,0x807790
		return 0;
  8011e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ee:	e9 61 01 00 00       	jmp    801354 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8011f3:	83 ec 04             	sub    $0x4,%esp
  8011f6:	6a 07                	push   $0x7
  8011f8:	68 00 f0 bf ee       	push   $0xeebff000
  8011fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801200:	e8 7f fc ff ff       	call   800e84 <sys_page_alloc>
  801205:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801208:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80120d:	89 d8                	mov    %ebx,%eax
  80120f:	c1 e8 16             	shr    $0x16,%eax
  801212:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801219:	a8 01                	test   $0x1,%al
  80121b:	0f 84 fc 00 00 00    	je     80131d <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801221:	89 d8                	mov    %ebx,%eax
  801223:	c1 e8 0c             	shr    $0xc,%eax
  801226:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80122d:	f6 c2 01             	test   $0x1,%dl
  801230:	0f 84 e7 00 00 00    	je     80131d <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801236:	89 c6                	mov    %eax,%esi
  801238:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80123b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801242:	f6 c6 04             	test   $0x4,%dh
  801245:	74 39                	je     801280 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801247:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80124e:	83 ec 0c             	sub    $0xc,%esp
  801251:	25 07 0e 00 00       	and    $0xe07,%eax
  801256:	50                   	push   %eax
  801257:	56                   	push   %esi
  801258:	57                   	push   %edi
  801259:	56                   	push   %esi
  80125a:	6a 00                	push   $0x0
  80125c:	e8 66 fc ff ff       	call   800ec7 <sys_page_map>
		if (r < 0) {
  801261:	83 c4 20             	add    $0x20,%esp
  801264:	85 c0                	test   %eax,%eax
  801266:	0f 89 b1 00 00 00    	jns    80131d <fork+0x192>
		    	panic("sys page map fault %e");
  80126c:	83 ec 04             	sub    $0x4,%esp
  80126f:	68 ac 2e 80 00       	push   $0x802eac
  801274:	6a 54                	push   $0x54
  801276:	68 7a 2e 80 00       	push   $0x802e7a
  80127b:	e8 a3 f1 ff ff       	call   800423 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801280:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801287:	f6 c2 02             	test   $0x2,%dl
  80128a:	75 0c                	jne    801298 <fork+0x10d>
  80128c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801293:	f6 c4 08             	test   $0x8,%ah
  801296:	74 5b                	je     8012f3 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801298:	83 ec 0c             	sub    $0xc,%esp
  80129b:	68 05 08 00 00       	push   $0x805
  8012a0:	56                   	push   %esi
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	6a 00                	push   $0x0
  8012a5:	e8 1d fc ff ff       	call   800ec7 <sys_page_map>
		if (r < 0) {
  8012aa:	83 c4 20             	add    $0x20,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	79 14                	jns    8012c5 <fork+0x13a>
		    	panic("sys page map fault %e");
  8012b1:	83 ec 04             	sub    $0x4,%esp
  8012b4:	68 ac 2e 80 00       	push   $0x802eac
  8012b9:	6a 5b                	push   $0x5b
  8012bb:	68 7a 2e 80 00       	push   $0x802e7a
  8012c0:	e8 5e f1 ff ff       	call   800423 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8012c5:	83 ec 0c             	sub    $0xc,%esp
  8012c8:	68 05 08 00 00       	push   $0x805
  8012cd:	56                   	push   %esi
  8012ce:	6a 00                	push   $0x0
  8012d0:	56                   	push   %esi
  8012d1:	6a 00                	push   $0x0
  8012d3:	e8 ef fb ff ff       	call   800ec7 <sys_page_map>
		if (r < 0) {
  8012d8:	83 c4 20             	add    $0x20,%esp
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	79 3e                	jns    80131d <fork+0x192>
		    	panic("sys page map fault %e");
  8012df:	83 ec 04             	sub    $0x4,%esp
  8012e2:	68 ac 2e 80 00       	push   $0x802eac
  8012e7:	6a 5f                	push   $0x5f
  8012e9:	68 7a 2e 80 00       	push   $0x802e7a
  8012ee:	e8 30 f1 ff ff       	call   800423 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8012f3:	83 ec 0c             	sub    $0xc,%esp
  8012f6:	6a 05                	push   $0x5
  8012f8:	56                   	push   %esi
  8012f9:	57                   	push   %edi
  8012fa:	56                   	push   %esi
  8012fb:	6a 00                	push   $0x0
  8012fd:	e8 c5 fb ff ff       	call   800ec7 <sys_page_map>
		if (r < 0) {
  801302:	83 c4 20             	add    $0x20,%esp
  801305:	85 c0                	test   %eax,%eax
  801307:	79 14                	jns    80131d <fork+0x192>
		    	panic("sys page map fault %e");
  801309:	83 ec 04             	sub    $0x4,%esp
  80130c:	68 ac 2e 80 00       	push   $0x802eac
  801311:	6a 64                	push   $0x64
  801313:	68 7a 2e 80 00       	push   $0x802e7a
  801318:	e8 06 f1 ff ff       	call   800423 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80131d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801323:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801329:	0f 85 de fe ff ff    	jne    80120d <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80132f:	a1 90 77 80 00       	mov    0x807790,%eax
  801334:	8b 40 70             	mov    0x70(%eax),%eax
  801337:	83 ec 08             	sub    $0x8,%esp
  80133a:	50                   	push   %eax
  80133b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80133e:	57                   	push   %edi
  80133f:	e8 8b fc ff ff       	call   800fcf <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801344:	83 c4 08             	add    $0x8,%esp
  801347:	6a 02                	push   $0x2
  801349:	57                   	push   %edi
  80134a:	e8 fc fb ff ff       	call   800f4b <sys_env_set_status>
	
	return envid;
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801354:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801357:	5b                   	pop    %ebx
  801358:	5e                   	pop    %esi
  801359:	5f                   	pop    %edi
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <sfork>:

envid_t
sfork(void)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80135f:	b8 00 00 00 00       	mov    $0x0,%eax
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    

00801366 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	56                   	push   %esi
  80136a:	53                   	push   %ebx
  80136b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80136e:	89 1d 94 77 80 00    	mov    %ebx,0x807794
	cprintf("in fork.c thread create. func: %x\n", func);
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	53                   	push   %ebx
  801378:	68 c4 2e 80 00       	push   $0x802ec4
  80137d:	e8 7a f1 ff ff       	call   8004fc <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801382:	c7 04 24 e9 03 80 00 	movl   $0x8003e9,(%esp)
  801389:	e8 e7 fc ff ff       	call   801075 <sys_thread_create>
  80138e:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801390:	83 c4 08             	add    $0x8,%esp
  801393:	53                   	push   %ebx
  801394:	68 c4 2e 80 00       	push   $0x802ec4
  801399:	e8 5e f1 ff ff       	call   8004fc <cprintf>
	return id;
	//return 0;
}
  80139e:	89 f0                	mov    %esi,%eax
  8013a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a3:	5b                   	pop    %ebx
  8013a4:	5e                   	pop    %esi
  8013a5:	5d                   	pop    %ebp
  8013a6:	c3                   	ret    

008013a7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ad:	05 00 00 00 30       	add    $0x30000000,%eax
  8013b2:	c1 e8 0c             	shr    $0xc,%eax
}
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    

008013b7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bd:	05 00 00 00 30       	add    $0x30000000,%eax
  8013c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013c7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	c1 ea 16             	shr    $0x16,%edx
  8013de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013e5:	f6 c2 01             	test   $0x1,%dl
  8013e8:	74 11                	je     8013fb <fd_alloc+0x2d>
  8013ea:	89 c2                	mov    %eax,%edx
  8013ec:	c1 ea 0c             	shr    $0xc,%edx
  8013ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013f6:	f6 c2 01             	test   $0x1,%dl
  8013f9:	75 09                	jne    801404 <fd_alloc+0x36>
			*fd_store = fd;
  8013fb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801402:	eb 17                	jmp    80141b <fd_alloc+0x4d>
  801404:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801409:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80140e:	75 c9                	jne    8013d9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801410:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801416:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    

0080141d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801423:	83 f8 1f             	cmp    $0x1f,%eax
  801426:	77 36                	ja     80145e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801428:	c1 e0 0c             	shl    $0xc,%eax
  80142b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801430:	89 c2                	mov    %eax,%edx
  801432:	c1 ea 16             	shr    $0x16,%edx
  801435:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80143c:	f6 c2 01             	test   $0x1,%dl
  80143f:	74 24                	je     801465 <fd_lookup+0x48>
  801441:	89 c2                	mov    %eax,%edx
  801443:	c1 ea 0c             	shr    $0xc,%edx
  801446:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80144d:	f6 c2 01             	test   $0x1,%dl
  801450:	74 1a                	je     80146c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801452:	8b 55 0c             	mov    0xc(%ebp),%edx
  801455:	89 02                	mov    %eax,(%edx)
	return 0;
  801457:	b8 00 00 00 00       	mov    $0x0,%eax
  80145c:	eb 13                	jmp    801471 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80145e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801463:	eb 0c                	jmp    801471 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801465:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146a:	eb 05                	jmp    801471 <fd_lookup+0x54>
  80146c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    

00801473 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	83 ec 08             	sub    $0x8,%esp
  801479:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80147c:	ba 64 2f 80 00       	mov    $0x802f64,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801481:	eb 13                	jmp    801496 <dev_lookup+0x23>
  801483:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801486:	39 08                	cmp    %ecx,(%eax)
  801488:	75 0c                	jne    801496 <dev_lookup+0x23>
			*dev = devtab[i];
  80148a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80148d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80148f:	b8 00 00 00 00       	mov    $0x0,%eax
  801494:	eb 2e                	jmp    8014c4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801496:	8b 02                	mov    (%edx),%eax
  801498:	85 c0                	test   %eax,%eax
  80149a:	75 e7                	jne    801483 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80149c:	a1 90 77 80 00       	mov    0x807790,%eax
  8014a1:	8b 40 54             	mov    0x54(%eax),%eax
  8014a4:	83 ec 04             	sub    $0x4,%esp
  8014a7:	51                   	push   %ecx
  8014a8:	50                   	push   %eax
  8014a9:	68 e8 2e 80 00       	push   $0x802ee8
  8014ae:	e8 49 f0 ff ff       	call   8004fc <cprintf>
	*dev = 0;
  8014b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014c4:	c9                   	leave  
  8014c5:	c3                   	ret    

008014c6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	56                   	push   %esi
  8014ca:	53                   	push   %ebx
  8014cb:	83 ec 10             	sub    $0x10,%esp
  8014ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d7:	50                   	push   %eax
  8014d8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014de:	c1 e8 0c             	shr    $0xc,%eax
  8014e1:	50                   	push   %eax
  8014e2:	e8 36 ff ff ff       	call   80141d <fd_lookup>
  8014e7:	83 c4 08             	add    $0x8,%esp
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 05                	js     8014f3 <fd_close+0x2d>
	    || fd != fd2)
  8014ee:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014f1:	74 0c                	je     8014ff <fd_close+0x39>
		return (must_exist ? r : 0);
  8014f3:	84 db                	test   %bl,%bl
  8014f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fa:	0f 44 c2             	cmove  %edx,%eax
  8014fd:	eb 41                	jmp    801540 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014ff:	83 ec 08             	sub    $0x8,%esp
  801502:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801505:	50                   	push   %eax
  801506:	ff 36                	pushl  (%esi)
  801508:	e8 66 ff ff ff       	call   801473 <dev_lookup>
  80150d:	89 c3                	mov    %eax,%ebx
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	85 c0                	test   %eax,%eax
  801514:	78 1a                	js     801530 <fd_close+0x6a>
		if (dev->dev_close)
  801516:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801519:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80151c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801521:	85 c0                	test   %eax,%eax
  801523:	74 0b                	je     801530 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801525:	83 ec 0c             	sub    $0xc,%esp
  801528:	56                   	push   %esi
  801529:	ff d0                	call   *%eax
  80152b:	89 c3                	mov    %eax,%ebx
  80152d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801530:	83 ec 08             	sub    $0x8,%esp
  801533:	56                   	push   %esi
  801534:	6a 00                	push   $0x0
  801536:	e8 ce f9 ff ff       	call   800f09 <sys_page_unmap>
	return r;
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	89 d8                	mov    %ebx,%eax
}
  801540:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801543:	5b                   	pop    %ebx
  801544:	5e                   	pop    %esi
  801545:	5d                   	pop    %ebp
  801546:	c3                   	ret    

00801547 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80154d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801550:	50                   	push   %eax
  801551:	ff 75 08             	pushl  0x8(%ebp)
  801554:	e8 c4 fe ff ff       	call   80141d <fd_lookup>
  801559:	83 c4 08             	add    $0x8,%esp
  80155c:	85 c0                	test   %eax,%eax
  80155e:	78 10                	js     801570 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801560:	83 ec 08             	sub    $0x8,%esp
  801563:	6a 01                	push   $0x1
  801565:	ff 75 f4             	pushl  -0xc(%ebp)
  801568:	e8 59 ff ff ff       	call   8014c6 <fd_close>
  80156d:	83 c4 10             	add    $0x10,%esp
}
  801570:	c9                   	leave  
  801571:	c3                   	ret    

00801572 <close_all>:

void
close_all(void)
{
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	53                   	push   %ebx
  801576:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801579:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80157e:	83 ec 0c             	sub    $0xc,%esp
  801581:	53                   	push   %ebx
  801582:	e8 c0 ff ff ff       	call   801547 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801587:	83 c3 01             	add    $0x1,%ebx
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	83 fb 20             	cmp    $0x20,%ebx
  801590:	75 ec                	jne    80157e <close_all+0xc>
		close(i);
}
  801592:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801595:	c9                   	leave  
  801596:	c3                   	ret    

00801597 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	57                   	push   %edi
  80159b:	56                   	push   %esi
  80159c:	53                   	push   %ebx
  80159d:	83 ec 2c             	sub    $0x2c,%esp
  8015a0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015a6:	50                   	push   %eax
  8015a7:	ff 75 08             	pushl  0x8(%ebp)
  8015aa:	e8 6e fe ff ff       	call   80141d <fd_lookup>
  8015af:	83 c4 08             	add    $0x8,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	0f 88 c1 00 00 00    	js     80167b <dup+0xe4>
		return r;
	close(newfdnum);
  8015ba:	83 ec 0c             	sub    $0xc,%esp
  8015bd:	56                   	push   %esi
  8015be:	e8 84 ff ff ff       	call   801547 <close>

	newfd = INDEX2FD(newfdnum);
  8015c3:	89 f3                	mov    %esi,%ebx
  8015c5:	c1 e3 0c             	shl    $0xc,%ebx
  8015c8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015ce:	83 c4 04             	add    $0x4,%esp
  8015d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015d4:	e8 de fd ff ff       	call   8013b7 <fd2data>
  8015d9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015db:	89 1c 24             	mov    %ebx,(%esp)
  8015de:	e8 d4 fd ff ff       	call   8013b7 <fd2data>
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015e9:	89 f8                	mov    %edi,%eax
  8015eb:	c1 e8 16             	shr    $0x16,%eax
  8015ee:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015f5:	a8 01                	test   $0x1,%al
  8015f7:	74 37                	je     801630 <dup+0x99>
  8015f9:	89 f8                	mov    %edi,%eax
  8015fb:	c1 e8 0c             	shr    $0xc,%eax
  8015fe:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801605:	f6 c2 01             	test   $0x1,%dl
  801608:	74 26                	je     801630 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80160a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	25 07 0e 00 00       	and    $0xe07,%eax
  801619:	50                   	push   %eax
  80161a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80161d:	6a 00                	push   $0x0
  80161f:	57                   	push   %edi
  801620:	6a 00                	push   $0x0
  801622:	e8 a0 f8 ff ff       	call   800ec7 <sys_page_map>
  801627:	89 c7                	mov    %eax,%edi
  801629:	83 c4 20             	add    $0x20,%esp
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 2e                	js     80165e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801630:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801633:	89 d0                	mov    %edx,%eax
  801635:	c1 e8 0c             	shr    $0xc,%eax
  801638:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80163f:	83 ec 0c             	sub    $0xc,%esp
  801642:	25 07 0e 00 00       	and    $0xe07,%eax
  801647:	50                   	push   %eax
  801648:	53                   	push   %ebx
  801649:	6a 00                	push   $0x0
  80164b:	52                   	push   %edx
  80164c:	6a 00                	push   $0x0
  80164e:	e8 74 f8 ff ff       	call   800ec7 <sys_page_map>
  801653:	89 c7                	mov    %eax,%edi
  801655:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801658:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80165a:	85 ff                	test   %edi,%edi
  80165c:	79 1d                	jns    80167b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80165e:	83 ec 08             	sub    $0x8,%esp
  801661:	53                   	push   %ebx
  801662:	6a 00                	push   $0x0
  801664:	e8 a0 f8 ff ff       	call   800f09 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801669:	83 c4 08             	add    $0x8,%esp
  80166c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80166f:	6a 00                	push   $0x0
  801671:	e8 93 f8 ff ff       	call   800f09 <sys_page_unmap>
	return r;
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	89 f8                	mov    %edi,%eax
}
  80167b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167e:	5b                   	pop    %ebx
  80167f:	5e                   	pop    %esi
  801680:	5f                   	pop    %edi
  801681:	5d                   	pop    %ebp
  801682:	c3                   	ret    

00801683 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	83 ec 14             	sub    $0x14,%esp
  80168a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	53                   	push   %ebx
  801692:	e8 86 fd ff ff       	call   80141d <fd_lookup>
  801697:	83 c4 08             	add    $0x8,%esp
  80169a:	89 c2                	mov    %eax,%edx
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 6d                	js     80170d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a6:	50                   	push   %eax
  8016a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016aa:	ff 30                	pushl  (%eax)
  8016ac:	e8 c2 fd ff ff       	call   801473 <dev_lookup>
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 4c                	js     801704 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016bb:	8b 42 08             	mov    0x8(%edx),%eax
  8016be:	83 e0 03             	and    $0x3,%eax
  8016c1:	83 f8 01             	cmp    $0x1,%eax
  8016c4:	75 21                	jne    8016e7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c6:	a1 90 77 80 00       	mov    0x807790,%eax
  8016cb:	8b 40 54             	mov    0x54(%eax),%eax
  8016ce:	83 ec 04             	sub    $0x4,%esp
  8016d1:	53                   	push   %ebx
  8016d2:	50                   	push   %eax
  8016d3:	68 29 2f 80 00       	push   $0x802f29
  8016d8:	e8 1f ee ff ff       	call   8004fc <cprintf>
		return -E_INVAL;
  8016dd:	83 c4 10             	add    $0x10,%esp
  8016e0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e5:	eb 26                	jmp    80170d <read+0x8a>
	}
	if (!dev->dev_read)
  8016e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ea:	8b 40 08             	mov    0x8(%eax),%eax
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	74 17                	je     801708 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016f1:	83 ec 04             	sub    $0x4,%esp
  8016f4:	ff 75 10             	pushl  0x10(%ebp)
  8016f7:	ff 75 0c             	pushl  0xc(%ebp)
  8016fa:	52                   	push   %edx
  8016fb:	ff d0                	call   *%eax
  8016fd:	89 c2                	mov    %eax,%edx
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	eb 09                	jmp    80170d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801704:	89 c2                	mov    %eax,%edx
  801706:	eb 05                	jmp    80170d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801708:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80170d:	89 d0                	mov    %edx,%eax
  80170f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801712:	c9                   	leave  
  801713:	c3                   	ret    

00801714 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	57                   	push   %edi
  801718:	56                   	push   %esi
  801719:	53                   	push   %ebx
  80171a:	83 ec 0c             	sub    $0xc,%esp
  80171d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801720:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801723:	bb 00 00 00 00       	mov    $0x0,%ebx
  801728:	eb 21                	jmp    80174b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80172a:	83 ec 04             	sub    $0x4,%esp
  80172d:	89 f0                	mov    %esi,%eax
  80172f:	29 d8                	sub    %ebx,%eax
  801731:	50                   	push   %eax
  801732:	89 d8                	mov    %ebx,%eax
  801734:	03 45 0c             	add    0xc(%ebp),%eax
  801737:	50                   	push   %eax
  801738:	57                   	push   %edi
  801739:	e8 45 ff ff ff       	call   801683 <read>
		if (m < 0)
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	85 c0                	test   %eax,%eax
  801743:	78 10                	js     801755 <readn+0x41>
			return m;
		if (m == 0)
  801745:	85 c0                	test   %eax,%eax
  801747:	74 0a                	je     801753 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801749:	01 c3                	add    %eax,%ebx
  80174b:	39 f3                	cmp    %esi,%ebx
  80174d:	72 db                	jb     80172a <readn+0x16>
  80174f:	89 d8                	mov    %ebx,%eax
  801751:	eb 02                	jmp    801755 <readn+0x41>
  801753:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801755:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801758:	5b                   	pop    %ebx
  801759:	5e                   	pop    %esi
  80175a:	5f                   	pop    %edi
  80175b:	5d                   	pop    %ebp
  80175c:	c3                   	ret    

0080175d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	53                   	push   %ebx
  801761:	83 ec 14             	sub    $0x14,%esp
  801764:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801767:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176a:	50                   	push   %eax
  80176b:	53                   	push   %ebx
  80176c:	e8 ac fc ff ff       	call   80141d <fd_lookup>
  801771:	83 c4 08             	add    $0x8,%esp
  801774:	89 c2                	mov    %eax,%edx
  801776:	85 c0                	test   %eax,%eax
  801778:	78 68                	js     8017e2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177a:	83 ec 08             	sub    $0x8,%esp
  80177d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801780:	50                   	push   %eax
  801781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801784:	ff 30                	pushl  (%eax)
  801786:	e8 e8 fc ff ff       	call   801473 <dev_lookup>
  80178b:	83 c4 10             	add    $0x10,%esp
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 47                	js     8017d9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801792:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801795:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801799:	75 21                	jne    8017bc <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80179b:	a1 90 77 80 00       	mov    0x807790,%eax
  8017a0:	8b 40 54             	mov    0x54(%eax),%eax
  8017a3:	83 ec 04             	sub    $0x4,%esp
  8017a6:	53                   	push   %ebx
  8017a7:	50                   	push   %eax
  8017a8:	68 45 2f 80 00       	push   $0x802f45
  8017ad:	e8 4a ed ff ff       	call   8004fc <cprintf>
		return -E_INVAL;
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017ba:	eb 26                	jmp    8017e2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017bf:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c2:	85 d2                	test   %edx,%edx
  8017c4:	74 17                	je     8017dd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017c6:	83 ec 04             	sub    $0x4,%esp
  8017c9:	ff 75 10             	pushl  0x10(%ebp)
  8017cc:	ff 75 0c             	pushl  0xc(%ebp)
  8017cf:	50                   	push   %eax
  8017d0:	ff d2                	call   *%edx
  8017d2:	89 c2                	mov    %eax,%edx
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	eb 09                	jmp    8017e2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d9:	89 c2                	mov    %eax,%edx
  8017db:	eb 05                	jmp    8017e2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017e2:	89 d0                	mov    %edx,%eax
  8017e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    

008017e9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017ef:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017f2:	50                   	push   %eax
  8017f3:	ff 75 08             	pushl  0x8(%ebp)
  8017f6:	e8 22 fc ff ff       	call   80141d <fd_lookup>
  8017fb:	83 c4 08             	add    $0x8,%esp
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 0e                	js     801810 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801802:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801805:	8b 55 0c             	mov    0xc(%ebp),%edx
  801808:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80180b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801810:	c9                   	leave  
  801811:	c3                   	ret    

00801812 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	53                   	push   %ebx
  801816:	83 ec 14             	sub    $0x14,%esp
  801819:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181f:	50                   	push   %eax
  801820:	53                   	push   %ebx
  801821:	e8 f7 fb ff ff       	call   80141d <fd_lookup>
  801826:	83 c4 08             	add    $0x8,%esp
  801829:	89 c2                	mov    %eax,%edx
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 65                	js     801894 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182f:	83 ec 08             	sub    $0x8,%esp
  801832:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801835:	50                   	push   %eax
  801836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801839:	ff 30                	pushl  (%eax)
  80183b:	e8 33 fc ff ff       	call   801473 <dev_lookup>
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	85 c0                	test   %eax,%eax
  801845:	78 44                	js     80188b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80184e:	75 21                	jne    801871 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801850:	a1 90 77 80 00       	mov    0x807790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801855:	8b 40 54             	mov    0x54(%eax),%eax
  801858:	83 ec 04             	sub    $0x4,%esp
  80185b:	53                   	push   %ebx
  80185c:	50                   	push   %eax
  80185d:	68 08 2f 80 00       	push   $0x802f08
  801862:	e8 95 ec ff ff       	call   8004fc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80186f:	eb 23                	jmp    801894 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801871:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801874:	8b 52 18             	mov    0x18(%edx),%edx
  801877:	85 d2                	test   %edx,%edx
  801879:	74 14                	je     80188f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80187b:	83 ec 08             	sub    $0x8,%esp
  80187e:	ff 75 0c             	pushl  0xc(%ebp)
  801881:	50                   	push   %eax
  801882:	ff d2                	call   *%edx
  801884:	89 c2                	mov    %eax,%edx
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	eb 09                	jmp    801894 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80188b:	89 c2                	mov    %eax,%edx
  80188d:	eb 05                	jmp    801894 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80188f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801894:	89 d0                	mov    %edx,%eax
  801896:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801899:	c9                   	leave  
  80189a:	c3                   	ret    

0080189b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	53                   	push   %ebx
  80189f:	83 ec 14             	sub    $0x14,%esp
  8018a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a8:	50                   	push   %eax
  8018a9:	ff 75 08             	pushl  0x8(%ebp)
  8018ac:	e8 6c fb ff ff       	call   80141d <fd_lookup>
  8018b1:	83 c4 08             	add    $0x8,%esp
  8018b4:	89 c2                	mov    %eax,%edx
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	78 58                	js     801912 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ba:	83 ec 08             	sub    $0x8,%esp
  8018bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c0:	50                   	push   %eax
  8018c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c4:	ff 30                	pushl  (%eax)
  8018c6:	e8 a8 fb ff ff       	call   801473 <dev_lookup>
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 37                	js     801909 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018d9:	74 32                	je     80190d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018db:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018de:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018e5:	00 00 00 
	stat->st_isdir = 0;
  8018e8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018ef:	00 00 00 
	stat->st_dev = dev;
  8018f2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018f8:	83 ec 08             	sub    $0x8,%esp
  8018fb:	53                   	push   %ebx
  8018fc:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ff:	ff 50 14             	call   *0x14(%eax)
  801902:	89 c2                	mov    %eax,%edx
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	eb 09                	jmp    801912 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801909:	89 c2                	mov    %eax,%edx
  80190b:	eb 05                	jmp    801912 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80190d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801912:	89 d0                	mov    %edx,%eax
  801914:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	56                   	push   %esi
  80191d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80191e:	83 ec 08             	sub    $0x8,%esp
  801921:	6a 00                	push   $0x0
  801923:	ff 75 08             	pushl  0x8(%ebp)
  801926:	e8 e3 01 00 00       	call   801b0e <open>
  80192b:	89 c3                	mov    %eax,%ebx
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	85 c0                	test   %eax,%eax
  801932:	78 1b                	js     80194f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	ff 75 0c             	pushl  0xc(%ebp)
  80193a:	50                   	push   %eax
  80193b:	e8 5b ff ff ff       	call   80189b <fstat>
  801940:	89 c6                	mov    %eax,%esi
	close(fd);
  801942:	89 1c 24             	mov    %ebx,(%esp)
  801945:	e8 fd fb ff ff       	call   801547 <close>
	return r;
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	89 f0                	mov    %esi,%eax
}
  80194f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801952:	5b                   	pop    %ebx
  801953:	5e                   	pop    %esi
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	56                   	push   %esi
  80195a:	53                   	push   %ebx
  80195b:	89 c6                	mov    %eax,%esi
  80195d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80195f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801966:	75 12                	jne    80197a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801968:	83 ec 0c             	sub    $0xc,%esp
  80196b:	6a 01                	push   $0x1
  80196d:	e8 38 0d 00 00       	call   8026aa <ipc_find_env>
  801972:	a3 00 60 80 00       	mov    %eax,0x806000
  801977:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80197a:	6a 07                	push   $0x7
  80197c:	68 00 80 80 00       	push   $0x808000
  801981:	56                   	push   %esi
  801982:	ff 35 00 60 80 00    	pushl  0x806000
  801988:	e8 bb 0c 00 00       	call   802648 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80198d:	83 c4 0c             	add    $0xc,%esp
  801990:	6a 00                	push   $0x0
  801992:	53                   	push   %ebx
  801993:	6a 00                	push   $0x0
  801995:	e8 36 0c 00 00       	call   8025d0 <ipc_recv>
}
  80199a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199d:	5b                   	pop    %ebx
  80199e:	5e                   	pop    %esi
  80199f:	5d                   	pop    %ebp
  8019a0:	c3                   	ret    

008019a1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
  8019a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ad:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  8019b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b5:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bf:	b8 02 00 00 00       	mov    $0x2,%eax
  8019c4:	e8 8d ff ff ff       	call   801956 <fsipc>
}
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d7:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  8019dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e1:	b8 06 00 00 00       	mov    $0x6,%eax
  8019e6:	e8 6b ff ff ff       	call   801956 <fsipc>
}
  8019eb:	c9                   	leave  
  8019ec:	c3                   	ret    

008019ed <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	53                   	push   %ebx
  8019f1:	83 ec 04             	sub    $0x4,%esp
  8019f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fd:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a02:	ba 00 00 00 00       	mov    $0x0,%edx
  801a07:	b8 05 00 00 00       	mov    $0x5,%eax
  801a0c:	e8 45 ff ff ff       	call   801956 <fsipc>
  801a11:	85 c0                	test   %eax,%eax
  801a13:	78 2c                	js     801a41 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a15:	83 ec 08             	sub    $0x8,%esp
  801a18:	68 00 80 80 00       	push   $0x808000
  801a1d:	53                   	push   %ebx
  801a1e:	e8 5e f0 ff ff       	call   800a81 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a23:	a1 80 80 80 00       	mov    0x808080,%eax
  801a28:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a2e:	a1 84 80 80 00       	mov    0x808084,%eax
  801a33:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a39:	83 c4 10             	add    $0x10,%esp
  801a3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    

00801a46 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 0c             	sub    $0xc,%esp
  801a4c:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a4f:	8b 55 08             	mov    0x8(%ebp),%edx
  801a52:	8b 52 0c             	mov    0xc(%edx),%edx
  801a55:	89 15 00 80 80 00    	mov    %edx,0x808000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a5b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a60:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a65:	0f 47 c2             	cmova  %edx,%eax
  801a68:	a3 04 80 80 00       	mov    %eax,0x808004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a6d:	50                   	push   %eax
  801a6e:	ff 75 0c             	pushl  0xc(%ebp)
  801a71:	68 08 80 80 00       	push   $0x808008
  801a76:	e8 98 f1 ff ff       	call   800c13 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a80:	b8 04 00 00 00       	mov    $0x4,%eax
  801a85:	e8 cc fe ff ff       	call   801956 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	56                   	push   %esi
  801a90:	53                   	push   %ebx
  801a91:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a94:	8b 45 08             	mov    0x8(%ebp),%eax
  801a97:	8b 40 0c             	mov    0xc(%eax),%eax
  801a9a:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  801a9f:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aa5:	ba 00 00 00 00       	mov    $0x0,%edx
  801aaa:	b8 03 00 00 00       	mov    $0x3,%eax
  801aaf:	e8 a2 fe ff ff       	call   801956 <fsipc>
  801ab4:	89 c3                	mov    %eax,%ebx
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	78 4b                	js     801b05 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801aba:	39 c6                	cmp    %eax,%esi
  801abc:	73 16                	jae    801ad4 <devfile_read+0x48>
  801abe:	68 74 2f 80 00       	push   $0x802f74
  801ac3:	68 7b 2f 80 00       	push   $0x802f7b
  801ac8:	6a 7c                	push   $0x7c
  801aca:	68 90 2f 80 00       	push   $0x802f90
  801acf:	e8 4f e9 ff ff       	call   800423 <_panic>
	assert(r <= PGSIZE);
  801ad4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ad9:	7e 16                	jle    801af1 <devfile_read+0x65>
  801adb:	68 9b 2f 80 00       	push   $0x802f9b
  801ae0:	68 7b 2f 80 00       	push   $0x802f7b
  801ae5:	6a 7d                	push   $0x7d
  801ae7:	68 90 2f 80 00       	push   $0x802f90
  801aec:	e8 32 e9 ff ff       	call   800423 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801af1:	83 ec 04             	sub    $0x4,%esp
  801af4:	50                   	push   %eax
  801af5:	68 00 80 80 00       	push   $0x808000
  801afa:	ff 75 0c             	pushl  0xc(%ebp)
  801afd:	e8 11 f1 ff ff       	call   800c13 <memmove>
	return r;
  801b02:	83 c4 10             	add    $0x10,%esp
}
  801b05:	89 d8                	mov    %ebx,%eax
  801b07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b0a:	5b                   	pop    %ebx
  801b0b:	5e                   	pop    %esi
  801b0c:	5d                   	pop    %ebp
  801b0d:	c3                   	ret    

00801b0e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	53                   	push   %ebx
  801b12:	83 ec 20             	sub    $0x20,%esp
  801b15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b18:	53                   	push   %ebx
  801b19:	e8 2a ef ff ff       	call   800a48 <strlen>
  801b1e:	83 c4 10             	add    $0x10,%esp
  801b21:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b26:	7f 67                	jg     801b8f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b28:	83 ec 0c             	sub    $0xc,%esp
  801b2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2e:	50                   	push   %eax
  801b2f:	e8 9a f8 ff ff       	call   8013ce <fd_alloc>
  801b34:	83 c4 10             	add    $0x10,%esp
		return r;
  801b37:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	78 57                	js     801b94 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b3d:	83 ec 08             	sub    $0x8,%esp
  801b40:	53                   	push   %ebx
  801b41:	68 00 80 80 00       	push   $0x808000
  801b46:	e8 36 ef ff ff       	call   800a81 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4e:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b53:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b56:	b8 01 00 00 00       	mov    $0x1,%eax
  801b5b:	e8 f6 fd ff ff       	call   801956 <fsipc>
  801b60:	89 c3                	mov    %eax,%ebx
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	85 c0                	test   %eax,%eax
  801b67:	79 14                	jns    801b7d <open+0x6f>
		fd_close(fd, 0);
  801b69:	83 ec 08             	sub    $0x8,%esp
  801b6c:	6a 00                	push   $0x0
  801b6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b71:	e8 50 f9 ff ff       	call   8014c6 <fd_close>
		return r;
  801b76:	83 c4 10             	add    $0x10,%esp
  801b79:	89 da                	mov    %ebx,%edx
  801b7b:	eb 17                	jmp    801b94 <open+0x86>
	}

	return fd2num(fd);
  801b7d:	83 ec 0c             	sub    $0xc,%esp
  801b80:	ff 75 f4             	pushl  -0xc(%ebp)
  801b83:	e8 1f f8 ff ff       	call   8013a7 <fd2num>
  801b88:	89 c2                	mov    %eax,%edx
  801b8a:	83 c4 10             	add    $0x10,%esp
  801b8d:	eb 05                	jmp    801b94 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b8f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b94:	89 d0                	mov    %edx,%eax
  801b96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    

00801b9b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba6:	b8 08 00 00 00       	mov    $0x8,%eax
  801bab:	e8 a6 fd ff ff       	call   801956 <fsipc>
}
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	57                   	push   %edi
  801bb6:	56                   	push   %esi
  801bb7:	53                   	push   %ebx
  801bb8:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801bbe:	6a 00                	push   $0x0
  801bc0:	ff 75 08             	pushl  0x8(%ebp)
  801bc3:	e8 46 ff ff ff       	call   801b0e <open>
  801bc8:	89 c7                	mov    %eax,%edi
  801bca:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801bd0:	83 c4 10             	add    $0x10,%esp
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	0f 88 89 04 00 00    	js     802064 <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801bdb:	83 ec 04             	sub    $0x4,%esp
  801bde:	68 00 02 00 00       	push   $0x200
  801be3:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801be9:	50                   	push   %eax
  801bea:	57                   	push   %edi
  801beb:	e8 24 fb ff ff       	call   801714 <readn>
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	3d 00 02 00 00       	cmp    $0x200,%eax
  801bf8:	75 0c                	jne    801c06 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801bfa:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c01:	45 4c 46 
  801c04:	74 33                	je     801c39 <spawn+0x87>
		close(fd);
  801c06:	83 ec 0c             	sub    $0xc,%esp
  801c09:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c0f:	e8 33 f9 ff ff       	call   801547 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c14:	83 c4 0c             	add    $0xc,%esp
  801c17:	68 7f 45 4c 46       	push   $0x464c457f
  801c1c:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801c22:	68 a7 2f 80 00       	push   $0x802fa7
  801c27:	e8 d0 e8 ff ff       	call   8004fc <cprintf>
		return -E_NOT_EXEC;
  801c2c:	83 c4 10             	add    $0x10,%esp
  801c2f:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801c34:	e9 de 04 00 00       	jmp    802117 <spawn+0x565>
  801c39:	b8 07 00 00 00       	mov    $0x7,%eax
  801c3e:	cd 30                	int    $0x30
  801c40:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801c46:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	0f 88 1b 04 00 00    	js     80206f <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801c54:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c59:	89 c2                	mov    %eax,%edx
  801c5b:	c1 e2 07             	shl    $0x7,%edx
  801c5e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801c64:	8d b4 c2 0c 00 c0 ee 	lea    -0x113ffff4(%edx,%eax,8),%esi
  801c6b:	b9 11 00 00 00       	mov    $0x11,%ecx
  801c70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801c72:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801c78:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801c83:	be 00 00 00 00       	mov    $0x0,%esi
  801c88:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c8b:	eb 13                	jmp    801ca0 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801c8d:	83 ec 0c             	sub    $0xc,%esp
  801c90:	50                   	push   %eax
  801c91:	e8 b2 ed ff ff       	call   800a48 <strlen>
  801c96:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c9a:	83 c3 01             	add    $0x1,%ebx
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801ca7:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801caa:	85 c0                	test   %eax,%eax
  801cac:	75 df                	jne    801c8d <spawn+0xdb>
  801cae:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801cb4:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801cba:	bf 00 10 40 00       	mov    $0x401000,%edi
  801cbf:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801cc1:	89 fa                	mov    %edi,%edx
  801cc3:	83 e2 fc             	and    $0xfffffffc,%edx
  801cc6:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801ccd:	29 c2                	sub    %eax,%edx
  801ccf:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801cd5:	8d 42 f8             	lea    -0x8(%edx),%eax
  801cd8:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801cdd:	0f 86 a2 03 00 00    	jbe    802085 <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ce3:	83 ec 04             	sub    $0x4,%esp
  801ce6:	6a 07                	push   $0x7
  801ce8:	68 00 00 40 00       	push   $0x400000
  801ced:	6a 00                	push   $0x0
  801cef:	e8 90 f1 ff ff       	call   800e84 <sys_page_alloc>
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	0f 88 90 03 00 00    	js     80208f <spawn+0x4dd>
  801cff:	be 00 00 00 00       	mov    $0x0,%esi
  801d04:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d0d:	eb 30                	jmp    801d3f <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801d0f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801d15:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801d1b:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801d1e:	83 ec 08             	sub    $0x8,%esp
  801d21:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d24:	57                   	push   %edi
  801d25:	e8 57 ed ff ff       	call   800a81 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801d2a:	83 c4 04             	add    $0x4,%esp
  801d2d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d30:	e8 13 ed ff ff       	call   800a48 <strlen>
  801d35:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d39:	83 c6 01             	add    $0x1,%esi
  801d3c:	83 c4 10             	add    $0x10,%esp
  801d3f:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801d45:	7f c8                	jg     801d0f <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801d47:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d4d:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801d53:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801d5a:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801d60:	74 19                	je     801d7b <spawn+0x1c9>
  801d62:	68 34 30 80 00       	push   $0x803034
  801d67:	68 7b 2f 80 00       	push   $0x802f7b
  801d6c:	68 f2 00 00 00       	push   $0xf2
  801d71:	68 c1 2f 80 00       	push   $0x802fc1
  801d76:	e8 a8 e6 ff ff       	call   800423 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801d7b:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801d81:	89 f8                	mov    %edi,%eax
  801d83:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801d88:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801d8b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d91:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801d94:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801d9a:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801da0:	83 ec 0c             	sub    $0xc,%esp
  801da3:	6a 07                	push   $0x7
  801da5:	68 00 d0 bf ee       	push   $0xeebfd000
  801daa:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801db0:	68 00 00 40 00       	push   $0x400000
  801db5:	6a 00                	push   $0x0
  801db7:	e8 0b f1 ff ff       	call   800ec7 <sys_page_map>
  801dbc:	89 c3                	mov    %eax,%ebx
  801dbe:	83 c4 20             	add    $0x20,%esp
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	0f 88 3c 03 00 00    	js     802105 <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801dc9:	83 ec 08             	sub    $0x8,%esp
  801dcc:	68 00 00 40 00       	push   $0x400000
  801dd1:	6a 00                	push   $0x0
  801dd3:	e8 31 f1 ff ff       	call   800f09 <sys_page_unmap>
  801dd8:	89 c3                	mov    %eax,%ebx
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	0f 88 20 03 00 00    	js     802105 <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801de5:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801deb:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801df2:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801df8:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801dff:	00 00 00 
  801e02:	e9 88 01 00 00       	jmp    801f8f <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801e07:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801e0d:	83 38 01             	cmpl   $0x1,(%eax)
  801e10:	0f 85 6b 01 00 00    	jne    801f81 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e16:	89 c2                	mov    %eax,%edx
  801e18:	8b 40 18             	mov    0x18(%eax),%eax
  801e1b:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e21:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801e24:	83 f8 01             	cmp    $0x1,%eax
  801e27:	19 c0                	sbb    %eax,%eax
  801e29:	83 e0 fe             	and    $0xfffffffe,%eax
  801e2c:	83 c0 07             	add    $0x7,%eax
  801e2f:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e35:	89 d0                	mov    %edx,%eax
  801e37:	8b 7a 04             	mov    0x4(%edx),%edi
  801e3a:	89 f9                	mov    %edi,%ecx
  801e3c:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801e42:	8b 7a 10             	mov    0x10(%edx),%edi
  801e45:	8b 52 14             	mov    0x14(%edx),%edx
  801e48:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801e4e:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801e51:	89 f0                	mov    %esi,%eax
  801e53:	25 ff 0f 00 00       	and    $0xfff,%eax
  801e58:	74 14                	je     801e6e <spawn+0x2bc>
		va -= i;
  801e5a:	29 c6                	sub    %eax,%esi
		memsz += i;
  801e5c:	01 c2                	add    %eax,%edx
  801e5e:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801e64:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801e66:	29 c1                	sub    %eax,%ecx
  801e68:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e73:	e9 f7 00 00 00       	jmp    801f6f <spawn+0x3bd>
		if (i >= filesz) {
  801e78:	39 fb                	cmp    %edi,%ebx
  801e7a:	72 27                	jb     801ea3 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801e7c:	83 ec 04             	sub    $0x4,%esp
  801e7f:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801e85:	56                   	push   %esi
  801e86:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801e8c:	e8 f3 ef ff ff       	call   800e84 <sys_page_alloc>
  801e91:	83 c4 10             	add    $0x10,%esp
  801e94:	85 c0                	test   %eax,%eax
  801e96:	0f 89 c7 00 00 00    	jns    801f63 <spawn+0x3b1>
  801e9c:	89 c3                	mov    %eax,%ebx
  801e9e:	e9 fd 01 00 00       	jmp    8020a0 <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ea3:	83 ec 04             	sub    $0x4,%esp
  801ea6:	6a 07                	push   $0x7
  801ea8:	68 00 00 40 00       	push   $0x400000
  801ead:	6a 00                	push   $0x0
  801eaf:	e8 d0 ef ff ff       	call   800e84 <sys_page_alloc>
  801eb4:	83 c4 10             	add    $0x10,%esp
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	0f 88 d7 01 00 00    	js     802096 <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ebf:	83 ec 08             	sub    $0x8,%esp
  801ec2:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ec8:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801ece:	50                   	push   %eax
  801ecf:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ed5:	e8 0f f9 ff ff       	call   8017e9 <seek>
  801eda:	83 c4 10             	add    $0x10,%esp
  801edd:	85 c0                	test   %eax,%eax
  801edf:	0f 88 b5 01 00 00    	js     80209a <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ee5:	83 ec 04             	sub    $0x4,%esp
  801ee8:	89 f8                	mov    %edi,%eax
  801eea:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801ef0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ef5:	ba 00 10 00 00       	mov    $0x1000,%edx
  801efa:	0f 47 c2             	cmova  %edx,%eax
  801efd:	50                   	push   %eax
  801efe:	68 00 00 40 00       	push   $0x400000
  801f03:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f09:	e8 06 f8 ff ff       	call   801714 <readn>
  801f0e:	83 c4 10             	add    $0x10,%esp
  801f11:	85 c0                	test   %eax,%eax
  801f13:	0f 88 85 01 00 00    	js     80209e <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f19:	83 ec 0c             	sub    $0xc,%esp
  801f1c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f22:	56                   	push   %esi
  801f23:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f29:	68 00 00 40 00       	push   $0x400000
  801f2e:	6a 00                	push   $0x0
  801f30:	e8 92 ef ff ff       	call   800ec7 <sys_page_map>
  801f35:	83 c4 20             	add    $0x20,%esp
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	79 15                	jns    801f51 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801f3c:	50                   	push   %eax
  801f3d:	68 cd 2f 80 00       	push   $0x802fcd
  801f42:	68 25 01 00 00       	push   $0x125
  801f47:	68 c1 2f 80 00       	push   $0x802fc1
  801f4c:	e8 d2 e4 ff ff       	call   800423 <_panic>
			sys_page_unmap(0, UTEMP);
  801f51:	83 ec 08             	sub    $0x8,%esp
  801f54:	68 00 00 40 00       	push   $0x400000
  801f59:	6a 00                	push   $0x0
  801f5b:	e8 a9 ef ff ff       	call   800f09 <sys_page_unmap>
  801f60:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f63:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801f69:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801f6f:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801f75:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801f7b:	0f 82 f7 fe ff ff    	jb     801e78 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f81:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801f88:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801f8f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801f96:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801f9c:	0f 8c 65 fe ff ff    	jl     801e07 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801fa2:	83 ec 0c             	sub    $0xc,%esp
  801fa5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fab:	e8 97 f5 ff ff       	call   801547 <close>
  801fb0:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801fb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fb8:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801fbe:	89 d8                	mov    %ebx,%eax
  801fc0:	c1 e8 16             	shr    $0x16,%eax
  801fc3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fca:	a8 01                	test   $0x1,%al
  801fcc:	74 42                	je     802010 <spawn+0x45e>
  801fce:	89 d8                	mov    %ebx,%eax
  801fd0:	c1 e8 0c             	shr    $0xc,%eax
  801fd3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801fda:	f6 c2 01             	test   $0x1,%dl
  801fdd:	74 31                	je     802010 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801fdf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801fe6:	f6 c6 04             	test   $0x4,%dh
  801fe9:	74 25                	je     802010 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801feb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ff2:	83 ec 0c             	sub    $0xc,%esp
  801ff5:	25 07 0e 00 00       	and    $0xe07,%eax
  801ffa:	50                   	push   %eax
  801ffb:	53                   	push   %ebx
  801ffc:	56                   	push   %esi
  801ffd:	53                   	push   %ebx
  801ffe:	6a 00                	push   $0x0
  802000:	e8 c2 ee ff ff       	call   800ec7 <sys_page_map>
			if (r < 0) {
  802005:	83 c4 20             	add    $0x20,%esp
  802008:	85 c0                	test   %eax,%eax
  80200a:	0f 88 b1 00 00 00    	js     8020c1 <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802010:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802016:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80201c:	75 a0                	jne    801fbe <spawn+0x40c>
  80201e:	e9 b3 00 00 00       	jmp    8020d6 <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802023:	50                   	push   %eax
  802024:	68 ea 2f 80 00       	push   $0x802fea
  802029:	68 86 00 00 00       	push   $0x86
  80202e:	68 c1 2f 80 00       	push   $0x802fc1
  802033:	e8 eb e3 ff ff       	call   800423 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802038:	83 ec 08             	sub    $0x8,%esp
  80203b:	6a 02                	push   $0x2
  80203d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802043:	e8 03 ef ff ff       	call   800f4b <sys_env_set_status>
  802048:	83 c4 10             	add    $0x10,%esp
  80204b:	85 c0                	test   %eax,%eax
  80204d:	79 2b                	jns    80207a <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  80204f:	50                   	push   %eax
  802050:	68 04 30 80 00       	push   $0x803004
  802055:	68 89 00 00 00       	push   $0x89
  80205a:	68 c1 2f 80 00       	push   $0x802fc1
  80205f:	e8 bf e3 ff ff       	call   800423 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802064:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  80206a:	e9 a8 00 00 00       	jmp    802117 <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  80206f:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802075:	e9 9d 00 00 00       	jmp    802117 <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80207a:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802080:	e9 92 00 00 00       	jmp    802117 <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802085:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  80208a:	e9 88 00 00 00       	jmp    802117 <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  80208f:	89 c3                	mov    %eax,%ebx
  802091:	e9 81 00 00 00       	jmp    802117 <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802096:	89 c3                	mov    %eax,%ebx
  802098:	eb 06                	jmp    8020a0 <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80209a:	89 c3                	mov    %eax,%ebx
  80209c:	eb 02                	jmp    8020a0 <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80209e:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8020a0:	83 ec 0c             	sub    $0xc,%esp
  8020a3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020a9:	e8 57 ed ff ff       	call   800e05 <sys_env_destroy>
	close(fd);
  8020ae:	83 c4 04             	add    $0x4,%esp
  8020b1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8020b7:	e8 8b f4 ff ff       	call   801547 <close>
	return r;
  8020bc:	83 c4 10             	add    $0x10,%esp
  8020bf:	eb 56                	jmp    802117 <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  8020c1:	50                   	push   %eax
  8020c2:	68 1b 30 80 00       	push   $0x80301b
  8020c7:	68 82 00 00 00       	push   $0x82
  8020cc:	68 c1 2f 80 00       	push   $0x802fc1
  8020d1:	e8 4d e3 ff ff       	call   800423 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8020d6:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8020dd:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8020e0:	83 ec 08             	sub    $0x8,%esp
  8020e3:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8020e9:	50                   	push   %eax
  8020ea:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020f0:	e8 98 ee ff ff       	call   800f8d <sys_env_set_trapframe>
  8020f5:	83 c4 10             	add    $0x10,%esp
  8020f8:	85 c0                	test   %eax,%eax
  8020fa:	0f 89 38 ff ff ff    	jns    802038 <spawn+0x486>
  802100:	e9 1e ff ff ff       	jmp    802023 <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802105:	83 ec 08             	sub    $0x8,%esp
  802108:	68 00 00 40 00       	push   $0x400000
  80210d:	6a 00                	push   $0x0
  80210f:	e8 f5 ed ff ff       	call   800f09 <sys_page_unmap>
  802114:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802117:	89 d8                	mov    %ebx,%eax
  802119:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80211c:	5b                   	pop    %ebx
  80211d:	5e                   	pop    %esi
  80211e:	5f                   	pop    %edi
  80211f:	5d                   	pop    %ebp
  802120:	c3                   	ret    

00802121 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802121:	55                   	push   %ebp
  802122:	89 e5                	mov    %esp,%ebp
  802124:	56                   	push   %esi
  802125:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802126:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802129:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80212e:	eb 03                	jmp    802133 <spawnl+0x12>
		argc++;
  802130:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802133:	83 c2 04             	add    $0x4,%edx
  802136:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  80213a:	75 f4                	jne    802130 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80213c:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802143:	83 e2 f0             	and    $0xfffffff0,%edx
  802146:	29 d4                	sub    %edx,%esp
  802148:	8d 54 24 03          	lea    0x3(%esp),%edx
  80214c:	c1 ea 02             	shr    $0x2,%edx
  80214f:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802156:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802158:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80215b:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802162:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802169:	00 
  80216a:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80216c:	b8 00 00 00 00       	mov    $0x0,%eax
  802171:	eb 0a                	jmp    80217d <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802173:	83 c0 01             	add    $0x1,%eax
  802176:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  80217a:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80217d:	39 d0                	cmp    %edx,%eax
  80217f:	75 f2                	jne    802173 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802181:	83 ec 08             	sub    $0x8,%esp
  802184:	56                   	push   %esi
  802185:	ff 75 08             	pushl  0x8(%ebp)
  802188:	e8 25 fa ff ff       	call   801bb2 <spawn>
}
  80218d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802190:	5b                   	pop    %ebx
  802191:	5e                   	pop    %esi
  802192:	5d                   	pop    %ebp
  802193:	c3                   	ret    

00802194 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802194:	55                   	push   %ebp
  802195:	89 e5                	mov    %esp,%ebp
  802197:	56                   	push   %esi
  802198:	53                   	push   %ebx
  802199:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80219c:	83 ec 0c             	sub    $0xc,%esp
  80219f:	ff 75 08             	pushl  0x8(%ebp)
  8021a2:	e8 10 f2 ff ff       	call   8013b7 <fd2data>
  8021a7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8021a9:	83 c4 08             	add    $0x8,%esp
  8021ac:	68 5c 30 80 00       	push   $0x80305c
  8021b1:	53                   	push   %ebx
  8021b2:	e8 ca e8 ff ff       	call   800a81 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021b7:	8b 46 04             	mov    0x4(%esi),%eax
  8021ba:	2b 06                	sub    (%esi),%eax
  8021bc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8021c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021c9:	00 00 00 
	stat->st_dev = &devpipe;
  8021cc:	c7 83 88 00 00 00 ac 	movl   $0x8057ac,0x88(%ebx)
  8021d3:	57 80 00 
	return 0;
}
  8021d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8021db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021de:	5b                   	pop    %ebx
  8021df:	5e                   	pop    %esi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    

008021e2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
  8021e5:	53                   	push   %ebx
  8021e6:	83 ec 0c             	sub    $0xc,%esp
  8021e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021ec:	53                   	push   %ebx
  8021ed:	6a 00                	push   $0x0
  8021ef:	e8 15 ed ff ff       	call   800f09 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021f4:	89 1c 24             	mov    %ebx,(%esp)
  8021f7:	e8 bb f1 ff ff       	call   8013b7 <fd2data>
  8021fc:	83 c4 08             	add    $0x8,%esp
  8021ff:	50                   	push   %eax
  802200:	6a 00                	push   $0x0
  802202:	e8 02 ed ff ff       	call   800f09 <sys_page_unmap>
}
  802207:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80220a:	c9                   	leave  
  80220b:	c3                   	ret    

0080220c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80220c:	55                   	push   %ebp
  80220d:	89 e5                	mov    %esp,%ebp
  80220f:	57                   	push   %edi
  802210:	56                   	push   %esi
  802211:	53                   	push   %ebx
  802212:	83 ec 1c             	sub    $0x1c,%esp
  802215:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802218:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80221a:	a1 90 77 80 00       	mov    0x807790,%eax
  80221f:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802222:	83 ec 0c             	sub    $0xc,%esp
  802225:	ff 75 e0             	pushl  -0x20(%ebp)
  802228:	e8 bd 04 00 00       	call   8026ea <pageref>
  80222d:	89 c3                	mov    %eax,%ebx
  80222f:	89 3c 24             	mov    %edi,(%esp)
  802232:	e8 b3 04 00 00       	call   8026ea <pageref>
  802237:	83 c4 10             	add    $0x10,%esp
  80223a:	39 c3                	cmp    %eax,%ebx
  80223c:	0f 94 c1             	sete   %cl
  80223f:	0f b6 c9             	movzbl %cl,%ecx
  802242:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802245:	8b 15 90 77 80 00    	mov    0x807790,%edx
  80224b:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  80224e:	39 ce                	cmp    %ecx,%esi
  802250:	74 1b                	je     80226d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802252:	39 c3                	cmp    %eax,%ebx
  802254:	75 c4                	jne    80221a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802256:	8b 42 64             	mov    0x64(%edx),%eax
  802259:	ff 75 e4             	pushl  -0x1c(%ebp)
  80225c:	50                   	push   %eax
  80225d:	56                   	push   %esi
  80225e:	68 63 30 80 00       	push   $0x803063
  802263:	e8 94 e2 ff ff       	call   8004fc <cprintf>
  802268:	83 c4 10             	add    $0x10,%esp
  80226b:	eb ad                	jmp    80221a <_pipeisclosed+0xe>
	}
}
  80226d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802270:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802273:	5b                   	pop    %ebx
  802274:	5e                   	pop    %esi
  802275:	5f                   	pop    %edi
  802276:	5d                   	pop    %ebp
  802277:	c3                   	ret    

00802278 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802278:	55                   	push   %ebp
  802279:	89 e5                	mov    %esp,%ebp
  80227b:	57                   	push   %edi
  80227c:	56                   	push   %esi
  80227d:	53                   	push   %ebx
  80227e:	83 ec 28             	sub    $0x28,%esp
  802281:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802284:	56                   	push   %esi
  802285:	e8 2d f1 ff ff       	call   8013b7 <fd2data>
  80228a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80228c:	83 c4 10             	add    $0x10,%esp
  80228f:	bf 00 00 00 00       	mov    $0x0,%edi
  802294:	eb 4b                	jmp    8022e1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802296:	89 da                	mov    %ebx,%edx
  802298:	89 f0                	mov    %esi,%eax
  80229a:	e8 6d ff ff ff       	call   80220c <_pipeisclosed>
  80229f:	85 c0                	test   %eax,%eax
  8022a1:	75 48                	jne    8022eb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022a3:	e8 bd eb ff ff       	call   800e65 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8022ab:	8b 0b                	mov    (%ebx),%ecx
  8022ad:	8d 51 20             	lea    0x20(%ecx),%edx
  8022b0:	39 d0                	cmp    %edx,%eax
  8022b2:	73 e2                	jae    802296 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022b7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8022bb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8022be:	89 c2                	mov    %eax,%edx
  8022c0:	c1 fa 1f             	sar    $0x1f,%edx
  8022c3:	89 d1                	mov    %edx,%ecx
  8022c5:	c1 e9 1b             	shr    $0x1b,%ecx
  8022c8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8022cb:	83 e2 1f             	and    $0x1f,%edx
  8022ce:	29 ca                	sub    %ecx,%edx
  8022d0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8022d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8022d8:	83 c0 01             	add    $0x1,%eax
  8022db:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022de:	83 c7 01             	add    $0x1,%edi
  8022e1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022e4:	75 c2                	jne    8022a8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8022e9:	eb 05                	jmp    8022f0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022eb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022f3:	5b                   	pop    %ebx
  8022f4:	5e                   	pop    %esi
  8022f5:	5f                   	pop    %edi
  8022f6:	5d                   	pop    %ebp
  8022f7:	c3                   	ret    

008022f8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022f8:	55                   	push   %ebp
  8022f9:	89 e5                	mov    %esp,%ebp
  8022fb:	57                   	push   %edi
  8022fc:	56                   	push   %esi
  8022fd:	53                   	push   %ebx
  8022fe:	83 ec 18             	sub    $0x18,%esp
  802301:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802304:	57                   	push   %edi
  802305:	e8 ad f0 ff ff       	call   8013b7 <fd2data>
  80230a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80230c:	83 c4 10             	add    $0x10,%esp
  80230f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802314:	eb 3d                	jmp    802353 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802316:	85 db                	test   %ebx,%ebx
  802318:	74 04                	je     80231e <devpipe_read+0x26>
				return i;
  80231a:	89 d8                	mov    %ebx,%eax
  80231c:	eb 44                	jmp    802362 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80231e:	89 f2                	mov    %esi,%edx
  802320:	89 f8                	mov    %edi,%eax
  802322:	e8 e5 fe ff ff       	call   80220c <_pipeisclosed>
  802327:	85 c0                	test   %eax,%eax
  802329:	75 32                	jne    80235d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80232b:	e8 35 eb ff ff       	call   800e65 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802330:	8b 06                	mov    (%esi),%eax
  802332:	3b 46 04             	cmp    0x4(%esi),%eax
  802335:	74 df                	je     802316 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802337:	99                   	cltd   
  802338:	c1 ea 1b             	shr    $0x1b,%edx
  80233b:	01 d0                	add    %edx,%eax
  80233d:	83 e0 1f             	and    $0x1f,%eax
  802340:	29 d0                	sub    %edx,%eax
  802342:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802347:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80234a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80234d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802350:	83 c3 01             	add    $0x1,%ebx
  802353:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802356:	75 d8                	jne    802330 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802358:	8b 45 10             	mov    0x10(%ebp),%eax
  80235b:	eb 05                	jmp    802362 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80235d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802362:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802365:	5b                   	pop    %ebx
  802366:	5e                   	pop    %esi
  802367:	5f                   	pop    %edi
  802368:	5d                   	pop    %ebp
  802369:	c3                   	ret    

0080236a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80236a:	55                   	push   %ebp
  80236b:	89 e5                	mov    %esp,%ebp
  80236d:	56                   	push   %esi
  80236e:	53                   	push   %ebx
  80236f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802372:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802375:	50                   	push   %eax
  802376:	e8 53 f0 ff ff       	call   8013ce <fd_alloc>
  80237b:	83 c4 10             	add    $0x10,%esp
  80237e:	89 c2                	mov    %eax,%edx
  802380:	85 c0                	test   %eax,%eax
  802382:	0f 88 2c 01 00 00    	js     8024b4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802388:	83 ec 04             	sub    $0x4,%esp
  80238b:	68 07 04 00 00       	push   $0x407
  802390:	ff 75 f4             	pushl  -0xc(%ebp)
  802393:	6a 00                	push   $0x0
  802395:	e8 ea ea ff ff       	call   800e84 <sys_page_alloc>
  80239a:	83 c4 10             	add    $0x10,%esp
  80239d:	89 c2                	mov    %eax,%edx
  80239f:	85 c0                	test   %eax,%eax
  8023a1:	0f 88 0d 01 00 00    	js     8024b4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8023a7:	83 ec 0c             	sub    $0xc,%esp
  8023aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8023ad:	50                   	push   %eax
  8023ae:	e8 1b f0 ff ff       	call   8013ce <fd_alloc>
  8023b3:	89 c3                	mov    %eax,%ebx
  8023b5:	83 c4 10             	add    $0x10,%esp
  8023b8:	85 c0                	test   %eax,%eax
  8023ba:	0f 88 e2 00 00 00    	js     8024a2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023c0:	83 ec 04             	sub    $0x4,%esp
  8023c3:	68 07 04 00 00       	push   $0x407
  8023c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8023cb:	6a 00                	push   $0x0
  8023cd:	e8 b2 ea ff ff       	call   800e84 <sys_page_alloc>
  8023d2:	89 c3                	mov    %eax,%ebx
  8023d4:	83 c4 10             	add    $0x10,%esp
  8023d7:	85 c0                	test   %eax,%eax
  8023d9:	0f 88 c3 00 00 00    	js     8024a2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023df:	83 ec 0c             	sub    $0xc,%esp
  8023e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8023e5:	e8 cd ef ff ff       	call   8013b7 <fd2data>
  8023ea:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023ec:	83 c4 0c             	add    $0xc,%esp
  8023ef:	68 07 04 00 00       	push   $0x407
  8023f4:	50                   	push   %eax
  8023f5:	6a 00                	push   $0x0
  8023f7:	e8 88 ea ff ff       	call   800e84 <sys_page_alloc>
  8023fc:	89 c3                	mov    %eax,%ebx
  8023fe:	83 c4 10             	add    $0x10,%esp
  802401:	85 c0                	test   %eax,%eax
  802403:	0f 88 89 00 00 00    	js     802492 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802409:	83 ec 0c             	sub    $0xc,%esp
  80240c:	ff 75 f0             	pushl  -0x10(%ebp)
  80240f:	e8 a3 ef ff ff       	call   8013b7 <fd2data>
  802414:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80241b:	50                   	push   %eax
  80241c:	6a 00                	push   $0x0
  80241e:	56                   	push   %esi
  80241f:	6a 00                	push   $0x0
  802421:	e8 a1 ea ff ff       	call   800ec7 <sys_page_map>
  802426:	89 c3                	mov    %eax,%ebx
  802428:	83 c4 20             	add    $0x20,%esp
  80242b:	85 c0                	test   %eax,%eax
  80242d:	78 55                	js     802484 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80242f:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  802435:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802438:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80243a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80243d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802444:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  80244a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80244d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80244f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802452:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802459:	83 ec 0c             	sub    $0xc,%esp
  80245c:	ff 75 f4             	pushl  -0xc(%ebp)
  80245f:	e8 43 ef ff ff       	call   8013a7 <fd2num>
  802464:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802467:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802469:	83 c4 04             	add    $0x4,%esp
  80246c:	ff 75 f0             	pushl  -0x10(%ebp)
  80246f:	e8 33 ef ff ff       	call   8013a7 <fd2num>
  802474:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802477:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80247a:	83 c4 10             	add    $0x10,%esp
  80247d:	ba 00 00 00 00       	mov    $0x0,%edx
  802482:	eb 30                	jmp    8024b4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802484:	83 ec 08             	sub    $0x8,%esp
  802487:	56                   	push   %esi
  802488:	6a 00                	push   $0x0
  80248a:	e8 7a ea ff ff       	call   800f09 <sys_page_unmap>
  80248f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802492:	83 ec 08             	sub    $0x8,%esp
  802495:	ff 75 f0             	pushl  -0x10(%ebp)
  802498:	6a 00                	push   $0x0
  80249a:	e8 6a ea ff ff       	call   800f09 <sys_page_unmap>
  80249f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8024a2:	83 ec 08             	sub    $0x8,%esp
  8024a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8024a8:	6a 00                	push   $0x0
  8024aa:	e8 5a ea ff ff       	call   800f09 <sys_page_unmap>
  8024af:	83 c4 10             	add    $0x10,%esp
  8024b2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8024b4:	89 d0                	mov    %edx,%eax
  8024b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024b9:	5b                   	pop    %ebx
  8024ba:	5e                   	pop    %esi
  8024bb:	5d                   	pop    %ebp
  8024bc:	c3                   	ret    

008024bd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024bd:	55                   	push   %ebp
  8024be:	89 e5                	mov    %esp,%ebp
  8024c0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024c6:	50                   	push   %eax
  8024c7:	ff 75 08             	pushl  0x8(%ebp)
  8024ca:	e8 4e ef ff ff       	call   80141d <fd_lookup>
  8024cf:	83 c4 10             	add    $0x10,%esp
  8024d2:	85 c0                	test   %eax,%eax
  8024d4:	78 18                	js     8024ee <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024d6:	83 ec 0c             	sub    $0xc,%esp
  8024d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8024dc:	e8 d6 ee ff ff       	call   8013b7 <fd2data>
	return _pipeisclosed(fd, p);
  8024e1:	89 c2                	mov    %eax,%edx
  8024e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e6:	e8 21 fd ff ff       	call   80220c <_pipeisclosed>
  8024eb:	83 c4 10             	add    $0x10,%esp
}
  8024ee:	c9                   	leave  
  8024ef:	c3                   	ret    

008024f0 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8024f0:	55                   	push   %ebp
  8024f1:	89 e5                	mov    %esp,%ebp
  8024f3:	56                   	push   %esi
  8024f4:	53                   	push   %ebx
  8024f5:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8024f8:	85 f6                	test   %esi,%esi
  8024fa:	75 16                	jne    802512 <wait+0x22>
  8024fc:	68 7b 30 80 00       	push   $0x80307b
  802501:	68 7b 2f 80 00       	push   $0x802f7b
  802506:	6a 09                	push   $0x9
  802508:	68 86 30 80 00       	push   $0x803086
  80250d:	e8 11 df ff ff       	call   800423 <_panic>
	e = &envs[ENVX(envid)];
  802512:	89 f0                	mov    %esi,%eax
  802514:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802519:	89 c2                	mov    %eax,%edx
  80251b:	c1 e2 07             	shl    $0x7,%edx
  80251e:	8d 9c c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%ebx
  802525:	eb 05                	jmp    80252c <wait+0x3c>
		sys_yield();
  802527:	e8 39 e9 ff ff       	call   800e65 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80252c:	8b 43 54             	mov    0x54(%ebx),%eax
  80252f:	39 c6                	cmp    %eax,%esi
  802531:	75 07                	jne    80253a <wait+0x4a>
  802533:	8b 43 60             	mov    0x60(%ebx),%eax
  802536:	85 c0                	test   %eax,%eax
  802538:	75 ed                	jne    802527 <wait+0x37>
		sys_yield();
}
  80253a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80253d:	5b                   	pop    %ebx
  80253e:	5e                   	pop    %esi
  80253f:	5d                   	pop    %ebp
  802540:	c3                   	ret    

00802541 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802541:	55                   	push   %ebp
  802542:	89 e5                	mov    %esp,%ebp
  802544:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802547:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  80254e:	75 2a                	jne    80257a <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802550:	83 ec 04             	sub    $0x4,%esp
  802553:	6a 07                	push   $0x7
  802555:	68 00 f0 bf ee       	push   $0xeebff000
  80255a:	6a 00                	push   $0x0
  80255c:	e8 23 e9 ff ff       	call   800e84 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802561:	83 c4 10             	add    $0x10,%esp
  802564:	85 c0                	test   %eax,%eax
  802566:	79 12                	jns    80257a <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802568:	50                   	push   %eax
  802569:	68 83 2a 80 00       	push   $0x802a83
  80256e:	6a 23                	push   $0x23
  802570:	68 91 30 80 00       	push   $0x803091
  802575:	e8 a9 de ff ff       	call   800423 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80257a:	8b 45 08             	mov    0x8(%ebp),%eax
  80257d:	a3 00 90 80 00       	mov    %eax,0x809000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802582:	83 ec 08             	sub    $0x8,%esp
  802585:	68 ac 25 80 00       	push   $0x8025ac
  80258a:	6a 00                	push   $0x0
  80258c:	e8 3e ea ff ff       	call   800fcf <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802591:	83 c4 10             	add    $0x10,%esp
  802594:	85 c0                	test   %eax,%eax
  802596:	79 12                	jns    8025aa <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802598:	50                   	push   %eax
  802599:	68 83 2a 80 00       	push   $0x802a83
  80259e:	6a 2c                	push   $0x2c
  8025a0:	68 91 30 80 00       	push   $0x803091
  8025a5:	e8 79 de ff ff       	call   800423 <_panic>
	}
}
  8025aa:	c9                   	leave  
  8025ab:	c3                   	ret    

008025ac <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8025ac:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8025ad:	a1 00 90 80 00       	mov    0x809000,%eax
	call *%eax
  8025b2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8025b4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8025b7:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8025bb:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8025c0:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8025c4:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8025c6:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8025c9:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8025ca:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8025cd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8025ce:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8025cf:	c3                   	ret    

008025d0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025d0:	55                   	push   %ebp
  8025d1:	89 e5                	mov    %esp,%ebp
  8025d3:	56                   	push   %esi
  8025d4:	53                   	push   %ebx
  8025d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8025d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025db:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8025de:	85 c0                	test   %eax,%eax
  8025e0:	75 12                	jne    8025f4 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8025e2:	83 ec 0c             	sub    $0xc,%esp
  8025e5:	68 00 00 c0 ee       	push   $0xeec00000
  8025ea:	e8 45 ea ff ff       	call   801034 <sys_ipc_recv>
  8025ef:	83 c4 10             	add    $0x10,%esp
  8025f2:	eb 0c                	jmp    802600 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8025f4:	83 ec 0c             	sub    $0xc,%esp
  8025f7:	50                   	push   %eax
  8025f8:	e8 37 ea ff ff       	call   801034 <sys_ipc_recv>
  8025fd:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802600:	85 f6                	test   %esi,%esi
  802602:	0f 95 c1             	setne  %cl
  802605:	85 db                	test   %ebx,%ebx
  802607:	0f 95 c2             	setne  %dl
  80260a:	84 d1                	test   %dl,%cl
  80260c:	74 09                	je     802617 <ipc_recv+0x47>
  80260e:	89 c2                	mov    %eax,%edx
  802610:	c1 ea 1f             	shr    $0x1f,%edx
  802613:	84 d2                	test   %dl,%dl
  802615:	75 2a                	jne    802641 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802617:	85 f6                	test   %esi,%esi
  802619:	74 0d                	je     802628 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80261b:	a1 90 77 80 00       	mov    0x807790,%eax
  802620:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  802626:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802628:	85 db                	test   %ebx,%ebx
  80262a:	74 0d                	je     802639 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80262c:	a1 90 77 80 00       	mov    0x807790,%eax
  802631:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  802637:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802639:	a1 90 77 80 00       	mov    0x807790,%eax
  80263e:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  802641:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802644:	5b                   	pop    %ebx
  802645:	5e                   	pop    %esi
  802646:	5d                   	pop    %ebp
  802647:	c3                   	ret    

00802648 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802648:	55                   	push   %ebp
  802649:	89 e5                	mov    %esp,%ebp
  80264b:	57                   	push   %edi
  80264c:	56                   	push   %esi
  80264d:	53                   	push   %ebx
  80264e:	83 ec 0c             	sub    $0xc,%esp
  802651:	8b 7d 08             	mov    0x8(%ebp),%edi
  802654:	8b 75 0c             	mov    0xc(%ebp),%esi
  802657:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80265a:	85 db                	test   %ebx,%ebx
  80265c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802661:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802664:	ff 75 14             	pushl  0x14(%ebp)
  802667:	53                   	push   %ebx
  802668:	56                   	push   %esi
  802669:	57                   	push   %edi
  80266a:	e8 a2 e9 ff ff       	call   801011 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80266f:	89 c2                	mov    %eax,%edx
  802671:	c1 ea 1f             	shr    $0x1f,%edx
  802674:	83 c4 10             	add    $0x10,%esp
  802677:	84 d2                	test   %dl,%dl
  802679:	74 17                	je     802692 <ipc_send+0x4a>
  80267b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80267e:	74 12                	je     802692 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802680:	50                   	push   %eax
  802681:	68 9f 30 80 00       	push   $0x80309f
  802686:	6a 47                	push   $0x47
  802688:	68 ad 30 80 00       	push   $0x8030ad
  80268d:	e8 91 dd ff ff       	call   800423 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802692:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802695:	75 07                	jne    80269e <ipc_send+0x56>
			sys_yield();
  802697:	e8 c9 e7 ff ff       	call   800e65 <sys_yield>
  80269c:	eb c6                	jmp    802664 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80269e:	85 c0                	test   %eax,%eax
  8026a0:	75 c2                	jne    802664 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8026a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026a5:	5b                   	pop    %ebx
  8026a6:	5e                   	pop    %esi
  8026a7:	5f                   	pop    %edi
  8026a8:	5d                   	pop    %ebp
  8026a9:	c3                   	ret    

008026aa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026aa:	55                   	push   %ebp
  8026ab:	89 e5                	mov    %esp,%ebp
  8026ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8026b0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026b5:	89 c2                	mov    %eax,%edx
  8026b7:	c1 e2 07             	shl    $0x7,%edx
  8026ba:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  8026c1:	8b 52 5c             	mov    0x5c(%edx),%edx
  8026c4:	39 ca                	cmp    %ecx,%edx
  8026c6:	75 11                	jne    8026d9 <ipc_find_env+0x2f>
			return envs[i].env_id;
  8026c8:	89 c2                	mov    %eax,%edx
  8026ca:	c1 e2 07             	shl    $0x7,%edx
  8026cd:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8026d4:	8b 40 54             	mov    0x54(%eax),%eax
  8026d7:	eb 0f                	jmp    8026e8 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026d9:	83 c0 01             	add    $0x1,%eax
  8026dc:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026e1:	75 d2                	jne    8026b5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026e8:	5d                   	pop    %ebp
  8026e9:	c3                   	ret    

008026ea <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026ea:	55                   	push   %ebp
  8026eb:	89 e5                	mov    %esp,%ebp
  8026ed:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026f0:	89 d0                	mov    %edx,%eax
  8026f2:	c1 e8 16             	shr    $0x16,%eax
  8026f5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8026fc:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802701:	f6 c1 01             	test   $0x1,%cl
  802704:	74 1d                	je     802723 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802706:	c1 ea 0c             	shr    $0xc,%edx
  802709:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802710:	f6 c2 01             	test   $0x1,%dl
  802713:	74 0e                	je     802723 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802715:	c1 ea 0c             	shr    $0xc,%edx
  802718:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80271f:	ef 
  802720:	0f b7 c0             	movzwl %ax,%eax
}
  802723:	5d                   	pop    %ebp
  802724:	c3                   	ret    
  802725:	66 90                	xchg   %ax,%ax
  802727:	66 90                	xchg   %ax,%ax
  802729:	66 90                	xchg   %ax,%ax
  80272b:	66 90                	xchg   %ax,%ax
  80272d:	66 90                	xchg   %ax,%ax
  80272f:	90                   	nop

00802730 <__udivdi3>:
  802730:	55                   	push   %ebp
  802731:	57                   	push   %edi
  802732:	56                   	push   %esi
  802733:	53                   	push   %ebx
  802734:	83 ec 1c             	sub    $0x1c,%esp
  802737:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80273b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80273f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802743:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802747:	85 f6                	test   %esi,%esi
  802749:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80274d:	89 ca                	mov    %ecx,%edx
  80274f:	89 f8                	mov    %edi,%eax
  802751:	75 3d                	jne    802790 <__udivdi3+0x60>
  802753:	39 cf                	cmp    %ecx,%edi
  802755:	0f 87 c5 00 00 00    	ja     802820 <__udivdi3+0xf0>
  80275b:	85 ff                	test   %edi,%edi
  80275d:	89 fd                	mov    %edi,%ebp
  80275f:	75 0b                	jne    80276c <__udivdi3+0x3c>
  802761:	b8 01 00 00 00       	mov    $0x1,%eax
  802766:	31 d2                	xor    %edx,%edx
  802768:	f7 f7                	div    %edi
  80276a:	89 c5                	mov    %eax,%ebp
  80276c:	89 c8                	mov    %ecx,%eax
  80276e:	31 d2                	xor    %edx,%edx
  802770:	f7 f5                	div    %ebp
  802772:	89 c1                	mov    %eax,%ecx
  802774:	89 d8                	mov    %ebx,%eax
  802776:	89 cf                	mov    %ecx,%edi
  802778:	f7 f5                	div    %ebp
  80277a:	89 c3                	mov    %eax,%ebx
  80277c:	89 d8                	mov    %ebx,%eax
  80277e:	89 fa                	mov    %edi,%edx
  802780:	83 c4 1c             	add    $0x1c,%esp
  802783:	5b                   	pop    %ebx
  802784:	5e                   	pop    %esi
  802785:	5f                   	pop    %edi
  802786:	5d                   	pop    %ebp
  802787:	c3                   	ret    
  802788:	90                   	nop
  802789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802790:	39 ce                	cmp    %ecx,%esi
  802792:	77 74                	ja     802808 <__udivdi3+0xd8>
  802794:	0f bd fe             	bsr    %esi,%edi
  802797:	83 f7 1f             	xor    $0x1f,%edi
  80279a:	0f 84 98 00 00 00    	je     802838 <__udivdi3+0x108>
  8027a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8027a5:	89 f9                	mov    %edi,%ecx
  8027a7:	89 c5                	mov    %eax,%ebp
  8027a9:	29 fb                	sub    %edi,%ebx
  8027ab:	d3 e6                	shl    %cl,%esi
  8027ad:	89 d9                	mov    %ebx,%ecx
  8027af:	d3 ed                	shr    %cl,%ebp
  8027b1:	89 f9                	mov    %edi,%ecx
  8027b3:	d3 e0                	shl    %cl,%eax
  8027b5:	09 ee                	or     %ebp,%esi
  8027b7:	89 d9                	mov    %ebx,%ecx
  8027b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027bd:	89 d5                	mov    %edx,%ebp
  8027bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027c3:	d3 ed                	shr    %cl,%ebp
  8027c5:	89 f9                	mov    %edi,%ecx
  8027c7:	d3 e2                	shl    %cl,%edx
  8027c9:	89 d9                	mov    %ebx,%ecx
  8027cb:	d3 e8                	shr    %cl,%eax
  8027cd:	09 c2                	or     %eax,%edx
  8027cf:	89 d0                	mov    %edx,%eax
  8027d1:	89 ea                	mov    %ebp,%edx
  8027d3:	f7 f6                	div    %esi
  8027d5:	89 d5                	mov    %edx,%ebp
  8027d7:	89 c3                	mov    %eax,%ebx
  8027d9:	f7 64 24 0c          	mull   0xc(%esp)
  8027dd:	39 d5                	cmp    %edx,%ebp
  8027df:	72 10                	jb     8027f1 <__udivdi3+0xc1>
  8027e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8027e5:	89 f9                	mov    %edi,%ecx
  8027e7:	d3 e6                	shl    %cl,%esi
  8027e9:	39 c6                	cmp    %eax,%esi
  8027eb:	73 07                	jae    8027f4 <__udivdi3+0xc4>
  8027ed:	39 d5                	cmp    %edx,%ebp
  8027ef:	75 03                	jne    8027f4 <__udivdi3+0xc4>
  8027f1:	83 eb 01             	sub    $0x1,%ebx
  8027f4:	31 ff                	xor    %edi,%edi
  8027f6:	89 d8                	mov    %ebx,%eax
  8027f8:	89 fa                	mov    %edi,%edx
  8027fa:	83 c4 1c             	add    $0x1c,%esp
  8027fd:	5b                   	pop    %ebx
  8027fe:	5e                   	pop    %esi
  8027ff:	5f                   	pop    %edi
  802800:	5d                   	pop    %ebp
  802801:	c3                   	ret    
  802802:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802808:	31 ff                	xor    %edi,%edi
  80280a:	31 db                	xor    %ebx,%ebx
  80280c:	89 d8                	mov    %ebx,%eax
  80280e:	89 fa                	mov    %edi,%edx
  802810:	83 c4 1c             	add    $0x1c,%esp
  802813:	5b                   	pop    %ebx
  802814:	5e                   	pop    %esi
  802815:	5f                   	pop    %edi
  802816:	5d                   	pop    %ebp
  802817:	c3                   	ret    
  802818:	90                   	nop
  802819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802820:	89 d8                	mov    %ebx,%eax
  802822:	f7 f7                	div    %edi
  802824:	31 ff                	xor    %edi,%edi
  802826:	89 c3                	mov    %eax,%ebx
  802828:	89 d8                	mov    %ebx,%eax
  80282a:	89 fa                	mov    %edi,%edx
  80282c:	83 c4 1c             	add    $0x1c,%esp
  80282f:	5b                   	pop    %ebx
  802830:	5e                   	pop    %esi
  802831:	5f                   	pop    %edi
  802832:	5d                   	pop    %ebp
  802833:	c3                   	ret    
  802834:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802838:	39 ce                	cmp    %ecx,%esi
  80283a:	72 0c                	jb     802848 <__udivdi3+0x118>
  80283c:	31 db                	xor    %ebx,%ebx
  80283e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802842:	0f 87 34 ff ff ff    	ja     80277c <__udivdi3+0x4c>
  802848:	bb 01 00 00 00       	mov    $0x1,%ebx
  80284d:	e9 2a ff ff ff       	jmp    80277c <__udivdi3+0x4c>
  802852:	66 90                	xchg   %ax,%ax
  802854:	66 90                	xchg   %ax,%ax
  802856:	66 90                	xchg   %ax,%ax
  802858:	66 90                	xchg   %ax,%ax
  80285a:	66 90                	xchg   %ax,%ax
  80285c:	66 90                	xchg   %ax,%ax
  80285e:	66 90                	xchg   %ax,%ax

00802860 <__umoddi3>:
  802860:	55                   	push   %ebp
  802861:	57                   	push   %edi
  802862:	56                   	push   %esi
  802863:	53                   	push   %ebx
  802864:	83 ec 1c             	sub    $0x1c,%esp
  802867:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80286b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80286f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802873:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802877:	85 d2                	test   %edx,%edx
  802879:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80287d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802881:	89 f3                	mov    %esi,%ebx
  802883:	89 3c 24             	mov    %edi,(%esp)
  802886:	89 74 24 04          	mov    %esi,0x4(%esp)
  80288a:	75 1c                	jne    8028a8 <__umoddi3+0x48>
  80288c:	39 f7                	cmp    %esi,%edi
  80288e:	76 50                	jbe    8028e0 <__umoddi3+0x80>
  802890:	89 c8                	mov    %ecx,%eax
  802892:	89 f2                	mov    %esi,%edx
  802894:	f7 f7                	div    %edi
  802896:	89 d0                	mov    %edx,%eax
  802898:	31 d2                	xor    %edx,%edx
  80289a:	83 c4 1c             	add    $0x1c,%esp
  80289d:	5b                   	pop    %ebx
  80289e:	5e                   	pop    %esi
  80289f:	5f                   	pop    %edi
  8028a0:	5d                   	pop    %ebp
  8028a1:	c3                   	ret    
  8028a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028a8:	39 f2                	cmp    %esi,%edx
  8028aa:	89 d0                	mov    %edx,%eax
  8028ac:	77 52                	ja     802900 <__umoddi3+0xa0>
  8028ae:	0f bd ea             	bsr    %edx,%ebp
  8028b1:	83 f5 1f             	xor    $0x1f,%ebp
  8028b4:	75 5a                	jne    802910 <__umoddi3+0xb0>
  8028b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8028ba:	0f 82 e0 00 00 00    	jb     8029a0 <__umoddi3+0x140>
  8028c0:	39 0c 24             	cmp    %ecx,(%esp)
  8028c3:	0f 86 d7 00 00 00    	jbe    8029a0 <__umoddi3+0x140>
  8028c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8028d1:	83 c4 1c             	add    $0x1c,%esp
  8028d4:	5b                   	pop    %ebx
  8028d5:	5e                   	pop    %esi
  8028d6:	5f                   	pop    %edi
  8028d7:	5d                   	pop    %ebp
  8028d8:	c3                   	ret    
  8028d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028e0:	85 ff                	test   %edi,%edi
  8028e2:	89 fd                	mov    %edi,%ebp
  8028e4:	75 0b                	jne    8028f1 <__umoddi3+0x91>
  8028e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8028eb:	31 d2                	xor    %edx,%edx
  8028ed:	f7 f7                	div    %edi
  8028ef:	89 c5                	mov    %eax,%ebp
  8028f1:	89 f0                	mov    %esi,%eax
  8028f3:	31 d2                	xor    %edx,%edx
  8028f5:	f7 f5                	div    %ebp
  8028f7:	89 c8                	mov    %ecx,%eax
  8028f9:	f7 f5                	div    %ebp
  8028fb:	89 d0                	mov    %edx,%eax
  8028fd:	eb 99                	jmp    802898 <__umoddi3+0x38>
  8028ff:	90                   	nop
  802900:	89 c8                	mov    %ecx,%eax
  802902:	89 f2                	mov    %esi,%edx
  802904:	83 c4 1c             	add    $0x1c,%esp
  802907:	5b                   	pop    %ebx
  802908:	5e                   	pop    %esi
  802909:	5f                   	pop    %edi
  80290a:	5d                   	pop    %ebp
  80290b:	c3                   	ret    
  80290c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802910:	8b 34 24             	mov    (%esp),%esi
  802913:	bf 20 00 00 00       	mov    $0x20,%edi
  802918:	89 e9                	mov    %ebp,%ecx
  80291a:	29 ef                	sub    %ebp,%edi
  80291c:	d3 e0                	shl    %cl,%eax
  80291e:	89 f9                	mov    %edi,%ecx
  802920:	89 f2                	mov    %esi,%edx
  802922:	d3 ea                	shr    %cl,%edx
  802924:	89 e9                	mov    %ebp,%ecx
  802926:	09 c2                	or     %eax,%edx
  802928:	89 d8                	mov    %ebx,%eax
  80292a:	89 14 24             	mov    %edx,(%esp)
  80292d:	89 f2                	mov    %esi,%edx
  80292f:	d3 e2                	shl    %cl,%edx
  802931:	89 f9                	mov    %edi,%ecx
  802933:	89 54 24 04          	mov    %edx,0x4(%esp)
  802937:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80293b:	d3 e8                	shr    %cl,%eax
  80293d:	89 e9                	mov    %ebp,%ecx
  80293f:	89 c6                	mov    %eax,%esi
  802941:	d3 e3                	shl    %cl,%ebx
  802943:	89 f9                	mov    %edi,%ecx
  802945:	89 d0                	mov    %edx,%eax
  802947:	d3 e8                	shr    %cl,%eax
  802949:	89 e9                	mov    %ebp,%ecx
  80294b:	09 d8                	or     %ebx,%eax
  80294d:	89 d3                	mov    %edx,%ebx
  80294f:	89 f2                	mov    %esi,%edx
  802951:	f7 34 24             	divl   (%esp)
  802954:	89 d6                	mov    %edx,%esi
  802956:	d3 e3                	shl    %cl,%ebx
  802958:	f7 64 24 04          	mull   0x4(%esp)
  80295c:	39 d6                	cmp    %edx,%esi
  80295e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802962:	89 d1                	mov    %edx,%ecx
  802964:	89 c3                	mov    %eax,%ebx
  802966:	72 08                	jb     802970 <__umoddi3+0x110>
  802968:	75 11                	jne    80297b <__umoddi3+0x11b>
  80296a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80296e:	73 0b                	jae    80297b <__umoddi3+0x11b>
  802970:	2b 44 24 04          	sub    0x4(%esp),%eax
  802974:	1b 14 24             	sbb    (%esp),%edx
  802977:	89 d1                	mov    %edx,%ecx
  802979:	89 c3                	mov    %eax,%ebx
  80297b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80297f:	29 da                	sub    %ebx,%edx
  802981:	19 ce                	sbb    %ecx,%esi
  802983:	89 f9                	mov    %edi,%ecx
  802985:	89 f0                	mov    %esi,%eax
  802987:	d3 e0                	shl    %cl,%eax
  802989:	89 e9                	mov    %ebp,%ecx
  80298b:	d3 ea                	shr    %cl,%edx
  80298d:	89 e9                	mov    %ebp,%ecx
  80298f:	d3 ee                	shr    %cl,%esi
  802991:	09 d0                	or     %edx,%eax
  802993:	89 f2                	mov    %esi,%edx
  802995:	83 c4 1c             	add    $0x1c,%esp
  802998:	5b                   	pop    %ebx
  802999:	5e                   	pop    %esi
  80299a:	5f                   	pop    %edi
  80299b:	5d                   	pop    %ebp
  80299c:	c3                   	ret    
  80299d:	8d 76 00             	lea    0x0(%esi),%esi
  8029a0:	29 f9                	sub    %edi,%ecx
  8029a2:	19 d6                	sbb    %edx,%esi
  8029a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029ac:	e9 18 ff ff ff       	jmp    8028c9 <__umoddi3+0x69>
