
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
  80005a:	68 42 23 80 00       	push   $0x802342
  80005f:	e8 eb 19 00 00       	call   801a4f <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 a8 23 80 00       	mov    $0x8023a8,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1e                	je     800093 <ls1+0x60>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 2b 09 00 00       	call   8009a9 <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
		else
			sep = "";
  800081:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800086:	ba a8 23 80 00       	mov    $0x8023a8,%edx
  80008b:	b8 40 23 80 00       	mov    $0x802340,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 4b 23 80 00       	push   $0x80234b
  80009d:	e8 ad 19 00 00       	call   801a4f <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 f5 27 80 00       	push   $0x8027f5
  8000b0:	e8 9a 19 00 00       	call   801a4f <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 40 23 80 00       	push   $0x802340
  8000cf:	e8 7b 19 00 00       	call   801a4f <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 a7 23 80 00       	push   $0x8023a7
  8000df:	e8 6b 19 00 00       	call   801a4f <printf>
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
  800100:	e8 ac 17 00 00       	call   8018b1 <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 50 23 80 00       	push   $0x802350
  800118:	6a 1d                	push   $0x1d
  80011a:	68 5c 23 80 00       	push   $0x80235c
  80011f:	e8 60 02 00 00       	call   800384 <_panic>
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
  80015f:	e8 53 13 00 00       	call   8014b7 <readn>
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
  800173:	68 66 23 80 00       	push   $0x802366
  800178:	6a 22                	push   $0x22
  80017a:	68 5c 23 80 00       	push   $0x80235c
  80017f:	e8 00 02 00 00       	call   800384 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 ac 23 80 00       	push   $0x8023ac
  800192:	6a 24                	push   $0x24
  800194:	68 5c 23 80 00       	push   $0x80235c
  800199:	e8 e6 01 00 00       	call   800384 <_panic>
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
  8001bb:	e8 fc 14 00 00       	call   8016bc <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 81 23 80 00       	push   $0x802381
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 5c 23 80 00       	push   $0x80235c
  8001d8:	e8 a7 01 00 00       	call   800384 <_panic>
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
  800220:	68 8d 23 80 00       	push   $0x80238d
  800225:	e8 25 18 00 00       	call   801a4f <printf>
	exit();
  80022a:	e8 3b 01 00 00       	call   80036a <exit>
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
  800248:	e8 a9 0d 00 00       	call   800ff6 <argstart>
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
  800277:	e8 aa 0d 00 00       	call   801026 <argnext>
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
  800291:	68 a8 23 80 00       	push   $0x8023a8
  800296:	68 40 23 80 00       	push   $0x802340
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
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8002cd:	c7 05 20 44 80 00 00 	movl   $0x0,0x804420
  8002d4:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8002d7:	e8 cb 0a 00 00       	call   800da7 <sys_getenvid>
  8002dc:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8002de:	83 ec 08             	sub    $0x8,%esp
  8002e1:	50                   	push   %eax
  8002e2:	68 cc 23 80 00       	push   $0x8023cc
  8002e7:	e8 71 01 00 00       	call   80045d <cprintf>
  8002ec:	8b 3d 20 44 80 00    	mov    0x804420,%edi
  8002f2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8002f7:	83 c4 10             	add    $0x10,%esp
  8002fa:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8002ff:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  800304:	89 c1                	mov    %eax,%ecx
  800306:	c1 e1 07             	shl    $0x7,%ecx
  800309:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800310:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800313:	39 cb                	cmp    %ecx,%ebx
  800315:	0f 44 fa             	cmove  %edx,%edi
  800318:	b9 01 00 00 00       	mov    $0x1,%ecx
  80031d:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800320:	83 c0 01             	add    $0x1,%eax
  800323:	81 c2 84 00 00 00    	add    $0x84,%edx
  800329:	3d 00 04 00 00       	cmp    $0x400,%eax
  80032e:	75 d4                	jne    800304 <libmain+0x40>
  800330:	89 f0                	mov    %esi,%eax
  800332:	84 c0                	test   %al,%al
  800334:	74 06                	je     80033c <libmain+0x78>
  800336:	89 3d 20 44 80 00    	mov    %edi,0x804420
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80033c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800340:	7e 0a                	jle    80034c <libmain+0x88>
		binaryname = argv[0];
  800342:	8b 45 0c             	mov    0xc(%ebp),%eax
  800345:	8b 00                	mov    (%eax),%eax
  800347:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80034c:	83 ec 08             	sub    $0x8,%esp
  80034f:	ff 75 0c             	pushl  0xc(%ebp)
  800352:	ff 75 08             	pushl  0x8(%ebp)
  800355:	e8 da fe ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  80035a:	e8 0b 00 00 00       	call   80036a <exit>
}
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5f                   	pop    %edi
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800370:	e8 a0 0f 00 00       	call   801315 <close_all>
	sys_env_destroy(0);
  800375:	83 ec 0c             	sub    $0xc,%esp
  800378:	6a 00                	push   $0x0
  80037a:	e8 e7 09 00 00       	call   800d66 <sys_env_destroy>
}
  80037f:	83 c4 10             	add    $0x10,%esp
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800389:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80038c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800392:	e8 10 0a 00 00       	call   800da7 <sys_getenvid>
  800397:	83 ec 0c             	sub    $0xc,%esp
  80039a:	ff 75 0c             	pushl  0xc(%ebp)
  80039d:	ff 75 08             	pushl  0x8(%ebp)
  8003a0:	56                   	push   %esi
  8003a1:	50                   	push   %eax
  8003a2:	68 f8 23 80 00       	push   $0x8023f8
  8003a7:	e8 b1 00 00 00       	call   80045d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003ac:	83 c4 18             	add    $0x18,%esp
  8003af:	53                   	push   %ebx
  8003b0:	ff 75 10             	pushl  0x10(%ebp)
  8003b3:	e8 54 00 00 00       	call   80040c <vcprintf>
	cprintf("\n");
  8003b8:	c7 04 24 a7 23 80 00 	movl   $0x8023a7,(%esp)
  8003bf:	e8 99 00 00 00       	call   80045d <cprintf>
  8003c4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003c7:	cc                   	int3   
  8003c8:	eb fd                	jmp    8003c7 <_panic+0x43>

008003ca <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	53                   	push   %ebx
  8003ce:	83 ec 04             	sub    $0x4,%esp
  8003d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003d4:	8b 13                	mov    (%ebx),%edx
  8003d6:	8d 42 01             	lea    0x1(%edx),%eax
  8003d9:	89 03                	mov    %eax,(%ebx)
  8003db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003de:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003e7:	75 1a                	jne    800403 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	68 ff 00 00 00       	push   $0xff
  8003f1:	8d 43 08             	lea    0x8(%ebx),%eax
  8003f4:	50                   	push   %eax
  8003f5:	e8 2f 09 00 00       	call   800d29 <sys_cputs>
		b->idx = 0;
  8003fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800400:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800403:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800407:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80040a:	c9                   	leave  
  80040b:	c3                   	ret    

0080040c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800415:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80041c:	00 00 00 
	b.cnt = 0;
  80041f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800426:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800429:	ff 75 0c             	pushl  0xc(%ebp)
  80042c:	ff 75 08             	pushl  0x8(%ebp)
  80042f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800435:	50                   	push   %eax
  800436:	68 ca 03 80 00       	push   $0x8003ca
  80043b:	e8 54 01 00 00       	call   800594 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800440:	83 c4 08             	add    $0x8,%esp
  800443:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800449:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80044f:	50                   	push   %eax
  800450:	e8 d4 08 00 00       	call   800d29 <sys_cputs>

	return b.cnt;
}
  800455:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80045b:	c9                   	leave  
  80045c:	c3                   	ret    

0080045d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80045d:	55                   	push   %ebp
  80045e:	89 e5                	mov    %esp,%ebp
  800460:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800463:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800466:	50                   	push   %eax
  800467:	ff 75 08             	pushl  0x8(%ebp)
  80046a:	e8 9d ff ff ff       	call   80040c <vcprintf>
	va_end(ap);

	return cnt;
}
  80046f:	c9                   	leave  
  800470:	c3                   	ret    

00800471 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800471:	55                   	push   %ebp
  800472:	89 e5                	mov    %esp,%ebp
  800474:	57                   	push   %edi
  800475:	56                   	push   %esi
  800476:	53                   	push   %ebx
  800477:	83 ec 1c             	sub    $0x1c,%esp
  80047a:	89 c7                	mov    %eax,%edi
  80047c:	89 d6                	mov    %edx,%esi
  80047e:	8b 45 08             	mov    0x8(%ebp),%eax
  800481:	8b 55 0c             	mov    0xc(%ebp),%edx
  800484:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800487:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80048a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80048d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800492:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800495:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800498:	39 d3                	cmp    %edx,%ebx
  80049a:	72 05                	jb     8004a1 <printnum+0x30>
  80049c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80049f:	77 45                	ja     8004e6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004a1:	83 ec 0c             	sub    $0xc,%esp
  8004a4:	ff 75 18             	pushl  0x18(%ebp)
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8004ad:	53                   	push   %ebx
  8004ae:	ff 75 10             	pushl  0x10(%ebp)
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8004bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c0:	e8 db 1b 00 00       	call   8020a0 <__udivdi3>
  8004c5:	83 c4 18             	add    $0x18,%esp
  8004c8:	52                   	push   %edx
  8004c9:	50                   	push   %eax
  8004ca:	89 f2                	mov    %esi,%edx
  8004cc:	89 f8                	mov    %edi,%eax
  8004ce:	e8 9e ff ff ff       	call   800471 <printnum>
  8004d3:	83 c4 20             	add    $0x20,%esp
  8004d6:	eb 18                	jmp    8004f0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	56                   	push   %esi
  8004dc:	ff 75 18             	pushl  0x18(%ebp)
  8004df:	ff d7                	call   *%edi
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	eb 03                	jmp    8004e9 <printnum+0x78>
  8004e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004e9:	83 eb 01             	sub    $0x1,%ebx
  8004ec:	85 db                	test   %ebx,%ebx
  8004ee:	7f e8                	jg     8004d8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	56                   	push   %esi
  8004f4:	83 ec 04             	sub    $0x4,%esp
  8004f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fd:	ff 75 dc             	pushl  -0x24(%ebp)
  800500:	ff 75 d8             	pushl  -0x28(%ebp)
  800503:	e8 c8 1c 00 00       	call   8021d0 <__umoddi3>
  800508:	83 c4 14             	add    $0x14,%esp
  80050b:	0f be 80 1b 24 80 00 	movsbl 0x80241b(%eax),%eax
  800512:	50                   	push   %eax
  800513:	ff d7                	call   *%edi
}
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80051b:	5b                   	pop    %ebx
  80051c:	5e                   	pop    %esi
  80051d:	5f                   	pop    %edi
  80051e:	5d                   	pop    %ebp
  80051f:	c3                   	ret    

00800520 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800523:	83 fa 01             	cmp    $0x1,%edx
  800526:	7e 0e                	jle    800536 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800528:	8b 10                	mov    (%eax),%edx
  80052a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80052d:	89 08                	mov    %ecx,(%eax)
  80052f:	8b 02                	mov    (%edx),%eax
  800531:	8b 52 04             	mov    0x4(%edx),%edx
  800534:	eb 22                	jmp    800558 <getuint+0x38>
	else if (lflag)
  800536:	85 d2                	test   %edx,%edx
  800538:	74 10                	je     80054a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80053a:	8b 10                	mov    (%eax),%edx
  80053c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80053f:	89 08                	mov    %ecx,(%eax)
  800541:	8b 02                	mov    (%edx),%eax
  800543:	ba 00 00 00 00       	mov    $0x0,%edx
  800548:	eb 0e                	jmp    800558 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80054a:	8b 10                	mov    (%eax),%edx
  80054c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80054f:	89 08                	mov    %ecx,(%eax)
  800551:	8b 02                	mov    (%edx),%eax
  800553:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800558:	5d                   	pop    %ebp
  800559:	c3                   	ret    

0080055a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800560:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800564:	8b 10                	mov    (%eax),%edx
  800566:	3b 50 04             	cmp    0x4(%eax),%edx
  800569:	73 0a                	jae    800575 <sprintputch+0x1b>
		*b->buf++ = ch;
  80056b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80056e:	89 08                	mov    %ecx,(%eax)
  800570:	8b 45 08             	mov    0x8(%ebp),%eax
  800573:	88 02                	mov    %al,(%edx)
}
  800575:	5d                   	pop    %ebp
  800576:	c3                   	ret    

00800577 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800577:	55                   	push   %ebp
  800578:	89 e5                	mov    %esp,%ebp
  80057a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80057d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800580:	50                   	push   %eax
  800581:	ff 75 10             	pushl  0x10(%ebp)
  800584:	ff 75 0c             	pushl  0xc(%ebp)
  800587:	ff 75 08             	pushl  0x8(%ebp)
  80058a:	e8 05 00 00 00       	call   800594 <vprintfmt>
	va_end(ap);
}
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	c9                   	leave  
  800593:	c3                   	ret    

00800594 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800594:	55                   	push   %ebp
  800595:	89 e5                	mov    %esp,%ebp
  800597:	57                   	push   %edi
  800598:	56                   	push   %esi
  800599:	53                   	push   %ebx
  80059a:	83 ec 2c             	sub    $0x2c,%esp
  80059d:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005a6:	eb 12                	jmp    8005ba <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005a8:	85 c0                	test   %eax,%eax
  8005aa:	0f 84 89 03 00 00    	je     800939 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	53                   	push   %ebx
  8005b4:	50                   	push   %eax
  8005b5:	ff d6                	call   *%esi
  8005b7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005ba:	83 c7 01             	add    $0x1,%edi
  8005bd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005c1:	83 f8 25             	cmp    $0x25,%eax
  8005c4:	75 e2                	jne    8005a8 <vprintfmt+0x14>
  8005c6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005ca:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005d1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005d8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005df:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e4:	eb 07                	jmp    8005ed <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005e9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ed:	8d 47 01             	lea    0x1(%edi),%eax
  8005f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005f3:	0f b6 07             	movzbl (%edi),%eax
  8005f6:	0f b6 c8             	movzbl %al,%ecx
  8005f9:	83 e8 23             	sub    $0x23,%eax
  8005fc:	3c 55                	cmp    $0x55,%al
  8005fe:	0f 87 1a 03 00 00    	ja     80091e <vprintfmt+0x38a>
  800604:	0f b6 c0             	movzbl %al,%eax
  800607:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  80060e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800611:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800615:	eb d6                	jmp    8005ed <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800617:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061a:	b8 00 00 00 00       	mov    $0x0,%eax
  80061f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800622:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800625:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800629:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80062c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80062f:	83 fa 09             	cmp    $0x9,%edx
  800632:	77 39                	ja     80066d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800634:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800637:	eb e9                	jmp    800622 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8d 48 04             	lea    0x4(%eax),%ecx
  80063f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800642:	8b 00                	mov    (%eax),%eax
  800644:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800647:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80064a:	eb 27                	jmp    800673 <vprintfmt+0xdf>
  80064c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80064f:	85 c0                	test   %eax,%eax
  800651:	b9 00 00 00 00       	mov    $0x0,%ecx
  800656:	0f 49 c8             	cmovns %eax,%ecx
  800659:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065f:	eb 8c                	jmp    8005ed <vprintfmt+0x59>
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800664:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80066b:	eb 80                	jmp    8005ed <vprintfmt+0x59>
  80066d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800670:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800673:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800677:	0f 89 70 ff ff ff    	jns    8005ed <vprintfmt+0x59>
				width = precision, precision = -1;
  80067d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800680:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800683:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80068a:	e9 5e ff ff ff       	jmp    8005ed <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80068f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800692:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800695:	e9 53 ff ff ff       	jmp    8005ed <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8d 50 04             	lea    0x4(%eax),%edx
  8006a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	ff 30                	pushl  (%eax)
  8006a9:	ff d6                	call   *%esi
			break;
  8006ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006b1:	e9 04 ff ff ff       	jmp    8005ba <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8d 50 04             	lea    0x4(%eax),%edx
  8006bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bf:	8b 00                	mov    (%eax),%eax
  8006c1:	99                   	cltd   
  8006c2:	31 d0                	xor    %edx,%eax
  8006c4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006c6:	83 f8 0f             	cmp    $0xf,%eax
  8006c9:	7f 0b                	jg     8006d6 <vprintfmt+0x142>
  8006cb:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  8006d2:	85 d2                	test   %edx,%edx
  8006d4:	75 18                	jne    8006ee <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8006d6:	50                   	push   %eax
  8006d7:	68 33 24 80 00       	push   $0x802433
  8006dc:	53                   	push   %ebx
  8006dd:	56                   	push   %esi
  8006de:	e8 94 fe ff ff       	call   800577 <printfmt>
  8006e3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006e9:	e9 cc fe ff ff       	jmp    8005ba <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006ee:	52                   	push   %edx
  8006ef:	68 f5 27 80 00       	push   $0x8027f5
  8006f4:	53                   	push   %ebx
  8006f5:	56                   	push   %esi
  8006f6:	e8 7c fe ff ff       	call   800577 <printfmt>
  8006fb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800701:	e9 b4 fe ff ff       	jmp    8005ba <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800711:	85 ff                	test   %edi,%edi
  800713:	b8 2c 24 80 00       	mov    $0x80242c,%eax
  800718:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80071b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80071f:	0f 8e 94 00 00 00    	jle    8007b9 <vprintfmt+0x225>
  800725:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800729:	0f 84 98 00 00 00    	je     8007c7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	ff 75 d0             	pushl  -0x30(%ebp)
  800735:	57                   	push   %edi
  800736:	e8 86 02 00 00       	call   8009c1 <strnlen>
  80073b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80073e:	29 c1                	sub    %eax,%ecx
  800740:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800743:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800746:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80074a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80074d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800750:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800752:	eb 0f                	jmp    800763 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800754:	83 ec 08             	sub    $0x8,%esp
  800757:	53                   	push   %ebx
  800758:	ff 75 e0             	pushl  -0x20(%ebp)
  80075b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80075d:	83 ef 01             	sub    $0x1,%edi
  800760:	83 c4 10             	add    $0x10,%esp
  800763:	85 ff                	test   %edi,%edi
  800765:	7f ed                	jg     800754 <vprintfmt+0x1c0>
  800767:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80076a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80076d:	85 c9                	test   %ecx,%ecx
  80076f:	b8 00 00 00 00       	mov    $0x0,%eax
  800774:	0f 49 c1             	cmovns %ecx,%eax
  800777:	29 c1                	sub    %eax,%ecx
  800779:	89 75 08             	mov    %esi,0x8(%ebp)
  80077c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80077f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800782:	89 cb                	mov    %ecx,%ebx
  800784:	eb 4d                	jmp    8007d3 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800786:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80078a:	74 1b                	je     8007a7 <vprintfmt+0x213>
  80078c:	0f be c0             	movsbl %al,%eax
  80078f:	83 e8 20             	sub    $0x20,%eax
  800792:	83 f8 5e             	cmp    $0x5e,%eax
  800795:	76 10                	jbe    8007a7 <vprintfmt+0x213>
					putch('?', putdat);
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	ff 75 0c             	pushl  0xc(%ebp)
  80079d:	6a 3f                	push   $0x3f
  80079f:	ff 55 08             	call   *0x8(%ebp)
  8007a2:	83 c4 10             	add    $0x10,%esp
  8007a5:	eb 0d                	jmp    8007b4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8007a7:	83 ec 08             	sub    $0x8,%esp
  8007aa:	ff 75 0c             	pushl  0xc(%ebp)
  8007ad:	52                   	push   %edx
  8007ae:	ff 55 08             	call   *0x8(%ebp)
  8007b1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007b4:	83 eb 01             	sub    $0x1,%ebx
  8007b7:	eb 1a                	jmp    8007d3 <vprintfmt+0x23f>
  8007b9:	89 75 08             	mov    %esi,0x8(%ebp)
  8007bc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007bf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007c2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007c5:	eb 0c                	jmp    8007d3 <vprintfmt+0x23f>
  8007c7:	89 75 08             	mov    %esi,0x8(%ebp)
  8007ca:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007cd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007d0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007d3:	83 c7 01             	add    $0x1,%edi
  8007d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007da:	0f be d0             	movsbl %al,%edx
  8007dd:	85 d2                	test   %edx,%edx
  8007df:	74 23                	je     800804 <vprintfmt+0x270>
  8007e1:	85 f6                	test   %esi,%esi
  8007e3:	78 a1                	js     800786 <vprintfmt+0x1f2>
  8007e5:	83 ee 01             	sub    $0x1,%esi
  8007e8:	79 9c                	jns    800786 <vprintfmt+0x1f2>
  8007ea:	89 df                	mov    %ebx,%edi
  8007ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f2:	eb 18                	jmp    80080c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	53                   	push   %ebx
  8007f8:	6a 20                	push   $0x20
  8007fa:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007fc:	83 ef 01             	sub    $0x1,%edi
  8007ff:	83 c4 10             	add    $0x10,%esp
  800802:	eb 08                	jmp    80080c <vprintfmt+0x278>
  800804:	89 df                	mov    %ebx,%edi
  800806:	8b 75 08             	mov    0x8(%ebp),%esi
  800809:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080c:	85 ff                	test   %edi,%edi
  80080e:	7f e4                	jg     8007f4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800810:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800813:	e9 a2 fd ff ff       	jmp    8005ba <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800818:	83 fa 01             	cmp    $0x1,%edx
  80081b:	7e 16                	jle    800833 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	8d 50 08             	lea    0x8(%eax),%edx
  800823:	89 55 14             	mov    %edx,0x14(%ebp)
  800826:	8b 50 04             	mov    0x4(%eax),%edx
  800829:	8b 00                	mov    (%eax),%eax
  80082b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800831:	eb 32                	jmp    800865 <vprintfmt+0x2d1>
	else if (lflag)
  800833:	85 d2                	test   %edx,%edx
  800835:	74 18                	je     80084f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800837:	8b 45 14             	mov    0x14(%ebp),%eax
  80083a:	8d 50 04             	lea    0x4(%eax),%edx
  80083d:	89 55 14             	mov    %edx,0x14(%ebp)
  800840:	8b 00                	mov    (%eax),%eax
  800842:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800845:	89 c1                	mov    %eax,%ecx
  800847:	c1 f9 1f             	sar    $0x1f,%ecx
  80084a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80084d:	eb 16                	jmp    800865 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80084f:	8b 45 14             	mov    0x14(%ebp),%eax
  800852:	8d 50 04             	lea    0x4(%eax),%edx
  800855:	89 55 14             	mov    %edx,0x14(%ebp)
  800858:	8b 00                	mov    (%eax),%eax
  80085a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80085d:	89 c1                	mov    %eax,%ecx
  80085f:	c1 f9 1f             	sar    $0x1f,%ecx
  800862:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800865:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800868:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80086b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800870:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800874:	79 74                	jns    8008ea <vprintfmt+0x356>
				putch('-', putdat);
  800876:	83 ec 08             	sub    $0x8,%esp
  800879:	53                   	push   %ebx
  80087a:	6a 2d                	push   $0x2d
  80087c:	ff d6                	call   *%esi
				num = -(long long) num;
  80087e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800881:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800884:	f7 d8                	neg    %eax
  800886:	83 d2 00             	adc    $0x0,%edx
  800889:	f7 da                	neg    %edx
  80088b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80088e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800893:	eb 55                	jmp    8008ea <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800895:	8d 45 14             	lea    0x14(%ebp),%eax
  800898:	e8 83 fc ff ff       	call   800520 <getuint>
			base = 10;
  80089d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8008a2:	eb 46                	jmp    8008ea <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8008a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a7:	e8 74 fc ff ff       	call   800520 <getuint>
			base = 8;
  8008ac:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8008b1:	eb 37                	jmp    8008ea <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8008b3:	83 ec 08             	sub    $0x8,%esp
  8008b6:	53                   	push   %ebx
  8008b7:	6a 30                	push   $0x30
  8008b9:	ff d6                	call   *%esi
			putch('x', putdat);
  8008bb:	83 c4 08             	add    $0x8,%esp
  8008be:	53                   	push   %ebx
  8008bf:	6a 78                	push   $0x78
  8008c1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c6:	8d 50 04             	lea    0x4(%eax),%edx
  8008c9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008cc:	8b 00                	mov    (%eax),%eax
  8008ce:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008d3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008d6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008db:	eb 0d                	jmp    8008ea <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e0:	e8 3b fc ff ff       	call   800520 <getuint>
			base = 16;
  8008e5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008ea:	83 ec 0c             	sub    $0xc,%esp
  8008ed:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008f1:	57                   	push   %edi
  8008f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8008f5:	51                   	push   %ecx
  8008f6:	52                   	push   %edx
  8008f7:	50                   	push   %eax
  8008f8:	89 da                	mov    %ebx,%edx
  8008fa:	89 f0                	mov    %esi,%eax
  8008fc:	e8 70 fb ff ff       	call   800471 <printnum>
			break;
  800901:	83 c4 20             	add    $0x20,%esp
  800904:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800907:	e9 ae fc ff ff       	jmp    8005ba <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80090c:	83 ec 08             	sub    $0x8,%esp
  80090f:	53                   	push   %ebx
  800910:	51                   	push   %ecx
  800911:	ff d6                	call   *%esi
			break;
  800913:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800916:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800919:	e9 9c fc ff ff       	jmp    8005ba <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	53                   	push   %ebx
  800922:	6a 25                	push   $0x25
  800924:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800926:	83 c4 10             	add    $0x10,%esp
  800929:	eb 03                	jmp    80092e <vprintfmt+0x39a>
  80092b:	83 ef 01             	sub    $0x1,%edi
  80092e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800932:	75 f7                	jne    80092b <vprintfmt+0x397>
  800934:	e9 81 fc ff ff       	jmp    8005ba <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800939:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5f                   	pop    %edi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	83 ec 18             	sub    $0x18,%esp
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80094d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800950:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800954:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800957:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80095e:	85 c0                	test   %eax,%eax
  800960:	74 26                	je     800988 <vsnprintf+0x47>
  800962:	85 d2                	test   %edx,%edx
  800964:	7e 22                	jle    800988 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800966:	ff 75 14             	pushl  0x14(%ebp)
  800969:	ff 75 10             	pushl  0x10(%ebp)
  80096c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80096f:	50                   	push   %eax
  800970:	68 5a 05 80 00       	push   $0x80055a
  800975:	e8 1a fc ff ff       	call   800594 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80097a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80097d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800980:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800983:	83 c4 10             	add    $0x10,%esp
  800986:	eb 05                	jmp    80098d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800988:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    

0080098f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800995:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800998:	50                   	push   %eax
  800999:	ff 75 10             	pushl  0x10(%ebp)
  80099c:	ff 75 0c             	pushl  0xc(%ebp)
  80099f:	ff 75 08             	pushl  0x8(%ebp)
  8009a2:	e8 9a ff ff ff       	call   800941 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    

008009a9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b4:	eb 03                	jmp    8009b9 <strlen+0x10>
		n++;
  8009b6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009bd:	75 f7                	jne    8009b6 <strlen+0xd>
		n++;
	return n;
}
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cf:	eb 03                	jmp    8009d4 <strnlen+0x13>
		n++;
  8009d1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d4:	39 c2                	cmp    %eax,%edx
  8009d6:	74 08                	je     8009e0 <strnlen+0x1f>
  8009d8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009dc:	75 f3                	jne    8009d1 <strnlen+0x10>
  8009de:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	53                   	push   %ebx
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009ec:	89 c2                	mov    %eax,%edx
  8009ee:	83 c2 01             	add    $0x1,%edx
  8009f1:	83 c1 01             	add    $0x1,%ecx
  8009f4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009f8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009fb:	84 db                	test   %bl,%bl
  8009fd:	75 ef                	jne    8009ee <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ff:	5b                   	pop    %ebx
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	53                   	push   %ebx
  800a06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a09:	53                   	push   %ebx
  800a0a:	e8 9a ff ff ff       	call   8009a9 <strlen>
  800a0f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a12:	ff 75 0c             	pushl  0xc(%ebp)
  800a15:	01 d8                	add    %ebx,%eax
  800a17:	50                   	push   %eax
  800a18:	e8 c5 ff ff ff       	call   8009e2 <strcpy>
	return dst;
}
  800a1d:	89 d8                	mov    %ebx,%eax
  800a1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2f:	89 f3                	mov    %esi,%ebx
  800a31:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a34:	89 f2                	mov    %esi,%edx
  800a36:	eb 0f                	jmp    800a47 <strncpy+0x23>
		*dst++ = *src;
  800a38:	83 c2 01             	add    $0x1,%edx
  800a3b:	0f b6 01             	movzbl (%ecx),%eax
  800a3e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a41:	80 39 01             	cmpb   $0x1,(%ecx)
  800a44:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a47:	39 da                	cmp    %ebx,%edx
  800a49:	75 ed                	jne    800a38 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a4b:	89 f0                	mov    %esi,%eax
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	56                   	push   %esi
  800a55:	53                   	push   %ebx
  800a56:	8b 75 08             	mov    0x8(%ebp),%esi
  800a59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5c:	8b 55 10             	mov    0x10(%ebp),%edx
  800a5f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a61:	85 d2                	test   %edx,%edx
  800a63:	74 21                	je     800a86 <strlcpy+0x35>
  800a65:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a69:	89 f2                	mov    %esi,%edx
  800a6b:	eb 09                	jmp    800a76 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a6d:	83 c2 01             	add    $0x1,%edx
  800a70:	83 c1 01             	add    $0x1,%ecx
  800a73:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a76:	39 c2                	cmp    %eax,%edx
  800a78:	74 09                	je     800a83 <strlcpy+0x32>
  800a7a:	0f b6 19             	movzbl (%ecx),%ebx
  800a7d:	84 db                	test   %bl,%bl
  800a7f:	75 ec                	jne    800a6d <strlcpy+0x1c>
  800a81:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a83:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a86:	29 f0                	sub    %esi,%eax
}
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a92:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a95:	eb 06                	jmp    800a9d <strcmp+0x11>
		p++, q++;
  800a97:	83 c1 01             	add    $0x1,%ecx
  800a9a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a9d:	0f b6 01             	movzbl (%ecx),%eax
  800aa0:	84 c0                	test   %al,%al
  800aa2:	74 04                	je     800aa8 <strcmp+0x1c>
  800aa4:	3a 02                	cmp    (%edx),%al
  800aa6:	74 ef                	je     800a97 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa8:	0f b6 c0             	movzbl %al,%eax
  800aab:	0f b6 12             	movzbl (%edx),%edx
  800aae:	29 d0                	sub    %edx,%eax
}
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	53                   	push   %ebx
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abc:	89 c3                	mov    %eax,%ebx
  800abe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ac1:	eb 06                	jmp    800ac9 <strncmp+0x17>
		n--, p++, q++;
  800ac3:	83 c0 01             	add    $0x1,%eax
  800ac6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ac9:	39 d8                	cmp    %ebx,%eax
  800acb:	74 15                	je     800ae2 <strncmp+0x30>
  800acd:	0f b6 08             	movzbl (%eax),%ecx
  800ad0:	84 c9                	test   %cl,%cl
  800ad2:	74 04                	je     800ad8 <strncmp+0x26>
  800ad4:	3a 0a                	cmp    (%edx),%cl
  800ad6:	74 eb                	je     800ac3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad8:	0f b6 00             	movzbl (%eax),%eax
  800adb:	0f b6 12             	movzbl (%edx),%edx
  800ade:	29 d0                	sub    %edx,%eax
  800ae0:	eb 05                	jmp    800ae7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af4:	eb 07                	jmp    800afd <strchr+0x13>
		if (*s == c)
  800af6:	38 ca                	cmp    %cl,%dl
  800af8:	74 0f                	je     800b09 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800afa:	83 c0 01             	add    $0x1,%eax
  800afd:	0f b6 10             	movzbl (%eax),%edx
  800b00:	84 d2                	test   %dl,%dl
  800b02:	75 f2                	jne    800af6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b15:	eb 03                	jmp    800b1a <strfind+0xf>
  800b17:	83 c0 01             	add    $0x1,%eax
  800b1a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b1d:	38 ca                	cmp    %cl,%dl
  800b1f:	74 04                	je     800b25 <strfind+0x1a>
  800b21:	84 d2                	test   %dl,%dl
  800b23:	75 f2                	jne    800b17 <strfind+0xc>
			break;
	return (char *) s;
}
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
  800b2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b33:	85 c9                	test   %ecx,%ecx
  800b35:	74 36                	je     800b6d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b37:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b3d:	75 28                	jne    800b67 <memset+0x40>
  800b3f:	f6 c1 03             	test   $0x3,%cl
  800b42:	75 23                	jne    800b67 <memset+0x40>
		c &= 0xFF;
  800b44:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b48:	89 d3                	mov    %edx,%ebx
  800b4a:	c1 e3 08             	shl    $0x8,%ebx
  800b4d:	89 d6                	mov    %edx,%esi
  800b4f:	c1 e6 18             	shl    $0x18,%esi
  800b52:	89 d0                	mov    %edx,%eax
  800b54:	c1 e0 10             	shl    $0x10,%eax
  800b57:	09 f0                	or     %esi,%eax
  800b59:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b5b:	89 d8                	mov    %ebx,%eax
  800b5d:	09 d0                	or     %edx,%eax
  800b5f:	c1 e9 02             	shr    $0x2,%ecx
  800b62:	fc                   	cld    
  800b63:	f3 ab                	rep stos %eax,%es:(%edi)
  800b65:	eb 06                	jmp    800b6d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6a:	fc                   	cld    
  800b6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b6d:	89 f8                	mov    %edi,%eax
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b82:	39 c6                	cmp    %eax,%esi
  800b84:	73 35                	jae    800bbb <memmove+0x47>
  800b86:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b89:	39 d0                	cmp    %edx,%eax
  800b8b:	73 2e                	jae    800bbb <memmove+0x47>
		s += n;
		d += n;
  800b8d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	09 fe                	or     %edi,%esi
  800b94:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b9a:	75 13                	jne    800baf <memmove+0x3b>
  800b9c:	f6 c1 03             	test   $0x3,%cl
  800b9f:	75 0e                	jne    800baf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ba1:	83 ef 04             	sub    $0x4,%edi
  800ba4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba7:	c1 e9 02             	shr    $0x2,%ecx
  800baa:	fd                   	std    
  800bab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bad:	eb 09                	jmp    800bb8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800baf:	83 ef 01             	sub    $0x1,%edi
  800bb2:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bb5:	fd                   	std    
  800bb6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb8:	fc                   	cld    
  800bb9:	eb 1d                	jmp    800bd8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bbb:	89 f2                	mov    %esi,%edx
  800bbd:	09 c2                	or     %eax,%edx
  800bbf:	f6 c2 03             	test   $0x3,%dl
  800bc2:	75 0f                	jne    800bd3 <memmove+0x5f>
  800bc4:	f6 c1 03             	test   $0x3,%cl
  800bc7:	75 0a                	jne    800bd3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bc9:	c1 e9 02             	shr    $0x2,%ecx
  800bcc:	89 c7                	mov    %eax,%edi
  800bce:	fc                   	cld    
  800bcf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd1:	eb 05                	jmp    800bd8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd3:	89 c7                	mov    %eax,%edi
  800bd5:	fc                   	cld    
  800bd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bdf:	ff 75 10             	pushl  0x10(%ebp)
  800be2:	ff 75 0c             	pushl  0xc(%ebp)
  800be5:	ff 75 08             	pushl  0x8(%ebp)
  800be8:	e8 87 ff ff ff       	call   800b74 <memmove>
}
  800bed:	c9                   	leave  
  800bee:	c3                   	ret    

00800bef <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bfa:	89 c6                	mov    %eax,%esi
  800bfc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bff:	eb 1a                	jmp    800c1b <memcmp+0x2c>
		if (*s1 != *s2)
  800c01:	0f b6 08             	movzbl (%eax),%ecx
  800c04:	0f b6 1a             	movzbl (%edx),%ebx
  800c07:	38 d9                	cmp    %bl,%cl
  800c09:	74 0a                	je     800c15 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c0b:	0f b6 c1             	movzbl %cl,%eax
  800c0e:	0f b6 db             	movzbl %bl,%ebx
  800c11:	29 d8                	sub    %ebx,%eax
  800c13:	eb 0f                	jmp    800c24 <memcmp+0x35>
		s1++, s2++;
  800c15:	83 c0 01             	add    $0x1,%eax
  800c18:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1b:	39 f0                	cmp    %esi,%eax
  800c1d:	75 e2                	jne    800c01 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	53                   	push   %ebx
  800c2c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c2f:	89 c1                	mov    %eax,%ecx
  800c31:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c34:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c38:	eb 0a                	jmp    800c44 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c3a:	0f b6 10             	movzbl (%eax),%edx
  800c3d:	39 da                	cmp    %ebx,%edx
  800c3f:	74 07                	je     800c48 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c41:	83 c0 01             	add    $0x1,%eax
  800c44:	39 c8                	cmp    %ecx,%eax
  800c46:	72 f2                	jb     800c3a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c48:	5b                   	pop    %ebx
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c57:	eb 03                	jmp    800c5c <strtol+0x11>
		s++;
  800c59:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c5c:	0f b6 01             	movzbl (%ecx),%eax
  800c5f:	3c 20                	cmp    $0x20,%al
  800c61:	74 f6                	je     800c59 <strtol+0xe>
  800c63:	3c 09                	cmp    $0x9,%al
  800c65:	74 f2                	je     800c59 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c67:	3c 2b                	cmp    $0x2b,%al
  800c69:	75 0a                	jne    800c75 <strtol+0x2a>
		s++;
  800c6b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c73:	eb 11                	jmp    800c86 <strtol+0x3b>
  800c75:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c7a:	3c 2d                	cmp    $0x2d,%al
  800c7c:	75 08                	jne    800c86 <strtol+0x3b>
		s++, neg = 1;
  800c7e:	83 c1 01             	add    $0x1,%ecx
  800c81:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c86:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c8c:	75 15                	jne    800ca3 <strtol+0x58>
  800c8e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c91:	75 10                	jne    800ca3 <strtol+0x58>
  800c93:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c97:	75 7c                	jne    800d15 <strtol+0xca>
		s += 2, base = 16;
  800c99:	83 c1 02             	add    $0x2,%ecx
  800c9c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ca1:	eb 16                	jmp    800cb9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ca3:	85 db                	test   %ebx,%ebx
  800ca5:	75 12                	jne    800cb9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ca7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cac:	80 39 30             	cmpb   $0x30,(%ecx)
  800caf:	75 08                	jne    800cb9 <strtol+0x6e>
		s++, base = 8;
  800cb1:	83 c1 01             	add    $0x1,%ecx
  800cb4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbe:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cc1:	0f b6 11             	movzbl (%ecx),%edx
  800cc4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cc7:	89 f3                	mov    %esi,%ebx
  800cc9:	80 fb 09             	cmp    $0x9,%bl
  800ccc:	77 08                	ja     800cd6 <strtol+0x8b>
			dig = *s - '0';
  800cce:	0f be d2             	movsbl %dl,%edx
  800cd1:	83 ea 30             	sub    $0x30,%edx
  800cd4:	eb 22                	jmp    800cf8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cd6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cd9:	89 f3                	mov    %esi,%ebx
  800cdb:	80 fb 19             	cmp    $0x19,%bl
  800cde:	77 08                	ja     800ce8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ce0:	0f be d2             	movsbl %dl,%edx
  800ce3:	83 ea 57             	sub    $0x57,%edx
  800ce6:	eb 10                	jmp    800cf8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ce8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ceb:	89 f3                	mov    %esi,%ebx
  800ced:	80 fb 19             	cmp    $0x19,%bl
  800cf0:	77 16                	ja     800d08 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cf2:	0f be d2             	movsbl %dl,%edx
  800cf5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cf8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cfb:	7d 0b                	jge    800d08 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cfd:	83 c1 01             	add    $0x1,%ecx
  800d00:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d04:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d06:	eb b9                	jmp    800cc1 <strtol+0x76>

	if (endptr)
  800d08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d0c:	74 0d                	je     800d1b <strtol+0xd0>
		*endptr = (char *) s;
  800d0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d11:	89 0e                	mov    %ecx,(%esi)
  800d13:	eb 06                	jmp    800d1b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d15:	85 db                	test   %ebx,%ebx
  800d17:	74 98                	je     800cb1 <strtol+0x66>
  800d19:	eb 9e                	jmp    800cb9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d1b:	89 c2                	mov    %eax,%edx
  800d1d:	f7 da                	neg    %edx
  800d1f:	85 ff                	test   %edi,%edi
  800d21:	0f 45 c2             	cmovne %edx,%eax
}
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	89 c3                	mov    %eax,%ebx
  800d3c:	89 c7                	mov    %eax,%edi
  800d3e:	89 c6                	mov    %eax,%esi
  800d40:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d52:	b8 01 00 00 00       	mov    $0x1,%eax
  800d57:	89 d1                	mov    %edx,%ecx
  800d59:	89 d3                	mov    %edx,%ebx
  800d5b:	89 d7                	mov    %edx,%edi
  800d5d:	89 d6                	mov    %edx,%esi
  800d5f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d74:	b8 03 00 00 00       	mov    $0x3,%eax
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 cb                	mov    %ecx,%ebx
  800d7e:	89 cf                	mov    %ecx,%edi
  800d80:	89 ce                	mov    %ecx,%esi
  800d82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d84:	85 c0                	test   %eax,%eax
  800d86:	7e 17                	jle    800d9f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	83 ec 0c             	sub    $0xc,%esp
  800d8b:	50                   	push   %eax
  800d8c:	6a 03                	push   $0x3
  800d8e:	68 1f 27 80 00       	push   $0x80271f
  800d93:	6a 23                	push   $0x23
  800d95:	68 3c 27 80 00       	push   $0x80273c
  800d9a:	e8 e5 f5 ff ff       	call   800384 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dad:	ba 00 00 00 00       	mov    $0x0,%edx
  800db2:	b8 02 00 00 00       	mov    $0x2,%eax
  800db7:	89 d1                	mov    %edx,%ecx
  800db9:	89 d3                	mov    %edx,%ebx
  800dbb:	89 d7                	mov    %edx,%edi
  800dbd:	89 d6                	mov    %edx,%esi
  800dbf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_yield>:

void
sys_yield(void)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dd6:	89 d1                	mov    %edx,%ecx
  800dd8:	89 d3                	mov    %edx,%ebx
  800dda:	89 d7                	mov    %edx,%edi
  800ddc:	89 d6                	mov    %edx,%esi
  800dde:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
  800deb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dee:	be 00 00 00 00       	mov    $0x0,%esi
  800df3:	b8 04 00 00 00       	mov    $0x4,%eax
  800df8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e01:	89 f7                	mov    %esi,%edi
  800e03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e05:	85 c0                	test   %eax,%eax
  800e07:	7e 17                	jle    800e20 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e09:	83 ec 0c             	sub    $0xc,%esp
  800e0c:	50                   	push   %eax
  800e0d:	6a 04                	push   $0x4
  800e0f:	68 1f 27 80 00       	push   $0x80271f
  800e14:	6a 23                	push   $0x23
  800e16:	68 3c 27 80 00       	push   $0x80273c
  800e1b:	e8 64 f5 ff ff       	call   800384 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	57                   	push   %edi
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e31:	b8 05 00 00 00       	mov    $0x5,%eax
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e42:	8b 75 18             	mov    0x18(%ebp),%esi
  800e45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7e 17                	jle    800e62 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	50                   	push   %eax
  800e4f:	6a 05                	push   $0x5
  800e51:	68 1f 27 80 00       	push   $0x80271f
  800e56:	6a 23                	push   $0x23
  800e58:	68 3c 27 80 00       	push   $0x80273c
  800e5d:	e8 22 f5 ff ff       	call   800384 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e78:	b8 06 00 00 00       	mov    $0x6,%eax
  800e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e80:	8b 55 08             	mov    0x8(%ebp),%edx
  800e83:	89 df                	mov    %ebx,%edi
  800e85:	89 de                	mov    %ebx,%esi
  800e87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	7e 17                	jle    800ea4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8d:	83 ec 0c             	sub    $0xc,%esp
  800e90:	50                   	push   %eax
  800e91:	6a 06                	push   $0x6
  800e93:	68 1f 27 80 00       	push   $0x80271f
  800e98:	6a 23                	push   $0x23
  800e9a:	68 3c 27 80 00       	push   $0x80273c
  800e9f:	e8 e0 f4 ff ff       	call   800384 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ea4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
  800eb2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eba:	b8 08 00 00 00       	mov    $0x8,%eax
  800ebf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec5:	89 df                	mov    %ebx,%edi
  800ec7:	89 de                	mov    %ebx,%esi
  800ec9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	7e 17                	jle    800ee6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecf:	83 ec 0c             	sub    $0xc,%esp
  800ed2:	50                   	push   %eax
  800ed3:	6a 08                	push   $0x8
  800ed5:	68 1f 27 80 00       	push   $0x80271f
  800eda:	6a 23                	push   $0x23
  800edc:	68 3c 27 80 00       	push   $0x80273c
  800ee1:	e8 9e f4 ff ff       	call   800384 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ee6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee9:	5b                   	pop    %ebx
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efc:	b8 09 00 00 00       	mov    $0x9,%eax
  800f01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f04:	8b 55 08             	mov    0x8(%ebp),%edx
  800f07:	89 df                	mov    %ebx,%edi
  800f09:	89 de                	mov    %ebx,%esi
  800f0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	7e 17                	jle    800f28 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f11:	83 ec 0c             	sub    $0xc,%esp
  800f14:	50                   	push   %eax
  800f15:	6a 09                	push   $0x9
  800f17:	68 1f 27 80 00       	push   $0x80271f
  800f1c:	6a 23                	push   $0x23
  800f1e:	68 3c 27 80 00       	push   $0x80273c
  800f23:	e8 5c f4 ff ff       	call   800384 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2b:	5b                   	pop    %ebx
  800f2c:	5e                   	pop    %esi
  800f2d:	5f                   	pop    %edi
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
  800f36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f46:	8b 55 08             	mov    0x8(%ebp),%edx
  800f49:	89 df                	mov    %ebx,%edi
  800f4b:	89 de                	mov    %ebx,%esi
  800f4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	7e 17                	jle    800f6a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f53:	83 ec 0c             	sub    $0xc,%esp
  800f56:	50                   	push   %eax
  800f57:	6a 0a                	push   $0xa
  800f59:	68 1f 27 80 00       	push   $0x80271f
  800f5e:	6a 23                	push   $0x23
  800f60:	68 3c 27 80 00       	push   $0x80273c
  800f65:	e8 1a f4 ff ff       	call   800384 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6d:	5b                   	pop    %ebx
  800f6e:	5e                   	pop    %esi
  800f6f:	5f                   	pop    %edi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	57                   	push   %edi
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f78:	be 00 00 00 00       	mov    $0x0,%esi
  800f7d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f85:	8b 55 08             	mov    0x8(%ebp),%edx
  800f88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f8e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	57                   	push   %edi
  800f99:	56                   	push   %esi
  800f9a:	53                   	push   %ebx
  800f9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fa8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fab:	89 cb                	mov    %ecx,%ebx
  800fad:	89 cf                	mov    %ecx,%edi
  800faf:	89 ce                	mov    %ecx,%esi
  800fb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	7e 17                	jle    800fce <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb7:	83 ec 0c             	sub    $0xc,%esp
  800fba:	50                   	push   %eax
  800fbb:	6a 0d                	push   $0xd
  800fbd:	68 1f 27 80 00       	push   $0x80271f
  800fc2:	6a 23                	push   $0x23
  800fc4:	68 3c 27 80 00       	push   $0x80273c
  800fc9:	e8 b6 f3 ff ff       	call   800384 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd1:	5b                   	pop    %ebx
  800fd2:	5e                   	pop    %esi
  800fd3:	5f                   	pop    %edi
  800fd4:	5d                   	pop    %ebp
  800fd5:	c3                   	ret    

00800fd6 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	57                   	push   %edi
  800fda:	56                   	push   %esi
  800fdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fe6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe9:	89 cb                	mov    %ecx,%ebx
  800feb:	89 cf                	mov    %ecx,%edi
  800fed:	89 ce                	mov    %ecx,%esi
  800fef:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fff:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801002:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801004:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801007:	83 3a 01             	cmpl   $0x1,(%edx)
  80100a:	7e 09                	jle    801015 <argstart+0x1f>
  80100c:	ba a8 23 80 00       	mov    $0x8023a8,%edx
  801011:	85 c9                	test   %ecx,%ecx
  801013:	75 05                	jne    80101a <argstart+0x24>
  801015:	ba 00 00 00 00       	mov    $0x0,%edx
  80101a:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  80101d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <argnext>:

int
argnext(struct Argstate *args)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	53                   	push   %ebx
  80102a:	83 ec 04             	sub    $0x4,%esp
  80102d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801030:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801037:	8b 43 08             	mov    0x8(%ebx),%eax
  80103a:	85 c0                	test   %eax,%eax
  80103c:	74 6f                	je     8010ad <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  80103e:	80 38 00             	cmpb   $0x0,(%eax)
  801041:	75 4e                	jne    801091 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801043:	8b 0b                	mov    (%ebx),%ecx
  801045:	83 39 01             	cmpl   $0x1,(%ecx)
  801048:	74 55                	je     80109f <argnext+0x79>
		    || args->argv[1][0] != '-'
  80104a:	8b 53 04             	mov    0x4(%ebx),%edx
  80104d:	8b 42 04             	mov    0x4(%edx),%eax
  801050:	80 38 2d             	cmpb   $0x2d,(%eax)
  801053:	75 4a                	jne    80109f <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801055:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801059:	74 44                	je     80109f <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  80105b:	83 c0 01             	add    $0x1,%eax
  80105e:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801061:	83 ec 04             	sub    $0x4,%esp
  801064:	8b 01                	mov    (%ecx),%eax
  801066:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80106d:	50                   	push   %eax
  80106e:	8d 42 08             	lea    0x8(%edx),%eax
  801071:	50                   	push   %eax
  801072:	83 c2 04             	add    $0x4,%edx
  801075:	52                   	push   %edx
  801076:	e8 f9 fa ff ff       	call   800b74 <memmove>
		(*args->argc)--;
  80107b:	8b 03                	mov    (%ebx),%eax
  80107d:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801080:	8b 43 08             	mov    0x8(%ebx),%eax
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	80 38 2d             	cmpb   $0x2d,(%eax)
  801089:	75 06                	jne    801091 <argnext+0x6b>
  80108b:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80108f:	74 0e                	je     80109f <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801091:	8b 53 08             	mov    0x8(%ebx),%edx
  801094:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801097:	83 c2 01             	add    $0x1,%edx
  80109a:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  80109d:	eb 13                	jmp    8010b2 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  80109f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8010a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8010ab:	eb 05                	jmp    8010b2 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  8010ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8010b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b5:	c9                   	leave  
  8010b6:	c3                   	ret    

008010b7 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	53                   	push   %ebx
  8010bb:	83 ec 04             	sub    $0x4,%esp
  8010be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8010c1:	8b 43 08             	mov    0x8(%ebx),%eax
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	74 58                	je     801120 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  8010c8:	80 38 00             	cmpb   $0x0,(%eax)
  8010cb:	74 0c                	je     8010d9 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8010cd:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8010d0:	c7 43 08 a8 23 80 00 	movl   $0x8023a8,0x8(%ebx)
  8010d7:	eb 42                	jmp    80111b <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  8010d9:	8b 13                	mov    (%ebx),%edx
  8010db:	83 3a 01             	cmpl   $0x1,(%edx)
  8010de:	7e 2d                	jle    80110d <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  8010e0:	8b 43 04             	mov    0x4(%ebx),%eax
  8010e3:	8b 48 04             	mov    0x4(%eax),%ecx
  8010e6:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8010e9:	83 ec 04             	sub    $0x4,%esp
  8010ec:	8b 12                	mov    (%edx),%edx
  8010ee:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  8010f5:	52                   	push   %edx
  8010f6:	8d 50 08             	lea    0x8(%eax),%edx
  8010f9:	52                   	push   %edx
  8010fa:	83 c0 04             	add    $0x4,%eax
  8010fd:	50                   	push   %eax
  8010fe:	e8 71 fa ff ff       	call   800b74 <memmove>
		(*args->argc)--;
  801103:	8b 03                	mov    (%ebx),%eax
  801105:	83 28 01             	subl   $0x1,(%eax)
  801108:	83 c4 10             	add    $0x10,%esp
  80110b:	eb 0e                	jmp    80111b <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  80110d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801114:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  80111b:	8b 43 0c             	mov    0xc(%ebx),%eax
  80111e:	eb 05                	jmp    801125 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801120:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801125:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801128:	c9                   	leave  
  801129:	c3                   	ret    

0080112a <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	83 ec 08             	sub    $0x8,%esp
  801130:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801133:	8b 51 0c             	mov    0xc(%ecx),%edx
  801136:	89 d0                	mov    %edx,%eax
  801138:	85 d2                	test   %edx,%edx
  80113a:	75 0c                	jne    801148 <argvalue+0x1e>
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	51                   	push   %ecx
  801140:	e8 72 ff ff ff       	call   8010b7 <argnextvalue>
  801145:	83 c4 10             	add    $0x10,%esp
}
  801148:	c9                   	leave  
  801149:	c3                   	ret    

0080114a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80114d:	8b 45 08             	mov    0x8(%ebp),%eax
  801150:	05 00 00 00 30       	add    $0x30000000,%eax
  801155:	c1 e8 0c             	shr    $0xc,%eax
}
  801158:	5d                   	pop    %ebp
  801159:	c3                   	ret    

0080115a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80115d:	8b 45 08             	mov    0x8(%ebp),%eax
  801160:	05 00 00 00 30       	add    $0x30000000,%eax
  801165:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80116a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801177:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80117c:	89 c2                	mov    %eax,%edx
  80117e:	c1 ea 16             	shr    $0x16,%edx
  801181:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801188:	f6 c2 01             	test   $0x1,%dl
  80118b:	74 11                	je     80119e <fd_alloc+0x2d>
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	c1 ea 0c             	shr    $0xc,%edx
  801192:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801199:	f6 c2 01             	test   $0x1,%dl
  80119c:	75 09                	jne    8011a7 <fd_alloc+0x36>
			*fd_store = fd;
  80119e:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a5:	eb 17                	jmp    8011be <fd_alloc+0x4d>
  8011a7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011ac:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011b1:	75 c9                	jne    80117c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011b3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011b9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011c6:	83 f8 1f             	cmp    $0x1f,%eax
  8011c9:	77 36                	ja     801201 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011cb:	c1 e0 0c             	shl    $0xc,%eax
  8011ce:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d3:	89 c2                	mov    %eax,%edx
  8011d5:	c1 ea 16             	shr    $0x16,%edx
  8011d8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011df:	f6 c2 01             	test   $0x1,%dl
  8011e2:	74 24                	je     801208 <fd_lookup+0x48>
  8011e4:	89 c2                	mov    %eax,%edx
  8011e6:	c1 ea 0c             	shr    $0xc,%edx
  8011e9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f0:	f6 c2 01             	test   $0x1,%dl
  8011f3:	74 1a                	je     80120f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f8:	89 02                	mov    %eax,(%edx)
	return 0;
  8011fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ff:	eb 13                	jmp    801214 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801201:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801206:	eb 0c                	jmp    801214 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801208:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120d:	eb 05                	jmp    801214 <fd_lookup+0x54>
  80120f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	83 ec 08             	sub    $0x8,%esp
  80121c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121f:	ba cc 27 80 00       	mov    $0x8027cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801224:	eb 13                	jmp    801239 <dev_lookup+0x23>
  801226:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801229:	39 08                	cmp    %ecx,(%eax)
  80122b:	75 0c                	jne    801239 <dev_lookup+0x23>
			*dev = devtab[i];
  80122d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801230:	89 01                	mov    %eax,(%ecx)
			return 0;
  801232:	b8 00 00 00 00       	mov    $0x0,%eax
  801237:	eb 2e                	jmp    801267 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801239:	8b 02                	mov    (%edx),%eax
  80123b:	85 c0                	test   %eax,%eax
  80123d:	75 e7                	jne    801226 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80123f:	a1 20 44 80 00       	mov    0x804420,%eax
  801244:	8b 40 50             	mov    0x50(%eax),%eax
  801247:	83 ec 04             	sub    $0x4,%esp
  80124a:	51                   	push   %ecx
  80124b:	50                   	push   %eax
  80124c:	68 4c 27 80 00       	push   $0x80274c
  801251:	e8 07 f2 ff ff       	call   80045d <cprintf>
	*dev = 0;
  801256:	8b 45 0c             	mov    0xc(%ebp),%eax
  801259:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801267:	c9                   	leave  
  801268:	c3                   	ret    

00801269 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	56                   	push   %esi
  80126d:	53                   	push   %ebx
  80126e:	83 ec 10             	sub    $0x10,%esp
  801271:	8b 75 08             	mov    0x8(%ebp),%esi
  801274:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801277:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127a:	50                   	push   %eax
  80127b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801281:	c1 e8 0c             	shr    $0xc,%eax
  801284:	50                   	push   %eax
  801285:	e8 36 ff ff ff       	call   8011c0 <fd_lookup>
  80128a:	83 c4 08             	add    $0x8,%esp
  80128d:	85 c0                	test   %eax,%eax
  80128f:	78 05                	js     801296 <fd_close+0x2d>
	    || fd != fd2)
  801291:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801294:	74 0c                	je     8012a2 <fd_close+0x39>
		return (must_exist ? r : 0);
  801296:	84 db                	test   %bl,%bl
  801298:	ba 00 00 00 00       	mov    $0x0,%edx
  80129d:	0f 44 c2             	cmove  %edx,%eax
  8012a0:	eb 41                	jmp    8012e3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a8:	50                   	push   %eax
  8012a9:	ff 36                	pushl  (%esi)
  8012ab:	e8 66 ff ff ff       	call   801216 <dev_lookup>
  8012b0:	89 c3                	mov    %eax,%ebx
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 1a                	js     8012d3 <fd_close+0x6a>
		if (dev->dev_close)
  8012b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012bf:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	74 0b                	je     8012d3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012c8:	83 ec 0c             	sub    $0xc,%esp
  8012cb:	56                   	push   %esi
  8012cc:	ff d0                	call   *%eax
  8012ce:	89 c3                	mov    %eax,%ebx
  8012d0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012d3:	83 ec 08             	sub    $0x8,%esp
  8012d6:	56                   	push   %esi
  8012d7:	6a 00                	push   $0x0
  8012d9:	e8 8c fb ff ff       	call   800e6a <sys_page_unmap>
	return r;
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	89 d8                	mov    %ebx,%eax
}
  8012e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e6:	5b                   	pop    %ebx
  8012e7:	5e                   	pop    %esi
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    

008012ea <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	ff 75 08             	pushl  0x8(%ebp)
  8012f7:	e8 c4 fe ff ff       	call   8011c0 <fd_lookup>
  8012fc:	83 c4 08             	add    $0x8,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 10                	js     801313 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	6a 01                	push   $0x1
  801308:	ff 75 f4             	pushl  -0xc(%ebp)
  80130b:	e8 59 ff ff ff       	call   801269 <fd_close>
  801310:	83 c4 10             	add    $0x10,%esp
}
  801313:	c9                   	leave  
  801314:	c3                   	ret    

00801315 <close_all>:

void
close_all(void)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	53                   	push   %ebx
  801319:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80131c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801321:	83 ec 0c             	sub    $0xc,%esp
  801324:	53                   	push   %ebx
  801325:	e8 c0 ff ff ff       	call   8012ea <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80132a:	83 c3 01             	add    $0x1,%ebx
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	83 fb 20             	cmp    $0x20,%ebx
  801333:	75 ec                	jne    801321 <close_all+0xc>
		close(i);
}
  801335:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801338:	c9                   	leave  
  801339:	c3                   	ret    

0080133a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	57                   	push   %edi
  80133e:	56                   	push   %esi
  80133f:	53                   	push   %ebx
  801340:	83 ec 2c             	sub    $0x2c,%esp
  801343:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801346:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801349:	50                   	push   %eax
  80134a:	ff 75 08             	pushl  0x8(%ebp)
  80134d:	e8 6e fe ff ff       	call   8011c0 <fd_lookup>
  801352:	83 c4 08             	add    $0x8,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	0f 88 c1 00 00 00    	js     80141e <dup+0xe4>
		return r;
	close(newfdnum);
  80135d:	83 ec 0c             	sub    $0xc,%esp
  801360:	56                   	push   %esi
  801361:	e8 84 ff ff ff       	call   8012ea <close>

	newfd = INDEX2FD(newfdnum);
  801366:	89 f3                	mov    %esi,%ebx
  801368:	c1 e3 0c             	shl    $0xc,%ebx
  80136b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801371:	83 c4 04             	add    $0x4,%esp
  801374:	ff 75 e4             	pushl  -0x1c(%ebp)
  801377:	e8 de fd ff ff       	call   80115a <fd2data>
  80137c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80137e:	89 1c 24             	mov    %ebx,(%esp)
  801381:	e8 d4 fd ff ff       	call   80115a <fd2data>
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80138c:	89 f8                	mov    %edi,%eax
  80138e:	c1 e8 16             	shr    $0x16,%eax
  801391:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801398:	a8 01                	test   $0x1,%al
  80139a:	74 37                	je     8013d3 <dup+0x99>
  80139c:	89 f8                	mov    %edi,%eax
  80139e:	c1 e8 0c             	shr    $0xc,%eax
  8013a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013a8:	f6 c2 01             	test   $0x1,%dl
  8013ab:	74 26                	je     8013d3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b4:	83 ec 0c             	sub    $0xc,%esp
  8013b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8013bc:	50                   	push   %eax
  8013bd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c0:	6a 00                	push   $0x0
  8013c2:	57                   	push   %edi
  8013c3:	6a 00                	push   $0x0
  8013c5:	e8 5e fa ff ff       	call   800e28 <sys_page_map>
  8013ca:	89 c7                	mov    %eax,%edi
  8013cc:	83 c4 20             	add    $0x20,%esp
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	78 2e                	js     801401 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013d6:	89 d0                	mov    %edx,%eax
  8013d8:	c1 e8 0c             	shr    $0xc,%eax
  8013db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e2:	83 ec 0c             	sub    $0xc,%esp
  8013e5:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ea:	50                   	push   %eax
  8013eb:	53                   	push   %ebx
  8013ec:	6a 00                	push   $0x0
  8013ee:	52                   	push   %edx
  8013ef:	6a 00                	push   $0x0
  8013f1:	e8 32 fa ff ff       	call   800e28 <sys_page_map>
  8013f6:	89 c7                	mov    %eax,%edi
  8013f8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013fb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013fd:	85 ff                	test   %edi,%edi
  8013ff:	79 1d                	jns    80141e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801401:	83 ec 08             	sub    $0x8,%esp
  801404:	53                   	push   %ebx
  801405:	6a 00                	push   $0x0
  801407:	e8 5e fa ff ff       	call   800e6a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80140c:	83 c4 08             	add    $0x8,%esp
  80140f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801412:	6a 00                	push   $0x0
  801414:	e8 51 fa ff ff       	call   800e6a <sys_page_unmap>
	return r;
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	89 f8                	mov    %edi,%eax
}
  80141e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5f                   	pop    %edi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    

00801426 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	53                   	push   %ebx
  80142a:	83 ec 14             	sub    $0x14,%esp
  80142d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801430:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801433:	50                   	push   %eax
  801434:	53                   	push   %ebx
  801435:	e8 86 fd ff ff       	call   8011c0 <fd_lookup>
  80143a:	83 c4 08             	add    $0x8,%esp
  80143d:	89 c2                	mov    %eax,%edx
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 6d                	js     8014b0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801449:	50                   	push   %eax
  80144a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144d:	ff 30                	pushl  (%eax)
  80144f:	e8 c2 fd ff ff       	call   801216 <dev_lookup>
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 4c                	js     8014a7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80145b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80145e:	8b 42 08             	mov    0x8(%edx),%eax
  801461:	83 e0 03             	and    $0x3,%eax
  801464:	83 f8 01             	cmp    $0x1,%eax
  801467:	75 21                	jne    80148a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801469:	a1 20 44 80 00       	mov    0x804420,%eax
  80146e:	8b 40 50             	mov    0x50(%eax),%eax
  801471:	83 ec 04             	sub    $0x4,%esp
  801474:	53                   	push   %ebx
  801475:	50                   	push   %eax
  801476:	68 90 27 80 00       	push   $0x802790
  80147b:	e8 dd ef ff ff       	call   80045d <cprintf>
		return -E_INVAL;
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801488:	eb 26                	jmp    8014b0 <read+0x8a>
	}
	if (!dev->dev_read)
  80148a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148d:	8b 40 08             	mov    0x8(%eax),%eax
  801490:	85 c0                	test   %eax,%eax
  801492:	74 17                	je     8014ab <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801494:	83 ec 04             	sub    $0x4,%esp
  801497:	ff 75 10             	pushl  0x10(%ebp)
  80149a:	ff 75 0c             	pushl  0xc(%ebp)
  80149d:	52                   	push   %edx
  80149e:	ff d0                	call   *%eax
  8014a0:	89 c2                	mov    %eax,%edx
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	eb 09                	jmp    8014b0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a7:	89 c2                	mov    %eax,%edx
  8014a9:	eb 05                	jmp    8014b0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014b0:	89 d0                	mov    %edx,%eax
  8014b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b5:	c9                   	leave  
  8014b6:	c3                   	ret    

008014b7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	57                   	push   %edi
  8014bb:	56                   	push   %esi
  8014bc:	53                   	push   %ebx
  8014bd:	83 ec 0c             	sub    $0xc,%esp
  8014c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014cb:	eb 21                	jmp    8014ee <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014cd:	83 ec 04             	sub    $0x4,%esp
  8014d0:	89 f0                	mov    %esi,%eax
  8014d2:	29 d8                	sub    %ebx,%eax
  8014d4:	50                   	push   %eax
  8014d5:	89 d8                	mov    %ebx,%eax
  8014d7:	03 45 0c             	add    0xc(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	57                   	push   %edi
  8014dc:	e8 45 ff ff ff       	call   801426 <read>
		if (m < 0)
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 10                	js     8014f8 <readn+0x41>
			return m;
		if (m == 0)
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	74 0a                	je     8014f6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ec:	01 c3                	add    %eax,%ebx
  8014ee:	39 f3                	cmp    %esi,%ebx
  8014f0:	72 db                	jb     8014cd <readn+0x16>
  8014f2:	89 d8                	mov    %ebx,%eax
  8014f4:	eb 02                	jmp    8014f8 <readn+0x41>
  8014f6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014fb:	5b                   	pop    %ebx
  8014fc:	5e                   	pop    %esi
  8014fd:	5f                   	pop    %edi
  8014fe:	5d                   	pop    %ebp
  8014ff:	c3                   	ret    

00801500 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	53                   	push   %ebx
  801504:	83 ec 14             	sub    $0x14,%esp
  801507:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	53                   	push   %ebx
  80150f:	e8 ac fc ff ff       	call   8011c0 <fd_lookup>
  801514:	83 c4 08             	add    $0x8,%esp
  801517:	89 c2                	mov    %eax,%edx
  801519:	85 c0                	test   %eax,%eax
  80151b:	78 68                	js     801585 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151d:	83 ec 08             	sub    $0x8,%esp
  801520:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801523:	50                   	push   %eax
  801524:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801527:	ff 30                	pushl  (%eax)
  801529:	e8 e8 fc ff ff       	call   801216 <dev_lookup>
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	85 c0                	test   %eax,%eax
  801533:	78 47                	js     80157c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801535:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801538:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153c:	75 21                	jne    80155f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80153e:	a1 20 44 80 00       	mov    0x804420,%eax
  801543:	8b 40 50             	mov    0x50(%eax),%eax
  801546:	83 ec 04             	sub    $0x4,%esp
  801549:	53                   	push   %ebx
  80154a:	50                   	push   %eax
  80154b:	68 ac 27 80 00       	push   $0x8027ac
  801550:	e8 08 ef ff ff       	call   80045d <cprintf>
		return -E_INVAL;
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80155d:	eb 26                	jmp    801585 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80155f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801562:	8b 52 0c             	mov    0xc(%edx),%edx
  801565:	85 d2                	test   %edx,%edx
  801567:	74 17                	je     801580 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801569:	83 ec 04             	sub    $0x4,%esp
  80156c:	ff 75 10             	pushl  0x10(%ebp)
  80156f:	ff 75 0c             	pushl  0xc(%ebp)
  801572:	50                   	push   %eax
  801573:	ff d2                	call   *%edx
  801575:	89 c2                	mov    %eax,%edx
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	eb 09                	jmp    801585 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157c:	89 c2                	mov    %eax,%edx
  80157e:	eb 05                	jmp    801585 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801580:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801585:	89 d0                	mov    %edx,%eax
  801587:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158a:	c9                   	leave  
  80158b:	c3                   	ret    

0080158c <seek>:

int
seek(int fdnum, off_t offset)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801592:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	ff 75 08             	pushl  0x8(%ebp)
  801599:	e8 22 fc ff ff       	call   8011c0 <fd_lookup>
  80159e:	83 c4 08             	add    $0x8,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 0e                	js     8015b3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ab:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b3:	c9                   	leave  
  8015b4:	c3                   	ret    

008015b5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	53                   	push   %ebx
  8015b9:	83 ec 14             	sub    $0x14,%esp
  8015bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c2:	50                   	push   %eax
  8015c3:	53                   	push   %ebx
  8015c4:	e8 f7 fb ff ff       	call   8011c0 <fd_lookup>
  8015c9:	83 c4 08             	add    $0x8,%esp
  8015cc:	89 c2                	mov    %eax,%edx
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 65                	js     801637 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d2:	83 ec 08             	sub    $0x8,%esp
  8015d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dc:	ff 30                	pushl  (%eax)
  8015de:	e8 33 fc ff ff       	call   801216 <dev_lookup>
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 44                	js     80162e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f1:	75 21                	jne    801614 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015f3:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015f8:	8b 40 50             	mov    0x50(%eax),%eax
  8015fb:	83 ec 04             	sub    $0x4,%esp
  8015fe:	53                   	push   %ebx
  8015ff:	50                   	push   %eax
  801600:	68 6c 27 80 00       	push   $0x80276c
  801605:	e8 53 ee ff ff       	call   80045d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801612:	eb 23                	jmp    801637 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801614:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801617:	8b 52 18             	mov    0x18(%edx),%edx
  80161a:	85 d2                	test   %edx,%edx
  80161c:	74 14                	je     801632 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	ff 75 0c             	pushl  0xc(%ebp)
  801624:	50                   	push   %eax
  801625:	ff d2                	call   *%edx
  801627:	89 c2                	mov    %eax,%edx
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	eb 09                	jmp    801637 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162e:	89 c2                	mov    %eax,%edx
  801630:	eb 05                	jmp    801637 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801632:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801637:	89 d0                	mov    %edx,%eax
  801639:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	53                   	push   %ebx
  801642:	83 ec 14             	sub    $0x14,%esp
  801645:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801648:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164b:	50                   	push   %eax
  80164c:	ff 75 08             	pushl  0x8(%ebp)
  80164f:	e8 6c fb ff ff       	call   8011c0 <fd_lookup>
  801654:	83 c4 08             	add    $0x8,%esp
  801657:	89 c2                	mov    %eax,%edx
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 58                	js     8016b5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165d:	83 ec 08             	sub    $0x8,%esp
  801660:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801663:	50                   	push   %eax
  801664:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801667:	ff 30                	pushl  (%eax)
  801669:	e8 a8 fb ff ff       	call   801216 <dev_lookup>
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	85 c0                	test   %eax,%eax
  801673:	78 37                	js     8016ac <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801675:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801678:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80167c:	74 32                	je     8016b0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80167e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801681:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801688:	00 00 00 
	stat->st_isdir = 0;
  80168b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801692:	00 00 00 
	stat->st_dev = dev;
  801695:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80169b:	83 ec 08             	sub    $0x8,%esp
  80169e:	53                   	push   %ebx
  80169f:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a2:	ff 50 14             	call   *0x14(%eax)
  8016a5:	89 c2                	mov    %eax,%edx
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	eb 09                	jmp    8016b5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ac:	89 c2                	mov    %eax,%edx
  8016ae:	eb 05                	jmp    8016b5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016b5:	89 d0                	mov    %edx,%eax
  8016b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	56                   	push   %esi
  8016c0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c1:	83 ec 08             	sub    $0x8,%esp
  8016c4:	6a 00                	push   $0x0
  8016c6:	ff 75 08             	pushl  0x8(%ebp)
  8016c9:	e8 e3 01 00 00       	call   8018b1 <open>
  8016ce:	89 c3                	mov    %eax,%ebx
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	78 1b                	js     8016f2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016d7:	83 ec 08             	sub    $0x8,%esp
  8016da:	ff 75 0c             	pushl  0xc(%ebp)
  8016dd:	50                   	push   %eax
  8016de:	e8 5b ff ff ff       	call   80163e <fstat>
  8016e3:	89 c6                	mov    %eax,%esi
	close(fd);
  8016e5:	89 1c 24             	mov    %ebx,(%esp)
  8016e8:	e8 fd fb ff ff       	call   8012ea <close>
	return r;
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	89 f0                	mov    %esi,%eax
}
  8016f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    

008016f9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	56                   	push   %esi
  8016fd:	53                   	push   %ebx
  8016fe:	89 c6                	mov    %eax,%esi
  801700:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801702:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801709:	75 12                	jne    80171d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80170b:	83 ec 0c             	sub    $0xc,%esp
  80170e:	6a 01                	push   $0x1
  801710:	e8 06 09 00 00       	call   80201b <ipc_find_env>
  801715:	a3 00 40 80 00       	mov    %eax,0x804000
  80171a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80171d:	6a 07                	push   $0x7
  80171f:	68 00 50 80 00       	push   $0x805000
  801724:	56                   	push   %esi
  801725:	ff 35 00 40 80 00    	pushl  0x804000
  80172b:	e8 89 08 00 00       	call   801fb9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801730:	83 c4 0c             	add    $0xc,%esp
  801733:	6a 00                	push   $0x0
  801735:	53                   	push   %ebx
  801736:	6a 00                	push   $0x0
  801738:	e8 07 08 00 00       	call   801f44 <ipc_recv>
}
  80173d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801740:	5b                   	pop    %ebx
  801741:	5e                   	pop    %esi
  801742:	5d                   	pop    %ebp
  801743:	c3                   	ret    

00801744 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80174a:	8b 45 08             	mov    0x8(%ebp),%eax
  80174d:	8b 40 0c             	mov    0xc(%eax),%eax
  801750:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801755:	8b 45 0c             	mov    0xc(%ebp),%eax
  801758:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80175d:	ba 00 00 00 00       	mov    $0x0,%edx
  801762:	b8 02 00 00 00       	mov    $0x2,%eax
  801767:	e8 8d ff ff ff       	call   8016f9 <fsipc>
}
  80176c:	c9                   	leave  
  80176d:	c3                   	ret    

0080176e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801774:	8b 45 08             	mov    0x8(%ebp),%eax
  801777:	8b 40 0c             	mov    0xc(%eax),%eax
  80177a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80177f:	ba 00 00 00 00       	mov    $0x0,%edx
  801784:	b8 06 00 00 00       	mov    $0x6,%eax
  801789:	e8 6b ff ff ff       	call   8016f9 <fsipc>
}
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	53                   	push   %ebx
  801794:	83 ec 04             	sub    $0x4,%esp
  801797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80179a:	8b 45 08             	mov    0x8(%ebp),%eax
  80179d:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8017af:	e8 45 ff ff ff       	call   8016f9 <fsipc>
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 2c                	js     8017e4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017b8:	83 ec 08             	sub    $0x8,%esp
  8017bb:	68 00 50 80 00       	push   $0x805000
  8017c0:	53                   	push   %ebx
  8017c1:	e8 1c f2 ff ff       	call   8009e2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017c6:	a1 80 50 80 00       	mov    0x805080,%eax
  8017cb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017d1:	a1 84 50 80 00       	mov    0x805084,%eax
  8017d6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    

008017e9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	83 ec 0c             	sub    $0xc,%esp
  8017ef:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f5:	8b 52 0c             	mov    0xc(%edx),%edx
  8017f8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8017fe:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801803:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801808:	0f 47 c2             	cmova  %edx,%eax
  80180b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801810:	50                   	push   %eax
  801811:	ff 75 0c             	pushl  0xc(%ebp)
  801814:	68 08 50 80 00       	push   $0x805008
  801819:	e8 56 f3 ff ff       	call   800b74 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80181e:	ba 00 00 00 00       	mov    $0x0,%edx
  801823:	b8 04 00 00 00       	mov    $0x4,%eax
  801828:	e8 cc fe ff ff       	call   8016f9 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80182d:	c9                   	leave  
  80182e:	c3                   	ret    

0080182f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	56                   	push   %esi
  801833:	53                   	push   %ebx
  801834:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801837:	8b 45 08             	mov    0x8(%ebp),%eax
  80183a:	8b 40 0c             	mov    0xc(%eax),%eax
  80183d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801842:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801848:	ba 00 00 00 00       	mov    $0x0,%edx
  80184d:	b8 03 00 00 00       	mov    $0x3,%eax
  801852:	e8 a2 fe ff ff       	call   8016f9 <fsipc>
  801857:	89 c3                	mov    %eax,%ebx
  801859:	85 c0                	test   %eax,%eax
  80185b:	78 4b                	js     8018a8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80185d:	39 c6                	cmp    %eax,%esi
  80185f:	73 16                	jae    801877 <devfile_read+0x48>
  801861:	68 dc 27 80 00       	push   $0x8027dc
  801866:	68 e3 27 80 00       	push   $0x8027e3
  80186b:	6a 7c                	push   $0x7c
  80186d:	68 f8 27 80 00       	push   $0x8027f8
  801872:	e8 0d eb ff ff       	call   800384 <_panic>
	assert(r <= PGSIZE);
  801877:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80187c:	7e 16                	jle    801894 <devfile_read+0x65>
  80187e:	68 03 28 80 00       	push   $0x802803
  801883:	68 e3 27 80 00       	push   $0x8027e3
  801888:	6a 7d                	push   $0x7d
  80188a:	68 f8 27 80 00       	push   $0x8027f8
  80188f:	e8 f0 ea ff ff       	call   800384 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801894:	83 ec 04             	sub    $0x4,%esp
  801897:	50                   	push   %eax
  801898:	68 00 50 80 00       	push   $0x805000
  80189d:	ff 75 0c             	pushl  0xc(%ebp)
  8018a0:	e8 cf f2 ff ff       	call   800b74 <memmove>
	return r;
  8018a5:	83 c4 10             	add    $0x10,%esp
}
  8018a8:	89 d8                	mov    %ebx,%eax
  8018aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ad:	5b                   	pop    %ebx
  8018ae:	5e                   	pop    %esi
  8018af:	5d                   	pop    %ebp
  8018b0:	c3                   	ret    

008018b1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	53                   	push   %ebx
  8018b5:	83 ec 20             	sub    $0x20,%esp
  8018b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018bb:	53                   	push   %ebx
  8018bc:	e8 e8 f0 ff ff       	call   8009a9 <strlen>
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018c9:	7f 67                	jg     801932 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018cb:	83 ec 0c             	sub    $0xc,%esp
  8018ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d1:	50                   	push   %eax
  8018d2:	e8 9a f8 ff ff       	call   801171 <fd_alloc>
  8018d7:	83 c4 10             	add    $0x10,%esp
		return r;
  8018da:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 57                	js     801937 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018e0:	83 ec 08             	sub    $0x8,%esp
  8018e3:	53                   	push   %ebx
  8018e4:	68 00 50 80 00       	push   $0x805000
  8018e9:	e8 f4 f0 ff ff       	call   8009e2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8018fe:	e8 f6 fd ff ff       	call   8016f9 <fsipc>
  801903:	89 c3                	mov    %eax,%ebx
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	85 c0                	test   %eax,%eax
  80190a:	79 14                	jns    801920 <open+0x6f>
		fd_close(fd, 0);
  80190c:	83 ec 08             	sub    $0x8,%esp
  80190f:	6a 00                	push   $0x0
  801911:	ff 75 f4             	pushl  -0xc(%ebp)
  801914:	e8 50 f9 ff ff       	call   801269 <fd_close>
		return r;
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	89 da                	mov    %ebx,%edx
  80191e:	eb 17                	jmp    801937 <open+0x86>
	}

	return fd2num(fd);
  801920:	83 ec 0c             	sub    $0xc,%esp
  801923:	ff 75 f4             	pushl  -0xc(%ebp)
  801926:	e8 1f f8 ff ff       	call   80114a <fd2num>
  80192b:	89 c2                	mov    %eax,%edx
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	eb 05                	jmp    801937 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801932:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801937:	89 d0                	mov    %edx,%eax
  801939:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801944:	ba 00 00 00 00       	mov    $0x0,%edx
  801949:	b8 08 00 00 00       	mov    $0x8,%eax
  80194e:	e8 a6 fd ff ff       	call   8016f9 <fsipc>
}
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801955:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801959:	7e 37                	jle    801992 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	53                   	push   %ebx
  80195f:	83 ec 08             	sub    $0x8,%esp
  801962:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801964:	ff 70 04             	pushl  0x4(%eax)
  801967:	8d 40 10             	lea    0x10(%eax),%eax
  80196a:	50                   	push   %eax
  80196b:	ff 33                	pushl  (%ebx)
  80196d:	e8 8e fb ff ff       	call   801500 <write>
		if (result > 0)
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	85 c0                	test   %eax,%eax
  801977:	7e 03                	jle    80197c <writebuf+0x27>
			b->result += result;
  801979:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80197c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80197f:	74 0d                	je     80198e <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801981:	85 c0                	test   %eax,%eax
  801983:	ba 00 00 00 00       	mov    $0x0,%edx
  801988:	0f 4f c2             	cmovg  %edx,%eax
  80198b:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80198e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801991:	c9                   	leave  
  801992:	f3 c3                	repz ret 

00801994 <putch>:

static void
putch(int ch, void *thunk)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	53                   	push   %ebx
  801998:	83 ec 04             	sub    $0x4,%esp
  80199b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80199e:	8b 53 04             	mov    0x4(%ebx),%edx
  8019a1:	8d 42 01             	lea    0x1(%edx),%eax
  8019a4:	89 43 04             	mov    %eax,0x4(%ebx)
  8019a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019aa:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8019ae:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019b3:	75 0e                	jne    8019c3 <putch+0x2f>
		writebuf(b);
  8019b5:	89 d8                	mov    %ebx,%eax
  8019b7:	e8 99 ff ff ff       	call   801955 <writebuf>
		b->idx = 0;
  8019bc:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8019c3:	83 c4 04             	add    $0x4,%esp
  8019c6:	5b                   	pop    %ebx
  8019c7:	5d                   	pop    %ebp
  8019c8:	c3                   	ret    

008019c9 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8019d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d5:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019db:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019e2:	00 00 00 
	b.result = 0;
  8019e5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019ec:	00 00 00 
	b.error = 1;
  8019ef:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019f6:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019f9:	ff 75 10             	pushl  0x10(%ebp)
  8019fc:	ff 75 0c             	pushl  0xc(%ebp)
  8019ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a05:	50                   	push   %eax
  801a06:	68 94 19 80 00       	push   $0x801994
  801a0b:	e8 84 eb ff ff       	call   800594 <vprintfmt>
	if (b.idx > 0)
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a1a:	7e 0b                	jle    801a27 <vfprintf+0x5e>
		writebuf(&b);
  801a1c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a22:	e8 2e ff ff ff       	call   801955 <writebuf>

	return (b.result ? b.result : b.error);
  801a27:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a3e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a41:	50                   	push   %eax
  801a42:	ff 75 0c             	pushl  0xc(%ebp)
  801a45:	ff 75 08             	pushl  0x8(%ebp)
  801a48:	e8 7c ff ff ff       	call   8019c9 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a4d:	c9                   	leave  
  801a4e:	c3                   	ret    

00801a4f <printf>:

int
printf(const char *fmt, ...)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a55:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a58:	50                   	push   %eax
  801a59:	ff 75 08             	pushl  0x8(%ebp)
  801a5c:	6a 01                	push   $0x1
  801a5e:	e8 66 ff ff ff       	call   8019c9 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a63:	c9                   	leave  
  801a64:	c3                   	ret    

00801a65 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	56                   	push   %esi
  801a69:	53                   	push   %ebx
  801a6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a6d:	83 ec 0c             	sub    $0xc,%esp
  801a70:	ff 75 08             	pushl  0x8(%ebp)
  801a73:	e8 e2 f6 ff ff       	call   80115a <fd2data>
  801a78:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a7a:	83 c4 08             	add    $0x8,%esp
  801a7d:	68 0f 28 80 00       	push   $0x80280f
  801a82:	53                   	push   %ebx
  801a83:	e8 5a ef ff ff       	call   8009e2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a88:	8b 46 04             	mov    0x4(%esi),%eax
  801a8b:	2b 06                	sub    (%esi),%eax
  801a8d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a93:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a9a:	00 00 00 
	stat->st_dev = &devpipe;
  801a9d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801aa4:	30 80 00 
	return 0;
}
  801aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  801aac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aaf:	5b                   	pop    %ebx
  801ab0:	5e                   	pop    %esi
  801ab1:	5d                   	pop    %ebp
  801ab2:	c3                   	ret    

00801ab3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	53                   	push   %ebx
  801ab7:	83 ec 0c             	sub    $0xc,%esp
  801aba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801abd:	53                   	push   %ebx
  801abe:	6a 00                	push   $0x0
  801ac0:	e8 a5 f3 ff ff       	call   800e6a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ac5:	89 1c 24             	mov    %ebx,(%esp)
  801ac8:	e8 8d f6 ff ff       	call   80115a <fd2data>
  801acd:	83 c4 08             	add    $0x8,%esp
  801ad0:	50                   	push   %eax
  801ad1:	6a 00                	push   $0x0
  801ad3:	e8 92 f3 ff ff       	call   800e6a <sys_page_unmap>
}
  801ad8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801adb:	c9                   	leave  
  801adc:	c3                   	ret    

00801add <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	57                   	push   %edi
  801ae1:	56                   	push   %esi
  801ae2:	53                   	push   %ebx
  801ae3:	83 ec 1c             	sub    $0x1c,%esp
  801ae6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ae9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aeb:	a1 20 44 80 00       	mov    0x804420,%eax
  801af0:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801af3:	83 ec 0c             	sub    $0xc,%esp
  801af6:	ff 75 e0             	pushl  -0x20(%ebp)
  801af9:	e8 5d 05 00 00       	call   80205b <pageref>
  801afe:	89 c3                	mov    %eax,%ebx
  801b00:	89 3c 24             	mov    %edi,(%esp)
  801b03:	e8 53 05 00 00       	call   80205b <pageref>
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	39 c3                	cmp    %eax,%ebx
  801b0d:	0f 94 c1             	sete   %cl
  801b10:	0f b6 c9             	movzbl %cl,%ecx
  801b13:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b16:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801b1c:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801b1f:	39 ce                	cmp    %ecx,%esi
  801b21:	74 1b                	je     801b3e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b23:	39 c3                	cmp    %eax,%ebx
  801b25:	75 c4                	jne    801aeb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b27:	8b 42 60             	mov    0x60(%edx),%eax
  801b2a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b2d:	50                   	push   %eax
  801b2e:	56                   	push   %esi
  801b2f:	68 16 28 80 00       	push   $0x802816
  801b34:	e8 24 e9 ff ff       	call   80045d <cprintf>
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	eb ad                	jmp    801aeb <_pipeisclosed+0xe>
	}
}
  801b3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b44:	5b                   	pop    %ebx
  801b45:	5e                   	pop    %esi
  801b46:	5f                   	pop    %edi
  801b47:	5d                   	pop    %ebp
  801b48:	c3                   	ret    

00801b49 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	57                   	push   %edi
  801b4d:	56                   	push   %esi
  801b4e:	53                   	push   %ebx
  801b4f:	83 ec 28             	sub    $0x28,%esp
  801b52:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b55:	56                   	push   %esi
  801b56:	e8 ff f5 ff ff       	call   80115a <fd2data>
  801b5b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	bf 00 00 00 00       	mov    $0x0,%edi
  801b65:	eb 4b                	jmp    801bb2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b67:	89 da                	mov    %ebx,%edx
  801b69:	89 f0                	mov    %esi,%eax
  801b6b:	e8 6d ff ff ff       	call   801add <_pipeisclosed>
  801b70:	85 c0                	test   %eax,%eax
  801b72:	75 48                	jne    801bbc <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b74:	e8 4d f2 ff ff       	call   800dc6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b79:	8b 43 04             	mov    0x4(%ebx),%eax
  801b7c:	8b 0b                	mov    (%ebx),%ecx
  801b7e:	8d 51 20             	lea    0x20(%ecx),%edx
  801b81:	39 d0                	cmp    %edx,%eax
  801b83:	73 e2                	jae    801b67 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b88:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b8c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b8f:	89 c2                	mov    %eax,%edx
  801b91:	c1 fa 1f             	sar    $0x1f,%edx
  801b94:	89 d1                	mov    %edx,%ecx
  801b96:	c1 e9 1b             	shr    $0x1b,%ecx
  801b99:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b9c:	83 e2 1f             	and    $0x1f,%edx
  801b9f:	29 ca                	sub    %ecx,%edx
  801ba1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ba5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ba9:	83 c0 01             	add    $0x1,%eax
  801bac:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801baf:	83 c7 01             	add    $0x1,%edi
  801bb2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bb5:	75 c2                	jne    801b79 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bb7:	8b 45 10             	mov    0x10(%ebp),%eax
  801bba:	eb 05                	jmp    801bc1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bbc:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc4:	5b                   	pop    %ebx
  801bc5:	5e                   	pop    %esi
  801bc6:	5f                   	pop    %edi
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    

00801bc9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	57                   	push   %edi
  801bcd:	56                   	push   %esi
  801bce:	53                   	push   %ebx
  801bcf:	83 ec 18             	sub    $0x18,%esp
  801bd2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bd5:	57                   	push   %edi
  801bd6:	e8 7f f5 ff ff       	call   80115a <fd2data>
  801bdb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801be5:	eb 3d                	jmp    801c24 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801be7:	85 db                	test   %ebx,%ebx
  801be9:	74 04                	je     801bef <devpipe_read+0x26>
				return i;
  801beb:	89 d8                	mov    %ebx,%eax
  801bed:	eb 44                	jmp    801c33 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bef:	89 f2                	mov    %esi,%edx
  801bf1:	89 f8                	mov    %edi,%eax
  801bf3:	e8 e5 fe ff ff       	call   801add <_pipeisclosed>
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	75 32                	jne    801c2e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bfc:	e8 c5 f1 ff ff       	call   800dc6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c01:	8b 06                	mov    (%esi),%eax
  801c03:	3b 46 04             	cmp    0x4(%esi),%eax
  801c06:	74 df                	je     801be7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c08:	99                   	cltd   
  801c09:	c1 ea 1b             	shr    $0x1b,%edx
  801c0c:	01 d0                	add    %edx,%eax
  801c0e:	83 e0 1f             	and    $0x1f,%eax
  801c11:	29 d0                	sub    %edx,%eax
  801c13:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c1b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c1e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c21:	83 c3 01             	add    $0x1,%ebx
  801c24:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c27:	75 d8                	jne    801c01 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c29:	8b 45 10             	mov    0x10(%ebp),%eax
  801c2c:	eb 05                	jmp    801c33 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c2e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c36:	5b                   	pop    %ebx
  801c37:	5e                   	pop    %esi
  801c38:	5f                   	pop    %edi
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	56                   	push   %esi
  801c3f:	53                   	push   %ebx
  801c40:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c46:	50                   	push   %eax
  801c47:	e8 25 f5 ff ff       	call   801171 <fd_alloc>
  801c4c:	83 c4 10             	add    $0x10,%esp
  801c4f:	89 c2                	mov    %eax,%edx
  801c51:	85 c0                	test   %eax,%eax
  801c53:	0f 88 2c 01 00 00    	js     801d85 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c59:	83 ec 04             	sub    $0x4,%esp
  801c5c:	68 07 04 00 00       	push   $0x407
  801c61:	ff 75 f4             	pushl  -0xc(%ebp)
  801c64:	6a 00                	push   $0x0
  801c66:	e8 7a f1 ff ff       	call   800de5 <sys_page_alloc>
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	89 c2                	mov    %eax,%edx
  801c70:	85 c0                	test   %eax,%eax
  801c72:	0f 88 0d 01 00 00    	js     801d85 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c78:	83 ec 0c             	sub    $0xc,%esp
  801c7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c7e:	50                   	push   %eax
  801c7f:	e8 ed f4 ff ff       	call   801171 <fd_alloc>
  801c84:	89 c3                	mov    %eax,%ebx
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	0f 88 e2 00 00 00    	js     801d73 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c91:	83 ec 04             	sub    $0x4,%esp
  801c94:	68 07 04 00 00       	push   $0x407
  801c99:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9c:	6a 00                	push   $0x0
  801c9e:	e8 42 f1 ff ff       	call   800de5 <sys_page_alloc>
  801ca3:	89 c3                	mov    %eax,%ebx
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	0f 88 c3 00 00 00    	js     801d73 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cb0:	83 ec 0c             	sub    $0xc,%esp
  801cb3:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb6:	e8 9f f4 ff ff       	call   80115a <fd2data>
  801cbb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbd:	83 c4 0c             	add    $0xc,%esp
  801cc0:	68 07 04 00 00       	push   $0x407
  801cc5:	50                   	push   %eax
  801cc6:	6a 00                	push   $0x0
  801cc8:	e8 18 f1 ff ff       	call   800de5 <sys_page_alloc>
  801ccd:	89 c3                	mov    %eax,%ebx
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	0f 88 89 00 00 00    	js     801d63 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cda:	83 ec 0c             	sub    $0xc,%esp
  801cdd:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce0:	e8 75 f4 ff ff       	call   80115a <fd2data>
  801ce5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cec:	50                   	push   %eax
  801ced:	6a 00                	push   $0x0
  801cef:	56                   	push   %esi
  801cf0:	6a 00                	push   $0x0
  801cf2:	e8 31 f1 ff ff       	call   800e28 <sys_page_map>
  801cf7:	89 c3                	mov    %eax,%ebx
  801cf9:	83 c4 20             	add    $0x20,%esp
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	78 55                	js     801d55 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d00:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d09:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d15:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d1e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d23:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d2a:	83 ec 0c             	sub    $0xc,%esp
  801d2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d30:	e8 15 f4 ff ff       	call   80114a <fd2num>
  801d35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d38:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d3a:	83 c4 04             	add    $0x4,%esp
  801d3d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d40:	e8 05 f4 ff ff       	call   80114a <fd2num>
  801d45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d48:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d53:	eb 30                	jmp    801d85 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d55:	83 ec 08             	sub    $0x8,%esp
  801d58:	56                   	push   %esi
  801d59:	6a 00                	push   $0x0
  801d5b:	e8 0a f1 ff ff       	call   800e6a <sys_page_unmap>
  801d60:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d63:	83 ec 08             	sub    $0x8,%esp
  801d66:	ff 75 f0             	pushl  -0x10(%ebp)
  801d69:	6a 00                	push   $0x0
  801d6b:	e8 fa f0 ff ff       	call   800e6a <sys_page_unmap>
  801d70:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d73:	83 ec 08             	sub    $0x8,%esp
  801d76:	ff 75 f4             	pushl  -0xc(%ebp)
  801d79:	6a 00                	push   $0x0
  801d7b:	e8 ea f0 ff ff       	call   800e6a <sys_page_unmap>
  801d80:	83 c4 10             	add    $0x10,%esp
  801d83:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d85:	89 d0                	mov    %edx,%eax
  801d87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d8a:	5b                   	pop    %ebx
  801d8b:	5e                   	pop    %esi
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    

00801d8e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d97:	50                   	push   %eax
  801d98:	ff 75 08             	pushl  0x8(%ebp)
  801d9b:	e8 20 f4 ff ff       	call   8011c0 <fd_lookup>
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	85 c0                	test   %eax,%eax
  801da5:	78 18                	js     801dbf <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801da7:	83 ec 0c             	sub    $0xc,%esp
  801daa:	ff 75 f4             	pushl  -0xc(%ebp)
  801dad:	e8 a8 f3 ff ff       	call   80115a <fd2data>
	return _pipeisclosed(fd, p);
  801db2:	89 c2                	mov    %eax,%edx
  801db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db7:	e8 21 fd ff ff       	call   801add <_pipeisclosed>
  801dbc:	83 c4 10             	add    $0x10,%esp
}
  801dbf:	c9                   	leave  
  801dc0:	c3                   	ret    

00801dc1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc9:	5d                   	pop    %ebp
  801dca:	c3                   	ret    

00801dcb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dd1:	68 2e 28 80 00       	push   $0x80282e
  801dd6:	ff 75 0c             	pushl  0xc(%ebp)
  801dd9:	e8 04 ec ff ff       	call   8009e2 <strcpy>
	return 0;
}
  801dde:	b8 00 00 00 00       	mov    $0x0,%eax
  801de3:	c9                   	leave  
  801de4:	c3                   	ret    

00801de5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	57                   	push   %edi
  801de9:	56                   	push   %esi
  801dea:	53                   	push   %ebx
  801deb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801df6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dfc:	eb 2d                	jmp    801e2b <devcons_write+0x46>
		m = n - tot;
  801dfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e01:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e03:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e06:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e0b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e0e:	83 ec 04             	sub    $0x4,%esp
  801e11:	53                   	push   %ebx
  801e12:	03 45 0c             	add    0xc(%ebp),%eax
  801e15:	50                   	push   %eax
  801e16:	57                   	push   %edi
  801e17:	e8 58 ed ff ff       	call   800b74 <memmove>
		sys_cputs(buf, m);
  801e1c:	83 c4 08             	add    $0x8,%esp
  801e1f:	53                   	push   %ebx
  801e20:	57                   	push   %edi
  801e21:	e8 03 ef ff ff       	call   800d29 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e26:	01 de                	add    %ebx,%esi
  801e28:	83 c4 10             	add    $0x10,%esp
  801e2b:	89 f0                	mov    %esi,%eax
  801e2d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e30:	72 cc                	jb     801dfe <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e35:	5b                   	pop    %ebx
  801e36:	5e                   	pop    %esi
  801e37:	5f                   	pop    %edi
  801e38:	5d                   	pop    %ebp
  801e39:	c3                   	ret    

00801e3a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	83 ec 08             	sub    $0x8,%esp
  801e40:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e45:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e49:	74 2a                	je     801e75 <devcons_read+0x3b>
  801e4b:	eb 05                	jmp    801e52 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e4d:	e8 74 ef ff ff       	call   800dc6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e52:	e8 f0 ee ff ff       	call   800d47 <sys_cgetc>
  801e57:	85 c0                	test   %eax,%eax
  801e59:	74 f2                	je     801e4d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	78 16                	js     801e75 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e5f:	83 f8 04             	cmp    $0x4,%eax
  801e62:	74 0c                	je     801e70 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e64:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e67:	88 02                	mov    %al,(%edx)
	return 1;
  801e69:	b8 01 00 00 00       	mov    $0x1,%eax
  801e6e:	eb 05                	jmp    801e75 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e70:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e75:	c9                   	leave  
  801e76:	c3                   	ret    

00801e77 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e80:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e83:	6a 01                	push   $0x1
  801e85:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e88:	50                   	push   %eax
  801e89:	e8 9b ee ff ff       	call   800d29 <sys_cputs>
}
  801e8e:	83 c4 10             	add    $0x10,%esp
  801e91:	c9                   	leave  
  801e92:	c3                   	ret    

00801e93 <getchar>:

int
getchar(void)
{
  801e93:	55                   	push   %ebp
  801e94:	89 e5                	mov    %esp,%ebp
  801e96:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e99:	6a 01                	push   $0x1
  801e9b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e9e:	50                   	push   %eax
  801e9f:	6a 00                	push   $0x0
  801ea1:	e8 80 f5 ff ff       	call   801426 <read>
	if (r < 0)
  801ea6:	83 c4 10             	add    $0x10,%esp
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	78 0f                	js     801ebc <getchar+0x29>
		return r;
	if (r < 1)
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	7e 06                	jle    801eb7 <getchar+0x24>
		return -E_EOF;
	return c;
  801eb1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801eb5:	eb 05                	jmp    801ebc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801eb7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ebc:	c9                   	leave  
  801ebd:	c3                   	ret    

00801ebe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec7:	50                   	push   %eax
  801ec8:	ff 75 08             	pushl  0x8(%ebp)
  801ecb:	e8 f0 f2 ff ff       	call   8011c0 <fd_lookup>
  801ed0:	83 c4 10             	add    $0x10,%esp
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	78 11                	js     801ee8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eda:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee0:	39 10                	cmp    %edx,(%eax)
  801ee2:	0f 94 c0             	sete   %al
  801ee5:	0f b6 c0             	movzbl %al,%eax
}
  801ee8:	c9                   	leave  
  801ee9:	c3                   	ret    

00801eea <opencons>:

int
opencons(void)
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ef0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef3:	50                   	push   %eax
  801ef4:	e8 78 f2 ff ff       	call   801171 <fd_alloc>
  801ef9:	83 c4 10             	add    $0x10,%esp
		return r;
  801efc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801efe:	85 c0                	test   %eax,%eax
  801f00:	78 3e                	js     801f40 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f02:	83 ec 04             	sub    $0x4,%esp
  801f05:	68 07 04 00 00       	push   $0x407
  801f0a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f0d:	6a 00                	push   $0x0
  801f0f:	e8 d1 ee ff ff       	call   800de5 <sys_page_alloc>
  801f14:	83 c4 10             	add    $0x10,%esp
		return r;
  801f17:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f19:	85 c0                	test   %eax,%eax
  801f1b:	78 23                	js     801f40 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f1d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f26:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f32:	83 ec 0c             	sub    $0xc,%esp
  801f35:	50                   	push   %eax
  801f36:	e8 0f f2 ff ff       	call   80114a <fd2num>
  801f3b:	89 c2                	mov    %eax,%edx
  801f3d:	83 c4 10             	add    $0x10,%esp
}
  801f40:	89 d0                	mov    %edx,%eax
  801f42:	c9                   	leave  
  801f43:	c3                   	ret    

00801f44 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	56                   	push   %esi
  801f48:	53                   	push   %ebx
  801f49:	8b 75 08             	mov    0x8(%ebp),%esi
  801f4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801f52:	85 c0                	test   %eax,%eax
  801f54:	75 12                	jne    801f68 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801f56:	83 ec 0c             	sub    $0xc,%esp
  801f59:	68 00 00 c0 ee       	push   $0xeec00000
  801f5e:	e8 32 f0 ff ff       	call   800f95 <sys_ipc_recv>
  801f63:	83 c4 10             	add    $0x10,%esp
  801f66:	eb 0c                	jmp    801f74 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801f68:	83 ec 0c             	sub    $0xc,%esp
  801f6b:	50                   	push   %eax
  801f6c:	e8 24 f0 ff ff       	call   800f95 <sys_ipc_recv>
  801f71:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801f74:	85 f6                	test   %esi,%esi
  801f76:	0f 95 c1             	setne  %cl
  801f79:	85 db                	test   %ebx,%ebx
  801f7b:	0f 95 c2             	setne  %dl
  801f7e:	84 d1                	test   %dl,%cl
  801f80:	74 09                	je     801f8b <ipc_recv+0x47>
  801f82:	89 c2                	mov    %eax,%edx
  801f84:	c1 ea 1f             	shr    $0x1f,%edx
  801f87:	84 d2                	test   %dl,%dl
  801f89:	75 27                	jne    801fb2 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801f8b:	85 f6                	test   %esi,%esi
  801f8d:	74 0a                	je     801f99 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801f8f:	a1 20 44 80 00       	mov    0x804420,%eax
  801f94:	8b 40 7c             	mov    0x7c(%eax),%eax
  801f97:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801f99:	85 db                	test   %ebx,%ebx
  801f9b:	74 0d                	je     801faa <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801f9d:	a1 20 44 80 00       	mov    0x804420,%eax
  801fa2:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801fa8:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801faa:	a1 20 44 80 00       	mov    0x804420,%eax
  801faf:	8b 40 78             	mov    0x78(%eax),%eax
}
  801fb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb5:	5b                   	pop    %ebx
  801fb6:	5e                   	pop    %esi
  801fb7:	5d                   	pop    %ebp
  801fb8:	c3                   	ret    

00801fb9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb9:	55                   	push   %ebp
  801fba:	89 e5                	mov    %esp,%ebp
  801fbc:	57                   	push   %edi
  801fbd:	56                   	push   %esi
  801fbe:	53                   	push   %ebx
  801fbf:	83 ec 0c             	sub    $0xc,%esp
  801fc2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801fcb:	85 db                	test   %ebx,%ebx
  801fcd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fd2:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801fd5:	ff 75 14             	pushl  0x14(%ebp)
  801fd8:	53                   	push   %ebx
  801fd9:	56                   	push   %esi
  801fda:	57                   	push   %edi
  801fdb:	e8 92 ef ff ff       	call   800f72 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801fe0:	89 c2                	mov    %eax,%edx
  801fe2:	c1 ea 1f             	shr    $0x1f,%edx
  801fe5:	83 c4 10             	add    $0x10,%esp
  801fe8:	84 d2                	test   %dl,%dl
  801fea:	74 17                	je     802003 <ipc_send+0x4a>
  801fec:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fef:	74 12                	je     802003 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ff1:	50                   	push   %eax
  801ff2:	68 3a 28 80 00       	push   $0x80283a
  801ff7:	6a 47                	push   $0x47
  801ff9:	68 48 28 80 00       	push   $0x802848
  801ffe:	e8 81 e3 ff ff       	call   800384 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802003:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802006:	75 07                	jne    80200f <ipc_send+0x56>
			sys_yield();
  802008:	e8 b9 ed ff ff       	call   800dc6 <sys_yield>
  80200d:	eb c6                	jmp    801fd5 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80200f:	85 c0                	test   %eax,%eax
  802011:	75 c2                	jne    801fd5 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802013:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802016:	5b                   	pop    %ebx
  802017:	5e                   	pop    %esi
  802018:	5f                   	pop    %edi
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    

0080201b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80201b:	55                   	push   %ebp
  80201c:	89 e5                	mov    %esp,%ebp
  80201e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802021:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802026:	89 c2                	mov    %eax,%edx
  802028:	c1 e2 07             	shl    $0x7,%edx
  80202b:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  802032:	8b 52 58             	mov    0x58(%edx),%edx
  802035:	39 ca                	cmp    %ecx,%edx
  802037:	75 11                	jne    80204a <ipc_find_env+0x2f>
			return envs[i].env_id;
  802039:	89 c2                	mov    %eax,%edx
  80203b:	c1 e2 07             	shl    $0x7,%edx
  80203e:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  802045:	8b 40 50             	mov    0x50(%eax),%eax
  802048:	eb 0f                	jmp    802059 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80204a:	83 c0 01             	add    $0x1,%eax
  80204d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802052:	75 d2                	jne    802026 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802054:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802059:	5d                   	pop    %ebp
  80205a:	c3                   	ret    

0080205b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80205b:	55                   	push   %ebp
  80205c:	89 e5                	mov    %esp,%ebp
  80205e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802061:	89 d0                	mov    %edx,%eax
  802063:	c1 e8 16             	shr    $0x16,%eax
  802066:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80206d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802072:	f6 c1 01             	test   $0x1,%cl
  802075:	74 1d                	je     802094 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802077:	c1 ea 0c             	shr    $0xc,%edx
  80207a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802081:	f6 c2 01             	test   $0x1,%dl
  802084:	74 0e                	je     802094 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802086:	c1 ea 0c             	shr    $0xc,%edx
  802089:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802090:	ef 
  802091:	0f b7 c0             	movzwl %ax,%eax
}
  802094:	5d                   	pop    %ebp
  802095:	c3                   	ret    
  802096:	66 90                	xchg   %ax,%ax
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__udivdi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 f6                	test   %esi,%esi
  8020b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020bd:	89 ca                	mov    %ecx,%edx
  8020bf:	89 f8                	mov    %edi,%eax
  8020c1:	75 3d                	jne    802100 <__udivdi3+0x60>
  8020c3:	39 cf                	cmp    %ecx,%edi
  8020c5:	0f 87 c5 00 00 00    	ja     802190 <__udivdi3+0xf0>
  8020cb:	85 ff                	test   %edi,%edi
  8020cd:	89 fd                	mov    %edi,%ebp
  8020cf:	75 0b                	jne    8020dc <__udivdi3+0x3c>
  8020d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d6:	31 d2                	xor    %edx,%edx
  8020d8:	f7 f7                	div    %edi
  8020da:	89 c5                	mov    %eax,%ebp
  8020dc:	89 c8                	mov    %ecx,%eax
  8020de:	31 d2                	xor    %edx,%edx
  8020e0:	f7 f5                	div    %ebp
  8020e2:	89 c1                	mov    %eax,%ecx
  8020e4:	89 d8                	mov    %ebx,%eax
  8020e6:	89 cf                	mov    %ecx,%edi
  8020e8:	f7 f5                	div    %ebp
  8020ea:	89 c3                	mov    %eax,%ebx
  8020ec:	89 d8                	mov    %ebx,%eax
  8020ee:	89 fa                	mov    %edi,%edx
  8020f0:	83 c4 1c             	add    $0x1c,%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    
  8020f8:	90                   	nop
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	39 ce                	cmp    %ecx,%esi
  802102:	77 74                	ja     802178 <__udivdi3+0xd8>
  802104:	0f bd fe             	bsr    %esi,%edi
  802107:	83 f7 1f             	xor    $0x1f,%edi
  80210a:	0f 84 98 00 00 00    	je     8021a8 <__udivdi3+0x108>
  802110:	bb 20 00 00 00       	mov    $0x20,%ebx
  802115:	89 f9                	mov    %edi,%ecx
  802117:	89 c5                	mov    %eax,%ebp
  802119:	29 fb                	sub    %edi,%ebx
  80211b:	d3 e6                	shl    %cl,%esi
  80211d:	89 d9                	mov    %ebx,%ecx
  80211f:	d3 ed                	shr    %cl,%ebp
  802121:	89 f9                	mov    %edi,%ecx
  802123:	d3 e0                	shl    %cl,%eax
  802125:	09 ee                	or     %ebp,%esi
  802127:	89 d9                	mov    %ebx,%ecx
  802129:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80212d:	89 d5                	mov    %edx,%ebp
  80212f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802133:	d3 ed                	shr    %cl,%ebp
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e2                	shl    %cl,%edx
  802139:	89 d9                	mov    %ebx,%ecx
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	09 c2                	or     %eax,%edx
  80213f:	89 d0                	mov    %edx,%eax
  802141:	89 ea                	mov    %ebp,%edx
  802143:	f7 f6                	div    %esi
  802145:	89 d5                	mov    %edx,%ebp
  802147:	89 c3                	mov    %eax,%ebx
  802149:	f7 64 24 0c          	mull   0xc(%esp)
  80214d:	39 d5                	cmp    %edx,%ebp
  80214f:	72 10                	jb     802161 <__udivdi3+0xc1>
  802151:	8b 74 24 08          	mov    0x8(%esp),%esi
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e6                	shl    %cl,%esi
  802159:	39 c6                	cmp    %eax,%esi
  80215b:	73 07                	jae    802164 <__udivdi3+0xc4>
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	75 03                	jne    802164 <__udivdi3+0xc4>
  802161:	83 eb 01             	sub    $0x1,%ebx
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 d8                	mov    %ebx,%eax
  802168:	89 fa                	mov    %edi,%edx
  80216a:	83 c4 1c             	add    $0x1c,%esp
  80216d:	5b                   	pop    %ebx
  80216e:	5e                   	pop    %esi
  80216f:	5f                   	pop    %edi
  802170:	5d                   	pop    %ebp
  802171:	c3                   	ret    
  802172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802178:	31 ff                	xor    %edi,%edi
  80217a:	31 db                	xor    %ebx,%ebx
  80217c:	89 d8                	mov    %ebx,%eax
  80217e:	89 fa                	mov    %edi,%edx
  802180:	83 c4 1c             	add    $0x1c,%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5f                   	pop    %edi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    
  802188:	90                   	nop
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	89 d8                	mov    %ebx,%eax
  802192:	f7 f7                	div    %edi
  802194:	31 ff                	xor    %edi,%edi
  802196:	89 c3                	mov    %eax,%ebx
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	89 fa                	mov    %edi,%edx
  80219c:	83 c4 1c             	add    $0x1c,%esp
  80219f:	5b                   	pop    %ebx
  8021a0:	5e                   	pop    %esi
  8021a1:	5f                   	pop    %edi
  8021a2:	5d                   	pop    %ebp
  8021a3:	c3                   	ret    
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	39 ce                	cmp    %ecx,%esi
  8021aa:	72 0c                	jb     8021b8 <__udivdi3+0x118>
  8021ac:	31 db                	xor    %ebx,%ebx
  8021ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021b2:	0f 87 34 ff ff ff    	ja     8020ec <__udivdi3+0x4c>
  8021b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021bd:	e9 2a ff ff ff       	jmp    8020ec <__udivdi3+0x4c>
  8021c2:	66 90                	xchg   %ax,%ax
  8021c4:	66 90                	xchg   %ax,%ax
  8021c6:	66 90                	xchg   %ax,%ax
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <__umoddi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e7:	85 d2                	test   %edx,%edx
  8021e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021f1:	89 f3                	mov    %esi,%ebx
  8021f3:	89 3c 24             	mov    %edi,(%esp)
  8021f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021fa:	75 1c                	jne    802218 <__umoddi3+0x48>
  8021fc:	39 f7                	cmp    %esi,%edi
  8021fe:	76 50                	jbe    802250 <__umoddi3+0x80>
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	f7 f7                	div    %edi
  802206:	89 d0                	mov    %edx,%eax
  802208:	31 d2                	xor    %edx,%edx
  80220a:	83 c4 1c             	add    $0x1c,%esp
  80220d:	5b                   	pop    %ebx
  80220e:	5e                   	pop    %esi
  80220f:	5f                   	pop    %edi
  802210:	5d                   	pop    %ebp
  802211:	c3                   	ret    
  802212:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802218:	39 f2                	cmp    %esi,%edx
  80221a:	89 d0                	mov    %edx,%eax
  80221c:	77 52                	ja     802270 <__umoddi3+0xa0>
  80221e:	0f bd ea             	bsr    %edx,%ebp
  802221:	83 f5 1f             	xor    $0x1f,%ebp
  802224:	75 5a                	jne    802280 <__umoddi3+0xb0>
  802226:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80222a:	0f 82 e0 00 00 00    	jb     802310 <__umoddi3+0x140>
  802230:	39 0c 24             	cmp    %ecx,(%esp)
  802233:	0f 86 d7 00 00 00    	jbe    802310 <__umoddi3+0x140>
  802239:	8b 44 24 08          	mov    0x8(%esp),%eax
  80223d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802241:	83 c4 1c             	add    $0x1c,%esp
  802244:	5b                   	pop    %ebx
  802245:	5e                   	pop    %esi
  802246:	5f                   	pop    %edi
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	85 ff                	test   %edi,%edi
  802252:	89 fd                	mov    %edi,%ebp
  802254:	75 0b                	jne    802261 <__umoddi3+0x91>
  802256:	b8 01 00 00 00       	mov    $0x1,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	f7 f7                	div    %edi
  80225f:	89 c5                	mov    %eax,%ebp
  802261:	89 f0                	mov    %esi,%eax
  802263:	31 d2                	xor    %edx,%edx
  802265:	f7 f5                	div    %ebp
  802267:	89 c8                	mov    %ecx,%eax
  802269:	f7 f5                	div    %ebp
  80226b:	89 d0                	mov    %edx,%eax
  80226d:	eb 99                	jmp    802208 <__umoddi3+0x38>
  80226f:	90                   	nop
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 f2                	mov    %esi,%edx
  802274:	83 c4 1c             	add    $0x1c,%esp
  802277:	5b                   	pop    %ebx
  802278:	5e                   	pop    %esi
  802279:	5f                   	pop    %edi
  80227a:	5d                   	pop    %ebp
  80227b:	c3                   	ret    
  80227c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802280:	8b 34 24             	mov    (%esp),%esi
  802283:	bf 20 00 00 00       	mov    $0x20,%edi
  802288:	89 e9                	mov    %ebp,%ecx
  80228a:	29 ef                	sub    %ebp,%edi
  80228c:	d3 e0                	shl    %cl,%eax
  80228e:	89 f9                	mov    %edi,%ecx
  802290:	89 f2                	mov    %esi,%edx
  802292:	d3 ea                	shr    %cl,%edx
  802294:	89 e9                	mov    %ebp,%ecx
  802296:	09 c2                	or     %eax,%edx
  802298:	89 d8                	mov    %ebx,%eax
  80229a:	89 14 24             	mov    %edx,(%esp)
  80229d:	89 f2                	mov    %esi,%edx
  80229f:	d3 e2                	shl    %cl,%edx
  8022a1:	89 f9                	mov    %edi,%ecx
  8022a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022ab:	d3 e8                	shr    %cl,%eax
  8022ad:	89 e9                	mov    %ebp,%ecx
  8022af:	89 c6                	mov    %eax,%esi
  8022b1:	d3 e3                	shl    %cl,%ebx
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 d0                	mov    %edx,%eax
  8022b7:	d3 e8                	shr    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	09 d8                	or     %ebx,%eax
  8022bd:	89 d3                	mov    %edx,%ebx
  8022bf:	89 f2                	mov    %esi,%edx
  8022c1:	f7 34 24             	divl   (%esp)
  8022c4:	89 d6                	mov    %edx,%esi
  8022c6:	d3 e3                	shl    %cl,%ebx
  8022c8:	f7 64 24 04          	mull   0x4(%esp)
  8022cc:	39 d6                	cmp    %edx,%esi
  8022ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022d2:	89 d1                	mov    %edx,%ecx
  8022d4:	89 c3                	mov    %eax,%ebx
  8022d6:	72 08                	jb     8022e0 <__umoddi3+0x110>
  8022d8:	75 11                	jne    8022eb <__umoddi3+0x11b>
  8022da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022de:	73 0b                	jae    8022eb <__umoddi3+0x11b>
  8022e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022e4:	1b 14 24             	sbb    (%esp),%edx
  8022e7:	89 d1                	mov    %edx,%ecx
  8022e9:	89 c3                	mov    %eax,%ebx
  8022eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ef:	29 da                	sub    %ebx,%edx
  8022f1:	19 ce                	sbb    %ecx,%esi
  8022f3:	89 f9                	mov    %edi,%ecx
  8022f5:	89 f0                	mov    %esi,%eax
  8022f7:	d3 e0                	shl    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	d3 ea                	shr    %cl,%edx
  8022fd:	89 e9                	mov    %ebp,%ecx
  8022ff:	d3 ee                	shr    %cl,%esi
  802301:	09 d0                	or     %edx,%eax
  802303:	89 f2                	mov    %esi,%edx
  802305:	83 c4 1c             	add    $0x1c,%esp
  802308:	5b                   	pop    %ebx
  802309:	5e                   	pop    %esi
  80230a:	5f                   	pop    %edi
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    
  80230d:	8d 76 00             	lea    0x0(%esi),%esi
  802310:	29 f9                	sub    %edi,%ecx
  802312:	19 d6                	sbb    %edx,%esi
  802314:	89 74 24 04          	mov    %esi,0x4(%esp)
  802318:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80231c:	e9 18 ff ff ff       	jmp    802239 <__umoddi3+0x69>
