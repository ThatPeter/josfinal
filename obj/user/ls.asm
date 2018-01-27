
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 93 02 00 00       	call   8002c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 a2 26 80 00       	push   $0x8026a2
  80005f:	e8 c2 1c 00 00       	call   801d26 <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 08 27 80 00       	mov    $0x802708,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1e                	je     800093 <ls1+0x60>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 ee 08 00 00       	call   80096c <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
		else
			sep = "";
  800081:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800086:	ba 08 27 80 00       	mov    $0x802708,%edx
  80008b:	b8 a0 26 80 00       	mov    $0x8026a0,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 ab 26 80 00       	push   $0x8026ab
  80009d:	e8 84 1c 00 00       	call   801d26 <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 b1 2b 80 00       	push   $0x802bb1
  8000b0:	e8 71 1c 00 00       	call   801d26 <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 a0 26 80 00       	push   $0x8026a0
  8000cf:	e8 52 1c 00 00       	call   801d26 <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 07 27 80 00       	push   $0x802707
  8000df:	e8 42 1c 00 00       	call   801d26 <printf>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fd:	6a 00                	push   $0x0
  8000ff:	57                   	push   %edi
  800100:	e8 83 1a 00 00       	call   801b88 <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 b0 26 80 00       	push   $0x8026b0
  800118:	6a 1d                	push   $0x1d
  80011a:	68 bc 26 80 00       	push   $0x8026bc
  80011f:	e8 23 02 00 00       	call   800347 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800124:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80012b:	74 28                	je     800155 <lsdir+0x67>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80012d:	56                   	push   %esi
  80012e:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800134:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80013b:	0f 94 c0             	sete   %al
  80013e:	0f b6 c0             	movzbl %al,%eax
  800141:	50                   	push   %eax
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	e8 e9 fe ff ff       	call   800033 <ls1>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	eb 06                	jmp    800155 <lsdir+0x67>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80014f:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800155:	83 ec 04             	sub    $0x4,%esp
  800158:	68 00 01 00 00       	push   $0x100
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	e8 2a 16 00 00       	call   80178e <readn>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	3d 00 01 00 00       	cmp    $0x100,%eax
  80016c:	74 b6                	je     800124 <lsdir+0x36>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 12                	jle    800184 <lsdir+0x96>
		panic("short read in directory %s", path);
  800172:	57                   	push   %edi
  800173:	68 c6 26 80 00       	push   $0x8026c6
  800178:	6a 22                	push   $0x22
  80017a:	68 bc 26 80 00       	push   $0x8026bc
  80017f:	e8 c3 01 00 00       	call   800347 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 0c 27 80 00       	push   $0x80270c
  800192:	6a 24                	push   $0x24
  800194:	68 bc 26 80 00       	push   $0x8026bc
  800199:	e8 a9 01 00 00       	call   800347 <_panic>
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001b9:	50                   	push   %eax
  8001ba:	53                   	push   %ebx
  8001bb:	e8 d3 17 00 00       	call   801993 <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 e1 26 80 00       	push   $0x8026e1
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 bc 26 80 00       	push   $0x8026bc
  8001d8:	e8 6a 01 00 00       	call   800347 <_panic>
	if (st.st_isdir && !flag['d'])
  8001dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	74 1a                	je     8001fe <ls+0x58>
  8001e4:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001eb:	75 11                	jne    8001fe <ls+0x58>
		lsdir(path, prefix);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	53                   	push   %ebx
  8001f4:	e8 f5 fe ff ff       	call   8000ee <lsdir>
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 17                	jmp    800215 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 ec             	pushl  -0x14(%ebp)
  800202:	85 c0                	test   %eax,%eax
  800204:	0f 95 c0             	setne  %al
  800207:	0f b6 c0             	movzbl %al,%eax
  80020a:	50                   	push   %eax
  80020b:	6a 00                	push   $0x0
  80020d:	e8 21 fe ff ff       	call   800033 <ls1>
  800212:	83 c4 10             	add    $0x10,%esp
}
  800215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <usage>:
	printf("\n");
}

void
usage(void)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800220:	68 ed 26 80 00       	push   $0x8026ed
  800225:	e8 fc 1a 00 00       	call   801d26 <printf>
	exit();
  80022a:	e8 fe 00 00 00       	call   80032d <exit>
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <umain>:

void
umain(int argc, char **argv)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 14             	sub    $0x14,%esp
  80023c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80023f:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	56                   	push   %esi
  800244:	8d 45 08             	lea    0x8(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	e8 80 10 00 00       	call   8012cd <argstart>
	while ((i = argnext(&args)) >= 0)
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800253:	eb 1e                	jmp    800273 <umain+0x3f>
		switch (i) {
  800255:	83 f8 64             	cmp    $0x64,%eax
  800258:	74 0a                	je     800264 <umain+0x30>
  80025a:	83 f8 6c             	cmp    $0x6c,%eax
  80025d:	74 05                	je     800264 <umain+0x30>
  80025f:	83 f8 46             	cmp    $0x46,%eax
  800262:	75 0a                	jne    80026e <umain+0x3a>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800264:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  80026b:	01 
			break;
  80026c:	eb 05                	jmp    800273 <umain+0x3f>
		default:
			usage();
  80026e:	e8 a7 ff ff ff       	call   80021a <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	53                   	push   %ebx
  800277:	e8 81 10 00 00       	call   8012fd <argnext>
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 c0                	test   %eax,%eax
  800281:	79 d2                	jns    800255 <umain+0x21>
  800283:	bb 01 00 00 00       	mov    $0x1,%ebx
			break;
		default:
			usage();
		}

	if (argc == 1)
  800288:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80028c:	75 2a                	jne    8002b8 <umain+0x84>
		ls("/", "");
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	68 08 27 80 00       	push   $0x802708
  800296:	68 a0 26 80 00       	push   $0x8026a0
  80029b:	e8 06 ff ff ff       	call   8001a6 <ls>
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	eb 18                	jmp    8002bd <umain+0x89>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002a5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	50                   	push   %eax
  8002ac:	50                   	push   %eax
  8002ad:	e8 f4 fe ff ff       	call   8001a6 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002b2:	83 c3 01             	add    $0x1,%ebx
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8002bb:	7c e8                	jl     8002a5 <umain+0x71>
			ls(argv[i], argv[i]);
	}
}
  8002bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002cf:	e8 96 0a 00 00       	call   800d6a <sys_getenvid>
  8002d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d9:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8002df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e4:	a3 20 44 80 00       	mov    %eax,0x804420
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e9:	85 db                	test   %ebx,%ebx
  8002eb:	7e 07                	jle    8002f4 <libmain+0x30>
		binaryname = argv[0];
  8002ed:	8b 06                	mov    (%esi),%eax
  8002ef:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f4:	83 ec 08             	sub    $0x8,%esp
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
  8002f9:	e8 36 ff ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  8002fe:	e8 2a 00 00 00       	call   80032d <exit>
}
  800303:	83 c4 10             	add    $0x10,%esp
  800306:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800313:	a1 24 44 80 00       	mov    0x804424,%eax
	func();
  800318:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80031a:	e8 4b 0a 00 00       	call   800d6a <sys_getenvid>
  80031f:	83 ec 0c             	sub    $0xc,%esp
  800322:	50                   	push   %eax
  800323:	e8 91 0c 00 00       	call   800fb9 <sys_thread_free>
}
  800328:	83 c4 10             	add    $0x10,%esp
  80032b:	c9                   	leave  
  80032c:	c3                   	ret    

0080032d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800333:	e8 b4 12 00 00       	call   8015ec <close_all>
	sys_env_destroy(0);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	6a 00                	push   $0x0
  80033d:	e8 e7 09 00 00       	call   800d29 <sys_env_destroy>
}
  800342:	83 c4 10             	add    $0x10,%esp
  800345:	c9                   	leave  
  800346:	c3                   	ret    

00800347 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	56                   	push   %esi
  80034b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80034c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80034f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800355:	e8 10 0a 00 00       	call   800d6a <sys_getenvid>
  80035a:	83 ec 0c             	sub    $0xc,%esp
  80035d:	ff 75 0c             	pushl  0xc(%ebp)
  800360:	ff 75 08             	pushl  0x8(%ebp)
  800363:	56                   	push   %esi
  800364:	50                   	push   %eax
  800365:	68 38 27 80 00       	push   $0x802738
  80036a:	e8 b1 00 00 00       	call   800420 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80036f:	83 c4 18             	add    $0x18,%esp
  800372:	53                   	push   %ebx
  800373:	ff 75 10             	pushl  0x10(%ebp)
  800376:	e8 54 00 00 00       	call   8003cf <vcprintf>
	cprintf("\n");
  80037b:	c7 04 24 07 27 80 00 	movl   $0x802707,(%esp)
  800382:	e8 99 00 00 00       	call   800420 <cprintf>
  800387:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80038a:	cc                   	int3   
  80038b:	eb fd                	jmp    80038a <_panic+0x43>

0080038d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	53                   	push   %ebx
  800391:	83 ec 04             	sub    $0x4,%esp
  800394:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800397:	8b 13                	mov    (%ebx),%edx
  800399:	8d 42 01             	lea    0x1(%edx),%eax
  80039c:	89 03                	mov    %eax,(%ebx)
  80039e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003a5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003aa:	75 1a                	jne    8003c6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003ac:	83 ec 08             	sub    $0x8,%esp
  8003af:	68 ff 00 00 00       	push   $0xff
  8003b4:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b7:	50                   	push   %eax
  8003b8:	e8 2f 09 00 00       	call   800cec <sys_cputs>
		b->idx = 0;
  8003bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003c6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003cd:	c9                   	leave  
  8003ce:	c3                   	ret    

008003cf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003df:	00 00 00 
	b.cnt = 0;
  8003e2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ec:	ff 75 0c             	pushl  0xc(%ebp)
  8003ef:	ff 75 08             	pushl  0x8(%ebp)
  8003f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f8:	50                   	push   %eax
  8003f9:	68 8d 03 80 00       	push   $0x80038d
  8003fe:	e8 54 01 00 00       	call   800557 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800403:	83 c4 08             	add    $0x8,%esp
  800406:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80040c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800412:	50                   	push   %eax
  800413:	e8 d4 08 00 00       	call   800cec <sys_cputs>

	return b.cnt;
}
  800418:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041e:	c9                   	leave  
  80041f:	c3                   	ret    

00800420 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800426:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800429:	50                   	push   %eax
  80042a:	ff 75 08             	pushl  0x8(%ebp)
  80042d:	e8 9d ff ff ff       	call   8003cf <vcprintf>
	va_end(ap);

	return cnt;
}
  800432:	c9                   	leave  
  800433:	c3                   	ret    

00800434 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	57                   	push   %edi
  800438:	56                   	push   %esi
  800439:	53                   	push   %ebx
  80043a:	83 ec 1c             	sub    $0x1c,%esp
  80043d:	89 c7                	mov    %eax,%edi
  80043f:	89 d6                	mov    %edx,%esi
  800441:	8b 45 08             	mov    0x8(%ebp),%eax
  800444:	8b 55 0c             	mov    0xc(%ebp),%edx
  800447:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80044a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80044d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800450:	bb 00 00 00 00       	mov    $0x0,%ebx
  800455:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800458:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80045b:	39 d3                	cmp    %edx,%ebx
  80045d:	72 05                	jb     800464 <printnum+0x30>
  80045f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800462:	77 45                	ja     8004a9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff 75 18             	pushl  0x18(%ebp)
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800470:	53                   	push   %ebx
  800471:	ff 75 10             	pushl  0x10(%ebp)
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047a:	ff 75 e0             	pushl  -0x20(%ebp)
  80047d:	ff 75 dc             	pushl  -0x24(%ebp)
  800480:	ff 75 d8             	pushl  -0x28(%ebp)
  800483:	e8 88 1f 00 00       	call   802410 <__udivdi3>
  800488:	83 c4 18             	add    $0x18,%esp
  80048b:	52                   	push   %edx
  80048c:	50                   	push   %eax
  80048d:	89 f2                	mov    %esi,%edx
  80048f:	89 f8                	mov    %edi,%eax
  800491:	e8 9e ff ff ff       	call   800434 <printnum>
  800496:	83 c4 20             	add    $0x20,%esp
  800499:	eb 18                	jmp    8004b3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	56                   	push   %esi
  80049f:	ff 75 18             	pushl  0x18(%ebp)
  8004a2:	ff d7                	call   *%edi
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	eb 03                	jmp    8004ac <printnum+0x78>
  8004a9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004ac:	83 eb 01             	sub    $0x1,%ebx
  8004af:	85 db                	test   %ebx,%ebx
  8004b1:	7f e8                	jg     80049b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	56                   	push   %esi
  8004b7:	83 ec 04             	sub    $0x4,%esp
  8004ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c0:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c3:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c6:	e8 75 20 00 00       	call   802540 <__umoddi3>
  8004cb:	83 c4 14             	add    $0x14,%esp
  8004ce:	0f be 80 5b 27 80 00 	movsbl 0x80275b(%eax),%eax
  8004d5:	50                   	push   %eax
  8004d6:	ff d7                	call   *%edi
}
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004de:	5b                   	pop    %ebx
  8004df:	5e                   	pop    %esi
  8004e0:	5f                   	pop    %edi
  8004e1:	5d                   	pop    %ebp
  8004e2:	c3                   	ret    

008004e3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004e6:	83 fa 01             	cmp    $0x1,%edx
  8004e9:	7e 0e                	jle    8004f9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004eb:	8b 10                	mov    (%eax),%edx
  8004ed:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004f0:	89 08                	mov    %ecx,(%eax)
  8004f2:	8b 02                	mov    (%edx),%eax
  8004f4:	8b 52 04             	mov    0x4(%edx),%edx
  8004f7:	eb 22                	jmp    80051b <getuint+0x38>
	else if (lflag)
  8004f9:	85 d2                	test   %edx,%edx
  8004fb:	74 10                	je     80050d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004fd:	8b 10                	mov    (%eax),%edx
  8004ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800502:	89 08                	mov    %ecx,(%eax)
  800504:	8b 02                	mov    (%edx),%eax
  800506:	ba 00 00 00 00       	mov    $0x0,%edx
  80050b:	eb 0e                	jmp    80051b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80050d:	8b 10                	mov    (%eax),%edx
  80050f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800512:	89 08                	mov    %ecx,(%eax)
  800514:	8b 02                	mov    (%edx),%eax
  800516:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80051b:	5d                   	pop    %ebp
  80051c:	c3                   	ret    

0080051d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800523:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800527:	8b 10                	mov    (%eax),%edx
  800529:	3b 50 04             	cmp    0x4(%eax),%edx
  80052c:	73 0a                	jae    800538 <sprintputch+0x1b>
		*b->buf++ = ch;
  80052e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800531:	89 08                	mov    %ecx,(%eax)
  800533:	8b 45 08             	mov    0x8(%ebp),%eax
  800536:	88 02                	mov    %al,(%edx)
}
  800538:	5d                   	pop    %ebp
  800539:	c3                   	ret    

0080053a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80053a:	55                   	push   %ebp
  80053b:	89 e5                	mov    %esp,%ebp
  80053d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800540:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800543:	50                   	push   %eax
  800544:	ff 75 10             	pushl  0x10(%ebp)
  800547:	ff 75 0c             	pushl  0xc(%ebp)
  80054a:	ff 75 08             	pushl  0x8(%ebp)
  80054d:	e8 05 00 00 00       	call   800557 <vprintfmt>
	va_end(ap);
}
  800552:	83 c4 10             	add    $0x10,%esp
  800555:	c9                   	leave  
  800556:	c3                   	ret    

00800557 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800557:	55                   	push   %ebp
  800558:	89 e5                	mov    %esp,%ebp
  80055a:	57                   	push   %edi
  80055b:	56                   	push   %esi
  80055c:	53                   	push   %ebx
  80055d:	83 ec 2c             	sub    $0x2c,%esp
  800560:	8b 75 08             	mov    0x8(%ebp),%esi
  800563:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800566:	8b 7d 10             	mov    0x10(%ebp),%edi
  800569:	eb 12                	jmp    80057d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80056b:	85 c0                	test   %eax,%eax
  80056d:	0f 84 89 03 00 00    	je     8008fc <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	53                   	push   %ebx
  800577:	50                   	push   %eax
  800578:	ff d6                	call   *%esi
  80057a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80057d:	83 c7 01             	add    $0x1,%edi
  800580:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800584:	83 f8 25             	cmp    $0x25,%eax
  800587:	75 e2                	jne    80056b <vprintfmt+0x14>
  800589:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80058d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800594:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a7:	eb 07                	jmp    8005b0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005ac:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8d 47 01             	lea    0x1(%edi),%eax
  8005b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005b6:	0f b6 07             	movzbl (%edi),%eax
  8005b9:	0f b6 c8             	movzbl %al,%ecx
  8005bc:	83 e8 23             	sub    $0x23,%eax
  8005bf:	3c 55                	cmp    $0x55,%al
  8005c1:	0f 87 1a 03 00 00    	ja     8008e1 <vprintfmt+0x38a>
  8005c7:	0f b6 c0             	movzbl %al,%eax
  8005ca:	ff 24 85 a0 28 80 00 	jmp    *0x8028a0(,%eax,4)
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005d4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005d8:	eb d6                	jmp    8005b0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005e5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005e8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005ec:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005ef:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005f2:	83 fa 09             	cmp    $0x9,%edx
  8005f5:	77 39                	ja     800630 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005f7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005fa:	eb e9                	jmp    8005e5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 48 04             	lea    0x4(%eax),%ecx
  800602:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800605:	8b 00                	mov    (%eax),%eax
  800607:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80060d:	eb 27                	jmp    800636 <vprintfmt+0xdf>
  80060f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800612:	85 c0                	test   %eax,%eax
  800614:	b9 00 00 00 00       	mov    $0x0,%ecx
  800619:	0f 49 c8             	cmovns %eax,%ecx
  80061c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800622:	eb 8c                	jmp    8005b0 <vprintfmt+0x59>
  800624:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800627:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80062e:	eb 80                	jmp    8005b0 <vprintfmt+0x59>
  800630:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800633:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800636:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80063a:	0f 89 70 ff ff ff    	jns    8005b0 <vprintfmt+0x59>
				width = precision, precision = -1;
  800640:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800643:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800646:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80064d:	e9 5e ff ff ff       	jmp    8005b0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800652:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800655:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800658:	e9 53 ff ff ff       	jmp    8005b0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8d 50 04             	lea    0x4(%eax),%edx
  800663:	89 55 14             	mov    %edx,0x14(%ebp)
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	53                   	push   %ebx
  80066a:	ff 30                	pushl  (%eax)
  80066c:	ff d6                	call   *%esi
			break;
  80066e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800674:	e9 04 ff ff ff       	jmp    80057d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8d 50 04             	lea    0x4(%eax),%edx
  80067f:	89 55 14             	mov    %edx,0x14(%ebp)
  800682:	8b 00                	mov    (%eax),%eax
  800684:	99                   	cltd   
  800685:	31 d0                	xor    %edx,%eax
  800687:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800689:	83 f8 0f             	cmp    $0xf,%eax
  80068c:	7f 0b                	jg     800699 <vprintfmt+0x142>
  80068e:	8b 14 85 00 2a 80 00 	mov    0x802a00(,%eax,4),%edx
  800695:	85 d2                	test   %edx,%edx
  800697:	75 18                	jne    8006b1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800699:	50                   	push   %eax
  80069a:	68 73 27 80 00       	push   $0x802773
  80069f:	53                   	push   %ebx
  8006a0:	56                   	push   %esi
  8006a1:	e8 94 fe ff ff       	call   80053a <printfmt>
  8006a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006ac:	e9 cc fe ff ff       	jmp    80057d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006b1:	52                   	push   %edx
  8006b2:	68 b1 2b 80 00       	push   $0x802bb1
  8006b7:	53                   	push   %ebx
  8006b8:	56                   	push   %esi
  8006b9:	e8 7c fe ff ff       	call   80053a <printfmt>
  8006be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c4:	e9 b4 fe ff ff       	jmp    80057d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8d 50 04             	lea    0x4(%eax),%edx
  8006cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006d4:	85 ff                	test   %edi,%edi
  8006d6:	b8 6c 27 80 00       	mov    $0x80276c,%eax
  8006db:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006e2:	0f 8e 94 00 00 00    	jle    80077c <vprintfmt+0x225>
  8006e8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006ec:	0f 84 98 00 00 00    	je     80078a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	ff 75 d0             	pushl  -0x30(%ebp)
  8006f8:	57                   	push   %edi
  8006f9:	e8 86 02 00 00       	call   800984 <strnlen>
  8006fe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800701:	29 c1                	sub    %eax,%ecx
  800703:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800706:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800709:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80070d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800710:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800713:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800715:	eb 0f                	jmp    800726 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	53                   	push   %ebx
  80071b:	ff 75 e0             	pushl  -0x20(%ebp)
  80071e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800720:	83 ef 01             	sub    $0x1,%edi
  800723:	83 c4 10             	add    $0x10,%esp
  800726:	85 ff                	test   %edi,%edi
  800728:	7f ed                	jg     800717 <vprintfmt+0x1c0>
  80072a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80072d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800730:	85 c9                	test   %ecx,%ecx
  800732:	b8 00 00 00 00       	mov    $0x0,%eax
  800737:	0f 49 c1             	cmovns %ecx,%eax
  80073a:	29 c1                	sub    %eax,%ecx
  80073c:	89 75 08             	mov    %esi,0x8(%ebp)
  80073f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800742:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800745:	89 cb                	mov    %ecx,%ebx
  800747:	eb 4d                	jmp    800796 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800749:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80074d:	74 1b                	je     80076a <vprintfmt+0x213>
  80074f:	0f be c0             	movsbl %al,%eax
  800752:	83 e8 20             	sub    $0x20,%eax
  800755:	83 f8 5e             	cmp    $0x5e,%eax
  800758:	76 10                	jbe    80076a <vprintfmt+0x213>
					putch('?', putdat);
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	ff 75 0c             	pushl  0xc(%ebp)
  800760:	6a 3f                	push   $0x3f
  800762:	ff 55 08             	call   *0x8(%ebp)
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	eb 0d                	jmp    800777 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	ff 75 0c             	pushl  0xc(%ebp)
  800770:	52                   	push   %edx
  800771:	ff 55 08             	call   *0x8(%ebp)
  800774:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800777:	83 eb 01             	sub    $0x1,%ebx
  80077a:	eb 1a                	jmp    800796 <vprintfmt+0x23f>
  80077c:	89 75 08             	mov    %esi,0x8(%ebp)
  80077f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800782:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800785:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800788:	eb 0c                	jmp    800796 <vprintfmt+0x23f>
  80078a:	89 75 08             	mov    %esi,0x8(%ebp)
  80078d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800790:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800793:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800796:	83 c7 01             	add    $0x1,%edi
  800799:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80079d:	0f be d0             	movsbl %al,%edx
  8007a0:	85 d2                	test   %edx,%edx
  8007a2:	74 23                	je     8007c7 <vprintfmt+0x270>
  8007a4:	85 f6                	test   %esi,%esi
  8007a6:	78 a1                	js     800749 <vprintfmt+0x1f2>
  8007a8:	83 ee 01             	sub    $0x1,%esi
  8007ab:	79 9c                	jns    800749 <vprintfmt+0x1f2>
  8007ad:	89 df                	mov    %ebx,%edi
  8007af:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b5:	eb 18                	jmp    8007cf <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007b7:	83 ec 08             	sub    $0x8,%esp
  8007ba:	53                   	push   %ebx
  8007bb:	6a 20                	push   $0x20
  8007bd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007bf:	83 ef 01             	sub    $0x1,%edi
  8007c2:	83 c4 10             	add    $0x10,%esp
  8007c5:	eb 08                	jmp    8007cf <vprintfmt+0x278>
  8007c7:	89 df                	mov    %ebx,%edi
  8007c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007cf:	85 ff                	test   %edi,%edi
  8007d1:	7f e4                	jg     8007b7 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007d6:	e9 a2 fd ff ff       	jmp    80057d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007db:	83 fa 01             	cmp    $0x1,%edx
  8007de:	7e 16                	jle    8007f6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8d 50 08             	lea    0x8(%eax),%edx
  8007e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e9:	8b 50 04             	mov    0x4(%eax),%edx
  8007ec:	8b 00                	mov    (%eax),%eax
  8007ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007f4:	eb 32                	jmp    800828 <vprintfmt+0x2d1>
	else if (lflag)
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	74 18                	je     800812 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)
  800803:	8b 00                	mov    (%eax),%eax
  800805:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800808:	89 c1                	mov    %eax,%ecx
  80080a:	c1 f9 1f             	sar    $0x1f,%ecx
  80080d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800810:	eb 16                	jmp    800828 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800812:	8b 45 14             	mov    0x14(%ebp),%eax
  800815:	8d 50 04             	lea    0x4(%eax),%edx
  800818:	89 55 14             	mov    %edx,0x14(%ebp)
  80081b:	8b 00                	mov    (%eax),%eax
  80081d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800820:	89 c1                	mov    %eax,%ecx
  800822:	c1 f9 1f             	sar    $0x1f,%ecx
  800825:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800828:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80082b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80082e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800833:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800837:	79 74                	jns    8008ad <vprintfmt+0x356>
				putch('-', putdat);
  800839:	83 ec 08             	sub    $0x8,%esp
  80083c:	53                   	push   %ebx
  80083d:	6a 2d                	push   $0x2d
  80083f:	ff d6                	call   *%esi
				num = -(long long) num;
  800841:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800844:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800847:	f7 d8                	neg    %eax
  800849:	83 d2 00             	adc    $0x0,%edx
  80084c:	f7 da                	neg    %edx
  80084e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800851:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800856:	eb 55                	jmp    8008ad <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800858:	8d 45 14             	lea    0x14(%ebp),%eax
  80085b:	e8 83 fc ff ff       	call   8004e3 <getuint>
			base = 10;
  800860:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800865:	eb 46                	jmp    8008ad <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800867:	8d 45 14             	lea    0x14(%ebp),%eax
  80086a:	e8 74 fc ff ff       	call   8004e3 <getuint>
			base = 8;
  80086f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800874:	eb 37                	jmp    8008ad <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800876:	83 ec 08             	sub    $0x8,%esp
  800879:	53                   	push   %ebx
  80087a:	6a 30                	push   $0x30
  80087c:	ff d6                	call   *%esi
			putch('x', putdat);
  80087e:	83 c4 08             	add    $0x8,%esp
  800881:	53                   	push   %ebx
  800882:	6a 78                	push   $0x78
  800884:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800886:	8b 45 14             	mov    0x14(%ebp),%eax
  800889:	8d 50 04             	lea    0x4(%eax),%edx
  80088c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80088f:	8b 00                	mov    (%eax),%eax
  800891:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800896:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800899:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80089e:	eb 0d                	jmp    8008ad <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a3:	e8 3b fc ff ff       	call   8004e3 <getuint>
			base = 16;
  8008a8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008ad:	83 ec 0c             	sub    $0xc,%esp
  8008b0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008b4:	57                   	push   %edi
  8008b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b8:	51                   	push   %ecx
  8008b9:	52                   	push   %edx
  8008ba:	50                   	push   %eax
  8008bb:	89 da                	mov    %ebx,%edx
  8008bd:	89 f0                	mov    %esi,%eax
  8008bf:	e8 70 fb ff ff       	call   800434 <printnum>
			break;
  8008c4:	83 c4 20             	add    $0x20,%esp
  8008c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ca:	e9 ae fc ff ff       	jmp    80057d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008cf:	83 ec 08             	sub    $0x8,%esp
  8008d2:	53                   	push   %ebx
  8008d3:	51                   	push   %ecx
  8008d4:	ff d6                	call   *%esi
			break;
  8008d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008dc:	e9 9c fc ff ff       	jmp    80057d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	53                   	push   %ebx
  8008e5:	6a 25                	push   $0x25
  8008e7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	eb 03                	jmp    8008f1 <vprintfmt+0x39a>
  8008ee:	83 ef 01             	sub    $0x1,%edi
  8008f1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008f5:	75 f7                	jne    8008ee <vprintfmt+0x397>
  8008f7:	e9 81 fc ff ff       	jmp    80057d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5f                   	pop    %edi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 18             	sub    $0x18,%esp
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800910:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800913:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800917:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80091a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800921:	85 c0                	test   %eax,%eax
  800923:	74 26                	je     80094b <vsnprintf+0x47>
  800925:	85 d2                	test   %edx,%edx
  800927:	7e 22                	jle    80094b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800929:	ff 75 14             	pushl  0x14(%ebp)
  80092c:	ff 75 10             	pushl  0x10(%ebp)
  80092f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800932:	50                   	push   %eax
  800933:	68 1d 05 80 00       	push   $0x80051d
  800938:	e8 1a fc ff ff       	call   800557 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80093d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800940:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800943:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800946:	83 c4 10             	add    $0x10,%esp
  800949:	eb 05                	jmp    800950 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80094b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800958:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80095b:	50                   	push   %eax
  80095c:	ff 75 10             	pushl  0x10(%ebp)
  80095f:	ff 75 0c             	pushl  0xc(%ebp)
  800962:	ff 75 08             	pushl  0x8(%ebp)
  800965:	e8 9a ff ff ff       	call   800904 <vsnprintf>
	va_end(ap);

	return rc;
}
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
  800977:	eb 03                	jmp    80097c <strlen+0x10>
		n++;
  800979:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80097c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800980:	75 f7                	jne    800979 <strlen+0xd>
		n++;
	return n;
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098d:	ba 00 00 00 00       	mov    $0x0,%edx
  800992:	eb 03                	jmp    800997 <strnlen+0x13>
		n++;
  800994:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800997:	39 c2                	cmp    %eax,%edx
  800999:	74 08                	je     8009a3 <strnlen+0x1f>
  80099b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80099f:	75 f3                	jne    800994 <strnlen+0x10>
  8009a1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	53                   	push   %ebx
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009af:	89 c2                	mov    %eax,%edx
  8009b1:	83 c2 01             	add    $0x1,%edx
  8009b4:	83 c1 01             	add    $0x1,%ecx
  8009b7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009bb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009be:	84 db                	test   %bl,%bl
  8009c0:	75 ef                	jne    8009b1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009c2:	5b                   	pop    %ebx
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	53                   	push   %ebx
  8009c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009cc:	53                   	push   %ebx
  8009cd:	e8 9a ff ff ff       	call   80096c <strlen>
  8009d2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009d5:	ff 75 0c             	pushl  0xc(%ebp)
  8009d8:	01 d8                	add    %ebx,%eax
  8009da:	50                   	push   %eax
  8009db:	e8 c5 ff ff ff       	call   8009a5 <strcpy>
	return dst;
}
  8009e0:	89 d8                	mov    %ebx,%eax
  8009e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	56                   	push   %esi
  8009eb:	53                   	push   %ebx
  8009ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f2:	89 f3                	mov    %esi,%ebx
  8009f4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f7:	89 f2                	mov    %esi,%edx
  8009f9:	eb 0f                	jmp    800a0a <strncpy+0x23>
		*dst++ = *src;
  8009fb:	83 c2 01             	add    $0x1,%edx
  8009fe:	0f b6 01             	movzbl (%ecx),%eax
  800a01:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a04:	80 39 01             	cmpb   $0x1,(%ecx)
  800a07:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0a:	39 da                	cmp    %ebx,%edx
  800a0c:	75 ed                	jne    8009fb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a0e:	89 f0                	mov    %esi,%eax
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1f:	8b 55 10             	mov    0x10(%ebp),%edx
  800a22:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a24:	85 d2                	test   %edx,%edx
  800a26:	74 21                	je     800a49 <strlcpy+0x35>
  800a28:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a2c:	89 f2                	mov    %esi,%edx
  800a2e:	eb 09                	jmp    800a39 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a30:	83 c2 01             	add    $0x1,%edx
  800a33:	83 c1 01             	add    $0x1,%ecx
  800a36:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a39:	39 c2                	cmp    %eax,%edx
  800a3b:	74 09                	je     800a46 <strlcpy+0x32>
  800a3d:	0f b6 19             	movzbl (%ecx),%ebx
  800a40:	84 db                	test   %bl,%bl
  800a42:	75 ec                	jne    800a30 <strlcpy+0x1c>
  800a44:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a46:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a49:	29 f0                	sub    %esi,%eax
}
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a55:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a58:	eb 06                	jmp    800a60 <strcmp+0x11>
		p++, q++;
  800a5a:	83 c1 01             	add    $0x1,%ecx
  800a5d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a60:	0f b6 01             	movzbl (%ecx),%eax
  800a63:	84 c0                	test   %al,%al
  800a65:	74 04                	je     800a6b <strcmp+0x1c>
  800a67:	3a 02                	cmp    (%edx),%al
  800a69:	74 ef                	je     800a5a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6b:	0f b6 c0             	movzbl %al,%eax
  800a6e:	0f b6 12             	movzbl (%edx),%edx
  800a71:	29 d0                	sub    %edx,%eax
}
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	53                   	push   %ebx
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7f:	89 c3                	mov    %eax,%ebx
  800a81:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a84:	eb 06                	jmp    800a8c <strncmp+0x17>
		n--, p++, q++;
  800a86:	83 c0 01             	add    $0x1,%eax
  800a89:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a8c:	39 d8                	cmp    %ebx,%eax
  800a8e:	74 15                	je     800aa5 <strncmp+0x30>
  800a90:	0f b6 08             	movzbl (%eax),%ecx
  800a93:	84 c9                	test   %cl,%cl
  800a95:	74 04                	je     800a9b <strncmp+0x26>
  800a97:	3a 0a                	cmp    (%edx),%cl
  800a99:	74 eb                	je     800a86 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a9b:	0f b6 00             	movzbl (%eax),%eax
  800a9e:	0f b6 12             	movzbl (%edx),%edx
  800aa1:	29 d0                	sub    %edx,%eax
  800aa3:	eb 05                	jmp    800aaa <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aa5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aaa:	5b                   	pop    %ebx
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab7:	eb 07                	jmp    800ac0 <strchr+0x13>
		if (*s == c)
  800ab9:	38 ca                	cmp    %cl,%dl
  800abb:	74 0f                	je     800acc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800abd:	83 c0 01             	add    $0x1,%eax
  800ac0:	0f b6 10             	movzbl (%eax),%edx
  800ac3:	84 d2                	test   %dl,%dl
  800ac5:	75 f2                	jne    800ab9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad8:	eb 03                	jmp    800add <strfind+0xf>
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ae0:	38 ca                	cmp    %cl,%dl
  800ae2:	74 04                	je     800ae8 <strfind+0x1a>
  800ae4:	84 d2                	test   %dl,%dl
  800ae6:	75 f2                	jne    800ada <strfind+0xc>
			break;
	return (char *) s;
}
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
  800af0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af6:	85 c9                	test   %ecx,%ecx
  800af8:	74 36                	je     800b30 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800afa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b00:	75 28                	jne    800b2a <memset+0x40>
  800b02:	f6 c1 03             	test   $0x3,%cl
  800b05:	75 23                	jne    800b2a <memset+0x40>
		c &= 0xFF;
  800b07:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b0b:	89 d3                	mov    %edx,%ebx
  800b0d:	c1 e3 08             	shl    $0x8,%ebx
  800b10:	89 d6                	mov    %edx,%esi
  800b12:	c1 e6 18             	shl    $0x18,%esi
  800b15:	89 d0                	mov    %edx,%eax
  800b17:	c1 e0 10             	shl    $0x10,%eax
  800b1a:	09 f0                	or     %esi,%eax
  800b1c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b1e:	89 d8                	mov    %ebx,%eax
  800b20:	09 d0                	or     %edx,%eax
  800b22:	c1 e9 02             	shr    $0x2,%ecx
  800b25:	fc                   	cld    
  800b26:	f3 ab                	rep stos %eax,%es:(%edi)
  800b28:	eb 06                	jmp    800b30 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2d:	fc                   	cld    
  800b2e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b30:	89 f8                	mov    %edi,%eax
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b42:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b45:	39 c6                	cmp    %eax,%esi
  800b47:	73 35                	jae    800b7e <memmove+0x47>
  800b49:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b4c:	39 d0                	cmp    %edx,%eax
  800b4e:	73 2e                	jae    800b7e <memmove+0x47>
		s += n;
		d += n;
  800b50:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	09 fe                	or     %edi,%esi
  800b57:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b5d:	75 13                	jne    800b72 <memmove+0x3b>
  800b5f:	f6 c1 03             	test   $0x3,%cl
  800b62:	75 0e                	jne    800b72 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b64:	83 ef 04             	sub    $0x4,%edi
  800b67:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b6a:	c1 e9 02             	shr    $0x2,%ecx
  800b6d:	fd                   	std    
  800b6e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b70:	eb 09                	jmp    800b7b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b72:	83 ef 01             	sub    $0x1,%edi
  800b75:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b78:	fd                   	std    
  800b79:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b7b:	fc                   	cld    
  800b7c:	eb 1d                	jmp    800b9b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7e:	89 f2                	mov    %esi,%edx
  800b80:	09 c2                	or     %eax,%edx
  800b82:	f6 c2 03             	test   $0x3,%dl
  800b85:	75 0f                	jne    800b96 <memmove+0x5f>
  800b87:	f6 c1 03             	test   $0x3,%cl
  800b8a:	75 0a                	jne    800b96 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b8c:	c1 e9 02             	shr    $0x2,%ecx
  800b8f:	89 c7                	mov    %eax,%edi
  800b91:	fc                   	cld    
  800b92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b94:	eb 05                	jmp    800b9b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b96:	89 c7                	mov    %eax,%edi
  800b98:	fc                   	cld    
  800b99:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ba2:	ff 75 10             	pushl  0x10(%ebp)
  800ba5:	ff 75 0c             	pushl  0xc(%ebp)
  800ba8:	ff 75 08             	pushl  0x8(%ebp)
  800bab:	e8 87 ff ff ff       	call   800b37 <memmove>
}
  800bb0:	c9                   	leave  
  800bb1:	c3                   	ret    

00800bb2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bba:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbd:	89 c6                	mov    %eax,%esi
  800bbf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc2:	eb 1a                	jmp    800bde <memcmp+0x2c>
		if (*s1 != *s2)
  800bc4:	0f b6 08             	movzbl (%eax),%ecx
  800bc7:	0f b6 1a             	movzbl (%edx),%ebx
  800bca:	38 d9                	cmp    %bl,%cl
  800bcc:	74 0a                	je     800bd8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bce:	0f b6 c1             	movzbl %cl,%eax
  800bd1:	0f b6 db             	movzbl %bl,%ebx
  800bd4:	29 d8                	sub    %ebx,%eax
  800bd6:	eb 0f                	jmp    800be7 <memcmp+0x35>
		s1++, s2++;
  800bd8:	83 c0 01             	add    $0x1,%eax
  800bdb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bde:	39 f0                	cmp    %esi,%eax
  800be0:	75 e2                	jne    800bc4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800be2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	53                   	push   %ebx
  800bef:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bf2:	89 c1                	mov    %eax,%ecx
  800bf4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bfb:	eb 0a                	jmp    800c07 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bfd:	0f b6 10             	movzbl (%eax),%edx
  800c00:	39 da                	cmp    %ebx,%edx
  800c02:	74 07                	je     800c0b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c04:	83 c0 01             	add    $0x1,%eax
  800c07:	39 c8                	cmp    %ecx,%eax
  800c09:	72 f2                	jb     800bfd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c0b:	5b                   	pop    %ebx
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1a:	eb 03                	jmp    800c1f <strtol+0x11>
		s++;
  800c1c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1f:	0f b6 01             	movzbl (%ecx),%eax
  800c22:	3c 20                	cmp    $0x20,%al
  800c24:	74 f6                	je     800c1c <strtol+0xe>
  800c26:	3c 09                	cmp    $0x9,%al
  800c28:	74 f2                	je     800c1c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c2a:	3c 2b                	cmp    $0x2b,%al
  800c2c:	75 0a                	jne    800c38 <strtol+0x2a>
		s++;
  800c2e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c31:	bf 00 00 00 00       	mov    $0x0,%edi
  800c36:	eb 11                	jmp    800c49 <strtol+0x3b>
  800c38:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c3d:	3c 2d                	cmp    $0x2d,%al
  800c3f:	75 08                	jne    800c49 <strtol+0x3b>
		s++, neg = 1;
  800c41:	83 c1 01             	add    $0x1,%ecx
  800c44:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c49:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c4f:	75 15                	jne    800c66 <strtol+0x58>
  800c51:	80 39 30             	cmpb   $0x30,(%ecx)
  800c54:	75 10                	jne    800c66 <strtol+0x58>
  800c56:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c5a:	75 7c                	jne    800cd8 <strtol+0xca>
		s += 2, base = 16;
  800c5c:	83 c1 02             	add    $0x2,%ecx
  800c5f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c64:	eb 16                	jmp    800c7c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c66:	85 db                	test   %ebx,%ebx
  800c68:	75 12                	jne    800c7c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c6a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c6f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c72:	75 08                	jne    800c7c <strtol+0x6e>
		s++, base = 8;
  800c74:	83 c1 01             	add    $0x1,%ecx
  800c77:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c81:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c84:	0f b6 11             	movzbl (%ecx),%edx
  800c87:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c8a:	89 f3                	mov    %esi,%ebx
  800c8c:	80 fb 09             	cmp    $0x9,%bl
  800c8f:	77 08                	ja     800c99 <strtol+0x8b>
			dig = *s - '0';
  800c91:	0f be d2             	movsbl %dl,%edx
  800c94:	83 ea 30             	sub    $0x30,%edx
  800c97:	eb 22                	jmp    800cbb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c99:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c9c:	89 f3                	mov    %esi,%ebx
  800c9e:	80 fb 19             	cmp    $0x19,%bl
  800ca1:	77 08                	ja     800cab <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ca3:	0f be d2             	movsbl %dl,%edx
  800ca6:	83 ea 57             	sub    $0x57,%edx
  800ca9:	eb 10                	jmp    800cbb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cab:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cae:	89 f3                	mov    %esi,%ebx
  800cb0:	80 fb 19             	cmp    $0x19,%bl
  800cb3:	77 16                	ja     800ccb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cb5:	0f be d2             	movsbl %dl,%edx
  800cb8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cbb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cbe:	7d 0b                	jge    800ccb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cc0:	83 c1 01             	add    $0x1,%ecx
  800cc3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cc7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cc9:	eb b9                	jmp    800c84 <strtol+0x76>

	if (endptr)
  800ccb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ccf:	74 0d                	je     800cde <strtol+0xd0>
		*endptr = (char *) s;
  800cd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd4:	89 0e                	mov    %ecx,(%esi)
  800cd6:	eb 06                	jmp    800cde <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd8:	85 db                	test   %ebx,%ebx
  800cda:	74 98                	je     800c74 <strtol+0x66>
  800cdc:	eb 9e                	jmp    800c7c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cde:	89 c2                	mov    %eax,%edx
  800ce0:	f7 da                	neg    %edx
  800ce2:	85 ff                	test   %edi,%edi
  800ce4:	0f 45 c2             	cmovne %edx,%eax
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 c3                	mov    %eax,%ebx
  800cff:	89 c7                	mov    %eax,%edi
  800d01:	89 c6                	mov    %eax,%esi
  800d03:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <sys_cgetc>:

int
sys_cgetc(void)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	ba 00 00 00 00       	mov    $0x0,%edx
  800d15:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1a:	89 d1                	mov    %edx,%ecx
  800d1c:	89 d3                	mov    %edx,%ebx
  800d1e:	89 d7                	mov    %edx,%edi
  800d20:	89 d6                	mov    %edx,%esi
  800d22:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d37:	b8 03 00 00 00       	mov    $0x3,%eax
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 cb                	mov    %ecx,%ebx
  800d41:	89 cf                	mov    %ecx,%edi
  800d43:	89 ce                	mov    %ecx,%esi
  800d45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d47:	85 c0                	test   %eax,%eax
  800d49:	7e 17                	jle    800d62 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	50                   	push   %eax
  800d4f:	6a 03                	push   $0x3
  800d51:	68 5f 2a 80 00       	push   $0x802a5f
  800d56:	6a 23                	push   $0x23
  800d58:	68 7c 2a 80 00       	push   $0x802a7c
  800d5d:	e8 e5 f5 ff ff       	call   800347 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	ba 00 00 00 00       	mov    $0x0,%edx
  800d75:	b8 02 00 00 00       	mov    $0x2,%eax
  800d7a:	89 d1                	mov    %edx,%ecx
  800d7c:	89 d3                	mov    %edx,%ebx
  800d7e:	89 d7                	mov    %edx,%edi
  800d80:	89 d6                	mov    %edx,%esi
  800d82:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_yield>:

void
sys_yield(void)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d94:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d99:	89 d1                	mov    %edx,%ecx
  800d9b:	89 d3                	mov    %edx,%ebx
  800d9d:	89 d7                	mov    %edx,%edi
  800d9f:	89 d6                	mov    %edx,%esi
  800da1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	be 00 00 00 00       	mov    $0x0,%esi
  800db6:	b8 04 00 00 00       	mov    $0x4,%eax
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc4:	89 f7                	mov    %esi,%edi
  800dc6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7e 17                	jle    800de3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	50                   	push   %eax
  800dd0:	6a 04                	push   $0x4
  800dd2:	68 5f 2a 80 00       	push   $0x802a5f
  800dd7:	6a 23                	push   $0x23
  800dd9:	68 7c 2a 80 00       	push   $0x802a7c
  800dde:	e8 64 f5 ff ff       	call   800347 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800de3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df4:	b8 05 00 00 00       	mov    $0x5,%eax
  800df9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e05:	8b 75 18             	mov    0x18(%ebp),%esi
  800e08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	7e 17                	jle    800e25 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	50                   	push   %eax
  800e12:	6a 05                	push   $0x5
  800e14:	68 5f 2a 80 00       	push   $0x802a5f
  800e19:	6a 23                	push   $0x23
  800e1b:	68 7c 2a 80 00       	push   $0x802a7c
  800e20:	e8 22 f5 ff ff       	call   800347 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	57                   	push   %edi
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
  800e33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3b:	b8 06 00 00 00       	mov    $0x6,%eax
  800e40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e43:	8b 55 08             	mov    0x8(%ebp),%edx
  800e46:	89 df                	mov    %ebx,%edi
  800e48:	89 de                	mov    %ebx,%esi
  800e4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	7e 17                	jle    800e67 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e50:	83 ec 0c             	sub    $0xc,%esp
  800e53:	50                   	push   %eax
  800e54:	6a 06                	push   $0x6
  800e56:	68 5f 2a 80 00       	push   $0x802a5f
  800e5b:	6a 23                	push   $0x23
  800e5d:	68 7c 2a 80 00       	push   $0x802a7c
  800e62:	e8 e0 f4 ff ff       	call   800347 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6a:	5b                   	pop    %ebx
  800e6b:	5e                   	pop    %esi
  800e6c:	5f                   	pop    %edi
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7d:	b8 08 00 00 00       	mov    $0x8,%eax
  800e82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e85:	8b 55 08             	mov    0x8(%ebp),%edx
  800e88:	89 df                	mov    %ebx,%edi
  800e8a:	89 de                	mov    %ebx,%esi
  800e8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	7e 17                	jle    800ea9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e92:	83 ec 0c             	sub    $0xc,%esp
  800e95:	50                   	push   %eax
  800e96:	6a 08                	push   $0x8
  800e98:	68 5f 2a 80 00       	push   $0x802a5f
  800e9d:	6a 23                	push   $0x23
  800e9f:	68 7c 2a 80 00       	push   $0x802a7c
  800ea4:	e8 9e f4 ff ff       	call   800347 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ea9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eac:	5b                   	pop    %ebx
  800ead:	5e                   	pop    %esi
  800eae:	5f                   	pop    %edi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	57                   	push   %edi
  800eb5:	56                   	push   %esi
  800eb6:	53                   	push   %ebx
  800eb7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebf:	b8 09 00 00 00       	mov    $0x9,%eax
  800ec4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eca:	89 df                	mov    %ebx,%edi
  800ecc:	89 de                	mov    %ebx,%esi
  800ece:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	7e 17                	jle    800eeb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed4:	83 ec 0c             	sub    $0xc,%esp
  800ed7:	50                   	push   %eax
  800ed8:	6a 09                	push   $0x9
  800eda:	68 5f 2a 80 00       	push   $0x802a5f
  800edf:	6a 23                	push   $0x23
  800ee1:	68 7c 2a 80 00       	push   $0x802a7c
  800ee6:	e8 5c f4 ff ff       	call   800347 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f01:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f09:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0c:	89 df                	mov    %ebx,%edi
  800f0e:	89 de                	mov    %ebx,%esi
  800f10:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f12:	85 c0                	test   %eax,%eax
  800f14:	7e 17                	jle    800f2d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f16:	83 ec 0c             	sub    $0xc,%esp
  800f19:	50                   	push   %eax
  800f1a:	6a 0a                	push   $0xa
  800f1c:	68 5f 2a 80 00       	push   $0x802a5f
  800f21:	6a 23                	push   $0x23
  800f23:	68 7c 2a 80 00       	push   $0x802a7c
  800f28:	e8 1a f4 ff ff       	call   800347 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3b:	be 00 00 00 00       	mov    $0x0,%esi
  800f40:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f48:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f51:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f53:	5b                   	pop    %ebx
  800f54:	5e                   	pop    %esi
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	57                   	push   %edi
  800f5c:	56                   	push   %esi
  800f5d:	53                   	push   %ebx
  800f5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f66:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6e:	89 cb                	mov    %ecx,%ebx
  800f70:	89 cf                	mov    %ecx,%edi
  800f72:	89 ce                	mov    %ecx,%esi
  800f74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f76:	85 c0                	test   %eax,%eax
  800f78:	7e 17                	jle    800f91 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7a:	83 ec 0c             	sub    $0xc,%esp
  800f7d:	50                   	push   %eax
  800f7e:	6a 0d                	push   $0xd
  800f80:	68 5f 2a 80 00       	push   $0x802a5f
  800f85:	6a 23                	push   $0x23
  800f87:	68 7c 2a 80 00       	push   $0x802a7c
  800f8c:	e8 b6 f3 ff ff       	call   800347 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f94:	5b                   	pop    %ebx
  800f95:	5e                   	pop    %esi
  800f96:	5f                   	pop    %edi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	57                   	push   %edi
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fac:	89 cb                	mov    %ecx,%ebx
  800fae:	89 cf                	mov    %ecx,%edi
  800fb0:	89 ce                	mov    %ecx,%esi
  800fb2:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800fb4:	5b                   	pop    %ebx
  800fb5:	5e                   	pop    %esi
  800fb6:	5f                   	pop    %edi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    

00800fb9 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	57                   	push   %edi
  800fbd:	56                   	push   %esi
  800fbe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc4:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcc:	89 cb                	mov    %ecx,%ebx
  800fce:	89 cf                	mov    %ecx,%edi
  800fd0:	89 ce                	mov    %ecx,%esi
  800fd2:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    

00800fd9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	53                   	push   %ebx
  800fdd:	83 ec 04             	sub    $0x4,%esp
  800fe0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fe3:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800fe5:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fe9:	74 11                	je     800ffc <pgfault+0x23>
  800feb:	89 d8                	mov    %ebx,%eax
  800fed:	c1 e8 0c             	shr    $0xc,%eax
  800ff0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff7:	f6 c4 08             	test   $0x8,%ah
  800ffa:	75 14                	jne    801010 <pgfault+0x37>
		panic("faulting access");
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	68 8a 2a 80 00       	push   $0x802a8a
  801004:	6a 1e                	push   $0x1e
  801006:	68 9a 2a 80 00       	push   $0x802a9a
  80100b:	e8 37 f3 ff ff       	call   800347 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  801010:	83 ec 04             	sub    $0x4,%esp
  801013:	6a 07                	push   $0x7
  801015:	68 00 f0 7f 00       	push   $0x7ff000
  80101a:	6a 00                	push   $0x0
  80101c:	e8 87 fd ff ff       	call   800da8 <sys_page_alloc>
	if (r < 0) {
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	85 c0                	test   %eax,%eax
  801026:	79 12                	jns    80103a <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  801028:	50                   	push   %eax
  801029:	68 a5 2a 80 00       	push   $0x802aa5
  80102e:	6a 2c                	push   $0x2c
  801030:	68 9a 2a 80 00       	push   $0x802a9a
  801035:	e8 0d f3 ff ff       	call   800347 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80103a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  801040:	83 ec 04             	sub    $0x4,%esp
  801043:	68 00 10 00 00       	push   $0x1000
  801048:	53                   	push   %ebx
  801049:	68 00 f0 7f 00       	push   $0x7ff000
  80104e:	e8 4c fb ff ff       	call   800b9f <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801053:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80105a:	53                   	push   %ebx
  80105b:	6a 00                	push   $0x0
  80105d:	68 00 f0 7f 00       	push   $0x7ff000
  801062:	6a 00                	push   $0x0
  801064:	e8 82 fd ff ff       	call   800deb <sys_page_map>
	if (r < 0) {
  801069:	83 c4 20             	add    $0x20,%esp
  80106c:	85 c0                	test   %eax,%eax
  80106e:	79 12                	jns    801082 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  801070:	50                   	push   %eax
  801071:	68 a5 2a 80 00       	push   $0x802aa5
  801076:	6a 33                	push   $0x33
  801078:	68 9a 2a 80 00       	push   $0x802a9a
  80107d:	e8 c5 f2 ff ff       	call   800347 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  801082:	83 ec 08             	sub    $0x8,%esp
  801085:	68 00 f0 7f 00       	push   $0x7ff000
  80108a:	6a 00                	push   $0x0
  80108c:	e8 9c fd ff ff       	call   800e2d <sys_page_unmap>
	if (r < 0) {
  801091:	83 c4 10             	add    $0x10,%esp
  801094:	85 c0                	test   %eax,%eax
  801096:	79 12                	jns    8010aa <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  801098:	50                   	push   %eax
  801099:	68 a5 2a 80 00       	push   $0x802aa5
  80109e:	6a 37                	push   $0x37
  8010a0:	68 9a 2a 80 00       	push   $0x802a9a
  8010a5:	e8 9d f2 ff ff       	call   800347 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8010aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ad:	c9                   	leave  
  8010ae:	c3                   	ret    

008010af <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	57                   	push   %edi
  8010b3:	56                   	push   %esi
  8010b4:	53                   	push   %ebx
  8010b5:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8010b8:	68 d9 0f 80 00       	push   $0x800fd9
  8010bd:	e8 62 11 00 00       	call   802224 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010c2:	b8 07 00 00 00       	mov    $0x7,%eax
  8010c7:	cd 30                	int    $0x30
  8010c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	79 17                	jns    8010ea <fork+0x3b>
		panic("fork fault %e");
  8010d3:	83 ec 04             	sub    $0x4,%esp
  8010d6:	68 be 2a 80 00       	push   $0x802abe
  8010db:	68 84 00 00 00       	push   $0x84
  8010e0:	68 9a 2a 80 00       	push   $0x802a9a
  8010e5:	e8 5d f2 ff ff       	call   800347 <_panic>
  8010ea:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8010ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010f0:	75 24                	jne    801116 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010f2:	e8 73 fc ff ff       	call   800d6a <sys_getenvid>
  8010f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010fc:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801102:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801107:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  80110c:	b8 00 00 00 00       	mov    $0x0,%eax
  801111:	e9 64 01 00 00       	jmp    80127a <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801116:	83 ec 04             	sub    $0x4,%esp
  801119:	6a 07                	push   $0x7
  80111b:	68 00 f0 bf ee       	push   $0xeebff000
  801120:	ff 75 e4             	pushl  -0x1c(%ebp)
  801123:	e8 80 fc ff ff       	call   800da8 <sys_page_alloc>
  801128:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80112b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801130:	89 d8                	mov    %ebx,%eax
  801132:	c1 e8 16             	shr    $0x16,%eax
  801135:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80113c:	a8 01                	test   $0x1,%al
  80113e:	0f 84 fc 00 00 00    	je     801240 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801144:	89 d8                	mov    %ebx,%eax
  801146:	c1 e8 0c             	shr    $0xc,%eax
  801149:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801150:	f6 c2 01             	test   $0x1,%dl
  801153:	0f 84 e7 00 00 00    	je     801240 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801159:	89 c6                	mov    %eax,%esi
  80115b:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80115e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801165:	f6 c6 04             	test   $0x4,%dh
  801168:	74 39                	je     8011a3 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80116a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801171:	83 ec 0c             	sub    $0xc,%esp
  801174:	25 07 0e 00 00       	and    $0xe07,%eax
  801179:	50                   	push   %eax
  80117a:	56                   	push   %esi
  80117b:	57                   	push   %edi
  80117c:	56                   	push   %esi
  80117d:	6a 00                	push   $0x0
  80117f:	e8 67 fc ff ff       	call   800deb <sys_page_map>
		if (r < 0) {
  801184:	83 c4 20             	add    $0x20,%esp
  801187:	85 c0                	test   %eax,%eax
  801189:	0f 89 b1 00 00 00    	jns    801240 <fork+0x191>
		    	panic("sys page map fault %e");
  80118f:	83 ec 04             	sub    $0x4,%esp
  801192:	68 cc 2a 80 00       	push   $0x802acc
  801197:	6a 54                	push   $0x54
  801199:	68 9a 2a 80 00       	push   $0x802a9a
  80119e:	e8 a4 f1 ff ff       	call   800347 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8011a3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011aa:	f6 c2 02             	test   $0x2,%dl
  8011ad:	75 0c                	jne    8011bb <fork+0x10c>
  8011af:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b6:	f6 c4 08             	test   $0x8,%ah
  8011b9:	74 5b                	je     801216 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8011bb:	83 ec 0c             	sub    $0xc,%esp
  8011be:	68 05 08 00 00       	push   $0x805
  8011c3:	56                   	push   %esi
  8011c4:	57                   	push   %edi
  8011c5:	56                   	push   %esi
  8011c6:	6a 00                	push   $0x0
  8011c8:	e8 1e fc ff ff       	call   800deb <sys_page_map>
		if (r < 0) {
  8011cd:	83 c4 20             	add    $0x20,%esp
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	79 14                	jns    8011e8 <fork+0x139>
		    	panic("sys page map fault %e");
  8011d4:	83 ec 04             	sub    $0x4,%esp
  8011d7:	68 cc 2a 80 00       	push   $0x802acc
  8011dc:	6a 5b                	push   $0x5b
  8011de:	68 9a 2a 80 00       	push   $0x802a9a
  8011e3:	e8 5f f1 ff ff       	call   800347 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8011e8:	83 ec 0c             	sub    $0xc,%esp
  8011eb:	68 05 08 00 00       	push   $0x805
  8011f0:	56                   	push   %esi
  8011f1:	6a 00                	push   $0x0
  8011f3:	56                   	push   %esi
  8011f4:	6a 00                	push   $0x0
  8011f6:	e8 f0 fb ff ff       	call   800deb <sys_page_map>
		if (r < 0) {
  8011fb:	83 c4 20             	add    $0x20,%esp
  8011fe:	85 c0                	test   %eax,%eax
  801200:	79 3e                	jns    801240 <fork+0x191>
		    	panic("sys page map fault %e");
  801202:	83 ec 04             	sub    $0x4,%esp
  801205:	68 cc 2a 80 00       	push   $0x802acc
  80120a:	6a 5f                	push   $0x5f
  80120c:	68 9a 2a 80 00       	push   $0x802a9a
  801211:	e8 31 f1 ff ff       	call   800347 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801216:	83 ec 0c             	sub    $0xc,%esp
  801219:	6a 05                	push   $0x5
  80121b:	56                   	push   %esi
  80121c:	57                   	push   %edi
  80121d:	56                   	push   %esi
  80121e:	6a 00                	push   $0x0
  801220:	e8 c6 fb ff ff       	call   800deb <sys_page_map>
		if (r < 0) {
  801225:	83 c4 20             	add    $0x20,%esp
  801228:	85 c0                	test   %eax,%eax
  80122a:	79 14                	jns    801240 <fork+0x191>
		    	panic("sys page map fault %e");
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	68 cc 2a 80 00       	push   $0x802acc
  801234:	6a 64                	push   $0x64
  801236:	68 9a 2a 80 00       	push   $0x802a9a
  80123b:	e8 07 f1 ff ff       	call   800347 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801240:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801246:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80124c:	0f 85 de fe ff ff    	jne    801130 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801252:	a1 20 44 80 00       	mov    0x804420,%eax
  801257:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  80125d:	83 ec 08             	sub    $0x8,%esp
  801260:	50                   	push   %eax
  801261:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801264:	57                   	push   %edi
  801265:	e8 89 fc ff ff       	call   800ef3 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80126a:	83 c4 08             	add    $0x8,%esp
  80126d:	6a 02                	push   $0x2
  80126f:	57                   	push   %edi
  801270:	e8 fa fb ff ff       	call   800e6f <sys_env_set_status>
	
	return envid;
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80127a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127d:	5b                   	pop    %ebx
  80127e:	5e                   	pop    %esi
  80127f:	5f                   	pop    %edi
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    

00801282 <sfork>:

envid_t
sfork(void)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801285:	b8 00 00 00 00       	mov    $0x0,%eax
  80128a:	5d                   	pop    %ebp
  80128b:	c3                   	ret    

0080128c <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	56                   	push   %esi
  801290:	53                   	push   %ebx
  801291:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801294:	89 1d 24 44 80 00    	mov    %ebx,0x804424
	cprintf("in fork.c thread create. func: %x\n", func);
  80129a:	83 ec 08             	sub    $0x8,%esp
  80129d:	53                   	push   %ebx
  80129e:	68 e4 2a 80 00       	push   $0x802ae4
  8012a3:	e8 78 f1 ff ff       	call   800420 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8012a8:	c7 04 24 0d 03 80 00 	movl   $0x80030d,(%esp)
  8012af:	e8 e5 fc ff ff       	call   800f99 <sys_thread_create>
  8012b4:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8012b6:	83 c4 08             	add    $0x8,%esp
  8012b9:	53                   	push   %ebx
  8012ba:	68 e4 2a 80 00       	push   $0x802ae4
  8012bf:	e8 5c f1 ff ff       	call   800420 <cprintf>
	return id;
}
  8012c4:	89 f0                	mov    %esi,%eax
  8012c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c9:	5b                   	pop    %ebx
  8012ca:	5e                   	pop    %esi
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    

008012cd <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d6:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  8012d9:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  8012db:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  8012de:	83 3a 01             	cmpl   $0x1,(%edx)
  8012e1:	7e 09                	jle    8012ec <argstart+0x1f>
  8012e3:	ba 08 27 80 00       	mov    $0x802708,%edx
  8012e8:	85 c9                	test   %ecx,%ecx
  8012ea:	75 05                	jne    8012f1 <argstart+0x24>
  8012ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f1:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  8012f4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  8012fb:	5d                   	pop    %ebp
  8012fc:	c3                   	ret    

008012fd <argnext>:

int
argnext(struct Argstate *args)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	53                   	push   %ebx
  801301:	83 ec 04             	sub    $0x4,%esp
  801304:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801307:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  80130e:	8b 43 08             	mov    0x8(%ebx),%eax
  801311:	85 c0                	test   %eax,%eax
  801313:	74 6f                	je     801384 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801315:	80 38 00             	cmpb   $0x0,(%eax)
  801318:	75 4e                	jne    801368 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  80131a:	8b 0b                	mov    (%ebx),%ecx
  80131c:	83 39 01             	cmpl   $0x1,(%ecx)
  80131f:	74 55                	je     801376 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801321:	8b 53 04             	mov    0x4(%ebx),%edx
  801324:	8b 42 04             	mov    0x4(%edx),%eax
  801327:	80 38 2d             	cmpb   $0x2d,(%eax)
  80132a:	75 4a                	jne    801376 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  80132c:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801330:	74 44                	je     801376 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801332:	83 c0 01             	add    $0x1,%eax
  801335:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801338:	83 ec 04             	sub    $0x4,%esp
  80133b:	8b 01                	mov    (%ecx),%eax
  80133d:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801344:	50                   	push   %eax
  801345:	8d 42 08             	lea    0x8(%edx),%eax
  801348:	50                   	push   %eax
  801349:	83 c2 04             	add    $0x4,%edx
  80134c:	52                   	push   %edx
  80134d:	e8 e5 f7 ff ff       	call   800b37 <memmove>
		(*args->argc)--;
  801352:	8b 03                	mov    (%ebx),%eax
  801354:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801357:	8b 43 08             	mov    0x8(%ebx),%eax
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	80 38 2d             	cmpb   $0x2d,(%eax)
  801360:	75 06                	jne    801368 <argnext+0x6b>
  801362:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801366:	74 0e                	je     801376 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801368:	8b 53 08             	mov    0x8(%ebx),%edx
  80136b:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  80136e:	83 c2 01             	add    $0x1,%edx
  801371:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801374:	eb 13                	jmp    801389 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801376:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  80137d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801382:	eb 05                	jmp    801389 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801384:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801389:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    

0080138e <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	53                   	push   %ebx
  801392:	83 ec 04             	sub    $0x4,%esp
  801395:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801398:	8b 43 08             	mov    0x8(%ebx),%eax
  80139b:	85 c0                	test   %eax,%eax
  80139d:	74 58                	je     8013f7 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  80139f:	80 38 00             	cmpb   $0x0,(%eax)
  8013a2:	74 0c                	je     8013b0 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8013a4:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8013a7:	c7 43 08 08 27 80 00 	movl   $0x802708,0x8(%ebx)
  8013ae:	eb 42                	jmp    8013f2 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  8013b0:	8b 13                	mov    (%ebx),%edx
  8013b2:	83 3a 01             	cmpl   $0x1,(%edx)
  8013b5:	7e 2d                	jle    8013e4 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  8013b7:	8b 43 04             	mov    0x4(%ebx),%eax
  8013ba:	8b 48 04             	mov    0x4(%eax),%ecx
  8013bd:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8013c0:	83 ec 04             	sub    $0x4,%esp
  8013c3:	8b 12                	mov    (%edx),%edx
  8013c5:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  8013cc:	52                   	push   %edx
  8013cd:	8d 50 08             	lea    0x8(%eax),%edx
  8013d0:	52                   	push   %edx
  8013d1:	83 c0 04             	add    $0x4,%eax
  8013d4:	50                   	push   %eax
  8013d5:	e8 5d f7 ff ff       	call   800b37 <memmove>
		(*args->argc)--;
  8013da:	8b 03                	mov    (%ebx),%eax
  8013dc:	83 28 01             	subl   $0x1,(%eax)
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	eb 0e                	jmp    8013f2 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  8013e4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8013eb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8013f2:	8b 43 0c             	mov    0xc(%ebx),%eax
  8013f5:	eb 05                	jmp    8013fc <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8013f7:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8013fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ff:	c9                   	leave  
  801400:	c3                   	ret    

00801401 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  80140a:	8b 51 0c             	mov    0xc(%ecx),%edx
  80140d:	89 d0                	mov    %edx,%eax
  80140f:	85 d2                	test   %edx,%edx
  801411:	75 0c                	jne    80141f <argvalue+0x1e>
  801413:	83 ec 0c             	sub    $0xc,%esp
  801416:	51                   	push   %ecx
  801417:	e8 72 ff ff ff       	call   80138e <argnextvalue>
  80141c:	83 c4 10             	add    $0x10,%esp
}
  80141f:	c9                   	leave  
  801420:	c3                   	ret    

00801421 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
  801427:	05 00 00 00 30       	add    $0x30000000,%eax
  80142c:	c1 e8 0c             	shr    $0xc,%eax
}
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    

00801431 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801434:	8b 45 08             	mov    0x8(%ebp),%eax
  801437:	05 00 00 00 30       	add    $0x30000000,%eax
  80143c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801441:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801446:	5d                   	pop    %ebp
  801447:	c3                   	ret    

00801448 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80144e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801453:	89 c2                	mov    %eax,%edx
  801455:	c1 ea 16             	shr    $0x16,%edx
  801458:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80145f:	f6 c2 01             	test   $0x1,%dl
  801462:	74 11                	je     801475 <fd_alloc+0x2d>
  801464:	89 c2                	mov    %eax,%edx
  801466:	c1 ea 0c             	shr    $0xc,%edx
  801469:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801470:	f6 c2 01             	test   $0x1,%dl
  801473:	75 09                	jne    80147e <fd_alloc+0x36>
			*fd_store = fd;
  801475:	89 01                	mov    %eax,(%ecx)
			return 0;
  801477:	b8 00 00 00 00       	mov    $0x0,%eax
  80147c:	eb 17                	jmp    801495 <fd_alloc+0x4d>
  80147e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801483:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801488:	75 c9                	jne    801453 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80148a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801490:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801495:	5d                   	pop    %ebp
  801496:	c3                   	ret    

00801497 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80149d:	83 f8 1f             	cmp    $0x1f,%eax
  8014a0:	77 36                	ja     8014d8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014a2:	c1 e0 0c             	shl    $0xc,%eax
  8014a5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	c1 ea 16             	shr    $0x16,%edx
  8014af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014b6:	f6 c2 01             	test   $0x1,%dl
  8014b9:	74 24                	je     8014df <fd_lookup+0x48>
  8014bb:	89 c2                	mov    %eax,%edx
  8014bd:	c1 ea 0c             	shr    $0xc,%edx
  8014c0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014c7:	f6 c2 01             	test   $0x1,%dl
  8014ca:	74 1a                	je     8014e6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014cf:	89 02                	mov    %eax,(%edx)
	return 0;
  8014d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d6:	eb 13                	jmp    8014eb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014dd:	eb 0c                	jmp    8014eb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014e4:	eb 05                	jmp    8014eb <fd_lookup+0x54>
  8014e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    

008014ed <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	83 ec 08             	sub    $0x8,%esp
  8014f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014f6:	ba 88 2b 80 00       	mov    $0x802b88,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014fb:	eb 13                	jmp    801510 <dev_lookup+0x23>
  8014fd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801500:	39 08                	cmp    %ecx,(%eax)
  801502:	75 0c                	jne    801510 <dev_lookup+0x23>
			*dev = devtab[i];
  801504:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801507:	89 01                	mov    %eax,(%ecx)
			return 0;
  801509:	b8 00 00 00 00       	mov    $0x0,%eax
  80150e:	eb 2e                	jmp    80153e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801510:	8b 02                	mov    (%edx),%eax
  801512:	85 c0                	test   %eax,%eax
  801514:	75 e7                	jne    8014fd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801516:	a1 20 44 80 00       	mov    0x804420,%eax
  80151b:	8b 40 7c             	mov    0x7c(%eax),%eax
  80151e:	83 ec 04             	sub    $0x4,%esp
  801521:	51                   	push   %ecx
  801522:	50                   	push   %eax
  801523:	68 08 2b 80 00       	push   $0x802b08
  801528:	e8 f3 ee ff ff       	call   800420 <cprintf>
	*dev = 0;
  80152d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801530:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80153e:	c9                   	leave  
  80153f:	c3                   	ret    

00801540 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	56                   	push   %esi
  801544:	53                   	push   %ebx
  801545:	83 ec 10             	sub    $0x10,%esp
  801548:	8b 75 08             	mov    0x8(%ebp),%esi
  80154b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80154e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801558:	c1 e8 0c             	shr    $0xc,%eax
  80155b:	50                   	push   %eax
  80155c:	e8 36 ff ff ff       	call   801497 <fd_lookup>
  801561:	83 c4 08             	add    $0x8,%esp
  801564:	85 c0                	test   %eax,%eax
  801566:	78 05                	js     80156d <fd_close+0x2d>
	    || fd != fd2)
  801568:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80156b:	74 0c                	je     801579 <fd_close+0x39>
		return (must_exist ? r : 0);
  80156d:	84 db                	test   %bl,%bl
  80156f:	ba 00 00 00 00       	mov    $0x0,%edx
  801574:	0f 44 c2             	cmove  %edx,%eax
  801577:	eb 41                	jmp    8015ba <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801579:	83 ec 08             	sub    $0x8,%esp
  80157c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157f:	50                   	push   %eax
  801580:	ff 36                	pushl  (%esi)
  801582:	e8 66 ff ff ff       	call   8014ed <dev_lookup>
  801587:	89 c3                	mov    %eax,%ebx
  801589:	83 c4 10             	add    $0x10,%esp
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 1a                	js     8015aa <fd_close+0x6a>
		if (dev->dev_close)
  801590:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801593:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801596:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80159b:	85 c0                	test   %eax,%eax
  80159d:	74 0b                	je     8015aa <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80159f:	83 ec 0c             	sub    $0xc,%esp
  8015a2:	56                   	push   %esi
  8015a3:	ff d0                	call   *%eax
  8015a5:	89 c3                	mov    %eax,%ebx
  8015a7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	56                   	push   %esi
  8015ae:	6a 00                	push   $0x0
  8015b0:	e8 78 f8 ff ff       	call   800e2d <sys_page_unmap>
	return r;
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	89 d8                	mov    %ebx,%eax
}
  8015ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015bd:	5b                   	pop    %ebx
  8015be:	5e                   	pop    %esi
  8015bf:	5d                   	pop    %ebp
  8015c0:	c3                   	ret    

008015c1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ca:	50                   	push   %eax
  8015cb:	ff 75 08             	pushl  0x8(%ebp)
  8015ce:	e8 c4 fe ff ff       	call   801497 <fd_lookup>
  8015d3:	83 c4 08             	add    $0x8,%esp
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 10                	js     8015ea <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015da:	83 ec 08             	sub    $0x8,%esp
  8015dd:	6a 01                	push   $0x1
  8015df:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e2:	e8 59 ff ff ff       	call   801540 <fd_close>
  8015e7:	83 c4 10             	add    $0x10,%esp
}
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    

008015ec <close_all>:

void
close_all(void)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	53                   	push   %ebx
  8015f0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015f3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015f8:	83 ec 0c             	sub    $0xc,%esp
  8015fb:	53                   	push   %ebx
  8015fc:	e8 c0 ff ff ff       	call   8015c1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801601:	83 c3 01             	add    $0x1,%ebx
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	83 fb 20             	cmp    $0x20,%ebx
  80160a:	75 ec                	jne    8015f8 <close_all+0xc>
		close(i);
}
  80160c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160f:	c9                   	leave  
  801610:	c3                   	ret    

00801611 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	57                   	push   %edi
  801615:	56                   	push   %esi
  801616:	53                   	push   %ebx
  801617:	83 ec 2c             	sub    $0x2c,%esp
  80161a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80161d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	ff 75 08             	pushl  0x8(%ebp)
  801624:	e8 6e fe ff ff       	call   801497 <fd_lookup>
  801629:	83 c4 08             	add    $0x8,%esp
  80162c:	85 c0                	test   %eax,%eax
  80162e:	0f 88 c1 00 00 00    	js     8016f5 <dup+0xe4>
		return r;
	close(newfdnum);
  801634:	83 ec 0c             	sub    $0xc,%esp
  801637:	56                   	push   %esi
  801638:	e8 84 ff ff ff       	call   8015c1 <close>

	newfd = INDEX2FD(newfdnum);
  80163d:	89 f3                	mov    %esi,%ebx
  80163f:	c1 e3 0c             	shl    $0xc,%ebx
  801642:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801648:	83 c4 04             	add    $0x4,%esp
  80164b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80164e:	e8 de fd ff ff       	call   801431 <fd2data>
  801653:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801655:	89 1c 24             	mov    %ebx,(%esp)
  801658:	e8 d4 fd ff ff       	call   801431 <fd2data>
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801663:	89 f8                	mov    %edi,%eax
  801665:	c1 e8 16             	shr    $0x16,%eax
  801668:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80166f:	a8 01                	test   $0x1,%al
  801671:	74 37                	je     8016aa <dup+0x99>
  801673:	89 f8                	mov    %edi,%eax
  801675:	c1 e8 0c             	shr    $0xc,%eax
  801678:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80167f:	f6 c2 01             	test   $0x1,%dl
  801682:	74 26                	je     8016aa <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801684:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80168b:	83 ec 0c             	sub    $0xc,%esp
  80168e:	25 07 0e 00 00       	and    $0xe07,%eax
  801693:	50                   	push   %eax
  801694:	ff 75 d4             	pushl  -0x2c(%ebp)
  801697:	6a 00                	push   $0x0
  801699:	57                   	push   %edi
  80169a:	6a 00                	push   $0x0
  80169c:	e8 4a f7 ff ff       	call   800deb <sys_page_map>
  8016a1:	89 c7                	mov    %eax,%edi
  8016a3:	83 c4 20             	add    $0x20,%esp
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	78 2e                	js     8016d8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016ad:	89 d0                	mov    %edx,%eax
  8016af:	c1 e8 0c             	shr    $0xc,%eax
  8016b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016b9:	83 ec 0c             	sub    $0xc,%esp
  8016bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8016c1:	50                   	push   %eax
  8016c2:	53                   	push   %ebx
  8016c3:	6a 00                	push   $0x0
  8016c5:	52                   	push   %edx
  8016c6:	6a 00                	push   $0x0
  8016c8:	e8 1e f7 ff ff       	call   800deb <sys_page_map>
  8016cd:	89 c7                	mov    %eax,%edi
  8016cf:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016d2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016d4:	85 ff                	test   %edi,%edi
  8016d6:	79 1d                	jns    8016f5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016d8:	83 ec 08             	sub    $0x8,%esp
  8016db:	53                   	push   %ebx
  8016dc:	6a 00                	push   $0x0
  8016de:	e8 4a f7 ff ff       	call   800e2d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016e3:	83 c4 08             	add    $0x8,%esp
  8016e6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016e9:	6a 00                	push   $0x0
  8016eb:	e8 3d f7 ff ff       	call   800e2d <sys_page_unmap>
	return r;
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	89 f8                	mov    %edi,%eax
}
  8016f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f8:	5b                   	pop    %ebx
  8016f9:	5e                   	pop    %esi
  8016fa:	5f                   	pop    %edi
  8016fb:	5d                   	pop    %ebp
  8016fc:	c3                   	ret    

008016fd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	53                   	push   %ebx
  801701:	83 ec 14             	sub    $0x14,%esp
  801704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801707:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170a:	50                   	push   %eax
  80170b:	53                   	push   %ebx
  80170c:	e8 86 fd ff ff       	call   801497 <fd_lookup>
  801711:	83 c4 08             	add    $0x8,%esp
  801714:	89 c2                	mov    %eax,%edx
  801716:	85 c0                	test   %eax,%eax
  801718:	78 6d                	js     801787 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171a:	83 ec 08             	sub    $0x8,%esp
  80171d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801720:	50                   	push   %eax
  801721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801724:	ff 30                	pushl  (%eax)
  801726:	e8 c2 fd ff ff       	call   8014ed <dev_lookup>
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 4c                	js     80177e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801732:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801735:	8b 42 08             	mov    0x8(%edx),%eax
  801738:	83 e0 03             	and    $0x3,%eax
  80173b:	83 f8 01             	cmp    $0x1,%eax
  80173e:	75 21                	jne    801761 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801740:	a1 20 44 80 00       	mov    0x804420,%eax
  801745:	8b 40 7c             	mov    0x7c(%eax),%eax
  801748:	83 ec 04             	sub    $0x4,%esp
  80174b:	53                   	push   %ebx
  80174c:	50                   	push   %eax
  80174d:	68 4c 2b 80 00       	push   $0x802b4c
  801752:	e8 c9 ec ff ff       	call   800420 <cprintf>
		return -E_INVAL;
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80175f:	eb 26                	jmp    801787 <read+0x8a>
	}
	if (!dev->dev_read)
  801761:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801764:	8b 40 08             	mov    0x8(%eax),%eax
  801767:	85 c0                	test   %eax,%eax
  801769:	74 17                	je     801782 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80176b:	83 ec 04             	sub    $0x4,%esp
  80176e:	ff 75 10             	pushl  0x10(%ebp)
  801771:	ff 75 0c             	pushl  0xc(%ebp)
  801774:	52                   	push   %edx
  801775:	ff d0                	call   *%eax
  801777:	89 c2                	mov    %eax,%edx
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	eb 09                	jmp    801787 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177e:	89 c2                	mov    %eax,%edx
  801780:	eb 05                	jmp    801787 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801782:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801787:	89 d0                	mov    %edx,%eax
  801789:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    

0080178e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	57                   	push   %edi
  801792:	56                   	push   %esi
  801793:	53                   	push   %ebx
  801794:	83 ec 0c             	sub    $0xc,%esp
  801797:	8b 7d 08             	mov    0x8(%ebp),%edi
  80179a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80179d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017a2:	eb 21                	jmp    8017c5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017a4:	83 ec 04             	sub    $0x4,%esp
  8017a7:	89 f0                	mov    %esi,%eax
  8017a9:	29 d8                	sub    %ebx,%eax
  8017ab:	50                   	push   %eax
  8017ac:	89 d8                	mov    %ebx,%eax
  8017ae:	03 45 0c             	add    0xc(%ebp),%eax
  8017b1:	50                   	push   %eax
  8017b2:	57                   	push   %edi
  8017b3:	e8 45 ff ff ff       	call   8016fd <read>
		if (m < 0)
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	78 10                	js     8017cf <readn+0x41>
			return m;
		if (m == 0)
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	74 0a                	je     8017cd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017c3:	01 c3                	add    %eax,%ebx
  8017c5:	39 f3                	cmp    %esi,%ebx
  8017c7:	72 db                	jb     8017a4 <readn+0x16>
  8017c9:	89 d8                	mov    %ebx,%eax
  8017cb:	eb 02                	jmp    8017cf <readn+0x41>
  8017cd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d2:	5b                   	pop    %ebx
  8017d3:	5e                   	pop    %esi
  8017d4:	5f                   	pop    %edi
  8017d5:	5d                   	pop    %ebp
  8017d6:	c3                   	ret    

008017d7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	53                   	push   %ebx
  8017db:	83 ec 14             	sub    $0x14,%esp
  8017de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e4:	50                   	push   %eax
  8017e5:	53                   	push   %ebx
  8017e6:	e8 ac fc ff ff       	call   801497 <fd_lookup>
  8017eb:	83 c4 08             	add    $0x8,%esp
  8017ee:	89 c2                	mov    %eax,%edx
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	78 68                	js     80185c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f4:	83 ec 08             	sub    $0x8,%esp
  8017f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fa:	50                   	push   %eax
  8017fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fe:	ff 30                	pushl  (%eax)
  801800:	e8 e8 fc ff ff       	call   8014ed <dev_lookup>
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	85 c0                	test   %eax,%eax
  80180a:	78 47                	js     801853 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80180c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801813:	75 21                	jne    801836 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801815:	a1 20 44 80 00       	mov    0x804420,%eax
  80181a:	8b 40 7c             	mov    0x7c(%eax),%eax
  80181d:	83 ec 04             	sub    $0x4,%esp
  801820:	53                   	push   %ebx
  801821:	50                   	push   %eax
  801822:	68 68 2b 80 00       	push   $0x802b68
  801827:	e8 f4 eb ff ff       	call   800420 <cprintf>
		return -E_INVAL;
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801834:	eb 26                	jmp    80185c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801836:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801839:	8b 52 0c             	mov    0xc(%edx),%edx
  80183c:	85 d2                	test   %edx,%edx
  80183e:	74 17                	je     801857 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801840:	83 ec 04             	sub    $0x4,%esp
  801843:	ff 75 10             	pushl  0x10(%ebp)
  801846:	ff 75 0c             	pushl  0xc(%ebp)
  801849:	50                   	push   %eax
  80184a:	ff d2                	call   *%edx
  80184c:	89 c2                	mov    %eax,%edx
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	eb 09                	jmp    80185c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801853:	89 c2                	mov    %eax,%edx
  801855:	eb 05                	jmp    80185c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801857:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80185c:	89 d0                	mov    %edx,%eax
  80185e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <seek>:

int
seek(int fdnum, off_t offset)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801869:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80186c:	50                   	push   %eax
  80186d:	ff 75 08             	pushl  0x8(%ebp)
  801870:	e8 22 fc ff ff       	call   801497 <fd_lookup>
  801875:	83 c4 08             	add    $0x8,%esp
  801878:	85 c0                	test   %eax,%eax
  80187a:	78 0e                	js     80188a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80187c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80187f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801882:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801885:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	53                   	push   %ebx
  801890:	83 ec 14             	sub    $0x14,%esp
  801893:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801896:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801899:	50                   	push   %eax
  80189a:	53                   	push   %ebx
  80189b:	e8 f7 fb ff ff       	call   801497 <fd_lookup>
  8018a0:	83 c4 08             	add    $0x8,%esp
  8018a3:	89 c2                	mov    %eax,%edx
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	78 65                	js     80190e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a9:	83 ec 08             	sub    $0x8,%esp
  8018ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018af:	50                   	push   %eax
  8018b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b3:	ff 30                	pushl  (%eax)
  8018b5:	e8 33 fc ff ff       	call   8014ed <dev_lookup>
  8018ba:	83 c4 10             	add    $0x10,%esp
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	78 44                	js     801905 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018c8:	75 21                	jne    8018eb <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018ca:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018cf:	8b 40 7c             	mov    0x7c(%eax),%eax
  8018d2:	83 ec 04             	sub    $0x4,%esp
  8018d5:	53                   	push   %ebx
  8018d6:	50                   	push   %eax
  8018d7:	68 28 2b 80 00       	push   $0x802b28
  8018dc:	e8 3f eb ff ff       	call   800420 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018e9:	eb 23                	jmp    80190e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ee:	8b 52 18             	mov    0x18(%edx),%edx
  8018f1:	85 d2                	test   %edx,%edx
  8018f3:	74 14                	je     801909 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018f5:	83 ec 08             	sub    $0x8,%esp
  8018f8:	ff 75 0c             	pushl  0xc(%ebp)
  8018fb:	50                   	push   %eax
  8018fc:	ff d2                	call   *%edx
  8018fe:	89 c2                	mov    %eax,%edx
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	eb 09                	jmp    80190e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801905:	89 c2                	mov    %eax,%edx
  801907:	eb 05                	jmp    80190e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801909:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80190e:	89 d0                	mov    %edx,%eax
  801910:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801913:	c9                   	leave  
  801914:	c3                   	ret    

00801915 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	53                   	push   %ebx
  801919:	83 ec 14             	sub    $0x14,%esp
  80191c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80191f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801922:	50                   	push   %eax
  801923:	ff 75 08             	pushl  0x8(%ebp)
  801926:	e8 6c fb ff ff       	call   801497 <fd_lookup>
  80192b:	83 c4 08             	add    $0x8,%esp
  80192e:	89 c2                	mov    %eax,%edx
  801930:	85 c0                	test   %eax,%eax
  801932:	78 58                	js     80198c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193a:	50                   	push   %eax
  80193b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193e:	ff 30                	pushl  (%eax)
  801940:	e8 a8 fb ff ff       	call   8014ed <dev_lookup>
  801945:	83 c4 10             	add    $0x10,%esp
  801948:	85 c0                	test   %eax,%eax
  80194a:	78 37                	js     801983 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80194c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801953:	74 32                	je     801987 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801955:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801958:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80195f:	00 00 00 
	stat->st_isdir = 0;
  801962:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801969:	00 00 00 
	stat->st_dev = dev;
  80196c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801972:	83 ec 08             	sub    $0x8,%esp
  801975:	53                   	push   %ebx
  801976:	ff 75 f0             	pushl  -0x10(%ebp)
  801979:	ff 50 14             	call   *0x14(%eax)
  80197c:	89 c2                	mov    %eax,%edx
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	eb 09                	jmp    80198c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801983:	89 c2                	mov    %eax,%edx
  801985:	eb 05                	jmp    80198c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801987:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80198c:	89 d0                	mov    %edx,%eax
  80198e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801991:	c9                   	leave  
  801992:	c3                   	ret    

00801993 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	56                   	push   %esi
  801997:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801998:	83 ec 08             	sub    $0x8,%esp
  80199b:	6a 00                	push   $0x0
  80199d:	ff 75 08             	pushl  0x8(%ebp)
  8019a0:	e8 e3 01 00 00       	call   801b88 <open>
  8019a5:	89 c3                	mov    %eax,%ebx
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	78 1b                	js     8019c9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019ae:	83 ec 08             	sub    $0x8,%esp
  8019b1:	ff 75 0c             	pushl  0xc(%ebp)
  8019b4:	50                   	push   %eax
  8019b5:	e8 5b ff ff ff       	call   801915 <fstat>
  8019ba:	89 c6                	mov    %eax,%esi
	close(fd);
  8019bc:	89 1c 24             	mov    %ebx,(%esp)
  8019bf:	e8 fd fb ff ff       	call   8015c1 <close>
	return r;
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	89 f0                	mov    %esi,%eax
}
  8019c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019cc:	5b                   	pop    %ebx
  8019cd:	5e                   	pop    %esi
  8019ce:	5d                   	pop    %ebp
  8019cf:	c3                   	ret    

008019d0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	56                   	push   %esi
  8019d4:	53                   	push   %ebx
  8019d5:	89 c6                	mov    %eax,%esi
  8019d7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019d9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019e0:	75 12                	jne    8019f4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019e2:	83 ec 0c             	sub    $0xc,%esp
  8019e5:	6a 01                	push   $0x1
  8019e7:	e8 a4 09 00 00       	call   802390 <ipc_find_env>
  8019ec:	a3 00 40 80 00       	mov    %eax,0x804000
  8019f1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019f4:	6a 07                	push   $0x7
  8019f6:	68 00 50 80 00       	push   $0x805000
  8019fb:	56                   	push   %esi
  8019fc:	ff 35 00 40 80 00    	pushl  0x804000
  801a02:	e8 27 09 00 00       	call   80232e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a07:	83 c4 0c             	add    $0xc,%esp
  801a0a:	6a 00                	push   $0x0
  801a0c:	53                   	push   %ebx
  801a0d:	6a 00                	push   $0x0
  801a0f:	e8 9f 08 00 00       	call   8022b3 <ipc_recv>
}
  801a14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a17:	5b                   	pop    %ebx
  801a18:	5e                   	pop    %esi
  801a19:	5d                   	pop    %ebp
  801a1a:	c3                   	ret    

00801a1b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a21:	8b 45 08             	mov    0x8(%ebp),%eax
  801a24:	8b 40 0c             	mov    0xc(%eax),%eax
  801a27:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a34:	ba 00 00 00 00       	mov    $0x0,%edx
  801a39:	b8 02 00 00 00       	mov    $0x2,%eax
  801a3e:	e8 8d ff ff ff       	call   8019d0 <fsipc>
}
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    

00801a45 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a51:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a56:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5b:	b8 06 00 00 00       	mov    $0x6,%eax
  801a60:	e8 6b ff ff ff       	call   8019d0 <fsipc>
}
  801a65:	c9                   	leave  
  801a66:	c3                   	ret    

00801a67 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	53                   	push   %ebx
  801a6b:	83 ec 04             	sub    $0x4,%esp
  801a6e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a71:	8b 45 08             	mov    0x8(%ebp),%eax
  801a74:	8b 40 0c             	mov    0xc(%eax),%eax
  801a77:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a7c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a81:	b8 05 00 00 00       	mov    $0x5,%eax
  801a86:	e8 45 ff ff ff       	call   8019d0 <fsipc>
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	78 2c                	js     801abb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a8f:	83 ec 08             	sub    $0x8,%esp
  801a92:	68 00 50 80 00       	push   $0x805000
  801a97:	53                   	push   %ebx
  801a98:	e8 08 ef ff ff       	call   8009a5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a9d:	a1 80 50 80 00       	mov    0x805080,%eax
  801aa2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801aa8:	a1 84 50 80 00       	mov    0x805084,%eax
  801aad:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801abb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 0c             	sub    $0xc,%esp
  801ac6:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ac9:	8b 55 08             	mov    0x8(%ebp),%edx
  801acc:	8b 52 0c             	mov    0xc(%edx),%edx
  801acf:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801ad5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ada:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801adf:	0f 47 c2             	cmova  %edx,%eax
  801ae2:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801ae7:	50                   	push   %eax
  801ae8:	ff 75 0c             	pushl  0xc(%ebp)
  801aeb:	68 08 50 80 00       	push   $0x805008
  801af0:	e8 42 f0 ff ff       	call   800b37 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801af5:	ba 00 00 00 00       	mov    $0x0,%edx
  801afa:	b8 04 00 00 00       	mov    $0x4,%eax
  801aff:	e8 cc fe ff ff       	call   8019d0 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b04:	c9                   	leave  
  801b05:	c3                   	ret    

00801b06 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	56                   	push   %esi
  801b0a:	53                   	push   %ebx
  801b0b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b11:	8b 40 0c             	mov    0xc(%eax),%eax
  801b14:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b19:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b24:	b8 03 00 00 00       	mov    $0x3,%eax
  801b29:	e8 a2 fe ff ff       	call   8019d0 <fsipc>
  801b2e:	89 c3                	mov    %eax,%ebx
  801b30:	85 c0                	test   %eax,%eax
  801b32:	78 4b                	js     801b7f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b34:	39 c6                	cmp    %eax,%esi
  801b36:	73 16                	jae    801b4e <devfile_read+0x48>
  801b38:	68 98 2b 80 00       	push   $0x802b98
  801b3d:	68 9f 2b 80 00       	push   $0x802b9f
  801b42:	6a 7c                	push   $0x7c
  801b44:	68 b4 2b 80 00       	push   $0x802bb4
  801b49:	e8 f9 e7 ff ff       	call   800347 <_panic>
	assert(r <= PGSIZE);
  801b4e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b53:	7e 16                	jle    801b6b <devfile_read+0x65>
  801b55:	68 bf 2b 80 00       	push   $0x802bbf
  801b5a:	68 9f 2b 80 00       	push   $0x802b9f
  801b5f:	6a 7d                	push   $0x7d
  801b61:	68 b4 2b 80 00       	push   $0x802bb4
  801b66:	e8 dc e7 ff ff       	call   800347 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b6b:	83 ec 04             	sub    $0x4,%esp
  801b6e:	50                   	push   %eax
  801b6f:	68 00 50 80 00       	push   $0x805000
  801b74:	ff 75 0c             	pushl  0xc(%ebp)
  801b77:	e8 bb ef ff ff       	call   800b37 <memmove>
	return r;
  801b7c:	83 c4 10             	add    $0x10,%esp
}
  801b7f:	89 d8                	mov    %ebx,%eax
  801b81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b84:	5b                   	pop    %ebx
  801b85:	5e                   	pop    %esi
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    

00801b88 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	53                   	push   %ebx
  801b8c:	83 ec 20             	sub    $0x20,%esp
  801b8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b92:	53                   	push   %ebx
  801b93:	e8 d4 ed ff ff       	call   80096c <strlen>
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ba0:	7f 67                	jg     801c09 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ba2:	83 ec 0c             	sub    $0xc,%esp
  801ba5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba8:	50                   	push   %eax
  801ba9:	e8 9a f8 ff ff       	call   801448 <fd_alloc>
  801bae:	83 c4 10             	add    $0x10,%esp
		return r;
  801bb1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	78 57                	js     801c0e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bb7:	83 ec 08             	sub    $0x8,%esp
  801bba:	53                   	push   %ebx
  801bbb:	68 00 50 80 00       	push   $0x805000
  801bc0:	e8 e0 ed ff ff       	call   8009a5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bcd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd0:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd5:	e8 f6 fd ff ff       	call   8019d0 <fsipc>
  801bda:	89 c3                	mov    %eax,%ebx
  801bdc:	83 c4 10             	add    $0x10,%esp
  801bdf:	85 c0                	test   %eax,%eax
  801be1:	79 14                	jns    801bf7 <open+0x6f>
		fd_close(fd, 0);
  801be3:	83 ec 08             	sub    $0x8,%esp
  801be6:	6a 00                	push   $0x0
  801be8:	ff 75 f4             	pushl  -0xc(%ebp)
  801beb:	e8 50 f9 ff ff       	call   801540 <fd_close>
		return r;
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	89 da                	mov    %ebx,%edx
  801bf5:	eb 17                	jmp    801c0e <open+0x86>
	}

	return fd2num(fd);
  801bf7:	83 ec 0c             	sub    $0xc,%esp
  801bfa:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfd:	e8 1f f8 ff ff       	call   801421 <fd2num>
  801c02:	89 c2                	mov    %eax,%edx
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	eb 05                	jmp    801c0e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c09:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c0e:	89 d0                	mov    %edx,%eax
  801c10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c13:	c9                   	leave  
  801c14:	c3                   	ret    

00801c15 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c20:	b8 08 00 00 00       	mov    $0x8,%eax
  801c25:	e8 a6 fd ff ff       	call   8019d0 <fsipc>
}
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801c2c:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801c30:	7e 37                	jle    801c69 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	53                   	push   %ebx
  801c36:	83 ec 08             	sub    $0x8,%esp
  801c39:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801c3b:	ff 70 04             	pushl  0x4(%eax)
  801c3e:	8d 40 10             	lea    0x10(%eax),%eax
  801c41:	50                   	push   %eax
  801c42:	ff 33                	pushl  (%ebx)
  801c44:	e8 8e fb ff ff       	call   8017d7 <write>
		if (result > 0)
  801c49:	83 c4 10             	add    $0x10,%esp
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	7e 03                	jle    801c53 <writebuf+0x27>
			b->result += result;
  801c50:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801c53:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c56:	74 0d                	je     801c65 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801c5f:	0f 4f c2             	cmovg  %edx,%eax
  801c62:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801c65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c68:	c9                   	leave  
  801c69:	f3 c3                	repz ret 

00801c6b <putch>:

static void
putch(int ch, void *thunk)
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	53                   	push   %ebx
  801c6f:	83 ec 04             	sub    $0x4,%esp
  801c72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801c75:	8b 53 04             	mov    0x4(%ebx),%edx
  801c78:	8d 42 01             	lea    0x1(%edx),%eax
  801c7b:	89 43 04             	mov    %eax,0x4(%ebx)
  801c7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c81:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801c85:	3d 00 01 00 00       	cmp    $0x100,%eax
  801c8a:	75 0e                	jne    801c9a <putch+0x2f>
		writebuf(b);
  801c8c:	89 d8                	mov    %ebx,%eax
  801c8e:	e8 99 ff ff ff       	call   801c2c <writebuf>
		b->idx = 0;
  801c93:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801c9a:	83 c4 04             	add    $0x4,%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5d                   	pop    %ebp
  801c9f:	c3                   	ret    

00801ca0 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cac:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801cb2:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801cb9:	00 00 00 
	b.result = 0;
  801cbc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801cc3:	00 00 00 
	b.error = 1;
  801cc6:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801ccd:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801cd0:	ff 75 10             	pushl  0x10(%ebp)
  801cd3:	ff 75 0c             	pushl  0xc(%ebp)
  801cd6:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801cdc:	50                   	push   %eax
  801cdd:	68 6b 1c 80 00       	push   $0x801c6b
  801ce2:	e8 70 e8 ff ff       	call   800557 <vprintfmt>
	if (b.idx > 0)
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801cf1:	7e 0b                	jle    801cfe <vfprintf+0x5e>
		writebuf(&b);
  801cf3:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801cf9:	e8 2e ff ff ff       	call   801c2c <writebuf>

	return (b.result ? b.result : b.error);
  801cfe:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801d04:	85 c0                	test   %eax,%eax
  801d06:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d15:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801d18:	50                   	push   %eax
  801d19:	ff 75 0c             	pushl  0xc(%ebp)
  801d1c:	ff 75 08             	pushl  0x8(%ebp)
  801d1f:	e8 7c ff ff ff       	call   801ca0 <vfprintf>
	va_end(ap);

	return cnt;
}
  801d24:	c9                   	leave  
  801d25:	c3                   	ret    

00801d26 <printf>:

int
printf(const char *fmt, ...)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d2c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801d2f:	50                   	push   %eax
  801d30:	ff 75 08             	pushl  0x8(%ebp)
  801d33:	6a 01                	push   $0x1
  801d35:	e8 66 ff ff ff       	call   801ca0 <vfprintf>
	va_end(ap);

	return cnt;
}
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    

00801d3c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	56                   	push   %esi
  801d40:	53                   	push   %ebx
  801d41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d44:	83 ec 0c             	sub    $0xc,%esp
  801d47:	ff 75 08             	pushl  0x8(%ebp)
  801d4a:	e8 e2 f6 ff ff       	call   801431 <fd2data>
  801d4f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d51:	83 c4 08             	add    $0x8,%esp
  801d54:	68 cb 2b 80 00       	push   $0x802bcb
  801d59:	53                   	push   %ebx
  801d5a:	e8 46 ec ff ff       	call   8009a5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d5f:	8b 46 04             	mov    0x4(%esi),%eax
  801d62:	2b 06                	sub    (%esi),%eax
  801d64:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d6a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d71:	00 00 00 
	stat->st_dev = &devpipe;
  801d74:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801d7b:	30 80 00 
	return 0;
}
  801d7e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d86:	5b                   	pop    %ebx
  801d87:	5e                   	pop    %esi
  801d88:	5d                   	pop    %ebp
  801d89:	c3                   	ret    

00801d8a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	53                   	push   %ebx
  801d8e:	83 ec 0c             	sub    $0xc,%esp
  801d91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d94:	53                   	push   %ebx
  801d95:	6a 00                	push   $0x0
  801d97:	e8 91 f0 ff ff       	call   800e2d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d9c:	89 1c 24             	mov    %ebx,(%esp)
  801d9f:	e8 8d f6 ff ff       	call   801431 <fd2data>
  801da4:	83 c4 08             	add    $0x8,%esp
  801da7:	50                   	push   %eax
  801da8:	6a 00                	push   $0x0
  801daa:	e8 7e f0 ff ff       	call   800e2d <sys_page_unmap>
}
  801daf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	57                   	push   %edi
  801db8:	56                   	push   %esi
  801db9:	53                   	push   %ebx
  801dba:	83 ec 1c             	sub    $0x1c,%esp
  801dbd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801dc0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801dc2:	a1 20 44 80 00       	mov    0x804420,%eax
  801dc7:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801dcd:	83 ec 0c             	sub    $0xc,%esp
  801dd0:	ff 75 e0             	pushl  -0x20(%ebp)
  801dd3:	e8 fa 05 00 00       	call   8023d2 <pageref>
  801dd8:	89 c3                	mov    %eax,%ebx
  801dda:	89 3c 24             	mov    %edi,(%esp)
  801ddd:	e8 f0 05 00 00       	call   8023d2 <pageref>
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	39 c3                	cmp    %eax,%ebx
  801de7:	0f 94 c1             	sete   %cl
  801dea:	0f b6 c9             	movzbl %cl,%ecx
  801ded:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801df0:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801df6:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801dfc:	39 ce                	cmp    %ecx,%esi
  801dfe:	74 1e                	je     801e1e <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801e00:	39 c3                	cmp    %eax,%ebx
  801e02:	75 be                	jne    801dc2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e04:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801e0a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e0d:	50                   	push   %eax
  801e0e:	56                   	push   %esi
  801e0f:	68 d2 2b 80 00       	push   $0x802bd2
  801e14:	e8 07 e6 ff ff       	call   800420 <cprintf>
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	eb a4                	jmp    801dc2 <_pipeisclosed+0xe>
	}
}
  801e1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e24:	5b                   	pop    %ebx
  801e25:	5e                   	pop    %esi
  801e26:	5f                   	pop    %edi
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    

00801e29 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	57                   	push   %edi
  801e2d:	56                   	push   %esi
  801e2e:	53                   	push   %ebx
  801e2f:	83 ec 28             	sub    $0x28,%esp
  801e32:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e35:	56                   	push   %esi
  801e36:	e8 f6 f5 ff ff       	call   801431 <fd2data>
  801e3b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e3d:	83 c4 10             	add    $0x10,%esp
  801e40:	bf 00 00 00 00       	mov    $0x0,%edi
  801e45:	eb 4b                	jmp    801e92 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e47:	89 da                	mov    %ebx,%edx
  801e49:	89 f0                	mov    %esi,%eax
  801e4b:	e8 64 ff ff ff       	call   801db4 <_pipeisclosed>
  801e50:	85 c0                	test   %eax,%eax
  801e52:	75 48                	jne    801e9c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e54:	e8 30 ef ff ff       	call   800d89 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e59:	8b 43 04             	mov    0x4(%ebx),%eax
  801e5c:	8b 0b                	mov    (%ebx),%ecx
  801e5e:	8d 51 20             	lea    0x20(%ecx),%edx
  801e61:	39 d0                	cmp    %edx,%eax
  801e63:	73 e2                	jae    801e47 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e68:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e6c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e6f:	89 c2                	mov    %eax,%edx
  801e71:	c1 fa 1f             	sar    $0x1f,%edx
  801e74:	89 d1                	mov    %edx,%ecx
  801e76:	c1 e9 1b             	shr    $0x1b,%ecx
  801e79:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e7c:	83 e2 1f             	and    $0x1f,%edx
  801e7f:	29 ca                	sub    %ecx,%edx
  801e81:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e85:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e89:	83 c0 01             	add    $0x1,%eax
  801e8c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e8f:	83 c7 01             	add    $0x1,%edi
  801e92:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e95:	75 c2                	jne    801e59 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e97:	8b 45 10             	mov    0x10(%ebp),%eax
  801e9a:	eb 05                	jmp    801ea1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e9c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ea1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea4:	5b                   	pop    %ebx
  801ea5:	5e                   	pop    %esi
  801ea6:	5f                   	pop    %edi
  801ea7:	5d                   	pop    %ebp
  801ea8:	c3                   	ret    

00801ea9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	57                   	push   %edi
  801ead:	56                   	push   %esi
  801eae:	53                   	push   %ebx
  801eaf:	83 ec 18             	sub    $0x18,%esp
  801eb2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801eb5:	57                   	push   %edi
  801eb6:	e8 76 f5 ff ff       	call   801431 <fd2data>
  801ebb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ebd:	83 c4 10             	add    $0x10,%esp
  801ec0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ec5:	eb 3d                	jmp    801f04 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ec7:	85 db                	test   %ebx,%ebx
  801ec9:	74 04                	je     801ecf <devpipe_read+0x26>
				return i;
  801ecb:	89 d8                	mov    %ebx,%eax
  801ecd:	eb 44                	jmp    801f13 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ecf:	89 f2                	mov    %esi,%edx
  801ed1:	89 f8                	mov    %edi,%eax
  801ed3:	e8 dc fe ff ff       	call   801db4 <_pipeisclosed>
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	75 32                	jne    801f0e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801edc:	e8 a8 ee ff ff       	call   800d89 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ee1:	8b 06                	mov    (%esi),%eax
  801ee3:	3b 46 04             	cmp    0x4(%esi),%eax
  801ee6:	74 df                	je     801ec7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ee8:	99                   	cltd   
  801ee9:	c1 ea 1b             	shr    $0x1b,%edx
  801eec:	01 d0                	add    %edx,%eax
  801eee:	83 e0 1f             	and    $0x1f,%eax
  801ef1:	29 d0                	sub    %edx,%eax
  801ef3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801efb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801efe:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f01:	83 c3 01             	add    $0x1,%ebx
  801f04:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f07:	75 d8                	jne    801ee1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f09:	8b 45 10             	mov    0x10(%ebp),%eax
  801f0c:	eb 05                	jmp    801f13 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f0e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f16:	5b                   	pop    %ebx
  801f17:	5e                   	pop    %esi
  801f18:	5f                   	pop    %edi
  801f19:	5d                   	pop    %ebp
  801f1a:	c3                   	ret    

00801f1b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	56                   	push   %esi
  801f1f:	53                   	push   %ebx
  801f20:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f26:	50                   	push   %eax
  801f27:	e8 1c f5 ff ff       	call   801448 <fd_alloc>
  801f2c:	83 c4 10             	add    $0x10,%esp
  801f2f:	89 c2                	mov    %eax,%edx
  801f31:	85 c0                	test   %eax,%eax
  801f33:	0f 88 2c 01 00 00    	js     802065 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f39:	83 ec 04             	sub    $0x4,%esp
  801f3c:	68 07 04 00 00       	push   $0x407
  801f41:	ff 75 f4             	pushl  -0xc(%ebp)
  801f44:	6a 00                	push   $0x0
  801f46:	e8 5d ee ff ff       	call   800da8 <sys_page_alloc>
  801f4b:	83 c4 10             	add    $0x10,%esp
  801f4e:	89 c2                	mov    %eax,%edx
  801f50:	85 c0                	test   %eax,%eax
  801f52:	0f 88 0d 01 00 00    	js     802065 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f58:	83 ec 0c             	sub    $0xc,%esp
  801f5b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f5e:	50                   	push   %eax
  801f5f:	e8 e4 f4 ff ff       	call   801448 <fd_alloc>
  801f64:	89 c3                	mov    %eax,%ebx
  801f66:	83 c4 10             	add    $0x10,%esp
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	0f 88 e2 00 00 00    	js     802053 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f71:	83 ec 04             	sub    $0x4,%esp
  801f74:	68 07 04 00 00       	push   $0x407
  801f79:	ff 75 f0             	pushl  -0x10(%ebp)
  801f7c:	6a 00                	push   $0x0
  801f7e:	e8 25 ee ff ff       	call   800da8 <sys_page_alloc>
  801f83:	89 c3                	mov    %eax,%ebx
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	0f 88 c3 00 00 00    	js     802053 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f90:	83 ec 0c             	sub    $0xc,%esp
  801f93:	ff 75 f4             	pushl  -0xc(%ebp)
  801f96:	e8 96 f4 ff ff       	call   801431 <fd2data>
  801f9b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f9d:	83 c4 0c             	add    $0xc,%esp
  801fa0:	68 07 04 00 00       	push   $0x407
  801fa5:	50                   	push   %eax
  801fa6:	6a 00                	push   $0x0
  801fa8:	e8 fb ed ff ff       	call   800da8 <sys_page_alloc>
  801fad:	89 c3                	mov    %eax,%ebx
  801faf:	83 c4 10             	add    $0x10,%esp
  801fb2:	85 c0                	test   %eax,%eax
  801fb4:	0f 88 89 00 00 00    	js     802043 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fba:	83 ec 0c             	sub    $0xc,%esp
  801fbd:	ff 75 f0             	pushl  -0x10(%ebp)
  801fc0:	e8 6c f4 ff ff       	call   801431 <fd2data>
  801fc5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801fcc:	50                   	push   %eax
  801fcd:	6a 00                	push   $0x0
  801fcf:	56                   	push   %esi
  801fd0:	6a 00                	push   $0x0
  801fd2:	e8 14 ee ff ff       	call   800deb <sys_page_map>
  801fd7:	89 c3                	mov    %eax,%ebx
  801fd9:	83 c4 20             	add    $0x20,%esp
  801fdc:	85 c0                	test   %eax,%eax
  801fde:	78 55                	js     802035 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fe0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fee:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ff5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ffb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ffe:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802000:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802003:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80200a:	83 ec 0c             	sub    $0xc,%esp
  80200d:	ff 75 f4             	pushl  -0xc(%ebp)
  802010:	e8 0c f4 ff ff       	call   801421 <fd2num>
  802015:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802018:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80201a:	83 c4 04             	add    $0x4,%esp
  80201d:	ff 75 f0             	pushl  -0x10(%ebp)
  802020:	e8 fc f3 ff ff       	call   801421 <fd2num>
  802025:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802028:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80202b:	83 c4 10             	add    $0x10,%esp
  80202e:	ba 00 00 00 00       	mov    $0x0,%edx
  802033:	eb 30                	jmp    802065 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802035:	83 ec 08             	sub    $0x8,%esp
  802038:	56                   	push   %esi
  802039:	6a 00                	push   $0x0
  80203b:	e8 ed ed ff ff       	call   800e2d <sys_page_unmap>
  802040:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802043:	83 ec 08             	sub    $0x8,%esp
  802046:	ff 75 f0             	pushl  -0x10(%ebp)
  802049:	6a 00                	push   $0x0
  80204b:	e8 dd ed ff ff       	call   800e2d <sys_page_unmap>
  802050:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802053:	83 ec 08             	sub    $0x8,%esp
  802056:	ff 75 f4             	pushl  -0xc(%ebp)
  802059:	6a 00                	push   $0x0
  80205b:	e8 cd ed ff ff       	call   800e2d <sys_page_unmap>
  802060:	83 c4 10             	add    $0x10,%esp
  802063:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802065:	89 d0                	mov    %edx,%eax
  802067:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80206a:	5b                   	pop    %ebx
  80206b:	5e                   	pop    %esi
  80206c:	5d                   	pop    %ebp
  80206d:	c3                   	ret    

0080206e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80206e:	55                   	push   %ebp
  80206f:	89 e5                	mov    %esp,%ebp
  802071:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802074:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802077:	50                   	push   %eax
  802078:	ff 75 08             	pushl  0x8(%ebp)
  80207b:	e8 17 f4 ff ff       	call   801497 <fd_lookup>
  802080:	83 c4 10             	add    $0x10,%esp
  802083:	85 c0                	test   %eax,%eax
  802085:	78 18                	js     80209f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802087:	83 ec 0c             	sub    $0xc,%esp
  80208a:	ff 75 f4             	pushl  -0xc(%ebp)
  80208d:	e8 9f f3 ff ff       	call   801431 <fd2data>
	return _pipeisclosed(fd, p);
  802092:	89 c2                	mov    %eax,%edx
  802094:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802097:	e8 18 fd ff ff       	call   801db4 <_pipeisclosed>
  80209c:	83 c4 10             	add    $0x10,%esp
}
  80209f:	c9                   	leave  
  8020a0:	c3                   	ret    

008020a1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020a1:	55                   	push   %ebp
  8020a2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8020a9:	5d                   	pop    %ebp
  8020aa:	c3                   	ret    

008020ab <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020b1:	68 ea 2b 80 00       	push   $0x802bea
  8020b6:	ff 75 0c             	pushl  0xc(%ebp)
  8020b9:	e8 e7 e8 ff ff       	call   8009a5 <strcpy>
	return 0;
}
  8020be:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c3:	c9                   	leave  
  8020c4:	c3                   	ret    

008020c5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020c5:	55                   	push   %ebp
  8020c6:	89 e5                	mov    %esp,%ebp
  8020c8:	57                   	push   %edi
  8020c9:	56                   	push   %esi
  8020ca:	53                   	push   %ebx
  8020cb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020d1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020d6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020dc:	eb 2d                	jmp    80210b <devcons_write+0x46>
		m = n - tot;
  8020de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020e1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8020e3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020e6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020eb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020ee:	83 ec 04             	sub    $0x4,%esp
  8020f1:	53                   	push   %ebx
  8020f2:	03 45 0c             	add    0xc(%ebp),%eax
  8020f5:	50                   	push   %eax
  8020f6:	57                   	push   %edi
  8020f7:	e8 3b ea ff ff       	call   800b37 <memmove>
		sys_cputs(buf, m);
  8020fc:	83 c4 08             	add    $0x8,%esp
  8020ff:	53                   	push   %ebx
  802100:	57                   	push   %edi
  802101:	e8 e6 eb ff ff       	call   800cec <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802106:	01 de                	add    %ebx,%esi
  802108:	83 c4 10             	add    $0x10,%esp
  80210b:	89 f0                	mov    %esi,%eax
  80210d:	3b 75 10             	cmp    0x10(%ebp),%esi
  802110:	72 cc                	jb     8020de <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802115:	5b                   	pop    %ebx
  802116:	5e                   	pop    %esi
  802117:	5f                   	pop    %edi
  802118:	5d                   	pop    %ebp
  802119:	c3                   	ret    

0080211a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80211a:	55                   	push   %ebp
  80211b:	89 e5                	mov    %esp,%ebp
  80211d:	83 ec 08             	sub    $0x8,%esp
  802120:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802125:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802129:	74 2a                	je     802155 <devcons_read+0x3b>
  80212b:	eb 05                	jmp    802132 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80212d:	e8 57 ec ff ff       	call   800d89 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802132:	e8 d3 eb ff ff       	call   800d0a <sys_cgetc>
  802137:	85 c0                	test   %eax,%eax
  802139:	74 f2                	je     80212d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80213b:	85 c0                	test   %eax,%eax
  80213d:	78 16                	js     802155 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80213f:	83 f8 04             	cmp    $0x4,%eax
  802142:	74 0c                	je     802150 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802144:	8b 55 0c             	mov    0xc(%ebp),%edx
  802147:	88 02                	mov    %al,(%edx)
	return 1;
  802149:	b8 01 00 00 00       	mov    $0x1,%eax
  80214e:	eb 05                	jmp    802155 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802150:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802155:	c9                   	leave  
  802156:	c3                   	ret    

00802157 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802157:	55                   	push   %ebp
  802158:	89 e5                	mov    %esp,%ebp
  80215a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80215d:	8b 45 08             	mov    0x8(%ebp),%eax
  802160:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802163:	6a 01                	push   $0x1
  802165:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802168:	50                   	push   %eax
  802169:	e8 7e eb ff ff       	call   800cec <sys_cputs>
}
  80216e:	83 c4 10             	add    $0x10,%esp
  802171:	c9                   	leave  
  802172:	c3                   	ret    

00802173 <getchar>:

int
getchar(void)
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802179:	6a 01                	push   $0x1
  80217b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80217e:	50                   	push   %eax
  80217f:	6a 00                	push   $0x0
  802181:	e8 77 f5 ff ff       	call   8016fd <read>
	if (r < 0)
  802186:	83 c4 10             	add    $0x10,%esp
  802189:	85 c0                	test   %eax,%eax
  80218b:	78 0f                	js     80219c <getchar+0x29>
		return r;
	if (r < 1)
  80218d:	85 c0                	test   %eax,%eax
  80218f:	7e 06                	jle    802197 <getchar+0x24>
		return -E_EOF;
	return c;
  802191:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802195:	eb 05                	jmp    80219c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802197:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80219c:	c9                   	leave  
  80219d:	c3                   	ret    

0080219e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80219e:	55                   	push   %ebp
  80219f:	89 e5                	mov    %esp,%ebp
  8021a1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a7:	50                   	push   %eax
  8021a8:	ff 75 08             	pushl  0x8(%ebp)
  8021ab:	e8 e7 f2 ff ff       	call   801497 <fd_lookup>
  8021b0:	83 c4 10             	add    $0x10,%esp
  8021b3:	85 c0                	test   %eax,%eax
  8021b5:	78 11                	js     8021c8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ba:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021c0:	39 10                	cmp    %edx,(%eax)
  8021c2:	0f 94 c0             	sete   %al
  8021c5:	0f b6 c0             	movzbl %al,%eax
}
  8021c8:	c9                   	leave  
  8021c9:	c3                   	ret    

008021ca <opencons>:

int
opencons(void)
{
  8021ca:	55                   	push   %ebp
  8021cb:	89 e5                	mov    %esp,%ebp
  8021cd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d3:	50                   	push   %eax
  8021d4:	e8 6f f2 ff ff       	call   801448 <fd_alloc>
  8021d9:	83 c4 10             	add    $0x10,%esp
		return r;
  8021dc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021de:	85 c0                	test   %eax,%eax
  8021e0:	78 3e                	js     802220 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021e2:	83 ec 04             	sub    $0x4,%esp
  8021e5:	68 07 04 00 00       	push   $0x407
  8021ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ed:	6a 00                	push   $0x0
  8021ef:	e8 b4 eb ff ff       	call   800da8 <sys_page_alloc>
  8021f4:	83 c4 10             	add    $0x10,%esp
		return r;
  8021f7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021f9:	85 c0                	test   %eax,%eax
  8021fb:	78 23                	js     802220 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021fd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802203:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802206:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802208:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802212:	83 ec 0c             	sub    $0xc,%esp
  802215:	50                   	push   %eax
  802216:	e8 06 f2 ff ff       	call   801421 <fd2num>
  80221b:	89 c2                	mov    %eax,%edx
  80221d:	83 c4 10             	add    $0x10,%esp
}
  802220:	89 d0                	mov    %edx,%eax
  802222:	c9                   	leave  
  802223:	c3                   	ret    

00802224 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802224:	55                   	push   %ebp
  802225:	89 e5                	mov    %esp,%ebp
  802227:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80222a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802231:	75 2a                	jne    80225d <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802233:	83 ec 04             	sub    $0x4,%esp
  802236:	6a 07                	push   $0x7
  802238:	68 00 f0 bf ee       	push   $0xeebff000
  80223d:	6a 00                	push   $0x0
  80223f:	e8 64 eb ff ff       	call   800da8 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802244:	83 c4 10             	add    $0x10,%esp
  802247:	85 c0                	test   %eax,%eax
  802249:	79 12                	jns    80225d <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80224b:	50                   	push   %eax
  80224c:	68 f6 2b 80 00       	push   $0x802bf6
  802251:	6a 23                	push   $0x23
  802253:	68 fa 2b 80 00       	push   $0x802bfa
  802258:	e8 ea e0 ff ff       	call   800347 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80225d:	8b 45 08             	mov    0x8(%ebp),%eax
  802260:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802265:	83 ec 08             	sub    $0x8,%esp
  802268:	68 8f 22 80 00       	push   $0x80228f
  80226d:	6a 00                	push   $0x0
  80226f:	e8 7f ec ff ff       	call   800ef3 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802274:	83 c4 10             	add    $0x10,%esp
  802277:	85 c0                	test   %eax,%eax
  802279:	79 12                	jns    80228d <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80227b:	50                   	push   %eax
  80227c:	68 f6 2b 80 00       	push   $0x802bf6
  802281:	6a 2c                	push   $0x2c
  802283:	68 fa 2b 80 00       	push   $0x802bfa
  802288:	e8 ba e0 ff ff       	call   800347 <_panic>
	}
}
  80228d:	c9                   	leave  
  80228e:	c3                   	ret    

0080228f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80228f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802290:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802295:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802297:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80229a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80229e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8022a3:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8022a7:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8022a9:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8022ac:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8022ad:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8022b0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8022b1:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8022b2:	c3                   	ret    

008022b3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022b3:	55                   	push   %ebp
  8022b4:	89 e5                	mov    %esp,%ebp
  8022b6:	56                   	push   %esi
  8022b7:	53                   	push   %ebx
  8022b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8022bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022be:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8022c1:	85 c0                	test   %eax,%eax
  8022c3:	75 12                	jne    8022d7 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8022c5:	83 ec 0c             	sub    $0xc,%esp
  8022c8:	68 00 00 c0 ee       	push   $0xeec00000
  8022cd:	e8 86 ec ff ff       	call   800f58 <sys_ipc_recv>
  8022d2:	83 c4 10             	add    $0x10,%esp
  8022d5:	eb 0c                	jmp    8022e3 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8022d7:	83 ec 0c             	sub    $0xc,%esp
  8022da:	50                   	push   %eax
  8022db:	e8 78 ec ff ff       	call   800f58 <sys_ipc_recv>
  8022e0:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8022e3:	85 f6                	test   %esi,%esi
  8022e5:	0f 95 c1             	setne  %cl
  8022e8:	85 db                	test   %ebx,%ebx
  8022ea:	0f 95 c2             	setne  %dl
  8022ed:	84 d1                	test   %dl,%cl
  8022ef:	74 09                	je     8022fa <ipc_recv+0x47>
  8022f1:	89 c2                	mov    %eax,%edx
  8022f3:	c1 ea 1f             	shr    $0x1f,%edx
  8022f6:	84 d2                	test   %dl,%dl
  8022f8:	75 2d                	jne    802327 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8022fa:	85 f6                	test   %esi,%esi
  8022fc:	74 0d                	je     80230b <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8022fe:	a1 20 44 80 00       	mov    0x804420,%eax
  802303:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  802309:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80230b:	85 db                	test   %ebx,%ebx
  80230d:	74 0d                	je     80231c <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80230f:	a1 20 44 80 00       	mov    0x804420,%eax
  802314:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  80231a:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80231c:	a1 20 44 80 00       	mov    0x804420,%eax
  802321:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  802327:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80232a:	5b                   	pop    %ebx
  80232b:	5e                   	pop    %esi
  80232c:	5d                   	pop    %ebp
  80232d:	c3                   	ret    

0080232e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80232e:	55                   	push   %ebp
  80232f:	89 e5                	mov    %esp,%ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	53                   	push   %ebx
  802334:	83 ec 0c             	sub    $0xc,%esp
  802337:	8b 7d 08             	mov    0x8(%ebp),%edi
  80233a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80233d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802340:	85 db                	test   %ebx,%ebx
  802342:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802347:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80234a:	ff 75 14             	pushl  0x14(%ebp)
  80234d:	53                   	push   %ebx
  80234e:	56                   	push   %esi
  80234f:	57                   	push   %edi
  802350:	e8 e0 eb ff ff       	call   800f35 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802355:	89 c2                	mov    %eax,%edx
  802357:	c1 ea 1f             	shr    $0x1f,%edx
  80235a:	83 c4 10             	add    $0x10,%esp
  80235d:	84 d2                	test   %dl,%dl
  80235f:	74 17                	je     802378 <ipc_send+0x4a>
  802361:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802364:	74 12                	je     802378 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802366:	50                   	push   %eax
  802367:	68 08 2c 80 00       	push   $0x802c08
  80236c:	6a 47                	push   $0x47
  80236e:	68 16 2c 80 00       	push   $0x802c16
  802373:	e8 cf df ff ff       	call   800347 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802378:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80237b:	75 07                	jne    802384 <ipc_send+0x56>
			sys_yield();
  80237d:	e8 07 ea ff ff       	call   800d89 <sys_yield>
  802382:	eb c6                	jmp    80234a <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802384:	85 c0                	test   %eax,%eax
  802386:	75 c2                	jne    80234a <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802388:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80238b:	5b                   	pop    %ebx
  80238c:	5e                   	pop    %esi
  80238d:	5f                   	pop    %edi
  80238e:	5d                   	pop    %ebp
  80238f:	c3                   	ret    

00802390 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802390:	55                   	push   %ebp
  802391:	89 e5                	mov    %esp,%ebp
  802393:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802396:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80239b:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  8023a1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023a7:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8023ad:	39 ca                	cmp    %ecx,%edx
  8023af:	75 10                	jne    8023c1 <ipc_find_env+0x31>
			return envs[i].env_id;
  8023b1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8023b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023bc:	8b 40 7c             	mov    0x7c(%eax),%eax
  8023bf:	eb 0f                	jmp    8023d0 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023c1:	83 c0 01             	add    $0x1,%eax
  8023c4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023c9:	75 d0                	jne    80239b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023d0:	5d                   	pop    %ebp
  8023d1:	c3                   	ret    

008023d2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023d2:	55                   	push   %ebp
  8023d3:	89 e5                	mov    %esp,%ebp
  8023d5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023d8:	89 d0                	mov    %edx,%eax
  8023da:	c1 e8 16             	shr    $0x16,%eax
  8023dd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023e4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023e9:	f6 c1 01             	test   $0x1,%cl
  8023ec:	74 1d                	je     80240b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023ee:	c1 ea 0c             	shr    $0xc,%edx
  8023f1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023f8:	f6 c2 01             	test   $0x1,%dl
  8023fb:	74 0e                	je     80240b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023fd:	c1 ea 0c             	shr    $0xc,%edx
  802400:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802407:	ef 
  802408:	0f b7 c0             	movzwl %ax,%eax
}
  80240b:	5d                   	pop    %ebp
  80240c:	c3                   	ret    
  80240d:	66 90                	xchg   %ax,%ax
  80240f:	90                   	nop

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
