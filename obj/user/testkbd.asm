
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
  80004e:	e8 fe 14 00 00       	call   801551 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 c0 24 80 00       	push   $0x8024c0
  800065:	6a 0f                	push   $0xf
  800067:	68 cd 24 80 00       	push   $0x8024cd
  80006c:	e8 7e 02 00 00       	call   8002ef <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 dc 24 80 00       	push   $0x8024dc
  80007b:	6a 11                	push   $0x11
  80007d:	68 cd 24 80 00       	push   $0x8024cd
  800082:	e8 68 02 00 00       	call   8002ef <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 0e 15 00 00       	call   8015a1 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 f6 24 80 00       	push   $0x8024f6
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 cd 24 80 00       	push   $0x8024cd
  8000a7:	e8 43 02 00 00       	call   8002ef <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 fe 24 80 00       	push   $0x8024fe
  8000b4:	e8 5b 08 00 00       	call   800914 <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 0c 25 80 00       	push   $0x80250c
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 d8 1b 00 00       	call   801ca8 <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 10 25 80 00       	push   $0x802510
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 c4 1b 00 00       	call   801ca8 <fprintf>
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
  8000f9:	68 28 25 80 00       	push   $0x802528
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
  8001c9:	e8 bf 14 00 00       	call   80168d <read>
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
  8001f3:	e8 2c 12 00 00       	call   801424 <fd_lookup>
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
  80021c:	e8 b4 11 00 00       	call   8013d5 <fd_alloc>
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
  80025e:	e8 4b 11 00 00       	call   8013ae <fd2num>
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
  8002db:	e8 9c 12 00 00       	call   80157c <close_all>
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
  80030d:	68 40 25 80 00       	push   $0x802540
  800312:	e8 b1 00 00 00       	call   8003c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800317:	83 c4 18             	add    $0x18,%esp
  80031a:	53                   	push   %ebx
  80031b:	ff 75 10             	pushl  0x10(%ebp)
  80031e:	e8 54 00 00 00       	call   800377 <vcprintf>
	cprintf("\n");
  800323:	c7 04 24 26 25 80 00 	movl   $0x802526,(%esp)
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
  80042b:	e8 00 1e 00 00       	call   802230 <__udivdi3>
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
  80046e:	e8 ed 1e 00 00       	call   802360 <__umoddi3>
  800473:	83 c4 14             	add    $0x14,%esp
  800476:	0f be 80 63 25 80 00 	movsbl 0x802563(%eax),%eax
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
  800572:	ff 24 85 a0 26 80 00 	jmp    *0x8026a0(,%eax,4)
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
  800636:	8b 14 85 00 28 80 00 	mov    0x802800(,%eax,4),%edx
  80063d:	85 d2                	test   %edx,%edx
  80063f:	75 18                	jne    800659 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800641:	50                   	push   %eax
  800642:	68 7b 25 80 00       	push   $0x80257b
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
  80065a:	68 c1 29 80 00       	push   $0x8029c1
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
  80067e:	b8 74 25 80 00       	mov    $0x802574,%eax
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
  800928:	68 c1 29 80 00       	push   $0x8029c1
  80092d:	6a 01                	push   $0x1
  80092f:	e8 74 13 00 00       	call   801ca8 <fprintf>
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
  800968:	68 5f 28 80 00       	push   $0x80285f
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
  800dec:	68 6f 28 80 00       	push   $0x80286f
  800df1:	6a 23                	push   $0x23
  800df3:	68 8c 28 80 00       	push   $0x80288c
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
  800e6d:	68 6f 28 80 00       	push   $0x80286f
  800e72:	6a 23                	push   $0x23
  800e74:	68 8c 28 80 00       	push   $0x80288c
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
  800eaf:	68 6f 28 80 00       	push   $0x80286f
  800eb4:	6a 23                	push   $0x23
  800eb6:	68 8c 28 80 00       	push   $0x80288c
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
  800ef1:	68 6f 28 80 00       	push   $0x80286f
  800ef6:	6a 23                	push   $0x23
  800ef8:	68 8c 28 80 00       	push   $0x80288c
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
  800f33:	68 6f 28 80 00       	push   $0x80286f
  800f38:	6a 23                	push   $0x23
  800f3a:	68 8c 28 80 00       	push   $0x80288c
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
  800f75:	68 6f 28 80 00       	push   $0x80286f
  800f7a:	6a 23                	push   $0x23
  800f7c:	68 8c 28 80 00       	push   $0x80288c
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
  800fb7:	68 6f 28 80 00       	push   $0x80286f
  800fbc:	6a 23                	push   $0x23
  800fbe:	68 8c 28 80 00       	push   $0x80288c
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
  80101b:	68 6f 28 80 00       	push   $0x80286f
  801020:	6a 23                	push   $0x23
  801022:	68 8c 28 80 00       	push   $0x80288c
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
  8010ba:	68 9a 28 80 00       	push   $0x80289a
  8010bf:	6a 1e                	push   $0x1e
  8010c1:	68 aa 28 80 00       	push   $0x8028aa
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
  8010e4:	68 b5 28 80 00       	push   $0x8028b5
  8010e9:	6a 2c                	push   $0x2c
  8010eb:	68 aa 28 80 00       	push   $0x8028aa
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
  80112c:	68 b5 28 80 00       	push   $0x8028b5
  801131:	6a 33                	push   $0x33
  801133:	68 aa 28 80 00       	push   $0x8028aa
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
  801154:	68 b5 28 80 00       	push   $0x8028b5
  801159:	6a 37                	push   $0x37
  80115b:	68 aa 28 80 00       	push   $0x8028aa
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
  801178:	e8 bd 0e 00 00       	call   80203a <set_pgfault_handler>
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
  801191:	68 ce 28 80 00       	push   $0x8028ce
  801196:	68 84 00 00 00       	push   $0x84
  80119b:	68 aa 28 80 00       	push   $0x8028aa
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
  80124d:	68 dc 28 80 00       	push   $0x8028dc
  801252:	6a 54                	push   $0x54
  801254:	68 aa 28 80 00       	push   $0x8028aa
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
  801292:	68 dc 28 80 00       	push   $0x8028dc
  801297:	6a 5b                	push   $0x5b
  801299:	68 aa 28 80 00       	push   $0x8028aa
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
  8012c0:	68 dc 28 80 00       	push   $0x8028dc
  8012c5:	6a 5f                	push   $0x5f
  8012c7:	68 aa 28 80 00       	push   $0x8028aa
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
  8012ea:	68 dc 28 80 00       	push   $0x8028dc
  8012ef:	6a 64                	push   $0x64
  8012f1:	68 aa 28 80 00       	push   $0x8028aa
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
  801359:	68 f4 28 80 00       	push   $0x8028f4
  80135e:	e8 65 f0 ff ff       	call   8003c8 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801363:	c7 04 24 b5 02 80 00 	movl   $0x8002b5,(%esp)
  80136a:	e8 c5 fc ff ff       	call   801034 <sys_thread_create>
  80136f:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801371:	83 c4 08             	add    $0x8,%esp
  801374:	53                   	push   %ebx
  801375:	68 f4 28 80 00       	push   $0x8028f4
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

008013ae <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b4:	05 00 00 00 30       	add    $0x30000000,%eax
  8013b9:	c1 e8 0c             	shr    $0xc,%eax
}
  8013bc:	5d                   	pop    %ebp
  8013bd:	c3                   	ret    

008013be <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c4:	05 00 00 00 30       	add    $0x30000000,%eax
  8013c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013ce:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013d3:	5d                   	pop    %ebp
  8013d4:	c3                   	ret    

008013d5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013db:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013e0:	89 c2                	mov    %eax,%edx
  8013e2:	c1 ea 16             	shr    $0x16,%edx
  8013e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ec:	f6 c2 01             	test   $0x1,%dl
  8013ef:	74 11                	je     801402 <fd_alloc+0x2d>
  8013f1:	89 c2                	mov    %eax,%edx
  8013f3:	c1 ea 0c             	shr    $0xc,%edx
  8013f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013fd:	f6 c2 01             	test   $0x1,%dl
  801400:	75 09                	jne    80140b <fd_alloc+0x36>
			*fd_store = fd;
  801402:	89 01                	mov    %eax,(%ecx)
			return 0;
  801404:	b8 00 00 00 00       	mov    $0x0,%eax
  801409:	eb 17                	jmp    801422 <fd_alloc+0x4d>
  80140b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801410:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801415:	75 c9                	jne    8013e0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801417:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80141d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80142a:	83 f8 1f             	cmp    $0x1f,%eax
  80142d:	77 36                	ja     801465 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80142f:	c1 e0 0c             	shl    $0xc,%eax
  801432:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801437:	89 c2                	mov    %eax,%edx
  801439:	c1 ea 16             	shr    $0x16,%edx
  80143c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801443:	f6 c2 01             	test   $0x1,%dl
  801446:	74 24                	je     80146c <fd_lookup+0x48>
  801448:	89 c2                	mov    %eax,%edx
  80144a:	c1 ea 0c             	shr    $0xc,%edx
  80144d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801454:	f6 c2 01             	test   $0x1,%dl
  801457:	74 1a                	je     801473 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801459:	8b 55 0c             	mov    0xc(%ebp),%edx
  80145c:	89 02                	mov    %eax,(%edx)
	return 0;
  80145e:	b8 00 00 00 00       	mov    $0x0,%eax
  801463:	eb 13                	jmp    801478 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801465:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146a:	eb 0c                	jmp    801478 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80146c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801471:	eb 05                	jmp    801478 <fd_lookup+0x54>
  801473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801478:	5d                   	pop    %ebp
  801479:	c3                   	ret    

0080147a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	83 ec 08             	sub    $0x8,%esp
  801480:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801483:	ba 98 29 80 00       	mov    $0x802998,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801488:	eb 13                	jmp    80149d <dev_lookup+0x23>
  80148a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80148d:	39 08                	cmp    %ecx,(%eax)
  80148f:	75 0c                	jne    80149d <dev_lookup+0x23>
			*dev = devtab[i];
  801491:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801494:	89 01                	mov    %eax,(%ecx)
			return 0;
  801496:	b8 00 00 00 00       	mov    $0x0,%eax
  80149b:	eb 31                	jmp    8014ce <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80149d:	8b 02                	mov    (%edx),%eax
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	75 e7                	jne    80148a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014a3:	a1 04 44 80 00       	mov    0x804404,%eax
  8014a8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8014ae:	83 ec 04             	sub    $0x4,%esp
  8014b1:	51                   	push   %ecx
  8014b2:	50                   	push   %eax
  8014b3:	68 18 29 80 00       	push   $0x802918
  8014b8:	e8 0b ef ff ff       	call   8003c8 <cprintf>
	*dev = 0;
  8014bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	56                   	push   %esi
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 10             	sub    $0x10,%esp
  8014d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8014db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e1:	50                   	push   %eax
  8014e2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014e8:	c1 e8 0c             	shr    $0xc,%eax
  8014eb:	50                   	push   %eax
  8014ec:	e8 33 ff ff ff       	call   801424 <fd_lookup>
  8014f1:	83 c4 08             	add    $0x8,%esp
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 05                	js     8014fd <fd_close+0x2d>
	    || fd != fd2)
  8014f8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014fb:	74 0c                	je     801509 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014fd:	84 db                	test   %bl,%bl
  8014ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801504:	0f 44 c2             	cmove  %edx,%eax
  801507:	eb 41                	jmp    80154a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801509:	83 ec 08             	sub    $0x8,%esp
  80150c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150f:	50                   	push   %eax
  801510:	ff 36                	pushl  (%esi)
  801512:	e8 63 ff ff ff       	call   80147a <dev_lookup>
  801517:	89 c3                	mov    %eax,%ebx
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 1a                	js     80153a <fd_close+0x6a>
		if (dev->dev_close)
  801520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801523:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801526:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80152b:	85 c0                	test   %eax,%eax
  80152d:	74 0b                	je     80153a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80152f:	83 ec 0c             	sub    $0xc,%esp
  801532:	56                   	push   %esi
  801533:	ff d0                	call   *%eax
  801535:	89 c3                	mov    %eax,%ebx
  801537:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	56                   	push   %esi
  80153e:	6a 00                	push   $0x0
  801540:	e8 83 f9 ff ff       	call   800ec8 <sys_page_unmap>
	return r;
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	89 d8                	mov    %ebx,%eax
}
  80154a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80154d:	5b                   	pop    %ebx
  80154e:	5e                   	pop    %esi
  80154f:	5d                   	pop    %ebp
  801550:	c3                   	ret    

00801551 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801557:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155a:	50                   	push   %eax
  80155b:	ff 75 08             	pushl  0x8(%ebp)
  80155e:	e8 c1 fe ff ff       	call   801424 <fd_lookup>
  801563:	83 c4 08             	add    $0x8,%esp
  801566:	85 c0                	test   %eax,%eax
  801568:	78 10                	js     80157a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	6a 01                	push   $0x1
  80156f:	ff 75 f4             	pushl  -0xc(%ebp)
  801572:	e8 59 ff ff ff       	call   8014d0 <fd_close>
  801577:	83 c4 10             	add    $0x10,%esp
}
  80157a:	c9                   	leave  
  80157b:	c3                   	ret    

0080157c <close_all>:

void
close_all(void)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	53                   	push   %ebx
  801580:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801583:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801588:	83 ec 0c             	sub    $0xc,%esp
  80158b:	53                   	push   %ebx
  80158c:	e8 c0 ff ff ff       	call   801551 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801591:	83 c3 01             	add    $0x1,%ebx
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	83 fb 20             	cmp    $0x20,%ebx
  80159a:	75 ec                	jne    801588 <close_all+0xc>
		close(i);
}
  80159c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	57                   	push   %edi
  8015a5:	56                   	push   %esi
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 2c             	sub    $0x2c,%esp
  8015aa:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015b0:	50                   	push   %eax
  8015b1:	ff 75 08             	pushl  0x8(%ebp)
  8015b4:	e8 6b fe ff ff       	call   801424 <fd_lookup>
  8015b9:	83 c4 08             	add    $0x8,%esp
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	0f 88 c1 00 00 00    	js     801685 <dup+0xe4>
		return r;
	close(newfdnum);
  8015c4:	83 ec 0c             	sub    $0xc,%esp
  8015c7:	56                   	push   %esi
  8015c8:	e8 84 ff ff ff       	call   801551 <close>

	newfd = INDEX2FD(newfdnum);
  8015cd:	89 f3                	mov    %esi,%ebx
  8015cf:	c1 e3 0c             	shl    $0xc,%ebx
  8015d2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015d8:	83 c4 04             	add    $0x4,%esp
  8015db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015de:	e8 db fd ff ff       	call   8013be <fd2data>
  8015e3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015e5:	89 1c 24             	mov    %ebx,(%esp)
  8015e8:	e8 d1 fd ff ff       	call   8013be <fd2data>
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015f3:	89 f8                	mov    %edi,%eax
  8015f5:	c1 e8 16             	shr    $0x16,%eax
  8015f8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015ff:	a8 01                	test   $0x1,%al
  801601:	74 37                	je     80163a <dup+0x99>
  801603:	89 f8                	mov    %edi,%eax
  801605:	c1 e8 0c             	shr    $0xc,%eax
  801608:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80160f:	f6 c2 01             	test   $0x1,%dl
  801612:	74 26                	je     80163a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801614:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80161b:	83 ec 0c             	sub    $0xc,%esp
  80161e:	25 07 0e 00 00       	and    $0xe07,%eax
  801623:	50                   	push   %eax
  801624:	ff 75 d4             	pushl  -0x2c(%ebp)
  801627:	6a 00                	push   $0x0
  801629:	57                   	push   %edi
  80162a:	6a 00                	push   $0x0
  80162c:	e8 55 f8 ff ff       	call   800e86 <sys_page_map>
  801631:	89 c7                	mov    %eax,%edi
  801633:	83 c4 20             	add    $0x20,%esp
  801636:	85 c0                	test   %eax,%eax
  801638:	78 2e                	js     801668 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80163a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80163d:	89 d0                	mov    %edx,%eax
  80163f:	c1 e8 0c             	shr    $0xc,%eax
  801642:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801649:	83 ec 0c             	sub    $0xc,%esp
  80164c:	25 07 0e 00 00       	and    $0xe07,%eax
  801651:	50                   	push   %eax
  801652:	53                   	push   %ebx
  801653:	6a 00                	push   $0x0
  801655:	52                   	push   %edx
  801656:	6a 00                	push   $0x0
  801658:	e8 29 f8 ff ff       	call   800e86 <sys_page_map>
  80165d:	89 c7                	mov    %eax,%edi
  80165f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801662:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801664:	85 ff                	test   %edi,%edi
  801666:	79 1d                	jns    801685 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801668:	83 ec 08             	sub    $0x8,%esp
  80166b:	53                   	push   %ebx
  80166c:	6a 00                	push   $0x0
  80166e:	e8 55 f8 ff ff       	call   800ec8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801673:	83 c4 08             	add    $0x8,%esp
  801676:	ff 75 d4             	pushl  -0x2c(%ebp)
  801679:	6a 00                	push   $0x0
  80167b:	e8 48 f8 ff ff       	call   800ec8 <sys_page_unmap>
	return r;
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	89 f8                	mov    %edi,%eax
}
  801685:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801688:	5b                   	pop    %ebx
  801689:	5e                   	pop    %esi
  80168a:	5f                   	pop    %edi
  80168b:	5d                   	pop    %ebp
  80168c:	c3                   	ret    

0080168d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	53                   	push   %ebx
  801691:	83 ec 14             	sub    $0x14,%esp
  801694:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801697:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169a:	50                   	push   %eax
  80169b:	53                   	push   %ebx
  80169c:	e8 83 fd ff ff       	call   801424 <fd_lookup>
  8016a1:	83 c4 08             	add    $0x8,%esp
  8016a4:	89 c2                	mov    %eax,%edx
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	78 70                	js     80171a <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016aa:	83 ec 08             	sub    $0x8,%esp
  8016ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b0:	50                   	push   %eax
  8016b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b4:	ff 30                	pushl  (%eax)
  8016b6:	e8 bf fd ff ff       	call   80147a <dev_lookup>
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	78 4f                	js     801711 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016c5:	8b 42 08             	mov    0x8(%edx),%eax
  8016c8:	83 e0 03             	and    $0x3,%eax
  8016cb:	83 f8 01             	cmp    $0x1,%eax
  8016ce:	75 24                	jne    8016f4 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016d0:	a1 04 44 80 00       	mov    0x804404,%eax
  8016d5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8016db:	83 ec 04             	sub    $0x4,%esp
  8016de:	53                   	push   %ebx
  8016df:	50                   	push   %eax
  8016e0:	68 5c 29 80 00       	push   $0x80295c
  8016e5:	e8 de ec ff ff       	call   8003c8 <cprintf>
		return -E_INVAL;
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016f2:	eb 26                	jmp    80171a <read+0x8d>
	}
	if (!dev->dev_read)
  8016f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f7:	8b 40 08             	mov    0x8(%eax),%eax
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	74 17                	je     801715 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016fe:	83 ec 04             	sub    $0x4,%esp
  801701:	ff 75 10             	pushl  0x10(%ebp)
  801704:	ff 75 0c             	pushl  0xc(%ebp)
  801707:	52                   	push   %edx
  801708:	ff d0                	call   *%eax
  80170a:	89 c2                	mov    %eax,%edx
  80170c:	83 c4 10             	add    $0x10,%esp
  80170f:	eb 09                	jmp    80171a <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801711:	89 c2                	mov    %eax,%edx
  801713:	eb 05                	jmp    80171a <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801715:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80171a:	89 d0                	mov    %edx,%eax
  80171c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171f:	c9                   	leave  
  801720:	c3                   	ret    

00801721 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	57                   	push   %edi
  801725:	56                   	push   %esi
  801726:	53                   	push   %ebx
  801727:	83 ec 0c             	sub    $0xc,%esp
  80172a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80172d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801730:	bb 00 00 00 00       	mov    $0x0,%ebx
  801735:	eb 21                	jmp    801758 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801737:	83 ec 04             	sub    $0x4,%esp
  80173a:	89 f0                	mov    %esi,%eax
  80173c:	29 d8                	sub    %ebx,%eax
  80173e:	50                   	push   %eax
  80173f:	89 d8                	mov    %ebx,%eax
  801741:	03 45 0c             	add    0xc(%ebp),%eax
  801744:	50                   	push   %eax
  801745:	57                   	push   %edi
  801746:	e8 42 ff ff ff       	call   80168d <read>
		if (m < 0)
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	85 c0                	test   %eax,%eax
  801750:	78 10                	js     801762 <readn+0x41>
			return m;
		if (m == 0)
  801752:	85 c0                	test   %eax,%eax
  801754:	74 0a                	je     801760 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801756:	01 c3                	add    %eax,%ebx
  801758:	39 f3                	cmp    %esi,%ebx
  80175a:	72 db                	jb     801737 <readn+0x16>
  80175c:	89 d8                	mov    %ebx,%eax
  80175e:	eb 02                	jmp    801762 <readn+0x41>
  801760:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801762:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801765:	5b                   	pop    %ebx
  801766:	5e                   	pop    %esi
  801767:	5f                   	pop    %edi
  801768:	5d                   	pop    %ebp
  801769:	c3                   	ret    

0080176a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	53                   	push   %ebx
  80176e:	83 ec 14             	sub    $0x14,%esp
  801771:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801774:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801777:	50                   	push   %eax
  801778:	53                   	push   %ebx
  801779:	e8 a6 fc ff ff       	call   801424 <fd_lookup>
  80177e:	83 c4 08             	add    $0x8,%esp
  801781:	89 c2                	mov    %eax,%edx
  801783:	85 c0                	test   %eax,%eax
  801785:	78 6b                	js     8017f2 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801787:	83 ec 08             	sub    $0x8,%esp
  80178a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178d:	50                   	push   %eax
  80178e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801791:	ff 30                	pushl  (%eax)
  801793:	e8 e2 fc ff ff       	call   80147a <dev_lookup>
  801798:	83 c4 10             	add    $0x10,%esp
  80179b:	85 c0                	test   %eax,%eax
  80179d:	78 4a                	js     8017e9 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80179f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017a6:	75 24                	jne    8017cc <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a8:	a1 04 44 80 00       	mov    0x804404,%eax
  8017ad:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8017b3:	83 ec 04             	sub    $0x4,%esp
  8017b6:	53                   	push   %ebx
  8017b7:	50                   	push   %eax
  8017b8:	68 78 29 80 00       	push   $0x802978
  8017bd:	e8 06 ec ff ff       	call   8003c8 <cprintf>
		return -E_INVAL;
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017ca:	eb 26                	jmp    8017f2 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017cf:	8b 52 0c             	mov    0xc(%edx),%edx
  8017d2:	85 d2                	test   %edx,%edx
  8017d4:	74 17                	je     8017ed <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017d6:	83 ec 04             	sub    $0x4,%esp
  8017d9:	ff 75 10             	pushl  0x10(%ebp)
  8017dc:	ff 75 0c             	pushl  0xc(%ebp)
  8017df:	50                   	push   %eax
  8017e0:	ff d2                	call   *%edx
  8017e2:	89 c2                	mov    %eax,%edx
  8017e4:	83 c4 10             	add    $0x10,%esp
  8017e7:	eb 09                	jmp    8017f2 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e9:	89 c2                	mov    %eax,%edx
  8017eb:	eb 05                	jmp    8017f2 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017ed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017f2:	89 d0                	mov    %edx,%eax
  8017f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017ff:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801802:	50                   	push   %eax
  801803:	ff 75 08             	pushl  0x8(%ebp)
  801806:	e8 19 fc ff ff       	call   801424 <fd_lookup>
  80180b:	83 c4 08             	add    $0x8,%esp
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 0e                	js     801820 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801812:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801815:	8b 55 0c             	mov    0xc(%ebp),%edx
  801818:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80181b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	53                   	push   %ebx
  801826:	83 ec 14             	sub    $0x14,%esp
  801829:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182f:	50                   	push   %eax
  801830:	53                   	push   %ebx
  801831:	e8 ee fb ff ff       	call   801424 <fd_lookup>
  801836:	83 c4 08             	add    $0x8,%esp
  801839:	89 c2                	mov    %eax,%edx
  80183b:	85 c0                	test   %eax,%eax
  80183d:	78 68                	js     8018a7 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183f:	83 ec 08             	sub    $0x8,%esp
  801842:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801845:	50                   	push   %eax
  801846:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801849:	ff 30                	pushl  (%eax)
  80184b:	e8 2a fc ff ff       	call   80147a <dev_lookup>
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	85 c0                	test   %eax,%eax
  801855:	78 47                	js     80189e <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801857:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80185e:	75 24                	jne    801884 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801860:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801865:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80186b:	83 ec 04             	sub    $0x4,%esp
  80186e:	53                   	push   %ebx
  80186f:	50                   	push   %eax
  801870:	68 38 29 80 00       	push   $0x802938
  801875:	e8 4e eb ff ff       	call   8003c8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80187a:	83 c4 10             	add    $0x10,%esp
  80187d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801882:	eb 23                	jmp    8018a7 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801884:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801887:	8b 52 18             	mov    0x18(%edx),%edx
  80188a:	85 d2                	test   %edx,%edx
  80188c:	74 14                	je     8018a2 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80188e:	83 ec 08             	sub    $0x8,%esp
  801891:	ff 75 0c             	pushl  0xc(%ebp)
  801894:	50                   	push   %eax
  801895:	ff d2                	call   *%edx
  801897:	89 c2                	mov    %eax,%edx
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	eb 09                	jmp    8018a7 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189e:	89 c2                	mov    %eax,%edx
  8018a0:	eb 05                	jmp    8018a7 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018a7:	89 d0                	mov    %edx,%eax
  8018a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ac:	c9                   	leave  
  8018ad:	c3                   	ret    

008018ae <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	53                   	push   %ebx
  8018b2:	83 ec 14             	sub    $0x14,%esp
  8018b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018bb:	50                   	push   %eax
  8018bc:	ff 75 08             	pushl  0x8(%ebp)
  8018bf:	e8 60 fb ff ff       	call   801424 <fd_lookup>
  8018c4:	83 c4 08             	add    $0x8,%esp
  8018c7:	89 c2                	mov    %eax,%edx
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	78 58                	js     801925 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018cd:	83 ec 08             	sub    $0x8,%esp
  8018d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d3:	50                   	push   %eax
  8018d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d7:	ff 30                	pushl  (%eax)
  8018d9:	e8 9c fb ff ff       	call   80147a <dev_lookup>
  8018de:	83 c4 10             	add    $0x10,%esp
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	78 37                	js     80191c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018ec:	74 32                	je     801920 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018ee:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018f1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018f8:	00 00 00 
	stat->st_isdir = 0;
  8018fb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801902:	00 00 00 
	stat->st_dev = dev;
  801905:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80190b:	83 ec 08             	sub    $0x8,%esp
  80190e:	53                   	push   %ebx
  80190f:	ff 75 f0             	pushl  -0x10(%ebp)
  801912:	ff 50 14             	call   *0x14(%eax)
  801915:	89 c2                	mov    %eax,%edx
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	eb 09                	jmp    801925 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80191c:	89 c2                	mov    %eax,%edx
  80191e:	eb 05                	jmp    801925 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801920:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801925:	89 d0                	mov    %edx,%eax
  801927:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192a:	c9                   	leave  
  80192b:	c3                   	ret    

0080192c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801931:	83 ec 08             	sub    $0x8,%esp
  801934:	6a 00                	push   $0x0
  801936:	ff 75 08             	pushl  0x8(%ebp)
  801939:	e8 e3 01 00 00       	call   801b21 <open>
  80193e:	89 c3                	mov    %eax,%ebx
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	85 c0                	test   %eax,%eax
  801945:	78 1b                	js     801962 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801947:	83 ec 08             	sub    $0x8,%esp
  80194a:	ff 75 0c             	pushl  0xc(%ebp)
  80194d:	50                   	push   %eax
  80194e:	e8 5b ff ff ff       	call   8018ae <fstat>
  801953:	89 c6                	mov    %eax,%esi
	close(fd);
  801955:	89 1c 24             	mov    %ebx,(%esp)
  801958:	e8 f4 fb ff ff       	call   801551 <close>
	return r;
  80195d:	83 c4 10             	add    $0x10,%esp
  801960:	89 f0                	mov    %esi,%eax
}
  801962:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801965:	5b                   	pop    %ebx
  801966:	5e                   	pop    %esi
  801967:	5d                   	pop    %ebp
  801968:	c3                   	ret    

00801969 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	56                   	push   %esi
  80196d:	53                   	push   %ebx
  80196e:	89 c6                	mov    %eax,%esi
  801970:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801972:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  801979:	75 12                	jne    80198d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80197b:	83 ec 0c             	sub    $0xc,%esp
  80197e:	6a 01                	push   $0x1
  801980:	e8 21 08 00 00       	call   8021a6 <ipc_find_env>
  801985:	a3 00 44 80 00       	mov    %eax,0x804400
  80198a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80198d:	6a 07                	push   $0x7
  80198f:	68 00 50 80 00       	push   $0x805000
  801994:	56                   	push   %esi
  801995:	ff 35 00 44 80 00    	pushl  0x804400
  80199b:	e8 a4 07 00 00       	call   802144 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019a0:	83 c4 0c             	add    $0xc,%esp
  8019a3:	6a 00                	push   $0x0
  8019a5:	53                   	push   %ebx
  8019a6:	6a 00                	push   $0x0
  8019a8:	e8 1c 07 00 00       	call   8020c9 <ipc_recv>
}
  8019ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b0:	5b                   	pop    %ebx
  8019b1:	5e                   	pop    %esi
  8019b2:	5d                   	pop    %ebp
  8019b3:	c3                   	ret    

008019b4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d2:	b8 02 00 00 00       	mov    $0x2,%eax
  8019d7:	e8 8d ff ff ff       	call   801969 <fsipc>
}
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ea:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f4:	b8 06 00 00 00       	mov    $0x6,%eax
  8019f9:	e8 6b ff ff ff       	call   801969 <fsipc>
}
  8019fe:	c9                   	leave  
  8019ff:	c3                   	ret    

00801a00 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	53                   	push   %ebx
  801a04:	83 ec 04             	sub    $0x4,%esp
  801a07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a10:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a15:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1a:	b8 05 00 00 00       	mov    $0x5,%eax
  801a1f:	e8 45 ff ff ff       	call   801969 <fsipc>
  801a24:	85 c0                	test   %eax,%eax
  801a26:	78 2c                	js     801a54 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a28:	83 ec 08             	sub    $0x8,%esp
  801a2b:	68 00 50 80 00       	push   $0x805000
  801a30:	53                   	push   %ebx
  801a31:	e8 0a f0 ff ff       	call   800a40 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a36:	a1 80 50 80 00       	mov    0x805080,%eax
  801a3b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a41:	a1 84 50 80 00       	mov    0x805084,%eax
  801a46:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    

00801a59 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	83 ec 0c             	sub    $0xc,%esp
  801a5f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a62:	8b 55 08             	mov    0x8(%ebp),%edx
  801a65:	8b 52 0c             	mov    0xc(%edx),%edx
  801a68:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a6e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a73:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a78:	0f 47 c2             	cmova  %edx,%eax
  801a7b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a80:	50                   	push   %eax
  801a81:	ff 75 0c             	pushl  0xc(%ebp)
  801a84:	68 08 50 80 00       	push   $0x805008
  801a89:	e8 44 f1 ff ff       	call   800bd2 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a8e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a93:	b8 04 00 00 00       	mov    $0x4,%eax
  801a98:	e8 cc fe ff ff       	call   801969 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a9d:	c9                   	leave  
  801a9e:	c3                   	ret    

00801a9f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	56                   	push   %esi
  801aa3:	53                   	push   %ebx
  801aa4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaa:	8b 40 0c             	mov    0xc(%eax),%eax
  801aad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ab2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  801abd:	b8 03 00 00 00       	mov    $0x3,%eax
  801ac2:	e8 a2 fe ff ff       	call   801969 <fsipc>
  801ac7:	89 c3                	mov    %eax,%ebx
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	78 4b                	js     801b18 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801acd:	39 c6                	cmp    %eax,%esi
  801acf:	73 16                	jae    801ae7 <devfile_read+0x48>
  801ad1:	68 a8 29 80 00       	push   $0x8029a8
  801ad6:	68 af 29 80 00       	push   $0x8029af
  801adb:	6a 7c                	push   $0x7c
  801add:	68 c4 29 80 00       	push   $0x8029c4
  801ae2:	e8 08 e8 ff ff       	call   8002ef <_panic>
	assert(r <= PGSIZE);
  801ae7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aec:	7e 16                	jle    801b04 <devfile_read+0x65>
  801aee:	68 cf 29 80 00       	push   $0x8029cf
  801af3:	68 af 29 80 00       	push   $0x8029af
  801af8:	6a 7d                	push   $0x7d
  801afa:	68 c4 29 80 00       	push   $0x8029c4
  801aff:	e8 eb e7 ff ff       	call   8002ef <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b04:	83 ec 04             	sub    $0x4,%esp
  801b07:	50                   	push   %eax
  801b08:	68 00 50 80 00       	push   $0x805000
  801b0d:	ff 75 0c             	pushl  0xc(%ebp)
  801b10:	e8 bd f0 ff ff       	call   800bd2 <memmove>
	return r;
  801b15:	83 c4 10             	add    $0x10,%esp
}
  801b18:	89 d8                	mov    %ebx,%eax
  801b1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b1d:	5b                   	pop    %ebx
  801b1e:	5e                   	pop    %esi
  801b1f:	5d                   	pop    %ebp
  801b20:	c3                   	ret    

00801b21 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	53                   	push   %ebx
  801b25:	83 ec 20             	sub    $0x20,%esp
  801b28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b2b:	53                   	push   %ebx
  801b2c:	e8 d6 ee ff ff       	call   800a07 <strlen>
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b39:	7f 67                	jg     801ba2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b3b:	83 ec 0c             	sub    $0xc,%esp
  801b3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b41:	50                   	push   %eax
  801b42:	e8 8e f8 ff ff       	call   8013d5 <fd_alloc>
  801b47:	83 c4 10             	add    $0x10,%esp
		return r;
  801b4a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	78 57                	js     801ba7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b50:	83 ec 08             	sub    $0x8,%esp
  801b53:	53                   	push   %ebx
  801b54:	68 00 50 80 00       	push   $0x805000
  801b59:	e8 e2 ee ff ff       	call   800a40 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b61:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b69:	b8 01 00 00 00       	mov    $0x1,%eax
  801b6e:	e8 f6 fd ff ff       	call   801969 <fsipc>
  801b73:	89 c3                	mov    %eax,%ebx
  801b75:	83 c4 10             	add    $0x10,%esp
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	79 14                	jns    801b90 <open+0x6f>
		fd_close(fd, 0);
  801b7c:	83 ec 08             	sub    $0x8,%esp
  801b7f:	6a 00                	push   $0x0
  801b81:	ff 75 f4             	pushl  -0xc(%ebp)
  801b84:	e8 47 f9 ff ff       	call   8014d0 <fd_close>
		return r;
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	89 da                	mov    %ebx,%edx
  801b8e:	eb 17                	jmp    801ba7 <open+0x86>
	}

	return fd2num(fd);
  801b90:	83 ec 0c             	sub    $0xc,%esp
  801b93:	ff 75 f4             	pushl  -0xc(%ebp)
  801b96:	e8 13 f8 ff ff       	call   8013ae <fd2num>
  801b9b:	89 c2                	mov    %eax,%edx
  801b9d:	83 c4 10             	add    $0x10,%esp
  801ba0:	eb 05                	jmp    801ba7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ba2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ba7:	89 d0                	mov    %edx,%eax
  801ba9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bac:	c9                   	leave  
  801bad:	c3                   	ret    

00801bae <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb9:	b8 08 00 00 00       	mov    $0x8,%eax
  801bbe:	e8 a6 fd ff ff       	call   801969 <fsipc>
}
  801bc3:	c9                   	leave  
  801bc4:	c3                   	ret    

00801bc5 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801bc5:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801bc9:	7e 37                	jle    801c02 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	53                   	push   %ebx
  801bcf:	83 ec 08             	sub    $0x8,%esp
  801bd2:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801bd4:	ff 70 04             	pushl  0x4(%eax)
  801bd7:	8d 40 10             	lea    0x10(%eax),%eax
  801bda:	50                   	push   %eax
  801bdb:	ff 33                	pushl  (%ebx)
  801bdd:	e8 88 fb ff ff       	call   80176a <write>
		if (result > 0)
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	85 c0                	test   %eax,%eax
  801be7:	7e 03                	jle    801bec <writebuf+0x27>
			b->result += result;
  801be9:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801bec:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bef:	74 0d                	je     801bfe <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf8:	0f 4f c2             	cmovg  %edx,%eax
  801bfb:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801bfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c01:	c9                   	leave  
  801c02:	f3 c3                	repz ret 

00801c04 <putch>:

static void
putch(int ch, void *thunk)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	53                   	push   %ebx
  801c08:	83 ec 04             	sub    $0x4,%esp
  801c0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801c0e:	8b 53 04             	mov    0x4(%ebx),%edx
  801c11:	8d 42 01             	lea    0x1(%edx),%eax
  801c14:	89 43 04             	mov    %eax,0x4(%ebx)
  801c17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1a:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801c1e:	3d 00 01 00 00       	cmp    $0x100,%eax
  801c23:	75 0e                	jne    801c33 <putch+0x2f>
		writebuf(b);
  801c25:	89 d8                	mov    %ebx,%eax
  801c27:	e8 99 ff ff ff       	call   801bc5 <writebuf>
		b->idx = 0;
  801c2c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801c33:	83 c4 04             	add    $0x4,%esp
  801c36:	5b                   	pop    %ebx
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    

00801c39 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801c4b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801c52:	00 00 00 
	b.result = 0;
  801c55:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801c5c:	00 00 00 
	b.error = 1;
  801c5f:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801c66:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801c69:	ff 75 10             	pushl  0x10(%ebp)
  801c6c:	ff 75 0c             	pushl  0xc(%ebp)
  801c6f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c75:	50                   	push   %eax
  801c76:	68 04 1c 80 00       	push   $0x801c04
  801c7b:	e8 7f e8 ff ff       	call   8004ff <vprintfmt>
	if (b.idx > 0)
  801c80:	83 c4 10             	add    $0x10,%esp
  801c83:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801c8a:	7e 0b                	jle    801c97 <vfprintf+0x5e>
		writebuf(&b);
  801c8c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c92:	e8 2e ff ff ff       	call   801bc5 <writebuf>

	return (b.result ? b.result : b.error);
  801c97:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    

00801ca8 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801cae:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801cb1:	50                   	push   %eax
  801cb2:	ff 75 0c             	pushl  0xc(%ebp)
  801cb5:	ff 75 08             	pushl  0x8(%ebp)
  801cb8:	e8 7c ff ff ff       	call   801c39 <vfprintf>
	va_end(ap);

	return cnt;
}
  801cbd:	c9                   	leave  
  801cbe:	c3                   	ret    

00801cbf <printf>:

int
printf(const char *fmt, ...)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801cc5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801cc8:	50                   	push   %eax
  801cc9:	ff 75 08             	pushl  0x8(%ebp)
  801ccc:	6a 01                	push   $0x1
  801cce:	e8 66 ff ff ff       	call   801c39 <vfprintf>
	va_end(ap);

	return cnt;
}
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    

00801cd5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	56                   	push   %esi
  801cd9:	53                   	push   %ebx
  801cda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cdd:	83 ec 0c             	sub    $0xc,%esp
  801ce0:	ff 75 08             	pushl  0x8(%ebp)
  801ce3:	e8 d6 f6 ff ff       	call   8013be <fd2data>
  801ce8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cea:	83 c4 08             	add    $0x8,%esp
  801ced:	68 db 29 80 00       	push   $0x8029db
  801cf2:	53                   	push   %ebx
  801cf3:	e8 48 ed ff ff       	call   800a40 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cf8:	8b 46 04             	mov    0x4(%esi),%eax
  801cfb:	2b 06                	sub    (%esi),%eax
  801cfd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d03:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d0a:	00 00 00 
	stat->st_dev = &devpipe;
  801d0d:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d14:	30 80 00 
	return 0;
}
  801d17:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d1f:	5b                   	pop    %ebx
  801d20:	5e                   	pop    %esi
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    

00801d23 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	53                   	push   %ebx
  801d27:	83 ec 0c             	sub    $0xc,%esp
  801d2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d2d:	53                   	push   %ebx
  801d2e:	6a 00                	push   $0x0
  801d30:	e8 93 f1 ff ff       	call   800ec8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d35:	89 1c 24             	mov    %ebx,(%esp)
  801d38:	e8 81 f6 ff ff       	call   8013be <fd2data>
  801d3d:	83 c4 08             	add    $0x8,%esp
  801d40:	50                   	push   %eax
  801d41:	6a 00                	push   $0x0
  801d43:	e8 80 f1 ff ff       	call   800ec8 <sys_page_unmap>
}
  801d48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d4b:	c9                   	leave  
  801d4c:	c3                   	ret    

00801d4d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	57                   	push   %edi
  801d51:	56                   	push   %esi
  801d52:	53                   	push   %ebx
  801d53:	83 ec 1c             	sub    $0x1c,%esp
  801d56:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d59:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d5b:	a1 04 44 80 00       	mov    0x804404,%eax
  801d60:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d66:	83 ec 0c             	sub    $0xc,%esp
  801d69:	ff 75 e0             	pushl  -0x20(%ebp)
  801d6c:	e8 7a 04 00 00       	call   8021eb <pageref>
  801d71:	89 c3                	mov    %eax,%ebx
  801d73:	89 3c 24             	mov    %edi,(%esp)
  801d76:	e8 70 04 00 00       	call   8021eb <pageref>
  801d7b:	83 c4 10             	add    $0x10,%esp
  801d7e:	39 c3                	cmp    %eax,%ebx
  801d80:	0f 94 c1             	sete   %cl
  801d83:	0f b6 c9             	movzbl %cl,%ecx
  801d86:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d89:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801d8f:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801d95:	39 ce                	cmp    %ecx,%esi
  801d97:	74 1e                	je     801db7 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801d99:	39 c3                	cmp    %eax,%ebx
  801d9b:	75 be                	jne    801d5b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d9d:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801da3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801da6:	50                   	push   %eax
  801da7:	56                   	push   %esi
  801da8:	68 e2 29 80 00       	push   $0x8029e2
  801dad:	e8 16 e6 ff ff       	call   8003c8 <cprintf>
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	eb a4                	jmp    801d5b <_pipeisclosed+0xe>
	}
}
  801db7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dbd:	5b                   	pop    %ebx
  801dbe:	5e                   	pop    %esi
  801dbf:	5f                   	pop    %edi
  801dc0:	5d                   	pop    %ebp
  801dc1:	c3                   	ret    

00801dc2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dc2:	55                   	push   %ebp
  801dc3:	89 e5                	mov    %esp,%ebp
  801dc5:	57                   	push   %edi
  801dc6:	56                   	push   %esi
  801dc7:	53                   	push   %ebx
  801dc8:	83 ec 28             	sub    $0x28,%esp
  801dcb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801dce:	56                   	push   %esi
  801dcf:	e8 ea f5 ff ff       	call   8013be <fd2data>
  801dd4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	bf 00 00 00 00       	mov    $0x0,%edi
  801dde:	eb 4b                	jmp    801e2b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801de0:	89 da                	mov    %ebx,%edx
  801de2:	89 f0                	mov    %esi,%eax
  801de4:	e8 64 ff ff ff       	call   801d4d <_pipeisclosed>
  801de9:	85 c0                	test   %eax,%eax
  801deb:	75 48                	jne    801e35 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ded:	e8 32 f0 ff ff       	call   800e24 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801df2:	8b 43 04             	mov    0x4(%ebx),%eax
  801df5:	8b 0b                	mov    (%ebx),%ecx
  801df7:	8d 51 20             	lea    0x20(%ecx),%edx
  801dfa:	39 d0                	cmp    %edx,%eax
  801dfc:	73 e2                	jae    801de0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e01:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e05:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e08:	89 c2                	mov    %eax,%edx
  801e0a:	c1 fa 1f             	sar    $0x1f,%edx
  801e0d:	89 d1                	mov    %edx,%ecx
  801e0f:	c1 e9 1b             	shr    $0x1b,%ecx
  801e12:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e15:	83 e2 1f             	and    $0x1f,%edx
  801e18:	29 ca                	sub    %ecx,%edx
  801e1a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e1e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e22:	83 c0 01             	add    $0x1,%eax
  801e25:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e28:	83 c7 01             	add    $0x1,%edi
  801e2b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e2e:	75 c2                	jne    801df2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e30:	8b 45 10             	mov    0x10(%ebp),%eax
  801e33:	eb 05                	jmp    801e3a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e35:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e3d:	5b                   	pop    %ebx
  801e3e:	5e                   	pop    %esi
  801e3f:	5f                   	pop    %edi
  801e40:	5d                   	pop    %ebp
  801e41:	c3                   	ret    

00801e42 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	57                   	push   %edi
  801e46:	56                   	push   %esi
  801e47:	53                   	push   %ebx
  801e48:	83 ec 18             	sub    $0x18,%esp
  801e4b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e4e:	57                   	push   %edi
  801e4f:	e8 6a f5 ff ff       	call   8013be <fd2data>
  801e54:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e56:	83 c4 10             	add    $0x10,%esp
  801e59:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e5e:	eb 3d                	jmp    801e9d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e60:	85 db                	test   %ebx,%ebx
  801e62:	74 04                	je     801e68 <devpipe_read+0x26>
				return i;
  801e64:	89 d8                	mov    %ebx,%eax
  801e66:	eb 44                	jmp    801eac <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e68:	89 f2                	mov    %esi,%edx
  801e6a:	89 f8                	mov    %edi,%eax
  801e6c:	e8 dc fe ff ff       	call   801d4d <_pipeisclosed>
  801e71:	85 c0                	test   %eax,%eax
  801e73:	75 32                	jne    801ea7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e75:	e8 aa ef ff ff       	call   800e24 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e7a:	8b 06                	mov    (%esi),%eax
  801e7c:	3b 46 04             	cmp    0x4(%esi),%eax
  801e7f:	74 df                	je     801e60 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e81:	99                   	cltd   
  801e82:	c1 ea 1b             	shr    $0x1b,%edx
  801e85:	01 d0                	add    %edx,%eax
  801e87:	83 e0 1f             	and    $0x1f,%eax
  801e8a:	29 d0                	sub    %edx,%eax
  801e8c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e94:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e97:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e9a:	83 c3 01             	add    $0x1,%ebx
  801e9d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ea0:	75 d8                	jne    801e7a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ea2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ea5:	eb 05                	jmp    801eac <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ea7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801eac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eaf:	5b                   	pop    %ebx
  801eb0:	5e                   	pop    %esi
  801eb1:	5f                   	pop    %edi
  801eb2:	5d                   	pop    %ebp
  801eb3:	c3                   	ret    

00801eb4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	56                   	push   %esi
  801eb8:	53                   	push   %ebx
  801eb9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ebc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebf:	50                   	push   %eax
  801ec0:	e8 10 f5 ff ff       	call   8013d5 <fd_alloc>
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	89 c2                	mov    %eax,%edx
  801eca:	85 c0                	test   %eax,%eax
  801ecc:	0f 88 2c 01 00 00    	js     801ffe <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ed2:	83 ec 04             	sub    $0x4,%esp
  801ed5:	68 07 04 00 00       	push   $0x407
  801eda:	ff 75 f4             	pushl  -0xc(%ebp)
  801edd:	6a 00                	push   $0x0
  801edf:	e8 5f ef ff ff       	call   800e43 <sys_page_alloc>
  801ee4:	83 c4 10             	add    $0x10,%esp
  801ee7:	89 c2                	mov    %eax,%edx
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	0f 88 0d 01 00 00    	js     801ffe <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ef1:	83 ec 0c             	sub    $0xc,%esp
  801ef4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ef7:	50                   	push   %eax
  801ef8:	e8 d8 f4 ff ff       	call   8013d5 <fd_alloc>
  801efd:	89 c3                	mov    %eax,%ebx
  801eff:	83 c4 10             	add    $0x10,%esp
  801f02:	85 c0                	test   %eax,%eax
  801f04:	0f 88 e2 00 00 00    	js     801fec <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f0a:	83 ec 04             	sub    $0x4,%esp
  801f0d:	68 07 04 00 00       	push   $0x407
  801f12:	ff 75 f0             	pushl  -0x10(%ebp)
  801f15:	6a 00                	push   $0x0
  801f17:	e8 27 ef ff ff       	call   800e43 <sys_page_alloc>
  801f1c:	89 c3                	mov    %eax,%ebx
  801f1e:	83 c4 10             	add    $0x10,%esp
  801f21:	85 c0                	test   %eax,%eax
  801f23:	0f 88 c3 00 00 00    	js     801fec <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f29:	83 ec 0c             	sub    $0xc,%esp
  801f2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f2f:	e8 8a f4 ff ff       	call   8013be <fd2data>
  801f34:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f36:	83 c4 0c             	add    $0xc,%esp
  801f39:	68 07 04 00 00       	push   $0x407
  801f3e:	50                   	push   %eax
  801f3f:	6a 00                	push   $0x0
  801f41:	e8 fd ee ff ff       	call   800e43 <sys_page_alloc>
  801f46:	89 c3                	mov    %eax,%ebx
  801f48:	83 c4 10             	add    $0x10,%esp
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	0f 88 89 00 00 00    	js     801fdc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f53:	83 ec 0c             	sub    $0xc,%esp
  801f56:	ff 75 f0             	pushl  -0x10(%ebp)
  801f59:	e8 60 f4 ff ff       	call   8013be <fd2data>
  801f5e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f65:	50                   	push   %eax
  801f66:	6a 00                	push   $0x0
  801f68:	56                   	push   %esi
  801f69:	6a 00                	push   $0x0
  801f6b:	e8 16 ef ff ff       	call   800e86 <sys_page_map>
  801f70:	89 c3                	mov    %eax,%ebx
  801f72:	83 c4 20             	add    $0x20,%esp
  801f75:	85 c0                	test   %eax,%eax
  801f77:	78 55                	js     801fce <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f79:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f82:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f87:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f8e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f97:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f9c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fa3:	83 ec 0c             	sub    $0xc,%esp
  801fa6:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa9:	e8 00 f4 ff ff       	call   8013ae <fd2num>
  801fae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fb1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fb3:	83 c4 04             	add    $0x4,%esp
  801fb6:	ff 75 f0             	pushl  -0x10(%ebp)
  801fb9:	e8 f0 f3 ff ff       	call   8013ae <fd2num>
  801fbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fc1:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801fc4:	83 c4 10             	add    $0x10,%esp
  801fc7:	ba 00 00 00 00       	mov    $0x0,%edx
  801fcc:	eb 30                	jmp    801ffe <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801fce:	83 ec 08             	sub    $0x8,%esp
  801fd1:	56                   	push   %esi
  801fd2:	6a 00                	push   $0x0
  801fd4:	e8 ef ee ff ff       	call   800ec8 <sys_page_unmap>
  801fd9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801fdc:	83 ec 08             	sub    $0x8,%esp
  801fdf:	ff 75 f0             	pushl  -0x10(%ebp)
  801fe2:	6a 00                	push   $0x0
  801fe4:	e8 df ee ff ff       	call   800ec8 <sys_page_unmap>
  801fe9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801fec:	83 ec 08             	sub    $0x8,%esp
  801fef:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff2:	6a 00                	push   $0x0
  801ff4:	e8 cf ee ff ff       	call   800ec8 <sys_page_unmap>
  801ff9:	83 c4 10             	add    $0x10,%esp
  801ffc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ffe:	89 d0                	mov    %edx,%eax
  802000:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5d                   	pop    %ebp
  802006:	c3                   	ret    

00802007 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802007:	55                   	push   %ebp
  802008:	89 e5                	mov    %esp,%ebp
  80200a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80200d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802010:	50                   	push   %eax
  802011:	ff 75 08             	pushl  0x8(%ebp)
  802014:	e8 0b f4 ff ff       	call   801424 <fd_lookup>
  802019:	83 c4 10             	add    $0x10,%esp
  80201c:	85 c0                	test   %eax,%eax
  80201e:	78 18                	js     802038 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802020:	83 ec 0c             	sub    $0xc,%esp
  802023:	ff 75 f4             	pushl  -0xc(%ebp)
  802026:	e8 93 f3 ff ff       	call   8013be <fd2data>
	return _pipeisclosed(fd, p);
  80202b:	89 c2                	mov    %eax,%edx
  80202d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802030:	e8 18 fd ff ff       	call   801d4d <_pipeisclosed>
  802035:	83 c4 10             	add    $0x10,%esp
}
  802038:	c9                   	leave  
  802039:	c3                   	ret    

0080203a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80203a:	55                   	push   %ebp
  80203b:	89 e5                	mov    %esp,%ebp
  80203d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802040:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802047:	75 2a                	jne    802073 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802049:	83 ec 04             	sub    $0x4,%esp
  80204c:	6a 07                	push   $0x7
  80204e:	68 00 f0 bf ee       	push   $0xeebff000
  802053:	6a 00                	push   $0x0
  802055:	e8 e9 ed ff ff       	call   800e43 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80205a:	83 c4 10             	add    $0x10,%esp
  80205d:	85 c0                	test   %eax,%eax
  80205f:	79 12                	jns    802073 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802061:	50                   	push   %eax
  802062:	68 6b 28 80 00       	push   $0x80286b
  802067:	6a 23                	push   $0x23
  802069:	68 fa 29 80 00       	push   $0x8029fa
  80206e:	e8 7c e2 ff ff       	call   8002ef <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802073:	8b 45 08             	mov    0x8(%ebp),%eax
  802076:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80207b:	83 ec 08             	sub    $0x8,%esp
  80207e:	68 a5 20 80 00       	push   $0x8020a5
  802083:	6a 00                	push   $0x0
  802085:	e8 04 ef ff ff       	call   800f8e <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80208a:	83 c4 10             	add    $0x10,%esp
  80208d:	85 c0                	test   %eax,%eax
  80208f:	79 12                	jns    8020a3 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802091:	50                   	push   %eax
  802092:	68 6b 28 80 00       	push   $0x80286b
  802097:	6a 2c                	push   $0x2c
  802099:	68 fa 29 80 00       	push   $0x8029fa
  80209e:	e8 4c e2 ff ff       	call   8002ef <_panic>
	}
}
  8020a3:	c9                   	leave  
  8020a4:	c3                   	ret    

008020a5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020a5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020a6:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020ab:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020ad:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8020b0:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8020b4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8020b9:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8020bd:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8020bf:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8020c2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8020c3:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8020c6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8020c7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020c8:	c3                   	ret    

008020c9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020c9:	55                   	push   %ebp
  8020ca:	89 e5                	mov    %esp,%ebp
  8020cc:	56                   	push   %esi
  8020cd:	53                   	push   %ebx
  8020ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8020d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	75 12                	jne    8020ed <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8020db:	83 ec 0c             	sub    $0xc,%esp
  8020de:	68 00 00 c0 ee       	push   $0xeec00000
  8020e3:	e8 0b ef ff ff       	call   800ff3 <sys_ipc_recv>
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	eb 0c                	jmp    8020f9 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020ed:	83 ec 0c             	sub    $0xc,%esp
  8020f0:	50                   	push   %eax
  8020f1:	e8 fd ee ff ff       	call   800ff3 <sys_ipc_recv>
  8020f6:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020f9:	85 f6                	test   %esi,%esi
  8020fb:	0f 95 c1             	setne  %cl
  8020fe:	85 db                	test   %ebx,%ebx
  802100:	0f 95 c2             	setne  %dl
  802103:	84 d1                	test   %dl,%cl
  802105:	74 09                	je     802110 <ipc_recv+0x47>
  802107:	89 c2                	mov    %eax,%edx
  802109:	c1 ea 1f             	shr    $0x1f,%edx
  80210c:	84 d2                	test   %dl,%dl
  80210e:	75 2d                	jne    80213d <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802110:	85 f6                	test   %esi,%esi
  802112:	74 0d                	je     802121 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802114:	a1 04 44 80 00       	mov    0x804404,%eax
  802119:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80211f:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802121:	85 db                	test   %ebx,%ebx
  802123:	74 0d                	je     802132 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802125:	a1 04 44 80 00       	mov    0x804404,%eax
  80212a:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  802130:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802132:	a1 04 44 80 00       	mov    0x804404,%eax
  802137:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  80213d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802140:	5b                   	pop    %ebx
  802141:	5e                   	pop    %esi
  802142:	5d                   	pop    %ebp
  802143:	c3                   	ret    

00802144 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802144:	55                   	push   %ebp
  802145:	89 e5                	mov    %esp,%ebp
  802147:	57                   	push   %edi
  802148:	56                   	push   %esi
  802149:	53                   	push   %ebx
  80214a:	83 ec 0c             	sub    $0xc,%esp
  80214d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802150:	8b 75 0c             	mov    0xc(%ebp),%esi
  802153:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802156:	85 db                	test   %ebx,%ebx
  802158:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80215d:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802160:	ff 75 14             	pushl  0x14(%ebp)
  802163:	53                   	push   %ebx
  802164:	56                   	push   %esi
  802165:	57                   	push   %edi
  802166:	e8 65 ee ff ff       	call   800fd0 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80216b:	89 c2                	mov    %eax,%edx
  80216d:	c1 ea 1f             	shr    $0x1f,%edx
  802170:	83 c4 10             	add    $0x10,%esp
  802173:	84 d2                	test   %dl,%dl
  802175:	74 17                	je     80218e <ipc_send+0x4a>
  802177:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80217a:	74 12                	je     80218e <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80217c:	50                   	push   %eax
  80217d:	68 08 2a 80 00       	push   $0x802a08
  802182:	6a 47                	push   $0x47
  802184:	68 16 2a 80 00       	push   $0x802a16
  802189:	e8 61 e1 ff ff       	call   8002ef <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80218e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802191:	75 07                	jne    80219a <ipc_send+0x56>
			sys_yield();
  802193:	e8 8c ec ff ff       	call   800e24 <sys_yield>
  802198:	eb c6                	jmp    802160 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80219a:	85 c0                	test   %eax,%eax
  80219c:	75 c2                	jne    802160 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80219e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021a1:	5b                   	pop    %ebx
  8021a2:	5e                   	pop    %esi
  8021a3:	5f                   	pop    %edi
  8021a4:	5d                   	pop    %ebp
  8021a5:	c3                   	ret    

008021a6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021a6:	55                   	push   %ebp
  8021a7:	89 e5                	mov    %esp,%ebp
  8021a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021ac:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021b1:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8021b7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021bd:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  8021c3:	39 ca                	cmp    %ecx,%edx
  8021c5:	75 13                	jne    8021da <ipc_find_env+0x34>
			return envs[i].env_id;
  8021c7:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8021cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021d2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8021d8:	eb 0f                	jmp    8021e9 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021da:	83 c0 01             	add    $0x1,%eax
  8021dd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021e2:	75 cd                	jne    8021b1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021e9:	5d                   	pop    %ebp
  8021ea:	c3                   	ret    

008021eb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021eb:	55                   	push   %ebp
  8021ec:	89 e5                	mov    %esp,%ebp
  8021ee:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021f1:	89 d0                	mov    %edx,%eax
  8021f3:	c1 e8 16             	shr    $0x16,%eax
  8021f6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021fd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802202:	f6 c1 01             	test   $0x1,%cl
  802205:	74 1d                	je     802224 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802207:	c1 ea 0c             	shr    $0xc,%edx
  80220a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802211:	f6 c2 01             	test   $0x1,%dl
  802214:	74 0e                	je     802224 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802216:	c1 ea 0c             	shr    $0xc,%edx
  802219:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802220:	ef 
  802221:	0f b7 c0             	movzwl %ax,%eax
}
  802224:	5d                   	pop    %ebp
  802225:	c3                   	ret    
  802226:	66 90                	xchg   %ax,%ax
  802228:	66 90                	xchg   %ax,%ax
  80222a:	66 90                	xchg   %ax,%ax
  80222c:	66 90                	xchg   %ax,%ax
  80222e:	66 90                	xchg   %ax,%ax

00802230 <__udivdi3>:
  802230:	55                   	push   %ebp
  802231:	57                   	push   %edi
  802232:	56                   	push   %esi
  802233:	53                   	push   %ebx
  802234:	83 ec 1c             	sub    $0x1c,%esp
  802237:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80223b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80223f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802243:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802247:	85 f6                	test   %esi,%esi
  802249:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80224d:	89 ca                	mov    %ecx,%edx
  80224f:	89 f8                	mov    %edi,%eax
  802251:	75 3d                	jne    802290 <__udivdi3+0x60>
  802253:	39 cf                	cmp    %ecx,%edi
  802255:	0f 87 c5 00 00 00    	ja     802320 <__udivdi3+0xf0>
  80225b:	85 ff                	test   %edi,%edi
  80225d:	89 fd                	mov    %edi,%ebp
  80225f:	75 0b                	jne    80226c <__udivdi3+0x3c>
  802261:	b8 01 00 00 00       	mov    $0x1,%eax
  802266:	31 d2                	xor    %edx,%edx
  802268:	f7 f7                	div    %edi
  80226a:	89 c5                	mov    %eax,%ebp
  80226c:	89 c8                	mov    %ecx,%eax
  80226e:	31 d2                	xor    %edx,%edx
  802270:	f7 f5                	div    %ebp
  802272:	89 c1                	mov    %eax,%ecx
  802274:	89 d8                	mov    %ebx,%eax
  802276:	89 cf                	mov    %ecx,%edi
  802278:	f7 f5                	div    %ebp
  80227a:	89 c3                	mov    %eax,%ebx
  80227c:	89 d8                	mov    %ebx,%eax
  80227e:	89 fa                	mov    %edi,%edx
  802280:	83 c4 1c             	add    $0x1c,%esp
  802283:	5b                   	pop    %ebx
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    
  802288:	90                   	nop
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	39 ce                	cmp    %ecx,%esi
  802292:	77 74                	ja     802308 <__udivdi3+0xd8>
  802294:	0f bd fe             	bsr    %esi,%edi
  802297:	83 f7 1f             	xor    $0x1f,%edi
  80229a:	0f 84 98 00 00 00    	je     802338 <__udivdi3+0x108>
  8022a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022a5:	89 f9                	mov    %edi,%ecx
  8022a7:	89 c5                	mov    %eax,%ebp
  8022a9:	29 fb                	sub    %edi,%ebx
  8022ab:	d3 e6                	shl    %cl,%esi
  8022ad:	89 d9                	mov    %ebx,%ecx
  8022af:	d3 ed                	shr    %cl,%ebp
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	d3 e0                	shl    %cl,%eax
  8022b5:	09 ee                	or     %ebp,%esi
  8022b7:	89 d9                	mov    %ebx,%ecx
  8022b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022bd:	89 d5                	mov    %edx,%ebp
  8022bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022c3:	d3 ed                	shr    %cl,%ebp
  8022c5:	89 f9                	mov    %edi,%ecx
  8022c7:	d3 e2                	shl    %cl,%edx
  8022c9:	89 d9                	mov    %ebx,%ecx
  8022cb:	d3 e8                	shr    %cl,%eax
  8022cd:	09 c2                	or     %eax,%edx
  8022cf:	89 d0                	mov    %edx,%eax
  8022d1:	89 ea                	mov    %ebp,%edx
  8022d3:	f7 f6                	div    %esi
  8022d5:	89 d5                	mov    %edx,%ebp
  8022d7:	89 c3                	mov    %eax,%ebx
  8022d9:	f7 64 24 0c          	mull   0xc(%esp)
  8022dd:	39 d5                	cmp    %edx,%ebp
  8022df:	72 10                	jb     8022f1 <__udivdi3+0xc1>
  8022e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022e5:	89 f9                	mov    %edi,%ecx
  8022e7:	d3 e6                	shl    %cl,%esi
  8022e9:	39 c6                	cmp    %eax,%esi
  8022eb:	73 07                	jae    8022f4 <__udivdi3+0xc4>
  8022ed:	39 d5                	cmp    %edx,%ebp
  8022ef:	75 03                	jne    8022f4 <__udivdi3+0xc4>
  8022f1:	83 eb 01             	sub    $0x1,%ebx
  8022f4:	31 ff                	xor    %edi,%edi
  8022f6:	89 d8                	mov    %ebx,%eax
  8022f8:	89 fa                	mov    %edi,%edx
  8022fa:	83 c4 1c             	add    $0x1c,%esp
  8022fd:	5b                   	pop    %ebx
  8022fe:	5e                   	pop    %esi
  8022ff:	5f                   	pop    %edi
  802300:	5d                   	pop    %ebp
  802301:	c3                   	ret    
  802302:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802308:	31 ff                	xor    %edi,%edi
  80230a:	31 db                	xor    %ebx,%ebx
  80230c:	89 d8                	mov    %ebx,%eax
  80230e:	89 fa                	mov    %edi,%edx
  802310:	83 c4 1c             	add    $0x1c,%esp
  802313:	5b                   	pop    %ebx
  802314:	5e                   	pop    %esi
  802315:	5f                   	pop    %edi
  802316:	5d                   	pop    %ebp
  802317:	c3                   	ret    
  802318:	90                   	nop
  802319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802320:	89 d8                	mov    %ebx,%eax
  802322:	f7 f7                	div    %edi
  802324:	31 ff                	xor    %edi,%edi
  802326:	89 c3                	mov    %eax,%ebx
  802328:	89 d8                	mov    %ebx,%eax
  80232a:	89 fa                	mov    %edi,%edx
  80232c:	83 c4 1c             	add    $0x1c,%esp
  80232f:	5b                   	pop    %ebx
  802330:	5e                   	pop    %esi
  802331:	5f                   	pop    %edi
  802332:	5d                   	pop    %ebp
  802333:	c3                   	ret    
  802334:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802338:	39 ce                	cmp    %ecx,%esi
  80233a:	72 0c                	jb     802348 <__udivdi3+0x118>
  80233c:	31 db                	xor    %ebx,%ebx
  80233e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802342:	0f 87 34 ff ff ff    	ja     80227c <__udivdi3+0x4c>
  802348:	bb 01 00 00 00       	mov    $0x1,%ebx
  80234d:	e9 2a ff ff ff       	jmp    80227c <__udivdi3+0x4c>
  802352:	66 90                	xchg   %ax,%ax
  802354:	66 90                	xchg   %ax,%ax
  802356:	66 90                	xchg   %ax,%ax
  802358:	66 90                	xchg   %ax,%ax
  80235a:	66 90                	xchg   %ax,%ax
  80235c:	66 90                	xchg   %ax,%ax
  80235e:	66 90                	xchg   %ax,%ax

00802360 <__umoddi3>:
  802360:	55                   	push   %ebp
  802361:	57                   	push   %edi
  802362:	56                   	push   %esi
  802363:	53                   	push   %ebx
  802364:	83 ec 1c             	sub    $0x1c,%esp
  802367:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80236b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80236f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802373:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802377:	85 d2                	test   %edx,%edx
  802379:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80237d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802381:	89 f3                	mov    %esi,%ebx
  802383:	89 3c 24             	mov    %edi,(%esp)
  802386:	89 74 24 04          	mov    %esi,0x4(%esp)
  80238a:	75 1c                	jne    8023a8 <__umoddi3+0x48>
  80238c:	39 f7                	cmp    %esi,%edi
  80238e:	76 50                	jbe    8023e0 <__umoddi3+0x80>
  802390:	89 c8                	mov    %ecx,%eax
  802392:	89 f2                	mov    %esi,%edx
  802394:	f7 f7                	div    %edi
  802396:	89 d0                	mov    %edx,%eax
  802398:	31 d2                	xor    %edx,%edx
  80239a:	83 c4 1c             	add    $0x1c,%esp
  80239d:	5b                   	pop    %ebx
  80239e:	5e                   	pop    %esi
  80239f:	5f                   	pop    %edi
  8023a0:	5d                   	pop    %ebp
  8023a1:	c3                   	ret    
  8023a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023a8:	39 f2                	cmp    %esi,%edx
  8023aa:	89 d0                	mov    %edx,%eax
  8023ac:	77 52                	ja     802400 <__umoddi3+0xa0>
  8023ae:	0f bd ea             	bsr    %edx,%ebp
  8023b1:	83 f5 1f             	xor    $0x1f,%ebp
  8023b4:	75 5a                	jne    802410 <__umoddi3+0xb0>
  8023b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023ba:	0f 82 e0 00 00 00    	jb     8024a0 <__umoddi3+0x140>
  8023c0:	39 0c 24             	cmp    %ecx,(%esp)
  8023c3:	0f 86 d7 00 00 00    	jbe    8024a0 <__umoddi3+0x140>
  8023c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023d1:	83 c4 1c             	add    $0x1c,%esp
  8023d4:	5b                   	pop    %ebx
  8023d5:	5e                   	pop    %esi
  8023d6:	5f                   	pop    %edi
  8023d7:	5d                   	pop    %ebp
  8023d8:	c3                   	ret    
  8023d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	85 ff                	test   %edi,%edi
  8023e2:	89 fd                	mov    %edi,%ebp
  8023e4:	75 0b                	jne    8023f1 <__umoddi3+0x91>
  8023e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023eb:	31 d2                	xor    %edx,%edx
  8023ed:	f7 f7                	div    %edi
  8023ef:	89 c5                	mov    %eax,%ebp
  8023f1:	89 f0                	mov    %esi,%eax
  8023f3:	31 d2                	xor    %edx,%edx
  8023f5:	f7 f5                	div    %ebp
  8023f7:	89 c8                	mov    %ecx,%eax
  8023f9:	f7 f5                	div    %ebp
  8023fb:	89 d0                	mov    %edx,%eax
  8023fd:	eb 99                	jmp    802398 <__umoddi3+0x38>
  8023ff:	90                   	nop
  802400:	89 c8                	mov    %ecx,%eax
  802402:	89 f2                	mov    %esi,%edx
  802404:	83 c4 1c             	add    $0x1c,%esp
  802407:	5b                   	pop    %ebx
  802408:	5e                   	pop    %esi
  802409:	5f                   	pop    %edi
  80240a:	5d                   	pop    %ebp
  80240b:	c3                   	ret    
  80240c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802410:	8b 34 24             	mov    (%esp),%esi
  802413:	bf 20 00 00 00       	mov    $0x20,%edi
  802418:	89 e9                	mov    %ebp,%ecx
  80241a:	29 ef                	sub    %ebp,%edi
  80241c:	d3 e0                	shl    %cl,%eax
  80241e:	89 f9                	mov    %edi,%ecx
  802420:	89 f2                	mov    %esi,%edx
  802422:	d3 ea                	shr    %cl,%edx
  802424:	89 e9                	mov    %ebp,%ecx
  802426:	09 c2                	or     %eax,%edx
  802428:	89 d8                	mov    %ebx,%eax
  80242a:	89 14 24             	mov    %edx,(%esp)
  80242d:	89 f2                	mov    %esi,%edx
  80242f:	d3 e2                	shl    %cl,%edx
  802431:	89 f9                	mov    %edi,%ecx
  802433:	89 54 24 04          	mov    %edx,0x4(%esp)
  802437:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80243b:	d3 e8                	shr    %cl,%eax
  80243d:	89 e9                	mov    %ebp,%ecx
  80243f:	89 c6                	mov    %eax,%esi
  802441:	d3 e3                	shl    %cl,%ebx
  802443:	89 f9                	mov    %edi,%ecx
  802445:	89 d0                	mov    %edx,%eax
  802447:	d3 e8                	shr    %cl,%eax
  802449:	89 e9                	mov    %ebp,%ecx
  80244b:	09 d8                	or     %ebx,%eax
  80244d:	89 d3                	mov    %edx,%ebx
  80244f:	89 f2                	mov    %esi,%edx
  802451:	f7 34 24             	divl   (%esp)
  802454:	89 d6                	mov    %edx,%esi
  802456:	d3 e3                	shl    %cl,%ebx
  802458:	f7 64 24 04          	mull   0x4(%esp)
  80245c:	39 d6                	cmp    %edx,%esi
  80245e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802462:	89 d1                	mov    %edx,%ecx
  802464:	89 c3                	mov    %eax,%ebx
  802466:	72 08                	jb     802470 <__umoddi3+0x110>
  802468:	75 11                	jne    80247b <__umoddi3+0x11b>
  80246a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80246e:	73 0b                	jae    80247b <__umoddi3+0x11b>
  802470:	2b 44 24 04          	sub    0x4(%esp),%eax
  802474:	1b 14 24             	sbb    (%esp),%edx
  802477:	89 d1                	mov    %edx,%ecx
  802479:	89 c3                	mov    %eax,%ebx
  80247b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80247f:	29 da                	sub    %ebx,%edx
  802481:	19 ce                	sbb    %ecx,%esi
  802483:	89 f9                	mov    %edi,%ecx
  802485:	89 f0                	mov    %esi,%eax
  802487:	d3 e0                	shl    %cl,%eax
  802489:	89 e9                	mov    %ebp,%ecx
  80248b:	d3 ea                	shr    %cl,%edx
  80248d:	89 e9                	mov    %ebp,%ecx
  80248f:	d3 ee                	shr    %cl,%esi
  802491:	09 d0                	or     %edx,%eax
  802493:	89 f2                	mov    %esi,%edx
  802495:	83 c4 1c             	add    $0x1c,%esp
  802498:	5b                   	pop    %ebx
  802499:	5e                   	pop    %esi
  80249a:	5f                   	pop    %edi
  80249b:	5d                   	pop    %ebp
  80249c:	c3                   	ret    
  80249d:	8d 76 00             	lea    0x0(%esi),%esi
  8024a0:	29 f9                	sub    %edi,%ecx
  8024a2:	19 d6                	sbb    %edx,%esi
  8024a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024ac:	e9 18 ff ff ff       	jmp    8023c9 <__umoddi3+0x69>
