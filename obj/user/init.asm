
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
  80006d:	68 20 2c 80 00       	push   $0x802c20
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
  80009c:	68 e8 2c 80 00       	push   $0x802ce8
  8000a1:	e8 55 04 00 00       	call   8004fb <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 2f 2c 80 00       	push   $0x802c2f
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
  8000d8:	68 24 2d 80 00       	push   $0x802d24
  8000dd:	e8 19 04 00 00       	call   8004fb <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 46 2c 80 00       	push   $0x802c46
  8000ef:	e8 07 04 00 00       	call   8004fb <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 5c 2c 80 00       	push   $0x802c5c
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
  80011e:	68 68 2c 80 00       	push   $0x802c68
  800123:	56                   	push   %esi
  800124:	e8 77 09 00 00       	call   800aa0 <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 6b 09 00 00       	call   800aa0 <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 69 2c 80 00       	push   $0x802c69
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
  800158:	68 6b 2c 80 00       	push   $0x802c6b
  80015d:	e8 99 03 00 00       	call   8004fb <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 6f 2c 80 00 	movl   $0x802c6f,(%esp)
  800169:	e8 8d 03 00 00       	call   8004fb <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 f7 15 00 00       	call   801771 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 81 2c 80 00       	push   $0x802c81
  80018c:	6a 37                	push   $0x37
  80018e:	68 8e 2c 80 00       	push   $0x802c8e
  800193:	e8 8a 02 00 00       	call   800422 <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 9a 2c 80 00       	push   $0x802c9a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 8e 2c 80 00       	push   $0x802c8e
  8001a9:	e8 74 02 00 00       	call   800422 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 07 16 00 00       	call   8017c1 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 b4 2c 80 00       	push   $0x802cb4
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 8e 2c 80 00       	push   $0x802c8e
  8001ce:	e8 4f 02 00 00       	call   800422 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 bc 2c 80 00       	push   $0x802cbc
  8001db:	e8 1b 03 00 00       	call   8004fb <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 d0 2c 80 00       	push   $0x802cd0
  8001ea:	68 cf 2c 80 00       	push   $0x802ccf
  8001ef:	e8 63 21 00 00       	call   802357 <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 d3 2c 80 00       	push   $0x802cd3
  800204:	e8 f2 02 00 00       	call   8004fb <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 18 25 00 00       	call   80272f <wait>
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
  80022c:	68 53 2d 80 00       	push   $0x802d53
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
  8002fc:	e8 ac 15 00 00       	call   8018ad <read>
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
  800326:	e8 19 13 00 00       	call   801644 <fd_lookup>
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
  80034f:	e8 a1 12 00 00       	call   8015f5 <fd_alloc>
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
  800391:	e8 38 12 00 00       	call   8015ce <fd2num>
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
  8003b4:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8003ba:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003bf:	a3 90 77 80 00       	mov    %eax,0x807790

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
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	83 ec 08             	sub    $0x8,%esp
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
  80040e:	e8 89 13 00 00       	call   80179c <close_all>
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
  800440:	68 6c 2d 80 00       	push   $0x802d6c
  800445:	e8 b1 00 00 00       	call   8004fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80044a:	83 c4 18             	add    $0x18,%esp
  80044d:	53                   	push   %ebx
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	e8 54 00 00 00       	call   8004aa <vcprintf>
	cprintf("\n");
  800456:	c7 04 24 3b 31 80 00 	movl   $0x80313b,(%esp)
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
  80055e:	e8 1d 24 00 00       	call   802980 <__udivdi3>
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
  8005a1:	e8 0a 25 00 00       	call   802ab0 <__umoddi3>
  8005a6:	83 c4 14             	add    $0x14,%esp
  8005a9:	0f be 80 8f 2d 80 00 	movsbl 0x802d8f(%eax),%eax
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
  8006a5:	ff 24 85 e0 2e 80 00 	jmp    *0x802ee0(,%eax,4)
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
  800769:	8b 14 85 40 30 80 00 	mov    0x803040(,%eax,4),%edx
  800770:	85 d2                	test   %edx,%edx
  800772:	75 18                	jne    80078c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800774:	50                   	push   %eax
  800775:	68 a7 2d 80 00       	push   $0x802da7
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
  80078d:	68 fd 31 80 00       	push   $0x8031fd
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
  8007b1:	b8 a0 2d 80 00       	mov    $0x802da0,%eax
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
  800e2c:	68 9f 30 80 00       	push   $0x80309f
  800e31:	6a 23                	push   $0x23
  800e33:	68 bc 30 80 00       	push   $0x8030bc
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
  800ead:	68 9f 30 80 00       	push   $0x80309f
  800eb2:	6a 23                	push   $0x23
  800eb4:	68 bc 30 80 00       	push   $0x8030bc
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
  800eef:	68 9f 30 80 00       	push   $0x80309f
  800ef4:	6a 23                	push   $0x23
  800ef6:	68 bc 30 80 00       	push   $0x8030bc
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
  800f31:	68 9f 30 80 00       	push   $0x80309f
  800f36:	6a 23                	push   $0x23
  800f38:	68 bc 30 80 00       	push   $0x8030bc
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
  800f73:	68 9f 30 80 00       	push   $0x80309f
  800f78:	6a 23                	push   $0x23
  800f7a:	68 bc 30 80 00       	push   $0x8030bc
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
  800fb5:	68 9f 30 80 00       	push   $0x80309f
  800fba:	6a 23                	push   $0x23
  800fbc:	68 bc 30 80 00       	push   $0x8030bc
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
  800ff7:	68 9f 30 80 00       	push   $0x80309f
  800ffc:	6a 23                	push   $0x23
  800ffe:	68 bc 30 80 00       	push   $0x8030bc
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
  80105b:	68 9f 30 80 00       	push   $0x80309f
  801060:	6a 23                	push   $0x23
  801062:	68 bc 30 80 00       	push   $0x8030bc
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
  8010fa:	68 ca 30 80 00       	push   $0x8030ca
  8010ff:	6a 1f                	push   $0x1f
  801101:	68 da 30 80 00       	push   $0x8030da
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
  801124:	68 e5 30 80 00       	push   $0x8030e5
  801129:	6a 2d                	push   $0x2d
  80112b:	68 da 30 80 00       	push   $0x8030da
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
  80116c:	68 e5 30 80 00       	push   $0x8030e5
  801171:	6a 34                	push   $0x34
  801173:	68 da 30 80 00       	push   $0x8030da
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
  801194:	68 e5 30 80 00       	push   $0x8030e5
  801199:	6a 38                	push   $0x38
  80119b:	68 da 30 80 00       	push   $0x8030da
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
  8011b8:	e8 ca 15 00 00       	call   802787 <set_pgfault_handler>
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
  8011d1:	68 fe 30 80 00       	push   $0x8030fe
  8011d6:	68 85 00 00 00       	push   $0x85
  8011db:	68 da 30 80 00       	push   $0x8030da
  8011e0:	e8 3d f2 ff ff       	call   800422 <_panic>
  8011e5:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8011e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011eb:	75 24                	jne    801211 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011ed:	e8 53 fc ff ff       	call   800e45 <sys_getenvid>
  8011f2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011f7:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
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
  80128d:	68 0c 31 80 00       	push   $0x80310c
  801292:	6a 55                	push   $0x55
  801294:	68 da 30 80 00       	push   $0x8030da
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
  8012d2:	68 0c 31 80 00       	push   $0x80310c
  8012d7:	6a 5c                	push   $0x5c
  8012d9:	68 da 30 80 00       	push   $0x8030da
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
  801300:	68 0c 31 80 00       	push   $0x80310c
  801305:	6a 60                	push   $0x60
  801307:	68 da 30 80 00       	push   $0x8030da
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
  80132a:	68 0c 31 80 00       	push   $0x80310c
  80132f:	6a 65                	push   $0x65
  801331:	68 da 30 80 00       	push   $0x8030da
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
  801352:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
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

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  80138d:	8b 45 08             	mov    0x8(%ebp),%eax
  801390:	a3 94 77 80 00       	mov    %eax,0x807794
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801395:	68 e8 03 80 00       	push   $0x8003e8
  80139a:	e8 d5 fc ff ff       	call   801074 <sys_thread_create>

	return id;
}
  80139f:	c9                   	leave  
  8013a0:	c3                   	ret    

008013a1 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8013a7:	ff 75 08             	pushl  0x8(%ebp)
  8013aa:	e8 e5 fc ff ff       	call   801094 <sys_thread_free>
}
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	c9                   	leave  
  8013b3:	c3                   	ret    

008013b4 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8013ba:	ff 75 08             	pushl  0x8(%ebp)
  8013bd:	e8 f2 fc ff ff       	call   8010b4 <sys_thread_join>
}
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	c9                   	leave  
  8013c6:	c3                   	ret    

008013c7 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	56                   	push   %esi
  8013cb:	53                   	push   %ebx
  8013cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8013cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8013d2:	83 ec 04             	sub    $0x4,%esp
  8013d5:	6a 07                	push   $0x7
  8013d7:	6a 00                	push   $0x0
  8013d9:	56                   	push   %esi
  8013da:	e8 a4 fa ff ff       	call   800e83 <sys_page_alloc>
	if (r < 0) {
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	79 15                	jns    8013fb <queue_append+0x34>
		panic("%e\n", r);
  8013e6:	50                   	push   %eax
  8013e7:	68 e3 2c 80 00       	push   $0x802ce3
  8013ec:	68 d5 00 00 00       	push   $0xd5
  8013f1:	68 da 30 80 00       	push   $0x8030da
  8013f6:	e8 27 f0 ff ff       	call   800422 <_panic>
	}	

	wt->envid = envid;
  8013fb:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  801401:	83 3b 00             	cmpl   $0x0,(%ebx)
  801404:	75 13                	jne    801419 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  801406:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80140d:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801414:	00 00 00 
  801417:	eb 1b                	jmp    801434 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801419:	8b 43 04             	mov    0x4(%ebx),%eax
  80141c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801423:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80142a:	00 00 00 
		queue->last = wt;
  80142d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801434:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801437:	5b                   	pop    %ebx
  801438:	5e                   	pop    %esi
  801439:	5d                   	pop    %ebp
  80143a:	c3                   	ret    

0080143b <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	83 ec 08             	sub    $0x8,%esp
  801441:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  801444:	8b 02                	mov    (%edx),%eax
  801446:	85 c0                	test   %eax,%eax
  801448:	75 17                	jne    801461 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  80144a:	83 ec 04             	sub    $0x4,%esp
  80144d:	68 22 31 80 00       	push   $0x803122
  801452:	68 ec 00 00 00       	push   $0xec
  801457:	68 da 30 80 00       	push   $0x8030da
  80145c:	e8 c1 ef ff ff       	call   800422 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801461:	8b 48 04             	mov    0x4(%eax),%ecx
  801464:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  801466:	8b 00                	mov    (%eax),%eax
}
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	53                   	push   %ebx
  80146e:	83 ec 04             	sub    $0x4,%esp
  801471:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801474:	b8 01 00 00 00       	mov    $0x1,%eax
  801479:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  80147c:	85 c0                	test   %eax,%eax
  80147e:	74 45                	je     8014c5 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  801480:	e8 c0 f9 ff ff       	call   800e45 <sys_getenvid>
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	83 c3 04             	add    $0x4,%ebx
  80148b:	53                   	push   %ebx
  80148c:	50                   	push   %eax
  80148d:	e8 35 ff ff ff       	call   8013c7 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801492:	e8 ae f9 ff ff       	call   800e45 <sys_getenvid>
  801497:	83 c4 08             	add    $0x8,%esp
  80149a:	6a 04                	push   $0x4
  80149c:	50                   	push   %eax
  80149d:	e8 a8 fa ff ff       	call   800f4a <sys_env_set_status>

		if (r < 0) {
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	79 15                	jns    8014be <mutex_lock+0x54>
			panic("%e\n", r);
  8014a9:	50                   	push   %eax
  8014aa:	68 e3 2c 80 00       	push   $0x802ce3
  8014af:	68 02 01 00 00       	push   $0x102
  8014b4:	68 da 30 80 00       	push   $0x8030da
  8014b9:	e8 64 ef ff ff       	call   800422 <_panic>
		}
		sys_yield();
  8014be:	e8 a1 f9 ff ff       	call   800e64 <sys_yield>
  8014c3:	eb 08                	jmp    8014cd <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8014c5:	e8 7b f9 ff ff       	call   800e45 <sys_getenvid>
  8014ca:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8014cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d0:	c9                   	leave  
  8014d1:	c3                   	ret    

008014d2 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	53                   	push   %ebx
  8014d6:	83 ec 04             	sub    $0x4,%esp
  8014d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8014dc:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8014e0:	74 36                	je     801518 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8014e2:	83 ec 0c             	sub    $0xc,%esp
  8014e5:	8d 43 04             	lea    0x4(%ebx),%eax
  8014e8:	50                   	push   %eax
  8014e9:	e8 4d ff ff ff       	call   80143b <queue_pop>
  8014ee:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8014f1:	83 c4 08             	add    $0x8,%esp
  8014f4:	6a 02                	push   $0x2
  8014f6:	50                   	push   %eax
  8014f7:	e8 4e fa ff ff       	call   800f4a <sys_env_set_status>
		if (r < 0) {
  8014fc:	83 c4 10             	add    $0x10,%esp
  8014ff:	85 c0                	test   %eax,%eax
  801501:	79 1d                	jns    801520 <mutex_unlock+0x4e>
			panic("%e\n", r);
  801503:	50                   	push   %eax
  801504:	68 e3 2c 80 00       	push   $0x802ce3
  801509:	68 16 01 00 00       	push   $0x116
  80150e:	68 da 30 80 00       	push   $0x8030da
  801513:	e8 0a ef ff ff       	call   800422 <_panic>
  801518:	b8 00 00 00 00       	mov    $0x0,%eax
  80151d:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  801520:	e8 3f f9 ff ff       	call   800e64 <sys_yield>
}
  801525:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	53                   	push   %ebx
  80152e:	83 ec 04             	sub    $0x4,%esp
  801531:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801534:	e8 0c f9 ff ff       	call   800e45 <sys_getenvid>
  801539:	83 ec 04             	sub    $0x4,%esp
  80153c:	6a 07                	push   $0x7
  80153e:	53                   	push   %ebx
  80153f:	50                   	push   %eax
  801540:	e8 3e f9 ff ff       	call   800e83 <sys_page_alloc>
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	85 c0                	test   %eax,%eax
  80154a:	79 15                	jns    801561 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80154c:	50                   	push   %eax
  80154d:	68 3d 31 80 00       	push   $0x80313d
  801552:	68 23 01 00 00       	push   $0x123
  801557:	68 da 30 80 00       	push   $0x8030da
  80155c:	e8 c1 ee ff ff       	call   800422 <_panic>
	}	
	mtx->locked = 0;
  801561:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  801567:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  80156e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  801575:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  80157c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157f:	c9                   	leave  
  801580:	c3                   	ret    

00801581 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	56                   	push   %esi
  801585:	53                   	push   %ebx
  801586:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801589:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  80158c:	eb 20                	jmp    8015ae <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  80158e:	83 ec 0c             	sub    $0xc,%esp
  801591:	56                   	push   %esi
  801592:	e8 a4 fe ff ff       	call   80143b <queue_pop>
  801597:	83 c4 08             	add    $0x8,%esp
  80159a:	6a 02                	push   $0x2
  80159c:	50                   	push   %eax
  80159d:	e8 a8 f9 ff ff       	call   800f4a <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8015a2:	8b 43 04             	mov    0x4(%ebx),%eax
  8015a5:	8b 40 04             	mov    0x4(%eax),%eax
  8015a8:	89 43 04             	mov    %eax,0x4(%ebx)
  8015ab:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8015ae:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8015b2:	75 da                	jne    80158e <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8015b4:	83 ec 04             	sub    $0x4,%esp
  8015b7:	68 00 10 00 00       	push   $0x1000
  8015bc:	6a 00                	push   $0x0
  8015be:	53                   	push   %ebx
  8015bf:	e8 01 f6 ff ff       	call   800bc5 <memset>
	mtx = NULL;
}
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ca:	5b                   	pop    %ebx
  8015cb:	5e                   	pop    %esi
  8015cc:	5d                   	pop    %ebp
  8015cd:	c3                   	ret    

008015ce <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d4:	05 00 00 00 30       	add    $0x30000000,%eax
  8015d9:	c1 e8 0c             	shr    $0xc,%eax
}
  8015dc:	5d                   	pop    %ebp
  8015dd:	c3                   	ret    

008015de <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8015e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e4:	05 00 00 00 30       	add    $0x30000000,%eax
  8015e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8015ee:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8015f3:	5d                   	pop    %ebp
  8015f4:	c3                   	ret    

008015f5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015fb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801600:	89 c2                	mov    %eax,%edx
  801602:	c1 ea 16             	shr    $0x16,%edx
  801605:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80160c:	f6 c2 01             	test   $0x1,%dl
  80160f:	74 11                	je     801622 <fd_alloc+0x2d>
  801611:	89 c2                	mov    %eax,%edx
  801613:	c1 ea 0c             	shr    $0xc,%edx
  801616:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80161d:	f6 c2 01             	test   $0x1,%dl
  801620:	75 09                	jne    80162b <fd_alloc+0x36>
			*fd_store = fd;
  801622:	89 01                	mov    %eax,(%ecx)
			return 0;
  801624:	b8 00 00 00 00       	mov    $0x0,%eax
  801629:	eb 17                	jmp    801642 <fd_alloc+0x4d>
  80162b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801630:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801635:	75 c9                	jne    801600 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801637:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80163d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801642:	5d                   	pop    %ebp
  801643:	c3                   	ret    

00801644 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80164a:	83 f8 1f             	cmp    $0x1f,%eax
  80164d:	77 36                	ja     801685 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80164f:	c1 e0 0c             	shl    $0xc,%eax
  801652:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801657:	89 c2                	mov    %eax,%edx
  801659:	c1 ea 16             	shr    $0x16,%edx
  80165c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801663:	f6 c2 01             	test   $0x1,%dl
  801666:	74 24                	je     80168c <fd_lookup+0x48>
  801668:	89 c2                	mov    %eax,%edx
  80166a:	c1 ea 0c             	shr    $0xc,%edx
  80166d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801674:	f6 c2 01             	test   $0x1,%dl
  801677:	74 1a                	je     801693 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801679:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167c:	89 02                	mov    %eax,(%edx)
	return 0;
  80167e:	b8 00 00 00 00       	mov    $0x0,%eax
  801683:	eb 13                	jmp    801698 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801685:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80168a:	eb 0c                	jmp    801698 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80168c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801691:	eb 05                	jmp    801698 <fd_lookup+0x54>
  801693:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801698:	5d                   	pop    %ebp
  801699:	c3                   	ret    

0080169a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	83 ec 08             	sub    $0x8,%esp
  8016a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a3:	ba d4 31 80 00       	mov    $0x8031d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8016a8:	eb 13                	jmp    8016bd <dev_lookup+0x23>
  8016aa:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8016ad:	39 08                	cmp    %ecx,(%eax)
  8016af:	75 0c                	jne    8016bd <dev_lookup+0x23>
			*dev = devtab[i];
  8016b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8016b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bb:	eb 31                	jmp    8016ee <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016bd:	8b 02                	mov    (%edx),%eax
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	75 e7                	jne    8016aa <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8016c3:	a1 90 77 80 00       	mov    0x807790,%eax
  8016c8:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8016ce:	83 ec 04             	sub    $0x4,%esp
  8016d1:	51                   	push   %ecx
  8016d2:	50                   	push   %eax
  8016d3:	68 58 31 80 00       	push   $0x803158
  8016d8:	e8 1e ee ff ff       	call   8004fb <cprintf>
	*dev = 0;
  8016dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 10             	sub    $0x10,%esp
  8016f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8016fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8016fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801701:	50                   	push   %eax
  801702:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801708:	c1 e8 0c             	shr    $0xc,%eax
  80170b:	50                   	push   %eax
  80170c:	e8 33 ff ff ff       	call   801644 <fd_lookup>
  801711:	83 c4 08             	add    $0x8,%esp
  801714:	85 c0                	test   %eax,%eax
  801716:	78 05                	js     80171d <fd_close+0x2d>
	    || fd != fd2)
  801718:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80171b:	74 0c                	je     801729 <fd_close+0x39>
		return (must_exist ? r : 0);
  80171d:	84 db                	test   %bl,%bl
  80171f:	ba 00 00 00 00       	mov    $0x0,%edx
  801724:	0f 44 c2             	cmove  %edx,%eax
  801727:	eb 41                	jmp    80176a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801729:	83 ec 08             	sub    $0x8,%esp
  80172c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172f:	50                   	push   %eax
  801730:	ff 36                	pushl  (%esi)
  801732:	e8 63 ff ff ff       	call   80169a <dev_lookup>
  801737:	89 c3                	mov    %eax,%ebx
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 1a                	js     80175a <fd_close+0x6a>
		if (dev->dev_close)
  801740:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801743:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801746:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80174b:	85 c0                	test   %eax,%eax
  80174d:	74 0b                	je     80175a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80174f:	83 ec 0c             	sub    $0xc,%esp
  801752:	56                   	push   %esi
  801753:	ff d0                	call   *%eax
  801755:	89 c3                	mov    %eax,%ebx
  801757:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80175a:	83 ec 08             	sub    $0x8,%esp
  80175d:	56                   	push   %esi
  80175e:	6a 00                	push   $0x0
  801760:	e8 a3 f7 ff ff       	call   800f08 <sys_page_unmap>
	return r;
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	89 d8                	mov    %ebx,%eax
}
  80176a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176d:	5b                   	pop    %ebx
  80176e:	5e                   	pop    %esi
  80176f:	5d                   	pop    %ebp
  801770:	c3                   	ret    

00801771 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801777:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177a:	50                   	push   %eax
  80177b:	ff 75 08             	pushl  0x8(%ebp)
  80177e:	e8 c1 fe ff ff       	call   801644 <fd_lookup>
  801783:	83 c4 08             	add    $0x8,%esp
  801786:	85 c0                	test   %eax,%eax
  801788:	78 10                	js     80179a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80178a:	83 ec 08             	sub    $0x8,%esp
  80178d:	6a 01                	push   $0x1
  80178f:	ff 75 f4             	pushl  -0xc(%ebp)
  801792:	e8 59 ff ff ff       	call   8016f0 <fd_close>
  801797:	83 c4 10             	add    $0x10,%esp
}
  80179a:	c9                   	leave  
  80179b:	c3                   	ret    

0080179c <close_all>:

void
close_all(void)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	53                   	push   %ebx
  8017a0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8017a3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8017a8:	83 ec 0c             	sub    $0xc,%esp
  8017ab:	53                   	push   %ebx
  8017ac:	e8 c0 ff ff ff       	call   801771 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8017b1:	83 c3 01             	add    $0x1,%ebx
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	83 fb 20             	cmp    $0x20,%ebx
  8017ba:	75 ec                	jne    8017a8 <close_all+0xc>
		close(i);
}
  8017bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017bf:	c9                   	leave  
  8017c0:	c3                   	ret    

008017c1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	57                   	push   %edi
  8017c5:	56                   	push   %esi
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 2c             	sub    $0x2c,%esp
  8017ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8017cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017d0:	50                   	push   %eax
  8017d1:	ff 75 08             	pushl  0x8(%ebp)
  8017d4:	e8 6b fe ff ff       	call   801644 <fd_lookup>
  8017d9:	83 c4 08             	add    $0x8,%esp
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	0f 88 c1 00 00 00    	js     8018a5 <dup+0xe4>
		return r;
	close(newfdnum);
  8017e4:	83 ec 0c             	sub    $0xc,%esp
  8017e7:	56                   	push   %esi
  8017e8:	e8 84 ff ff ff       	call   801771 <close>

	newfd = INDEX2FD(newfdnum);
  8017ed:	89 f3                	mov    %esi,%ebx
  8017ef:	c1 e3 0c             	shl    $0xc,%ebx
  8017f2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8017f8:	83 c4 04             	add    $0x4,%esp
  8017fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017fe:	e8 db fd ff ff       	call   8015de <fd2data>
  801803:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801805:	89 1c 24             	mov    %ebx,(%esp)
  801808:	e8 d1 fd ff ff       	call   8015de <fd2data>
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801813:	89 f8                	mov    %edi,%eax
  801815:	c1 e8 16             	shr    $0x16,%eax
  801818:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80181f:	a8 01                	test   $0x1,%al
  801821:	74 37                	je     80185a <dup+0x99>
  801823:	89 f8                	mov    %edi,%eax
  801825:	c1 e8 0c             	shr    $0xc,%eax
  801828:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80182f:	f6 c2 01             	test   $0x1,%dl
  801832:	74 26                	je     80185a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801834:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80183b:	83 ec 0c             	sub    $0xc,%esp
  80183e:	25 07 0e 00 00       	and    $0xe07,%eax
  801843:	50                   	push   %eax
  801844:	ff 75 d4             	pushl  -0x2c(%ebp)
  801847:	6a 00                	push   $0x0
  801849:	57                   	push   %edi
  80184a:	6a 00                	push   $0x0
  80184c:	e8 75 f6 ff ff       	call   800ec6 <sys_page_map>
  801851:	89 c7                	mov    %eax,%edi
  801853:	83 c4 20             	add    $0x20,%esp
  801856:	85 c0                	test   %eax,%eax
  801858:	78 2e                	js     801888 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80185a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80185d:	89 d0                	mov    %edx,%eax
  80185f:	c1 e8 0c             	shr    $0xc,%eax
  801862:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801869:	83 ec 0c             	sub    $0xc,%esp
  80186c:	25 07 0e 00 00       	and    $0xe07,%eax
  801871:	50                   	push   %eax
  801872:	53                   	push   %ebx
  801873:	6a 00                	push   $0x0
  801875:	52                   	push   %edx
  801876:	6a 00                	push   $0x0
  801878:	e8 49 f6 ff ff       	call   800ec6 <sys_page_map>
  80187d:	89 c7                	mov    %eax,%edi
  80187f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801882:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801884:	85 ff                	test   %edi,%edi
  801886:	79 1d                	jns    8018a5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	53                   	push   %ebx
  80188c:	6a 00                	push   $0x0
  80188e:	e8 75 f6 ff ff       	call   800f08 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801893:	83 c4 08             	add    $0x8,%esp
  801896:	ff 75 d4             	pushl  -0x2c(%ebp)
  801899:	6a 00                	push   $0x0
  80189b:	e8 68 f6 ff ff       	call   800f08 <sys_page_unmap>
	return r;
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	89 f8                	mov    %edi,%eax
}
  8018a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a8:	5b                   	pop    %ebx
  8018a9:	5e                   	pop    %esi
  8018aa:	5f                   	pop    %edi
  8018ab:	5d                   	pop    %ebp
  8018ac:	c3                   	ret    

008018ad <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	53                   	push   %ebx
  8018b1:	83 ec 14             	sub    $0x14,%esp
  8018b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ba:	50                   	push   %eax
  8018bb:	53                   	push   %ebx
  8018bc:	e8 83 fd ff ff       	call   801644 <fd_lookup>
  8018c1:	83 c4 08             	add    $0x8,%esp
  8018c4:	89 c2                	mov    %eax,%edx
  8018c6:	85 c0                	test   %eax,%eax
  8018c8:	78 70                	js     80193a <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ca:	83 ec 08             	sub    $0x8,%esp
  8018cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d0:	50                   	push   %eax
  8018d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d4:	ff 30                	pushl  (%eax)
  8018d6:	e8 bf fd ff ff       	call   80169a <dev_lookup>
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	78 4f                	js     801931 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8018e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018e5:	8b 42 08             	mov    0x8(%edx),%eax
  8018e8:	83 e0 03             	and    $0x3,%eax
  8018eb:	83 f8 01             	cmp    $0x1,%eax
  8018ee:	75 24                	jne    801914 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8018f0:	a1 90 77 80 00       	mov    0x807790,%eax
  8018f5:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8018fb:	83 ec 04             	sub    $0x4,%esp
  8018fe:	53                   	push   %ebx
  8018ff:	50                   	push   %eax
  801900:	68 99 31 80 00       	push   $0x803199
  801905:	e8 f1 eb ff ff       	call   8004fb <cprintf>
		return -E_INVAL;
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801912:	eb 26                	jmp    80193a <read+0x8d>
	}
	if (!dev->dev_read)
  801914:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801917:	8b 40 08             	mov    0x8(%eax),%eax
  80191a:	85 c0                	test   %eax,%eax
  80191c:	74 17                	je     801935 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80191e:	83 ec 04             	sub    $0x4,%esp
  801921:	ff 75 10             	pushl  0x10(%ebp)
  801924:	ff 75 0c             	pushl  0xc(%ebp)
  801927:	52                   	push   %edx
  801928:	ff d0                	call   *%eax
  80192a:	89 c2                	mov    %eax,%edx
  80192c:	83 c4 10             	add    $0x10,%esp
  80192f:	eb 09                	jmp    80193a <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801931:	89 c2                	mov    %eax,%edx
  801933:	eb 05                	jmp    80193a <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801935:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80193a:	89 d0                	mov    %edx,%eax
  80193c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193f:	c9                   	leave  
  801940:	c3                   	ret    

00801941 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	57                   	push   %edi
  801945:	56                   	push   %esi
  801946:	53                   	push   %ebx
  801947:	83 ec 0c             	sub    $0xc,%esp
  80194a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80194d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801950:	bb 00 00 00 00       	mov    $0x0,%ebx
  801955:	eb 21                	jmp    801978 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801957:	83 ec 04             	sub    $0x4,%esp
  80195a:	89 f0                	mov    %esi,%eax
  80195c:	29 d8                	sub    %ebx,%eax
  80195e:	50                   	push   %eax
  80195f:	89 d8                	mov    %ebx,%eax
  801961:	03 45 0c             	add    0xc(%ebp),%eax
  801964:	50                   	push   %eax
  801965:	57                   	push   %edi
  801966:	e8 42 ff ff ff       	call   8018ad <read>
		if (m < 0)
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 10                	js     801982 <readn+0x41>
			return m;
		if (m == 0)
  801972:	85 c0                	test   %eax,%eax
  801974:	74 0a                	je     801980 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801976:	01 c3                	add    %eax,%ebx
  801978:	39 f3                	cmp    %esi,%ebx
  80197a:	72 db                	jb     801957 <readn+0x16>
  80197c:	89 d8                	mov    %ebx,%eax
  80197e:	eb 02                	jmp    801982 <readn+0x41>
  801980:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801982:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801985:	5b                   	pop    %ebx
  801986:	5e                   	pop    %esi
  801987:	5f                   	pop    %edi
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    

0080198a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	53                   	push   %ebx
  80198e:	83 ec 14             	sub    $0x14,%esp
  801991:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801994:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801997:	50                   	push   %eax
  801998:	53                   	push   %ebx
  801999:	e8 a6 fc ff ff       	call   801644 <fd_lookup>
  80199e:	83 c4 08             	add    $0x8,%esp
  8019a1:	89 c2                	mov    %eax,%edx
  8019a3:	85 c0                	test   %eax,%eax
  8019a5:	78 6b                	js     801a12 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019a7:	83 ec 08             	sub    $0x8,%esp
  8019aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ad:	50                   	push   %eax
  8019ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b1:	ff 30                	pushl  (%eax)
  8019b3:	e8 e2 fc ff ff       	call   80169a <dev_lookup>
  8019b8:	83 c4 10             	add    $0x10,%esp
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	78 4a                	js     801a09 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019c6:	75 24                	jne    8019ec <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8019c8:	a1 90 77 80 00       	mov    0x807790,%eax
  8019cd:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8019d3:	83 ec 04             	sub    $0x4,%esp
  8019d6:	53                   	push   %ebx
  8019d7:	50                   	push   %eax
  8019d8:	68 b5 31 80 00       	push   $0x8031b5
  8019dd:	e8 19 eb ff ff       	call   8004fb <cprintf>
		return -E_INVAL;
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8019ea:	eb 26                	jmp    801a12 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8019ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019ef:	8b 52 0c             	mov    0xc(%edx),%edx
  8019f2:	85 d2                	test   %edx,%edx
  8019f4:	74 17                	je     801a0d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8019f6:	83 ec 04             	sub    $0x4,%esp
  8019f9:	ff 75 10             	pushl  0x10(%ebp)
  8019fc:	ff 75 0c             	pushl  0xc(%ebp)
  8019ff:	50                   	push   %eax
  801a00:	ff d2                	call   *%edx
  801a02:	89 c2                	mov    %eax,%edx
  801a04:	83 c4 10             	add    $0x10,%esp
  801a07:	eb 09                	jmp    801a12 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a09:	89 c2                	mov    %eax,%edx
  801a0b:	eb 05                	jmp    801a12 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801a0d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801a12:	89 d0                	mov    %edx,%eax
  801a14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a17:	c9                   	leave  
  801a18:	c3                   	ret    

00801a19 <seek>:

int
seek(int fdnum, off_t offset)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a1f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a22:	50                   	push   %eax
  801a23:	ff 75 08             	pushl  0x8(%ebp)
  801a26:	e8 19 fc ff ff       	call   801644 <fd_lookup>
  801a2b:	83 c4 08             	add    $0x8,%esp
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	78 0e                	js     801a40 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801a32:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a35:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a38:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801a3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a40:	c9                   	leave  
  801a41:	c3                   	ret    

00801a42 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	53                   	push   %ebx
  801a46:	83 ec 14             	sub    $0x14,%esp
  801a49:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a4c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a4f:	50                   	push   %eax
  801a50:	53                   	push   %ebx
  801a51:	e8 ee fb ff ff       	call   801644 <fd_lookup>
  801a56:	83 c4 08             	add    $0x8,%esp
  801a59:	89 c2                	mov    %eax,%edx
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	78 68                	js     801ac7 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a5f:	83 ec 08             	sub    $0x8,%esp
  801a62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a65:	50                   	push   %eax
  801a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a69:	ff 30                	pushl  (%eax)
  801a6b:	e8 2a fc ff ff       	call   80169a <dev_lookup>
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 47                	js     801abe <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a7a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a7e:	75 24                	jne    801aa4 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801a80:	a1 90 77 80 00       	mov    0x807790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a85:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801a8b:	83 ec 04             	sub    $0x4,%esp
  801a8e:	53                   	push   %ebx
  801a8f:	50                   	push   %eax
  801a90:	68 78 31 80 00       	push   $0x803178
  801a95:	e8 61 ea ff ff       	call   8004fb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801aa2:	eb 23                	jmp    801ac7 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801aa4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aa7:	8b 52 18             	mov    0x18(%edx),%edx
  801aaa:	85 d2                	test   %edx,%edx
  801aac:	74 14                	je     801ac2 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801aae:	83 ec 08             	sub    $0x8,%esp
  801ab1:	ff 75 0c             	pushl  0xc(%ebp)
  801ab4:	50                   	push   %eax
  801ab5:	ff d2                	call   *%edx
  801ab7:	89 c2                	mov    %eax,%edx
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	eb 09                	jmp    801ac7 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801abe:	89 c2                	mov    %eax,%edx
  801ac0:	eb 05                	jmp    801ac7 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801ac2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801ac7:	89 d0                	mov    %edx,%eax
  801ac9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    

00801ace <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	53                   	push   %ebx
  801ad2:	83 ec 14             	sub    $0x14,%esp
  801ad5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ad8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801adb:	50                   	push   %eax
  801adc:	ff 75 08             	pushl  0x8(%ebp)
  801adf:	e8 60 fb ff ff       	call   801644 <fd_lookup>
  801ae4:	83 c4 08             	add    $0x8,%esp
  801ae7:	89 c2                	mov    %eax,%edx
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	78 58                	js     801b45 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801aed:	83 ec 08             	sub    $0x8,%esp
  801af0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af3:	50                   	push   %eax
  801af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801af7:	ff 30                	pushl  (%eax)
  801af9:	e8 9c fb ff ff       	call   80169a <dev_lookup>
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	85 c0                	test   %eax,%eax
  801b03:	78 37                	js     801b3c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b08:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b0c:	74 32                	je     801b40 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b0e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b11:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b18:	00 00 00 
	stat->st_isdir = 0;
  801b1b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b22:	00 00 00 
	stat->st_dev = dev;
  801b25:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b2b:	83 ec 08             	sub    $0x8,%esp
  801b2e:	53                   	push   %ebx
  801b2f:	ff 75 f0             	pushl  -0x10(%ebp)
  801b32:	ff 50 14             	call   *0x14(%eax)
  801b35:	89 c2                	mov    %eax,%edx
  801b37:	83 c4 10             	add    $0x10,%esp
  801b3a:	eb 09                	jmp    801b45 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b3c:	89 c2                	mov    %eax,%edx
  801b3e:	eb 05                	jmp    801b45 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801b40:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801b45:	89 d0                	mov    %edx,%eax
  801b47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	56                   	push   %esi
  801b50:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b51:	83 ec 08             	sub    $0x8,%esp
  801b54:	6a 00                	push   $0x0
  801b56:	ff 75 08             	pushl  0x8(%ebp)
  801b59:	e8 e3 01 00 00       	call   801d41 <open>
  801b5e:	89 c3                	mov    %eax,%ebx
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 1b                	js     801b82 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801b67:	83 ec 08             	sub    $0x8,%esp
  801b6a:	ff 75 0c             	pushl  0xc(%ebp)
  801b6d:	50                   	push   %eax
  801b6e:	e8 5b ff ff ff       	call   801ace <fstat>
  801b73:	89 c6                	mov    %eax,%esi
	close(fd);
  801b75:	89 1c 24             	mov    %ebx,(%esp)
  801b78:	e8 f4 fb ff ff       	call   801771 <close>
	return r;
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	89 f0                	mov    %esi,%eax
}
  801b82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5e                   	pop    %esi
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	56                   	push   %esi
  801b8d:	53                   	push   %ebx
  801b8e:	89 c6                	mov    %eax,%esi
  801b90:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801b92:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801b99:	75 12                	jne    801bad <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b9b:	83 ec 0c             	sub    $0xc,%esp
  801b9e:	6a 01                	push   $0x1
  801ba0:	e8 4e 0d 00 00       	call   8028f3 <ipc_find_env>
  801ba5:	a3 00 60 80 00       	mov    %eax,0x806000
  801baa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801bad:	6a 07                	push   $0x7
  801baf:	68 00 80 80 00       	push   $0x808000
  801bb4:	56                   	push   %esi
  801bb5:	ff 35 00 60 80 00    	pushl  0x806000
  801bbb:	e8 d1 0c 00 00       	call   802891 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801bc0:	83 c4 0c             	add    $0xc,%esp
  801bc3:	6a 00                	push   $0x0
  801bc5:	53                   	push   %ebx
  801bc6:	6a 00                	push   $0x0
  801bc8:	e8 49 0c 00 00       	call   802816 <ipc_recv>
}
  801bcd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd0:	5b                   	pop    %ebx
  801bd1:	5e                   	pop    %esi
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    

00801bd4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801bda:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdd:	8b 40 0c             	mov    0xc(%eax),%eax
  801be0:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  801be5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be8:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801bed:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf2:	b8 02 00 00 00       	mov    $0x2,%eax
  801bf7:	e8 8d ff ff ff       	call   801b89 <fsipc>
}
  801bfc:	c9                   	leave  
  801bfd:	c3                   	ret    

00801bfe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c04:	8b 45 08             	mov    0x8(%ebp),%eax
  801c07:	8b 40 0c             	mov    0xc(%eax),%eax
  801c0a:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  801c0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c14:	b8 06 00 00 00       	mov    $0x6,%eax
  801c19:	e8 6b ff ff ff       	call   801b89 <fsipc>
}
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    

00801c20 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	53                   	push   %ebx
  801c24:	83 ec 04             	sub    $0x4,%esp
  801c27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2d:	8b 40 0c             	mov    0xc(%eax),%eax
  801c30:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c35:	ba 00 00 00 00       	mov    $0x0,%edx
  801c3a:	b8 05 00 00 00       	mov    $0x5,%eax
  801c3f:	e8 45 ff ff ff       	call   801b89 <fsipc>
  801c44:	85 c0                	test   %eax,%eax
  801c46:	78 2c                	js     801c74 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c48:	83 ec 08             	sub    $0x8,%esp
  801c4b:	68 00 80 80 00       	push   $0x808000
  801c50:	53                   	push   %ebx
  801c51:	e8 2a ee ff ff       	call   800a80 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c56:	a1 80 80 80 00       	mov    0x808080,%eax
  801c5b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c61:	a1 84 80 80 00       	mov    0x808084,%eax
  801c66:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    

00801c79 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	83 ec 0c             	sub    $0xc,%esp
  801c7f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c82:	8b 55 08             	mov    0x8(%ebp),%edx
  801c85:	8b 52 0c             	mov    0xc(%edx),%edx
  801c88:	89 15 00 80 80 00    	mov    %edx,0x808000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801c8e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c93:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801c98:	0f 47 c2             	cmova  %edx,%eax
  801c9b:	a3 04 80 80 00       	mov    %eax,0x808004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801ca0:	50                   	push   %eax
  801ca1:	ff 75 0c             	pushl  0xc(%ebp)
  801ca4:	68 08 80 80 00       	push   $0x808008
  801ca9:	e8 64 ef ff ff       	call   800c12 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801cae:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb3:	b8 04 00 00 00       	mov    $0x4,%eax
  801cb8:	e8 cc fe ff ff       	call   801b89 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801cbd:	c9                   	leave  
  801cbe:	c3                   	ret    

00801cbf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cca:	8b 40 0c             	mov    0xc(%eax),%eax
  801ccd:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  801cd2:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801cd8:	ba 00 00 00 00       	mov    $0x0,%edx
  801cdd:	b8 03 00 00 00       	mov    $0x3,%eax
  801ce2:	e8 a2 fe ff ff       	call   801b89 <fsipc>
  801ce7:	89 c3                	mov    %eax,%ebx
  801ce9:	85 c0                	test   %eax,%eax
  801ceb:	78 4b                	js     801d38 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801ced:	39 c6                	cmp    %eax,%esi
  801cef:	73 16                	jae    801d07 <devfile_read+0x48>
  801cf1:	68 e4 31 80 00       	push   $0x8031e4
  801cf6:	68 eb 31 80 00       	push   $0x8031eb
  801cfb:	6a 7c                	push   $0x7c
  801cfd:	68 00 32 80 00       	push   $0x803200
  801d02:	e8 1b e7 ff ff       	call   800422 <_panic>
	assert(r <= PGSIZE);
  801d07:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d0c:	7e 16                	jle    801d24 <devfile_read+0x65>
  801d0e:	68 0b 32 80 00       	push   $0x80320b
  801d13:	68 eb 31 80 00       	push   $0x8031eb
  801d18:	6a 7d                	push   $0x7d
  801d1a:	68 00 32 80 00       	push   $0x803200
  801d1f:	e8 fe e6 ff ff       	call   800422 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801d24:	83 ec 04             	sub    $0x4,%esp
  801d27:	50                   	push   %eax
  801d28:	68 00 80 80 00       	push   $0x808000
  801d2d:	ff 75 0c             	pushl  0xc(%ebp)
  801d30:	e8 dd ee ff ff       	call   800c12 <memmove>
	return r;
  801d35:	83 c4 10             	add    $0x10,%esp
}
  801d38:	89 d8                	mov    %ebx,%eax
  801d3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    

00801d41 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	53                   	push   %ebx
  801d45:	83 ec 20             	sub    $0x20,%esp
  801d48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801d4b:	53                   	push   %ebx
  801d4c:	e8 f6 ec ff ff       	call   800a47 <strlen>
  801d51:	83 c4 10             	add    $0x10,%esp
  801d54:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d59:	7f 67                	jg     801dc2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d5b:	83 ec 0c             	sub    $0xc,%esp
  801d5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d61:	50                   	push   %eax
  801d62:	e8 8e f8 ff ff       	call   8015f5 <fd_alloc>
  801d67:	83 c4 10             	add    $0x10,%esp
		return r;
  801d6a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d6c:	85 c0                	test   %eax,%eax
  801d6e:	78 57                	js     801dc7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d70:	83 ec 08             	sub    $0x8,%esp
  801d73:	53                   	push   %ebx
  801d74:	68 00 80 80 00       	push   $0x808000
  801d79:	e8 02 ed ff ff       	call   800a80 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d81:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d89:	b8 01 00 00 00       	mov    $0x1,%eax
  801d8e:	e8 f6 fd ff ff       	call   801b89 <fsipc>
  801d93:	89 c3                	mov    %eax,%ebx
  801d95:	83 c4 10             	add    $0x10,%esp
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	79 14                	jns    801db0 <open+0x6f>
		fd_close(fd, 0);
  801d9c:	83 ec 08             	sub    $0x8,%esp
  801d9f:	6a 00                	push   $0x0
  801da1:	ff 75 f4             	pushl  -0xc(%ebp)
  801da4:	e8 47 f9 ff ff       	call   8016f0 <fd_close>
		return r;
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	89 da                	mov    %ebx,%edx
  801dae:	eb 17                	jmp    801dc7 <open+0x86>
	}

	return fd2num(fd);
  801db0:	83 ec 0c             	sub    $0xc,%esp
  801db3:	ff 75 f4             	pushl  -0xc(%ebp)
  801db6:	e8 13 f8 ff ff       	call   8015ce <fd2num>
  801dbb:	89 c2                	mov    %eax,%edx
  801dbd:	83 c4 10             	add    $0x10,%esp
  801dc0:	eb 05                	jmp    801dc7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801dc2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801dc7:	89 d0                	mov    %edx,%eax
  801dc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dcc:	c9                   	leave  
  801dcd:	c3                   	ret    

00801dce <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801dd4:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd9:	b8 08 00 00 00       	mov    $0x8,%eax
  801dde:	e8 a6 fd ff ff       	call   801b89 <fsipc>
}
  801de3:	c9                   	leave  
  801de4:	c3                   	ret    

00801de5 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	57                   	push   %edi
  801de9:	56                   	push   %esi
  801dea:	53                   	push   %ebx
  801deb:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801df1:	6a 00                	push   $0x0
  801df3:	ff 75 08             	pushl  0x8(%ebp)
  801df6:	e8 46 ff ff ff       	call   801d41 <open>
  801dfb:	89 c7                	mov    %eax,%edi
  801dfd:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	85 c0                	test   %eax,%eax
  801e08:	0f 88 8c 04 00 00    	js     80229a <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801e0e:	83 ec 04             	sub    $0x4,%esp
  801e11:	68 00 02 00 00       	push   $0x200
  801e16:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801e1c:	50                   	push   %eax
  801e1d:	57                   	push   %edi
  801e1e:	e8 1e fb ff ff       	call   801941 <readn>
  801e23:	83 c4 10             	add    $0x10,%esp
  801e26:	3d 00 02 00 00       	cmp    $0x200,%eax
  801e2b:	75 0c                	jne    801e39 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801e2d:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801e34:	45 4c 46 
  801e37:	74 33                	je     801e6c <spawn+0x87>
		close(fd);
  801e39:	83 ec 0c             	sub    $0xc,%esp
  801e3c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e42:	e8 2a f9 ff ff       	call   801771 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801e47:	83 c4 0c             	add    $0xc,%esp
  801e4a:	68 7f 45 4c 46       	push   $0x464c457f
  801e4f:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801e55:	68 17 32 80 00       	push   $0x803217
  801e5a:	e8 9c e6 ff ff       	call   8004fb <cprintf>
		return -E_NOT_EXEC;
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801e67:	e9 e1 04 00 00       	jmp    80234d <spawn+0x568>
  801e6c:	b8 07 00 00 00       	mov    $0x7,%eax
  801e71:	cd 30                	int    $0x30
  801e73:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801e79:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801e7f:	85 c0                	test   %eax,%eax
  801e81:	0f 88 1e 04 00 00    	js     8022a5 <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801e87:	89 c6                	mov    %eax,%esi
  801e89:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801e8f:	69 f6 d4 00 00 00    	imul   $0xd4,%esi,%esi
  801e95:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801e9b:	81 c6 58 00 c0 ee    	add    $0xeec00058,%esi
  801ea1:	b9 11 00 00 00       	mov    $0x11,%ecx
  801ea6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801ea8:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801eae:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801eb4:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801eb9:	be 00 00 00 00       	mov    $0x0,%esi
  801ebe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ec1:	eb 13                	jmp    801ed6 <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	50                   	push   %eax
  801ec7:	e8 7b eb ff ff       	call   800a47 <strlen>
  801ecc:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ed0:	83 c3 01             	add    $0x1,%ebx
  801ed3:	83 c4 10             	add    $0x10,%esp
  801ed6:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801edd:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	75 df                	jne    801ec3 <spawn+0xde>
  801ee4:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801eea:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801ef0:	bf 00 10 40 00       	mov    $0x401000,%edi
  801ef5:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801ef7:	89 fa                	mov    %edi,%edx
  801ef9:	83 e2 fc             	and    $0xfffffffc,%edx
  801efc:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801f03:	29 c2                	sub    %eax,%edx
  801f05:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801f0b:	8d 42 f8             	lea    -0x8(%edx),%eax
  801f0e:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801f13:	0f 86 a2 03 00 00    	jbe    8022bb <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f19:	83 ec 04             	sub    $0x4,%esp
  801f1c:	6a 07                	push   $0x7
  801f1e:	68 00 00 40 00       	push   $0x400000
  801f23:	6a 00                	push   $0x0
  801f25:	e8 59 ef ff ff       	call   800e83 <sys_page_alloc>
  801f2a:	83 c4 10             	add    $0x10,%esp
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	0f 88 90 03 00 00    	js     8022c5 <spawn+0x4e0>
  801f35:	be 00 00 00 00       	mov    $0x0,%esi
  801f3a:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801f40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f43:	eb 30                	jmp    801f75 <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801f45:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801f4b:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801f51:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801f54:	83 ec 08             	sub    $0x8,%esp
  801f57:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801f5a:	57                   	push   %edi
  801f5b:	e8 20 eb ff ff       	call   800a80 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801f60:	83 c4 04             	add    $0x4,%esp
  801f63:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801f66:	e8 dc ea ff ff       	call   800a47 <strlen>
  801f6b:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801f6f:	83 c6 01             	add    $0x1,%esi
  801f72:	83 c4 10             	add    $0x10,%esp
  801f75:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801f7b:	7f c8                	jg     801f45 <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801f7d:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801f83:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801f89:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801f90:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801f96:	74 19                	je     801fb1 <spawn+0x1cc>
  801f98:	68 a4 32 80 00       	push   $0x8032a4
  801f9d:	68 eb 31 80 00       	push   $0x8031eb
  801fa2:	68 f2 00 00 00       	push   $0xf2
  801fa7:	68 31 32 80 00       	push   $0x803231
  801fac:	e8 71 e4 ff ff       	call   800422 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801fb1:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801fb7:	89 f8                	mov    %edi,%eax
  801fb9:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801fbe:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801fc1:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801fc7:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801fca:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801fd0:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801fd6:	83 ec 0c             	sub    $0xc,%esp
  801fd9:	6a 07                	push   $0x7
  801fdb:	68 00 d0 bf ee       	push   $0xeebfd000
  801fe0:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801fe6:	68 00 00 40 00       	push   $0x400000
  801feb:	6a 00                	push   $0x0
  801fed:	e8 d4 ee ff ff       	call   800ec6 <sys_page_map>
  801ff2:	89 c3                	mov    %eax,%ebx
  801ff4:	83 c4 20             	add    $0x20,%esp
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	0f 88 3c 03 00 00    	js     80233b <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801fff:	83 ec 08             	sub    $0x8,%esp
  802002:	68 00 00 40 00       	push   $0x400000
  802007:	6a 00                	push   $0x0
  802009:	e8 fa ee ff ff       	call   800f08 <sys_page_unmap>
  80200e:	89 c3                	mov    %eax,%ebx
  802010:	83 c4 10             	add    $0x10,%esp
  802013:	85 c0                	test   %eax,%eax
  802015:	0f 88 20 03 00 00    	js     80233b <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80201b:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802021:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802028:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80202e:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802035:	00 00 00 
  802038:	e9 88 01 00 00       	jmp    8021c5 <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  80203d:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802043:	83 38 01             	cmpl   $0x1,(%eax)
  802046:	0f 85 6b 01 00 00    	jne    8021b7 <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80204c:	89 c2                	mov    %eax,%edx
  80204e:	8b 40 18             	mov    0x18(%eax),%eax
  802051:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802057:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  80205a:	83 f8 01             	cmp    $0x1,%eax
  80205d:	19 c0                	sbb    %eax,%eax
  80205f:	83 e0 fe             	and    $0xfffffffe,%eax
  802062:	83 c0 07             	add    $0x7,%eax
  802065:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80206b:	89 d0                	mov    %edx,%eax
  80206d:	8b 7a 04             	mov    0x4(%edx),%edi
  802070:	89 f9                	mov    %edi,%ecx
  802072:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  802078:	8b 7a 10             	mov    0x10(%edx),%edi
  80207b:	8b 52 14             	mov    0x14(%edx),%edx
  80207e:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  802084:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802087:	89 f0                	mov    %esi,%eax
  802089:	25 ff 0f 00 00       	and    $0xfff,%eax
  80208e:	74 14                	je     8020a4 <spawn+0x2bf>
		va -= i;
  802090:	29 c6                	sub    %eax,%esi
		memsz += i;
  802092:	01 c2                	add    %eax,%edx
  802094:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  80209a:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80209c:	29 c1                	sub    %eax,%ecx
  80209e:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8020a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020a9:	e9 f7 00 00 00       	jmp    8021a5 <spawn+0x3c0>
		if (i >= filesz) {
  8020ae:	39 fb                	cmp    %edi,%ebx
  8020b0:	72 27                	jb     8020d9 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8020b2:	83 ec 04             	sub    $0x4,%esp
  8020b5:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8020bb:	56                   	push   %esi
  8020bc:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8020c2:	e8 bc ed ff ff       	call   800e83 <sys_page_alloc>
  8020c7:	83 c4 10             	add    $0x10,%esp
  8020ca:	85 c0                	test   %eax,%eax
  8020cc:	0f 89 c7 00 00 00    	jns    802199 <spawn+0x3b4>
  8020d2:	89 c3                	mov    %eax,%ebx
  8020d4:	e9 fd 01 00 00       	jmp    8022d6 <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020d9:	83 ec 04             	sub    $0x4,%esp
  8020dc:	6a 07                	push   $0x7
  8020de:	68 00 00 40 00       	push   $0x400000
  8020e3:	6a 00                	push   $0x0
  8020e5:	e8 99 ed ff ff       	call   800e83 <sys_page_alloc>
  8020ea:	83 c4 10             	add    $0x10,%esp
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	0f 88 d7 01 00 00    	js     8022cc <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8020f5:	83 ec 08             	sub    $0x8,%esp
  8020f8:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8020fe:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802104:	50                   	push   %eax
  802105:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80210b:	e8 09 f9 ff ff       	call   801a19 <seek>
  802110:	83 c4 10             	add    $0x10,%esp
  802113:	85 c0                	test   %eax,%eax
  802115:	0f 88 b5 01 00 00    	js     8022d0 <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80211b:	83 ec 04             	sub    $0x4,%esp
  80211e:	89 f8                	mov    %edi,%eax
  802120:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  802126:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80212b:	ba 00 10 00 00       	mov    $0x1000,%edx
  802130:	0f 47 c2             	cmova  %edx,%eax
  802133:	50                   	push   %eax
  802134:	68 00 00 40 00       	push   $0x400000
  802139:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80213f:	e8 fd f7 ff ff       	call   801941 <readn>
  802144:	83 c4 10             	add    $0x10,%esp
  802147:	85 c0                	test   %eax,%eax
  802149:	0f 88 85 01 00 00    	js     8022d4 <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80214f:	83 ec 0c             	sub    $0xc,%esp
  802152:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802158:	56                   	push   %esi
  802159:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80215f:	68 00 00 40 00       	push   $0x400000
  802164:	6a 00                	push   $0x0
  802166:	e8 5b ed ff ff       	call   800ec6 <sys_page_map>
  80216b:	83 c4 20             	add    $0x20,%esp
  80216e:	85 c0                	test   %eax,%eax
  802170:	79 15                	jns    802187 <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  802172:	50                   	push   %eax
  802173:	68 3d 32 80 00       	push   $0x80323d
  802178:	68 25 01 00 00       	push   $0x125
  80217d:	68 31 32 80 00       	push   $0x803231
  802182:	e8 9b e2 ff ff       	call   800422 <_panic>
			sys_page_unmap(0, UTEMP);
  802187:	83 ec 08             	sub    $0x8,%esp
  80218a:	68 00 00 40 00       	push   $0x400000
  80218f:	6a 00                	push   $0x0
  802191:	e8 72 ed ff ff       	call   800f08 <sys_page_unmap>
  802196:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802199:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80219f:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8021a5:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8021ab:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8021b1:	0f 82 f7 fe ff ff    	jb     8020ae <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8021b7:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8021be:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8021c5:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8021cc:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8021d2:	0f 8c 65 fe ff ff    	jl     80203d <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8021d8:	83 ec 0c             	sub    $0xc,%esp
  8021db:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8021e1:	e8 8b f5 ff ff       	call   801771 <close>
  8021e6:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  8021e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021ee:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  8021f4:	89 d8                	mov    %ebx,%eax
  8021f6:	c1 e8 16             	shr    $0x16,%eax
  8021f9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802200:	a8 01                	test   $0x1,%al
  802202:	74 42                	je     802246 <spawn+0x461>
  802204:	89 d8                	mov    %ebx,%eax
  802206:	c1 e8 0c             	shr    $0xc,%eax
  802209:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802210:	f6 c2 01             	test   $0x1,%dl
  802213:	74 31                	je     802246 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  802215:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  80221c:	f6 c6 04             	test   $0x4,%dh
  80221f:	74 25                	je     802246 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  802221:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802228:	83 ec 0c             	sub    $0xc,%esp
  80222b:	25 07 0e 00 00       	and    $0xe07,%eax
  802230:	50                   	push   %eax
  802231:	53                   	push   %ebx
  802232:	56                   	push   %esi
  802233:	53                   	push   %ebx
  802234:	6a 00                	push   $0x0
  802236:	e8 8b ec ff ff       	call   800ec6 <sys_page_map>
			if (r < 0) {
  80223b:	83 c4 20             	add    $0x20,%esp
  80223e:	85 c0                	test   %eax,%eax
  802240:	0f 88 b1 00 00 00    	js     8022f7 <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802246:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80224c:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802252:	75 a0                	jne    8021f4 <spawn+0x40f>
  802254:	e9 b3 00 00 00       	jmp    80230c <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802259:	50                   	push   %eax
  80225a:	68 5a 32 80 00       	push   $0x80325a
  80225f:	68 86 00 00 00       	push   $0x86
  802264:	68 31 32 80 00       	push   $0x803231
  802269:	e8 b4 e1 ff ff       	call   800422 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80226e:	83 ec 08             	sub    $0x8,%esp
  802271:	6a 02                	push   $0x2
  802273:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802279:	e8 cc ec ff ff       	call   800f4a <sys_env_set_status>
  80227e:	83 c4 10             	add    $0x10,%esp
  802281:	85 c0                	test   %eax,%eax
  802283:	79 2b                	jns    8022b0 <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  802285:	50                   	push   %eax
  802286:	68 74 32 80 00       	push   $0x803274
  80228b:	68 89 00 00 00       	push   $0x89
  802290:	68 31 32 80 00       	push   $0x803231
  802295:	e8 88 e1 ff ff       	call   800422 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80229a:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8022a0:	e9 a8 00 00 00       	jmp    80234d <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8022a5:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8022ab:	e9 9d 00 00 00       	jmp    80234d <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8022b0:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8022b6:	e9 92 00 00 00       	jmp    80234d <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8022bb:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8022c0:	e9 88 00 00 00       	jmp    80234d <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8022c5:	89 c3                	mov    %eax,%ebx
  8022c7:	e9 81 00 00 00       	jmp    80234d <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8022cc:	89 c3                	mov    %eax,%ebx
  8022ce:	eb 06                	jmp    8022d6 <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8022d0:	89 c3                	mov    %eax,%ebx
  8022d2:	eb 02                	jmp    8022d6 <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8022d4:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8022d6:	83 ec 0c             	sub    $0xc,%esp
  8022d9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8022df:	e8 20 eb ff ff       	call   800e04 <sys_env_destroy>
	close(fd);
  8022e4:	83 c4 04             	add    $0x4,%esp
  8022e7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8022ed:	e8 7f f4 ff ff       	call   801771 <close>
	return r;
  8022f2:	83 c4 10             	add    $0x10,%esp
  8022f5:	eb 56                	jmp    80234d <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  8022f7:	50                   	push   %eax
  8022f8:	68 8b 32 80 00       	push   $0x80328b
  8022fd:	68 82 00 00 00       	push   $0x82
  802302:	68 31 32 80 00       	push   $0x803231
  802307:	e8 16 e1 ff ff       	call   800422 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  80230c:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802313:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802316:	83 ec 08             	sub    $0x8,%esp
  802319:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80231f:	50                   	push   %eax
  802320:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802326:	e8 61 ec ff ff       	call   800f8c <sys_env_set_trapframe>
  80232b:	83 c4 10             	add    $0x10,%esp
  80232e:	85 c0                	test   %eax,%eax
  802330:	0f 89 38 ff ff ff    	jns    80226e <spawn+0x489>
  802336:	e9 1e ff ff ff       	jmp    802259 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  80233b:	83 ec 08             	sub    $0x8,%esp
  80233e:	68 00 00 40 00       	push   $0x400000
  802343:	6a 00                	push   $0x0
  802345:	e8 be eb ff ff       	call   800f08 <sys_page_unmap>
  80234a:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80234d:	89 d8                	mov    %ebx,%eax
  80234f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802352:	5b                   	pop    %ebx
  802353:	5e                   	pop    %esi
  802354:	5f                   	pop    %edi
  802355:	5d                   	pop    %ebp
  802356:	c3                   	ret    

00802357 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802357:	55                   	push   %ebp
  802358:	89 e5                	mov    %esp,%ebp
  80235a:	56                   	push   %esi
  80235b:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80235c:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80235f:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802364:	eb 03                	jmp    802369 <spawnl+0x12>
		argc++;
  802366:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802369:	83 c2 04             	add    $0x4,%edx
  80236c:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802370:	75 f4                	jne    802366 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802372:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802379:	83 e2 f0             	and    $0xfffffff0,%edx
  80237c:	29 d4                	sub    %edx,%esp
  80237e:	8d 54 24 03          	lea    0x3(%esp),%edx
  802382:	c1 ea 02             	shr    $0x2,%edx
  802385:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  80238c:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  80238e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802391:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802398:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  80239f:	00 
  8023a0:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8023a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8023a7:	eb 0a                	jmp    8023b3 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  8023a9:	83 c0 01             	add    $0x1,%eax
  8023ac:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  8023b0:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8023b3:	39 d0                	cmp    %edx,%eax
  8023b5:	75 f2                	jne    8023a9 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8023b7:	83 ec 08             	sub    $0x8,%esp
  8023ba:	56                   	push   %esi
  8023bb:	ff 75 08             	pushl  0x8(%ebp)
  8023be:	e8 22 fa ff ff       	call   801de5 <spawn>
}
  8023c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023c6:	5b                   	pop    %ebx
  8023c7:	5e                   	pop    %esi
  8023c8:	5d                   	pop    %ebp
  8023c9:	c3                   	ret    

008023ca <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8023ca:	55                   	push   %ebp
  8023cb:	89 e5                	mov    %esp,%ebp
  8023cd:	56                   	push   %esi
  8023ce:	53                   	push   %ebx
  8023cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8023d2:	83 ec 0c             	sub    $0xc,%esp
  8023d5:	ff 75 08             	pushl  0x8(%ebp)
  8023d8:	e8 01 f2 ff ff       	call   8015de <fd2data>
  8023dd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8023df:	83 c4 08             	add    $0x8,%esp
  8023e2:	68 cc 32 80 00       	push   $0x8032cc
  8023e7:	53                   	push   %ebx
  8023e8:	e8 93 e6 ff ff       	call   800a80 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8023ed:	8b 46 04             	mov    0x4(%esi),%eax
  8023f0:	2b 06                	sub    (%esi),%eax
  8023f2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8023f8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8023ff:	00 00 00 
	stat->st_dev = &devpipe;
  802402:	c7 83 88 00 00 00 ac 	movl   $0x8057ac,0x88(%ebx)
  802409:	57 80 00 
	return 0;
}
  80240c:	b8 00 00 00 00       	mov    $0x0,%eax
  802411:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802414:	5b                   	pop    %ebx
  802415:	5e                   	pop    %esi
  802416:	5d                   	pop    %ebp
  802417:	c3                   	ret    

00802418 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802418:	55                   	push   %ebp
  802419:	89 e5                	mov    %esp,%ebp
  80241b:	53                   	push   %ebx
  80241c:	83 ec 0c             	sub    $0xc,%esp
  80241f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802422:	53                   	push   %ebx
  802423:	6a 00                	push   $0x0
  802425:	e8 de ea ff ff       	call   800f08 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80242a:	89 1c 24             	mov    %ebx,(%esp)
  80242d:	e8 ac f1 ff ff       	call   8015de <fd2data>
  802432:	83 c4 08             	add    $0x8,%esp
  802435:	50                   	push   %eax
  802436:	6a 00                	push   $0x0
  802438:	e8 cb ea ff ff       	call   800f08 <sys_page_unmap>
}
  80243d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802440:	c9                   	leave  
  802441:	c3                   	ret    

00802442 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802442:	55                   	push   %ebp
  802443:	89 e5                	mov    %esp,%ebp
  802445:	57                   	push   %edi
  802446:	56                   	push   %esi
  802447:	53                   	push   %ebx
  802448:	83 ec 1c             	sub    $0x1c,%esp
  80244b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80244e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802450:	a1 90 77 80 00       	mov    0x807790,%eax
  802455:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80245b:	83 ec 0c             	sub    $0xc,%esp
  80245e:	ff 75 e0             	pushl  -0x20(%ebp)
  802461:	e8 d2 04 00 00       	call   802938 <pageref>
  802466:	89 c3                	mov    %eax,%ebx
  802468:	89 3c 24             	mov    %edi,(%esp)
  80246b:	e8 c8 04 00 00       	call   802938 <pageref>
  802470:	83 c4 10             	add    $0x10,%esp
  802473:	39 c3                	cmp    %eax,%ebx
  802475:	0f 94 c1             	sete   %cl
  802478:	0f b6 c9             	movzbl %cl,%ecx
  80247b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80247e:	8b 15 90 77 80 00    	mov    0x807790,%edx
  802484:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  80248a:	39 ce                	cmp    %ecx,%esi
  80248c:	74 1e                	je     8024ac <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  80248e:	39 c3                	cmp    %eax,%ebx
  802490:	75 be                	jne    802450 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802492:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  802498:	ff 75 e4             	pushl  -0x1c(%ebp)
  80249b:	50                   	push   %eax
  80249c:	56                   	push   %esi
  80249d:	68 d3 32 80 00       	push   $0x8032d3
  8024a2:	e8 54 e0 ff ff       	call   8004fb <cprintf>
  8024a7:	83 c4 10             	add    $0x10,%esp
  8024aa:	eb a4                	jmp    802450 <_pipeisclosed+0xe>
	}
}
  8024ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024b2:	5b                   	pop    %ebx
  8024b3:	5e                   	pop    %esi
  8024b4:	5f                   	pop    %edi
  8024b5:	5d                   	pop    %ebp
  8024b6:	c3                   	ret    

008024b7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024b7:	55                   	push   %ebp
  8024b8:	89 e5                	mov    %esp,%ebp
  8024ba:	57                   	push   %edi
  8024bb:	56                   	push   %esi
  8024bc:	53                   	push   %ebx
  8024bd:	83 ec 28             	sub    $0x28,%esp
  8024c0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8024c3:	56                   	push   %esi
  8024c4:	e8 15 f1 ff ff       	call   8015de <fd2data>
  8024c9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024cb:	83 c4 10             	add    $0x10,%esp
  8024ce:	bf 00 00 00 00       	mov    $0x0,%edi
  8024d3:	eb 4b                	jmp    802520 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8024d5:	89 da                	mov    %ebx,%edx
  8024d7:	89 f0                	mov    %esi,%eax
  8024d9:	e8 64 ff ff ff       	call   802442 <_pipeisclosed>
  8024de:	85 c0                	test   %eax,%eax
  8024e0:	75 48                	jne    80252a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8024e2:	e8 7d e9 ff ff       	call   800e64 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8024e7:	8b 43 04             	mov    0x4(%ebx),%eax
  8024ea:	8b 0b                	mov    (%ebx),%ecx
  8024ec:	8d 51 20             	lea    0x20(%ecx),%edx
  8024ef:	39 d0                	cmp    %edx,%eax
  8024f1:	73 e2                	jae    8024d5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8024f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024f6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8024fa:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8024fd:	89 c2                	mov    %eax,%edx
  8024ff:	c1 fa 1f             	sar    $0x1f,%edx
  802502:	89 d1                	mov    %edx,%ecx
  802504:	c1 e9 1b             	shr    $0x1b,%ecx
  802507:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80250a:	83 e2 1f             	and    $0x1f,%edx
  80250d:	29 ca                	sub    %ecx,%edx
  80250f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802513:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802517:	83 c0 01             	add    $0x1,%eax
  80251a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80251d:	83 c7 01             	add    $0x1,%edi
  802520:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802523:	75 c2                	jne    8024e7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802525:	8b 45 10             	mov    0x10(%ebp),%eax
  802528:	eb 05                	jmp    80252f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80252a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80252f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802532:	5b                   	pop    %ebx
  802533:	5e                   	pop    %esi
  802534:	5f                   	pop    %edi
  802535:	5d                   	pop    %ebp
  802536:	c3                   	ret    

00802537 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802537:	55                   	push   %ebp
  802538:	89 e5                	mov    %esp,%ebp
  80253a:	57                   	push   %edi
  80253b:	56                   	push   %esi
  80253c:	53                   	push   %ebx
  80253d:	83 ec 18             	sub    $0x18,%esp
  802540:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802543:	57                   	push   %edi
  802544:	e8 95 f0 ff ff       	call   8015de <fd2data>
  802549:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80254b:	83 c4 10             	add    $0x10,%esp
  80254e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802553:	eb 3d                	jmp    802592 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802555:	85 db                	test   %ebx,%ebx
  802557:	74 04                	je     80255d <devpipe_read+0x26>
				return i;
  802559:	89 d8                	mov    %ebx,%eax
  80255b:	eb 44                	jmp    8025a1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80255d:	89 f2                	mov    %esi,%edx
  80255f:	89 f8                	mov    %edi,%eax
  802561:	e8 dc fe ff ff       	call   802442 <_pipeisclosed>
  802566:	85 c0                	test   %eax,%eax
  802568:	75 32                	jne    80259c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80256a:	e8 f5 e8 ff ff       	call   800e64 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80256f:	8b 06                	mov    (%esi),%eax
  802571:	3b 46 04             	cmp    0x4(%esi),%eax
  802574:	74 df                	je     802555 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802576:	99                   	cltd   
  802577:	c1 ea 1b             	shr    $0x1b,%edx
  80257a:	01 d0                	add    %edx,%eax
  80257c:	83 e0 1f             	and    $0x1f,%eax
  80257f:	29 d0                	sub    %edx,%eax
  802581:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802586:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802589:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80258c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80258f:	83 c3 01             	add    $0x1,%ebx
  802592:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802595:	75 d8                	jne    80256f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802597:	8b 45 10             	mov    0x10(%ebp),%eax
  80259a:	eb 05                	jmp    8025a1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80259c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8025a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025a4:	5b                   	pop    %ebx
  8025a5:	5e                   	pop    %esi
  8025a6:	5f                   	pop    %edi
  8025a7:	5d                   	pop    %ebp
  8025a8:	c3                   	ret    

008025a9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8025a9:	55                   	push   %ebp
  8025aa:	89 e5                	mov    %esp,%ebp
  8025ac:	56                   	push   %esi
  8025ad:	53                   	push   %ebx
  8025ae:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8025b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025b4:	50                   	push   %eax
  8025b5:	e8 3b f0 ff ff       	call   8015f5 <fd_alloc>
  8025ba:	83 c4 10             	add    $0x10,%esp
  8025bd:	89 c2                	mov    %eax,%edx
  8025bf:	85 c0                	test   %eax,%eax
  8025c1:	0f 88 2c 01 00 00    	js     8026f3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025c7:	83 ec 04             	sub    $0x4,%esp
  8025ca:	68 07 04 00 00       	push   $0x407
  8025cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8025d2:	6a 00                	push   $0x0
  8025d4:	e8 aa e8 ff ff       	call   800e83 <sys_page_alloc>
  8025d9:	83 c4 10             	add    $0x10,%esp
  8025dc:	89 c2                	mov    %eax,%edx
  8025de:	85 c0                	test   %eax,%eax
  8025e0:	0f 88 0d 01 00 00    	js     8026f3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8025e6:	83 ec 0c             	sub    $0xc,%esp
  8025e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8025ec:	50                   	push   %eax
  8025ed:	e8 03 f0 ff ff       	call   8015f5 <fd_alloc>
  8025f2:	89 c3                	mov    %eax,%ebx
  8025f4:	83 c4 10             	add    $0x10,%esp
  8025f7:	85 c0                	test   %eax,%eax
  8025f9:	0f 88 e2 00 00 00    	js     8026e1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025ff:	83 ec 04             	sub    $0x4,%esp
  802602:	68 07 04 00 00       	push   $0x407
  802607:	ff 75 f0             	pushl  -0x10(%ebp)
  80260a:	6a 00                	push   $0x0
  80260c:	e8 72 e8 ff ff       	call   800e83 <sys_page_alloc>
  802611:	89 c3                	mov    %eax,%ebx
  802613:	83 c4 10             	add    $0x10,%esp
  802616:	85 c0                	test   %eax,%eax
  802618:	0f 88 c3 00 00 00    	js     8026e1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80261e:	83 ec 0c             	sub    $0xc,%esp
  802621:	ff 75 f4             	pushl  -0xc(%ebp)
  802624:	e8 b5 ef ff ff       	call   8015de <fd2data>
  802629:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80262b:	83 c4 0c             	add    $0xc,%esp
  80262e:	68 07 04 00 00       	push   $0x407
  802633:	50                   	push   %eax
  802634:	6a 00                	push   $0x0
  802636:	e8 48 e8 ff ff       	call   800e83 <sys_page_alloc>
  80263b:	89 c3                	mov    %eax,%ebx
  80263d:	83 c4 10             	add    $0x10,%esp
  802640:	85 c0                	test   %eax,%eax
  802642:	0f 88 89 00 00 00    	js     8026d1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802648:	83 ec 0c             	sub    $0xc,%esp
  80264b:	ff 75 f0             	pushl  -0x10(%ebp)
  80264e:	e8 8b ef ff ff       	call   8015de <fd2data>
  802653:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80265a:	50                   	push   %eax
  80265b:	6a 00                	push   $0x0
  80265d:	56                   	push   %esi
  80265e:	6a 00                	push   $0x0
  802660:	e8 61 e8 ff ff       	call   800ec6 <sys_page_map>
  802665:	89 c3                	mov    %eax,%ebx
  802667:	83 c4 20             	add    $0x20,%esp
  80266a:	85 c0                	test   %eax,%eax
  80266c:	78 55                	js     8026c3 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80266e:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  802674:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802677:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802679:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80267c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802683:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  802689:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80268c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80268e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802691:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802698:	83 ec 0c             	sub    $0xc,%esp
  80269b:	ff 75 f4             	pushl  -0xc(%ebp)
  80269e:	e8 2b ef ff ff       	call   8015ce <fd2num>
  8026a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026a6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8026a8:	83 c4 04             	add    $0x4,%esp
  8026ab:	ff 75 f0             	pushl  -0x10(%ebp)
  8026ae:	e8 1b ef ff ff       	call   8015ce <fd2num>
  8026b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026b6:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8026b9:	83 c4 10             	add    $0x10,%esp
  8026bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8026c1:	eb 30                	jmp    8026f3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8026c3:	83 ec 08             	sub    $0x8,%esp
  8026c6:	56                   	push   %esi
  8026c7:	6a 00                	push   $0x0
  8026c9:	e8 3a e8 ff ff       	call   800f08 <sys_page_unmap>
  8026ce:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8026d1:	83 ec 08             	sub    $0x8,%esp
  8026d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8026d7:	6a 00                	push   $0x0
  8026d9:	e8 2a e8 ff ff       	call   800f08 <sys_page_unmap>
  8026de:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8026e1:	83 ec 08             	sub    $0x8,%esp
  8026e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8026e7:	6a 00                	push   $0x0
  8026e9:	e8 1a e8 ff ff       	call   800f08 <sys_page_unmap>
  8026ee:	83 c4 10             	add    $0x10,%esp
  8026f1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8026f3:	89 d0                	mov    %edx,%eax
  8026f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026f8:	5b                   	pop    %ebx
  8026f9:	5e                   	pop    %esi
  8026fa:	5d                   	pop    %ebp
  8026fb:	c3                   	ret    

008026fc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8026fc:	55                   	push   %ebp
  8026fd:	89 e5                	mov    %esp,%ebp
  8026ff:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802702:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802705:	50                   	push   %eax
  802706:	ff 75 08             	pushl  0x8(%ebp)
  802709:	e8 36 ef ff ff       	call   801644 <fd_lookup>
  80270e:	83 c4 10             	add    $0x10,%esp
  802711:	85 c0                	test   %eax,%eax
  802713:	78 18                	js     80272d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802715:	83 ec 0c             	sub    $0xc,%esp
  802718:	ff 75 f4             	pushl  -0xc(%ebp)
  80271b:	e8 be ee ff ff       	call   8015de <fd2data>
	return _pipeisclosed(fd, p);
  802720:	89 c2                	mov    %eax,%edx
  802722:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802725:	e8 18 fd ff ff       	call   802442 <_pipeisclosed>
  80272a:	83 c4 10             	add    $0x10,%esp
}
  80272d:	c9                   	leave  
  80272e:	c3                   	ret    

0080272f <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80272f:	55                   	push   %ebp
  802730:	89 e5                	mov    %esp,%ebp
  802732:	56                   	push   %esi
  802733:	53                   	push   %ebx
  802734:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802737:	85 f6                	test   %esi,%esi
  802739:	75 16                	jne    802751 <wait+0x22>
  80273b:	68 eb 32 80 00       	push   $0x8032eb
  802740:	68 eb 31 80 00       	push   $0x8031eb
  802745:	6a 09                	push   $0x9
  802747:	68 f6 32 80 00       	push   $0x8032f6
  80274c:	e8 d1 dc ff ff       	call   800422 <_panic>
	e = &envs[ENVX(envid)];
  802751:	89 f3                	mov    %esi,%ebx
  802753:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802759:	69 db d4 00 00 00    	imul   $0xd4,%ebx,%ebx
  80275f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802765:	eb 05                	jmp    80276c <wait+0x3d>
		sys_yield();
  802767:	e8 f8 e6 ff ff       	call   800e64 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80276c:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
  802772:	39 c6                	cmp    %eax,%esi
  802774:	75 0a                	jne    802780 <wait+0x51>
  802776:	8b 83 ac 00 00 00    	mov    0xac(%ebx),%eax
  80277c:	85 c0                	test   %eax,%eax
  80277e:	75 e7                	jne    802767 <wait+0x38>
		sys_yield();
}
  802780:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802783:	5b                   	pop    %ebx
  802784:	5e                   	pop    %esi
  802785:	5d                   	pop    %ebp
  802786:	c3                   	ret    

00802787 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802787:	55                   	push   %ebp
  802788:	89 e5                	mov    %esp,%ebp
  80278a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80278d:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  802794:	75 2a                	jne    8027c0 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802796:	83 ec 04             	sub    $0x4,%esp
  802799:	6a 07                	push   $0x7
  80279b:	68 00 f0 bf ee       	push   $0xeebff000
  8027a0:	6a 00                	push   $0x0
  8027a2:	e8 dc e6 ff ff       	call   800e83 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8027a7:	83 c4 10             	add    $0x10,%esp
  8027aa:	85 c0                	test   %eax,%eax
  8027ac:	79 12                	jns    8027c0 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8027ae:	50                   	push   %eax
  8027af:	68 e3 2c 80 00       	push   $0x802ce3
  8027b4:	6a 23                	push   $0x23
  8027b6:	68 01 33 80 00       	push   $0x803301
  8027bb:	e8 62 dc ff ff       	call   800422 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8027c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8027c3:	a3 00 90 80 00       	mov    %eax,0x809000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8027c8:	83 ec 08             	sub    $0x8,%esp
  8027cb:	68 f2 27 80 00       	push   $0x8027f2
  8027d0:	6a 00                	push   $0x0
  8027d2:	e8 f7 e7 ff ff       	call   800fce <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8027d7:	83 c4 10             	add    $0x10,%esp
  8027da:	85 c0                	test   %eax,%eax
  8027dc:	79 12                	jns    8027f0 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8027de:	50                   	push   %eax
  8027df:	68 e3 2c 80 00       	push   $0x802ce3
  8027e4:	6a 2c                	push   $0x2c
  8027e6:	68 01 33 80 00       	push   $0x803301
  8027eb:	e8 32 dc ff ff       	call   800422 <_panic>
	}
}
  8027f0:	c9                   	leave  
  8027f1:	c3                   	ret    

008027f2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8027f2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8027f3:	a1 00 90 80 00       	mov    0x809000,%eax
	call *%eax
  8027f8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8027fa:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8027fd:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802801:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802806:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80280a:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80280c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80280f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802810:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802813:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802814:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802815:	c3                   	ret    

00802816 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802816:	55                   	push   %ebp
  802817:	89 e5                	mov    %esp,%ebp
  802819:	56                   	push   %esi
  80281a:	53                   	push   %ebx
  80281b:	8b 75 08             	mov    0x8(%ebp),%esi
  80281e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802821:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802824:	85 c0                	test   %eax,%eax
  802826:	75 12                	jne    80283a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802828:	83 ec 0c             	sub    $0xc,%esp
  80282b:	68 00 00 c0 ee       	push   $0xeec00000
  802830:	e8 fe e7 ff ff       	call   801033 <sys_ipc_recv>
  802835:	83 c4 10             	add    $0x10,%esp
  802838:	eb 0c                	jmp    802846 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80283a:	83 ec 0c             	sub    $0xc,%esp
  80283d:	50                   	push   %eax
  80283e:	e8 f0 e7 ff ff       	call   801033 <sys_ipc_recv>
  802843:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802846:	85 f6                	test   %esi,%esi
  802848:	0f 95 c1             	setne  %cl
  80284b:	85 db                	test   %ebx,%ebx
  80284d:	0f 95 c2             	setne  %dl
  802850:	84 d1                	test   %dl,%cl
  802852:	74 09                	je     80285d <ipc_recv+0x47>
  802854:	89 c2                	mov    %eax,%edx
  802856:	c1 ea 1f             	shr    $0x1f,%edx
  802859:	84 d2                	test   %dl,%dl
  80285b:	75 2d                	jne    80288a <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80285d:	85 f6                	test   %esi,%esi
  80285f:	74 0d                	je     80286e <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802861:	a1 90 77 80 00       	mov    0x807790,%eax
  802866:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  80286c:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80286e:	85 db                	test   %ebx,%ebx
  802870:	74 0d                	je     80287f <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802872:	a1 90 77 80 00       	mov    0x807790,%eax
  802877:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80287d:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80287f:	a1 90 77 80 00       	mov    0x807790,%eax
  802884:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80288a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80288d:	5b                   	pop    %ebx
  80288e:	5e                   	pop    %esi
  80288f:	5d                   	pop    %ebp
  802890:	c3                   	ret    

00802891 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802891:	55                   	push   %ebp
  802892:	89 e5                	mov    %esp,%ebp
  802894:	57                   	push   %edi
  802895:	56                   	push   %esi
  802896:	53                   	push   %ebx
  802897:	83 ec 0c             	sub    $0xc,%esp
  80289a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80289d:	8b 75 0c             	mov    0xc(%ebp),%esi
  8028a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8028a3:	85 db                	test   %ebx,%ebx
  8028a5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8028aa:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8028ad:	ff 75 14             	pushl  0x14(%ebp)
  8028b0:	53                   	push   %ebx
  8028b1:	56                   	push   %esi
  8028b2:	57                   	push   %edi
  8028b3:	e8 58 e7 ff ff       	call   801010 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8028b8:	89 c2                	mov    %eax,%edx
  8028ba:	c1 ea 1f             	shr    $0x1f,%edx
  8028bd:	83 c4 10             	add    $0x10,%esp
  8028c0:	84 d2                	test   %dl,%dl
  8028c2:	74 17                	je     8028db <ipc_send+0x4a>
  8028c4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028c7:	74 12                	je     8028db <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8028c9:	50                   	push   %eax
  8028ca:	68 0f 33 80 00       	push   $0x80330f
  8028cf:	6a 47                	push   $0x47
  8028d1:	68 1d 33 80 00       	push   $0x80331d
  8028d6:	e8 47 db ff ff       	call   800422 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8028db:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028de:	75 07                	jne    8028e7 <ipc_send+0x56>
			sys_yield();
  8028e0:	e8 7f e5 ff ff       	call   800e64 <sys_yield>
  8028e5:	eb c6                	jmp    8028ad <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8028e7:	85 c0                	test   %eax,%eax
  8028e9:	75 c2                	jne    8028ad <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8028eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028ee:	5b                   	pop    %ebx
  8028ef:	5e                   	pop    %esi
  8028f0:	5f                   	pop    %edi
  8028f1:	5d                   	pop    %ebp
  8028f2:	c3                   	ret    

008028f3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8028f3:	55                   	push   %ebp
  8028f4:	89 e5                	mov    %esp,%ebp
  8028f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8028f9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8028fe:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  802904:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80290a:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802910:	39 ca                	cmp    %ecx,%edx
  802912:	75 13                	jne    802927 <ipc_find_env+0x34>
			return envs[i].env_id;
  802914:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80291a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80291f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802925:	eb 0f                	jmp    802936 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802927:	83 c0 01             	add    $0x1,%eax
  80292a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80292f:	75 cd                	jne    8028fe <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802931:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802936:	5d                   	pop    %ebp
  802937:	c3                   	ret    

00802938 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802938:	55                   	push   %ebp
  802939:	89 e5                	mov    %esp,%ebp
  80293b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80293e:	89 d0                	mov    %edx,%eax
  802940:	c1 e8 16             	shr    $0x16,%eax
  802943:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80294a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80294f:	f6 c1 01             	test   $0x1,%cl
  802952:	74 1d                	je     802971 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802954:	c1 ea 0c             	shr    $0xc,%edx
  802957:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80295e:	f6 c2 01             	test   $0x1,%dl
  802961:	74 0e                	je     802971 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802963:	c1 ea 0c             	shr    $0xc,%edx
  802966:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80296d:	ef 
  80296e:	0f b7 c0             	movzwl %ax,%eax
}
  802971:	5d                   	pop    %ebp
  802972:	c3                   	ret    
  802973:	66 90                	xchg   %ax,%ax
  802975:	66 90                	xchg   %ax,%ax
  802977:	66 90                	xchg   %ax,%ax
  802979:	66 90                	xchg   %ax,%ax
  80297b:	66 90                	xchg   %ax,%ax
  80297d:	66 90                	xchg   %ax,%ax
  80297f:	90                   	nop

00802980 <__udivdi3>:
  802980:	55                   	push   %ebp
  802981:	57                   	push   %edi
  802982:	56                   	push   %esi
  802983:	53                   	push   %ebx
  802984:	83 ec 1c             	sub    $0x1c,%esp
  802987:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80298b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80298f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802993:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802997:	85 f6                	test   %esi,%esi
  802999:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80299d:	89 ca                	mov    %ecx,%edx
  80299f:	89 f8                	mov    %edi,%eax
  8029a1:	75 3d                	jne    8029e0 <__udivdi3+0x60>
  8029a3:	39 cf                	cmp    %ecx,%edi
  8029a5:	0f 87 c5 00 00 00    	ja     802a70 <__udivdi3+0xf0>
  8029ab:	85 ff                	test   %edi,%edi
  8029ad:	89 fd                	mov    %edi,%ebp
  8029af:	75 0b                	jne    8029bc <__udivdi3+0x3c>
  8029b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8029b6:	31 d2                	xor    %edx,%edx
  8029b8:	f7 f7                	div    %edi
  8029ba:	89 c5                	mov    %eax,%ebp
  8029bc:	89 c8                	mov    %ecx,%eax
  8029be:	31 d2                	xor    %edx,%edx
  8029c0:	f7 f5                	div    %ebp
  8029c2:	89 c1                	mov    %eax,%ecx
  8029c4:	89 d8                	mov    %ebx,%eax
  8029c6:	89 cf                	mov    %ecx,%edi
  8029c8:	f7 f5                	div    %ebp
  8029ca:	89 c3                	mov    %eax,%ebx
  8029cc:	89 d8                	mov    %ebx,%eax
  8029ce:	89 fa                	mov    %edi,%edx
  8029d0:	83 c4 1c             	add    $0x1c,%esp
  8029d3:	5b                   	pop    %ebx
  8029d4:	5e                   	pop    %esi
  8029d5:	5f                   	pop    %edi
  8029d6:	5d                   	pop    %ebp
  8029d7:	c3                   	ret    
  8029d8:	90                   	nop
  8029d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029e0:	39 ce                	cmp    %ecx,%esi
  8029e2:	77 74                	ja     802a58 <__udivdi3+0xd8>
  8029e4:	0f bd fe             	bsr    %esi,%edi
  8029e7:	83 f7 1f             	xor    $0x1f,%edi
  8029ea:	0f 84 98 00 00 00    	je     802a88 <__udivdi3+0x108>
  8029f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8029f5:	89 f9                	mov    %edi,%ecx
  8029f7:	89 c5                	mov    %eax,%ebp
  8029f9:	29 fb                	sub    %edi,%ebx
  8029fb:	d3 e6                	shl    %cl,%esi
  8029fd:	89 d9                	mov    %ebx,%ecx
  8029ff:	d3 ed                	shr    %cl,%ebp
  802a01:	89 f9                	mov    %edi,%ecx
  802a03:	d3 e0                	shl    %cl,%eax
  802a05:	09 ee                	or     %ebp,%esi
  802a07:	89 d9                	mov    %ebx,%ecx
  802a09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a0d:	89 d5                	mov    %edx,%ebp
  802a0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a13:	d3 ed                	shr    %cl,%ebp
  802a15:	89 f9                	mov    %edi,%ecx
  802a17:	d3 e2                	shl    %cl,%edx
  802a19:	89 d9                	mov    %ebx,%ecx
  802a1b:	d3 e8                	shr    %cl,%eax
  802a1d:	09 c2                	or     %eax,%edx
  802a1f:	89 d0                	mov    %edx,%eax
  802a21:	89 ea                	mov    %ebp,%edx
  802a23:	f7 f6                	div    %esi
  802a25:	89 d5                	mov    %edx,%ebp
  802a27:	89 c3                	mov    %eax,%ebx
  802a29:	f7 64 24 0c          	mull   0xc(%esp)
  802a2d:	39 d5                	cmp    %edx,%ebp
  802a2f:	72 10                	jb     802a41 <__udivdi3+0xc1>
  802a31:	8b 74 24 08          	mov    0x8(%esp),%esi
  802a35:	89 f9                	mov    %edi,%ecx
  802a37:	d3 e6                	shl    %cl,%esi
  802a39:	39 c6                	cmp    %eax,%esi
  802a3b:	73 07                	jae    802a44 <__udivdi3+0xc4>
  802a3d:	39 d5                	cmp    %edx,%ebp
  802a3f:	75 03                	jne    802a44 <__udivdi3+0xc4>
  802a41:	83 eb 01             	sub    $0x1,%ebx
  802a44:	31 ff                	xor    %edi,%edi
  802a46:	89 d8                	mov    %ebx,%eax
  802a48:	89 fa                	mov    %edi,%edx
  802a4a:	83 c4 1c             	add    $0x1c,%esp
  802a4d:	5b                   	pop    %ebx
  802a4e:	5e                   	pop    %esi
  802a4f:	5f                   	pop    %edi
  802a50:	5d                   	pop    %ebp
  802a51:	c3                   	ret    
  802a52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a58:	31 ff                	xor    %edi,%edi
  802a5a:	31 db                	xor    %ebx,%ebx
  802a5c:	89 d8                	mov    %ebx,%eax
  802a5e:	89 fa                	mov    %edi,%edx
  802a60:	83 c4 1c             	add    $0x1c,%esp
  802a63:	5b                   	pop    %ebx
  802a64:	5e                   	pop    %esi
  802a65:	5f                   	pop    %edi
  802a66:	5d                   	pop    %ebp
  802a67:	c3                   	ret    
  802a68:	90                   	nop
  802a69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a70:	89 d8                	mov    %ebx,%eax
  802a72:	f7 f7                	div    %edi
  802a74:	31 ff                	xor    %edi,%edi
  802a76:	89 c3                	mov    %eax,%ebx
  802a78:	89 d8                	mov    %ebx,%eax
  802a7a:	89 fa                	mov    %edi,%edx
  802a7c:	83 c4 1c             	add    $0x1c,%esp
  802a7f:	5b                   	pop    %ebx
  802a80:	5e                   	pop    %esi
  802a81:	5f                   	pop    %edi
  802a82:	5d                   	pop    %ebp
  802a83:	c3                   	ret    
  802a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a88:	39 ce                	cmp    %ecx,%esi
  802a8a:	72 0c                	jb     802a98 <__udivdi3+0x118>
  802a8c:	31 db                	xor    %ebx,%ebx
  802a8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802a92:	0f 87 34 ff ff ff    	ja     8029cc <__udivdi3+0x4c>
  802a98:	bb 01 00 00 00       	mov    $0x1,%ebx
  802a9d:	e9 2a ff ff ff       	jmp    8029cc <__udivdi3+0x4c>
  802aa2:	66 90                	xchg   %ax,%ax
  802aa4:	66 90                	xchg   %ax,%ax
  802aa6:	66 90                	xchg   %ax,%ax
  802aa8:	66 90                	xchg   %ax,%ax
  802aaa:	66 90                	xchg   %ax,%ax
  802aac:	66 90                	xchg   %ax,%ax
  802aae:	66 90                	xchg   %ax,%ax

00802ab0 <__umoddi3>:
  802ab0:	55                   	push   %ebp
  802ab1:	57                   	push   %edi
  802ab2:	56                   	push   %esi
  802ab3:	53                   	push   %ebx
  802ab4:	83 ec 1c             	sub    $0x1c,%esp
  802ab7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802abb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802abf:	8b 74 24 34          	mov    0x34(%esp),%esi
  802ac3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802ac7:	85 d2                	test   %edx,%edx
  802ac9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802acd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802ad1:	89 f3                	mov    %esi,%ebx
  802ad3:	89 3c 24             	mov    %edi,(%esp)
  802ad6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802ada:	75 1c                	jne    802af8 <__umoddi3+0x48>
  802adc:	39 f7                	cmp    %esi,%edi
  802ade:	76 50                	jbe    802b30 <__umoddi3+0x80>
  802ae0:	89 c8                	mov    %ecx,%eax
  802ae2:	89 f2                	mov    %esi,%edx
  802ae4:	f7 f7                	div    %edi
  802ae6:	89 d0                	mov    %edx,%eax
  802ae8:	31 d2                	xor    %edx,%edx
  802aea:	83 c4 1c             	add    $0x1c,%esp
  802aed:	5b                   	pop    %ebx
  802aee:	5e                   	pop    %esi
  802aef:	5f                   	pop    %edi
  802af0:	5d                   	pop    %ebp
  802af1:	c3                   	ret    
  802af2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802af8:	39 f2                	cmp    %esi,%edx
  802afa:	89 d0                	mov    %edx,%eax
  802afc:	77 52                	ja     802b50 <__umoddi3+0xa0>
  802afe:	0f bd ea             	bsr    %edx,%ebp
  802b01:	83 f5 1f             	xor    $0x1f,%ebp
  802b04:	75 5a                	jne    802b60 <__umoddi3+0xb0>
  802b06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802b0a:	0f 82 e0 00 00 00    	jb     802bf0 <__umoddi3+0x140>
  802b10:	39 0c 24             	cmp    %ecx,(%esp)
  802b13:	0f 86 d7 00 00 00    	jbe    802bf0 <__umoddi3+0x140>
  802b19:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802b21:	83 c4 1c             	add    $0x1c,%esp
  802b24:	5b                   	pop    %ebx
  802b25:	5e                   	pop    %esi
  802b26:	5f                   	pop    %edi
  802b27:	5d                   	pop    %ebp
  802b28:	c3                   	ret    
  802b29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b30:	85 ff                	test   %edi,%edi
  802b32:	89 fd                	mov    %edi,%ebp
  802b34:	75 0b                	jne    802b41 <__umoddi3+0x91>
  802b36:	b8 01 00 00 00       	mov    $0x1,%eax
  802b3b:	31 d2                	xor    %edx,%edx
  802b3d:	f7 f7                	div    %edi
  802b3f:	89 c5                	mov    %eax,%ebp
  802b41:	89 f0                	mov    %esi,%eax
  802b43:	31 d2                	xor    %edx,%edx
  802b45:	f7 f5                	div    %ebp
  802b47:	89 c8                	mov    %ecx,%eax
  802b49:	f7 f5                	div    %ebp
  802b4b:	89 d0                	mov    %edx,%eax
  802b4d:	eb 99                	jmp    802ae8 <__umoddi3+0x38>
  802b4f:	90                   	nop
  802b50:	89 c8                	mov    %ecx,%eax
  802b52:	89 f2                	mov    %esi,%edx
  802b54:	83 c4 1c             	add    $0x1c,%esp
  802b57:	5b                   	pop    %ebx
  802b58:	5e                   	pop    %esi
  802b59:	5f                   	pop    %edi
  802b5a:	5d                   	pop    %ebp
  802b5b:	c3                   	ret    
  802b5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b60:	8b 34 24             	mov    (%esp),%esi
  802b63:	bf 20 00 00 00       	mov    $0x20,%edi
  802b68:	89 e9                	mov    %ebp,%ecx
  802b6a:	29 ef                	sub    %ebp,%edi
  802b6c:	d3 e0                	shl    %cl,%eax
  802b6e:	89 f9                	mov    %edi,%ecx
  802b70:	89 f2                	mov    %esi,%edx
  802b72:	d3 ea                	shr    %cl,%edx
  802b74:	89 e9                	mov    %ebp,%ecx
  802b76:	09 c2                	or     %eax,%edx
  802b78:	89 d8                	mov    %ebx,%eax
  802b7a:	89 14 24             	mov    %edx,(%esp)
  802b7d:	89 f2                	mov    %esi,%edx
  802b7f:	d3 e2                	shl    %cl,%edx
  802b81:	89 f9                	mov    %edi,%ecx
  802b83:	89 54 24 04          	mov    %edx,0x4(%esp)
  802b87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802b8b:	d3 e8                	shr    %cl,%eax
  802b8d:	89 e9                	mov    %ebp,%ecx
  802b8f:	89 c6                	mov    %eax,%esi
  802b91:	d3 e3                	shl    %cl,%ebx
  802b93:	89 f9                	mov    %edi,%ecx
  802b95:	89 d0                	mov    %edx,%eax
  802b97:	d3 e8                	shr    %cl,%eax
  802b99:	89 e9                	mov    %ebp,%ecx
  802b9b:	09 d8                	or     %ebx,%eax
  802b9d:	89 d3                	mov    %edx,%ebx
  802b9f:	89 f2                	mov    %esi,%edx
  802ba1:	f7 34 24             	divl   (%esp)
  802ba4:	89 d6                	mov    %edx,%esi
  802ba6:	d3 e3                	shl    %cl,%ebx
  802ba8:	f7 64 24 04          	mull   0x4(%esp)
  802bac:	39 d6                	cmp    %edx,%esi
  802bae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802bb2:	89 d1                	mov    %edx,%ecx
  802bb4:	89 c3                	mov    %eax,%ebx
  802bb6:	72 08                	jb     802bc0 <__umoddi3+0x110>
  802bb8:	75 11                	jne    802bcb <__umoddi3+0x11b>
  802bba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802bbe:	73 0b                	jae    802bcb <__umoddi3+0x11b>
  802bc0:	2b 44 24 04          	sub    0x4(%esp),%eax
  802bc4:	1b 14 24             	sbb    (%esp),%edx
  802bc7:	89 d1                	mov    %edx,%ecx
  802bc9:	89 c3                	mov    %eax,%ebx
  802bcb:	8b 54 24 08          	mov    0x8(%esp),%edx
  802bcf:	29 da                	sub    %ebx,%edx
  802bd1:	19 ce                	sbb    %ecx,%esi
  802bd3:	89 f9                	mov    %edi,%ecx
  802bd5:	89 f0                	mov    %esi,%eax
  802bd7:	d3 e0                	shl    %cl,%eax
  802bd9:	89 e9                	mov    %ebp,%ecx
  802bdb:	d3 ea                	shr    %cl,%edx
  802bdd:	89 e9                	mov    %ebp,%ecx
  802bdf:	d3 ee                	shr    %cl,%esi
  802be1:	09 d0                	or     %edx,%eax
  802be3:	89 f2                	mov    %esi,%edx
  802be5:	83 c4 1c             	add    $0x1c,%esp
  802be8:	5b                   	pop    %ebx
  802be9:	5e                   	pop    %esi
  802bea:	5f                   	pop    %edi
  802beb:	5d                   	pop    %ebp
  802bec:	c3                   	ret    
  802bed:	8d 76 00             	lea    0x0(%esi),%esi
  802bf0:	29 f9                	sub    %edi,%ecx
  802bf2:	19 d6                	sbb    %edx,%esi
  802bf4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802bf8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802bfc:	e9 18 ff ff ff       	jmp    802b19 <__umoddi3+0x69>
