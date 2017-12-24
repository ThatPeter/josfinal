
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
  80003f:	e8 05 0e 00 00       	call   800e49 <sys_yield>
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
  80004e:	e8 a6 11 00 00       	call   8011f9 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 c0 20 80 00       	push   $0x8020c0
  800065:	6a 0f                	push   $0xf
  800067:	68 cd 20 80 00       	push   $0x8020cd
  80006c:	e8 a3 02 00 00       	call   800314 <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 dc 20 80 00       	push   $0x8020dc
  80007b:	6a 11                	push   $0x11
  80007d:	68 cd 20 80 00       	push   $0x8020cd
  800082:	e8 8d 02 00 00       	call   800314 <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 b6 11 00 00       	call   801249 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 f6 20 80 00       	push   $0x8020f6
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 cd 20 80 00       	push   $0x8020cd
  8000a7:	e8 68 02 00 00       	call   800314 <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 fe 20 80 00       	push   $0x8020fe
  8000b4:	e8 80 08 00 00       	call   800939 <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 0c 21 80 00       	push   $0x80210c
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 77 18 00 00       	call   801947 <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 10 21 80 00       	push   $0x802110
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 63 18 00 00       	call   801947 <fprintf>
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
  8000f9:	68 28 21 80 00       	push   $0x802128
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	e8 5f 09 00 00       	call   800a65 <strcpy>
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
  80013f:	e8 b3 0a 00 00       	call   800bf7 <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 5e 0c 00 00       	call   800dac <sys_cputs>
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
  800175:	e8 cf 0c 00 00       	call   800e49 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80017a:	e8 4b 0c 00 00       	call   800dca <sys_cgetc>
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
  8001b1:	e8 f6 0b 00 00       	call   800dac <sys_cputs>
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
  8001c9:	e8 67 11 00 00       	call   801335 <read>
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
  8001f3:	e8 d7 0e 00 00       	call   8010cf <fd_lookup>
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
  80021c:	e8 5f 0e 00 00       	call   801080 <fd_alloc>
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
  800237:	e8 2c 0c 00 00       	call   800e68 <sys_page_alloc>
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
  80025e:	e8 f6 0d 00 00       	call   801059 <fd2num>
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
  80027f:	e8 a6 0b 00 00       	call   800e2a <sys_getenvid>
  800284:	8b 3d 04 44 80 00    	mov    0x804404,%edi
  80028a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80028f:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800294:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800299:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80029c:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8002a2:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8002a5:	39 c8                	cmp    %ecx,%eax
  8002a7:	0f 44 fb             	cmove  %ebx,%edi
  8002aa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8002af:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8002b2:	83 c2 01             	add    $0x1,%edx
  8002b5:	83 c3 7c             	add    $0x7c,%ebx
  8002b8:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8002be:	75 d9                	jne    800299 <libmain+0x2d>
  8002c0:	89 f0                	mov    %esi,%eax
  8002c2:	84 c0                	test   %al,%al
  8002c4:	74 06                	je     8002cc <libmain+0x60>
  8002c6:	89 3d 04 44 80 00    	mov    %edi,0x804404
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002cc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8002d0:	7e 0a                	jle    8002dc <libmain+0x70>
		binaryname = argv[0];
  8002d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d5:	8b 00                	mov    (%eax),%eax
  8002d7:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  8002dc:	83 ec 08             	sub    $0x8,%esp
  8002df:	ff 75 0c             	pushl  0xc(%ebp)
  8002e2:	ff 75 08             	pushl  0x8(%ebp)
  8002e5:	e8 49 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002ea:	e8 0b 00 00 00       	call   8002fa <exit>
}
  8002ef:	83 c4 10             	add    $0x10,%esp
  8002f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f5:	5b                   	pop    %ebx
  8002f6:	5e                   	pop    %esi
  8002f7:	5f                   	pop    %edi
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    

008002fa <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800300:	e8 1f 0f 00 00       	call   801224 <close_all>
	sys_env_destroy(0);
  800305:	83 ec 0c             	sub    $0xc,%esp
  800308:	6a 00                	push   $0x0
  80030a:	e8 da 0a 00 00       	call   800de9 <sys_env_destroy>
}
  80030f:	83 c4 10             	add    $0x10,%esp
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800319:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031c:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  800322:	e8 03 0b 00 00       	call   800e2a <sys_getenvid>
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	ff 75 08             	pushl  0x8(%ebp)
  800330:	56                   	push   %esi
  800331:	50                   	push   %eax
  800332:	68 40 21 80 00       	push   $0x802140
  800337:	e8 b1 00 00 00       	call   8003ed <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033c:	83 c4 18             	add    $0x18,%esp
  80033f:	53                   	push   %ebx
  800340:	ff 75 10             	pushl  0x10(%ebp)
  800343:	e8 54 00 00 00       	call   80039c <vcprintf>
	cprintf("\n");
  800348:	c7 04 24 26 21 80 00 	movl   $0x802126,(%esp)
  80034f:	e8 99 00 00 00       	call   8003ed <cprintf>
  800354:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800357:	cc                   	int3   
  800358:	eb fd                	jmp    800357 <_panic+0x43>

0080035a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	53                   	push   %ebx
  80035e:	83 ec 04             	sub    $0x4,%esp
  800361:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800364:	8b 13                	mov    (%ebx),%edx
  800366:	8d 42 01             	lea    0x1(%edx),%eax
  800369:	89 03                	mov    %eax,(%ebx)
  80036b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800372:	3d ff 00 00 00       	cmp    $0xff,%eax
  800377:	75 1a                	jne    800393 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	68 ff 00 00 00       	push   $0xff
  800381:	8d 43 08             	lea    0x8(%ebx),%eax
  800384:	50                   	push   %eax
  800385:	e8 22 0a 00 00       	call   800dac <sys_cputs>
		b->idx = 0;
  80038a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800390:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800393:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800397:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80039a:	c9                   	leave  
  80039b:	c3                   	ret    

0080039c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ac:	00 00 00 
	b.cnt = 0;
  8003af:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b9:	ff 75 0c             	pushl  0xc(%ebp)
  8003bc:	ff 75 08             	pushl  0x8(%ebp)
  8003bf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c5:	50                   	push   %eax
  8003c6:	68 5a 03 80 00       	push   $0x80035a
  8003cb:	e8 54 01 00 00       	call   800524 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d0:	83 c4 08             	add    $0x8,%esp
  8003d3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003df:	50                   	push   %eax
  8003e0:	e8 c7 09 00 00       	call   800dac <sys_cputs>

	return b.cnt;
}
  8003e5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003eb:	c9                   	leave  
  8003ec:	c3                   	ret    

008003ed <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ed:	55                   	push   %ebp
  8003ee:	89 e5                	mov    %esp,%ebp
  8003f0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f6:	50                   	push   %eax
  8003f7:	ff 75 08             	pushl  0x8(%ebp)
  8003fa:	e8 9d ff ff ff       	call   80039c <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ff:	c9                   	leave  
  800400:	c3                   	ret    

00800401 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800401:	55                   	push   %ebp
  800402:	89 e5                	mov    %esp,%ebp
  800404:	57                   	push   %edi
  800405:	56                   	push   %esi
  800406:	53                   	push   %ebx
  800407:	83 ec 1c             	sub    $0x1c,%esp
  80040a:	89 c7                	mov    %eax,%edi
  80040c:	89 d6                	mov    %edx,%esi
  80040e:	8b 45 08             	mov    0x8(%ebp),%eax
  800411:	8b 55 0c             	mov    0xc(%ebp),%edx
  800414:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800417:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80041a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800422:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800425:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800428:	39 d3                	cmp    %edx,%ebx
  80042a:	72 05                	jb     800431 <printnum+0x30>
  80042c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042f:	77 45                	ja     800476 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800431:	83 ec 0c             	sub    $0xc,%esp
  800434:	ff 75 18             	pushl  0x18(%ebp)
  800437:	8b 45 14             	mov    0x14(%ebp),%eax
  80043a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043d:	53                   	push   %ebx
  80043e:	ff 75 10             	pushl  0x10(%ebp)
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	ff 75 e4             	pushl  -0x1c(%ebp)
  800447:	ff 75 e0             	pushl  -0x20(%ebp)
  80044a:	ff 75 dc             	pushl  -0x24(%ebp)
  80044d:	ff 75 d8             	pushl  -0x28(%ebp)
  800450:	e8 cb 19 00 00       	call   801e20 <__udivdi3>
  800455:	83 c4 18             	add    $0x18,%esp
  800458:	52                   	push   %edx
  800459:	50                   	push   %eax
  80045a:	89 f2                	mov    %esi,%edx
  80045c:	89 f8                	mov    %edi,%eax
  80045e:	e8 9e ff ff ff       	call   800401 <printnum>
  800463:	83 c4 20             	add    $0x20,%esp
  800466:	eb 18                	jmp    800480 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	56                   	push   %esi
  80046c:	ff 75 18             	pushl  0x18(%ebp)
  80046f:	ff d7                	call   *%edi
  800471:	83 c4 10             	add    $0x10,%esp
  800474:	eb 03                	jmp    800479 <printnum+0x78>
  800476:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800479:	83 eb 01             	sub    $0x1,%ebx
  80047c:	85 db                	test   %ebx,%ebx
  80047e:	7f e8                	jg     800468 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	56                   	push   %esi
  800484:	83 ec 04             	sub    $0x4,%esp
  800487:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048a:	ff 75 e0             	pushl  -0x20(%ebp)
  80048d:	ff 75 dc             	pushl  -0x24(%ebp)
  800490:	ff 75 d8             	pushl  -0x28(%ebp)
  800493:	e8 b8 1a 00 00       	call   801f50 <__umoddi3>
  800498:	83 c4 14             	add    $0x14,%esp
  80049b:	0f be 80 63 21 80 00 	movsbl 0x802163(%eax),%eax
  8004a2:	50                   	push   %eax
  8004a3:	ff d7                	call   *%edi
}
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ab:	5b                   	pop    %ebx
  8004ac:	5e                   	pop    %esi
  8004ad:	5f                   	pop    %edi
  8004ae:	5d                   	pop    %ebp
  8004af:	c3                   	ret    

008004b0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b3:	83 fa 01             	cmp    $0x1,%edx
  8004b6:	7e 0e                	jle    8004c6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b8:	8b 10                	mov    (%eax),%edx
  8004ba:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004bd:	89 08                	mov    %ecx,(%eax)
  8004bf:	8b 02                	mov    (%edx),%eax
  8004c1:	8b 52 04             	mov    0x4(%edx),%edx
  8004c4:	eb 22                	jmp    8004e8 <getuint+0x38>
	else if (lflag)
  8004c6:	85 d2                	test   %edx,%edx
  8004c8:	74 10                	je     8004da <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004ca:	8b 10                	mov    (%eax),%edx
  8004cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cf:	89 08                	mov    %ecx,(%eax)
  8004d1:	8b 02                	mov    (%edx),%eax
  8004d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d8:	eb 0e                	jmp    8004e8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f4:	8b 10                	mov    (%eax),%edx
  8004f6:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f9:	73 0a                	jae    800505 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004fb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fe:	89 08                	mov    %ecx,(%eax)
  800500:	8b 45 08             	mov    0x8(%ebp),%eax
  800503:	88 02                	mov    %al,(%edx)
}
  800505:	5d                   	pop    %ebp
  800506:	c3                   	ret    

00800507 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800507:	55                   	push   %ebp
  800508:	89 e5                	mov    %esp,%ebp
  80050a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800510:	50                   	push   %eax
  800511:	ff 75 10             	pushl  0x10(%ebp)
  800514:	ff 75 0c             	pushl  0xc(%ebp)
  800517:	ff 75 08             	pushl  0x8(%ebp)
  80051a:	e8 05 00 00 00       	call   800524 <vprintfmt>
	va_end(ap);
}
  80051f:	83 c4 10             	add    $0x10,%esp
  800522:	c9                   	leave  
  800523:	c3                   	ret    

00800524 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800524:	55                   	push   %ebp
  800525:	89 e5                	mov    %esp,%ebp
  800527:	57                   	push   %edi
  800528:	56                   	push   %esi
  800529:	53                   	push   %ebx
  80052a:	83 ec 2c             	sub    $0x2c,%esp
  80052d:	8b 75 08             	mov    0x8(%ebp),%esi
  800530:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800533:	8b 7d 10             	mov    0x10(%ebp),%edi
  800536:	eb 12                	jmp    80054a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800538:	85 c0                	test   %eax,%eax
  80053a:	0f 84 89 03 00 00    	je     8008c9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	53                   	push   %ebx
  800544:	50                   	push   %eax
  800545:	ff d6                	call   *%esi
  800547:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80054a:	83 c7 01             	add    $0x1,%edi
  80054d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800551:	83 f8 25             	cmp    $0x25,%eax
  800554:	75 e2                	jne    800538 <vprintfmt+0x14>
  800556:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80055a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800561:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800568:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056f:	ba 00 00 00 00       	mov    $0x0,%edx
  800574:	eb 07                	jmp    80057d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800579:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057d:	8d 47 01             	lea    0x1(%edi),%eax
  800580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800583:	0f b6 07             	movzbl (%edi),%eax
  800586:	0f b6 c8             	movzbl %al,%ecx
  800589:	83 e8 23             	sub    $0x23,%eax
  80058c:	3c 55                	cmp    $0x55,%al
  80058e:	0f 87 1a 03 00 00    	ja     8008ae <vprintfmt+0x38a>
  800594:	0f b6 c0             	movzbl %al,%eax
  800597:	ff 24 85 a0 22 80 00 	jmp    *0x8022a0(,%eax,4)
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005a1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a5:	eb d6                	jmp    80057d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8005af:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005bc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005bf:	83 fa 09             	cmp    $0x9,%edx
  8005c2:	77 39                	ja     8005fd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c7:	eb e9                	jmp    8005b2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8d 48 04             	lea    0x4(%eax),%ecx
  8005cf:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005d2:	8b 00                	mov    (%eax),%eax
  8005d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005da:	eb 27                	jmp    800603 <vprintfmt+0xdf>
  8005dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e6:	0f 49 c8             	cmovns %eax,%ecx
  8005e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ef:	eb 8c                	jmp    80057d <vprintfmt+0x59>
  8005f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005fb:	eb 80                	jmp    80057d <vprintfmt+0x59>
  8005fd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800600:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800603:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800607:	0f 89 70 ff ff ff    	jns    80057d <vprintfmt+0x59>
				width = precision, precision = -1;
  80060d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800610:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800613:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80061a:	e9 5e ff ff ff       	jmp    80057d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800622:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800625:	e9 53 ff ff ff       	jmp    80057d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 50 04             	lea    0x4(%eax),%edx
  800630:	89 55 14             	mov    %edx,0x14(%ebp)
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	53                   	push   %ebx
  800637:	ff 30                	pushl  (%eax)
  800639:	ff d6                	call   *%esi
			break;
  80063b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800641:	e9 04 ff ff ff       	jmp    80054a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	99                   	cltd   
  800652:	31 d0                	xor    %edx,%eax
  800654:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800656:	83 f8 0f             	cmp    $0xf,%eax
  800659:	7f 0b                	jg     800666 <vprintfmt+0x142>
  80065b:	8b 14 85 00 24 80 00 	mov    0x802400(,%eax,4),%edx
  800662:	85 d2                	test   %edx,%edx
  800664:	75 18                	jne    80067e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800666:	50                   	push   %eax
  800667:	68 7b 21 80 00       	push   $0x80217b
  80066c:	53                   	push   %ebx
  80066d:	56                   	push   %esi
  80066e:	e8 94 fe ff ff       	call   800507 <printfmt>
  800673:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800679:	e9 cc fe ff ff       	jmp    80054a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80067e:	52                   	push   %edx
  80067f:	68 45 25 80 00       	push   $0x802545
  800684:	53                   	push   %ebx
  800685:	56                   	push   %esi
  800686:	e8 7c fe ff ff       	call   800507 <printfmt>
  80068b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800691:	e9 b4 fe ff ff       	jmp    80054a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8d 50 04             	lea    0x4(%eax),%edx
  80069c:	89 55 14             	mov    %edx,0x14(%ebp)
  80069f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006a1:	85 ff                	test   %edi,%edi
  8006a3:	b8 74 21 80 00       	mov    $0x802174,%eax
  8006a8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006ab:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006af:	0f 8e 94 00 00 00    	jle    800749 <vprintfmt+0x225>
  8006b5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b9:	0f 84 98 00 00 00    	je     800757 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c5:	57                   	push   %edi
  8006c6:	e8 79 03 00 00       	call   800a44 <strnlen>
  8006cb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006ce:	29 c1                	sub    %eax,%ecx
  8006d0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006d3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006dd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006e0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e2:	eb 0f                	jmp    8006f3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	53                   	push   %ebx
  8006e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006eb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ed:	83 ef 01             	sub    $0x1,%edi
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	85 ff                	test   %edi,%edi
  8006f5:	7f ed                	jg     8006e4 <vprintfmt+0x1c0>
  8006f7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006fa:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006fd:	85 c9                	test   %ecx,%ecx
  8006ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800704:	0f 49 c1             	cmovns %ecx,%eax
  800707:	29 c1                	sub    %eax,%ecx
  800709:	89 75 08             	mov    %esi,0x8(%ebp)
  80070c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800712:	89 cb                	mov    %ecx,%ebx
  800714:	eb 4d                	jmp    800763 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800716:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071a:	74 1b                	je     800737 <vprintfmt+0x213>
  80071c:	0f be c0             	movsbl %al,%eax
  80071f:	83 e8 20             	sub    $0x20,%eax
  800722:	83 f8 5e             	cmp    $0x5e,%eax
  800725:	76 10                	jbe    800737 <vprintfmt+0x213>
					putch('?', putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	ff 75 0c             	pushl  0xc(%ebp)
  80072d:	6a 3f                	push   $0x3f
  80072f:	ff 55 08             	call   *0x8(%ebp)
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	eb 0d                	jmp    800744 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	52                   	push   %edx
  80073e:	ff 55 08             	call   *0x8(%ebp)
  800741:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800744:	83 eb 01             	sub    $0x1,%ebx
  800747:	eb 1a                	jmp    800763 <vprintfmt+0x23f>
  800749:	89 75 08             	mov    %esi,0x8(%ebp)
  80074c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800752:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800755:	eb 0c                	jmp    800763 <vprintfmt+0x23f>
  800757:	89 75 08             	mov    %esi,0x8(%ebp)
  80075a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800760:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800763:	83 c7 01             	add    $0x1,%edi
  800766:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80076a:	0f be d0             	movsbl %al,%edx
  80076d:	85 d2                	test   %edx,%edx
  80076f:	74 23                	je     800794 <vprintfmt+0x270>
  800771:	85 f6                	test   %esi,%esi
  800773:	78 a1                	js     800716 <vprintfmt+0x1f2>
  800775:	83 ee 01             	sub    $0x1,%esi
  800778:	79 9c                	jns    800716 <vprintfmt+0x1f2>
  80077a:	89 df                	mov    %ebx,%edi
  80077c:	8b 75 08             	mov    0x8(%ebp),%esi
  80077f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800782:	eb 18                	jmp    80079c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	53                   	push   %ebx
  800788:	6a 20                	push   $0x20
  80078a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078c:	83 ef 01             	sub    $0x1,%edi
  80078f:	83 c4 10             	add    $0x10,%esp
  800792:	eb 08                	jmp    80079c <vprintfmt+0x278>
  800794:	89 df                	mov    %ebx,%edi
  800796:	8b 75 08             	mov    0x8(%ebp),%esi
  800799:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079c:	85 ff                	test   %edi,%edi
  80079e:	7f e4                	jg     800784 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a3:	e9 a2 fd ff ff       	jmp    80054a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a8:	83 fa 01             	cmp    $0x1,%edx
  8007ab:	7e 16                	jle    8007c3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b0:	8d 50 08             	lea    0x8(%eax),%edx
  8007b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b6:	8b 50 04             	mov    0x4(%eax),%edx
  8007b9:	8b 00                	mov    (%eax),%eax
  8007bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007be:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c1:	eb 32                	jmp    8007f5 <vprintfmt+0x2d1>
	else if (lflag)
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	74 18                	je     8007df <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8d 50 04             	lea    0x4(%eax),%edx
  8007cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d0:	8b 00                	mov    (%eax),%eax
  8007d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d5:	89 c1                	mov    %eax,%ecx
  8007d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007dd:	eb 16                	jmp    8007f5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8d 50 04             	lea    0x4(%eax),%edx
  8007e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e8:	8b 00                	mov    (%eax),%eax
  8007ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ed:	89 c1                	mov    %eax,%ecx
  8007ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007fb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800800:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800804:	79 74                	jns    80087a <vprintfmt+0x356>
				putch('-', putdat);
  800806:	83 ec 08             	sub    $0x8,%esp
  800809:	53                   	push   %ebx
  80080a:	6a 2d                	push   $0x2d
  80080c:	ff d6                	call   *%esi
				num = -(long long) num;
  80080e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800811:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800814:	f7 d8                	neg    %eax
  800816:	83 d2 00             	adc    $0x0,%edx
  800819:	f7 da                	neg    %edx
  80081b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80081e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800823:	eb 55                	jmp    80087a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800825:	8d 45 14             	lea    0x14(%ebp),%eax
  800828:	e8 83 fc ff ff       	call   8004b0 <getuint>
			base = 10;
  80082d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800832:	eb 46                	jmp    80087a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800834:	8d 45 14             	lea    0x14(%ebp),%eax
  800837:	e8 74 fc ff ff       	call   8004b0 <getuint>
			base = 8;
  80083c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800841:	eb 37                	jmp    80087a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800843:	83 ec 08             	sub    $0x8,%esp
  800846:	53                   	push   %ebx
  800847:	6a 30                	push   $0x30
  800849:	ff d6                	call   *%esi
			putch('x', putdat);
  80084b:	83 c4 08             	add    $0x8,%esp
  80084e:	53                   	push   %ebx
  80084f:	6a 78                	push   $0x78
  800851:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800853:	8b 45 14             	mov    0x14(%ebp),%eax
  800856:	8d 50 04             	lea    0x4(%eax),%edx
  800859:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80085c:	8b 00                	mov    (%eax),%eax
  80085e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800863:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800866:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80086b:	eb 0d                	jmp    80087a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80086d:	8d 45 14             	lea    0x14(%ebp),%eax
  800870:	e8 3b fc ff ff       	call   8004b0 <getuint>
			base = 16;
  800875:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80087a:	83 ec 0c             	sub    $0xc,%esp
  80087d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800881:	57                   	push   %edi
  800882:	ff 75 e0             	pushl  -0x20(%ebp)
  800885:	51                   	push   %ecx
  800886:	52                   	push   %edx
  800887:	50                   	push   %eax
  800888:	89 da                	mov    %ebx,%edx
  80088a:	89 f0                	mov    %esi,%eax
  80088c:	e8 70 fb ff ff       	call   800401 <printnum>
			break;
  800891:	83 c4 20             	add    $0x20,%esp
  800894:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800897:	e9 ae fc ff ff       	jmp    80054a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	53                   	push   %ebx
  8008a0:	51                   	push   %ecx
  8008a1:	ff d6                	call   *%esi
			break;
  8008a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a9:	e9 9c fc ff ff       	jmp    80054a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	53                   	push   %ebx
  8008b2:	6a 25                	push   $0x25
  8008b4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b6:	83 c4 10             	add    $0x10,%esp
  8008b9:	eb 03                	jmp    8008be <vprintfmt+0x39a>
  8008bb:	83 ef 01             	sub    $0x1,%edi
  8008be:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008c2:	75 f7                	jne    8008bb <vprintfmt+0x397>
  8008c4:	e9 81 fc ff ff       	jmp    80054a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008cc:	5b                   	pop    %ebx
  8008cd:	5e                   	pop    %esi
  8008ce:	5f                   	pop    %edi
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	83 ec 18             	sub    $0x18,%esp
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ee:	85 c0                	test   %eax,%eax
  8008f0:	74 26                	je     800918 <vsnprintf+0x47>
  8008f2:	85 d2                	test   %edx,%edx
  8008f4:	7e 22                	jle    800918 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f6:	ff 75 14             	pushl  0x14(%ebp)
  8008f9:	ff 75 10             	pushl  0x10(%ebp)
  8008fc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ff:	50                   	push   %eax
  800900:	68 ea 04 80 00       	push   $0x8004ea
  800905:	e8 1a fc ff ff       	call   800524 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80090a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80090d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800910:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800913:	83 c4 10             	add    $0x10,%esp
  800916:	eb 05                	jmp    80091d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800918:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800925:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800928:	50                   	push   %eax
  800929:	ff 75 10             	pushl  0x10(%ebp)
  80092c:	ff 75 0c             	pushl  0xc(%ebp)
  80092f:	ff 75 08             	pushl  0x8(%ebp)
  800932:	e8 9a ff ff ff       	call   8008d1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800937:	c9                   	leave  
  800938:	c3                   	ret    

00800939 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	57                   	push   %edi
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	83 ec 0c             	sub    $0xc,%esp
  800942:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800945:	85 c0                	test   %eax,%eax
  800947:	74 13                	je     80095c <readline+0x23>
		fprintf(1, "%s", prompt);
  800949:	83 ec 04             	sub    $0x4,%esp
  80094c:	50                   	push   %eax
  80094d:	68 45 25 80 00       	push   $0x802545
  800952:	6a 01                	push   $0x1
  800954:	e8 ee 0f 00 00       	call   801947 <fprintf>
  800959:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80095c:	83 ec 0c             	sub    $0xc,%esp
  80095f:	6a 00                	push   $0x0
  800961:	e8 80 f8 ff ff       	call   8001e6 <iscons>
  800966:	89 c7                	mov    %eax,%edi
  800968:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  80096b:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  800970:	e8 46 f8 ff ff       	call   8001bb <getchar>
  800975:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800977:	85 c0                	test   %eax,%eax
  800979:	79 29                	jns    8009a4 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80097b:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  800980:	83 fb f8             	cmp    $0xfffffff8,%ebx
  800983:	0f 84 9b 00 00 00    	je     800a24 <readline+0xeb>
				cprintf("read error: %e\n", c);
  800989:	83 ec 08             	sub    $0x8,%esp
  80098c:	53                   	push   %ebx
  80098d:	68 5f 24 80 00       	push   $0x80245f
  800992:	e8 56 fa ff ff       	call   8003ed <cprintf>
  800997:	83 c4 10             	add    $0x10,%esp
			return NULL;
  80099a:	b8 00 00 00 00       	mov    $0x0,%eax
  80099f:	e9 80 00 00 00       	jmp    800a24 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8009a4:	83 f8 08             	cmp    $0x8,%eax
  8009a7:	0f 94 c2             	sete   %dl
  8009aa:	83 f8 7f             	cmp    $0x7f,%eax
  8009ad:	0f 94 c0             	sete   %al
  8009b0:	08 c2                	or     %al,%dl
  8009b2:	74 1a                	je     8009ce <readline+0x95>
  8009b4:	85 f6                	test   %esi,%esi
  8009b6:	7e 16                	jle    8009ce <readline+0x95>
			if (echoing)
  8009b8:	85 ff                	test   %edi,%edi
  8009ba:	74 0d                	je     8009c9 <readline+0x90>
				cputchar('\b');
  8009bc:	83 ec 0c             	sub    $0xc,%esp
  8009bf:	6a 08                	push   $0x8
  8009c1:	e8 d9 f7 ff ff       	call   80019f <cputchar>
  8009c6:	83 c4 10             	add    $0x10,%esp
			i--;
  8009c9:	83 ee 01             	sub    $0x1,%esi
  8009cc:	eb a2                	jmp    800970 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8009ce:	83 fb 1f             	cmp    $0x1f,%ebx
  8009d1:	7e 26                	jle    8009f9 <readline+0xc0>
  8009d3:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8009d9:	7f 1e                	jg     8009f9 <readline+0xc0>
			if (echoing)
  8009db:	85 ff                	test   %edi,%edi
  8009dd:	74 0c                	je     8009eb <readline+0xb2>
				cputchar(c);
  8009df:	83 ec 0c             	sub    $0xc,%esp
  8009e2:	53                   	push   %ebx
  8009e3:	e8 b7 f7 ff ff       	call   80019f <cputchar>
  8009e8:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8009eb:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  8009f1:	8d 76 01             	lea    0x1(%esi),%esi
  8009f4:	e9 77 ff ff ff       	jmp    800970 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8009f9:	83 fb 0a             	cmp    $0xa,%ebx
  8009fc:	74 09                	je     800a07 <readline+0xce>
  8009fe:	83 fb 0d             	cmp    $0xd,%ebx
  800a01:	0f 85 69 ff ff ff    	jne    800970 <readline+0x37>
			if (echoing)
  800a07:	85 ff                	test   %edi,%edi
  800a09:	74 0d                	je     800a18 <readline+0xdf>
				cputchar('\n');
  800a0b:	83 ec 0c             	sub    $0xc,%esp
  800a0e:	6a 0a                	push   $0xa
  800a10:	e8 8a f7 ff ff       	call   80019f <cputchar>
  800a15:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  800a18:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800a1f:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  800a24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a27:	5b                   	pop    %ebx
  800a28:	5e                   	pop    %esi
  800a29:	5f                   	pop    %edi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
  800a37:	eb 03                	jmp    800a3c <strlen+0x10>
		n++;
  800a39:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a3c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a40:	75 f7                	jne    800a39 <strlen+0xd>
		n++;
	return n;
}
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a52:	eb 03                	jmp    800a57 <strnlen+0x13>
		n++;
  800a54:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a57:	39 c2                	cmp    %eax,%edx
  800a59:	74 08                	je     800a63 <strnlen+0x1f>
  800a5b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a5f:	75 f3                	jne    800a54 <strnlen+0x10>
  800a61:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	53                   	push   %ebx
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a6f:	89 c2                	mov    %eax,%edx
  800a71:	83 c2 01             	add    $0x1,%edx
  800a74:	83 c1 01             	add    $0x1,%ecx
  800a77:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a7b:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a7e:	84 db                	test   %bl,%bl
  800a80:	75 ef                	jne    800a71 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a82:	5b                   	pop    %ebx
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	53                   	push   %ebx
  800a89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a8c:	53                   	push   %ebx
  800a8d:	e8 9a ff ff ff       	call   800a2c <strlen>
  800a92:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a95:	ff 75 0c             	pushl  0xc(%ebp)
  800a98:	01 d8                	add    %ebx,%eax
  800a9a:	50                   	push   %eax
  800a9b:	e8 c5 ff ff ff       	call   800a65 <strcpy>
	return dst;
}
  800aa0:	89 d8                	mov    %ebx,%eax
  800aa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	8b 75 08             	mov    0x8(%ebp),%esi
  800aaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab2:	89 f3                	mov    %esi,%ebx
  800ab4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab7:	89 f2                	mov    %esi,%edx
  800ab9:	eb 0f                	jmp    800aca <strncpy+0x23>
		*dst++ = *src;
  800abb:	83 c2 01             	add    $0x1,%edx
  800abe:	0f b6 01             	movzbl (%ecx),%eax
  800ac1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ac4:	80 39 01             	cmpb   $0x1,(%ecx)
  800ac7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aca:	39 da                	cmp    %ebx,%edx
  800acc:	75 ed                	jne    800abb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ace:	89 f0                	mov    %esi,%eax
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 75 08             	mov    0x8(%ebp),%esi
  800adc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800adf:	8b 55 10             	mov    0x10(%ebp),%edx
  800ae2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae4:	85 d2                	test   %edx,%edx
  800ae6:	74 21                	je     800b09 <strlcpy+0x35>
  800ae8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800aec:	89 f2                	mov    %esi,%edx
  800aee:	eb 09                	jmp    800af9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800af0:	83 c2 01             	add    $0x1,%edx
  800af3:	83 c1 01             	add    $0x1,%ecx
  800af6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af9:	39 c2                	cmp    %eax,%edx
  800afb:	74 09                	je     800b06 <strlcpy+0x32>
  800afd:	0f b6 19             	movzbl (%ecx),%ebx
  800b00:	84 db                	test   %bl,%bl
  800b02:	75 ec                	jne    800af0 <strlcpy+0x1c>
  800b04:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b06:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b09:	29 f0                	sub    %esi,%eax
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b15:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b18:	eb 06                	jmp    800b20 <strcmp+0x11>
		p++, q++;
  800b1a:	83 c1 01             	add    $0x1,%ecx
  800b1d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b20:	0f b6 01             	movzbl (%ecx),%eax
  800b23:	84 c0                	test   %al,%al
  800b25:	74 04                	je     800b2b <strcmp+0x1c>
  800b27:	3a 02                	cmp    (%edx),%al
  800b29:	74 ef                	je     800b1a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b2b:	0f b6 c0             	movzbl %al,%eax
  800b2e:	0f b6 12             	movzbl (%edx),%edx
  800b31:	29 d0                	sub    %edx,%eax
}
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	53                   	push   %ebx
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3f:	89 c3                	mov    %eax,%ebx
  800b41:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b44:	eb 06                	jmp    800b4c <strncmp+0x17>
		n--, p++, q++;
  800b46:	83 c0 01             	add    $0x1,%eax
  800b49:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b4c:	39 d8                	cmp    %ebx,%eax
  800b4e:	74 15                	je     800b65 <strncmp+0x30>
  800b50:	0f b6 08             	movzbl (%eax),%ecx
  800b53:	84 c9                	test   %cl,%cl
  800b55:	74 04                	je     800b5b <strncmp+0x26>
  800b57:	3a 0a                	cmp    (%edx),%cl
  800b59:	74 eb                	je     800b46 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b5b:	0f b6 00             	movzbl (%eax),%eax
  800b5e:	0f b6 12             	movzbl (%edx),%edx
  800b61:	29 d0                	sub    %edx,%eax
  800b63:	eb 05                	jmp    800b6a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b6a:	5b                   	pop    %ebx
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b77:	eb 07                	jmp    800b80 <strchr+0x13>
		if (*s == c)
  800b79:	38 ca                	cmp    %cl,%dl
  800b7b:	74 0f                	je     800b8c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b7d:	83 c0 01             	add    $0x1,%eax
  800b80:	0f b6 10             	movzbl (%eax),%edx
  800b83:	84 d2                	test   %dl,%dl
  800b85:	75 f2                	jne    800b79 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	8b 45 08             	mov    0x8(%ebp),%eax
  800b94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b98:	eb 03                	jmp    800b9d <strfind+0xf>
  800b9a:	83 c0 01             	add    $0x1,%eax
  800b9d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ba0:	38 ca                	cmp    %cl,%dl
  800ba2:	74 04                	je     800ba8 <strfind+0x1a>
  800ba4:	84 d2                	test   %dl,%dl
  800ba6:	75 f2                	jne    800b9a <strfind+0xc>
			break;
	return (char *) s;
}
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
  800bb0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bb3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bb6:	85 c9                	test   %ecx,%ecx
  800bb8:	74 36                	je     800bf0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bba:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bc0:	75 28                	jne    800bea <memset+0x40>
  800bc2:	f6 c1 03             	test   $0x3,%cl
  800bc5:	75 23                	jne    800bea <memset+0x40>
		c &= 0xFF;
  800bc7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bcb:	89 d3                	mov    %edx,%ebx
  800bcd:	c1 e3 08             	shl    $0x8,%ebx
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	c1 e6 18             	shl    $0x18,%esi
  800bd5:	89 d0                	mov    %edx,%eax
  800bd7:	c1 e0 10             	shl    $0x10,%eax
  800bda:	09 f0                	or     %esi,%eax
  800bdc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bde:	89 d8                	mov    %ebx,%eax
  800be0:	09 d0                	or     %edx,%eax
  800be2:	c1 e9 02             	shr    $0x2,%ecx
  800be5:	fc                   	cld    
  800be6:	f3 ab                	rep stos %eax,%es:(%edi)
  800be8:	eb 06                	jmp    800bf0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bed:	fc                   	cld    
  800bee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bf0:	89 f8                	mov    %edi,%eax
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c05:	39 c6                	cmp    %eax,%esi
  800c07:	73 35                	jae    800c3e <memmove+0x47>
  800c09:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c0c:	39 d0                	cmp    %edx,%eax
  800c0e:	73 2e                	jae    800c3e <memmove+0x47>
		s += n;
		d += n;
  800c10:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c13:	89 d6                	mov    %edx,%esi
  800c15:	09 fe                	or     %edi,%esi
  800c17:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c1d:	75 13                	jne    800c32 <memmove+0x3b>
  800c1f:	f6 c1 03             	test   $0x3,%cl
  800c22:	75 0e                	jne    800c32 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c24:	83 ef 04             	sub    $0x4,%edi
  800c27:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c2a:	c1 e9 02             	shr    $0x2,%ecx
  800c2d:	fd                   	std    
  800c2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c30:	eb 09                	jmp    800c3b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c32:	83 ef 01             	sub    $0x1,%edi
  800c35:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c38:	fd                   	std    
  800c39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c3b:	fc                   	cld    
  800c3c:	eb 1d                	jmp    800c5b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3e:	89 f2                	mov    %esi,%edx
  800c40:	09 c2                	or     %eax,%edx
  800c42:	f6 c2 03             	test   $0x3,%dl
  800c45:	75 0f                	jne    800c56 <memmove+0x5f>
  800c47:	f6 c1 03             	test   $0x3,%cl
  800c4a:	75 0a                	jne    800c56 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c4c:	c1 e9 02             	shr    $0x2,%ecx
  800c4f:	89 c7                	mov    %eax,%edi
  800c51:	fc                   	cld    
  800c52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c54:	eb 05                	jmp    800c5b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c56:	89 c7                	mov    %eax,%edi
  800c58:	fc                   	cld    
  800c59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c62:	ff 75 10             	pushl  0x10(%ebp)
  800c65:	ff 75 0c             	pushl  0xc(%ebp)
  800c68:	ff 75 08             	pushl  0x8(%ebp)
  800c6b:	e8 87 ff ff ff       	call   800bf7 <memmove>
}
  800c70:	c9                   	leave  
  800c71:	c3                   	ret    

00800c72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
  800c77:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7d:	89 c6                	mov    %eax,%esi
  800c7f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c82:	eb 1a                	jmp    800c9e <memcmp+0x2c>
		if (*s1 != *s2)
  800c84:	0f b6 08             	movzbl (%eax),%ecx
  800c87:	0f b6 1a             	movzbl (%edx),%ebx
  800c8a:	38 d9                	cmp    %bl,%cl
  800c8c:	74 0a                	je     800c98 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c8e:	0f b6 c1             	movzbl %cl,%eax
  800c91:	0f b6 db             	movzbl %bl,%ebx
  800c94:	29 d8                	sub    %ebx,%eax
  800c96:	eb 0f                	jmp    800ca7 <memcmp+0x35>
		s1++, s2++;
  800c98:	83 c0 01             	add    $0x1,%eax
  800c9b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c9e:	39 f0                	cmp    %esi,%eax
  800ca0:	75 e2                	jne    800c84 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ca2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	53                   	push   %ebx
  800caf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cb2:	89 c1                	mov    %eax,%ecx
  800cb4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cbb:	eb 0a                	jmp    800cc7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cbd:	0f b6 10             	movzbl (%eax),%edx
  800cc0:	39 da                	cmp    %ebx,%edx
  800cc2:	74 07                	je     800ccb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cc4:	83 c0 01             	add    $0x1,%eax
  800cc7:	39 c8                	cmp    %ecx,%eax
  800cc9:	72 f2                	jb     800cbd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ccb:	5b                   	pop    %ebx
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cda:	eb 03                	jmp    800cdf <strtol+0x11>
		s++;
  800cdc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cdf:	0f b6 01             	movzbl (%ecx),%eax
  800ce2:	3c 20                	cmp    $0x20,%al
  800ce4:	74 f6                	je     800cdc <strtol+0xe>
  800ce6:	3c 09                	cmp    $0x9,%al
  800ce8:	74 f2                	je     800cdc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cea:	3c 2b                	cmp    $0x2b,%al
  800cec:	75 0a                	jne    800cf8 <strtol+0x2a>
		s++;
  800cee:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cf1:	bf 00 00 00 00       	mov    $0x0,%edi
  800cf6:	eb 11                	jmp    800d09 <strtol+0x3b>
  800cf8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cfd:	3c 2d                	cmp    $0x2d,%al
  800cff:	75 08                	jne    800d09 <strtol+0x3b>
		s++, neg = 1;
  800d01:	83 c1 01             	add    $0x1,%ecx
  800d04:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d09:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d0f:	75 15                	jne    800d26 <strtol+0x58>
  800d11:	80 39 30             	cmpb   $0x30,(%ecx)
  800d14:	75 10                	jne    800d26 <strtol+0x58>
  800d16:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d1a:	75 7c                	jne    800d98 <strtol+0xca>
		s += 2, base = 16;
  800d1c:	83 c1 02             	add    $0x2,%ecx
  800d1f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d24:	eb 16                	jmp    800d3c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d26:	85 db                	test   %ebx,%ebx
  800d28:	75 12                	jne    800d3c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d2a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d2f:	80 39 30             	cmpb   $0x30,(%ecx)
  800d32:	75 08                	jne    800d3c <strtol+0x6e>
		s++, base = 8;
  800d34:	83 c1 01             	add    $0x1,%ecx
  800d37:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d41:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d44:	0f b6 11             	movzbl (%ecx),%edx
  800d47:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d4a:	89 f3                	mov    %esi,%ebx
  800d4c:	80 fb 09             	cmp    $0x9,%bl
  800d4f:	77 08                	ja     800d59 <strtol+0x8b>
			dig = *s - '0';
  800d51:	0f be d2             	movsbl %dl,%edx
  800d54:	83 ea 30             	sub    $0x30,%edx
  800d57:	eb 22                	jmp    800d7b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d59:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d5c:	89 f3                	mov    %esi,%ebx
  800d5e:	80 fb 19             	cmp    $0x19,%bl
  800d61:	77 08                	ja     800d6b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d63:	0f be d2             	movsbl %dl,%edx
  800d66:	83 ea 57             	sub    $0x57,%edx
  800d69:	eb 10                	jmp    800d7b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d6b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d6e:	89 f3                	mov    %esi,%ebx
  800d70:	80 fb 19             	cmp    $0x19,%bl
  800d73:	77 16                	ja     800d8b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d75:	0f be d2             	movsbl %dl,%edx
  800d78:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d7b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d7e:	7d 0b                	jge    800d8b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d80:	83 c1 01             	add    $0x1,%ecx
  800d83:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d87:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d89:	eb b9                	jmp    800d44 <strtol+0x76>

	if (endptr)
  800d8b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d8f:	74 0d                	je     800d9e <strtol+0xd0>
		*endptr = (char *) s;
  800d91:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d94:	89 0e                	mov    %ecx,(%esi)
  800d96:	eb 06                	jmp    800d9e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d98:	85 db                	test   %ebx,%ebx
  800d9a:	74 98                	je     800d34 <strtol+0x66>
  800d9c:	eb 9e                	jmp    800d3c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d9e:	89 c2                	mov    %eax,%edx
  800da0:	f7 da                	neg    %edx
  800da2:	85 ff                	test   %edi,%edi
  800da4:	0f 45 c2             	cmovne %edx,%eax
}
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	b8 00 00 00 00       	mov    $0x0,%eax
  800db7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	89 c3                	mov    %eax,%ebx
  800dbf:	89 c7                	mov    %eax,%edi
  800dc1:	89 c6                	mov    %eax,%esi
  800dc3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_cgetc>:

int
sys_cgetc(void)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd5:	b8 01 00 00 00       	mov    $0x1,%eax
  800dda:	89 d1                	mov    %edx,%ecx
  800ddc:	89 d3                	mov    %edx,%ebx
  800dde:	89 d7                	mov    %edx,%edi
  800de0:	89 d6                	mov    %edx,%esi
  800de2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
  800def:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df7:	b8 03 00 00 00       	mov    $0x3,%eax
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	89 cb                	mov    %ecx,%ebx
  800e01:	89 cf                	mov    %ecx,%edi
  800e03:	89 ce                	mov    %ecx,%esi
  800e05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 17                	jle    800e22 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	50                   	push   %eax
  800e0f:	6a 03                	push   $0x3
  800e11:	68 6f 24 80 00       	push   $0x80246f
  800e16:	6a 23                	push   $0x23
  800e18:	68 8c 24 80 00       	push   $0x80248c
  800e1d:	e8 f2 f4 ff ff       	call   800314 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e30:	ba 00 00 00 00       	mov    $0x0,%edx
  800e35:	b8 02 00 00 00       	mov    $0x2,%eax
  800e3a:	89 d1                	mov    %edx,%ecx
  800e3c:	89 d3                	mov    %edx,%ebx
  800e3e:	89 d7                	mov    %edx,%edi
  800e40:	89 d6                	mov    %edx,%esi
  800e42:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_yield>:

void
sys_yield(void)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e54:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e59:	89 d1                	mov    %edx,%ecx
  800e5b:	89 d3                	mov    %edx,%ebx
  800e5d:	89 d7                	mov    %edx,%edi
  800e5f:	89 d6                	mov    %edx,%esi
  800e61:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
  800e6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e71:	be 00 00 00 00       	mov    $0x0,%esi
  800e76:	b8 04 00 00 00       	mov    $0x4,%eax
  800e7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e84:	89 f7                	mov    %esi,%edi
  800e86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	7e 17                	jle    800ea3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8c:	83 ec 0c             	sub    $0xc,%esp
  800e8f:	50                   	push   %eax
  800e90:	6a 04                	push   $0x4
  800e92:	68 6f 24 80 00       	push   $0x80246f
  800e97:	6a 23                	push   $0x23
  800e99:	68 8c 24 80 00       	push   $0x80248c
  800e9e:	e8 71 f4 ff ff       	call   800314 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ea3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
  800eb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb4:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec5:	8b 75 18             	mov    0x18(%ebp),%esi
  800ec8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	7e 17                	jle    800ee5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ece:	83 ec 0c             	sub    $0xc,%esp
  800ed1:	50                   	push   %eax
  800ed2:	6a 05                	push   $0x5
  800ed4:	68 6f 24 80 00       	push   $0x80246f
  800ed9:	6a 23                	push   $0x23
  800edb:	68 8c 24 80 00       	push   $0x80248c
  800ee0:	e8 2f f4 ff ff       	call   800314 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ee5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	57                   	push   %edi
  800ef1:	56                   	push   %esi
  800ef2:	53                   	push   %ebx
  800ef3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efb:	b8 06 00 00 00       	mov    $0x6,%eax
  800f00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	89 df                	mov    %ebx,%edi
  800f08:	89 de                	mov    %ebx,%esi
  800f0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	7e 17                	jle    800f27 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	50                   	push   %eax
  800f14:	6a 06                	push   $0x6
  800f16:	68 6f 24 80 00       	push   $0x80246f
  800f1b:	6a 23                	push   $0x23
  800f1d:	68 8c 24 80 00       	push   $0x80248c
  800f22:	e8 ed f3 ff ff       	call   800314 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5f                   	pop    %edi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	57                   	push   %edi
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3d:	b8 08 00 00 00       	mov    $0x8,%eax
  800f42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f45:	8b 55 08             	mov    0x8(%ebp),%edx
  800f48:	89 df                	mov    %ebx,%edi
  800f4a:	89 de                	mov    %ebx,%esi
  800f4c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	7e 17                	jle    800f69 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f52:	83 ec 0c             	sub    $0xc,%esp
  800f55:	50                   	push   %eax
  800f56:	6a 08                	push   $0x8
  800f58:	68 6f 24 80 00       	push   $0x80246f
  800f5d:	6a 23                	push   $0x23
  800f5f:	68 8c 24 80 00       	push   $0x80248c
  800f64:	e8 ab f3 ff ff       	call   800314 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6c:	5b                   	pop    %ebx
  800f6d:	5e                   	pop    %esi
  800f6e:	5f                   	pop    %edi
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    

00800f71 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	57                   	push   %edi
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7f:	b8 09 00 00 00       	mov    $0x9,%eax
  800f84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f87:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8a:	89 df                	mov    %ebx,%edi
  800f8c:	89 de                	mov    %ebx,%esi
  800f8e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f90:	85 c0                	test   %eax,%eax
  800f92:	7e 17                	jle    800fab <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	50                   	push   %eax
  800f98:	6a 09                	push   $0x9
  800f9a:	68 6f 24 80 00       	push   $0x80246f
  800f9f:	6a 23                	push   $0x23
  800fa1:	68 8c 24 80 00       	push   $0x80248c
  800fa6:	e8 69 f3 ff ff       	call   800314 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fae:	5b                   	pop    %ebx
  800faf:	5e                   	pop    %esi
  800fb0:	5f                   	pop    %edi
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    

00800fb3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	57                   	push   %edi
  800fb7:	56                   	push   %esi
  800fb8:	53                   	push   %ebx
  800fb9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcc:	89 df                	mov    %ebx,%edi
  800fce:	89 de                	mov    %ebx,%esi
  800fd0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	7e 17                	jle    800fed <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	50                   	push   %eax
  800fda:	6a 0a                	push   $0xa
  800fdc:	68 6f 24 80 00       	push   $0x80246f
  800fe1:	6a 23                	push   $0x23
  800fe3:	68 8c 24 80 00       	push   $0x80248c
  800fe8:	e8 27 f3 ff ff       	call   800314 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	57                   	push   %edi
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffb:	be 00 00 00 00       	mov    $0x0,%esi
  801000:	b8 0c 00 00 00       	mov    $0xc,%eax
  801005:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801008:	8b 55 08             	mov    0x8(%ebp),%edx
  80100b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80100e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801011:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801013:	5b                   	pop    %ebx
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    

00801018 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	57                   	push   %edi
  80101c:	56                   	push   %esi
  80101d:	53                   	push   %ebx
  80101e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801021:	b9 00 00 00 00       	mov    $0x0,%ecx
  801026:	b8 0d 00 00 00       	mov    $0xd,%eax
  80102b:	8b 55 08             	mov    0x8(%ebp),%edx
  80102e:	89 cb                	mov    %ecx,%ebx
  801030:	89 cf                	mov    %ecx,%edi
  801032:	89 ce                	mov    %ecx,%esi
  801034:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801036:	85 c0                	test   %eax,%eax
  801038:	7e 17                	jle    801051 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103a:	83 ec 0c             	sub    $0xc,%esp
  80103d:	50                   	push   %eax
  80103e:	6a 0d                	push   $0xd
  801040:	68 6f 24 80 00       	push   $0x80246f
  801045:	6a 23                	push   $0x23
  801047:	68 8c 24 80 00       	push   $0x80248c
  80104c:	e8 c3 f2 ff ff       	call   800314 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801051:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801054:	5b                   	pop    %ebx
  801055:	5e                   	pop    %esi
  801056:	5f                   	pop    %edi
  801057:	5d                   	pop    %ebp
  801058:	c3                   	ret    

00801059 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80105c:	8b 45 08             	mov    0x8(%ebp),%eax
  80105f:	05 00 00 00 30       	add    $0x30000000,%eax
  801064:	c1 e8 0c             	shr    $0xc,%eax
}
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    

00801069 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80106c:	8b 45 08             	mov    0x8(%ebp),%eax
  80106f:	05 00 00 00 30       	add    $0x30000000,%eax
  801074:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801079:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801086:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80108b:	89 c2                	mov    %eax,%edx
  80108d:	c1 ea 16             	shr    $0x16,%edx
  801090:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801097:	f6 c2 01             	test   $0x1,%dl
  80109a:	74 11                	je     8010ad <fd_alloc+0x2d>
  80109c:	89 c2                	mov    %eax,%edx
  80109e:	c1 ea 0c             	shr    $0xc,%edx
  8010a1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010a8:	f6 c2 01             	test   $0x1,%dl
  8010ab:	75 09                	jne    8010b6 <fd_alloc+0x36>
			*fd_store = fd;
  8010ad:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010af:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b4:	eb 17                	jmp    8010cd <fd_alloc+0x4d>
  8010b6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010bb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010c0:	75 c9                	jne    80108b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010c2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010c8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010d5:	83 f8 1f             	cmp    $0x1f,%eax
  8010d8:	77 36                	ja     801110 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010da:	c1 e0 0c             	shl    $0xc,%eax
  8010dd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010e2:	89 c2                	mov    %eax,%edx
  8010e4:	c1 ea 16             	shr    $0x16,%edx
  8010e7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ee:	f6 c2 01             	test   $0x1,%dl
  8010f1:	74 24                	je     801117 <fd_lookup+0x48>
  8010f3:	89 c2                	mov    %eax,%edx
  8010f5:	c1 ea 0c             	shr    $0xc,%edx
  8010f8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ff:	f6 c2 01             	test   $0x1,%dl
  801102:	74 1a                	je     80111e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801104:	8b 55 0c             	mov    0xc(%ebp),%edx
  801107:	89 02                	mov    %eax,(%edx)
	return 0;
  801109:	b8 00 00 00 00       	mov    $0x0,%eax
  80110e:	eb 13                	jmp    801123 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801110:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801115:	eb 0c                	jmp    801123 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801117:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111c:	eb 05                	jmp    801123 <fd_lookup+0x54>
  80111e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    

00801125 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	83 ec 08             	sub    $0x8,%esp
  80112b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112e:	ba 1c 25 80 00       	mov    $0x80251c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801133:	eb 13                	jmp    801148 <dev_lookup+0x23>
  801135:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801138:	39 08                	cmp    %ecx,(%eax)
  80113a:	75 0c                	jne    801148 <dev_lookup+0x23>
			*dev = devtab[i];
  80113c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801141:	b8 00 00 00 00       	mov    $0x0,%eax
  801146:	eb 2e                	jmp    801176 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801148:	8b 02                	mov    (%edx),%eax
  80114a:	85 c0                	test   %eax,%eax
  80114c:	75 e7                	jne    801135 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80114e:	a1 04 44 80 00       	mov    0x804404,%eax
  801153:	8b 40 48             	mov    0x48(%eax),%eax
  801156:	83 ec 04             	sub    $0x4,%esp
  801159:	51                   	push   %ecx
  80115a:	50                   	push   %eax
  80115b:	68 9c 24 80 00       	push   $0x80249c
  801160:	e8 88 f2 ff ff       	call   8003ed <cprintf>
	*dev = 0;
  801165:	8b 45 0c             	mov    0xc(%ebp),%eax
  801168:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80116e:	83 c4 10             	add    $0x10,%esp
  801171:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801176:	c9                   	leave  
  801177:	c3                   	ret    

00801178 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	56                   	push   %esi
  80117c:	53                   	push   %ebx
  80117d:	83 ec 10             	sub    $0x10,%esp
  801180:	8b 75 08             	mov    0x8(%ebp),%esi
  801183:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801186:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801189:	50                   	push   %eax
  80118a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801190:	c1 e8 0c             	shr    $0xc,%eax
  801193:	50                   	push   %eax
  801194:	e8 36 ff ff ff       	call   8010cf <fd_lookup>
  801199:	83 c4 08             	add    $0x8,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	78 05                	js     8011a5 <fd_close+0x2d>
	    || fd != fd2)
  8011a0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011a3:	74 0c                	je     8011b1 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011a5:	84 db                	test   %bl,%bl
  8011a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ac:	0f 44 c2             	cmove  %edx,%eax
  8011af:	eb 41                	jmp    8011f2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011b1:	83 ec 08             	sub    $0x8,%esp
  8011b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b7:	50                   	push   %eax
  8011b8:	ff 36                	pushl  (%esi)
  8011ba:	e8 66 ff ff ff       	call   801125 <dev_lookup>
  8011bf:	89 c3                	mov    %eax,%ebx
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 1a                	js     8011e2 <fd_close+0x6a>
		if (dev->dev_close)
  8011c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011ce:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	74 0b                	je     8011e2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011d7:	83 ec 0c             	sub    $0xc,%esp
  8011da:	56                   	push   %esi
  8011db:	ff d0                	call   *%eax
  8011dd:	89 c3                	mov    %eax,%ebx
  8011df:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011e2:	83 ec 08             	sub    $0x8,%esp
  8011e5:	56                   	push   %esi
  8011e6:	6a 00                	push   $0x0
  8011e8:	e8 00 fd ff ff       	call   800eed <sys_page_unmap>
	return r;
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	89 d8                	mov    %ebx,%eax
}
  8011f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f5:	5b                   	pop    %ebx
  8011f6:	5e                   	pop    %esi
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801202:	50                   	push   %eax
  801203:	ff 75 08             	pushl  0x8(%ebp)
  801206:	e8 c4 fe ff ff       	call   8010cf <fd_lookup>
  80120b:	83 c4 08             	add    $0x8,%esp
  80120e:	85 c0                	test   %eax,%eax
  801210:	78 10                	js     801222 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801212:	83 ec 08             	sub    $0x8,%esp
  801215:	6a 01                	push   $0x1
  801217:	ff 75 f4             	pushl  -0xc(%ebp)
  80121a:	e8 59 ff ff ff       	call   801178 <fd_close>
  80121f:	83 c4 10             	add    $0x10,%esp
}
  801222:	c9                   	leave  
  801223:	c3                   	ret    

00801224 <close_all>:

void
close_all(void)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	53                   	push   %ebx
  801228:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80122b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801230:	83 ec 0c             	sub    $0xc,%esp
  801233:	53                   	push   %ebx
  801234:	e8 c0 ff ff ff       	call   8011f9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801239:	83 c3 01             	add    $0x1,%ebx
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	83 fb 20             	cmp    $0x20,%ebx
  801242:	75 ec                	jne    801230 <close_all+0xc>
		close(i);
}
  801244:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801247:	c9                   	leave  
  801248:	c3                   	ret    

00801249 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	57                   	push   %edi
  80124d:	56                   	push   %esi
  80124e:	53                   	push   %ebx
  80124f:	83 ec 2c             	sub    $0x2c,%esp
  801252:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801255:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	ff 75 08             	pushl  0x8(%ebp)
  80125c:	e8 6e fe ff ff       	call   8010cf <fd_lookup>
  801261:	83 c4 08             	add    $0x8,%esp
  801264:	85 c0                	test   %eax,%eax
  801266:	0f 88 c1 00 00 00    	js     80132d <dup+0xe4>
		return r;
	close(newfdnum);
  80126c:	83 ec 0c             	sub    $0xc,%esp
  80126f:	56                   	push   %esi
  801270:	e8 84 ff ff ff       	call   8011f9 <close>

	newfd = INDEX2FD(newfdnum);
  801275:	89 f3                	mov    %esi,%ebx
  801277:	c1 e3 0c             	shl    $0xc,%ebx
  80127a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801280:	83 c4 04             	add    $0x4,%esp
  801283:	ff 75 e4             	pushl  -0x1c(%ebp)
  801286:	e8 de fd ff ff       	call   801069 <fd2data>
  80128b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80128d:	89 1c 24             	mov    %ebx,(%esp)
  801290:	e8 d4 fd ff ff       	call   801069 <fd2data>
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80129b:	89 f8                	mov    %edi,%eax
  80129d:	c1 e8 16             	shr    $0x16,%eax
  8012a0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012a7:	a8 01                	test   $0x1,%al
  8012a9:	74 37                	je     8012e2 <dup+0x99>
  8012ab:	89 f8                	mov    %edi,%eax
  8012ad:	c1 e8 0c             	shr    $0xc,%eax
  8012b0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012b7:	f6 c2 01             	test   $0x1,%dl
  8012ba:	74 26                	je     8012e2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c3:	83 ec 0c             	sub    $0xc,%esp
  8012c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8012cb:	50                   	push   %eax
  8012cc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012cf:	6a 00                	push   $0x0
  8012d1:	57                   	push   %edi
  8012d2:	6a 00                	push   $0x0
  8012d4:	e8 d2 fb ff ff       	call   800eab <sys_page_map>
  8012d9:	89 c7                	mov    %eax,%edi
  8012db:	83 c4 20             	add    $0x20,%esp
  8012de:	85 c0                	test   %eax,%eax
  8012e0:	78 2e                	js     801310 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012e5:	89 d0                	mov    %edx,%eax
  8012e7:	c1 e8 0c             	shr    $0xc,%eax
  8012ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f1:	83 ec 0c             	sub    $0xc,%esp
  8012f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f9:	50                   	push   %eax
  8012fa:	53                   	push   %ebx
  8012fb:	6a 00                	push   $0x0
  8012fd:	52                   	push   %edx
  8012fe:	6a 00                	push   $0x0
  801300:	e8 a6 fb ff ff       	call   800eab <sys_page_map>
  801305:	89 c7                	mov    %eax,%edi
  801307:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80130a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80130c:	85 ff                	test   %edi,%edi
  80130e:	79 1d                	jns    80132d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801310:	83 ec 08             	sub    $0x8,%esp
  801313:	53                   	push   %ebx
  801314:	6a 00                	push   $0x0
  801316:	e8 d2 fb ff ff       	call   800eed <sys_page_unmap>
	sys_page_unmap(0, nva);
  80131b:	83 c4 08             	add    $0x8,%esp
  80131e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801321:	6a 00                	push   $0x0
  801323:	e8 c5 fb ff ff       	call   800eed <sys_page_unmap>
	return r;
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	89 f8                	mov    %edi,%eax
}
  80132d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801330:	5b                   	pop    %ebx
  801331:	5e                   	pop    %esi
  801332:	5f                   	pop    %edi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	53                   	push   %ebx
  801339:	83 ec 14             	sub    $0x14,%esp
  80133c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801342:	50                   	push   %eax
  801343:	53                   	push   %ebx
  801344:	e8 86 fd ff ff       	call   8010cf <fd_lookup>
  801349:	83 c4 08             	add    $0x8,%esp
  80134c:	89 c2                	mov    %eax,%edx
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 6d                	js     8013bf <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801358:	50                   	push   %eax
  801359:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135c:	ff 30                	pushl  (%eax)
  80135e:	e8 c2 fd ff ff       	call   801125 <dev_lookup>
  801363:	83 c4 10             	add    $0x10,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	78 4c                	js     8013b6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80136a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80136d:	8b 42 08             	mov    0x8(%edx),%eax
  801370:	83 e0 03             	and    $0x3,%eax
  801373:	83 f8 01             	cmp    $0x1,%eax
  801376:	75 21                	jne    801399 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801378:	a1 04 44 80 00       	mov    0x804404,%eax
  80137d:	8b 40 48             	mov    0x48(%eax),%eax
  801380:	83 ec 04             	sub    $0x4,%esp
  801383:	53                   	push   %ebx
  801384:	50                   	push   %eax
  801385:	68 e0 24 80 00       	push   $0x8024e0
  80138a:	e8 5e f0 ff ff       	call   8003ed <cprintf>
		return -E_INVAL;
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801397:	eb 26                	jmp    8013bf <read+0x8a>
	}
	if (!dev->dev_read)
  801399:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139c:	8b 40 08             	mov    0x8(%eax),%eax
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	74 17                	je     8013ba <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013a3:	83 ec 04             	sub    $0x4,%esp
  8013a6:	ff 75 10             	pushl  0x10(%ebp)
  8013a9:	ff 75 0c             	pushl  0xc(%ebp)
  8013ac:	52                   	push   %edx
  8013ad:	ff d0                	call   *%eax
  8013af:	89 c2                	mov    %eax,%edx
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	eb 09                	jmp    8013bf <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b6:	89 c2                	mov    %eax,%edx
  8013b8:	eb 05                	jmp    8013bf <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8013bf:	89 d0                	mov    %edx,%eax
  8013c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c4:	c9                   	leave  
  8013c5:	c3                   	ret    

008013c6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	57                   	push   %edi
  8013ca:	56                   	push   %esi
  8013cb:	53                   	push   %ebx
  8013cc:	83 ec 0c             	sub    $0xc,%esp
  8013cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013da:	eb 21                	jmp    8013fd <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013dc:	83 ec 04             	sub    $0x4,%esp
  8013df:	89 f0                	mov    %esi,%eax
  8013e1:	29 d8                	sub    %ebx,%eax
  8013e3:	50                   	push   %eax
  8013e4:	89 d8                	mov    %ebx,%eax
  8013e6:	03 45 0c             	add    0xc(%ebp),%eax
  8013e9:	50                   	push   %eax
  8013ea:	57                   	push   %edi
  8013eb:	e8 45 ff ff ff       	call   801335 <read>
		if (m < 0)
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	78 10                	js     801407 <readn+0x41>
			return m;
		if (m == 0)
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	74 0a                	je     801405 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013fb:	01 c3                	add    %eax,%ebx
  8013fd:	39 f3                	cmp    %esi,%ebx
  8013ff:	72 db                	jb     8013dc <readn+0x16>
  801401:	89 d8                	mov    %ebx,%eax
  801403:	eb 02                	jmp    801407 <readn+0x41>
  801405:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801407:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140a:	5b                   	pop    %ebx
  80140b:	5e                   	pop    %esi
  80140c:	5f                   	pop    %edi
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    

0080140f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	53                   	push   %ebx
  801413:	83 ec 14             	sub    $0x14,%esp
  801416:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801419:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141c:	50                   	push   %eax
  80141d:	53                   	push   %ebx
  80141e:	e8 ac fc ff ff       	call   8010cf <fd_lookup>
  801423:	83 c4 08             	add    $0x8,%esp
  801426:	89 c2                	mov    %eax,%edx
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 68                	js     801494 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142c:	83 ec 08             	sub    $0x8,%esp
  80142f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801432:	50                   	push   %eax
  801433:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801436:	ff 30                	pushl  (%eax)
  801438:	e8 e8 fc ff ff       	call   801125 <dev_lookup>
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 47                	js     80148b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801444:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801447:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80144b:	75 21                	jne    80146e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80144d:	a1 04 44 80 00       	mov    0x804404,%eax
  801452:	8b 40 48             	mov    0x48(%eax),%eax
  801455:	83 ec 04             	sub    $0x4,%esp
  801458:	53                   	push   %ebx
  801459:	50                   	push   %eax
  80145a:	68 fc 24 80 00       	push   $0x8024fc
  80145f:	e8 89 ef ff ff       	call   8003ed <cprintf>
		return -E_INVAL;
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80146c:	eb 26                	jmp    801494 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80146e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801471:	8b 52 0c             	mov    0xc(%edx),%edx
  801474:	85 d2                	test   %edx,%edx
  801476:	74 17                	je     80148f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801478:	83 ec 04             	sub    $0x4,%esp
  80147b:	ff 75 10             	pushl  0x10(%ebp)
  80147e:	ff 75 0c             	pushl  0xc(%ebp)
  801481:	50                   	push   %eax
  801482:	ff d2                	call   *%edx
  801484:	89 c2                	mov    %eax,%edx
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	eb 09                	jmp    801494 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148b:	89 c2                	mov    %eax,%edx
  80148d:	eb 05                	jmp    801494 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80148f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801494:	89 d0                	mov    %edx,%eax
  801496:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801499:	c9                   	leave  
  80149a:	c3                   	ret    

0080149b <seek>:

int
seek(int fdnum, off_t offset)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014a4:	50                   	push   %eax
  8014a5:	ff 75 08             	pushl  0x8(%ebp)
  8014a8:	e8 22 fc ff ff       	call   8010cf <fd_lookup>
  8014ad:	83 c4 08             	add    $0x8,%esp
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 0e                	js     8014c2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ba:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c2:	c9                   	leave  
  8014c3:	c3                   	ret    

008014c4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	53                   	push   %ebx
  8014c8:	83 ec 14             	sub    $0x14,%esp
  8014cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d1:	50                   	push   %eax
  8014d2:	53                   	push   %ebx
  8014d3:	e8 f7 fb ff ff       	call   8010cf <fd_lookup>
  8014d8:	83 c4 08             	add    $0x8,%esp
  8014db:	89 c2                	mov    %eax,%edx
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 65                	js     801546 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e1:	83 ec 08             	sub    $0x8,%esp
  8014e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e7:	50                   	push   %eax
  8014e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014eb:	ff 30                	pushl  (%eax)
  8014ed:	e8 33 fc ff ff       	call   801125 <dev_lookup>
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	78 44                	js     80153d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801500:	75 21                	jne    801523 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801502:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801507:	8b 40 48             	mov    0x48(%eax),%eax
  80150a:	83 ec 04             	sub    $0x4,%esp
  80150d:	53                   	push   %ebx
  80150e:	50                   	push   %eax
  80150f:	68 bc 24 80 00       	push   $0x8024bc
  801514:	e8 d4 ee ff ff       	call   8003ed <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801521:	eb 23                	jmp    801546 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801523:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801526:	8b 52 18             	mov    0x18(%edx),%edx
  801529:	85 d2                	test   %edx,%edx
  80152b:	74 14                	je     801541 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80152d:	83 ec 08             	sub    $0x8,%esp
  801530:	ff 75 0c             	pushl  0xc(%ebp)
  801533:	50                   	push   %eax
  801534:	ff d2                	call   *%edx
  801536:	89 c2                	mov    %eax,%edx
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	eb 09                	jmp    801546 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153d:	89 c2                	mov    %eax,%edx
  80153f:	eb 05                	jmp    801546 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801541:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801546:	89 d0                	mov    %edx,%eax
  801548:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154b:	c9                   	leave  
  80154c:	c3                   	ret    

0080154d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	53                   	push   %ebx
  801551:	83 ec 14             	sub    $0x14,%esp
  801554:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801557:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155a:	50                   	push   %eax
  80155b:	ff 75 08             	pushl  0x8(%ebp)
  80155e:	e8 6c fb ff ff       	call   8010cf <fd_lookup>
  801563:	83 c4 08             	add    $0x8,%esp
  801566:	89 c2                	mov    %eax,%edx
  801568:	85 c0                	test   %eax,%eax
  80156a:	78 58                	js     8015c4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801572:	50                   	push   %eax
  801573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801576:	ff 30                	pushl  (%eax)
  801578:	e8 a8 fb ff ff       	call   801125 <dev_lookup>
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	85 c0                	test   %eax,%eax
  801582:	78 37                	js     8015bb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801584:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801587:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80158b:	74 32                	je     8015bf <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80158d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801590:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801597:	00 00 00 
	stat->st_isdir = 0;
  80159a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015a1:	00 00 00 
	stat->st_dev = dev;
  8015a4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	53                   	push   %ebx
  8015ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8015b1:	ff 50 14             	call   *0x14(%eax)
  8015b4:	89 c2                	mov    %eax,%edx
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	eb 09                	jmp    8015c4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bb:	89 c2                	mov    %eax,%edx
  8015bd:	eb 05                	jmp    8015c4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015bf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015c4:	89 d0                	mov    %edx,%eax
  8015c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c9:	c9                   	leave  
  8015ca:	c3                   	ret    

008015cb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	56                   	push   %esi
  8015cf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	6a 00                	push   $0x0
  8015d5:	ff 75 08             	pushl  0x8(%ebp)
  8015d8:	e8 e3 01 00 00       	call   8017c0 <open>
  8015dd:	89 c3                	mov    %eax,%ebx
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	78 1b                	js     801601 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ec:	50                   	push   %eax
  8015ed:	e8 5b ff ff ff       	call   80154d <fstat>
  8015f2:	89 c6                	mov    %eax,%esi
	close(fd);
  8015f4:	89 1c 24             	mov    %ebx,(%esp)
  8015f7:	e8 fd fb ff ff       	call   8011f9 <close>
	return r;
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	89 f0                	mov    %esi,%eax
}
  801601:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801604:	5b                   	pop    %ebx
  801605:	5e                   	pop    %esi
  801606:	5d                   	pop    %ebp
  801607:	c3                   	ret    

00801608 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	56                   	push   %esi
  80160c:	53                   	push   %ebx
  80160d:	89 c6                	mov    %eax,%esi
  80160f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801611:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  801618:	75 12                	jne    80162c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80161a:	83 ec 0c             	sub    $0xc,%esp
  80161d:	6a 01                	push   $0x1
  80161f:	e8 80 07 00 00       	call   801da4 <ipc_find_env>
  801624:	a3 00 44 80 00       	mov    %eax,0x804400
  801629:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80162c:	6a 07                	push   $0x7
  80162e:	68 00 50 80 00       	push   $0x805000
  801633:	56                   	push   %esi
  801634:	ff 35 00 44 80 00    	pushl  0x804400
  80163a:	e8 03 07 00 00       	call   801d42 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80163f:	83 c4 0c             	add    $0xc,%esp
  801642:	6a 00                	push   $0x0
  801644:	53                   	push   %ebx
  801645:	6a 00                	push   $0x0
  801647:	e8 84 06 00 00       	call   801cd0 <ipc_recv>
}
  80164c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164f:	5b                   	pop    %ebx
  801650:	5e                   	pop    %esi
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    

00801653 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801659:	8b 45 08             	mov    0x8(%ebp),%eax
  80165c:	8b 40 0c             	mov    0xc(%eax),%eax
  80165f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801664:	8b 45 0c             	mov    0xc(%ebp),%eax
  801667:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80166c:	ba 00 00 00 00       	mov    $0x0,%edx
  801671:	b8 02 00 00 00       	mov    $0x2,%eax
  801676:	e8 8d ff ff ff       	call   801608 <fsipc>
}
  80167b:	c9                   	leave  
  80167c:	c3                   	ret    

0080167d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801683:	8b 45 08             	mov    0x8(%ebp),%eax
  801686:	8b 40 0c             	mov    0xc(%eax),%eax
  801689:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80168e:	ba 00 00 00 00       	mov    $0x0,%edx
  801693:	b8 06 00 00 00       	mov    $0x6,%eax
  801698:	e8 6b ff ff ff       	call   801608 <fsipc>
}
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	53                   	push   %ebx
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8016af:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8016be:	e8 45 ff ff ff       	call   801608 <fsipc>
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	78 2c                	js     8016f3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016c7:	83 ec 08             	sub    $0x8,%esp
  8016ca:	68 00 50 80 00       	push   $0x805000
  8016cf:	53                   	push   %ebx
  8016d0:	e8 90 f3 ff ff       	call   800a65 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016d5:	a1 80 50 80 00       	mov    0x805080,%eax
  8016da:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016e0:	a1 84 50 80 00       	mov    0x805084,%eax
  8016e5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 0c             	sub    $0xc,%esp
  8016fe:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801701:	8b 55 08             	mov    0x8(%ebp),%edx
  801704:	8b 52 0c             	mov    0xc(%edx),%edx
  801707:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80170d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801712:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801717:	0f 47 c2             	cmova  %edx,%eax
  80171a:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80171f:	50                   	push   %eax
  801720:	ff 75 0c             	pushl  0xc(%ebp)
  801723:	68 08 50 80 00       	push   $0x805008
  801728:	e8 ca f4 ff ff       	call   800bf7 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80172d:	ba 00 00 00 00       	mov    $0x0,%edx
  801732:	b8 04 00 00 00       	mov    $0x4,%eax
  801737:	e8 cc fe ff ff       	call   801608 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	56                   	push   %esi
  801742:	53                   	push   %ebx
  801743:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801746:	8b 45 08             	mov    0x8(%ebp),%eax
  801749:	8b 40 0c             	mov    0xc(%eax),%eax
  80174c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801751:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801757:	ba 00 00 00 00       	mov    $0x0,%edx
  80175c:	b8 03 00 00 00       	mov    $0x3,%eax
  801761:	e8 a2 fe ff ff       	call   801608 <fsipc>
  801766:	89 c3                	mov    %eax,%ebx
  801768:	85 c0                	test   %eax,%eax
  80176a:	78 4b                	js     8017b7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80176c:	39 c6                	cmp    %eax,%esi
  80176e:	73 16                	jae    801786 <devfile_read+0x48>
  801770:	68 2c 25 80 00       	push   $0x80252c
  801775:	68 33 25 80 00       	push   $0x802533
  80177a:	6a 7c                	push   $0x7c
  80177c:	68 48 25 80 00       	push   $0x802548
  801781:	e8 8e eb ff ff       	call   800314 <_panic>
	assert(r <= PGSIZE);
  801786:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80178b:	7e 16                	jle    8017a3 <devfile_read+0x65>
  80178d:	68 53 25 80 00       	push   $0x802553
  801792:	68 33 25 80 00       	push   $0x802533
  801797:	6a 7d                	push   $0x7d
  801799:	68 48 25 80 00       	push   $0x802548
  80179e:	e8 71 eb ff ff       	call   800314 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017a3:	83 ec 04             	sub    $0x4,%esp
  8017a6:	50                   	push   %eax
  8017a7:	68 00 50 80 00       	push   $0x805000
  8017ac:	ff 75 0c             	pushl  0xc(%ebp)
  8017af:	e8 43 f4 ff ff       	call   800bf7 <memmove>
	return r;
  8017b4:	83 c4 10             	add    $0x10,%esp
}
  8017b7:	89 d8                	mov    %ebx,%eax
  8017b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017bc:	5b                   	pop    %ebx
  8017bd:	5e                   	pop    %esi
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    

008017c0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	53                   	push   %ebx
  8017c4:	83 ec 20             	sub    $0x20,%esp
  8017c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017ca:	53                   	push   %ebx
  8017cb:	e8 5c f2 ff ff       	call   800a2c <strlen>
  8017d0:	83 c4 10             	add    $0x10,%esp
  8017d3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017d8:	7f 67                	jg     801841 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017da:	83 ec 0c             	sub    $0xc,%esp
  8017dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e0:	50                   	push   %eax
  8017e1:	e8 9a f8 ff ff       	call   801080 <fd_alloc>
  8017e6:	83 c4 10             	add    $0x10,%esp
		return r;
  8017e9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 57                	js     801846 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017ef:	83 ec 08             	sub    $0x8,%esp
  8017f2:	53                   	push   %ebx
  8017f3:	68 00 50 80 00       	push   $0x805000
  8017f8:	e8 68 f2 ff ff       	call   800a65 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801800:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801805:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801808:	b8 01 00 00 00       	mov    $0x1,%eax
  80180d:	e8 f6 fd ff ff       	call   801608 <fsipc>
  801812:	89 c3                	mov    %eax,%ebx
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	85 c0                	test   %eax,%eax
  801819:	79 14                	jns    80182f <open+0x6f>
		fd_close(fd, 0);
  80181b:	83 ec 08             	sub    $0x8,%esp
  80181e:	6a 00                	push   $0x0
  801820:	ff 75 f4             	pushl  -0xc(%ebp)
  801823:	e8 50 f9 ff ff       	call   801178 <fd_close>
		return r;
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	89 da                	mov    %ebx,%edx
  80182d:	eb 17                	jmp    801846 <open+0x86>
	}

	return fd2num(fd);
  80182f:	83 ec 0c             	sub    $0xc,%esp
  801832:	ff 75 f4             	pushl  -0xc(%ebp)
  801835:	e8 1f f8 ff ff       	call   801059 <fd2num>
  80183a:	89 c2                	mov    %eax,%edx
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	eb 05                	jmp    801846 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801841:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801846:	89 d0                	mov    %edx,%eax
  801848:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    

0080184d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801853:	ba 00 00 00 00       	mov    $0x0,%edx
  801858:	b8 08 00 00 00       	mov    $0x8,%eax
  80185d:	e8 a6 fd ff ff       	call   801608 <fsipc>
}
  801862:	c9                   	leave  
  801863:	c3                   	ret    

00801864 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801864:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801868:	7e 37                	jle    8018a1 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	53                   	push   %ebx
  80186e:	83 ec 08             	sub    $0x8,%esp
  801871:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801873:	ff 70 04             	pushl  0x4(%eax)
  801876:	8d 40 10             	lea    0x10(%eax),%eax
  801879:	50                   	push   %eax
  80187a:	ff 33                	pushl  (%ebx)
  80187c:	e8 8e fb ff ff       	call   80140f <write>
		if (result > 0)
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	85 c0                	test   %eax,%eax
  801886:	7e 03                	jle    80188b <writebuf+0x27>
			b->result += result;
  801888:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80188b:	3b 43 04             	cmp    0x4(%ebx),%eax
  80188e:	74 0d                	je     80189d <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801890:	85 c0                	test   %eax,%eax
  801892:	ba 00 00 00 00       	mov    $0x0,%edx
  801897:	0f 4f c2             	cmovg  %edx,%eax
  80189a:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80189d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a0:	c9                   	leave  
  8018a1:	f3 c3                	repz ret 

008018a3 <putch>:

static void
putch(int ch, void *thunk)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	53                   	push   %ebx
  8018a7:	83 ec 04             	sub    $0x4,%esp
  8018aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018ad:	8b 53 04             	mov    0x4(%ebx),%edx
  8018b0:	8d 42 01             	lea    0x1(%edx),%eax
  8018b3:	89 43 04             	mov    %eax,0x4(%ebx)
  8018b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018b9:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8018bd:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018c2:	75 0e                	jne    8018d2 <putch+0x2f>
		writebuf(b);
  8018c4:	89 d8                	mov    %ebx,%eax
  8018c6:	e8 99 ff ff ff       	call   801864 <writebuf>
		b->idx = 0;
  8018cb:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8018d2:	83 c4 04             	add    $0x4,%esp
  8018d5:	5b                   	pop    %ebx
  8018d6:	5d                   	pop    %ebp
  8018d7:	c3                   	ret    

008018d8 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8018e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e4:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018ea:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018f1:	00 00 00 
	b.result = 0;
  8018f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018fb:	00 00 00 
	b.error = 1;
  8018fe:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801905:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801908:	ff 75 10             	pushl  0x10(%ebp)
  80190b:	ff 75 0c             	pushl  0xc(%ebp)
  80190e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801914:	50                   	push   %eax
  801915:	68 a3 18 80 00       	push   $0x8018a3
  80191a:	e8 05 ec ff ff       	call   800524 <vprintfmt>
	if (b.idx > 0)
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801929:	7e 0b                	jle    801936 <vfprintf+0x5e>
		writebuf(&b);
  80192b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801931:	e8 2e ff ff ff       	call   801864 <writebuf>

	return (b.result ? b.result : b.error);
  801936:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80193c:	85 c0                	test   %eax,%eax
  80193e:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801945:	c9                   	leave  
  801946:	c3                   	ret    

00801947 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80194d:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801950:	50                   	push   %eax
  801951:	ff 75 0c             	pushl  0xc(%ebp)
  801954:	ff 75 08             	pushl  0x8(%ebp)
  801957:	e8 7c ff ff ff       	call   8018d8 <vfprintf>
	va_end(ap);

	return cnt;
}
  80195c:	c9                   	leave  
  80195d:	c3                   	ret    

0080195e <printf>:

int
printf(const char *fmt, ...)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801964:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801967:	50                   	push   %eax
  801968:	ff 75 08             	pushl  0x8(%ebp)
  80196b:	6a 01                	push   $0x1
  80196d:	e8 66 ff ff ff       	call   8018d8 <vfprintf>
	va_end(ap);

	return cnt;
}
  801972:	c9                   	leave  
  801973:	c3                   	ret    

00801974 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	56                   	push   %esi
  801978:	53                   	push   %ebx
  801979:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80197c:	83 ec 0c             	sub    $0xc,%esp
  80197f:	ff 75 08             	pushl  0x8(%ebp)
  801982:	e8 e2 f6 ff ff       	call   801069 <fd2data>
  801987:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801989:	83 c4 08             	add    $0x8,%esp
  80198c:	68 5f 25 80 00       	push   $0x80255f
  801991:	53                   	push   %ebx
  801992:	e8 ce f0 ff ff       	call   800a65 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801997:	8b 46 04             	mov    0x4(%esi),%eax
  80199a:	2b 06                	sub    (%esi),%eax
  80199c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019a2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019a9:	00 00 00 
	stat->st_dev = &devpipe;
  8019ac:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019b3:	30 80 00 
	return 0;
}
  8019b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019be:	5b                   	pop    %ebx
  8019bf:	5e                   	pop    %esi
  8019c0:	5d                   	pop    %ebp
  8019c1:	c3                   	ret    

008019c2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	53                   	push   %ebx
  8019c6:	83 ec 0c             	sub    $0xc,%esp
  8019c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019cc:	53                   	push   %ebx
  8019cd:	6a 00                	push   $0x0
  8019cf:	e8 19 f5 ff ff       	call   800eed <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019d4:	89 1c 24             	mov    %ebx,(%esp)
  8019d7:	e8 8d f6 ff ff       	call   801069 <fd2data>
  8019dc:	83 c4 08             	add    $0x8,%esp
  8019df:	50                   	push   %eax
  8019e0:	6a 00                	push   $0x0
  8019e2:	e8 06 f5 ff ff       	call   800eed <sys_page_unmap>
}
  8019e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ea:	c9                   	leave  
  8019eb:	c3                   	ret    

008019ec <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	57                   	push   %edi
  8019f0:	56                   	push   %esi
  8019f1:	53                   	push   %ebx
  8019f2:	83 ec 1c             	sub    $0x1c,%esp
  8019f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019f8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019fa:	a1 04 44 80 00       	mov    0x804404,%eax
  8019ff:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a02:	83 ec 0c             	sub    $0xc,%esp
  801a05:	ff 75 e0             	pushl  -0x20(%ebp)
  801a08:	e8 d0 03 00 00       	call   801ddd <pageref>
  801a0d:	89 c3                	mov    %eax,%ebx
  801a0f:	89 3c 24             	mov    %edi,(%esp)
  801a12:	e8 c6 03 00 00       	call   801ddd <pageref>
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	39 c3                	cmp    %eax,%ebx
  801a1c:	0f 94 c1             	sete   %cl
  801a1f:	0f b6 c9             	movzbl %cl,%ecx
  801a22:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a25:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801a2b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a2e:	39 ce                	cmp    %ecx,%esi
  801a30:	74 1b                	je     801a4d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a32:	39 c3                	cmp    %eax,%ebx
  801a34:	75 c4                	jne    8019fa <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a36:	8b 42 58             	mov    0x58(%edx),%eax
  801a39:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a3c:	50                   	push   %eax
  801a3d:	56                   	push   %esi
  801a3e:	68 66 25 80 00       	push   $0x802566
  801a43:	e8 a5 e9 ff ff       	call   8003ed <cprintf>
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	eb ad                	jmp    8019fa <_pipeisclosed+0xe>
	}
}
  801a4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a53:	5b                   	pop    %ebx
  801a54:	5e                   	pop    %esi
  801a55:	5f                   	pop    %edi
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    

00801a58 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	57                   	push   %edi
  801a5c:	56                   	push   %esi
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 28             	sub    $0x28,%esp
  801a61:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a64:	56                   	push   %esi
  801a65:	e8 ff f5 ff ff       	call   801069 <fd2data>
  801a6a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	bf 00 00 00 00       	mov    $0x0,%edi
  801a74:	eb 4b                	jmp    801ac1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a76:	89 da                	mov    %ebx,%edx
  801a78:	89 f0                	mov    %esi,%eax
  801a7a:	e8 6d ff ff ff       	call   8019ec <_pipeisclosed>
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	75 48                	jne    801acb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a83:	e8 c1 f3 ff ff       	call   800e49 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a88:	8b 43 04             	mov    0x4(%ebx),%eax
  801a8b:	8b 0b                	mov    (%ebx),%ecx
  801a8d:	8d 51 20             	lea    0x20(%ecx),%edx
  801a90:	39 d0                	cmp    %edx,%eax
  801a92:	73 e2                	jae    801a76 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a97:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a9b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a9e:	89 c2                	mov    %eax,%edx
  801aa0:	c1 fa 1f             	sar    $0x1f,%edx
  801aa3:	89 d1                	mov    %edx,%ecx
  801aa5:	c1 e9 1b             	shr    $0x1b,%ecx
  801aa8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aab:	83 e2 1f             	and    $0x1f,%edx
  801aae:	29 ca                	sub    %ecx,%edx
  801ab0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ab4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ab8:	83 c0 01             	add    $0x1,%eax
  801abb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801abe:	83 c7 01             	add    $0x1,%edi
  801ac1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ac4:	75 c2                	jne    801a88 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ac6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac9:	eb 05                	jmp    801ad0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801acb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ad0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad3:	5b                   	pop    %ebx
  801ad4:	5e                   	pop    %esi
  801ad5:	5f                   	pop    %edi
  801ad6:	5d                   	pop    %ebp
  801ad7:	c3                   	ret    

00801ad8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	57                   	push   %edi
  801adc:	56                   	push   %esi
  801add:	53                   	push   %ebx
  801ade:	83 ec 18             	sub    $0x18,%esp
  801ae1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ae4:	57                   	push   %edi
  801ae5:	e8 7f f5 ff ff       	call   801069 <fd2data>
  801aea:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	bb 00 00 00 00       	mov    $0x0,%ebx
  801af4:	eb 3d                	jmp    801b33 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801af6:	85 db                	test   %ebx,%ebx
  801af8:	74 04                	je     801afe <devpipe_read+0x26>
				return i;
  801afa:	89 d8                	mov    %ebx,%eax
  801afc:	eb 44                	jmp    801b42 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801afe:	89 f2                	mov    %esi,%edx
  801b00:	89 f8                	mov    %edi,%eax
  801b02:	e8 e5 fe ff ff       	call   8019ec <_pipeisclosed>
  801b07:	85 c0                	test   %eax,%eax
  801b09:	75 32                	jne    801b3d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b0b:	e8 39 f3 ff ff       	call   800e49 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b10:	8b 06                	mov    (%esi),%eax
  801b12:	3b 46 04             	cmp    0x4(%esi),%eax
  801b15:	74 df                	je     801af6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b17:	99                   	cltd   
  801b18:	c1 ea 1b             	shr    $0x1b,%edx
  801b1b:	01 d0                	add    %edx,%eax
  801b1d:	83 e0 1f             	and    $0x1f,%eax
  801b20:	29 d0                	sub    %edx,%eax
  801b22:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b2a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b2d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b30:	83 c3 01             	add    $0x1,%ebx
  801b33:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b36:	75 d8                	jne    801b10 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b38:	8b 45 10             	mov    0x10(%ebp),%eax
  801b3b:	eb 05                	jmp    801b42 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b3d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b45:	5b                   	pop    %ebx
  801b46:	5e                   	pop    %esi
  801b47:	5f                   	pop    %edi
  801b48:	5d                   	pop    %ebp
  801b49:	c3                   	ret    

00801b4a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	56                   	push   %esi
  801b4e:	53                   	push   %ebx
  801b4f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b55:	50                   	push   %eax
  801b56:	e8 25 f5 ff ff       	call   801080 <fd_alloc>
  801b5b:	83 c4 10             	add    $0x10,%esp
  801b5e:	89 c2                	mov    %eax,%edx
  801b60:	85 c0                	test   %eax,%eax
  801b62:	0f 88 2c 01 00 00    	js     801c94 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b68:	83 ec 04             	sub    $0x4,%esp
  801b6b:	68 07 04 00 00       	push   $0x407
  801b70:	ff 75 f4             	pushl  -0xc(%ebp)
  801b73:	6a 00                	push   $0x0
  801b75:	e8 ee f2 ff ff       	call   800e68 <sys_page_alloc>
  801b7a:	83 c4 10             	add    $0x10,%esp
  801b7d:	89 c2                	mov    %eax,%edx
  801b7f:	85 c0                	test   %eax,%eax
  801b81:	0f 88 0d 01 00 00    	js     801c94 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b87:	83 ec 0c             	sub    $0xc,%esp
  801b8a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b8d:	50                   	push   %eax
  801b8e:	e8 ed f4 ff ff       	call   801080 <fd_alloc>
  801b93:	89 c3                	mov    %eax,%ebx
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	0f 88 e2 00 00 00    	js     801c82 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba0:	83 ec 04             	sub    $0x4,%esp
  801ba3:	68 07 04 00 00       	push   $0x407
  801ba8:	ff 75 f0             	pushl  -0x10(%ebp)
  801bab:	6a 00                	push   $0x0
  801bad:	e8 b6 f2 ff ff       	call   800e68 <sys_page_alloc>
  801bb2:	89 c3                	mov    %eax,%ebx
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	0f 88 c3 00 00 00    	js     801c82 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bbf:	83 ec 0c             	sub    $0xc,%esp
  801bc2:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc5:	e8 9f f4 ff ff       	call   801069 <fd2data>
  801bca:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bcc:	83 c4 0c             	add    $0xc,%esp
  801bcf:	68 07 04 00 00       	push   $0x407
  801bd4:	50                   	push   %eax
  801bd5:	6a 00                	push   $0x0
  801bd7:	e8 8c f2 ff ff       	call   800e68 <sys_page_alloc>
  801bdc:	89 c3                	mov    %eax,%ebx
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	85 c0                	test   %eax,%eax
  801be3:	0f 88 89 00 00 00    	js     801c72 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be9:	83 ec 0c             	sub    $0xc,%esp
  801bec:	ff 75 f0             	pushl  -0x10(%ebp)
  801bef:	e8 75 f4 ff ff       	call   801069 <fd2data>
  801bf4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bfb:	50                   	push   %eax
  801bfc:	6a 00                	push   $0x0
  801bfe:	56                   	push   %esi
  801bff:	6a 00                	push   $0x0
  801c01:	e8 a5 f2 ff ff       	call   800eab <sys_page_map>
  801c06:	89 c3                	mov    %eax,%ebx
  801c08:	83 c4 20             	add    $0x20,%esp
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	78 55                	js     801c64 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c0f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c18:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c24:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c2d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c32:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c39:	83 ec 0c             	sub    $0xc,%esp
  801c3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3f:	e8 15 f4 ff ff       	call   801059 <fd2num>
  801c44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c47:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c49:	83 c4 04             	add    $0x4,%esp
  801c4c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c4f:	e8 05 f4 ff ff       	call   801059 <fd2num>
  801c54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c57:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c62:	eb 30                	jmp    801c94 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c64:	83 ec 08             	sub    $0x8,%esp
  801c67:	56                   	push   %esi
  801c68:	6a 00                	push   $0x0
  801c6a:	e8 7e f2 ff ff       	call   800eed <sys_page_unmap>
  801c6f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c72:	83 ec 08             	sub    $0x8,%esp
  801c75:	ff 75 f0             	pushl  -0x10(%ebp)
  801c78:	6a 00                	push   $0x0
  801c7a:	e8 6e f2 ff ff       	call   800eed <sys_page_unmap>
  801c7f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c82:	83 ec 08             	sub    $0x8,%esp
  801c85:	ff 75 f4             	pushl  -0xc(%ebp)
  801c88:	6a 00                	push   $0x0
  801c8a:	e8 5e f2 ff ff       	call   800eed <sys_page_unmap>
  801c8f:	83 c4 10             	add    $0x10,%esp
  801c92:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c94:	89 d0                	mov    %edx,%eax
  801c96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c99:	5b                   	pop    %ebx
  801c9a:	5e                   	pop    %esi
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    

00801c9d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ca3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca6:	50                   	push   %eax
  801ca7:	ff 75 08             	pushl  0x8(%ebp)
  801caa:	e8 20 f4 ff ff       	call   8010cf <fd_lookup>
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	78 18                	js     801cce <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cb6:	83 ec 0c             	sub    $0xc,%esp
  801cb9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbc:	e8 a8 f3 ff ff       	call   801069 <fd2data>
	return _pipeisclosed(fd, p);
  801cc1:	89 c2                	mov    %eax,%edx
  801cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc6:	e8 21 fd ff ff       	call   8019ec <_pipeisclosed>
  801ccb:	83 c4 10             	add    $0x10,%esp
}
  801cce:	c9                   	leave  
  801ccf:	c3                   	ret    

00801cd0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	56                   	push   %esi
  801cd4:	53                   	push   %ebx
  801cd5:	8b 75 08             	mov    0x8(%ebp),%esi
  801cd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	75 12                	jne    801cf4 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801ce2:	83 ec 0c             	sub    $0xc,%esp
  801ce5:	68 00 00 c0 ee       	push   $0xeec00000
  801cea:	e8 29 f3 ff ff       	call   801018 <sys_ipc_recv>
  801cef:	83 c4 10             	add    $0x10,%esp
  801cf2:	eb 0c                	jmp    801d00 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801cf4:	83 ec 0c             	sub    $0xc,%esp
  801cf7:	50                   	push   %eax
  801cf8:	e8 1b f3 ff ff       	call   801018 <sys_ipc_recv>
  801cfd:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801d00:	85 f6                	test   %esi,%esi
  801d02:	0f 95 c1             	setne  %cl
  801d05:	85 db                	test   %ebx,%ebx
  801d07:	0f 95 c2             	setne  %dl
  801d0a:	84 d1                	test   %dl,%cl
  801d0c:	74 09                	je     801d17 <ipc_recv+0x47>
  801d0e:	89 c2                	mov    %eax,%edx
  801d10:	c1 ea 1f             	shr    $0x1f,%edx
  801d13:	84 d2                	test   %dl,%dl
  801d15:	75 24                	jne    801d3b <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801d17:	85 f6                	test   %esi,%esi
  801d19:	74 0a                	je     801d25 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801d1b:	a1 04 44 80 00       	mov    0x804404,%eax
  801d20:	8b 40 74             	mov    0x74(%eax),%eax
  801d23:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801d25:	85 db                	test   %ebx,%ebx
  801d27:	74 0a                	je     801d33 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801d29:	a1 04 44 80 00       	mov    0x804404,%eax
  801d2e:	8b 40 78             	mov    0x78(%eax),%eax
  801d31:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801d33:	a1 04 44 80 00       	mov    0x804404,%eax
  801d38:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d3e:	5b                   	pop    %ebx
  801d3f:	5e                   	pop    %esi
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    

00801d42 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	57                   	push   %edi
  801d46:	56                   	push   %esi
  801d47:	53                   	push   %ebx
  801d48:	83 ec 0c             	sub    $0xc,%esp
  801d4b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801d54:	85 db                	test   %ebx,%ebx
  801d56:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801d5b:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801d5e:	ff 75 14             	pushl  0x14(%ebp)
  801d61:	53                   	push   %ebx
  801d62:	56                   	push   %esi
  801d63:	57                   	push   %edi
  801d64:	e8 8c f2 ff ff       	call   800ff5 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801d69:	89 c2                	mov    %eax,%edx
  801d6b:	c1 ea 1f             	shr    $0x1f,%edx
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	84 d2                	test   %dl,%dl
  801d73:	74 17                	je     801d8c <ipc_send+0x4a>
  801d75:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d78:	74 12                	je     801d8c <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801d7a:	50                   	push   %eax
  801d7b:	68 7e 25 80 00       	push   $0x80257e
  801d80:	6a 47                	push   $0x47
  801d82:	68 8c 25 80 00       	push   $0x80258c
  801d87:	e8 88 e5 ff ff       	call   800314 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801d8c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d8f:	75 07                	jne    801d98 <ipc_send+0x56>
			sys_yield();
  801d91:	e8 b3 f0 ff ff       	call   800e49 <sys_yield>
  801d96:	eb c6                	jmp    801d5e <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	75 c2                	jne    801d5e <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801d9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9f:	5b                   	pop    %ebx
  801da0:	5e                   	pop    %esi
  801da1:	5f                   	pop    %edi
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    

00801da4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801daa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801daf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801db2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801db8:	8b 52 50             	mov    0x50(%edx),%edx
  801dbb:	39 ca                	cmp    %ecx,%edx
  801dbd:	75 0d                	jne    801dcc <ipc_find_env+0x28>
			return envs[i].env_id;
  801dbf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801dc2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801dc7:	8b 40 48             	mov    0x48(%eax),%eax
  801dca:	eb 0f                	jmp    801ddb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801dcc:	83 c0 01             	add    $0x1,%eax
  801dcf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dd4:	75 d9                	jne    801daf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801dd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ddb:	5d                   	pop    %ebp
  801ddc:	c3                   	ret    

00801ddd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ddd:	55                   	push   %ebp
  801dde:	89 e5                	mov    %esp,%ebp
  801de0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801de3:	89 d0                	mov    %edx,%eax
  801de5:	c1 e8 16             	shr    $0x16,%eax
  801de8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801def:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801df4:	f6 c1 01             	test   $0x1,%cl
  801df7:	74 1d                	je     801e16 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801df9:	c1 ea 0c             	shr    $0xc,%edx
  801dfc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e03:	f6 c2 01             	test   $0x1,%dl
  801e06:	74 0e                	je     801e16 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e08:	c1 ea 0c             	shr    $0xc,%edx
  801e0b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e12:	ef 
  801e13:	0f b7 c0             	movzwl %ax,%eax
}
  801e16:	5d                   	pop    %ebp
  801e17:	c3                   	ret    
  801e18:	66 90                	xchg   %ax,%ax
  801e1a:	66 90                	xchg   %ax,%ax
  801e1c:	66 90                	xchg   %ax,%ax
  801e1e:	66 90                	xchg   %ax,%ax

00801e20 <__udivdi3>:
  801e20:	55                   	push   %ebp
  801e21:	57                   	push   %edi
  801e22:	56                   	push   %esi
  801e23:	53                   	push   %ebx
  801e24:	83 ec 1c             	sub    $0x1c,%esp
  801e27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e37:	85 f6                	test   %esi,%esi
  801e39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e3d:	89 ca                	mov    %ecx,%edx
  801e3f:	89 f8                	mov    %edi,%eax
  801e41:	75 3d                	jne    801e80 <__udivdi3+0x60>
  801e43:	39 cf                	cmp    %ecx,%edi
  801e45:	0f 87 c5 00 00 00    	ja     801f10 <__udivdi3+0xf0>
  801e4b:	85 ff                	test   %edi,%edi
  801e4d:	89 fd                	mov    %edi,%ebp
  801e4f:	75 0b                	jne    801e5c <__udivdi3+0x3c>
  801e51:	b8 01 00 00 00       	mov    $0x1,%eax
  801e56:	31 d2                	xor    %edx,%edx
  801e58:	f7 f7                	div    %edi
  801e5a:	89 c5                	mov    %eax,%ebp
  801e5c:	89 c8                	mov    %ecx,%eax
  801e5e:	31 d2                	xor    %edx,%edx
  801e60:	f7 f5                	div    %ebp
  801e62:	89 c1                	mov    %eax,%ecx
  801e64:	89 d8                	mov    %ebx,%eax
  801e66:	89 cf                	mov    %ecx,%edi
  801e68:	f7 f5                	div    %ebp
  801e6a:	89 c3                	mov    %eax,%ebx
  801e6c:	89 d8                	mov    %ebx,%eax
  801e6e:	89 fa                	mov    %edi,%edx
  801e70:	83 c4 1c             	add    $0x1c,%esp
  801e73:	5b                   	pop    %ebx
  801e74:	5e                   	pop    %esi
  801e75:	5f                   	pop    %edi
  801e76:	5d                   	pop    %ebp
  801e77:	c3                   	ret    
  801e78:	90                   	nop
  801e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e80:	39 ce                	cmp    %ecx,%esi
  801e82:	77 74                	ja     801ef8 <__udivdi3+0xd8>
  801e84:	0f bd fe             	bsr    %esi,%edi
  801e87:	83 f7 1f             	xor    $0x1f,%edi
  801e8a:	0f 84 98 00 00 00    	je     801f28 <__udivdi3+0x108>
  801e90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801e95:	89 f9                	mov    %edi,%ecx
  801e97:	89 c5                	mov    %eax,%ebp
  801e99:	29 fb                	sub    %edi,%ebx
  801e9b:	d3 e6                	shl    %cl,%esi
  801e9d:	89 d9                	mov    %ebx,%ecx
  801e9f:	d3 ed                	shr    %cl,%ebp
  801ea1:	89 f9                	mov    %edi,%ecx
  801ea3:	d3 e0                	shl    %cl,%eax
  801ea5:	09 ee                	or     %ebp,%esi
  801ea7:	89 d9                	mov    %ebx,%ecx
  801ea9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ead:	89 d5                	mov    %edx,%ebp
  801eaf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801eb3:	d3 ed                	shr    %cl,%ebp
  801eb5:	89 f9                	mov    %edi,%ecx
  801eb7:	d3 e2                	shl    %cl,%edx
  801eb9:	89 d9                	mov    %ebx,%ecx
  801ebb:	d3 e8                	shr    %cl,%eax
  801ebd:	09 c2                	or     %eax,%edx
  801ebf:	89 d0                	mov    %edx,%eax
  801ec1:	89 ea                	mov    %ebp,%edx
  801ec3:	f7 f6                	div    %esi
  801ec5:	89 d5                	mov    %edx,%ebp
  801ec7:	89 c3                	mov    %eax,%ebx
  801ec9:	f7 64 24 0c          	mull   0xc(%esp)
  801ecd:	39 d5                	cmp    %edx,%ebp
  801ecf:	72 10                	jb     801ee1 <__udivdi3+0xc1>
  801ed1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ed5:	89 f9                	mov    %edi,%ecx
  801ed7:	d3 e6                	shl    %cl,%esi
  801ed9:	39 c6                	cmp    %eax,%esi
  801edb:	73 07                	jae    801ee4 <__udivdi3+0xc4>
  801edd:	39 d5                	cmp    %edx,%ebp
  801edf:	75 03                	jne    801ee4 <__udivdi3+0xc4>
  801ee1:	83 eb 01             	sub    $0x1,%ebx
  801ee4:	31 ff                	xor    %edi,%edi
  801ee6:	89 d8                	mov    %ebx,%eax
  801ee8:	89 fa                	mov    %edi,%edx
  801eea:	83 c4 1c             	add    $0x1c,%esp
  801eed:	5b                   	pop    %ebx
  801eee:	5e                   	pop    %esi
  801eef:	5f                   	pop    %edi
  801ef0:	5d                   	pop    %ebp
  801ef1:	c3                   	ret    
  801ef2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ef8:	31 ff                	xor    %edi,%edi
  801efa:	31 db                	xor    %ebx,%ebx
  801efc:	89 d8                	mov    %ebx,%eax
  801efe:	89 fa                	mov    %edi,%edx
  801f00:	83 c4 1c             	add    $0x1c,%esp
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5f                   	pop    %edi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    
  801f08:	90                   	nop
  801f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f10:	89 d8                	mov    %ebx,%eax
  801f12:	f7 f7                	div    %edi
  801f14:	31 ff                	xor    %edi,%edi
  801f16:	89 c3                	mov    %eax,%ebx
  801f18:	89 d8                	mov    %ebx,%eax
  801f1a:	89 fa                	mov    %edi,%edx
  801f1c:	83 c4 1c             	add    $0x1c,%esp
  801f1f:	5b                   	pop    %ebx
  801f20:	5e                   	pop    %esi
  801f21:	5f                   	pop    %edi
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    
  801f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f28:	39 ce                	cmp    %ecx,%esi
  801f2a:	72 0c                	jb     801f38 <__udivdi3+0x118>
  801f2c:	31 db                	xor    %ebx,%ebx
  801f2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f32:	0f 87 34 ff ff ff    	ja     801e6c <__udivdi3+0x4c>
  801f38:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f3d:	e9 2a ff ff ff       	jmp    801e6c <__udivdi3+0x4c>
  801f42:	66 90                	xchg   %ax,%ax
  801f44:	66 90                	xchg   %ax,%ax
  801f46:	66 90                	xchg   %ax,%ax
  801f48:	66 90                	xchg   %ax,%ax
  801f4a:	66 90                	xchg   %ax,%ax
  801f4c:	66 90                	xchg   %ax,%ax
  801f4e:	66 90                	xchg   %ax,%ax

00801f50 <__umoddi3>:
  801f50:	55                   	push   %ebp
  801f51:	57                   	push   %edi
  801f52:	56                   	push   %esi
  801f53:	53                   	push   %ebx
  801f54:	83 ec 1c             	sub    $0x1c,%esp
  801f57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f67:	85 d2                	test   %edx,%edx
  801f69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f71:	89 f3                	mov    %esi,%ebx
  801f73:	89 3c 24             	mov    %edi,(%esp)
  801f76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f7a:	75 1c                	jne    801f98 <__umoddi3+0x48>
  801f7c:	39 f7                	cmp    %esi,%edi
  801f7e:	76 50                	jbe    801fd0 <__umoddi3+0x80>
  801f80:	89 c8                	mov    %ecx,%eax
  801f82:	89 f2                	mov    %esi,%edx
  801f84:	f7 f7                	div    %edi
  801f86:	89 d0                	mov    %edx,%eax
  801f88:	31 d2                	xor    %edx,%edx
  801f8a:	83 c4 1c             	add    $0x1c,%esp
  801f8d:	5b                   	pop    %ebx
  801f8e:	5e                   	pop    %esi
  801f8f:	5f                   	pop    %edi
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    
  801f92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f98:	39 f2                	cmp    %esi,%edx
  801f9a:	89 d0                	mov    %edx,%eax
  801f9c:	77 52                	ja     801ff0 <__umoddi3+0xa0>
  801f9e:	0f bd ea             	bsr    %edx,%ebp
  801fa1:	83 f5 1f             	xor    $0x1f,%ebp
  801fa4:	75 5a                	jne    802000 <__umoddi3+0xb0>
  801fa6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801faa:	0f 82 e0 00 00 00    	jb     802090 <__umoddi3+0x140>
  801fb0:	39 0c 24             	cmp    %ecx,(%esp)
  801fb3:	0f 86 d7 00 00 00    	jbe    802090 <__umoddi3+0x140>
  801fb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fbd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801fc1:	83 c4 1c             	add    $0x1c,%esp
  801fc4:	5b                   	pop    %ebx
  801fc5:	5e                   	pop    %esi
  801fc6:	5f                   	pop    %edi
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	85 ff                	test   %edi,%edi
  801fd2:	89 fd                	mov    %edi,%ebp
  801fd4:	75 0b                	jne    801fe1 <__umoddi3+0x91>
  801fd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fdb:	31 d2                	xor    %edx,%edx
  801fdd:	f7 f7                	div    %edi
  801fdf:	89 c5                	mov    %eax,%ebp
  801fe1:	89 f0                	mov    %esi,%eax
  801fe3:	31 d2                	xor    %edx,%edx
  801fe5:	f7 f5                	div    %ebp
  801fe7:	89 c8                	mov    %ecx,%eax
  801fe9:	f7 f5                	div    %ebp
  801feb:	89 d0                	mov    %edx,%eax
  801fed:	eb 99                	jmp    801f88 <__umoddi3+0x38>
  801fef:	90                   	nop
  801ff0:	89 c8                	mov    %ecx,%eax
  801ff2:	89 f2                	mov    %esi,%edx
  801ff4:	83 c4 1c             	add    $0x1c,%esp
  801ff7:	5b                   	pop    %ebx
  801ff8:	5e                   	pop    %esi
  801ff9:	5f                   	pop    %edi
  801ffa:	5d                   	pop    %ebp
  801ffb:	c3                   	ret    
  801ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802000:	8b 34 24             	mov    (%esp),%esi
  802003:	bf 20 00 00 00       	mov    $0x20,%edi
  802008:	89 e9                	mov    %ebp,%ecx
  80200a:	29 ef                	sub    %ebp,%edi
  80200c:	d3 e0                	shl    %cl,%eax
  80200e:	89 f9                	mov    %edi,%ecx
  802010:	89 f2                	mov    %esi,%edx
  802012:	d3 ea                	shr    %cl,%edx
  802014:	89 e9                	mov    %ebp,%ecx
  802016:	09 c2                	or     %eax,%edx
  802018:	89 d8                	mov    %ebx,%eax
  80201a:	89 14 24             	mov    %edx,(%esp)
  80201d:	89 f2                	mov    %esi,%edx
  80201f:	d3 e2                	shl    %cl,%edx
  802021:	89 f9                	mov    %edi,%ecx
  802023:	89 54 24 04          	mov    %edx,0x4(%esp)
  802027:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80202b:	d3 e8                	shr    %cl,%eax
  80202d:	89 e9                	mov    %ebp,%ecx
  80202f:	89 c6                	mov    %eax,%esi
  802031:	d3 e3                	shl    %cl,%ebx
  802033:	89 f9                	mov    %edi,%ecx
  802035:	89 d0                	mov    %edx,%eax
  802037:	d3 e8                	shr    %cl,%eax
  802039:	89 e9                	mov    %ebp,%ecx
  80203b:	09 d8                	or     %ebx,%eax
  80203d:	89 d3                	mov    %edx,%ebx
  80203f:	89 f2                	mov    %esi,%edx
  802041:	f7 34 24             	divl   (%esp)
  802044:	89 d6                	mov    %edx,%esi
  802046:	d3 e3                	shl    %cl,%ebx
  802048:	f7 64 24 04          	mull   0x4(%esp)
  80204c:	39 d6                	cmp    %edx,%esi
  80204e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802052:	89 d1                	mov    %edx,%ecx
  802054:	89 c3                	mov    %eax,%ebx
  802056:	72 08                	jb     802060 <__umoddi3+0x110>
  802058:	75 11                	jne    80206b <__umoddi3+0x11b>
  80205a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80205e:	73 0b                	jae    80206b <__umoddi3+0x11b>
  802060:	2b 44 24 04          	sub    0x4(%esp),%eax
  802064:	1b 14 24             	sbb    (%esp),%edx
  802067:	89 d1                	mov    %edx,%ecx
  802069:	89 c3                	mov    %eax,%ebx
  80206b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80206f:	29 da                	sub    %ebx,%edx
  802071:	19 ce                	sbb    %ecx,%esi
  802073:	89 f9                	mov    %edi,%ecx
  802075:	89 f0                	mov    %esi,%eax
  802077:	d3 e0                	shl    %cl,%eax
  802079:	89 e9                	mov    %ebp,%ecx
  80207b:	d3 ea                	shr    %cl,%edx
  80207d:	89 e9                	mov    %ebp,%ecx
  80207f:	d3 ee                	shr    %cl,%esi
  802081:	09 d0                	or     %edx,%eax
  802083:	89 f2                	mov    %esi,%edx
  802085:	83 c4 1c             	add    $0x1c,%esp
  802088:	5b                   	pop    %ebx
  802089:	5e                   	pop    %esi
  80208a:	5f                   	pop    %edi
  80208b:	5d                   	pop    %ebp
  80208c:	c3                   	ret    
  80208d:	8d 76 00             	lea    0x0(%esi),%esi
  802090:	29 f9                	sub    %edi,%ecx
  802092:	19 d6                	sbb    %edx,%esi
  802094:	89 74 24 04          	mov    %esi,0x4(%esp)
  802098:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80209c:	e9 18 ff ff ff       	jmp    801fb9 <__umoddi3+0x69>
