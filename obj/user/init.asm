
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
  80006d:	68 40 2a 80 00       	push   $0x802a40
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
  80009c:	68 08 2b 80 00       	push   $0x802b08
  8000a1:	e8 55 04 00 00       	call   8004fb <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 4f 2a 80 00       	push   $0x802a4f
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
  8000d8:	68 44 2b 80 00       	push   $0x802b44
  8000dd:	e8 19 04 00 00       	call   8004fb <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 66 2a 80 00       	push   $0x802a66
  8000ef:	e8 07 04 00 00       	call   8004fb <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 7c 2a 80 00       	push   $0x802a7c
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
  80011e:	68 88 2a 80 00       	push   $0x802a88
  800123:	56                   	push   %esi
  800124:	e8 77 09 00 00       	call   800aa0 <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 6b 09 00 00       	call   800aa0 <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 89 2a 80 00       	push   $0x802a89
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
  800158:	68 8b 2a 80 00       	push   $0x802a8b
  80015d:	e8 99 03 00 00       	call   8004fb <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 8f 2a 80 00 	movl   $0x802a8f,(%esp)
  800169:	e8 8d 03 00 00       	call   8004fb <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 17 14 00 00       	call   801591 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 a1 2a 80 00       	push   $0x802aa1
  80018c:	6a 37                	push   $0x37
  80018e:	68 ae 2a 80 00       	push   $0x802aae
  800193:	e8 8a 02 00 00       	call   800422 <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 ba 2a 80 00       	push   $0x802aba
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 ae 2a 80 00       	push   $0x802aae
  8001a9:	e8 74 02 00 00       	call   800422 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 27 14 00 00       	call   8015e1 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 d4 2a 80 00       	push   $0x802ad4
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 ae 2a 80 00       	push   $0x802aae
  8001ce:	e8 4f 02 00 00       	call   800422 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 dc 2a 80 00       	push   $0x802adc
  8001db:	e8 1b 03 00 00       	call   8004fb <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 f0 2a 80 00       	push   $0x802af0
  8001ea:	68 ef 2a 80 00       	push   $0x802aef
  8001ef:	e8 83 1f 00 00       	call   802177 <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 f3 2a 80 00       	push   $0x802af3
  800204:	e8 f2 02 00 00       	call   8004fb <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 38 23 00 00       	call   80254f <wait>
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
  80022c:	68 73 2b 80 00       	push   $0x802b73
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
  8002fc:	e8 cc 13 00 00       	call   8016cd <read>
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
  800326:	e8 39 11 00 00       	call   801464 <fd_lookup>
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
  80034f:	e8 c1 10 00 00       	call   801415 <fd_alloc>
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
  800391:	e8 58 10 00 00       	call   8013ee <fd2num>
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
  80040e:	e8 a9 11 00 00       	call   8015bc <close_all>
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
  800440:	68 8c 2b 80 00       	push   $0x802b8c
  800445:	e8 b1 00 00 00       	call   8004fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80044a:	83 c4 18             	add    $0x18,%esp
  80044d:	53                   	push   %ebx
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	e8 54 00 00 00       	call   8004aa <vcprintf>
	cprintf("\n");
  800456:	c7 04 24 f4 30 80 00 	movl   $0x8030f4,(%esp)
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
  80055e:	e8 3d 22 00 00       	call   8027a0 <__udivdi3>
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
  8005a1:	e8 2a 23 00 00       	call   8028d0 <__umoddi3>
  8005a6:	83 c4 14             	add    $0x14,%esp
  8005a9:	0f be 80 af 2b 80 00 	movsbl 0x802baf(%eax),%eax
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
  8006a5:	ff 24 85 00 2d 80 00 	jmp    *0x802d00(,%eax,4)
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
  800769:	8b 14 85 60 2e 80 00 	mov    0x802e60(,%eax,4),%edx
  800770:	85 d2                	test   %edx,%edx
  800772:	75 18                	jne    80078c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800774:	50                   	push   %eax
  800775:	68 c7 2b 80 00       	push   $0x802bc7
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
  80078d:	68 0d 30 80 00       	push   $0x80300d
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
  8007b1:	b8 c0 2b 80 00       	mov    $0x802bc0,%eax
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
  800e2c:	68 bf 2e 80 00       	push   $0x802ebf
  800e31:	6a 23                	push   $0x23
  800e33:	68 dc 2e 80 00       	push   $0x802edc
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
  800ead:	68 bf 2e 80 00       	push   $0x802ebf
  800eb2:	6a 23                	push   $0x23
  800eb4:	68 dc 2e 80 00       	push   $0x802edc
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
  800eef:	68 bf 2e 80 00       	push   $0x802ebf
  800ef4:	6a 23                	push   $0x23
  800ef6:	68 dc 2e 80 00       	push   $0x802edc
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
  800f31:	68 bf 2e 80 00       	push   $0x802ebf
  800f36:	6a 23                	push   $0x23
  800f38:	68 dc 2e 80 00       	push   $0x802edc
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
  800f73:	68 bf 2e 80 00       	push   $0x802ebf
  800f78:	6a 23                	push   $0x23
  800f7a:	68 dc 2e 80 00       	push   $0x802edc
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
  800fb5:	68 bf 2e 80 00       	push   $0x802ebf
  800fba:	6a 23                	push   $0x23
  800fbc:	68 dc 2e 80 00       	push   $0x802edc
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
  800ff7:	68 bf 2e 80 00       	push   $0x802ebf
  800ffc:	6a 23                	push   $0x23
  800ffe:	68 dc 2e 80 00       	push   $0x802edc
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
  80105b:	68 bf 2e 80 00       	push   $0x802ebf
  801060:	6a 23                	push   $0x23
  801062:	68 dc 2e 80 00       	push   $0x802edc
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
  8010fa:	68 ea 2e 80 00       	push   $0x802eea
  8010ff:	6a 1e                	push   $0x1e
  801101:	68 fa 2e 80 00       	push   $0x802efa
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
  801124:	68 05 2f 80 00       	push   $0x802f05
  801129:	6a 2c                	push   $0x2c
  80112b:	68 fa 2e 80 00       	push   $0x802efa
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
  80116c:	68 05 2f 80 00       	push   $0x802f05
  801171:	6a 33                	push   $0x33
  801173:	68 fa 2e 80 00       	push   $0x802efa
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
  801194:	68 05 2f 80 00       	push   $0x802f05
  801199:	6a 37                	push   $0x37
  80119b:	68 fa 2e 80 00       	push   $0x802efa
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
  8011b8:	e8 ea 13 00 00       	call   8025a7 <set_pgfault_handler>
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
  8011d1:	68 1e 2f 80 00       	push   $0x802f1e
  8011d6:	68 84 00 00 00       	push   $0x84
  8011db:	68 fa 2e 80 00       	push   $0x802efa
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
  80128d:	68 2c 2f 80 00       	push   $0x802f2c
  801292:	6a 54                	push   $0x54
  801294:	68 fa 2e 80 00       	push   $0x802efa
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
  8012d2:	68 2c 2f 80 00       	push   $0x802f2c
  8012d7:	6a 5b                	push   $0x5b
  8012d9:	68 fa 2e 80 00       	push   $0x802efa
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
  801300:	68 2c 2f 80 00       	push   $0x802f2c
  801305:	6a 5f                	push   $0x5f
  801307:	68 fa 2e 80 00       	push   $0x802efa
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
  80132a:	68 2c 2f 80 00       	push   $0x802f2c
  80132f:	6a 64                	push   $0x64
  801331:	68 fa 2e 80 00       	push   $0x802efa
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
  801399:	68 44 2f 80 00       	push   $0x802f44
  80139e:	e8 58 f1 ff ff       	call   8004fb <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8013a3:	c7 04 24 e8 03 80 00 	movl   $0x8003e8,(%esp)
  8013aa:	e8 c5 fc ff ff       	call   801074 <sys_thread_create>
  8013af:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8013b1:	83 c4 08             	add    $0x8,%esp
  8013b4:	53                   	push   %ebx
  8013b5:	68 44 2f 80 00       	push   $0x802f44
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

008013ee <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f4:	05 00 00 00 30       	add    $0x30000000,%eax
  8013f9:	c1 e8 0c             	shr    $0xc,%eax
}
  8013fc:	5d                   	pop    %ebp
  8013fd:	c3                   	ret    

008013fe <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801401:	8b 45 08             	mov    0x8(%ebp),%eax
  801404:	05 00 00 00 30       	add    $0x30000000,%eax
  801409:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80140e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80141b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801420:	89 c2                	mov    %eax,%edx
  801422:	c1 ea 16             	shr    $0x16,%edx
  801425:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80142c:	f6 c2 01             	test   $0x1,%dl
  80142f:	74 11                	je     801442 <fd_alloc+0x2d>
  801431:	89 c2                	mov    %eax,%edx
  801433:	c1 ea 0c             	shr    $0xc,%edx
  801436:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80143d:	f6 c2 01             	test   $0x1,%dl
  801440:	75 09                	jne    80144b <fd_alloc+0x36>
			*fd_store = fd;
  801442:	89 01                	mov    %eax,(%ecx)
			return 0;
  801444:	b8 00 00 00 00       	mov    $0x0,%eax
  801449:	eb 17                	jmp    801462 <fd_alloc+0x4d>
  80144b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801450:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801455:	75 c9                	jne    801420 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801457:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80145d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801462:	5d                   	pop    %ebp
  801463:	c3                   	ret    

00801464 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80146a:	83 f8 1f             	cmp    $0x1f,%eax
  80146d:	77 36                	ja     8014a5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80146f:	c1 e0 0c             	shl    $0xc,%eax
  801472:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801477:	89 c2                	mov    %eax,%edx
  801479:	c1 ea 16             	shr    $0x16,%edx
  80147c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801483:	f6 c2 01             	test   $0x1,%dl
  801486:	74 24                	je     8014ac <fd_lookup+0x48>
  801488:	89 c2                	mov    %eax,%edx
  80148a:	c1 ea 0c             	shr    $0xc,%edx
  80148d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801494:	f6 c2 01             	test   $0x1,%dl
  801497:	74 1a                	je     8014b3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801499:	8b 55 0c             	mov    0xc(%ebp),%edx
  80149c:	89 02                	mov    %eax,(%edx)
	return 0;
  80149e:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a3:	eb 13                	jmp    8014b8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014aa:	eb 0c                	jmp    8014b8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b1:	eb 05                	jmp    8014b8 <fd_lookup+0x54>
  8014b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014b8:	5d                   	pop    %ebp
  8014b9:	c3                   	ret    

008014ba <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	83 ec 08             	sub    $0x8,%esp
  8014c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014c3:	ba e4 2f 80 00       	mov    $0x802fe4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014c8:	eb 13                	jmp    8014dd <dev_lookup+0x23>
  8014ca:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014cd:	39 08                	cmp    %ecx,(%eax)
  8014cf:	75 0c                	jne    8014dd <dev_lookup+0x23>
			*dev = devtab[i];
  8014d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014d4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014db:	eb 31                	jmp    80150e <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014dd:	8b 02                	mov    (%edx),%eax
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	75 e7                	jne    8014ca <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014e3:	a1 90 77 80 00       	mov    0x807790,%eax
  8014e8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8014ee:	83 ec 04             	sub    $0x4,%esp
  8014f1:	51                   	push   %ecx
  8014f2:	50                   	push   %eax
  8014f3:	68 68 2f 80 00       	push   $0x802f68
  8014f8:	e8 fe ef ff ff       	call   8004fb <cprintf>
	*dev = 0;
  8014fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801500:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80150e:	c9                   	leave  
  80150f:	c3                   	ret    

00801510 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	56                   	push   %esi
  801514:	53                   	push   %ebx
  801515:	83 ec 10             	sub    $0x10,%esp
  801518:	8b 75 08             	mov    0x8(%ebp),%esi
  80151b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80151e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801521:	50                   	push   %eax
  801522:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801528:	c1 e8 0c             	shr    $0xc,%eax
  80152b:	50                   	push   %eax
  80152c:	e8 33 ff ff ff       	call   801464 <fd_lookup>
  801531:	83 c4 08             	add    $0x8,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	78 05                	js     80153d <fd_close+0x2d>
	    || fd != fd2)
  801538:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80153b:	74 0c                	je     801549 <fd_close+0x39>
		return (must_exist ? r : 0);
  80153d:	84 db                	test   %bl,%bl
  80153f:	ba 00 00 00 00       	mov    $0x0,%edx
  801544:	0f 44 c2             	cmove  %edx,%eax
  801547:	eb 41                	jmp    80158a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801549:	83 ec 08             	sub    $0x8,%esp
  80154c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154f:	50                   	push   %eax
  801550:	ff 36                	pushl  (%esi)
  801552:	e8 63 ff ff ff       	call   8014ba <dev_lookup>
  801557:	89 c3                	mov    %eax,%ebx
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	85 c0                	test   %eax,%eax
  80155e:	78 1a                	js     80157a <fd_close+0x6a>
		if (dev->dev_close)
  801560:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801563:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801566:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80156b:	85 c0                	test   %eax,%eax
  80156d:	74 0b                	je     80157a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80156f:	83 ec 0c             	sub    $0xc,%esp
  801572:	56                   	push   %esi
  801573:	ff d0                	call   *%eax
  801575:	89 c3                	mov    %eax,%ebx
  801577:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	56                   	push   %esi
  80157e:	6a 00                	push   $0x0
  801580:	e8 83 f9 ff ff       	call   800f08 <sys_page_unmap>
	return r;
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	89 d8                	mov    %ebx,%eax
}
  80158a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158d:	5b                   	pop    %ebx
  80158e:	5e                   	pop    %esi
  80158f:	5d                   	pop    %ebp
  801590:	c3                   	ret    

00801591 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801597:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159a:	50                   	push   %eax
  80159b:	ff 75 08             	pushl  0x8(%ebp)
  80159e:	e8 c1 fe ff ff       	call   801464 <fd_lookup>
  8015a3:	83 c4 08             	add    $0x8,%esp
  8015a6:	85 c0                	test   %eax,%eax
  8015a8:	78 10                	js     8015ba <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	6a 01                	push   $0x1
  8015af:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b2:	e8 59 ff ff ff       	call   801510 <fd_close>
  8015b7:	83 c4 10             	add    $0x10,%esp
}
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <close_all>:

void
close_all(void)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015c3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015c8:	83 ec 0c             	sub    $0xc,%esp
  8015cb:	53                   	push   %ebx
  8015cc:	e8 c0 ff ff ff       	call   801591 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015d1:	83 c3 01             	add    $0x1,%ebx
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	83 fb 20             	cmp    $0x20,%ebx
  8015da:	75 ec                	jne    8015c8 <close_all+0xc>
		close(i);
}
  8015dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    

008015e1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	57                   	push   %edi
  8015e5:	56                   	push   %esi
  8015e6:	53                   	push   %ebx
  8015e7:	83 ec 2c             	sub    $0x2c,%esp
  8015ea:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015ed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015f0:	50                   	push   %eax
  8015f1:	ff 75 08             	pushl  0x8(%ebp)
  8015f4:	e8 6b fe ff ff       	call   801464 <fd_lookup>
  8015f9:	83 c4 08             	add    $0x8,%esp
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	0f 88 c1 00 00 00    	js     8016c5 <dup+0xe4>
		return r;
	close(newfdnum);
  801604:	83 ec 0c             	sub    $0xc,%esp
  801607:	56                   	push   %esi
  801608:	e8 84 ff ff ff       	call   801591 <close>

	newfd = INDEX2FD(newfdnum);
  80160d:	89 f3                	mov    %esi,%ebx
  80160f:	c1 e3 0c             	shl    $0xc,%ebx
  801612:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801618:	83 c4 04             	add    $0x4,%esp
  80161b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161e:	e8 db fd ff ff       	call   8013fe <fd2data>
  801623:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801625:	89 1c 24             	mov    %ebx,(%esp)
  801628:	e8 d1 fd ff ff       	call   8013fe <fd2data>
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801633:	89 f8                	mov    %edi,%eax
  801635:	c1 e8 16             	shr    $0x16,%eax
  801638:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80163f:	a8 01                	test   $0x1,%al
  801641:	74 37                	je     80167a <dup+0x99>
  801643:	89 f8                	mov    %edi,%eax
  801645:	c1 e8 0c             	shr    $0xc,%eax
  801648:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80164f:	f6 c2 01             	test   $0x1,%dl
  801652:	74 26                	je     80167a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801654:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80165b:	83 ec 0c             	sub    $0xc,%esp
  80165e:	25 07 0e 00 00       	and    $0xe07,%eax
  801663:	50                   	push   %eax
  801664:	ff 75 d4             	pushl  -0x2c(%ebp)
  801667:	6a 00                	push   $0x0
  801669:	57                   	push   %edi
  80166a:	6a 00                	push   $0x0
  80166c:	e8 55 f8 ff ff       	call   800ec6 <sys_page_map>
  801671:	89 c7                	mov    %eax,%edi
  801673:	83 c4 20             	add    $0x20,%esp
  801676:	85 c0                	test   %eax,%eax
  801678:	78 2e                	js     8016a8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80167a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80167d:	89 d0                	mov    %edx,%eax
  80167f:	c1 e8 0c             	shr    $0xc,%eax
  801682:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801689:	83 ec 0c             	sub    $0xc,%esp
  80168c:	25 07 0e 00 00       	and    $0xe07,%eax
  801691:	50                   	push   %eax
  801692:	53                   	push   %ebx
  801693:	6a 00                	push   $0x0
  801695:	52                   	push   %edx
  801696:	6a 00                	push   $0x0
  801698:	e8 29 f8 ff ff       	call   800ec6 <sys_page_map>
  80169d:	89 c7                	mov    %eax,%edi
  80169f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016a2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016a4:	85 ff                	test   %edi,%edi
  8016a6:	79 1d                	jns    8016c5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	53                   	push   %ebx
  8016ac:	6a 00                	push   $0x0
  8016ae:	e8 55 f8 ff ff       	call   800f08 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016b3:	83 c4 08             	add    $0x8,%esp
  8016b6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016b9:	6a 00                	push   $0x0
  8016bb:	e8 48 f8 ff ff       	call   800f08 <sys_page_unmap>
	return r;
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	89 f8                	mov    %edi,%eax
}
  8016c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c8:	5b                   	pop    %ebx
  8016c9:	5e                   	pop    %esi
  8016ca:	5f                   	pop    %edi
  8016cb:	5d                   	pop    %ebp
  8016cc:	c3                   	ret    

008016cd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	53                   	push   %ebx
  8016d1:	83 ec 14             	sub    $0x14,%esp
  8016d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016da:	50                   	push   %eax
  8016db:	53                   	push   %ebx
  8016dc:	e8 83 fd ff ff       	call   801464 <fd_lookup>
  8016e1:	83 c4 08             	add    $0x8,%esp
  8016e4:	89 c2                	mov    %eax,%edx
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	78 70                	js     80175a <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ea:	83 ec 08             	sub    $0x8,%esp
  8016ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f0:	50                   	push   %eax
  8016f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f4:	ff 30                	pushl  (%eax)
  8016f6:	e8 bf fd ff ff       	call   8014ba <dev_lookup>
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	85 c0                	test   %eax,%eax
  801700:	78 4f                	js     801751 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801702:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801705:	8b 42 08             	mov    0x8(%edx),%eax
  801708:	83 e0 03             	and    $0x3,%eax
  80170b:	83 f8 01             	cmp    $0x1,%eax
  80170e:	75 24                	jne    801734 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801710:	a1 90 77 80 00       	mov    0x807790,%eax
  801715:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80171b:	83 ec 04             	sub    $0x4,%esp
  80171e:	53                   	push   %ebx
  80171f:	50                   	push   %eax
  801720:	68 a9 2f 80 00       	push   $0x802fa9
  801725:	e8 d1 ed ff ff       	call   8004fb <cprintf>
		return -E_INVAL;
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801732:	eb 26                	jmp    80175a <read+0x8d>
	}
	if (!dev->dev_read)
  801734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801737:	8b 40 08             	mov    0x8(%eax),%eax
  80173a:	85 c0                	test   %eax,%eax
  80173c:	74 17                	je     801755 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80173e:	83 ec 04             	sub    $0x4,%esp
  801741:	ff 75 10             	pushl  0x10(%ebp)
  801744:	ff 75 0c             	pushl  0xc(%ebp)
  801747:	52                   	push   %edx
  801748:	ff d0                	call   *%eax
  80174a:	89 c2                	mov    %eax,%edx
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	eb 09                	jmp    80175a <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801751:	89 c2                	mov    %eax,%edx
  801753:	eb 05                	jmp    80175a <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801755:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80175a:	89 d0                	mov    %edx,%eax
  80175c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175f:	c9                   	leave  
  801760:	c3                   	ret    

00801761 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	57                   	push   %edi
  801765:	56                   	push   %esi
  801766:	53                   	push   %ebx
  801767:	83 ec 0c             	sub    $0xc,%esp
  80176a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80176d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801770:	bb 00 00 00 00       	mov    $0x0,%ebx
  801775:	eb 21                	jmp    801798 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801777:	83 ec 04             	sub    $0x4,%esp
  80177a:	89 f0                	mov    %esi,%eax
  80177c:	29 d8                	sub    %ebx,%eax
  80177e:	50                   	push   %eax
  80177f:	89 d8                	mov    %ebx,%eax
  801781:	03 45 0c             	add    0xc(%ebp),%eax
  801784:	50                   	push   %eax
  801785:	57                   	push   %edi
  801786:	e8 42 ff ff ff       	call   8016cd <read>
		if (m < 0)
  80178b:	83 c4 10             	add    $0x10,%esp
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 10                	js     8017a2 <readn+0x41>
			return m;
		if (m == 0)
  801792:	85 c0                	test   %eax,%eax
  801794:	74 0a                	je     8017a0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801796:	01 c3                	add    %eax,%ebx
  801798:	39 f3                	cmp    %esi,%ebx
  80179a:	72 db                	jb     801777 <readn+0x16>
  80179c:	89 d8                	mov    %ebx,%eax
  80179e:	eb 02                	jmp    8017a2 <readn+0x41>
  8017a0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a5:	5b                   	pop    %ebx
  8017a6:	5e                   	pop    %esi
  8017a7:	5f                   	pop    %edi
  8017a8:	5d                   	pop    %ebp
  8017a9:	c3                   	ret    

008017aa <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	53                   	push   %ebx
  8017ae:	83 ec 14             	sub    $0x14,%esp
  8017b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b7:	50                   	push   %eax
  8017b8:	53                   	push   %ebx
  8017b9:	e8 a6 fc ff ff       	call   801464 <fd_lookup>
  8017be:	83 c4 08             	add    $0x8,%esp
  8017c1:	89 c2                	mov    %eax,%edx
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	78 6b                	js     801832 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c7:	83 ec 08             	sub    $0x8,%esp
  8017ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017cd:	50                   	push   %eax
  8017ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d1:	ff 30                	pushl  (%eax)
  8017d3:	e8 e2 fc ff ff       	call   8014ba <dev_lookup>
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	78 4a                	js     801829 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017e6:	75 24                	jne    80180c <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017e8:	a1 90 77 80 00       	mov    0x807790,%eax
  8017ed:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8017f3:	83 ec 04             	sub    $0x4,%esp
  8017f6:	53                   	push   %ebx
  8017f7:	50                   	push   %eax
  8017f8:	68 c5 2f 80 00       	push   $0x802fc5
  8017fd:	e8 f9 ec ff ff       	call   8004fb <cprintf>
		return -E_INVAL;
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80180a:	eb 26                	jmp    801832 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80180c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80180f:	8b 52 0c             	mov    0xc(%edx),%edx
  801812:	85 d2                	test   %edx,%edx
  801814:	74 17                	je     80182d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801816:	83 ec 04             	sub    $0x4,%esp
  801819:	ff 75 10             	pushl  0x10(%ebp)
  80181c:	ff 75 0c             	pushl  0xc(%ebp)
  80181f:	50                   	push   %eax
  801820:	ff d2                	call   *%edx
  801822:	89 c2                	mov    %eax,%edx
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	eb 09                	jmp    801832 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801829:	89 c2                	mov    %eax,%edx
  80182b:	eb 05                	jmp    801832 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80182d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801832:	89 d0                	mov    %edx,%eax
  801834:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801837:	c9                   	leave  
  801838:	c3                   	ret    

00801839 <seek>:

int
seek(int fdnum, off_t offset)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80183f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801842:	50                   	push   %eax
  801843:	ff 75 08             	pushl  0x8(%ebp)
  801846:	e8 19 fc ff ff       	call   801464 <fd_lookup>
  80184b:	83 c4 08             	add    $0x8,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 0e                	js     801860 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801852:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801855:	8b 55 0c             	mov    0xc(%ebp),%edx
  801858:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80185b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	53                   	push   %ebx
  801866:	83 ec 14             	sub    $0x14,%esp
  801869:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80186f:	50                   	push   %eax
  801870:	53                   	push   %ebx
  801871:	e8 ee fb ff ff       	call   801464 <fd_lookup>
  801876:	83 c4 08             	add    $0x8,%esp
  801879:	89 c2                	mov    %eax,%edx
  80187b:	85 c0                	test   %eax,%eax
  80187d:	78 68                	js     8018e7 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187f:	83 ec 08             	sub    $0x8,%esp
  801882:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801885:	50                   	push   %eax
  801886:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801889:	ff 30                	pushl  (%eax)
  80188b:	e8 2a fc ff ff       	call   8014ba <dev_lookup>
  801890:	83 c4 10             	add    $0x10,%esp
  801893:	85 c0                	test   %eax,%eax
  801895:	78 47                	js     8018de <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801897:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80189e:	75 24                	jne    8018c4 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018a0:	a1 90 77 80 00       	mov    0x807790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018a5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	53                   	push   %ebx
  8018af:	50                   	push   %eax
  8018b0:	68 88 2f 80 00       	push   $0x802f88
  8018b5:	e8 41 ec ff ff       	call   8004fb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018ba:	83 c4 10             	add    $0x10,%esp
  8018bd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018c2:	eb 23                	jmp    8018e7 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8018c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c7:	8b 52 18             	mov    0x18(%edx),%edx
  8018ca:	85 d2                	test   %edx,%edx
  8018cc:	74 14                	je     8018e2 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018ce:	83 ec 08             	sub    $0x8,%esp
  8018d1:	ff 75 0c             	pushl  0xc(%ebp)
  8018d4:	50                   	push   %eax
  8018d5:	ff d2                	call   *%edx
  8018d7:	89 c2                	mov    %eax,%edx
  8018d9:	83 c4 10             	add    $0x10,%esp
  8018dc:	eb 09                	jmp    8018e7 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018de:	89 c2                	mov    %eax,%edx
  8018e0:	eb 05                	jmp    8018e7 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018e7:	89 d0                	mov    %edx,%eax
  8018e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ec:	c9                   	leave  
  8018ed:	c3                   	ret    

008018ee <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	53                   	push   %ebx
  8018f2:	83 ec 14             	sub    $0x14,%esp
  8018f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018fb:	50                   	push   %eax
  8018fc:	ff 75 08             	pushl  0x8(%ebp)
  8018ff:	e8 60 fb ff ff       	call   801464 <fd_lookup>
  801904:	83 c4 08             	add    $0x8,%esp
  801907:	89 c2                	mov    %eax,%edx
  801909:	85 c0                	test   %eax,%eax
  80190b:	78 58                	js     801965 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80190d:	83 ec 08             	sub    $0x8,%esp
  801910:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801913:	50                   	push   %eax
  801914:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801917:	ff 30                	pushl  (%eax)
  801919:	e8 9c fb ff ff       	call   8014ba <dev_lookup>
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	85 c0                	test   %eax,%eax
  801923:	78 37                	js     80195c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801925:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801928:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80192c:	74 32                	je     801960 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80192e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801931:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801938:	00 00 00 
	stat->st_isdir = 0;
  80193b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801942:	00 00 00 
	stat->st_dev = dev;
  801945:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80194b:	83 ec 08             	sub    $0x8,%esp
  80194e:	53                   	push   %ebx
  80194f:	ff 75 f0             	pushl  -0x10(%ebp)
  801952:	ff 50 14             	call   *0x14(%eax)
  801955:	89 c2                	mov    %eax,%edx
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	eb 09                	jmp    801965 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80195c:	89 c2                	mov    %eax,%edx
  80195e:	eb 05                	jmp    801965 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801960:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801965:	89 d0                	mov    %edx,%eax
  801967:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	56                   	push   %esi
  801970:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801971:	83 ec 08             	sub    $0x8,%esp
  801974:	6a 00                	push   $0x0
  801976:	ff 75 08             	pushl  0x8(%ebp)
  801979:	e8 e3 01 00 00       	call   801b61 <open>
  80197e:	89 c3                	mov    %eax,%ebx
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	85 c0                	test   %eax,%eax
  801985:	78 1b                	js     8019a2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801987:	83 ec 08             	sub    $0x8,%esp
  80198a:	ff 75 0c             	pushl  0xc(%ebp)
  80198d:	50                   	push   %eax
  80198e:	e8 5b ff ff ff       	call   8018ee <fstat>
  801993:	89 c6                	mov    %eax,%esi
	close(fd);
  801995:	89 1c 24             	mov    %ebx,(%esp)
  801998:	e8 f4 fb ff ff       	call   801591 <close>
	return r;
  80199d:	83 c4 10             	add    $0x10,%esp
  8019a0:	89 f0                	mov    %esi,%eax
}
  8019a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a5:	5b                   	pop    %ebx
  8019a6:	5e                   	pop    %esi
  8019a7:	5d                   	pop    %ebp
  8019a8:	c3                   	ret    

008019a9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	56                   	push   %esi
  8019ad:	53                   	push   %ebx
  8019ae:	89 c6                	mov    %eax,%esi
  8019b0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019b2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8019b9:	75 12                	jne    8019cd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019bb:	83 ec 0c             	sub    $0xc,%esp
  8019be:	6a 01                	push   $0x1
  8019c0:	e8 4e 0d 00 00       	call   802713 <ipc_find_env>
  8019c5:	a3 00 60 80 00       	mov    %eax,0x806000
  8019ca:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019cd:	6a 07                	push   $0x7
  8019cf:	68 00 80 80 00       	push   $0x808000
  8019d4:	56                   	push   %esi
  8019d5:	ff 35 00 60 80 00    	pushl  0x806000
  8019db:	e8 d1 0c 00 00       	call   8026b1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019e0:	83 c4 0c             	add    $0xc,%esp
  8019e3:	6a 00                	push   $0x0
  8019e5:	53                   	push   %ebx
  8019e6:	6a 00                	push   $0x0
  8019e8:	e8 49 0c 00 00       	call   802636 <ipc_recv>
}
  8019ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f0:	5b                   	pop    %ebx
  8019f1:	5e                   	pop    %esi
  8019f2:	5d                   	pop    %ebp
  8019f3:	c3                   	ret    

008019f4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801a00:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  801a05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a08:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a12:	b8 02 00 00 00       	mov    $0x2,%eax
  801a17:	e8 8d ff ff ff       	call   8019a9 <fsipc>
}
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    

00801a1e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a24:	8b 45 08             	mov    0x8(%ebp),%eax
  801a27:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2a:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  801a2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a34:	b8 06 00 00 00       	mov    $0x6,%eax
  801a39:	e8 6b ff ff ff       	call   8019a9 <fsipc>
}
  801a3e:	c9                   	leave  
  801a3f:	c3                   	ret    

00801a40 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	53                   	push   %ebx
  801a44:	83 ec 04             	sub    $0x4,%esp
  801a47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a50:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a55:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5a:	b8 05 00 00 00       	mov    $0x5,%eax
  801a5f:	e8 45 ff ff ff       	call   8019a9 <fsipc>
  801a64:	85 c0                	test   %eax,%eax
  801a66:	78 2c                	js     801a94 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a68:	83 ec 08             	sub    $0x8,%esp
  801a6b:	68 00 80 80 00       	push   $0x808000
  801a70:	53                   	push   %ebx
  801a71:	e8 0a f0 ff ff       	call   800a80 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a76:	a1 80 80 80 00       	mov    0x808080,%eax
  801a7b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a81:	a1 84 80 80 00       	mov    0x808084,%eax
  801a86:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a97:	c9                   	leave  
  801a98:	c3                   	ret    

00801a99 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	83 ec 0c             	sub    $0xc,%esp
  801a9f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801aa2:	8b 55 08             	mov    0x8(%ebp),%edx
  801aa5:	8b 52 0c             	mov    0xc(%edx),%edx
  801aa8:	89 15 00 80 80 00    	mov    %edx,0x808000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801aae:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ab3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ab8:	0f 47 c2             	cmova  %edx,%eax
  801abb:	a3 04 80 80 00       	mov    %eax,0x808004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801ac0:	50                   	push   %eax
  801ac1:	ff 75 0c             	pushl  0xc(%ebp)
  801ac4:	68 08 80 80 00       	push   $0x808008
  801ac9:	e8 44 f1 ff ff       	call   800c12 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801ace:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad3:	b8 04 00 00 00       	mov    $0x4,%eax
  801ad8:	e8 cc fe ff ff       	call   8019a9 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aea:	8b 40 0c             	mov    0xc(%eax),%eax
  801aed:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  801af2:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801af8:	ba 00 00 00 00       	mov    $0x0,%edx
  801afd:	b8 03 00 00 00       	mov    $0x3,%eax
  801b02:	e8 a2 fe ff ff       	call   8019a9 <fsipc>
  801b07:	89 c3                	mov    %eax,%ebx
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	78 4b                	js     801b58 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b0d:	39 c6                	cmp    %eax,%esi
  801b0f:	73 16                	jae    801b27 <devfile_read+0x48>
  801b11:	68 f4 2f 80 00       	push   $0x802ff4
  801b16:	68 fb 2f 80 00       	push   $0x802ffb
  801b1b:	6a 7c                	push   $0x7c
  801b1d:	68 10 30 80 00       	push   $0x803010
  801b22:	e8 fb e8 ff ff       	call   800422 <_panic>
	assert(r <= PGSIZE);
  801b27:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b2c:	7e 16                	jle    801b44 <devfile_read+0x65>
  801b2e:	68 1b 30 80 00       	push   $0x80301b
  801b33:	68 fb 2f 80 00       	push   $0x802ffb
  801b38:	6a 7d                	push   $0x7d
  801b3a:	68 10 30 80 00       	push   $0x803010
  801b3f:	e8 de e8 ff ff       	call   800422 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b44:	83 ec 04             	sub    $0x4,%esp
  801b47:	50                   	push   %eax
  801b48:	68 00 80 80 00       	push   $0x808000
  801b4d:	ff 75 0c             	pushl  0xc(%ebp)
  801b50:	e8 bd f0 ff ff       	call   800c12 <memmove>
	return r;
  801b55:	83 c4 10             	add    $0x10,%esp
}
  801b58:	89 d8                	mov    %ebx,%eax
  801b5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5d:	5b                   	pop    %ebx
  801b5e:	5e                   	pop    %esi
  801b5f:	5d                   	pop    %ebp
  801b60:	c3                   	ret    

00801b61 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	53                   	push   %ebx
  801b65:	83 ec 20             	sub    $0x20,%esp
  801b68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b6b:	53                   	push   %ebx
  801b6c:	e8 d6 ee ff ff       	call   800a47 <strlen>
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b79:	7f 67                	jg     801be2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b7b:	83 ec 0c             	sub    $0xc,%esp
  801b7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b81:	50                   	push   %eax
  801b82:	e8 8e f8 ff ff       	call   801415 <fd_alloc>
  801b87:	83 c4 10             	add    $0x10,%esp
		return r;
  801b8a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	78 57                	js     801be7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b90:	83 ec 08             	sub    $0x8,%esp
  801b93:	53                   	push   %ebx
  801b94:	68 00 80 80 00       	push   $0x808000
  801b99:	e8 e2 ee ff ff       	call   800a80 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba1:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ba6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ba9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bae:	e8 f6 fd ff ff       	call   8019a9 <fsipc>
  801bb3:	89 c3                	mov    %eax,%ebx
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	79 14                	jns    801bd0 <open+0x6f>
		fd_close(fd, 0);
  801bbc:	83 ec 08             	sub    $0x8,%esp
  801bbf:	6a 00                	push   $0x0
  801bc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc4:	e8 47 f9 ff ff       	call   801510 <fd_close>
		return r;
  801bc9:	83 c4 10             	add    $0x10,%esp
  801bcc:	89 da                	mov    %ebx,%edx
  801bce:	eb 17                	jmp    801be7 <open+0x86>
	}

	return fd2num(fd);
  801bd0:	83 ec 0c             	sub    $0xc,%esp
  801bd3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd6:	e8 13 f8 ff ff       	call   8013ee <fd2num>
  801bdb:	89 c2                	mov    %eax,%edx
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	eb 05                	jmp    801be7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801be2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801be7:	89 d0                	mov    %edx,%eax
  801be9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bec:	c9                   	leave  
  801bed:	c3                   	ret    

00801bee <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bf4:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf9:	b8 08 00 00 00       	mov    $0x8,%eax
  801bfe:	e8 a6 fd ff ff       	call   8019a9 <fsipc>
}
  801c03:	c9                   	leave  
  801c04:	c3                   	ret    

00801c05 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	57                   	push   %edi
  801c09:	56                   	push   %esi
  801c0a:	53                   	push   %ebx
  801c0b:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c11:	6a 00                	push   $0x0
  801c13:	ff 75 08             	pushl  0x8(%ebp)
  801c16:	e8 46 ff ff ff       	call   801b61 <open>
  801c1b:	89 c7                	mov    %eax,%edi
  801c1d:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	85 c0                	test   %eax,%eax
  801c28:	0f 88 8c 04 00 00    	js     8020ba <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c2e:	83 ec 04             	sub    $0x4,%esp
  801c31:	68 00 02 00 00       	push   $0x200
  801c36:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c3c:	50                   	push   %eax
  801c3d:	57                   	push   %edi
  801c3e:	e8 1e fb ff ff       	call   801761 <readn>
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c4b:	75 0c                	jne    801c59 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801c4d:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c54:	45 4c 46 
  801c57:	74 33                	je     801c8c <spawn+0x87>
		close(fd);
  801c59:	83 ec 0c             	sub    $0xc,%esp
  801c5c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c62:	e8 2a f9 ff ff       	call   801591 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c67:	83 c4 0c             	add    $0xc,%esp
  801c6a:	68 7f 45 4c 46       	push   $0x464c457f
  801c6f:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801c75:	68 27 30 80 00       	push   $0x803027
  801c7a:	e8 7c e8 ff ff       	call   8004fb <cprintf>
		return -E_NOT_EXEC;
  801c7f:	83 c4 10             	add    $0x10,%esp
  801c82:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801c87:	e9 e1 04 00 00       	jmp    80216d <spawn+0x568>
  801c8c:	b8 07 00 00 00       	mov    $0x7,%eax
  801c91:	cd 30                	int    $0x30
  801c93:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801c99:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	0f 88 1e 04 00 00    	js     8020c5 <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801ca7:	89 c6                	mov    %eax,%esi
  801ca9:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801caf:	69 f6 d8 00 00 00    	imul   $0xd8,%esi,%esi
  801cb5:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801cbb:	81 c6 59 00 c0 ee    	add    $0xeec00059,%esi
  801cc1:	b9 11 00 00 00       	mov    $0x11,%ecx
  801cc6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801cc8:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801cce:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801cd9:	be 00 00 00 00       	mov    $0x0,%esi
  801cde:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ce1:	eb 13                	jmp    801cf6 <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801ce3:	83 ec 0c             	sub    $0xc,%esp
  801ce6:	50                   	push   %eax
  801ce7:	e8 5b ed ff ff       	call   800a47 <strlen>
  801cec:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801cf0:	83 c3 01             	add    $0x1,%ebx
  801cf3:	83 c4 10             	add    $0x10,%esp
  801cf6:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801cfd:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d00:	85 c0                	test   %eax,%eax
  801d02:	75 df                	jne    801ce3 <spawn+0xde>
  801d04:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801d0a:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d10:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d15:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d17:	89 fa                	mov    %edi,%edx
  801d19:	83 e2 fc             	and    $0xfffffffc,%edx
  801d1c:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d23:	29 c2                	sub    %eax,%edx
  801d25:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d2b:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d2e:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d33:	0f 86 a2 03 00 00    	jbe    8020db <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d39:	83 ec 04             	sub    $0x4,%esp
  801d3c:	6a 07                	push   $0x7
  801d3e:	68 00 00 40 00       	push   $0x400000
  801d43:	6a 00                	push   $0x0
  801d45:	e8 39 f1 ff ff       	call   800e83 <sys_page_alloc>
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	85 c0                	test   %eax,%eax
  801d4f:	0f 88 90 03 00 00    	js     8020e5 <spawn+0x4e0>
  801d55:	be 00 00 00 00       	mov    $0x0,%esi
  801d5a:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d63:	eb 30                	jmp    801d95 <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801d65:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801d6b:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801d71:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801d74:	83 ec 08             	sub    $0x8,%esp
  801d77:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d7a:	57                   	push   %edi
  801d7b:	e8 00 ed ff ff       	call   800a80 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801d80:	83 c4 04             	add    $0x4,%esp
  801d83:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d86:	e8 bc ec ff ff       	call   800a47 <strlen>
  801d8b:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d8f:	83 c6 01             	add    $0x1,%esi
  801d92:	83 c4 10             	add    $0x10,%esp
  801d95:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801d9b:	7f c8                	jg     801d65 <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801d9d:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801da3:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801da9:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801db0:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801db6:	74 19                	je     801dd1 <spawn+0x1cc>
  801db8:	68 b4 30 80 00       	push   $0x8030b4
  801dbd:	68 fb 2f 80 00       	push   $0x802ffb
  801dc2:	68 f2 00 00 00       	push   $0xf2
  801dc7:	68 41 30 80 00       	push   $0x803041
  801dcc:	e8 51 e6 ff ff       	call   800422 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801dd1:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801dd7:	89 f8                	mov    %edi,%eax
  801dd9:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801dde:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801de1:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801de7:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801dea:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801df0:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801df6:	83 ec 0c             	sub    $0xc,%esp
  801df9:	6a 07                	push   $0x7
  801dfb:	68 00 d0 bf ee       	push   $0xeebfd000
  801e00:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e06:	68 00 00 40 00       	push   $0x400000
  801e0b:	6a 00                	push   $0x0
  801e0d:	e8 b4 f0 ff ff       	call   800ec6 <sys_page_map>
  801e12:	89 c3                	mov    %eax,%ebx
  801e14:	83 c4 20             	add    $0x20,%esp
  801e17:	85 c0                	test   %eax,%eax
  801e19:	0f 88 3c 03 00 00    	js     80215b <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e1f:	83 ec 08             	sub    $0x8,%esp
  801e22:	68 00 00 40 00       	push   $0x400000
  801e27:	6a 00                	push   $0x0
  801e29:	e8 da f0 ff ff       	call   800f08 <sys_page_unmap>
  801e2e:	89 c3                	mov    %eax,%ebx
  801e30:	83 c4 10             	add    $0x10,%esp
  801e33:	85 c0                	test   %eax,%eax
  801e35:	0f 88 20 03 00 00    	js     80215b <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e3b:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801e41:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e48:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e4e:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801e55:	00 00 00 
  801e58:	e9 88 01 00 00       	jmp    801fe5 <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  801e5d:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801e63:	83 38 01             	cmpl   $0x1,(%eax)
  801e66:	0f 85 6b 01 00 00    	jne    801fd7 <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e6c:	89 c2                	mov    %eax,%edx
  801e6e:	8b 40 18             	mov    0x18(%eax),%eax
  801e71:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e77:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801e7a:	83 f8 01             	cmp    $0x1,%eax
  801e7d:	19 c0                	sbb    %eax,%eax
  801e7f:	83 e0 fe             	and    $0xfffffffe,%eax
  801e82:	83 c0 07             	add    $0x7,%eax
  801e85:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e8b:	89 d0                	mov    %edx,%eax
  801e8d:	8b 7a 04             	mov    0x4(%edx),%edi
  801e90:	89 f9                	mov    %edi,%ecx
  801e92:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801e98:	8b 7a 10             	mov    0x10(%edx),%edi
  801e9b:	8b 52 14             	mov    0x14(%edx),%edx
  801e9e:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801ea4:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801ea7:	89 f0                	mov    %esi,%eax
  801ea9:	25 ff 0f 00 00       	and    $0xfff,%eax
  801eae:	74 14                	je     801ec4 <spawn+0x2bf>
		va -= i;
  801eb0:	29 c6                	sub    %eax,%esi
		memsz += i;
  801eb2:	01 c2                	add    %eax,%edx
  801eb4:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801eba:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801ebc:	29 c1                	sub    %eax,%ecx
  801ebe:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ec4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ec9:	e9 f7 00 00 00       	jmp    801fc5 <spawn+0x3c0>
		if (i >= filesz) {
  801ece:	39 fb                	cmp    %edi,%ebx
  801ed0:	72 27                	jb     801ef9 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801ed2:	83 ec 04             	sub    $0x4,%esp
  801ed5:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801edb:	56                   	push   %esi
  801edc:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801ee2:	e8 9c ef ff ff       	call   800e83 <sys_page_alloc>
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	85 c0                	test   %eax,%eax
  801eec:	0f 89 c7 00 00 00    	jns    801fb9 <spawn+0x3b4>
  801ef2:	89 c3                	mov    %eax,%ebx
  801ef4:	e9 fd 01 00 00       	jmp    8020f6 <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ef9:	83 ec 04             	sub    $0x4,%esp
  801efc:	6a 07                	push   $0x7
  801efe:	68 00 00 40 00       	push   $0x400000
  801f03:	6a 00                	push   $0x0
  801f05:	e8 79 ef ff ff       	call   800e83 <sys_page_alloc>
  801f0a:	83 c4 10             	add    $0x10,%esp
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	0f 88 d7 01 00 00    	js     8020ec <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f15:	83 ec 08             	sub    $0x8,%esp
  801f18:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f1e:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801f24:	50                   	push   %eax
  801f25:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f2b:	e8 09 f9 ff ff       	call   801839 <seek>
  801f30:	83 c4 10             	add    $0x10,%esp
  801f33:	85 c0                	test   %eax,%eax
  801f35:	0f 88 b5 01 00 00    	js     8020f0 <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f3b:	83 ec 04             	sub    $0x4,%esp
  801f3e:	89 f8                	mov    %edi,%eax
  801f40:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801f46:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f4b:	ba 00 10 00 00       	mov    $0x1000,%edx
  801f50:	0f 47 c2             	cmova  %edx,%eax
  801f53:	50                   	push   %eax
  801f54:	68 00 00 40 00       	push   $0x400000
  801f59:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f5f:	e8 fd f7 ff ff       	call   801761 <readn>
  801f64:	83 c4 10             	add    $0x10,%esp
  801f67:	85 c0                	test   %eax,%eax
  801f69:	0f 88 85 01 00 00    	js     8020f4 <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f6f:	83 ec 0c             	sub    $0xc,%esp
  801f72:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f78:	56                   	push   %esi
  801f79:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f7f:	68 00 00 40 00       	push   $0x400000
  801f84:	6a 00                	push   $0x0
  801f86:	e8 3b ef ff ff       	call   800ec6 <sys_page_map>
  801f8b:	83 c4 20             	add    $0x20,%esp
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	79 15                	jns    801fa7 <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  801f92:	50                   	push   %eax
  801f93:	68 4d 30 80 00       	push   $0x80304d
  801f98:	68 25 01 00 00       	push   $0x125
  801f9d:	68 41 30 80 00       	push   $0x803041
  801fa2:	e8 7b e4 ff ff       	call   800422 <_panic>
			sys_page_unmap(0, UTEMP);
  801fa7:	83 ec 08             	sub    $0x8,%esp
  801faa:	68 00 00 40 00       	push   $0x400000
  801faf:	6a 00                	push   $0x0
  801fb1:	e8 52 ef ff ff       	call   800f08 <sys_page_unmap>
  801fb6:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801fb9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801fbf:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801fc5:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801fcb:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801fd1:	0f 82 f7 fe ff ff    	jb     801ece <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801fd7:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801fde:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801fe5:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801fec:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801ff2:	0f 8c 65 fe ff ff    	jl     801e5d <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801ff8:	83 ec 0c             	sub    $0xc,%esp
  801ffb:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802001:	e8 8b f5 ff ff       	call   801591 <close>
  802006:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802009:	bb 00 00 00 00       	mov    $0x0,%ebx
  80200e:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  802014:	89 d8                	mov    %ebx,%eax
  802016:	c1 e8 16             	shr    $0x16,%eax
  802019:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802020:	a8 01                	test   $0x1,%al
  802022:	74 42                	je     802066 <spawn+0x461>
  802024:	89 d8                	mov    %ebx,%eax
  802026:	c1 e8 0c             	shr    $0xc,%eax
  802029:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802030:	f6 c2 01             	test   $0x1,%dl
  802033:	74 31                	je     802066 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  802035:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  80203c:	f6 c6 04             	test   $0x4,%dh
  80203f:	74 25                	je     802066 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  802041:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802048:	83 ec 0c             	sub    $0xc,%esp
  80204b:	25 07 0e 00 00       	and    $0xe07,%eax
  802050:	50                   	push   %eax
  802051:	53                   	push   %ebx
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	6a 00                	push   $0x0
  802056:	e8 6b ee ff ff       	call   800ec6 <sys_page_map>
			if (r < 0) {
  80205b:	83 c4 20             	add    $0x20,%esp
  80205e:	85 c0                	test   %eax,%eax
  802060:	0f 88 b1 00 00 00    	js     802117 <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802066:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80206c:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802072:	75 a0                	jne    802014 <spawn+0x40f>
  802074:	e9 b3 00 00 00       	jmp    80212c <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802079:	50                   	push   %eax
  80207a:	68 6a 30 80 00       	push   $0x80306a
  80207f:	68 86 00 00 00       	push   $0x86
  802084:	68 41 30 80 00       	push   $0x803041
  802089:	e8 94 e3 ff ff       	call   800422 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80208e:	83 ec 08             	sub    $0x8,%esp
  802091:	6a 02                	push   $0x2
  802093:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802099:	e8 ac ee ff ff       	call   800f4a <sys_env_set_status>
  80209e:	83 c4 10             	add    $0x10,%esp
  8020a1:	85 c0                	test   %eax,%eax
  8020a3:	79 2b                	jns    8020d0 <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  8020a5:	50                   	push   %eax
  8020a6:	68 84 30 80 00       	push   $0x803084
  8020ab:	68 89 00 00 00       	push   $0x89
  8020b0:	68 41 30 80 00       	push   $0x803041
  8020b5:	e8 68 e3 ff ff       	call   800422 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8020ba:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8020c0:	e9 a8 00 00 00       	jmp    80216d <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8020c5:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8020cb:	e9 9d 00 00 00       	jmp    80216d <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8020d0:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8020d6:	e9 92 00 00 00       	jmp    80216d <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8020db:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8020e0:	e9 88 00 00 00       	jmp    80216d <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8020e5:	89 c3                	mov    %eax,%ebx
  8020e7:	e9 81 00 00 00       	jmp    80216d <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020ec:	89 c3                	mov    %eax,%ebx
  8020ee:	eb 06                	jmp    8020f6 <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8020f0:	89 c3                	mov    %eax,%ebx
  8020f2:	eb 02                	jmp    8020f6 <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8020f4:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8020f6:	83 ec 0c             	sub    $0xc,%esp
  8020f9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020ff:	e8 00 ed ff ff       	call   800e04 <sys_env_destroy>
	close(fd);
  802104:	83 c4 04             	add    $0x4,%esp
  802107:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80210d:	e8 7f f4 ff ff       	call   801591 <close>
	return r;
  802112:	83 c4 10             	add    $0x10,%esp
  802115:	eb 56                	jmp    80216d <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802117:	50                   	push   %eax
  802118:	68 9b 30 80 00       	push   $0x80309b
  80211d:	68 82 00 00 00       	push   $0x82
  802122:	68 41 30 80 00       	push   $0x803041
  802127:	e8 f6 e2 ff ff       	call   800422 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  80212c:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802133:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802136:	83 ec 08             	sub    $0x8,%esp
  802139:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80213f:	50                   	push   %eax
  802140:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802146:	e8 41 ee ff ff       	call   800f8c <sys_env_set_trapframe>
  80214b:	83 c4 10             	add    $0x10,%esp
  80214e:	85 c0                	test   %eax,%eax
  802150:	0f 89 38 ff ff ff    	jns    80208e <spawn+0x489>
  802156:	e9 1e ff ff ff       	jmp    802079 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  80215b:	83 ec 08             	sub    $0x8,%esp
  80215e:	68 00 00 40 00       	push   $0x400000
  802163:	6a 00                	push   $0x0
  802165:	e8 9e ed ff ff       	call   800f08 <sys_page_unmap>
  80216a:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80216d:	89 d8                	mov    %ebx,%eax
  80216f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802172:	5b                   	pop    %ebx
  802173:	5e                   	pop    %esi
  802174:	5f                   	pop    %edi
  802175:	5d                   	pop    %ebp
  802176:	c3                   	ret    

00802177 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802177:	55                   	push   %ebp
  802178:	89 e5                	mov    %esp,%ebp
  80217a:	56                   	push   %esi
  80217b:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80217c:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80217f:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802184:	eb 03                	jmp    802189 <spawnl+0x12>
		argc++;
  802186:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802189:	83 c2 04             	add    $0x4,%edx
  80218c:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802190:	75 f4                	jne    802186 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802192:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802199:	83 e2 f0             	and    $0xfffffff0,%edx
  80219c:	29 d4                	sub    %edx,%esp
  80219e:	8d 54 24 03          	lea    0x3(%esp),%edx
  8021a2:	c1 ea 02             	shr    $0x2,%edx
  8021a5:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8021ac:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8021ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021b1:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8021b8:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8021bf:	00 
  8021c0:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8021c7:	eb 0a                	jmp    8021d3 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  8021c9:	83 c0 01             	add    $0x1,%eax
  8021cc:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  8021d0:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021d3:	39 d0                	cmp    %edx,%eax
  8021d5:	75 f2                	jne    8021c9 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8021d7:	83 ec 08             	sub    $0x8,%esp
  8021da:	56                   	push   %esi
  8021db:	ff 75 08             	pushl  0x8(%ebp)
  8021de:	e8 22 fa ff ff       	call   801c05 <spawn>
}
  8021e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021e6:	5b                   	pop    %ebx
  8021e7:	5e                   	pop    %esi
  8021e8:	5d                   	pop    %ebp
  8021e9:	c3                   	ret    

008021ea <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021ea:	55                   	push   %ebp
  8021eb:	89 e5                	mov    %esp,%ebp
  8021ed:	56                   	push   %esi
  8021ee:	53                   	push   %ebx
  8021ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021f2:	83 ec 0c             	sub    $0xc,%esp
  8021f5:	ff 75 08             	pushl  0x8(%ebp)
  8021f8:	e8 01 f2 ff ff       	call   8013fe <fd2data>
  8021fd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8021ff:	83 c4 08             	add    $0x8,%esp
  802202:	68 dc 30 80 00       	push   $0x8030dc
  802207:	53                   	push   %ebx
  802208:	e8 73 e8 ff ff       	call   800a80 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80220d:	8b 46 04             	mov    0x4(%esi),%eax
  802210:	2b 06                	sub    (%esi),%eax
  802212:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802218:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80221f:	00 00 00 
	stat->st_dev = &devpipe;
  802222:	c7 83 88 00 00 00 ac 	movl   $0x8057ac,0x88(%ebx)
  802229:	57 80 00 
	return 0;
}
  80222c:	b8 00 00 00 00       	mov    $0x0,%eax
  802231:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    

00802238 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802238:	55                   	push   %ebp
  802239:	89 e5                	mov    %esp,%ebp
  80223b:	53                   	push   %ebx
  80223c:	83 ec 0c             	sub    $0xc,%esp
  80223f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802242:	53                   	push   %ebx
  802243:	6a 00                	push   $0x0
  802245:	e8 be ec ff ff       	call   800f08 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80224a:	89 1c 24             	mov    %ebx,(%esp)
  80224d:	e8 ac f1 ff ff       	call   8013fe <fd2data>
  802252:	83 c4 08             	add    $0x8,%esp
  802255:	50                   	push   %eax
  802256:	6a 00                	push   $0x0
  802258:	e8 ab ec ff ff       	call   800f08 <sys_page_unmap>
}
  80225d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802260:	c9                   	leave  
  802261:	c3                   	ret    

00802262 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802262:	55                   	push   %ebp
  802263:	89 e5                	mov    %esp,%ebp
  802265:	57                   	push   %edi
  802266:	56                   	push   %esi
  802267:	53                   	push   %ebx
  802268:	83 ec 1c             	sub    $0x1c,%esp
  80226b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80226e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802270:	a1 90 77 80 00       	mov    0x807790,%eax
  802275:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80227b:	83 ec 0c             	sub    $0xc,%esp
  80227e:	ff 75 e0             	pushl  -0x20(%ebp)
  802281:	e8 d2 04 00 00       	call   802758 <pageref>
  802286:	89 c3                	mov    %eax,%ebx
  802288:	89 3c 24             	mov    %edi,(%esp)
  80228b:	e8 c8 04 00 00       	call   802758 <pageref>
  802290:	83 c4 10             	add    $0x10,%esp
  802293:	39 c3                	cmp    %eax,%ebx
  802295:	0f 94 c1             	sete   %cl
  802298:	0f b6 c9             	movzbl %cl,%ecx
  80229b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80229e:	8b 15 90 77 80 00    	mov    0x807790,%edx
  8022a4:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  8022aa:	39 ce                	cmp    %ecx,%esi
  8022ac:	74 1e                	je     8022cc <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8022ae:	39 c3                	cmp    %eax,%ebx
  8022b0:	75 be                	jne    802270 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022b2:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  8022b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8022bb:	50                   	push   %eax
  8022bc:	56                   	push   %esi
  8022bd:	68 e3 30 80 00       	push   $0x8030e3
  8022c2:	e8 34 e2 ff ff       	call   8004fb <cprintf>
  8022c7:	83 c4 10             	add    $0x10,%esp
  8022ca:	eb a4                	jmp    802270 <_pipeisclosed+0xe>
	}
}
  8022cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022d2:	5b                   	pop    %ebx
  8022d3:	5e                   	pop    %esi
  8022d4:	5f                   	pop    %edi
  8022d5:	5d                   	pop    %ebp
  8022d6:	c3                   	ret    

008022d7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022d7:	55                   	push   %ebp
  8022d8:	89 e5                	mov    %esp,%ebp
  8022da:	57                   	push   %edi
  8022db:	56                   	push   %esi
  8022dc:	53                   	push   %ebx
  8022dd:	83 ec 28             	sub    $0x28,%esp
  8022e0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8022e3:	56                   	push   %esi
  8022e4:	e8 15 f1 ff ff       	call   8013fe <fd2data>
  8022e9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022eb:	83 c4 10             	add    $0x10,%esp
  8022ee:	bf 00 00 00 00       	mov    $0x0,%edi
  8022f3:	eb 4b                	jmp    802340 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8022f5:	89 da                	mov    %ebx,%edx
  8022f7:	89 f0                	mov    %esi,%eax
  8022f9:	e8 64 ff ff ff       	call   802262 <_pipeisclosed>
  8022fe:	85 c0                	test   %eax,%eax
  802300:	75 48                	jne    80234a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802302:	e8 5d eb ff ff       	call   800e64 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802307:	8b 43 04             	mov    0x4(%ebx),%eax
  80230a:	8b 0b                	mov    (%ebx),%ecx
  80230c:	8d 51 20             	lea    0x20(%ecx),%edx
  80230f:	39 d0                	cmp    %edx,%eax
  802311:	73 e2                	jae    8022f5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802313:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802316:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80231a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80231d:	89 c2                	mov    %eax,%edx
  80231f:	c1 fa 1f             	sar    $0x1f,%edx
  802322:	89 d1                	mov    %edx,%ecx
  802324:	c1 e9 1b             	shr    $0x1b,%ecx
  802327:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80232a:	83 e2 1f             	and    $0x1f,%edx
  80232d:	29 ca                	sub    %ecx,%edx
  80232f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802333:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802337:	83 c0 01             	add    $0x1,%eax
  80233a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80233d:	83 c7 01             	add    $0x1,%edi
  802340:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802343:	75 c2                	jne    802307 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802345:	8b 45 10             	mov    0x10(%ebp),%eax
  802348:	eb 05                	jmp    80234f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80234a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80234f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802352:	5b                   	pop    %ebx
  802353:	5e                   	pop    %esi
  802354:	5f                   	pop    %edi
  802355:	5d                   	pop    %ebp
  802356:	c3                   	ret    

00802357 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802357:	55                   	push   %ebp
  802358:	89 e5                	mov    %esp,%ebp
  80235a:	57                   	push   %edi
  80235b:	56                   	push   %esi
  80235c:	53                   	push   %ebx
  80235d:	83 ec 18             	sub    $0x18,%esp
  802360:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802363:	57                   	push   %edi
  802364:	e8 95 f0 ff ff       	call   8013fe <fd2data>
  802369:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80236b:	83 c4 10             	add    $0x10,%esp
  80236e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802373:	eb 3d                	jmp    8023b2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802375:	85 db                	test   %ebx,%ebx
  802377:	74 04                	je     80237d <devpipe_read+0x26>
				return i;
  802379:	89 d8                	mov    %ebx,%eax
  80237b:	eb 44                	jmp    8023c1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80237d:	89 f2                	mov    %esi,%edx
  80237f:	89 f8                	mov    %edi,%eax
  802381:	e8 dc fe ff ff       	call   802262 <_pipeisclosed>
  802386:	85 c0                	test   %eax,%eax
  802388:	75 32                	jne    8023bc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80238a:	e8 d5 ea ff ff       	call   800e64 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80238f:	8b 06                	mov    (%esi),%eax
  802391:	3b 46 04             	cmp    0x4(%esi),%eax
  802394:	74 df                	je     802375 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802396:	99                   	cltd   
  802397:	c1 ea 1b             	shr    $0x1b,%edx
  80239a:	01 d0                	add    %edx,%eax
  80239c:	83 e0 1f             	and    $0x1f,%eax
  80239f:	29 d0                	sub    %edx,%eax
  8023a1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8023a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023a9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8023ac:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023af:	83 c3 01             	add    $0x1,%ebx
  8023b2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023b5:	75 d8                	jne    80238f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8023ba:	eb 05                	jmp    8023c1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023bc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023c4:	5b                   	pop    %ebx
  8023c5:	5e                   	pop    %esi
  8023c6:	5f                   	pop    %edi
  8023c7:	5d                   	pop    %ebp
  8023c8:	c3                   	ret    

008023c9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023c9:	55                   	push   %ebp
  8023ca:	89 e5                	mov    %esp,%ebp
  8023cc:	56                   	push   %esi
  8023cd:	53                   	push   %ebx
  8023ce:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d4:	50                   	push   %eax
  8023d5:	e8 3b f0 ff ff       	call   801415 <fd_alloc>
  8023da:	83 c4 10             	add    $0x10,%esp
  8023dd:	89 c2                	mov    %eax,%edx
  8023df:	85 c0                	test   %eax,%eax
  8023e1:	0f 88 2c 01 00 00    	js     802513 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023e7:	83 ec 04             	sub    $0x4,%esp
  8023ea:	68 07 04 00 00       	push   $0x407
  8023ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8023f2:	6a 00                	push   $0x0
  8023f4:	e8 8a ea ff ff       	call   800e83 <sys_page_alloc>
  8023f9:	83 c4 10             	add    $0x10,%esp
  8023fc:	89 c2                	mov    %eax,%edx
  8023fe:	85 c0                	test   %eax,%eax
  802400:	0f 88 0d 01 00 00    	js     802513 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802406:	83 ec 0c             	sub    $0xc,%esp
  802409:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80240c:	50                   	push   %eax
  80240d:	e8 03 f0 ff ff       	call   801415 <fd_alloc>
  802412:	89 c3                	mov    %eax,%ebx
  802414:	83 c4 10             	add    $0x10,%esp
  802417:	85 c0                	test   %eax,%eax
  802419:	0f 88 e2 00 00 00    	js     802501 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80241f:	83 ec 04             	sub    $0x4,%esp
  802422:	68 07 04 00 00       	push   $0x407
  802427:	ff 75 f0             	pushl  -0x10(%ebp)
  80242a:	6a 00                	push   $0x0
  80242c:	e8 52 ea ff ff       	call   800e83 <sys_page_alloc>
  802431:	89 c3                	mov    %eax,%ebx
  802433:	83 c4 10             	add    $0x10,%esp
  802436:	85 c0                	test   %eax,%eax
  802438:	0f 88 c3 00 00 00    	js     802501 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80243e:	83 ec 0c             	sub    $0xc,%esp
  802441:	ff 75 f4             	pushl  -0xc(%ebp)
  802444:	e8 b5 ef ff ff       	call   8013fe <fd2data>
  802449:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80244b:	83 c4 0c             	add    $0xc,%esp
  80244e:	68 07 04 00 00       	push   $0x407
  802453:	50                   	push   %eax
  802454:	6a 00                	push   $0x0
  802456:	e8 28 ea ff ff       	call   800e83 <sys_page_alloc>
  80245b:	89 c3                	mov    %eax,%ebx
  80245d:	83 c4 10             	add    $0x10,%esp
  802460:	85 c0                	test   %eax,%eax
  802462:	0f 88 89 00 00 00    	js     8024f1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802468:	83 ec 0c             	sub    $0xc,%esp
  80246b:	ff 75 f0             	pushl  -0x10(%ebp)
  80246e:	e8 8b ef ff ff       	call   8013fe <fd2data>
  802473:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80247a:	50                   	push   %eax
  80247b:	6a 00                	push   $0x0
  80247d:	56                   	push   %esi
  80247e:	6a 00                	push   $0x0
  802480:	e8 41 ea ff ff       	call   800ec6 <sys_page_map>
  802485:	89 c3                	mov    %eax,%ebx
  802487:	83 c4 20             	add    $0x20,%esp
  80248a:	85 c0                	test   %eax,%eax
  80248c:	78 55                	js     8024e3 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80248e:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  802494:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802497:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802499:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80249c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024a3:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  8024a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024ac:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024b1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024b8:	83 ec 0c             	sub    $0xc,%esp
  8024bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8024be:	e8 2b ef ff ff       	call   8013ee <fd2num>
  8024c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024c6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8024c8:	83 c4 04             	add    $0x4,%esp
  8024cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8024ce:	e8 1b ef ff ff       	call   8013ee <fd2num>
  8024d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024d6:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8024d9:	83 c4 10             	add    $0x10,%esp
  8024dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8024e1:	eb 30                	jmp    802513 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8024e3:	83 ec 08             	sub    $0x8,%esp
  8024e6:	56                   	push   %esi
  8024e7:	6a 00                	push   $0x0
  8024e9:	e8 1a ea ff ff       	call   800f08 <sys_page_unmap>
  8024ee:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8024f1:	83 ec 08             	sub    $0x8,%esp
  8024f4:	ff 75 f0             	pushl  -0x10(%ebp)
  8024f7:	6a 00                	push   $0x0
  8024f9:	e8 0a ea ff ff       	call   800f08 <sys_page_unmap>
  8024fe:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802501:	83 ec 08             	sub    $0x8,%esp
  802504:	ff 75 f4             	pushl  -0xc(%ebp)
  802507:	6a 00                	push   $0x0
  802509:	e8 fa e9 ff ff       	call   800f08 <sys_page_unmap>
  80250e:	83 c4 10             	add    $0x10,%esp
  802511:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802513:	89 d0                	mov    %edx,%eax
  802515:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802518:	5b                   	pop    %ebx
  802519:	5e                   	pop    %esi
  80251a:	5d                   	pop    %ebp
  80251b:	c3                   	ret    

0080251c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80251c:	55                   	push   %ebp
  80251d:	89 e5                	mov    %esp,%ebp
  80251f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802522:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802525:	50                   	push   %eax
  802526:	ff 75 08             	pushl  0x8(%ebp)
  802529:	e8 36 ef ff ff       	call   801464 <fd_lookup>
  80252e:	83 c4 10             	add    $0x10,%esp
  802531:	85 c0                	test   %eax,%eax
  802533:	78 18                	js     80254d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802535:	83 ec 0c             	sub    $0xc,%esp
  802538:	ff 75 f4             	pushl  -0xc(%ebp)
  80253b:	e8 be ee ff ff       	call   8013fe <fd2data>
	return _pipeisclosed(fd, p);
  802540:	89 c2                	mov    %eax,%edx
  802542:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802545:	e8 18 fd ff ff       	call   802262 <_pipeisclosed>
  80254a:	83 c4 10             	add    $0x10,%esp
}
  80254d:	c9                   	leave  
  80254e:	c3                   	ret    

0080254f <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80254f:	55                   	push   %ebp
  802550:	89 e5                	mov    %esp,%ebp
  802552:	56                   	push   %esi
  802553:	53                   	push   %ebx
  802554:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802557:	85 f6                	test   %esi,%esi
  802559:	75 16                	jne    802571 <wait+0x22>
  80255b:	68 fb 30 80 00       	push   $0x8030fb
  802560:	68 fb 2f 80 00       	push   $0x802ffb
  802565:	6a 09                	push   $0x9
  802567:	68 06 31 80 00       	push   $0x803106
  80256c:	e8 b1 de ff ff       	call   800422 <_panic>
	e = &envs[ENVX(envid)];
  802571:	89 f3                	mov    %esi,%ebx
  802573:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802579:	69 db d8 00 00 00    	imul   $0xd8,%ebx,%ebx
  80257f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802585:	eb 05                	jmp    80258c <wait+0x3d>
		sys_yield();
  802587:	e8 d8 e8 ff ff       	call   800e64 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80258c:	8b 83 a4 00 00 00    	mov    0xa4(%ebx),%eax
  802592:	39 c6                	cmp    %eax,%esi
  802594:	75 0a                	jne    8025a0 <wait+0x51>
  802596:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  80259c:	85 c0                	test   %eax,%eax
  80259e:	75 e7                	jne    802587 <wait+0x38>
		sys_yield();
}
  8025a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025a3:	5b                   	pop    %ebx
  8025a4:	5e                   	pop    %esi
  8025a5:	5d                   	pop    %ebp
  8025a6:	c3                   	ret    

008025a7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8025a7:	55                   	push   %ebp
  8025a8:	89 e5                	mov    %esp,%ebp
  8025aa:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8025ad:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  8025b4:	75 2a                	jne    8025e0 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8025b6:	83 ec 04             	sub    $0x4,%esp
  8025b9:	6a 07                	push   $0x7
  8025bb:	68 00 f0 bf ee       	push   $0xeebff000
  8025c0:	6a 00                	push   $0x0
  8025c2:	e8 bc e8 ff ff       	call   800e83 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8025c7:	83 c4 10             	add    $0x10,%esp
  8025ca:	85 c0                	test   %eax,%eax
  8025cc:	79 12                	jns    8025e0 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8025ce:	50                   	push   %eax
  8025cf:	68 03 2b 80 00       	push   $0x802b03
  8025d4:	6a 23                	push   $0x23
  8025d6:	68 11 31 80 00       	push   $0x803111
  8025db:	e8 42 de ff ff       	call   800422 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8025e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8025e3:	a3 00 90 80 00       	mov    %eax,0x809000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8025e8:	83 ec 08             	sub    $0x8,%esp
  8025eb:	68 12 26 80 00       	push   $0x802612
  8025f0:	6a 00                	push   $0x0
  8025f2:	e8 d7 e9 ff ff       	call   800fce <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8025f7:	83 c4 10             	add    $0x10,%esp
  8025fa:	85 c0                	test   %eax,%eax
  8025fc:	79 12                	jns    802610 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8025fe:	50                   	push   %eax
  8025ff:	68 03 2b 80 00       	push   $0x802b03
  802604:	6a 2c                	push   $0x2c
  802606:	68 11 31 80 00       	push   $0x803111
  80260b:	e8 12 de ff ff       	call   800422 <_panic>
	}
}
  802610:	c9                   	leave  
  802611:	c3                   	ret    

00802612 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802612:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802613:	a1 00 90 80 00       	mov    0x809000,%eax
	call *%eax
  802618:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80261a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80261d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802621:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802626:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80262a:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80262c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80262f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802630:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802633:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802634:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802635:	c3                   	ret    

00802636 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802636:	55                   	push   %ebp
  802637:	89 e5                	mov    %esp,%ebp
  802639:	56                   	push   %esi
  80263a:	53                   	push   %ebx
  80263b:	8b 75 08             	mov    0x8(%ebp),%esi
  80263e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802641:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802644:	85 c0                	test   %eax,%eax
  802646:	75 12                	jne    80265a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802648:	83 ec 0c             	sub    $0xc,%esp
  80264b:	68 00 00 c0 ee       	push   $0xeec00000
  802650:	e8 de e9 ff ff       	call   801033 <sys_ipc_recv>
  802655:	83 c4 10             	add    $0x10,%esp
  802658:	eb 0c                	jmp    802666 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80265a:	83 ec 0c             	sub    $0xc,%esp
  80265d:	50                   	push   %eax
  80265e:	e8 d0 e9 ff ff       	call   801033 <sys_ipc_recv>
  802663:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802666:	85 f6                	test   %esi,%esi
  802668:	0f 95 c1             	setne  %cl
  80266b:	85 db                	test   %ebx,%ebx
  80266d:	0f 95 c2             	setne  %dl
  802670:	84 d1                	test   %dl,%cl
  802672:	74 09                	je     80267d <ipc_recv+0x47>
  802674:	89 c2                	mov    %eax,%edx
  802676:	c1 ea 1f             	shr    $0x1f,%edx
  802679:	84 d2                	test   %dl,%dl
  80267b:	75 2d                	jne    8026aa <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80267d:	85 f6                	test   %esi,%esi
  80267f:	74 0d                	je     80268e <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802681:	a1 90 77 80 00       	mov    0x807790,%eax
  802686:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80268c:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80268e:	85 db                	test   %ebx,%ebx
  802690:	74 0d                	je     80269f <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802692:	a1 90 77 80 00       	mov    0x807790,%eax
  802697:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  80269d:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80269f:	a1 90 77 80 00       	mov    0x807790,%eax
  8026a4:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8026aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026ad:	5b                   	pop    %ebx
  8026ae:	5e                   	pop    %esi
  8026af:	5d                   	pop    %ebp
  8026b0:	c3                   	ret    

008026b1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026b1:	55                   	push   %ebp
  8026b2:	89 e5                	mov    %esp,%ebp
  8026b4:	57                   	push   %edi
  8026b5:	56                   	push   %esi
  8026b6:	53                   	push   %ebx
  8026b7:	83 ec 0c             	sub    $0xc,%esp
  8026ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8026c3:	85 db                	test   %ebx,%ebx
  8026c5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8026ca:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8026cd:	ff 75 14             	pushl  0x14(%ebp)
  8026d0:	53                   	push   %ebx
  8026d1:	56                   	push   %esi
  8026d2:	57                   	push   %edi
  8026d3:	e8 38 e9 ff ff       	call   801010 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8026d8:	89 c2                	mov    %eax,%edx
  8026da:	c1 ea 1f             	shr    $0x1f,%edx
  8026dd:	83 c4 10             	add    $0x10,%esp
  8026e0:	84 d2                	test   %dl,%dl
  8026e2:	74 17                	je     8026fb <ipc_send+0x4a>
  8026e4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026e7:	74 12                	je     8026fb <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8026e9:	50                   	push   %eax
  8026ea:	68 1f 31 80 00       	push   $0x80311f
  8026ef:	6a 47                	push   $0x47
  8026f1:	68 2d 31 80 00       	push   $0x80312d
  8026f6:	e8 27 dd ff ff       	call   800422 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8026fb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026fe:	75 07                	jne    802707 <ipc_send+0x56>
			sys_yield();
  802700:	e8 5f e7 ff ff       	call   800e64 <sys_yield>
  802705:	eb c6                	jmp    8026cd <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802707:	85 c0                	test   %eax,%eax
  802709:	75 c2                	jne    8026cd <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80270b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80270e:	5b                   	pop    %ebx
  80270f:	5e                   	pop    %esi
  802710:	5f                   	pop    %edi
  802711:	5d                   	pop    %ebp
  802712:	c3                   	ret    

00802713 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802713:	55                   	push   %ebp
  802714:	89 e5                	mov    %esp,%ebp
  802716:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802719:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80271e:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802724:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80272a:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802730:	39 ca                	cmp    %ecx,%edx
  802732:	75 13                	jne    802747 <ipc_find_env+0x34>
			return envs[i].env_id;
  802734:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80273a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80273f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802745:	eb 0f                	jmp    802756 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802747:	83 c0 01             	add    $0x1,%eax
  80274a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80274f:	75 cd                	jne    80271e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802751:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802756:	5d                   	pop    %ebp
  802757:	c3                   	ret    

00802758 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802758:	55                   	push   %ebp
  802759:	89 e5                	mov    %esp,%ebp
  80275b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80275e:	89 d0                	mov    %edx,%eax
  802760:	c1 e8 16             	shr    $0x16,%eax
  802763:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80276a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80276f:	f6 c1 01             	test   $0x1,%cl
  802772:	74 1d                	je     802791 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802774:	c1 ea 0c             	shr    $0xc,%edx
  802777:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80277e:	f6 c2 01             	test   $0x1,%dl
  802781:	74 0e                	je     802791 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802783:	c1 ea 0c             	shr    $0xc,%edx
  802786:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80278d:	ef 
  80278e:	0f b7 c0             	movzwl %ax,%eax
}
  802791:	5d                   	pop    %ebp
  802792:	c3                   	ret    
  802793:	66 90                	xchg   %ax,%ax
  802795:	66 90                	xchg   %ax,%ax
  802797:	66 90                	xchg   %ax,%ax
  802799:	66 90                	xchg   %ax,%ax
  80279b:	66 90                	xchg   %ax,%ax
  80279d:	66 90                	xchg   %ax,%ax
  80279f:	90                   	nop

008027a0 <__udivdi3>:
  8027a0:	55                   	push   %ebp
  8027a1:	57                   	push   %edi
  8027a2:	56                   	push   %esi
  8027a3:	53                   	push   %ebx
  8027a4:	83 ec 1c             	sub    $0x1c,%esp
  8027a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8027ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8027af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8027b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027b7:	85 f6                	test   %esi,%esi
  8027b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027bd:	89 ca                	mov    %ecx,%edx
  8027bf:	89 f8                	mov    %edi,%eax
  8027c1:	75 3d                	jne    802800 <__udivdi3+0x60>
  8027c3:	39 cf                	cmp    %ecx,%edi
  8027c5:	0f 87 c5 00 00 00    	ja     802890 <__udivdi3+0xf0>
  8027cb:	85 ff                	test   %edi,%edi
  8027cd:	89 fd                	mov    %edi,%ebp
  8027cf:	75 0b                	jne    8027dc <__udivdi3+0x3c>
  8027d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027d6:	31 d2                	xor    %edx,%edx
  8027d8:	f7 f7                	div    %edi
  8027da:	89 c5                	mov    %eax,%ebp
  8027dc:	89 c8                	mov    %ecx,%eax
  8027de:	31 d2                	xor    %edx,%edx
  8027e0:	f7 f5                	div    %ebp
  8027e2:	89 c1                	mov    %eax,%ecx
  8027e4:	89 d8                	mov    %ebx,%eax
  8027e6:	89 cf                	mov    %ecx,%edi
  8027e8:	f7 f5                	div    %ebp
  8027ea:	89 c3                	mov    %eax,%ebx
  8027ec:	89 d8                	mov    %ebx,%eax
  8027ee:	89 fa                	mov    %edi,%edx
  8027f0:	83 c4 1c             	add    $0x1c,%esp
  8027f3:	5b                   	pop    %ebx
  8027f4:	5e                   	pop    %esi
  8027f5:	5f                   	pop    %edi
  8027f6:	5d                   	pop    %ebp
  8027f7:	c3                   	ret    
  8027f8:	90                   	nop
  8027f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802800:	39 ce                	cmp    %ecx,%esi
  802802:	77 74                	ja     802878 <__udivdi3+0xd8>
  802804:	0f bd fe             	bsr    %esi,%edi
  802807:	83 f7 1f             	xor    $0x1f,%edi
  80280a:	0f 84 98 00 00 00    	je     8028a8 <__udivdi3+0x108>
  802810:	bb 20 00 00 00       	mov    $0x20,%ebx
  802815:	89 f9                	mov    %edi,%ecx
  802817:	89 c5                	mov    %eax,%ebp
  802819:	29 fb                	sub    %edi,%ebx
  80281b:	d3 e6                	shl    %cl,%esi
  80281d:	89 d9                	mov    %ebx,%ecx
  80281f:	d3 ed                	shr    %cl,%ebp
  802821:	89 f9                	mov    %edi,%ecx
  802823:	d3 e0                	shl    %cl,%eax
  802825:	09 ee                	or     %ebp,%esi
  802827:	89 d9                	mov    %ebx,%ecx
  802829:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80282d:	89 d5                	mov    %edx,%ebp
  80282f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802833:	d3 ed                	shr    %cl,%ebp
  802835:	89 f9                	mov    %edi,%ecx
  802837:	d3 e2                	shl    %cl,%edx
  802839:	89 d9                	mov    %ebx,%ecx
  80283b:	d3 e8                	shr    %cl,%eax
  80283d:	09 c2                	or     %eax,%edx
  80283f:	89 d0                	mov    %edx,%eax
  802841:	89 ea                	mov    %ebp,%edx
  802843:	f7 f6                	div    %esi
  802845:	89 d5                	mov    %edx,%ebp
  802847:	89 c3                	mov    %eax,%ebx
  802849:	f7 64 24 0c          	mull   0xc(%esp)
  80284d:	39 d5                	cmp    %edx,%ebp
  80284f:	72 10                	jb     802861 <__udivdi3+0xc1>
  802851:	8b 74 24 08          	mov    0x8(%esp),%esi
  802855:	89 f9                	mov    %edi,%ecx
  802857:	d3 e6                	shl    %cl,%esi
  802859:	39 c6                	cmp    %eax,%esi
  80285b:	73 07                	jae    802864 <__udivdi3+0xc4>
  80285d:	39 d5                	cmp    %edx,%ebp
  80285f:	75 03                	jne    802864 <__udivdi3+0xc4>
  802861:	83 eb 01             	sub    $0x1,%ebx
  802864:	31 ff                	xor    %edi,%edi
  802866:	89 d8                	mov    %ebx,%eax
  802868:	89 fa                	mov    %edi,%edx
  80286a:	83 c4 1c             	add    $0x1c,%esp
  80286d:	5b                   	pop    %ebx
  80286e:	5e                   	pop    %esi
  80286f:	5f                   	pop    %edi
  802870:	5d                   	pop    %ebp
  802871:	c3                   	ret    
  802872:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802878:	31 ff                	xor    %edi,%edi
  80287a:	31 db                	xor    %ebx,%ebx
  80287c:	89 d8                	mov    %ebx,%eax
  80287e:	89 fa                	mov    %edi,%edx
  802880:	83 c4 1c             	add    $0x1c,%esp
  802883:	5b                   	pop    %ebx
  802884:	5e                   	pop    %esi
  802885:	5f                   	pop    %edi
  802886:	5d                   	pop    %ebp
  802887:	c3                   	ret    
  802888:	90                   	nop
  802889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802890:	89 d8                	mov    %ebx,%eax
  802892:	f7 f7                	div    %edi
  802894:	31 ff                	xor    %edi,%edi
  802896:	89 c3                	mov    %eax,%ebx
  802898:	89 d8                	mov    %ebx,%eax
  80289a:	89 fa                	mov    %edi,%edx
  80289c:	83 c4 1c             	add    $0x1c,%esp
  80289f:	5b                   	pop    %ebx
  8028a0:	5e                   	pop    %esi
  8028a1:	5f                   	pop    %edi
  8028a2:	5d                   	pop    %ebp
  8028a3:	c3                   	ret    
  8028a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028a8:	39 ce                	cmp    %ecx,%esi
  8028aa:	72 0c                	jb     8028b8 <__udivdi3+0x118>
  8028ac:	31 db                	xor    %ebx,%ebx
  8028ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8028b2:	0f 87 34 ff ff ff    	ja     8027ec <__udivdi3+0x4c>
  8028b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8028bd:	e9 2a ff ff ff       	jmp    8027ec <__udivdi3+0x4c>
  8028c2:	66 90                	xchg   %ax,%ax
  8028c4:	66 90                	xchg   %ax,%ax
  8028c6:	66 90                	xchg   %ax,%ax
  8028c8:	66 90                	xchg   %ax,%ax
  8028ca:	66 90                	xchg   %ax,%ax
  8028cc:	66 90                	xchg   %ax,%ax
  8028ce:	66 90                	xchg   %ax,%ax

008028d0 <__umoddi3>:
  8028d0:	55                   	push   %ebp
  8028d1:	57                   	push   %edi
  8028d2:	56                   	push   %esi
  8028d3:	53                   	push   %ebx
  8028d4:	83 ec 1c             	sub    $0x1c,%esp
  8028d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8028db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8028df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028e7:	85 d2                	test   %edx,%edx
  8028e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028f1:	89 f3                	mov    %esi,%ebx
  8028f3:	89 3c 24             	mov    %edi,(%esp)
  8028f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028fa:	75 1c                	jne    802918 <__umoddi3+0x48>
  8028fc:	39 f7                	cmp    %esi,%edi
  8028fe:	76 50                	jbe    802950 <__umoddi3+0x80>
  802900:	89 c8                	mov    %ecx,%eax
  802902:	89 f2                	mov    %esi,%edx
  802904:	f7 f7                	div    %edi
  802906:	89 d0                	mov    %edx,%eax
  802908:	31 d2                	xor    %edx,%edx
  80290a:	83 c4 1c             	add    $0x1c,%esp
  80290d:	5b                   	pop    %ebx
  80290e:	5e                   	pop    %esi
  80290f:	5f                   	pop    %edi
  802910:	5d                   	pop    %ebp
  802911:	c3                   	ret    
  802912:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802918:	39 f2                	cmp    %esi,%edx
  80291a:	89 d0                	mov    %edx,%eax
  80291c:	77 52                	ja     802970 <__umoddi3+0xa0>
  80291e:	0f bd ea             	bsr    %edx,%ebp
  802921:	83 f5 1f             	xor    $0x1f,%ebp
  802924:	75 5a                	jne    802980 <__umoddi3+0xb0>
  802926:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80292a:	0f 82 e0 00 00 00    	jb     802a10 <__umoddi3+0x140>
  802930:	39 0c 24             	cmp    %ecx,(%esp)
  802933:	0f 86 d7 00 00 00    	jbe    802a10 <__umoddi3+0x140>
  802939:	8b 44 24 08          	mov    0x8(%esp),%eax
  80293d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802941:	83 c4 1c             	add    $0x1c,%esp
  802944:	5b                   	pop    %ebx
  802945:	5e                   	pop    %esi
  802946:	5f                   	pop    %edi
  802947:	5d                   	pop    %ebp
  802948:	c3                   	ret    
  802949:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802950:	85 ff                	test   %edi,%edi
  802952:	89 fd                	mov    %edi,%ebp
  802954:	75 0b                	jne    802961 <__umoddi3+0x91>
  802956:	b8 01 00 00 00       	mov    $0x1,%eax
  80295b:	31 d2                	xor    %edx,%edx
  80295d:	f7 f7                	div    %edi
  80295f:	89 c5                	mov    %eax,%ebp
  802961:	89 f0                	mov    %esi,%eax
  802963:	31 d2                	xor    %edx,%edx
  802965:	f7 f5                	div    %ebp
  802967:	89 c8                	mov    %ecx,%eax
  802969:	f7 f5                	div    %ebp
  80296b:	89 d0                	mov    %edx,%eax
  80296d:	eb 99                	jmp    802908 <__umoddi3+0x38>
  80296f:	90                   	nop
  802970:	89 c8                	mov    %ecx,%eax
  802972:	89 f2                	mov    %esi,%edx
  802974:	83 c4 1c             	add    $0x1c,%esp
  802977:	5b                   	pop    %ebx
  802978:	5e                   	pop    %esi
  802979:	5f                   	pop    %edi
  80297a:	5d                   	pop    %ebp
  80297b:	c3                   	ret    
  80297c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802980:	8b 34 24             	mov    (%esp),%esi
  802983:	bf 20 00 00 00       	mov    $0x20,%edi
  802988:	89 e9                	mov    %ebp,%ecx
  80298a:	29 ef                	sub    %ebp,%edi
  80298c:	d3 e0                	shl    %cl,%eax
  80298e:	89 f9                	mov    %edi,%ecx
  802990:	89 f2                	mov    %esi,%edx
  802992:	d3 ea                	shr    %cl,%edx
  802994:	89 e9                	mov    %ebp,%ecx
  802996:	09 c2                	or     %eax,%edx
  802998:	89 d8                	mov    %ebx,%eax
  80299a:	89 14 24             	mov    %edx,(%esp)
  80299d:	89 f2                	mov    %esi,%edx
  80299f:	d3 e2                	shl    %cl,%edx
  8029a1:	89 f9                	mov    %edi,%ecx
  8029a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029ab:	d3 e8                	shr    %cl,%eax
  8029ad:	89 e9                	mov    %ebp,%ecx
  8029af:	89 c6                	mov    %eax,%esi
  8029b1:	d3 e3                	shl    %cl,%ebx
  8029b3:	89 f9                	mov    %edi,%ecx
  8029b5:	89 d0                	mov    %edx,%eax
  8029b7:	d3 e8                	shr    %cl,%eax
  8029b9:	89 e9                	mov    %ebp,%ecx
  8029bb:	09 d8                	or     %ebx,%eax
  8029bd:	89 d3                	mov    %edx,%ebx
  8029bf:	89 f2                	mov    %esi,%edx
  8029c1:	f7 34 24             	divl   (%esp)
  8029c4:	89 d6                	mov    %edx,%esi
  8029c6:	d3 e3                	shl    %cl,%ebx
  8029c8:	f7 64 24 04          	mull   0x4(%esp)
  8029cc:	39 d6                	cmp    %edx,%esi
  8029ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029d2:	89 d1                	mov    %edx,%ecx
  8029d4:	89 c3                	mov    %eax,%ebx
  8029d6:	72 08                	jb     8029e0 <__umoddi3+0x110>
  8029d8:	75 11                	jne    8029eb <__umoddi3+0x11b>
  8029da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8029de:	73 0b                	jae    8029eb <__umoddi3+0x11b>
  8029e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8029e4:	1b 14 24             	sbb    (%esp),%edx
  8029e7:	89 d1                	mov    %edx,%ecx
  8029e9:	89 c3                	mov    %eax,%ebx
  8029eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8029ef:	29 da                	sub    %ebx,%edx
  8029f1:	19 ce                	sbb    %ecx,%esi
  8029f3:	89 f9                	mov    %edi,%ecx
  8029f5:	89 f0                	mov    %esi,%eax
  8029f7:	d3 e0                	shl    %cl,%eax
  8029f9:	89 e9                	mov    %ebp,%ecx
  8029fb:	d3 ea                	shr    %cl,%edx
  8029fd:	89 e9                	mov    %ebp,%ecx
  8029ff:	d3 ee                	shr    %cl,%esi
  802a01:	09 d0                	or     %edx,%eax
  802a03:	89 f2                	mov    %esi,%edx
  802a05:	83 c4 1c             	add    $0x1c,%esp
  802a08:	5b                   	pop    %ebx
  802a09:	5e                   	pop    %esi
  802a0a:	5f                   	pop    %edi
  802a0b:	5d                   	pop    %ebp
  802a0c:	c3                   	ret    
  802a0d:	8d 76 00             	lea    0x0(%esi),%esi
  802a10:	29 f9                	sub    %edi,%ecx
  802a12:	19 d6                	sbb    %edx,%esi
  802a14:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a1c:	e9 18 ff ff ff       	jmp    802939 <__umoddi3+0x69>
