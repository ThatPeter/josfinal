
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
  80006d:	68 a0 2c 80 00       	push   $0x802ca0
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
  80009c:	68 68 2d 80 00       	push   $0x802d68
  8000a1:	e8 55 04 00 00       	call   8004fb <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 af 2c 80 00       	push   $0x802caf
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
  8000d8:	68 a4 2d 80 00       	push   $0x802da4
  8000dd:	e8 19 04 00 00       	call   8004fb <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 c6 2c 80 00       	push   $0x802cc6
  8000ef:	e8 07 04 00 00       	call   8004fb <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 dc 2c 80 00       	push   $0x802cdc
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
  80011e:	68 e8 2c 80 00       	push   $0x802ce8
  800123:	56                   	push   %esi
  800124:	e8 77 09 00 00       	call   800aa0 <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 6b 09 00 00       	call   800aa0 <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 e9 2c 80 00       	push   $0x802ce9
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
  800158:	68 eb 2c 80 00       	push   $0x802ceb
  80015d:	e8 99 03 00 00       	call   8004fb <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 ef 2c 80 00 	movl   $0x802cef,(%esp)
  800169:	e8 8d 03 00 00       	call   8004fb <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 79 16 00 00       	call   8017f3 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 01 2d 80 00       	push   $0x802d01
  80018c:	6a 37                	push   $0x37
  80018e:	68 0e 2d 80 00       	push   $0x802d0e
  800193:	e8 8a 02 00 00       	call   800422 <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 1a 2d 80 00       	push   $0x802d1a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 0e 2d 80 00       	push   $0x802d0e
  8001a9:	e8 74 02 00 00       	call   800422 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 89 16 00 00       	call   801843 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 34 2d 80 00       	push   $0x802d34
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 0e 2d 80 00       	push   $0x802d0e
  8001ce:	e8 4f 02 00 00       	call   800422 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 3c 2d 80 00       	push   $0x802d3c
  8001db:	e8 1b 03 00 00       	call   8004fb <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 50 2d 80 00       	push   $0x802d50
  8001ea:	68 4f 2d 80 00       	push   $0x802d4f
  8001ef:	e8 e5 21 00 00       	call   8023d9 <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 53 2d 80 00       	push   $0x802d53
  800204:	e8 f2 02 00 00       	call   8004fb <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 9a 25 00 00       	call   8027b1 <wait>
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
  80022c:	68 d3 2d 80 00       	push   $0x802dd3
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
  8002fc:	e8 2e 16 00 00       	call   80192f <read>
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
  800326:	e8 9b 13 00 00       	call   8016c6 <fd_lookup>
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
  80034f:	e8 23 13 00 00       	call   801677 <fd_alloc>
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
  800391:	e8 ba 12 00 00       	call   801650 <fd2num>
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
  8003b4:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  80040e:	e8 0b 14 00 00       	call   80181e <close_all>
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
  800440:	68 ec 2d 80 00       	push   $0x802dec
  800445:	e8 b1 00 00 00       	call   8004fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80044a:	83 c4 18             	add    $0x18,%esp
  80044d:	53                   	push   %ebx
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	e8 54 00 00 00       	call   8004aa <vcprintf>
	cprintf("\n");
  800456:	c7 04 24 e6 31 80 00 	movl   $0x8031e6,(%esp)
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
  80055e:	e8 9d 24 00 00       	call   802a00 <__udivdi3>
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
  8005a1:	e8 8a 25 00 00       	call   802b30 <__umoddi3>
  8005a6:	83 c4 14             	add    $0x14,%esp
  8005a9:	0f be 80 0f 2e 80 00 	movsbl 0x802e0f(%eax),%eax
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
  8006a5:	ff 24 85 60 2f 80 00 	jmp    *0x802f60(,%eax,4)
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
  800769:	8b 14 85 c0 30 80 00 	mov    0x8030c0(,%eax,4),%edx
  800770:	85 d2                	test   %edx,%edx
  800772:	75 18                	jne    80078c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800774:	50                   	push   %eax
  800775:	68 27 2e 80 00       	push   $0x802e27
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
  80078d:	68 4d 33 80 00       	push   $0x80334d
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
  8007b1:	b8 20 2e 80 00       	mov    $0x802e20,%eax
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
  800e2c:	68 1f 31 80 00       	push   $0x80311f
  800e31:	6a 23                	push   $0x23
  800e33:	68 3c 31 80 00       	push   $0x80313c
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
  800ead:	68 1f 31 80 00       	push   $0x80311f
  800eb2:	6a 23                	push   $0x23
  800eb4:	68 3c 31 80 00       	push   $0x80313c
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
  800eef:	68 1f 31 80 00       	push   $0x80311f
  800ef4:	6a 23                	push   $0x23
  800ef6:	68 3c 31 80 00       	push   $0x80313c
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
  800f31:	68 1f 31 80 00       	push   $0x80311f
  800f36:	6a 23                	push   $0x23
  800f38:	68 3c 31 80 00       	push   $0x80313c
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
  800f73:	68 1f 31 80 00       	push   $0x80311f
  800f78:	6a 23                	push   $0x23
  800f7a:	68 3c 31 80 00       	push   $0x80313c
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
  800fb5:	68 1f 31 80 00       	push   $0x80311f
  800fba:	6a 23                	push   $0x23
  800fbc:	68 3c 31 80 00       	push   $0x80313c
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
  800ff7:	68 1f 31 80 00       	push   $0x80311f
  800ffc:	6a 23                	push   $0x23
  800ffe:	68 3c 31 80 00       	push   $0x80313c
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
  80105b:	68 1f 31 80 00       	push   $0x80311f
  801060:	6a 23                	push   $0x23
  801062:	68 3c 31 80 00       	push   $0x80313c
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

008010b4 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010bf:	b8 10 00 00 00       	mov    $0x10,%eax
  8010c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c7:	89 cb                	mov    %ecx,%ebx
  8010c9:	89 cf                	mov    %ecx,%edi
  8010cb:	89 ce                	mov    %ecx,%esi
  8010cd:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  8010cf:	5b                   	pop    %ebx
  8010d0:	5e                   	pop    %esi
  8010d1:	5f                   	pop    %edi
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	53                   	push   %ebx
  8010d8:	83 ec 04             	sub    $0x4,%esp
  8010db:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010de:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8010e0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8010e4:	74 11                	je     8010f7 <pgfault+0x23>
  8010e6:	89 d8                	mov    %ebx,%eax
  8010e8:	c1 e8 0c             	shr    $0xc,%eax
  8010eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f2:	f6 c4 08             	test   $0x8,%ah
  8010f5:	75 14                	jne    80110b <pgfault+0x37>
		panic("faulting access");
  8010f7:	83 ec 04             	sub    $0x4,%esp
  8010fa:	68 4a 31 80 00       	push   $0x80314a
  8010ff:	6a 1f                	push   $0x1f
  801101:	68 5a 31 80 00       	push   $0x80315a
  801106:	e8 17 f3 ff ff       	call   800422 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  80110b:	83 ec 04             	sub    $0x4,%esp
  80110e:	6a 07                	push   $0x7
  801110:	68 00 f0 7f 00       	push   $0x7ff000
  801115:	6a 00                	push   $0x0
  801117:	e8 67 fd ff ff       	call   800e83 <sys_page_alloc>
	if (r < 0) {
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	85 c0                	test   %eax,%eax
  801121:	79 12                	jns    801135 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  801123:	50                   	push   %eax
  801124:	68 65 31 80 00       	push   $0x803165
  801129:	6a 2d                	push   $0x2d
  80112b:	68 5a 31 80 00       	push   $0x80315a
  801130:	e8 ed f2 ff ff       	call   800422 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  801135:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80113b:	83 ec 04             	sub    $0x4,%esp
  80113e:	68 00 10 00 00       	push   $0x1000
  801143:	53                   	push   %ebx
  801144:	68 00 f0 7f 00       	push   $0x7ff000
  801149:	e8 2c fb ff ff       	call   800c7a <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  80114e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801155:	53                   	push   %ebx
  801156:	6a 00                	push   $0x0
  801158:	68 00 f0 7f 00       	push   $0x7ff000
  80115d:	6a 00                	push   $0x0
  80115f:	e8 62 fd ff ff       	call   800ec6 <sys_page_map>
	if (r < 0) {
  801164:	83 c4 20             	add    $0x20,%esp
  801167:	85 c0                	test   %eax,%eax
  801169:	79 12                	jns    80117d <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80116b:	50                   	push   %eax
  80116c:	68 65 31 80 00       	push   $0x803165
  801171:	6a 34                	push   $0x34
  801173:	68 5a 31 80 00       	push   $0x80315a
  801178:	e8 a5 f2 ff ff       	call   800422 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  80117d:	83 ec 08             	sub    $0x8,%esp
  801180:	68 00 f0 7f 00       	push   $0x7ff000
  801185:	6a 00                	push   $0x0
  801187:	e8 7c fd ff ff       	call   800f08 <sys_page_unmap>
	if (r < 0) {
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	85 c0                	test   %eax,%eax
  801191:	79 12                	jns    8011a5 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  801193:	50                   	push   %eax
  801194:	68 65 31 80 00       	push   $0x803165
  801199:	6a 38                	push   $0x38
  80119b:	68 5a 31 80 00       	push   $0x80315a
  8011a0:	e8 7d f2 ff ff       	call   800422 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8011a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a8:	c9                   	leave  
  8011a9:	c3                   	ret    

008011aa <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	57                   	push   %edi
  8011ae:	56                   	push   %esi
  8011af:	53                   	push   %ebx
  8011b0:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8011b3:	68 d4 10 80 00       	push   $0x8010d4
  8011b8:	e8 4c 16 00 00       	call   802809 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8011bd:	b8 07 00 00 00       	mov    $0x7,%eax
  8011c2:	cd 30                	int    $0x30
  8011c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	79 17                	jns    8011e5 <fork+0x3b>
		panic("fork fault %e");
  8011ce:	83 ec 04             	sub    $0x4,%esp
  8011d1:	68 7e 31 80 00       	push   $0x80317e
  8011d6:	68 85 00 00 00       	push   $0x85
  8011db:	68 5a 31 80 00       	push   $0x80315a
  8011e0:	e8 3d f2 ff ff       	call   800422 <_panic>
  8011e5:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8011e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011eb:	75 24                	jne    801211 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011ed:	e8 53 fc ff ff       	call   800e45 <sys_getenvid>
  8011f2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011f7:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8011fd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801202:	a3 90 77 80 00       	mov    %eax,0x807790
		return 0;
  801207:	b8 00 00 00 00       	mov    $0x0,%eax
  80120c:	e9 64 01 00 00       	jmp    801375 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801211:	83 ec 04             	sub    $0x4,%esp
  801214:	6a 07                	push   $0x7
  801216:	68 00 f0 bf ee       	push   $0xeebff000
  80121b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80121e:	e8 60 fc ff ff       	call   800e83 <sys_page_alloc>
  801223:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801226:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80122b:	89 d8                	mov    %ebx,%eax
  80122d:	c1 e8 16             	shr    $0x16,%eax
  801230:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801237:	a8 01                	test   $0x1,%al
  801239:	0f 84 fc 00 00 00    	je     80133b <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80123f:	89 d8                	mov    %ebx,%eax
  801241:	c1 e8 0c             	shr    $0xc,%eax
  801244:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80124b:	f6 c2 01             	test   $0x1,%dl
  80124e:	0f 84 e7 00 00 00    	je     80133b <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801254:	89 c6                	mov    %eax,%esi
  801256:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801259:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801260:	f6 c6 04             	test   $0x4,%dh
  801263:	74 39                	je     80129e <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801265:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80126c:	83 ec 0c             	sub    $0xc,%esp
  80126f:	25 07 0e 00 00       	and    $0xe07,%eax
  801274:	50                   	push   %eax
  801275:	56                   	push   %esi
  801276:	57                   	push   %edi
  801277:	56                   	push   %esi
  801278:	6a 00                	push   $0x0
  80127a:	e8 47 fc ff ff       	call   800ec6 <sys_page_map>
		if (r < 0) {
  80127f:	83 c4 20             	add    $0x20,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	0f 89 b1 00 00 00    	jns    80133b <fork+0x191>
		    	panic("sys page map fault %e");
  80128a:	83 ec 04             	sub    $0x4,%esp
  80128d:	68 8c 31 80 00       	push   $0x80318c
  801292:	6a 55                	push   $0x55
  801294:	68 5a 31 80 00       	push   $0x80315a
  801299:	e8 84 f1 ff ff       	call   800422 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80129e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012a5:	f6 c2 02             	test   $0x2,%dl
  8012a8:	75 0c                	jne    8012b6 <fork+0x10c>
  8012aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b1:	f6 c4 08             	test   $0x8,%ah
  8012b4:	74 5b                	je     801311 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8012b6:	83 ec 0c             	sub    $0xc,%esp
  8012b9:	68 05 08 00 00       	push   $0x805
  8012be:	56                   	push   %esi
  8012bf:	57                   	push   %edi
  8012c0:	56                   	push   %esi
  8012c1:	6a 00                	push   $0x0
  8012c3:	e8 fe fb ff ff       	call   800ec6 <sys_page_map>
		if (r < 0) {
  8012c8:	83 c4 20             	add    $0x20,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	79 14                	jns    8012e3 <fork+0x139>
		    	panic("sys page map fault %e");
  8012cf:	83 ec 04             	sub    $0x4,%esp
  8012d2:	68 8c 31 80 00       	push   $0x80318c
  8012d7:	6a 5c                	push   $0x5c
  8012d9:	68 5a 31 80 00       	push   $0x80315a
  8012de:	e8 3f f1 ff ff       	call   800422 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8012e3:	83 ec 0c             	sub    $0xc,%esp
  8012e6:	68 05 08 00 00       	push   $0x805
  8012eb:	56                   	push   %esi
  8012ec:	6a 00                	push   $0x0
  8012ee:	56                   	push   %esi
  8012ef:	6a 00                	push   $0x0
  8012f1:	e8 d0 fb ff ff       	call   800ec6 <sys_page_map>
		if (r < 0) {
  8012f6:	83 c4 20             	add    $0x20,%esp
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	79 3e                	jns    80133b <fork+0x191>
		    	panic("sys page map fault %e");
  8012fd:	83 ec 04             	sub    $0x4,%esp
  801300:	68 8c 31 80 00       	push   $0x80318c
  801305:	6a 60                	push   $0x60
  801307:	68 5a 31 80 00       	push   $0x80315a
  80130c:	e8 11 f1 ff ff       	call   800422 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801311:	83 ec 0c             	sub    $0xc,%esp
  801314:	6a 05                	push   $0x5
  801316:	56                   	push   %esi
  801317:	57                   	push   %edi
  801318:	56                   	push   %esi
  801319:	6a 00                	push   $0x0
  80131b:	e8 a6 fb ff ff       	call   800ec6 <sys_page_map>
		if (r < 0) {
  801320:	83 c4 20             	add    $0x20,%esp
  801323:	85 c0                	test   %eax,%eax
  801325:	79 14                	jns    80133b <fork+0x191>
		    	panic("sys page map fault %e");
  801327:	83 ec 04             	sub    $0x4,%esp
  80132a:	68 8c 31 80 00       	push   $0x80318c
  80132f:	6a 65                	push   $0x65
  801331:	68 5a 31 80 00       	push   $0x80315a
  801336:	e8 e7 f0 ff ff       	call   800422 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80133b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801341:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801347:	0f 85 de fe ff ff    	jne    80122b <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80134d:	a1 90 77 80 00       	mov    0x807790,%eax
  801352:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  801358:	83 ec 08             	sub    $0x8,%esp
  80135b:	50                   	push   %eax
  80135c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80135f:	57                   	push   %edi
  801360:	e8 69 fc ff ff       	call   800fce <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801365:	83 c4 08             	add    $0x8,%esp
  801368:	6a 02                	push   $0x2
  80136a:	57                   	push   %edi
  80136b:	e8 da fb ff ff       	call   800f4a <sys_env_set_status>
	
	return envid;
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801375:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801378:	5b                   	pop    %ebx
  801379:	5e                   	pop    %esi
  80137a:	5f                   	pop    %edi
  80137b:	5d                   	pop    %ebp
  80137c:	c3                   	ret    

0080137d <sfork>:

envid_t
sfork(void)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801380:	b8 00 00 00 00       	mov    $0x0,%eax
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    

00801387 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	56                   	push   %esi
  80138b:	53                   	push   %ebx
  80138c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80138f:	89 1d 94 77 80 00    	mov    %ebx,0x807794
	cprintf("in fork.c thread create. func: %x\n", func);
  801395:	83 ec 08             	sub    $0x8,%esp
  801398:	53                   	push   %ebx
  801399:	68 1c 32 80 00       	push   $0x80321c
  80139e:	e8 58 f1 ff ff       	call   8004fb <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8013a3:	c7 04 24 e8 03 80 00 	movl   $0x8003e8,(%esp)
  8013aa:	e8 c5 fc ff ff       	call   801074 <sys_thread_create>
  8013af:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8013b1:	83 c4 08             	add    $0x8,%esp
  8013b4:	53                   	push   %ebx
  8013b5:	68 1c 32 80 00       	push   $0x80321c
  8013ba:	e8 3c f1 ff ff       	call   8004fb <cprintf>
	return id;
}
  8013bf:	89 f0                	mov    %esi,%eax
  8013c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c4:	5b                   	pop    %ebx
  8013c5:	5e                   	pop    %esi
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    

008013c8 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8013ce:	ff 75 08             	pushl  0x8(%ebp)
  8013d1:	e8 be fc ff ff       	call   801094 <sys_thread_free>
}
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	c9                   	leave  
  8013da:	c3                   	ret    

008013db <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8013e1:	ff 75 08             	pushl  0x8(%ebp)
  8013e4:	e8 cb fc ff ff       	call   8010b4 <sys_thread_join>
}
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8013f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8013f9:	83 ec 04             	sub    $0x4,%esp
  8013fc:	6a 07                	push   $0x7
  8013fe:	6a 00                	push   $0x0
  801400:	56                   	push   %esi
  801401:	e8 7d fa ff ff       	call   800e83 <sys_page_alloc>
	if (r < 0) {
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	85 c0                	test   %eax,%eax
  80140b:	79 15                	jns    801422 <queue_append+0x34>
		panic("%e\n", r);
  80140d:	50                   	push   %eax
  80140e:	68 63 2d 80 00       	push   $0x802d63
  801413:	68 c4 00 00 00       	push   $0xc4
  801418:	68 5a 31 80 00       	push   $0x80315a
  80141d:	e8 00 f0 ff ff       	call   800422 <_panic>
	}	
	wt->envid = envid;
  801422:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801428:	83 ec 04             	sub    $0x4,%esp
  80142b:	ff 33                	pushl  (%ebx)
  80142d:	56                   	push   %esi
  80142e:	68 40 32 80 00       	push   $0x803240
  801433:	e8 c3 f0 ff ff       	call   8004fb <cprintf>
	if (queue->first == NULL) {
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	83 3b 00             	cmpl   $0x0,(%ebx)
  80143e:	75 29                	jne    801469 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  801440:	83 ec 0c             	sub    $0xc,%esp
  801443:	68 a2 31 80 00       	push   $0x8031a2
  801448:	e8 ae f0 ff ff       	call   8004fb <cprintf>
		queue->first = wt;
  80144d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  801453:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80145a:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801461:	00 00 00 
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	eb 2b                	jmp    801494 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801469:	83 ec 0c             	sub    $0xc,%esp
  80146c:	68 bc 31 80 00       	push   $0x8031bc
  801471:	e8 85 f0 ff ff       	call   8004fb <cprintf>
		queue->last->next = wt;
  801476:	8b 43 04             	mov    0x4(%ebx),%eax
  801479:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801480:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801487:	00 00 00 
		queue->last = wt;
  80148a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  801491:	83 c4 10             	add    $0x10,%esp
	}
}
  801494:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801497:	5b                   	pop    %ebx
  801498:	5e                   	pop    %esi
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    

0080149b <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	53                   	push   %ebx
  80149f:	83 ec 04             	sub    $0x4,%esp
  8014a2:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8014a5:	8b 02                	mov    (%edx),%eax
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	75 17                	jne    8014c2 <queue_pop+0x27>
		panic("queue empty!\n");
  8014ab:	83 ec 04             	sub    $0x4,%esp
  8014ae:	68 da 31 80 00       	push   $0x8031da
  8014b3:	68 d8 00 00 00       	push   $0xd8
  8014b8:	68 5a 31 80 00       	push   $0x80315a
  8014bd:	e8 60 ef ff ff       	call   800422 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8014c2:	8b 48 04             	mov    0x4(%eax),%ecx
  8014c5:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8014c7:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8014c9:	83 ec 08             	sub    $0x8,%esp
  8014cc:	53                   	push   %ebx
  8014cd:	68 e8 31 80 00       	push   $0x8031e8
  8014d2:	e8 24 f0 ff ff       	call   8004fb <cprintf>
	return envid;
}
  8014d7:	89 d8                	mov    %ebx,%eax
  8014d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014dc:	c9                   	leave  
  8014dd:	c3                   	ret    

008014de <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	53                   	push   %ebx
  8014e2:	83 ec 04             	sub    $0x4,%esp
  8014e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8014e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ed:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	74 5a                	je     80154e <mutex_lock+0x70>
  8014f4:	8b 43 04             	mov    0x4(%ebx),%eax
  8014f7:	83 38 00             	cmpl   $0x0,(%eax)
  8014fa:	75 52                	jne    80154e <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8014fc:	83 ec 0c             	sub    $0xc,%esp
  8014ff:	68 68 32 80 00       	push   $0x803268
  801504:	e8 f2 ef ff ff       	call   8004fb <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801509:	8b 5b 04             	mov    0x4(%ebx),%ebx
  80150c:	e8 34 f9 ff ff       	call   800e45 <sys_getenvid>
  801511:	83 c4 08             	add    $0x8,%esp
  801514:	53                   	push   %ebx
  801515:	50                   	push   %eax
  801516:	e8 d3 fe ff ff       	call   8013ee <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80151b:	e8 25 f9 ff ff       	call   800e45 <sys_getenvid>
  801520:	83 c4 08             	add    $0x8,%esp
  801523:	6a 04                	push   $0x4
  801525:	50                   	push   %eax
  801526:	e8 1f fa ff ff       	call   800f4a <sys_env_set_status>
		if (r < 0) {
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	85 c0                	test   %eax,%eax
  801530:	79 15                	jns    801547 <mutex_lock+0x69>
			panic("%e\n", r);
  801532:	50                   	push   %eax
  801533:	68 63 2d 80 00       	push   $0x802d63
  801538:	68 eb 00 00 00       	push   $0xeb
  80153d:	68 5a 31 80 00       	push   $0x80315a
  801542:	e8 db ee ff ff       	call   800422 <_panic>
		}
		sys_yield();
  801547:	e8 18 f9 ff ff       	call   800e64 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80154c:	eb 18                	jmp    801566 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  80154e:	83 ec 0c             	sub    $0xc,%esp
  801551:	68 88 32 80 00       	push   $0x803288
  801556:	e8 a0 ef ff ff       	call   8004fb <cprintf>
	mtx->owner = sys_getenvid();}
  80155b:	e8 e5 f8 ff ff       	call   800e45 <sys_getenvid>
  801560:	89 43 08             	mov    %eax,0x8(%ebx)
  801563:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  801566:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	53                   	push   %ebx
  80156f:	83 ec 04             	sub    $0x4,%esp
  801572:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801575:	b8 00 00 00 00       	mov    $0x0,%eax
  80157a:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  80157d:	8b 43 04             	mov    0x4(%ebx),%eax
  801580:	83 38 00             	cmpl   $0x0,(%eax)
  801583:	74 33                	je     8015b8 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  801585:	83 ec 0c             	sub    $0xc,%esp
  801588:	50                   	push   %eax
  801589:	e8 0d ff ff ff       	call   80149b <queue_pop>
  80158e:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	6a 02                	push   $0x2
  801596:	50                   	push   %eax
  801597:	e8 ae f9 ff ff       	call   800f4a <sys_env_set_status>
		if (r < 0) {
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	79 15                	jns    8015b8 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8015a3:	50                   	push   %eax
  8015a4:	68 63 2d 80 00       	push   $0x802d63
  8015a9:	68 00 01 00 00       	push   $0x100
  8015ae:	68 5a 31 80 00       	push   $0x80315a
  8015b3:	e8 6a ee ff ff       	call   800422 <_panic>
		}
	}

	asm volatile("pause");
  8015b8:	f3 90                	pause  
	//sys_yield();
}
  8015ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	53                   	push   %ebx
  8015c3:	83 ec 04             	sub    $0x4,%esp
  8015c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8015c9:	e8 77 f8 ff ff       	call   800e45 <sys_getenvid>
  8015ce:	83 ec 04             	sub    $0x4,%esp
  8015d1:	6a 07                	push   $0x7
  8015d3:	53                   	push   %ebx
  8015d4:	50                   	push   %eax
  8015d5:	e8 a9 f8 ff ff       	call   800e83 <sys_page_alloc>
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	79 15                	jns    8015f6 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8015e1:	50                   	push   %eax
  8015e2:	68 03 32 80 00       	push   $0x803203
  8015e7:	68 0d 01 00 00       	push   $0x10d
  8015ec:	68 5a 31 80 00       	push   $0x80315a
  8015f1:	e8 2c ee ff ff       	call   800422 <_panic>
	}	
	mtx->locked = 0;
  8015f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8015fc:	8b 43 04             	mov    0x4(%ebx),%eax
  8015ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801605:	8b 43 04             	mov    0x4(%ebx),%eax
  801608:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80160f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801616:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801619:	c9                   	leave  
  80161a:	c3                   	ret    

0080161b <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  801621:	e8 1f f8 ff ff       	call   800e45 <sys_getenvid>
  801626:	83 ec 08             	sub    $0x8,%esp
  801629:	ff 75 08             	pushl  0x8(%ebp)
  80162c:	50                   	push   %eax
  80162d:	e8 d6 f8 ff ff       	call   800f08 <sys_page_unmap>
	if (r < 0) {
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	85 c0                	test   %eax,%eax
  801637:	79 15                	jns    80164e <mutex_destroy+0x33>
		panic("%e\n", r);
  801639:	50                   	push   %eax
  80163a:	68 63 2d 80 00       	push   $0x802d63
  80163f:	68 1a 01 00 00       	push   $0x11a
  801644:	68 5a 31 80 00       	push   $0x80315a
  801649:	e8 d4 ed ff ff       	call   800422 <_panic>
	}
}
  80164e:	c9                   	leave  
  80164f:	c3                   	ret    

00801650 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801653:	8b 45 08             	mov    0x8(%ebp),%eax
  801656:	05 00 00 00 30       	add    $0x30000000,%eax
  80165b:	c1 e8 0c             	shr    $0xc,%eax
}
  80165e:	5d                   	pop    %ebp
  80165f:	c3                   	ret    

00801660 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801663:	8b 45 08             	mov    0x8(%ebp),%eax
  801666:	05 00 00 00 30       	add    $0x30000000,%eax
  80166b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801670:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    

00801677 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80167d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801682:	89 c2                	mov    %eax,%edx
  801684:	c1 ea 16             	shr    $0x16,%edx
  801687:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80168e:	f6 c2 01             	test   $0x1,%dl
  801691:	74 11                	je     8016a4 <fd_alloc+0x2d>
  801693:	89 c2                	mov    %eax,%edx
  801695:	c1 ea 0c             	shr    $0xc,%edx
  801698:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80169f:	f6 c2 01             	test   $0x1,%dl
  8016a2:	75 09                	jne    8016ad <fd_alloc+0x36>
			*fd_store = fd;
  8016a4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8016a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ab:	eb 17                	jmp    8016c4 <fd_alloc+0x4d>
  8016ad:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016b2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016b7:	75 c9                	jne    801682 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016b9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8016bf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8016c4:	5d                   	pop    %ebp
  8016c5:	c3                   	ret    

008016c6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016cc:	83 f8 1f             	cmp    $0x1f,%eax
  8016cf:	77 36                	ja     801707 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8016d1:	c1 e0 0c             	shl    $0xc,%eax
  8016d4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016d9:	89 c2                	mov    %eax,%edx
  8016db:	c1 ea 16             	shr    $0x16,%edx
  8016de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016e5:	f6 c2 01             	test   $0x1,%dl
  8016e8:	74 24                	je     80170e <fd_lookup+0x48>
  8016ea:	89 c2                	mov    %eax,%edx
  8016ec:	c1 ea 0c             	shr    $0xc,%edx
  8016ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016f6:	f6 c2 01             	test   $0x1,%dl
  8016f9:	74 1a                	je     801715 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016fe:	89 02                	mov    %eax,(%edx)
	return 0;
  801700:	b8 00 00 00 00       	mov    $0x0,%eax
  801705:	eb 13                	jmp    80171a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801707:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80170c:	eb 0c                	jmp    80171a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80170e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801713:	eb 05                	jmp    80171a <fd_lookup+0x54>
  801715:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	83 ec 08             	sub    $0x8,%esp
  801722:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801725:	ba 24 33 80 00       	mov    $0x803324,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80172a:	eb 13                	jmp    80173f <dev_lookup+0x23>
  80172c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80172f:	39 08                	cmp    %ecx,(%eax)
  801731:	75 0c                	jne    80173f <dev_lookup+0x23>
			*dev = devtab[i];
  801733:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801736:	89 01                	mov    %eax,(%ecx)
			return 0;
  801738:	b8 00 00 00 00       	mov    $0x0,%eax
  80173d:	eb 31                	jmp    801770 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80173f:	8b 02                	mov    (%edx),%eax
  801741:	85 c0                	test   %eax,%eax
  801743:	75 e7                	jne    80172c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801745:	a1 90 77 80 00       	mov    0x807790,%eax
  80174a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801750:	83 ec 04             	sub    $0x4,%esp
  801753:	51                   	push   %ecx
  801754:	50                   	push   %eax
  801755:	68 a8 32 80 00       	push   $0x8032a8
  80175a:	e8 9c ed ff ff       	call   8004fb <cprintf>
	*dev = 0;
  80175f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801762:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801770:	c9                   	leave  
  801771:	c3                   	ret    

00801772 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	56                   	push   %esi
  801776:	53                   	push   %ebx
  801777:	83 ec 10             	sub    $0x10,%esp
  80177a:	8b 75 08             	mov    0x8(%ebp),%esi
  80177d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801780:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801783:	50                   	push   %eax
  801784:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80178a:	c1 e8 0c             	shr    $0xc,%eax
  80178d:	50                   	push   %eax
  80178e:	e8 33 ff ff ff       	call   8016c6 <fd_lookup>
  801793:	83 c4 08             	add    $0x8,%esp
  801796:	85 c0                	test   %eax,%eax
  801798:	78 05                	js     80179f <fd_close+0x2d>
	    || fd != fd2)
  80179a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80179d:	74 0c                	je     8017ab <fd_close+0x39>
		return (must_exist ? r : 0);
  80179f:	84 db                	test   %bl,%bl
  8017a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a6:	0f 44 c2             	cmove  %edx,%eax
  8017a9:	eb 41                	jmp    8017ec <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8017ab:	83 ec 08             	sub    $0x8,%esp
  8017ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b1:	50                   	push   %eax
  8017b2:	ff 36                	pushl  (%esi)
  8017b4:	e8 63 ff ff ff       	call   80171c <dev_lookup>
  8017b9:	89 c3                	mov    %eax,%ebx
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 1a                	js     8017dc <fd_close+0x6a>
		if (dev->dev_close)
  8017c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8017c8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	74 0b                	je     8017dc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8017d1:	83 ec 0c             	sub    $0xc,%esp
  8017d4:	56                   	push   %esi
  8017d5:	ff d0                	call   *%eax
  8017d7:	89 c3                	mov    %eax,%ebx
  8017d9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8017dc:	83 ec 08             	sub    $0x8,%esp
  8017df:	56                   	push   %esi
  8017e0:	6a 00                	push   $0x0
  8017e2:	e8 21 f7 ff ff       	call   800f08 <sys_page_unmap>
	return r;
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	89 d8                	mov    %ebx,%eax
}
  8017ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ef:	5b                   	pop    %ebx
  8017f0:	5e                   	pop    %esi
  8017f1:	5d                   	pop    %ebp
  8017f2:	c3                   	ret    

008017f3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fc:	50                   	push   %eax
  8017fd:	ff 75 08             	pushl  0x8(%ebp)
  801800:	e8 c1 fe ff ff       	call   8016c6 <fd_lookup>
  801805:	83 c4 08             	add    $0x8,%esp
  801808:	85 c0                	test   %eax,%eax
  80180a:	78 10                	js     80181c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80180c:	83 ec 08             	sub    $0x8,%esp
  80180f:	6a 01                	push   $0x1
  801811:	ff 75 f4             	pushl  -0xc(%ebp)
  801814:	e8 59 ff ff ff       	call   801772 <fd_close>
  801819:	83 c4 10             	add    $0x10,%esp
}
  80181c:	c9                   	leave  
  80181d:	c3                   	ret    

0080181e <close_all>:

void
close_all(void)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	53                   	push   %ebx
  801822:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801825:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80182a:	83 ec 0c             	sub    $0xc,%esp
  80182d:	53                   	push   %ebx
  80182e:	e8 c0 ff ff ff       	call   8017f3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801833:	83 c3 01             	add    $0x1,%ebx
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	83 fb 20             	cmp    $0x20,%ebx
  80183c:	75 ec                	jne    80182a <close_all+0xc>
		close(i);
}
  80183e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	57                   	push   %edi
  801847:	56                   	push   %esi
  801848:	53                   	push   %ebx
  801849:	83 ec 2c             	sub    $0x2c,%esp
  80184c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80184f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801852:	50                   	push   %eax
  801853:	ff 75 08             	pushl  0x8(%ebp)
  801856:	e8 6b fe ff ff       	call   8016c6 <fd_lookup>
  80185b:	83 c4 08             	add    $0x8,%esp
  80185e:	85 c0                	test   %eax,%eax
  801860:	0f 88 c1 00 00 00    	js     801927 <dup+0xe4>
		return r;
	close(newfdnum);
  801866:	83 ec 0c             	sub    $0xc,%esp
  801869:	56                   	push   %esi
  80186a:	e8 84 ff ff ff       	call   8017f3 <close>

	newfd = INDEX2FD(newfdnum);
  80186f:	89 f3                	mov    %esi,%ebx
  801871:	c1 e3 0c             	shl    $0xc,%ebx
  801874:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80187a:	83 c4 04             	add    $0x4,%esp
  80187d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801880:	e8 db fd ff ff       	call   801660 <fd2data>
  801885:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801887:	89 1c 24             	mov    %ebx,(%esp)
  80188a:	e8 d1 fd ff ff       	call   801660 <fd2data>
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801895:	89 f8                	mov    %edi,%eax
  801897:	c1 e8 16             	shr    $0x16,%eax
  80189a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018a1:	a8 01                	test   $0x1,%al
  8018a3:	74 37                	je     8018dc <dup+0x99>
  8018a5:	89 f8                	mov    %edi,%eax
  8018a7:	c1 e8 0c             	shr    $0xc,%eax
  8018aa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018b1:	f6 c2 01             	test   $0x1,%dl
  8018b4:	74 26                	je     8018dc <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8018b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018bd:	83 ec 0c             	sub    $0xc,%esp
  8018c0:	25 07 0e 00 00       	and    $0xe07,%eax
  8018c5:	50                   	push   %eax
  8018c6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8018c9:	6a 00                	push   $0x0
  8018cb:	57                   	push   %edi
  8018cc:	6a 00                	push   $0x0
  8018ce:	e8 f3 f5 ff ff       	call   800ec6 <sys_page_map>
  8018d3:	89 c7                	mov    %eax,%edi
  8018d5:	83 c4 20             	add    $0x20,%esp
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	78 2e                	js     80190a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018df:	89 d0                	mov    %edx,%eax
  8018e1:	c1 e8 0c             	shr    $0xc,%eax
  8018e4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018eb:	83 ec 0c             	sub    $0xc,%esp
  8018ee:	25 07 0e 00 00       	and    $0xe07,%eax
  8018f3:	50                   	push   %eax
  8018f4:	53                   	push   %ebx
  8018f5:	6a 00                	push   $0x0
  8018f7:	52                   	push   %edx
  8018f8:	6a 00                	push   $0x0
  8018fa:	e8 c7 f5 ff ff       	call   800ec6 <sys_page_map>
  8018ff:	89 c7                	mov    %eax,%edi
  801901:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801904:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801906:	85 ff                	test   %edi,%edi
  801908:	79 1d                	jns    801927 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80190a:	83 ec 08             	sub    $0x8,%esp
  80190d:	53                   	push   %ebx
  80190e:	6a 00                	push   $0x0
  801910:	e8 f3 f5 ff ff       	call   800f08 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801915:	83 c4 08             	add    $0x8,%esp
  801918:	ff 75 d4             	pushl  -0x2c(%ebp)
  80191b:	6a 00                	push   $0x0
  80191d:	e8 e6 f5 ff ff       	call   800f08 <sys_page_unmap>
	return r;
  801922:	83 c4 10             	add    $0x10,%esp
  801925:	89 f8                	mov    %edi,%eax
}
  801927:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80192a:	5b                   	pop    %ebx
  80192b:	5e                   	pop    %esi
  80192c:	5f                   	pop    %edi
  80192d:	5d                   	pop    %ebp
  80192e:	c3                   	ret    

0080192f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	53                   	push   %ebx
  801933:	83 ec 14             	sub    $0x14,%esp
  801936:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801939:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80193c:	50                   	push   %eax
  80193d:	53                   	push   %ebx
  80193e:	e8 83 fd ff ff       	call   8016c6 <fd_lookup>
  801943:	83 c4 08             	add    $0x8,%esp
  801946:	89 c2                	mov    %eax,%edx
  801948:	85 c0                	test   %eax,%eax
  80194a:	78 70                	js     8019bc <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80194c:	83 ec 08             	sub    $0x8,%esp
  80194f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801952:	50                   	push   %eax
  801953:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801956:	ff 30                	pushl  (%eax)
  801958:	e8 bf fd ff ff       	call   80171c <dev_lookup>
  80195d:	83 c4 10             	add    $0x10,%esp
  801960:	85 c0                	test   %eax,%eax
  801962:	78 4f                	js     8019b3 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801964:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801967:	8b 42 08             	mov    0x8(%edx),%eax
  80196a:	83 e0 03             	and    $0x3,%eax
  80196d:	83 f8 01             	cmp    $0x1,%eax
  801970:	75 24                	jne    801996 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801972:	a1 90 77 80 00       	mov    0x807790,%eax
  801977:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80197d:	83 ec 04             	sub    $0x4,%esp
  801980:	53                   	push   %ebx
  801981:	50                   	push   %eax
  801982:	68 e9 32 80 00       	push   $0x8032e9
  801987:	e8 6f eb ff ff       	call   8004fb <cprintf>
		return -E_INVAL;
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801994:	eb 26                	jmp    8019bc <read+0x8d>
	}
	if (!dev->dev_read)
  801996:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801999:	8b 40 08             	mov    0x8(%eax),%eax
  80199c:	85 c0                	test   %eax,%eax
  80199e:	74 17                	je     8019b7 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8019a0:	83 ec 04             	sub    $0x4,%esp
  8019a3:	ff 75 10             	pushl  0x10(%ebp)
  8019a6:	ff 75 0c             	pushl  0xc(%ebp)
  8019a9:	52                   	push   %edx
  8019aa:	ff d0                	call   *%eax
  8019ac:	89 c2                	mov    %eax,%edx
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	eb 09                	jmp    8019bc <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019b3:	89 c2                	mov    %eax,%edx
  8019b5:	eb 05                	jmp    8019bc <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8019b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8019bc:	89 d0                	mov    %edx,%eax
  8019be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	57                   	push   %edi
  8019c7:	56                   	push   %esi
  8019c8:	53                   	push   %ebx
  8019c9:	83 ec 0c             	sub    $0xc,%esp
  8019cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019cf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019d7:	eb 21                	jmp    8019fa <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019d9:	83 ec 04             	sub    $0x4,%esp
  8019dc:	89 f0                	mov    %esi,%eax
  8019de:	29 d8                	sub    %ebx,%eax
  8019e0:	50                   	push   %eax
  8019e1:	89 d8                	mov    %ebx,%eax
  8019e3:	03 45 0c             	add    0xc(%ebp),%eax
  8019e6:	50                   	push   %eax
  8019e7:	57                   	push   %edi
  8019e8:	e8 42 ff ff ff       	call   80192f <read>
		if (m < 0)
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	78 10                	js     801a04 <readn+0x41>
			return m;
		if (m == 0)
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	74 0a                	je     801a02 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019f8:	01 c3                	add    %eax,%ebx
  8019fa:	39 f3                	cmp    %esi,%ebx
  8019fc:	72 db                	jb     8019d9 <readn+0x16>
  8019fe:	89 d8                	mov    %ebx,%eax
  801a00:	eb 02                	jmp    801a04 <readn+0x41>
  801a02:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a07:	5b                   	pop    %ebx
  801a08:	5e                   	pop    %esi
  801a09:	5f                   	pop    %edi
  801a0a:	5d                   	pop    %ebp
  801a0b:	c3                   	ret    

00801a0c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	53                   	push   %ebx
  801a10:	83 ec 14             	sub    $0x14,%esp
  801a13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a16:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a19:	50                   	push   %eax
  801a1a:	53                   	push   %ebx
  801a1b:	e8 a6 fc ff ff       	call   8016c6 <fd_lookup>
  801a20:	83 c4 08             	add    $0x8,%esp
  801a23:	89 c2                	mov    %eax,%edx
  801a25:	85 c0                	test   %eax,%eax
  801a27:	78 6b                	js     801a94 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a29:	83 ec 08             	sub    $0x8,%esp
  801a2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a2f:	50                   	push   %eax
  801a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a33:	ff 30                	pushl  (%eax)
  801a35:	e8 e2 fc ff ff       	call   80171c <dev_lookup>
  801a3a:	83 c4 10             	add    $0x10,%esp
  801a3d:	85 c0                	test   %eax,%eax
  801a3f:	78 4a                	js     801a8b <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a44:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a48:	75 24                	jne    801a6e <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a4a:	a1 90 77 80 00       	mov    0x807790,%eax
  801a4f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801a55:	83 ec 04             	sub    $0x4,%esp
  801a58:	53                   	push   %ebx
  801a59:	50                   	push   %eax
  801a5a:	68 05 33 80 00       	push   $0x803305
  801a5f:	e8 97 ea ff ff       	call   8004fb <cprintf>
		return -E_INVAL;
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801a6c:	eb 26                	jmp    801a94 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a71:	8b 52 0c             	mov    0xc(%edx),%edx
  801a74:	85 d2                	test   %edx,%edx
  801a76:	74 17                	je     801a8f <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a78:	83 ec 04             	sub    $0x4,%esp
  801a7b:	ff 75 10             	pushl  0x10(%ebp)
  801a7e:	ff 75 0c             	pushl  0xc(%ebp)
  801a81:	50                   	push   %eax
  801a82:	ff d2                	call   *%edx
  801a84:	89 c2                	mov    %eax,%edx
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	eb 09                	jmp    801a94 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a8b:	89 c2                	mov    %eax,%edx
  801a8d:	eb 05                	jmp    801a94 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801a8f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801a94:	89 d0                	mov    %edx,%eax
  801a96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <seek>:

int
seek(int fdnum, off_t offset)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aa1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801aa4:	50                   	push   %eax
  801aa5:	ff 75 08             	pushl  0x8(%ebp)
  801aa8:	e8 19 fc ff ff       	call   8016c6 <fd_lookup>
  801aad:	83 c4 08             	add    $0x8,%esp
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	78 0e                	js     801ac2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801ab4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ab7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aba:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac2:	c9                   	leave  
  801ac3:	c3                   	ret    

00801ac4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	53                   	push   %ebx
  801ac8:	83 ec 14             	sub    $0x14,%esp
  801acb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ace:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ad1:	50                   	push   %eax
  801ad2:	53                   	push   %ebx
  801ad3:	e8 ee fb ff ff       	call   8016c6 <fd_lookup>
  801ad8:	83 c4 08             	add    $0x8,%esp
  801adb:	89 c2                	mov    %eax,%edx
  801add:	85 c0                	test   %eax,%eax
  801adf:	78 68                	js     801b49 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ae1:	83 ec 08             	sub    $0x8,%esp
  801ae4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae7:	50                   	push   %eax
  801ae8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aeb:	ff 30                	pushl  (%eax)
  801aed:	e8 2a fc ff ff       	call   80171c <dev_lookup>
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	85 c0                	test   %eax,%eax
  801af7:	78 47                	js     801b40 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801af9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801afc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b00:	75 24                	jne    801b26 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b02:	a1 90 77 80 00       	mov    0x807790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b07:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801b0d:	83 ec 04             	sub    $0x4,%esp
  801b10:	53                   	push   %ebx
  801b11:	50                   	push   %eax
  801b12:	68 c8 32 80 00       	push   $0x8032c8
  801b17:	e8 df e9 ff ff       	call   8004fb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801b24:	eb 23                	jmp    801b49 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801b26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b29:	8b 52 18             	mov    0x18(%edx),%edx
  801b2c:	85 d2                	test   %edx,%edx
  801b2e:	74 14                	je     801b44 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b30:	83 ec 08             	sub    $0x8,%esp
  801b33:	ff 75 0c             	pushl  0xc(%ebp)
  801b36:	50                   	push   %eax
  801b37:	ff d2                	call   *%edx
  801b39:	89 c2                	mov    %eax,%edx
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	eb 09                	jmp    801b49 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b40:	89 c2                	mov    %eax,%edx
  801b42:	eb 05                	jmp    801b49 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b44:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801b49:	89 d0                	mov    %edx,%eax
  801b4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	53                   	push   %ebx
  801b54:	83 ec 14             	sub    $0x14,%esp
  801b57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b5a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b5d:	50                   	push   %eax
  801b5e:	ff 75 08             	pushl  0x8(%ebp)
  801b61:	e8 60 fb ff ff       	call   8016c6 <fd_lookup>
  801b66:	83 c4 08             	add    $0x8,%esp
  801b69:	89 c2                	mov    %eax,%edx
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	78 58                	js     801bc7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b6f:	83 ec 08             	sub    $0x8,%esp
  801b72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b75:	50                   	push   %eax
  801b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b79:	ff 30                	pushl  (%eax)
  801b7b:	e8 9c fb ff ff       	call   80171c <dev_lookup>
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	85 c0                	test   %eax,%eax
  801b85:	78 37                	js     801bbe <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b8e:	74 32                	je     801bc2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b90:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b93:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b9a:	00 00 00 
	stat->st_isdir = 0;
  801b9d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ba4:	00 00 00 
	stat->st_dev = dev;
  801ba7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801bad:	83 ec 08             	sub    $0x8,%esp
  801bb0:	53                   	push   %ebx
  801bb1:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb4:	ff 50 14             	call   *0x14(%eax)
  801bb7:	89 c2                	mov    %eax,%edx
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	eb 09                	jmp    801bc7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bbe:	89 c2                	mov    %eax,%edx
  801bc0:	eb 05                	jmp    801bc7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801bc2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801bc7:	89 d0                	mov    %edx,%eax
  801bc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    

00801bce <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	56                   	push   %esi
  801bd2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801bd3:	83 ec 08             	sub    $0x8,%esp
  801bd6:	6a 00                	push   $0x0
  801bd8:	ff 75 08             	pushl  0x8(%ebp)
  801bdb:	e8 e3 01 00 00       	call   801dc3 <open>
  801be0:	89 c3                	mov    %eax,%ebx
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	85 c0                	test   %eax,%eax
  801be7:	78 1b                	js     801c04 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801be9:	83 ec 08             	sub    $0x8,%esp
  801bec:	ff 75 0c             	pushl  0xc(%ebp)
  801bef:	50                   	push   %eax
  801bf0:	e8 5b ff ff ff       	call   801b50 <fstat>
  801bf5:	89 c6                	mov    %eax,%esi
	close(fd);
  801bf7:	89 1c 24             	mov    %ebx,(%esp)
  801bfa:	e8 f4 fb ff ff       	call   8017f3 <close>
	return r;
  801bff:	83 c4 10             	add    $0x10,%esp
  801c02:	89 f0                	mov    %esi,%eax
}
  801c04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c07:	5b                   	pop    %ebx
  801c08:	5e                   	pop    %esi
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    

00801c0b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	56                   	push   %esi
  801c0f:	53                   	push   %ebx
  801c10:	89 c6                	mov    %eax,%esi
  801c12:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801c14:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801c1b:	75 12                	jne    801c2f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c1d:	83 ec 0c             	sub    $0xc,%esp
  801c20:	6a 01                	push   $0x1
  801c22:	e8 4e 0d 00 00       	call   802975 <ipc_find_env>
  801c27:	a3 00 60 80 00       	mov    %eax,0x806000
  801c2c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c2f:	6a 07                	push   $0x7
  801c31:	68 00 80 80 00       	push   $0x808000
  801c36:	56                   	push   %esi
  801c37:	ff 35 00 60 80 00    	pushl  0x806000
  801c3d:	e8 d1 0c 00 00       	call   802913 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c42:	83 c4 0c             	add    $0xc,%esp
  801c45:	6a 00                	push   $0x0
  801c47:	53                   	push   %ebx
  801c48:	6a 00                	push   $0x0
  801c4a:	e8 49 0c 00 00       	call   802898 <ipc_recv>
}
  801c4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c52:	5b                   	pop    %ebx
  801c53:	5e                   	pop    %esi
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    

00801c56 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5f:	8b 40 0c             	mov    0xc(%eax),%eax
  801c62:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  801c67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c6a:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c74:	b8 02 00 00 00       	mov    $0x2,%eax
  801c79:	e8 8d ff ff ff       	call   801c0b <fsipc>
}
  801c7e:	c9                   	leave  
  801c7f:	c3                   	ret    

00801c80 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c86:	8b 45 08             	mov    0x8(%ebp),%eax
  801c89:	8b 40 0c             	mov    0xc(%eax),%eax
  801c8c:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  801c91:	ba 00 00 00 00       	mov    $0x0,%edx
  801c96:	b8 06 00 00 00       	mov    $0x6,%eax
  801c9b:	e8 6b ff ff ff       	call   801c0b <fsipc>
}
  801ca0:	c9                   	leave  
  801ca1:	c3                   	ret    

00801ca2 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	53                   	push   %ebx
  801ca6:	83 ec 04             	sub    $0x4,%esp
  801ca9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801cac:	8b 45 08             	mov    0x8(%ebp),%eax
  801caf:	8b 40 0c             	mov    0xc(%eax),%eax
  801cb2:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801cb7:	ba 00 00 00 00       	mov    $0x0,%edx
  801cbc:	b8 05 00 00 00       	mov    $0x5,%eax
  801cc1:	e8 45 ff ff ff       	call   801c0b <fsipc>
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	78 2c                	js     801cf6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801cca:	83 ec 08             	sub    $0x8,%esp
  801ccd:	68 00 80 80 00       	push   $0x808000
  801cd2:	53                   	push   %ebx
  801cd3:	e8 a8 ed ff ff       	call   800a80 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801cd8:	a1 80 80 80 00       	mov    0x808080,%eax
  801cdd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ce3:	a1 84 80 80 00       	mov    0x808084,%eax
  801ce8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801cee:	83 c4 10             	add    $0x10,%esp
  801cf1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	83 ec 0c             	sub    $0xc,%esp
  801d01:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d04:	8b 55 08             	mov    0x8(%ebp),%edx
  801d07:	8b 52 0c             	mov    0xc(%edx),%edx
  801d0a:	89 15 00 80 80 00    	mov    %edx,0x808000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801d10:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801d15:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801d1a:	0f 47 c2             	cmova  %edx,%eax
  801d1d:	a3 04 80 80 00       	mov    %eax,0x808004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801d22:	50                   	push   %eax
  801d23:	ff 75 0c             	pushl  0xc(%ebp)
  801d26:	68 08 80 80 00       	push   $0x808008
  801d2b:	e8 e2 ee ff ff       	call   800c12 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801d30:	ba 00 00 00 00       	mov    $0x0,%edx
  801d35:	b8 04 00 00 00       	mov    $0x4,%eax
  801d3a:	e8 cc fe ff ff       	call   801c0b <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    

00801d41 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	56                   	push   %esi
  801d45:	53                   	push   %ebx
  801d46:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d49:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d4f:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  801d54:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d5f:	b8 03 00 00 00       	mov    $0x3,%eax
  801d64:	e8 a2 fe ff ff       	call   801c0b <fsipc>
  801d69:	89 c3                	mov    %eax,%ebx
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	78 4b                	js     801dba <devfile_read+0x79>
		return r;
	assert(r <= n);
  801d6f:	39 c6                	cmp    %eax,%esi
  801d71:	73 16                	jae    801d89 <devfile_read+0x48>
  801d73:	68 34 33 80 00       	push   $0x803334
  801d78:	68 3b 33 80 00       	push   $0x80333b
  801d7d:	6a 7c                	push   $0x7c
  801d7f:	68 50 33 80 00       	push   $0x803350
  801d84:	e8 99 e6 ff ff       	call   800422 <_panic>
	assert(r <= PGSIZE);
  801d89:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d8e:	7e 16                	jle    801da6 <devfile_read+0x65>
  801d90:	68 5b 33 80 00       	push   $0x80335b
  801d95:	68 3b 33 80 00       	push   $0x80333b
  801d9a:	6a 7d                	push   $0x7d
  801d9c:	68 50 33 80 00       	push   $0x803350
  801da1:	e8 7c e6 ff ff       	call   800422 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801da6:	83 ec 04             	sub    $0x4,%esp
  801da9:	50                   	push   %eax
  801daa:	68 00 80 80 00       	push   $0x808000
  801daf:	ff 75 0c             	pushl  0xc(%ebp)
  801db2:	e8 5b ee ff ff       	call   800c12 <memmove>
	return r;
  801db7:	83 c4 10             	add    $0x10,%esp
}
  801dba:	89 d8                	mov    %ebx,%eax
  801dbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dbf:	5b                   	pop    %ebx
  801dc0:	5e                   	pop    %esi
  801dc1:	5d                   	pop    %ebp
  801dc2:	c3                   	ret    

00801dc3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	53                   	push   %ebx
  801dc7:	83 ec 20             	sub    $0x20,%esp
  801dca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801dcd:	53                   	push   %ebx
  801dce:	e8 74 ec ff ff       	call   800a47 <strlen>
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ddb:	7f 67                	jg     801e44 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ddd:	83 ec 0c             	sub    $0xc,%esp
  801de0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de3:	50                   	push   %eax
  801de4:	e8 8e f8 ff ff       	call   801677 <fd_alloc>
  801de9:	83 c4 10             	add    $0x10,%esp
		return r;
  801dec:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801dee:	85 c0                	test   %eax,%eax
  801df0:	78 57                	js     801e49 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801df2:	83 ec 08             	sub    $0x8,%esp
  801df5:	53                   	push   %ebx
  801df6:	68 00 80 80 00       	push   $0x808000
  801dfb:	e8 80 ec ff ff       	call   800a80 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e03:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e08:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e0b:	b8 01 00 00 00       	mov    $0x1,%eax
  801e10:	e8 f6 fd ff ff       	call   801c0b <fsipc>
  801e15:	89 c3                	mov    %eax,%ebx
  801e17:	83 c4 10             	add    $0x10,%esp
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	79 14                	jns    801e32 <open+0x6f>
		fd_close(fd, 0);
  801e1e:	83 ec 08             	sub    $0x8,%esp
  801e21:	6a 00                	push   $0x0
  801e23:	ff 75 f4             	pushl  -0xc(%ebp)
  801e26:	e8 47 f9 ff ff       	call   801772 <fd_close>
		return r;
  801e2b:	83 c4 10             	add    $0x10,%esp
  801e2e:	89 da                	mov    %ebx,%edx
  801e30:	eb 17                	jmp    801e49 <open+0x86>
	}

	return fd2num(fd);
  801e32:	83 ec 0c             	sub    $0xc,%esp
  801e35:	ff 75 f4             	pushl  -0xc(%ebp)
  801e38:	e8 13 f8 ff ff       	call   801650 <fd2num>
  801e3d:	89 c2                	mov    %eax,%edx
  801e3f:	83 c4 10             	add    $0x10,%esp
  801e42:	eb 05                	jmp    801e49 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801e44:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801e49:	89 d0                	mov    %edx,%eax
  801e4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e4e:	c9                   	leave  
  801e4f:	c3                   	ret    

00801e50 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e56:	ba 00 00 00 00       	mov    $0x0,%edx
  801e5b:	b8 08 00 00 00       	mov    $0x8,%eax
  801e60:	e8 a6 fd ff ff       	call   801c0b <fsipc>
}
  801e65:	c9                   	leave  
  801e66:	c3                   	ret    

00801e67 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	57                   	push   %edi
  801e6b:	56                   	push   %esi
  801e6c:	53                   	push   %ebx
  801e6d:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801e73:	6a 00                	push   $0x0
  801e75:	ff 75 08             	pushl  0x8(%ebp)
  801e78:	e8 46 ff ff ff       	call   801dc3 <open>
  801e7d:	89 c7                	mov    %eax,%edi
  801e7f:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801e85:	83 c4 10             	add    $0x10,%esp
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	0f 88 8c 04 00 00    	js     80231c <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801e90:	83 ec 04             	sub    $0x4,%esp
  801e93:	68 00 02 00 00       	push   $0x200
  801e98:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801e9e:	50                   	push   %eax
  801e9f:	57                   	push   %edi
  801ea0:	e8 1e fb ff ff       	call   8019c3 <readn>
  801ea5:	83 c4 10             	add    $0x10,%esp
  801ea8:	3d 00 02 00 00       	cmp    $0x200,%eax
  801ead:	75 0c                	jne    801ebb <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801eaf:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801eb6:	45 4c 46 
  801eb9:	74 33                	je     801eee <spawn+0x87>
		close(fd);
  801ebb:	83 ec 0c             	sub    $0xc,%esp
  801ebe:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ec4:	e8 2a f9 ff ff       	call   8017f3 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801ec9:	83 c4 0c             	add    $0xc,%esp
  801ecc:	68 7f 45 4c 46       	push   $0x464c457f
  801ed1:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801ed7:	68 67 33 80 00       	push   $0x803367
  801edc:	e8 1a e6 ff ff       	call   8004fb <cprintf>
		return -E_NOT_EXEC;
  801ee1:	83 c4 10             	add    $0x10,%esp
  801ee4:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801ee9:	e9 e1 04 00 00       	jmp    8023cf <spawn+0x568>
  801eee:	b8 07 00 00 00       	mov    $0x7,%eax
  801ef3:	cd 30                	int    $0x30
  801ef5:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801efb:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801f01:	85 c0                	test   %eax,%eax
  801f03:	0f 88 1e 04 00 00    	js     802327 <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801f09:	89 c6                	mov    %eax,%esi
  801f0b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801f11:	69 f6 d8 00 00 00    	imul   $0xd8,%esi,%esi
  801f17:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801f1d:	81 c6 59 00 c0 ee    	add    $0xeec00059,%esi
  801f23:	b9 11 00 00 00       	mov    $0x11,%ecx
  801f28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801f2a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801f30:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801f36:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801f3b:	be 00 00 00 00       	mov    $0x0,%esi
  801f40:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f43:	eb 13                	jmp    801f58 <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801f45:	83 ec 0c             	sub    $0xc,%esp
  801f48:	50                   	push   %eax
  801f49:	e8 f9 ea ff ff       	call   800a47 <strlen>
  801f4e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801f52:	83 c3 01             	add    $0x1,%ebx
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801f5f:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801f62:	85 c0                	test   %eax,%eax
  801f64:	75 df                	jne    801f45 <spawn+0xde>
  801f66:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801f6c:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801f72:	bf 00 10 40 00       	mov    $0x401000,%edi
  801f77:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801f79:	89 fa                	mov    %edi,%edx
  801f7b:	83 e2 fc             	and    $0xfffffffc,%edx
  801f7e:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801f85:	29 c2                	sub    %eax,%edx
  801f87:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801f8d:	8d 42 f8             	lea    -0x8(%edx),%eax
  801f90:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801f95:	0f 86 a2 03 00 00    	jbe    80233d <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f9b:	83 ec 04             	sub    $0x4,%esp
  801f9e:	6a 07                	push   $0x7
  801fa0:	68 00 00 40 00       	push   $0x400000
  801fa5:	6a 00                	push   $0x0
  801fa7:	e8 d7 ee ff ff       	call   800e83 <sys_page_alloc>
  801fac:	83 c4 10             	add    $0x10,%esp
  801faf:	85 c0                	test   %eax,%eax
  801fb1:	0f 88 90 03 00 00    	js     802347 <spawn+0x4e0>
  801fb7:	be 00 00 00 00       	mov    $0x0,%esi
  801fbc:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801fc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801fc5:	eb 30                	jmp    801ff7 <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801fc7:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801fcd:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801fd3:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801fd6:	83 ec 08             	sub    $0x8,%esp
  801fd9:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801fdc:	57                   	push   %edi
  801fdd:	e8 9e ea ff ff       	call   800a80 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801fe2:	83 c4 04             	add    $0x4,%esp
  801fe5:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801fe8:	e8 5a ea ff ff       	call   800a47 <strlen>
  801fed:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801ff1:	83 c6 01             	add    $0x1,%esi
  801ff4:	83 c4 10             	add    $0x10,%esp
  801ff7:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801ffd:	7f c8                	jg     801fc7 <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801fff:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802005:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80200b:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802012:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802018:	74 19                	je     802033 <spawn+0x1cc>
  80201a:	68 f4 33 80 00       	push   $0x8033f4
  80201f:	68 3b 33 80 00       	push   $0x80333b
  802024:	68 f2 00 00 00       	push   $0xf2
  802029:	68 81 33 80 00       	push   $0x803381
  80202e:	e8 ef e3 ff ff       	call   800422 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802033:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  802039:	89 f8                	mov    %edi,%eax
  80203b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802040:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  802043:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802049:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80204c:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  802052:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802058:	83 ec 0c             	sub    $0xc,%esp
  80205b:	6a 07                	push   $0x7
  80205d:	68 00 d0 bf ee       	push   $0xeebfd000
  802062:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802068:	68 00 00 40 00       	push   $0x400000
  80206d:	6a 00                	push   $0x0
  80206f:	e8 52 ee ff ff       	call   800ec6 <sys_page_map>
  802074:	89 c3                	mov    %eax,%ebx
  802076:	83 c4 20             	add    $0x20,%esp
  802079:	85 c0                	test   %eax,%eax
  80207b:	0f 88 3c 03 00 00    	js     8023bd <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802081:	83 ec 08             	sub    $0x8,%esp
  802084:	68 00 00 40 00       	push   $0x400000
  802089:	6a 00                	push   $0x0
  80208b:	e8 78 ee ff ff       	call   800f08 <sys_page_unmap>
  802090:	89 c3                	mov    %eax,%ebx
  802092:	83 c4 10             	add    $0x10,%esp
  802095:	85 c0                	test   %eax,%eax
  802097:	0f 88 20 03 00 00    	js     8023bd <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80209d:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8020a3:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8020aa:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8020b0:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8020b7:	00 00 00 
  8020ba:	e9 88 01 00 00       	jmp    802247 <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  8020bf:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8020c5:	83 38 01             	cmpl   $0x1,(%eax)
  8020c8:	0f 85 6b 01 00 00    	jne    802239 <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8020ce:	89 c2                	mov    %eax,%edx
  8020d0:	8b 40 18             	mov    0x18(%eax),%eax
  8020d3:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8020d9:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8020dc:	83 f8 01             	cmp    $0x1,%eax
  8020df:	19 c0                	sbb    %eax,%eax
  8020e1:	83 e0 fe             	and    $0xfffffffe,%eax
  8020e4:	83 c0 07             	add    $0x7,%eax
  8020e7:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8020ed:	89 d0                	mov    %edx,%eax
  8020ef:	8b 7a 04             	mov    0x4(%edx),%edi
  8020f2:	89 f9                	mov    %edi,%ecx
  8020f4:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8020fa:	8b 7a 10             	mov    0x10(%edx),%edi
  8020fd:	8b 52 14             	mov    0x14(%edx),%edx
  802100:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  802106:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802109:	89 f0                	mov    %esi,%eax
  80210b:	25 ff 0f 00 00       	and    $0xfff,%eax
  802110:	74 14                	je     802126 <spawn+0x2bf>
		va -= i;
  802112:	29 c6                	sub    %eax,%esi
		memsz += i;
  802114:	01 c2                	add    %eax,%edx
  802116:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  80211c:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80211e:	29 c1                	sub    %eax,%ecx
  802120:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802126:	bb 00 00 00 00       	mov    $0x0,%ebx
  80212b:	e9 f7 00 00 00       	jmp    802227 <spawn+0x3c0>
		if (i >= filesz) {
  802130:	39 fb                	cmp    %edi,%ebx
  802132:	72 27                	jb     80215b <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802134:	83 ec 04             	sub    $0x4,%esp
  802137:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80213d:	56                   	push   %esi
  80213e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802144:	e8 3a ed ff ff       	call   800e83 <sys_page_alloc>
  802149:	83 c4 10             	add    $0x10,%esp
  80214c:	85 c0                	test   %eax,%eax
  80214e:	0f 89 c7 00 00 00    	jns    80221b <spawn+0x3b4>
  802154:	89 c3                	mov    %eax,%ebx
  802156:	e9 fd 01 00 00       	jmp    802358 <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80215b:	83 ec 04             	sub    $0x4,%esp
  80215e:	6a 07                	push   $0x7
  802160:	68 00 00 40 00       	push   $0x400000
  802165:	6a 00                	push   $0x0
  802167:	e8 17 ed ff ff       	call   800e83 <sys_page_alloc>
  80216c:	83 c4 10             	add    $0x10,%esp
  80216f:	85 c0                	test   %eax,%eax
  802171:	0f 88 d7 01 00 00    	js     80234e <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802177:	83 ec 08             	sub    $0x8,%esp
  80217a:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802180:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802186:	50                   	push   %eax
  802187:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80218d:	e8 09 f9 ff ff       	call   801a9b <seek>
  802192:	83 c4 10             	add    $0x10,%esp
  802195:	85 c0                	test   %eax,%eax
  802197:	0f 88 b5 01 00 00    	js     802352 <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80219d:	83 ec 04             	sub    $0x4,%esp
  8021a0:	89 f8                	mov    %edi,%eax
  8021a2:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8021a8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8021ad:	ba 00 10 00 00       	mov    $0x1000,%edx
  8021b2:	0f 47 c2             	cmova  %edx,%eax
  8021b5:	50                   	push   %eax
  8021b6:	68 00 00 40 00       	push   $0x400000
  8021bb:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8021c1:	e8 fd f7 ff ff       	call   8019c3 <readn>
  8021c6:	83 c4 10             	add    $0x10,%esp
  8021c9:	85 c0                	test   %eax,%eax
  8021cb:	0f 88 85 01 00 00    	js     802356 <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8021d1:	83 ec 0c             	sub    $0xc,%esp
  8021d4:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8021da:	56                   	push   %esi
  8021db:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8021e1:	68 00 00 40 00       	push   $0x400000
  8021e6:	6a 00                	push   $0x0
  8021e8:	e8 d9 ec ff ff       	call   800ec6 <sys_page_map>
  8021ed:	83 c4 20             	add    $0x20,%esp
  8021f0:	85 c0                	test   %eax,%eax
  8021f2:	79 15                	jns    802209 <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  8021f4:	50                   	push   %eax
  8021f5:	68 8d 33 80 00       	push   $0x80338d
  8021fa:	68 25 01 00 00       	push   $0x125
  8021ff:	68 81 33 80 00       	push   $0x803381
  802204:	e8 19 e2 ff ff       	call   800422 <_panic>
			sys_page_unmap(0, UTEMP);
  802209:	83 ec 08             	sub    $0x8,%esp
  80220c:	68 00 00 40 00       	push   $0x400000
  802211:	6a 00                	push   $0x0
  802213:	e8 f0 ec ff ff       	call   800f08 <sys_page_unmap>
  802218:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80221b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802221:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802227:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80222d:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  802233:	0f 82 f7 fe ff ff    	jb     802130 <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802239:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802240:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802247:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80224e:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802254:	0f 8c 65 fe ff ff    	jl     8020bf <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80225a:	83 ec 0c             	sub    $0xc,%esp
  80225d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802263:	e8 8b f5 ff ff       	call   8017f3 <close>
  802268:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  80226b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802270:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  802276:	89 d8                	mov    %ebx,%eax
  802278:	c1 e8 16             	shr    $0x16,%eax
  80227b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802282:	a8 01                	test   $0x1,%al
  802284:	74 42                	je     8022c8 <spawn+0x461>
  802286:	89 d8                	mov    %ebx,%eax
  802288:	c1 e8 0c             	shr    $0xc,%eax
  80228b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802292:	f6 c2 01             	test   $0x1,%dl
  802295:	74 31                	je     8022c8 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  802297:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  80229e:	f6 c6 04             	test   $0x4,%dh
  8022a1:	74 25                	je     8022c8 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  8022a3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8022aa:	83 ec 0c             	sub    $0xc,%esp
  8022ad:	25 07 0e 00 00       	and    $0xe07,%eax
  8022b2:	50                   	push   %eax
  8022b3:	53                   	push   %ebx
  8022b4:	56                   	push   %esi
  8022b5:	53                   	push   %ebx
  8022b6:	6a 00                	push   $0x0
  8022b8:	e8 09 ec ff ff       	call   800ec6 <sys_page_map>
			if (r < 0) {
  8022bd:	83 c4 20             	add    $0x20,%esp
  8022c0:	85 c0                	test   %eax,%eax
  8022c2:	0f 88 b1 00 00 00    	js     802379 <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  8022c8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8022ce:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8022d4:	75 a0                	jne    802276 <spawn+0x40f>
  8022d6:	e9 b3 00 00 00       	jmp    80238e <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8022db:	50                   	push   %eax
  8022dc:	68 aa 33 80 00       	push   $0x8033aa
  8022e1:	68 86 00 00 00       	push   $0x86
  8022e6:	68 81 33 80 00       	push   $0x803381
  8022eb:	e8 32 e1 ff ff       	call   800422 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8022f0:	83 ec 08             	sub    $0x8,%esp
  8022f3:	6a 02                	push   $0x2
  8022f5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8022fb:	e8 4a ec ff ff       	call   800f4a <sys_env_set_status>
  802300:	83 c4 10             	add    $0x10,%esp
  802303:	85 c0                	test   %eax,%eax
  802305:	79 2b                	jns    802332 <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  802307:	50                   	push   %eax
  802308:	68 c4 33 80 00       	push   $0x8033c4
  80230d:	68 89 00 00 00       	push   $0x89
  802312:	68 81 33 80 00       	push   $0x803381
  802317:	e8 06 e1 ff ff       	call   800422 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80231c:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802322:	e9 a8 00 00 00       	jmp    8023cf <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802327:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80232d:	e9 9d 00 00 00       	jmp    8023cf <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802332:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802338:	e9 92 00 00 00       	jmp    8023cf <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  80233d:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802342:	e9 88 00 00 00       	jmp    8023cf <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802347:	89 c3                	mov    %eax,%ebx
  802349:	e9 81 00 00 00       	jmp    8023cf <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80234e:	89 c3                	mov    %eax,%ebx
  802350:	eb 06                	jmp    802358 <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802352:	89 c3                	mov    %eax,%ebx
  802354:	eb 02                	jmp    802358 <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802356:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802358:	83 ec 0c             	sub    $0xc,%esp
  80235b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802361:	e8 9e ea ff ff       	call   800e04 <sys_env_destroy>
	close(fd);
  802366:	83 c4 04             	add    $0x4,%esp
  802369:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80236f:	e8 7f f4 ff ff       	call   8017f3 <close>
	return r;
  802374:	83 c4 10             	add    $0x10,%esp
  802377:	eb 56                	jmp    8023cf <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802379:	50                   	push   %eax
  80237a:	68 db 33 80 00       	push   $0x8033db
  80237f:	68 82 00 00 00       	push   $0x82
  802384:	68 81 33 80 00       	push   $0x803381
  802389:	e8 94 e0 ff ff       	call   800422 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  80238e:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802395:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802398:	83 ec 08             	sub    $0x8,%esp
  80239b:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8023a1:	50                   	push   %eax
  8023a2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8023a8:	e8 df eb ff ff       	call   800f8c <sys_env_set_trapframe>
  8023ad:	83 c4 10             	add    $0x10,%esp
  8023b0:	85 c0                	test   %eax,%eax
  8023b2:	0f 89 38 ff ff ff    	jns    8022f0 <spawn+0x489>
  8023b8:	e9 1e ff ff ff       	jmp    8022db <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8023bd:	83 ec 08             	sub    $0x8,%esp
  8023c0:	68 00 00 40 00       	push   $0x400000
  8023c5:	6a 00                	push   $0x0
  8023c7:	e8 3c eb ff ff       	call   800f08 <sys_page_unmap>
  8023cc:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8023cf:	89 d8                	mov    %ebx,%eax
  8023d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023d4:	5b                   	pop    %ebx
  8023d5:	5e                   	pop    %esi
  8023d6:	5f                   	pop    %edi
  8023d7:	5d                   	pop    %ebp
  8023d8:	c3                   	ret    

008023d9 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8023d9:	55                   	push   %ebp
  8023da:	89 e5                	mov    %esp,%ebp
  8023dc:	56                   	push   %esi
  8023dd:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8023de:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8023e1:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8023e6:	eb 03                	jmp    8023eb <spawnl+0x12>
		argc++;
  8023e8:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8023eb:	83 c2 04             	add    $0x4,%edx
  8023ee:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8023f2:	75 f4                	jne    8023e8 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8023f4:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8023fb:	83 e2 f0             	and    $0xfffffff0,%edx
  8023fe:	29 d4                	sub    %edx,%esp
  802400:	8d 54 24 03          	lea    0x3(%esp),%edx
  802404:	c1 ea 02             	shr    $0x2,%edx
  802407:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  80240e:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802410:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802413:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  80241a:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802421:	00 
  802422:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802424:	b8 00 00 00 00       	mov    $0x0,%eax
  802429:	eb 0a                	jmp    802435 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  80242b:	83 c0 01             	add    $0x1,%eax
  80242e:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802432:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802435:	39 d0                	cmp    %edx,%eax
  802437:	75 f2                	jne    80242b <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802439:	83 ec 08             	sub    $0x8,%esp
  80243c:	56                   	push   %esi
  80243d:	ff 75 08             	pushl  0x8(%ebp)
  802440:	e8 22 fa ff ff       	call   801e67 <spawn>
}
  802445:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802448:	5b                   	pop    %ebx
  802449:	5e                   	pop    %esi
  80244a:	5d                   	pop    %ebp
  80244b:	c3                   	ret    

0080244c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80244c:	55                   	push   %ebp
  80244d:	89 e5                	mov    %esp,%ebp
  80244f:	56                   	push   %esi
  802450:	53                   	push   %ebx
  802451:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802454:	83 ec 0c             	sub    $0xc,%esp
  802457:	ff 75 08             	pushl  0x8(%ebp)
  80245a:	e8 01 f2 ff ff       	call   801660 <fd2data>
  80245f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802461:	83 c4 08             	add    $0x8,%esp
  802464:	68 1c 34 80 00       	push   $0x80341c
  802469:	53                   	push   %ebx
  80246a:	e8 11 e6 ff ff       	call   800a80 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80246f:	8b 46 04             	mov    0x4(%esi),%eax
  802472:	2b 06                	sub    (%esi),%eax
  802474:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80247a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802481:	00 00 00 
	stat->st_dev = &devpipe;
  802484:	c7 83 88 00 00 00 ac 	movl   $0x8057ac,0x88(%ebx)
  80248b:	57 80 00 
	return 0;
}
  80248e:	b8 00 00 00 00       	mov    $0x0,%eax
  802493:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802496:	5b                   	pop    %ebx
  802497:	5e                   	pop    %esi
  802498:	5d                   	pop    %ebp
  802499:	c3                   	ret    

0080249a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80249a:	55                   	push   %ebp
  80249b:	89 e5                	mov    %esp,%ebp
  80249d:	53                   	push   %ebx
  80249e:	83 ec 0c             	sub    $0xc,%esp
  8024a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8024a4:	53                   	push   %ebx
  8024a5:	6a 00                	push   $0x0
  8024a7:	e8 5c ea ff ff       	call   800f08 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8024ac:	89 1c 24             	mov    %ebx,(%esp)
  8024af:	e8 ac f1 ff ff       	call   801660 <fd2data>
  8024b4:	83 c4 08             	add    $0x8,%esp
  8024b7:	50                   	push   %eax
  8024b8:	6a 00                	push   $0x0
  8024ba:	e8 49 ea ff ff       	call   800f08 <sys_page_unmap>
}
  8024bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024c2:	c9                   	leave  
  8024c3:	c3                   	ret    

008024c4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8024c4:	55                   	push   %ebp
  8024c5:	89 e5                	mov    %esp,%ebp
  8024c7:	57                   	push   %edi
  8024c8:	56                   	push   %esi
  8024c9:	53                   	push   %ebx
  8024ca:	83 ec 1c             	sub    $0x1c,%esp
  8024cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8024d0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8024d2:	a1 90 77 80 00       	mov    0x807790,%eax
  8024d7:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8024dd:	83 ec 0c             	sub    $0xc,%esp
  8024e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8024e3:	e8 d2 04 00 00       	call   8029ba <pageref>
  8024e8:	89 c3                	mov    %eax,%ebx
  8024ea:	89 3c 24             	mov    %edi,(%esp)
  8024ed:	e8 c8 04 00 00       	call   8029ba <pageref>
  8024f2:	83 c4 10             	add    $0x10,%esp
  8024f5:	39 c3                	cmp    %eax,%ebx
  8024f7:	0f 94 c1             	sete   %cl
  8024fa:	0f b6 c9             	movzbl %cl,%ecx
  8024fd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802500:	8b 15 90 77 80 00    	mov    0x807790,%edx
  802506:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  80250c:	39 ce                	cmp    %ecx,%esi
  80250e:	74 1e                	je     80252e <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  802510:	39 c3                	cmp    %eax,%ebx
  802512:	75 be                	jne    8024d2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802514:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  80251a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80251d:	50                   	push   %eax
  80251e:	56                   	push   %esi
  80251f:	68 23 34 80 00       	push   $0x803423
  802524:	e8 d2 df ff ff       	call   8004fb <cprintf>
  802529:	83 c4 10             	add    $0x10,%esp
  80252c:	eb a4                	jmp    8024d2 <_pipeisclosed+0xe>
	}
}
  80252e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802531:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802534:	5b                   	pop    %ebx
  802535:	5e                   	pop    %esi
  802536:	5f                   	pop    %edi
  802537:	5d                   	pop    %ebp
  802538:	c3                   	ret    

00802539 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802539:	55                   	push   %ebp
  80253a:	89 e5                	mov    %esp,%ebp
  80253c:	57                   	push   %edi
  80253d:	56                   	push   %esi
  80253e:	53                   	push   %ebx
  80253f:	83 ec 28             	sub    $0x28,%esp
  802542:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802545:	56                   	push   %esi
  802546:	e8 15 f1 ff ff       	call   801660 <fd2data>
  80254b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80254d:	83 c4 10             	add    $0x10,%esp
  802550:	bf 00 00 00 00       	mov    $0x0,%edi
  802555:	eb 4b                	jmp    8025a2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802557:	89 da                	mov    %ebx,%edx
  802559:	89 f0                	mov    %esi,%eax
  80255b:	e8 64 ff ff ff       	call   8024c4 <_pipeisclosed>
  802560:	85 c0                	test   %eax,%eax
  802562:	75 48                	jne    8025ac <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802564:	e8 fb e8 ff ff       	call   800e64 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802569:	8b 43 04             	mov    0x4(%ebx),%eax
  80256c:	8b 0b                	mov    (%ebx),%ecx
  80256e:	8d 51 20             	lea    0x20(%ecx),%edx
  802571:	39 d0                	cmp    %edx,%eax
  802573:	73 e2                	jae    802557 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802575:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802578:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80257c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80257f:	89 c2                	mov    %eax,%edx
  802581:	c1 fa 1f             	sar    $0x1f,%edx
  802584:	89 d1                	mov    %edx,%ecx
  802586:	c1 e9 1b             	shr    $0x1b,%ecx
  802589:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80258c:	83 e2 1f             	and    $0x1f,%edx
  80258f:	29 ca                	sub    %ecx,%edx
  802591:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802595:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802599:	83 c0 01             	add    $0x1,%eax
  80259c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80259f:	83 c7 01             	add    $0x1,%edi
  8025a2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8025a5:	75 c2                	jne    802569 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8025a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8025aa:	eb 05                	jmp    8025b1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8025ac:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8025b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025b4:	5b                   	pop    %ebx
  8025b5:	5e                   	pop    %esi
  8025b6:	5f                   	pop    %edi
  8025b7:	5d                   	pop    %ebp
  8025b8:	c3                   	ret    

008025b9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025b9:	55                   	push   %ebp
  8025ba:	89 e5                	mov    %esp,%ebp
  8025bc:	57                   	push   %edi
  8025bd:	56                   	push   %esi
  8025be:	53                   	push   %ebx
  8025bf:	83 ec 18             	sub    $0x18,%esp
  8025c2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8025c5:	57                   	push   %edi
  8025c6:	e8 95 f0 ff ff       	call   801660 <fd2data>
  8025cb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025cd:	83 c4 10             	add    $0x10,%esp
  8025d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025d5:	eb 3d                	jmp    802614 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8025d7:	85 db                	test   %ebx,%ebx
  8025d9:	74 04                	je     8025df <devpipe_read+0x26>
				return i;
  8025db:	89 d8                	mov    %ebx,%eax
  8025dd:	eb 44                	jmp    802623 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8025df:	89 f2                	mov    %esi,%edx
  8025e1:	89 f8                	mov    %edi,%eax
  8025e3:	e8 dc fe ff ff       	call   8024c4 <_pipeisclosed>
  8025e8:	85 c0                	test   %eax,%eax
  8025ea:	75 32                	jne    80261e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8025ec:	e8 73 e8 ff ff       	call   800e64 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8025f1:	8b 06                	mov    (%esi),%eax
  8025f3:	3b 46 04             	cmp    0x4(%esi),%eax
  8025f6:	74 df                	je     8025d7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8025f8:	99                   	cltd   
  8025f9:	c1 ea 1b             	shr    $0x1b,%edx
  8025fc:	01 d0                	add    %edx,%eax
  8025fe:	83 e0 1f             	and    $0x1f,%eax
  802601:	29 d0                	sub    %edx,%eax
  802603:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802608:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80260b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80260e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802611:	83 c3 01             	add    $0x1,%ebx
  802614:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802617:	75 d8                	jne    8025f1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802619:	8b 45 10             	mov    0x10(%ebp),%eax
  80261c:	eb 05                	jmp    802623 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80261e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802626:	5b                   	pop    %ebx
  802627:	5e                   	pop    %esi
  802628:	5f                   	pop    %edi
  802629:	5d                   	pop    %ebp
  80262a:	c3                   	ret    

0080262b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80262b:	55                   	push   %ebp
  80262c:	89 e5                	mov    %esp,%ebp
  80262e:	56                   	push   %esi
  80262f:	53                   	push   %ebx
  802630:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802633:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802636:	50                   	push   %eax
  802637:	e8 3b f0 ff ff       	call   801677 <fd_alloc>
  80263c:	83 c4 10             	add    $0x10,%esp
  80263f:	89 c2                	mov    %eax,%edx
  802641:	85 c0                	test   %eax,%eax
  802643:	0f 88 2c 01 00 00    	js     802775 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802649:	83 ec 04             	sub    $0x4,%esp
  80264c:	68 07 04 00 00       	push   $0x407
  802651:	ff 75 f4             	pushl  -0xc(%ebp)
  802654:	6a 00                	push   $0x0
  802656:	e8 28 e8 ff ff       	call   800e83 <sys_page_alloc>
  80265b:	83 c4 10             	add    $0x10,%esp
  80265e:	89 c2                	mov    %eax,%edx
  802660:	85 c0                	test   %eax,%eax
  802662:	0f 88 0d 01 00 00    	js     802775 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802668:	83 ec 0c             	sub    $0xc,%esp
  80266b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80266e:	50                   	push   %eax
  80266f:	e8 03 f0 ff ff       	call   801677 <fd_alloc>
  802674:	89 c3                	mov    %eax,%ebx
  802676:	83 c4 10             	add    $0x10,%esp
  802679:	85 c0                	test   %eax,%eax
  80267b:	0f 88 e2 00 00 00    	js     802763 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802681:	83 ec 04             	sub    $0x4,%esp
  802684:	68 07 04 00 00       	push   $0x407
  802689:	ff 75 f0             	pushl  -0x10(%ebp)
  80268c:	6a 00                	push   $0x0
  80268e:	e8 f0 e7 ff ff       	call   800e83 <sys_page_alloc>
  802693:	89 c3                	mov    %eax,%ebx
  802695:	83 c4 10             	add    $0x10,%esp
  802698:	85 c0                	test   %eax,%eax
  80269a:	0f 88 c3 00 00 00    	js     802763 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8026a0:	83 ec 0c             	sub    $0xc,%esp
  8026a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8026a6:	e8 b5 ef ff ff       	call   801660 <fd2data>
  8026ab:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026ad:	83 c4 0c             	add    $0xc,%esp
  8026b0:	68 07 04 00 00       	push   $0x407
  8026b5:	50                   	push   %eax
  8026b6:	6a 00                	push   $0x0
  8026b8:	e8 c6 e7 ff ff       	call   800e83 <sys_page_alloc>
  8026bd:	89 c3                	mov    %eax,%ebx
  8026bf:	83 c4 10             	add    $0x10,%esp
  8026c2:	85 c0                	test   %eax,%eax
  8026c4:	0f 88 89 00 00 00    	js     802753 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026ca:	83 ec 0c             	sub    $0xc,%esp
  8026cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8026d0:	e8 8b ef ff ff       	call   801660 <fd2data>
  8026d5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8026dc:	50                   	push   %eax
  8026dd:	6a 00                	push   $0x0
  8026df:	56                   	push   %esi
  8026e0:	6a 00                	push   $0x0
  8026e2:	e8 df e7 ff ff       	call   800ec6 <sys_page_map>
  8026e7:	89 c3                	mov    %eax,%ebx
  8026e9:	83 c4 20             	add    $0x20,%esp
  8026ec:	85 c0                	test   %eax,%eax
  8026ee:	78 55                	js     802745 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8026f0:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  8026f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026f9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8026fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026fe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802705:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  80270b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80270e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802713:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80271a:	83 ec 0c             	sub    $0xc,%esp
  80271d:	ff 75 f4             	pushl  -0xc(%ebp)
  802720:	e8 2b ef ff ff       	call   801650 <fd2num>
  802725:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802728:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80272a:	83 c4 04             	add    $0x4,%esp
  80272d:	ff 75 f0             	pushl  -0x10(%ebp)
  802730:	e8 1b ef ff ff       	call   801650 <fd2num>
  802735:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802738:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80273b:	83 c4 10             	add    $0x10,%esp
  80273e:	ba 00 00 00 00       	mov    $0x0,%edx
  802743:	eb 30                	jmp    802775 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802745:	83 ec 08             	sub    $0x8,%esp
  802748:	56                   	push   %esi
  802749:	6a 00                	push   $0x0
  80274b:	e8 b8 e7 ff ff       	call   800f08 <sys_page_unmap>
  802750:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802753:	83 ec 08             	sub    $0x8,%esp
  802756:	ff 75 f0             	pushl  -0x10(%ebp)
  802759:	6a 00                	push   $0x0
  80275b:	e8 a8 e7 ff ff       	call   800f08 <sys_page_unmap>
  802760:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802763:	83 ec 08             	sub    $0x8,%esp
  802766:	ff 75 f4             	pushl  -0xc(%ebp)
  802769:	6a 00                	push   $0x0
  80276b:	e8 98 e7 ff ff       	call   800f08 <sys_page_unmap>
  802770:	83 c4 10             	add    $0x10,%esp
  802773:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802775:	89 d0                	mov    %edx,%eax
  802777:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80277a:	5b                   	pop    %ebx
  80277b:	5e                   	pop    %esi
  80277c:	5d                   	pop    %ebp
  80277d:	c3                   	ret    

0080277e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80277e:	55                   	push   %ebp
  80277f:	89 e5                	mov    %esp,%ebp
  802781:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802784:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802787:	50                   	push   %eax
  802788:	ff 75 08             	pushl  0x8(%ebp)
  80278b:	e8 36 ef ff ff       	call   8016c6 <fd_lookup>
  802790:	83 c4 10             	add    $0x10,%esp
  802793:	85 c0                	test   %eax,%eax
  802795:	78 18                	js     8027af <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802797:	83 ec 0c             	sub    $0xc,%esp
  80279a:	ff 75 f4             	pushl  -0xc(%ebp)
  80279d:	e8 be ee ff ff       	call   801660 <fd2data>
	return _pipeisclosed(fd, p);
  8027a2:	89 c2                	mov    %eax,%edx
  8027a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027a7:	e8 18 fd ff ff       	call   8024c4 <_pipeisclosed>
  8027ac:	83 c4 10             	add    $0x10,%esp
}
  8027af:	c9                   	leave  
  8027b0:	c3                   	ret    

008027b1 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8027b1:	55                   	push   %ebp
  8027b2:	89 e5                	mov    %esp,%ebp
  8027b4:	56                   	push   %esi
  8027b5:	53                   	push   %ebx
  8027b6:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8027b9:	85 f6                	test   %esi,%esi
  8027bb:	75 16                	jne    8027d3 <wait+0x22>
  8027bd:	68 3b 34 80 00       	push   $0x80343b
  8027c2:	68 3b 33 80 00       	push   $0x80333b
  8027c7:	6a 09                	push   $0x9
  8027c9:	68 46 34 80 00       	push   $0x803446
  8027ce:	e8 4f dc ff ff       	call   800422 <_panic>
	e = &envs[ENVX(envid)];
  8027d3:	89 f3                	mov    %esi,%ebx
  8027d5:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8027db:	69 db d8 00 00 00    	imul   $0xd8,%ebx,%ebx
  8027e1:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8027e7:	eb 05                	jmp    8027ee <wait+0x3d>
		sys_yield();
  8027e9:	e8 76 e6 ff ff       	call   800e64 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8027ee:	8b 83 a4 00 00 00    	mov    0xa4(%ebx),%eax
  8027f4:	39 c6                	cmp    %eax,%esi
  8027f6:	75 0a                	jne    802802 <wait+0x51>
  8027f8:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  8027fe:	85 c0                	test   %eax,%eax
  802800:	75 e7                	jne    8027e9 <wait+0x38>
		sys_yield();
}
  802802:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802805:	5b                   	pop    %ebx
  802806:	5e                   	pop    %esi
  802807:	5d                   	pop    %ebp
  802808:	c3                   	ret    

00802809 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802809:	55                   	push   %ebp
  80280a:	89 e5                	mov    %esp,%ebp
  80280c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80280f:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  802816:	75 2a                	jne    802842 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802818:	83 ec 04             	sub    $0x4,%esp
  80281b:	6a 07                	push   $0x7
  80281d:	68 00 f0 bf ee       	push   $0xeebff000
  802822:	6a 00                	push   $0x0
  802824:	e8 5a e6 ff ff       	call   800e83 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802829:	83 c4 10             	add    $0x10,%esp
  80282c:	85 c0                	test   %eax,%eax
  80282e:	79 12                	jns    802842 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802830:	50                   	push   %eax
  802831:	68 63 2d 80 00       	push   $0x802d63
  802836:	6a 23                	push   $0x23
  802838:	68 51 34 80 00       	push   $0x803451
  80283d:	e8 e0 db ff ff       	call   800422 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802842:	8b 45 08             	mov    0x8(%ebp),%eax
  802845:	a3 00 90 80 00       	mov    %eax,0x809000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80284a:	83 ec 08             	sub    $0x8,%esp
  80284d:	68 74 28 80 00       	push   $0x802874
  802852:	6a 00                	push   $0x0
  802854:	e8 75 e7 ff ff       	call   800fce <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802859:	83 c4 10             	add    $0x10,%esp
  80285c:	85 c0                	test   %eax,%eax
  80285e:	79 12                	jns    802872 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802860:	50                   	push   %eax
  802861:	68 63 2d 80 00       	push   $0x802d63
  802866:	6a 2c                	push   $0x2c
  802868:	68 51 34 80 00       	push   $0x803451
  80286d:	e8 b0 db ff ff       	call   800422 <_panic>
	}
}
  802872:	c9                   	leave  
  802873:	c3                   	ret    

00802874 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802874:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802875:	a1 00 90 80 00       	mov    0x809000,%eax
	call *%eax
  80287a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80287c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80287f:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802883:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802888:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80288c:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80288e:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802891:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802892:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802895:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802896:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802897:	c3                   	ret    

00802898 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802898:	55                   	push   %ebp
  802899:	89 e5                	mov    %esp,%ebp
  80289b:	56                   	push   %esi
  80289c:	53                   	push   %ebx
  80289d:	8b 75 08             	mov    0x8(%ebp),%esi
  8028a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8028a6:	85 c0                	test   %eax,%eax
  8028a8:	75 12                	jne    8028bc <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8028aa:	83 ec 0c             	sub    $0xc,%esp
  8028ad:	68 00 00 c0 ee       	push   $0xeec00000
  8028b2:	e8 7c e7 ff ff       	call   801033 <sys_ipc_recv>
  8028b7:	83 c4 10             	add    $0x10,%esp
  8028ba:	eb 0c                	jmp    8028c8 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8028bc:	83 ec 0c             	sub    $0xc,%esp
  8028bf:	50                   	push   %eax
  8028c0:	e8 6e e7 ff ff       	call   801033 <sys_ipc_recv>
  8028c5:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8028c8:	85 f6                	test   %esi,%esi
  8028ca:	0f 95 c1             	setne  %cl
  8028cd:	85 db                	test   %ebx,%ebx
  8028cf:	0f 95 c2             	setne  %dl
  8028d2:	84 d1                	test   %dl,%cl
  8028d4:	74 09                	je     8028df <ipc_recv+0x47>
  8028d6:	89 c2                	mov    %eax,%edx
  8028d8:	c1 ea 1f             	shr    $0x1f,%edx
  8028db:	84 d2                	test   %dl,%dl
  8028dd:	75 2d                	jne    80290c <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8028df:	85 f6                	test   %esi,%esi
  8028e1:	74 0d                	je     8028f0 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8028e3:	a1 90 77 80 00       	mov    0x807790,%eax
  8028e8:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8028ee:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8028f0:	85 db                	test   %ebx,%ebx
  8028f2:	74 0d                	je     802901 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8028f4:	a1 90 77 80 00       	mov    0x807790,%eax
  8028f9:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8028ff:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802901:	a1 90 77 80 00       	mov    0x807790,%eax
  802906:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  80290c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80290f:	5b                   	pop    %ebx
  802910:	5e                   	pop    %esi
  802911:	5d                   	pop    %ebp
  802912:	c3                   	ret    

00802913 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802913:	55                   	push   %ebp
  802914:	89 e5                	mov    %esp,%ebp
  802916:	57                   	push   %edi
  802917:	56                   	push   %esi
  802918:	53                   	push   %ebx
  802919:	83 ec 0c             	sub    $0xc,%esp
  80291c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80291f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802922:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802925:	85 db                	test   %ebx,%ebx
  802927:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80292c:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80292f:	ff 75 14             	pushl  0x14(%ebp)
  802932:	53                   	push   %ebx
  802933:	56                   	push   %esi
  802934:	57                   	push   %edi
  802935:	e8 d6 e6 ff ff       	call   801010 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80293a:	89 c2                	mov    %eax,%edx
  80293c:	c1 ea 1f             	shr    $0x1f,%edx
  80293f:	83 c4 10             	add    $0x10,%esp
  802942:	84 d2                	test   %dl,%dl
  802944:	74 17                	je     80295d <ipc_send+0x4a>
  802946:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802949:	74 12                	je     80295d <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80294b:	50                   	push   %eax
  80294c:	68 5f 34 80 00       	push   $0x80345f
  802951:	6a 47                	push   $0x47
  802953:	68 6d 34 80 00       	push   $0x80346d
  802958:	e8 c5 da ff ff       	call   800422 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80295d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802960:	75 07                	jne    802969 <ipc_send+0x56>
			sys_yield();
  802962:	e8 fd e4 ff ff       	call   800e64 <sys_yield>
  802967:	eb c6                	jmp    80292f <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802969:	85 c0                	test   %eax,%eax
  80296b:	75 c2                	jne    80292f <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80296d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802970:	5b                   	pop    %ebx
  802971:	5e                   	pop    %esi
  802972:	5f                   	pop    %edi
  802973:	5d                   	pop    %ebp
  802974:	c3                   	ret    

00802975 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802975:	55                   	push   %ebp
  802976:	89 e5                	mov    %esp,%ebp
  802978:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80297b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802980:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802986:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80298c:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802992:	39 ca                	cmp    %ecx,%edx
  802994:	75 13                	jne    8029a9 <ipc_find_env+0x34>
			return envs[i].env_id;
  802996:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80299c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8029a1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8029a7:	eb 0f                	jmp    8029b8 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8029a9:	83 c0 01             	add    $0x1,%eax
  8029ac:	3d 00 04 00 00       	cmp    $0x400,%eax
  8029b1:	75 cd                	jne    802980 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8029b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8029b8:	5d                   	pop    %ebp
  8029b9:	c3                   	ret    

008029ba <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8029ba:	55                   	push   %ebp
  8029bb:	89 e5                	mov    %esp,%ebp
  8029bd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029c0:	89 d0                	mov    %edx,%eax
  8029c2:	c1 e8 16             	shr    $0x16,%eax
  8029c5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8029cc:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029d1:	f6 c1 01             	test   $0x1,%cl
  8029d4:	74 1d                	je     8029f3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8029d6:	c1 ea 0c             	shr    $0xc,%edx
  8029d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8029e0:	f6 c2 01             	test   $0x1,%dl
  8029e3:	74 0e                	je     8029f3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029e5:	c1 ea 0c             	shr    $0xc,%edx
  8029e8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8029ef:	ef 
  8029f0:	0f b7 c0             	movzwl %ax,%eax
}
  8029f3:	5d                   	pop    %ebp
  8029f4:	c3                   	ret    
  8029f5:	66 90                	xchg   %ax,%ax
  8029f7:	66 90                	xchg   %ax,%ax
  8029f9:	66 90                	xchg   %ax,%ax
  8029fb:	66 90                	xchg   %ax,%ax
  8029fd:	66 90                	xchg   %ax,%ax
  8029ff:	90                   	nop

00802a00 <__udivdi3>:
  802a00:	55                   	push   %ebp
  802a01:	57                   	push   %edi
  802a02:	56                   	push   %esi
  802a03:	53                   	push   %ebx
  802a04:	83 ec 1c             	sub    $0x1c,%esp
  802a07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802a0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802a0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802a13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a17:	85 f6                	test   %esi,%esi
  802a19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a1d:	89 ca                	mov    %ecx,%edx
  802a1f:	89 f8                	mov    %edi,%eax
  802a21:	75 3d                	jne    802a60 <__udivdi3+0x60>
  802a23:	39 cf                	cmp    %ecx,%edi
  802a25:	0f 87 c5 00 00 00    	ja     802af0 <__udivdi3+0xf0>
  802a2b:	85 ff                	test   %edi,%edi
  802a2d:	89 fd                	mov    %edi,%ebp
  802a2f:	75 0b                	jne    802a3c <__udivdi3+0x3c>
  802a31:	b8 01 00 00 00       	mov    $0x1,%eax
  802a36:	31 d2                	xor    %edx,%edx
  802a38:	f7 f7                	div    %edi
  802a3a:	89 c5                	mov    %eax,%ebp
  802a3c:	89 c8                	mov    %ecx,%eax
  802a3e:	31 d2                	xor    %edx,%edx
  802a40:	f7 f5                	div    %ebp
  802a42:	89 c1                	mov    %eax,%ecx
  802a44:	89 d8                	mov    %ebx,%eax
  802a46:	89 cf                	mov    %ecx,%edi
  802a48:	f7 f5                	div    %ebp
  802a4a:	89 c3                	mov    %eax,%ebx
  802a4c:	89 d8                	mov    %ebx,%eax
  802a4e:	89 fa                	mov    %edi,%edx
  802a50:	83 c4 1c             	add    $0x1c,%esp
  802a53:	5b                   	pop    %ebx
  802a54:	5e                   	pop    %esi
  802a55:	5f                   	pop    %edi
  802a56:	5d                   	pop    %ebp
  802a57:	c3                   	ret    
  802a58:	90                   	nop
  802a59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a60:	39 ce                	cmp    %ecx,%esi
  802a62:	77 74                	ja     802ad8 <__udivdi3+0xd8>
  802a64:	0f bd fe             	bsr    %esi,%edi
  802a67:	83 f7 1f             	xor    $0x1f,%edi
  802a6a:	0f 84 98 00 00 00    	je     802b08 <__udivdi3+0x108>
  802a70:	bb 20 00 00 00       	mov    $0x20,%ebx
  802a75:	89 f9                	mov    %edi,%ecx
  802a77:	89 c5                	mov    %eax,%ebp
  802a79:	29 fb                	sub    %edi,%ebx
  802a7b:	d3 e6                	shl    %cl,%esi
  802a7d:	89 d9                	mov    %ebx,%ecx
  802a7f:	d3 ed                	shr    %cl,%ebp
  802a81:	89 f9                	mov    %edi,%ecx
  802a83:	d3 e0                	shl    %cl,%eax
  802a85:	09 ee                	or     %ebp,%esi
  802a87:	89 d9                	mov    %ebx,%ecx
  802a89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a8d:	89 d5                	mov    %edx,%ebp
  802a8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a93:	d3 ed                	shr    %cl,%ebp
  802a95:	89 f9                	mov    %edi,%ecx
  802a97:	d3 e2                	shl    %cl,%edx
  802a99:	89 d9                	mov    %ebx,%ecx
  802a9b:	d3 e8                	shr    %cl,%eax
  802a9d:	09 c2                	or     %eax,%edx
  802a9f:	89 d0                	mov    %edx,%eax
  802aa1:	89 ea                	mov    %ebp,%edx
  802aa3:	f7 f6                	div    %esi
  802aa5:	89 d5                	mov    %edx,%ebp
  802aa7:	89 c3                	mov    %eax,%ebx
  802aa9:	f7 64 24 0c          	mull   0xc(%esp)
  802aad:	39 d5                	cmp    %edx,%ebp
  802aaf:	72 10                	jb     802ac1 <__udivdi3+0xc1>
  802ab1:	8b 74 24 08          	mov    0x8(%esp),%esi
  802ab5:	89 f9                	mov    %edi,%ecx
  802ab7:	d3 e6                	shl    %cl,%esi
  802ab9:	39 c6                	cmp    %eax,%esi
  802abb:	73 07                	jae    802ac4 <__udivdi3+0xc4>
  802abd:	39 d5                	cmp    %edx,%ebp
  802abf:	75 03                	jne    802ac4 <__udivdi3+0xc4>
  802ac1:	83 eb 01             	sub    $0x1,%ebx
  802ac4:	31 ff                	xor    %edi,%edi
  802ac6:	89 d8                	mov    %ebx,%eax
  802ac8:	89 fa                	mov    %edi,%edx
  802aca:	83 c4 1c             	add    $0x1c,%esp
  802acd:	5b                   	pop    %ebx
  802ace:	5e                   	pop    %esi
  802acf:	5f                   	pop    %edi
  802ad0:	5d                   	pop    %ebp
  802ad1:	c3                   	ret    
  802ad2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ad8:	31 ff                	xor    %edi,%edi
  802ada:	31 db                	xor    %ebx,%ebx
  802adc:	89 d8                	mov    %ebx,%eax
  802ade:	89 fa                	mov    %edi,%edx
  802ae0:	83 c4 1c             	add    $0x1c,%esp
  802ae3:	5b                   	pop    %ebx
  802ae4:	5e                   	pop    %esi
  802ae5:	5f                   	pop    %edi
  802ae6:	5d                   	pop    %ebp
  802ae7:	c3                   	ret    
  802ae8:	90                   	nop
  802ae9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802af0:	89 d8                	mov    %ebx,%eax
  802af2:	f7 f7                	div    %edi
  802af4:	31 ff                	xor    %edi,%edi
  802af6:	89 c3                	mov    %eax,%ebx
  802af8:	89 d8                	mov    %ebx,%eax
  802afa:	89 fa                	mov    %edi,%edx
  802afc:	83 c4 1c             	add    $0x1c,%esp
  802aff:	5b                   	pop    %ebx
  802b00:	5e                   	pop    %esi
  802b01:	5f                   	pop    %edi
  802b02:	5d                   	pop    %ebp
  802b03:	c3                   	ret    
  802b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b08:	39 ce                	cmp    %ecx,%esi
  802b0a:	72 0c                	jb     802b18 <__udivdi3+0x118>
  802b0c:	31 db                	xor    %ebx,%ebx
  802b0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802b12:	0f 87 34 ff ff ff    	ja     802a4c <__udivdi3+0x4c>
  802b18:	bb 01 00 00 00       	mov    $0x1,%ebx
  802b1d:	e9 2a ff ff ff       	jmp    802a4c <__udivdi3+0x4c>
  802b22:	66 90                	xchg   %ax,%ax
  802b24:	66 90                	xchg   %ax,%ax
  802b26:	66 90                	xchg   %ax,%ax
  802b28:	66 90                	xchg   %ax,%ax
  802b2a:	66 90                	xchg   %ax,%ax
  802b2c:	66 90                	xchg   %ax,%ax
  802b2e:	66 90                	xchg   %ax,%ax

00802b30 <__umoddi3>:
  802b30:	55                   	push   %ebp
  802b31:	57                   	push   %edi
  802b32:	56                   	push   %esi
  802b33:	53                   	push   %ebx
  802b34:	83 ec 1c             	sub    $0x1c,%esp
  802b37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802b3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802b3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802b43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802b47:	85 d2                	test   %edx,%edx
  802b49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802b4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b51:	89 f3                	mov    %esi,%ebx
  802b53:	89 3c 24             	mov    %edi,(%esp)
  802b56:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b5a:	75 1c                	jne    802b78 <__umoddi3+0x48>
  802b5c:	39 f7                	cmp    %esi,%edi
  802b5e:	76 50                	jbe    802bb0 <__umoddi3+0x80>
  802b60:	89 c8                	mov    %ecx,%eax
  802b62:	89 f2                	mov    %esi,%edx
  802b64:	f7 f7                	div    %edi
  802b66:	89 d0                	mov    %edx,%eax
  802b68:	31 d2                	xor    %edx,%edx
  802b6a:	83 c4 1c             	add    $0x1c,%esp
  802b6d:	5b                   	pop    %ebx
  802b6e:	5e                   	pop    %esi
  802b6f:	5f                   	pop    %edi
  802b70:	5d                   	pop    %ebp
  802b71:	c3                   	ret    
  802b72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b78:	39 f2                	cmp    %esi,%edx
  802b7a:	89 d0                	mov    %edx,%eax
  802b7c:	77 52                	ja     802bd0 <__umoddi3+0xa0>
  802b7e:	0f bd ea             	bsr    %edx,%ebp
  802b81:	83 f5 1f             	xor    $0x1f,%ebp
  802b84:	75 5a                	jne    802be0 <__umoddi3+0xb0>
  802b86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802b8a:	0f 82 e0 00 00 00    	jb     802c70 <__umoddi3+0x140>
  802b90:	39 0c 24             	cmp    %ecx,(%esp)
  802b93:	0f 86 d7 00 00 00    	jbe    802c70 <__umoddi3+0x140>
  802b99:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802ba1:	83 c4 1c             	add    $0x1c,%esp
  802ba4:	5b                   	pop    %ebx
  802ba5:	5e                   	pop    %esi
  802ba6:	5f                   	pop    %edi
  802ba7:	5d                   	pop    %ebp
  802ba8:	c3                   	ret    
  802ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802bb0:	85 ff                	test   %edi,%edi
  802bb2:	89 fd                	mov    %edi,%ebp
  802bb4:	75 0b                	jne    802bc1 <__umoddi3+0x91>
  802bb6:	b8 01 00 00 00       	mov    $0x1,%eax
  802bbb:	31 d2                	xor    %edx,%edx
  802bbd:	f7 f7                	div    %edi
  802bbf:	89 c5                	mov    %eax,%ebp
  802bc1:	89 f0                	mov    %esi,%eax
  802bc3:	31 d2                	xor    %edx,%edx
  802bc5:	f7 f5                	div    %ebp
  802bc7:	89 c8                	mov    %ecx,%eax
  802bc9:	f7 f5                	div    %ebp
  802bcb:	89 d0                	mov    %edx,%eax
  802bcd:	eb 99                	jmp    802b68 <__umoddi3+0x38>
  802bcf:	90                   	nop
  802bd0:	89 c8                	mov    %ecx,%eax
  802bd2:	89 f2                	mov    %esi,%edx
  802bd4:	83 c4 1c             	add    $0x1c,%esp
  802bd7:	5b                   	pop    %ebx
  802bd8:	5e                   	pop    %esi
  802bd9:	5f                   	pop    %edi
  802bda:	5d                   	pop    %ebp
  802bdb:	c3                   	ret    
  802bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802be0:	8b 34 24             	mov    (%esp),%esi
  802be3:	bf 20 00 00 00       	mov    $0x20,%edi
  802be8:	89 e9                	mov    %ebp,%ecx
  802bea:	29 ef                	sub    %ebp,%edi
  802bec:	d3 e0                	shl    %cl,%eax
  802bee:	89 f9                	mov    %edi,%ecx
  802bf0:	89 f2                	mov    %esi,%edx
  802bf2:	d3 ea                	shr    %cl,%edx
  802bf4:	89 e9                	mov    %ebp,%ecx
  802bf6:	09 c2                	or     %eax,%edx
  802bf8:	89 d8                	mov    %ebx,%eax
  802bfa:	89 14 24             	mov    %edx,(%esp)
  802bfd:	89 f2                	mov    %esi,%edx
  802bff:	d3 e2                	shl    %cl,%edx
  802c01:	89 f9                	mov    %edi,%ecx
  802c03:	89 54 24 04          	mov    %edx,0x4(%esp)
  802c07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802c0b:	d3 e8                	shr    %cl,%eax
  802c0d:	89 e9                	mov    %ebp,%ecx
  802c0f:	89 c6                	mov    %eax,%esi
  802c11:	d3 e3                	shl    %cl,%ebx
  802c13:	89 f9                	mov    %edi,%ecx
  802c15:	89 d0                	mov    %edx,%eax
  802c17:	d3 e8                	shr    %cl,%eax
  802c19:	89 e9                	mov    %ebp,%ecx
  802c1b:	09 d8                	or     %ebx,%eax
  802c1d:	89 d3                	mov    %edx,%ebx
  802c1f:	89 f2                	mov    %esi,%edx
  802c21:	f7 34 24             	divl   (%esp)
  802c24:	89 d6                	mov    %edx,%esi
  802c26:	d3 e3                	shl    %cl,%ebx
  802c28:	f7 64 24 04          	mull   0x4(%esp)
  802c2c:	39 d6                	cmp    %edx,%esi
  802c2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c32:	89 d1                	mov    %edx,%ecx
  802c34:	89 c3                	mov    %eax,%ebx
  802c36:	72 08                	jb     802c40 <__umoddi3+0x110>
  802c38:	75 11                	jne    802c4b <__umoddi3+0x11b>
  802c3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802c3e:	73 0b                	jae    802c4b <__umoddi3+0x11b>
  802c40:	2b 44 24 04          	sub    0x4(%esp),%eax
  802c44:	1b 14 24             	sbb    (%esp),%edx
  802c47:	89 d1                	mov    %edx,%ecx
  802c49:	89 c3                	mov    %eax,%ebx
  802c4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802c4f:	29 da                	sub    %ebx,%edx
  802c51:	19 ce                	sbb    %ecx,%esi
  802c53:	89 f9                	mov    %edi,%ecx
  802c55:	89 f0                	mov    %esi,%eax
  802c57:	d3 e0                	shl    %cl,%eax
  802c59:	89 e9                	mov    %ebp,%ecx
  802c5b:	d3 ea                	shr    %cl,%edx
  802c5d:	89 e9                	mov    %ebp,%ecx
  802c5f:	d3 ee                	shr    %cl,%esi
  802c61:	09 d0                	or     %edx,%eax
  802c63:	89 f2                	mov    %esi,%edx
  802c65:	83 c4 1c             	add    $0x1c,%esp
  802c68:	5b                   	pop    %ebx
  802c69:	5e                   	pop    %esi
  802c6a:	5f                   	pop    %edi
  802c6b:	5d                   	pop    %ebp
  802c6c:	c3                   	ret    
  802c6d:	8d 76 00             	lea    0x0(%esi),%esi
  802c70:	29 f9                	sub    %edi,%ecx
  802c72:	19 d6                	sbb    %edx,%esi
  802c74:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802c7c:	e9 18 ff ff ff       	jmp    802b99 <__umoddi3+0x69>
