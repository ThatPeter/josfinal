
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
  80003f:	e8 e1 0d 00 00       	call   800e25 <sys_yield>
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
  80004e:	e8 b4 14 00 00       	call   801507 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 60 24 80 00       	push   $0x802460
  800065:	6a 0f                	push   $0xf
  800067:	68 6d 24 80 00       	push   $0x80246d
  80006c:	e8 7f 02 00 00       	call   8002f0 <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 7c 24 80 00       	push   $0x80247c
  80007b:	6a 11                	push   $0x11
  80007d:	68 6d 24 80 00       	push   $0x80246d
  800082:	e8 69 02 00 00       	call   8002f0 <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 c4 14 00 00       	call   801557 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 96 24 80 00       	push   $0x802496
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 6d 24 80 00       	push   $0x80246d
  8000a7:	e8 44 02 00 00       	call   8002f0 <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 9e 24 80 00       	push   $0x80249e
  8000b4:	e8 5c 08 00 00       	call   800915 <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 ac 24 80 00       	push   $0x8024ac
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 85 1b 00 00       	call   801c55 <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 b0 24 80 00       	push   $0x8024b0
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 71 1b 00 00       	call   801c55 <fprintf>
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
  8000f9:	68 c8 24 80 00       	push   $0x8024c8
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	e8 3b 09 00 00       	call   800a41 <strcpy>
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
  80013f:	e8 8f 0a 00 00       	call   800bd3 <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 3a 0c 00 00       	call   800d88 <sys_cputs>
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
  800175:	e8 ab 0c 00 00       	call   800e25 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80017a:	e8 27 0c 00 00       	call   800da6 <sys_cgetc>
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
  8001b1:	e8 d2 0b 00 00       	call   800d88 <sys_cputs>
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
  8001c9:	e8 75 14 00 00       	call   801643 <read>
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
  8001f3:	e8 e5 11 00 00       	call   8013dd <fd_lookup>
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
  80021c:	e8 6d 11 00 00       	call   80138e <fd_alloc>
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
  800237:	e8 08 0c 00 00       	call   800e44 <sys_page_alloc>
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
  80025e:	e8 04 11 00 00       	call   801367 <fd2num>
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
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800274:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800277:	e8 8a 0b 00 00       	call   800e06 <sys_getenvid>
  80027c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800281:	89 c2                	mov    %eax,%edx
  800283:	c1 e2 07             	shl    $0x7,%edx
  800286:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80028d:	a3 04 44 80 00       	mov    %eax,0x804404
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800292:	85 db                	test   %ebx,%ebx
  800294:	7e 07                	jle    80029d <libmain+0x31>
		binaryname = argv[0];
  800296:	8b 06                	mov    (%esi),%eax
  800298:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  80029d:	83 ec 08             	sub    $0x8,%esp
  8002a0:	56                   	push   %esi
  8002a1:	53                   	push   %ebx
  8002a2:	e8 8c fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002a7:	e8 2a 00 00 00       	call   8002d6 <exit>
}
  8002ac:	83 c4 10             	add    $0x10,%esp
  8002af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002b2:	5b                   	pop    %ebx
  8002b3:	5e                   	pop    %esi
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8002bc:	a1 08 44 80 00       	mov    0x804408,%eax
	func();
  8002c1:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8002c3:	e8 3e 0b 00 00       	call   800e06 <sys_getenvid>
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	e8 84 0d 00 00       	call   801055 <sys_thread_free>
}
  8002d1:	83 c4 10             	add    $0x10,%esp
  8002d4:	c9                   	leave  
  8002d5:	c3                   	ret    

008002d6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002dc:	e8 51 12 00 00       	call   801532 <close_all>
	sys_env_destroy(0);
  8002e1:	83 ec 0c             	sub    $0xc,%esp
  8002e4:	6a 00                	push   $0x0
  8002e6:	e8 da 0a 00 00       	call   800dc5 <sys_env_destroy>
}
  8002eb:	83 c4 10             	add    $0x10,%esp
  8002ee:	c9                   	leave  
  8002ef:	c3                   	ret    

008002f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	56                   	push   %esi
  8002f4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002f5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002f8:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002fe:	e8 03 0b 00 00       	call   800e06 <sys_getenvid>
  800303:	83 ec 0c             	sub    $0xc,%esp
  800306:	ff 75 0c             	pushl  0xc(%ebp)
  800309:	ff 75 08             	pushl  0x8(%ebp)
  80030c:	56                   	push   %esi
  80030d:	50                   	push   %eax
  80030e:	68 e0 24 80 00       	push   $0x8024e0
  800313:	e8 b1 00 00 00       	call   8003c9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800318:	83 c4 18             	add    $0x18,%esp
  80031b:	53                   	push   %ebx
  80031c:	ff 75 10             	pushl  0x10(%ebp)
  80031f:	e8 54 00 00 00       	call   800378 <vcprintf>
	cprintf("\n");
  800324:	c7 04 24 c6 24 80 00 	movl   $0x8024c6,(%esp)
  80032b:	e8 99 00 00 00       	call   8003c9 <cprintf>
  800330:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800333:	cc                   	int3   
  800334:	eb fd                	jmp    800333 <_panic+0x43>

00800336 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	53                   	push   %ebx
  80033a:	83 ec 04             	sub    $0x4,%esp
  80033d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800340:	8b 13                	mov    (%ebx),%edx
  800342:	8d 42 01             	lea    0x1(%edx),%eax
  800345:	89 03                	mov    %eax,(%ebx)
  800347:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80034a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80034e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800353:	75 1a                	jne    80036f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800355:	83 ec 08             	sub    $0x8,%esp
  800358:	68 ff 00 00 00       	push   $0xff
  80035d:	8d 43 08             	lea    0x8(%ebx),%eax
  800360:	50                   	push   %eax
  800361:	e8 22 0a 00 00       	call   800d88 <sys_cputs>
		b->idx = 0;
  800366:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80036c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80036f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800373:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800376:	c9                   	leave  
  800377:	c3                   	ret    

00800378 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800381:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800388:	00 00 00 
	b.cnt = 0;
  80038b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800392:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800395:	ff 75 0c             	pushl  0xc(%ebp)
  800398:	ff 75 08             	pushl  0x8(%ebp)
  80039b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003a1:	50                   	push   %eax
  8003a2:	68 36 03 80 00       	push   $0x800336
  8003a7:	e8 54 01 00 00       	call   800500 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ac:	83 c4 08             	add    $0x8,%esp
  8003af:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003b5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003bb:	50                   	push   %eax
  8003bc:	e8 c7 09 00 00       	call   800d88 <sys_cputs>

	return b.cnt;
}
  8003c1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003c7:	c9                   	leave  
  8003c8:	c3                   	ret    

008003c9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
  8003cc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003cf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003d2:	50                   	push   %eax
  8003d3:	ff 75 08             	pushl  0x8(%ebp)
  8003d6:	e8 9d ff ff ff       	call   800378 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003db:	c9                   	leave  
  8003dc:	c3                   	ret    

008003dd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
  8003e0:	57                   	push   %edi
  8003e1:	56                   	push   %esi
  8003e2:	53                   	push   %ebx
  8003e3:	83 ec 1c             	sub    $0x1c,%esp
  8003e6:	89 c7                	mov    %eax,%edi
  8003e8:	89 d6                	mov    %edx,%esi
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003fe:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800401:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800404:	39 d3                	cmp    %edx,%ebx
  800406:	72 05                	jb     80040d <printnum+0x30>
  800408:	39 45 10             	cmp    %eax,0x10(%ebp)
  80040b:	77 45                	ja     800452 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80040d:	83 ec 0c             	sub    $0xc,%esp
  800410:	ff 75 18             	pushl  0x18(%ebp)
  800413:	8b 45 14             	mov    0x14(%ebp),%eax
  800416:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800419:	53                   	push   %ebx
  80041a:	ff 75 10             	pushl  0x10(%ebp)
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	ff 75 e4             	pushl  -0x1c(%ebp)
  800423:	ff 75 e0             	pushl  -0x20(%ebp)
  800426:	ff 75 dc             	pushl  -0x24(%ebp)
  800429:	ff 75 d8             	pushl  -0x28(%ebp)
  80042c:	e8 9f 1d 00 00       	call   8021d0 <__udivdi3>
  800431:	83 c4 18             	add    $0x18,%esp
  800434:	52                   	push   %edx
  800435:	50                   	push   %eax
  800436:	89 f2                	mov    %esi,%edx
  800438:	89 f8                	mov    %edi,%eax
  80043a:	e8 9e ff ff ff       	call   8003dd <printnum>
  80043f:	83 c4 20             	add    $0x20,%esp
  800442:	eb 18                	jmp    80045c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	56                   	push   %esi
  800448:	ff 75 18             	pushl  0x18(%ebp)
  80044b:	ff d7                	call   *%edi
  80044d:	83 c4 10             	add    $0x10,%esp
  800450:	eb 03                	jmp    800455 <printnum+0x78>
  800452:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800455:	83 eb 01             	sub    $0x1,%ebx
  800458:	85 db                	test   %ebx,%ebx
  80045a:	7f e8                	jg     800444 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80045c:	83 ec 08             	sub    $0x8,%esp
  80045f:	56                   	push   %esi
  800460:	83 ec 04             	sub    $0x4,%esp
  800463:	ff 75 e4             	pushl  -0x1c(%ebp)
  800466:	ff 75 e0             	pushl  -0x20(%ebp)
  800469:	ff 75 dc             	pushl  -0x24(%ebp)
  80046c:	ff 75 d8             	pushl  -0x28(%ebp)
  80046f:	e8 8c 1e 00 00       	call   802300 <__umoddi3>
  800474:	83 c4 14             	add    $0x14,%esp
  800477:	0f be 80 03 25 80 00 	movsbl 0x802503(%eax),%eax
  80047e:	50                   	push   %eax
  80047f:	ff d7                	call   *%edi
}
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800487:	5b                   	pop    %ebx
  800488:	5e                   	pop    %esi
  800489:	5f                   	pop    %edi
  80048a:	5d                   	pop    %ebp
  80048b:	c3                   	ret    

0080048c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80048c:	55                   	push   %ebp
  80048d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80048f:	83 fa 01             	cmp    $0x1,%edx
  800492:	7e 0e                	jle    8004a2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800494:	8b 10                	mov    (%eax),%edx
  800496:	8d 4a 08             	lea    0x8(%edx),%ecx
  800499:	89 08                	mov    %ecx,(%eax)
  80049b:	8b 02                	mov    (%edx),%eax
  80049d:	8b 52 04             	mov    0x4(%edx),%edx
  8004a0:	eb 22                	jmp    8004c4 <getuint+0x38>
	else if (lflag)
  8004a2:	85 d2                	test   %edx,%edx
  8004a4:	74 10                	je     8004b6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004a6:	8b 10                	mov    (%eax),%edx
  8004a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ab:	89 08                	mov    %ecx,(%eax)
  8004ad:	8b 02                	mov    (%edx),%eax
  8004af:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b4:	eb 0e                	jmp    8004c4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004b6:	8b 10                	mov    (%eax),%edx
  8004b8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004bb:	89 08                	mov    %ecx,(%eax)
  8004bd:	8b 02                	mov    (%edx),%eax
  8004bf:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004c4:	5d                   	pop    %ebp
  8004c5:	c3                   	ret    

008004c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
  8004c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004cc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004d0:	8b 10                	mov    (%eax),%edx
  8004d2:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d5:	73 0a                	jae    8004e1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004d7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004da:	89 08                	mov    %ecx,(%eax)
  8004dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8004df:	88 02                	mov    %al,(%edx)
}
  8004e1:	5d                   	pop    %ebp
  8004e2:	c3                   	ret    

008004e3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004ec:	50                   	push   %eax
  8004ed:	ff 75 10             	pushl  0x10(%ebp)
  8004f0:	ff 75 0c             	pushl  0xc(%ebp)
  8004f3:	ff 75 08             	pushl  0x8(%ebp)
  8004f6:	e8 05 00 00 00       	call   800500 <vprintfmt>
	va_end(ap);
}
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	c9                   	leave  
  8004ff:	c3                   	ret    

00800500 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	57                   	push   %edi
  800504:	56                   	push   %esi
  800505:	53                   	push   %ebx
  800506:	83 ec 2c             	sub    $0x2c,%esp
  800509:	8b 75 08             	mov    0x8(%ebp),%esi
  80050c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800512:	eb 12                	jmp    800526 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800514:	85 c0                	test   %eax,%eax
  800516:	0f 84 89 03 00 00    	je     8008a5 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	53                   	push   %ebx
  800520:	50                   	push   %eax
  800521:	ff d6                	call   *%esi
  800523:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800526:	83 c7 01             	add    $0x1,%edi
  800529:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052d:	83 f8 25             	cmp    $0x25,%eax
  800530:	75 e2                	jne    800514 <vprintfmt+0x14>
  800532:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800536:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80053d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800544:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80054b:	ba 00 00 00 00       	mov    $0x0,%edx
  800550:	eb 07                	jmp    800559 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800555:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800559:	8d 47 01             	lea    0x1(%edi),%eax
  80055c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80055f:	0f b6 07             	movzbl (%edi),%eax
  800562:	0f b6 c8             	movzbl %al,%ecx
  800565:	83 e8 23             	sub    $0x23,%eax
  800568:	3c 55                	cmp    $0x55,%al
  80056a:	0f 87 1a 03 00 00    	ja     80088a <vprintfmt+0x38a>
  800570:	0f b6 c0             	movzbl %al,%eax
  800573:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  80057a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80057d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800581:	eb d6                	jmp    800559 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800583:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800586:	b8 00 00 00 00       	mov    $0x0,%eax
  80058b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80058e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800591:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800595:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800598:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80059b:	83 fa 09             	cmp    $0x9,%edx
  80059e:	77 39                	ja     8005d9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005a3:	eb e9                	jmp    80058e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 48 04             	lea    0x4(%eax),%ecx
  8005ab:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005ae:	8b 00                	mov    (%eax),%eax
  8005b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b6:	eb 27                	jmp    8005df <vprintfmt+0xdf>
  8005b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005bb:	85 c0                	test   %eax,%eax
  8005bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c2:	0f 49 c8             	cmovns %eax,%ecx
  8005c5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cb:	eb 8c                	jmp    800559 <vprintfmt+0x59>
  8005cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005d7:	eb 80                	jmp    800559 <vprintfmt+0x59>
  8005d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005dc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e3:	0f 89 70 ff ff ff    	jns    800559 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005e9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ef:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005f6:	e9 5e ff ff ff       	jmp    800559 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005fb:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800601:	e9 53 ff ff ff       	jmp    800559 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	ff 30                	pushl  (%eax)
  800615:	ff d6                	call   *%esi
			break;
  800617:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80061d:	e9 04 ff ff ff       	jmp    800526 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)
  80062b:	8b 00                	mov    (%eax),%eax
  80062d:	99                   	cltd   
  80062e:	31 d0                	xor    %edx,%eax
  800630:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800632:	83 f8 0f             	cmp    $0xf,%eax
  800635:	7f 0b                	jg     800642 <vprintfmt+0x142>
  800637:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  80063e:	85 d2                	test   %edx,%edx
  800640:	75 18                	jne    80065a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800642:	50                   	push   %eax
  800643:	68 1b 25 80 00       	push   $0x80251b
  800648:	53                   	push   %ebx
  800649:	56                   	push   %esi
  80064a:	e8 94 fe ff ff       	call   8004e3 <printfmt>
  80064f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800655:	e9 cc fe ff ff       	jmp    800526 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80065a:	52                   	push   %edx
  80065b:	68 61 29 80 00       	push   $0x802961
  800660:	53                   	push   %ebx
  800661:	56                   	push   %esi
  800662:	e8 7c fe ff ff       	call   8004e3 <printfmt>
  800667:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066d:	e9 b4 fe ff ff       	jmp    800526 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8d 50 04             	lea    0x4(%eax),%edx
  800678:	89 55 14             	mov    %edx,0x14(%ebp)
  80067b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80067d:	85 ff                	test   %edi,%edi
  80067f:	b8 14 25 80 00       	mov    $0x802514,%eax
  800684:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800687:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80068b:	0f 8e 94 00 00 00    	jle    800725 <vprintfmt+0x225>
  800691:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800695:	0f 84 98 00 00 00    	je     800733 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	ff 75 d0             	pushl  -0x30(%ebp)
  8006a1:	57                   	push   %edi
  8006a2:	e8 79 03 00 00       	call   800a20 <strnlen>
  8006a7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006aa:	29 c1                	sub    %eax,%ecx
  8006ac:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006af:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006b2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006bc:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006be:	eb 0f                	jmp    8006cf <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c9:	83 ef 01             	sub    $0x1,%edi
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	85 ff                	test   %edi,%edi
  8006d1:	7f ed                	jg     8006c0 <vprintfmt+0x1c0>
  8006d3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006d6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006d9:	85 c9                	test   %ecx,%ecx
  8006db:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e0:	0f 49 c1             	cmovns %ecx,%eax
  8006e3:	29 c1                	sub    %eax,%ecx
  8006e5:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ee:	89 cb                	mov    %ecx,%ebx
  8006f0:	eb 4d                	jmp    80073f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006f2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f6:	74 1b                	je     800713 <vprintfmt+0x213>
  8006f8:	0f be c0             	movsbl %al,%eax
  8006fb:	83 e8 20             	sub    $0x20,%eax
  8006fe:	83 f8 5e             	cmp    $0x5e,%eax
  800701:	76 10                	jbe    800713 <vprintfmt+0x213>
					putch('?', putdat);
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	ff 75 0c             	pushl  0xc(%ebp)
  800709:	6a 3f                	push   $0x3f
  80070b:	ff 55 08             	call   *0x8(%ebp)
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	eb 0d                	jmp    800720 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	ff 75 0c             	pushl  0xc(%ebp)
  800719:	52                   	push   %edx
  80071a:	ff 55 08             	call   *0x8(%ebp)
  80071d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800720:	83 eb 01             	sub    $0x1,%ebx
  800723:	eb 1a                	jmp    80073f <vprintfmt+0x23f>
  800725:	89 75 08             	mov    %esi,0x8(%ebp)
  800728:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80072b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80072e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800731:	eb 0c                	jmp    80073f <vprintfmt+0x23f>
  800733:	89 75 08             	mov    %esi,0x8(%ebp)
  800736:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800739:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80073f:	83 c7 01             	add    $0x1,%edi
  800742:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800746:	0f be d0             	movsbl %al,%edx
  800749:	85 d2                	test   %edx,%edx
  80074b:	74 23                	je     800770 <vprintfmt+0x270>
  80074d:	85 f6                	test   %esi,%esi
  80074f:	78 a1                	js     8006f2 <vprintfmt+0x1f2>
  800751:	83 ee 01             	sub    $0x1,%esi
  800754:	79 9c                	jns    8006f2 <vprintfmt+0x1f2>
  800756:	89 df                	mov    %ebx,%edi
  800758:	8b 75 08             	mov    0x8(%ebp),%esi
  80075b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80075e:	eb 18                	jmp    800778 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800760:	83 ec 08             	sub    $0x8,%esp
  800763:	53                   	push   %ebx
  800764:	6a 20                	push   $0x20
  800766:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800768:	83 ef 01             	sub    $0x1,%edi
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	eb 08                	jmp    800778 <vprintfmt+0x278>
  800770:	89 df                	mov    %ebx,%edi
  800772:	8b 75 08             	mov    0x8(%ebp),%esi
  800775:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800778:	85 ff                	test   %edi,%edi
  80077a:	7f e4                	jg     800760 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077f:	e9 a2 fd ff ff       	jmp    800526 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800784:	83 fa 01             	cmp    $0x1,%edx
  800787:	7e 16                	jle    80079f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8d 50 08             	lea    0x8(%eax),%edx
  80078f:	89 55 14             	mov    %edx,0x14(%ebp)
  800792:	8b 50 04             	mov    0x4(%eax),%edx
  800795:	8b 00                	mov    (%eax),%eax
  800797:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80079d:	eb 32                	jmp    8007d1 <vprintfmt+0x2d1>
	else if (lflag)
  80079f:	85 d2                	test   %edx,%edx
  8007a1:	74 18                	je     8007bb <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8d 50 04             	lea    0x4(%eax),%edx
  8007a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ac:	8b 00                	mov    (%eax),%eax
  8007ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b1:	89 c1                	mov    %eax,%ecx
  8007b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b9:	eb 16                	jmp    8007d1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8d 50 04             	lea    0x4(%eax),%edx
  8007c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c4:	8b 00                	mov    (%eax),%eax
  8007c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c9:	89 c1                	mov    %eax,%ecx
  8007cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007d7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007dc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007e0:	79 74                	jns    800856 <vprintfmt+0x356>
				putch('-', putdat);
  8007e2:	83 ec 08             	sub    $0x8,%esp
  8007e5:	53                   	push   %ebx
  8007e6:	6a 2d                	push   $0x2d
  8007e8:	ff d6                	call   *%esi
				num = -(long long) num;
  8007ea:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007f0:	f7 d8                	neg    %eax
  8007f2:	83 d2 00             	adc    $0x0,%edx
  8007f5:	f7 da                	neg    %edx
  8007f7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007fa:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007ff:	eb 55                	jmp    800856 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800801:	8d 45 14             	lea    0x14(%ebp),%eax
  800804:	e8 83 fc ff ff       	call   80048c <getuint>
			base = 10;
  800809:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80080e:	eb 46                	jmp    800856 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800810:	8d 45 14             	lea    0x14(%ebp),%eax
  800813:	e8 74 fc ff ff       	call   80048c <getuint>
			base = 8;
  800818:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80081d:	eb 37                	jmp    800856 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	53                   	push   %ebx
  800823:	6a 30                	push   $0x30
  800825:	ff d6                	call   *%esi
			putch('x', putdat);
  800827:	83 c4 08             	add    $0x8,%esp
  80082a:	53                   	push   %ebx
  80082b:	6a 78                	push   $0x78
  80082d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80082f:	8b 45 14             	mov    0x14(%ebp),%eax
  800832:	8d 50 04             	lea    0x4(%eax),%edx
  800835:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800838:	8b 00                	mov    (%eax),%eax
  80083a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80083f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800842:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800847:	eb 0d                	jmp    800856 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800849:	8d 45 14             	lea    0x14(%ebp),%eax
  80084c:	e8 3b fc ff ff       	call   80048c <getuint>
			base = 16;
  800851:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800856:	83 ec 0c             	sub    $0xc,%esp
  800859:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80085d:	57                   	push   %edi
  80085e:	ff 75 e0             	pushl  -0x20(%ebp)
  800861:	51                   	push   %ecx
  800862:	52                   	push   %edx
  800863:	50                   	push   %eax
  800864:	89 da                	mov    %ebx,%edx
  800866:	89 f0                	mov    %esi,%eax
  800868:	e8 70 fb ff ff       	call   8003dd <printnum>
			break;
  80086d:	83 c4 20             	add    $0x20,%esp
  800870:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800873:	e9 ae fc ff ff       	jmp    800526 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800878:	83 ec 08             	sub    $0x8,%esp
  80087b:	53                   	push   %ebx
  80087c:	51                   	push   %ecx
  80087d:	ff d6                	call   *%esi
			break;
  80087f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800882:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800885:	e9 9c fc ff ff       	jmp    800526 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80088a:	83 ec 08             	sub    $0x8,%esp
  80088d:	53                   	push   %ebx
  80088e:	6a 25                	push   $0x25
  800890:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	eb 03                	jmp    80089a <vprintfmt+0x39a>
  800897:	83 ef 01             	sub    $0x1,%edi
  80089a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80089e:	75 f7                	jne    800897 <vprintfmt+0x397>
  8008a0:	e9 81 fc ff ff       	jmp    800526 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a8:	5b                   	pop    %ebx
  8008a9:	5e                   	pop    %esi
  8008aa:	5f                   	pop    %edi
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	83 ec 18             	sub    $0x18,%esp
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ca:	85 c0                	test   %eax,%eax
  8008cc:	74 26                	je     8008f4 <vsnprintf+0x47>
  8008ce:	85 d2                	test   %edx,%edx
  8008d0:	7e 22                	jle    8008f4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d2:	ff 75 14             	pushl  0x14(%ebp)
  8008d5:	ff 75 10             	pushl  0x10(%ebp)
  8008d8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008db:	50                   	push   %eax
  8008dc:	68 c6 04 80 00       	push   $0x8004c6
  8008e1:	e8 1a fc ff ff       	call   800500 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ef:	83 c4 10             	add    $0x10,%esp
  8008f2:	eb 05                	jmp    8008f9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008f9:	c9                   	leave  
  8008fa:	c3                   	ret    

008008fb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800901:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800904:	50                   	push   %eax
  800905:	ff 75 10             	pushl  0x10(%ebp)
  800908:	ff 75 0c             	pushl  0xc(%ebp)
  80090b:	ff 75 08             	pushl  0x8(%ebp)
  80090e:	e8 9a ff ff ff       	call   8008ad <vsnprintf>
	va_end(ap);

	return rc;
}
  800913:	c9                   	leave  
  800914:	c3                   	ret    

00800915 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	83 ec 0c             	sub    $0xc,%esp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800921:	85 c0                	test   %eax,%eax
  800923:	74 13                	je     800938 <readline+0x23>
		fprintf(1, "%s", prompt);
  800925:	83 ec 04             	sub    $0x4,%esp
  800928:	50                   	push   %eax
  800929:	68 61 29 80 00       	push   $0x802961
  80092e:	6a 01                	push   $0x1
  800930:	e8 20 13 00 00       	call   801c55 <fprintf>
  800935:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  800938:	83 ec 0c             	sub    $0xc,%esp
  80093b:	6a 00                	push   $0x0
  80093d:	e8 a4 f8 ff ff       	call   8001e6 <iscons>
  800942:	89 c7                	mov    %eax,%edi
  800944:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  800947:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  80094c:	e8 6a f8 ff ff       	call   8001bb <getchar>
  800951:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800953:	85 c0                	test   %eax,%eax
  800955:	79 29                	jns    800980 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800957:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  80095c:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80095f:	0f 84 9b 00 00 00    	je     800a00 <readline+0xeb>
				cprintf("read error: %e\n", c);
  800965:	83 ec 08             	sub    $0x8,%esp
  800968:	53                   	push   %ebx
  800969:	68 ff 27 80 00       	push   $0x8027ff
  80096e:	e8 56 fa ff ff       	call   8003c9 <cprintf>
  800973:	83 c4 10             	add    $0x10,%esp
			return NULL;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
  80097b:	e9 80 00 00 00       	jmp    800a00 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800980:	83 f8 08             	cmp    $0x8,%eax
  800983:	0f 94 c2             	sete   %dl
  800986:	83 f8 7f             	cmp    $0x7f,%eax
  800989:	0f 94 c0             	sete   %al
  80098c:	08 c2                	or     %al,%dl
  80098e:	74 1a                	je     8009aa <readline+0x95>
  800990:	85 f6                	test   %esi,%esi
  800992:	7e 16                	jle    8009aa <readline+0x95>
			if (echoing)
  800994:	85 ff                	test   %edi,%edi
  800996:	74 0d                	je     8009a5 <readline+0x90>
				cputchar('\b');
  800998:	83 ec 0c             	sub    $0xc,%esp
  80099b:	6a 08                	push   $0x8
  80099d:	e8 fd f7 ff ff       	call   80019f <cputchar>
  8009a2:	83 c4 10             	add    $0x10,%esp
			i--;
  8009a5:	83 ee 01             	sub    $0x1,%esi
  8009a8:	eb a2                	jmp    80094c <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8009aa:	83 fb 1f             	cmp    $0x1f,%ebx
  8009ad:	7e 26                	jle    8009d5 <readline+0xc0>
  8009af:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8009b5:	7f 1e                	jg     8009d5 <readline+0xc0>
			if (echoing)
  8009b7:	85 ff                	test   %edi,%edi
  8009b9:	74 0c                	je     8009c7 <readline+0xb2>
				cputchar(c);
  8009bb:	83 ec 0c             	sub    $0xc,%esp
  8009be:	53                   	push   %ebx
  8009bf:	e8 db f7 ff ff       	call   80019f <cputchar>
  8009c4:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8009c7:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  8009cd:	8d 76 01             	lea    0x1(%esi),%esi
  8009d0:	e9 77 ff ff ff       	jmp    80094c <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8009d5:	83 fb 0a             	cmp    $0xa,%ebx
  8009d8:	74 09                	je     8009e3 <readline+0xce>
  8009da:	83 fb 0d             	cmp    $0xd,%ebx
  8009dd:	0f 85 69 ff ff ff    	jne    80094c <readline+0x37>
			if (echoing)
  8009e3:	85 ff                	test   %edi,%edi
  8009e5:	74 0d                	je     8009f4 <readline+0xdf>
				cputchar('\n');
  8009e7:	83 ec 0c             	sub    $0xc,%esp
  8009ea:	6a 0a                	push   $0xa
  8009ec:	e8 ae f7 ff ff       	call   80019f <cputchar>
  8009f1:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  8009f4:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  8009fb:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  800a00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5f                   	pop    %edi
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a13:	eb 03                	jmp    800a18 <strlen+0x10>
		n++;
  800a15:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a18:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a1c:	75 f7                	jne    800a15 <strlen+0xd>
		n++;
	return n;
}
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a26:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a29:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2e:	eb 03                	jmp    800a33 <strnlen+0x13>
		n++;
  800a30:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a33:	39 c2                	cmp    %eax,%edx
  800a35:	74 08                	je     800a3f <strnlen+0x1f>
  800a37:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a3b:	75 f3                	jne    800a30 <strnlen+0x10>
  800a3d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	53                   	push   %ebx
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a4b:	89 c2                	mov    %eax,%edx
  800a4d:	83 c2 01             	add    $0x1,%edx
  800a50:	83 c1 01             	add    $0x1,%ecx
  800a53:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a57:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a5a:	84 db                	test   %bl,%bl
  800a5c:	75 ef                	jne    800a4d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a5e:	5b                   	pop    %ebx
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	53                   	push   %ebx
  800a65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a68:	53                   	push   %ebx
  800a69:	e8 9a ff ff ff       	call   800a08 <strlen>
  800a6e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a71:	ff 75 0c             	pushl  0xc(%ebp)
  800a74:	01 d8                	add    %ebx,%eax
  800a76:	50                   	push   %eax
  800a77:	e8 c5 ff ff ff       	call   800a41 <strcpy>
	return dst;
}
  800a7c:	89 d8                	mov    %ebx,%eax
  800a7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8e:	89 f3                	mov    %esi,%ebx
  800a90:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a93:	89 f2                	mov    %esi,%edx
  800a95:	eb 0f                	jmp    800aa6 <strncpy+0x23>
		*dst++ = *src;
  800a97:	83 c2 01             	add    $0x1,%edx
  800a9a:	0f b6 01             	movzbl (%ecx),%eax
  800a9d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aa0:	80 39 01             	cmpb   $0x1,(%ecx)
  800aa3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa6:	39 da                	cmp    %ebx,%edx
  800aa8:	75 ed                	jne    800a97 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aaa:	89 f0                	mov    %esi,%eax
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abb:	8b 55 10             	mov    0x10(%ebp),%edx
  800abe:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac0:	85 d2                	test   %edx,%edx
  800ac2:	74 21                	je     800ae5 <strlcpy+0x35>
  800ac4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ac8:	89 f2                	mov    %esi,%edx
  800aca:	eb 09                	jmp    800ad5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800acc:	83 c2 01             	add    $0x1,%edx
  800acf:	83 c1 01             	add    $0x1,%ecx
  800ad2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ad5:	39 c2                	cmp    %eax,%edx
  800ad7:	74 09                	je     800ae2 <strlcpy+0x32>
  800ad9:	0f b6 19             	movzbl (%ecx),%ebx
  800adc:	84 db                	test   %bl,%bl
  800ade:	75 ec                	jne    800acc <strlcpy+0x1c>
  800ae0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ae2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ae5:	29 f0                	sub    %esi,%eax
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800af4:	eb 06                	jmp    800afc <strcmp+0x11>
		p++, q++;
  800af6:	83 c1 01             	add    $0x1,%ecx
  800af9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800afc:	0f b6 01             	movzbl (%ecx),%eax
  800aff:	84 c0                	test   %al,%al
  800b01:	74 04                	je     800b07 <strcmp+0x1c>
  800b03:	3a 02                	cmp    (%edx),%al
  800b05:	74 ef                	je     800af6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b07:	0f b6 c0             	movzbl %al,%eax
  800b0a:	0f b6 12             	movzbl (%edx),%edx
  800b0d:	29 d0                	sub    %edx,%eax
}
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	53                   	push   %ebx
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
  800b18:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1b:	89 c3                	mov    %eax,%ebx
  800b1d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b20:	eb 06                	jmp    800b28 <strncmp+0x17>
		n--, p++, q++;
  800b22:	83 c0 01             	add    $0x1,%eax
  800b25:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b28:	39 d8                	cmp    %ebx,%eax
  800b2a:	74 15                	je     800b41 <strncmp+0x30>
  800b2c:	0f b6 08             	movzbl (%eax),%ecx
  800b2f:	84 c9                	test   %cl,%cl
  800b31:	74 04                	je     800b37 <strncmp+0x26>
  800b33:	3a 0a                	cmp    (%edx),%cl
  800b35:	74 eb                	je     800b22 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b37:	0f b6 00             	movzbl (%eax),%eax
  800b3a:	0f b6 12             	movzbl (%edx),%edx
  800b3d:	29 d0                	sub    %edx,%eax
  800b3f:	eb 05                	jmp    800b46 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b46:	5b                   	pop    %ebx
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b53:	eb 07                	jmp    800b5c <strchr+0x13>
		if (*s == c)
  800b55:	38 ca                	cmp    %cl,%dl
  800b57:	74 0f                	je     800b68 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b59:	83 c0 01             	add    $0x1,%eax
  800b5c:	0f b6 10             	movzbl (%eax),%edx
  800b5f:	84 d2                	test   %dl,%dl
  800b61:	75 f2                	jne    800b55 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b74:	eb 03                	jmp    800b79 <strfind+0xf>
  800b76:	83 c0 01             	add    $0x1,%eax
  800b79:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b7c:	38 ca                	cmp    %cl,%dl
  800b7e:	74 04                	je     800b84 <strfind+0x1a>
  800b80:	84 d2                	test   %dl,%dl
  800b82:	75 f2                	jne    800b76 <strfind+0xc>
			break;
	return (char *) s;
}
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b92:	85 c9                	test   %ecx,%ecx
  800b94:	74 36                	je     800bcc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b96:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b9c:	75 28                	jne    800bc6 <memset+0x40>
  800b9e:	f6 c1 03             	test   $0x3,%cl
  800ba1:	75 23                	jne    800bc6 <memset+0x40>
		c &= 0xFF;
  800ba3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ba7:	89 d3                	mov    %edx,%ebx
  800ba9:	c1 e3 08             	shl    $0x8,%ebx
  800bac:	89 d6                	mov    %edx,%esi
  800bae:	c1 e6 18             	shl    $0x18,%esi
  800bb1:	89 d0                	mov    %edx,%eax
  800bb3:	c1 e0 10             	shl    $0x10,%eax
  800bb6:	09 f0                	or     %esi,%eax
  800bb8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bba:	89 d8                	mov    %ebx,%eax
  800bbc:	09 d0                	or     %edx,%eax
  800bbe:	c1 e9 02             	shr    $0x2,%ecx
  800bc1:	fc                   	cld    
  800bc2:	f3 ab                	rep stos %eax,%es:(%edi)
  800bc4:	eb 06                	jmp    800bcc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc9:	fc                   	cld    
  800bca:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bcc:	89 f8                	mov    %edi,%eax
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800be1:	39 c6                	cmp    %eax,%esi
  800be3:	73 35                	jae    800c1a <memmove+0x47>
  800be5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800be8:	39 d0                	cmp    %edx,%eax
  800bea:	73 2e                	jae    800c1a <memmove+0x47>
		s += n;
		d += n;
  800bec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bef:	89 d6                	mov    %edx,%esi
  800bf1:	09 fe                	or     %edi,%esi
  800bf3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bf9:	75 13                	jne    800c0e <memmove+0x3b>
  800bfb:	f6 c1 03             	test   $0x3,%cl
  800bfe:	75 0e                	jne    800c0e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c00:	83 ef 04             	sub    $0x4,%edi
  800c03:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c06:	c1 e9 02             	shr    $0x2,%ecx
  800c09:	fd                   	std    
  800c0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0c:	eb 09                	jmp    800c17 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c0e:	83 ef 01             	sub    $0x1,%edi
  800c11:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c14:	fd                   	std    
  800c15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c17:	fc                   	cld    
  800c18:	eb 1d                	jmp    800c37 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c1a:	89 f2                	mov    %esi,%edx
  800c1c:	09 c2                	or     %eax,%edx
  800c1e:	f6 c2 03             	test   $0x3,%dl
  800c21:	75 0f                	jne    800c32 <memmove+0x5f>
  800c23:	f6 c1 03             	test   $0x3,%cl
  800c26:	75 0a                	jne    800c32 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c28:	c1 e9 02             	shr    $0x2,%ecx
  800c2b:	89 c7                	mov    %eax,%edi
  800c2d:	fc                   	cld    
  800c2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c30:	eb 05                	jmp    800c37 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c32:	89 c7                	mov    %eax,%edi
  800c34:	fc                   	cld    
  800c35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c3e:	ff 75 10             	pushl  0x10(%ebp)
  800c41:	ff 75 0c             	pushl  0xc(%ebp)
  800c44:	ff 75 08             	pushl  0x8(%ebp)
  800c47:	e8 87 ff ff ff       	call   800bd3 <memmove>
}
  800c4c:	c9                   	leave  
  800c4d:	c3                   	ret    

00800c4e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	8b 45 08             	mov    0x8(%ebp),%eax
  800c56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c59:	89 c6                	mov    %eax,%esi
  800c5b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c5e:	eb 1a                	jmp    800c7a <memcmp+0x2c>
		if (*s1 != *s2)
  800c60:	0f b6 08             	movzbl (%eax),%ecx
  800c63:	0f b6 1a             	movzbl (%edx),%ebx
  800c66:	38 d9                	cmp    %bl,%cl
  800c68:	74 0a                	je     800c74 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c6a:	0f b6 c1             	movzbl %cl,%eax
  800c6d:	0f b6 db             	movzbl %bl,%ebx
  800c70:	29 d8                	sub    %ebx,%eax
  800c72:	eb 0f                	jmp    800c83 <memcmp+0x35>
		s1++, s2++;
  800c74:	83 c0 01             	add    $0x1,%eax
  800c77:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7a:	39 f0                	cmp    %esi,%eax
  800c7c:	75 e2                	jne    800c60 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	53                   	push   %ebx
  800c8b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c8e:	89 c1                	mov    %eax,%ecx
  800c90:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c93:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c97:	eb 0a                	jmp    800ca3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c99:	0f b6 10             	movzbl (%eax),%edx
  800c9c:	39 da                	cmp    %ebx,%edx
  800c9e:	74 07                	je     800ca7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ca0:	83 c0 01             	add    $0x1,%eax
  800ca3:	39 c8                	cmp    %ecx,%eax
  800ca5:	72 f2                	jb     800c99 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ca7:	5b                   	pop    %ebx
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb6:	eb 03                	jmp    800cbb <strtol+0x11>
		s++;
  800cb8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cbb:	0f b6 01             	movzbl (%ecx),%eax
  800cbe:	3c 20                	cmp    $0x20,%al
  800cc0:	74 f6                	je     800cb8 <strtol+0xe>
  800cc2:	3c 09                	cmp    $0x9,%al
  800cc4:	74 f2                	je     800cb8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cc6:	3c 2b                	cmp    $0x2b,%al
  800cc8:	75 0a                	jne    800cd4 <strtol+0x2a>
		s++;
  800cca:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ccd:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd2:	eb 11                	jmp    800ce5 <strtol+0x3b>
  800cd4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cd9:	3c 2d                	cmp    $0x2d,%al
  800cdb:	75 08                	jne    800ce5 <strtol+0x3b>
		s++, neg = 1;
  800cdd:	83 c1 01             	add    $0x1,%ecx
  800ce0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ce5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ceb:	75 15                	jne    800d02 <strtol+0x58>
  800ced:	80 39 30             	cmpb   $0x30,(%ecx)
  800cf0:	75 10                	jne    800d02 <strtol+0x58>
  800cf2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cf6:	75 7c                	jne    800d74 <strtol+0xca>
		s += 2, base = 16;
  800cf8:	83 c1 02             	add    $0x2,%ecx
  800cfb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d00:	eb 16                	jmp    800d18 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d02:	85 db                	test   %ebx,%ebx
  800d04:	75 12                	jne    800d18 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d06:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d0b:	80 39 30             	cmpb   $0x30,(%ecx)
  800d0e:	75 08                	jne    800d18 <strtol+0x6e>
		s++, base = 8;
  800d10:	83 c1 01             	add    $0x1,%ecx
  800d13:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d18:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d20:	0f b6 11             	movzbl (%ecx),%edx
  800d23:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d26:	89 f3                	mov    %esi,%ebx
  800d28:	80 fb 09             	cmp    $0x9,%bl
  800d2b:	77 08                	ja     800d35 <strtol+0x8b>
			dig = *s - '0';
  800d2d:	0f be d2             	movsbl %dl,%edx
  800d30:	83 ea 30             	sub    $0x30,%edx
  800d33:	eb 22                	jmp    800d57 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d35:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d38:	89 f3                	mov    %esi,%ebx
  800d3a:	80 fb 19             	cmp    $0x19,%bl
  800d3d:	77 08                	ja     800d47 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d3f:	0f be d2             	movsbl %dl,%edx
  800d42:	83 ea 57             	sub    $0x57,%edx
  800d45:	eb 10                	jmp    800d57 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d47:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d4a:	89 f3                	mov    %esi,%ebx
  800d4c:	80 fb 19             	cmp    $0x19,%bl
  800d4f:	77 16                	ja     800d67 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d51:	0f be d2             	movsbl %dl,%edx
  800d54:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d57:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d5a:	7d 0b                	jge    800d67 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d5c:	83 c1 01             	add    $0x1,%ecx
  800d5f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d63:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d65:	eb b9                	jmp    800d20 <strtol+0x76>

	if (endptr)
  800d67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d6b:	74 0d                	je     800d7a <strtol+0xd0>
		*endptr = (char *) s;
  800d6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d70:	89 0e                	mov    %ecx,(%esi)
  800d72:	eb 06                	jmp    800d7a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d74:	85 db                	test   %ebx,%ebx
  800d76:	74 98                	je     800d10 <strtol+0x66>
  800d78:	eb 9e                	jmp    800d18 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d7a:	89 c2                	mov    %eax,%edx
  800d7c:	f7 da                	neg    %edx
  800d7e:	85 ff                	test   %edi,%edi
  800d80:	0f 45 c2             	cmovne %edx,%eax
}
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	89 c3                	mov    %eax,%ebx
  800d9b:	89 c7                	mov    %eax,%edi
  800d9d:	89 c6                	mov    %eax,%esi
  800d9f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dac:	ba 00 00 00 00       	mov    $0x0,%edx
  800db1:	b8 01 00 00 00       	mov    $0x1,%eax
  800db6:	89 d1                	mov    %edx,%ecx
  800db8:	89 d3                	mov    %edx,%ebx
  800dba:	89 d7                	mov    %edx,%edi
  800dbc:	89 d6                	mov    %edx,%esi
  800dbe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
  800dcb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd3:	b8 03 00 00 00       	mov    $0x3,%eax
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	89 cb                	mov    %ecx,%ebx
  800ddd:	89 cf                	mov    %ecx,%edi
  800ddf:	89 ce                	mov    %ecx,%esi
  800de1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7e 17                	jle    800dfe <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	50                   	push   %eax
  800deb:	6a 03                	push   $0x3
  800ded:	68 0f 28 80 00       	push   $0x80280f
  800df2:	6a 23                	push   $0x23
  800df4:	68 2c 28 80 00       	push   $0x80282c
  800df9:	e8 f2 f4 ff ff       	call   8002f0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e11:	b8 02 00 00 00       	mov    $0x2,%eax
  800e16:	89 d1                	mov    %edx,%ecx
  800e18:	89 d3                	mov    %edx,%ebx
  800e1a:	89 d7                	mov    %edx,%edi
  800e1c:	89 d6                	mov    %edx,%esi
  800e1e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_yield>:

void
sys_yield(void)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e30:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e35:	89 d1                	mov    %edx,%ecx
  800e37:	89 d3                	mov    %edx,%ebx
  800e39:	89 d7                	mov    %edx,%edi
  800e3b:	89 d6                	mov    %edx,%esi
  800e3d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
  800e4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4d:	be 00 00 00 00       	mov    $0x0,%esi
  800e52:	b8 04 00 00 00       	mov    $0x4,%eax
  800e57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e60:	89 f7                	mov    %esi,%edi
  800e62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e64:	85 c0                	test   %eax,%eax
  800e66:	7e 17                	jle    800e7f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e68:	83 ec 0c             	sub    $0xc,%esp
  800e6b:	50                   	push   %eax
  800e6c:	6a 04                	push   $0x4
  800e6e:	68 0f 28 80 00       	push   $0x80280f
  800e73:	6a 23                	push   $0x23
  800e75:	68 2c 28 80 00       	push   $0x80282c
  800e7a:	e8 71 f4 ff ff       	call   8002f0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e82:	5b                   	pop    %ebx
  800e83:	5e                   	pop    %esi
  800e84:	5f                   	pop    %edi
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    

00800e87 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	57                   	push   %edi
  800e8b:	56                   	push   %esi
  800e8c:	53                   	push   %ebx
  800e8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e90:	b8 05 00 00 00       	mov    $0x5,%eax
  800e95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e98:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea1:	8b 75 18             	mov    0x18(%ebp),%esi
  800ea4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	7e 17                	jle    800ec1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eaa:	83 ec 0c             	sub    $0xc,%esp
  800ead:	50                   	push   %eax
  800eae:	6a 05                	push   $0x5
  800eb0:	68 0f 28 80 00       	push   $0x80280f
  800eb5:	6a 23                	push   $0x23
  800eb7:	68 2c 28 80 00       	push   $0x80282c
  800ebc:	e8 2f f4 ff ff       	call   8002f0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ec1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	57                   	push   %edi
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
  800ecf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed7:	b8 06 00 00 00       	mov    $0x6,%eax
  800edc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee2:	89 df                	mov    %ebx,%edi
  800ee4:	89 de                	mov    %ebx,%esi
  800ee6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	7e 17                	jle    800f03 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eec:	83 ec 0c             	sub    $0xc,%esp
  800eef:	50                   	push   %eax
  800ef0:	6a 06                	push   $0x6
  800ef2:	68 0f 28 80 00       	push   $0x80280f
  800ef7:	6a 23                	push   $0x23
  800ef9:	68 2c 28 80 00       	push   $0x80282c
  800efe:	e8 ed f3 ff ff       	call   8002f0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f06:	5b                   	pop    %ebx
  800f07:	5e                   	pop    %esi
  800f08:	5f                   	pop    %edi
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	57                   	push   %edi
  800f0f:	56                   	push   %esi
  800f10:	53                   	push   %ebx
  800f11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f19:	b8 08 00 00 00       	mov    $0x8,%eax
  800f1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f21:	8b 55 08             	mov    0x8(%ebp),%edx
  800f24:	89 df                	mov    %ebx,%edi
  800f26:	89 de                	mov    %ebx,%esi
  800f28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	7e 17                	jle    800f45 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2e:	83 ec 0c             	sub    $0xc,%esp
  800f31:	50                   	push   %eax
  800f32:	6a 08                	push   $0x8
  800f34:	68 0f 28 80 00       	push   $0x80280f
  800f39:	6a 23                	push   $0x23
  800f3b:	68 2c 28 80 00       	push   $0x80282c
  800f40:	e8 ab f3 ff ff       	call   8002f0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	57                   	push   %edi
  800f51:	56                   	push   %esi
  800f52:	53                   	push   %ebx
  800f53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5b:	b8 09 00 00 00       	mov    $0x9,%eax
  800f60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f63:	8b 55 08             	mov    0x8(%ebp),%edx
  800f66:	89 df                	mov    %ebx,%edi
  800f68:	89 de                	mov    %ebx,%esi
  800f6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	7e 17                	jle    800f87 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f70:	83 ec 0c             	sub    $0xc,%esp
  800f73:	50                   	push   %eax
  800f74:	6a 09                	push   $0x9
  800f76:	68 0f 28 80 00       	push   $0x80280f
  800f7b:	6a 23                	push   $0x23
  800f7d:	68 2c 28 80 00       	push   $0x80282c
  800f82:	e8 69 f3 ff ff       	call   8002f0 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8a:	5b                   	pop    %ebx
  800f8b:	5e                   	pop    %esi
  800f8c:	5f                   	pop    %edi
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    

00800f8f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	57                   	push   %edi
  800f93:	56                   	push   %esi
  800f94:	53                   	push   %ebx
  800f95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa8:	89 df                	mov    %ebx,%edi
  800faa:	89 de                	mov    %ebx,%esi
  800fac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	7e 17                	jle    800fc9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb2:	83 ec 0c             	sub    $0xc,%esp
  800fb5:	50                   	push   %eax
  800fb6:	6a 0a                	push   $0xa
  800fb8:	68 0f 28 80 00       	push   $0x80280f
  800fbd:	6a 23                	push   $0x23
  800fbf:	68 2c 28 80 00       	push   $0x80282c
  800fc4:	e8 27 f3 ff ff       	call   8002f0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcc:	5b                   	pop    %ebx
  800fcd:	5e                   	pop    %esi
  800fce:	5f                   	pop    %edi
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    

00800fd1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	57                   	push   %edi
  800fd5:	56                   	push   %esi
  800fd6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd7:	be 00 00 00 00       	mov    $0x0,%esi
  800fdc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fe1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fea:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fed:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fef:	5b                   	pop    %ebx
  800ff0:	5e                   	pop    %esi
  800ff1:	5f                   	pop    %edi
  800ff2:	5d                   	pop    %ebp
  800ff3:	c3                   	ret    

00800ff4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	57                   	push   %edi
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
  800ffa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801002:	b8 0d 00 00 00       	mov    $0xd,%eax
  801007:	8b 55 08             	mov    0x8(%ebp),%edx
  80100a:	89 cb                	mov    %ecx,%ebx
  80100c:	89 cf                	mov    %ecx,%edi
  80100e:	89 ce                	mov    %ecx,%esi
  801010:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801012:	85 c0                	test   %eax,%eax
  801014:	7e 17                	jle    80102d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	50                   	push   %eax
  80101a:	6a 0d                	push   $0xd
  80101c:	68 0f 28 80 00       	push   $0x80280f
  801021:	6a 23                	push   $0x23
  801023:	68 2c 28 80 00       	push   $0x80282c
  801028:	e8 c3 f2 ff ff       	call   8002f0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80102d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801030:	5b                   	pop    %ebx
  801031:	5e                   	pop    %esi
  801032:	5f                   	pop    %edi
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
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
  80103b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801040:	b8 0e 00 00 00       	mov    $0xe,%eax
  801045:	8b 55 08             	mov    0x8(%ebp),%edx
  801048:	89 cb                	mov    %ecx,%ebx
  80104a:	89 cf                	mov    %ecx,%edi
  80104c:	89 ce                	mov    %ecx,%esi
  80104e:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  801050:	5b                   	pop    %ebx
  801051:	5e                   	pop    %esi
  801052:	5f                   	pop    %edi
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    

00801055 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	57                   	push   %edi
  801059:	56                   	push   %esi
  80105a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801060:	b8 0f 00 00 00       	mov    $0xf,%eax
  801065:	8b 55 08             	mov    0x8(%ebp),%edx
  801068:	89 cb                	mov    %ecx,%ebx
  80106a:	89 cf                	mov    %ecx,%edi
  80106c:	89 ce                	mov    %ecx,%esi
  80106e:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5f                   	pop    %edi
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	53                   	push   %ebx
  801079:	83 ec 04             	sub    $0x4,%esp
  80107c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80107f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  801081:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801085:	74 11                	je     801098 <pgfault+0x23>
  801087:	89 d8                	mov    %ebx,%eax
  801089:	c1 e8 0c             	shr    $0xc,%eax
  80108c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801093:	f6 c4 08             	test   $0x8,%ah
  801096:	75 14                	jne    8010ac <pgfault+0x37>
		panic("faulting access");
  801098:	83 ec 04             	sub    $0x4,%esp
  80109b:	68 3a 28 80 00       	push   $0x80283a
  8010a0:	6a 1e                	push   $0x1e
  8010a2:	68 4a 28 80 00       	push   $0x80284a
  8010a7:	e8 44 f2 ff ff       	call   8002f0 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8010ac:	83 ec 04             	sub    $0x4,%esp
  8010af:	6a 07                	push   $0x7
  8010b1:	68 00 f0 7f 00       	push   $0x7ff000
  8010b6:	6a 00                	push   $0x0
  8010b8:	e8 87 fd ff ff       	call   800e44 <sys_page_alloc>
	if (r < 0) {
  8010bd:	83 c4 10             	add    $0x10,%esp
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	79 12                	jns    8010d6 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  8010c4:	50                   	push   %eax
  8010c5:	68 55 28 80 00       	push   $0x802855
  8010ca:	6a 2c                	push   $0x2c
  8010cc:	68 4a 28 80 00       	push   $0x80284a
  8010d1:	e8 1a f2 ff ff       	call   8002f0 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  8010d6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  8010dc:	83 ec 04             	sub    $0x4,%esp
  8010df:	68 00 10 00 00       	push   $0x1000
  8010e4:	53                   	push   %ebx
  8010e5:	68 00 f0 7f 00       	push   $0x7ff000
  8010ea:	e8 4c fb ff ff       	call   800c3b <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  8010ef:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8010f6:	53                   	push   %ebx
  8010f7:	6a 00                	push   $0x0
  8010f9:	68 00 f0 7f 00       	push   $0x7ff000
  8010fe:	6a 00                	push   $0x0
  801100:	e8 82 fd ff ff       	call   800e87 <sys_page_map>
	if (r < 0) {
  801105:	83 c4 20             	add    $0x20,%esp
  801108:	85 c0                	test   %eax,%eax
  80110a:	79 12                	jns    80111e <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80110c:	50                   	push   %eax
  80110d:	68 55 28 80 00       	push   $0x802855
  801112:	6a 33                	push   $0x33
  801114:	68 4a 28 80 00       	push   $0x80284a
  801119:	e8 d2 f1 ff ff       	call   8002f0 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  80111e:	83 ec 08             	sub    $0x8,%esp
  801121:	68 00 f0 7f 00       	push   $0x7ff000
  801126:	6a 00                	push   $0x0
  801128:	e8 9c fd ff ff       	call   800ec9 <sys_page_unmap>
	if (r < 0) {
  80112d:	83 c4 10             	add    $0x10,%esp
  801130:	85 c0                	test   %eax,%eax
  801132:	79 12                	jns    801146 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  801134:	50                   	push   %eax
  801135:	68 55 28 80 00       	push   $0x802855
  80113a:	6a 37                	push   $0x37
  80113c:	68 4a 28 80 00       	push   $0x80284a
  801141:	e8 aa f1 ff ff       	call   8002f0 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  801146:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801149:	c9                   	leave  
  80114a:	c3                   	ret    

0080114b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	57                   	push   %edi
  80114f:	56                   	push   %esi
  801150:	53                   	push   %ebx
  801151:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  801154:	68 75 10 80 00       	push   $0x801075
  801159:	e8 80 0e 00 00       	call   801fde <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80115e:	b8 07 00 00 00       	mov    $0x7,%eax
  801163:	cd 30                	int    $0x30
  801165:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	85 c0                	test   %eax,%eax
  80116d:	79 17                	jns    801186 <fork+0x3b>
		panic("fork fault %e");
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	68 6e 28 80 00       	push   $0x80286e
  801177:	68 84 00 00 00       	push   $0x84
  80117c:	68 4a 28 80 00       	push   $0x80284a
  801181:	e8 6a f1 ff ff       	call   8002f0 <_panic>
  801186:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801188:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80118c:	75 25                	jne    8011b3 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  80118e:	e8 73 fc ff ff       	call   800e06 <sys_getenvid>
  801193:	25 ff 03 00 00       	and    $0x3ff,%eax
  801198:	89 c2                	mov    %eax,%edx
  80119a:	c1 e2 07             	shl    $0x7,%edx
  80119d:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8011a4:	a3 04 44 80 00       	mov    %eax,0x804404
		return 0;
  8011a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ae:	e9 61 01 00 00       	jmp    801314 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8011b3:	83 ec 04             	sub    $0x4,%esp
  8011b6:	6a 07                	push   $0x7
  8011b8:	68 00 f0 bf ee       	push   $0xeebff000
  8011bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c0:	e8 7f fc ff ff       	call   800e44 <sys_page_alloc>
  8011c5:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8011c8:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8011cd:	89 d8                	mov    %ebx,%eax
  8011cf:	c1 e8 16             	shr    $0x16,%eax
  8011d2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011d9:	a8 01                	test   $0x1,%al
  8011db:	0f 84 fc 00 00 00    	je     8012dd <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  8011e1:	89 d8                	mov    %ebx,%eax
  8011e3:	c1 e8 0c             	shr    $0xc,%eax
  8011e6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8011ed:	f6 c2 01             	test   $0x1,%dl
  8011f0:	0f 84 e7 00 00 00    	je     8012dd <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  8011f6:	89 c6                	mov    %eax,%esi
  8011f8:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  8011fb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801202:	f6 c6 04             	test   $0x4,%dh
  801205:	74 39                	je     801240 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801207:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80120e:	83 ec 0c             	sub    $0xc,%esp
  801211:	25 07 0e 00 00       	and    $0xe07,%eax
  801216:	50                   	push   %eax
  801217:	56                   	push   %esi
  801218:	57                   	push   %edi
  801219:	56                   	push   %esi
  80121a:	6a 00                	push   $0x0
  80121c:	e8 66 fc ff ff       	call   800e87 <sys_page_map>
		if (r < 0) {
  801221:	83 c4 20             	add    $0x20,%esp
  801224:	85 c0                	test   %eax,%eax
  801226:	0f 89 b1 00 00 00    	jns    8012dd <fork+0x192>
		    	panic("sys page map fault %e");
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	68 7c 28 80 00       	push   $0x80287c
  801234:	6a 54                	push   $0x54
  801236:	68 4a 28 80 00       	push   $0x80284a
  80123b:	e8 b0 f0 ff ff       	call   8002f0 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801240:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801247:	f6 c2 02             	test   $0x2,%dl
  80124a:	75 0c                	jne    801258 <fork+0x10d>
  80124c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801253:	f6 c4 08             	test   $0x8,%ah
  801256:	74 5b                	je     8012b3 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801258:	83 ec 0c             	sub    $0xc,%esp
  80125b:	68 05 08 00 00       	push   $0x805
  801260:	56                   	push   %esi
  801261:	57                   	push   %edi
  801262:	56                   	push   %esi
  801263:	6a 00                	push   $0x0
  801265:	e8 1d fc ff ff       	call   800e87 <sys_page_map>
		if (r < 0) {
  80126a:	83 c4 20             	add    $0x20,%esp
  80126d:	85 c0                	test   %eax,%eax
  80126f:	79 14                	jns    801285 <fork+0x13a>
		    	panic("sys page map fault %e");
  801271:	83 ec 04             	sub    $0x4,%esp
  801274:	68 7c 28 80 00       	push   $0x80287c
  801279:	6a 5b                	push   $0x5b
  80127b:	68 4a 28 80 00       	push   $0x80284a
  801280:	e8 6b f0 ff ff       	call   8002f0 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801285:	83 ec 0c             	sub    $0xc,%esp
  801288:	68 05 08 00 00       	push   $0x805
  80128d:	56                   	push   %esi
  80128e:	6a 00                	push   $0x0
  801290:	56                   	push   %esi
  801291:	6a 00                	push   $0x0
  801293:	e8 ef fb ff ff       	call   800e87 <sys_page_map>
		if (r < 0) {
  801298:	83 c4 20             	add    $0x20,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	79 3e                	jns    8012dd <fork+0x192>
		    	panic("sys page map fault %e");
  80129f:	83 ec 04             	sub    $0x4,%esp
  8012a2:	68 7c 28 80 00       	push   $0x80287c
  8012a7:	6a 5f                	push   $0x5f
  8012a9:	68 4a 28 80 00       	push   $0x80284a
  8012ae:	e8 3d f0 ff ff       	call   8002f0 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8012b3:	83 ec 0c             	sub    $0xc,%esp
  8012b6:	6a 05                	push   $0x5
  8012b8:	56                   	push   %esi
  8012b9:	57                   	push   %edi
  8012ba:	56                   	push   %esi
  8012bb:	6a 00                	push   $0x0
  8012bd:	e8 c5 fb ff ff       	call   800e87 <sys_page_map>
		if (r < 0) {
  8012c2:	83 c4 20             	add    $0x20,%esp
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	79 14                	jns    8012dd <fork+0x192>
		    	panic("sys page map fault %e");
  8012c9:	83 ec 04             	sub    $0x4,%esp
  8012cc:	68 7c 28 80 00       	push   $0x80287c
  8012d1:	6a 64                	push   $0x64
  8012d3:	68 4a 28 80 00       	push   $0x80284a
  8012d8:	e8 13 f0 ff ff       	call   8002f0 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8012dd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012e3:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8012e9:	0f 85 de fe ff ff    	jne    8011cd <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8012ef:	a1 04 44 80 00       	mov    0x804404,%eax
  8012f4:	8b 40 70             	mov    0x70(%eax),%eax
  8012f7:	83 ec 08             	sub    $0x8,%esp
  8012fa:	50                   	push   %eax
  8012fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012fe:	57                   	push   %edi
  8012ff:	e8 8b fc ff ff       	call   800f8f <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801304:	83 c4 08             	add    $0x8,%esp
  801307:	6a 02                	push   $0x2
  801309:	57                   	push   %edi
  80130a:	e8 fc fb ff ff       	call   800f0b <sys_env_set_status>
	
	return envid;
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801314:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801317:	5b                   	pop    %ebx
  801318:	5e                   	pop    %esi
  801319:	5f                   	pop    %edi
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <sfork>:

envid_t
sfork(void)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80131f:	b8 00 00 00 00       	mov    $0x0,%eax
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	56                   	push   %esi
  80132a:	53                   	push   %ebx
  80132b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80132e:	89 1d 08 44 80 00    	mov    %ebx,0x804408
	cprintf("in fork.c thread create. func: %x\n", func);
  801334:	83 ec 08             	sub    $0x8,%esp
  801337:	53                   	push   %ebx
  801338:	68 94 28 80 00       	push   $0x802894
  80133d:	e8 87 f0 ff ff       	call   8003c9 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801342:	c7 04 24 b6 02 80 00 	movl   $0x8002b6,(%esp)
  801349:	e8 e7 fc ff ff       	call   801035 <sys_thread_create>
  80134e:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801350:	83 c4 08             	add    $0x8,%esp
  801353:	53                   	push   %ebx
  801354:	68 94 28 80 00       	push   $0x802894
  801359:	e8 6b f0 ff ff       	call   8003c9 <cprintf>
	return id;
	//return 0;
}
  80135e:	89 f0                	mov    %esi,%eax
  801360:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801363:	5b                   	pop    %ebx
  801364:	5e                   	pop    %esi
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    

00801367 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80136a:	8b 45 08             	mov    0x8(%ebp),%eax
  80136d:	05 00 00 00 30       	add    $0x30000000,%eax
  801372:	c1 e8 0c             	shr    $0xc,%eax
}
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    

00801377 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80137a:	8b 45 08             	mov    0x8(%ebp),%eax
  80137d:	05 00 00 00 30       	add    $0x30000000,%eax
  801382:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801387:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    

0080138e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801394:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801399:	89 c2                	mov    %eax,%edx
  80139b:	c1 ea 16             	shr    $0x16,%edx
  80139e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a5:	f6 c2 01             	test   $0x1,%dl
  8013a8:	74 11                	je     8013bb <fd_alloc+0x2d>
  8013aa:	89 c2                	mov    %eax,%edx
  8013ac:	c1 ea 0c             	shr    $0xc,%edx
  8013af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b6:	f6 c2 01             	test   $0x1,%dl
  8013b9:	75 09                	jne    8013c4 <fd_alloc+0x36>
			*fd_store = fd;
  8013bb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c2:	eb 17                	jmp    8013db <fd_alloc+0x4d>
  8013c4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013c9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013ce:	75 c9                	jne    801399 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013d0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013d6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    

008013dd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013e3:	83 f8 1f             	cmp    $0x1f,%eax
  8013e6:	77 36                	ja     80141e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013e8:	c1 e0 0c             	shl    $0xc,%eax
  8013eb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013f0:	89 c2                	mov    %eax,%edx
  8013f2:	c1 ea 16             	shr    $0x16,%edx
  8013f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013fc:	f6 c2 01             	test   $0x1,%dl
  8013ff:	74 24                	je     801425 <fd_lookup+0x48>
  801401:	89 c2                	mov    %eax,%edx
  801403:	c1 ea 0c             	shr    $0xc,%edx
  801406:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80140d:	f6 c2 01             	test   $0x1,%dl
  801410:	74 1a                	je     80142c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801412:	8b 55 0c             	mov    0xc(%ebp),%edx
  801415:	89 02                	mov    %eax,(%edx)
	return 0;
  801417:	b8 00 00 00 00       	mov    $0x0,%eax
  80141c:	eb 13                	jmp    801431 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80141e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801423:	eb 0c                	jmp    801431 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801425:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80142a:	eb 05                	jmp    801431 <fd_lookup+0x54>
  80142c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    

00801433 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80143c:	ba 38 29 80 00       	mov    $0x802938,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801441:	eb 13                	jmp    801456 <dev_lookup+0x23>
  801443:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801446:	39 08                	cmp    %ecx,(%eax)
  801448:	75 0c                	jne    801456 <dev_lookup+0x23>
			*dev = devtab[i];
  80144a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80144d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80144f:	b8 00 00 00 00       	mov    $0x0,%eax
  801454:	eb 2e                	jmp    801484 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801456:	8b 02                	mov    (%edx),%eax
  801458:	85 c0                	test   %eax,%eax
  80145a:	75 e7                	jne    801443 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80145c:	a1 04 44 80 00       	mov    0x804404,%eax
  801461:	8b 40 54             	mov    0x54(%eax),%eax
  801464:	83 ec 04             	sub    $0x4,%esp
  801467:	51                   	push   %ecx
  801468:	50                   	push   %eax
  801469:	68 b8 28 80 00       	push   $0x8028b8
  80146e:	e8 56 ef ff ff       	call   8003c9 <cprintf>
	*dev = 0;
  801473:	8b 45 0c             	mov    0xc(%ebp),%eax
  801476:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801484:	c9                   	leave  
  801485:	c3                   	ret    

00801486 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	56                   	push   %esi
  80148a:	53                   	push   %ebx
  80148b:	83 ec 10             	sub    $0x10,%esp
  80148e:	8b 75 08             	mov    0x8(%ebp),%esi
  801491:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801494:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80149e:	c1 e8 0c             	shr    $0xc,%eax
  8014a1:	50                   	push   %eax
  8014a2:	e8 36 ff ff ff       	call   8013dd <fd_lookup>
  8014a7:	83 c4 08             	add    $0x8,%esp
  8014aa:	85 c0                	test   %eax,%eax
  8014ac:	78 05                	js     8014b3 <fd_close+0x2d>
	    || fd != fd2)
  8014ae:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014b1:	74 0c                	je     8014bf <fd_close+0x39>
		return (must_exist ? r : 0);
  8014b3:	84 db                	test   %bl,%bl
  8014b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ba:	0f 44 c2             	cmove  %edx,%eax
  8014bd:	eb 41                	jmp    801500 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014bf:	83 ec 08             	sub    $0x8,%esp
  8014c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c5:	50                   	push   %eax
  8014c6:	ff 36                	pushl  (%esi)
  8014c8:	e8 66 ff ff ff       	call   801433 <dev_lookup>
  8014cd:	89 c3                	mov    %eax,%ebx
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 1a                	js     8014f0 <fd_close+0x6a>
		if (dev->dev_close)
  8014d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014dc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	74 0b                	je     8014f0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014e5:	83 ec 0c             	sub    $0xc,%esp
  8014e8:	56                   	push   %esi
  8014e9:	ff d0                	call   *%eax
  8014eb:	89 c3                	mov    %eax,%ebx
  8014ed:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014f0:	83 ec 08             	sub    $0x8,%esp
  8014f3:	56                   	push   %esi
  8014f4:	6a 00                	push   $0x0
  8014f6:	e8 ce f9 ff ff       	call   800ec9 <sys_page_unmap>
	return r;
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	89 d8                	mov    %ebx,%eax
}
  801500:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801503:	5b                   	pop    %ebx
  801504:	5e                   	pop    %esi
  801505:	5d                   	pop    %ebp
  801506:	c3                   	ret    

00801507 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80150d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801510:	50                   	push   %eax
  801511:	ff 75 08             	pushl  0x8(%ebp)
  801514:	e8 c4 fe ff ff       	call   8013dd <fd_lookup>
  801519:	83 c4 08             	add    $0x8,%esp
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 10                	js     801530 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	6a 01                	push   $0x1
  801525:	ff 75 f4             	pushl  -0xc(%ebp)
  801528:	e8 59 ff ff ff       	call   801486 <fd_close>
  80152d:	83 c4 10             	add    $0x10,%esp
}
  801530:	c9                   	leave  
  801531:	c3                   	ret    

00801532 <close_all>:

void
close_all(void)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	53                   	push   %ebx
  801536:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801539:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80153e:	83 ec 0c             	sub    $0xc,%esp
  801541:	53                   	push   %ebx
  801542:	e8 c0 ff ff ff       	call   801507 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801547:	83 c3 01             	add    $0x1,%ebx
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	83 fb 20             	cmp    $0x20,%ebx
  801550:	75 ec                	jne    80153e <close_all+0xc>
		close(i);
}
  801552:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801555:	c9                   	leave  
  801556:	c3                   	ret    

00801557 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	57                   	push   %edi
  80155b:	56                   	push   %esi
  80155c:	53                   	push   %ebx
  80155d:	83 ec 2c             	sub    $0x2c,%esp
  801560:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801563:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801566:	50                   	push   %eax
  801567:	ff 75 08             	pushl  0x8(%ebp)
  80156a:	e8 6e fe ff ff       	call   8013dd <fd_lookup>
  80156f:	83 c4 08             	add    $0x8,%esp
  801572:	85 c0                	test   %eax,%eax
  801574:	0f 88 c1 00 00 00    	js     80163b <dup+0xe4>
		return r;
	close(newfdnum);
  80157a:	83 ec 0c             	sub    $0xc,%esp
  80157d:	56                   	push   %esi
  80157e:	e8 84 ff ff ff       	call   801507 <close>

	newfd = INDEX2FD(newfdnum);
  801583:	89 f3                	mov    %esi,%ebx
  801585:	c1 e3 0c             	shl    $0xc,%ebx
  801588:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80158e:	83 c4 04             	add    $0x4,%esp
  801591:	ff 75 e4             	pushl  -0x1c(%ebp)
  801594:	e8 de fd ff ff       	call   801377 <fd2data>
  801599:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80159b:	89 1c 24             	mov    %ebx,(%esp)
  80159e:	e8 d4 fd ff ff       	call   801377 <fd2data>
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015a9:	89 f8                	mov    %edi,%eax
  8015ab:	c1 e8 16             	shr    $0x16,%eax
  8015ae:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015b5:	a8 01                	test   $0x1,%al
  8015b7:	74 37                	je     8015f0 <dup+0x99>
  8015b9:	89 f8                	mov    %edi,%eax
  8015bb:	c1 e8 0c             	shr    $0xc,%eax
  8015be:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015c5:	f6 c2 01             	test   $0x1,%dl
  8015c8:	74 26                	je     8015f0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015d1:	83 ec 0c             	sub    $0xc,%esp
  8015d4:	25 07 0e 00 00       	and    $0xe07,%eax
  8015d9:	50                   	push   %eax
  8015da:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015dd:	6a 00                	push   $0x0
  8015df:	57                   	push   %edi
  8015e0:	6a 00                	push   $0x0
  8015e2:	e8 a0 f8 ff ff       	call   800e87 <sys_page_map>
  8015e7:	89 c7                	mov    %eax,%edi
  8015e9:	83 c4 20             	add    $0x20,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 2e                	js     80161e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015f3:	89 d0                	mov    %edx,%eax
  8015f5:	c1 e8 0c             	shr    $0xc,%eax
  8015f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015ff:	83 ec 0c             	sub    $0xc,%esp
  801602:	25 07 0e 00 00       	and    $0xe07,%eax
  801607:	50                   	push   %eax
  801608:	53                   	push   %ebx
  801609:	6a 00                	push   $0x0
  80160b:	52                   	push   %edx
  80160c:	6a 00                	push   $0x0
  80160e:	e8 74 f8 ff ff       	call   800e87 <sys_page_map>
  801613:	89 c7                	mov    %eax,%edi
  801615:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801618:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80161a:	85 ff                	test   %edi,%edi
  80161c:	79 1d                	jns    80163b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	53                   	push   %ebx
  801622:	6a 00                	push   $0x0
  801624:	e8 a0 f8 ff ff       	call   800ec9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801629:	83 c4 08             	add    $0x8,%esp
  80162c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80162f:	6a 00                	push   $0x0
  801631:	e8 93 f8 ff ff       	call   800ec9 <sys_page_unmap>
	return r;
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	89 f8                	mov    %edi,%eax
}
  80163b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163e:	5b                   	pop    %ebx
  80163f:	5e                   	pop    %esi
  801640:	5f                   	pop    %edi
  801641:	5d                   	pop    %ebp
  801642:	c3                   	ret    

00801643 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	53                   	push   %ebx
  801647:	83 ec 14             	sub    $0x14,%esp
  80164a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801650:	50                   	push   %eax
  801651:	53                   	push   %ebx
  801652:	e8 86 fd ff ff       	call   8013dd <fd_lookup>
  801657:	83 c4 08             	add    $0x8,%esp
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 6d                	js     8016cd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801666:	50                   	push   %eax
  801667:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166a:	ff 30                	pushl  (%eax)
  80166c:	e8 c2 fd ff ff       	call   801433 <dev_lookup>
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	85 c0                	test   %eax,%eax
  801676:	78 4c                	js     8016c4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801678:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80167b:	8b 42 08             	mov    0x8(%edx),%eax
  80167e:	83 e0 03             	and    $0x3,%eax
  801681:	83 f8 01             	cmp    $0x1,%eax
  801684:	75 21                	jne    8016a7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801686:	a1 04 44 80 00       	mov    0x804404,%eax
  80168b:	8b 40 54             	mov    0x54(%eax),%eax
  80168e:	83 ec 04             	sub    $0x4,%esp
  801691:	53                   	push   %ebx
  801692:	50                   	push   %eax
  801693:	68 fc 28 80 00       	push   $0x8028fc
  801698:	e8 2c ed ff ff       	call   8003c9 <cprintf>
		return -E_INVAL;
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a5:	eb 26                	jmp    8016cd <read+0x8a>
	}
	if (!dev->dev_read)
  8016a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016aa:	8b 40 08             	mov    0x8(%eax),%eax
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	74 17                	je     8016c8 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016b1:	83 ec 04             	sub    $0x4,%esp
  8016b4:	ff 75 10             	pushl  0x10(%ebp)
  8016b7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ba:	52                   	push   %edx
  8016bb:	ff d0                	call   *%eax
  8016bd:	89 c2                	mov    %eax,%edx
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	eb 09                	jmp    8016cd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c4:	89 c2                	mov    %eax,%edx
  8016c6:	eb 05                	jmp    8016cd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8016cd:	89 d0                	mov    %edx,%eax
  8016cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    

008016d4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	57                   	push   %edi
  8016d8:	56                   	push   %esi
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 0c             	sub    $0xc,%esp
  8016dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016e0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e8:	eb 21                	jmp    80170b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016ea:	83 ec 04             	sub    $0x4,%esp
  8016ed:	89 f0                	mov    %esi,%eax
  8016ef:	29 d8                	sub    %ebx,%eax
  8016f1:	50                   	push   %eax
  8016f2:	89 d8                	mov    %ebx,%eax
  8016f4:	03 45 0c             	add    0xc(%ebp),%eax
  8016f7:	50                   	push   %eax
  8016f8:	57                   	push   %edi
  8016f9:	e8 45 ff ff ff       	call   801643 <read>
		if (m < 0)
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	85 c0                	test   %eax,%eax
  801703:	78 10                	js     801715 <readn+0x41>
			return m;
		if (m == 0)
  801705:	85 c0                	test   %eax,%eax
  801707:	74 0a                	je     801713 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801709:	01 c3                	add    %eax,%ebx
  80170b:	39 f3                	cmp    %esi,%ebx
  80170d:	72 db                	jb     8016ea <readn+0x16>
  80170f:	89 d8                	mov    %ebx,%eax
  801711:	eb 02                	jmp    801715 <readn+0x41>
  801713:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801715:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801718:	5b                   	pop    %ebx
  801719:	5e                   	pop    %esi
  80171a:	5f                   	pop    %edi
  80171b:	5d                   	pop    %ebp
  80171c:	c3                   	ret    

0080171d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	53                   	push   %ebx
  801721:	83 ec 14             	sub    $0x14,%esp
  801724:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801727:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172a:	50                   	push   %eax
  80172b:	53                   	push   %ebx
  80172c:	e8 ac fc ff ff       	call   8013dd <fd_lookup>
  801731:	83 c4 08             	add    $0x8,%esp
  801734:	89 c2                	mov    %eax,%edx
  801736:	85 c0                	test   %eax,%eax
  801738:	78 68                	js     8017a2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173a:	83 ec 08             	sub    $0x8,%esp
  80173d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801740:	50                   	push   %eax
  801741:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801744:	ff 30                	pushl  (%eax)
  801746:	e8 e8 fc ff ff       	call   801433 <dev_lookup>
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	85 c0                	test   %eax,%eax
  801750:	78 47                	js     801799 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801752:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801755:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801759:	75 21                	jne    80177c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80175b:	a1 04 44 80 00       	mov    0x804404,%eax
  801760:	8b 40 54             	mov    0x54(%eax),%eax
  801763:	83 ec 04             	sub    $0x4,%esp
  801766:	53                   	push   %ebx
  801767:	50                   	push   %eax
  801768:	68 18 29 80 00       	push   $0x802918
  80176d:	e8 57 ec ff ff       	call   8003c9 <cprintf>
		return -E_INVAL;
  801772:	83 c4 10             	add    $0x10,%esp
  801775:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80177a:	eb 26                	jmp    8017a2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80177c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80177f:	8b 52 0c             	mov    0xc(%edx),%edx
  801782:	85 d2                	test   %edx,%edx
  801784:	74 17                	je     80179d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801786:	83 ec 04             	sub    $0x4,%esp
  801789:	ff 75 10             	pushl  0x10(%ebp)
  80178c:	ff 75 0c             	pushl  0xc(%ebp)
  80178f:	50                   	push   %eax
  801790:	ff d2                	call   *%edx
  801792:	89 c2                	mov    %eax,%edx
  801794:	83 c4 10             	add    $0x10,%esp
  801797:	eb 09                	jmp    8017a2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801799:	89 c2                	mov    %eax,%edx
  80179b:	eb 05                	jmp    8017a2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80179d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017a2:	89 d0                	mov    %edx,%eax
  8017a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    

008017a9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017af:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017b2:	50                   	push   %eax
  8017b3:	ff 75 08             	pushl  0x8(%ebp)
  8017b6:	e8 22 fc ff ff       	call   8013dd <fd_lookup>
  8017bb:	83 c4 08             	add    $0x8,%esp
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 0e                	js     8017d0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    

008017d2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	53                   	push   %ebx
  8017d6:	83 ec 14             	sub    $0x14,%esp
  8017d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017df:	50                   	push   %eax
  8017e0:	53                   	push   %ebx
  8017e1:	e8 f7 fb ff ff       	call   8013dd <fd_lookup>
  8017e6:	83 c4 08             	add    $0x8,%esp
  8017e9:	89 c2                	mov    %eax,%edx
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 65                	js     801854 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ef:	83 ec 08             	sub    $0x8,%esp
  8017f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f5:	50                   	push   %eax
  8017f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f9:	ff 30                	pushl  (%eax)
  8017fb:	e8 33 fc ff ff       	call   801433 <dev_lookup>
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	85 c0                	test   %eax,%eax
  801805:	78 44                	js     80184b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801807:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80180e:	75 21                	jne    801831 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801810:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801815:	8b 40 54             	mov    0x54(%eax),%eax
  801818:	83 ec 04             	sub    $0x4,%esp
  80181b:	53                   	push   %ebx
  80181c:	50                   	push   %eax
  80181d:	68 d8 28 80 00       	push   $0x8028d8
  801822:	e8 a2 eb ff ff       	call   8003c9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80182f:	eb 23                	jmp    801854 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801831:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801834:	8b 52 18             	mov    0x18(%edx),%edx
  801837:	85 d2                	test   %edx,%edx
  801839:	74 14                	je     80184f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80183b:	83 ec 08             	sub    $0x8,%esp
  80183e:	ff 75 0c             	pushl  0xc(%ebp)
  801841:	50                   	push   %eax
  801842:	ff d2                	call   *%edx
  801844:	89 c2                	mov    %eax,%edx
  801846:	83 c4 10             	add    $0x10,%esp
  801849:	eb 09                	jmp    801854 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184b:	89 c2                	mov    %eax,%edx
  80184d:	eb 05                	jmp    801854 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80184f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801854:	89 d0                	mov    %edx,%eax
  801856:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801859:	c9                   	leave  
  80185a:	c3                   	ret    

0080185b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	53                   	push   %ebx
  80185f:	83 ec 14             	sub    $0x14,%esp
  801862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801865:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801868:	50                   	push   %eax
  801869:	ff 75 08             	pushl  0x8(%ebp)
  80186c:	e8 6c fb ff ff       	call   8013dd <fd_lookup>
  801871:	83 c4 08             	add    $0x8,%esp
  801874:	89 c2                	mov    %eax,%edx
  801876:	85 c0                	test   %eax,%eax
  801878:	78 58                	js     8018d2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187a:	83 ec 08             	sub    $0x8,%esp
  80187d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801880:	50                   	push   %eax
  801881:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801884:	ff 30                	pushl  (%eax)
  801886:	e8 a8 fb ff ff       	call   801433 <dev_lookup>
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 37                	js     8018c9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801892:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801895:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801899:	74 32                	je     8018cd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80189b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80189e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018a5:	00 00 00 
	stat->st_isdir = 0;
  8018a8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018af:	00 00 00 
	stat->st_dev = dev;
  8018b2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018b8:	83 ec 08             	sub    $0x8,%esp
  8018bb:	53                   	push   %ebx
  8018bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8018bf:	ff 50 14             	call   *0x14(%eax)
  8018c2:	89 c2                	mov    %eax,%edx
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	eb 09                	jmp    8018d2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c9:	89 c2                	mov    %eax,%edx
  8018cb:	eb 05                	jmp    8018d2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018d2:	89 d0                	mov    %edx,%eax
  8018d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d7:	c9                   	leave  
  8018d8:	c3                   	ret    

008018d9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	56                   	push   %esi
  8018dd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018de:	83 ec 08             	sub    $0x8,%esp
  8018e1:	6a 00                	push   $0x0
  8018e3:	ff 75 08             	pushl  0x8(%ebp)
  8018e6:	e8 e3 01 00 00       	call   801ace <open>
  8018eb:	89 c3                	mov    %eax,%ebx
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	78 1b                	js     80190f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018f4:	83 ec 08             	sub    $0x8,%esp
  8018f7:	ff 75 0c             	pushl  0xc(%ebp)
  8018fa:	50                   	push   %eax
  8018fb:	e8 5b ff ff ff       	call   80185b <fstat>
  801900:	89 c6                	mov    %eax,%esi
	close(fd);
  801902:	89 1c 24             	mov    %ebx,(%esp)
  801905:	e8 fd fb ff ff       	call   801507 <close>
	return r;
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	89 f0                	mov    %esi,%eax
}
  80190f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801912:	5b                   	pop    %ebx
  801913:	5e                   	pop    %esi
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	56                   	push   %esi
  80191a:	53                   	push   %ebx
  80191b:	89 c6                	mov    %eax,%esi
  80191d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80191f:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  801926:	75 12                	jne    80193a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801928:	83 ec 0c             	sub    $0xc,%esp
  80192b:	6a 01                	push   $0x1
  80192d:	e8 15 08 00 00       	call   802147 <ipc_find_env>
  801932:	a3 00 44 80 00       	mov    %eax,0x804400
  801937:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80193a:	6a 07                	push   $0x7
  80193c:	68 00 50 80 00       	push   $0x805000
  801941:	56                   	push   %esi
  801942:	ff 35 00 44 80 00    	pushl  0x804400
  801948:	e8 98 07 00 00       	call   8020e5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80194d:	83 c4 0c             	add    $0xc,%esp
  801950:	6a 00                	push   $0x0
  801952:	53                   	push   %ebx
  801953:	6a 00                	push   $0x0
  801955:	e8 13 07 00 00       	call   80206d <ipc_recv>
}
  80195a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195d:	5b                   	pop    %ebx
  80195e:	5e                   	pop    %esi
  80195f:	5d                   	pop    %ebp
  801960:	c3                   	ret    

00801961 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801967:	8b 45 08             	mov    0x8(%ebp),%eax
  80196a:	8b 40 0c             	mov    0xc(%eax),%eax
  80196d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801972:	8b 45 0c             	mov    0xc(%ebp),%eax
  801975:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80197a:	ba 00 00 00 00       	mov    $0x0,%edx
  80197f:	b8 02 00 00 00       	mov    $0x2,%eax
  801984:	e8 8d ff ff ff       	call   801916 <fsipc>
}
  801989:	c9                   	leave  
  80198a:	c3                   	ret    

0080198b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801991:	8b 45 08             	mov    0x8(%ebp),%eax
  801994:	8b 40 0c             	mov    0xc(%eax),%eax
  801997:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80199c:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a1:	b8 06 00 00 00       	mov    $0x6,%eax
  8019a6:	e8 6b ff ff ff       	call   801916 <fsipc>
}
  8019ab:	c9                   	leave  
  8019ac:	c3                   	ret    

008019ad <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	53                   	push   %ebx
  8019b1:	83 ec 04             	sub    $0x4,%esp
  8019b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8019bd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c7:	b8 05 00 00 00       	mov    $0x5,%eax
  8019cc:	e8 45 ff ff ff       	call   801916 <fsipc>
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	78 2c                	js     801a01 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019d5:	83 ec 08             	sub    $0x8,%esp
  8019d8:	68 00 50 80 00       	push   $0x805000
  8019dd:	53                   	push   %ebx
  8019de:	e8 5e f0 ff ff       	call   800a41 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019e3:	a1 80 50 80 00       	mov    0x805080,%eax
  8019e8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019ee:	a1 84 50 80 00       	mov    0x805084,%eax
  8019f3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019f9:	83 c4 10             	add    $0x10,%esp
  8019fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a04:	c9                   	leave  
  801a05:	c3                   	ret    

00801a06 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	83 ec 0c             	sub    $0xc,%esp
  801a0c:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a0f:	8b 55 08             	mov    0x8(%ebp),%edx
  801a12:	8b 52 0c             	mov    0xc(%edx),%edx
  801a15:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a1b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a20:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a25:	0f 47 c2             	cmova  %edx,%eax
  801a28:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a2d:	50                   	push   %eax
  801a2e:	ff 75 0c             	pushl  0xc(%ebp)
  801a31:	68 08 50 80 00       	push   $0x805008
  801a36:	e8 98 f1 ff ff       	call   800bd3 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a40:	b8 04 00 00 00       	mov    $0x4,%eax
  801a45:	e8 cc fe ff ff       	call   801916 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a4a:	c9                   	leave  
  801a4b:	c3                   	ret    

00801a4c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	56                   	push   %esi
  801a50:	53                   	push   %ebx
  801a51:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a54:	8b 45 08             	mov    0x8(%ebp),%eax
  801a57:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a5f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a65:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6a:	b8 03 00 00 00       	mov    $0x3,%eax
  801a6f:	e8 a2 fe ff ff       	call   801916 <fsipc>
  801a74:	89 c3                	mov    %eax,%ebx
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 4b                	js     801ac5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a7a:	39 c6                	cmp    %eax,%esi
  801a7c:	73 16                	jae    801a94 <devfile_read+0x48>
  801a7e:	68 48 29 80 00       	push   $0x802948
  801a83:	68 4f 29 80 00       	push   $0x80294f
  801a88:	6a 7c                	push   $0x7c
  801a8a:	68 64 29 80 00       	push   $0x802964
  801a8f:	e8 5c e8 ff ff       	call   8002f0 <_panic>
	assert(r <= PGSIZE);
  801a94:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a99:	7e 16                	jle    801ab1 <devfile_read+0x65>
  801a9b:	68 6f 29 80 00       	push   $0x80296f
  801aa0:	68 4f 29 80 00       	push   $0x80294f
  801aa5:	6a 7d                	push   $0x7d
  801aa7:	68 64 29 80 00       	push   $0x802964
  801aac:	e8 3f e8 ff ff       	call   8002f0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ab1:	83 ec 04             	sub    $0x4,%esp
  801ab4:	50                   	push   %eax
  801ab5:	68 00 50 80 00       	push   $0x805000
  801aba:	ff 75 0c             	pushl  0xc(%ebp)
  801abd:	e8 11 f1 ff ff       	call   800bd3 <memmove>
	return r;
  801ac2:	83 c4 10             	add    $0x10,%esp
}
  801ac5:	89 d8                	mov    %ebx,%eax
  801ac7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aca:	5b                   	pop    %ebx
  801acb:	5e                   	pop    %esi
  801acc:	5d                   	pop    %ebp
  801acd:	c3                   	ret    

00801ace <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	53                   	push   %ebx
  801ad2:	83 ec 20             	sub    $0x20,%esp
  801ad5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ad8:	53                   	push   %ebx
  801ad9:	e8 2a ef ff ff       	call   800a08 <strlen>
  801ade:	83 c4 10             	add    $0x10,%esp
  801ae1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ae6:	7f 67                	jg     801b4f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ae8:	83 ec 0c             	sub    $0xc,%esp
  801aeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aee:	50                   	push   %eax
  801aef:	e8 9a f8 ff ff       	call   80138e <fd_alloc>
  801af4:	83 c4 10             	add    $0x10,%esp
		return r;
  801af7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801af9:	85 c0                	test   %eax,%eax
  801afb:	78 57                	js     801b54 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801afd:	83 ec 08             	sub    $0x8,%esp
  801b00:	53                   	push   %ebx
  801b01:	68 00 50 80 00       	push   $0x805000
  801b06:	e8 36 ef ff ff       	call   800a41 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b13:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b16:	b8 01 00 00 00       	mov    $0x1,%eax
  801b1b:	e8 f6 fd ff ff       	call   801916 <fsipc>
  801b20:	89 c3                	mov    %eax,%ebx
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	85 c0                	test   %eax,%eax
  801b27:	79 14                	jns    801b3d <open+0x6f>
		fd_close(fd, 0);
  801b29:	83 ec 08             	sub    $0x8,%esp
  801b2c:	6a 00                	push   $0x0
  801b2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b31:	e8 50 f9 ff ff       	call   801486 <fd_close>
		return r;
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	89 da                	mov    %ebx,%edx
  801b3b:	eb 17                	jmp    801b54 <open+0x86>
	}

	return fd2num(fd);
  801b3d:	83 ec 0c             	sub    $0xc,%esp
  801b40:	ff 75 f4             	pushl  -0xc(%ebp)
  801b43:	e8 1f f8 ff ff       	call   801367 <fd2num>
  801b48:	89 c2                	mov    %eax,%edx
  801b4a:	83 c4 10             	add    $0x10,%esp
  801b4d:	eb 05                	jmp    801b54 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b4f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b54:	89 d0                	mov    %edx,%eax
  801b56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b61:	ba 00 00 00 00       	mov    $0x0,%edx
  801b66:	b8 08 00 00 00       	mov    $0x8,%eax
  801b6b:	e8 a6 fd ff ff       	call   801916 <fsipc>
}
  801b70:	c9                   	leave  
  801b71:	c3                   	ret    

00801b72 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801b72:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801b76:	7e 37                	jle    801baf <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	53                   	push   %ebx
  801b7c:	83 ec 08             	sub    $0x8,%esp
  801b7f:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801b81:	ff 70 04             	pushl  0x4(%eax)
  801b84:	8d 40 10             	lea    0x10(%eax),%eax
  801b87:	50                   	push   %eax
  801b88:	ff 33                	pushl  (%ebx)
  801b8a:	e8 8e fb ff ff       	call   80171d <write>
		if (result > 0)
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	85 c0                	test   %eax,%eax
  801b94:	7e 03                	jle    801b99 <writebuf+0x27>
			b->result += result;
  801b96:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801b99:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b9c:	74 0d                	je     801bab <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba5:	0f 4f c2             	cmovg  %edx,%eax
  801ba8:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801bab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bae:	c9                   	leave  
  801baf:	f3 c3                	repz ret 

00801bb1 <putch>:

static void
putch(int ch, void *thunk)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	53                   	push   %ebx
  801bb5:	83 ec 04             	sub    $0x4,%esp
  801bb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801bbb:	8b 53 04             	mov    0x4(%ebx),%edx
  801bbe:	8d 42 01             	lea    0x1(%edx),%eax
  801bc1:	89 43 04             	mov    %eax,0x4(%ebx)
  801bc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc7:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801bcb:	3d 00 01 00 00       	cmp    $0x100,%eax
  801bd0:	75 0e                	jne    801be0 <putch+0x2f>
		writebuf(b);
  801bd2:	89 d8                	mov    %ebx,%eax
  801bd4:	e8 99 ff ff ff       	call   801b72 <writebuf>
		b->idx = 0;
  801bd9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801be0:	83 c4 04             	add    $0x4,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5d                   	pop    %ebp
  801be5:	c3                   	ret    

00801be6 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801bef:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf2:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801bf8:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801bff:	00 00 00 
	b.result = 0;
  801c02:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801c09:	00 00 00 
	b.error = 1;
  801c0c:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801c13:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801c16:	ff 75 10             	pushl  0x10(%ebp)
  801c19:	ff 75 0c             	pushl  0xc(%ebp)
  801c1c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c22:	50                   	push   %eax
  801c23:	68 b1 1b 80 00       	push   $0x801bb1
  801c28:	e8 d3 e8 ff ff       	call   800500 <vprintfmt>
	if (b.idx > 0)
  801c2d:	83 c4 10             	add    $0x10,%esp
  801c30:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801c37:	7e 0b                	jle    801c44 <vfprintf+0x5e>
		writebuf(&b);
  801c39:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c3f:	e8 2e ff ff ff       	call   801b72 <writebuf>

	return (b.result ? b.result : b.error);
  801c44:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801c53:	c9                   	leave  
  801c54:	c3                   	ret    

00801c55 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c5b:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801c5e:	50                   	push   %eax
  801c5f:	ff 75 0c             	pushl  0xc(%ebp)
  801c62:	ff 75 08             	pushl  0x8(%ebp)
  801c65:	e8 7c ff ff ff       	call   801be6 <vfprintf>
	va_end(ap);

	return cnt;
}
  801c6a:	c9                   	leave  
  801c6b:	c3                   	ret    

00801c6c <printf>:

int
printf(const char *fmt, ...)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c72:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801c75:	50                   	push   %eax
  801c76:	ff 75 08             	pushl  0x8(%ebp)
  801c79:	6a 01                	push   $0x1
  801c7b:	e8 66 ff ff ff       	call   801be6 <vfprintf>
	va_end(ap);

	return cnt;
}
  801c80:	c9                   	leave  
  801c81:	c3                   	ret    

00801c82 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	56                   	push   %esi
  801c86:	53                   	push   %ebx
  801c87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c8a:	83 ec 0c             	sub    $0xc,%esp
  801c8d:	ff 75 08             	pushl  0x8(%ebp)
  801c90:	e8 e2 f6 ff ff       	call   801377 <fd2data>
  801c95:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c97:	83 c4 08             	add    $0x8,%esp
  801c9a:	68 7b 29 80 00       	push   $0x80297b
  801c9f:	53                   	push   %ebx
  801ca0:	e8 9c ed ff ff       	call   800a41 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ca5:	8b 46 04             	mov    0x4(%esi),%eax
  801ca8:	2b 06                	sub    (%esi),%eax
  801caa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cb0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cb7:	00 00 00 
	stat->st_dev = &devpipe;
  801cba:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801cc1:	30 80 00 
	return 0;
}
  801cc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ccc:	5b                   	pop    %ebx
  801ccd:	5e                   	pop    %esi
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    

00801cd0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 0c             	sub    $0xc,%esp
  801cd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cda:	53                   	push   %ebx
  801cdb:	6a 00                	push   $0x0
  801cdd:	e8 e7 f1 ff ff       	call   800ec9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ce2:	89 1c 24             	mov    %ebx,(%esp)
  801ce5:	e8 8d f6 ff ff       	call   801377 <fd2data>
  801cea:	83 c4 08             	add    $0x8,%esp
  801ced:	50                   	push   %eax
  801cee:	6a 00                	push   $0x0
  801cf0:	e8 d4 f1 ff ff       	call   800ec9 <sys_page_unmap>
}
  801cf5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	57                   	push   %edi
  801cfe:	56                   	push   %esi
  801cff:	53                   	push   %ebx
  801d00:	83 ec 1c             	sub    $0x1c,%esp
  801d03:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d06:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d08:	a1 04 44 80 00       	mov    0x804404,%eax
  801d0d:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d10:	83 ec 0c             	sub    $0xc,%esp
  801d13:	ff 75 e0             	pushl  -0x20(%ebp)
  801d16:	e8 6c 04 00 00       	call   802187 <pageref>
  801d1b:	89 c3                	mov    %eax,%ebx
  801d1d:	89 3c 24             	mov    %edi,(%esp)
  801d20:	e8 62 04 00 00       	call   802187 <pageref>
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	39 c3                	cmp    %eax,%ebx
  801d2a:	0f 94 c1             	sete   %cl
  801d2d:	0f b6 c9             	movzbl %cl,%ecx
  801d30:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d33:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801d39:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801d3c:	39 ce                	cmp    %ecx,%esi
  801d3e:	74 1b                	je     801d5b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d40:	39 c3                	cmp    %eax,%ebx
  801d42:	75 c4                	jne    801d08 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d44:	8b 42 64             	mov    0x64(%edx),%eax
  801d47:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d4a:	50                   	push   %eax
  801d4b:	56                   	push   %esi
  801d4c:	68 82 29 80 00       	push   $0x802982
  801d51:	e8 73 e6 ff ff       	call   8003c9 <cprintf>
  801d56:	83 c4 10             	add    $0x10,%esp
  801d59:	eb ad                	jmp    801d08 <_pipeisclosed+0xe>
	}
}
  801d5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d61:	5b                   	pop    %ebx
  801d62:	5e                   	pop    %esi
  801d63:	5f                   	pop    %edi
  801d64:	5d                   	pop    %ebp
  801d65:	c3                   	ret    

00801d66 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	57                   	push   %edi
  801d6a:	56                   	push   %esi
  801d6b:	53                   	push   %ebx
  801d6c:	83 ec 28             	sub    $0x28,%esp
  801d6f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d72:	56                   	push   %esi
  801d73:	e8 ff f5 ff ff       	call   801377 <fd2data>
  801d78:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d7a:	83 c4 10             	add    $0x10,%esp
  801d7d:	bf 00 00 00 00       	mov    $0x0,%edi
  801d82:	eb 4b                	jmp    801dcf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d84:	89 da                	mov    %ebx,%edx
  801d86:	89 f0                	mov    %esi,%eax
  801d88:	e8 6d ff ff ff       	call   801cfa <_pipeisclosed>
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	75 48                	jne    801dd9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d91:	e8 8f f0 ff ff       	call   800e25 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d96:	8b 43 04             	mov    0x4(%ebx),%eax
  801d99:	8b 0b                	mov    (%ebx),%ecx
  801d9b:	8d 51 20             	lea    0x20(%ecx),%edx
  801d9e:	39 d0                	cmp    %edx,%eax
  801da0:	73 e2                	jae    801d84 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801da5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801da9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dac:	89 c2                	mov    %eax,%edx
  801dae:	c1 fa 1f             	sar    $0x1f,%edx
  801db1:	89 d1                	mov    %edx,%ecx
  801db3:	c1 e9 1b             	shr    $0x1b,%ecx
  801db6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801db9:	83 e2 1f             	and    $0x1f,%edx
  801dbc:	29 ca                	sub    %ecx,%edx
  801dbe:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801dc2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801dc6:	83 c0 01             	add    $0x1,%eax
  801dc9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dcc:	83 c7 01             	add    $0x1,%edi
  801dcf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dd2:	75 c2                	jne    801d96 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801dd4:	8b 45 10             	mov    0x10(%ebp),%eax
  801dd7:	eb 05                	jmp    801dde <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dd9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de1:	5b                   	pop    %ebx
  801de2:	5e                   	pop    %esi
  801de3:	5f                   	pop    %edi
  801de4:	5d                   	pop    %ebp
  801de5:	c3                   	ret    

00801de6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	57                   	push   %edi
  801dea:	56                   	push   %esi
  801deb:	53                   	push   %ebx
  801dec:	83 ec 18             	sub    $0x18,%esp
  801def:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801df2:	57                   	push   %edi
  801df3:	e8 7f f5 ff ff       	call   801377 <fd2data>
  801df8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e02:	eb 3d                	jmp    801e41 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e04:	85 db                	test   %ebx,%ebx
  801e06:	74 04                	je     801e0c <devpipe_read+0x26>
				return i;
  801e08:	89 d8                	mov    %ebx,%eax
  801e0a:	eb 44                	jmp    801e50 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e0c:	89 f2                	mov    %esi,%edx
  801e0e:	89 f8                	mov    %edi,%eax
  801e10:	e8 e5 fe ff ff       	call   801cfa <_pipeisclosed>
  801e15:	85 c0                	test   %eax,%eax
  801e17:	75 32                	jne    801e4b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e19:	e8 07 f0 ff ff       	call   800e25 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e1e:	8b 06                	mov    (%esi),%eax
  801e20:	3b 46 04             	cmp    0x4(%esi),%eax
  801e23:	74 df                	je     801e04 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e25:	99                   	cltd   
  801e26:	c1 ea 1b             	shr    $0x1b,%edx
  801e29:	01 d0                	add    %edx,%eax
  801e2b:	83 e0 1f             	and    $0x1f,%eax
  801e2e:	29 d0                	sub    %edx,%eax
  801e30:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e38:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e3b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e3e:	83 c3 01             	add    $0x1,%ebx
  801e41:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e44:	75 d8                	jne    801e1e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e46:	8b 45 10             	mov    0x10(%ebp),%eax
  801e49:	eb 05                	jmp    801e50 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e4b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e53:	5b                   	pop    %ebx
  801e54:	5e                   	pop    %esi
  801e55:	5f                   	pop    %edi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    

00801e58 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	56                   	push   %esi
  801e5c:	53                   	push   %ebx
  801e5d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e63:	50                   	push   %eax
  801e64:	e8 25 f5 ff ff       	call   80138e <fd_alloc>
  801e69:	83 c4 10             	add    $0x10,%esp
  801e6c:	89 c2                	mov    %eax,%edx
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	0f 88 2c 01 00 00    	js     801fa2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e76:	83 ec 04             	sub    $0x4,%esp
  801e79:	68 07 04 00 00       	push   $0x407
  801e7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e81:	6a 00                	push   $0x0
  801e83:	e8 bc ef ff ff       	call   800e44 <sys_page_alloc>
  801e88:	83 c4 10             	add    $0x10,%esp
  801e8b:	89 c2                	mov    %eax,%edx
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	0f 88 0d 01 00 00    	js     801fa2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e95:	83 ec 0c             	sub    $0xc,%esp
  801e98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e9b:	50                   	push   %eax
  801e9c:	e8 ed f4 ff ff       	call   80138e <fd_alloc>
  801ea1:	89 c3                	mov    %eax,%ebx
  801ea3:	83 c4 10             	add    $0x10,%esp
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	0f 88 e2 00 00 00    	js     801f90 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eae:	83 ec 04             	sub    $0x4,%esp
  801eb1:	68 07 04 00 00       	push   $0x407
  801eb6:	ff 75 f0             	pushl  -0x10(%ebp)
  801eb9:	6a 00                	push   $0x0
  801ebb:	e8 84 ef ff ff       	call   800e44 <sys_page_alloc>
  801ec0:	89 c3                	mov    %eax,%ebx
  801ec2:	83 c4 10             	add    $0x10,%esp
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	0f 88 c3 00 00 00    	js     801f90 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ecd:	83 ec 0c             	sub    $0xc,%esp
  801ed0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed3:	e8 9f f4 ff ff       	call   801377 <fd2data>
  801ed8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eda:	83 c4 0c             	add    $0xc,%esp
  801edd:	68 07 04 00 00       	push   $0x407
  801ee2:	50                   	push   %eax
  801ee3:	6a 00                	push   $0x0
  801ee5:	e8 5a ef ff ff       	call   800e44 <sys_page_alloc>
  801eea:	89 c3                	mov    %eax,%ebx
  801eec:	83 c4 10             	add    $0x10,%esp
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	0f 88 89 00 00 00    	js     801f80 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef7:	83 ec 0c             	sub    $0xc,%esp
  801efa:	ff 75 f0             	pushl  -0x10(%ebp)
  801efd:	e8 75 f4 ff ff       	call   801377 <fd2data>
  801f02:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f09:	50                   	push   %eax
  801f0a:	6a 00                	push   $0x0
  801f0c:	56                   	push   %esi
  801f0d:	6a 00                	push   $0x0
  801f0f:	e8 73 ef ff ff       	call   800e87 <sys_page_map>
  801f14:	89 c3                	mov    %eax,%ebx
  801f16:	83 c4 20             	add    $0x20,%esp
  801f19:	85 c0                	test   %eax,%eax
  801f1b:	78 55                	js     801f72 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f1d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f26:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f32:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f3b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f40:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f47:	83 ec 0c             	sub    $0xc,%esp
  801f4a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f4d:	e8 15 f4 ff ff       	call   801367 <fd2num>
  801f52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f55:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f57:	83 c4 04             	add    $0x4,%esp
  801f5a:	ff 75 f0             	pushl  -0x10(%ebp)
  801f5d:	e8 05 f4 ff ff       	call   801367 <fd2num>
  801f62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f65:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f68:	83 c4 10             	add    $0x10,%esp
  801f6b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f70:	eb 30                	jmp    801fa2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f72:	83 ec 08             	sub    $0x8,%esp
  801f75:	56                   	push   %esi
  801f76:	6a 00                	push   $0x0
  801f78:	e8 4c ef ff ff       	call   800ec9 <sys_page_unmap>
  801f7d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f80:	83 ec 08             	sub    $0x8,%esp
  801f83:	ff 75 f0             	pushl  -0x10(%ebp)
  801f86:	6a 00                	push   $0x0
  801f88:	e8 3c ef ff ff       	call   800ec9 <sys_page_unmap>
  801f8d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f90:	83 ec 08             	sub    $0x8,%esp
  801f93:	ff 75 f4             	pushl  -0xc(%ebp)
  801f96:	6a 00                	push   $0x0
  801f98:	e8 2c ef ff ff       	call   800ec9 <sys_page_unmap>
  801f9d:	83 c4 10             	add    $0x10,%esp
  801fa0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fa2:	89 d0                	mov    %edx,%eax
  801fa4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa7:	5b                   	pop    %ebx
  801fa8:	5e                   	pop    %esi
  801fa9:	5d                   	pop    %ebp
  801faa:	c3                   	ret    

00801fab <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb4:	50                   	push   %eax
  801fb5:	ff 75 08             	pushl  0x8(%ebp)
  801fb8:	e8 20 f4 ff ff       	call   8013dd <fd_lookup>
  801fbd:	83 c4 10             	add    $0x10,%esp
  801fc0:	85 c0                	test   %eax,%eax
  801fc2:	78 18                	js     801fdc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fc4:	83 ec 0c             	sub    $0xc,%esp
  801fc7:	ff 75 f4             	pushl  -0xc(%ebp)
  801fca:	e8 a8 f3 ff ff       	call   801377 <fd2data>
	return _pipeisclosed(fd, p);
  801fcf:	89 c2                	mov    %eax,%edx
  801fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd4:	e8 21 fd ff ff       	call   801cfa <_pipeisclosed>
  801fd9:	83 c4 10             	add    $0x10,%esp
}
  801fdc:	c9                   	leave  
  801fdd:	c3                   	ret    

00801fde <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fe4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801feb:	75 2a                	jne    802017 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801fed:	83 ec 04             	sub    $0x4,%esp
  801ff0:	6a 07                	push   $0x7
  801ff2:	68 00 f0 bf ee       	push   $0xeebff000
  801ff7:	6a 00                	push   $0x0
  801ff9:	e8 46 ee ff ff       	call   800e44 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	85 c0                	test   %eax,%eax
  802003:	79 12                	jns    802017 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802005:	50                   	push   %eax
  802006:	68 0b 28 80 00       	push   $0x80280b
  80200b:	6a 23                	push   $0x23
  80200d:	68 9a 29 80 00       	push   $0x80299a
  802012:	e8 d9 e2 ff ff       	call   8002f0 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802017:	8b 45 08             	mov    0x8(%ebp),%eax
  80201a:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80201f:	83 ec 08             	sub    $0x8,%esp
  802022:	68 49 20 80 00       	push   $0x802049
  802027:	6a 00                	push   $0x0
  802029:	e8 61 ef ff ff       	call   800f8f <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	85 c0                	test   %eax,%eax
  802033:	79 12                	jns    802047 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802035:	50                   	push   %eax
  802036:	68 0b 28 80 00       	push   $0x80280b
  80203b:	6a 2c                	push   $0x2c
  80203d:	68 9a 29 80 00       	push   $0x80299a
  802042:	e8 a9 e2 ff ff       	call   8002f0 <_panic>
	}
}
  802047:	c9                   	leave  
  802048:	c3                   	ret    

00802049 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802049:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80204a:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80204f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802051:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802054:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802058:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80205d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802061:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802063:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802066:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802067:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80206a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80206b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80206c:	c3                   	ret    

0080206d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	56                   	push   %esi
  802071:	53                   	push   %ebx
  802072:	8b 75 08             	mov    0x8(%ebp),%esi
  802075:	8b 45 0c             	mov    0xc(%ebp),%eax
  802078:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80207b:	85 c0                	test   %eax,%eax
  80207d:	75 12                	jne    802091 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80207f:	83 ec 0c             	sub    $0xc,%esp
  802082:	68 00 00 c0 ee       	push   $0xeec00000
  802087:	e8 68 ef ff ff       	call   800ff4 <sys_ipc_recv>
  80208c:	83 c4 10             	add    $0x10,%esp
  80208f:	eb 0c                	jmp    80209d <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802091:	83 ec 0c             	sub    $0xc,%esp
  802094:	50                   	push   %eax
  802095:	e8 5a ef ff ff       	call   800ff4 <sys_ipc_recv>
  80209a:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80209d:	85 f6                	test   %esi,%esi
  80209f:	0f 95 c1             	setne  %cl
  8020a2:	85 db                	test   %ebx,%ebx
  8020a4:	0f 95 c2             	setne  %dl
  8020a7:	84 d1                	test   %dl,%cl
  8020a9:	74 09                	je     8020b4 <ipc_recv+0x47>
  8020ab:	89 c2                	mov    %eax,%edx
  8020ad:	c1 ea 1f             	shr    $0x1f,%edx
  8020b0:	84 d2                	test   %dl,%dl
  8020b2:	75 2a                	jne    8020de <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020b4:	85 f6                	test   %esi,%esi
  8020b6:	74 0d                	je     8020c5 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020b8:	a1 04 44 80 00       	mov    0x804404,%eax
  8020bd:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8020c3:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020c5:	85 db                	test   %ebx,%ebx
  8020c7:	74 0d                	je     8020d6 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020c9:	a1 04 44 80 00       	mov    0x804404,%eax
  8020ce:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  8020d4:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020d6:	a1 04 44 80 00       	mov    0x804404,%eax
  8020db:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  8020de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020e1:	5b                   	pop    %ebx
  8020e2:	5e                   	pop    %esi
  8020e3:	5d                   	pop    %ebp
  8020e4:	c3                   	ret    

008020e5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020e5:	55                   	push   %ebp
  8020e6:	89 e5                	mov    %esp,%ebp
  8020e8:	57                   	push   %edi
  8020e9:	56                   	push   %esi
  8020ea:	53                   	push   %ebx
  8020eb:	83 ec 0c             	sub    $0xc,%esp
  8020ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020f7:	85 db                	test   %ebx,%ebx
  8020f9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020fe:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802101:	ff 75 14             	pushl  0x14(%ebp)
  802104:	53                   	push   %ebx
  802105:	56                   	push   %esi
  802106:	57                   	push   %edi
  802107:	e8 c5 ee ff ff       	call   800fd1 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80210c:	89 c2                	mov    %eax,%edx
  80210e:	c1 ea 1f             	shr    $0x1f,%edx
  802111:	83 c4 10             	add    $0x10,%esp
  802114:	84 d2                	test   %dl,%dl
  802116:	74 17                	je     80212f <ipc_send+0x4a>
  802118:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80211b:	74 12                	je     80212f <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80211d:	50                   	push   %eax
  80211e:	68 a8 29 80 00       	push   $0x8029a8
  802123:	6a 47                	push   $0x47
  802125:	68 b6 29 80 00       	push   $0x8029b6
  80212a:	e8 c1 e1 ff ff       	call   8002f0 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80212f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802132:	75 07                	jne    80213b <ipc_send+0x56>
			sys_yield();
  802134:	e8 ec ec ff ff       	call   800e25 <sys_yield>
  802139:	eb c6                	jmp    802101 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80213b:	85 c0                	test   %eax,%eax
  80213d:	75 c2                	jne    802101 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80213f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802142:	5b                   	pop    %ebx
  802143:	5e                   	pop    %esi
  802144:	5f                   	pop    %edi
  802145:	5d                   	pop    %ebp
  802146:	c3                   	ret    

00802147 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802147:	55                   	push   %ebp
  802148:	89 e5                	mov    %esp,%ebp
  80214a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80214d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802152:	89 c2                	mov    %eax,%edx
  802154:	c1 e2 07             	shl    $0x7,%edx
  802157:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  80215e:	8b 52 5c             	mov    0x5c(%edx),%edx
  802161:	39 ca                	cmp    %ecx,%edx
  802163:	75 11                	jne    802176 <ipc_find_env+0x2f>
			return envs[i].env_id;
  802165:	89 c2                	mov    %eax,%edx
  802167:	c1 e2 07             	shl    $0x7,%edx
  80216a:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  802171:	8b 40 54             	mov    0x54(%eax),%eax
  802174:	eb 0f                	jmp    802185 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802176:	83 c0 01             	add    $0x1,%eax
  802179:	3d 00 04 00 00       	cmp    $0x400,%eax
  80217e:	75 d2                	jne    802152 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802180:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802185:	5d                   	pop    %ebp
  802186:	c3                   	ret    

00802187 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802187:	55                   	push   %ebp
  802188:	89 e5                	mov    %esp,%ebp
  80218a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80218d:	89 d0                	mov    %edx,%eax
  80218f:	c1 e8 16             	shr    $0x16,%eax
  802192:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802199:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80219e:	f6 c1 01             	test   $0x1,%cl
  8021a1:	74 1d                	je     8021c0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021a3:	c1 ea 0c             	shr    $0xc,%edx
  8021a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021ad:	f6 c2 01             	test   $0x1,%dl
  8021b0:	74 0e                	je     8021c0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021b2:	c1 ea 0c             	shr    $0xc,%edx
  8021b5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021bc:	ef 
  8021bd:	0f b7 c0             	movzwl %ax,%eax
}
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	66 90                	xchg   %ax,%ax
  8021c4:	66 90                	xchg   %ax,%ax
  8021c6:	66 90                	xchg   %ax,%ax
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <__udivdi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e7:	85 f6                	test   %esi,%esi
  8021e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021ed:	89 ca                	mov    %ecx,%edx
  8021ef:	89 f8                	mov    %edi,%eax
  8021f1:	75 3d                	jne    802230 <__udivdi3+0x60>
  8021f3:	39 cf                	cmp    %ecx,%edi
  8021f5:	0f 87 c5 00 00 00    	ja     8022c0 <__udivdi3+0xf0>
  8021fb:	85 ff                	test   %edi,%edi
  8021fd:	89 fd                	mov    %edi,%ebp
  8021ff:	75 0b                	jne    80220c <__udivdi3+0x3c>
  802201:	b8 01 00 00 00       	mov    $0x1,%eax
  802206:	31 d2                	xor    %edx,%edx
  802208:	f7 f7                	div    %edi
  80220a:	89 c5                	mov    %eax,%ebp
  80220c:	89 c8                	mov    %ecx,%eax
  80220e:	31 d2                	xor    %edx,%edx
  802210:	f7 f5                	div    %ebp
  802212:	89 c1                	mov    %eax,%ecx
  802214:	89 d8                	mov    %ebx,%eax
  802216:	89 cf                	mov    %ecx,%edi
  802218:	f7 f5                	div    %ebp
  80221a:	89 c3                	mov    %eax,%ebx
  80221c:	89 d8                	mov    %ebx,%eax
  80221e:	89 fa                	mov    %edi,%edx
  802220:	83 c4 1c             	add    $0x1c,%esp
  802223:	5b                   	pop    %ebx
  802224:	5e                   	pop    %esi
  802225:	5f                   	pop    %edi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    
  802228:	90                   	nop
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	39 ce                	cmp    %ecx,%esi
  802232:	77 74                	ja     8022a8 <__udivdi3+0xd8>
  802234:	0f bd fe             	bsr    %esi,%edi
  802237:	83 f7 1f             	xor    $0x1f,%edi
  80223a:	0f 84 98 00 00 00    	je     8022d8 <__udivdi3+0x108>
  802240:	bb 20 00 00 00       	mov    $0x20,%ebx
  802245:	89 f9                	mov    %edi,%ecx
  802247:	89 c5                	mov    %eax,%ebp
  802249:	29 fb                	sub    %edi,%ebx
  80224b:	d3 e6                	shl    %cl,%esi
  80224d:	89 d9                	mov    %ebx,%ecx
  80224f:	d3 ed                	shr    %cl,%ebp
  802251:	89 f9                	mov    %edi,%ecx
  802253:	d3 e0                	shl    %cl,%eax
  802255:	09 ee                	or     %ebp,%esi
  802257:	89 d9                	mov    %ebx,%ecx
  802259:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80225d:	89 d5                	mov    %edx,%ebp
  80225f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802263:	d3 ed                	shr    %cl,%ebp
  802265:	89 f9                	mov    %edi,%ecx
  802267:	d3 e2                	shl    %cl,%edx
  802269:	89 d9                	mov    %ebx,%ecx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	09 c2                	or     %eax,%edx
  80226f:	89 d0                	mov    %edx,%eax
  802271:	89 ea                	mov    %ebp,%edx
  802273:	f7 f6                	div    %esi
  802275:	89 d5                	mov    %edx,%ebp
  802277:	89 c3                	mov    %eax,%ebx
  802279:	f7 64 24 0c          	mull   0xc(%esp)
  80227d:	39 d5                	cmp    %edx,%ebp
  80227f:	72 10                	jb     802291 <__udivdi3+0xc1>
  802281:	8b 74 24 08          	mov    0x8(%esp),%esi
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e6                	shl    %cl,%esi
  802289:	39 c6                	cmp    %eax,%esi
  80228b:	73 07                	jae    802294 <__udivdi3+0xc4>
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	75 03                	jne    802294 <__udivdi3+0xc4>
  802291:	83 eb 01             	sub    $0x1,%ebx
  802294:	31 ff                	xor    %edi,%edi
  802296:	89 d8                	mov    %ebx,%eax
  802298:	89 fa                	mov    %edi,%edx
  80229a:	83 c4 1c             	add    $0x1c,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	31 ff                	xor    %edi,%edi
  8022aa:	31 db                	xor    %ebx,%ebx
  8022ac:	89 d8                	mov    %ebx,%eax
  8022ae:	89 fa                	mov    %edi,%edx
  8022b0:	83 c4 1c             	add    $0x1c,%esp
  8022b3:	5b                   	pop    %ebx
  8022b4:	5e                   	pop    %esi
  8022b5:	5f                   	pop    %edi
  8022b6:	5d                   	pop    %ebp
  8022b7:	c3                   	ret    
  8022b8:	90                   	nop
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	89 d8                	mov    %ebx,%eax
  8022c2:	f7 f7                	div    %edi
  8022c4:	31 ff                	xor    %edi,%edi
  8022c6:	89 c3                	mov    %eax,%ebx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 fa                	mov    %edi,%edx
  8022cc:	83 c4 1c             	add    $0x1c,%esp
  8022cf:	5b                   	pop    %ebx
  8022d0:	5e                   	pop    %esi
  8022d1:	5f                   	pop    %edi
  8022d2:	5d                   	pop    %ebp
  8022d3:	c3                   	ret    
  8022d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	39 ce                	cmp    %ecx,%esi
  8022da:	72 0c                	jb     8022e8 <__udivdi3+0x118>
  8022dc:	31 db                	xor    %ebx,%ebx
  8022de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022e2:	0f 87 34 ff ff ff    	ja     80221c <__udivdi3+0x4c>
  8022e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022ed:	e9 2a ff ff ff       	jmp    80221c <__udivdi3+0x4c>
  8022f2:	66 90                	xchg   %ax,%ax
  8022f4:	66 90                	xchg   %ax,%ax
  8022f6:	66 90                	xchg   %ax,%ax
  8022f8:	66 90                	xchg   %ax,%ax
  8022fa:	66 90                	xchg   %ax,%ax
  8022fc:	66 90                	xchg   %ax,%ax
  8022fe:	66 90                	xchg   %ax,%ax

00802300 <__umoddi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80230b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80230f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 d2                	test   %edx,%edx
  802319:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80231d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802321:	89 f3                	mov    %esi,%ebx
  802323:	89 3c 24             	mov    %edi,(%esp)
  802326:	89 74 24 04          	mov    %esi,0x4(%esp)
  80232a:	75 1c                	jne    802348 <__umoddi3+0x48>
  80232c:	39 f7                	cmp    %esi,%edi
  80232e:	76 50                	jbe    802380 <__umoddi3+0x80>
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	f7 f7                	div    %edi
  802336:	89 d0                	mov    %edx,%eax
  802338:	31 d2                	xor    %edx,%edx
  80233a:	83 c4 1c             	add    $0x1c,%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5f                   	pop    %edi
  802340:	5d                   	pop    %ebp
  802341:	c3                   	ret    
  802342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802348:	39 f2                	cmp    %esi,%edx
  80234a:	89 d0                	mov    %edx,%eax
  80234c:	77 52                	ja     8023a0 <__umoddi3+0xa0>
  80234e:	0f bd ea             	bsr    %edx,%ebp
  802351:	83 f5 1f             	xor    $0x1f,%ebp
  802354:	75 5a                	jne    8023b0 <__umoddi3+0xb0>
  802356:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80235a:	0f 82 e0 00 00 00    	jb     802440 <__umoddi3+0x140>
  802360:	39 0c 24             	cmp    %ecx,(%esp)
  802363:	0f 86 d7 00 00 00    	jbe    802440 <__umoddi3+0x140>
  802369:	8b 44 24 08          	mov    0x8(%esp),%eax
  80236d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802371:	83 c4 1c             	add    $0x1c,%esp
  802374:	5b                   	pop    %ebx
  802375:	5e                   	pop    %esi
  802376:	5f                   	pop    %edi
  802377:	5d                   	pop    %ebp
  802378:	c3                   	ret    
  802379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802380:	85 ff                	test   %edi,%edi
  802382:	89 fd                	mov    %edi,%ebp
  802384:	75 0b                	jne    802391 <__umoddi3+0x91>
  802386:	b8 01 00 00 00       	mov    $0x1,%eax
  80238b:	31 d2                	xor    %edx,%edx
  80238d:	f7 f7                	div    %edi
  80238f:	89 c5                	mov    %eax,%ebp
  802391:	89 f0                	mov    %esi,%eax
  802393:	31 d2                	xor    %edx,%edx
  802395:	f7 f5                	div    %ebp
  802397:	89 c8                	mov    %ecx,%eax
  802399:	f7 f5                	div    %ebp
  80239b:	89 d0                	mov    %edx,%eax
  80239d:	eb 99                	jmp    802338 <__umoddi3+0x38>
  80239f:	90                   	nop
  8023a0:	89 c8                	mov    %ecx,%eax
  8023a2:	89 f2                	mov    %esi,%edx
  8023a4:	83 c4 1c             	add    $0x1c,%esp
  8023a7:	5b                   	pop    %ebx
  8023a8:	5e                   	pop    %esi
  8023a9:	5f                   	pop    %edi
  8023aa:	5d                   	pop    %ebp
  8023ab:	c3                   	ret    
  8023ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	8b 34 24             	mov    (%esp),%esi
  8023b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023b8:	89 e9                	mov    %ebp,%ecx
  8023ba:	29 ef                	sub    %ebp,%edi
  8023bc:	d3 e0                	shl    %cl,%eax
  8023be:	89 f9                	mov    %edi,%ecx
  8023c0:	89 f2                	mov    %esi,%edx
  8023c2:	d3 ea                	shr    %cl,%edx
  8023c4:	89 e9                	mov    %ebp,%ecx
  8023c6:	09 c2                	or     %eax,%edx
  8023c8:	89 d8                	mov    %ebx,%eax
  8023ca:	89 14 24             	mov    %edx,(%esp)
  8023cd:	89 f2                	mov    %esi,%edx
  8023cf:	d3 e2                	shl    %cl,%edx
  8023d1:	89 f9                	mov    %edi,%ecx
  8023d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	89 c6                	mov    %eax,%esi
  8023e1:	d3 e3                	shl    %cl,%ebx
  8023e3:	89 f9                	mov    %edi,%ecx
  8023e5:	89 d0                	mov    %edx,%eax
  8023e7:	d3 e8                	shr    %cl,%eax
  8023e9:	89 e9                	mov    %ebp,%ecx
  8023eb:	09 d8                	or     %ebx,%eax
  8023ed:	89 d3                	mov    %edx,%ebx
  8023ef:	89 f2                	mov    %esi,%edx
  8023f1:	f7 34 24             	divl   (%esp)
  8023f4:	89 d6                	mov    %edx,%esi
  8023f6:	d3 e3                	shl    %cl,%ebx
  8023f8:	f7 64 24 04          	mull   0x4(%esp)
  8023fc:	39 d6                	cmp    %edx,%esi
  8023fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802402:	89 d1                	mov    %edx,%ecx
  802404:	89 c3                	mov    %eax,%ebx
  802406:	72 08                	jb     802410 <__umoddi3+0x110>
  802408:	75 11                	jne    80241b <__umoddi3+0x11b>
  80240a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80240e:	73 0b                	jae    80241b <__umoddi3+0x11b>
  802410:	2b 44 24 04          	sub    0x4(%esp),%eax
  802414:	1b 14 24             	sbb    (%esp),%edx
  802417:	89 d1                	mov    %edx,%ecx
  802419:	89 c3                	mov    %eax,%ebx
  80241b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80241f:	29 da                	sub    %ebx,%edx
  802421:	19 ce                	sbb    %ecx,%esi
  802423:	89 f9                	mov    %edi,%ecx
  802425:	89 f0                	mov    %esi,%eax
  802427:	d3 e0                	shl    %cl,%eax
  802429:	89 e9                	mov    %ebp,%ecx
  80242b:	d3 ea                	shr    %cl,%edx
  80242d:	89 e9                	mov    %ebp,%ecx
  80242f:	d3 ee                	shr    %cl,%esi
  802431:	09 d0                	or     %edx,%eax
  802433:	89 f2                	mov    %esi,%edx
  802435:	83 c4 1c             	add    $0x1c,%esp
  802438:	5b                   	pop    %ebx
  802439:	5e                   	pop    %esi
  80243a:	5f                   	pop    %edi
  80243b:	5d                   	pop    %ebp
  80243c:	c3                   	ret    
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
  802440:	29 f9                	sub    %edi,%ecx
  802442:	19 d6                	sbb    %edx,%esi
  802444:	89 74 24 04          	mov    %esi,0x4(%esp)
  802448:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80244c:	e9 18 ff ff ff       	jmp    802369 <__umoddi3+0x69>
