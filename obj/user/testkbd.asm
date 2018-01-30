
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
  80003f:	e8 e0 0d 00 00       	call   800e24 <sys_yield>
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
  80004e:	e8 de 16 00 00       	call   801731 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 a0 26 80 00       	push   $0x8026a0
  800065:	6a 0f                	push   $0xf
  800067:	68 ad 26 80 00       	push   $0x8026ad
  80006c:	e8 7e 02 00 00       	call   8002ef <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 bc 26 80 00       	push   $0x8026bc
  80007b:	6a 11                	push   $0x11
  80007d:	68 ad 26 80 00       	push   $0x8026ad
  800082:	e8 68 02 00 00       	call   8002ef <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 ee 16 00 00       	call   801781 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 d6 26 80 00       	push   $0x8026d6
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 ad 26 80 00       	push   $0x8026ad
  8000a7:	e8 43 02 00 00       	call   8002ef <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 de 26 80 00       	push   $0x8026de
  8000b4:	e8 5b 08 00 00       	call   800914 <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 ec 26 80 00       	push   $0x8026ec
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 b8 1d 00 00       	call   801e88 <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 f0 26 80 00       	push   $0x8026f0
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 a4 1d 00 00       	call   801e88 <fprintf>
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
  8000f9:	68 08 27 80 00       	push   $0x802708
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	e8 3a 09 00 00       	call   800a40 <strcpy>
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
  80013f:	e8 8e 0a 00 00       	call   800bd2 <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 39 0c 00 00       	call   800d87 <sys_cputs>
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
  800175:	e8 aa 0c 00 00       	call   800e24 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80017a:	e8 26 0c 00 00       	call   800da5 <sys_cgetc>
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
  8001b1:	e8 d1 0b 00 00       	call   800d87 <sys_cputs>
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
  8001c9:	e8 9f 16 00 00       	call   80186d <read>
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
  8001f3:	e8 0c 14 00 00       	call   801604 <fd_lookup>
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
  80021c:	e8 94 13 00 00       	call   8015b5 <fd_alloc>
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
  800237:	e8 07 0c 00 00       	call   800e43 <sys_page_alloc>
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
  80025e:	e8 2b 13 00 00       	call   80158e <fd2num>
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
  800277:	e8 89 0b 00 00       	call   800e05 <sys_getenvid>
  80027c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800281:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800287:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80028c:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800291:	85 db                	test   %ebx,%ebx
  800293:	7e 07                	jle    80029c <libmain+0x30>
		binaryname = argv[0];
  800295:	8b 06                	mov    (%esi),%eax
  800297:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  80029c:	83 ec 08             	sub    $0x8,%esp
  80029f:	56                   	push   %esi
  8002a0:	53                   	push   %ebx
  8002a1:	e8 8d fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002a6:	e8 2a 00 00 00       	call   8002d5 <exit>
}
  8002ab:	83 c4 10             	add    $0x10,%esp
  8002ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002b1:	5b                   	pop    %ebx
  8002b2:	5e                   	pop    %esi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  8002bb:	a1 08 44 80 00       	mov    0x804408,%eax
	func();
  8002c0:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8002c2:	e8 3e 0b 00 00       	call   800e05 <sys_getenvid>
  8002c7:	83 ec 0c             	sub    $0xc,%esp
  8002ca:	50                   	push   %eax
  8002cb:	e8 84 0d 00 00       	call   801054 <sys_thread_free>
}
  8002d0:	83 c4 10             	add    $0x10,%esp
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002db:	e8 7c 14 00 00       	call   80175c <close_all>
	sys_env_destroy(0);
  8002e0:	83 ec 0c             	sub    $0xc,%esp
  8002e3:	6a 00                	push   $0x0
  8002e5:	e8 da 0a 00 00       	call   800dc4 <sys_env_destroy>
}
  8002ea:	83 c4 10             	add    $0x10,%esp
  8002ed:	c9                   	leave  
  8002ee:	c3                   	ret    

008002ef <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002f4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002f7:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002fd:	e8 03 0b 00 00       	call   800e05 <sys_getenvid>
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	ff 75 0c             	pushl  0xc(%ebp)
  800308:	ff 75 08             	pushl  0x8(%ebp)
  80030b:	56                   	push   %esi
  80030c:	50                   	push   %eax
  80030d:	68 20 27 80 00       	push   $0x802720
  800312:	e8 b1 00 00 00       	call   8003c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800317:	83 c4 18             	add    $0x18,%esp
  80031a:	53                   	push   %ebx
  80031b:	ff 75 10             	pushl  0x10(%ebp)
  80031e:	e8 54 00 00 00       	call   800377 <vcprintf>
	cprintf("\n");
  800323:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  80032a:	e8 99 00 00 00       	call   8003c8 <cprintf>
  80032f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800332:	cc                   	int3   
  800333:	eb fd                	jmp    800332 <_panic+0x43>

00800335 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	53                   	push   %ebx
  800339:	83 ec 04             	sub    $0x4,%esp
  80033c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80033f:	8b 13                	mov    (%ebx),%edx
  800341:	8d 42 01             	lea    0x1(%edx),%eax
  800344:	89 03                	mov    %eax,(%ebx)
  800346:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800349:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80034d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800352:	75 1a                	jne    80036e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800354:	83 ec 08             	sub    $0x8,%esp
  800357:	68 ff 00 00 00       	push   $0xff
  80035c:	8d 43 08             	lea    0x8(%ebx),%eax
  80035f:	50                   	push   %eax
  800360:	e8 22 0a 00 00       	call   800d87 <sys_cputs>
		b->idx = 0;
  800365:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80036b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80036e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800372:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800375:	c9                   	leave  
  800376:	c3                   	ret    

00800377 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800380:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800387:	00 00 00 
	b.cnt = 0;
  80038a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800391:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800394:	ff 75 0c             	pushl  0xc(%ebp)
  800397:	ff 75 08             	pushl  0x8(%ebp)
  80039a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003a0:	50                   	push   %eax
  8003a1:	68 35 03 80 00       	push   $0x800335
  8003a6:	e8 54 01 00 00       	call   8004ff <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ab:	83 c4 08             	add    $0x8,%esp
  8003ae:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003b4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ba:	50                   	push   %eax
  8003bb:	e8 c7 09 00 00       	call   800d87 <sys_cputs>

	return b.cnt;
}
  8003c0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003c6:	c9                   	leave  
  8003c7:	c3                   	ret    

008003c8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003d1:	50                   	push   %eax
  8003d2:	ff 75 08             	pushl  0x8(%ebp)
  8003d5:	e8 9d ff ff ff       	call   800377 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003da:	c9                   	leave  
  8003db:	c3                   	ret    

008003dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	57                   	push   %edi
  8003e0:	56                   	push   %esi
  8003e1:	53                   	push   %ebx
  8003e2:	83 ec 1c             	sub    $0x1c,%esp
  8003e5:	89 c7                	mov    %eax,%edi
  8003e7:	89 d6                	mov    %edx,%esi
  8003e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003fd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800400:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800403:	39 d3                	cmp    %edx,%ebx
  800405:	72 05                	jb     80040c <printnum+0x30>
  800407:	39 45 10             	cmp    %eax,0x10(%ebp)
  80040a:	77 45                	ja     800451 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80040c:	83 ec 0c             	sub    $0xc,%esp
  80040f:	ff 75 18             	pushl  0x18(%ebp)
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800418:	53                   	push   %ebx
  800419:	ff 75 10             	pushl  0x10(%ebp)
  80041c:	83 ec 08             	sub    $0x8,%esp
  80041f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800422:	ff 75 e0             	pushl  -0x20(%ebp)
  800425:	ff 75 dc             	pushl  -0x24(%ebp)
  800428:	ff 75 d8             	pushl  -0x28(%ebp)
  80042b:	e8 e0 1f 00 00       	call   802410 <__udivdi3>
  800430:	83 c4 18             	add    $0x18,%esp
  800433:	52                   	push   %edx
  800434:	50                   	push   %eax
  800435:	89 f2                	mov    %esi,%edx
  800437:	89 f8                	mov    %edi,%eax
  800439:	e8 9e ff ff ff       	call   8003dc <printnum>
  80043e:	83 c4 20             	add    $0x20,%esp
  800441:	eb 18                	jmp    80045b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800443:	83 ec 08             	sub    $0x8,%esp
  800446:	56                   	push   %esi
  800447:	ff 75 18             	pushl  0x18(%ebp)
  80044a:	ff d7                	call   *%edi
  80044c:	83 c4 10             	add    $0x10,%esp
  80044f:	eb 03                	jmp    800454 <printnum+0x78>
  800451:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800454:	83 eb 01             	sub    $0x1,%ebx
  800457:	85 db                	test   %ebx,%ebx
  800459:	7f e8                	jg     800443 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80045b:	83 ec 08             	sub    $0x8,%esp
  80045e:	56                   	push   %esi
  80045f:	83 ec 04             	sub    $0x4,%esp
  800462:	ff 75 e4             	pushl  -0x1c(%ebp)
  800465:	ff 75 e0             	pushl  -0x20(%ebp)
  800468:	ff 75 dc             	pushl  -0x24(%ebp)
  80046b:	ff 75 d8             	pushl  -0x28(%ebp)
  80046e:	e8 cd 20 00 00       	call   802540 <__umoddi3>
  800473:	83 c4 14             	add    $0x14,%esp
  800476:	0f be 80 43 27 80 00 	movsbl 0x802743(%eax),%eax
  80047d:	50                   	push   %eax
  80047e:	ff d7                	call   *%edi
}
  800480:	83 c4 10             	add    $0x10,%esp
  800483:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800486:	5b                   	pop    %ebx
  800487:	5e                   	pop    %esi
  800488:	5f                   	pop    %edi
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80048e:	83 fa 01             	cmp    $0x1,%edx
  800491:	7e 0e                	jle    8004a1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800493:	8b 10                	mov    (%eax),%edx
  800495:	8d 4a 08             	lea    0x8(%edx),%ecx
  800498:	89 08                	mov    %ecx,(%eax)
  80049a:	8b 02                	mov    (%edx),%eax
  80049c:	8b 52 04             	mov    0x4(%edx),%edx
  80049f:	eb 22                	jmp    8004c3 <getuint+0x38>
	else if (lflag)
  8004a1:	85 d2                	test   %edx,%edx
  8004a3:	74 10                	je     8004b5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004a5:	8b 10                	mov    (%eax),%edx
  8004a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004aa:	89 08                	mov    %ecx,(%eax)
  8004ac:	8b 02                	mov    (%edx),%eax
  8004ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b3:	eb 0e                	jmp    8004c3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004b5:	8b 10                	mov    (%eax),%edx
  8004b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ba:	89 08                	mov    %ecx,(%eax)
  8004bc:	8b 02                	mov    (%edx),%eax
  8004be:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004c3:	5d                   	pop    %ebp
  8004c4:	c3                   	ret    

008004c5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c5:	55                   	push   %ebp
  8004c6:	89 e5                	mov    %esp,%ebp
  8004c8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004cb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004cf:	8b 10                	mov    (%eax),%edx
  8004d1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d4:	73 0a                	jae    8004e0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004d6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004d9:	89 08                	mov    %ecx,(%eax)
  8004db:	8b 45 08             	mov    0x8(%ebp),%eax
  8004de:	88 02                	mov    %al,(%edx)
}
  8004e0:	5d                   	pop    %ebp
  8004e1:	c3                   	ret    

008004e2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004e8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004eb:	50                   	push   %eax
  8004ec:	ff 75 10             	pushl  0x10(%ebp)
  8004ef:	ff 75 0c             	pushl  0xc(%ebp)
  8004f2:	ff 75 08             	pushl  0x8(%ebp)
  8004f5:	e8 05 00 00 00       	call   8004ff <vprintfmt>
	va_end(ap);
}
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	c9                   	leave  
  8004fe:	c3                   	ret    

008004ff <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	57                   	push   %edi
  800503:	56                   	push   %esi
  800504:	53                   	push   %ebx
  800505:	83 ec 2c             	sub    $0x2c,%esp
  800508:	8b 75 08             	mov    0x8(%ebp),%esi
  80050b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800511:	eb 12                	jmp    800525 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800513:	85 c0                	test   %eax,%eax
  800515:	0f 84 89 03 00 00    	je     8008a4 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	53                   	push   %ebx
  80051f:	50                   	push   %eax
  800520:	ff d6                	call   *%esi
  800522:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800525:	83 c7 01             	add    $0x1,%edi
  800528:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052c:	83 f8 25             	cmp    $0x25,%eax
  80052f:	75 e2                	jne    800513 <vprintfmt+0x14>
  800531:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800535:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80053c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800543:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80054a:	ba 00 00 00 00       	mov    $0x0,%edx
  80054f:	eb 07                	jmp    800558 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800551:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800554:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800558:	8d 47 01             	lea    0x1(%edi),%eax
  80055b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80055e:	0f b6 07             	movzbl (%edi),%eax
  800561:	0f b6 c8             	movzbl %al,%ecx
  800564:	83 e8 23             	sub    $0x23,%eax
  800567:	3c 55                	cmp    $0x55,%al
  800569:	0f 87 1a 03 00 00    	ja     800889 <vprintfmt+0x38a>
  80056f:	0f b6 c0             	movzbl %al,%eax
  800572:	ff 24 85 80 28 80 00 	jmp    *0x802880(,%eax,4)
  800579:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80057c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800580:	eb d6                	jmp    800558 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800585:	b8 00 00 00 00       	mov    $0x0,%eax
  80058a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80058d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800590:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800594:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800597:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80059a:	83 fa 09             	cmp    $0x9,%edx
  80059d:	77 39                	ja     8005d8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80059f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005a2:	eb e9                	jmp    80058d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 48 04             	lea    0x4(%eax),%ecx
  8005aa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005ad:	8b 00                	mov    (%eax),%eax
  8005af:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b5:	eb 27                	jmp    8005de <vprintfmt+0xdf>
  8005b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ba:	85 c0                	test   %eax,%eax
  8005bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c1:	0f 49 c8             	cmovns %eax,%ecx
  8005c4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ca:	eb 8c                	jmp    800558 <vprintfmt+0x59>
  8005cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005cf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005d6:	eb 80                	jmp    800558 <vprintfmt+0x59>
  8005d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005db:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e2:	0f 89 70 ff ff ff    	jns    800558 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ee:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005f5:	e9 5e ff ff ff       	jmp    800558 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005fa:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800600:	e9 53 ff ff ff       	jmp    800558 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 50 04             	lea    0x4(%eax),%edx
  80060b:	89 55 14             	mov    %edx,0x14(%ebp)
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	ff 30                	pushl  (%eax)
  800614:	ff d6                	call   *%esi
			break;
  800616:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80061c:	e9 04 ff ff ff       	jmp    800525 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8d 50 04             	lea    0x4(%eax),%edx
  800627:	89 55 14             	mov    %edx,0x14(%ebp)
  80062a:	8b 00                	mov    (%eax),%eax
  80062c:	99                   	cltd   
  80062d:	31 d0                	xor    %edx,%eax
  80062f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800631:	83 f8 0f             	cmp    $0xf,%eax
  800634:	7f 0b                	jg     800641 <vprintfmt+0x142>
  800636:	8b 14 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%edx
  80063d:	85 d2                	test   %edx,%edx
  80063f:	75 18                	jne    800659 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800641:	50                   	push   %eax
  800642:	68 5b 27 80 00       	push   $0x80275b
  800647:	53                   	push   %ebx
  800648:	56                   	push   %esi
  800649:	e8 94 fe ff ff       	call   8004e2 <printfmt>
  80064e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800651:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800654:	e9 cc fe ff ff       	jmp    800525 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800659:	52                   	push   %edx
  80065a:	68 b1 2b 80 00       	push   $0x802bb1
  80065f:	53                   	push   %ebx
  800660:	56                   	push   %esi
  800661:	e8 7c fe ff ff       	call   8004e2 <printfmt>
  800666:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800669:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066c:	e9 b4 fe ff ff       	jmp    800525 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 50 04             	lea    0x4(%eax),%edx
  800677:	89 55 14             	mov    %edx,0x14(%ebp)
  80067a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80067c:	85 ff                	test   %edi,%edi
  80067e:	b8 54 27 80 00       	mov    $0x802754,%eax
  800683:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800686:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80068a:	0f 8e 94 00 00 00    	jle    800724 <vprintfmt+0x225>
  800690:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800694:	0f 84 98 00 00 00    	je     800732 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069a:	83 ec 08             	sub    $0x8,%esp
  80069d:	ff 75 d0             	pushl  -0x30(%ebp)
  8006a0:	57                   	push   %edi
  8006a1:	e8 79 03 00 00       	call   800a1f <strnlen>
  8006a6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006a9:	29 c1                	sub    %eax,%ecx
  8006ab:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006ae:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006b1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006bb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	eb 0f                	jmp    8006ce <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	53                   	push   %ebx
  8006c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c8:	83 ef 01             	sub    $0x1,%edi
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	85 ff                	test   %edi,%edi
  8006d0:	7f ed                	jg     8006bf <vprintfmt+0x1c0>
  8006d2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006d5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006d8:	85 c9                	test   %ecx,%ecx
  8006da:	b8 00 00 00 00       	mov    $0x0,%eax
  8006df:	0f 49 c1             	cmovns %ecx,%eax
  8006e2:	29 c1                	sub    %eax,%ecx
  8006e4:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006ea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ed:	89 cb                	mov    %ecx,%ebx
  8006ef:	eb 4d                	jmp    80073e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006f1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f5:	74 1b                	je     800712 <vprintfmt+0x213>
  8006f7:	0f be c0             	movsbl %al,%eax
  8006fa:	83 e8 20             	sub    $0x20,%eax
  8006fd:	83 f8 5e             	cmp    $0x5e,%eax
  800700:	76 10                	jbe    800712 <vprintfmt+0x213>
					putch('?', putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	ff 75 0c             	pushl  0xc(%ebp)
  800708:	6a 3f                	push   $0x3f
  80070a:	ff 55 08             	call   *0x8(%ebp)
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	eb 0d                	jmp    80071f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	ff 75 0c             	pushl  0xc(%ebp)
  800718:	52                   	push   %edx
  800719:	ff 55 08             	call   *0x8(%ebp)
  80071c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071f:	83 eb 01             	sub    $0x1,%ebx
  800722:	eb 1a                	jmp    80073e <vprintfmt+0x23f>
  800724:	89 75 08             	mov    %esi,0x8(%ebp)
  800727:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80072a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80072d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800730:	eb 0c                	jmp    80073e <vprintfmt+0x23f>
  800732:	89 75 08             	mov    %esi,0x8(%ebp)
  800735:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800738:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80073e:	83 c7 01             	add    $0x1,%edi
  800741:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800745:	0f be d0             	movsbl %al,%edx
  800748:	85 d2                	test   %edx,%edx
  80074a:	74 23                	je     80076f <vprintfmt+0x270>
  80074c:	85 f6                	test   %esi,%esi
  80074e:	78 a1                	js     8006f1 <vprintfmt+0x1f2>
  800750:	83 ee 01             	sub    $0x1,%esi
  800753:	79 9c                	jns    8006f1 <vprintfmt+0x1f2>
  800755:	89 df                	mov    %ebx,%edi
  800757:	8b 75 08             	mov    0x8(%ebp),%esi
  80075a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80075d:	eb 18                	jmp    800777 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	53                   	push   %ebx
  800763:	6a 20                	push   $0x20
  800765:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800767:	83 ef 01             	sub    $0x1,%edi
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	eb 08                	jmp    800777 <vprintfmt+0x278>
  80076f:	89 df                	mov    %ebx,%edi
  800771:	8b 75 08             	mov    0x8(%ebp),%esi
  800774:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800777:	85 ff                	test   %edi,%edi
  800779:	7f e4                	jg     80075f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077e:	e9 a2 fd ff ff       	jmp    800525 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800783:	83 fa 01             	cmp    $0x1,%edx
  800786:	7e 16                	jle    80079e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8d 50 08             	lea    0x8(%eax),%edx
  80078e:	89 55 14             	mov    %edx,0x14(%ebp)
  800791:	8b 50 04             	mov    0x4(%eax),%edx
  800794:	8b 00                	mov    (%eax),%eax
  800796:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800799:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80079c:	eb 32                	jmp    8007d0 <vprintfmt+0x2d1>
	else if (lflag)
  80079e:	85 d2                	test   %edx,%edx
  8007a0:	74 18                	je     8007ba <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a5:	8d 50 04             	lea    0x4(%eax),%edx
  8007a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ab:	8b 00                	mov    (%eax),%eax
  8007ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b0:	89 c1                	mov    %eax,%ecx
  8007b2:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b8:	eb 16                	jmp    8007d0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8d 50 04             	lea    0x4(%eax),%edx
  8007c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c3:	8b 00                	mov    (%eax),%eax
  8007c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c8:	89 c1                	mov    %eax,%ecx
  8007ca:	c1 f9 1f             	sar    $0x1f,%ecx
  8007cd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007d3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007db:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007df:	79 74                	jns    800855 <vprintfmt+0x356>
				putch('-', putdat);
  8007e1:	83 ec 08             	sub    $0x8,%esp
  8007e4:	53                   	push   %ebx
  8007e5:	6a 2d                	push   $0x2d
  8007e7:	ff d6                	call   *%esi
				num = -(long long) num;
  8007e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007ef:	f7 d8                	neg    %eax
  8007f1:	83 d2 00             	adc    $0x0,%edx
  8007f4:	f7 da                	neg    %edx
  8007f6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007fe:	eb 55                	jmp    800855 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800800:	8d 45 14             	lea    0x14(%ebp),%eax
  800803:	e8 83 fc ff ff       	call   80048b <getuint>
			base = 10;
  800808:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80080d:	eb 46                	jmp    800855 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80080f:	8d 45 14             	lea    0x14(%ebp),%eax
  800812:	e8 74 fc ff ff       	call   80048b <getuint>
			base = 8;
  800817:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80081c:	eb 37                	jmp    800855 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80081e:	83 ec 08             	sub    $0x8,%esp
  800821:	53                   	push   %ebx
  800822:	6a 30                	push   $0x30
  800824:	ff d6                	call   *%esi
			putch('x', putdat);
  800826:	83 c4 08             	add    $0x8,%esp
  800829:	53                   	push   %ebx
  80082a:	6a 78                	push   $0x78
  80082c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80082e:	8b 45 14             	mov    0x14(%ebp),%eax
  800831:	8d 50 04             	lea    0x4(%eax),%edx
  800834:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800837:	8b 00                	mov    (%eax),%eax
  800839:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80083e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800841:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800846:	eb 0d                	jmp    800855 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800848:	8d 45 14             	lea    0x14(%ebp),%eax
  80084b:	e8 3b fc ff ff       	call   80048b <getuint>
			base = 16;
  800850:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800855:	83 ec 0c             	sub    $0xc,%esp
  800858:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80085c:	57                   	push   %edi
  80085d:	ff 75 e0             	pushl  -0x20(%ebp)
  800860:	51                   	push   %ecx
  800861:	52                   	push   %edx
  800862:	50                   	push   %eax
  800863:	89 da                	mov    %ebx,%edx
  800865:	89 f0                	mov    %esi,%eax
  800867:	e8 70 fb ff ff       	call   8003dc <printnum>
			break;
  80086c:	83 c4 20             	add    $0x20,%esp
  80086f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800872:	e9 ae fc ff ff       	jmp    800525 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800877:	83 ec 08             	sub    $0x8,%esp
  80087a:	53                   	push   %ebx
  80087b:	51                   	push   %ecx
  80087c:	ff d6                	call   *%esi
			break;
  80087e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800881:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800884:	e9 9c fc ff ff       	jmp    800525 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800889:	83 ec 08             	sub    $0x8,%esp
  80088c:	53                   	push   %ebx
  80088d:	6a 25                	push   $0x25
  80088f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800891:	83 c4 10             	add    $0x10,%esp
  800894:	eb 03                	jmp    800899 <vprintfmt+0x39a>
  800896:	83 ef 01             	sub    $0x1,%edi
  800899:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80089d:	75 f7                	jne    800896 <vprintfmt+0x397>
  80089f:	e9 81 fc ff ff       	jmp    800525 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a7:	5b                   	pop    %ebx
  8008a8:	5e                   	pop    %esi
  8008a9:	5f                   	pop    %edi
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	83 ec 18             	sub    $0x18,%esp
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008bb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008bf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c9:	85 c0                	test   %eax,%eax
  8008cb:	74 26                	je     8008f3 <vsnprintf+0x47>
  8008cd:	85 d2                	test   %edx,%edx
  8008cf:	7e 22                	jle    8008f3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d1:	ff 75 14             	pushl  0x14(%ebp)
  8008d4:	ff 75 10             	pushl  0x10(%ebp)
  8008d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008da:	50                   	push   %eax
  8008db:	68 c5 04 80 00       	push   $0x8004c5
  8008e0:	e8 1a fc ff ff       	call   8004ff <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	eb 05                	jmp    8008f8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008f8:	c9                   	leave  
  8008f9:	c3                   	ret    

008008fa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800900:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800903:	50                   	push   %eax
  800904:	ff 75 10             	pushl  0x10(%ebp)
  800907:	ff 75 0c             	pushl  0xc(%ebp)
  80090a:	ff 75 08             	pushl  0x8(%ebp)
  80090d:	e8 9a ff ff ff       	call   8008ac <vsnprintf>
	va_end(ap);

	return rc;
}
  800912:	c9                   	leave  
  800913:	c3                   	ret    

00800914 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	57                   	push   %edi
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	83 ec 0c             	sub    $0xc,%esp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800920:	85 c0                	test   %eax,%eax
  800922:	74 13                	je     800937 <readline+0x23>
		fprintf(1, "%s", prompt);
  800924:	83 ec 04             	sub    $0x4,%esp
  800927:	50                   	push   %eax
  800928:	68 b1 2b 80 00       	push   $0x802bb1
  80092d:	6a 01                	push   $0x1
  80092f:	e8 54 15 00 00       	call   801e88 <fprintf>
  800934:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  800937:	83 ec 0c             	sub    $0xc,%esp
  80093a:	6a 00                	push   $0x0
  80093c:	e8 a5 f8 ff ff       	call   8001e6 <iscons>
  800941:	89 c7                	mov    %eax,%edi
  800943:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  800946:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  80094b:	e8 6b f8 ff ff       	call   8001bb <getchar>
  800950:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800952:	85 c0                	test   %eax,%eax
  800954:	79 29                	jns    80097f <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  80095b:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80095e:	0f 84 9b 00 00 00    	je     8009ff <readline+0xeb>
				cprintf("read error: %e\n", c);
  800964:	83 ec 08             	sub    $0x8,%esp
  800967:	53                   	push   %ebx
  800968:	68 3f 2a 80 00       	push   $0x802a3f
  80096d:	e8 56 fa ff ff       	call   8003c8 <cprintf>
  800972:	83 c4 10             	add    $0x10,%esp
			return NULL;
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
  80097a:	e9 80 00 00 00       	jmp    8009ff <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  80097f:	83 f8 08             	cmp    $0x8,%eax
  800982:	0f 94 c2             	sete   %dl
  800985:	83 f8 7f             	cmp    $0x7f,%eax
  800988:	0f 94 c0             	sete   %al
  80098b:	08 c2                	or     %al,%dl
  80098d:	74 1a                	je     8009a9 <readline+0x95>
  80098f:	85 f6                	test   %esi,%esi
  800991:	7e 16                	jle    8009a9 <readline+0x95>
			if (echoing)
  800993:	85 ff                	test   %edi,%edi
  800995:	74 0d                	je     8009a4 <readline+0x90>
				cputchar('\b');
  800997:	83 ec 0c             	sub    $0xc,%esp
  80099a:	6a 08                	push   $0x8
  80099c:	e8 fe f7 ff ff       	call   80019f <cputchar>
  8009a1:	83 c4 10             	add    $0x10,%esp
			i--;
  8009a4:	83 ee 01             	sub    $0x1,%esi
  8009a7:	eb a2                	jmp    80094b <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8009a9:	83 fb 1f             	cmp    $0x1f,%ebx
  8009ac:	7e 26                	jle    8009d4 <readline+0xc0>
  8009ae:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8009b4:	7f 1e                	jg     8009d4 <readline+0xc0>
			if (echoing)
  8009b6:	85 ff                	test   %edi,%edi
  8009b8:	74 0c                	je     8009c6 <readline+0xb2>
				cputchar(c);
  8009ba:	83 ec 0c             	sub    $0xc,%esp
  8009bd:	53                   	push   %ebx
  8009be:	e8 dc f7 ff ff       	call   80019f <cputchar>
  8009c3:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8009c6:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  8009cc:	8d 76 01             	lea    0x1(%esi),%esi
  8009cf:	e9 77 ff ff ff       	jmp    80094b <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8009d4:	83 fb 0a             	cmp    $0xa,%ebx
  8009d7:	74 09                	je     8009e2 <readline+0xce>
  8009d9:	83 fb 0d             	cmp    $0xd,%ebx
  8009dc:	0f 85 69 ff ff ff    	jne    80094b <readline+0x37>
			if (echoing)
  8009e2:	85 ff                	test   %edi,%edi
  8009e4:	74 0d                	je     8009f3 <readline+0xdf>
				cputchar('\n');
  8009e6:	83 ec 0c             	sub    $0xc,%esp
  8009e9:	6a 0a                	push   $0xa
  8009eb:	e8 af f7 ff ff       	call   80019f <cputchar>
  8009f0:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  8009f3:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  8009fa:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  8009ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5f                   	pop    %edi
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a12:	eb 03                	jmp    800a17 <strlen+0x10>
		n++;
  800a14:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a17:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a1b:	75 f7                	jne    800a14 <strlen+0xd>
		n++;
	return n;
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a25:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a28:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2d:	eb 03                	jmp    800a32 <strnlen+0x13>
		n++;
  800a2f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a32:	39 c2                	cmp    %eax,%edx
  800a34:	74 08                	je     800a3e <strnlen+0x1f>
  800a36:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a3a:	75 f3                	jne    800a2f <strnlen+0x10>
  800a3c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	53                   	push   %ebx
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a4a:	89 c2                	mov    %eax,%edx
  800a4c:	83 c2 01             	add    $0x1,%edx
  800a4f:	83 c1 01             	add    $0x1,%ecx
  800a52:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a56:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a59:	84 db                	test   %bl,%bl
  800a5b:	75 ef                	jne    800a4c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	53                   	push   %ebx
  800a64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a67:	53                   	push   %ebx
  800a68:	e8 9a ff ff ff       	call   800a07 <strlen>
  800a6d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a70:	ff 75 0c             	pushl  0xc(%ebp)
  800a73:	01 d8                	add    %ebx,%eax
  800a75:	50                   	push   %eax
  800a76:	e8 c5 ff ff ff       	call   800a40 <strcpy>
	return dst;
}
  800a7b:	89 d8                	mov    %ebx,%eax
  800a7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    

00800a82 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
  800a87:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8d:	89 f3                	mov    %esi,%ebx
  800a8f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a92:	89 f2                	mov    %esi,%edx
  800a94:	eb 0f                	jmp    800aa5 <strncpy+0x23>
		*dst++ = *src;
  800a96:	83 c2 01             	add    $0x1,%edx
  800a99:	0f b6 01             	movzbl (%ecx),%eax
  800a9c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a9f:	80 39 01             	cmpb   $0x1,(%ecx)
  800aa2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa5:	39 da                	cmp    %ebx,%edx
  800aa7:	75 ed                	jne    800a96 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aa9:	89 f0                	mov    %esi,%eax
  800aab:	5b                   	pop    %ebx
  800aac:	5e                   	pop    %esi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aba:	8b 55 10             	mov    0x10(%ebp),%edx
  800abd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800abf:	85 d2                	test   %edx,%edx
  800ac1:	74 21                	je     800ae4 <strlcpy+0x35>
  800ac3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ac7:	89 f2                	mov    %esi,%edx
  800ac9:	eb 09                	jmp    800ad4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800acb:	83 c2 01             	add    $0x1,%edx
  800ace:	83 c1 01             	add    $0x1,%ecx
  800ad1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ad4:	39 c2                	cmp    %eax,%edx
  800ad6:	74 09                	je     800ae1 <strlcpy+0x32>
  800ad8:	0f b6 19             	movzbl (%ecx),%ebx
  800adb:	84 db                	test   %bl,%bl
  800add:	75 ec                	jne    800acb <strlcpy+0x1c>
  800adf:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ae1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ae4:	29 f0                	sub    %esi,%eax
}
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800af3:	eb 06                	jmp    800afb <strcmp+0x11>
		p++, q++;
  800af5:	83 c1 01             	add    $0x1,%ecx
  800af8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800afb:	0f b6 01             	movzbl (%ecx),%eax
  800afe:	84 c0                	test   %al,%al
  800b00:	74 04                	je     800b06 <strcmp+0x1c>
  800b02:	3a 02                	cmp    (%edx),%al
  800b04:	74 ef                	je     800af5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b06:	0f b6 c0             	movzbl %al,%eax
  800b09:	0f b6 12             	movzbl (%edx),%edx
  800b0c:	29 d0                	sub    %edx,%eax
}
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	53                   	push   %ebx
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1a:	89 c3                	mov    %eax,%ebx
  800b1c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b1f:	eb 06                	jmp    800b27 <strncmp+0x17>
		n--, p++, q++;
  800b21:	83 c0 01             	add    $0x1,%eax
  800b24:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b27:	39 d8                	cmp    %ebx,%eax
  800b29:	74 15                	je     800b40 <strncmp+0x30>
  800b2b:	0f b6 08             	movzbl (%eax),%ecx
  800b2e:	84 c9                	test   %cl,%cl
  800b30:	74 04                	je     800b36 <strncmp+0x26>
  800b32:	3a 0a                	cmp    (%edx),%cl
  800b34:	74 eb                	je     800b21 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b36:	0f b6 00             	movzbl (%eax),%eax
  800b39:	0f b6 12             	movzbl (%edx),%edx
  800b3c:	29 d0                	sub    %edx,%eax
  800b3e:	eb 05                	jmp    800b45 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b40:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b45:	5b                   	pop    %ebx
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b52:	eb 07                	jmp    800b5b <strchr+0x13>
		if (*s == c)
  800b54:	38 ca                	cmp    %cl,%dl
  800b56:	74 0f                	je     800b67 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b58:	83 c0 01             	add    $0x1,%eax
  800b5b:	0f b6 10             	movzbl (%eax),%edx
  800b5e:	84 d2                	test   %dl,%dl
  800b60:	75 f2                	jne    800b54 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b73:	eb 03                	jmp    800b78 <strfind+0xf>
  800b75:	83 c0 01             	add    $0x1,%eax
  800b78:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b7b:	38 ca                	cmp    %cl,%dl
  800b7d:	74 04                	je     800b83 <strfind+0x1a>
  800b7f:	84 d2                	test   %dl,%dl
  800b81:	75 f2                	jne    800b75 <strfind+0xc>
			break;
	return (char *) s;
}
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b91:	85 c9                	test   %ecx,%ecx
  800b93:	74 36                	je     800bcb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b95:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b9b:	75 28                	jne    800bc5 <memset+0x40>
  800b9d:	f6 c1 03             	test   $0x3,%cl
  800ba0:	75 23                	jne    800bc5 <memset+0x40>
		c &= 0xFF;
  800ba2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ba6:	89 d3                	mov    %edx,%ebx
  800ba8:	c1 e3 08             	shl    $0x8,%ebx
  800bab:	89 d6                	mov    %edx,%esi
  800bad:	c1 e6 18             	shl    $0x18,%esi
  800bb0:	89 d0                	mov    %edx,%eax
  800bb2:	c1 e0 10             	shl    $0x10,%eax
  800bb5:	09 f0                	or     %esi,%eax
  800bb7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bb9:	89 d8                	mov    %ebx,%eax
  800bbb:	09 d0                	or     %edx,%eax
  800bbd:	c1 e9 02             	shr    $0x2,%ecx
  800bc0:	fc                   	cld    
  800bc1:	f3 ab                	rep stos %eax,%es:(%edi)
  800bc3:	eb 06                	jmp    800bcb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc8:	fc                   	cld    
  800bc9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bcb:	89 f8                	mov    %edi,%eax
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bdd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800be0:	39 c6                	cmp    %eax,%esi
  800be2:	73 35                	jae    800c19 <memmove+0x47>
  800be4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800be7:	39 d0                	cmp    %edx,%eax
  800be9:	73 2e                	jae    800c19 <memmove+0x47>
		s += n;
		d += n;
  800beb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bee:	89 d6                	mov    %edx,%esi
  800bf0:	09 fe                	or     %edi,%esi
  800bf2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bf8:	75 13                	jne    800c0d <memmove+0x3b>
  800bfa:	f6 c1 03             	test   $0x3,%cl
  800bfd:	75 0e                	jne    800c0d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bff:	83 ef 04             	sub    $0x4,%edi
  800c02:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c05:	c1 e9 02             	shr    $0x2,%ecx
  800c08:	fd                   	std    
  800c09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0b:	eb 09                	jmp    800c16 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c0d:	83 ef 01             	sub    $0x1,%edi
  800c10:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c13:	fd                   	std    
  800c14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c16:	fc                   	cld    
  800c17:	eb 1d                	jmp    800c36 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c19:	89 f2                	mov    %esi,%edx
  800c1b:	09 c2                	or     %eax,%edx
  800c1d:	f6 c2 03             	test   $0x3,%dl
  800c20:	75 0f                	jne    800c31 <memmove+0x5f>
  800c22:	f6 c1 03             	test   $0x3,%cl
  800c25:	75 0a                	jne    800c31 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c27:	c1 e9 02             	shr    $0x2,%ecx
  800c2a:	89 c7                	mov    %eax,%edi
  800c2c:	fc                   	cld    
  800c2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c2f:	eb 05                	jmp    800c36 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c31:	89 c7                	mov    %eax,%edi
  800c33:	fc                   	cld    
  800c34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c3d:	ff 75 10             	pushl  0x10(%ebp)
  800c40:	ff 75 0c             	pushl  0xc(%ebp)
  800c43:	ff 75 08             	pushl  0x8(%ebp)
  800c46:	e8 87 ff ff ff       	call   800bd2 <memmove>
}
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    

00800c4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c58:	89 c6                	mov    %eax,%esi
  800c5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c5d:	eb 1a                	jmp    800c79 <memcmp+0x2c>
		if (*s1 != *s2)
  800c5f:	0f b6 08             	movzbl (%eax),%ecx
  800c62:	0f b6 1a             	movzbl (%edx),%ebx
  800c65:	38 d9                	cmp    %bl,%cl
  800c67:	74 0a                	je     800c73 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c69:	0f b6 c1             	movzbl %cl,%eax
  800c6c:	0f b6 db             	movzbl %bl,%ebx
  800c6f:	29 d8                	sub    %ebx,%eax
  800c71:	eb 0f                	jmp    800c82 <memcmp+0x35>
		s1++, s2++;
  800c73:	83 c0 01             	add    $0x1,%eax
  800c76:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c79:	39 f0                	cmp    %esi,%eax
  800c7b:	75 e2                	jne    800c5f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	53                   	push   %ebx
  800c8a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c8d:	89 c1                	mov    %eax,%ecx
  800c8f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c92:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c96:	eb 0a                	jmp    800ca2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c98:	0f b6 10             	movzbl (%eax),%edx
  800c9b:	39 da                	cmp    %ebx,%edx
  800c9d:	74 07                	je     800ca6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c9f:	83 c0 01             	add    $0x1,%eax
  800ca2:	39 c8                	cmp    %ecx,%eax
  800ca4:	72 f2                	jb     800c98 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
  800caf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb5:	eb 03                	jmp    800cba <strtol+0x11>
		s++;
  800cb7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cba:	0f b6 01             	movzbl (%ecx),%eax
  800cbd:	3c 20                	cmp    $0x20,%al
  800cbf:	74 f6                	je     800cb7 <strtol+0xe>
  800cc1:	3c 09                	cmp    $0x9,%al
  800cc3:	74 f2                	je     800cb7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cc5:	3c 2b                	cmp    $0x2b,%al
  800cc7:	75 0a                	jne    800cd3 <strtol+0x2a>
		s++;
  800cc9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ccc:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd1:	eb 11                	jmp    800ce4 <strtol+0x3b>
  800cd3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cd8:	3c 2d                	cmp    $0x2d,%al
  800cda:	75 08                	jne    800ce4 <strtol+0x3b>
		s++, neg = 1;
  800cdc:	83 c1 01             	add    $0x1,%ecx
  800cdf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ce4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cea:	75 15                	jne    800d01 <strtol+0x58>
  800cec:	80 39 30             	cmpb   $0x30,(%ecx)
  800cef:	75 10                	jne    800d01 <strtol+0x58>
  800cf1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cf5:	75 7c                	jne    800d73 <strtol+0xca>
		s += 2, base = 16;
  800cf7:	83 c1 02             	add    $0x2,%ecx
  800cfa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cff:	eb 16                	jmp    800d17 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d01:	85 db                	test   %ebx,%ebx
  800d03:	75 12                	jne    800d17 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d05:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d0a:	80 39 30             	cmpb   $0x30,(%ecx)
  800d0d:	75 08                	jne    800d17 <strtol+0x6e>
		s++, base = 8;
  800d0f:	83 c1 01             	add    $0x1,%ecx
  800d12:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d17:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d1f:	0f b6 11             	movzbl (%ecx),%edx
  800d22:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d25:	89 f3                	mov    %esi,%ebx
  800d27:	80 fb 09             	cmp    $0x9,%bl
  800d2a:	77 08                	ja     800d34 <strtol+0x8b>
			dig = *s - '0';
  800d2c:	0f be d2             	movsbl %dl,%edx
  800d2f:	83 ea 30             	sub    $0x30,%edx
  800d32:	eb 22                	jmp    800d56 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d34:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d37:	89 f3                	mov    %esi,%ebx
  800d39:	80 fb 19             	cmp    $0x19,%bl
  800d3c:	77 08                	ja     800d46 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d3e:	0f be d2             	movsbl %dl,%edx
  800d41:	83 ea 57             	sub    $0x57,%edx
  800d44:	eb 10                	jmp    800d56 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d46:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d49:	89 f3                	mov    %esi,%ebx
  800d4b:	80 fb 19             	cmp    $0x19,%bl
  800d4e:	77 16                	ja     800d66 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d50:	0f be d2             	movsbl %dl,%edx
  800d53:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d56:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d59:	7d 0b                	jge    800d66 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d5b:	83 c1 01             	add    $0x1,%ecx
  800d5e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d62:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d64:	eb b9                	jmp    800d1f <strtol+0x76>

	if (endptr)
  800d66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d6a:	74 0d                	je     800d79 <strtol+0xd0>
		*endptr = (char *) s;
  800d6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d6f:	89 0e                	mov    %ecx,(%esi)
  800d71:	eb 06                	jmp    800d79 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d73:	85 db                	test   %ebx,%ebx
  800d75:	74 98                	je     800d0f <strtol+0x66>
  800d77:	eb 9e                	jmp    800d17 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d79:	89 c2                	mov    %eax,%edx
  800d7b:	f7 da                	neg    %edx
  800d7d:	85 ff                	test   %edi,%edi
  800d7f:	0f 45 c2             	cmovne %edx,%eax
}
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	89 c3                	mov    %eax,%ebx
  800d9a:	89 c7                	mov    %eax,%edi
  800d9c:	89 c6                	mov    %eax,%esi
  800d9e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	ba 00 00 00 00       	mov    $0x0,%edx
  800db0:	b8 01 00 00 00       	mov    $0x1,%eax
  800db5:	89 d1                	mov    %edx,%ecx
  800db7:	89 d3                	mov    %edx,%ebx
  800db9:	89 d7                	mov    %edx,%edi
  800dbb:	89 d6                	mov    %edx,%esi
  800dbd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd2:	b8 03 00 00 00       	mov    $0x3,%eax
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 cb                	mov    %ecx,%ebx
  800ddc:	89 cf                	mov    %ecx,%edi
  800dde:	89 ce                	mov    %ecx,%esi
  800de0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 17                	jle    800dfd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	50                   	push   %eax
  800dea:	6a 03                	push   $0x3
  800dec:	68 4f 2a 80 00       	push   $0x802a4f
  800df1:	6a 23                	push   $0x23
  800df3:	68 6c 2a 80 00       	push   $0x802a6c
  800df8:	e8 f2 f4 ff ff       	call   8002ef <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e10:	b8 02 00 00 00       	mov    $0x2,%eax
  800e15:	89 d1                	mov    %edx,%ecx
  800e17:	89 d3                	mov    %edx,%ebx
  800e19:	89 d7                	mov    %edx,%edi
  800e1b:	89 d6                	mov    %edx,%esi
  800e1d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_yield>:

void
sys_yield(void)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e34:	89 d1                	mov    %edx,%ecx
  800e36:	89 d3                	mov    %edx,%ebx
  800e38:	89 d7                	mov    %edx,%edi
  800e3a:	89 d6                	mov    %edx,%esi
  800e3c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4c:	be 00 00 00 00       	mov    $0x0,%esi
  800e51:	b8 04 00 00 00       	mov    $0x4,%eax
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5f:	89 f7                	mov    %esi,%edi
  800e61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e63:	85 c0                	test   %eax,%eax
  800e65:	7e 17                	jle    800e7e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e67:	83 ec 0c             	sub    $0xc,%esp
  800e6a:	50                   	push   %eax
  800e6b:	6a 04                	push   $0x4
  800e6d:	68 4f 2a 80 00       	push   $0x802a4f
  800e72:	6a 23                	push   $0x23
  800e74:	68 6c 2a 80 00       	push   $0x802a6c
  800e79:	e8 71 f4 ff ff       	call   8002ef <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea0:	8b 75 18             	mov    0x18(%ebp),%esi
  800ea3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	7e 17                	jle    800ec0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea9:	83 ec 0c             	sub    $0xc,%esp
  800eac:	50                   	push   %eax
  800ead:	6a 05                	push   $0x5
  800eaf:	68 4f 2a 80 00       	push   $0x802a4f
  800eb4:	6a 23                	push   $0x23
  800eb6:	68 6c 2a 80 00       	push   $0x802a6c
  800ebb:	e8 2f f4 ff ff       	call   8002ef <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ec0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	57                   	push   %edi
  800ecc:	56                   	push   %esi
  800ecd:	53                   	push   %ebx
  800ece:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed6:	b8 06 00 00 00       	mov    $0x6,%eax
  800edb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ede:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee1:	89 df                	mov    %ebx,%edi
  800ee3:	89 de                	mov    %ebx,%esi
  800ee5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	7e 17                	jle    800f02 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eeb:	83 ec 0c             	sub    $0xc,%esp
  800eee:	50                   	push   %eax
  800eef:	6a 06                	push   $0x6
  800ef1:	68 4f 2a 80 00       	push   $0x802a4f
  800ef6:	6a 23                	push   $0x23
  800ef8:	68 6c 2a 80 00       	push   $0x802a6c
  800efd:	e8 ed f3 ff ff       	call   8002ef <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	57                   	push   %edi
  800f0e:	56                   	push   %esi
  800f0f:	53                   	push   %ebx
  800f10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f18:	b8 08 00 00 00       	mov    $0x8,%eax
  800f1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f20:	8b 55 08             	mov    0x8(%ebp),%edx
  800f23:	89 df                	mov    %ebx,%edi
  800f25:	89 de                	mov    %ebx,%esi
  800f27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	7e 17                	jle    800f44 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2d:	83 ec 0c             	sub    $0xc,%esp
  800f30:	50                   	push   %eax
  800f31:	6a 08                	push   $0x8
  800f33:	68 4f 2a 80 00       	push   $0x802a4f
  800f38:	6a 23                	push   $0x23
  800f3a:	68 6c 2a 80 00       	push   $0x802a6c
  800f3f:	e8 ab f3 ff ff       	call   8002ef <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	57                   	push   %edi
  800f50:	56                   	push   %esi
  800f51:	53                   	push   %ebx
  800f52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5a:	b8 09 00 00 00       	mov    $0x9,%eax
  800f5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f62:	8b 55 08             	mov    0x8(%ebp),%edx
  800f65:	89 df                	mov    %ebx,%edi
  800f67:	89 de                	mov    %ebx,%esi
  800f69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	7e 17                	jle    800f86 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6f:	83 ec 0c             	sub    $0xc,%esp
  800f72:	50                   	push   %eax
  800f73:	6a 09                	push   $0x9
  800f75:	68 4f 2a 80 00       	push   $0x802a4f
  800f7a:	6a 23                	push   $0x23
  800f7c:	68 6c 2a 80 00       	push   $0x802a6c
  800f81:	e8 69 f3 ff ff       	call   8002ef <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5f                   	pop    %edi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	57                   	push   %edi
  800f92:	56                   	push   %esi
  800f93:	53                   	push   %ebx
  800f94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fa1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa7:	89 df                	mov    %ebx,%edi
  800fa9:	89 de                	mov    %ebx,%esi
  800fab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fad:	85 c0                	test   %eax,%eax
  800faf:	7e 17                	jle    800fc8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb1:	83 ec 0c             	sub    $0xc,%esp
  800fb4:	50                   	push   %eax
  800fb5:	6a 0a                	push   $0xa
  800fb7:	68 4f 2a 80 00       	push   $0x802a4f
  800fbc:	6a 23                	push   $0x23
  800fbe:	68 6c 2a 80 00       	push   $0x802a6c
  800fc3:	e8 27 f3 ff ff       	call   8002ef <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5f                   	pop    %edi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd6:	be 00 00 00 00       	mov    $0x0,%esi
  800fdb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fe0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fec:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fee:	5b                   	pop    %ebx
  800fef:	5e                   	pop    %esi
  800ff0:	5f                   	pop    %edi
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    

00800ff3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800ffc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801001:	b8 0d 00 00 00       	mov    $0xd,%eax
  801006:	8b 55 08             	mov    0x8(%ebp),%edx
  801009:	89 cb                	mov    %ecx,%ebx
  80100b:	89 cf                	mov    %ecx,%edi
  80100d:	89 ce                	mov    %ecx,%esi
  80100f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801011:	85 c0                	test   %eax,%eax
  801013:	7e 17                	jle    80102c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801015:	83 ec 0c             	sub    $0xc,%esp
  801018:	50                   	push   %eax
  801019:	6a 0d                	push   $0xd
  80101b:	68 4f 2a 80 00       	push   $0x802a4f
  801020:	6a 23                	push   $0x23
  801022:	68 6c 2a 80 00       	push   $0x802a6c
  801027:	e8 c3 f2 ff ff       	call   8002ef <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80102c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5f                   	pop    %edi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	57                   	push   %edi
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801044:	8b 55 08             	mov    0x8(%ebp),%edx
  801047:	89 cb                	mov    %ecx,%ebx
  801049:	89 cf                	mov    %ecx,%edi
  80104b:	89 ce                	mov    %ecx,%esi
  80104d:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	57                   	push   %edi
  801058:	56                   	push   %esi
  801059:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80105f:	b8 0f 00 00 00       	mov    $0xf,%eax
  801064:	8b 55 08             	mov    0x8(%ebp),%edx
  801067:	89 cb                	mov    %ecx,%ebx
  801069:	89 cf                	mov    %ecx,%edi
  80106b:	89 ce                	mov    %ecx,%esi
  80106d:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  80106f:	5b                   	pop    %ebx
  801070:	5e                   	pop    %esi
  801071:	5f                   	pop    %edi
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    

00801074 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
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
  80107f:	b8 10 00 00 00       	mov    $0x10,%eax
  801084:	8b 55 08             	mov    0x8(%ebp),%edx
  801087:	89 cb                	mov    %ecx,%ebx
  801089:	89 cf                	mov    %ecx,%edi
  80108b:	89 ce                	mov    %ecx,%esi
  80108d:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	53                   	push   %ebx
  801098:	83 ec 04             	sub    $0x4,%esp
  80109b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80109e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8010a0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8010a4:	74 11                	je     8010b7 <pgfault+0x23>
  8010a6:	89 d8                	mov    %ebx,%eax
  8010a8:	c1 e8 0c             	shr    $0xc,%eax
  8010ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b2:	f6 c4 08             	test   $0x8,%ah
  8010b5:	75 14                	jne    8010cb <pgfault+0x37>
		panic("faulting access");
  8010b7:	83 ec 04             	sub    $0x4,%esp
  8010ba:	68 7a 2a 80 00       	push   $0x802a7a
  8010bf:	6a 1f                	push   $0x1f
  8010c1:	68 8a 2a 80 00       	push   $0x802a8a
  8010c6:	e8 24 f2 ff ff       	call   8002ef <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8010cb:	83 ec 04             	sub    $0x4,%esp
  8010ce:	6a 07                	push   $0x7
  8010d0:	68 00 f0 7f 00       	push   $0x7ff000
  8010d5:	6a 00                	push   $0x0
  8010d7:	e8 67 fd ff ff       	call   800e43 <sys_page_alloc>
	if (r < 0) {
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	79 12                	jns    8010f5 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  8010e3:	50                   	push   %eax
  8010e4:	68 95 2a 80 00       	push   $0x802a95
  8010e9:	6a 2d                	push   $0x2d
  8010eb:	68 8a 2a 80 00       	push   $0x802a8a
  8010f0:	e8 fa f1 ff ff       	call   8002ef <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  8010f5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  8010fb:	83 ec 04             	sub    $0x4,%esp
  8010fe:	68 00 10 00 00       	push   $0x1000
  801103:	53                   	push   %ebx
  801104:	68 00 f0 7f 00       	push   $0x7ff000
  801109:	e8 2c fb ff ff       	call   800c3a <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  80110e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801115:	53                   	push   %ebx
  801116:	6a 00                	push   $0x0
  801118:	68 00 f0 7f 00       	push   $0x7ff000
  80111d:	6a 00                	push   $0x0
  80111f:	e8 62 fd ff ff       	call   800e86 <sys_page_map>
	if (r < 0) {
  801124:	83 c4 20             	add    $0x20,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	79 12                	jns    80113d <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80112b:	50                   	push   %eax
  80112c:	68 95 2a 80 00       	push   $0x802a95
  801131:	6a 34                	push   $0x34
  801133:	68 8a 2a 80 00       	push   $0x802a8a
  801138:	e8 b2 f1 ff ff       	call   8002ef <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  80113d:	83 ec 08             	sub    $0x8,%esp
  801140:	68 00 f0 7f 00       	push   $0x7ff000
  801145:	6a 00                	push   $0x0
  801147:	e8 7c fd ff ff       	call   800ec8 <sys_page_unmap>
	if (r < 0) {
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	79 12                	jns    801165 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  801153:	50                   	push   %eax
  801154:	68 95 2a 80 00       	push   $0x802a95
  801159:	6a 38                	push   $0x38
  80115b:	68 8a 2a 80 00       	push   $0x802a8a
  801160:	e8 8a f1 ff ff       	call   8002ef <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  801165:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801168:	c9                   	leave  
  801169:	c3                   	ret    

0080116a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	57                   	push   %edi
  80116e:	56                   	push   %esi
  80116f:	53                   	push   %ebx
  801170:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  801173:	68 94 10 80 00       	push   $0x801094
  801178:	e8 9d 10 00 00       	call   80221a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80117d:	b8 07 00 00 00       	mov    $0x7,%eax
  801182:	cd 30                	int    $0x30
  801184:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	85 c0                	test   %eax,%eax
  80118c:	79 17                	jns    8011a5 <fork+0x3b>
		panic("fork fault %e");
  80118e:	83 ec 04             	sub    $0x4,%esp
  801191:	68 ae 2a 80 00       	push   $0x802aae
  801196:	68 85 00 00 00       	push   $0x85
  80119b:	68 8a 2a 80 00       	push   $0x802a8a
  8011a0:	e8 4a f1 ff ff       	call   8002ef <_panic>
  8011a5:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8011a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011ab:	75 24                	jne    8011d1 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011ad:	e8 53 fc ff ff       	call   800e05 <sys_getenvid>
  8011b2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011b7:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8011bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011c2:	a3 04 44 80 00       	mov    %eax,0x804404
		return 0;
  8011c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cc:	e9 64 01 00 00       	jmp    801335 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8011d1:	83 ec 04             	sub    $0x4,%esp
  8011d4:	6a 07                	push   $0x7
  8011d6:	68 00 f0 bf ee       	push   $0xeebff000
  8011db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011de:	e8 60 fc ff ff       	call   800e43 <sys_page_alloc>
  8011e3:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8011e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8011eb:	89 d8                	mov    %ebx,%eax
  8011ed:	c1 e8 16             	shr    $0x16,%eax
  8011f0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011f7:	a8 01                	test   $0x1,%al
  8011f9:	0f 84 fc 00 00 00    	je     8012fb <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  8011ff:	89 d8                	mov    %ebx,%eax
  801201:	c1 e8 0c             	shr    $0xc,%eax
  801204:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80120b:	f6 c2 01             	test   $0x1,%dl
  80120e:	0f 84 e7 00 00 00    	je     8012fb <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801214:	89 c6                	mov    %eax,%esi
  801216:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801219:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801220:	f6 c6 04             	test   $0x4,%dh
  801223:	74 39                	je     80125e <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801225:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80122c:	83 ec 0c             	sub    $0xc,%esp
  80122f:	25 07 0e 00 00       	and    $0xe07,%eax
  801234:	50                   	push   %eax
  801235:	56                   	push   %esi
  801236:	57                   	push   %edi
  801237:	56                   	push   %esi
  801238:	6a 00                	push   $0x0
  80123a:	e8 47 fc ff ff       	call   800e86 <sys_page_map>
		if (r < 0) {
  80123f:	83 c4 20             	add    $0x20,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	0f 89 b1 00 00 00    	jns    8012fb <fork+0x191>
		    	panic("sys page map fault %e");
  80124a:	83 ec 04             	sub    $0x4,%esp
  80124d:	68 bc 2a 80 00       	push   $0x802abc
  801252:	6a 55                	push   $0x55
  801254:	68 8a 2a 80 00       	push   $0x802a8a
  801259:	e8 91 f0 ff ff       	call   8002ef <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80125e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801265:	f6 c2 02             	test   $0x2,%dl
  801268:	75 0c                	jne    801276 <fork+0x10c>
  80126a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801271:	f6 c4 08             	test   $0x8,%ah
  801274:	74 5b                	je     8012d1 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801276:	83 ec 0c             	sub    $0xc,%esp
  801279:	68 05 08 00 00       	push   $0x805
  80127e:	56                   	push   %esi
  80127f:	57                   	push   %edi
  801280:	56                   	push   %esi
  801281:	6a 00                	push   $0x0
  801283:	e8 fe fb ff ff       	call   800e86 <sys_page_map>
		if (r < 0) {
  801288:	83 c4 20             	add    $0x20,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	79 14                	jns    8012a3 <fork+0x139>
		    	panic("sys page map fault %e");
  80128f:	83 ec 04             	sub    $0x4,%esp
  801292:	68 bc 2a 80 00       	push   $0x802abc
  801297:	6a 5c                	push   $0x5c
  801299:	68 8a 2a 80 00       	push   $0x802a8a
  80129e:	e8 4c f0 ff ff       	call   8002ef <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8012a3:	83 ec 0c             	sub    $0xc,%esp
  8012a6:	68 05 08 00 00       	push   $0x805
  8012ab:	56                   	push   %esi
  8012ac:	6a 00                	push   $0x0
  8012ae:	56                   	push   %esi
  8012af:	6a 00                	push   $0x0
  8012b1:	e8 d0 fb ff ff       	call   800e86 <sys_page_map>
		if (r < 0) {
  8012b6:	83 c4 20             	add    $0x20,%esp
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	79 3e                	jns    8012fb <fork+0x191>
		    	panic("sys page map fault %e");
  8012bd:	83 ec 04             	sub    $0x4,%esp
  8012c0:	68 bc 2a 80 00       	push   $0x802abc
  8012c5:	6a 60                	push   $0x60
  8012c7:	68 8a 2a 80 00       	push   $0x802a8a
  8012cc:	e8 1e f0 ff ff       	call   8002ef <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8012d1:	83 ec 0c             	sub    $0xc,%esp
  8012d4:	6a 05                	push   $0x5
  8012d6:	56                   	push   %esi
  8012d7:	57                   	push   %edi
  8012d8:	56                   	push   %esi
  8012d9:	6a 00                	push   $0x0
  8012db:	e8 a6 fb ff ff       	call   800e86 <sys_page_map>
		if (r < 0) {
  8012e0:	83 c4 20             	add    $0x20,%esp
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	79 14                	jns    8012fb <fork+0x191>
		    	panic("sys page map fault %e");
  8012e7:	83 ec 04             	sub    $0x4,%esp
  8012ea:	68 bc 2a 80 00       	push   $0x802abc
  8012ef:	6a 65                	push   $0x65
  8012f1:	68 8a 2a 80 00       	push   $0x802a8a
  8012f6:	e8 f4 ef ff ff       	call   8002ef <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8012fb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801301:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801307:	0f 85 de fe ff ff    	jne    8011eb <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80130d:	a1 04 44 80 00       	mov    0x804404,%eax
  801312:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	50                   	push   %eax
  80131c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131f:	57                   	push   %edi
  801320:	e8 69 fc ff ff       	call   800f8e <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801325:	83 c4 08             	add    $0x8,%esp
  801328:	6a 02                	push   $0x2
  80132a:	57                   	push   %edi
  80132b:	e8 da fb ff ff       	call   800f0a <sys_env_set_status>
	
	return envid;
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801335:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801338:	5b                   	pop    %ebx
  801339:	5e                   	pop    %esi
  80133a:	5f                   	pop    %edi
  80133b:	5d                   	pop    %ebp
  80133c:	c3                   	ret    

0080133d <sfork>:

envid_t
sfork(void)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801340:	b8 00 00 00 00       	mov    $0x0,%eax
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    

00801347 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  80134d:	8b 45 08             	mov    0x8(%ebp),%eax
  801350:	a3 08 44 80 00       	mov    %eax,0x804408
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801355:	68 b5 02 80 00       	push   $0x8002b5
  80135a:	e8 d5 fc ff ff       	call   801034 <sys_thread_create>

	return id;
}
  80135f:	c9                   	leave  
  801360:	c3                   	ret    

00801361 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  801367:	ff 75 08             	pushl  0x8(%ebp)
  80136a:	e8 e5 fc ff ff       	call   801054 <sys_thread_free>
}
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	c9                   	leave  
  801373:	c3                   	ret    

00801374 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  80137a:	ff 75 08             	pushl  0x8(%ebp)
  80137d:	e8 f2 fc ff ff       	call   801074 <sys_thread_join>
}
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	c9                   	leave  
  801386:	c3                   	ret    

00801387 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	56                   	push   %esi
  80138b:	53                   	push   %ebx
  80138c:	8b 75 08             	mov    0x8(%ebp),%esi
  80138f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801392:	83 ec 04             	sub    $0x4,%esp
  801395:	6a 07                	push   $0x7
  801397:	6a 00                	push   $0x0
  801399:	56                   	push   %esi
  80139a:	e8 a4 fa ff ff       	call   800e43 <sys_page_alloc>
	if (r < 0) {
  80139f:	83 c4 10             	add    $0x10,%esp
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	79 15                	jns    8013bb <queue_append+0x34>
		panic("%e\n", r);
  8013a6:	50                   	push   %eax
  8013a7:	68 4b 2a 80 00       	push   $0x802a4b
  8013ac:	68 d5 00 00 00       	push   $0xd5
  8013b1:	68 8a 2a 80 00       	push   $0x802a8a
  8013b6:	e8 34 ef ff ff       	call   8002ef <_panic>
	}	

	wt->envid = envid;
  8013bb:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  8013c1:	83 3b 00             	cmpl   $0x0,(%ebx)
  8013c4:	75 13                	jne    8013d9 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  8013c6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8013cd:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8013d4:	00 00 00 
  8013d7:	eb 1b                	jmp    8013f4 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  8013d9:	8b 43 04             	mov    0x4(%ebx),%eax
  8013dc:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8013e3:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8013ea:	00 00 00 
		queue->last = wt;
  8013ed:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8013f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f7:	5b                   	pop    %ebx
  8013f8:	5e                   	pop    %esi
  8013f9:	5d                   	pop    %ebp
  8013fa:	c3                   	ret    

008013fb <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	83 ec 08             	sub    $0x8,%esp
  801401:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  801404:	8b 02                	mov    (%edx),%eax
  801406:	85 c0                	test   %eax,%eax
  801408:	75 17                	jne    801421 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  80140a:	83 ec 04             	sub    $0x4,%esp
  80140d:	68 d2 2a 80 00       	push   $0x802ad2
  801412:	68 ec 00 00 00       	push   $0xec
  801417:	68 8a 2a 80 00       	push   $0x802a8a
  80141c:	e8 ce ee ff ff       	call   8002ef <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801421:	8b 48 04             	mov    0x4(%eax),%ecx
  801424:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  801426:	8b 00                	mov    (%eax),%eax
}
  801428:	c9                   	leave  
  801429:	c3                   	ret    

0080142a <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	53                   	push   %ebx
  80142e:	83 ec 04             	sub    $0x4,%esp
  801431:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801434:	b8 01 00 00 00       	mov    $0x1,%eax
  801439:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  80143c:	85 c0                	test   %eax,%eax
  80143e:	74 45                	je     801485 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  801440:	e8 c0 f9 ff ff       	call   800e05 <sys_getenvid>
  801445:	83 ec 08             	sub    $0x8,%esp
  801448:	83 c3 04             	add    $0x4,%ebx
  80144b:	53                   	push   %ebx
  80144c:	50                   	push   %eax
  80144d:	e8 35 ff ff ff       	call   801387 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801452:	e8 ae f9 ff ff       	call   800e05 <sys_getenvid>
  801457:	83 c4 08             	add    $0x8,%esp
  80145a:	6a 04                	push   $0x4
  80145c:	50                   	push   %eax
  80145d:	e8 a8 fa ff ff       	call   800f0a <sys_env_set_status>

		if (r < 0) {
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	85 c0                	test   %eax,%eax
  801467:	79 15                	jns    80147e <mutex_lock+0x54>
			panic("%e\n", r);
  801469:	50                   	push   %eax
  80146a:	68 4b 2a 80 00       	push   $0x802a4b
  80146f:	68 02 01 00 00       	push   $0x102
  801474:	68 8a 2a 80 00       	push   $0x802a8a
  801479:	e8 71 ee ff ff       	call   8002ef <_panic>
		}
		sys_yield();
  80147e:	e8 a1 f9 ff ff       	call   800e24 <sys_yield>
  801483:	eb 08                	jmp    80148d <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  801485:	e8 7b f9 ff ff       	call   800e05 <sys_getenvid>
  80148a:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80148d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801490:	c9                   	leave  
  801491:	c3                   	ret    

00801492 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	53                   	push   %ebx
  801496:	83 ec 04             	sub    $0x4,%esp
  801499:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  80149c:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8014a0:	74 36                	je     8014d8 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8014a2:	83 ec 0c             	sub    $0xc,%esp
  8014a5:	8d 43 04             	lea    0x4(%ebx),%eax
  8014a8:	50                   	push   %eax
  8014a9:	e8 4d ff ff ff       	call   8013fb <queue_pop>
  8014ae:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8014b1:	83 c4 08             	add    $0x8,%esp
  8014b4:	6a 02                	push   $0x2
  8014b6:	50                   	push   %eax
  8014b7:	e8 4e fa ff ff       	call   800f0a <sys_env_set_status>
		if (r < 0) {
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	79 1d                	jns    8014e0 <mutex_unlock+0x4e>
			panic("%e\n", r);
  8014c3:	50                   	push   %eax
  8014c4:	68 4b 2a 80 00       	push   $0x802a4b
  8014c9:	68 16 01 00 00       	push   $0x116
  8014ce:	68 8a 2a 80 00       	push   $0x802a8a
  8014d3:	e8 17 ee ff ff       	call   8002ef <_panic>
  8014d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014dd:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  8014e0:	e8 3f f9 ff ff       	call   800e24 <sys_yield>
}
  8014e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	53                   	push   %ebx
  8014ee:	83 ec 04             	sub    $0x4,%esp
  8014f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8014f4:	e8 0c f9 ff ff       	call   800e05 <sys_getenvid>
  8014f9:	83 ec 04             	sub    $0x4,%esp
  8014fc:	6a 07                	push   $0x7
  8014fe:	53                   	push   %ebx
  8014ff:	50                   	push   %eax
  801500:	e8 3e f9 ff ff       	call   800e43 <sys_page_alloc>
  801505:	83 c4 10             	add    $0x10,%esp
  801508:	85 c0                	test   %eax,%eax
  80150a:	79 15                	jns    801521 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80150c:	50                   	push   %eax
  80150d:	68 ed 2a 80 00       	push   $0x802aed
  801512:	68 23 01 00 00       	push   $0x123
  801517:	68 8a 2a 80 00       	push   $0x802a8a
  80151c:	e8 ce ed ff ff       	call   8002ef <_panic>
	}	
	mtx->locked = 0;
  801521:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  801527:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  80152e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  801535:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  80153c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	56                   	push   %esi
  801545:	53                   	push   %ebx
  801546:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801549:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  80154c:	eb 20                	jmp    80156e <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  80154e:	83 ec 0c             	sub    $0xc,%esp
  801551:	56                   	push   %esi
  801552:	e8 a4 fe ff ff       	call   8013fb <queue_pop>
  801557:	83 c4 08             	add    $0x8,%esp
  80155a:	6a 02                	push   $0x2
  80155c:	50                   	push   %eax
  80155d:	e8 a8 f9 ff ff       	call   800f0a <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  801562:	8b 43 04             	mov    0x4(%ebx),%eax
  801565:	8b 40 04             	mov    0x4(%eax),%eax
  801568:	89 43 04             	mov    %eax,0x4(%ebx)
  80156b:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  80156e:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  801572:	75 da                	jne    80154e <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  801574:	83 ec 04             	sub    $0x4,%esp
  801577:	68 00 10 00 00       	push   $0x1000
  80157c:	6a 00                	push   $0x0
  80157e:	53                   	push   %ebx
  80157f:	e8 01 f6 ff ff       	call   800b85 <memset>
	mtx = NULL;
}
  801584:	83 c4 10             	add    $0x10,%esp
  801587:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158a:	5b                   	pop    %ebx
  80158b:	5e                   	pop    %esi
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801591:	8b 45 08             	mov    0x8(%ebp),%eax
  801594:	05 00 00 00 30       	add    $0x30000000,%eax
  801599:	c1 e8 0c             	shr    $0xc,%eax
}
  80159c:	5d                   	pop    %ebp
  80159d:	c3                   	ret    

0080159e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8015a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a4:	05 00 00 00 30       	add    $0x30000000,%eax
  8015a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8015ae:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8015b3:	5d                   	pop    %ebp
  8015b4:	c3                   	ret    

008015b5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015bb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8015c0:	89 c2                	mov    %eax,%edx
  8015c2:	c1 ea 16             	shr    $0x16,%edx
  8015c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015cc:	f6 c2 01             	test   $0x1,%dl
  8015cf:	74 11                	je     8015e2 <fd_alloc+0x2d>
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	c1 ea 0c             	shr    $0xc,%edx
  8015d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015dd:	f6 c2 01             	test   $0x1,%dl
  8015e0:	75 09                	jne    8015eb <fd_alloc+0x36>
			*fd_store = fd;
  8015e2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e9:	eb 17                	jmp    801602 <fd_alloc+0x4d>
  8015eb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015f0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015f5:	75 c9                	jne    8015c0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015f7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8015fd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801602:	5d                   	pop    %ebp
  801603:	c3                   	ret    

00801604 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80160a:	83 f8 1f             	cmp    $0x1f,%eax
  80160d:	77 36                	ja     801645 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80160f:	c1 e0 0c             	shl    $0xc,%eax
  801612:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801617:	89 c2                	mov    %eax,%edx
  801619:	c1 ea 16             	shr    $0x16,%edx
  80161c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801623:	f6 c2 01             	test   $0x1,%dl
  801626:	74 24                	je     80164c <fd_lookup+0x48>
  801628:	89 c2                	mov    %eax,%edx
  80162a:	c1 ea 0c             	shr    $0xc,%edx
  80162d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801634:	f6 c2 01             	test   $0x1,%dl
  801637:	74 1a                	je     801653 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801639:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163c:	89 02                	mov    %eax,(%edx)
	return 0;
  80163e:	b8 00 00 00 00       	mov    $0x0,%eax
  801643:	eb 13                	jmp    801658 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801645:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164a:	eb 0c                	jmp    801658 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80164c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801651:	eb 05                	jmp    801658 <fd_lookup+0x54>
  801653:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801658:	5d                   	pop    %ebp
  801659:	c3                   	ret    

0080165a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	83 ec 08             	sub    $0x8,%esp
  801660:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801663:	ba 88 2b 80 00       	mov    $0x802b88,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801668:	eb 13                	jmp    80167d <dev_lookup+0x23>
  80166a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80166d:	39 08                	cmp    %ecx,(%eax)
  80166f:	75 0c                	jne    80167d <dev_lookup+0x23>
			*dev = devtab[i];
  801671:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801674:	89 01                	mov    %eax,(%ecx)
			return 0;
  801676:	b8 00 00 00 00       	mov    $0x0,%eax
  80167b:	eb 31                	jmp    8016ae <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80167d:	8b 02                	mov    (%edx),%eax
  80167f:	85 c0                	test   %eax,%eax
  801681:	75 e7                	jne    80166a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801683:	a1 04 44 80 00       	mov    0x804404,%eax
  801688:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80168e:	83 ec 04             	sub    $0x4,%esp
  801691:	51                   	push   %ecx
  801692:	50                   	push   %eax
  801693:	68 08 2b 80 00       	push   $0x802b08
  801698:	e8 2b ed ff ff       	call   8003c8 <cprintf>
	*dev = 0;
  80169d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	56                   	push   %esi
  8016b4:	53                   	push   %ebx
  8016b5:	83 ec 10             	sub    $0x10,%esp
  8016b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8016bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8016be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c1:	50                   	push   %eax
  8016c2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8016c8:	c1 e8 0c             	shr    $0xc,%eax
  8016cb:	50                   	push   %eax
  8016cc:	e8 33 ff ff ff       	call   801604 <fd_lookup>
  8016d1:	83 c4 08             	add    $0x8,%esp
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	78 05                	js     8016dd <fd_close+0x2d>
	    || fd != fd2)
  8016d8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8016db:	74 0c                	je     8016e9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8016dd:	84 db                	test   %bl,%bl
  8016df:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e4:	0f 44 c2             	cmove  %edx,%eax
  8016e7:	eb 41                	jmp    80172a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8016e9:	83 ec 08             	sub    $0x8,%esp
  8016ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ef:	50                   	push   %eax
  8016f0:	ff 36                	pushl  (%esi)
  8016f2:	e8 63 ff ff ff       	call   80165a <dev_lookup>
  8016f7:	89 c3                	mov    %eax,%ebx
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	78 1a                	js     80171a <fd_close+0x6a>
		if (dev->dev_close)
  801700:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801703:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801706:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80170b:	85 c0                	test   %eax,%eax
  80170d:	74 0b                	je     80171a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80170f:	83 ec 0c             	sub    $0xc,%esp
  801712:	56                   	push   %esi
  801713:	ff d0                	call   *%eax
  801715:	89 c3                	mov    %eax,%ebx
  801717:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80171a:	83 ec 08             	sub    $0x8,%esp
  80171d:	56                   	push   %esi
  80171e:	6a 00                	push   $0x0
  801720:	e8 a3 f7 ff ff       	call   800ec8 <sys_page_unmap>
	return r;
  801725:	83 c4 10             	add    $0x10,%esp
  801728:	89 d8                	mov    %ebx,%eax
}
  80172a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172d:	5b                   	pop    %ebx
  80172e:	5e                   	pop    %esi
  80172f:	5d                   	pop    %ebp
  801730:	c3                   	ret    

00801731 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801737:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173a:	50                   	push   %eax
  80173b:	ff 75 08             	pushl  0x8(%ebp)
  80173e:	e8 c1 fe ff ff       	call   801604 <fd_lookup>
  801743:	83 c4 08             	add    $0x8,%esp
  801746:	85 c0                	test   %eax,%eax
  801748:	78 10                	js     80175a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80174a:	83 ec 08             	sub    $0x8,%esp
  80174d:	6a 01                	push   $0x1
  80174f:	ff 75 f4             	pushl  -0xc(%ebp)
  801752:	e8 59 ff ff ff       	call   8016b0 <fd_close>
  801757:	83 c4 10             	add    $0x10,%esp
}
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <close_all>:

void
close_all(void)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	53                   	push   %ebx
  801760:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801763:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801768:	83 ec 0c             	sub    $0xc,%esp
  80176b:	53                   	push   %ebx
  80176c:	e8 c0 ff ff ff       	call   801731 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801771:	83 c3 01             	add    $0x1,%ebx
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	83 fb 20             	cmp    $0x20,%ebx
  80177a:	75 ec                	jne    801768 <close_all+0xc>
		close(i);
}
  80177c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177f:	c9                   	leave  
  801780:	c3                   	ret    

00801781 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	57                   	push   %edi
  801785:	56                   	push   %esi
  801786:	53                   	push   %ebx
  801787:	83 ec 2c             	sub    $0x2c,%esp
  80178a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80178d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801790:	50                   	push   %eax
  801791:	ff 75 08             	pushl  0x8(%ebp)
  801794:	e8 6b fe ff ff       	call   801604 <fd_lookup>
  801799:	83 c4 08             	add    $0x8,%esp
  80179c:	85 c0                	test   %eax,%eax
  80179e:	0f 88 c1 00 00 00    	js     801865 <dup+0xe4>
		return r;
	close(newfdnum);
  8017a4:	83 ec 0c             	sub    $0xc,%esp
  8017a7:	56                   	push   %esi
  8017a8:	e8 84 ff ff ff       	call   801731 <close>

	newfd = INDEX2FD(newfdnum);
  8017ad:	89 f3                	mov    %esi,%ebx
  8017af:	c1 e3 0c             	shl    $0xc,%ebx
  8017b2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8017b8:	83 c4 04             	add    $0x4,%esp
  8017bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017be:	e8 db fd ff ff       	call   80159e <fd2data>
  8017c3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8017c5:	89 1c 24             	mov    %ebx,(%esp)
  8017c8:	e8 d1 fd ff ff       	call   80159e <fd2data>
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8017d3:	89 f8                	mov    %edi,%eax
  8017d5:	c1 e8 16             	shr    $0x16,%eax
  8017d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017df:	a8 01                	test   $0x1,%al
  8017e1:	74 37                	je     80181a <dup+0x99>
  8017e3:	89 f8                	mov    %edi,%eax
  8017e5:	c1 e8 0c             	shr    $0xc,%eax
  8017e8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8017ef:	f6 c2 01             	test   $0x1,%dl
  8017f2:	74 26                	je     80181a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	25 07 0e 00 00       	and    $0xe07,%eax
  801803:	50                   	push   %eax
  801804:	ff 75 d4             	pushl  -0x2c(%ebp)
  801807:	6a 00                	push   $0x0
  801809:	57                   	push   %edi
  80180a:	6a 00                	push   $0x0
  80180c:	e8 75 f6 ff ff       	call   800e86 <sys_page_map>
  801811:	89 c7                	mov    %eax,%edi
  801813:	83 c4 20             	add    $0x20,%esp
  801816:	85 c0                	test   %eax,%eax
  801818:	78 2e                	js     801848 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80181a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80181d:	89 d0                	mov    %edx,%eax
  80181f:	c1 e8 0c             	shr    $0xc,%eax
  801822:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801829:	83 ec 0c             	sub    $0xc,%esp
  80182c:	25 07 0e 00 00       	and    $0xe07,%eax
  801831:	50                   	push   %eax
  801832:	53                   	push   %ebx
  801833:	6a 00                	push   $0x0
  801835:	52                   	push   %edx
  801836:	6a 00                	push   $0x0
  801838:	e8 49 f6 ff ff       	call   800e86 <sys_page_map>
  80183d:	89 c7                	mov    %eax,%edi
  80183f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801842:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801844:	85 ff                	test   %edi,%edi
  801846:	79 1d                	jns    801865 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801848:	83 ec 08             	sub    $0x8,%esp
  80184b:	53                   	push   %ebx
  80184c:	6a 00                	push   $0x0
  80184e:	e8 75 f6 ff ff       	call   800ec8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801853:	83 c4 08             	add    $0x8,%esp
  801856:	ff 75 d4             	pushl  -0x2c(%ebp)
  801859:	6a 00                	push   $0x0
  80185b:	e8 68 f6 ff ff       	call   800ec8 <sys_page_unmap>
	return r;
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	89 f8                	mov    %edi,%eax
}
  801865:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801868:	5b                   	pop    %ebx
  801869:	5e                   	pop    %esi
  80186a:	5f                   	pop    %edi
  80186b:	5d                   	pop    %ebp
  80186c:	c3                   	ret    

0080186d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	53                   	push   %ebx
  801871:	83 ec 14             	sub    $0x14,%esp
  801874:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801877:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80187a:	50                   	push   %eax
  80187b:	53                   	push   %ebx
  80187c:	e8 83 fd ff ff       	call   801604 <fd_lookup>
  801881:	83 c4 08             	add    $0x8,%esp
  801884:	89 c2                	mov    %eax,%edx
  801886:	85 c0                	test   %eax,%eax
  801888:	78 70                	js     8018fa <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80188a:	83 ec 08             	sub    $0x8,%esp
  80188d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801890:	50                   	push   %eax
  801891:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801894:	ff 30                	pushl  (%eax)
  801896:	e8 bf fd ff ff       	call   80165a <dev_lookup>
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	78 4f                	js     8018f1 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8018a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018a5:	8b 42 08             	mov    0x8(%edx),%eax
  8018a8:	83 e0 03             	and    $0x3,%eax
  8018ab:	83 f8 01             	cmp    $0x1,%eax
  8018ae:	75 24                	jne    8018d4 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8018b0:	a1 04 44 80 00       	mov    0x804404,%eax
  8018b5:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8018bb:	83 ec 04             	sub    $0x4,%esp
  8018be:	53                   	push   %ebx
  8018bf:	50                   	push   %eax
  8018c0:	68 4c 2b 80 00       	push   $0x802b4c
  8018c5:	e8 fe ea ff ff       	call   8003c8 <cprintf>
		return -E_INVAL;
  8018ca:	83 c4 10             	add    $0x10,%esp
  8018cd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018d2:	eb 26                	jmp    8018fa <read+0x8d>
	}
	if (!dev->dev_read)
  8018d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d7:	8b 40 08             	mov    0x8(%eax),%eax
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	74 17                	je     8018f5 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8018de:	83 ec 04             	sub    $0x4,%esp
  8018e1:	ff 75 10             	pushl  0x10(%ebp)
  8018e4:	ff 75 0c             	pushl  0xc(%ebp)
  8018e7:	52                   	push   %edx
  8018e8:	ff d0                	call   *%eax
  8018ea:	89 c2                	mov    %eax,%edx
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	eb 09                	jmp    8018fa <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f1:	89 c2                	mov    %eax,%edx
  8018f3:	eb 05                	jmp    8018fa <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8018f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8018fa:	89 d0                	mov    %edx,%eax
  8018fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ff:	c9                   	leave  
  801900:	c3                   	ret    

00801901 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	57                   	push   %edi
  801905:	56                   	push   %esi
  801906:	53                   	push   %ebx
  801907:	83 ec 0c             	sub    $0xc,%esp
  80190a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80190d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801910:	bb 00 00 00 00       	mov    $0x0,%ebx
  801915:	eb 21                	jmp    801938 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801917:	83 ec 04             	sub    $0x4,%esp
  80191a:	89 f0                	mov    %esi,%eax
  80191c:	29 d8                	sub    %ebx,%eax
  80191e:	50                   	push   %eax
  80191f:	89 d8                	mov    %ebx,%eax
  801921:	03 45 0c             	add    0xc(%ebp),%eax
  801924:	50                   	push   %eax
  801925:	57                   	push   %edi
  801926:	e8 42 ff ff ff       	call   80186d <read>
		if (m < 0)
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	85 c0                	test   %eax,%eax
  801930:	78 10                	js     801942 <readn+0x41>
			return m;
		if (m == 0)
  801932:	85 c0                	test   %eax,%eax
  801934:	74 0a                	je     801940 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801936:	01 c3                	add    %eax,%ebx
  801938:	39 f3                	cmp    %esi,%ebx
  80193a:	72 db                	jb     801917 <readn+0x16>
  80193c:	89 d8                	mov    %ebx,%eax
  80193e:	eb 02                	jmp    801942 <readn+0x41>
  801940:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801942:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801945:	5b                   	pop    %ebx
  801946:	5e                   	pop    %esi
  801947:	5f                   	pop    %edi
  801948:	5d                   	pop    %ebp
  801949:	c3                   	ret    

0080194a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	53                   	push   %ebx
  80194e:	83 ec 14             	sub    $0x14,%esp
  801951:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801954:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801957:	50                   	push   %eax
  801958:	53                   	push   %ebx
  801959:	e8 a6 fc ff ff       	call   801604 <fd_lookup>
  80195e:	83 c4 08             	add    $0x8,%esp
  801961:	89 c2                	mov    %eax,%edx
  801963:	85 c0                	test   %eax,%eax
  801965:	78 6b                	js     8019d2 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801967:	83 ec 08             	sub    $0x8,%esp
  80196a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196d:	50                   	push   %eax
  80196e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801971:	ff 30                	pushl  (%eax)
  801973:	e8 e2 fc ff ff       	call   80165a <dev_lookup>
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	85 c0                	test   %eax,%eax
  80197d:	78 4a                	js     8019c9 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80197f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801982:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801986:	75 24                	jne    8019ac <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801988:	a1 04 44 80 00       	mov    0x804404,%eax
  80198d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801993:	83 ec 04             	sub    $0x4,%esp
  801996:	53                   	push   %ebx
  801997:	50                   	push   %eax
  801998:	68 68 2b 80 00       	push   $0x802b68
  80199d:	e8 26 ea ff ff       	call   8003c8 <cprintf>
		return -E_INVAL;
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8019aa:	eb 26                	jmp    8019d2 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8019ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019af:	8b 52 0c             	mov    0xc(%edx),%edx
  8019b2:	85 d2                	test   %edx,%edx
  8019b4:	74 17                	je     8019cd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8019b6:	83 ec 04             	sub    $0x4,%esp
  8019b9:	ff 75 10             	pushl  0x10(%ebp)
  8019bc:	ff 75 0c             	pushl  0xc(%ebp)
  8019bf:	50                   	push   %eax
  8019c0:	ff d2                	call   *%edx
  8019c2:	89 c2                	mov    %eax,%edx
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	eb 09                	jmp    8019d2 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c9:	89 c2                	mov    %eax,%edx
  8019cb:	eb 05                	jmp    8019d2 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8019cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8019d2:	89 d0                	mov    %edx,%eax
  8019d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d7:	c9                   	leave  
  8019d8:	c3                   	ret    

008019d9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019df:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8019e2:	50                   	push   %eax
  8019e3:	ff 75 08             	pushl  0x8(%ebp)
  8019e6:	e8 19 fc ff ff       	call   801604 <fd_lookup>
  8019eb:	83 c4 08             	add    $0x8,%esp
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	78 0e                	js     801a00 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8019f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8019f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019f8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8019fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	53                   	push   %ebx
  801a06:	83 ec 14             	sub    $0x14,%esp
  801a09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a0c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a0f:	50                   	push   %eax
  801a10:	53                   	push   %ebx
  801a11:	e8 ee fb ff ff       	call   801604 <fd_lookup>
  801a16:	83 c4 08             	add    $0x8,%esp
  801a19:	89 c2                	mov    %eax,%edx
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	78 68                	js     801a87 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a1f:	83 ec 08             	sub    $0x8,%esp
  801a22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a25:	50                   	push   %eax
  801a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a29:	ff 30                	pushl  (%eax)
  801a2b:	e8 2a fc ff ff       	call   80165a <dev_lookup>
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	85 c0                	test   %eax,%eax
  801a35:	78 47                	js     801a7e <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a3e:	75 24                	jne    801a64 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801a40:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a45:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801a4b:	83 ec 04             	sub    $0x4,%esp
  801a4e:	53                   	push   %ebx
  801a4f:	50                   	push   %eax
  801a50:	68 28 2b 80 00       	push   $0x802b28
  801a55:	e8 6e e9 ff ff       	call   8003c8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801a62:	eb 23                	jmp    801a87 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801a64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a67:	8b 52 18             	mov    0x18(%edx),%edx
  801a6a:	85 d2                	test   %edx,%edx
  801a6c:	74 14                	je     801a82 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a6e:	83 ec 08             	sub    $0x8,%esp
  801a71:	ff 75 0c             	pushl  0xc(%ebp)
  801a74:	50                   	push   %eax
  801a75:	ff d2                	call   *%edx
  801a77:	89 c2                	mov    %eax,%edx
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	eb 09                	jmp    801a87 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a7e:	89 c2                	mov    %eax,%edx
  801a80:	eb 05                	jmp    801a87 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a82:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801a87:	89 d0                	mov    %edx,%eax
  801a89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8c:	c9                   	leave  
  801a8d:	c3                   	ret    

00801a8e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	53                   	push   %ebx
  801a92:	83 ec 14             	sub    $0x14,%esp
  801a95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a9b:	50                   	push   %eax
  801a9c:	ff 75 08             	pushl  0x8(%ebp)
  801a9f:	e8 60 fb ff ff       	call   801604 <fd_lookup>
  801aa4:	83 c4 08             	add    $0x8,%esp
  801aa7:	89 c2                	mov    %eax,%edx
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	78 58                	js     801b05 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801aad:	83 ec 08             	sub    $0x8,%esp
  801ab0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab3:	50                   	push   %eax
  801ab4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ab7:	ff 30                	pushl  (%eax)
  801ab9:	e8 9c fb ff ff       	call   80165a <dev_lookup>
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	78 37                	js     801afc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801acc:	74 32                	je     801b00 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ace:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801ad1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801ad8:	00 00 00 
	stat->st_isdir = 0;
  801adb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ae2:	00 00 00 
	stat->st_dev = dev;
  801ae5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801aeb:	83 ec 08             	sub    $0x8,%esp
  801aee:	53                   	push   %ebx
  801aef:	ff 75 f0             	pushl  -0x10(%ebp)
  801af2:	ff 50 14             	call   *0x14(%eax)
  801af5:	89 c2                	mov    %eax,%edx
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	eb 09                	jmp    801b05 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801afc:	89 c2                	mov    %eax,%edx
  801afe:	eb 05                	jmp    801b05 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801b00:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801b05:	89 d0                	mov    %edx,%eax
  801b07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	56                   	push   %esi
  801b10:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b11:	83 ec 08             	sub    $0x8,%esp
  801b14:	6a 00                	push   $0x0
  801b16:	ff 75 08             	pushl  0x8(%ebp)
  801b19:	e8 e3 01 00 00       	call   801d01 <open>
  801b1e:	89 c3                	mov    %eax,%ebx
  801b20:	83 c4 10             	add    $0x10,%esp
  801b23:	85 c0                	test   %eax,%eax
  801b25:	78 1b                	js     801b42 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801b27:	83 ec 08             	sub    $0x8,%esp
  801b2a:	ff 75 0c             	pushl  0xc(%ebp)
  801b2d:	50                   	push   %eax
  801b2e:	e8 5b ff ff ff       	call   801a8e <fstat>
  801b33:	89 c6                	mov    %eax,%esi
	close(fd);
  801b35:	89 1c 24             	mov    %ebx,(%esp)
  801b38:	e8 f4 fb ff ff       	call   801731 <close>
	return r;
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	89 f0                	mov    %esi,%eax
}
  801b42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b45:	5b                   	pop    %ebx
  801b46:	5e                   	pop    %esi
  801b47:	5d                   	pop    %ebp
  801b48:	c3                   	ret    

00801b49 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	56                   	push   %esi
  801b4d:	53                   	push   %ebx
  801b4e:	89 c6                	mov    %eax,%esi
  801b50:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801b52:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  801b59:	75 12                	jne    801b6d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b5b:	83 ec 0c             	sub    $0xc,%esp
  801b5e:	6a 01                	push   $0x1
  801b60:	e8 21 08 00 00       	call   802386 <ipc_find_env>
  801b65:	a3 00 44 80 00       	mov    %eax,0x804400
  801b6a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b6d:	6a 07                	push   $0x7
  801b6f:	68 00 50 80 00       	push   $0x805000
  801b74:	56                   	push   %esi
  801b75:	ff 35 00 44 80 00    	pushl  0x804400
  801b7b:	e8 a4 07 00 00       	call   802324 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b80:	83 c4 0c             	add    $0xc,%esp
  801b83:	6a 00                	push   $0x0
  801b85:	53                   	push   %ebx
  801b86:	6a 00                	push   $0x0
  801b88:	e8 1c 07 00 00       	call   8022a9 <ipc_recv>
}
  801b8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b90:	5b                   	pop    %ebx
  801b91:	5e                   	pop    %esi
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    

00801b94 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9d:	8b 40 0c             	mov    0xc(%eax),%eax
  801ba0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801bad:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb2:	b8 02 00 00 00       	mov    $0x2,%eax
  801bb7:	e8 8d ff ff ff       	call   801b49 <fsipc>
}
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    

00801bbe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc7:	8b 40 0c             	mov    0xc(%eax),%eax
  801bca:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd4:	b8 06 00 00 00       	mov    $0x6,%eax
  801bd9:	e8 6b ff ff ff       	call   801b49 <fsipc>
}
  801bde:	c9                   	leave  
  801bdf:	c3                   	ret    

00801be0 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	53                   	push   %ebx
  801be4:	83 ec 04             	sub    $0x4,%esp
  801be7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801bea:	8b 45 08             	mov    0x8(%ebp),%eax
  801bed:	8b 40 0c             	mov    0xc(%eax),%eax
  801bf0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  801bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  801bff:	e8 45 ff ff ff       	call   801b49 <fsipc>
  801c04:	85 c0                	test   %eax,%eax
  801c06:	78 2c                	js     801c34 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c08:	83 ec 08             	sub    $0x8,%esp
  801c0b:	68 00 50 80 00       	push   $0x805000
  801c10:	53                   	push   %ebx
  801c11:	e8 2a ee ff ff       	call   800a40 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c16:	a1 80 50 80 00       	mov    0x805080,%eax
  801c1b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c21:	a1 84 50 80 00       	mov    0x805084,%eax
  801c26:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801c2c:	83 c4 10             	add    $0x10,%esp
  801c2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c37:	c9                   	leave  
  801c38:	c3                   	ret    

00801c39 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	83 ec 0c             	sub    $0xc,%esp
  801c3f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c42:	8b 55 08             	mov    0x8(%ebp),%edx
  801c45:	8b 52 0c             	mov    0xc(%edx),%edx
  801c48:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801c4e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c53:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801c58:	0f 47 c2             	cmova  %edx,%eax
  801c5b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801c60:	50                   	push   %eax
  801c61:	ff 75 0c             	pushl  0xc(%ebp)
  801c64:	68 08 50 80 00       	push   $0x805008
  801c69:	e8 64 ef ff ff       	call   800bd2 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801c6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c73:	b8 04 00 00 00       	mov    $0x4,%eax
  801c78:	e8 cc fe ff ff       	call   801b49 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801c7d:	c9                   	leave  
  801c7e:	c3                   	ret    

00801c7f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c87:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8a:	8b 40 0c             	mov    0xc(%eax),%eax
  801c8d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801c92:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c98:	ba 00 00 00 00       	mov    $0x0,%edx
  801c9d:	b8 03 00 00 00       	mov    $0x3,%eax
  801ca2:	e8 a2 fe ff ff       	call   801b49 <fsipc>
  801ca7:	89 c3                	mov    %eax,%ebx
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	78 4b                	js     801cf8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801cad:	39 c6                	cmp    %eax,%esi
  801caf:	73 16                	jae    801cc7 <devfile_read+0x48>
  801cb1:	68 98 2b 80 00       	push   $0x802b98
  801cb6:	68 9f 2b 80 00       	push   $0x802b9f
  801cbb:	6a 7c                	push   $0x7c
  801cbd:	68 b4 2b 80 00       	push   $0x802bb4
  801cc2:	e8 28 e6 ff ff       	call   8002ef <_panic>
	assert(r <= PGSIZE);
  801cc7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ccc:	7e 16                	jle    801ce4 <devfile_read+0x65>
  801cce:	68 bf 2b 80 00       	push   $0x802bbf
  801cd3:	68 9f 2b 80 00       	push   $0x802b9f
  801cd8:	6a 7d                	push   $0x7d
  801cda:	68 b4 2b 80 00       	push   $0x802bb4
  801cdf:	e8 0b e6 ff ff       	call   8002ef <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ce4:	83 ec 04             	sub    $0x4,%esp
  801ce7:	50                   	push   %eax
  801ce8:	68 00 50 80 00       	push   $0x805000
  801ced:	ff 75 0c             	pushl  0xc(%ebp)
  801cf0:	e8 dd ee ff ff       	call   800bd2 <memmove>
	return r;
  801cf5:	83 c4 10             	add    $0x10,%esp
}
  801cf8:	89 d8                	mov    %ebx,%eax
  801cfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    

00801d01 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	53                   	push   %ebx
  801d05:	83 ec 20             	sub    $0x20,%esp
  801d08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801d0b:	53                   	push   %ebx
  801d0c:	e8 f6 ec ff ff       	call   800a07 <strlen>
  801d11:	83 c4 10             	add    $0x10,%esp
  801d14:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d19:	7f 67                	jg     801d82 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d1b:	83 ec 0c             	sub    $0xc,%esp
  801d1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d21:	50                   	push   %eax
  801d22:	e8 8e f8 ff ff       	call   8015b5 <fd_alloc>
  801d27:	83 c4 10             	add    $0x10,%esp
		return r;
  801d2a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d2c:	85 c0                	test   %eax,%eax
  801d2e:	78 57                	js     801d87 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d30:	83 ec 08             	sub    $0x8,%esp
  801d33:	53                   	push   %ebx
  801d34:	68 00 50 80 00       	push   $0x805000
  801d39:	e8 02 ed ff ff       	call   800a40 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d41:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d49:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4e:	e8 f6 fd ff ff       	call   801b49 <fsipc>
  801d53:	89 c3                	mov    %eax,%ebx
  801d55:	83 c4 10             	add    $0x10,%esp
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	79 14                	jns    801d70 <open+0x6f>
		fd_close(fd, 0);
  801d5c:	83 ec 08             	sub    $0x8,%esp
  801d5f:	6a 00                	push   $0x0
  801d61:	ff 75 f4             	pushl  -0xc(%ebp)
  801d64:	e8 47 f9 ff ff       	call   8016b0 <fd_close>
		return r;
  801d69:	83 c4 10             	add    $0x10,%esp
  801d6c:	89 da                	mov    %ebx,%edx
  801d6e:	eb 17                	jmp    801d87 <open+0x86>
	}

	return fd2num(fd);
  801d70:	83 ec 0c             	sub    $0xc,%esp
  801d73:	ff 75 f4             	pushl  -0xc(%ebp)
  801d76:	e8 13 f8 ff ff       	call   80158e <fd2num>
  801d7b:	89 c2                	mov    %eax,%edx
  801d7d:	83 c4 10             	add    $0x10,%esp
  801d80:	eb 05                	jmp    801d87 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d82:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d87:	89 d0                	mov    %edx,%eax
  801d89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d8c:	c9                   	leave  
  801d8d:	c3                   	ret    

00801d8e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d94:	ba 00 00 00 00       	mov    $0x0,%edx
  801d99:	b8 08 00 00 00       	mov    $0x8,%eax
  801d9e:	e8 a6 fd ff ff       	call   801b49 <fsipc>
}
  801da3:	c9                   	leave  
  801da4:	c3                   	ret    

00801da5 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801da5:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801da9:	7e 37                	jle    801de2 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	53                   	push   %ebx
  801daf:	83 ec 08             	sub    $0x8,%esp
  801db2:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801db4:	ff 70 04             	pushl  0x4(%eax)
  801db7:	8d 40 10             	lea    0x10(%eax),%eax
  801dba:	50                   	push   %eax
  801dbb:	ff 33                	pushl  (%ebx)
  801dbd:	e8 88 fb ff ff       	call   80194a <write>
		if (result > 0)
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	7e 03                	jle    801dcc <writebuf+0x27>
			b->result += result;
  801dc9:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801dcc:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dcf:	74 0d                	je     801dde <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd8:	0f 4f c2             	cmovg  %edx,%eax
  801ddb:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801dde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de1:	c9                   	leave  
  801de2:	f3 c3                	repz ret 

00801de4 <putch>:

static void
putch(int ch, void *thunk)
{
  801de4:	55                   	push   %ebp
  801de5:	89 e5                	mov    %esp,%ebp
  801de7:	53                   	push   %ebx
  801de8:	83 ec 04             	sub    $0x4,%esp
  801deb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801dee:	8b 53 04             	mov    0x4(%ebx),%edx
  801df1:	8d 42 01             	lea    0x1(%edx),%eax
  801df4:	89 43 04             	mov    %eax,0x4(%ebx)
  801df7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dfa:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801dfe:	3d 00 01 00 00       	cmp    $0x100,%eax
  801e03:	75 0e                	jne    801e13 <putch+0x2f>
		writebuf(b);
  801e05:	89 d8                	mov    %ebx,%eax
  801e07:	e8 99 ff ff ff       	call   801da5 <writebuf>
		b->idx = 0;
  801e0c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801e13:	83 c4 04             	add    $0x4,%esp
  801e16:	5b                   	pop    %ebx
  801e17:	5d                   	pop    %ebp
  801e18:	c3                   	ret    

00801e19 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801e22:	8b 45 08             	mov    0x8(%ebp),%eax
  801e25:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801e2b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801e32:	00 00 00 
	b.result = 0;
  801e35:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801e3c:	00 00 00 
	b.error = 1;
  801e3f:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801e46:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801e49:	ff 75 10             	pushl  0x10(%ebp)
  801e4c:	ff 75 0c             	pushl  0xc(%ebp)
  801e4f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801e55:	50                   	push   %eax
  801e56:	68 e4 1d 80 00       	push   $0x801de4
  801e5b:	e8 9f e6 ff ff       	call   8004ff <vprintfmt>
	if (b.idx > 0)
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801e6a:	7e 0b                	jle    801e77 <vfprintf+0x5e>
		writebuf(&b);
  801e6c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801e72:	e8 2e ff ff ff       	call   801da5 <writebuf>

	return (b.result ? b.result : b.error);
  801e77:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801e86:	c9                   	leave  
  801e87:	c3                   	ret    

00801e88 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801e8e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801e91:	50                   	push   %eax
  801e92:	ff 75 0c             	pushl  0xc(%ebp)
  801e95:	ff 75 08             	pushl  0x8(%ebp)
  801e98:	e8 7c ff ff ff       	call   801e19 <vfprintf>
	va_end(ap);

	return cnt;
}
  801e9d:	c9                   	leave  
  801e9e:	c3                   	ret    

00801e9f <printf>:

int
printf(const char *fmt, ...)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801ea5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801ea8:	50                   	push   %eax
  801ea9:	ff 75 08             	pushl  0x8(%ebp)
  801eac:	6a 01                	push   $0x1
  801eae:	e8 66 ff ff ff       	call   801e19 <vfprintf>
	va_end(ap);

	return cnt;
}
  801eb3:	c9                   	leave  
  801eb4:	c3                   	ret    

00801eb5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	56                   	push   %esi
  801eb9:	53                   	push   %ebx
  801eba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ebd:	83 ec 0c             	sub    $0xc,%esp
  801ec0:	ff 75 08             	pushl  0x8(%ebp)
  801ec3:	e8 d6 f6 ff ff       	call   80159e <fd2data>
  801ec8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801eca:	83 c4 08             	add    $0x8,%esp
  801ecd:	68 cb 2b 80 00       	push   $0x802bcb
  801ed2:	53                   	push   %ebx
  801ed3:	e8 68 eb ff ff       	call   800a40 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ed8:	8b 46 04             	mov    0x4(%esi),%eax
  801edb:	2b 06                	sub    (%esi),%eax
  801edd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ee3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801eea:	00 00 00 
	stat->st_dev = &devpipe;
  801eed:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ef4:	30 80 00 
	return 0;
}
  801ef7:	b8 00 00 00 00       	mov    $0x0,%eax
  801efc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eff:	5b                   	pop    %ebx
  801f00:	5e                   	pop    %esi
  801f01:	5d                   	pop    %ebp
  801f02:	c3                   	ret    

00801f03 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f03:	55                   	push   %ebp
  801f04:	89 e5                	mov    %esp,%ebp
  801f06:	53                   	push   %ebx
  801f07:	83 ec 0c             	sub    $0xc,%esp
  801f0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f0d:	53                   	push   %ebx
  801f0e:	6a 00                	push   $0x0
  801f10:	e8 b3 ef ff ff       	call   800ec8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f15:	89 1c 24             	mov    %ebx,(%esp)
  801f18:	e8 81 f6 ff ff       	call   80159e <fd2data>
  801f1d:	83 c4 08             	add    $0x8,%esp
  801f20:	50                   	push   %eax
  801f21:	6a 00                	push   $0x0
  801f23:	e8 a0 ef ff ff       	call   800ec8 <sys_page_unmap>
}
  801f28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f2b:	c9                   	leave  
  801f2c:	c3                   	ret    

00801f2d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f2d:	55                   	push   %ebp
  801f2e:	89 e5                	mov    %esp,%ebp
  801f30:	57                   	push   %edi
  801f31:	56                   	push   %esi
  801f32:	53                   	push   %ebx
  801f33:	83 ec 1c             	sub    $0x1c,%esp
  801f36:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f39:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f3b:	a1 04 44 80 00       	mov    0x804404,%eax
  801f40:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f46:	83 ec 0c             	sub    $0xc,%esp
  801f49:	ff 75 e0             	pushl  -0x20(%ebp)
  801f4c:	e8 7a 04 00 00       	call   8023cb <pageref>
  801f51:	89 c3                	mov    %eax,%ebx
  801f53:	89 3c 24             	mov    %edi,(%esp)
  801f56:	e8 70 04 00 00       	call   8023cb <pageref>
  801f5b:	83 c4 10             	add    $0x10,%esp
  801f5e:	39 c3                	cmp    %eax,%ebx
  801f60:	0f 94 c1             	sete   %cl
  801f63:	0f b6 c9             	movzbl %cl,%ecx
  801f66:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f69:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801f6f:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801f75:	39 ce                	cmp    %ecx,%esi
  801f77:	74 1e                	je     801f97 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801f79:	39 c3                	cmp    %eax,%ebx
  801f7b:	75 be                	jne    801f3b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f7d:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801f83:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f86:	50                   	push   %eax
  801f87:	56                   	push   %esi
  801f88:	68 d2 2b 80 00       	push   $0x802bd2
  801f8d:	e8 36 e4 ff ff       	call   8003c8 <cprintf>
  801f92:	83 c4 10             	add    $0x10,%esp
  801f95:	eb a4                	jmp    801f3b <_pipeisclosed+0xe>
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
  801faf:	e8 ea f5 ff ff       	call   80159e <fd2data>
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
  801fc4:	e8 64 ff ff ff       	call   801f2d <_pipeisclosed>
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	75 48                	jne    802015 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fcd:	e8 52 ee ff ff       	call   800e24 <sys_yield>
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
  80202f:	e8 6a f5 ff ff       	call   80159e <fd2data>
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
  80204c:	e8 dc fe ff ff       	call   801f2d <_pipeisclosed>
  802051:	85 c0                	test   %eax,%eax
  802053:	75 32                	jne    802087 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802055:	e8 ca ed ff ff       	call   800e24 <sys_yield>
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
  8020a0:	e8 10 f5 ff ff       	call   8015b5 <fd_alloc>
  8020a5:	83 c4 10             	add    $0x10,%esp
  8020a8:	89 c2                	mov    %eax,%edx
  8020aa:	85 c0                	test   %eax,%eax
  8020ac:	0f 88 2c 01 00 00    	js     8021de <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b2:	83 ec 04             	sub    $0x4,%esp
  8020b5:	68 07 04 00 00       	push   $0x407
  8020ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8020bd:	6a 00                	push   $0x0
  8020bf:	e8 7f ed ff ff       	call   800e43 <sys_page_alloc>
  8020c4:	83 c4 10             	add    $0x10,%esp
  8020c7:	89 c2                	mov    %eax,%edx
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	0f 88 0d 01 00 00    	js     8021de <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020d1:	83 ec 0c             	sub    $0xc,%esp
  8020d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020d7:	50                   	push   %eax
  8020d8:	e8 d8 f4 ff ff       	call   8015b5 <fd_alloc>
  8020dd:	89 c3                	mov    %eax,%ebx
  8020df:	83 c4 10             	add    $0x10,%esp
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	0f 88 e2 00 00 00    	js     8021cc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ea:	83 ec 04             	sub    $0x4,%esp
  8020ed:	68 07 04 00 00       	push   $0x407
  8020f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f5:	6a 00                	push   $0x0
  8020f7:	e8 47 ed ff ff       	call   800e43 <sys_page_alloc>
  8020fc:	89 c3                	mov    %eax,%ebx
  8020fe:	83 c4 10             	add    $0x10,%esp
  802101:	85 c0                	test   %eax,%eax
  802103:	0f 88 c3 00 00 00    	js     8021cc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802109:	83 ec 0c             	sub    $0xc,%esp
  80210c:	ff 75 f4             	pushl  -0xc(%ebp)
  80210f:	e8 8a f4 ff ff       	call   80159e <fd2data>
  802114:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802116:	83 c4 0c             	add    $0xc,%esp
  802119:	68 07 04 00 00       	push   $0x407
  80211e:	50                   	push   %eax
  80211f:	6a 00                	push   $0x0
  802121:	e8 1d ed ff ff       	call   800e43 <sys_page_alloc>
  802126:	89 c3                	mov    %eax,%ebx
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	85 c0                	test   %eax,%eax
  80212d:	0f 88 89 00 00 00    	js     8021bc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802133:	83 ec 0c             	sub    $0xc,%esp
  802136:	ff 75 f0             	pushl  -0x10(%ebp)
  802139:	e8 60 f4 ff ff       	call   80159e <fd2data>
  80213e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802145:	50                   	push   %eax
  802146:	6a 00                	push   $0x0
  802148:	56                   	push   %esi
  802149:	6a 00                	push   $0x0
  80214b:	e8 36 ed ff ff       	call   800e86 <sys_page_map>
  802150:	89 c3                	mov    %eax,%ebx
  802152:	83 c4 20             	add    $0x20,%esp
  802155:	85 c0                	test   %eax,%eax
  802157:	78 55                	js     8021ae <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802159:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80215f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802162:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802167:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80216e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
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
  802189:	e8 00 f4 ff ff       	call   80158e <fd2num>
  80218e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802191:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802193:	83 c4 04             	add    $0x4,%esp
  802196:	ff 75 f0             	pushl  -0x10(%ebp)
  802199:	e8 f0 f3 ff ff       	call   80158e <fd2num>
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
  8021b4:	e8 0f ed ff ff       	call   800ec8 <sys_page_unmap>
  8021b9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021bc:	83 ec 08             	sub    $0x8,%esp
  8021bf:	ff 75 f0             	pushl  -0x10(%ebp)
  8021c2:	6a 00                	push   $0x0
  8021c4:	e8 ff ec ff ff       	call   800ec8 <sys_page_unmap>
  8021c9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021cc:	83 ec 08             	sub    $0x8,%esp
  8021cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8021d2:	6a 00                	push   $0x0
  8021d4:	e8 ef ec ff ff       	call   800ec8 <sys_page_unmap>
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
  8021f4:	e8 0b f4 ff ff       	call   801604 <fd_lookup>
  8021f9:	83 c4 10             	add    $0x10,%esp
  8021fc:	85 c0                	test   %eax,%eax
  8021fe:	78 18                	js     802218 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802200:	83 ec 0c             	sub    $0xc,%esp
  802203:	ff 75 f4             	pushl  -0xc(%ebp)
  802206:	e8 93 f3 ff ff       	call   80159e <fd2data>
	return _pipeisclosed(fd, p);
  80220b:	89 c2                	mov    %eax,%edx
  80220d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802210:	e8 18 fd ff ff       	call   801f2d <_pipeisclosed>
  802215:	83 c4 10             	add    $0x10,%esp
}
  802218:	c9                   	leave  
  802219:	c3                   	ret    

0080221a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80221a:	55                   	push   %ebp
  80221b:	89 e5                	mov    %esp,%ebp
  80221d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802220:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802227:	75 2a                	jne    802253 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802229:	83 ec 04             	sub    $0x4,%esp
  80222c:	6a 07                	push   $0x7
  80222e:	68 00 f0 bf ee       	push   $0xeebff000
  802233:	6a 00                	push   $0x0
  802235:	e8 09 ec ff ff       	call   800e43 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80223a:	83 c4 10             	add    $0x10,%esp
  80223d:	85 c0                	test   %eax,%eax
  80223f:	79 12                	jns    802253 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802241:	50                   	push   %eax
  802242:	68 4b 2a 80 00       	push   $0x802a4b
  802247:	6a 23                	push   $0x23
  802249:	68 ea 2b 80 00       	push   $0x802bea
  80224e:	e8 9c e0 ff ff       	call   8002ef <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802253:	8b 45 08             	mov    0x8(%ebp),%eax
  802256:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80225b:	83 ec 08             	sub    $0x8,%esp
  80225e:	68 85 22 80 00       	push   $0x802285
  802263:	6a 00                	push   $0x0
  802265:	e8 24 ed ff ff       	call   800f8e <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80226a:	83 c4 10             	add    $0x10,%esp
  80226d:	85 c0                	test   %eax,%eax
  80226f:	79 12                	jns    802283 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802271:	50                   	push   %eax
  802272:	68 4b 2a 80 00       	push   $0x802a4b
  802277:	6a 2c                	push   $0x2c
  802279:	68 ea 2b 80 00       	push   $0x802bea
  80227e:	e8 6c e0 ff ff       	call   8002ef <_panic>
	}
}
  802283:	c9                   	leave  
  802284:	c3                   	ret    

00802285 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802285:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802286:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80228b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80228d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802290:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802294:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802299:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80229d:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80229f:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8022a2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8022a3:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8022a6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8022a7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8022a8:	c3                   	ret    

008022a9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022a9:	55                   	push   %ebp
  8022aa:	89 e5                	mov    %esp,%ebp
  8022ac:	56                   	push   %esi
  8022ad:	53                   	push   %ebx
  8022ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8022b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8022b7:	85 c0                	test   %eax,%eax
  8022b9:	75 12                	jne    8022cd <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8022bb:	83 ec 0c             	sub    $0xc,%esp
  8022be:	68 00 00 c0 ee       	push   $0xeec00000
  8022c3:	e8 2b ed ff ff       	call   800ff3 <sys_ipc_recv>
  8022c8:	83 c4 10             	add    $0x10,%esp
  8022cb:	eb 0c                	jmp    8022d9 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8022cd:	83 ec 0c             	sub    $0xc,%esp
  8022d0:	50                   	push   %eax
  8022d1:	e8 1d ed ff ff       	call   800ff3 <sys_ipc_recv>
  8022d6:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8022d9:	85 f6                	test   %esi,%esi
  8022db:	0f 95 c1             	setne  %cl
  8022de:	85 db                	test   %ebx,%ebx
  8022e0:	0f 95 c2             	setne  %dl
  8022e3:	84 d1                	test   %dl,%cl
  8022e5:	74 09                	je     8022f0 <ipc_recv+0x47>
  8022e7:	89 c2                	mov    %eax,%edx
  8022e9:	c1 ea 1f             	shr    $0x1f,%edx
  8022ec:	84 d2                	test   %dl,%dl
  8022ee:	75 2d                	jne    80231d <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8022f0:	85 f6                	test   %esi,%esi
  8022f2:	74 0d                	je     802301 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8022f4:	a1 04 44 80 00       	mov    0x804404,%eax
  8022f9:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8022ff:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802301:	85 db                	test   %ebx,%ebx
  802303:	74 0d                	je     802312 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802305:	a1 04 44 80 00       	mov    0x804404,%eax
  80230a:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802310:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802312:	a1 04 44 80 00       	mov    0x804404,%eax
  802317:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80231d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802320:	5b                   	pop    %ebx
  802321:	5e                   	pop    %esi
  802322:	5d                   	pop    %ebp
  802323:	c3                   	ret    

00802324 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802324:	55                   	push   %ebp
  802325:	89 e5                	mov    %esp,%ebp
  802327:	57                   	push   %edi
  802328:	56                   	push   %esi
  802329:	53                   	push   %ebx
  80232a:	83 ec 0c             	sub    $0xc,%esp
  80232d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802330:	8b 75 0c             	mov    0xc(%ebp),%esi
  802333:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802336:	85 db                	test   %ebx,%ebx
  802338:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80233d:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802340:	ff 75 14             	pushl  0x14(%ebp)
  802343:	53                   	push   %ebx
  802344:	56                   	push   %esi
  802345:	57                   	push   %edi
  802346:	e8 85 ec ff ff       	call   800fd0 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80234b:	89 c2                	mov    %eax,%edx
  80234d:	c1 ea 1f             	shr    $0x1f,%edx
  802350:	83 c4 10             	add    $0x10,%esp
  802353:	84 d2                	test   %dl,%dl
  802355:	74 17                	je     80236e <ipc_send+0x4a>
  802357:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80235a:	74 12                	je     80236e <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80235c:	50                   	push   %eax
  80235d:	68 f8 2b 80 00       	push   $0x802bf8
  802362:	6a 47                	push   $0x47
  802364:	68 06 2c 80 00       	push   $0x802c06
  802369:	e8 81 df ff ff       	call   8002ef <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80236e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802371:	75 07                	jne    80237a <ipc_send+0x56>
			sys_yield();
  802373:	e8 ac ea ff ff       	call   800e24 <sys_yield>
  802378:	eb c6                	jmp    802340 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80237a:	85 c0                	test   %eax,%eax
  80237c:	75 c2                	jne    802340 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80237e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802381:	5b                   	pop    %ebx
  802382:	5e                   	pop    %esi
  802383:	5f                   	pop    %edi
  802384:	5d                   	pop    %ebp
  802385:	c3                   	ret    

00802386 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802386:	55                   	push   %ebp
  802387:	89 e5                	mov    %esp,%ebp
  802389:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80238c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802391:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  802397:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80239d:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8023a3:	39 ca                	cmp    %ecx,%edx
  8023a5:	75 13                	jne    8023ba <ipc_find_env+0x34>
			return envs[i].env_id;
  8023a7:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8023ad:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023b2:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8023b8:	eb 0f                	jmp    8023c9 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023ba:	83 c0 01             	add    $0x1,%eax
  8023bd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023c2:	75 cd                	jne    802391 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023c9:	5d                   	pop    %ebp
  8023ca:	c3                   	ret    

008023cb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023cb:	55                   	push   %ebp
  8023cc:	89 e5                	mov    %esp,%ebp
  8023ce:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023d1:	89 d0                	mov    %edx,%eax
  8023d3:	c1 e8 16             	shr    $0x16,%eax
  8023d6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023dd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023e2:	f6 c1 01             	test   $0x1,%cl
  8023e5:	74 1d                	je     802404 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023e7:	c1 ea 0c             	shr    $0xc,%edx
  8023ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023f1:	f6 c2 01             	test   $0x1,%dl
  8023f4:	74 0e                	je     802404 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023f6:	c1 ea 0c             	shr    $0xc,%edx
  8023f9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802400:	ef 
  802401:	0f b7 c0             	movzwl %ax,%eax
}
  802404:	5d                   	pop    %ebp
  802405:	c3                   	ret    
  802406:	66 90                	xchg   %ax,%ax
  802408:	66 90                	xchg   %ax,%ax
  80240a:	66 90                	xchg   %ax,%ax
  80240c:	66 90                	xchg   %ax,%ax
  80240e:	66 90                	xchg   %ax,%ax

00802410 <__udivdi3>:
  802410:	55                   	push   %ebp
  802411:	57                   	push   %edi
  802412:	56                   	push   %esi
  802413:	53                   	push   %ebx
  802414:	83 ec 1c             	sub    $0x1c,%esp
  802417:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80241b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80241f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802423:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802427:	85 f6                	test   %esi,%esi
  802429:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80242d:	89 ca                	mov    %ecx,%edx
  80242f:	89 f8                	mov    %edi,%eax
  802431:	75 3d                	jne    802470 <__udivdi3+0x60>
  802433:	39 cf                	cmp    %ecx,%edi
  802435:	0f 87 c5 00 00 00    	ja     802500 <__udivdi3+0xf0>
  80243b:	85 ff                	test   %edi,%edi
  80243d:	89 fd                	mov    %edi,%ebp
  80243f:	75 0b                	jne    80244c <__udivdi3+0x3c>
  802441:	b8 01 00 00 00       	mov    $0x1,%eax
  802446:	31 d2                	xor    %edx,%edx
  802448:	f7 f7                	div    %edi
  80244a:	89 c5                	mov    %eax,%ebp
  80244c:	89 c8                	mov    %ecx,%eax
  80244e:	31 d2                	xor    %edx,%edx
  802450:	f7 f5                	div    %ebp
  802452:	89 c1                	mov    %eax,%ecx
  802454:	89 d8                	mov    %ebx,%eax
  802456:	89 cf                	mov    %ecx,%edi
  802458:	f7 f5                	div    %ebp
  80245a:	89 c3                	mov    %eax,%ebx
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
  802470:	39 ce                	cmp    %ecx,%esi
  802472:	77 74                	ja     8024e8 <__udivdi3+0xd8>
  802474:	0f bd fe             	bsr    %esi,%edi
  802477:	83 f7 1f             	xor    $0x1f,%edi
  80247a:	0f 84 98 00 00 00    	je     802518 <__udivdi3+0x108>
  802480:	bb 20 00 00 00       	mov    $0x20,%ebx
  802485:	89 f9                	mov    %edi,%ecx
  802487:	89 c5                	mov    %eax,%ebp
  802489:	29 fb                	sub    %edi,%ebx
  80248b:	d3 e6                	shl    %cl,%esi
  80248d:	89 d9                	mov    %ebx,%ecx
  80248f:	d3 ed                	shr    %cl,%ebp
  802491:	89 f9                	mov    %edi,%ecx
  802493:	d3 e0                	shl    %cl,%eax
  802495:	09 ee                	or     %ebp,%esi
  802497:	89 d9                	mov    %ebx,%ecx
  802499:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80249d:	89 d5                	mov    %edx,%ebp
  80249f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024a3:	d3 ed                	shr    %cl,%ebp
  8024a5:	89 f9                	mov    %edi,%ecx
  8024a7:	d3 e2                	shl    %cl,%edx
  8024a9:	89 d9                	mov    %ebx,%ecx
  8024ab:	d3 e8                	shr    %cl,%eax
  8024ad:	09 c2                	or     %eax,%edx
  8024af:	89 d0                	mov    %edx,%eax
  8024b1:	89 ea                	mov    %ebp,%edx
  8024b3:	f7 f6                	div    %esi
  8024b5:	89 d5                	mov    %edx,%ebp
  8024b7:	89 c3                	mov    %eax,%ebx
  8024b9:	f7 64 24 0c          	mull   0xc(%esp)
  8024bd:	39 d5                	cmp    %edx,%ebp
  8024bf:	72 10                	jb     8024d1 <__udivdi3+0xc1>
  8024c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	d3 e6                	shl    %cl,%esi
  8024c9:	39 c6                	cmp    %eax,%esi
  8024cb:	73 07                	jae    8024d4 <__udivdi3+0xc4>
  8024cd:	39 d5                	cmp    %edx,%ebp
  8024cf:	75 03                	jne    8024d4 <__udivdi3+0xc4>
  8024d1:	83 eb 01             	sub    $0x1,%ebx
  8024d4:	31 ff                	xor    %edi,%edi
  8024d6:	89 d8                	mov    %ebx,%eax
  8024d8:	89 fa                	mov    %edi,%edx
  8024da:	83 c4 1c             	add    $0x1c,%esp
  8024dd:	5b                   	pop    %ebx
  8024de:	5e                   	pop    %esi
  8024df:	5f                   	pop    %edi
  8024e0:	5d                   	pop    %ebp
  8024e1:	c3                   	ret    
  8024e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024e8:	31 ff                	xor    %edi,%edi
  8024ea:	31 db                	xor    %ebx,%ebx
  8024ec:	89 d8                	mov    %ebx,%eax
  8024ee:	89 fa                	mov    %edi,%edx
  8024f0:	83 c4 1c             	add    $0x1c,%esp
  8024f3:	5b                   	pop    %ebx
  8024f4:	5e                   	pop    %esi
  8024f5:	5f                   	pop    %edi
  8024f6:	5d                   	pop    %ebp
  8024f7:	c3                   	ret    
  8024f8:	90                   	nop
  8024f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802500:	89 d8                	mov    %ebx,%eax
  802502:	f7 f7                	div    %edi
  802504:	31 ff                	xor    %edi,%edi
  802506:	89 c3                	mov    %eax,%ebx
  802508:	89 d8                	mov    %ebx,%eax
  80250a:	89 fa                	mov    %edi,%edx
  80250c:	83 c4 1c             	add    $0x1c,%esp
  80250f:	5b                   	pop    %ebx
  802510:	5e                   	pop    %esi
  802511:	5f                   	pop    %edi
  802512:	5d                   	pop    %ebp
  802513:	c3                   	ret    
  802514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802518:	39 ce                	cmp    %ecx,%esi
  80251a:	72 0c                	jb     802528 <__udivdi3+0x118>
  80251c:	31 db                	xor    %ebx,%ebx
  80251e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802522:	0f 87 34 ff ff ff    	ja     80245c <__udivdi3+0x4c>
  802528:	bb 01 00 00 00       	mov    $0x1,%ebx
  80252d:	e9 2a ff ff ff       	jmp    80245c <__udivdi3+0x4c>
  802532:	66 90                	xchg   %ax,%ax
  802534:	66 90                	xchg   %ax,%ax
  802536:	66 90                	xchg   %ax,%ax
  802538:	66 90                	xchg   %ax,%ax
  80253a:	66 90                	xchg   %ax,%ax
  80253c:	66 90                	xchg   %ax,%ax
  80253e:	66 90                	xchg   %ax,%ax

00802540 <__umoddi3>:
  802540:	55                   	push   %ebp
  802541:	57                   	push   %edi
  802542:	56                   	push   %esi
  802543:	53                   	push   %ebx
  802544:	83 ec 1c             	sub    $0x1c,%esp
  802547:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80254b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80254f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802553:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802557:	85 d2                	test   %edx,%edx
  802559:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80255d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802561:	89 f3                	mov    %esi,%ebx
  802563:	89 3c 24             	mov    %edi,(%esp)
  802566:	89 74 24 04          	mov    %esi,0x4(%esp)
  80256a:	75 1c                	jne    802588 <__umoddi3+0x48>
  80256c:	39 f7                	cmp    %esi,%edi
  80256e:	76 50                	jbe    8025c0 <__umoddi3+0x80>
  802570:	89 c8                	mov    %ecx,%eax
  802572:	89 f2                	mov    %esi,%edx
  802574:	f7 f7                	div    %edi
  802576:	89 d0                	mov    %edx,%eax
  802578:	31 d2                	xor    %edx,%edx
  80257a:	83 c4 1c             	add    $0x1c,%esp
  80257d:	5b                   	pop    %ebx
  80257e:	5e                   	pop    %esi
  80257f:	5f                   	pop    %edi
  802580:	5d                   	pop    %ebp
  802581:	c3                   	ret    
  802582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802588:	39 f2                	cmp    %esi,%edx
  80258a:	89 d0                	mov    %edx,%eax
  80258c:	77 52                	ja     8025e0 <__umoddi3+0xa0>
  80258e:	0f bd ea             	bsr    %edx,%ebp
  802591:	83 f5 1f             	xor    $0x1f,%ebp
  802594:	75 5a                	jne    8025f0 <__umoddi3+0xb0>
  802596:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80259a:	0f 82 e0 00 00 00    	jb     802680 <__umoddi3+0x140>
  8025a0:	39 0c 24             	cmp    %ecx,(%esp)
  8025a3:	0f 86 d7 00 00 00    	jbe    802680 <__umoddi3+0x140>
  8025a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025b1:	83 c4 1c             	add    $0x1c,%esp
  8025b4:	5b                   	pop    %ebx
  8025b5:	5e                   	pop    %esi
  8025b6:	5f                   	pop    %edi
  8025b7:	5d                   	pop    %ebp
  8025b8:	c3                   	ret    
  8025b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	85 ff                	test   %edi,%edi
  8025c2:	89 fd                	mov    %edi,%ebp
  8025c4:	75 0b                	jne    8025d1 <__umoddi3+0x91>
  8025c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025cb:	31 d2                	xor    %edx,%edx
  8025cd:	f7 f7                	div    %edi
  8025cf:	89 c5                	mov    %eax,%ebp
  8025d1:	89 f0                	mov    %esi,%eax
  8025d3:	31 d2                	xor    %edx,%edx
  8025d5:	f7 f5                	div    %ebp
  8025d7:	89 c8                	mov    %ecx,%eax
  8025d9:	f7 f5                	div    %ebp
  8025db:	89 d0                	mov    %edx,%eax
  8025dd:	eb 99                	jmp    802578 <__umoddi3+0x38>
  8025df:	90                   	nop
  8025e0:	89 c8                	mov    %ecx,%eax
  8025e2:	89 f2                	mov    %esi,%edx
  8025e4:	83 c4 1c             	add    $0x1c,%esp
  8025e7:	5b                   	pop    %ebx
  8025e8:	5e                   	pop    %esi
  8025e9:	5f                   	pop    %edi
  8025ea:	5d                   	pop    %ebp
  8025eb:	c3                   	ret    
  8025ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	8b 34 24             	mov    (%esp),%esi
  8025f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025f8:	89 e9                	mov    %ebp,%ecx
  8025fa:	29 ef                	sub    %ebp,%edi
  8025fc:	d3 e0                	shl    %cl,%eax
  8025fe:	89 f9                	mov    %edi,%ecx
  802600:	89 f2                	mov    %esi,%edx
  802602:	d3 ea                	shr    %cl,%edx
  802604:	89 e9                	mov    %ebp,%ecx
  802606:	09 c2                	or     %eax,%edx
  802608:	89 d8                	mov    %ebx,%eax
  80260a:	89 14 24             	mov    %edx,(%esp)
  80260d:	89 f2                	mov    %esi,%edx
  80260f:	d3 e2                	shl    %cl,%edx
  802611:	89 f9                	mov    %edi,%ecx
  802613:	89 54 24 04          	mov    %edx,0x4(%esp)
  802617:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80261b:	d3 e8                	shr    %cl,%eax
  80261d:	89 e9                	mov    %ebp,%ecx
  80261f:	89 c6                	mov    %eax,%esi
  802621:	d3 e3                	shl    %cl,%ebx
  802623:	89 f9                	mov    %edi,%ecx
  802625:	89 d0                	mov    %edx,%eax
  802627:	d3 e8                	shr    %cl,%eax
  802629:	89 e9                	mov    %ebp,%ecx
  80262b:	09 d8                	or     %ebx,%eax
  80262d:	89 d3                	mov    %edx,%ebx
  80262f:	89 f2                	mov    %esi,%edx
  802631:	f7 34 24             	divl   (%esp)
  802634:	89 d6                	mov    %edx,%esi
  802636:	d3 e3                	shl    %cl,%ebx
  802638:	f7 64 24 04          	mull   0x4(%esp)
  80263c:	39 d6                	cmp    %edx,%esi
  80263e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802642:	89 d1                	mov    %edx,%ecx
  802644:	89 c3                	mov    %eax,%ebx
  802646:	72 08                	jb     802650 <__umoddi3+0x110>
  802648:	75 11                	jne    80265b <__umoddi3+0x11b>
  80264a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80264e:	73 0b                	jae    80265b <__umoddi3+0x11b>
  802650:	2b 44 24 04          	sub    0x4(%esp),%eax
  802654:	1b 14 24             	sbb    (%esp),%edx
  802657:	89 d1                	mov    %edx,%ecx
  802659:	89 c3                	mov    %eax,%ebx
  80265b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80265f:	29 da                	sub    %ebx,%edx
  802661:	19 ce                	sbb    %ecx,%esi
  802663:	89 f9                	mov    %edi,%ecx
  802665:	89 f0                	mov    %esi,%eax
  802667:	d3 e0                	shl    %cl,%eax
  802669:	89 e9                	mov    %ebp,%ecx
  80266b:	d3 ea                	shr    %cl,%edx
  80266d:	89 e9                	mov    %ebp,%ecx
  80266f:	d3 ee                	shr    %cl,%esi
  802671:	09 d0                	or     %edx,%eax
  802673:	89 f2                	mov    %esi,%edx
  802675:	83 c4 1c             	add    $0x1c,%esp
  802678:	5b                   	pop    %ebx
  802679:	5e                   	pop    %esi
  80267a:	5f                   	pop    %edi
  80267b:	5d                   	pop    %ebp
  80267c:	c3                   	ret    
  80267d:	8d 76 00             	lea    0x0(%esi),%esi
  802680:	29 f9                	sub    %edi,%ecx
  802682:	19 d6                	sbb    %edx,%esi
  802684:	89 74 24 04          	mov    %esi,0x4(%esp)
  802688:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80268c:	e9 18 ff ff ff       	jmp    8025a9 <__umoddi3+0x69>
