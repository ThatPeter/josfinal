
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
  80005a:	68 e2 28 80 00       	push   $0x8028e2
  80005f:	e8 f4 1e 00 00       	call   801f58 <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 3c 2d 80 00       	mov    $0x802d3c,%eax
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
  800086:	ba 3c 2d 80 00       	mov    $0x802d3c,%edx
  80008b:	b8 e0 28 80 00       	mov    $0x8028e0,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 eb 28 80 00       	push   $0x8028eb
  80009d:	e8 b6 1e 00 00       	call   801f58 <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 01 2e 80 00       	push   $0x802e01
  8000b0:	e8 a3 1e 00 00       	call   801f58 <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 e0 28 80 00       	push   $0x8028e0
  8000cf:	e8 84 1e 00 00       	call   801f58 <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 3b 2d 80 00       	push   $0x802d3b
  8000df:	e8 74 1e 00 00       	call   801f58 <printf>
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
  800100:	e8 b5 1c 00 00       	call   801dba <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 f0 28 80 00       	push   $0x8028f0
  800118:	6a 1d                	push   $0x1d
  80011a:	68 fc 28 80 00       	push   $0x8028fc
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
  80015f:	e8 56 18 00 00       	call   8019ba <readn>
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
  800173:	68 06 29 80 00       	push   $0x802906
  800178:	6a 22                	push   $0x22
  80017a:	68 fc 28 80 00       	push   $0x8028fc
  80017f:	e8 c3 01 00 00       	call   800347 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 4c 29 80 00       	push   $0x80294c
  800192:	6a 24                	push   $0x24
  800194:	68 fc 28 80 00       	push   $0x8028fc
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
  8001bb:	e8 05 1a 00 00       	call   801bc5 <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 21 29 80 00       	push   $0x802921
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 fc 28 80 00       	push   $0x8028fc
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
  800220:	68 2d 29 80 00       	push   $0x80292d
  800225:	e8 2e 1d 00 00       	call   801f58 <printf>
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
  800248:	e8 a6 12 00 00       	call   8014f3 <argstart>
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
  800277:	e8 a7 12 00 00       	call   801523 <argnext>
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
  800291:	68 3c 2d 80 00       	push   $0x802d3c
  800296:	68 e0 28 80 00       	push   $0x8028e0
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
  8002d9:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8002df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e4:	a3 20 44 80 00       	mov    %eax,0x804420

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
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	83 ec 08             	sub    $0x8,%esp
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
  800333:	e8 dd 14 00 00       	call   801815 <close_all>
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
  800365:	68 78 29 80 00       	push   $0x802978
  80036a:	e8 b1 00 00 00       	call   800420 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80036f:	83 c4 18             	add    $0x18,%esp
  800372:	53                   	push   %ebx
  800373:	ff 75 10             	pushl  0x10(%ebp)
  800376:	e8 54 00 00 00       	call   8003cf <vcprintf>
	cprintf("\n");
  80037b:	c7 04 24 3b 2d 80 00 	movl   $0x802d3b,(%esp)
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
  800483:	e8 c8 21 00 00       	call   802650 <__udivdi3>
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
  8004c6:	e8 b5 22 00 00       	call   802780 <__umoddi3>
  8004cb:	83 c4 14             	add    $0x14,%esp
  8004ce:	0f be 80 9b 29 80 00 	movsbl 0x80299b(%eax),%eax
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
  8005ca:	ff 24 85 e0 2a 80 00 	jmp    *0x802ae0(,%eax,4)
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
  80068e:	8b 14 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%edx
  800695:	85 d2                	test   %edx,%edx
  800697:	75 18                	jne    8006b1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800699:	50                   	push   %eax
  80069a:	68 b3 29 80 00       	push   $0x8029b3
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
  8006b2:	68 01 2e 80 00       	push   $0x802e01
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
  8006d6:	b8 ac 29 80 00       	mov    $0x8029ac,%eax
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
  800d51:	68 9f 2c 80 00       	push   $0x802c9f
  800d56:	6a 23                	push   $0x23
  800d58:	68 bc 2c 80 00       	push   $0x802cbc
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
  800dd2:	68 9f 2c 80 00       	push   $0x802c9f
  800dd7:	6a 23                	push   $0x23
  800dd9:	68 bc 2c 80 00       	push   $0x802cbc
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
  800e14:	68 9f 2c 80 00       	push   $0x802c9f
  800e19:	6a 23                	push   $0x23
  800e1b:	68 bc 2c 80 00       	push   $0x802cbc
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
  800e56:	68 9f 2c 80 00       	push   $0x802c9f
  800e5b:	6a 23                	push   $0x23
  800e5d:	68 bc 2c 80 00       	push   $0x802cbc
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
  800e98:	68 9f 2c 80 00       	push   $0x802c9f
  800e9d:	6a 23                	push   $0x23
  800e9f:	68 bc 2c 80 00       	push   $0x802cbc
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
  800eda:	68 9f 2c 80 00       	push   $0x802c9f
  800edf:	6a 23                	push   $0x23
  800ee1:	68 bc 2c 80 00       	push   $0x802cbc
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
  800f1c:	68 9f 2c 80 00       	push   $0x802c9f
  800f21:	6a 23                	push   $0x23
  800f23:	68 bc 2c 80 00       	push   $0x802cbc
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
  800f80:	68 9f 2c 80 00       	push   $0x802c9f
  800f85:	6a 23                	push   $0x23
  800f87:	68 bc 2c 80 00       	push   $0x802cbc
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

00800fd9 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	57                   	push   %edi
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fdf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe4:	b8 10 00 00 00       	mov    $0x10,%eax
  800fe9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fec:	89 cb                	mov    %ecx,%ebx
  800fee:	89 cf                	mov    %ecx,%edi
  800ff0:	89 ce                	mov    %ecx,%esi
  800ff2:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800ff4:	5b                   	pop    %ebx
  800ff5:	5e                   	pop    %esi
  800ff6:	5f                   	pop    %edi
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    

00800ff9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	53                   	push   %ebx
  800ffd:	83 ec 04             	sub    $0x4,%esp
  801000:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801003:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  801005:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801009:	74 11                	je     80101c <pgfault+0x23>
  80100b:	89 d8                	mov    %ebx,%eax
  80100d:	c1 e8 0c             	shr    $0xc,%eax
  801010:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801017:	f6 c4 08             	test   $0x8,%ah
  80101a:	75 14                	jne    801030 <pgfault+0x37>
		panic("faulting access");
  80101c:	83 ec 04             	sub    $0x4,%esp
  80101f:	68 ca 2c 80 00       	push   $0x802cca
  801024:	6a 1f                	push   $0x1f
  801026:	68 da 2c 80 00       	push   $0x802cda
  80102b:	e8 17 f3 ff ff       	call   800347 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  801030:	83 ec 04             	sub    $0x4,%esp
  801033:	6a 07                	push   $0x7
  801035:	68 00 f0 7f 00       	push   $0x7ff000
  80103a:	6a 00                	push   $0x0
  80103c:	e8 67 fd ff ff       	call   800da8 <sys_page_alloc>
	if (r < 0) {
  801041:	83 c4 10             	add    $0x10,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	79 12                	jns    80105a <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  801048:	50                   	push   %eax
  801049:	68 e5 2c 80 00       	push   $0x802ce5
  80104e:	6a 2d                	push   $0x2d
  801050:	68 da 2c 80 00       	push   $0x802cda
  801055:	e8 ed f2 ff ff       	call   800347 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80105a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  801060:	83 ec 04             	sub    $0x4,%esp
  801063:	68 00 10 00 00       	push   $0x1000
  801068:	53                   	push   %ebx
  801069:	68 00 f0 7f 00       	push   $0x7ff000
  80106e:	e8 2c fb ff ff       	call   800b9f <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801073:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80107a:	53                   	push   %ebx
  80107b:	6a 00                	push   $0x0
  80107d:	68 00 f0 7f 00       	push   $0x7ff000
  801082:	6a 00                	push   $0x0
  801084:	e8 62 fd ff ff       	call   800deb <sys_page_map>
	if (r < 0) {
  801089:	83 c4 20             	add    $0x20,%esp
  80108c:	85 c0                	test   %eax,%eax
  80108e:	79 12                	jns    8010a2 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  801090:	50                   	push   %eax
  801091:	68 e5 2c 80 00       	push   $0x802ce5
  801096:	6a 34                	push   $0x34
  801098:	68 da 2c 80 00       	push   $0x802cda
  80109d:	e8 a5 f2 ff ff       	call   800347 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  8010a2:	83 ec 08             	sub    $0x8,%esp
  8010a5:	68 00 f0 7f 00       	push   $0x7ff000
  8010aa:	6a 00                	push   $0x0
  8010ac:	e8 7c fd ff ff       	call   800e2d <sys_page_unmap>
	if (r < 0) {
  8010b1:	83 c4 10             	add    $0x10,%esp
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	79 12                	jns    8010ca <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  8010b8:	50                   	push   %eax
  8010b9:	68 e5 2c 80 00       	push   $0x802ce5
  8010be:	6a 38                	push   $0x38
  8010c0:	68 da 2c 80 00       	push   $0x802cda
  8010c5:	e8 7d f2 ff ff       	call   800347 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8010ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cd:	c9                   	leave  
  8010ce:	c3                   	ret    

008010cf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	57                   	push   %edi
  8010d3:	56                   	push   %esi
  8010d4:	53                   	push   %ebx
  8010d5:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8010d8:	68 f9 0f 80 00       	push   $0x800ff9
  8010dd:	e8 74 13 00 00       	call   802456 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010e2:	b8 07 00 00 00       	mov    $0x7,%eax
  8010e7:	cd 30                	int    $0x30
  8010e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	79 17                	jns    80110a <fork+0x3b>
		panic("fork fault %e");
  8010f3:	83 ec 04             	sub    $0x4,%esp
  8010f6:	68 fe 2c 80 00       	push   $0x802cfe
  8010fb:	68 85 00 00 00       	push   $0x85
  801100:	68 da 2c 80 00       	push   $0x802cda
  801105:	e8 3d f2 ff ff       	call   800347 <_panic>
  80110a:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  80110c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801110:	75 24                	jne    801136 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  801112:	e8 53 fc ff ff       	call   800d6a <sys_getenvid>
  801117:	25 ff 03 00 00       	and    $0x3ff,%eax
  80111c:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  801122:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801127:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  80112c:	b8 00 00 00 00       	mov    $0x0,%eax
  801131:	e9 64 01 00 00       	jmp    80129a <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801136:	83 ec 04             	sub    $0x4,%esp
  801139:	6a 07                	push   $0x7
  80113b:	68 00 f0 bf ee       	push   $0xeebff000
  801140:	ff 75 e4             	pushl  -0x1c(%ebp)
  801143:	e8 60 fc ff ff       	call   800da8 <sys_page_alloc>
  801148:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80114b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801150:	89 d8                	mov    %ebx,%eax
  801152:	c1 e8 16             	shr    $0x16,%eax
  801155:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80115c:	a8 01                	test   $0x1,%al
  80115e:	0f 84 fc 00 00 00    	je     801260 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801164:	89 d8                	mov    %ebx,%eax
  801166:	c1 e8 0c             	shr    $0xc,%eax
  801169:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801170:	f6 c2 01             	test   $0x1,%dl
  801173:	0f 84 e7 00 00 00    	je     801260 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801179:	89 c6                	mov    %eax,%esi
  80117b:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80117e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801185:	f6 c6 04             	test   $0x4,%dh
  801188:	74 39                	je     8011c3 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80118a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801191:	83 ec 0c             	sub    $0xc,%esp
  801194:	25 07 0e 00 00       	and    $0xe07,%eax
  801199:	50                   	push   %eax
  80119a:	56                   	push   %esi
  80119b:	57                   	push   %edi
  80119c:	56                   	push   %esi
  80119d:	6a 00                	push   $0x0
  80119f:	e8 47 fc ff ff       	call   800deb <sys_page_map>
		if (r < 0) {
  8011a4:	83 c4 20             	add    $0x20,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	0f 89 b1 00 00 00    	jns    801260 <fork+0x191>
		    	panic("sys page map fault %e");
  8011af:	83 ec 04             	sub    $0x4,%esp
  8011b2:	68 0c 2d 80 00       	push   $0x802d0c
  8011b7:	6a 55                	push   $0x55
  8011b9:	68 da 2c 80 00       	push   $0x802cda
  8011be:	e8 84 f1 ff ff       	call   800347 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8011c3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011ca:	f6 c2 02             	test   $0x2,%dl
  8011cd:	75 0c                	jne    8011db <fork+0x10c>
  8011cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011d6:	f6 c4 08             	test   $0x8,%ah
  8011d9:	74 5b                	je     801236 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8011db:	83 ec 0c             	sub    $0xc,%esp
  8011de:	68 05 08 00 00       	push   $0x805
  8011e3:	56                   	push   %esi
  8011e4:	57                   	push   %edi
  8011e5:	56                   	push   %esi
  8011e6:	6a 00                	push   $0x0
  8011e8:	e8 fe fb ff ff       	call   800deb <sys_page_map>
		if (r < 0) {
  8011ed:	83 c4 20             	add    $0x20,%esp
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	79 14                	jns    801208 <fork+0x139>
		    	panic("sys page map fault %e");
  8011f4:	83 ec 04             	sub    $0x4,%esp
  8011f7:	68 0c 2d 80 00       	push   $0x802d0c
  8011fc:	6a 5c                	push   $0x5c
  8011fe:	68 da 2c 80 00       	push   $0x802cda
  801203:	e8 3f f1 ff ff       	call   800347 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801208:	83 ec 0c             	sub    $0xc,%esp
  80120b:	68 05 08 00 00       	push   $0x805
  801210:	56                   	push   %esi
  801211:	6a 00                	push   $0x0
  801213:	56                   	push   %esi
  801214:	6a 00                	push   $0x0
  801216:	e8 d0 fb ff ff       	call   800deb <sys_page_map>
		if (r < 0) {
  80121b:	83 c4 20             	add    $0x20,%esp
  80121e:	85 c0                	test   %eax,%eax
  801220:	79 3e                	jns    801260 <fork+0x191>
		    	panic("sys page map fault %e");
  801222:	83 ec 04             	sub    $0x4,%esp
  801225:	68 0c 2d 80 00       	push   $0x802d0c
  80122a:	6a 60                	push   $0x60
  80122c:	68 da 2c 80 00       	push   $0x802cda
  801231:	e8 11 f1 ff ff       	call   800347 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801236:	83 ec 0c             	sub    $0xc,%esp
  801239:	6a 05                	push   $0x5
  80123b:	56                   	push   %esi
  80123c:	57                   	push   %edi
  80123d:	56                   	push   %esi
  80123e:	6a 00                	push   $0x0
  801240:	e8 a6 fb ff ff       	call   800deb <sys_page_map>
		if (r < 0) {
  801245:	83 c4 20             	add    $0x20,%esp
  801248:	85 c0                	test   %eax,%eax
  80124a:	79 14                	jns    801260 <fork+0x191>
		    	panic("sys page map fault %e");
  80124c:	83 ec 04             	sub    $0x4,%esp
  80124f:	68 0c 2d 80 00       	push   $0x802d0c
  801254:	6a 65                	push   $0x65
  801256:	68 da 2c 80 00       	push   $0x802cda
  80125b:	e8 e7 f0 ff ff       	call   800347 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801260:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801266:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80126c:	0f 85 de fe ff ff    	jne    801150 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801272:	a1 20 44 80 00       	mov    0x804420,%eax
  801277:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  80127d:	83 ec 08             	sub    $0x8,%esp
  801280:	50                   	push   %eax
  801281:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801284:	57                   	push   %edi
  801285:	e8 69 fc ff ff       	call   800ef3 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80128a:	83 c4 08             	add    $0x8,%esp
  80128d:	6a 02                	push   $0x2
  80128f:	57                   	push   %edi
  801290:	e8 da fb ff ff       	call   800e6f <sys_env_set_status>
	
	return envid;
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80129a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80129d:	5b                   	pop    %ebx
  80129e:	5e                   	pop    %esi
  80129f:	5f                   	pop    %edi
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <sfork>:

envid_t
sfork(void)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8012a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  8012b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b5:	a3 24 44 80 00       	mov    %eax,0x804424
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8012ba:	68 0d 03 80 00       	push   $0x80030d
  8012bf:	e8 d5 fc ff ff       	call   800f99 <sys_thread_create>

	return id;
}
  8012c4:	c9                   	leave  
  8012c5:	c3                   	ret    

008012c6 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8012cc:	ff 75 08             	pushl  0x8(%ebp)
  8012cf:	e8 e5 fc ff ff       	call   800fb9 <sys_thread_free>
}
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	c9                   	leave  
  8012d8:	c3                   	ret    

008012d9 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8012df:	ff 75 08             	pushl  0x8(%ebp)
  8012e2:	e8 f2 fc ff ff       	call   800fd9 <sys_thread_join>
}
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	c9                   	leave  
  8012eb:	c3                   	ret    

008012ec <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	56                   	push   %esi
  8012f0:	53                   	push   %ebx
  8012f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8012f7:	83 ec 04             	sub    $0x4,%esp
  8012fa:	6a 07                	push   $0x7
  8012fc:	6a 00                	push   $0x0
  8012fe:	56                   	push   %esi
  8012ff:	e8 a4 fa ff ff       	call   800da8 <sys_page_alloc>
	if (r < 0) {
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	79 15                	jns    801320 <queue_append+0x34>
		panic("%e\n", r);
  80130b:	50                   	push   %eax
  80130c:	68 52 2d 80 00       	push   $0x802d52
  801311:	68 d5 00 00 00       	push   $0xd5
  801316:	68 da 2c 80 00       	push   $0x802cda
  80131b:	e8 27 f0 ff ff       	call   800347 <_panic>
	}	

	wt->envid = envid;
  801320:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  801326:	83 3b 00             	cmpl   $0x0,(%ebx)
  801329:	75 13                	jne    80133e <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  80132b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801332:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801339:	00 00 00 
  80133c:	eb 1b                	jmp    801359 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  80133e:	8b 43 04             	mov    0x4(%ebx),%eax
  801341:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801348:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80134f:	00 00 00 
		queue->last = wt;
  801352:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801359:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135c:	5b                   	pop    %ebx
  80135d:	5e                   	pop    %esi
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  801369:	8b 02                	mov    (%edx),%eax
  80136b:	85 c0                	test   %eax,%eax
  80136d:	75 17                	jne    801386 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  80136f:	83 ec 04             	sub    $0x4,%esp
  801372:	68 22 2d 80 00       	push   $0x802d22
  801377:	68 ec 00 00 00       	push   $0xec
  80137c:	68 da 2c 80 00       	push   $0x802cda
  801381:	e8 c1 ef ff ff       	call   800347 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801386:	8b 48 04             	mov    0x4(%eax),%ecx
  801389:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  80138b:	8b 00                	mov    (%eax),%eax
}
  80138d:	c9                   	leave  
  80138e:	c3                   	ret    

0080138f <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	53                   	push   %ebx
  801393:	83 ec 04             	sub    $0x4,%esp
  801396:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801399:	b8 01 00 00 00       	mov    $0x1,%eax
  80139e:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	74 45                	je     8013ea <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  8013a5:	e8 c0 f9 ff ff       	call   800d6a <sys_getenvid>
  8013aa:	83 ec 08             	sub    $0x8,%esp
  8013ad:	83 c3 04             	add    $0x4,%ebx
  8013b0:	53                   	push   %ebx
  8013b1:	50                   	push   %eax
  8013b2:	e8 35 ff ff ff       	call   8012ec <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8013b7:	e8 ae f9 ff ff       	call   800d6a <sys_getenvid>
  8013bc:	83 c4 08             	add    $0x8,%esp
  8013bf:	6a 04                	push   $0x4
  8013c1:	50                   	push   %eax
  8013c2:	e8 a8 fa ff ff       	call   800e6f <sys_env_set_status>

		if (r < 0) {
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	79 15                	jns    8013e3 <mutex_lock+0x54>
			panic("%e\n", r);
  8013ce:	50                   	push   %eax
  8013cf:	68 52 2d 80 00       	push   $0x802d52
  8013d4:	68 02 01 00 00       	push   $0x102
  8013d9:	68 da 2c 80 00       	push   $0x802cda
  8013de:	e8 64 ef ff ff       	call   800347 <_panic>
		}
		sys_yield();
  8013e3:	e8 a1 f9 ff ff       	call   800d89 <sys_yield>
  8013e8:	eb 08                	jmp    8013f2 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8013ea:	e8 7b f9 ff ff       	call   800d6a <sys_getenvid>
  8013ef:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8013f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f5:	c9                   	leave  
  8013f6:	c3                   	ret    

008013f7 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	53                   	push   %ebx
  8013fb:	83 ec 04             	sub    $0x4,%esp
  8013fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  801401:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  801405:	74 36                	je     80143d <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  801407:	83 ec 0c             	sub    $0xc,%esp
  80140a:	8d 43 04             	lea    0x4(%ebx),%eax
  80140d:	50                   	push   %eax
  80140e:	e8 4d ff ff ff       	call   801360 <queue_pop>
  801413:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801416:	83 c4 08             	add    $0x8,%esp
  801419:	6a 02                	push   $0x2
  80141b:	50                   	push   %eax
  80141c:	e8 4e fa ff ff       	call   800e6f <sys_env_set_status>
		if (r < 0) {
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	85 c0                	test   %eax,%eax
  801426:	79 1d                	jns    801445 <mutex_unlock+0x4e>
			panic("%e\n", r);
  801428:	50                   	push   %eax
  801429:	68 52 2d 80 00       	push   $0x802d52
  80142e:	68 16 01 00 00       	push   $0x116
  801433:	68 da 2c 80 00       	push   $0x802cda
  801438:	e8 0a ef ff ff       	call   800347 <_panic>
  80143d:	b8 00 00 00 00       	mov    $0x0,%eax
  801442:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  801445:	e8 3f f9 ff ff       	call   800d89 <sys_yield>
}
  80144a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    

0080144f <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	53                   	push   %ebx
  801453:	83 ec 04             	sub    $0x4,%esp
  801456:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801459:	e8 0c f9 ff ff       	call   800d6a <sys_getenvid>
  80145e:	83 ec 04             	sub    $0x4,%esp
  801461:	6a 07                	push   $0x7
  801463:	53                   	push   %ebx
  801464:	50                   	push   %eax
  801465:	e8 3e f9 ff ff       	call   800da8 <sys_page_alloc>
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	85 c0                	test   %eax,%eax
  80146f:	79 15                	jns    801486 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801471:	50                   	push   %eax
  801472:	68 3d 2d 80 00       	push   $0x802d3d
  801477:	68 23 01 00 00       	push   $0x123
  80147c:	68 da 2c 80 00       	push   $0x802cda
  801481:	e8 c1 ee ff ff       	call   800347 <_panic>
	}	
	mtx->locked = 0;
  801486:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  80148c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  801493:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  80149a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  8014a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    

008014a6 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	56                   	push   %esi
  8014aa:	53                   	push   %ebx
  8014ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8014ae:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8014b1:	eb 20                	jmp    8014d3 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8014b3:	83 ec 0c             	sub    $0xc,%esp
  8014b6:	56                   	push   %esi
  8014b7:	e8 a4 fe ff ff       	call   801360 <queue_pop>
  8014bc:	83 c4 08             	add    $0x8,%esp
  8014bf:	6a 02                	push   $0x2
  8014c1:	50                   	push   %eax
  8014c2:	e8 a8 f9 ff ff       	call   800e6f <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8014c7:	8b 43 04             	mov    0x4(%ebx),%eax
  8014ca:	8b 40 04             	mov    0x4(%eax),%eax
  8014cd:	89 43 04             	mov    %eax,0x4(%ebx)
  8014d0:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8014d3:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8014d7:	75 da                	jne    8014b3 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8014d9:	83 ec 04             	sub    $0x4,%esp
  8014dc:	68 00 10 00 00       	push   $0x1000
  8014e1:	6a 00                	push   $0x0
  8014e3:	53                   	push   %ebx
  8014e4:	e8 01 f6 ff ff       	call   800aea <memset>
	mtx = NULL;
}
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ef:	5b                   	pop    %ebx
  8014f0:	5e                   	pop    %esi
  8014f1:	5d                   	pop    %ebp
  8014f2:	c3                   	ret    

008014f3 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014fc:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  8014ff:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801501:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801504:	83 3a 01             	cmpl   $0x1,(%edx)
  801507:	7e 09                	jle    801512 <argstart+0x1f>
  801509:	ba 3c 2d 80 00       	mov    $0x802d3c,%edx
  80150e:	85 c9                	test   %ecx,%ecx
  801510:	75 05                	jne    801517 <argstart+0x24>
  801512:	ba 00 00 00 00       	mov    $0x0,%edx
  801517:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  80151a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    

00801523 <argnext>:

int
argnext(struct Argstate *args)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	53                   	push   %ebx
  801527:	83 ec 04             	sub    $0x4,%esp
  80152a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  80152d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801534:	8b 43 08             	mov    0x8(%ebx),%eax
  801537:	85 c0                	test   %eax,%eax
  801539:	74 6f                	je     8015aa <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  80153b:	80 38 00             	cmpb   $0x0,(%eax)
  80153e:	75 4e                	jne    80158e <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801540:	8b 0b                	mov    (%ebx),%ecx
  801542:	83 39 01             	cmpl   $0x1,(%ecx)
  801545:	74 55                	je     80159c <argnext+0x79>
		    || args->argv[1][0] != '-'
  801547:	8b 53 04             	mov    0x4(%ebx),%edx
  80154a:	8b 42 04             	mov    0x4(%edx),%eax
  80154d:	80 38 2d             	cmpb   $0x2d,(%eax)
  801550:	75 4a                	jne    80159c <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801552:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801556:	74 44                	je     80159c <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801558:	83 c0 01             	add    $0x1,%eax
  80155b:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80155e:	83 ec 04             	sub    $0x4,%esp
  801561:	8b 01                	mov    (%ecx),%eax
  801563:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80156a:	50                   	push   %eax
  80156b:	8d 42 08             	lea    0x8(%edx),%eax
  80156e:	50                   	push   %eax
  80156f:	83 c2 04             	add    $0x4,%edx
  801572:	52                   	push   %edx
  801573:	e8 bf f5 ff ff       	call   800b37 <memmove>
		(*args->argc)--;
  801578:	8b 03                	mov    (%ebx),%eax
  80157a:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  80157d:	8b 43 08             	mov    0x8(%ebx),%eax
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	80 38 2d             	cmpb   $0x2d,(%eax)
  801586:	75 06                	jne    80158e <argnext+0x6b>
  801588:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80158c:	74 0e                	je     80159c <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  80158e:	8b 53 08             	mov    0x8(%ebx),%edx
  801591:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801594:	83 c2 01             	add    $0x1,%edx
  801597:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  80159a:	eb 13                	jmp    8015af <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  80159c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8015a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8015a8:	eb 05                	jmp    8015af <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  8015aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8015af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b2:	c9                   	leave  
  8015b3:	c3                   	ret    

008015b4 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	53                   	push   %ebx
  8015b8:	83 ec 04             	sub    $0x4,%esp
  8015bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8015be:	8b 43 08             	mov    0x8(%ebx),%eax
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	74 58                	je     80161d <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  8015c5:	80 38 00             	cmpb   $0x0,(%eax)
  8015c8:	74 0c                	je     8015d6 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8015ca:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8015cd:	c7 43 08 3c 2d 80 00 	movl   $0x802d3c,0x8(%ebx)
  8015d4:	eb 42                	jmp    801618 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  8015d6:	8b 13                	mov    (%ebx),%edx
  8015d8:	83 3a 01             	cmpl   $0x1,(%edx)
  8015db:	7e 2d                	jle    80160a <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  8015dd:	8b 43 04             	mov    0x4(%ebx),%eax
  8015e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8015e3:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8015e6:	83 ec 04             	sub    $0x4,%esp
  8015e9:	8b 12                	mov    (%edx),%edx
  8015eb:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  8015f2:	52                   	push   %edx
  8015f3:	8d 50 08             	lea    0x8(%eax),%edx
  8015f6:	52                   	push   %edx
  8015f7:	83 c0 04             	add    $0x4,%eax
  8015fa:	50                   	push   %eax
  8015fb:	e8 37 f5 ff ff       	call   800b37 <memmove>
		(*args->argc)--;
  801600:	8b 03                	mov    (%ebx),%eax
  801602:	83 28 01             	subl   $0x1,(%eax)
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	eb 0e                	jmp    801618 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  80160a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801611:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801618:	8b 43 0c             	mov    0xc(%ebx),%eax
  80161b:	eb 05                	jmp    801622 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  80161d:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801622:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801625:	c9                   	leave  
  801626:	c3                   	ret    

00801627 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	83 ec 08             	sub    $0x8,%esp
  80162d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801630:	8b 51 0c             	mov    0xc(%ecx),%edx
  801633:	89 d0                	mov    %edx,%eax
  801635:	85 d2                	test   %edx,%edx
  801637:	75 0c                	jne    801645 <argvalue+0x1e>
  801639:	83 ec 0c             	sub    $0xc,%esp
  80163c:	51                   	push   %ecx
  80163d:	e8 72 ff ff ff       	call   8015b4 <argnextvalue>
  801642:	83 c4 10             	add    $0x10,%esp
}
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80164a:	8b 45 08             	mov    0x8(%ebp),%eax
  80164d:	05 00 00 00 30       	add    $0x30000000,%eax
  801652:	c1 e8 0c             	shr    $0xc,%eax
}
  801655:	5d                   	pop    %ebp
  801656:	c3                   	ret    

00801657 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80165a:	8b 45 08             	mov    0x8(%ebp),%eax
  80165d:	05 00 00 00 30       	add    $0x30000000,%eax
  801662:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801667:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801674:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801679:	89 c2                	mov    %eax,%edx
  80167b:	c1 ea 16             	shr    $0x16,%edx
  80167e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801685:	f6 c2 01             	test   $0x1,%dl
  801688:	74 11                	je     80169b <fd_alloc+0x2d>
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	c1 ea 0c             	shr    $0xc,%edx
  80168f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801696:	f6 c2 01             	test   $0x1,%dl
  801699:	75 09                	jne    8016a4 <fd_alloc+0x36>
			*fd_store = fd;
  80169b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80169d:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a2:	eb 17                	jmp    8016bb <fd_alloc+0x4d>
  8016a4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016a9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016ae:	75 c9                	jne    801679 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016b0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8016b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8016bb:	5d                   	pop    %ebp
  8016bc:	c3                   	ret    

008016bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016c3:	83 f8 1f             	cmp    $0x1f,%eax
  8016c6:	77 36                	ja     8016fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8016c8:	c1 e0 0c             	shl    $0xc,%eax
  8016cb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016d0:	89 c2                	mov    %eax,%edx
  8016d2:	c1 ea 16             	shr    $0x16,%edx
  8016d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016dc:	f6 c2 01             	test   $0x1,%dl
  8016df:	74 24                	je     801705 <fd_lookup+0x48>
  8016e1:	89 c2                	mov    %eax,%edx
  8016e3:	c1 ea 0c             	shr    $0xc,%edx
  8016e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016ed:	f6 c2 01             	test   $0x1,%dl
  8016f0:	74 1a                	je     80170c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f5:	89 02                	mov    %eax,(%edx)
	return 0;
  8016f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016fc:	eb 13                	jmp    801711 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801703:	eb 0c                	jmp    801711 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801705:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80170a:	eb 05                	jmp    801711 <fd_lookup+0x54>
  80170c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801711:	5d                   	pop    %ebp
  801712:	c3                   	ret    

00801713 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	83 ec 08             	sub    $0x8,%esp
  801719:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80171c:	ba d8 2d 80 00       	mov    $0x802dd8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801721:	eb 13                	jmp    801736 <dev_lookup+0x23>
  801723:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801726:	39 08                	cmp    %ecx,(%eax)
  801728:	75 0c                	jne    801736 <dev_lookup+0x23>
			*dev = devtab[i];
  80172a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80172f:	b8 00 00 00 00       	mov    $0x0,%eax
  801734:	eb 31                	jmp    801767 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801736:	8b 02                	mov    (%edx),%eax
  801738:	85 c0                	test   %eax,%eax
  80173a:	75 e7                	jne    801723 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80173c:	a1 20 44 80 00       	mov    0x804420,%eax
  801741:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801747:	83 ec 04             	sub    $0x4,%esp
  80174a:	51                   	push   %ecx
  80174b:	50                   	push   %eax
  80174c:	68 58 2d 80 00       	push   $0x802d58
  801751:	e8 ca ec ff ff       	call   800420 <cprintf>
	*dev = 0;
  801756:	8b 45 0c             	mov    0xc(%ebp),%eax
  801759:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801767:	c9                   	leave  
  801768:	c3                   	ret    

00801769 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	56                   	push   %esi
  80176d:	53                   	push   %ebx
  80176e:	83 ec 10             	sub    $0x10,%esp
  801771:	8b 75 08             	mov    0x8(%ebp),%esi
  801774:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801777:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177a:	50                   	push   %eax
  80177b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801781:	c1 e8 0c             	shr    $0xc,%eax
  801784:	50                   	push   %eax
  801785:	e8 33 ff ff ff       	call   8016bd <fd_lookup>
  80178a:	83 c4 08             	add    $0x8,%esp
  80178d:	85 c0                	test   %eax,%eax
  80178f:	78 05                	js     801796 <fd_close+0x2d>
	    || fd != fd2)
  801791:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801794:	74 0c                	je     8017a2 <fd_close+0x39>
		return (must_exist ? r : 0);
  801796:	84 db                	test   %bl,%bl
  801798:	ba 00 00 00 00       	mov    $0x0,%edx
  80179d:	0f 44 c2             	cmove  %edx,%eax
  8017a0:	eb 41                	jmp    8017e3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8017a2:	83 ec 08             	sub    $0x8,%esp
  8017a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a8:	50                   	push   %eax
  8017a9:	ff 36                	pushl  (%esi)
  8017ab:	e8 63 ff ff ff       	call   801713 <dev_lookup>
  8017b0:	89 c3                	mov    %eax,%ebx
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 1a                	js     8017d3 <fd_close+0x6a>
		if (dev->dev_close)
  8017b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8017bf:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	74 0b                	je     8017d3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8017c8:	83 ec 0c             	sub    $0xc,%esp
  8017cb:	56                   	push   %esi
  8017cc:	ff d0                	call   *%eax
  8017ce:	89 c3                	mov    %eax,%ebx
  8017d0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8017d3:	83 ec 08             	sub    $0x8,%esp
  8017d6:	56                   	push   %esi
  8017d7:	6a 00                	push   $0x0
  8017d9:	e8 4f f6 ff ff       	call   800e2d <sys_page_unmap>
	return r;
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	89 d8                	mov    %ebx,%eax
}
  8017e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e6:	5b                   	pop    %ebx
  8017e7:	5e                   	pop    %esi
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f3:	50                   	push   %eax
  8017f4:	ff 75 08             	pushl  0x8(%ebp)
  8017f7:	e8 c1 fe ff ff       	call   8016bd <fd_lookup>
  8017fc:	83 c4 08             	add    $0x8,%esp
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 10                	js     801813 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	6a 01                	push   $0x1
  801808:	ff 75 f4             	pushl  -0xc(%ebp)
  80180b:	e8 59 ff ff ff       	call   801769 <fd_close>
  801810:	83 c4 10             	add    $0x10,%esp
}
  801813:	c9                   	leave  
  801814:	c3                   	ret    

00801815 <close_all>:

void
close_all(void)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	53                   	push   %ebx
  801819:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80181c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801821:	83 ec 0c             	sub    $0xc,%esp
  801824:	53                   	push   %ebx
  801825:	e8 c0 ff ff ff       	call   8017ea <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80182a:	83 c3 01             	add    $0x1,%ebx
  80182d:	83 c4 10             	add    $0x10,%esp
  801830:	83 fb 20             	cmp    $0x20,%ebx
  801833:	75 ec                	jne    801821 <close_all+0xc>
		close(i);
}
  801835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801838:	c9                   	leave  
  801839:	c3                   	ret    

0080183a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80183a:	55                   	push   %ebp
  80183b:	89 e5                	mov    %esp,%ebp
  80183d:	57                   	push   %edi
  80183e:	56                   	push   %esi
  80183f:	53                   	push   %ebx
  801840:	83 ec 2c             	sub    $0x2c,%esp
  801843:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801846:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801849:	50                   	push   %eax
  80184a:	ff 75 08             	pushl  0x8(%ebp)
  80184d:	e8 6b fe ff ff       	call   8016bd <fd_lookup>
  801852:	83 c4 08             	add    $0x8,%esp
  801855:	85 c0                	test   %eax,%eax
  801857:	0f 88 c1 00 00 00    	js     80191e <dup+0xe4>
		return r;
	close(newfdnum);
  80185d:	83 ec 0c             	sub    $0xc,%esp
  801860:	56                   	push   %esi
  801861:	e8 84 ff ff ff       	call   8017ea <close>

	newfd = INDEX2FD(newfdnum);
  801866:	89 f3                	mov    %esi,%ebx
  801868:	c1 e3 0c             	shl    $0xc,%ebx
  80186b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801871:	83 c4 04             	add    $0x4,%esp
  801874:	ff 75 e4             	pushl  -0x1c(%ebp)
  801877:	e8 db fd ff ff       	call   801657 <fd2data>
  80187c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80187e:	89 1c 24             	mov    %ebx,(%esp)
  801881:	e8 d1 fd ff ff       	call   801657 <fd2data>
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80188c:	89 f8                	mov    %edi,%eax
  80188e:	c1 e8 16             	shr    $0x16,%eax
  801891:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801898:	a8 01                	test   $0x1,%al
  80189a:	74 37                	je     8018d3 <dup+0x99>
  80189c:	89 f8                	mov    %edi,%eax
  80189e:	c1 e8 0c             	shr    $0xc,%eax
  8018a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018a8:	f6 c2 01             	test   $0x1,%dl
  8018ab:	74 26                	je     8018d3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8018ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018b4:	83 ec 0c             	sub    $0xc,%esp
  8018b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8018bc:	50                   	push   %eax
  8018bd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8018c0:	6a 00                	push   $0x0
  8018c2:	57                   	push   %edi
  8018c3:	6a 00                	push   $0x0
  8018c5:	e8 21 f5 ff ff       	call   800deb <sys_page_map>
  8018ca:	89 c7                	mov    %eax,%edi
  8018cc:	83 c4 20             	add    $0x20,%esp
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	78 2e                	js     801901 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018d6:	89 d0                	mov    %edx,%eax
  8018d8:	c1 e8 0c             	shr    $0xc,%eax
  8018db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018e2:	83 ec 0c             	sub    $0xc,%esp
  8018e5:	25 07 0e 00 00       	and    $0xe07,%eax
  8018ea:	50                   	push   %eax
  8018eb:	53                   	push   %ebx
  8018ec:	6a 00                	push   $0x0
  8018ee:	52                   	push   %edx
  8018ef:	6a 00                	push   $0x0
  8018f1:	e8 f5 f4 ff ff       	call   800deb <sys_page_map>
  8018f6:	89 c7                	mov    %eax,%edi
  8018f8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8018fb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018fd:	85 ff                	test   %edi,%edi
  8018ff:	79 1d                	jns    80191e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801901:	83 ec 08             	sub    $0x8,%esp
  801904:	53                   	push   %ebx
  801905:	6a 00                	push   $0x0
  801907:	e8 21 f5 ff ff       	call   800e2d <sys_page_unmap>
	sys_page_unmap(0, nva);
  80190c:	83 c4 08             	add    $0x8,%esp
  80190f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801912:	6a 00                	push   $0x0
  801914:	e8 14 f5 ff ff       	call   800e2d <sys_page_unmap>
	return r;
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	89 f8                	mov    %edi,%eax
}
  80191e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801921:	5b                   	pop    %ebx
  801922:	5e                   	pop    %esi
  801923:	5f                   	pop    %edi
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    

00801926 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	53                   	push   %ebx
  80192a:	83 ec 14             	sub    $0x14,%esp
  80192d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801930:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801933:	50                   	push   %eax
  801934:	53                   	push   %ebx
  801935:	e8 83 fd ff ff       	call   8016bd <fd_lookup>
  80193a:	83 c4 08             	add    $0x8,%esp
  80193d:	89 c2                	mov    %eax,%edx
  80193f:	85 c0                	test   %eax,%eax
  801941:	78 70                	js     8019b3 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801943:	83 ec 08             	sub    $0x8,%esp
  801946:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801949:	50                   	push   %eax
  80194a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194d:	ff 30                	pushl  (%eax)
  80194f:	e8 bf fd ff ff       	call   801713 <dev_lookup>
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	85 c0                	test   %eax,%eax
  801959:	78 4f                	js     8019aa <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80195b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80195e:	8b 42 08             	mov    0x8(%edx),%eax
  801961:	83 e0 03             	and    $0x3,%eax
  801964:	83 f8 01             	cmp    $0x1,%eax
  801967:	75 24                	jne    80198d <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801969:	a1 20 44 80 00       	mov    0x804420,%eax
  80196e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801974:	83 ec 04             	sub    $0x4,%esp
  801977:	53                   	push   %ebx
  801978:	50                   	push   %eax
  801979:	68 9c 2d 80 00       	push   $0x802d9c
  80197e:	e8 9d ea ff ff       	call   800420 <cprintf>
		return -E_INVAL;
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80198b:	eb 26                	jmp    8019b3 <read+0x8d>
	}
	if (!dev->dev_read)
  80198d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801990:	8b 40 08             	mov    0x8(%eax),%eax
  801993:	85 c0                	test   %eax,%eax
  801995:	74 17                	je     8019ae <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801997:	83 ec 04             	sub    $0x4,%esp
  80199a:	ff 75 10             	pushl  0x10(%ebp)
  80199d:	ff 75 0c             	pushl  0xc(%ebp)
  8019a0:	52                   	push   %edx
  8019a1:	ff d0                	call   *%eax
  8019a3:	89 c2                	mov    %eax,%edx
  8019a5:	83 c4 10             	add    $0x10,%esp
  8019a8:	eb 09                	jmp    8019b3 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019aa:	89 c2                	mov    %eax,%edx
  8019ac:	eb 05                	jmp    8019b3 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8019ae:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8019b3:	89 d0                	mov    %edx,%eax
  8019b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    

008019ba <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	57                   	push   %edi
  8019be:	56                   	push   %esi
  8019bf:	53                   	push   %ebx
  8019c0:	83 ec 0c             	sub    $0xc,%esp
  8019c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019c6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ce:	eb 21                	jmp    8019f1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019d0:	83 ec 04             	sub    $0x4,%esp
  8019d3:	89 f0                	mov    %esi,%eax
  8019d5:	29 d8                	sub    %ebx,%eax
  8019d7:	50                   	push   %eax
  8019d8:	89 d8                	mov    %ebx,%eax
  8019da:	03 45 0c             	add    0xc(%ebp),%eax
  8019dd:	50                   	push   %eax
  8019de:	57                   	push   %edi
  8019df:	e8 42 ff ff ff       	call   801926 <read>
		if (m < 0)
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	78 10                	js     8019fb <readn+0x41>
			return m;
		if (m == 0)
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	74 0a                	je     8019f9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019ef:	01 c3                	add    %eax,%ebx
  8019f1:	39 f3                	cmp    %esi,%ebx
  8019f3:	72 db                	jb     8019d0 <readn+0x16>
  8019f5:	89 d8                	mov    %ebx,%eax
  8019f7:	eb 02                	jmp    8019fb <readn+0x41>
  8019f9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8019fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019fe:	5b                   	pop    %ebx
  8019ff:	5e                   	pop    %esi
  801a00:	5f                   	pop    %edi
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    

00801a03 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	53                   	push   %ebx
  801a07:	83 ec 14             	sub    $0x14,%esp
  801a0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a0d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a10:	50                   	push   %eax
  801a11:	53                   	push   %ebx
  801a12:	e8 a6 fc ff ff       	call   8016bd <fd_lookup>
  801a17:	83 c4 08             	add    $0x8,%esp
  801a1a:	89 c2                	mov    %eax,%edx
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	78 6b                	js     801a8b <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a20:	83 ec 08             	sub    $0x8,%esp
  801a23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a26:	50                   	push   %eax
  801a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a2a:	ff 30                	pushl  (%eax)
  801a2c:	e8 e2 fc ff ff       	call   801713 <dev_lookup>
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	85 c0                	test   %eax,%eax
  801a36:	78 4a                	js     801a82 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a3f:	75 24                	jne    801a65 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a41:	a1 20 44 80 00       	mov    0x804420,%eax
  801a46:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801a4c:	83 ec 04             	sub    $0x4,%esp
  801a4f:	53                   	push   %ebx
  801a50:	50                   	push   %eax
  801a51:	68 b8 2d 80 00       	push   $0x802db8
  801a56:	e8 c5 e9 ff ff       	call   800420 <cprintf>
		return -E_INVAL;
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801a63:	eb 26                	jmp    801a8b <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a68:	8b 52 0c             	mov    0xc(%edx),%edx
  801a6b:	85 d2                	test   %edx,%edx
  801a6d:	74 17                	je     801a86 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a6f:	83 ec 04             	sub    $0x4,%esp
  801a72:	ff 75 10             	pushl  0x10(%ebp)
  801a75:	ff 75 0c             	pushl  0xc(%ebp)
  801a78:	50                   	push   %eax
  801a79:	ff d2                	call   *%edx
  801a7b:	89 c2                	mov    %eax,%edx
  801a7d:	83 c4 10             	add    $0x10,%esp
  801a80:	eb 09                	jmp    801a8b <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a82:	89 c2                	mov    %eax,%edx
  801a84:	eb 05                	jmp    801a8b <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801a86:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801a8b:	89 d0                	mov    %edx,%eax
  801a8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a90:	c9                   	leave  
  801a91:	c3                   	ret    

00801a92 <seek>:

int
seek(int fdnum, off_t offset)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a98:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a9b:	50                   	push   %eax
  801a9c:	ff 75 08             	pushl  0x8(%ebp)
  801a9f:	e8 19 fc ff ff       	call   8016bd <fd_lookup>
  801aa4:	83 c4 08             	add    $0x8,%esp
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	78 0e                	js     801ab9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801aab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ab1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801ab4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    

00801abb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	53                   	push   %ebx
  801abf:	83 ec 14             	sub    $0x14,%esp
  801ac2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ac5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac8:	50                   	push   %eax
  801ac9:	53                   	push   %ebx
  801aca:	e8 ee fb ff ff       	call   8016bd <fd_lookup>
  801acf:	83 c4 08             	add    $0x8,%esp
  801ad2:	89 c2                	mov    %eax,%edx
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	78 68                	js     801b40 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ad8:	83 ec 08             	sub    $0x8,%esp
  801adb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ade:	50                   	push   %eax
  801adf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae2:	ff 30                	pushl  (%eax)
  801ae4:	e8 2a fc ff ff       	call   801713 <dev_lookup>
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	85 c0                	test   %eax,%eax
  801aee:	78 47                	js     801b37 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801af0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801af3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801af7:	75 24                	jne    801b1d <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801af9:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801afe:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801b04:	83 ec 04             	sub    $0x4,%esp
  801b07:	53                   	push   %ebx
  801b08:	50                   	push   %eax
  801b09:	68 78 2d 80 00       	push   $0x802d78
  801b0e:	e8 0d e9 ff ff       	call   800420 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801b1b:	eb 23                	jmp    801b40 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801b1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b20:	8b 52 18             	mov    0x18(%edx),%edx
  801b23:	85 d2                	test   %edx,%edx
  801b25:	74 14                	je     801b3b <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b27:	83 ec 08             	sub    $0x8,%esp
  801b2a:	ff 75 0c             	pushl  0xc(%ebp)
  801b2d:	50                   	push   %eax
  801b2e:	ff d2                	call   *%edx
  801b30:	89 c2                	mov    %eax,%edx
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	eb 09                	jmp    801b40 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b37:	89 c2                	mov    %eax,%edx
  801b39:	eb 05                	jmp    801b40 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b3b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801b40:	89 d0                	mov    %edx,%eax
  801b42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b45:	c9                   	leave  
  801b46:	c3                   	ret    

00801b47 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	53                   	push   %ebx
  801b4b:	83 ec 14             	sub    $0x14,%esp
  801b4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b51:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b54:	50                   	push   %eax
  801b55:	ff 75 08             	pushl  0x8(%ebp)
  801b58:	e8 60 fb ff ff       	call   8016bd <fd_lookup>
  801b5d:	83 c4 08             	add    $0x8,%esp
  801b60:	89 c2                	mov    %eax,%edx
  801b62:	85 c0                	test   %eax,%eax
  801b64:	78 58                	js     801bbe <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b66:	83 ec 08             	sub    $0x8,%esp
  801b69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6c:	50                   	push   %eax
  801b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b70:	ff 30                	pushl  (%eax)
  801b72:	e8 9c fb ff ff       	call   801713 <dev_lookup>
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	78 37                	js     801bb5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b81:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b85:	74 32                	je     801bb9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b87:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b8a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b91:	00 00 00 
	stat->st_isdir = 0;
  801b94:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b9b:	00 00 00 
	stat->st_dev = dev;
  801b9e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ba4:	83 ec 08             	sub    $0x8,%esp
  801ba7:	53                   	push   %ebx
  801ba8:	ff 75 f0             	pushl  -0x10(%ebp)
  801bab:	ff 50 14             	call   *0x14(%eax)
  801bae:	89 c2                	mov    %eax,%edx
  801bb0:	83 c4 10             	add    $0x10,%esp
  801bb3:	eb 09                	jmp    801bbe <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bb5:	89 c2                	mov    %eax,%edx
  801bb7:	eb 05                	jmp    801bbe <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801bb9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801bbe:	89 d0                	mov    %edx,%eax
  801bc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc3:	c9                   	leave  
  801bc4:	c3                   	ret    

00801bc5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801bc5:	55                   	push   %ebp
  801bc6:	89 e5                	mov    %esp,%ebp
  801bc8:	56                   	push   %esi
  801bc9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801bca:	83 ec 08             	sub    $0x8,%esp
  801bcd:	6a 00                	push   $0x0
  801bcf:	ff 75 08             	pushl  0x8(%ebp)
  801bd2:	e8 e3 01 00 00       	call   801dba <open>
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	83 c4 10             	add    $0x10,%esp
  801bdc:	85 c0                	test   %eax,%eax
  801bde:	78 1b                	js     801bfb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801be0:	83 ec 08             	sub    $0x8,%esp
  801be3:	ff 75 0c             	pushl  0xc(%ebp)
  801be6:	50                   	push   %eax
  801be7:	e8 5b ff ff ff       	call   801b47 <fstat>
  801bec:	89 c6                	mov    %eax,%esi
	close(fd);
  801bee:	89 1c 24             	mov    %ebx,(%esp)
  801bf1:	e8 f4 fb ff ff       	call   8017ea <close>
	return r;
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	89 f0                	mov    %esi,%eax
}
  801bfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bfe:	5b                   	pop    %ebx
  801bff:	5e                   	pop    %esi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    

00801c02 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	56                   	push   %esi
  801c06:	53                   	push   %ebx
  801c07:	89 c6                	mov    %eax,%esi
  801c09:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801c0b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801c12:	75 12                	jne    801c26 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c14:	83 ec 0c             	sub    $0xc,%esp
  801c17:	6a 01                	push   $0x1
  801c19:	e8 a4 09 00 00       	call   8025c2 <ipc_find_env>
  801c1e:	a3 00 40 80 00       	mov    %eax,0x804000
  801c23:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c26:	6a 07                	push   $0x7
  801c28:	68 00 50 80 00       	push   $0x805000
  801c2d:	56                   	push   %esi
  801c2e:	ff 35 00 40 80 00    	pushl  0x804000
  801c34:	e8 27 09 00 00       	call   802560 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c39:	83 c4 0c             	add    $0xc,%esp
  801c3c:	6a 00                	push   $0x0
  801c3e:	53                   	push   %ebx
  801c3f:	6a 00                	push   $0x0
  801c41:	e8 9f 08 00 00       	call   8024e5 <ipc_recv>
}
  801c46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c49:	5b                   	pop    %ebx
  801c4a:	5e                   	pop    %esi
  801c4b:	5d                   	pop    %ebp
  801c4c:	c3                   	ret    

00801c4d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c53:	8b 45 08             	mov    0x8(%ebp),%eax
  801c56:	8b 40 0c             	mov    0xc(%eax),%eax
  801c59:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c61:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c66:	ba 00 00 00 00       	mov    $0x0,%edx
  801c6b:	b8 02 00 00 00       	mov    $0x2,%eax
  801c70:	e8 8d ff ff ff       	call   801c02 <fsipc>
}
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c80:	8b 40 0c             	mov    0xc(%eax),%eax
  801c83:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c88:	ba 00 00 00 00       	mov    $0x0,%edx
  801c8d:	b8 06 00 00 00       	mov    $0x6,%eax
  801c92:	e8 6b ff ff ff       	call   801c02 <fsipc>
}
  801c97:	c9                   	leave  
  801c98:	c3                   	ret    

00801c99 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	53                   	push   %ebx
  801c9d:	83 ec 04             	sub    $0x4,%esp
  801ca0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca6:	8b 40 0c             	mov    0xc(%eax),%eax
  801ca9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801cae:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb3:	b8 05 00 00 00       	mov    $0x5,%eax
  801cb8:	e8 45 ff ff ff       	call   801c02 <fsipc>
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	78 2c                	js     801ced <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801cc1:	83 ec 08             	sub    $0x8,%esp
  801cc4:	68 00 50 80 00       	push   $0x805000
  801cc9:	53                   	push   %ebx
  801cca:	e8 d6 ec ff ff       	call   8009a5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ccf:	a1 80 50 80 00       	mov    0x805080,%eax
  801cd4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801cda:	a1 84 50 80 00       	mov    0x805084,%eax
  801cdf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ced:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 0c             	sub    $0xc,%esp
  801cf8:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  801cfe:	8b 52 0c             	mov    0xc(%edx),%edx
  801d01:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801d07:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801d0c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801d11:	0f 47 c2             	cmova  %edx,%eax
  801d14:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801d19:	50                   	push   %eax
  801d1a:	ff 75 0c             	pushl  0xc(%ebp)
  801d1d:	68 08 50 80 00       	push   $0x805008
  801d22:	e8 10 ee ff ff       	call   800b37 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801d27:	ba 00 00 00 00       	mov    $0x0,%edx
  801d2c:	b8 04 00 00 00       	mov    $0x4,%eax
  801d31:	e8 cc fe ff ff       	call   801c02 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801d36:	c9                   	leave  
  801d37:	c3                   	ret    

00801d38 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	56                   	push   %esi
  801d3c:	53                   	push   %ebx
  801d3d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d40:	8b 45 08             	mov    0x8(%ebp),%eax
  801d43:	8b 40 0c             	mov    0xc(%eax),%eax
  801d46:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801d4b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d51:	ba 00 00 00 00       	mov    $0x0,%edx
  801d56:	b8 03 00 00 00       	mov    $0x3,%eax
  801d5b:	e8 a2 fe ff ff       	call   801c02 <fsipc>
  801d60:	89 c3                	mov    %eax,%ebx
  801d62:	85 c0                	test   %eax,%eax
  801d64:	78 4b                	js     801db1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801d66:	39 c6                	cmp    %eax,%esi
  801d68:	73 16                	jae    801d80 <devfile_read+0x48>
  801d6a:	68 e8 2d 80 00       	push   $0x802de8
  801d6f:	68 ef 2d 80 00       	push   $0x802def
  801d74:	6a 7c                	push   $0x7c
  801d76:	68 04 2e 80 00       	push   $0x802e04
  801d7b:	e8 c7 e5 ff ff       	call   800347 <_panic>
	assert(r <= PGSIZE);
  801d80:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d85:	7e 16                	jle    801d9d <devfile_read+0x65>
  801d87:	68 0f 2e 80 00       	push   $0x802e0f
  801d8c:	68 ef 2d 80 00       	push   $0x802def
  801d91:	6a 7d                	push   $0x7d
  801d93:	68 04 2e 80 00       	push   $0x802e04
  801d98:	e8 aa e5 ff ff       	call   800347 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801d9d:	83 ec 04             	sub    $0x4,%esp
  801da0:	50                   	push   %eax
  801da1:	68 00 50 80 00       	push   $0x805000
  801da6:	ff 75 0c             	pushl  0xc(%ebp)
  801da9:	e8 89 ed ff ff       	call   800b37 <memmove>
	return r;
  801dae:	83 c4 10             	add    $0x10,%esp
}
  801db1:	89 d8                	mov    %ebx,%eax
  801db3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db6:	5b                   	pop    %ebx
  801db7:	5e                   	pop    %esi
  801db8:	5d                   	pop    %ebp
  801db9:	c3                   	ret    

00801dba <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	53                   	push   %ebx
  801dbe:	83 ec 20             	sub    $0x20,%esp
  801dc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801dc4:	53                   	push   %ebx
  801dc5:	e8 a2 eb ff ff       	call   80096c <strlen>
  801dca:	83 c4 10             	add    $0x10,%esp
  801dcd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801dd2:	7f 67                	jg     801e3b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801dd4:	83 ec 0c             	sub    $0xc,%esp
  801dd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dda:	50                   	push   %eax
  801ddb:	e8 8e f8 ff ff       	call   80166e <fd_alloc>
  801de0:	83 c4 10             	add    $0x10,%esp
		return r;
  801de3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801de5:	85 c0                	test   %eax,%eax
  801de7:	78 57                	js     801e40 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801de9:	83 ec 08             	sub    $0x8,%esp
  801dec:	53                   	push   %ebx
  801ded:	68 00 50 80 00       	push   $0x805000
  801df2:	e8 ae eb ff ff       	call   8009a5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801df7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dfa:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801dff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e02:	b8 01 00 00 00       	mov    $0x1,%eax
  801e07:	e8 f6 fd ff ff       	call   801c02 <fsipc>
  801e0c:	89 c3                	mov    %eax,%ebx
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	85 c0                	test   %eax,%eax
  801e13:	79 14                	jns    801e29 <open+0x6f>
		fd_close(fd, 0);
  801e15:	83 ec 08             	sub    $0x8,%esp
  801e18:	6a 00                	push   $0x0
  801e1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1d:	e8 47 f9 ff ff       	call   801769 <fd_close>
		return r;
  801e22:	83 c4 10             	add    $0x10,%esp
  801e25:	89 da                	mov    %ebx,%edx
  801e27:	eb 17                	jmp    801e40 <open+0x86>
	}

	return fd2num(fd);
  801e29:	83 ec 0c             	sub    $0xc,%esp
  801e2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2f:	e8 13 f8 ff ff       	call   801647 <fd2num>
  801e34:	89 c2                	mov    %eax,%edx
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	eb 05                	jmp    801e40 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801e3b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801e40:	89 d0                	mov    %edx,%eax
  801e42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e45:	c9                   	leave  
  801e46:	c3                   	ret    

00801e47 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801e52:	b8 08 00 00 00       	mov    $0x8,%eax
  801e57:	e8 a6 fd ff ff       	call   801c02 <fsipc>
}
  801e5c:	c9                   	leave  
  801e5d:	c3                   	ret    

00801e5e <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801e5e:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801e62:	7e 37                	jle    801e9b <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	53                   	push   %ebx
  801e68:	83 ec 08             	sub    $0x8,%esp
  801e6b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801e6d:	ff 70 04             	pushl  0x4(%eax)
  801e70:	8d 40 10             	lea    0x10(%eax),%eax
  801e73:	50                   	push   %eax
  801e74:	ff 33                	pushl  (%ebx)
  801e76:	e8 88 fb ff ff       	call   801a03 <write>
		if (result > 0)
  801e7b:	83 c4 10             	add    $0x10,%esp
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	7e 03                	jle    801e85 <writebuf+0x27>
			b->result += result;
  801e82:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801e85:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e88:	74 0d                	je     801e97 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801e8a:	85 c0                	test   %eax,%eax
  801e8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801e91:	0f 4f c2             	cmovg  %edx,%eax
  801e94:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801e97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e9a:	c9                   	leave  
  801e9b:	f3 c3                	repz ret 

00801e9d <putch>:

static void
putch(int ch, void *thunk)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	53                   	push   %ebx
  801ea1:	83 ec 04             	sub    $0x4,%esp
  801ea4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801ea7:	8b 53 04             	mov    0x4(%ebx),%edx
  801eaa:	8d 42 01             	lea    0x1(%edx),%eax
  801ead:	89 43 04             	mov    %eax,0x4(%ebx)
  801eb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eb3:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801eb7:	3d 00 01 00 00       	cmp    $0x100,%eax
  801ebc:	75 0e                	jne    801ecc <putch+0x2f>
		writebuf(b);
  801ebe:	89 d8                	mov    %ebx,%eax
  801ec0:	e8 99 ff ff ff       	call   801e5e <writebuf>
		b->idx = 0;
  801ec5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801ecc:	83 c4 04             	add    $0x4,%esp
  801ecf:	5b                   	pop    %ebx
  801ed0:	5d                   	pop    %ebp
  801ed1:	c3                   	ret    

00801ed2 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801edb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ede:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801ee4:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801eeb:	00 00 00 
	b.result = 0;
  801eee:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801ef5:	00 00 00 
	b.error = 1;
  801ef8:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801eff:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801f02:	ff 75 10             	pushl  0x10(%ebp)
  801f05:	ff 75 0c             	pushl  0xc(%ebp)
  801f08:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801f0e:	50                   	push   %eax
  801f0f:	68 9d 1e 80 00       	push   $0x801e9d
  801f14:	e8 3e e6 ff ff       	call   800557 <vprintfmt>
	if (b.idx > 0)
  801f19:	83 c4 10             	add    $0x10,%esp
  801f1c:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801f23:	7e 0b                	jle    801f30 <vfprintf+0x5e>
		writebuf(&b);
  801f25:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801f2b:	e8 2e ff ff ff       	call   801e5e <writebuf>

	return (b.result ? b.result : b.error);
  801f30:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801f36:	85 c0                	test   %eax,%eax
  801f38:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801f3f:	c9                   	leave  
  801f40:	c3                   	ret    

00801f41 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801f41:	55                   	push   %ebp
  801f42:	89 e5                	mov    %esp,%ebp
  801f44:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801f47:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801f4a:	50                   	push   %eax
  801f4b:	ff 75 0c             	pushl  0xc(%ebp)
  801f4e:	ff 75 08             	pushl  0x8(%ebp)
  801f51:	e8 7c ff ff ff       	call   801ed2 <vfprintf>
	va_end(ap);

	return cnt;
}
  801f56:	c9                   	leave  
  801f57:	c3                   	ret    

00801f58 <printf>:

int
printf(const char *fmt, ...)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801f5e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801f61:	50                   	push   %eax
  801f62:	ff 75 08             	pushl  0x8(%ebp)
  801f65:	6a 01                	push   $0x1
  801f67:	e8 66 ff ff ff       	call   801ed2 <vfprintf>
	va_end(ap);

	return cnt;
}
  801f6c:	c9                   	leave  
  801f6d:	c3                   	ret    

00801f6e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f6e:	55                   	push   %ebp
  801f6f:	89 e5                	mov    %esp,%ebp
  801f71:	56                   	push   %esi
  801f72:	53                   	push   %ebx
  801f73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f76:	83 ec 0c             	sub    $0xc,%esp
  801f79:	ff 75 08             	pushl  0x8(%ebp)
  801f7c:	e8 d6 f6 ff ff       	call   801657 <fd2data>
  801f81:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f83:	83 c4 08             	add    $0x8,%esp
  801f86:	68 1b 2e 80 00       	push   $0x802e1b
  801f8b:	53                   	push   %ebx
  801f8c:	e8 14 ea ff ff       	call   8009a5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f91:	8b 46 04             	mov    0x4(%esi),%eax
  801f94:	2b 06                	sub    (%esi),%eax
  801f96:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f9c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fa3:	00 00 00 
	stat->st_dev = &devpipe;
  801fa6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801fad:	30 80 00 
	return 0;
}
  801fb0:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb8:	5b                   	pop    %ebx
  801fb9:	5e                   	pop    %esi
  801fba:	5d                   	pop    %ebp
  801fbb:	c3                   	ret    

00801fbc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	53                   	push   %ebx
  801fc0:	83 ec 0c             	sub    $0xc,%esp
  801fc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fc6:	53                   	push   %ebx
  801fc7:	6a 00                	push   $0x0
  801fc9:	e8 5f ee ff ff       	call   800e2d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fce:	89 1c 24             	mov    %ebx,(%esp)
  801fd1:	e8 81 f6 ff ff       	call   801657 <fd2data>
  801fd6:	83 c4 08             	add    $0x8,%esp
  801fd9:	50                   	push   %eax
  801fda:	6a 00                	push   $0x0
  801fdc:	e8 4c ee ff ff       	call   800e2d <sys_page_unmap>
}
  801fe1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe4:	c9                   	leave  
  801fe5:	c3                   	ret    

00801fe6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	57                   	push   %edi
  801fea:	56                   	push   %esi
  801feb:	53                   	push   %ebx
  801fec:	83 ec 1c             	sub    $0x1c,%esp
  801fef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ff2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ff4:	a1 20 44 80 00       	mov    0x804420,%eax
  801ff9:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fff:	83 ec 0c             	sub    $0xc,%esp
  802002:	ff 75 e0             	pushl  -0x20(%ebp)
  802005:	e8 fd 05 00 00       	call   802607 <pageref>
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	89 3c 24             	mov    %edi,(%esp)
  80200f:	e8 f3 05 00 00       	call   802607 <pageref>
  802014:	83 c4 10             	add    $0x10,%esp
  802017:	39 c3                	cmp    %eax,%ebx
  802019:	0f 94 c1             	sete   %cl
  80201c:	0f b6 c9             	movzbl %cl,%ecx
  80201f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802022:	8b 15 20 44 80 00    	mov    0x804420,%edx
  802028:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  80202e:	39 ce                	cmp    %ecx,%esi
  802030:	74 1e                	je     802050 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  802032:	39 c3                	cmp    %eax,%ebx
  802034:	75 be                	jne    801ff4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802036:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  80203c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80203f:	50                   	push   %eax
  802040:	56                   	push   %esi
  802041:	68 22 2e 80 00       	push   $0x802e22
  802046:	e8 d5 e3 ff ff       	call   800420 <cprintf>
  80204b:	83 c4 10             	add    $0x10,%esp
  80204e:	eb a4                	jmp    801ff4 <_pipeisclosed+0xe>
	}
}
  802050:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802053:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802056:	5b                   	pop    %ebx
  802057:	5e                   	pop    %esi
  802058:	5f                   	pop    %edi
  802059:	5d                   	pop    %ebp
  80205a:	c3                   	ret    

0080205b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80205b:	55                   	push   %ebp
  80205c:	89 e5                	mov    %esp,%ebp
  80205e:	57                   	push   %edi
  80205f:	56                   	push   %esi
  802060:	53                   	push   %ebx
  802061:	83 ec 28             	sub    $0x28,%esp
  802064:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802067:	56                   	push   %esi
  802068:	e8 ea f5 ff ff       	call   801657 <fd2data>
  80206d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80206f:	83 c4 10             	add    $0x10,%esp
  802072:	bf 00 00 00 00       	mov    $0x0,%edi
  802077:	eb 4b                	jmp    8020c4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802079:	89 da                	mov    %ebx,%edx
  80207b:	89 f0                	mov    %esi,%eax
  80207d:	e8 64 ff ff ff       	call   801fe6 <_pipeisclosed>
  802082:	85 c0                	test   %eax,%eax
  802084:	75 48                	jne    8020ce <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802086:	e8 fe ec ff ff       	call   800d89 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80208b:	8b 43 04             	mov    0x4(%ebx),%eax
  80208e:	8b 0b                	mov    (%ebx),%ecx
  802090:	8d 51 20             	lea    0x20(%ecx),%edx
  802093:	39 d0                	cmp    %edx,%eax
  802095:	73 e2                	jae    802079 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802097:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80209a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80209e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020a1:	89 c2                	mov    %eax,%edx
  8020a3:	c1 fa 1f             	sar    $0x1f,%edx
  8020a6:	89 d1                	mov    %edx,%ecx
  8020a8:	c1 e9 1b             	shr    $0x1b,%ecx
  8020ab:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020ae:	83 e2 1f             	and    $0x1f,%edx
  8020b1:	29 ca                	sub    %ecx,%edx
  8020b3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020b7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020bb:	83 c0 01             	add    $0x1,%eax
  8020be:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c1:	83 c7 01             	add    $0x1,%edi
  8020c4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020c7:	75 c2                	jne    80208b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8020cc:	eb 05                	jmp    8020d3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020ce:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d6:	5b                   	pop    %ebx
  8020d7:	5e                   	pop    %esi
  8020d8:	5f                   	pop    %edi
  8020d9:	5d                   	pop    %ebp
  8020da:	c3                   	ret    

008020db <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020db:	55                   	push   %ebp
  8020dc:	89 e5                	mov    %esp,%ebp
  8020de:	57                   	push   %edi
  8020df:	56                   	push   %esi
  8020e0:	53                   	push   %ebx
  8020e1:	83 ec 18             	sub    $0x18,%esp
  8020e4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020e7:	57                   	push   %edi
  8020e8:	e8 6a f5 ff ff       	call   801657 <fd2data>
  8020ed:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020ef:	83 c4 10             	add    $0x10,%esp
  8020f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020f7:	eb 3d                	jmp    802136 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020f9:	85 db                	test   %ebx,%ebx
  8020fb:	74 04                	je     802101 <devpipe_read+0x26>
				return i;
  8020fd:	89 d8                	mov    %ebx,%eax
  8020ff:	eb 44                	jmp    802145 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802101:	89 f2                	mov    %esi,%edx
  802103:	89 f8                	mov    %edi,%eax
  802105:	e8 dc fe ff ff       	call   801fe6 <_pipeisclosed>
  80210a:	85 c0                	test   %eax,%eax
  80210c:	75 32                	jne    802140 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80210e:	e8 76 ec ff ff       	call   800d89 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802113:	8b 06                	mov    (%esi),%eax
  802115:	3b 46 04             	cmp    0x4(%esi),%eax
  802118:	74 df                	je     8020f9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80211a:	99                   	cltd   
  80211b:	c1 ea 1b             	shr    $0x1b,%edx
  80211e:	01 d0                	add    %edx,%eax
  802120:	83 e0 1f             	and    $0x1f,%eax
  802123:	29 d0                	sub    %edx,%eax
  802125:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80212a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80212d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802130:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802133:	83 c3 01             	add    $0x1,%ebx
  802136:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802139:	75 d8                	jne    802113 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80213b:	8b 45 10             	mov    0x10(%ebp),%eax
  80213e:	eb 05                	jmp    802145 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802140:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802145:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802148:	5b                   	pop    %ebx
  802149:	5e                   	pop    %esi
  80214a:	5f                   	pop    %edi
  80214b:	5d                   	pop    %ebp
  80214c:	c3                   	ret    

0080214d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80214d:	55                   	push   %ebp
  80214e:	89 e5                	mov    %esp,%ebp
  802150:	56                   	push   %esi
  802151:	53                   	push   %ebx
  802152:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802155:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802158:	50                   	push   %eax
  802159:	e8 10 f5 ff ff       	call   80166e <fd_alloc>
  80215e:	83 c4 10             	add    $0x10,%esp
  802161:	89 c2                	mov    %eax,%edx
  802163:	85 c0                	test   %eax,%eax
  802165:	0f 88 2c 01 00 00    	js     802297 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80216b:	83 ec 04             	sub    $0x4,%esp
  80216e:	68 07 04 00 00       	push   $0x407
  802173:	ff 75 f4             	pushl  -0xc(%ebp)
  802176:	6a 00                	push   $0x0
  802178:	e8 2b ec ff ff       	call   800da8 <sys_page_alloc>
  80217d:	83 c4 10             	add    $0x10,%esp
  802180:	89 c2                	mov    %eax,%edx
  802182:	85 c0                	test   %eax,%eax
  802184:	0f 88 0d 01 00 00    	js     802297 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80218a:	83 ec 0c             	sub    $0xc,%esp
  80218d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802190:	50                   	push   %eax
  802191:	e8 d8 f4 ff ff       	call   80166e <fd_alloc>
  802196:	89 c3                	mov    %eax,%ebx
  802198:	83 c4 10             	add    $0x10,%esp
  80219b:	85 c0                	test   %eax,%eax
  80219d:	0f 88 e2 00 00 00    	js     802285 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021a3:	83 ec 04             	sub    $0x4,%esp
  8021a6:	68 07 04 00 00       	push   $0x407
  8021ab:	ff 75 f0             	pushl  -0x10(%ebp)
  8021ae:	6a 00                	push   $0x0
  8021b0:	e8 f3 eb ff ff       	call   800da8 <sys_page_alloc>
  8021b5:	89 c3                	mov    %eax,%ebx
  8021b7:	83 c4 10             	add    $0x10,%esp
  8021ba:	85 c0                	test   %eax,%eax
  8021bc:	0f 88 c3 00 00 00    	js     802285 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021c2:	83 ec 0c             	sub    $0xc,%esp
  8021c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c8:	e8 8a f4 ff ff       	call   801657 <fd2data>
  8021cd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021cf:	83 c4 0c             	add    $0xc,%esp
  8021d2:	68 07 04 00 00       	push   $0x407
  8021d7:	50                   	push   %eax
  8021d8:	6a 00                	push   $0x0
  8021da:	e8 c9 eb ff ff       	call   800da8 <sys_page_alloc>
  8021df:	89 c3                	mov    %eax,%ebx
  8021e1:	83 c4 10             	add    $0x10,%esp
  8021e4:	85 c0                	test   %eax,%eax
  8021e6:	0f 88 89 00 00 00    	js     802275 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ec:	83 ec 0c             	sub    $0xc,%esp
  8021ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8021f2:	e8 60 f4 ff ff       	call   801657 <fd2data>
  8021f7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021fe:	50                   	push   %eax
  8021ff:	6a 00                	push   $0x0
  802201:	56                   	push   %esi
  802202:	6a 00                	push   $0x0
  802204:	e8 e2 eb ff ff       	call   800deb <sys_page_map>
  802209:	89 c3                	mov    %eax,%ebx
  80220b:	83 c4 20             	add    $0x20,%esp
  80220e:	85 c0                	test   %eax,%eax
  802210:	78 55                	js     802267 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802212:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802218:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80221d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802220:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802227:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80222d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802230:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802232:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802235:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80223c:	83 ec 0c             	sub    $0xc,%esp
  80223f:	ff 75 f4             	pushl  -0xc(%ebp)
  802242:	e8 00 f4 ff ff       	call   801647 <fd2num>
  802247:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80224a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80224c:	83 c4 04             	add    $0x4,%esp
  80224f:	ff 75 f0             	pushl  -0x10(%ebp)
  802252:	e8 f0 f3 ff ff       	call   801647 <fd2num>
  802257:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80225a:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80225d:	83 c4 10             	add    $0x10,%esp
  802260:	ba 00 00 00 00       	mov    $0x0,%edx
  802265:	eb 30                	jmp    802297 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802267:	83 ec 08             	sub    $0x8,%esp
  80226a:	56                   	push   %esi
  80226b:	6a 00                	push   $0x0
  80226d:	e8 bb eb ff ff       	call   800e2d <sys_page_unmap>
  802272:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802275:	83 ec 08             	sub    $0x8,%esp
  802278:	ff 75 f0             	pushl  -0x10(%ebp)
  80227b:	6a 00                	push   $0x0
  80227d:	e8 ab eb ff ff       	call   800e2d <sys_page_unmap>
  802282:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802285:	83 ec 08             	sub    $0x8,%esp
  802288:	ff 75 f4             	pushl  -0xc(%ebp)
  80228b:	6a 00                	push   $0x0
  80228d:	e8 9b eb ff ff       	call   800e2d <sys_page_unmap>
  802292:	83 c4 10             	add    $0x10,%esp
  802295:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802297:	89 d0                	mov    %edx,%eax
  802299:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80229c:	5b                   	pop    %ebx
  80229d:	5e                   	pop    %esi
  80229e:	5d                   	pop    %ebp
  80229f:	c3                   	ret    

008022a0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022a9:	50                   	push   %eax
  8022aa:	ff 75 08             	pushl  0x8(%ebp)
  8022ad:	e8 0b f4 ff ff       	call   8016bd <fd_lookup>
  8022b2:	83 c4 10             	add    $0x10,%esp
  8022b5:	85 c0                	test   %eax,%eax
  8022b7:	78 18                	js     8022d1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022b9:	83 ec 0c             	sub    $0xc,%esp
  8022bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8022bf:	e8 93 f3 ff ff       	call   801657 <fd2data>
	return _pipeisclosed(fd, p);
  8022c4:	89 c2                	mov    %eax,%edx
  8022c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c9:	e8 18 fd ff ff       	call   801fe6 <_pipeisclosed>
  8022ce:	83 c4 10             	add    $0x10,%esp
}
  8022d1:	c9                   	leave  
  8022d2:	c3                   	ret    

008022d3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022d3:	55                   	push   %ebp
  8022d4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    

008022dd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022dd:	55                   	push   %ebp
  8022de:	89 e5                	mov    %esp,%ebp
  8022e0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022e3:	68 3a 2e 80 00       	push   $0x802e3a
  8022e8:	ff 75 0c             	pushl  0xc(%ebp)
  8022eb:	e8 b5 e6 ff ff       	call   8009a5 <strcpy>
	return 0;
}
  8022f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8022f5:	c9                   	leave  
  8022f6:	c3                   	ret    

008022f7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022f7:	55                   	push   %ebp
  8022f8:	89 e5                	mov    %esp,%ebp
  8022fa:	57                   	push   %edi
  8022fb:	56                   	push   %esi
  8022fc:	53                   	push   %ebx
  8022fd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802303:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802308:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80230e:	eb 2d                	jmp    80233d <devcons_write+0x46>
		m = n - tot;
  802310:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802313:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802315:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802318:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80231d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802320:	83 ec 04             	sub    $0x4,%esp
  802323:	53                   	push   %ebx
  802324:	03 45 0c             	add    0xc(%ebp),%eax
  802327:	50                   	push   %eax
  802328:	57                   	push   %edi
  802329:	e8 09 e8 ff ff       	call   800b37 <memmove>
		sys_cputs(buf, m);
  80232e:	83 c4 08             	add    $0x8,%esp
  802331:	53                   	push   %ebx
  802332:	57                   	push   %edi
  802333:	e8 b4 e9 ff ff       	call   800cec <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802338:	01 de                	add    %ebx,%esi
  80233a:	83 c4 10             	add    $0x10,%esp
  80233d:	89 f0                	mov    %esi,%eax
  80233f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802342:	72 cc                	jb     802310 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802344:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802347:	5b                   	pop    %ebx
  802348:	5e                   	pop    %esi
  802349:	5f                   	pop    %edi
  80234a:	5d                   	pop    %ebp
  80234b:	c3                   	ret    

0080234c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80234c:	55                   	push   %ebp
  80234d:	89 e5                	mov    %esp,%ebp
  80234f:	83 ec 08             	sub    $0x8,%esp
  802352:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802357:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80235b:	74 2a                	je     802387 <devcons_read+0x3b>
  80235d:	eb 05                	jmp    802364 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80235f:	e8 25 ea ff ff       	call   800d89 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802364:	e8 a1 e9 ff ff       	call   800d0a <sys_cgetc>
  802369:	85 c0                	test   %eax,%eax
  80236b:	74 f2                	je     80235f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80236d:	85 c0                	test   %eax,%eax
  80236f:	78 16                	js     802387 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802371:	83 f8 04             	cmp    $0x4,%eax
  802374:	74 0c                	je     802382 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802376:	8b 55 0c             	mov    0xc(%ebp),%edx
  802379:	88 02                	mov    %al,(%edx)
	return 1;
  80237b:	b8 01 00 00 00       	mov    $0x1,%eax
  802380:	eb 05                	jmp    802387 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802382:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802387:	c9                   	leave  
  802388:	c3                   	ret    

00802389 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802389:	55                   	push   %ebp
  80238a:	89 e5                	mov    %esp,%ebp
  80238c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80238f:	8b 45 08             	mov    0x8(%ebp),%eax
  802392:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802395:	6a 01                	push   $0x1
  802397:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80239a:	50                   	push   %eax
  80239b:	e8 4c e9 ff ff       	call   800cec <sys_cputs>
}
  8023a0:	83 c4 10             	add    $0x10,%esp
  8023a3:	c9                   	leave  
  8023a4:	c3                   	ret    

008023a5 <getchar>:

int
getchar(void)
{
  8023a5:	55                   	push   %ebp
  8023a6:	89 e5                	mov    %esp,%ebp
  8023a8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023ab:	6a 01                	push   $0x1
  8023ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023b0:	50                   	push   %eax
  8023b1:	6a 00                	push   $0x0
  8023b3:	e8 6e f5 ff ff       	call   801926 <read>
	if (r < 0)
  8023b8:	83 c4 10             	add    $0x10,%esp
  8023bb:	85 c0                	test   %eax,%eax
  8023bd:	78 0f                	js     8023ce <getchar+0x29>
		return r;
	if (r < 1)
  8023bf:	85 c0                	test   %eax,%eax
  8023c1:	7e 06                	jle    8023c9 <getchar+0x24>
		return -E_EOF;
	return c;
  8023c3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023c7:	eb 05                	jmp    8023ce <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023c9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023ce:	c9                   	leave  
  8023cf:	c3                   	ret    

008023d0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d9:	50                   	push   %eax
  8023da:	ff 75 08             	pushl  0x8(%ebp)
  8023dd:	e8 db f2 ff ff       	call   8016bd <fd_lookup>
  8023e2:	83 c4 10             	add    $0x10,%esp
  8023e5:	85 c0                	test   %eax,%eax
  8023e7:	78 11                	js     8023fa <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ec:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023f2:	39 10                	cmp    %edx,(%eax)
  8023f4:	0f 94 c0             	sete   %al
  8023f7:	0f b6 c0             	movzbl %al,%eax
}
  8023fa:	c9                   	leave  
  8023fb:	c3                   	ret    

008023fc <opencons>:

int
opencons(void)
{
  8023fc:	55                   	push   %ebp
  8023fd:	89 e5                	mov    %esp,%ebp
  8023ff:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802402:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802405:	50                   	push   %eax
  802406:	e8 63 f2 ff ff       	call   80166e <fd_alloc>
  80240b:	83 c4 10             	add    $0x10,%esp
		return r;
  80240e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802410:	85 c0                	test   %eax,%eax
  802412:	78 3e                	js     802452 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802414:	83 ec 04             	sub    $0x4,%esp
  802417:	68 07 04 00 00       	push   $0x407
  80241c:	ff 75 f4             	pushl  -0xc(%ebp)
  80241f:	6a 00                	push   $0x0
  802421:	e8 82 e9 ff ff       	call   800da8 <sys_page_alloc>
  802426:	83 c4 10             	add    $0x10,%esp
		return r;
  802429:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80242b:	85 c0                	test   %eax,%eax
  80242d:	78 23                	js     802452 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80242f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802435:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802438:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80243a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80243d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802444:	83 ec 0c             	sub    $0xc,%esp
  802447:	50                   	push   %eax
  802448:	e8 fa f1 ff ff       	call   801647 <fd2num>
  80244d:	89 c2                	mov    %eax,%edx
  80244f:	83 c4 10             	add    $0x10,%esp
}
  802452:	89 d0                	mov    %edx,%eax
  802454:	c9                   	leave  
  802455:	c3                   	ret    

00802456 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802456:	55                   	push   %ebp
  802457:	89 e5                	mov    %esp,%ebp
  802459:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80245c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802463:	75 2a                	jne    80248f <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802465:	83 ec 04             	sub    $0x4,%esp
  802468:	6a 07                	push   $0x7
  80246a:	68 00 f0 bf ee       	push   $0xeebff000
  80246f:	6a 00                	push   $0x0
  802471:	e8 32 e9 ff ff       	call   800da8 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802476:	83 c4 10             	add    $0x10,%esp
  802479:	85 c0                	test   %eax,%eax
  80247b:	79 12                	jns    80248f <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80247d:	50                   	push   %eax
  80247e:	68 52 2d 80 00       	push   $0x802d52
  802483:	6a 23                	push   $0x23
  802485:	68 46 2e 80 00       	push   $0x802e46
  80248a:	e8 b8 de ff ff       	call   800347 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80248f:	8b 45 08             	mov    0x8(%ebp),%eax
  802492:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802497:	83 ec 08             	sub    $0x8,%esp
  80249a:	68 c1 24 80 00       	push   $0x8024c1
  80249f:	6a 00                	push   $0x0
  8024a1:	e8 4d ea ff ff       	call   800ef3 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8024a6:	83 c4 10             	add    $0x10,%esp
  8024a9:	85 c0                	test   %eax,%eax
  8024ab:	79 12                	jns    8024bf <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8024ad:	50                   	push   %eax
  8024ae:	68 52 2d 80 00       	push   $0x802d52
  8024b3:	6a 2c                	push   $0x2c
  8024b5:	68 46 2e 80 00       	push   $0x802e46
  8024ba:	e8 88 de ff ff       	call   800347 <_panic>
	}
}
  8024bf:	c9                   	leave  
  8024c0:	c3                   	ret    

008024c1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024c1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024c2:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8024c7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024c9:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8024cc:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8024d0:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8024d5:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8024d9:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8024db:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8024de:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8024df:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8024e2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8024e3:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8024e4:	c3                   	ret    

008024e5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024e5:	55                   	push   %ebp
  8024e6:	89 e5                	mov    %esp,%ebp
  8024e8:	56                   	push   %esi
  8024e9:	53                   	push   %ebx
  8024ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8024ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8024f3:	85 c0                	test   %eax,%eax
  8024f5:	75 12                	jne    802509 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8024f7:	83 ec 0c             	sub    $0xc,%esp
  8024fa:	68 00 00 c0 ee       	push   $0xeec00000
  8024ff:	e8 54 ea ff ff       	call   800f58 <sys_ipc_recv>
  802504:	83 c4 10             	add    $0x10,%esp
  802507:	eb 0c                	jmp    802515 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802509:	83 ec 0c             	sub    $0xc,%esp
  80250c:	50                   	push   %eax
  80250d:	e8 46 ea ff ff       	call   800f58 <sys_ipc_recv>
  802512:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802515:	85 f6                	test   %esi,%esi
  802517:	0f 95 c1             	setne  %cl
  80251a:	85 db                	test   %ebx,%ebx
  80251c:	0f 95 c2             	setne  %dl
  80251f:	84 d1                	test   %dl,%cl
  802521:	74 09                	je     80252c <ipc_recv+0x47>
  802523:	89 c2                	mov    %eax,%edx
  802525:	c1 ea 1f             	shr    $0x1f,%edx
  802528:	84 d2                	test   %dl,%dl
  80252a:	75 2d                	jne    802559 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80252c:	85 f6                	test   %esi,%esi
  80252e:	74 0d                	je     80253d <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802530:	a1 20 44 80 00       	mov    0x804420,%eax
  802535:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  80253b:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80253d:	85 db                	test   %ebx,%ebx
  80253f:	74 0d                	je     80254e <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802541:	a1 20 44 80 00       	mov    0x804420,%eax
  802546:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80254c:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80254e:	a1 20 44 80 00       	mov    0x804420,%eax
  802553:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802559:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80255c:	5b                   	pop    %ebx
  80255d:	5e                   	pop    %esi
  80255e:	5d                   	pop    %ebp
  80255f:	c3                   	ret    

00802560 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802560:	55                   	push   %ebp
  802561:	89 e5                	mov    %esp,%ebp
  802563:	57                   	push   %edi
  802564:	56                   	push   %esi
  802565:	53                   	push   %ebx
  802566:	83 ec 0c             	sub    $0xc,%esp
  802569:	8b 7d 08             	mov    0x8(%ebp),%edi
  80256c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80256f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802572:	85 db                	test   %ebx,%ebx
  802574:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802579:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80257c:	ff 75 14             	pushl  0x14(%ebp)
  80257f:	53                   	push   %ebx
  802580:	56                   	push   %esi
  802581:	57                   	push   %edi
  802582:	e8 ae e9 ff ff       	call   800f35 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802587:	89 c2                	mov    %eax,%edx
  802589:	c1 ea 1f             	shr    $0x1f,%edx
  80258c:	83 c4 10             	add    $0x10,%esp
  80258f:	84 d2                	test   %dl,%dl
  802591:	74 17                	je     8025aa <ipc_send+0x4a>
  802593:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802596:	74 12                	je     8025aa <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802598:	50                   	push   %eax
  802599:	68 54 2e 80 00       	push   $0x802e54
  80259e:	6a 47                	push   $0x47
  8025a0:	68 62 2e 80 00       	push   $0x802e62
  8025a5:	e8 9d dd ff ff       	call   800347 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8025aa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025ad:	75 07                	jne    8025b6 <ipc_send+0x56>
			sys_yield();
  8025af:	e8 d5 e7 ff ff       	call   800d89 <sys_yield>
  8025b4:	eb c6                	jmp    80257c <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8025b6:	85 c0                	test   %eax,%eax
  8025b8:	75 c2                	jne    80257c <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8025ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025bd:	5b                   	pop    %ebx
  8025be:	5e                   	pop    %esi
  8025bf:	5f                   	pop    %edi
  8025c0:	5d                   	pop    %ebp
  8025c1:	c3                   	ret    

008025c2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025c2:	55                   	push   %ebp
  8025c3:	89 e5                	mov    %esp,%ebp
  8025c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025c8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025cd:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8025d3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025d9:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8025df:	39 ca                	cmp    %ecx,%edx
  8025e1:	75 13                	jne    8025f6 <ipc_find_env+0x34>
			return envs[i].env_id;
  8025e3:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8025e9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025ee:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8025f4:	eb 0f                	jmp    802605 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025f6:	83 c0 01             	add    $0x1,%eax
  8025f9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025fe:	75 cd                	jne    8025cd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802600:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802605:	5d                   	pop    %ebp
  802606:	c3                   	ret    

00802607 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802607:	55                   	push   %ebp
  802608:	89 e5                	mov    %esp,%ebp
  80260a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80260d:	89 d0                	mov    %edx,%eax
  80260f:	c1 e8 16             	shr    $0x16,%eax
  802612:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802619:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80261e:	f6 c1 01             	test   $0x1,%cl
  802621:	74 1d                	je     802640 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802623:	c1 ea 0c             	shr    $0xc,%edx
  802626:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80262d:	f6 c2 01             	test   $0x1,%dl
  802630:	74 0e                	je     802640 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802632:	c1 ea 0c             	shr    $0xc,%edx
  802635:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80263c:	ef 
  80263d:	0f b7 c0             	movzwl %ax,%eax
}
  802640:	5d                   	pop    %ebp
  802641:	c3                   	ret    
  802642:	66 90                	xchg   %ax,%ax
  802644:	66 90                	xchg   %ax,%ax
  802646:	66 90                	xchg   %ax,%ax
  802648:	66 90                	xchg   %ax,%ax
  80264a:	66 90                	xchg   %ax,%ax
  80264c:	66 90                	xchg   %ax,%ax
  80264e:	66 90                	xchg   %ax,%ax

00802650 <__udivdi3>:
  802650:	55                   	push   %ebp
  802651:	57                   	push   %edi
  802652:	56                   	push   %esi
  802653:	53                   	push   %ebx
  802654:	83 ec 1c             	sub    $0x1c,%esp
  802657:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80265b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80265f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802663:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802667:	85 f6                	test   %esi,%esi
  802669:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80266d:	89 ca                	mov    %ecx,%edx
  80266f:	89 f8                	mov    %edi,%eax
  802671:	75 3d                	jne    8026b0 <__udivdi3+0x60>
  802673:	39 cf                	cmp    %ecx,%edi
  802675:	0f 87 c5 00 00 00    	ja     802740 <__udivdi3+0xf0>
  80267b:	85 ff                	test   %edi,%edi
  80267d:	89 fd                	mov    %edi,%ebp
  80267f:	75 0b                	jne    80268c <__udivdi3+0x3c>
  802681:	b8 01 00 00 00       	mov    $0x1,%eax
  802686:	31 d2                	xor    %edx,%edx
  802688:	f7 f7                	div    %edi
  80268a:	89 c5                	mov    %eax,%ebp
  80268c:	89 c8                	mov    %ecx,%eax
  80268e:	31 d2                	xor    %edx,%edx
  802690:	f7 f5                	div    %ebp
  802692:	89 c1                	mov    %eax,%ecx
  802694:	89 d8                	mov    %ebx,%eax
  802696:	89 cf                	mov    %ecx,%edi
  802698:	f7 f5                	div    %ebp
  80269a:	89 c3                	mov    %eax,%ebx
  80269c:	89 d8                	mov    %ebx,%eax
  80269e:	89 fa                	mov    %edi,%edx
  8026a0:	83 c4 1c             	add    $0x1c,%esp
  8026a3:	5b                   	pop    %ebx
  8026a4:	5e                   	pop    %esi
  8026a5:	5f                   	pop    %edi
  8026a6:	5d                   	pop    %ebp
  8026a7:	c3                   	ret    
  8026a8:	90                   	nop
  8026a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	39 ce                	cmp    %ecx,%esi
  8026b2:	77 74                	ja     802728 <__udivdi3+0xd8>
  8026b4:	0f bd fe             	bsr    %esi,%edi
  8026b7:	83 f7 1f             	xor    $0x1f,%edi
  8026ba:	0f 84 98 00 00 00    	je     802758 <__udivdi3+0x108>
  8026c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8026c5:	89 f9                	mov    %edi,%ecx
  8026c7:	89 c5                	mov    %eax,%ebp
  8026c9:	29 fb                	sub    %edi,%ebx
  8026cb:	d3 e6                	shl    %cl,%esi
  8026cd:	89 d9                	mov    %ebx,%ecx
  8026cf:	d3 ed                	shr    %cl,%ebp
  8026d1:	89 f9                	mov    %edi,%ecx
  8026d3:	d3 e0                	shl    %cl,%eax
  8026d5:	09 ee                	or     %ebp,%esi
  8026d7:	89 d9                	mov    %ebx,%ecx
  8026d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026dd:	89 d5                	mov    %edx,%ebp
  8026df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026e3:	d3 ed                	shr    %cl,%ebp
  8026e5:	89 f9                	mov    %edi,%ecx
  8026e7:	d3 e2                	shl    %cl,%edx
  8026e9:	89 d9                	mov    %ebx,%ecx
  8026eb:	d3 e8                	shr    %cl,%eax
  8026ed:	09 c2                	or     %eax,%edx
  8026ef:	89 d0                	mov    %edx,%eax
  8026f1:	89 ea                	mov    %ebp,%edx
  8026f3:	f7 f6                	div    %esi
  8026f5:	89 d5                	mov    %edx,%ebp
  8026f7:	89 c3                	mov    %eax,%ebx
  8026f9:	f7 64 24 0c          	mull   0xc(%esp)
  8026fd:	39 d5                	cmp    %edx,%ebp
  8026ff:	72 10                	jb     802711 <__udivdi3+0xc1>
  802701:	8b 74 24 08          	mov    0x8(%esp),%esi
  802705:	89 f9                	mov    %edi,%ecx
  802707:	d3 e6                	shl    %cl,%esi
  802709:	39 c6                	cmp    %eax,%esi
  80270b:	73 07                	jae    802714 <__udivdi3+0xc4>
  80270d:	39 d5                	cmp    %edx,%ebp
  80270f:	75 03                	jne    802714 <__udivdi3+0xc4>
  802711:	83 eb 01             	sub    $0x1,%ebx
  802714:	31 ff                	xor    %edi,%edi
  802716:	89 d8                	mov    %ebx,%eax
  802718:	89 fa                	mov    %edi,%edx
  80271a:	83 c4 1c             	add    $0x1c,%esp
  80271d:	5b                   	pop    %ebx
  80271e:	5e                   	pop    %esi
  80271f:	5f                   	pop    %edi
  802720:	5d                   	pop    %ebp
  802721:	c3                   	ret    
  802722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802728:	31 ff                	xor    %edi,%edi
  80272a:	31 db                	xor    %ebx,%ebx
  80272c:	89 d8                	mov    %ebx,%eax
  80272e:	89 fa                	mov    %edi,%edx
  802730:	83 c4 1c             	add    $0x1c,%esp
  802733:	5b                   	pop    %ebx
  802734:	5e                   	pop    %esi
  802735:	5f                   	pop    %edi
  802736:	5d                   	pop    %ebp
  802737:	c3                   	ret    
  802738:	90                   	nop
  802739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802740:	89 d8                	mov    %ebx,%eax
  802742:	f7 f7                	div    %edi
  802744:	31 ff                	xor    %edi,%edi
  802746:	89 c3                	mov    %eax,%ebx
  802748:	89 d8                	mov    %ebx,%eax
  80274a:	89 fa                	mov    %edi,%edx
  80274c:	83 c4 1c             	add    $0x1c,%esp
  80274f:	5b                   	pop    %ebx
  802750:	5e                   	pop    %esi
  802751:	5f                   	pop    %edi
  802752:	5d                   	pop    %ebp
  802753:	c3                   	ret    
  802754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802758:	39 ce                	cmp    %ecx,%esi
  80275a:	72 0c                	jb     802768 <__udivdi3+0x118>
  80275c:	31 db                	xor    %ebx,%ebx
  80275e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802762:	0f 87 34 ff ff ff    	ja     80269c <__udivdi3+0x4c>
  802768:	bb 01 00 00 00       	mov    $0x1,%ebx
  80276d:	e9 2a ff ff ff       	jmp    80269c <__udivdi3+0x4c>
  802772:	66 90                	xchg   %ax,%ax
  802774:	66 90                	xchg   %ax,%ax
  802776:	66 90                	xchg   %ax,%ax
  802778:	66 90                	xchg   %ax,%ax
  80277a:	66 90                	xchg   %ax,%ax
  80277c:	66 90                	xchg   %ax,%ax
  80277e:	66 90                	xchg   %ax,%ax

00802780 <__umoddi3>:
  802780:	55                   	push   %ebp
  802781:	57                   	push   %edi
  802782:	56                   	push   %esi
  802783:	53                   	push   %ebx
  802784:	83 ec 1c             	sub    $0x1c,%esp
  802787:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80278b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80278f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802793:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802797:	85 d2                	test   %edx,%edx
  802799:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80279d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027a1:	89 f3                	mov    %esi,%ebx
  8027a3:	89 3c 24             	mov    %edi,(%esp)
  8027a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027aa:	75 1c                	jne    8027c8 <__umoddi3+0x48>
  8027ac:	39 f7                	cmp    %esi,%edi
  8027ae:	76 50                	jbe    802800 <__umoddi3+0x80>
  8027b0:	89 c8                	mov    %ecx,%eax
  8027b2:	89 f2                	mov    %esi,%edx
  8027b4:	f7 f7                	div    %edi
  8027b6:	89 d0                	mov    %edx,%eax
  8027b8:	31 d2                	xor    %edx,%edx
  8027ba:	83 c4 1c             	add    $0x1c,%esp
  8027bd:	5b                   	pop    %ebx
  8027be:	5e                   	pop    %esi
  8027bf:	5f                   	pop    %edi
  8027c0:	5d                   	pop    %ebp
  8027c1:	c3                   	ret    
  8027c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027c8:	39 f2                	cmp    %esi,%edx
  8027ca:	89 d0                	mov    %edx,%eax
  8027cc:	77 52                	ja     802820 <__umoddi3+0xa0>
  8027ce:	0f bd ea             	bsr    %edx,%ebp
  8027d1:	83 f5 1f             	xor    $0x1f,%ebp
  8027d4:	75 5a                	jne    802830 <__umoddi3+0xb0>
  8027d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8027da:	0f 82 e0 00 00 00    	jb     8028c0 <__umoddi3+0x140>
  8027e0:	39 0c 24             	cmp    %ecx,(%esp)
  8027e3:	0f 86 d7 00 00 00    	jbe    8028c0 <__umoddi3+0x140>
  8027e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027f1:	83 c4 1c             	add    $0x1c,%esp
  8027f4:	5b                   	pop    %ebx
  8027f5:	5e                   	pop    %esi
  8027f6:	5f                   	pop    %edi
  8027f7:	5d                   	pop    %ebp
  8027f8:	c3                   	ret    
  8027f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802800:	85 ff                	test   %edi,%edi
  802802:	89 fd                	mov    %edi,%ebp
  802804:	75 0b                	jne    802811 <__umoddi3+0x91>
  802806:	b8 01 00 00 00       	mov    $0x1,%eax
  80280b:	31 d2                	xor    %edx,%edx
  80280d:	f7 f7                	div    %edi
  80280f:	89 c5                	mov    %eax,%ebp
  802811:	89 f0                	mov    %esi,%eax
  802813:	31 d2                	xor    %edx,%edx
  802815:	f7 f5                	div    %ebp
  802817:	89 c8                	mov    %ecx,%eax
  802819:	f7 f5                	div    %ebp
  80281b:	89 d0                	mov    %edx,%eax
  80281d:	eb 99                	jmp    8027b8 <__umoddi3+0x38>
  80281f:	90                   	nop
  802820:	89 c8                	mov    %ecx,%eax
  802822:	89 f2                	mov    %esi,%edx
  802824:	83 c4 1c             	add    $0x1c,%esp
  802827:	5b                   	pop    %ebx
  802828:	5e                   	pop    %esi
  802829:	5f                   	pop    %edi
  80282a:	5d                   	pop    %ebp
  80282b:	c3                   	ret    
  80282c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802830:	8b 34 24             	mov    (%esp),%esi
  802833:	bf 20 00 00 00       	mov    $0x20,%edi
  802838:	89 e9                	mov    %ebp,%ecx
  80283a:	29 ef                	sub    %ebp,%edi
  80283c:	d3 e0                	shl    %cl,%eax
  80283e:	89 f9                	mov    %edi,%ecx
  802840:	89 f2                	mov    %esi,%edx
  802842:	d3 ea                	shr    %cl,%edx
  802844:	89 e9                	mov    %ebp,%ecx
  802846:	09 c2                	or     %eax,%edx
  802848:	89 d8                	mov    %ebx,%eax
  80284a:	89 14 24             	mov    %edx,(%esp)
  80284d:	89 f2                	mov    %esi,%edx
  80284f:	d3 e2                	shl    %cl,%edx
  802851:	89 f9                	mov    %edi,%ecx
  802853:	89 54 24 04          	mov    %edx,0x4(%esp)
  802857:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80285b:	d3 e8                	shr    %cl,%eax
  80285d:	89 e9                	mov    %ebp,%ecx
  80285f:	89 c6                	mov    %eax,%esi
  802861:	d3 e3                	shl    %cl,%ebx
  802863:	89 f9                	mov    %edi,%ecx
  802865:	89 d0                	mov    %edx,%eax
  802867:	d3 e8                	shr    %cl,%eax
  802869:	89 e9                	mov    %ebp,%ecx
  80286b:	09 d8                	or     %ebx,%eax
  80286d:	89 d3                	mov    %edx,%ebx
  80286f:	89 f2                	mov    %esi,%edx
  802871:	f7 34 24             	divl   (%esp)
  802874:	89 d6                	mov    %edx,%esi
  802876:	d3 e3                	shl    %cl,%ebx
  802878:	f7 64 24 04          	mull   0x4(%esp)
  80287c:	39 d6                	cmp    %edx,%esi
  80287e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802882:	89 d1                	mov    %edx,%ecx
  802884:	89 c3                	mov    %eax,%ebx
  802886:	72 08                	jb     802890 <__umoddi3+0x110>
  802888:	75 11                	jne    80289b <__umoddi3+0x11b>
  80288a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80288e:	73 0b                	jae    80289b <__umoddi3+0x11b>
  802890:	2b 44 24 04          	sub    0x4(%esp),%eax
  802894:	1b 14 24             	sbb    (%esp),%edx
  802897:	89 d1                	mov    %edx,%ecx
  802899:	89 c3                	mov    %eax,%ebx
  80289b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80289f:	29 da                	sub    %ebx,%edx
  8028a1:	19 ce                	sbb    %ecx,%esi
  8028a3:	89 f9                	mov    %edi,%ecx
  8028a5:	89 f0                	mov    %esi,%eax
  8028a7:	d3 e0                	shl    %cl,%eax
  8028a9:	89 e9                	mov    %ebp,%ecx
  8028ab:	d3 ea                	shr    %cl,%edx
  8028ad:	89 e9                	mov    %ebp,%ecx
  8028af:	d3 ee                	shr    %cl,%esi
  8028b1:	09 d0                	or     %edx,%eax
  8028b3:	89 f2                	mov    %esi,%edx
  8028b5:	83 c4 1c             	add    $0x1c,%esp
  8028b8:	5b                   	pop    %ebx
  8028b9:	5e                   	pop    %esi
  8028ba:	5f                   	pop    %edi
  8028bb:	5d                   	pop    %ebp
  8028bc:	c3                   	ret    
  8028bd:	8d 76 00             	lea    0x0(%esi),%esi
  8028c0:	29 f9                	sub    %edi,%ecx
  8028c2:	19 d6                	sbb    %edx,%esi
  8028c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028cc:	e9 18 ff ff ff       	jmp    8027e9 <__umoddi3+0x69>
