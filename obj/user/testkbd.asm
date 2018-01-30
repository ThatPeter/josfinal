
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
  80004e:	e8 60 17 00 00       	call   8017b3 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 20 27 80 00       	push   $0x802720
  800065:	6a 0f                	push   $0xf
  800067:	68 2d 27 80 00       	push   $0x80272d
  80006c:	e8 7e 02 00 00       	call   8002ef <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 3c 27 80 00       	push   $0x80273c
  80007b:	6a 11                	push   $0x11
  80007d:	68 2d 27 80 00       	push   $0x80272d
  800082:	e8 68 02 00 00       	call   8002ef <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 70 17 00 00       	call   801803 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 56 27 80 00       	push   $0x802756
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 2d 27 80 00       	push   $0x80272d
  8000a7:	e8 43 02 00 00       	call   8002ef <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 5e 27 80 00       	push   $0x80275e
  8000b4:	e8 5b 08 00 00       	call   800914 <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 6c 27 80 00       	push   $0x80276c
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 3a 1e 00 00       	call   801f0a <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 70 27 80 00       	push   $0x802770
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 26 1e 00 00       	call   801f0a <fprintf>
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
  8000f9:	68 88 27 80 00       	push   $0x802788
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
  8001c9:	e8 21 17 00 00       	call   8018ef <read>
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
  8001f3:	e8 8e 14 00 00       	call   801686 <fd_lookup>
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
  80021c:	e8 16 14 00 00       	call   801637 <fd_alloc>
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
  80025e:	e8 ad 13 00 00       	call   801610 <fd2num>
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
  800281:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800287:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80028c:	a3 04 44 80 00       	mov    %eax,0x804404
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  8002db:	e8 fe 14 00 00       	call   8017de <close_all>
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
  80030d:	68 a0 27 80 00       	push   $0x8027a0
  800312:	e8 b1 00 00 00       	call   8003c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800317:	83 c4 18             	add    $0x18,%esp
  80031a:	53                   	push   %ebx
  80031b:	ff 75 10             	pushl  0x10(%ebp)
  80031e:	e8 54 00 00 00       	call   800377 <vcprintf>
	cprintf("\n");
  800323:	c7 04 24 96 2b 80 00 	movl   $0x802b96,(%esp)
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
  80042b:	e8 60 20 00 00       	call   802490 <__udivdi3>
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
  80046e:	e8 4d 21 00 00       	call   8025c0 <__umoddi3>
  800473:	83 c4 14             	add    $0x14,%esp
  800476:	0f be 80 c3 27 80 00 	movsbl 0x8027c3(%eax),%eax
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
  800572:	ff 24 85 00 29 80 00 	jmp    *0x802900(,%eax,4)
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
  800636:	8b 14 85 60 2a 80 00 	mov    0x802a60(,%eax,4),%edx
  80063d:	85 d2                	test   %edx,%edx
  80063f:	75 18                	jne    800659 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800641:	50                   	push   %eax
  800642:	68 db 27 80 00       	push   $0x8027db
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
  80065a:	68 01 2d 80 00       	push   $0x802d01
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
  80067e:	b8 d4 27 80 00       	mov    $0x8027d4,%eax
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
  800928:	68 01 2d 80 00       	push   $0x802d01
  80092d:	6a 01                	push   $0x1
  80092f:	e8 d6 15 00 00       	call   801f0a <fprintf>
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
  800968:	68 bf 2a 80 00       	push   $0x802abf
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
  800dec:	68 cf 2a 80 00       	push   $0x802acf
  800df1:	6a 23                	push   $0x23
  800df3:	68 ec 2a 80 00       	push   $0x802aec
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
  800e6d:	68 cf 2a 80 00       	push   $0x802acf
  800e72:	6a 23                	push   $0x23
  800e74:	68 ec 2a 80 00       	push   $0x802aec
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
  800eaf:	68 cf 2a 80 00       	push   $0x802acf
  800eb4:	6a 23                	push   $0x23
  800eb6:	68 ec 2a 80 00       	push   $0x802aec
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
  800ef1:	68 cf 2a 80 00       	push   $0x802acf
  800ef6:	6a 23                	push   $0x23
  800ef8:	68 ec 2a 80 00       	push   $0x802aec
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
  800f33:	68 cf 2a 80 00       	push   $0x802acf
  800f38:	6a 23                	push   $0x23
  800f3a:	68 ec 2a 80 00       	push   $0x802aec
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
  800f75:	68 cf 2a 80 00       	push   $0x802acf
  800f7a:	6a 23                	push   $0x23
  800f7c:	68 ec 2a 80 00       	push   $0x802aec
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
  800fb7:	68 cf 2a 80 00       	push   $0x802acf
  800fbc:	6a 23                	push   $0x23
  800fbe:	68 ec 2a 80 00       	push   $0x802aec
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
  80101b:	68 cf 2a 80 00       	push   $0x802acf
  801020:	6a 23                	push   $0x23
  801022:	68 ec 2a 80 00       	push   $0x802aec
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
  8010ba:	68 fa 2a 80 00       	push   $0x802afa
  8010bf:	6a 1f                	push   $0x1f
  8010c1:	68 0a 2b 80 00       	push   $0x802b0a
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
  8010e4:	68 15 2b 80 00       	push   $0x802b15
  8010e9:	6a 2d                	push   $0x2d
  8010eb:	68 0a 2b 80 00       	push   $0x802b0a
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
  80112c:	68 15 2b 80 00       	push   $0x802b15
  801131:	6a 34                	push   $0x34
  801133:	68 0a 2b 80 00       	push   $0x802b0a
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
  801154:	68 15 2b 80 00       	push   $0x802b15
  801159:	6a 38                	push   $0x38
  80115b:	68 0a 2b 80 00       	push   $0x802b0a
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
  801178:	e8 1f 11 00 00       	call   80229c <set_pgfault_handler>
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
  801191:	68 2e 2b 80 00       	push   $0x802b2e
  801196:	68 85 00 00 00       	push   $0x85
  80119b:	68 0a 2b 80 00       	push   $0x802b0a
  8011a0:	e8 4a f1 ff ff       	call   8002ef <_panic>
  8011a5:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8011a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011ab:	75 24                	jne    8011d1 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011ad:	e8 53 fc ff ff       	call   800e05 <sys_getenvid>
  8011b2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011b7:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  80124d:	68 3c 2b 80 00       	push   $0x802b3c
  801252:	6a 55                	push   $0x55
  801254:	68 0a 2b 80 00       	push   $0x802b0a
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
  801292:	68 3c 2b 80 00       	push   $0x802b3c
  801297:	6a 5c                	push   $0x5c
  801299:	68 0a 2b 80 00       	push   $0x802b0a
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
  8012c0:	68 3c 2b 80 00       	push   $0x802b3c
  8012c5:	6a 60                	push   $0x60
  8012c7:	68 0a 2b 80 00       	push   $0x802b0a
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
  8012ea:	68 3c 2b 80 00       	push   $0x802b3c
  8012ef:	6a 65                	push   $0x65
  8012f1:	68 0a 2b 80 00       	push   $0x802b0a
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
  801312:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	56                   	push   %esi
  80134b:	53                   	push   %ebx
  80134c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80134f:	89 1d 08 44 80 00    	mov    %ebx,0x804408
	cprintf("in fork.c thread create. func: %x\n", func);
  801355:	83 ec 08             	sub    $0x8,%esp
  801358:	53                   	push   %ebx
  801359:	68 cc 2b 80 00       	push   $0x802bcc
  80135e:	e8 65 f0 ff ff       	call   8003c8 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801363:	c7 04 24 b5 02 80 00 	movl   $0x8002b5,(%esp)
  80136a:	e8 c5 fc ff ff       	call   801034 <sys_thread_create>
  80136f:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801371:	83 c4 08             	add    $0x8,%esp
  801374:	53                   	push   %ebx
  801375:	68 cc 2b 80 00       	push   $0x802bcc
  80137a:	e8 49 f0 ff ff       	call   8003c8 <cprintf>
	return id;
}
  80137f:	89 f0                	mov    %esi,%eax
  801381:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801384:	5b                   	pop    %ebx
  801385:	5e                   	pop    %esi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    

00801388 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  80138e:	ff 75 08             	pushl  0x8(%ebp)
  801391:	e8 be fc ff ff       	call   801054 <sys_thread_free>
}
  801396:	83 c4 10             	add    $0x10,%esp
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8013a1:	ff 75 08             	pushl  0x8(%ebp)
  8013a4:	e8 cb fc ff ff       	call   801074 <sys_thread_join>
}
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	c9                   	leave  
  8013ad:	c3                   	ret    

008013ae <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	56                   	push   %esi
  8013b2:	53                   	push   %ebx
  8013b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8013b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8013b9:	83 ec 04             	sub    $0x4,%esp
  8013bc:	6a 07                	push   $0x7
  8013be:	6a 00                	push   $0x0
  8013c0:	56                   	push   %esi
  8013c1:	e8 7d fa ff ff       	call   800e43 <sys_page_alloc>
	if (r < 0) {
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	79 15                	jns    8013e2 <queue_append+0x34>
		panic("%e\n", r);
  8013cd:	50                   	push   %eax
  8013ce:	68 cb 2a 80 00       	push   $0x802acb
  8013d3:	68 c4 00 00 00       	push   $0xc4
  8013d8:	68 0a 2b 80 00       	push   $0x802b0a
  8013dd:	e8 0d ef ff ff       	call   8002ef <_panic>
	}	
	wt->envid = envid;
  8013e2:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  8013e8:	83 ec 04             	sub    $0x4,%esp
  8013eb:	ff 33                	pushl  (%ebx)
  8013ed:	56                   	push   %esi
  8013ee:	68 f0 2b 80 00       	push   $0x802bf0
  8013f3:	e8 d0 ef ff ff       	call   8003c8 <cprintf>
	if (queue->first == NULL) {
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	83 3b 00             	cmpl   $0x0,(%ebx)
  8013fe:	75 29                	jne    801429 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  801400:	83 ec 0c             	sub    $0xc,%esp
  801403:	68 52 2b 80 00       	push   $0x802b52
  801408:	e8 bb ef ff ff       	call   8003c8 <cprintf>
		queue->first = wt;
  80140d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  801413:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80141a:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801421:	00 00 00 
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	eb 2b                	jmp    801454 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801429:	83 ec 0c             	sub    $0xc,%esp
  80142c:	68 6c 2b 80 00       	push   $0x802b6c
  801431:	e8 92 ef ff ff       	call   8003c8 <cprintf>
		queue->last->next = wt;
  801436:	8b 43 04             	mov    0x4(%ebx),%eax
  801439:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801440:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801447:	00 00 00 
		queue->last = wt;
  80144a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  801451:	83 c4 10             	add    $0x10,%esp
	}
}
  801454:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801457:	5b                   	pop    %ebx
  801458:	5e                   	pop    %esi
  801459:	5d                   	pop    %ebp
  80145a:	c3                   	ret    

0080145b <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	53                   	push   %ebx
  80145f:	83 ec 04             	sub    $0x4,%esp
  801462:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  801465:	8b 02                	mov    (%edx),%eax
  801467:	85 c0                	test   %eax,%eax
  801469:	75 17                	jne    801482 <queue_pop+0x27>
		panic("queue empty!\n");
  80146b:	83 ec 04             	sub    $0x4,%esp
  80146e:	68 8a 2b 80 00       	push   $0x802b8a
  801473:	68 d8 00 00 00       	push   $0xd8
  801478:	68 0a 2b 80 00       	push   $0x802b0a
  80147d:	e8 6d ee ff ff       	call   8002ef <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801482:	8b 48 04             	mov    0x4(%eax),%ecx
  801485:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  801487:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801489:	83 ec 08             	sub    $0x8,%esp
  80148c:	53                   	push   %ebx
  80148d:	68 98 2b 80 00       	push   $0x802b98
  801492:	e8 31 ef ff ff       	call   8003c8 <cprintf>
	return envid;
}
  801497:	89 d8                	mov    %ebx,%eax
  801499:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 04             	sub    $0x4,%esp
  8014a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8014a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ad:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	74 5a                	je     80150e <mutex_lock+0x70>
  8014b4:	8b 43 04             	mov    0x4(%ebx),%eax
  8014b7:	83 38 00             	cmpl   $0x0,(%eax)
  8014ba:	75 52                	jne    80150e <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8014bc:	83 ec 0c             	sub    $0xc,%esp
  8014bf:	68 18 2c 80 00       	push   $0x802c18
  8014c4:	e8 ff ee ff ff       	call   8003c8 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  8014c9:	8b 5b 04             	mov    0x4(%ebx),%ebx
  8014cc:	e8 34 f9 ff ff       	call   800e05 <sys_getenvid>
  8014d1:	83 c4 08             	add    $0x8,%esp
  8014d4:	53                   	push   %ebx
  8014d5:	50                   	push   %eax
  8014d6:	e8 d3 fe ff ff       	call   8013ae <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8014db:	e8 25 f9 ff ff       	call   800e05 <sys_getenvid>
  8014e0:	83 c4 08             	add    $0x8,%esp
  8014e3:	6a 04                	push   $0x4
  8014e5:	50                   	push   %eax
  8014e6:	e8 1f fa ff ff       	call   800f0a <sys_env_set_status>
		if (r < 0) {
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	79 15                	jns    801507 <mutex_lock+0x69>
			panic("%e\n", r);
  8014f2:	50                   	push   %eax
  8014f3:	68 cb 2a 80 00       	push   $0x802acb
  8014f8:	68 eb 00 00 00       	push   $0xeb
  8014fd:	68 0a 2b 80 00       	push   $0x802b0a
  801502:	e8 e8 ed ff ff       	call   8002ef <_panic>
		}
		sys_yield();
  801507:	e8 18 f9 ff ff       	call   800e24 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80150c:	eb 18                	jmp    801526 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  80150e:	83 ec 0c             	sub    $0xc,%esp
  801511:	68 38 2c 80 00       	push   $0x802c38
  801516:	e8 ad ee ff ff       	call   8003c8 <cprintf>
	mtx->owner = sys_getenvid();}
  80151b:	e8 e5 f8 ff ff       	call   800e05 <sys_getenvid>
  801520:	89 43 08             	mov    %eax,0x8(%ebx)
  801523:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  801526:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801529:	c9                   	leave  
  80152a:	c3                   	ret    

0080152b <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	53                   	push   %ebx
  80152f:	83 ec 04             	sub    $0x4,%esp
  801532:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801535:	b8 00 00 00 00       	mov    $0x0,%eax
  80153a:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  80153d:	8b 43 04             	mov    0x4(%ebx),%eax
  801540:	83 38 00             	cmpl   $0x0,(%eax)
  801543:	74 33                	je     801578 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  801545:	83 ec 0c             	sub    $0xc,%esp
  801548:	50                   	push   %eax
  801549:	e8 0d ff ff ff       	call   80145b <queue_pop>
  80154e:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801551:	83 c4 08             	add    $0x8,%esp
  801554:	6a 02                	push   $0x2
  801556:	50                   	push   %eax
  801557:	e8 ae f9 ff ff       	call   800f0a <sys_env_set_status>
		if (r < 0) {
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	85 c0                	test   %eax,%eax
  801561:	79 15                	jns    801578 <mutex_unlock+0x4d>
			panic("%e\n", r);
  801563:	50                   	push   %eax
  801564:	68 cb 2a 80 00       	push   $0x802acb
  801569:	68 00 01 00 00       	push   $0x100
  80156e:	68 0a 2b 80 00       	push   $0x802b0a
  801573:	e8 77 ed ff ff       	call   8002ef <_panic>
		}
	}

	asm volatile("pause");
  801578:	f3 90                	pause  
	//sys_yield();
}
  80157a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157d:	c9                   	leave  
  80157e:	c3                   	ret    

0080157f <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	53                   	push   %ebx
  801583:	83 ec 04             	sub    $0x4,%esp
  801586:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801589:	e8 77 f8 ff ff       	call   800e05 <sys_getenvid>
  80158e:	83 ec 04             	sub    $0x4,%esp
  801591:	6a 07                	push   $0x7
  801593:	53                   	push   %ebx
  801594:	50                   	push   %eax
  801595:	e8 a9 f8 ff ff       	call   800e43 <sys_page_alloc>
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	79 15                	jns    8015b6 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8015a1:	50                   	push   %eax
  8015a2:	68 b3 2b 80 00       	push   $0x802bb3
  8015a7:	68 0d 01 00 00       	push   $0x10d
  8015ac:	68 0a 2b 80 00       	push   $0x802b0a
  8015b1:	e8 39 ed ff ff       	call   8002ef <_panic>
	}	
	mtx->locked = 0;
  8015b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8015bc:	8b 43 04             	mov    0x4(%ebx),%eax
  8015bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  8015c5:	8b 43 04             	mov    0x4(%ebx),%eax
  8015c8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8015cf:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8015d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  8015e1:	e8 1f f8 ff ff       	call   800e05 <sys_getenvid>
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	ff 75 08             	pushl  0x8(%ebp)
  8015ec:	50                   	push   %eax
  8015ed:	e8 d6 f8 ff ff       	call   800ec8 <sys_page_unmap>
	if (r < 0) {
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	79 15                	jns    80160e <mutex_destroy+0x33>
		panic("%e\n", r);
  8015f9:	50                   	push   %eax
  8015fa:	68 cb 2a 80 00       	push   $0x802acb
  8015ff:	68 1a 01 00 00       	push   $0x11a
  801604:	68 0a 2b 80 00       	push   $0x802b0a
  801609:	e8 e1 ec ff ff       	call   8002ef <_panic>
	}
}
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    

00801610 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801613:	8b 45 08             	mov    0x8(%ebp),%eax
  801616:	05 00 00 00 30       	add    $0x30000000,%eax
  80161b:	c1 e8 0c             	shr    $0xc,%eax
}
  80161e:	5d                   	pop    %ebp
  80161f:	c3                   	ret    

00801620 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801623:	8b 45 08             	mov    0x8(%ebp),%eax
  801626:	05 00 00 00 30       	add    $0x30000000,%eax
  80162b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801630:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801635:	5d                   	pop    %ebp
  801636:	c3                   	ret    

00801637 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80163d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801642:	89 c2                	mov    %eax,%edx
  801644:	c1 ea 16             	shr    $0x16,%edx
  801647:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80164e:	f6 c2 01             	test   $0x1,%dl
  801651:	74 11                	je     801664 <fd_alloc+0x2d>
  801653:	89 c2                	mov    %eax,%edx
  801655:	c1 ea 0c             	shr    $0xc,%edx
  801658:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80165f:	f6 c2 01             	test   $0x1,%dl
  801662:	75 09                	jne    80166d <fd_alloc+0x36>
			*fd_store = fd;
  801664:	89 01                	mov    %eax,(%ecx)
			return 0;
  801666:	b8 00 00 00 00       	mov    $0x0,%eax
  80166b:	eb 17                	jmp    801684 <fd_alloc+0x4d>
  80166d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801672:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801677:	75 c9                	jne    801642 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801679:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80167f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801684:	5d                   	pop    %ebp
  801685:	c3                   	ret    

00801686 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80168c:	83 f8 1f             	cmp    $0x1f,%eax
  80168f:	77 36                	ja     8016c7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801691:	c1 e0 0c             	shl    $0xc,%eax
  801694:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801699:	89 c2                	mov    %eax,%edx
  80169b:	c1 ea 16             	shr    $0x16,%edx
  80169e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016a5:	f6 c2 01             	test   $0x1,%dl
  8016a8:	74 24                	je     8016ce <fd_lookup+0x48>
  8016aa:	89 c2                	mov    %eax,%edx
  8016ac:	c1 ea 0c             	shr    $0xc,%edx
  8016af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016b6:	f6 c2 01             	test   $0x1,%dl
  8016b9:	74 1a                	je     8016d5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016be:	89 02                	mov    %eax,(%edx)
	return 0;
  8016c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c5:	eb 13                	jmp    8016da <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016cc:	eb 0c                	jmp    8016da <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d3:	eb 05                	jmp    8016da <fd_lookup+0x54>
  8016d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	83 ec 08             	sub    $0x8,%esp
  8016e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e5:	ba d8 2c 80 00       	mov    $0x802cd8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8016ea:	eb 13                	jmp    8016ff <dev_lookup+0x23>
  8016ec:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8016ef:	39 08                	cmp    %ecx,(%eax)
  8016f1:	75 0c                	jne    8016ff <dev_lookup+0x23>
			*dev = devtab[i];
  8016f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8016f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016fd:	eb 31                	jmp    801730 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016ff:	8b 02                	mov    (%edx),%eax
  801701:	85 c0                	test   %eax,%eax
  801703:	75 e7                	jne    8016ec <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801705:	a1 04 44 80 00       	mov    0x804404,%eax
  80170a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801710:	83 ec 04             	sub    $0x4,%esp
  801713:	51                   	push   %ecx
  801714:	50                   	push   %eax
  801715:	68 58 2c 80 00       	push   $0x802c58
  80171a:	e8 a9 ec ff ff       	call   8003c8 <cprintf>
	*dev = 0;
  80171f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801722:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801730:	c9                   	leave  
  801731:	c3                   	ret    

00801732 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	56                   	push   %esi
  801736:	53                   	push   %ebx
  801737:	83 ec 10             	sub    $0x10,%esp
  80173a:	8b 75 08             	mov    0x8(%ebp),%esi
  80173d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801740:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801743:	50                   	push   %eax
  801744:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80174a:	c1 e8 0c             	shr    $0xc,%eax
  80174d:	50                   	push   %eax
  80174e:	e8 33 ff ff ff       	call   801686 <fd_lookup>
  801753:	83 c4 08             	add    $0x8,%esp
  801756:	85 c0                	test   %eax,%eax
  801758:	78 05                	js     80175f <fd_close+0x2d>
	    || fd != fd2)
  80175a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80175d:	74 0c                	je     80176b <fd_close+0x39>
		return (must_exist ? r : 0);
  80175f:	84 db                	test   %bl,%bl
  801761:	ba 00 00 00 00       	mov    $0x0,%edx
  801766:	0f 44 c2             	cmove  %edx,%eax
  801769:	eb 41                	jmp    8017ac <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80176b:	83 ec 08             	sub    $0x8,%esp
  80176e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801771:	50                   	push   %eax
  801772:	ff 36                	pushl  (%esi)
  801774:	e8 63 ff ff ff       	call   8016dc <dev_lookup>
  801779:	89 c3                	mov    %eax,%ebx
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 1a                	js     80179c <fd_close+0x6a>
		if (dev->dev_close)
  801782:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801785:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801788:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80178d:	85 c0                	test   %eax,%eax
  80178f:	74 0b                	je     80179c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801791:	83 ec 0c             	sub    $0xc,%esp
  801794:	56                   	push   %esi
  801795:	ff d0                	call   *%eax
  801797:	89 c3                	mov    %eax,%ebx
  801799:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80179c:	83 ec 08             	sub    $0x8,%esp
  80179f:	56                   	push   %esi
  8017a0:	6a 00                	push   $0x0
  8017a2:	e8 21 f7 ff ff       	call   800ec8 <sys_page_unmap>
	return r;
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	89 d8                	mov    %ebx,%eax
}
  8017ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017af:	5b                   	pop    %ebx
  8017b0:	5e                   	pop    %esi
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    

008017b3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017bc:	50                   	push   %eax
  8017bd:	ff 75 08             	pushl  0x8(%ebp)
  8017c0:	e8 c1 fe ff ff       	call   801686 <fd_lookup>
  8017c5:	83 c4 08             	add    $0x8,%esp
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	78 10                	js     8017dc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8017cc:	83 ec 08             	sub    $0x8,%esp
  8017cf:	6a 01                	push   $0x1
  8017d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d4:	e8 59 ff ff ff       	call   801732 <fd_close>
  8017d9:	83 c4 10             	add    $0x10,%esp
}
  8017dc:	c9                   	leave  
  8017dd:	c3                   	ret    

008017de <close_all>:

void
close_all(void)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8017e5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8017ea:	83 ec 0c             	sub    $0xc,%esp
  8017ed:	53                   	push   %ebx
  8017ee:	e8 c0 ff ff ff       	call   8017b3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8017f3:	83 c3 01             	add    $0x1,%ebx
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	83 fb 20             	cmp    $0x20,%ebx
  8017fc:	75 ec                	jne    8017ea <close_all+0xc>
		close(i);
}
  8017fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	57                   	push   %edi
  801807:	56                   	push   %esi
  801808:	53                   	push   %ebx
  801809:	83 ec 2c             	sub    $0x2c,%esp
  80180c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80180f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801812:	50                   	push   %eax
  801813:	ff 75 08             	pushl  0x8(%ebp)
  801816:	e8 6b fe ff ff       	call   801686 <fd_lookup>
  80181b:	83 c4 08             	add    $0x8,%esp
  80181e:	85 c0                	test   %eax,%eax
  801820:	0f 88 c1 00 00 00    	js     8018e7 <dup+0xe4>
		return r;
	close(newfdnum);
  801826:	83 ec 0c             	sub    $0xc,%esp
  801829:	56                   	push   %esi
  80182a:	e8 84 ff ff ff       	call   8017b3 <close>

	newfd = INDEX2FD(newfdnum);
  80182f:	89 f3                	mov    %esi,%ebx
  801831:	c1 e3 0c             	shl    $0xc,%ebx
  801834:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80183a:	83 c4 04             	add    $0x4,%esp
  80183d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801840:	e8 db fd ff ff       	call   801620 <fd2data>
  801845:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801847:	89 1c 24             	mov    %ebx,(%esp)
  80184a:	e8 d1 fd ff ff       	call   801620 <fd2data>
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801855:	89 f8                	mov    %edi,%eax
  801857:	c1 e8 16             	shr    $0x16,%eax
  80185a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801861:	a8 01                	test   $0x1,%al
  801863:	74 37                	je     80189c <dup+0x99>
  801865:	89 f8                	mov    %edi,%eax
  801867:	c1 e8 0c             	shr    $0xc,%eax
  80186a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801871:	f6 c2 01             	test   $0x1,%dl
  801874:	74 26                	je     80189c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801876:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80187d:	83 ec 0c             	sub    $0xc,%esp
  801880:	25 07 0e 00 00       	and    $0xe07,%eax
  801885:	50                   	push   %eax
  801886:	ff 75 d4             	pushl  -0x2c(%ebp)
  801889:	6a 00                	push   $0x0
  80188b:	57                   	push   %edi
  80188c:	6a 00                	push   $0x0
  80188e:	e8 f3 f5 ff ff       	call   800e86 <sys_page_map>
  801893:	89 c7                	mov    %eax,%edi
  801895:	83 c4 20             	add    $0x20,%esp
  801898:	85 c0                	test   %eax,%eax
  80189a:	78 2e                	js     8018ca <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80189c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80189f:	89 d0                	mov    %edx,%eax
  8018a1:	c1 e8 0c             	shr    $0xc,%eax
  8018a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018ab:	83 ec 0c             	sub    $0xc,%esp
  8018ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8018b3:	50                   	push   %eax
  8018b4:	53                   	push   %ebx
  8018b5:	6a 00                	push   $0x0
  8018b7:	52                   	push   %edx
  8018b8:	6a 00                	push   $0x0
  8018ba:	e8 c7 f5 ff ff       	call   800e86 <sys_page_map>
  8018bf:	89 c7                	mov    %eax,%edi
  8018c1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8018c4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018c6:	85 ff                	test   %edi,%edi
  8018c8:	79 1d                	jns    8018e7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8018ca:	83 ec 08             	sub    $0x8,%esp
  8018cd:	53                   	push   %ebx
  8018ce:	6a 00                	push   $0x0
  8018d0:	e8 f3 f5 ff ff       	call   800ec8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8018d5:	83 c4 08             	add    $0x8,%esp
  8018d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8018db:	6a 00                	push   $0x0
  8018dd:	e8 e6 f5 ff ff       	call   800ec8 <sys_page_unmap>
	return r;
  8018e2:	83 c4 10             	add    $0x10,%esp
  8018e5:	89 f8                	mov    %edi,%eax
}
  8018e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ea:	5b                   	pop    %ebx
  8018eb:	5e                   	pop    %esi
  8018ec:	5f                   	pop    %edi
  8018ed:	5d                   	pop    %ebp
  8018ee:	c3                   	ret    

008018ef <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	53                   	push   %ebx
  8018f3:	83 ec 14             	sub    $0x14,%esp
  8018f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018fc:	50                   	push   %eax
  8018fd:	53                   	push   %ebx
  8018fe:	e8 83 fd ff ff       	call   801686 <fd_lookup>
  801903:	83 c4 08             	add    $0x8,%esp
  801906:	89 c2                	mov    %eax,%edx
  801908:	85 c0                	test   %eax,%eax
  80190a:	78 70                	js     80197c <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80190c:	83 ec 08             	sub    $0x8,%esp
  80190f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801912:	50                   	push   %eax
  801913:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801916:	ff 30                	pushl  (%eax)
  801918:	e8 bf fd ff ff       	call   8016dc <dev_lookup>
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	85 c0                	test   %eax,%eax
  801922:	78 4f                	js     801973 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801924:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801927:	8b 42 08             	mov    0x8(%edx),%eax
  80192a:	83 e0 03             	and    $0x3,%eax
  80192d:	83 f8 01             	cmp    $0x1,%eax
  801930:	75 24                	jne    801956 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801932:	a1 04 44 80 00       	mov    0x804404,%eax
  801937:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80193d:	83 ec 04             	sub    $0x4,%esp
  801940:	53                   	push   %ebx
  801941:	50                   	push   %eax
  801942:	68 9c 2c 80 00       	push   $0x802c9c
  801947:	e8 7c ea ff ff       	call   8003c8 <cprintf>
		return -E_INVAL;
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801954:	eb 26                	jmp    80197c <read+0x8d>
	}
	if (!dev->dev_read)
  801956:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801959:	8b 40 08             	mov    0x8(%eax),%eax
  80195c:	85 c0                	test   %eax,%eax
  80195e:	74 17                	je     801977 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801960:	83 ec 04             	sub    $0x4,%esp
  801963:	ff 75 10             	pushl  0x10(%ebp)
  801966:	ff 75 0c             	pushl  0xc(%ebp)
  801969:	52                   	push   %edx
  80196a:	ff d0                	call   *%eax
  80196c:	89 c2                	mov    %eax,%edx
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	eb 09                	jmp    80197c <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801973:	89 c2                	mov    %eax,%edx
  801975:	eb 05                	jmp    80197c <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801977:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80197c:	89 d0                	mov    %edx,%eax
  80197e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801981:	c9                   	leave  
  801982:	c3                   	ret    

00801983 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	57                   	push   %edi
  801987:	56                   	push   %esi
  801988:	53                   	push   %ebx
  801989:	83 ec 0c             	sub    $0xc,%esp
  80198c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80198f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801992:	bb 00 00 00 00       	mov    $0x0,%ebx
  801997:	eb 21                	jmp    8019ba <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801999:	83 ec 04             	sub    $0x4,%esp
  80199c:	89 f0                	mov    %esi,%eax
  80199e:	29 d8                	sub    %ebx,%eax
  8019a0:	50                   	push   %eax
  8019a1:	89 d8                	mov    %ebx,%eax
  8019a3:	03 45 0c             	add    0xc(%ebp),%eax
  8019a6:	50                   	push   %eax
  8019a7:	57                   	push   %edi
  8019a8:	e8 42 ff ff ff       	call   8018ef <read>
		if (m < 0)
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	78 10                	js     8019c4 <readn+0x41>
			return m;
		if (m == 0)
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	74 0a                	je     8019c2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019b8:	01 c3                	add    %eax,%ebx
  8019ba:	39 f3                	cmp    %esi,%ebx
  8019bc:	72 db                	jb     801999 <readn+0x16>
  8019be:	89 d8                	mov    %ebx,%eax
  8019c0:	eb 02                	jmp    8019c4 <readn+0x41>
  8019c2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8019c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019c7:	5b                   	pop    %ebx
  8019c8:	5e                   	pop    %esi
  8019c9:	5f                   	pop    %edi
  8019ca:	5d                   	pop    %ebp
  8019cb:	c3                   	ret    

008019cc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	53                   	push   %ebx
  8019d0:	83 ec 14             	sub    $0x14,%esp
  8019d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019d9:	50                   	push   %eax
  8019da:	53                   	push   %ebx
  8019db:	e8 a6 fc ff ff       	call   801686 <fd_lookup>
  8019e0:	83 c4 08             	add    $0x8,%esp
  8019e3:	89 c2                	mov    %eax,%edx
  8019e5:	85 c0                	test   %eax,%eax
  8019e7:	78 6b                	js     801a54 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019e9:	83 ec 08             	sub    $0x8,%esp
  8019ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ef:	50                   	push   %eax
  8019f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019f3:	ff 30                	pushl  (%eax)
  8019f5:	e8 e2 fc ff ff       	call   8016dc <dev_lookup>
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 4a                	js     801a4b <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a04:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a08:	75 24                	jne    801a2e <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a0a:	a1 04 44 80 00       	mov    0x804404,%eax
  801a0f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801a15:	83 ec 04             	sub    $0x4,%esp
  801a18:	53                   	push   %ebx
  801a19:	50                   	push   %eax
  801a1a:	68 b8 2c 80 00       	push   $0x802cb8
  801a1f:	e8 a4 e9 ff ff       	call   8003c8 <cprintf>
		return -E_INVAL;
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801a2c:	eb 26                	jmp    801a54 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a31:	8b 52 0c             	mov    0xc(%edx),%edx
  801a34:	85 d2                	test   %edx,%edx
  801a36:	74 17                	je     801a4f <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a38:	83 ec 04             	sub    $0x4,%esp
  801a3b:	ff 75 10             	pushl  0x10(%ebp)
  801a3e:	ff 75 0c             	pushl  0xc(%ebp)
  801a41:	50                   	push   %eax
  801a42:	ff d2                	call   *%edx
  801a44:	89 c2                	mov    %eax,%edx
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	eb 09                	jmp    801a54 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a4b:	89 c2                	mov    %eax,%edx
  801a4d:	eb 05                	jmp    801a54 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801a4f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801a54:	89 d0                	mov    %edx,%eax
  801a56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a59:	c9                   	leave  
  801a5a:	c3                   	ret    

00801a5b <seek>:

int
seek(int fdnum, off_t offset)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a61:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a64:	50                   	push   %eax
  801a65:	ff 75 08             	pushl  0x8(%ebp)
  801a68:	e8 19 fc ff ff       	call   801686 <fd_lookup>
  801a6d:	83 c4 08             	add    $0x8,%esp
  801a70:	85 c0                	test   %eax,%eax
  801a72:	78 0e                	js     801a82 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801a74:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a77:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a7a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801a7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	53                   	push   %ebx
  801a88:	83 ec 14             	sub    $0x14,%esp
  801a8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a91:	50                   	push   %eax
  801a92:	53                   	push   %ebx
  801a93:	e8 ee fb ff ff       	call   801686 <fd_lookup>
  801a98:	83 c4 08             	add    $0x8,%esp
  801a9b:	89 c2                	mov    %eax,%edx
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	78 68                	js     801b09 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801aa1:	83 ec 08             	sub    $0x8,%esp
  801aa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa7:	50                   	push   %eax
  801aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aab:	ff 30                	pushl  (%eax)
  801aad:	e8 2a fc ff ff       	call   8016dc <dev_lookup>
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	78 47                	js     801b00 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801abc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ac0:	75 24                	jne    801ae6 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801ac2:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801ac7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	53                   	push   %ebx
  801ad1:	50                   	push   %eax
  801ad2:	68 78 2c 80 00       	push   $0x802c78
  801ad7:	e8 ec e8 ff ff       	call   8003c8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801ae4:	eb 23                	jmp    801b09 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801ae6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ae9:	8b 52 18             	mov    0x18(%edx),%edx
  801aec:	85 d2                	test   %edx,%edx
  801aee:	74 14                	je     801b04 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801af0:	83 ec 08             	sub    $0x8,%esp
  801af3:	ff 75 0c             	pushl  0xc(%ebp)
  801af6:	50                   	push   %eax
  801af7:	ff d2                	call   *%edx
  801af9:	89 c2                	mov    %eax,%edx
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	eb 09                	jmp    801b09 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b00:	89 c2                	mov    %eax,%edx
  801b02:	eb 05                	jmp    801b09 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b04:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801b09:	89 d0                	mov    %edx,%eax
  801b0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	53                   	push   %ebx
  801b14:	83 ec 14             	sub    $0x14,%esp
  801b17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b1a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b1d:	50                   	push   %eax
  801b1e:	ff 75 08             	pushl  0x8(%ebp)
  801b21:	e8 60 fb ff ff       	call   801686 <fd_lookup>
  801b26:	83 c4 08             	add    $0x8,%esp
  801b29:	89 c2                	mov    %eax,%edx
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	78 58                	js     801b87 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b2f:	83 ec 08             	sub    $0x8,%esp
  801b32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b35:	50                   	push   %eax
  801b36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b39:	ff 30                	pushl  (%eax)
  801b3b:	e8 9c fb ff ff       	call   8016dc <dev_lookup>
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	85 c0                	test   %eax,%eax
  801b45:	78 37                	js     801b7e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b4e:	74 32                	je     801b82 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b50:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b53:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b5a:	00 00 00 
	stat->st_isdir = 0;
  801b5d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b64:	00 00 00 
	stat->st_dev = dev;
  801b67:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b6d:	83 ec 08             	sub    $0x8,%esp
  801b70:	53                   	push   %ebx
  801b71:	ff 75 f0             	pushl  -0x10(%ebp)
  801b74:	ff 50 14             	call   *0x14(%eax)
  801b77:	89 c2                	mov    %eax,%edx
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	eb 09                	jmp    801b87 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b7e:	89 c2                	mov    %eax,%edx
  801b80:	eb 05                	jmp    801b87 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801b82:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801b87:	89 d0                	mov    %edx,%eax
  801b89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8c:	c9                   	leave  
  801b8d:	c3                   	ret    

00801b8e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	56                   	push   %esi
  801b92:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b93:	83 ec 08             	sub    $0x8,%esp
  801b96:	6a 00                	push   $0x0
  801b98:	ff 75 08             	pushl  0x8(%ebp)
  801b9b:	e8 e3 01 00 00       	call   801d83 <open>
  801ba0:	89 c3                	mov    %eax,%ebx
  801ba2:	83 c4 10             	add    $0x10,%esp
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	78 1b                	js     801bc4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801ba9:	83 ec 08             	sub    $0x8,%esp
  801bac:	ff 75 0c             	pushl  0xc(%ebp)
  801baf:	50                   	push   %eax
  801bb0:	e8 5b ff ff ff       	call   801b10 <fstat>
  801bb5:	89 c6                	mov    %eax,%esi
	close(fd);
  801bb7:	89 1c 24             	mov    %ebx,(%esp)
  801bba:	e8 f4 fb ff ff       	call   8017b3 <close>
	return r;
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	89 f0                	mov    %esi,%eax
}
  801bc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc7:	5b                   	pop    %ebx
  801bc8:	5e                   	pop    %esi
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    

00801bcb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	56                   	push   %esi
  801bcf:	53                   	push   %ebx
  801bd0:	89 c6                	mov    %eax,%esi
  801bd2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801bd4:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  801bdb:	75 12                	jne    801bef <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801bdd:	83 ec 0c             	sub    $0xc,%esp
  801be0:	6a 01                	push   $0x1
  801be2:	e8 21 08 00 00       	call   802408 <ipc_find_env>
  801be7:	a3 00 44 80 00       	mov    %eax,0x804400
  801bec:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801bef:	6a 07                	push   $0x7
  801bf1:	68 00 50 80 00       	push   $0x805000
  801bf6:	56                   	push   %esi
  801bf7:	ff 35 00 44 80 00    	pushl  0x804400
  801bfd:	e8 a4 07 00 00       	call   8023a6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c02:	83 c4 0c             	add    $0xc,%esp
  801c05:	6a 00                	push   $0x0
  801c07:	53                   	push   %ebx
  801c08:	6a 00                	push   $0x0
  801c0a:	e8 1c 07 00 00       	call   80232b <ipc_recv>
}
  801c0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    

00801c16 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1f:	8b 40 0c             	mov    0xc(%eax),%eax
  801c22:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c34:	b8 02 00 00 00       	mov    $0x2,%eax
  801c39:	e8 8d ff ff ff       	call   801bcb <fsipc>
}
  801c3e:	c9                   	leave  
  801c3f:	c3                   	ret    

00801c40 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c46:	8b 45 08             	mov    0x8(%ebp),%eax
  801c49:	8b 40 0c             	mov    0xc(%eax),%eax
  801c4c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c51:	ba 00 00 00 00       	mov    $0x0,%edx
  801c56:	b8 06 00 00 00       	mov    $0x6,%eax
  801c5b:	e8 6b ff ff ff       	call   801bcb <fsipc>
}
  801c60:	c9                   	leave  
  801c61:	c3                   	ret    

00801c62 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	53                   	push   %ebx
  801c66:	83 ec 04             	sub    $0x4,%esp
  801c69:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6f:	8b 40 0c             	mov    0xc(%eax),%eax
  801c72:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c77:	ba 00 00 00 00       	mov    $0x0,%edx
  801c7c:	b8 05 00 00 00       	mov    $0x5,%eax
  801c81:	e8 45 ff ff ff       	call   801bcb <fsipc>
  801c86:	85 c0                	test   %eax,%eax
  801c88:	78 2c                	js     801cb6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c8a:	83 ec 08             	sub    $0x8,%esp
  801c8d:	68 00 50 80 00       	push   $0x805000
  801c92:	53                   	push   %ebx
  801c93:	e8 a8 ed ff ff       	call   800a40 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c98:	a1 80 50 80 00       	mov    0x805080,%eax
  801c9d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ca3:	a1 84 50 80 00       	mov    0x805084,%eax
  801ca8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb9:	c9                   	leave  
  801cba:	c3                   	ret    

00801cbb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	83 ec 0c             	sub    $0xc,%esp
  801cc1:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  801cc7:	8b 52 0c             	mov    0xc(%edx),%edx
  801cca:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801cd0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801cd5:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801cda:	0f 47 c2             	cmova  %edx,%eax
  801cdd:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801ce2:	50                   	push   %eax
  801ce3:	ff 75 0c             	pushl  0xc(%ebp)
  801ce6:	68 08 50 80 00       	push   $0x805008
  801ceb:	e8 e2 ee ff ff       	call   800bd2 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801cf0:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf5:	b8 04 00 00 00       	mov    $0x4,%eax
  801cfa:	e8 cc fe ff ff       	call   801bcb <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801cff:	c9                   	leave  
  801d00:	c3                   	ret    

00801d01 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	56                   	push   %esi
  801d05:	53                   	push   %ebx
  801d06:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d09:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d0f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801d14:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d1a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d1f:	b8 03 00 00 00       	mov    $0x3,%eax
  801d24:	e8 a2 fe ff ff       	call   801bcb <fsipc>
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	78 4b                	js     801d7a <devfile_read+0x79>
		return r;
	assert(r <= n);
  801d2f:	39 c6                	cmp    %eax,%esi
  801d31:	73 16                	jae    801d49 <devfile_read+0x48>
  801d33:	68 e8 2c 80 00       	push   $0x802ce8
  801d38:	68 ef 2c 80 00       	push   $0x802cef
  801d3d:	6a 7c                	push   $0x7c
  801d3f:	68 04 2d 80 00       	push   $0x802d04
  801d44:	e8 a6 e5 ff ff       	call   8002ef <_panic>
	assert(r <= PGSIZE);
  801d49:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d4e:	7e 16                	jle    801d66 <devfile_read+0x65>
  801d50:	68 0f 2d 80 00       	push   $0x802d0f
  801d55:	68 ef 2c 80 00       	push   $0x802cef
  801d5a:	6a 7d                	push   $0x7d
  801d5c:	68 04 2d 80 00       	push   $0x802d04
  801d61:	e8 89 e5 ff ff       	call   8002ef <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801d66:	83 ec 04             	sub    $0x4,%esp
  801d69:	50                   	push   %eax
  801d6a:	68 00 50 80 00       	push   $0x805000
  801d6f:	ff 75 0c             	pushl  0xc(%ebp)
  801d72:	e8 5b ee ff ff       	call   800bd2 <memmove>
	return r;
  801d77:	83 c4 10             	add    $0x10,%esp
}
  801d7a:	89 d8                	mov    %ebx,%eax
  801d7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d7f:	5b                   	pop    %ebx
  801d80:	5e                   	pop    %esi
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    

00801d83 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	53                   	push   %ebx
  801d87:	83 ec 20             	sub    $0x20,%esp
  801d8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801d8d:	53                   	push   %ebx
  801d8e:	e8 74 ec ff ff       	call   800a07 <strlen>
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d9b:	7f 67                	jg     801e04 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d9d:	83 ec 0c             	sub    $0xc,%esp
  801da0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da3:	50                   	push   %eax
  801da4:	e8 8e f8 ff ff       	call   801637 <fd_alloc>
  801da9:	83 c4 10             	add    $0x10,%esp
		return r;
  801dac:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801dae:	85 c0                	test   %eax,%eax
  801db0:	78 57                	js     801e09 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801db2:	83 ec 08             	sub    $0x8,%esp
  801db5:	53                   	push   %ebx
  801db6:	68 00 50 80 00       	push   $0x805000
  801dbb:	e8 80 ec ff ff       	call   800a40 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801dc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801dc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dcb:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd0:	e8 f6 fd ff ff       	call   801bcb <fsipc>
  801dd5:	89 c3                	mov    %eax,%ebx
  801dd7:	83 c4 10             	add    $0x10,%esp
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	79 14                	jns    801df2 <open+0x6f>
		fd_close(fd, 0);
  801dde:	83 ec 08             	sub    $0x8,%esp
  801de1:	6a 00                	push   $0x0
  801de3:	ff 75 f4             	pushl  -0xc(%ebp)
  801de6:	e8 47 f9 ff ff       	call   801732 <fd_close>
		return r;
  801deb:	83 c4 10             	add    $0x10,%esp
  801dee:	89 da                	mov    %ebx,%edx
  801df0:	eb 17                	jmp    801e09 <open+0x86>
	}

	return fd2num(fd);
  801df2:	83 ec 0c             	sub    $0xc,%esp
  801df5:	ff 75 f4             	pushl  -0xc(%ebp)
  801df8:	e8 13 f8 ff ff       	call   801610 <fd2num>
  801dfd:	89 c2                	mov    %eax,%edx
  801dff:	83 c4 10             	add    $0x10,%esp
  801e02:	eb 05                	jmp    801e09 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801e04:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801e09:	89 d0                	mov    %edx,%eax
  801e0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e0e:	c9                   	leave  
  801e0f:	c3                   	ret    

00801e10 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e16:	ba 00 00 00 00       	mov    $0x0,%edx
  801e1b:	b8 08 00 00 00       	mov    $0x8,%eax
  801e20:	e8 a6 fd ff ff       	call   801bcb <fsipc>
}
  801e25:	c9                   	leave  
  801e26:	c3                   	ret    

00801e27 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801e27:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801e2b:	7e 37                	jle    801e64 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	53                   	push   %ebx
  801e31:	83 ec 08             	sub    $0x8,%esp
  801e34:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801e36:	ff 70 04             	pushl  0x4(%eax)
  801e39:	8d 40 10             	lea    0x10(%eax),%eax
  801e3c:	50                   	push   %eax
  801e3d:	ff 33                	pushl  (%ebx)
  801e3f:	e8 88 fb ff ff       	call   8019cc <write>
		if (result > 0)
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	85 c0                	test   %eax,%eax
  801e49:	7e 03                	jle    801e4e <writebuf+0x27>
			b->result += result;
  801e4b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801e4e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e51:	74 0d                	je     801e60 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801e53:	85 c0                	test   %eax,%eax
  801e55:	ba 00 00 00 00       	mov    $0x0,%edx
  801e5a:	0f 4f c2             	cmovg  %edx,%eax
  801e5d:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801e60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e63:	c9                   	leave  
  801e64:	f3 c3                	repz ret 

00801e66 <putch>:

static void
putch(int ch, void *thunk)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	53                   	push   %ebx
  801e6a:	83 ec 04             	sub    $0x4,%esp
  801e6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801e70:	8b 53 04             	mov    0x4(%ebx),%edx
  801e73:	8d 42 01             	lea    0x1(%edx),%eax
  801e76:	89 43 04             	mov    %eax,0x4(%ebx)
  801e79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e7c:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801e80:	3d 00 01 00 00       	cmp    $0x100,%eax
  801e85:	75 0e                	jne    801e95 <putch+0x2f>
		writebuf(b);
  801e87:	89 d8                	mov    %ebx,%eax
  801e89:	e8 99 ff ff ff       	call   801e27 <writebuf>
		b->idx = 0;
  801e8e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801e95:	83 c4 04             	add    $0x4,%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    

00801e9b <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801ea4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea7:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801ead:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801eb4:	00 00 00 
	b.result = 0;
  801eb7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801ebe:	00 00 00 
	b.error = 1;
  801ec1:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801ec8:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801ecb:	ff 75 10             	pushl  0x10(%ebp)
  801ece:	ff 75 0c             	pushl  0xc(%ebp)
  801ed1:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801ed7:	50                   	push   %eax
  801ed8:	68 66 1e 80 00       	push   $0x801e66
  801edd:	e8 1d e6 ff ff       	call   8004ff <vprintfmt>
	if (b.idx > 0)
  801ee2:	83 c4 10             	add    $0x10,%esp
  801ee5:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801eec:	7e 0b                	jle    801ef9 <vfprintf+0x5e>
		writebuf(&b);
  801eee:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801ef4:	e8 2e ff ff ff       	call   801e27 <writebuf>

	return (b.result ? b.result : b.error);
  801ef9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801eff:	85 c0                	test   %eax,%eax
  801f01:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801f08:	c9                   	leave  
  801f09:	c3                   	ret    

00801f0a <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801f10:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801f13:	50                   	push   %eax
  801f14:	ff 75 0c             	pushl  0xc(%ebp)
  801f17:	ff 75 08             	pushl  0x8(%ebp)
  801f1a:	e8 7c ff ff ff       	call   801e9b <vfprintf>
	va_end(ap);

	return cnt;
}
  801f1f:	c9                   	leave  
  801f20:	c3                   	ret    

00801f21 <printf>:

int
printf(const char *fmt, ...)
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801f27:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801f2a:	50                   	push   %eax
  801f2b:	ff 75 08             	pushl  0x8(%ebp)
  801f2e:	6a 01                	push   $0x1
  801f30:	e8 66 ff ff ff       	call   801e9b <vfprintf>
	va_end(ap);

	return cnt;
}
  801f35:	c9                   	leave  
  801f36:	c3                   	ret    

00801f37 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	56                   	push   %esi
  801f3b:	53                   	push   %ebx
  801f3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f3f:	83 ec 0c             	sub    $0xc,%esp
  801f42:	ff 75 08             	pushl  0x8(%ebp)
  801f45:	e8 d6 f6 ff ff       	call   801620 <fd2data>
  801f4a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f4c:	83 c4 08             	add    $0x8,%esp
  801f4f:	68 1b 2d 80 00       	push   $0x802d1b
  801f54:	53                   	push   %ebx
  801f55:	e8 e6 ea ff ff       	call   800a40 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f5a:	8b 46 04             	mov    0x4(%esi),%eax
  801f5d:	2b 06                	sub    (%esi),%eax
  801f5f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f65:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f6c:	00 00 00 
	stat->st_dev = &devpipe;
  801f6f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f76:	30 80 00 
	return 0;
}
  801f79:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f81:	5b                   	pop    %ebx
  801f82:	5e                   	pop    %esi
  801f83:	5d                   	pop    %ebp
  801f84:	c3                   	ret    

00801f85 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f85:	55                   	push   %ebp
  801f86:	89 e5                	mov    %esp,%ebp
  801f88:	53                   	push   %ebx
  801f89:	83 ec 0c             	sub    $0xc,%esp
  801f8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f8f:	53                   	push   %ebx
  801f90:	6a 00                	push   $0x0
  801f92:	e8 31 ef ff ff       	call   800ec8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f97:	89 1c 24             	mov    %ebx,(%esp)
  801f9a:	e8 81 f6 ff ff       	call   801620 <fd2data>
  801f9f:	83 c4 08             	add    $0x8,%esp
  801fa2:	50                   	push   %eax
  801fa3:	6a 00                	push   $0x0
  801fa5:	e8 1e ef ff ff       	call   800ec8 <sys_page_unmap>
}
  801faa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fad:	c9                   	leave  
  801fae:	c3                   	ret    

00801faf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	57                   	push   %edi
  801fb3:	56                   	push   %esi
  801fb4:	53                   	push   %ebx
  801fb5:	83 ec 1c             	sub    $0x1c,%esp
  801fb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fbb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fbd:	a1 04 44 80 00       	mov    0x804404,%eax
  801fc2:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fc8:	83 ec 0c             	sub    $0xc,%esp
  801fcb:	ff 75 e0             	pushl  -0x20(%ebp)
  801fce:	e8 7a 04 00 00       	call   80244d <pageref>
  801fd3:	89 c3                	mov    %eax,%ebx
  801fd5:	89 3c 24             	mov    %edi,(%esp)
  801fd8:	e8 70 04 00 00       	call   80244d <pageref>
  801fdd:	83 c4 10             	add    $0x10,%esp
  801fe0:	39 c3                	cmp    %eax,%ebx
  801fe2:	0f 94 c1             	sete   %cl
  801fe5:	0f b6 c9             	movzbl %cl,%ecx
  801fe8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801feb:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801ff1:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801ff7:	39 ce                	cmp    %ecx,%esi
  801ff9:	74 1e                	je     802019 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801ffb:	39 c3                	cmp    %eax,%ebx
  801ffd:	75 be                	jne    801fbd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fff:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  802005:	ff 75 e4             	pushl  -0x1c(%ebp)
  802008:	50                   	push   %eax
  802009:	56                   	push   %esi
  80200a:	68 22 2d 80 00       	push   $0x802d22
  80200f:	e8 b4 e3 ff ff       	call   8003c8 <cprintf>
  802014:	83 c4 10             	add    $0x10,%esp
  802017:	eb a4                	jmp    801fbd <_pipeisclosed+0xe>
	}
}
  802019:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80201c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80201f:	5b                   	pop    %ebx
  802020:	5e                   	pop    %esi
  802021:	5f                   	pop    %edi
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    

00802024 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	57                   	push   %edi
  802028:	56                   	push   %esi
  802029:	53                   	push   %ebx
  80202a:	83 ec 28             	sub    $0x28,%esp
  80202d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802030:	56                   	push   %esi
  802031:	e8 ea f5 ff ff       	call   801620 <fd2data>
  802036:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802038:	83 c4 10             	add    $0x10,%esp
  80203b:	bf 00 00 00 00       	mov    $0x0,%edi
  802040:	eb 4b                	jmp    80208d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802042:	89 da                	mov    %ebx,%edx
  802044:	89 f0                	mov    %esi,%eax
  802046:	e8 64 ff ff ff       	call   801faf <_pipeisclosed>
  80204b:	85 c0                	test   %eax,%eax
  80204d:	75 48                	jne    802097 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80204f:	e8 d0 ed ff ff       	call   800e24 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802054:	8b 43 04             	mov    0x4(%ebx),%eax
  802057:	8b 0b                	mov    (%ebx),%ecx
  802059:	8d 51 20             	lea    0x20(%ecx),%edx
  80205c:	39 d0                	cmp    %edx,%eax
  80205e:	73 e2                	jae    802042 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802060:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802063:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802067:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80206a:	89 c2                	mov    %eax,%edx
  80206c:	c1 fa 1f             	sar    $0x1f,%edx
  80206f:	89 d1                	mov    %edx,%ecx
  802071:	c1 e9 1b             	shr    $0x1b,%ecx
  802074:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802077:	83 e2 1f             	and    $0x1f,%edx
  80207a:	29 ca                	sub    %ecx,%edx
  80207c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802080:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802084:	83 c0 01             	add    $0x1,%eax
  802087:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80208a:	83 c7 01             	add    $0x1,%edi
  80208d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802090:	75 c2                	jne    802054 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802092:	8b 45 10             	mov    0x10(%ebp),%eax
  802095:	eb 05                	jmp    80209c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802097:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80209c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5f                   	pop    %edi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    

008020a4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	57                   	push   %edi
  8020a8:	56                   	push   %esi
  8020a9:	53                   	push   %ebx
  8020aa:	83 ec 18             	sub    $0x18,%esp
  8020ad:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020b0:	57                   	push   %edi
  8020b1:	e8 6a f5 ff ff       	call   801620 <fd2data>
  8020b6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020b8:	83 c4 10             	add    $0x10,%esp
  8020bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020c0:	eb 3d                	jmp    8020ff <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020c2:	85 db                	test   %ebx,%ebx
  8020c4:	74 04                	je     8020ca <devpipe_read+0x26>
				return i;
  8020c6:	89 d8                	mov    %ebx,%eax
  8020c8:	eb 44                	jmp    80210e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020ca:	89 f2                	mov    %esi,%edx
  8020cc:	89 f8                	mov    %edi,%eax
  8020ce:	e8 dc fe ff ff       	call   801faf <_pipeisclosed>
  8020d3:	85 c0                	test   %eax,%eax
  8020d5:	75 32                	jne    802109 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020d7:	e8 48 ed ff ff       	call   800e24 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020dc:	8b 06                	mov    (%esi),%eax
  8020de:	3b 46 04             	cmp    0x4(%esi),%eax
  8020e1:	74 df                	je     8020c2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020e3:	99                   	cltd   
  8020e4:	c1 ea 1b             	shr    $0x1b,%edx
  8020e7:	01 d0                	add    %edx,%eax
  8020e9:	83 e0 1f             	and    $0x1f,%eax
  8020ec:	29 d0                	sub    %edx,%eax
  8020ee:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020f6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020f9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020fc:	83 c3 01             	add    $0x1,%ebx
  8020ff:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802102:	75 d8                	jne    8020dc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802104:	8b 45 10             	mov    0x10(%ebp),%eax
  802107:	eb 05                	jmp    80210e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802109:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80210e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802111:	5b                   	pop    %ebx
  802112:	5e                   	pop    %esi
  802113:	5f                   	pop    %edi
  802114:	5d                   	pop    %ebp
  802115:	c3                   	ret    

00802116 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	56                   	push   %esi
  80211a:	53                   	push   %ebx
  80211b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80211e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802121:	50                   	push   %eax
  802122:	e8 10 f5 ff ff       	call   801637 <fd_alloc>
  802127:	83 c4 10             	add    $0x10,%esp
  80212a:	89 c2                	mov    %eax,%edx
  80212c:	85 c0                	test   %eax,%eax
  80212e:	0f 88 2c 01 00 00    	js     802260 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802134:	83 ec 04             	sub    $0x4,%esp
  802137:	68 07 04 00 00       	push   $0x407
  80213c:	ff 75 f4             	pushl  -0xc(%ebp)
  80213f:	6a 00                	push   $0x0
  802141:	e8 fd ec ff ff       	call   800e43 <sys_page_alloc>
  802146:	83 c4 10             	add    $0x10,%esp
  802149:	89 c2                	mov    %eax,%edx
  80214b:	85 c0                	test   %eax,%eax
  80214d:	0f 88 0d 01 00 00    	js     802260 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802153:	83 ec 0c             	sub    $0xc,%esp
  802156:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802159:	50                   	push   %eax
  80215a:	e8 d8 f4 ff ff       	call   801637 <fd_alloc>
  80215f:	89 c3                	mov    %eax,%ebx
  802161:	83 c4 10             	add    $0x10,%esp
  802164:	85 c0                	test   %eax,%eax
  802166:	0f 88 e2 00 00 00    	js     80224e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80216c:	83 ec 04             	sub    $0x4,%esp
  80216f:	68 07 04 00 00       	push   $0x407
  802174:	ff 75 f0             	pushl  -0x10(%ebp)
  802177:	6a 00                	push   $0x0
  802179:	e8 c5 ec ff ff       	call   800e43 <sys_page_alloc>
  80217e:	89 c3                	mov    %eax,%ebx
  802180:	83 c4 10             	add    $0x10,%esp
  802183:	85 c0                	test   %eax,%eax
  802185:	0f 88 c3 00 00 00    	js     80224e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80218b:	83 ec 0c             	sub    $0xc,%esp
  80218e:	ff 75 f4             	pushl  -0xc(%ebp)
  802191:	e8 8a f4 ff ff       	call   801620 <fd2data>
  802196:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802198:	83 c4 0c             	add    $0xc,%esp
  80219b:	68 07 04 00 00       	push   $0x407
  8021a0:	50                   	push   %eax
  8021a1:	6a 00                	push   $0x0
  8021a3:	e8 9b ec ff ff       	call   800e43 <sys_page_alloc>
  8021a8:	89 c3                	mov    %eax,%ebx
  8021aa:	83 c4 10             	add    $0x10,%esp
  8021ad:	85 c0                	test   %eax,%eax
  8021af:	0f 88 89 00 00 00    	js     80223e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021b5:	83 ec 0c             	sub    $0xc,%esp
  8021b8:	ff 75 f0             	pushl  -0x10(%ebp)
  8021bb:	e8 60 f4 ff ff       	call   801620 <fd2data>
  8021c0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021c7:	50                   	push   %eax
  8021c8:	6a 00                	push   $0x0
  8021ca:	56                   	push   %esi
  8021cb:	6a 00                	push   $0x0
  8021cd:	e8 b4 ec ff ff       	call   800e86 <sys_page_map>
  8021d2:	89 c3                	mov    %eax,%ebx
  8021d4:	83 c4 20             	add    $0x20,%esp
  8021d7:	85 c0                	test   %eax,%eax
  8021d9:	78 55                	js     802230 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021db:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021f0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021f9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021fe:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802205:	83 ec 0c             	sub    $0xc,%esp
  802208:	ff 75 f4             	pushl  -0xc(%ebp)
  80220b:	e8 00 f4 ff ff       	call   801610 <fd2num>
  802210:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802213:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802215:	83 c4 04             	add    $0x4,%esp
  802218:	ff 75 f0             	pushl  -0x10(%ebp)
  80221b:	e8 f0 f3 ff ff       	call   801610 <fd2num>
  802220:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802223:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802226:	83 c4 10             	add    $0x10,%esp
  802229:	ba 00 00 00 00       	mov    $0x0,%edx
  80222e:	eb 30                	jmp    802260 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802230:	83 ec 08             	sub    $0x8,%esp
  802233:	56                   	push   %esi
  802234:	6a 00                	push   $0x0
  802236:	e8 8d ec ff ff       	call   800ec8 <sys_page_unmap>
  80223b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80223e:	83 ec 08             	sub    $0x8,%esp
  802241:	ff 75 f0             	pushl  -0x10(%ebp)
  802244:	6a 00                	push   $0x0
  802246:	e8 7d ec ff ff       	call   800ec8 <sys_page_unmap>
  80224b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80224e:	83 ec 08             	sub    $0x8,%esp
  802251:	ff 75 f4             	pushl  -0xc(%ebp)
  802254:	6a 00                	push   $0x0
  802256:	e8 6d ec ff ff       	call   800ec8 <sys_page_unmap>
  80225b:	83 c4 10             	add    $0x10,%esp
  80225e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802260:	89 d0                	mov    %edx,%eax
  802262:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802265:	5b                   	pop    %ebx
  802266:	5e                   	pop    %esi
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    

00802269 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802269:	55                   	push   %ebp
  80226a:	89 e5                	mov    %esp,%ebp
  80226c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80226f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802272:	50                   	push   %eax
  802273:	ff 75 08             	pushl  0x8(%ebp)
  802276:	e8 0b f4 ff ff       	call   801686 <fd_lookup>
  80227b:	83 c4 10             	add    $0x10,%esp
  80227e:	85 c0                	test   %eax,%eax
  802280:	78 18                	js     80229a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802282:	83 ec 0c             	sub    $0xc,%esp
  802285:	ff 75 f4             	pushl  -0xc(%ebp)
  802288:	e8 93 f3 ff ff       	call   801620 <fd2data>
	return _pipeisclosed(fd, p);
  80228d:	89 c2                	mov    %eax,%edx
  80228f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802292:	e8 18 fd ff ff       	call   801faf <_pipeisclosed>
  802297:	83 c4 10             	add    $0x10,%esp
}
  80229a:	c9                   	leave  
  80229b:	c3                   	ret    

0080229c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022a2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8022a9:	75 2a                	jne    8022d5 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8022ab:	83 ec 04             	sub    $0x4,%esp
  8022ae:	6a 07                	push   $0x7
  8022b0:	68 00 f0 bf ee       	push   $0xeebff000
  8022b5:	6a 00                	push   $0x0
  8022b7:	e8 87 eb ff ff       	call   800e43 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8022bc:	83 c4 10             	add    $0x10,%esp
  8022bf:	85 c0                	test   %eax,%eax
  8022c1:	79 12                	jns    8022d5 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8022c3:	50                   	push   %eax
  8022c4:	68 cb 2a 80 00       	push   $0x802acb
  8022c9:	6a 23                	push   $0x23
  8022cb:	68 3a 2d 80 00       	push   $0x802d3a
  8022d0:	e8 1a e0 ff ff       	call   8002ef <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d8:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8022dd:	83 ec 08             	sub    $0x8,%esp
  8022e0:	68 07 23 80 00       	push   $0x802307
  8022e5:	6a 00                	push   $0x0
  8022e7:	e8 a2 ec ff ff       	call   800f8e <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8022ec:	83 c4 10             	add    $0x10,%esp
  8022ef:	85 c0                	test   %eax,%eax
  8022f1:	79 12                	jns    802305 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8022f3:	50                   	push   %eax
  8022f4:	68 cb 2a 80 00       	push   $0x802acb
  8022f9:	6a 2c                	push   $0x2c
  8022fb:	68 3a 2d 80 00       	push   $0x802d3a
  802300:	e8 ea df ff ff       	call   8002ef <_panic>
	}
}
  802305:	c9                   	leave  
  802306:	c3                   	ret    

00802307 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802307:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802308:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80230d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80230f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802312:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802316:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80231b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80231f:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802321:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802324:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802325:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802328:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802329:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80232a:	c3                   	ret    

0080232b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80232b:	55                   	push   %ebp
  80232c:	89 e5                	mov    %esp,%ebp
  80232e:	56                   	push   %esi
  80232f:	53                   	push   %ebx
  802330:	8b 75 08             	mov    0x8(%ebp),%esi
  802333:	8b 45 0c             	mov    0xc(%ebp),%eax
  802336:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802339:	85 c0                	test   %eax,%eax
  80233b:	75 12                	jne    80234f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80233d:	83 ec 0c             	sub    $0xc,%esp
  802340:	68 00 00 c0 ee       	push   $0xeec00000
  802345:	e8 a9 ec ff ff       	call   800ff3 <sys_ipc_recv>
  80234a:	83 c4 10             	add    $0x10,%esp
  80234d:	eb 0c                	jmp    80235b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80234f:	83 ec 0c             	sub    $0xc,%esp
  802352:	50                   	push   %eax
  802353:	e8 9b ec ff ff       	call   800ff3 <sys_ipc_recv>
  802358:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80235b:	85 f6                	test   %esi,%esi
  80235d:	0f 95 c1             	setne  %cl
  802360:	85 db                	test   %ebx,%ebx
  802362:	0f 95 c2             	setne  %dl
  802365:	84 d1                	test   %dl,%cl
  802367:	74 09                	je     802372 <ipc_recv+0x47>
  802369:	89 c2                	mov    %eax,%edx
  80236b:	c1 ea 1f             	shr    $0x1f,%edx
  80236e:	84 d2                	test   %dl,%dl
  802370:	75 2d                	jne    80239f <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802372:	85 f6                	test   %esi,%esi
  802374:	74 0d                	je     802383 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802376:	a1 04 44 80 00       	mov    0x804404,%eax
  80237b:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802381:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802383:	85 db                	test   %ebx,%ebx
  802385:	74 0d                	je     802394 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802387:	a1 04 44 80 00       	mov    0x804404,%eax
  80238c:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  802392:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802394:	a1 04 44 80 00       	mov    0x804404,%eax
  802399:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  80239f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023a2:	5b                   	pop    %ebx
  8023a3:	5e                   	pop    %esi
  8023a4:	5d                   	pop    %ebp
  8023a5:	c3                   	ret    

008023a6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023a6:	55                   	push   %ebp
  8023a7:	89 e5                	mov    %esp,%ebp
  8023a9:	57                   	push   %edi
  8023aa:	56                   	push   %esi
  8023ab:	53                   	push   %ebx
  8023ac:	83 ec 0c             	sub    $0xc,%esp
  8023af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8023b8:	85 db                	test   %ebx,%ebx
  8023ba:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023bf:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8023c2:	ff 75 14             	pushl  0x14(%ebp)
  8023c5:	53                   	push   %ebx
  8023c6:	56                   	push   %esi
  8023c7:	57                   	push   %edi
  8023c8:	e8 03 ec ff ff       	call   800fd0 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8023cd:	89 c2                	mov    %eax,%edx
  8023cf:	c1 ea 1f             	shr    $0x1f,%edx
  8023d2:	83 c4 10             	add    $0x10,%esp
  8023d5:	84 d2                	test   %dl,%dl
  8023d7:	74 17                	je     8023f0 <ipc_send+0x4a>
  8023d9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023dc:	74 12                	je     8023f0 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8023de:	50                   	push   %eax
  8023df:	68 48 2d 80 00       	push   $0x802d48
  8023e4:	6a 47                	push   $0x47
  8023e6:	68 56 2d 80 00       	push   $0x802d56
  8023eb:	e8 ff de ff ff       	call   8002ef <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8023f0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023f3:	75 07                	jne    8023fc <ipc_send+0x56>
			sys_yield();
  8023f5:	e8 2a ea ff ff       	call   800e24 <sys_yield>
  8023fa:	eb c6                	jmp    8023c2 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8023fc:	85 c0                	test   %eax,%eax
  8023fe:	75 c2                	jne    8023c2 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802400:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802403:	5b                   	pop    %ebx
  802404:	5e                   	pop    %esi
  802405:	5f                   	pop    %edi
  802406:	5d                   	pop    %ebp
  802407:	c3                   	ret    

00802408 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802408:	55                   	push   %ebp
  802409:	89 e5                	mov    %esp,%ebp
  80240b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80240e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802413:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802419:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80241f:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802425:	39 ca                	cmp    %ecx,%edx
  802427:	75 13                	jne    80243c <ipc_find_env+0x34>
			return envs[i].env_id;
  802429:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80242f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802434:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80243a:	eb 0f                	jmp    80244b <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80243c:	83 c0 01             	add    $0x1,%eax
  80243f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802444:	75 cd                	jne    802413 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802446:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    

0080244d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80244d:	55                   	push   %ebp
  80244e:	89 e5                	mov    %esp,%ebp
  802450:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802453:	89 d0                	mov    %edx,%eax
  802455:	c1 e8 16             	shr    $0x16,%eax
  802458:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80245f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802464:	f6 c1 01             	test   $0x1,%cl
  802467:	74 1d                	je     802486 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802469:	c1 ea 0c             	shr    $0xc,%edx
  80246c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802473:	f6 c2 01             	test   $0x1,%dl
  802476:	74 0e                	je     802486 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802478:	c1 ea 0c             	shr    $0xc,%edx
  80247b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802482:	ef 
  802483:	0f b7 c0             	movzwl %ax,%eax
}
  802486:	5d                   	pop    %ebp
  802487:	c3                   	ret    
  802488:	66 90                	xchg   %ax,%ax
  80248a:	66 90                	xchg   %ax,%ax
  80248c:	66 90                	xchg   %ax,%ax
  80248e:	66 90                	xchg   %ax,%ax

00802490 <__udivdi3>:
  802490:	55                   	push   %ebp
  802491:	57                   	push   %edi
  802492:	56                   	push   %esi
  802493:	53                   	push   %ebx
  802494:	83 ec 1c             	sub    $0x1c,%esp
  802497:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80249b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80249f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024a7:	85 f6                	test   %esi,%esi
  8024a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024ad:	89 ca                	mov    %ecx,%edx
  8024af:	89 f8                	mov    %edi,%eax
  8024b1:	75 3d                	jne    8024f0 <__udivdi3+0x60>
  8024b3:	39 cf                	cmp    %ecx,%edi
  8024b5:	0f 87 c5 00 00 00    	ja     802580 <__udivdi3+0xf0>
  8024bb:	85 ff                	test   %edi,%edi
  8024bd:	89 fd                	mov    %edi,%ebp
  8024bf:	75 0b                	jne    8024cc <__udivdi3+0x3c>
  8024c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024c6:	31 d2                	xor    %edx,%edx
  8024c8:	f7 f7                	div    %edi
  8024ca:	89 c5                	mov    %eax,%ebp
  8024cc:	89 c8                	mov    %ecx,%eax
  8024ce:	31 d2                	xor    %edx,%edx
  8024d0:	f7 f5                	div    %ebp
  8024d2:	89 c1                	mov    %eax,%ecx
  8024d4:	89 d8                	mov    %ebx,%eax
  8024d6:	89 cf                	mov    %ecx,%edi
  8024d8:	f7 f5                	div    %ebp
  8024da:	89 c3                	mov    %eax,%ebx
  8024dc:	89 d8                	mov    %ebx,%eax
  8024de:	89 fa                	mov    %edi,%edx
  8024e0:	83 c4 1c             	add    $0x1c,%esp
  8024e3:	5b                   	pop    %ebx
  8024e4:	5e                   	pop    %esi
  8024e5:	5f                   	pop    %edi
  8024e6:	5d                   	pop    %ebp
  8024e7:	c3                   	ret    
  8024e8:	90                   	nop
  8024e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	39 ce                	cmp    %ecx,%esi
  8024f2:	77 74                	ja     802568 <__udivdi3+0xd8>
  8024f4:	0f bd fe             	bsr    %esi,%edi
  8024f7:	83 f7 1f             	xor    $0x1f,%edi
  8024fa:	0f 84 98 00 00 00    	je     802598 <__udivdi3+0x108>
  802500:	bb 20 00 00 00       	mov    $0x20,%ebx
  802505:	89 f9                	mov    %edi,%ecx
  802507:	89 c5                	mov    %eax,%ebp
  802509:	29 fb                	sub    %edi,%ebx
  80250b:	d3 e6                	shl    %cl,%esi
  80250d:	89 d9                	mov    %ebx,%ecx
  80250f:	d3 ed                	shr    %cl,%ebp
  802511:	89 f9                	mov    %edi,%ecx
  802513:	d3 e0                	shl    %cl,%eax
  802515:	09 ee                	or     %ebp,%esi
  802517:	89 d9                	mov    %ebx,%ecx
  802519:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80251d:	89 d5                	mov    %edx,%ebp
  80251f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802523:	d3 ed                	shr    %cl,%ebp
  802525:	89 f9                	mov    %edi,%ecx
  802527:	d3 e2                	shl    %cl,%edx
  802529:	89 d9                	mov    %ebx,%ecx
  80252b:	d3 e8                	shr    %cl,%eax
  80252d:	09 c2                	or     %eax,%edx
  80252f:	89 d0                	mov    %edx,%eax
  802531:	89 ea                	mov    %ebp,%edx
  802533:	f7 f6                	div    %esi
  802535:	89 d5                	mov    %edx,%ebp
  802537:	89 c3                	mov    %eax,%ebx
  802539:	f7 64 24 0c          	mull   0xc(%esp)
  80253d:	39 d5                	cmp    %edx,%ebp
  80253f:	72 10                	jb     802551 <__udivdi3+0xc1>
  802541:	8b 74 24 08          	mov    0x8(%esp),%esi
  802545:	89 f9                	mov    %edi,%ecx
  802547:	d3 e6                	shl    %cl,%esi
  802549:	39 c6                	cmp    %eax,%esi
  80254b:	73 07                	jae    802554 <__udivdi3+0xc4>
  80254d:	39 d5                	cmp    %edx,%ebp
  80254f:	75 03                	jne    802554 <__udivdi3+0xc4>
  802551:	83 eb 01             	sub    $0x1,%ebx
  802554:	31 ff                	xor    %edi,%edi
  802556:	89 d8                	mov    %ebx,%eax
  802558:	89 fa                	mov    %edi,%edx
  80255a:	83 c4 1c             	add    $0x1c,%esp
  80255d:	5b                   	pop    %ebx
  80255e:	5e                   	pop    %esi
  80255f:	5f                   	pop    %edi
  802560:	5d                   	pop    %ebp
  802561:	c3                   	ret    
  802562:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802568:	31 ff                	xor    %edi,%edi
  80256a:	31 db                	xor    %ebx,%ebx
  80256c:	89 d8                	mov    %ebx,%eax
  80256e:	89 fa                	mov    %edi,%edx
  802570:	83 c4 1c             	add    $0x1c,%esp
  802573:	5b                   	pop    %ebx
  802574:	5e                   	pop    %esi
  802575:	5f                   	pop    %edi
  802576:	5d                   	pop    %ebp
  802577:	c3                   	ret    
  802578:	90                   	nop
  802579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802580:	89 d8                	mov    %ebx,%eax
  802582:	f7 f7                	div    %edi
  802584:	31 ff                	xor    %edi,%edi
  802586:	89 c3                	mov    %eax,%ebx
  802588:	89 d8                	mov    %ebx,%eax
  80258a:	89 fa                	mov    %edi,%edx
  80258c:	83 c4 1c             	add    $0x1c,%esp
  80258f:	5b                   	pop    %ebx
  802590:	5e                   	pop    %esi
  802591:	5f                   	pop    %edi
  802592:	5d                   	pop    %ebp
  802593:	c3                   	ret    
  802594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802598:	39 ce                	cmp    %ecx,%esi
  80259a:	72 0c                	jb     8025a8 <__udivdi3+0x118>
  80259c:	31 db                	xor    %ebx,%ebx
  80259e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025a2:	0f 87 34 ff ff ff    	ja     8024dc <__udivdi3+0x4c>
  8025a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025ad:	e9 2a ff ff ff       	jmp    8024dc <__udivdi3+0x4c>
  8025b2:	66 90                	xchg   %ax,%ax
  8025b4:	66 90                	xchg   %ax,%ax
  8025b6:	66 90                	xchg   %ax,%ax
  8025b8:	66 90                	xchg   %ax,%ax
  8025ba:	66 90                	xchg   %ax,%ax
  8025bc:	66 90                	xchg   %ax,%ax
  8025be:	66 90                	xchg   %ax,%ax

008025c0 <__umoddi3>:
  8025c0:	55                   	push   %ebp
  8025c1:	57                   	push   %edi
  8025c2:	56                   	push   %esi
  8025c3:	53                   	push   %ebx
  8025c4:	83 ec 1c             	sub    $0x1c,%esp
  8025c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025d7:	85 d2                	test   %edx,%edx
  8025d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025e1:	89 f3                	mov    %esi,%ebx
  8025e3:	89 3c 24             	mov    %edi,(%esp)
  8025e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ea:	75 1c                	jne    802608 <__umoddi3+0x48>
  8025ec:	39 f7                	cmp    %esi,%edi
  8025ee:	76 50                	jbe    802640 <__umoddi3+0x80>
  8025f0:	89 c8                	mov    %ecx,%eax
  8025f2:	89 f2                	mov    %esi,%edx
  8025f4:	f7 f7                	div    %edi
  8025f6:	89 d0                	mov    %edx,%eax
  8025f8:	31 d2                	xor    %edx,%edx
  8025fa:	83 c4 1c             	add    $0x1c,%esp
  8025fd:	5b                   	pop    %ebx
  8025fe:	5e                   	pop    %esi
  8025ff:	5f                   	pop    %edi
  802600:	5d                   	pop    %ebp
  802601:	c3                   	ret    
  802602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802608:	39 f2                	cmp    %esi,%edx
  80260a:	89 d0                	mov    %edx,%eax
  80260c:	77 52                	ja     802660 <__umoddi3+0xa0>
  80260e:	0f bd ea             	bsr    %edx,%ebp
  802611:	83 f5 1f             	xor    $0x1f,%ebp
  802614:	75 5a                	jne    802670 <__umoddi3+0xb0>
  802616:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80261a:	0f 82 e0 00 00 00    	jb     802700 <__umoddi3+0x140>
  802620:	39 0c 24             	cmp    %ecx,(%esp)
  802623:	0f 86 d7 00 00 00    	jbe    802700 <__umoddi3+0x140>
  802629:	8b 44 24 08          	mov    0x8(%esp),%eax
  80262d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802631:	83 c4 1c             	add    $0x1c,%esp
  802634:	5b                   	pop    %ebx
  802635:	5e                   	pop    %esi
  802636:	5f                   	pop    %edi
  802637:	5d                   	pop    %ebp
  802638:	c3                   	ret    
  802639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802640:	85 ff                	test   %edi,%edi
  802642:	89 fd                	mov    %edi,%ebp
  802644:	75 0b                	jne    802651 <__umoddi3+0x91>
  802646:	b8 01 00 00 00       	mov    $0x1,%eax
  80264b:	31 d2                	xor    %edx,%edx
  80264d:	f7 f7                	div    %edi
  80264f:	89 c5                	mov    %eax,%ebp
  802651:	89 f0                	mov    %esi,%eax
  802653:	31 d2                	xor    %edx,%edx
  802655:	f7 f5                	div    %ebp
  802657:	89 c8                	mov    %ecx,%eax
  802659:	f7 f5                	div    %ebp
  80265b:	89 d0                	mov    %edx,%eax
  80265d:	eb 99                	jmp    8025f8 <__umoddi3+0x38>
  80265f:	90                   	nop
  802660:	89 c8                	mov    %ecx,%eax
  802662:	89 f2                	mov    %esi,%edx
  802664:	83 c4 1c             	add    $0x1c,%esp
  802667:	5b                   	pop    %ebx
  802668:	5e                   	pop    %esi
  802669:	5f                   	pop    %edi
  80266a:	5d                   	pop    %ebp
  80266b:	c3                   	ret    
  80266c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802670:	8b 34 24             	mov    (%esp),%esi
  802673:	bf 20 00 00 00       	mov    $0x20,%edi
  802678:	89 e9                	mov    %ebp,%ecx
  80267a:	29 ef                	sub    %ebp,%edi
  80267c:	d3 e0                	shl    %cl,%eax
  80267e:	89 f9                	mov    %edi,%ecx
  802680:	89 f2                	mov    %esi,%edx
  802682:	d3 ea                	shr    %cl,%edx
  802684:	89 e9                	mov    %ebp,%ecx
  802686:	09 c2                	or     %eax,%edx
  802688:	89 d8                	mov    %ebx,%eax
  80268a:	89 14 24             	mov    %edx,(%esp)
  80268d:	89 f2                	mov    %esi,%edx
  80268f:	d3 e2                	shl    %cl,%edx
  802691:	89 f9                	mov    %edi,%ecx
  802693:	89 54 24 04          	mov    %edx,0x4(%esp)
  802697:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80269b:	d3 e8                	shr    %cl,%eax
  80269d:	89 e9                	mov    %ebp,%ecx
  80269f:	89 c6                	mov    %eax,%esi
  8026a1:	d3 e3                	shl    %cl,%ebx
  8026a3:	89 f9                	mov    %edi,%ecx
  8026a5:	89 d0                	mov    %edx,%eax
  8026a7:	d3 e8                	shr    %cl,%eax
  8026a9:	89 e9                	mov    %ebp,%ecx
  8026ab:	09 d8                	or     %ebx,%eax
  8026ad:	89 d3                	mov    %edx,%ebx
  8026af:	89 f2                	mov    %esi,%edx
  8026b1:	f7 34 24             	divl   (%esp)
  8026b4:	89 d6                	mov    %edx,%esi
  8026b6:	d3 e3                	shl    %cl,%ebx
  8026b8:	f7 64 24 04          	mull   0x4(%esp)
  8026bc:	39 d6                	cmp    %edx,%esi
  8026be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026c2:	89 d1                	mov    %edx,%ecx
  8026c4:	89 c3                	mov    %eax,%ebx
  8026c6:	72 08                	jb     8026d0 <__umoddi3+0x110>
  8026c8:	75 11                	jne    8026db <__umoddi3+0x11b>
  8026ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026ce:	73 0b                	jae    8026db <__umoddi3+0x11b>
  8026d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026d4:	1b 14 24             	sbb    (%esp),%edx
  8026d7:	89 d1                	mov    %edx,%ecx
  8026d9:	89 c3                	mov    %eax,%ebx
  8026db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026df:	29 da                	sub    %ebx,%edx
  8026e1:	19 ce                	sbb    %ecx,%esi
  8026e3:	89 f9                	mov    %edi,%ecx
  8026e5:	89 f0                	mov    %esi,%eax
  8026e7:	d3 e0                	shl    %cl,%eax
  8026e9:	89 e9                	mov    %ebp,%ecx
  8026eb:	d3 ea                	shr    %cl,%edx
  8026ed:	89 e9                	mov    %ebp,%ecx
  8026ef:	d3 ee                	shr    %cl,%esi
  8026f1:	09 d0                	or     %edx,%eax
  8026f3:	89 f2                	mov    %esi,%edx
  8026f5:	83 c4 1c             	add    $0x1c,%esp
  8026f8:	5b                   	pop    %ebx
  8026f9:	5e                   	pop    %esi
  8026fa:	5f                   	pop    %edi
  8026fb:	5d                   	pop    %ebp
  8026fc:	c3                   	ret    
  8026fd:	8d 76 00             	lea    0x0(%esi),%esi
  802700:	29 f9                	sub    %edi,%ecx
  802702:	19 d6                	sbb    %edx,%esi
  802704:	89 74 24 04          	mov    %esi,0x4(%esp)
  802708:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80270c:	e9 18 ff ff ff       	jmp    802629 <__umoddi3+0x69>
