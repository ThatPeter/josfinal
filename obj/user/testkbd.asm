
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 3b 02 00 00       	call   80026c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 1d 0e 00 00       	call   800e61 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>
		sys_yield();

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 de 11 00 00       	call   801231 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 00 21 80 00       	push   $0x802100
  800065:	6a 0f                	push   $0xf
  800067:	68 0d 21 80 00       	push   $0x80210d
  80006c:	e8 bb 02 00 00       	call   80032c <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 1c 21 80 00       	push   $0x80211c
  80007b:	6a 11                	push   $0x11
  80007d:	68 0d 21 80 00       	push   $0x80210d
  800082:	e8 a5 02 00 00       	call   80032c <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 ee 11 00 00       	call   801281 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 36 21 80 00       	push   $0x802136
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 0d 21 80 00       	push   $0x80210d
  8000a7:	e8 80 02 00 00       	call   80032c <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 3e 21 80 00       	push   $0x80213e
  8000b4:	e8 98 08 00 00       	call   800951 <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 4c 21 80 00       	push   $0x80214c
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 af 18 00 00       	call   80197f <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 50 21 80 00       	push   $0x802150
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 9b 18 00 00       	call   80197f <fprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	eb c3                	jmp    8000ac <umain+0x79>

008000e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f9:	68 68 21 80 00       	push   $0x802168
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	e8 77 09 00 00       	call   800a7d <strcpy>
	return 0;
}
  800106:	b8 00 00 00 00       	mov    $0x0,%eax
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800119:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80011e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800124:	eb 2d                	jmp    800153 <devcons_write+0x46>
		m = n - tot;
  800126:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800129:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80012b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80012e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800133:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800136:	83 ec 04             	sub    $0x4,%esp
  800139:	53                   	push   %ebx
  80013a:	03 45 0c             	add    0xc(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	57                   	push   %edi
  80013f:	e8 cb 0a 00 00       	call   800c0f <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 76 0c 00 00       	call   800dc4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80014e:	01 de                	add    %ebx,%esi
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	89 f0                	mov    %esi,%eax
  800155:	3b 75 10             	cmp    0x10(%ebp),%esi
  800158:	72 cc                	jb     800126 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80015a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80016d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800171:	74 2a                	je     80019d <devcons_read+0x3b>
  800173:	eb 05                	jmp    80017a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800175:	e8 e7 0c 00 00       	call   800e61 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80017a:	e8 63 0c 00 00       	call   800de2 <sys_cgetc>
  80017f:	85 c0                	test   %eax,%eax
  800181:	74 f2                	je     800175 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	78 16                	js     80019d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800187:	83 f8 04             	cmp    $0x4,%eax
  80018a:	74 0c                	je     800198 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	88 02                	mov    %al,(%edx)
	return 1;
  800191:	b8 01 00 00 00       	mov    $0x1,%eax
  800196:	eb 05                	jmp    80019d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800198:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ab:	6a 01                	push   $0x1
  8001ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 0e 0c 00 00       	call   800dc4 <sys_cputs>
}
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <getchar>:

int
getchar(void)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8001c1:	6a 01                	push   $0x1
  8001c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	6a 00                	push   $0x0
  8001c9:	e8 9f 11 00 00       	call   80136d <read>
	if (r < 0)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	78 0f                	js     8001e4 <getchar+0x29>
		return r;
	if (r < 1)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 06                	jle    8001df <getchar+0x24>
		return -E_EOF;
	return c;
  8001d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8001dd:	eb 05                	jmp    8001e4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8001df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 0f 0f 00 00       	call   801107 <fd_lookup>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	78 11                	js     800210 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8001ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800202:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800208:	39 10                	cmp    %edx,(%eax)
  80020a:	0f 94 c0             	sete   %al
  80020d:	0f b6 c0             	movzbl %al,%eax
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <opencons>:

int
opencons(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 97 0e 00 00       	call   8010b8 <fd_alloc>
  800221:	83 c4 10             	add    $0x10,%esp
		return r;
  800224:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800226:	85 c0                	test   %eax,%eax
  800228:	78 3e                	js     800268 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	68 07 04 00 00       	push   $0x407
  800232:	ff 75 f4             	pushl  -0xc(%ebp)
  800235:	6a 00                	push   $0x0
  800237:	e8 44 0c 00 00       	call   800e80 <sys_page_alloc>
  80023c:	83 c4 10             	add    $0x10,%esp
		return r;
  80023f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	78 23                	js     800268 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800245:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80024b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80024e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800250:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800253:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	e8 2e 0e 00 00       	call   801091 <fd2num>
  800263:	89 c2                	mov    %eax,%edx
  800265:	83 c4 10             	add    $0x10,%esp
}
  800268:	89 d0                	mov    %edx,%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800275:	c7 05 04 44 80 00 00 	movl   $0x0,0x804404
  80027c:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  80027f:	e8 be 0b 00 00       	call   800e42 <sys_getenvid>
  800284:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	50                   	push   %eax
  80028a:	68 74 21 80 00       	push   $0x802174
  80028f:	e8 71 01 00 00       	call   800405 <cprintf>
  800294:	8b 3d 04 44 80 00    	mov    0x804404,%edi
  80029a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8002a7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8002ac:	89 c1                	mov    %eax,%ecx
  8002ae:	c1 e1 07             	shl    $0x7,%ecx
  8002b1:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8002b8:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8002bb:	39 cb                	cmp    %ecx,%ebx
  8002bd:	0f 44 fa             	cmove  %edx,%edi
  8002c0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8002c5:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8002c8:	83 c0 01             	add    $0x1,%eax
  8002cb:	81 c2 84 00 00 00    	add    $0x84,%edx
  8002d1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8002d6:	75 d4                	jne    8002ac <libmain+0x40>
  8002d8:	89 f0                	mov    %esi,%eax
  8002da:	84 c0                	test   %al,%al
  8002dc:	74 06                	je     8002e4 <libmain+0x78>
  8002de:	89 3d 04 44 80 00    	mov    %edi,0x804404
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8002e8:	7e 0a                	jle    8002f4 <libmain+0x88>
		binaryname = argv[0];
  8002ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ed:	8b 00                	mov    (%eax),%eax
  8002ef:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  8002f4:	83 ec 08             	sub    $0x8,%esp
  8002f7:	ff 75 0c             	pushl  0xc(%ebp)
  8002fa:	ff 75 08             	pushl  0x8(%ebp)
  8002fd:	e8 31 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800302:	e8 0b 00 00 00       	call   800312 <exit>
}
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030d:	5b                   	pop    %ebx
  80030e:	5e                   	pop    %esi
  80030f:	5f                   	pop    %edi
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800318:	e8 3f 0f 00 00       	call   80125c <close_all>
	sys_env_destroy(0);
  80031d:	83 ec 0c             	sub    $0xc,%esp
  800320:	6a 00                	push   $0x0
  800322:	e8 da 0a 00 00       	call   800e01 <sys_env_destroy>
}
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	c9                   	leave  
  80032b:	c3                   	ret    

0080032c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	56                   	push   %esi
  800330:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800331:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800334:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  80033a:	e8 03 0b 00 00       	call   800e42 <sys_getenvid>
  80033f:	83 ec 0c             	sub    $0xc,%esp
  800342:	ff 75 0c             	pushl  0xc(%ebp)
  800345:	ff 75 08             	pushl  0x8(%ebp)
  800348:	56                   	push   %esi
  800349:	50                   	push   %eax
  80034a:	68 a0 21 80 00       	push   $0x8021a0
  80034f:	e8 b1 00 00 00       	call   800405 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800354:	83 c4 18             	add    $0x18,%esp
  800357:	53                   	push   %ebx
  800358:	ff 75 10             	pushl  0x10(%ebp)
  80035b:	e8 54 00 00 00       	call   8003b4 <vcprintf>
	cprintf("\n");
  800360:	c7 04 24 66 21 80 00 	movl   $0x802166,(%esp)
  800367:	e8 99 00 00 00       	call   800405 <cprintf>
  80036c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80036f:	cc                   	int3   
  800370:	eb fd                	jmp    80036f <_panic+0x43>

00800372 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	53                   	push   %ebx
  800376:	83 ec 04             	sub    $0x4,%esp
  800379:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80037c:	8b 13                	mov    (%ebx),%edx
  80037e:	8d 42 01             	lea    0x1(%edx),%eax
  800381:	89 03                	mov    %eax,(%ebx)
  800383:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800386:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80038a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80038f:	75 1a                	jne    8003ab <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	68 ff 00 00 00       	push   $0xff
  800399:	8d 43 08             	lea    0x8(%ebx),%eax
  80039c:	50                   	push   %eax
  80039d:	e8 22 0a 00 00       	call   800dc4 <sys_cputs>
		b->idx = 0;
  8003a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b2:	c9                   	leave  
  8003b3:	c3                   	ret    

008003b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c4:	00 00 00 
	b.cnt = 0;
  8003c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d1:	ff 75 0c             	pushl  0xc(%ebp)
  8003d4:	ff 75 08             	pushl  0x8(%ebp)
  8003d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	68 72 03 80 00       	push   $0x800372
  8003e3:	e8 54 01 00 00       	call   80053c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e8:	83 c4 08             	add    $0x8,%esp
  8003eb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003f7:	50                   	push   %eax
  8003f8:	e8 c7 09 00 00       	call   800dc4 <sys_cputs>

	return b.cnt;
}
  8003fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800403:	c9                   	leave  
  800404:	c3                   	ret    

00800405 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80040b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80040e:	50                   	push   %eax
  80040f:	ff 75 08             	pushl  0x8(%ebp)
  800412:	e8 9d ff ff ff       	call   8003b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800417:	c9                   	leave  
  800418:	c3                   	ret    

00800419 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	57                   	push   %edi
  80041d:	56                   	push   %esi
  80041e:	53                   	push   %ebx
  80041f:	83 ec 1c             	sub    $0x1c,%esp
  800422:	89 c7                	mov    %eax,%edi
  800424:	89 d6                	mov    %edx,%esi
  800426:	8b 45 08             	mov    0x8(%ebp),%eax
  800429:	8b 55 0c             	mov    0xc(%ebp),%edx
  80042c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80042f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800432:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800435:	bb 00 00 00 00       	mov    $0x0,%ebx
  80043a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80043d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800440:	39 d3                	cmp    %edx,%ebx
  800442:	72 05                	jb     800449 <printnum+0x30>
  800444:	39 45 10             	cmp    %eax,0x10(%ebp)
  800447:	77 45                	ja     80048e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800449:	83 ec 0c             	sub    $0xc,%esp
  80044c:	ff 75 18             	pushl  0x18(%ebp)
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800455:	53                   	push   %ebx
  800456:	ff 75 10             	pushl  0x10(%ebp)
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80045f:	ff 75 e0             	pushl  -0x20(%ebp)
  800462:	ff 75 dc             	pushl  -0x24(%ebp)
  800465:	ff 75 d8             	pushl  -0x28(%ebp)
  800468:	e8 f3 19 00 00       	call   801e60 <__udivdi3>
  80046d:	83 c4 18             	add    $0x18,%esp
  800470:	52                   	push   %edx
  800471:	50                   	push   %eax
  800472:	89 f2                	mov    %esi,%edx
  800474:	89 f8                	mov    %edi,%eax
  800476:	e8 9e ff ff ff       	call   800419 <printnum>
  80047b:	83 c4 20             	add    $0x20,%esp
  80047e:	eb 18                	jmp    800498 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	56                   	push   %esi
  800484:	ff 75 18             	pushl  0x18(%ebp)
  800487:	ff d7                	call   *%edi
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	eb 03                	jmp    800491 <printnum+0x78>
  80048e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800491:	83 eb 01             	sub    $0x1,%ebx
  800494:	85 db                	test   %ebx,%ebx
  800496:	7f e8                	jg     800480 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	56                   	push   %esi
  80049c:	83 ec 04             	sub    $0x4,%esp
  80049f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ab:	e8 e0 1a 00 00       	call   801f90 <__umoddi3>
  8004b0:	83 c4 14             	add    $0x14,%esp
  8004b3:	0f be 80 c3 21 80 00 	movsbl 0x8021c3(%eax),%eax
  8004ba:	50                   	push   %eax
  8004bb:	ff d7                	call   *%edi
}
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c3:	5b                   	pop    %ebx
  8004c4:	5e                   	pop    %esi
  8004c5:	5f                   	pop    %edi
  8004c6:	5d                   	pop    %ebp
  8004c7:	c3                   	ret    

008004c8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004cb:	83 fa 01             	cmp    $0x1,%edx
  8004ce:	7e 0e                	jle    8004de <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004d0:	8b 10                	mov    (%eax),%edx
  8004d2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d5:	89 08                	mov    %ecx,(%eax)
  8004d7:	8b 02                	mov    (%edx),%eax
  8004d9:	8b 52 04             	mov    0x4(%edx),%edx
  8004dc:	eb 22                	jmp    800500 <getuint+0x38>
	else if (lflag)
  8004de:	85 d2                	test   %edx,%edx
  8004e0:	74 10                	je     8004f2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004e2:	8b 10                	mov    (%eax),%edx
  8004e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e7:	89 08                	mov    %ecx,(%eax)
  8004e9:	8b 02                	mov    (%edx),%eax
  8004eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f0:	eb 0e                	jmp    800500 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004f2:	8b 10                	mov    (%eax),%edx
  8004f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f7:	89 08                	mov    %ecx,(%eax)
  8004f9:	8b 02                	mov    (%edx),%eax
  8004fb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800500:	5d                   	pop    %ebp
  800501:	c3                   	ret    

00800502 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
  800505:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800508:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80050c:	8b 10                	mov    (%eax),%edx
  80050e:	3b 50 04             	cmp    0x4(%eax),%edx
  800511:	73 0a                	jae    80051d <sprintputch+0x1b>
		*b->buf++ = ch;
  800513:	8d 4a 01             	lea    0x1(%edx),%ecx
  800516:	89 08                	mov    %ecx,(%eax)
  800518:	8b 45 08             	mov    0x8(%ebp),%eax
  80051b:	88 02                	mov    %al,(%edx)
}
  80051d:	5d                   	pop    %ebp
  80051e:	c3                   	ret    

0080051f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800525:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800528:	50                   	push   %eax
  800529:	ff 75 10             	pushl  0x10(%ebp)
  80052c:	ff 75 0c             	pushl  0xc(%ebp)
  80052f:	ff 75 08             	pushl  0x8(%ebp)
  800532:	e8 05 00 00 00       	call   80053c <vprintfmt>
	va_end(ap);
}
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	c9                   	leave  
  80053b:	c3                   	ret    

0080053c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	57                   	push   %edi
  800540:	56                   	push   %esi
  800541:	53                   	push   %ebx
  800542:	83 ec 2c             	sub    $0x2c,%esp
  800545:	8b 75 08             	mov    0x8(%ebp),%esi
  800548:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80054e:	eb 12                	jmp    800562 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800550:	85 c0                	test   %eax,%eax
  800552:	0f 84 89 03 00 00    	je     8008e1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	53                   	push   %ebx
  80055c:	50                   	push   %eax
  80055d:	ff d6                	call   *%esi
  80055f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800562:	83 c7 01             	add    $0x1,%edi
  800565:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800569:	83 f8 25             	cmp    $0x25,%eax
  80056c:	75 e2                	jne    800550 <vprintfmt+0x14>
  80056e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800572:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800579:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800580:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800587:	ba 00 00 00 00       	mov    $0x0,%edx
  80058c:	eb 07                	jmp    800595 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800591:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800595:	8d 47 01             	lea    0x1(%edi),%eax
  800598:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80059b:	0f b6 07             	movzbl (%edi),%eax
  80059e:	0f b6 c8             	movzbl %al,%ecx
  8005a1:	83 e8 23             	sub    $0x23,%eax
  8005a4:	3c 55                	cmp    $0x55,%al
  8005a6:	0f 87 1a 03 00 00    	ja     8008c6 <vprintfmt+0x38a>
  8005ac:	0f b6 c0             	movzbl %al,%eax
  8005af:	ff 24 85 00 23 80 00 	jmp    *0x802300(,%eax,4)
  8005b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005bd:	eb d6                	jmp    800595 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005cd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005d1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005d4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005d7:	83 fa 09             	cmp    $0x9,%edx
  8005da:	77 39                	ja     800615 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005dc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005df:	eb e9                	jmp    8005ca <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 48 04             	lea    0x4(%eax),%ecx
  8005e7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f2:	eb 27                	jmp    80061b <vprintfmt+0xdf>
  8005f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fe:	0f 49 c8             	cmovns %eax,%ecx
  800601:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800607:	eb 8c                	jmp    800595 <vprintfmt+0x59>
  800609:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80060c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800613:	eb 80                	jmp    800595 <vprintfmt+0x59>
  800615:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800618:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80061b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80061f:	0f 89 70 ff ff ff    	jns    800595 <vprintfmt+0x59>
				width = precision, precision = -1;
  800625:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800628:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80062b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800632:	e9 5e ff ff ff       	jmp    800595 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800637:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80063d:	e9 53 ff ff ff       	jmp    800595 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 50 04             	lea    0x4(%eax),%edx
  800648:	89 55 14             	mov    %edx,0x14(%ebp)
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	ff 30                	pushl  (%eax)
  800651:	ff d6                	call   *%esi
			break;
  800653:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800659:	e9 04 ff ff ff       	jmp    800562 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	99                   	cltd   
  80066a:	31 d0                	xor    %edx,%eax
  80066c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066e:	83 f8 0f             	cmp    $0xf,%eax
  800671:	7f 0b                	jg     80067e <vprintfmt+0x142>
  800673:	8b 14 85 60 24 80 00 	mov    0x802460(,%eax,4),%edx
  80067a:	85 d2                	test   %edx,%edx
  80067c:	75 18                	jne    800696 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80067e:	50                   	push   %eax
  80067f:	68 db 21 80 00       	push   $0x8021db
  800684:	53                   	push   %ebx
  800685:	56                   	push   %esi
  800686:	e8 94 fe ff ff       	call   80051f <printfmt>
  80068b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800691:	e9 cc fe ff ff       	jmp    800562 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800696:	52                   	push   %edx
  800697:	68 a5 25 80 00       	push   $0x8025a5
  80069c:	53                   	push   %ebx
  80069d:	56                   	push   %esi
  80069e:	e8 7c fe ff ff       	call   80051f <printfmt>
  8006a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a9:	e9 b4 fe ff ff       	jmp    800562 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 50 04             	lea    0x4(%eax),%edx
  8006b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b9:	85 ff                	test   %edi,%edi
  8006bb:	b8 d4 21 80 00       	mov    $0x8021d4,%eax
  8006c0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c7:	0f 8e 94 00 00 00    	jle    800761 <vprintfmt+0x225>
  8006cd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006d1:	0f 84 98 00 00 00    	je     80076f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	ff 75 d0             	pushl  -0x30(%ebp)
  8006dd:	57                   	push   %edi
  8006de:	e8 79 03 00 00       	call   800a5c <strnlen>
  8006e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006e6:	29 c1                	sub    %eax,%ecx
  8006e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006eb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ee:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fa:	eb 0f                	jmp    80070b <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	53                   	push   %ebx
  800700:	ff 75 e0             	pushl  -0x20(%ebp)
  800703:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800705:	83 ef 01             	sub    $0x1,%edi
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	85 ff                	test   %edi,%edi
  80070d:	7f ed                	jg     8006fc <vprintfmt+0x1c0>
  80070f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800712:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800715:	85 c9                	test   %ecx,%ecx
  800717:	b8 00 00 00 00       	mov    $0x0,%eax
  80071c:	0f 49 c1             	cmovns %ecx,%eax
  80071f:	29 c1                	sub    %eax,%ecx
  800721:	89 75 08             	mov    %esi,0x8(%ebp)
  800724:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800727:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80072a:	89 cb                	mov    %ecx,%ebx
  80072c:	eb 4d                	jmp    80077b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80072e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800732:	74 1b                	je     80074f <vprintfmt+0x213>
  800734:	0f be c0             	movsbl %al,%eax
  800737:	83 e8 20             	sub    $0x20,%eax
  80073a:	83 f8 5e             	cmp    $0x5e,%eax
  80073d:	76 10                	jbe    80074f <vprintfmt+0x213>
					putch('?', putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	ff 75 0c             	pushl  0xc(%ebp)
  800745:	6a 3f                	push   $0x3f
  800747:	ff 55 08             	call   *0x8(%ebp)
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	eb 0d                	jmp    80075c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	ff 75 0c             	pushl  0xc(%ebp)
  800755:	52                   	push   %edx
  800756:	ff 55 08             	call   *0x8(%ebp)
  800759:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80075c:	83 eb 01             	sub    $0x1,%ebx
  80075f:	eb 1a                	jmp    80077b <vprintfmt+0x23f>
  800761:	89 75 08             	mov    %esi,0x8(%ebp)
  800764:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800767:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80076a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80076d:	eb 0c                	jmp    80077b <vprintfmt+0x23f>
  80076f:	89 75 08             	mov    %esi,0x8(%ebp)
  800772:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800775:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800778:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80077b:	83 c7 01             	add    $0x1,%edi
  80077e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800782:	0f be d0             	movsbl %al,%edx
  800785:	85 d2                	test   %edx,%edx
  800787:	74 23                	je     8007ac <vprintfmt+0x270>
  800789:	85 f6                	test   %esi,%esi
  80078b:	78 a1                	js     80072e <vprintfmt+0x1f2>
  80078d:	83 ee 01             	sub    $0x1,%esi
  800790:	79 9c                	jns    80072e <vprintfmt+0x1f2>
  800792:	89 df                	mov    %ebx,%edi
  800794:	8b 75 08             	mov    0x8(%ebp),%esi
  800797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079a:	eb 18                	jmp    8007b4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	53                   	push   %ebx
  8007a0:	6a 20                	push   $0x20
  8007a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a4:	83 ef 01             	sub    $0x1,%edi
  8007a7:	83 c4 10             	add    $0x10,%esp
  8007aa:	eb 08                	jmp    8007b4 <vprintfmt+0x278>
  8007ac:	89 df                	mov    %ebx,%edi
  8007ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b4:	85 ff                	test   %edi,%edi
  8007b6:	7f e4                	jg     80079c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bb:	e9 a2 fd ff ff       	jmp    800562 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c0:	83 fa 01             	cmp    $0x1,%edx
  8007c3:	7e 16                	jle    8007db <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8d 50 08             	lea    0x8(%eax),%edx
  8007cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ce:	8b 50 04             	mov    0x4(%eax),%edx
  8007d1:	8b 00                	mov    (%eax),%eax
  8007d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d9:	eb 32                	jmp    80080d <vprintfmt+0x2d1>
	else if (lflag)
  8007db:	85 d2                	test   %edx,%edx
  8007dd:	74 18                	je     8007f7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8d 50 04             	lea    0x4(%eax),%edx
  8007e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e8:	8b 00                	mov    (%eax),%eax
  8007ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ed:	89 c1                	mov    %eax,%ecx
  8007ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f5:	eb 16                	jmp    80080d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fa:	8d 50 04             	lea    0x4(%eax),%edx
  8007fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800800:	8b 00                	mov    (%eax),%eax
  800802:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800805:	89 c1                	mov    %eax,%ecx
  800807:	c1 f9 1f             	sar    $0x1f,%ecx
  80080a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80080d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800810:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800813:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800818:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80081c:	79 74                	jns    800892 <vprintfmt+0x356>
				putch('-', putdat);
  80081e:	83 ec 08             	sub    $0x8,%esp
  800821:	53                   	push   %ebx
  800822:	6a 2d                	push   $0x2d
  800824:	ff d6                	call   *%esi
				num = -(long long) num;
  800826:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800829:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80082c:	f7 d8                	neg    %eax
  80082e:	83 d2 00             	adc    $0x0,%edx
  800831:	f7 da                	neg    %edx
  800833:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800836:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80083b:	eb 55                	jmp    800892 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80083d:	8d 45 14             	lea    0x14(%ebp),%eax
  800840:	e8 83 fc ff ff       	call   8004c8 <getuint>
			base = 10;
  800845:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80084a:	eb 46                	jmp    800892 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80084c:	8d 45 14             	lea    0x14(%ebp),%eax
  80084f:	e8 74 fc ff ff       	call   8004c8 <getuint>
			base = 8;
  800854:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800859:	eb 37                	jmp    800892 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	53                   	push   %ebx
  80085f:	6a 30                	push   $0x30
  800861:	ff d6                	call   *%esi
			putch('x', putdat);
  800863:	83 c4 08             	add    $0x8,%esp
  800866:	53                   	push   %ebx
  800867:	6a 78                	push   $0x78
  800869:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80086b:	8b 45 14             	mov    0x14(%ebp),%eax
  80086e:	8d 50 04             	lea    0x4(%eax),%edx
  800871:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800874:	8b 00                	mov    (%eax),%eax
  800876:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80087b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80087e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800883:	eb 0d                	jmp    800892 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800885:	8d 45 14             	lea    0x14(%ebp),%eax
  800888:	e8 3b fc ff ff       	call   8004c8 <getuint>
			base = 16;
  80088d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800892:	83 ec 0c             	sub    $0xc,%esp
  800895:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800899:	57                   	push   %edi
  80089a:	ff 75 e0             	pushl  -0x20(%ebp)
  80089d:	51                   	push   %ecx
  80089e:	52                   	push   %edx
  80089f:	50                   	push   %eax
  8008a0:	89 da                	mov    %ebx,%edx
  8008a2:	89 f0                	mov    %esi,%eax
  8008a4:	e8 70 fb ff ff       	call   800419 <printnum>
			break;
  8008a9:	83 c4 20             	add    $0x20,%esp
  8008ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008af:	e9 ae fc ff ff       	jmp    800562 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	51                   	push   %ecx
  8008b9:	ff d6                	call   *%esi
			break;
  8008bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008c1:	e9 9c fc ff ff       	jmp    800562 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	53                   	push   %ebx
  8008ca:	6a 25                	push   $0x25
  8008cc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ce:	83 c4 10             	add    $0x10,%esp
  8008d1:	eb 03                	jmp    8008d6 <vprintfmt+0x39a>
  8008d3:	83 ef 01             	sub    $0x1,%edi
  8008d6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008da:	75 f7                	jne    8008d3 <vprintfmt+0x397>
  8008dc:	e9 81 fc ff ff       	jmp    800562 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008e4:	5b                   	pop    %ebx
  8008e5:	5e                   	pop    %esi
  8008e6:	5f                   	pop    %edi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	83 ec 18             	sub    $0x18,%esp
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008fc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800906:	85 c0                	test   %eax,%eax
  800908:	74 26                	je     800930 <vsnprintf+0x47>
  80090a:	85 d2                	test   %edx,%edx
  80090c:	7e 22                	jle    800930 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80090e:	ff 75 14             	pushl  0x14(%ebp)
  800911:	ff 75 10             	pushl  0x10(%ebp)
  800914:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800917:	50                   	push   %eax
  800918:	68 02 05 80 00       	push   $0x800502
  80091d:	e8 1a fc ff ff       	call   80053c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800922:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800925:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800928:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80092b:	83 c4 10             	add    $0x10,%esp
  80092e:	eb 05                	jmp    800935 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800930:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80093d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800940:	50                   	push   %eax
  800941:	ff 75 10             	pushl  0x10(%ebp)
  800944:	ff 75 0c             	pushl  0xc(%ebp)
  800947:	ff 75 08             	pushl  0x8(%ebp)
  80094a:	e8 9a ff ff ff       	call   8008e9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80094f:	c9                   	leave  
  800950:	c3                   	ret    

00800951 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	57                   	push   %edi
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	83 ec 0c             	sub    $0xc,%esp
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80095d:	85 c0                	test   %eax,%eax
  80095f:	74 13                	je     800974 <readline+0x23>
		fprintf(1, "%s", prompt);
  800961:	83 ec 04             	sub    $0x4,%esp
  800964:	50                   	push   %eax
  800965:	68 a5 25 80 00       	push   $0x8025a5
  80096a:	6a 01                	push   $0x1
  80096c:	e8 0e 10 00 00       	call   80197f <fprintf>
  800971:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  800974:	83 ec 0c             	sub    $0xc,%esp
  800977:	6a 00                	push   $0x0
  800979:	e8 68 f8 ff ff       	call   8001e6 <iscons>
  80097e:	89 c7                	mov    %eax,%edi
  800980:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  800983:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  800988:	e8 2e f8 ff ff       	call   8001bb <getchar>
  80098d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80098f:	85 c0                	test   %eax,%eax
  800991:	79 29                	jns    8009bc <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800993:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  800998:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80099b:	0f 84 9b 00 00 00    	je     800a3c <readline+0xeb>
				cprintf("read error: %e\n", c);
  8009a1:	83 ec 08             	sub    $0x8,%esp
  8009a4:	53                   	push   %ebx
  8009a5:	68 bf 24 80 00       	push   $0x8024bf
  8009aa:	e8 56 fa ff ff       	call   800405 <cprintf>
  8009af:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b7:	e9 80 00 00 00       	jmp    800a3c <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8009bc:	83 f8 08             	cmp    $0x8,%eax
  8009bf:	0f 94 c2             	sete   %dl
  8009c2:	83 f8 7f             	cmp    $0x7f,%eax
  8009c5:	0f 94 c0             	sete   %al
  8009c8:	08 c2                	or     %al,%dl
  8009ca:	74 1a                	je     8009e6 <readline+0x95>
  8009cc:	85 f6                	test   %esi,%esi
  8009ce:	7e 16                	jle    8009e6 <readline+0x95>
			if (echoing)
  8009d0:	85 ff                	test   %edi,%edi
  8009d2:	74 0d                	je     8009e1 <readline+0x90>
				cputchar('\b');
  8009d4:	83 ec 0c             	sub    $0xc,%esp
  8009d7:	6a 08                	push   $0x8
  8009d9:	e8 c1 f7 ff ff       	call   80019f <cputchar>
  8009de:	83 c4 10             	add    $0x10,%esp
			i--;
  8009e1:	83 ee 01             	sub    $0x1,%esi
  8009e4:	eb a2                	jmp    800988 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8009e6:	83 fb 1f             	cmp    $0x1f,%ebx
  8009e9:	7e 26                	jle    800a11 <readline+0xc0>
  8009eb:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8009f1:	7f 1e                	jg     800a11 <readline+0xc0>
			if (echoing)
  8009f3:	85 ff                	test   %edi,%edi
  8009f5:	74 0c                	je     800a03 <readline+0xb2>
				cputchar(c);
  8009f7:	83 ec 0c             	sub    $0xc,%esp
  8009fa:	53                   	push   %ebx
  8009fb:	e8 9f f7 ff ff       	call   80019f <cputchar>
  800a00:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  800a03:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800a09:	8d 76 01             	lea    0x1(%esi),%esi
  800a0c:	e9 77 ff ff ff       	jmp    800988 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  800a11:	83 fb 0a             	cmp    $0xa,%ebx
  800a14:	74 09                	je     800a1f <readline+0xce>
  800a16:	83 fb 0d             	cmp    $0xd,%ebx
  800a19:	0f 85 69 ff ff ff    	jne    800988 <readline+0x37>
			if (echoing)
  800a1f:	85 ff                	test   %edi,%edi
  800a21:	74 0d                	je     800a30 <readline+0xdf>
				cputchar('\n');
  800a23:	83 ec 0c             	sub    $0xc,%esp
  800a26:	6a 0a                	push   $0xa
  800a28:	e8 72 f7 ff ff       	call   80019f <cputchar>
  800a2d:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  800a30:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800a37:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  800a3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a3f:	5b                   	pop    %ebx
  800a40:	5e                   	pop    %esi
  800a41:	5f                   	pop    %edi
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4f:	eb 03                	jmp    800a54 <strlen+0x10>
		n++;
  800a51:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a54:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a58:	75 f7                	jne    800a51 <strlen+0xd>
		n++;
	return n;
}
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a62:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a65:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6a:	eb 03                	jmp    800a6f <strnlen+0x13>
		n++;
  800a6c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a6f:	39 c2                	cmp    %eax,%edx
  800a71:	74 08                	je     800a7b <strnlen+0x1f>
  800a73:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a77:	75 f3                	jne    800a6c <strnlen+0x10>
  800a79:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a87:	89 c2                	mov    %eax,%edx
  800a89:	83 c2 01             	add    $0x1,%edx
  800a8c:	83 c1 01             	add    $0x1,%ecx
  800a8f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a93:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a96:	84 db                	test   %bl,%bl
  800a98:	75 ef                	jne    800a89 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a9a:	5b                   	pop    %ebx
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	53                   	push   %ebx
  800aa1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa4:	53                   	push   %ebx
  800aa5:	e8 9a ff ff ff       	call   800a44 <strlen>
  800aaa:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800aad:	ff 75 0c             	pushl  0xc(%ebp)
  800ab0:	01 d8                	add    %ebx,%eax
  800ab2:	50                   	push   %eax
  800ab3:	e8 c5 ff ff ff       	call   800a7d <strcpy>
	return dst;
}
  800ab8:	89 d8                	mov    %ebx,%eax
  800aba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800acf:	89 f2                	mov    %esi,%edx
  800ad1:	eb 0f                	jmp    800ae2 <strncpy+0x23>
		*dst++ = *src;
  800ad3:	83 c2 01             	add    $0x1,%edx
  800ad6:	0f b6 01             	movzbl (%ecx),%eax
  800ad9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800adc:	80 39 01             	cmpb   $0x1,(%ecx)
  800adf:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae2:	39 da                	cmp    %ebx,%edx
  800ae4:	75 ed                	jne    800ad3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ae6:	89 f0                	mov    %esi,%eax
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
  800af1:	8b 75 08             	mov    0x8(%ebp),%esi
  800af4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af7:	8b 55 10             	mov    0x10(%ebp),%edx
  800afa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800afc:	85 d2                	test   %edx,%edx
  800afe:	74 21                	je     800b21 <strlcpy+0x35>
  800b00:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b04:	89 f2                	mov    %esi,%edx
  800b06:	eb 09                	jmp    800b11 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b08:	83 c2 01             	add    $0x1,%edx
  800b0b:	83 c1 01             	add    $0x1,%ecx
  800b0e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b11:	39 c2                	cmp    %eax,%edx
  800b13:	74 09                	je     800b1e <strlcpy+0x32>
  800b15:	0f b6 19             	movzbl (%ecx),%ebx
  800b18:	84 db                	test   %bl,%bl
  800b1a:	75 ec                	jne    800b08 <strlcpy+0x1c>
  800b1c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b1e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b21:	29 f0                	sub    %esi,%eax
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b30:	eb 06                	jmp    800b38 <strcmp+0x11>
		p++, q++;
  800b32:	83 c1 01             	add    $0x1,%ecx
  800b35:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b38:	0f b6 01             	movzbl (%ecx),%eax
  800b3b:	84 c0                	test   %al,%al
  800b3d:	74 04                	je     800b43 <strcmp+0x1c>
  800b3f:	3a 02                	cmp    (%edx),%al
  800b41:	74 ef                	je     800b32 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b43:	0f b6 c0             	movzbl %al,%eax
  800b46:	0f b6 12             	movzbl (%edx),%edx
  800b49:	29 d0                	sub    %edx,%eax
}
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	53                   	push   %ebx
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b57:	89 c3                	mov    %eax,%ebx
  800b59:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b5c:	eb 06                	jmp    800b64 <strncmp+0x17>
		n--, p++, q++;
  800b5e:	83 c0 01             	add    $0x1,%eax
  800b61:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b64:	39 d8                	cmp    %ebx,%eax
  800b66:	74 15                	je     800b7d <strncmp+0x30>
  800b68:	0f b6 08             	movzbl (%eax),%ecx
  800b6b:	84 c9                	test   %cl,%cl
  800b6d:	74 04                	je     800b73 <strncmp+0x26>
  800b6f:	3a 0a                	cmp    (%edx),%cl
  800b71:	74 eb                	je     800b5e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b73:	0f b6 00             	movzbl (%eax),%eax
  800b76:	0f b6 12             	movzbl (%edx),%edx
  800b79:	29 d0                	sub    %edx,%eax
  800b7b:	eb 05                	jmp    800b82 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b7d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b82:	5b                   	pop    %ebx
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b8f:	eb 07                	jmp    800b98 <strchr+0x13>
		if (*s == c)
  800b91:	38 ca                	cmp    %cl,%dl
  800b93:	74 0f                	je     800ba4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b95:	83 c0 01             	add    $0x1,%eax
  800b98:	0f b6 10             	movzbl (%eax),%edx
  800b9b:	84 d2                	test   %dl,%dl
  800b9d:	75 f2                	jne    800b91 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb0:	eb 03                	jmp    800bb5 <strfind+0xf>
  800bb2:	83 c0 01             	add    $0x1,%eax
  800bb5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bb8:	38 ca                	cmp    %cl,%dl
  800bba:	74 04                	je     800bc0 <strfind+0x1a>
  800bbc:	84 d2                	test   %dl,%dl
  800bbe:	75 f2                	jne    800bb2 <strfind+0xc>
			break;
	return (char *) s;
}
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bcb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bce:	85 c9                	test   %ecx,%ecx
  800bd0:	74 36                	je     800c08 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bd8:	75 28                	jne    800c02 <memset+0x40>
  800bda:	f6 c1 03             	test   $0x3,%cl
  800bdd:	75 23                	jne    800c02 <memset+0x40>
		c &= 0xFF;
  800bdf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be3:	89 d3                	mov    %edx,%ebx
  800be5:	c1 e3 08             	shl    $0x8,%ebx
  800be8:	89 d6                	mov    %edx,%esi
  800bea:	c1 e6 18             	shl    $0x18,%esi
  800bed:	89 d0                	mov    %edx,%eax
  800bef:	c1 e0 10             	shl    $0x10,%eax
  800bf2:	09 f0                	or     %esi,%eax
  800bf4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bf6:	89 d8                	mov    %ebx,%eax
  800bf8:	09 d0                	or     %edx,%eax
  800bfa:	c1 e9 02             	shr    $0x2,%ecx
  800bfd:	fc                   	cld    
  800bfe:	f3 ab                	rep stos %eax,%es:(%edi)
  800c00:	eb 06                	jmp    800c08 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c05:	fc                   	cld    
  800c06:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c08:	89 f8                	mov    %edi,%eax
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	8b 45 08             	mov    0x8(%ebp),%eax
  800c17:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c1d:	39 c6                	cmp    %eax,%esi
  800c1f:	73 35                	jae    800c56 <memmove+0x47>
  800c21:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c24:	39 d0                	cmp    %edx,%eax
  800c26:	73 2e                	jae    800c56 <memmove+0x47>
		s += n;
		d += n;
  800c28:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2b:	89 d6                	mov    %edx,%esi
  800c2d:	09 fe                	or     %edi,%esi
  800c2f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c35:	75 13                	jne    800c4a <memmove+0x3b>
  800c37:	f6 c1 03             	test   $0x3,%cl
  800c3a:	75 0e                	jne    800c4a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c3c:	83 ef 04             	sub    $0x4,%edi
  800c3f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c42:	c1 e9 02             	shr    $0x2,%ecx
  800c45:	fd                   	std    
  800c46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c48:	eb 09                	jmp    800c53 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c4a:	83 ef 01             	sub    $0x1,%edi
  800c4d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c50:	fd                   	std    
  800c51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c53:	fc                   	cld    
  800c54:	eb 1d                	jmp    800c73 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c56:	89 f2                	mov    %esi,%edx
  800c58:	09 c2                	or     %eax,%edx
  800c5a:	f6 c2 03             	test   $0x3,%dl
  800c5d:	75 0f                	jne    800c6e <memmove+0x5f>
  800c5f:	f6 c1 03             	test   $0x3,%cl
  800c62:	75 0a                	jne    800c6e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c64:	c1 e9 02             	shr    $0x2,%ecx
  800c67:	89 c7                	mov    %eax,%edi
  800c69:	fc                   	cld    
  800c6a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6c:	eb 05                	jmp    800c73 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c6e:	89 c7                	mov    %eax,%edi
  800c70:	fc                   	cld    
  800c71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c7a:	ff 75 10             	pushl  0x10(%ebp)
  800c7d:	ff 75 0c             	pushl  0xc(%ebp)
  800c80:	ff 75 08             	pushl  0x8(%ebp)
  800c83:	e8 87 ff ff ff       	call   800c0f <memmove>
}
  800c88:	c9                   	leave  
  800c89:	c3                   	ret    

00800c8a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c92:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c95:	89 c6                	mov    %eax,%esi
  800c97:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c9a:	eb 1a                	jmp    800cb6 <memcmp+0x2c>
		if (*s1 != *s2)
  800c9c:	0f b6 08             	movzbl (%eax),%ecx
  800c9f:	0f b6 1a             	movzbl (%edx),%ebx
  800ca2:	38 d9                	cmp    %bl,%cl
  800ca4:	74 0a                	je     800cb0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ca6:	0f b6 c1             	movzbl %cl,%eax
  800ca9:	0f b6 db             	movzbl %bl,%ebx
  800cac:	29 d8                	sub    %ebx,%eax
  800cae:	eb 0f                	jmp    800cbf <memcmp+0x35>
		s1++, s2++;
  800cb0:	83 c0 01             	add    $0x1,%eax
  800cb3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb6:	39 f0                	cmp    %esi,%eax
  800cb8:	75 e2                	jne    800c9c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	53                   	push   %ebx
  800cc7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cca:	89 c1                	mov    %eax,%ecx
  800ccc:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ccf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cd3:	eb 0a                	jmp    800cdf <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd5:	0f b6 10             	movzbl (%eax),%edx
  800cd8:	39 da                	cmp    %ebx,%edx
  800cda:	74 07                	je     800ce3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cdc:	83 c0 01             	add    $0x1,%eax
  800cdf:	39 c8                	cmp    %ecx,%eax
  800ce1:	72 f2                	jb     800cd5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ce3:	5b                   	pop    %ebx
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf2:	eb 03                	jmp    800cf7 <strtol+0x11>
		s++;
  800cf4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf7:	0f b6 01             	movzbl (%ecx),%eax
  800cfa:	3c 20                	cmp    $0x20,%al
  800cfc:	74 f6                	je     800cf4 <strtol+0xe>
  800cfe:	3c 09                	cmp    $0x9,%al
  800d00:	74 f2                	je     800cf4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d02:	3c 2b                	cmp    $0x2b,%al
  800d04:	75 0a                	jne    800d10 <strtol+0x2a>
		s++;
  800d06:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d09:	bf 00 00 00 00       	mov    $0x0,%edi
  800d0e:	eb 11                	jmp    800d21 <strtol+0x3b>
  800d10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d15:	3c 2d                	cmp    $0x2d,%al
  800d17:	75 08                	jne    800d21 <strtol+0x3b>
		s++, neg = 1;
  800d19:	83 c1 01             	add    $0x1,%ecx
  800d1c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d21:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d27:	75 15                	jne    800d3e <strtol+0x58>
  800d29:	80 39 30             	cmpb   $0x30,(%ecx)
  800d2c:	75 10                	jne    800d3e <strtol+0x58>
  800d2e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d32:	75 7c                	jne    800db0 <strtol+0xca>
		s += 2, base = 16;
  800d34:	83 c1 02             	add    $0x2,%ecx
  800d37:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d3c:	eb 16                	jmp    800d54 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d3e:	85 db                	test   %ebx,%ebx
  800d40:	75 12                	jne    800d54 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d42:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d47:	80 39 30             	cmpb   $0x30,(%ecx)
  800d4a:	75 08                	jne    800d54 <strtol+0x6e>
		s++, base = 8;
  800d4c:	83 c1 01             	add    $0x1,%ecx
  800d4f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d54:	b8 00 00 00 00       	mov    $0x0,%eax
  800d59:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d5c:	0f b6 11             	movzbl (%ecx),%edx
  800d5f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d62:	89 f3                	mov    %esi,%ebx
  800d64:	80 fb 09             	cmp    $0x9,%bl
  800d67:	77 08                	ja     800d71 <strtol+0x8b>
			dig = *s - '0';
  800d69:	0f be d2             	movsbl %dl,%edx
  800d6c:	83 ea 30             	sub    $0x30,%edx
  800d6f:	eb 22                	jmp    800d93 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d71:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d74:	89 f3                	mov    %esi,%ebx
  800d76:	80 fb 19             	cmp    $0x19,%bl
  800d79:	77 08                	ja     800d83 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d7b:	0f be d2             	movsbl %dl,%edx
  800d7e:	83 ea 57             	sub    $0x57,%edx
  800d81:	eb 10                	jmp    800d93 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d83:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d86:	89 f3                	mov    %esi,%ebx
  800d88:	80 fb 19             	cmp    $0x19,%bl
  800d8b:	77 16                	ja     800da3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d8d:	0f be d2             	movsbl %dl,%edx
  800d90:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d93:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d96:	7d 0b                	jge    800da3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d98:	83 c1 01             	add    $0x1,%ecx
  800d9b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d9f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800da1:	eb b9                	jmp    800d5c <strtol+0x76>

	if (endptr)
  800da3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da7:	74 0d                	je     800db6 <strtol+0xd0>
		*endptr = (char *) s;
  800da9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dac:	89 0e                	mov    %ecx,(%esi)
  800dae:	eb 06                	jmp    800db6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800db0:	85 db                	test   %ebx,%ebx
  800db2:	74 98                	je     800d4c <strtol+0x66>
  800db4:	eb 9e                	jmp    800d54 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800db6:	89 c2                	mov    %eax,%edx
  800db8:	f7 da                	neg    %edx
  800dba:	85 ff                	test   %edi,%edi
  800dbc:	0f 45 c2             	cmovne %edx,%eax
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dca:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	89 c3                	mov    %eax,%ebx
  800dd7:	89 c7                	mov    %eax,%edi
  800dd9:	89 c6                	mov    %eax,%esi
  800ddb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ded:	b8 01 00 00 00       	mov    $0x1,%eax
  800df2:	89 d1                	mov    %edx,%ecx
  800df4:	89 d3                	mov    %edx,%ebx
  800df6:	89 d7                	mov    %edx,%edi
  800df8:	89 d6                	mov    %edx,%esi
  800dfa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0f:	b8 03 00 00 00       	mov    $0x3,%eax
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	89 cb                	mov    %ecx,%ebx
  800e19:	89 cf                	mov    %ecx,%edi
  800e1b:	89 ce                	mov    %ecx,%esi
  800e1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	7e 17                	jle    800e3a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	50                   	push   %eax
  800e27:	6a 03                	push   $0x3
  800e29:	68 cf 24 80 00       	push   $0x8024cf
  800e2e:	6a 23                	push   $0x23
  800e30:	68 ec 24 80 00       	push   $0x8024ec
  800e35:	e8 f2 f4 ff ff       	call   80032c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e48:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e52:	89 d1                	mov    %edx,%ecx
  800e54:	89 d3                	mov    %edx,%ebx
  800e56:	89 d7                	mov    %edx,%edi
  800e58:	89 d6                	mov    %edx,%esi
  800e5a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <sys_yield>:

void
sys_yield(void)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e67:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e71:	89 d1                	mov    %edx,%ecx
  800e73:	89 d3                	mov    %edx,%ebx
  800e75:	89 d7                	mov    %edx,%edi
  800e77:	89 d6                	mov    %edx,%esi
  800e79:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5f                   	pop    %edi
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
  800e86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e89:	be 00 00 00 00       	mov    $0x0,%esi
  800e8e:	b8 04 00 00 00       	mov    $0x4,%eax
  800e93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e96:	8b 55 08             	mov    0x8(%ebp),%edx
  800e99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9c:	89 f7                	mov    %esi,%edi
  800e9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	7e 17                	jle    800ebb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	50                   	push   %eax
  800ea8:	6a 04                	push   $0x4
  800eaa:	68 cf 24 80 00       	push   $0x8024cf
  800eaf:	6a 23                	push   $0x23
  800eb1:	68 ec 24 80 00       	push   $0x8024ec
  800eb6:	e8 71 f4 ff ff       	call   80032c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecc:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eda:	8b 7d 14             	mov    0x14(%ebp),%edi
  800edd:	8b 75 18             	mov    0x18(%ebp),%esi
  800ee0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	7e 17                	jle    800efd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee6:	83 ec 0c             	sub    $0xc,%esp
  800ee9:	50                   	push   %eax
  800eea:	6a 05                	push   $0x5
  800eec:	68 cf 24 80 00       	push   $0x8024cf
  800ef1:	6a 23                	push   $0x23
  800ef3:	68 ec 24 80 00       	push   $0x8024ec
  800ef8:	e8 2f f4 ff ff       	call   80032c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800efd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	57                   	push   %edi
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
  800f0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f13:	b8 06 00 00 00       	mov    $0x6,%eax
  800f18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	89 df                	mov    %ebx,%edi
  800f20:	89 de                	mov    %ebx,%esi
  800f22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f24:	85 c0                	test   %eax,%eax
  800f26:	7e 17                	jle    800f3f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f28:	83 ec 0c             	sub    $0xc,%esp
  800f2b:	50                   	push   %eax
  800f2c:	6a 06                	push   $0x6
  800f2e:	68 cf 24 80 00       	push   $0x8024cf
  800f33:	6a 23                	push   $0x23
  800f35:	68 ec 24 80 00       	push   $0x8024ec
  800f3a:	e8 ed f3 ff ff       	call   80032c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f42:	5b                   	pop    %ebx
  800f43:	5e                   	pop    %esi
  800f44:	5f                   	pop    %edi
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	57                   	push   %edi
  800f4b:	56                   	push   %esi
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f55:	b8 08 00 00 00       	mov    $0x8,%eax
  800f5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f60:	89 df                	mov    %ebx,%edi
  800f62:	89 de                	mov    %ebx,%esi
  800f64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f66:	85 c0                	test   %eax,%eax
  800f68:	7e 17                	jle    800f81 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6a:	83 ec 0c             	sub    $0xc,%esp
  800f6d:	50                   	push   %eax
  800f6e:	6a 08                	push   $0x8
  800f70:	68 cf 24 80 00       	push   $0x8024cf
  800f75:	6a 23                	push   $0x23
  800f77:	68 ec 24 80 00       	push   $0x8024ec
  800f7c:	e8 ab f3 ff ff       	call   80032c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	57                   	push   %edi
  800f8d:	56                   	push   %esi
  800f8e:	53                   	push   %ebx
  800f8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f97:	b8 09 00 00 00       	mov    $0x9,%eax
  800f9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa2:	89 df                	mov    %ebx,%edi
  800fa4:	89 de                	mov    %ebx,%esi
  800fa6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	7e 17                	jle    800fc3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	50                   	push   %eax
  800fb0:	6a 09                	push   $0x9
  800fb2:	68 cf 24 80 00       	push   $0x8024cf
  800fb7:	6a 23                	push   $0x23
  800fb9:	68 ec 24 80 00       	push   $0x8024ec
  800fbe:	e8 69 f3 ff ff       	call   80032c <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc6:	5b                   	pop    %ebx
  800fc7:	5e                   	pop    %esi
  800fc8:	5f                   	pop    %edi
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    

00800fcb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	57                   	push   %edi
  800fcf:	56                   	push   %esi
  800fd0:	53                   	push   %ebx
  800fd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe4:	89 df                	mov    %ebx,%edi
  800fe6:	89 de                	mov    %ebx,%esi
  800fe8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	7e 17                	jle    801005 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fee:	83 ec 0c             	sub    $0xc,%esp
  800ff1:	50                   	push   %eax
  800ff2:	6a 0a                	push   $0xa
  800ff4:	68 cf 24 80 00       	push   $0x8024cf
  800ff9:	6a 23                	push   $0x23
  800ffb:	68 ec 24 80 00       	push   $0x8024ec
  801000:	e8 27 f3 ff ff       	call   80032c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801005:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    

0080100d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	57                   	push   %edi
  801011:	56                   	push   %esi
  801012:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801013:	be 00 00 00 00       	mov    $0x0,%esi
  801018:	b8 0c 00 00 00       	mov    $0xc,%eax
  80101d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801020:	8b 55 08             	mov    0x8(%ebp),%edx
  801023:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801026:	8b 7d 14             	mov    0x14(%ebp),%edi
  801029:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80102b:	5b                   	pop    %ebx
  80102c:	5e                   	pop    %esi
  80102d:	5f                   	pop    %edi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	57                   	push   %edi
  801034:	56                   	push   %esi
  801035:	53                   	push   %ebx
  801036:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801039:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801043:	8b 55 08             	mov    0x8(%ebp),%edx
  801046:	89 cb                	mov    %ecx,%ebx
  801048:	89 cf                	mov    %ecx,%edi
  80104a:	89 ce                	mov    %ecx,%esi
  80104c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80104e:	85 c0                	test   %eax,%eax
  801050:	7e 17                	jle    801069 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801052:	83 ec 0c             	sub    $0xc,%esp
  801055:	50                   	push   %eax
  801056:	6a 0d                	push   $0xd
  801058:	68 cf 24 80 00       	push   $0x8024cf
  80105d:	6a 23                	push   $0x23
  80105f:	68 ec 24 80 00       	push   $0x8024ec
  801064:	e8 c3 f2 ff ff       	call   80032c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801069:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106c:	5b                   	pop    %ebx
  80106d:	5e                   	pop    %esi
  80106e:	5f                   	pop    %edi
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	57                   	push   %edi
  801075:	56                   	push   %esi
  801076:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801077:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801081:	8b 55 08             	mov    0x8(%ebp),%edx
  801084:	89 cb                	mov    %ecx,%ebx
  801086:	89 cf                	mov    %ecx,%edi
  801088:	89 ce                	mov    %ecx,%esi
  80108a:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  80108c:	5b                   	pop    %ebx
  80108d:	5e                   	pop    %esi
  80108e:	5f                   	pop    %edi
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    

00801091 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801094:	8b 45 08             	mov    0x8(%ebp),%eax
  801097:	05 00 00 00 30       	add    $0x30000000,%eax
  80109c:	c1 e8 0c             	shr    $0xc,%eax
}
  80109f:	5d                   	pop    %ebp
  8010a0:	c3                   	ret    

008010a1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a7:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010b1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    

008010b8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010be:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010c3:	89 c2                	mov    %eax,%edx
  8010c5:	c1 ea 16             	shr    $0x16,%edx
  8010c8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010cf:	f6 c2 01             	test   $0x1,%dl
  8010d2:	74 11                	je     8010e5 <fd_alloc+0x2d>
  8010d4:	89 c2                	mov    %eax,%edx
  8010d6:	c1 ea 0c             	shr    $0xc,%edx
  8010d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010e0:	f6 c2 01             	test   $0x1,%dl
  8010e3:	75 09                	jne    8010ee <fd_alloc+0x36>
			*fd_store = fd;
  8010e5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ec:	eb 17                	jmp    801105 <fd_alloc+0x4d>
  8010ee:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010f3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010f8:	75 c9                	jne    8010c3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010fa:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801100:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80110d:	83 f8 1f             	cmp    $0x1f,%eax
  801110:	77 36                	ja     801148 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801112:	c1 e0 0c             	shl    $0xc,%eax
  801115:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80111a:	89 c2                	mov    %eax,%edx
  80111c:	c1 ea 16             	shr    $0x16,%edx
  80111f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801126:	f6 c2 01             	test   $0x1,%dl
  801129:	74 24                	je     80114f <fd_lookup+0x48>
  80112b:	89 c2                	mov    %eax,%edx
  80112d:	c1 ea 0c             	shr    $0xc,%edx
  801130:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801137:	f6 c2 01             	test   $0x1,%dl
  80113a:	74 1a                	je     801156 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80113c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113f:	89 02                	mov    %eax,(%edx)
	return 0;
  801141:	b8 00 00 00 00       	mov    $0x0,%eax
  801146:	eb 13                	jmp    80115b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801148:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80114d:	eb 0c                	jmp    80115b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80114f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801154:	eb 05                	jmp    80115b <fd_lookup+0x54>
  801156:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	83 ec 08             	sub    $0x8,%esp
  801163:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801166:	ba 7c 25 80 00       	mov    $0x80257c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80116b:	eb 13                	jmp    801180 <dev_lookup+0x23>
  80116d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801170:	39 08                	cmp    %ecx,(%eax)
  801172:	75 0c                	jne    801180 <dev_lookup+0x23>
			*dev = devtab[i];
  801174:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801177:	89 01                	mov    %eax,(%ecx)
			return 0;
  801179:	b8 00 00 00 00       	mov    $0x0,%eax
  80117e:	eb 2e                	jmp    8011ae <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801180:	8b 02                	mov    (%edx),%eax
  801182:	85 c0                	test   %eax,%eax
  801184:	75 e7                	jne    80116d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801186:	a1 04 44 80 00       	mov    0x804404,%eax
  80118b:	8b 40 50             	mov    0x50(%eax),%eax
  80118e:	83 ec 04             	sub    $0x4,%esp
  801191:	51                   	push   %ecx
  801192:	50                   	push   %eax
  801193:	68 fc 24 80 00       	push   $0x8024fc
  801198:	e8 68 f2 ff ff       	call   800405 <cprintf>
	*dev = 0;
  80119d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011a6:	83 c4 10             	add    $0x10,%esp
  8011a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ae:	c9                   	leave  
  8011af:	c3                   	ret    

008011b0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	56                   	push   %esi
  8011b4:	53                   	push   %ebx
  8011b5:	83 ec 10             	sub    $0x10,%esp
  8011b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8011bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c1:	50                   	push   %eax
  8011c2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011c8:	c1 e8 0c             	shr    $0xc,%eax
  8011cb:	50                   	push   %eax
  8011cc:	e8 36 ff ff ff       	call   801107 <fd_lookup>
  8011d1:	83 c4 08             	add    $0x8,%esp
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 05                	js     8011dd <fd_close+0x2d>
	    || fd != fd2)
  8011d8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011db:	74 0c                	je     8011e9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011dd:	84 db                	test   %bl,%bl
  8011df:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e4:	0f 44 c2             	cmove  %edx,%eax
  8011e7:	eb 41                	jmp    80122a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011e9:	83 ec 08             	sub    $0x8,%esp
  8011ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ef:	50                   	push   %eax
  8011f0:	ff 36                	pushl  (%esi)
  8011f2:	e8 66 ff ff ff       	call   80115d <dev_lookup>
  8011f7:	89 c3                	mov    %eax,%ebx
  8011f9:	83 c4 10             	add    $0x10,%esp
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	78 1a                	js     80121a <fd_close+0x6a>
		if (dev->dev_close)
  801200:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801203:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801206:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80120b:	85 c0                	test   %eax,%eax
  80120d:	74 0b                	je     80121a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80120f:	83 ec 0c             	sub    $0xc,%esp
  801212:	56                   	push   %esi
  801213:	ff d0                	call   *%eax
  801215:	89 c3                	mov    %eax,%ebx
  801217:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80121a:	83 ec 08             	sub    $0x8,%esp
  80121d:	56                   	push   %esi
  80121e:	6a 00                	push   $0x0
  801220:	e8 e0 fc ff ff       	call   800f05 <sys_page_unmap>
	return r;
  801225:	83 c4 10             	add    $0x10,%esp
  801228:	89 d8                	mov    %ebx,%eax
}
  80122a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80122d:	5b                   	pop    %ebx
  80122e:	5e                   	pop    %esi
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    

00801231 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801237:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123a:	50                   	push   %eax
  80123b:	ff 75 08             	pushl  0x8(%ebp)
  80123e:	e8 c4 fe ff ff       	call   801107 <fd_lookup>
  801243:	83 c4 08             	add    $0x8,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	78 10                	js     80125a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	6a 01                	push   $0x1
  80124f:	ff 75 f4             	pushl  -0xc(%ebp)
  801252:	e8 59 ff ff ff       	call   8011b0 <fd_close>
  801257:	83 c4 10             	add    $0x10,%esp
}
  80125a:	c9                   	leave  
  80125b:	c3                   	ret    

0080125c <close_all>:

void
close_all(void)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	53                   	push   %ebx
  801260:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801263:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801268:	83 ec 0c             	sub    $0xc,%esp
  80126b:	53                   	push   %ebx
  80126c:	e8 c0 ff ff ff       	call   801231 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801271:	83 c3 01             	add    $0x1,%ebx
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	83 fb 20             	cmp    $0x20,%ebx
  80127a:	75 ec                	jne    801268 <close_all+0xc>
		close(i);
}
  80127c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127f:	c9                   	leave  
  801280:	c3                   	ret    

00801281 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	57                   	push   %edi
  801285:	56                   	push   %esi
  801286:	53                   	push   %ebx
  801287:	83 ec 2c             	sub    $0x2c,%esp
  80128a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80128d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801290:	50                   	push   %eax
  801291:	ff 75 08             	pushl  0x8(%ebp)
  801294:	e8 6e fe ff ff       	call   801107 <fd_lookup>
  801299:	83 c4 08             	add    $0x8,%esp
  80129c:	85 c0                	test   %eax,%eax
  80129e:	0f 88 c1 00 00 00    	js     801365 <dup+0xe4>
		return r;
	close(newfdnum);
  8012a4:	83 ec 0c             	sub    $0xc,%esp
  8012a7:	56                   	push   %esi
  8012a8:	e8 84 ff ff ff       	call   801231 <close>

	newfd = INDEX2FD(newfdnum);
  8012ad:	89 f3                	mov    %esi,%ebx
  8012af:	c1 e3 0c             	shl    $0xc,%ebx
  8012b2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012b8:	83 c4 04             	add    $0x4,%esp
  8012bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012be:	e8 de fd ff ff       	call   8010a1 <fd2data>
  8012c3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012c5:	89 1c 24             	mov    %ebx,(%esp)
  8012c8:	e8 d4 fd ff ff       	call   8010a1 <fd2data>
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012d3:	89 f8                	mov    %edi,%eax
  8012d5:	c1 e8 16             	shr    $0x16,%eax
  8012d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012df:	a8 01                	test   $0x1,%al
  8012e1:	74 37                	je     80131a <dup+0x99>
  8012e3:	89 f8                	mov    %edi,%eax
  8012e5:	c1 e8 0c             	shr    $0xc,%eax
  8012e8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ef:	f6 c2 01             	test   $0x1,%dl
  8012f2:	74 26                	je     80131a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012fb:	83 ec 0c             	sub    $0xc,%esp
  8012fe:	25 07 0e 00 00       	and    $0xe07,%eax
  801303:	50                   	push   %eax
  801304:	ff 75 d4             	pushl  -0x2c(%ebp)
  801307:	6a 00                	push   $0x0
  801309:	57                   	push   %edi
  80130a:	6a 00                	push   $0x0
  80130c:	e8 b2 fb ff ff       	call   800ec3 <sys_page_map>
  801311:	89 c7                	mov    %eax,%edi
  801313:	83 c4 20             	add    $0x20,%esp
  801316:	85 c0                	test   %eax,%eax
  801318:	78 2e                	js     801348 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80131a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80131d:	89 d0                	mov    %edx,%eax
  80131f:	c1 e8 0c             	shr    $0xc,%eax
  801322:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801329:	83 ec 0c             	sub    $0xc,%esp
  80132c:	25 07 0e 00 00       	and    $0xe07,%eax
  801331:	50                   	push   %eax
  801332:	53                   	push   %ebx
  801333:	6a 00                	push   $0x0
  801335:	52                   	push   %edx
  801336:	6a 00                	push   $0x0
  801338:	e8 86 fb ff ff       	call   800ec3 <sys_page_map>
  80133d:	89 c7                	mov    %eax,%edi
  80133f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801342:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801344:	85 ff                	test   %edi,%edi
  801346:	79 1d                	jns    801365 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801348:	83 ec 08             	sub    $0x8,%esp
  80134b:	53                   	push   %ebx
  80134c:	6a 00                	push   $0x0
  80134e:	e8 b2 fb ff ff       	call   800f05 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801353:	83 c4 08             	add    $0x8,%esp
  801356:	ff 75 d4             	pushl  -0x2c(%ebp)
  801359:	6a 00                	push   $0x0
  80135b:	e8 a5 fb ff ff       	call   800f05 <sys_page_unmap>
	return r;
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	89 f8                	mov    %edi,%eax
}
  801365:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801368:	5b                   	pop    %ebx
  801369:	5e                   	pop    %esi
  80136a:	5f                   	pop    %edi
  80136b:	5d                   	pop    %ebp
  80136c:	c3                   	ret    

0080136d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	53                   	push   %ebx
  801371:	83 ec 14             	sub    $0x14,%esp
  801374:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801377:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137a:	50                   	push   %eax
  80137b:	53                   	push   %ebx
  80137c:	e8 86 fd ff ff       	call   801107 <fd_lookup>
  801381:	83 c4 08             	add    $0x8,%esp
  801384:	89 c2                	mov    %eax,%edx
  801386:	85 c0                	test   %eax,%eax
  801388:	78 6d                	js     8013f7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138a:	83 ec 08             	sub    $0x8,%esp
  80138d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801390:	50                   	push   %eax
  801391:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801394:	ff 30                	pushl  (%eax)
  801396:	e8 c2 fd ff ff       	call   80115d <dev_lookup>
  80139b:	83 c4 10             	add    $0x10,%esp
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	78 4c                	js     8013ee <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013a5:	8b 42 08             	mov    0x8(%edx),%eax
  8013a8:	83 e0 03             	and    $0x3,%eax
  8013ab:	83 f8 01             	cmp    $0x1,%eax
  8013ae:	75 21                	jne    8013d1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013b0:	a1 04 44 80 00       	mov    0x804404,%eax
  8013b5:	8b 40 50             	mov    0x50(%eax),%eax
  8013b8:	83 ec 04             	sub    $0x4,%esp
  8013bb:	53                   	push   %ebx
  8013bc:	50                   	push   %eax
  8013bd:	68 40 25 80 00       	push   $0x802540
  8013c2:	e8 3e f0 ff ff       	call   800405 <cprintf>
		return -E_INVAL;
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013cf:	eb 26                	jmp    8013f7 <read+0x8a>
	}
	if (!dev->dev_read)
  8013d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d4:	8b 40 08             	mov    0x8(%eax),%eax
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	74 17                	je     8013f2 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013db:	83 ec 04             	sub    $0x4,%esp
  8013de:	ff 75 10             	pushl  0x10(%ebp)
  8013e1:	ff 75 0c             	pushl  0xc(%ebp)
  8013e4:	52                   	push   %edx
  8013e5:	ff d0                	call   *%eax
  8013e7:	89 c2                	mov    %eax,%edx
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	eb 09                	jmp    8013f7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	eb 05                	jmp    8013f7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8013f7:	89 d0                	mov    %edx,%eax
  8013f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fc:	c9                   	leave  
  8013fd:	c3                   	ret    

008013fe <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	57                   	push   %edi
  801402:	56                   	push   %esi
  801403:	53                   	push   %ebx
  801404:	83 ec 0c             	sub    $0xc,%esp
  801407:	8b 7d 08             	mov    0x8(%ebp),%edi
  80140a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80140d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801412:	eb 21                	jmp    801435 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801414:	83 ec 04             	sub    $0x4,%esp
  801417:	89 f0                	mov    %esi,%eax
  801419:	29 d8                	sub    %ebx,%eax
  80141b:	50                   	push   %eax
  80141c:	89 d8                	mov    %ebx,%eax
  80141e:	03 45 0c             	add    0xc(%ebp),%eax
  801421:	50                   	push   %eax
  801422:	57                   	push   %edi
  801423:	e8 45 ff ff ff       	call   80136d <read>
		if (m < 0)
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	85 c0                	test   %eax,%eax
  80142d:	78 10                	js     80143f <readn+0x41>
			return m;
		if (m == 0)
  80142f:	85 c0                	test   %eax,%eax
  801431:	74 0a                	je     80143d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801433:	01 c3                	add    %eax,%ebx
  801435:	39 f3                	cmp    %esi,%ebx
  801437:	72 db                	jb     801414 <readn+0x16>
  801439:	89 d8                	mov    %ebx,%eax
  80143b:	eb 02                	jmp    80143f <readn+0x41>
  80143d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80143f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801442:	5b                   	pop    %ebx
  801443:	5e                   	pop    %esi
  801444:	5f                   	pop    %edi
  801445:	5d                   	pop    %ebp
  801446:	c3                   	ret    

00801447 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801447:	55                   	push   %ebp
  801448:	89 e5                	mov    %esp,%ebp
  80144a:	53                   	push   %ebx
  80144b:	83 ec 14             	sub    $0x14,%esp
  80144e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801451:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	53                   	push   %ebx
  801456:	e8 ac fc ff ff       	call   801107 <fd_lookup>
  80145b:	83 c4 08             	add    $0x8,%esp
  80145e:	89 c2                	mov    %eax,%edx
  801460:	85 c0                	test   %eax,%eax
  801462:	78 68                	js     8014cc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801464:	83 ec 08             	sub    $0x8,%esp
  801467:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146a:	50                   	push   %eax
  80146b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146e:	ff 30                	pushl  (%eax)
  801470:	e8 e8 fc ff ff       	call   80115d <dev_lookup>
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 47                	js     8014c3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80147c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801483:	75 21                	jne    8014a6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801485:	a1 04 44 80 00       	mov    0x804404,%eax
  80148a:	8b 40 50             	mov    0x50(%eax),%eax
  80148d:	83 ec 04             	sub    $0x4,%esp
  801490:	53                   	push   %ebx
  801491:	50                   	push   %eax
  801492:	68 5c 25 80 00       	push   $0x80255c
  801497:	e8 69 ef ff ff       	call   800405 <cprintf>
		return -E_INVAL;
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014a4:	eb 26                	jmp    8014cc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a9:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ac:	85 d2                	test   %edx,%edx
  8014ae:	74 17                	je     8014c7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014b0:	83 ec 04             	sub    $0x4,%esp
  8014b3:	ff 75 10             	pushl  0x10(%ebp)
  8014b6:	ff 75 0c             	pushl  0xc(%ebp)
  8014b9:	50                   	push   %eax
  8014ba:	ff d2                	call   *%edx
  8014bc:	89 c2                	mov    %eax,%edx
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	eb 09                	jmp    8014cc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c3:	89 c2                	mov    %eax,%edx
  8014c5:	eb 05                	jmp    8014cc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014cc:	89 d0                	mov    %edx,%eax
  8014ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d1:	c9                   	leave  
  8014d2:	c3                   	ret    

008014d3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014dc:	50                   	push   %eax
  8014dd:	ff 75 08             	pushl  0x8(%ebp)
  8014e0:	e8 22 fc ff ff       	call   801107 <fd_lookup>
  8014e5:	83 c4 08             	add    $0x8,%esp
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 0e                	js     8014fa <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	53                   	push   %ebx
  801500:	83 ec 14             	sub    $0x14,%esp
  801503:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801506:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801509:	50                   	push   %eax
  80150a:	53                   	push   %ebx
  80150b:	e8 f7 fb ff ff       	call   801107 <fd_lookup>
  801510:	83 c4 08             	add    $0x8,%esp
  801513:	89 c2                	mov    %eax,%edx
  801515:	85 c0                	test   %eax,%eax
  801517:	78 65                	js     80157e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801523:	ff 30                	pushl  (%eax)
  801525:	e8 33 fc ff ff       	call   80115d <dev_lookup>
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 44                	js     801575 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801531:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801534:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801538:	75 21                	jne    80155b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80153a:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80153f:	8b 40 50             	mov    0x50(%eax),%eax
  801542:	83 ec 04             	sub    $0x4,%esp
  801545:	53                   	push   %ebx
  801546:	50                   	push   %eax
  801547:	68 1c 25 80 00       	push   $0x80251c
  80154c:	e8 b4 ee ff ff       	call   800405 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801559:	eb 23                	jmp    80157e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80155b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80155e:	8b 52 18             	mov    0x18(%edx),%edx
  801561:	85 d2                	test   %edx,%edx
  801563:	74 14                	je     801579 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801565:	83 ec 08             	sub    $0x8,%esp
  801568:	ff 75 0c             	pushl  0xc(%ebp)
  80156b:	50                   	push   %eax
  80156c:	ff d2                	call   *%edx
  80156e:	89 c2                	mov    %eax,%edx
  801570:	83 c4 10             	add    $0x10,%esp
  801573:	eb 09                	jmp    80157e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801575:	89 c2                	mov    %eax,%edx
  801577:	eb 05                	jmp    80157e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801579:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80157e:	89 d0                	mov    %edx,%eax
  801580:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801583:	c9                   	leave  
  801584:	c3                   	ret    

00801585 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	53                   	push   %ebx
  801589:	83 ec 14             	sub    $0x14,%esp
  80158c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801592:	50                   	push   %eax
  801593:	ff 75 08             	pushl  0x8(%ebp)
  801596:	e8 6c fb ff ff       	call   801107 <fd_lookup>
  80159b:	83 c4 08             	add    $0x8,%esp
  80159e:	89 c2                	mov    %eax,%edx
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	78 58                	js     8015fc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a4:	83 ec 08             	sub    $0x8,%esp
  8015a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015aa:	50                   	push   %eax
  8015ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ae:	ff 30                	pushl  (%eax)
  8015b0:	e8 a8 fb ff ff       	call   80115d <dev_lookup>
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 37                	js     8015f3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015c3:	74 32                	je     8015f7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015c5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015c8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015cf:	00 00 00 
	stat->st_isdir = 0;
  8015d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015d9:	00 00 00 
	stat->st_dev = dev;
  8015dc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	53                   	push   %ebx
  8015e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8015e9:	ff 50 14             	call   *0x14(%eax)
  8015ec:	89 c2                	mov    %eax,%edx
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	eb 09                	jmp    8015fc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f3:	89 c2                	mov    %eax,%edx
  8015f5:	eb 05                	jmp    8015fc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015f7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015fc:	89 d0                	mov    %edx,%eax
  8015fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801601:	c9                   	leave  
  801602:	c3                   	ret    

00801603 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	56                   	push   %esi
  801607:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801608:	83 ec 08             	sub    $0x8,%esp
  80160b:	6a 00                	push   $0x0
  80160d:	ff 75 08             	pushl  0x8(%ebp)
  801610:	e8 e3 01 00 00       	call   8017f8 <open>
  801615:	89 c3                	mov    %eax,%ebx
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	85 c0                	test   %eax,%eax
  80161c:	78 1b                	js     801639 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	ff 75 0c             	pushl  0xc(%ebp)
  801624:	50                   	push   %eax
  801625:	e8 5b ff ff ff       	call   801585 <fstat>
  80162a:	89 c6                	mov    %eax,%esi
	close(fd);
  80162c:	89 1c 24             	mov    %ebx,(%esp)
  80162f:	e8 fd fb ff ff       	call   801231 <close>
	return r;
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	89 f0                	mov    %esi,%eax
}
  801639:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80163c:	5b                   	pop    %ebx
  80163d:	5e                   	pop    %esi
  80163e:	5d                   	pop    %ebp
  80163f:	c3                   	ret    

00801640 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	56                   	push   %esi
  801644:	53                   	push   %ebx
  801645:	89 c6                	mov    %eax,%esi
  801647:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801649:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  801650:	75 12                	jne    801664 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801652:	83 ec 0c             	sub    $0xc,%esp
  801655:	6a 01                	push   $0x1
  801657:	e8 83 07 00 00       	call   801ddf <ipc_find_env>
  80165c:	a3 00 44 80 00       	mov    %eax,0x804400
  801661:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801664:	6a 07                	push   $0x7
  801666:	68 00 50 80 00       	push   $0x805000
  80166b:	56                   	push   %esi
  80166c:	ff 35 00 44 80 00    	pushl  0x804400
  801672:	e8 06 07 00 00       	call   801d7d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801677:	83 c4 0c             	add    $0xc,%esp
  80167a:	6a 00                	push   $0x0
  80167c:	53                   	push   %ebx
  80167d:	6a 00                	push   $0x0
  80167f:	e8 84 06 00 00       	call   801d08 <ipc_recv>
}
  801684:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801687:	5b                   	pop    %ebx
  801688:	5e                   	pop    %esi
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801691:	8b 45 08             	mov    0x8(%ebp),%eax
  801694:	8b 40 0c             	mov    0xc(%eax),%eax
  801697:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80169c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a9:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ae:	e8 8d ff ff ff       	call   801640 <fsipc>
}
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016be:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cb:	b8 06 00 00 00       	mov    $0x6,%eax
  8016d0:	e8 6b ff ff ff       	call   801640 <fsipc>
}
  8016d5:	c9                   	leave  
  8016d6:	c3                   	ret    

008016d7 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	53                   	push   %ebx
  8016db:	83 ec 04             	sub    $0x4,%esp
  8016de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f1:	b8 05 00 00 00       	mov    $0x5,%eax
  8016f6:	e8 45 ff ff ff       	call   801640 <fsipc>
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	78 2c                	js     80172b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016ff:	83 ec 08             	sub    $0x8,%esp
  801702:	68 00 50 80 00       	push   $0x805000
  801707:	53                   	push   %ebx
  801708:	e8 70 f3 ff ff       	call   800a7d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80170d:	a1 80 50 80 00       	mov    0x805080,%eax
  801712:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801718:	a1 84 50 80 00       	mov    0x805084,%eax
  80171d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80172b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172e:	c9                   	leave  
  80172f:	c3                   	ret    

00801730 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	83 ec 0c             	sub    $0xc,%esp
  801736:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801739:	8b 55 08             	mov    0x8(%ebp),%edx
  80173c:	8b 52 0c             	mov    0xc(%edx),%edx
  80173f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801745:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80174a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80174f:	0f 47 c2             	cmova  %edx,%eax
  801752:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801757:	50                   	push   %eax
  801758:	ff 75 0c             	pushl  0xc(%ebp)
  80175b:	68 08 50 80 00       	push   $0x805008
  801760:	e8 aa f4 ff ff       	call   800c0f <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801765:	ba 00 00 00 00       	mov    $0x0,%edx
  80176a:	b8 04 00 00 00       	mov    $0x4,%eax
  80176f:	e8 cc fe ff ff       	call   801640 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801774:	c9                   	leave  
  801775:	c3                   	ret    

00801776 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	56                   	push   %esi
  80177a:	53                   	push   %ebx
  80177b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80177e:	8b 45 08             	mov    0x8(%ebp),%eax
  801781:	8b 40 0c             	mov    0xc(%eax),%eax
  801784:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801789:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80178f:	ba 00 00 00 00       	mov    $0x0,%edx
  801794:	b8 03 00 00 00       	mov    $0x3,%eax
  801799:	e8 a2 fe ff ff       	call   801640 <fsipc>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	85 c0                	test   %eax,%eax
  8017a2:	78 4b                	js     8017ef <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017a4:	39 c6                	cmp    %eax,%esi
  8017a6:	73 16                	jae    8017be <devfile_read+0x48>
  8017a8:	68 8c 25 80 00       	push   $0x80258c
  8017ad:	68 93 25 80 00       	push   $0x802593
  8017b2:	6a 7c                	push   $0x7c
  8017b4:	68 a8 25 80 00       	push   $0x8025a8
  8017b9:	e8 6e eb ff ff       	call   80032c <_panic>
	assert(r <= PGSIZE);
  8017be:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017c3:	7e 16                	jle    8017db <devfile_read+0x65>
  8017c5:	68 b3 25 80 00       	push   $0x8025b3
  8017ca:	68 93 25 80 00       	push   $0x802593
  8017cf:	6a 7d                	push   $0x7d
  8017d1:	68 a8 25 80 00       	push   $0x8025a8
  8017d6:	e8 51 eb ff ff       	call   80032c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017db:	83 ec 04             	sub    $0x4,%esp
  8017de:	50                   	push   %eax
  8017df:	68 00 50 80 00       	push   $0x805000
  8017e4:	ff 75 0c             	pushl  0xc(%ebp)
  8017e7:	e8 23 f4 ff ff       	call   800c0f <memmove>
	return r;
  8017ec:	83 c4 10             	add    $0x10,%esp
}
  8017ef:	89 d8                	mov    %ebx,%eax
  8017f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f4:	5b                   	pop    %ebx
  8017f5:	5e                   	pop    %esi
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    

008017f8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	53                   	push   %ebx
  8017fc:	83 ec 20             	sub    $0x20,%esp
  8017ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801802:	53                   	push   %ebx
  801803:	e8 3c f2 ff ff       	call   800a44 <strlen>
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801810:	7f 67                	jg     801879 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801812:	83 ec 0c             	sub    $0xc,%esp
  801815:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801818:	50                   	push   %eax
  801819:	e8 9a f8 ff ff       	call   8010b8 <fd_alloc>
  80181e:	83 c4 10             	add    $0x10,%esp
		return r;
  801821:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801823:	85 c0                	test   %eax,%eax
  801825:	78 57                	js     80187e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801827:	83 ec 08             	sub    $0x8,%esp
  80182a:	53                   	push   %ebx
  80182b:	68 00 50 80 00       	push   $0x805000
  801830:	e8 48 f2 ff ff       	call   800a7d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801835:	8b 45 0c             	mov    0xc(%ebp),%eax
  801838:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80183d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801840:	b8 01 00 00 00       	mov    $0x1,%eax
  801845:	e8 f6 fd ff ff       	call   801640 <fsipc>
  80184a:	89 c3                	mov    %eax,%ebx
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	85 c0                	test   %eax,%eax
  801851:	79 14                	jns    801867 <open+0x6f>
		fd_close(fd, 0);
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	6a 00                	push   $0x0
  801858:	ff 75 f4             	pushl  -0xc(%ebp)
  80185b:	e8 50 f9 ff ff       	call   8011b0 <fd_close>
		return r;
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	89 da                	mov    %ebx,%edx
  801865:	eb 17                	jmp    80187e <open+0x86>
	}

	return fd2num(fd);
  801867:	83 ec 0c             	sub    $0xc,%esp
  80186a:	ff 75 f4             	pushl  -0xc(%ebp)
  80186d:	e8 1f f8 ff ff       	call   801091 <fd2num>
  801872:	89 c2                	mov    %eax,%edx
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	eb 05                	jmp    80187e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801879:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80187e:	89 d0                	mov    %edx,%eax
  801880:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801883:	c9                   	leave  
  801884:	c3                   	ret    

00801885 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80188b:	ba 00 00 00 00       	mov    $0x0,%edx
  801890:	b8 08 00 00 00       	mov    $0x8,%eax
  801895:	e8 a6 fd ff ff       	call   801640 <fsipc>
}
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80189c:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8018a0:	7e 37                	jle    8018d9 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	53                   	push   %ebx
  8018a6:	83 ec 08             	sub    $0x8,%esp
  8018a9:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018ab:	ff 70 04             	pushl  0x4(%eax)
  8018ae:	8d 40 10             	lea    0x10(%eax),%eax
  8018b1:	50                   	push   %eax
  8018b2:	ff 33                	pushl  (%ebx)
  8018b4:	e8 8e fb ff ff       	call   801447 <write>
		if (result > 0)
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	7e 03                	jle    8018c3 <writebuf+0x27>
			b->result += result;
  8018c0:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8018c3:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018c6:	74 0d                	je     8018d5 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cf:	0f 4f c2             	cmovg  %edx,%eax
  8018d2:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8018d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d8:	c9                   	leave  
  8018d9:	f3 c3                	repz ret 

008018db <putch>:

static void
putch(int ch, void *thunk)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	53                   	push   %ebx
  8018df:	83 ec 04             	sub    $0x4,%esp
  8018e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018e5:	8b 53 04             	mov    0x4(%ebx),%edx
  8018e8:	8d 42 01             	lea    0x1(%edx),%eax
  8018eb:	89 43 04             	mov    %eax,0x4(%ebx)
  8018ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f1:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8018f5:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018fa:	75 0e                	jne    80190a <putch+0x2f>
		writebuf(b);
  8018fc:	89 d8                	mov    %ebx,%eax
  8018fe:	e8 99 ff ff ff       	call   80189c <writebuf>
		b->idx = 0;
  801903:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80190a:	83 c4 04             	add    $0x4,%esp
  80190d:	5b                   	pop    %ebx
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    

00801910 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801919:	8b 45 08             	mov    0x8(%ebp),%eax
  80191c:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801922:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801929:	00 00 00 
	b.result = 0;
  80192c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801933:	00 00 00 
	b.error = 1;
  801936:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80193d:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801940:	ff 75 10             	pushl  0x10(%ebp)
  801943:	ff 75 0c             	pushl  0xc(%ebp)
  801946:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80194c:	50                   	push   %eax
  80194d:	68 db 18 80 00       	push   $0x8018db
  801952:	e8 e5 eb ff ff       	call   80053c <vprintfmt>
	if (b.idx > 0)
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801961:	7e 0b                	jle    80196e <vfprintf+0x5e>
		writebuf(&b);
  801963:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801969:	e8 2e ff ff ff       	call   80189c <writebuf>

	return (b.result ? b.result : b.error);
  80196e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801974:	85 c0                	test   %eax,%eax
  801976:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80197d:	c9                   	leave  
  80197e:	c3                   	ret    

0080197f <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801985:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801988:	50                   	push   %eax
  801989:	ff 75 0c             	pushl  0xc(%ebp)
  80198c:	ff 75 08             	pushl  0x8(%ebp)
  80198f:	e8 7c ff ff ff       	call   801910 <vfprintf>
	va_end(ap);

	return cnt;
}
  801994:	c9                   	leave  
  801995:	c3                   	ret    

00801996 <printf>:

int
printf(const char *fmt, ...)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80199c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80199f:	50                   	push   %eax
  8019a0:	ff 75 08             	pushl  0x8(%ebp)
  8019a3:	6a 01                	push   $0x1
  8019a5:	e8 66 ff ff ff       	call   801910 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	56                   	push   %esi
  8019b0:	53                   	push   %ebx
  8019b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019b4:	83 ec 0c             	sub    $0xc,%esp
  8019b7:	ff 75 08             	pushl  0x8(%ebp)
  8019ba:	e8 e2 f6 ff ff       	call   8010a1 <fd2data>
  8019bf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019c1:	83 c4 08             	add    $0x8,%esp
  8019c4:	68 bf 25 80 00       	push   $0x8025bf
  8019c9:	53                   	push   %ebx
  8019ca:	e8 ae f0 ff ff       	call   800a7d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019cf:	8b 46 04             	mov    0x4(%esi),%eax
  8019d2:	2b 06                	sub    (%esi),%eax
  8019d4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019da:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019e1:	00 00 00 
	stat->st_dev = &devpipe;
  8019e4:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019eb:	30 80 00 
	return 0;
}
  8019ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f6:	5b                   	pop    %ebx
  8019f7:	5e                   	pop    %esi
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    

008019fa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	53                   	push   %ebx
  8019fe:	83 ec 0c             	sub    $0xc,%esp
  801a01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a04:	53                   	push   %ebx
  801a05:	6a 00                	push   $0x0
  801a07:	e8 f9 f4 ff ff       	call   800f05 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a0c:	89 1c 24             	mov    %ebx,(%esp)
  801a0f:	e8 8d f6 ff ff       	call   8010a1 <fd2data>
  801a14:	83 c4 08             	add    $0x8,%esp
  801a17:	50                   	push   %eax
  801a18:	6a 00                	push   $0x0
  801a1a:	e8 e6 f4 ff ff       	call   800f05 <sys_page_unmap>
}
  801a1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a22:	c9                   	leave  
  801a23:	c3                   	ret    

00801a24 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	57                   	push   %edi
  801a28:	56                   	push   %esi
  801a29:	53                   	push   %ebx
  801a2a:	83 ec 1c             	sub    $0x1c,%esp
  801a2d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a30:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a32:	a1 04 44 80 00       	mov    0x804404,%eax
  801a37:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a3a:	83 ec 0c             	sub    $0xc,%esp
  801a3d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a40:	e8 da 03 00 00       	call   801e1f <pageref>
  801a45:	89 c3                	mov    %eax,%ebx
  801a47:	89 3c 24             	mov    %edi,(%esp)
  801a4a:	e8 d0 03 00 00       	call   801e1f <pageref>
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	39 c3                	cmp    %eax,%ebx
  801a54:	0f 94 c1             	sete   %cl
  801a57:	0f b6 c9             	movzbl %cl,%ecx
  801a5a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a5d:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801a63:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801a66:	39 ce                	cmp    %ecx,%esi
  801a68:	74 1b                	je     801a85 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a6a:	39 c3                	cmp    %eax,%ebx
  801a6c:	75 c4                	jne    801a32 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a6e:	8b 42 60             	mov    0x60(%edx),%eax
  801a71:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a74:	50                   	push   %eax
  801a75:	56                   	push   %esi
  801a76:	68 c6 25 80 00       	push   $0x8025c6
  801a7b:	e8 85 e9 ff ff       	call   800405 <cprintf>
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	eb ad                	jmp    801a32 <_pipeisclosed+0xe>
	}
}
  801a85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8b:	5b                   	pop    %ebx
  801a8c:	5e                   	pop    %esi
  801a8d:	5f                   	pop    %edi
  801a8e:	5d                   	pop    %ebp
  801a8f:	c3                   	ret    

00801a90 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	57                   	push   %edi
  801a94:	56                   	push   %esi
  801a95:	53                   	push   %ebx
  801a96:	83 ec 28             	sub    $0x28,%esp
  801a99:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a9c:	56                   	push   %esi
  801a9d:	e8 ff f5 ff ff       	call   8010a1 <fd2data>
  801aa2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	bf 00 00 00 00       	mov    $0x0,%edi
  801aac:	eb 4b                	jmp    801af9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aae:	89 da                	mov    %ebx,%edx
  801ab0:	89 f0                	mov    %esi,%eax
  801ab2:	e8 6d ff ff ff       	call   801a24 <_pipeisclosed>
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	75 48                	jne    801b03 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801abb:	e8 a1 f3 ff ff       	call   800e61 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac0:	8b 43 04             	mov    0x4(%ebx),%eax
  801ac3:	8b 0b                	mov    (%ebx),%ecx
  801ac5:	8d 51 20             	lea    0x20(%ecx),%edx
  801ac8:	39 d0                	cmp    %edx,%eax
  801aca:	73 e2                	jae    801aae <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801acc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801acf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ad3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ad6:	89 c2                	mov    %eax,%edx
  801ad8:	c1 fa 1f             	sar    $0x1f,%edx
  801adb:	89 d1                	mov    %edx,%ecx
  801add:	c1 e9 1b             	shr    $0x1b,%ecx
  801ae0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ae3:	83 e2 1f             	and    $0x1f,%edx
  801ae6:	29 ca                	sub    %ecx,%edx
  801ae8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801aec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801af0:	83 c0 01             	add    $0x1,%eax
  801af3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af6:	83 c7 01             	add    $0x1,%edi
  801af9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801afc:	75 c2                	jne    801ac0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801afe:	8b 45 10             	mov    0x10(%ebp),%eax
  801b01:	eb 05                	jmp    801b08 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b03:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0b:	5b                   	pop    %ebx
  801b0c:	5e                   	pop    %esi
  801b0d:	5f                   	pop    %edi
  801b0e:	5d                   	pop    %ebp
  801b0f:	c3                   	ret    

00801b10 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	57                   	push   %edi
  801b14:	56                   	push   %esi
  801b15:	53                   	push   %ebx
  801b16:	83 ec 18             	sub    $0x18,%esp
  801b19:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b1c:	57                   	push   %edi
  801b1d:	e8 7f f5 ff ff       	call   8010a1 <fd2data>
  801b22:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b24:	83 c4 10             	add    $0x10,%esp
  801b27:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b2c:	eb 3d                	jmp    801b6b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b2e:	85 db                	test   %ebx,%ebx
  801b30:	74 04                	je     801b36 <devpipe_read+0x26>
				return i;
  801b32:	89 d8                	mov    %ebx,%eax
  801b34:	eb 44                	jmp    801b7a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b36:	89 f2                	mov    %esi,%edx
  801b38:	89 f8                	mov    %edi,%eax
  801b3a:	e8 e5 fe ff ff       	call   801a24 <_pipeisclosed>
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	75 32                	jne    801b75 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b43:	e8 19 f3 ff ff       	call   800e61 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b48:	8b 06                	mov    (%esi),%eax
  801b4a:	3b 46 04             	cmp    0x4(%esi),%eax
  801b4d:	74 df                	je     801b2e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b4f:	99                   	cltd   
  801b50:	c1 ea 1b             	shr    $0x1b,%edx
  801b53:	01 d0                	add    %edx,%eax
  801b55:	83 e0 1f             	and    $0x1f,%eax
  801b58:	29 d0                	sub    %edx,%eax
  801b5a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b62:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b65:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b68:	83 c3 01             	add    $0x1,%ebx
  801b6b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b6e:	75 d8                	jne    801b48 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b70:	8b 45 10             	mov    0x10(%ebp),%eax
  801b73:	eb 05                	jmp    801b7a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7d:	5b                   	pop    %ebx
  801b7e:	5e                   	pop    %esi
  801b7f:	5f                   	pop    %edi
  801b80:	5d                   	pop    %ebp
  801b81:	c3                   	ret    

00801b82 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	56                   	push   %esi
  801b86:	53                   	push   %ebx
  801b87:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8d:	50                   	push   %eax
  801b8e:	e8 25 f5 ff ff       	call   8010b8 <fd_alloc>
  801b93:	83 c4 10             	add    $0x10,%esp
  801b96:	89 c2                	mov    %eax,%edx
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	0f 88 2c 01 00 00    	js     801ccc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba0:	83 ec 04             	sub    $0x4,%esp
  801ba3:	68 07 04 00 00       	push   $0x407
  801ba8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bab:	6a 00                	push   $0x0
  801bad:	e8 ce f2 ff ff       	call   800e80 <sys_page_alloc>
  801bb2:	83 c4 10             	add    $0x10,%esp
  801bb5:	89 c2                	mov    %eax,%edx
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	0f 88 0d 01 00 00    	js     801ccc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bbf:	83 ec 0c             	sub    $0xc,%esp
  801bc2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bc5:	50                   	push   %eax
  801bc6:	e8 ed f4 ff ff       	call   8010b8 <fd_alloc>
  801bcb:	89 c3                	mov    %eax,%ebx
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	0f 88 e2 00 00 00    	js     801cba <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd8:	83 ec 04             	sub    $0x4,%esp
  801bdb:	68 07 04 00 00       	push   $0x407
  801be0:	ff 75 f0             	pushl  -0x10(%ebp)
  801be3:	6a 00                	push   $0x0
  801be5:	e8 96 f2 ff ff       	call   800e80 <sys_page_alloc>
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	0f 88 c3 00 00 00    	js     801cba <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bf7:	83 ec 0c             	sub    $0xc,%esp
  801bfa:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfd:	e8 9f f4 ff ff       	call   8010a1 <fd2data>
  801c02:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c04:	83 c4 0c             	add    $0xc,%esp
  801c07:	68 07 04 00 00       	push   $0x407
  801c0c:	50                   	push   %eax
  801c0d:	6a 00                	push   $0x0
  801c0f:	e8 6c f2 ff ff       	call   800e80 <sys_page_alloc>
  801c14:	89 c3                	mov    %eax,%ebx
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	0f 88 89 00 00 00    	js     801caa <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c21:	83 ec 0c             	sub    $0xc,%esp
  801c24:	ff 75 f0             	pushl  -0x10(%ebp)
  801c27:	e8 75 f4 ff ff       	call   8010a1 <fd2data>
  801c2c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c33:	50                   	push   %eax
  801c34:	6a 00                	push   $0x0
  801c36:	56                   	push   %esi
  801c37:	6a 00                	push   $0x0
  801c39:	e8 85 f2 ff ff       	call   800ec3 <sys_page_map>
  801c3e:	89 c3                	mov    %eax,%ebx
  801c40:	83 c4 20             	add    $0x20,%esp
  801c43:	85 c0                	test   %eax,%eax
  801c45:	78 55                	js     801c9c <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c47:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c50:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c55:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c5c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c65:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c6a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c71:	83 ec 0c             	sub    $0xc,%esp
  801c74:	ff 75 f4             	pushl  -0xc(%ebp)
  801c77:	e8 15 f4 ff ff       	call   801091 <fd2num>
  801c7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c81:	83 c4 04             	add    $0x4,%esp
  801c84:	ff 75 f0             	pushl  -0x10(%ebp)
  801c87:	e8 05 f4 ff ff       	call   801091 <fd2num>
  801c8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8f:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	ba 00 00 00 00       	mov    $0x0,%edx
  801c9a:	eb 30                	jmp    801ccc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c9c:	83 ec 08             	sub    $0x8,%esp
  801c9f:	56                   	push   %esi
  801ca0:	6a 00                	push   $0x0
  801ca2:	e8 5e f2 ff ff       	call   800f05 <sys_page_unmap>
  801ca7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801caa:	83 ec 08             	sub    $0x8,%esp
  801cad:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb0:	6a 00                	push   $0x0
  801cb2:	e8 4e f2 ff ff       	call   800f05 <sys_page_unmap>
  801cb7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cba:	83 ec 08             	sub    $0x8,%esp
  801cbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc0:	6a 00                	push   $0x0
  801cc2:	e8 3e f2 ff ff       	call   800f05 <sys_page_unmap>
  801cc7:	83 c4 10             	add    $0x10,%esp
  801cca:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ccc:	89 d0                	mov    %edx,%eax
  801cce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cd1:	5b                   	pop    %ebx
  801cd2:	5e                   	pop    %esi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    

00801cd5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cde:	50                   	push   %eax
  801cdf:	ff 75 08             	pushl  0x8(%ebp)
  801ce2:	e8 20 f4 ff ff       	call   801107 <fd_lookup>
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	85 c0                	test   %eax,%eax
  801cec:	78 18                	js     801d06 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cee:	83 ec 0c             	sub    $0xc,%esp
  801cf1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf4:	e8 a8 f3 ff ff       	call   8010a1 <fd2data>
	return _pipeisclosed(fd, p);
  801cf9:	89 c2                	mov    %eax,%edx
  801cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfe:	e8 21 fd ff ff       	call   801a24 <_pipeisclosed>
  801d03:	83 c4 10             	add    $0x10,%esp
}
  801d06:	c9                   	leave  
  801d07:	c3                   	ret    

00801d08 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	56                   	push   %esi
  801d0c:	53                   	push   %ebx
  801d0d:	8b 75 08             	mov    0x8(%ebp),%esi
  801d10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801d16:	85 c0                	test   %eax,%eax
  801d18:	75 12                	jne    801d2c <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801d1a:	83 ec 0c             	sub    $0xc,%esp
  801d1d:	68 00 00 c0 ee       	push   $0xeec00000
  801d22:	e8 09 f3 ff ff       	call   801030 <sys_ipc_recv>
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	eb 0c                	jmp    801d38 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801d2c:	83 ec 0c             	sub    $0xc,%esp
  801d2f:	50                   	push   %eax
  801d30:	e8 fb f2 ff ff       	call   801030 <sys_ipc_recv>
  801d35:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801d38:	85 f6                	test   %esi,%esi
  801d3a:	0f 95 c1             	setne  %cl
  801d3d:	85 db                	test   %ebx,%ebx
  801d3f:	0f 95 c2             	setne  %dl
  801d42:	84 d1                	test   %dl,%cl
  801d44:	74 09                	je     801d4f <ipc_recv+0x47>
  801d46:	89 c2                	mov    %eax,%edx
  801d48:	c1 ea 1f             	shr    $0x1f,%edx
  801d4b:	84 d2                	test   %dl,%dl
  801d4d:	75 27                	jne    801d76 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801d4f:	85 f6                	test   %esi,%esi
  801d51:	74 0a                	je     801d5d <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801d53:	a1 04 44 80 00       	mov    0x804404,%eax
  801d58:	8b 40 7c             	mov    0x7c(%eax),%eax
  801d5b:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801d5d:	85 db                	test   %ebx,%ebx
  801d5f:	74 0d                	je     801d6e <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801d61:	a1 04 44 80 00       	mov    0x804404,%eax
  801d66:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801d6c:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801d6e:	a1 04 44 80 00       	mov    0x804404,%eax
  801d73:	8b 40 78             	mov    0x78(%eax),%eax
}
  801d76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d79:	5b                   	pop    %ebx
  801d7a:	5e                   	pop    %esi
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    

00801d7d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	57                   	push   %edi
  801d81:	56                   	push   %esi
  801d82:	53                   	push   %ebx
  801d83:	83 ec 0c             	sub    $0xc,%esp
  801d86:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d89:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801d8f:	85 db                	test   %ebx,%ebx
  801d91:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801d96:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801d99:	ff 75 14             	pushl  0x14(%ebp)
  801d9c:	53                   	push   %ebx
  801d9d:	56                   	push   %esi
  801d9e:	57                   	push   %edi
  801d9f:	e8 69 f2 ff ff       	call   80100d <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801da4:	89 c2                	mov    %eax,%edx
  801da6:	c1 ea 1f             	shr    $0x1f,%edx
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	84 d2                	test   %dl,%dl
  801dae:	74 17                	je     801dc7 <ipc_send+0x4a>
  801db0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801db3:	74 12                	je     801dc7 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801db5:	50                   	push   %eax
  801db6:	68 de 25 80 00       	push   $0x8025de
  801dbb:	6a 47                	push   $0x47
  801dbd:	68 ec 25 80 00       	push   $0x8025ec
  801dc2:	e8 65 e5 ff ff       	call   80032c <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801dc7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dca:	75 07                	jne    801dd3 <ipc_send+0x56>
			sys_yield();
  801dcc:	e8 90 f0 ff ff       	call   800e61 <sys_yield>
  801dd1:	eb c6                	jmp    801d99 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	75 c2                	jne    801d99 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801dd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dda:	5b                   	pop    %ebx
  801ddb:	5e                   	pop    %esi
  801ddc:	5f                   	pop    %edi
  801ddd:	5d                   	pop    %ebp
  801dde:	c3                   	ret    

00801ddf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801de5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801dea:	89 c2                	mov    %eax,%edx
  801dec:	c1 e2 07             	shl    $0x7,%edx
  801def:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801df6:	8b 52 58             	mov    0x58(%edx),%edx
  801df9:	39 ca                	cmp    %ecx,%edx
  801dfb:	75 11                	jne    801e0e <ipc_find_env+0x2f>
			return envs[i].env_id;
  801dfd:	89 c2                	mov    %eax,%edx
  801dff:	c1 e2 07             	shl    $0x7,%edx
  801e02:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801e09:	8b 40 50             	mov    0x50(%eax),%eax
  801e0c:	eb 0f                	jmp    801e1d <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e0e:	83 c0 01             	add    $0x1,%eax
  801e11:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e16:	75 d2                	jne    801dea <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e1d:	5d                   	pop    %ebp
  801e1e:	c3                   	ret    

00801e1f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e25:	89 d0                	mov    %edx,%eax
  801e27:	c1 e8 16             	shr    $0x16,%eax
  801e2a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e31:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e36:	f6 c1 01             	test   $0x1,%cl
  801e39:	74 1d                	je     801e58 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e3b:	c1 ea 0c             	shr    $0xc,%edx
  801e3e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e45:	f6 c2 01             	test   $0x1,%dl
  801e48:	74 0e                	je     801e58 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e4a:	c1 ea 0c             	shr    $0xc,%edx
  801e4d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e54:	ef 
  801e55:	0f b7 c0             	movzwl %ax,%eax
}
  801e58:	5d                   	pop    %ebp
  801e59:	c3                   	ret    
  801e5a:	66 90                	xchg   %ax,%ax
  801e5c:	66 90                	xchg   %ax,%ax
  801e5e:	66 90                	xchg   %ax,%ax

00801e60 <__udivdi3>:
  801e60:	55                   	push   %ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	53                   	push   %ebx
  801e64:	83 ec 1c             	sub    $0x1c,%esp
  801e67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e77:	85 f6                	test   %esi,%esi
  801e79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e7d:	89 ca                	mov    %ecx,%edx
  801e7f:	89 f8                	mov    %edi,%eax
  801e81:	75 3d                	jne    801ec0 <__udivdi3+0x60>
  801e83:	39 cf                	cmp    %ecx,%edi
  801e85:	0f 87 c5 00 00 00    	ja     801f50 <__udivdi3+0xf0>
  801e8b:	85 ff                	test   %edi,%edi
  801e8d:	89 fd                	mov    %edi,%ebp
  801e8f:	75 0b                	jne    801e9c <__udivdi3+0x3c>
  801e91:	b8 01 00 00 00       	mov    $0x1,%eax
  801e96:	31 d2                	xor    %edx,%edx
  801e98:	f7 f7                	div    %edi
  801e9a:	89 c5                	mov    %eax,%ebp
  801e9c:	89 c8                	mov    %ecx,%eax
  801e9e:	31 d2                	xor    %edx,%edx
  801ea0:	f7 f5                	div    %ebp
  801ea2:	89 c1                	mov    %eax,%ecx
  801ea4:	89 d8                	mov    %ebx,%eax
  801ea6:	89 cf                	mov    %ecx,%edi
  801ea8:	f7 f5                	div    %ebp
  801eaa:	89 c3                	mov    %eax,%ebx
  801eac:	89 d8                	mov    %ebx,%eax
  801eae:	89 fa                	mov    %edi,%edx
  801eb0:	83 c4 1c             	add    $0x1c,%esp
  801eb3:	5b                   	pop    %ebx
  801eb4:	5e                   	pop    %esi
  801eb5:	5f                   	pop    %edi
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    
  801eb8:	90                   	nop
  801eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ec0:	39 ce                	cmp    %ecx,%esi
  801ec2:	77 74                	ja     801f38 <__udivdi3+0xd8>
  801ec4:	0f bd fe             	bsr    %esi,%edi
  801ec7:	83 f7 1f             	xor    $0x1f,%edi
  801eca:	0f 84 98 00 00 00    	je     801f68 <__udivdi3+0x108>
  801ed0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ed5:	89 f9                	mov    %edi,%ecx
  801ed7:	89 c5                	mov    %eax,%ebp
  801ed9:	29 fb                	sub    %edi,%ebx
  801edb:	d3 e6                	shl    %cl,%esi
  801edd:	89 d9                	mov    %ebx,%ecx
  801edf:	d3 ed                	shr    %cl,%ebp
  801ee1:	89 f9                	mov    %edi,%ecx
  801ee3:	d3 e0                	shl    %cl,%eax
  801ee5:	09 ee                	or     %ebp,%esi
  801ee7:	89 d9                	mov    %ebx,%ecx
  801ee9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eed:	89 d5                	mov    %edx,%ebp
  801eef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ef3:	d3 ed                	shr    %cl,%ebp
  801ef5:	89 f9                	mov    %edi,%ecx
  801ef7:	d3 e2                	shl    %cl,%edx
  801ef9:	89 d9                	mov    %ebx,%ecx
  801efb:	d3 e8                	shr    %cl,%eax
  801efd:	09 c2                	or     %eax,%edx
  801eff:	89 d0                	mov    %edx,%eax
  801f01:	89 ea                	mov    %ebp,%edx
  801f03:	f7 f6                	div    %esi
  801f05:	89 d5                	mov    %edx,%ebp
  801f07:	89 c3                	mov    %eax,%ebx
  801f09:	f7 64 24 0c          	mull   0xc(%esp)
  801f0d:	39 d5                	cmp    %edx,%ebp
  801f0f:	72 10                	jb     801f21 <__udivdi3+0xc1>
  801f11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f15:	89 f9                	mov    %edi,%ecx
  801f17:	d3 e6                	shl    %cl,%esi
  801f19:	39 c6                	cmp    %eax,%esi
  801f1b:	73 07                	jae    801f24 <__udivdi3+0xc4>
  801f1d:	39 d5                	cmp    %edx,%ebp
  801f1f:	75 03                	jne    801f24 <__udivdi3+0xc4>
  801f21:	83 eb 01             	sub    $0x1,%ebx
  801f24:	31 ff                	xor    %edi,%edi
  801f26:	89 d8                	mov    %ebx,%eax
  801f28:	89 fa                	mov    %edi,%edx
  801f2a:	83 c4 1c             	add    $0x1c,%esp
  801f2d:	5b                   	pop    %ebx
  801f2e:	5e                   	pop    %esi
  801f2f:	5f                   	pop    %edi
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    
  801f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f38:	31 ff                	xor    %edi,%edi
  801f3a:	31 db                	xor    %ebx,%ebx
  801f3c:	89 d8                	mov    %ebx,%eax
  801f3e:	89 fa                	mov    %edi,%edx
  801f40:	83 c4 1c             	add    $0x1c,%esp
  801f43:	5b                   	pop    %ebx
  801f44:	5e                   	pop    %esi
  801f45:	5f                   	pop    %edi
  801f46:	5d                   	pop    %ebp
  801f47:	c3                   	ret    
  801f48:	90                   	nop
  801f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f50:	89 d8                	mov    %ebx,%eax
  801f52:	f7 f7                	div    %edi
  801f54:	31 ff                	xor    %edi,%edi
  801f56:	89 c3                	mov    %eax,%ebx
  801f58:	89 d8                	mov    %ebx,%eax
  801f5a:	89 fa                	mov    %edi,%edx
  801f5c:	83 c4 1c             	add    $0x1c,%esp
  801f5f:	5b                   	pop    %ebx
  801f60:	5e                   	pop    %esi
  801f61:	5f                   	pop    %edi
  801f62:	5d                   	pop    %ebp
  801f63:	c3                   	ret    
  801f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f68:	39 ce                	cmp    %ecx,%esi
  801f6a:	72 0c                	jb     801f78 <__udivdi3+0x118>
  801f6c:	31 db                	xor    %ebx,%ebx
  801f6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f72:	0f 87 34 ff ff ff    	ja     801eac <__udivdi3+0x4c>
  801f78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f7d:	e9 2a ff ff ff       	jmp    801eac <__udivdi3+0x4c>
  801f82:	66 90                	xchg   %ax,%ax
  801f84:	66 90                	xchg   %ax,%ax
  801f86:	66 90                	xchg   %ax,%ax
  801f88:	66 90                	xchg   %ax,%ax
  801f8a:	66 90                	xchg   %ax,%ax
  801f8c:	66 90                	xchg   %ax,%ax
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <__umoddi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 1c             	sub    $0x1c,%esp
  801f97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fa7:	85 d2                	test   %edx,%edx
  801fa9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801fad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fb1:	89 f3                	mov    %esi,%ebx
  801fb3:	89 3c 24             	mov    %edi,(%esp)
  801fb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fba:	75 1c                	jne    801fd8 <__umoddi3+0x48>
  801fbc:	39 f7                	cmp    %esi,%edi
  801fbe:	76 50                	jbe    802010 <__umoddi3+0x80>
  801fc0:	89 c8                	mov    %ecx,%eax
  801fc2:	89 f2                	mov    %esi,%edx
  801fc4:	f7 f7                	div    %edi
  801fc6:	89 d0                	mov    %edx,%eax
  801fc8:	31 d2                	xor    %edx,%edx
  801fca:	83 c4 1c             	add    $0x1c,%esp
  801fcd:	5b                   	pop    %ebx
  801fce:	5e                   	pop    %esi
  801fcf:	5f                   	pop    %edi
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    
  801fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fd8:	39 f2                	cmp    %esi,%edx
  801fda:	89 d0                	mov    %edx,%eax
  801fdc:	77 52                	ja     802030 <__umoddi3+0xa0>
  801fde:	0f bd ea             	bsr    %edx,%ebp
  801fe1:	83 f5 1f             	xor    $0x1f,%ebp
  801fe4:	75 5a                	jne    802040 <__umoddi3+0xb0>
  801fe6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801fea:	0f 82 e0 00 00 00    	jb     8020d0 <__umoddi3+0x140>
  801ff0:	39 0c 24             	cmp    %ecx,(%esp)
  801ff3:	0f 86 d7 00 00 00    	jbe    8020d0 <__umoddi3+0x140>
  801ff9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ffd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802001:	83 c4 1c             	add    $0x1c,%esp
  802004:	5b                   	pop    %ebx
  802005:	5e                   	pop    %esi
  802006:	5f                   	pop    %edi
  802007:	5d                   	pop    %ebp
  802008:	c3                   	ret    
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	85 ff                	test   %edi,%edi
  802012:	89 fd                	mov    %edi,%ebp
  802014:	75 0b                	jne    802021 <__umoddi3+0x91>
  802016:	b8 01 00 00 00       	mov    $0x1,%eax
  80201b:	31 d2                	xor    %edx,%edx
  80201d:	f7 f7                	div    %edi
  80201f:	89 c5                	mov    %eax,%ebp
  802021:	89 f0                	mov    %esi,%eax
  802023:	31 d2                	xor    %edx,%edx
  802025:	f7 f5                	div    %ebp
  802027:	89 c8                	mov    %ecx,%eax
  802029:	f7 f5                	div    %ebp
  80202b:	89 d0                	mov    %edx,%eax
  80202d:	eb 99                	jmp    801fc8 <__umoddi3+0x38>
  80202f:	90                   	nop
  802030:	89 c8                	mov    %ecx,%eax
  802032:	89 f2                	mov    %esi,%edx
  802034:	83 c4 1c             	add    $0x1c,%esp
  802037:	5b                   	pop    %ebx
  802038:	5e                   	pop    %esi
  802039:	5f                   	pop    %edi
  80203a:	5d                   	pop    %ebp
  80203b:	c3                   	ret    
  80203c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802040:	8b 34 24             	mov    (%esp),%esi
  802043:	bf 20 00 00 00       	mov    $0x20,%edi
  802048:	89 e9                	mov    %ebp,%ecx
  80204a:	29 ef                	sub    %ebp,%edi
  80204c:	d3 e0                	shl    %cl,%eax
  80204e:	89 f9                	mov    %edi,%ecx
  802050:	89 f2                	mov    %esi,%edx
  802052:	d3 ea                	shr    %cl,%edx
  802054:	89 e9                	mov    %ebp,%ecx
  802056:	09 c2                	or     %eax,%edx
  802058:	89 d8                	mov    %ebx,%eax
  80205a:	89 14 24             	mov    %edx,(%esp)
  80205d:	89 f2                	mov    %esi,%edx
  80205f:	d3 e2                	shl    %cl,%edx
  802061:	89 f9                	mov    %edi,%ecx
  802063:	89 54 24 04          	mov    %edx,0x4(%esp)
  802067:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	89 e9                	mov    %ebp,%ecx
  80206f:	89 c6                	mov    %eax,%esi
  802071:	d3 e3                	shl    %cl,%ebx
  802073:	89 f9                	mov    %edi,%ecx
  802075:	89 d0                	mov    %edx,%eax
  802077:	d3 e8                	shr    %cl,%eax
  802079:	89 e9                	mov    %ebp,%ecx
  80207b:	09 d8                	or     %ebx,%eax
  80207d:	89 d3                	mov    %edx,%ebx
  80207f:	89 f2                	mov    %esi,%edx
  802081:	f7 34 24             	divl   (%esp)
  802084:	89 d6                	mov    %edx,%esi
  802086:	d3 e3                	shl    %cl,%ebx
  802088:	f7 64 24 04          	mull   0x4(%esp)
  80208c:	39 d6                	cmp    %edx,%esi
  80208e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802092:	89 d1                	mov    %edx,%ecx
  802094:	89 c3                	mov    %eax,%ebx
  802096:	72 08                	jb     8020a0 <__umoddi3+0x110>
  802098:	75 11                	jne    8020ab <__umoddi3+0x11b>
  80209a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80209e:	73 0b                	jae    8020ab <__umoddi3+0x11b>
  8020a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020a4:	1b 14 24             	sbb    (%esp),%edx
  8020a7:	89 d1                	mov    %edx,%ecx
  8020a9:	89 c3                	mov    %eax,%ebx
  8020ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020af:	29 da                	sub    %ebx,%edx
  8020b1:	19 ce                	sbb    %ecx,%esi
  8020b3:	89 f9                	mov    %edi,%ecx
  8020b5:	89 f0                	mov    %esi,%eax
  8020b7:	d3 e0                	shl    %cl,%eax
  8020b9:	89 e9                	mov    %ebp,%ecx
  8020bb:	d3 ea                	shr    %cl,%edx
  8020bd:	89 e9                	mov    %ebp,%ecx
  8020bf:	d3 ee                	shr    %cl,%esi
  8020c1:	09 d0                	or     %edx,%eax
  8020c3:	89 f2                	mov    %esi,%edx
  8020c5:	83 c4 1c             	add    $0x1c,%esp
  8020c8:	5b                   	pop    %ebx
  8020c9:	5e                   	pop    %esi
  8020ca:	5f                   	pop    %edi
  8020cb:	5d                   	pop    %ebp
  8020cc:	c3                   	ret    
  8020cd:	8d 76 00             	lea    0x0(%esi),%esi
  8020d0:	29 f9                	sub    %edi,%ecx
  8020d2:	19 d6                	sbb    %edx,%esi
  8020d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020dc:	e9 18 ff ff ff       	jmp    801ff9 <__umoddi3+0x69>
