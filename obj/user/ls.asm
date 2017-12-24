
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
  80005a:	68 02 23 80 00       	push   $0x802302
  80005f:	e8 b3 19 00 00       	call   801a17 <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 68 23 80 00       	mov    $0x802368,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1e                	je     800093 <ls1+0x60>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 13 09 00 00       	call   800991 <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
		else
			sep = "";
  800081:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800086:	ba 68 23 80 00       	mov    $0x802368,%edx
  80008b:	b8 00 23 80 00       	mov    $0x802300,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 0b 23 80 00       	push   $0x80230b
  80009d:	e8 75 19 00 00       	call   801a17 <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 95 27 80 00       	push   $0x802795
  8000b0:	e8 62 19 00 00       	call   801a17 <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 00 23 80 00       	push   $0x802300
  8000cf:	e8 43 19 00 00       	call   801a17 <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 67 23 80 00       	push   $0x802367
  8000df:	e8 33 19 00 00       	call   801a17 <printf>
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
  800100:	e8 74 17 00 00       	call   801879 <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 10 23 80 00       	push   $0x802310
  800118:	6a 1d                	push   $0x1d
  80011a:	68 1c 23 80 00       	push   $0x80231c
  80011f:	e8 48 02 00 00       	call   80036c <_panic>
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
  80015f:	e8 1b 13 00 00       	call   80147f <readn>
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
  800173:	68 26 23 80 00       	push   $0x802326
  800178:	6a 22                	push   $0x22
  80017a:	68 1c 23 80 00       	push   $0x80231c
  80017f:	e8 e8 01 00 00       	call   80036c <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 6c 23 80 00       	push   $0x80236c
  800192:	6a 24                	push   $0x24
  800194:	68 1c 23 80 00       	push   $0x80231c
  800199:	e8 ce 01 00 00       	call   80036c <_panic>
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
  8001bb:	e8 c4 14 00 00       	call   801684 <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 41 23 80 00       	push   $0x802341
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 1c 23 80 00       	push   $0x80231c
  8001d8:	e8 8f 01 00 00       	call   80036c <_panic>
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
  800220:	68 4d 23 80 00       	push   $0x80234d
  800225:	e8 ed 17 00 00       	call   801a17 <printf>
	exit();
  80022a:	e8 23 01 00 00       	call   800352 <exit>
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
  800248:	e8 71 0d 00 00       	call   800fbe <argstart>
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
  800277:	e8 72 0d 00 00       	call   800fee <argnext>
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
  800291:	68 68 23 80 00       	push   $0x802368
  800296:	68 00 23 80 00       	push   $0x802300
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
  8002d7:	e8 b3 0a 00 00       	call   800d8f <sys_getenvid>
  8002dc:	8b 3d 20 44 80 00    	mov    0x804420,%edi
  8002e2:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8002e7:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8002ec:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8002f1:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8002f4:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8002fa:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8002fd:	39 c8                	cmp    %ecx,%eax
  8002ff:	0f 44 fb             	cmove  %ebx,%edi
  800302:	b9 01 00 00 00       	mov    $0x1,%ecx
  800307:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  80030a:	83 c2 01             	add    $0x1,%edx
  80030d:	83 c3 7c             	add    $0x7c,%ebx
  800310:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800316:	75 d9                	jne    8002f1 <libmain+0x2d>
  800318:	89 f0                	mov    %esi,%eax
  80031a:	84 c0                	test   %al,%al
  80031c:	74 06                	je     800324 <libmain+0x60>
  80031e:	89 3d 20 44 80 00    	mov    %edi,0x804420
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800324:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800328:	7e 0a                	jle    800334 <libmain+0x70>
		binaryname = argv[0];
  80032a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032d:	8b 00                	mov    (%eax),%eax
  80032f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800334:	83 ec 08             	sub    $0x8,%esp
  800337:	ff 75 0c             	pushl  0xc(%ebp)
  80033a:	ff 75 08             	pushl  0x8(%ebp)
  80033d:	e8 f2 fe ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  800342:	e8 0b 00 00 00       	call   800352 <exit>
}
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034d:	5b                   	pop    %ebx
  80034e:	5e                   	pop    %esi
  80034f:	5f                   	pop    %edi
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800358:	e8 80 0f 00 00       	call   8012dd <close_all>
	sys_env_destroy(0);
  80035d:	83 ec 0c             	sub    $0xc,%esp
  800360:	6a 00                	push   $0x0
  800362:	e8 e7 09 00 00       	call   800d4e <sys_env_destroy>
}
  800367:	83 c4 10             	add    $0x10,%esp
  80036a:	c9                   	leave  
  80036b:	c3                   	ret    

0080036c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	56                   	push   %esi
  800370:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800371:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800374:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80037a:	e8 10 0a 00 00       	call   800d8f <sys_getenvid>
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	ff 75 0c             	pushl  0xc(%ebp)
  800385:	ff 75 08             	pushl  0x8(%ebp)
  800388:	56                   	push   %esi
  800389:	50                   	push   %eax
  80038a:	68 98 23 80 00       	push   $0x802398
  80038f:	e8 b1 00 00 00       	call   800445 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800394:	83 c4 18             	add    $0x18,%esp
  800397:	53                   	push   %ebx
  800398:	ff 75 10             	pushl  0x10(%ebp)
  80039b:	e8 54 00 00 00       	call   8003f4 <vcprintf>
	cprintf("\n");
  8003a0:	c7 04 24 67 23 80 00 	movl   $0x802367,(%esp)
  8003a7:	e8 99 00 00 00       	call   800445 <cprintf>
  8003ac:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003af:	cc                   	int3   
  8003b0:	eb fd                	jmp    8003af <_panic+0x43>

008003b2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	53                   	push   %ebx
  8003b6:	83 ec 04             	sub    $0x4,%esp
  8003b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003bc:	8b 13                	mov    (%ebx),%edx
  8003be:	8d 42 01             	lea    0x1(%edx),%eax
  8003c1:	89 03                	mov    %eax,(%ebx)
  8003c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003cf:	75 1a                	jne    8003eb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003d1:	83 ec 08             	sub    $0x8,%esp
  8003d4:	68 ff 00 00 00       	push   $0xff
  8003d9:	8d 43 08             	lea    0x8(%ebx),%eax
  8003dc:	50                   	push   %eax
  8003dd:	e8 2f 09 00 00       	call   800d11 <sys_cputs>
		b->idx = 0;
  8003e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003e8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003eb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003f2:	c9                   	leave  
  8003f3:	c3                   	ret    

008003f4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003fd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800404:	00 00 00 
	b.cnt = 0;
  800407:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80040e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800411:	ff 75 0c             	pushl  0xc(%ebp)
  800414:	ff 75 08             	pushl  0x8(%ebp)
  800417:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80041d:	50                   	push   %eax
  80041e:	68 b2 03 80 00       	push   $0x8003b2
  800423:	e8 54 01 00 00       	call   80057c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800428:	83 c4 08             	add    $0x8,%esp
  80042b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800431:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800437:	50                   	push   %eax
  800438:	e8 d4 08 00 00       	call   800d11 <sys_cputs>

	return b.cnt;
}
  80043d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800443:	c9                   	leave  
  800444:	c3                   	ret    

00800445 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80044b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80044e:	50                   	push   %eax
  80044f:	ff 75 08             	pushl  0x8(%ebp)
  800452:	e8 9d ff ff ff       	call   8003f4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800457:	c9                   	leave  
  800458:	c3                   	ret    

00800459 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800459:	55                   	push   %ebp
  80045a:	89 e5                	mov    %esp,%ebp
  80045c:	57                   	push   %edi
  80045d:	56                   	push   %esi
  80045e:	53                   	push   %ebx
  80045f:	83 ec 1c             	sub    $0x1c,%esp
  800462:	89 c7                	mov    %eax,%edi
  800464:	89 d6                	mov    %edx,%esi
  800466:	8b 45 08             	mov    0x8(%ebp),%eax
  800469:	8b 55 0c             	mov    0xc(%ebp),%edx
  80046c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80046f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800472:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800475:	bb 00 00 00 00       	mov    $0x0,%ebx
  80047a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80047d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800480:	39 d3                	cmp    %edx,%ebx
  800482:	72 05                	jb     800489 <printnum+0x30>
  800484:	39 45 10             	cmp    %eax,0x10(%ebp)
  800487:	77 45                	ja     8004ce <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800489:	83 ec 0c             	sub    $0xc,%esp
  80048c:	ff 75 18             	pushl  0x18(%ebp)
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800495:	53                   	push   %ebx
  800496:	ff 75 10             	pushl  0x10(%ebp)
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049f:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a8:	e8 b3 1b 00 00       	call   802060 <__udivdi3>
  8004ad:	83 c4 18             	add    $0x18,%esp
  8004b0:	52                   	push   %edx
  8004b1:	50                   	push   %eax
  8004b2:	89 f2                	mov    %esi,%edx
  8004b4:	89 f8                	mov    %edi,%eax
  8004b6:	e8 9e ff ff ff       	call   800459 <printnum>
  8004bb:	83 c4 20             	add    $0x20,%esp
  8004be:	eb 18                	jmp    8004d8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	56                   	push   %esi
  8004c4:	ff 75 18             	pushl  0x18(%ebp)
  8004c7:	ff d7                	call   *%edi
  8004c9:	83 c4 10             	add    $0x10,%esp
  8004cc:	eb 03                	jmp    8004d1 <printnum+0x78>
  8004ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004d1:	83 eb 01             	sub    $0x1,%ebx
  8004d4:	85 db                	test   %ebx,%ebx
  8004d6:	7f e8                	jg     8004c0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	56                   	push   %esi
  8004dc:	83 ec 04             	sub    $0x4,%esp
  8004df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e5:	ff 75 dc             	pushl  -0x24(%ebp)
  8004e8:	ff 75 d8             	pushl  -0x28(%ebp)
  8004eb:	e8 a0 1c 00 00       	call   802190 <__umoddi3>
  8004f0:	83 c4 14             	add    $0x14,%esp
  8004f3:	0f be 80 bb 23 80 00 	movsbl 0x8023bb(%eax),%eax
  8004fa:	50                   	push   %eax
  8004fb:	ff d7                	call   *%edi
}
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800503:	5b                   	pop    %ebx
  800504:	5e                   	pop    %esi
  800505:	5f                   	pop    %edi
  800506:	5d                   	pop    %ebp
  800507:	c3                   	ret    

00800508 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80050b:	83 fa 01             	cmp    $0x1,%edx
  80050e:	7e 0e                	jle    80051e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800510:	8b 10                	mov    (%eax),%edx
  800512:	8d 4a 08             	lea    0x8(%edx),%ecx
  800515:	89 08                	mov    %ecx,(%eax)
  800517:	8b 02                	mov    (%edx),%eax
  800519:	8b 52 04             	mov    0x4(%edx),%edx
  80051c:	eb 22                	jmp    800540 <getuint+0x38>
	else if (lflag)
  80051e:	85 d2                	test   %edx,%edx
  800520:	74 10                	je     800532 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800522:	8b 10                	mov    (%eax),%edx
  800524:	8d 4a 04             	lea    0x4(%edx),%ecx
  800527:	89 08                	mov    %ecx,(%eax)
  800529:	8b 02                	mov    (%edx),%eax
  80052b:	ba 00 00 00 00       	mov    $0x0,%edx
  800530:	eb 0e                	jmp    800540 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800532:	8b 10                	mov    (%eax),%edx
  800534:	8d 4a 04             	lea    0x4(%edx),%ecx
  800537:	89 08                	mov    %ecx,(%eax)
  800539:	8b 02                	mov    (%edx),%eax
  80053b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800540:	5d                   	pop    %ebp
  800541:	c3                   	ret    

00800542 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800542:	55                   	push   %ebp
  800543:	89 e5                	mov    %esp,%ebp
  800545:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800548:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80054c:	8b 10                	mov    (%eax),%edx
  80054e:	3b 50 04             	cmp    0x4(%eax),%edx
  800551:	73 0a                	jae    80055d <sprintputch+0x1b>
		*b->buf++ = ch;
  800553:	8d 4a 01             	lea    0x1(%edx),%ecx
  800556:	89 08                	mov    %ecx,(%eax)
  800558:	8b 45 08             	mov    0x8(%ebp),%eax
  80055b:	88 02                	mov    %al,(%edx)
}
  80055d:	5d                   	pop    %ebp
  80055e:	c3                   	ret    

0080055f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80055f:	55                   	push   %ebp
  800560:	89 e5                	mov    %esp,%ebp
  800562:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800565:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800568:	50                   	push   %eax
  800569:	ff 75 10             	pushl  0x10(%ebp)
  80056c:	ff 75 0c             	pushl  0xc(%ebp)
  80056f:	ff 75 08             	pushl  0x8(%ebp)
  800572:	e8 05 00 00 00       	call   80057c <vprintfmt>
	va_end(ap);
}
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	c9                   	leave  
  80057b:	c3                   	ret    

0080057c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  80057f:	57                   	push   %edi
  800580:	56                   	push   %esi
  800581:	53                   	push   %ebx
  800582:	83 ec 2c             	sub    $0x2c,%esp
  800585:	8b 75 08             	mov    0x8(%ebp),%esi
  800588:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80058e:	eb 12                	jmp    8005a2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800590:	85 c0                	test   %eax,%eax
  800592:	0f 84 89 03 00 00    	je     800921 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	53                   	push   %ebx
  80059c:	50                   	push   %eax
  80059d:	ff d6                	call   *%esi
  80059f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a2:	83 c7 01             	add    $0x1,%edi
  8005a5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a9:	83 f8 25             	cmp    $0x25,%eax
  8005ac:	75 e2                	jne    800590 <vprintfmt+0x14>
  8005ae:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005b2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005b9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005c0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8005cc:	eb 07                	jmp    8005d5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005d1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8d 47 01             	lea    0x1(%edi),%eax
  8005d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005db:	0f b6 07             	movzbl (%edi),%eax
  8005de:	0f b6 c8             	movzbl %al,%ecx
  8005e1:	83 e8 23             	sub    $0x23,%eax
  8005e4:	3c 55                	cmp    $0x55,%al
  8005e6:	0f 87 1a 03 00 00    	ja     800906 <vprintfmt+0x38a>
  8005ec:	0f b6 c0             	movzbl %al,%eax
  8005ef:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  8005f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005f9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005fd:	eb d6                	jmp    8005d5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800602:	b8 00 00 00 00       	mov    $0x0,%eax
  800607:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80060a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80060d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800611:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800614:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800617:	83 fa 09             	cmp    $0x9,%edx
  80061a:	77 39                	ja     800655 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80061c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80061f:	eb e9                	jmp    80060a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8d 48 04             	lea    0x4(%eax),%ecx
  800627:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80062a:	8b 00                	mov    (%eax),%eax
  80062c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800632:	eb 27                	jmp    80065b <vprintfmt+0xdf>
  800634:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800637:	85 c0                	test   %eax,%eax
  800639:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063e:	0f 49 c8             	cmovns %eax,%ecx
  800641:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800647:	eb 8c                	jmp    8005d5 <vprintfmt+0x59>
  800649:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80064c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800653:	eb 80                	jmp    8005d5 <vprintfmt+0x59>
  800655:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800658:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80065b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80065f:	0f 89 70 ff ff ff    	jns    8005d5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800665:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800668:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80066b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800672:	e9 5e ff ff ff       	jmp    8005d5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800677:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80067d:	e9 53 ff ff ff       	jmp    8005d5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 50 04             	lea    0x4(%eax),%edx
  800688:	89 55 14             	mov    %edx,0x14(%ebp)
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	ff 30                	pushl  (%eax)
  800691:	ff d6                	call   *%esi
			break;
  800693:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800696:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800699:	e9 04 ff ff ff       	jmp    8005a2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 50 04             	lea    0x4(%eax),%edx
  8006a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a7:	8b 00                	mov    (%eax),%eax
  8006a9:	99                   	cltd   
  8006aa:	31 d0                	xor    %edx,%eax
  8006ac:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006ae:	83 f8 0f             	cmp    $0xf,%eax
  8006b1:	7f 0b                	jg     8006be <vprintfmt+0x142>
  8006b3:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  8006ba:	85 d2                	test   %edx,%edx
  8006bc:	75 18                	jne    8006d6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8006be:	50                   	push   %eax
  8006bf:	68 d3 23 80 00       	push   $0x8023d3
  8006c4:	53                   	push   %ebx
  8006c5:	56                   	push   %esi
  8006c6:	e8 94 fe ff ff       	call   80055f <printfmt>
  8006cb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006d1:	e9 cc fe ff ff       	jmp    8005a2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006d6:	52                   	push   %edx
  8006d7:	68 95 27 80 00       	push   $0x802795
  8006dc:	53                   	push   %ebx
  8006dd:	56                   	push   %esi
  8006de:	e8 7c fe ff ff       	call   80055f <printfmt>
  8006e3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e9:	e9 b4 fe ff ff       	jmp    8005a2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8d 50 04             	lea    0x4(%eax),%edx
  8006f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006f9:	85 ff                	test   %edi,%edi
  8006fb:	b8 cc 23 80 00       	mov    $0x8023cc,%eax
  800700:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800703:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800707:	0f 8e 94 00 00 00    	jle    8007a1 <vprintfmt+0x225>
  80070d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800711:	0f 84 98 00 00 00    	je     8007af <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	ff 75 d0             	pushl  -0x30(%ebp)
  80071d:	57                   	push   %edi
  80071e:	e8 86 02 00 00       	call   8009a9 <strnlen>
  800723:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800726:	29 c1                	sub    %eax,%ecx
  800728:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80072b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80072e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800732:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800735:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800738:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80073a:	eb 0f                	jmp    80074b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	ff 75 e0             	pushl  -0x20(%ebp)
  800743:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800745:	83 ef 01             	sub    $0x1,%edi
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	85 ff                	test   %edi,%edi
  80074d:	7f ed                	jg     80073c <vprintfmt+0x1c0>
  80074f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800752:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800755:	85 c9                	test   %ecx,%ecx
  800757:	b8 00 00 00 00       	mov    $0x0,%eax
  80075c:	0f 49 c1             	cmovns %ecx,%eax
  80075f:	29 c1                	sub    %eax,%ecx
  800761:	89 75 08             	mov    %esi,0x8(%ebp)
  800764:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800767:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80076a:	89 cb                	mov    %ecx,%ebx
  80076c:	eb 4d                	jmp    8007bb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80076e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800772:	74 1b                	je     80078f <vprintfmt+0x213>
  800774:	0f be c0             	movsbl %al,%eax
  800777:	83 e8 20             	sub    $0x20,%eax
  80077a:	83 f8 5e             	cmp    $0x5e,%eax
  80077d:	76 10                	jbe    80078f <vprintfmt+0x213>
					putch('?', putdat);
  80077f:	83 ec 08             	sub    $0x8,%esp
  800782:	ff 75 0c             	pushl  0xc(%ebp)
  800785:	6a 3f                	push   $0x3f
  800787:	ff 55 08             	call   *0x8(%ebp)
  80078a:	83 c4 10             	add    $0x10,%esp
  80078d:	eb 0d                	jmp    80079c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80078f:	83 ec 08             	sub    $0x8,%esp
  800792:	ff 75 0c             	pushl  0xc(%ebp)
  800795:	52                   	push   %edx
  800796:	ff 55 08             	call   *0x8(%ebp)
  800799:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80079c:	83 eb 01             	sub    $0x1,%ebx
  80079f:	eb 1a                	jmp    8007bb <vprintfmt+0x23f>
  8007a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8007a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007aa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007ad:	eb 0c                	jmp    8007bb <vprintfmt+0x23f>
  8007af:	89 75 08             	mov    %esi,0x8(%ebp)
  8007b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007bb:	83 c7 01             	add    $0x1,%edi
  8007be:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007c2:	0f be d0             	movsbl %al,%edx
  8007c5:	85 d2                	test   %edx,%edx
  8007c7:	74 23                	je     8007ec <vprintfmt+0x270>
  8007c9:	85 f6                	test   %esi,%esi
  8007cb:	78 a1                	js     80076e <vprintfmt+0x1f2>
  8007cd:	83 ee 01             	sub    $0x1,%esi
  8007d0:	79 9c                	jns    80076e <vprintfmt+0x1f2>
  8007d2:	89 df                	mov    %ebx,%edi
  8007d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007da:	eb 18                	jmp    8007f4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	53                   	push   %ebx
  8007e0:	6a 20                	push   $0x20
  8007e2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007e4:	83 ef 01             	sub    $0x1,%edi
  8007e7:	83 c4 10             	add    $0x10,%esp
  8007ea:	eb 08                	jmp    8007f4 <vprintfmt+0x278>
  8007ec:	89 df                	mov    %ebx,%edi
  8007ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f4:	85 ff                	test   %edi,%edi
  8007f6:	7f e4                	jg     8007dc <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007fb:	e9 a2 fd ff ff       	jmp    8005a2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800800:	83 fa 01             	cmp    $0x1,%edx
  800803:	7e 16                	jle    80081b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	8d 50 08             	lea    0x8(%eax),%edx
  80080b:	89 55 14             	mov    %edx,0x14(%ebp)
  80080e:	8b 50 04             	mov    0x4(%eax),%edx
  800811:	8b 00                	mov    (%eax),%eax
  800813:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800816:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800819:	eb 32                	jmp    80084d <vprintfmt+0x2d1>
	else if (lflag)
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 18                	je     800837 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8d 50 04             	lea    0x4(%eax),%edx
  800825:	89 55 14             	mov    %edx,0x14(%ebp)
  800828:	8b 00                	mov    (%eax),%eax
  80082a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082d:	89 c1                	mov    %eax,%ecx
  80082f:	c1 f9 1f             	sar    $0x1f,%ecx
  800832:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800835:	eb 16                	jmp    80084d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800837:	8b 45 14             	mov    0x14(%ebp),%eax
  80083a:	8d 50 04             	lea    0x4(%eax),%edx
  80083d:	89 55 14             	mov    %edx,0x14(%ebp)
  800840:	8b 00                	mov    (%eax),%eax
  800842:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800845:	89 c1                	mov    %eax,%ecx
  800847:	c1 f9 1f             	sar    $0x1f,%ecx
  80084a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80084d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800850:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800853:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800858:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80085c:	79 74                	jns    8008d2 <vprintfmt+0x356>
				putch('-', putdat);
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	53                   	push   %ebx
  800862:	6a 2d                	push   $0x2d
  800864:	ff d6                	call   *%esi
				num = -(long long) num;
  800866:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800869:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80086c:	f7 d8                	neg    %eax
  80086e:	83 d2 00             	adc    $0x0,%edx
  800871:	f7 da                	neg    %edx
  800873:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800876:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80087b:	eb 55                	jmp    8008d2 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80087d:	8d 45 14             	lea    0x14(%ebp),%eax
  800880:	e8 83 fc ff ff       	call   800508 <getuint>
			base = 10;
  800885:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80088a:	eb 46                	jmp    8008d2 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80088c:	8d 45 14             	lea    0x14(%ebp),%eax
  80088f:	e8 74 fc ff ff       	call   800508 <getuint>
			base = 8;
  800894:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800899:	eb 37                	jmp    8008d2 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	53                   	push   %ebx
  80089f:	6a 30                	push   $0x30
  8008a1:	ff d6                	call   *%esi
			putch('x', putdat);
  8008a3:	83 c4 08             	add    $0x8,%esp
  8008a6:	53                   	push   %ebx
  8008a7:	6a 78                	push   $0x78
  8008a9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ae:	8d 50 04             	lea    0x4(%eax),%edx
  8008b1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008b4:	8b 00                	mov    (%eax),%eax
  8008b6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008bb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008be:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008c3:	eb 0d                	jmp    8008d2 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c8:	e8 3b fc ff ff       	call   800508 <getuint>
			base = 16;
  8008cd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d2:	83 ec 0c             	sub    $0xc,%esp
  8008d5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008d9:	57                   	push   %edi
  8008da:	ff 75 e0             	pushl  -0x20(%ebp)
  8008dd:	51                   	push   %ecx
  8008de:	52                   	push   %edx
  8008df:	50                   	push   %eax
  8008e0:	89 da                	mov    %ebx,%edx
  8008e2:	89 f0                	mov    %esi,%eax
  8008e4:	e8 70 fb ff ff       	call   800459 <printnum>
			break;
  8008e9:	83 c4 20             	add    $0x20,%esp
  8008ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ef:	e9 ae fc ff ff       	jmp    8005a2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	53                   	push   %ebx
  8008f8:	51                   	push   %ecx
  8008f9:	ff d6                	call   *%esi
			break;
  8008fb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800901:	e9 9c fc ff ff       	jmp    8005a2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800906:	83 ec 08             	sub    $0x8,%esp
  800909:	53                   	push   %ebx
  80090a:	6a 25                	push   $0x25
  80090c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80090e:	83 c4 10             	add    $0x10,%esp
  800911:	eb 03                	jmp    800916 <vprintfmt+0x39a>
  800913:	83 ef 01             	sub    $0x1,%edi
  800916:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80091a:	75 f7                	jne    800913 <vprintfmt+0x397>
  80091c:	e9 81 fc ff ff       	jmp    8005a2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800921:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	83 ec 18             	sub    $0x18,%esp
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800935:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800938:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80093c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80093f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800946:	85 c0                	test   %eax,%eax
  800948:	74 26                	je     800970 <vsnprintf+0x47>
  80094a:	85 d2                	test   %edx,%edx
  80094c:	7e 22                	jle    800970 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80094e:	ff 75 14             	pushl  0x14(%ebp)
  800951:	ff 75 10             	pushl  0x10(%ebp)
  800954:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800957:	50                   	push   %eax
  800958:	68 42 05 80 00       	push   $0x800542
  80095d:	e8 1a fc ff ff       	call   80057c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800962:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800965:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800968:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096b:	83 c4 10             	add    $0x10,%esp
  80096e:	eb 05                	jmp    800975 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800970:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800975:	c9                   	leave  
  800976:	c3                   	ret    

00800977 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80097d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800980:	50                   	push   %eax
  800981:	ff 75 10             	pushl  0x10(%ebp)
  800984:	ff 75 0c             	pushl  0xc(%ebp)
  800987:	ff 75 08             	pushl  0x8(%ebp)
  80098a:	e8 9a ff ff ff       	call   800929 <vsnprintf>
	va_end(ap);

	return rc;
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
  80099c:	eb 03                	jmp    8009a1 <strlen+0x10>
		n++;
  80099e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a5:	75 f7                	jne    80099e <strlen+0xd>
		n++;
	return n;
}
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009af:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	eb 03                	jmp    8009bc <strnlen+0x13>
		n++;
  8009b9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009bc:	39 c2                	cmp    %eax,%edx
  8009be:	74 08                	je     8009c8 <strnlen+0x1f>
  8009c0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009c4:	75 f3                	jne    8009b9 <strnlen+0x10>
  8009c6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	53                   	push   %ebx
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d4:	89 c2                	mov    %eax,%edx
  8009d6:	83 c2 01             	add    $0x1,%edx
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009e0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e3:	84 db                	test   %bl,%bl
  8009e5:	75 ef                	jne    8009d6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009e7:	5b                   	pop    %ebx
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	53                   	push   %ebx
  8009ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f1:	53                   	push   %ebx
  8009f2:	e8 9a ff ff ff       	call   800991 <strlen>
  8009f7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009fa:	ff 75 0c             	pushl  0xc(%ebp)
  8009fd:	01 d8                	add    %ebx,%eax
  8009ff:	50                   	push   %eax
  800a00:	e8 c5 ff ff ff       	call   8009ca <strcpy>
	return dst;
}
  800a05:	89 d8                	mov    %ebx,%eax
  800a07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	8b 75 08             	mov    0x8(%ebp),%esi
  800a14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a17:	89 f3                	mov    %esi,%ebx
  800a19:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1c:	89 f2                	mov    %esi,%edx
  800a1e:	eb 0f                	jmp    800a2f <strncpy+0x23>
		*dst++ = *src;
  800a20:	83 c2 01             	add    $0x1,%edx
  800a23:	0f b6 01             	movzbl (%ecx),%eax
  800a26:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a29:	80 39 01             	cmpb   $0x1,(%ecx)
  800a2c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a2f:	39 da                	cmp    %ebx,%edx
  800a31:	75 ed                	jne    800a20 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a33:	89 f0                	mov    %esi,%eax
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a44:	8b 55 10             	mov    0x10(%ebp),%edx
  800a47:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a49:	85 d2                	test   %edx,%edx
  800a4b:	74 21                	je     800a6e <strlcpy+0x35>
  800a4d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a51:	89 f2                	mov    %esi,%edx
  800a53:	eb 09                	jmp    800a5e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a55:	83 c2 01             	add    $0x1,%edx
  800a58:	83 c1 01             	add    $0x1,%ecx
  800a5b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a5e:	39 c2                	cmp    %eax,%edx
  800a60:	74 09                	je     800a6b <strlcpy+0x32>
  800a62:	0f b6 19             	movzbl (%ecx),%ebx
  800a65:	84 db                	test   %bl,%bl
  800a67:	75 ec                	jne    800a55 <strlcpy+0x1c>
  800a69:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a6b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a6e:	29 f0                	sub    %esi,%eax
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a7d:	eb 06                	jmp    800a85 <strcmp+0x11>
		p++, q++;
  800a7f:	83 c1 01             	add    $0x1,%ecx
  800a82:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a85:	0f b6 01             	movzbl (%ecx),%eax
  800a88:	84 c0                	test   %al,%al
  800a8a:	74 04                	je     800a90 <strcmp+0x1c>
  800a8c:	3a 02                	cmp    (%edx),%al
  800a8e:	74 ef                	je     800a7f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a90:	0f b6 c0             	movzbl %al,%eax
  800a93:	0f b6 12             	movzbl (%edx),%edx
  800a96:	29 d0                	sub    %edx,%eax
}
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	53                   	push   %ebx
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa4:	89 c3                	mov    %eax,%ebx
  800aa6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aa9:	eb 06                	jmp    800ab1 <strncmp+0x17>
		n--, p++, q++;
  800aab:	83 c0 01             	add    $0x1,%eax
  800aae:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab1:	39 d8                	cmp    %ebx,%eax
  800ab3:	74 15                	je     800aca <strncmp+0x30>
  800ab5:	0f b6 08             	movzbl (%eax),%ecx
  800ab8:	84 c9                	test   %cl,%cl
  800aba:	74 04                	je     800ac0 <strncmp+0x26>
  800abc:	3a 0a                	cmp    (%edx),%cl
  800abe:	74 eb                	je     800aab <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac0:	0f b6 00             	movzbl (%eax),%eax
  800ac3:	0f b6 12             	movzbl (%edx),%edx
  800ac6:	29 d0                	sub    %edx,%eax
  800ac8:	eb 05                	jmp    800acf <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800acf:	5b                   	pop    %ebx
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800adc:	eb 07                	jmp    800ae5 <strchr+0x13>
		if (*s == c)
  800ade:	38 ca                	cmp    %cl,%dl
  800ae0:	74 0f                	je     800af1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae2:	83 c0 01             	add    $0x1,%eax
  800ae5:	0f b6 10             	movzbl (%eax),%edx
  800ae8:	84 d2                	test   %dl,%dl
  800aea:	75 f2                	jne    800ade <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800afd:	eb 03                	jmp    800b02 <strfind+0xf>
  800aff:	83 c0 01             	add    $0x1,%eax
  800b02:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b05:	38 ca                	cmp    %cl,%dl
  800b07:	74 04                	je     800b0d <strfind+0x1a>
  800b09:	84 d2                	test   %dl,%dl
  800b0b:	75 f2                	jne    800aff <strfind+0xc>
			break;
	return (char *) s;
}
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b1b:	85 c9                	test   %ecx,%ecx
  800b1d:	74 36                	je     800b55 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b25:	75 28                	jne    800b4f <memset+0x40>
  800b27:	f6 c1 03             	test   $0x3,%cl
  800b2a:	75 23                	jne    800b4f <memset+0x40>
		c &= 0xFF;
  800b2c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	c1 e3 08             	shl    $0x8,%ebx
  800b35:	89 d6                	mov    %edx,%esi
  800b37:	c1 e6 18             	shl    $0x18,%esi
  800b3a:	89 d0                	mov    %edx,%eax
  800b3c:	c1 e0 10             	shl    $0x10,%eax
  800b3f:	09 f0                	or     %esi,%eax
  800b41:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b43:	89 d8                	mov    %ebx,%eax
  800b45:	09 d0                	or     %edx,%eax
  800b47:	c1 e9 02             	shr    $0x2,%ecx
  800b4a:	fc                   	cld    
  800b4b:	f3 ab                	rep stos %eax,%es:(%edi)
  800b4d:	eb 06                	jmp    800b55 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b52:	fc                   	cld    
  800b53:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b55:	89 f8                	mov    %edi,%eax
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	8b 45 08             	mov    0x8(%ebp),%eax
  800b64:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b67:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b6a:	39 c6                	cmp    %eax,%esi
  800b6c:	73 35                	jae    800ba3 <memmove+0x47>
  800b6e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b71:	39 d0                	cmp    %edx,%eax
  800b73:	73 2e                	jae    800ba3 <memmove+0x47>
		s += n;
		d += n;
  800b75:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	09 fe                	or     %edi,%esi
  800b7c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b82:	75 13                	jne    800b97 <memmove+0x3b>
  800b84:	f6 c1 03             	test   $0x3,%cl
  800b87:	75 0e                	jne    800b97 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b89:	83 ef 04             	sub    $0x4,%edi
  800b8c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b8f:	c1 e9 02             	shr    $0x2,%ecx
  800b92:	fd                   	std    
  800b93:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b95:	eb 09                	jmp    800ba0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b97:	83 ef 01             	sub    $0x1,%edi
  800b9a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b9d:	fd                   	std    
  800b9e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba0:	fc                   	cld    
  800ba1:	eb 1d                	jmp    800bc0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba3:	89 f2                	mov    %esi,%edx
  800ba5:	09 c2                	or     %eax,%edx
  800ba7:	f6 c2 03             	test   $0x3,%dl
  800baa:	75 0f                	jne    800bbb <memmove+0x5f>
  800bac:	f6 c1 03             	test   $0x3,%cl
  800baf:	75 0a                	jne    800bbb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bb1:	c1 e9 02             	shr    $0x2,%ecx
  800bb4:	89 c7                	mov    %eax,%edi
  800bb6:	fc                   	cld    
  800bb7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb9:	eb 05                	jmp    800bc0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bbb:	89 c7                	mov    %eax,%edi
  800bbd:	fc                   	cld    
  800bbe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bc7:	ff 75 10             	pushl  0x10(%ebp)
  800bca:	ff 75 0c             	pushl  0xc(%ebp)
  800bcd:	ff 75 08             	pushl  0x8(%ebp)
  800bd0:	e8 87 ff ff ff       	call   800b5c <memmove>
}
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be2:	89 c6                	mov    %eax,%esi
  800be4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be7:	eb 1a                	jmp    800c03 <memcmp+0x2c>
		if (*s1 != *s2)
  800be9:	0f b6 08             	movzbl (%eax),%ecx
  800bec:	0f b6 1a             	movzbl (%edx),%ebx
  800bef:	38 d9                	cmp    %bl,%cl
  800bf1:	74 0a                	je     800bfd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bf3:	0f b6 c1             	movzbl %cl,%eax
  800bf6:	0f b6 db             	movzbl %bl,%ebx
  800bf9:	29 d8                	sub    %ebx,%eax
  800bfb:	eb 0f                	jmp    800c0c <memcmp+0x35>
		s1++, s2++;
  800bfd:	83 c0 01             	add    $0x1,%eax
  800c00:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c03:	39 f0                	cmp    %esi,%eax
  800c05:	75 e2                	jne    800be9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	53                   	push   %ebx
  800c14:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c17:	89 c1                	mov    %eax,%ecx
  800c19:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c20:	eb 0a                	jmp    800c2c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c22:	0f b6 10             	movzbl (%eax),%edx
  800c25:	39 da                	cmp    %ebx,%edx
  800c27:	74 07                	je     800c30 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c29:	83 c0 01             	add    $0x1,%eax
  800c2c:	39 c8                	cmp    %ecx,%eax
  800c2e:	72 f2                	jb     800c22 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c30:	5b                   	pop    %ebx
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3f:	eb 03                	jmp    800c44 <strtol+0x11>
		s++;
  800c41:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c44:	0f b6 01             	movzbl (%ecx),%eax
  800c47:	3c 20                	cmp    $0x20,%al
  800c49:	74 f6                	je     800c41 <strtol+0xe>
  800c4b:	3c 09                	cmp    $0x9,%al
  800c4d:	74 f2                	je     800c41 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c4f:	3c 2b                	cmp    $0x2b,%al
  800c51:	75 0a                	jne    800c5d <strtol+0x2a>
		s++;
  800c53:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c56:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5b:	eb 11                	jmp    800c6e <strtol+0x3b>
  800c5d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c62:	3c 2d                	cmp    $0x2d,%al
  800c64:	75 08                	jne    800c6e <strtol+0x3b>
		s++, neg = 1;
  800c66:	83 c1 01             	add    $0x1,%ecx
  800c69:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c6e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c74:	75 15                	jne    800c8b <strtol+0x58>
  800c76:	80 39 30             	cmpb   $0x30,(%ecx)
  800c79:	75 10                	jne    800c8b <strtol+0x58>
  800c7b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c7f:	75 7c                	jne    800cfd <strtol+0xca>
		s += 2, base = 16;
  800c81:	83 c1 02             	add    $0x2,%ecx
  800c84:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c89:	eb 16                	jmp    800ca1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c8b:	85 db                	test   %ebx,%ebx
  800c8d:	75 12                	jne    800ca1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c8f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c94:	80 39 30             	cmpb   $0x30,(%ecx)
  800c97:	75 08                	jne    800ca1 <strtol+0x6e>
		s++, base = 8;
  800c99:	83 c1 01             	add    $0x1,%ecx
  800c9c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ca1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca9:	0f b6 11             	movzbl (%ecx),%edx
  800cac:	8d 72 d0             	lea    -0x30(%edx),%esi
  800caf:	89 f3                	mov    %esi,%ebx
  800cb1:	80 fb 09             	cmp    $0x9,%bl
  800cb4:	77 08                	ja     800cbe <strtol+0x8b>
			dig = *s - '0';
  800cb6:	0f be d2             	movsbl %dl,%edx
  800cb9:	83 ea 30             	sub    $0x30,%edx
  800cbc:	eb 22                	jmp    800ce0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cbe:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cc1:	89 f3                	mov    %esi,%ebx
  800cc3:	80 fb 19             	cmp    $0x19,%bl
  800cc6:	77 08                	ja     800cd0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cc8:	0f be d2             	movsbl %dl,%edx
  800ccb:	83 ea 57             	sub    $0x57,%edx
  800cce:	eb 10                	jmp    800ce0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cd0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cd3:	89 f3                	mov    %esi,%ebx
  800cd5:	80 fb 19             	cmp    $0x19,%bl
  800cd8:	77 16                	ja     800cf0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cda:	0f be d2             	movsbl %dl,%edx
  800cdd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ce0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ce3:	7d 0b                	jge    800cf0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ce5:	83 c1 01             	add    $0x1,%ecx
  800ce8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cec:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cee:	eb b9                	jmp    800ca9 <strtol+0x76>

	if (endptr)
  800cf0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf4:	74 0d                	je     800d03 <strtol+0xd0>
		*endptr = (char *) s;
  800cf6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf9:	89 0e                	mov    %ecx,(%esi)
  800cfb:	eb 06                	jmp    800d03 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cfd:	85 db                	test   %ebx,%ebx
  800cff:	74 98                	je     800c99 <strtol+0x66>
  800d01:	eb 9e                	jmp    800ca1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d03:	89 c2                	mov    %eax,%edx
  800d05:	f7 da                	neg    %edx
  800d07:	85 ff                	test   %edi,%edi
  800d09:	0f 45 c2             	cmovne %edx,%eax
}
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d17:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	89 c3                	mov    %eax,%ebx
  800d24:	89 c7                	mov    %eax,%edi
  800d26:	89 c6                	mov    %eax,%esi
  800d28:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <sys_cgetc>:

int
sys_cgetc(void)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	57                   	push   %edi
  800d33:	56                   	push   %esi
  800d34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3a:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3f:	89 d1                	mov    %edx,%ecx
  800d41:	89 d3                	mov    %edx,%ebx
  800d43:	89 d7                	mov    %edx,%edi
  800d45:	89 d6                	mov    %edx,%esi
  800d47:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5c:	b8 03 00 00 00       	mov    $0x3,%eax
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	89 cb                	mov    %ecx,%ebx
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	89 ce                	mov    %ecx,%esi
  800d6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	7e 17                	jle    800d87 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	50                   	push   %eax
  800d74:	6a 03                	push   $0x3
  800d76:	68 bf 26 80 00       	push   $0x8026bf
  800d7b:	6a 23                	push   $0x23
  800d7d:	68 dc 26 80 00       	push   $0x8026dc
  800d82:	e8 e5 f5 ff ff       	call   80036c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	57                   	push   %edi
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d95:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9a:	b8 02 00 00 00       	mov    $0x2,%eax
  800d9f:	89 d1                	mov    %edx,%ecx
  800da1:	89 d3                	mov    %edx,%ebx
  800da3:	89 d7                	mov    %edx,%edi
  800da5:	89 d6                	mov    %edx,%esi
  800da7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_yield>:

void
sys_yield(void)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	ba 00 00 00 00       	mov    $0x0,%edx
  800db9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dbe:	89 d1                	mov    %edx,%ecx
  800dc0:	89 d3                	mov    %edx,%ebx
  800dc2:	89 d7                	mov    %edx,%edi
  800dc4:	89 d6                	mov    %edx,%esi
  800dc6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd6:	be 00 00 00 00       	mov    $0x0,%esi
  800ddb:	b8 04 00 00 00       	mov    $0x4,%eax
  800de0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de9:	89 f7                	mov    %esi,%edi
  800deb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ded:	85 c0                	test   %eax,%eax
  800def:	7e 17                	jle    800e08 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df1:	83 ec 0c             	sub    $0xc,%esp
  800df4:	50                   	push   %eax
  800df5:	6a 04                	push   $0x4
  800df7:	68 bf 26 80 00       	push   $0x8026bf
  800dfc:	6a 23                	push   $0x23
  800dfe:	68 dc 26 80 00       	push   $0x8026dc
  800e03:	e8 64 f5 ff ff       	call   80036c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
  800e16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e19:	b8 05 00 00 00       	mov    $0x5,%eax
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	8b 55 08             	mov    0x8(%ebp),%edx
  800e24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e27:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2a:	8b 75 18             	mov    0x18(%ebp),%esi
  800e2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	7e 17                	jle    800e4a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	50                   	push   %eax
  800e37:	6a 05                	push   $0x5
  800e39:	68 bf 26 80 00       	push   $0x8026bf
  800e3e:	6a 23                	push   $0x23
  800e40:	68 dc 26 80 00       	push   $0x8026dc
  800e45:	e8 22 f5 ff ff       	call   80036c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5f                   	pop    %edi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	57                   	push   %edi
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
  800e58:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e60:	b8 06 00 00 00       	mov    $0x6,%eax
  800e65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	89 df                	mov    %ebx,%edi
  800e6d:	89 de                	mov    %ebx,%esi
  800e6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e71:	85 c0                	test   %eax,%eax
  800e73:	7e 17                	jle    800e8c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e75:	83 ec 0c             	sub    $0xc,%esp
  800e78:	50                   	push   %eax
  800e79:	6a 06                	push   $0x6
  800e7b:	68 bf 26 80 00       	push   $0x8026bf
  800e80:	6a 23                	push   $0x23
  800e82:	68 dc 26 80 00       	push   $0x8026dc
  800e87:	e8 e0 f4 ff ff       	call   80036c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8f:	5b                   	pop    %ebx
  800e90:	5e                   	pop    %esi
  800e91:	5f                   	pop    %edi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
  800e9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea2:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eaa:	8b 55 08             	mov    0x8(%ebp),%edx
  800ead:	89 df                	mov    %ebx,%edi
  800eaf:	89 de                	mov    %ebx,%esi
  800eb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	7e 17                	jle    800ece <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb7:	83 ec 0c             	sub    $0xc,%esp
  800eba:	50                   	push   %eax
  800ebb:	6a 08                	push   $0x8
  800ebd:	68 bf 26 80 00       	push   $0x8026bf
  800ec2:	6a 23                	push   $0x23
  800ec4:	68 dc 26 80 00       	push   $0x8026dc
  800ec9:	e8 9e f4 ff ff       	call   80036c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ece:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	57                   	push   %edi
  800eda:	56                   	push   %esi
  800edb:	53                   	push   %ebx
  800edc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ee9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eec:	8b 55 08             	mov    0x8(%ebp),%edx
  800eef:	89 df                	mov    %ebx,%edi
  800ef1:	89 de                	mov    %ebx,%esi
  800ef3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	7e 17                	jle    800f10 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef9:	83 ec 0c             	sub    $0xc,%esp
  800efc:	50                   	push   %eax
  800efd:	6a 09                	push   $0x9
  800eff:	68 bf 26 80 00       	push   $0x8026bf
  800f04:	6a 23                	push   $0x23
  800f06:	68 dc 26 80 00       	push   $0x8026dc
  800f0b:	e8 5c f4 ff ff       	call   80036c <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    

00800f18 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	57                   	push   %edi
  800f1c:	56                   	push   %esi
  800f1d:	53                   	push   %ebx
  800f1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f26:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f31:	89 df                	mov    %ebx,%edi
  800f33:	89 de                	mov    %ebx,%esi
  800f35:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f37:	85 c0                	test   %eax,%eax
  800f39:	7e 17                	jle    800f52 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3b:	83 ec 0c             	sub    $0xc,%esp
  800f3e:	50                   	push   %eax
  800f3f:	6a 0a                	push   $0xa
  800f41:	68 bf 26 80 00       	push   $0x8026bf
  800f46:	6a 23                	push   $0x23
  800f48:	68 dc 26 80 00       	push   $0x8026dc
  800f4d:	e8 1a f4 ff ff       	call   80036c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f60:	be 00 00 00 00       	mov    $0x0,%esi
  800f65:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f73:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f76:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f78:	5b                   	pop    %ebx
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    

00800f7d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	57                   	push   %edi
  800f81:	56                   	push   %esi
  800f82:	53                   	push   %ebx
  800f83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f8b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f90:	8b 55 08             	mov    0x8(%ebp),%edx
  800f93:	89 cb                	mov    %ecx,%ebx
  800f95:	89 cf                	mov    %ecx,%edi
  800f97:	89 ce                	mov    %ecx,%esi
  800f99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	7e 17                	jle    800fb6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9f:	83 ec 0c             	sub    $0xc,%esp
  800fa2:	50                   	push   %eax
  800fa3:	6a 0d                	push   $0xd
  800fa5:	68 bf 26 80 00       	push   $0x8026bf
  800faa:	6a 23                	push   $0x23
  800fac:	68 dc 26 80 00       	push   $0x8026dc
  800fb1:	e8 b6 f3 ff ff       	call   80036c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb9:	5b                   	pop    %ebx
  800fba:	5e                   	pop    %esi
  800fbb:	5f                   	pop    %edi
  800fbc:	5d                   	pop    %ebp
  800fbd:	c3                   	ret    

00800fbe <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc7:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800fca:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800fcc:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800fcf:	83 3a 01             	cmpl   $0x1,(%edx)
  800fd2:	7e 09                	jle    800fdd <argstart+0x1f>
  800fd4:	ba 68 23 80 00       	mov    $0x802368,%edx
  800fd9:	85 c9                	test   %ecx,%ecx
  800fdb:	75 05                	jne    800fe2 <argstart+0x24>
  800fdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe2:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800fe5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    

00800fee <argnext>:

int
argnext(struct Argstate *args)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	53                   	push   %ebx
  800ff2:	83 ec 04             	sub    $0x4,%esp
  800ff5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800ff8:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800fff:	8b 43 08             	mov    0x8(%ebx),%eax
  801002:	85 c0                	test   %eax,%eax
  801004:	74 6f                	je     801075 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801006:	80 38 00             	cmpb   $0x0,(%eax)
  801009:	75 4e                	jne    801059 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  80100b:	8b 0b                	mov    (%ebx),%ecx
  80100d:	83 39 01             	cmpl   $0x1,(%ecx)
  801010:	74 55                	je     801067 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801012:	8b 53 04             	mov    0x4(%ebx),%edx
  801015:	8b 42 04             	mov    0x4(%edx),%eax
  801018:	80 38 2d             	cmpb   $0x2d,(%eax)
  80101b:	75 4a                	jne    801067 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  80101d:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801021:	74 44                	je     801067 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801023:	83 c0 01             	add    $0x1,%eax
  801026:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801029:	83 ec 04             	sub    $0x4,%esp
  80102c:	8b 01                	mov    (%ecx),%eax
  80102e:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801035:	50                   	push   %eax
  801036:	8d 42 08             	lea    0x8(%edx),%eax
  801039:	50                   	push   %eax
  80103a:	83 c2 04             	add    $0x4,%edx
  80103d:	52                   	push   %edx
  80103e:	e8 19 fb ff ff       	call   800b5c <memmove>
		(*args->argc)--;
  801043:	8b 03                	mov    (%ebx),%eax
  801045:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801048:	8b 43 08             	mov    0x8(%ebx),%eax
  80104b:	83 c4 10             	add    $0x10,%esp
  80104e:	80 38 2d             	cmpb   $0x2d,(%eax)
  801051:	75 06                	jne    801059 <argnext+0x6b>
  801053:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801057:	74 0e                	je     801067 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801059:	8b 53 08             	mov    0x8(%ebx),%edx
  80105c:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  80105f:	83 c2 01             	add    $0x1,%edx
  801062:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801065:	eb 13                	jmp    80107a <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801067:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  80106e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801073:	eb 05                	jmp    80107a <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801075:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  80107a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    

0080107f <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	53                   	push   %ebx
  801083:	83 ec 04             	sub    $0x4,%esp
  801086:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801089:	8b 43 08             	mov    0x8(%ebx),%eax
  80108c:	85 c0                	test   %eax,%eax
  80108e:	74 58                	je     8010e8 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801090:	80 38 00             	cmpb   $0x0,(%eax)
  801093:	74 0c                	je     8010a1 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801095:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801098:	c7 43 08 68 23 80 00 	movl   $0x802368,0x8(%ebx)
  80109f:	eb 42                	jmp    8010e3 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  8010a1:	8b 13                	mov    (%ebx),%edx
  8010a3:	83 3a 01             	cmpl   $0x1,(%edx)
  8010a6:	7e 2d                	jle    8010d5 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  8010a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8010ab:	8b 48 04             	mov    0x4(%eax),%ecx
  8010ae:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8010b1:	83 ec 04             	sub    $0x4,%esp
  8010b4:	8b 12                	mov    (%edx),%edx
  8010b6:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  8010bd:	52                   	push   %edx
  8010be:	8d 50 08             	lea    0x8(%eax),%edx
  8010c1:	52                   	push   %edx
  8010c2:	83 c0 04             	add    $0x4,%eax
  8010c5:	50                   	push   %eax
  8010c6:	e8 91 fa ff ff       	call   800b5c <memmove>
		(*args->argc)--;
  8010cb:	8b 03                	mov    (%ebx),%eax
  8010cd:	83 28 01             	subl   $0x1,(%eax)
  8010d0:	83 c4 10             	add    $0x10,%esp
  8010d3:	eb 0e                	jmp    8010e3 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  8010d5:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8010dc:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8010e3:	8b 43 0c             	mov    0xc(%ebx),%eax
  8010e6:	eb 05                	jmp    8010ed <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8010e8:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8010ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	83 ec 08             	sub    $0x8,%esp
  8010f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8010fb:	8b 51 0c             	mov    0xc(%ecx),%edx
  8010fe:	89 d0                	mov    %edx,%eax
  801100:	85 d2                	test   %edx,%edx
  801102:	75 0c                	jne    801110 <argvalue+0x1e>
  801104:	83 ec 0c             	sub    $0xc,%esp
  801107:	51                   	push   %ecx
  801108:	e8 72 ff ff ff       	call   80107f <argnextvalue>
  80110d:	83 c4 10             	add    $0x10,%esp
}
  801110:	c9                   	leave  
  801111:	c3                   	ret    

00801112 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801115:	8b 45 08             	mov    0x8(%ebp),%eax
  801118:	05 00 00 00 30       	add    $0x30000000,%eax
  80111d:	c1 e8 0c             	shr    $0xc,%eax
}
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    

00801122 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801125:	8b 45 08             	mov    0x8(%ebp),%eax
  801128:	05 00 00 00 30       	add    $0x30000000,%eax
  80112d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801132:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801137:	5d                   	pop    %ebp
  801138:	c3                   	ret    

00801139 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801139:	55                   	push   %ebp
  80113a:	89 e5                	mov    %esp,%ebp
  80113c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80113f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801144:	89 c2                	mov    %eax,%edx
  801146:	c1 ea 16             	shr    $0x16,%edx
  801149:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801150:	f6 c2 01             	test   $0x1,%dl
  801153:	74 11                	je     801166 <fd_alloc+0x2d>
  801155:	89 c2                	mov    %eax,%edx
  801157:	c1 ea 0c             	shr    $0xc,%edx
  80115a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801161:	f6 c2 01             	test   $0x1,%dl
  801164:	75 09                	jne    80116f <fd_alloc+0x36>
			*fd_store = fd;
  801166:	89 01                	mov    %eax,(%ecx)
			return 0;
  801168:	b8 00 00 00 00       	mov    $0x0,%eax
  80116d:	eb 17                	jmp    801186 <fd_alloc+0x4d>
  80116f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801174:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801179:	75 c9                	jne    801144 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80117b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801181:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80118e:	83 f8 1f             	cmp    $0x1f,%eax
  801191:	77 36                	ja     8011c9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801193:	c1 e0 0c             	shl    $0xc,%eax
  801196:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80119b:	89 c2                	mov    %eax,%edx
  80119d:	c1 ea 16             	shr    $0x16,%edx
  8011a0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a7:	f6 c2 01             	test   $0x1,%dl
  8011aa:	74 24                	je     8011d0 <fd_lookup+0x48>
  8011ac:	89 c2                	mov    %eax,%edx
  8011ae:	c1 ea 0c             	shr    $0xc,%edx
  8011b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b8:	f6 c2 01             	test   $0x1,%dl
  8011bb:	74 1a                	je     8011d7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c0:	89 02                	mov    %eax,(%edx)
	return 0;
  8011c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c7:	eb 13                	jmp    8011dc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ce:	eb 0c                	jmp    8011dc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d5:	eb 05                	jmp    8011dc <fd_lookup+0x54>
  8011d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    

008011de <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e7:	ba 6c 27 80 00       	mov    $0x80276c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ec:	eb 13                	jmp    801201 <dev_lookup+0x23>
  8011ee:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011f1:	39 08                	cmp    %ecx,(%eax)
  8011f3:	75 0c                	jne    801201 <dev_lookup+0x23>
			*dev = devtab[i];
  8011f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ff:	eb 2e                	jmp    80122f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801201:	8b 02                	mov    (%edx),%eax
  801203:	85 c0                	test   %eax,%eax
  801205:	75 e7                	jne    8011ee <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801207:	a1 20 44 80 00       	mov    0x804420,%eax
  80120c:	8b 40 48             	mov    0x48(%eax),%eax
  80120f:	83 ec 04             	sub    $0x4,%esp
  801212:	51                   	push   %ecx
  801213:	50                   	push   %eax
  801214:	68 ec 26 80 00       	push   $0x8026ec
  801219:	e8 27 f2 ff ff       	call   800445 <cprintf>
	*dev = 0;
  80121e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801221:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80122f:	c9                   	leave  
  801230:	c3                   	ret    

00801231 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	56                   	push   %esi
  801235:	53                   	push   %ebx
  801236:	83 ec 10             	sub    $0x10,%esp
  801239:	8b 75 08             	mov    0x8(%ebp),%esi
  80123c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80123f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801242:	50                   	push   %eax
  801243:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801249:	c1 e8 0c             	shr    $0xc,%eax
  80124c:	50                   	push   %eax
  80124d:	e8 36 ff ff ff       	call   801188 <fd_lookup>
  801252:	83 c4 08             	add    $0x8,%esp
  801255:	85 c0                	test   %eax,%eax
  801257:	78 05                	js     80125e <fd_close+0x2d>
	    || fd != fd2)
  801259:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80125c:	74 0c                	je     80126a <fd_close+0x39>
		return (must_exist ? r : 0);
  80125e:	84 db                	test   %bl,%bl
  801260:	ba 00 00 00 00       	mov    $0x0,%edx
  801265:	0f 44 c2             	cmove  %edx,%eax
  801268:	eb 41                	jmp    8012ab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80126a:	83 ec 08             	sub    $0x8,%esp
  80126d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801270:	50                   	push   %eax
  801271:	ff 36                	pushl  (%esi)
  801273:	e8 66 ff ff ff       	call   8011de <dev_lookup>
  801278:	89 c3                	mov    %eax,%ebx
  80127a:	83 c4 10             	add    $0x10,%esp
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 1a                	js     80129b <fd_close+0x6a>
		if (dev->dev_close)
  801281:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801284:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801287:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80128c:	85 c0                	test   %eax,%eax
  80128e:	74 0b                	je     80129b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801290:	83 ec 0c             	sub    $0xc,%esp
  801293:	56                   	push   %esi
  801294:	ff d0                	call   *%eax
  801296:	89 c3                	mov    %eax,%ebx
  801298:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	56                   	push   %esi
  80129f:	6a 00                	push   $0x0
  8012a1:	e8 ac fb ff ff       	call   800e52 <sys_page_unmap>
	return r;
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	89 d8                	mov    %ebx,%eax
}
  8012ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ae:	5b                   	pop    %ebx
  8012af:	5e                   	pop    %esi
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bb:	50                   	push   %eax
  8012bc:	ff 75 08             	pushl  0x8(%ebp)
  8012bf:	e8 c4 fe ff ff       	call   801188 <fd_lookup>
  8012c4:	83 c4 08             	add    $0x8,%esp
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	78 10                	js     8012db <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012cb:	83 ec 08             	sub    $0x8,%esp
  8012ce:	6a 01                	push   $0x1
  8012d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d3:	e8 59 ff ff ff       	call   801231 <fd_close>
  8012d8:	83 c4 10             	add    $0x10,%esp
}
  8012db:	c9                   	leave  
  8012dc:	c3                   	ret    

008012dd <close_all>:

void
close_all(void)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	53                   	push   %ebx
  8012e1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012e9:	83 ec 0c             	sub    $0xc,%esp
  8012ec:	53                   	push   %ebx
  8012ed:	e8 c0 ff ff ff       	call   8012b2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012f2:	83 c3 01             	add    $0x1,%ebx
  8012f5:	83 c4 10             	add    $0x10,%esp
  8012f8:	83 fb 20             	cmp    $0x20,%ebx
  8012fb:	75 ec                	jne    8012e9 <close_all+0xc>
		close(i);
}
  8012fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801300:	c9                   	leave  
  801301:	c3                   	ret    

00801302 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	57                   	push   %edi
  801306:	56                   	push   %esi
  801307:	53                   	push   %ebx
  801308:	83 ec 2c             	sub    $0x2c,%esp
  80130b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80130e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801311:	50                   	push   %eax
  801312:	ff 75 08             	pushl  0x8(%ebp)
  801315:	e8 6e fe ff ff       	call   801188 <fd_lookup>
  80131a:	83 c4 08             	add    $0x8,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	0f 88 c1 00 00 00    	js     8013e6 <dup+0xe4>
		return r;
	close(newfdnum);
  801325:	83 ec 0c             	sub    $0xc,%esp
  801328:	56                   	push   %esi
  801329:	e8 84 ff ff ff       	call   8012b2 <close>

	newfd = INDEX2FD(newfdnum);
  80132e:	89 f3                	mov    %esi,%ebx
  801330:	c1 e3 0c             	shl    $0xc,%ebx
  801333:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801339:	83 c4 04             	add    $0x4,%esp
  80133c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80133f:	e8 de fd ff ff       	call   801122 <fd2data>
  801344:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801346:	89 1c 24             	mov    %ebx,(%esp)
  801349:	e8 d4 fd ff ff       	call   801122 <fd2data>
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801354:	89 f8                	mov    %edi,%eax
  801356:	c1 e8 16             	shr    $0x16,%eax
  801359:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801360:	a8 01                	test   $0x1,%al
  801362:	74 37                	je     80139b <dup+0x99>
  801364:	89 f8                	mov    %edi,%eax
  801366:	c1 e8 0c             	shr    $0xc,%eax
  801369:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801370:	f6 c2 01             	test   $0x1,%dl
  801373:	74 26                	je     80139b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801375:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80137c:	83 ec 0c             	sub    $0xc,%esp
  80137f:	25 07 0e 00 00       	and    $0xe07,%eax
  801384:	50                   	push   %eax
  801385:	ff 75 d4             	pushl  -0x2c(%ebp)
  801388:	6a 00                	push   $0x0
  80138a:	57                   	push   %edi
  80138b:	6a 00                	push   $0x0
  80138d:	e8 7e fa ff ff       	call   800e10 <sys_page_map>
  801392:	89 c7                	mov    %eax,%edi
  801394:	83 c4 20             	add    $0x20,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	78 2e                	js     8013c9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80139e:	89 d0                	mov    %edx,%eax
  8013a0:	c1 e8 0c             	shr    $0xc,%eax
  8013a3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013aa:	83 ec 0c             	sub    $0xc,%esp
  8013ad:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b2:	50                   	push   %eax
  8013b3:	53                   	push   %ebx
  8013b4:	6a 00                	push   $0x0
  8013b6:	52                   	push   %edx
  8013b7:	6a 00                	push   $0x0
  8013b9:	e8 52 fa ff ff       	call   800e10 <sys_page_map>
  8013be:	89 c7                	mov    %eax,%edi
  8013c0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013c3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c5:	85 ff                	test   %edi,%edi
  8013c7:	79 1d                	jns    8013e6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013c9:	83 ec 08             	sub    $0x8,%esp
  8013cc:	53                   	push   %ebx
  8013cd:	6a 00                	push   $0x0
  8013cf:	e8 7e fa ff ff       	call   800e52 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013d4:	83 c4 08             	add    $0x8,%esp
  8013d7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013da:	6a 00                	push   $0x0
  8013dc:	e8 71 fa ff ff       	call   800e52 <sys_page_unmap>
	return r;
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	89 f8                	mov    %edi,%eax
}
  8013e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e9:	5b                   	pop    %ebx
  8013ea:	5e                   	pop    %esi
  8013eb:	5f                   	pop    %edi
  8013ec:	5d                   	pop    %ebp
  8013ed:	c3                   	ret    

008013ee <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	53                   	push   %ebx
  8013f2:	83 ec 14             	sub    $0x14,%esp
  8013f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013fb:	50                   	push   %eax
  8013fc:	53                   	push   %ebx
  8013fd:	e8 86 fd ff ff       	call   801188 <fd_lookup>
  801402:	83 c4 08             	add    $0x8,%esp
  801405:	89 c2                	mov    %eax,%edx
  801407:	85 c0                	test   %eax,%eax
  801409:	78 6d                	js     801478 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140b:	83 ec 08             	sub    $0x8,%esp
  80140e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801411:	50                   	push   %eax
  801412:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801415:	ff 30                	pushl  (%eax)
  801417:	e8 c2 fd ff ff       	call   8011de <dev_lookup>
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	85 c0                	test   %eax,%eax
  801421:	78 4c                	js     80146f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801423:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801426:	8b 42 08             	mov    0x8(%edx),%eax
  801429:	83 e0 03             	and    $0x3,%eax
  80142c:	83 f8 01             	cmp    $0x1,%eax
  80142f:	75 21                	jne    801452 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801431:	a1 20 44 80 00       	mov    0x804420,%eax
  801436:	8b 40 48             	mov    0x48(%eax),%eax
  801439:	83 ec 04             	sub    $0x4,%esp
  80143c:	53                   	push   %ebx
  80143d:	50                   	push   %eax
  80143e:	68 30 27 80 00       	push   $0x802730
  801443:	e8 fd ef ff ff       	call   800445 <cprintf>
		return -E_INVAL;
  801448:	83 c4 10             	add    $0x10,%esp
  80144b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801450:	eb 26                	jmp    801478 <read+0x8a>
	}
	if (!dev->dev_read)
  801452:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801455:	8b 40 08             	mov    0x8(%eax),%eax
  801458:	85 c0                	test   %eax,%eax
  80145a:	74 17                	je     801473 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80145c:	83 ec 04             	sub    $0x4,%esp
  80145f:	ff 75 10             	pushl  0x10(%ebp)
  801462:	ff 75 0c             	pushl  0xc(%ebp)
  801465:	52                   	push   %edx
  801466:	ff d0                	call   *%eax
  801468:	89 c2                	mov    %eax,%edx
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	eb 09                	jmp    801478 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146f:	89 c2                	mov    %eax,%edx
  801471:	eb 05                	jmp    801478 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801473:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801478:	89 d0                	mov    %edx,%eax
  80147a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	57                   	push   %edi
  801483:	56                   	push   %esi
  801484:	53                   	push   %ebx
  801485:	83 ec 0c             	sub    $0xc,%esp
  801488:	8b 7d 08             	mov    0x8(%ebp),%edi
  80148b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80148e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801493:	eb 21                	jmp    8014b6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801495:	83 ec 04             	sub    $0x4,%esp
  801498:	89 f0                	mov    %esi,%eax
  80149a:	29 d8                	sub    %ebx,%eax
  80149c:	50                   	push   %eax
  80149d:	89 d8                	mov    %ebx,%eax
  80149f:	03 45 0c             	add    0xc(%ebp),%eax
  8014a2:	50                   	push   %eax
  8014a3:	57                   	push   %edi
  8014a4:	e8 45 ff ff ff       	call   8013ee <read>
		if (m < 0)
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	78 10                	js     8014c0 <readn+0x41>
			return m;
		if (m == 0)
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	74 0a                	je     8014be <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b4:	01 c3                	add    %eax,%ebx
  8014b6:	39 f3                	cmp    %esi,%ebx
  8014b8:	72 db                	jb     801495 <readn+0x16>
  8014ba:	89 d8                	mov    %ebx,%eax
  8014bc:	eb 02                	jmp    8014c0 <readn+0x41>
  8014be:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c3:	5b                   	pop    %ebx
  8014c4:	5e                   	pop    %esi
  8014c5:	5f                   	pop    %edi
  8014c6:	5d                   	pop    %ebp
  8014c7:	c3                   	ret    

008014c8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	53                   	push   %ebx
  8014cc:	83 ec 14             	sub    $0x14,%esp
  8014cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d5:	50                   	push   %eax
  8014d6:	53                   	push   %ebx
  8014d7:	e8 ac fc ff ff       	call   801188 <fd_lookup>
  8014dc:	83 c4 08             	add    $0x8,%esp
  8014df:	89 c2                	mov    %eax,%edx
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 68                	js     80154d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014eb:	50                   	push   %eax
  8014ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ef:	ff 30                	pushl  (%eax)
  8014f1:	e8 e8 fc ff ff       	call   8011de <dev_lookup>
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 47                	js     801544 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801500:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801504:	75 21                	jne    801527 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801506:	a1 20 44 80 00       	mov    0x804420,%eax
  80150b:	8b 40 48             	mov    0x48(%eax),%eax
  80150e:	83 ec 04             	sub    $0x4,%esp
  801511:	53                   	push   %ebx
  801512:	50                   	push   %eax
  801513:	68 4c 27 80 00       	push   $0x80274c
  801518:	e8 28 ef ff ff       	call   800445 <cprintf>
		return -E_INVAL;
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801525:	eb 26                	jmp    80154d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801527:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80152a:	8b 52 0c             	mov    0xc(%edx),%edx
  80152d:	85 d2                	test   %edx,%edx
  80152f:	74 17                	je     801548 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801531:	83 ec 04             	sub    $0x4,%esp
  801534:	ff 75 10             	pushl  0x10(%ebp)
  801537:	ff 75 0c             	pushl  0xc(%ebp)
  80153a:	50                   	push   %eax
  80153b:	ff d2                	call   *%edx
  80153d:	89 c2                	mov    %eax,%edx
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	eb 09                	jmp    80154d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801544:	89 c2                	mov    %eax,%edx
  801546:	eb 05                	jmp    80154d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801548:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80154d:	89 d0                	mov    %edx,%eax
  80154f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801552:	c9                   	leave  
  801553:	c3                   	ret    

00801554 <seek>:

int
seek(int fdnum, off_t offset)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80155a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	ff 75 08             	pushl  0x8(%ebp)
  801561:	e8 22 fc ff ff       	call   801188 <fd_lookup>
  801566:	83 c4 08             	add    $0x8,%esp
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 0e                	js     80157b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80156d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801570:	8b 55 0c             	mov    0xc(%ebp),%edx
  801573:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801576:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80157b:	c9                   	leave  
  80157c:	c3                   	ret    

0080157d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	53                   	push   %ebx
  801581:	83 ec 14             	sub    $0x14,%esp
  801584:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801587:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158a:	50                   	push   %eax
  80158b:	53                   	push   %ebx
  80158c:	e8 f7 fb ff ff       	call   801188 <fd_lookup>
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	89 c2                	mov    %eax,%edx
  801596:	85 c0                	test   %eax,%eax
  801598:	78 65                	js     8015ff <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a4:	ff 30                	pushl  (%eax)
  8015a6:	e8 33 fc ff ff       	call   8011de <dev_lookup>
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	78 44                	js     8015f6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b9:	75 21                	jne    8015dc <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015bb:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015c0:	8b 40 48             	mov    0x48(%eax),%eax
  8015c3:	83 ec 04             	sub    $0x4,%esp
  8015c6:	53                   	push   %ebx
  8015c7:	50                   	push   %eax
  8015c8:	68 0c 27 80 00       	push   $0x80270c
  8015cd:	e8 73 ee ff ff       	call   800445 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015da:	eb 23                	jmp    8015ff <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015df:	8b 52 18             	mov    0x18(%edx),%edx
  8015e2:	85 d2                	test   %edx,%edx
  8015e4:	74 14                	je     8015fa <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ec:	50                   	push   %eax
  8015ed:	ff d2                	call   *%edx
  8015ef:	89 c2                	mov    %eax,%edx
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	eb 09                	jmp    8015ff <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f6:	89 c2                	mov    %eax,%edx
  8015f8:	eb 05                	jmp    8015ff <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015fa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015ff:	89 d0                	mov    %edx,%eax
  801601:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801604:	c9                   	leave  
  801605:	c3                   	ret    

00801606 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	53                   	push   %ebx
  80160a:	83 ec 14             	sub    $0x14,%esp
  80160d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801610:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801613:	50                   	push   %eax
  801614:	ff 75 08             	pushl  0x8(%ebp)
  801617:	e8 6c fb ff ff       	call   801188 <fd_lookup>
  80161c:	83 c4 08             	add    $0x8,%esp
  80161f:	89 c2                	mov    %eax,%edx
  801621:	85 c0                	test   %eax,%eax
  801623:	78 58                	js     80167d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162f:	ff 30                	pushl  (%eax)
  801631:	e8 a8 fb ff ff       	call   8011de <dev_lookup>
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	85 c0                	test   %eax,%eax
  80163b:	78 37                	js     801674 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80163d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801640:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801644:	74 32                	je     801678 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801646:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801649:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801650:	00 00 00 
	stat->st_isdir = 0;
  801653:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80165a:	00 00 00 
	stat->st_dev = dev;
  80165d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	53                   	push   %ebx
  801667:	ff 75 f0             	pushl  -0x10(%ebp)
  80166a:	ff 50 14             	call   *0x14(%eax)
  80166d:	89 c2                	mov    %eax,%edx
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	eb 09                	jmp    80167d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801674:	89 c2                	mov    %eax,%edx
  801676:	eb 05                	jmp    80167d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801678:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80167d:	89 d0                	mov    %edx,%eax
  80167f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	56                   	push   %esi
  801688:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801689:	83 ec 08             	sub    $0x8,%esp
  80168c:	6a 00                	push   $0x0
  80168e:	ff 75 08             	pushl  0x8(%ebp)
  801691:	e8 e3 01 00 00       	call   801879 <open>
  801696:	89 c3                	mov    %eax,%ebx
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 1b                	js     8016ba <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80169f:	83 ec 08             	sub    $0x8,%esp
  8016a2:	ff 75 0c             	pushl  0xc(%ebp)
  8016a5:	50                   	push   %eax
  8016a6:	e8 5b ff ff ff       	call   801606 <fstat>
  8016ab:	89 c6                	mov    %eax,%esi
	close(fd);
  8016ad:	89 1c 24             	mov    %ebx,(%esp)
  8016b0:	e8 fd fb ff ff       	call   8012b2 <close>
	return r;
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	89 f0                	mov    %esi,%eax
}
  8016ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bd:	5b                   	pop    %ebx
  8016be:	5e                   	pop    %esi
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    

008016c1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	56                   	push   %esi
  8016c5:	53                   	push   %ebx
  8016c6:	89 c6                	mov    %eax,%esi
  8016c8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016ca:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016d1:	75 12                	jne    8016e5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016d3:	83 ec 0c             	sub    $0xc,%esp
  8016d6:	6a 01                	push   $0x1
  8016d8:	e8 03 09 00 00       	call   801fe0 <ipc_find_env>
  8016dd:	a3 00 40 80 00       	mov    %eax,0x804000
  8016e2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016e5:	6a 07                	push   $0x7
  8016e7:	68 00 50 80 00       	push   $0x805000
  8016ec:	56                   	push   %esi
  8016ed:	ff 35 00 40 80 00    	pushl  0x804000
  8016f3:	e8 86 08 00 00       	call   801f7e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016f8:	83 c4 0c             	add    $0xc,%esp
  8016fb:	6a 00                	push   $0x0
  8016fd:	53                   	push   %ebx
  8016fe:	6a 00                	push   $0x0
  801700:	e8 07 08 00 00       	call   801f0c <ipc_recv>
}
  801705:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801708:	5b                   	pop    %ebx
  801709:	5e                   	pop    %esi
  80170a:	5d                   	pop    %ebp
  80170b:	c3                   	ret    

0080170c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801712:	8b 45 08             	mov    0x8(%ebp),%eax
  801715:	8b 40 0c             	mov    0xc(%eax),%eax
  801718:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80171d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801720:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801725:	ba 00 00 00 00       	mov    $0x0,%edx
  80172a:	b8 02 00 00 00       	mov    $0x2,%eax
  80172f:	e8 8d ff ff ff       	call   8016c1 <fsipc>
}
  801734:	c9                   	leave  
  801735:	c3                   	ret    

00801736 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80173c:	8b 45 08             	mov    0x8(%ebp),%eax
  80173f:	8b 40 0c             	mov    0xc(%eax),%eax
  801742:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801747:	ba 00 00 00 00       	mov    $0x0,%edx
  80174c:	b8 06 00 00 00       	mov    $0x6,%eax
  801751:	e8 6b ff ff ff       	call   8016c1 <fsipc>
}
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	53                   	push   %ebx
  80175c:	83 ec 04             	sub    $0x4,%esp
  80175f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801762:	8b 45 08             	mov    0x8(%ebp),%eax
  801765:	8b 40 0c             	mov    0xc(%eax),%eax
  801768:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	b8 05 00 00 00       	mov    $0x5,%eax
  801777:	e8 45 ff ff ff       	call   8016c1 <fsipc>
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 2c                	js     8017ac <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801780:	83 ec 08             	sub    $0x8,%esp
  801783:	68 00 50 80 00       	push   $0x805000
  801788:	53                   	push   %ebx
  801789:	e8 3c f2 ff ff       	call   8009ca <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80178e:	a1 80 50 80 00       	mov    0x805080,%eax
  801793:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801799:	a1 84 50 80 00       	mov    0x805084,%eax
  80179e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017a4:	83 c4 10             	add    $0x10,%esp
  8017a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	83 ec 0c             	sub    $0xc,%esp
  8017b7:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8017bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c0:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8017c6:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017cb:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017d0:	0f 47 c2             	cmova  %edx,%eax
  8017d3:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8017d8:	50                   	push   %eax
  8017d9:	ff 75 0c             	pushl  0xc(%ebp)
  8017dc:	68 08 50 80 00       	push   $0x805008
  8017e1:	e8 76 f3 ff ff       	call   800b5c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8017e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017eb:	b8 04 00 00 00       	mov    $0x4,%eax
  8017f0:	e8 cc fe ff ff       	call   8016c1 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	56                   	push   %esi
  8017fb:	53                   	push   %ebx
  8017fc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801802:	8b 40 0c             	mov    0xc(%eax),%eax
  801805:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80180a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801810:	ba 00 00 00 00       	mov    $0x0,%edx
  801815:	b8 03 00 00 00       	mov    $0x3,%eax
  80181a:	e8 a2 fe ff ff       	call   8016c1 <fsipc>
  80181f:	89 c3                	mov    %eax,%ebx
  801821:	85 c0                	test   %eax,%eax
  801823:	78 4b                	js     801870 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801825:	39 c6                	cmp    %eax,%esi
  801827:	73 16                	jae    80183f <devfile_read+0x48>
  801829:	68 7c 27 80 00       	push   $0x80277c
  80182e:	68 83 27 80 00       	push   $0x802783
  801833:	6a 7c                	push   $0x7c
  801835:	68 98 27 80 00       	push   $0x802798
  80183a:	e8 2d eb ff ff       	call   80036c <_panic>
	assert(r <= PGSIZE);
  80183f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801844:	7e 16                	jle    80185c <devfile_read+0x65>
  801846:	68 a3 27 80 00       	push   $0x8027a3
  80184b:	68 83 27 80 00       	push   $0x802783
  801850:	6a 7d                	push   $0x7d
  801852:	68 98 27 80 00       	push   $0x802798
  801857:	e8 10 eb ff ff       	call   80036c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80185c:	83 ec 04             	sub    $0x4,%esp
  80185f:	50                   	push   %eax
  801860:	68 00 50 80 00       	push   $0x805000
  801865:	ff 75 0c             	pushl  0xc(%ebp)
  801868:	e8 ef f2 ff ff       	call   800b5c <memmove>
	return r;
  80186d:	83 c4 10             	add    $0x10,%esp
}
  801870:	89 d8                	mov    %ebx,%eax
  801872:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801875:	5b                   	pop    %ebx
  801876:	5e                   	pop    %esi
  801877:	5d                   	pop    %ebp
  801878:	c3                   	ret    

00801879 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	53                   	push   %ebx
  80187d:	83 ec 20             	sub    $0x20,%esp
  801880:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801883:	53                   	push   %ebx
  801884:	e8 08 f1 ff ff       	call   800991 <strlen>
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801891:	7f 67                	jg     8018fa <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801893:	83 ec 0c             	sub    $0xc,%esp
  801896:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801899:	50                   	push   %eax
  80189a:	e8 9a f8 ff ff       	call   801139 <fd_alloc>
  80189f:	83 c4 10             	add    $0x10,%esp
		return r;
  8018a2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	78 57                	js     8018ff <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018a8:	83 ec 08             	sub    $0x8,%esp
  8018ab:	53                   	push   %ebx
  8018ac:	68 00 50 80 00       	push   $0x805000
  8018b1:	e8 14 f1 ff ff       	call   8009ca <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c6:	e8 f6 fd ff ff       	call   8016c1 <fsipc>
  8018cb:	89 c3                	mov    %eax,%ebx
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	79 14                	jns    8018e8 <open+0x6f>
		fd_close(fd, 0);
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	6a 00                	push   $0x0
  8018d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018dc:	e8 50 f9 ff ff       	call   801231 <fd_close>
		return r;
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	89 da                	mov    %ebx,%edx
  8018e6:	eb 17                	jmp    8018ff <open+0x86>
	}

	return fd2num(fd);
  8018e8:	83 ec 0c             	sub    $0xc,%esp
  8018eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ee:	e8 1f f8 ff ff       	call   801112 <fd2num>
  8018f3:	89 c2                	mov    %eax,%edx
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	eb 05                	jmp    8018ff <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018fa:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018ff:	89 d0                	mov    %edx,%eax
  801901:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801904:	c9                   	leave  
  801905:	c3                   	ret    

00801906 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80190c:	ba 00 00 00 00       	mov    $0x0,%edx
  801911:	b8 08 00 00 00       	mov    $0x8,%eax
  801916:	e8 a6 fd ff ff       	call   8016c1 <fsipc>
}
  80191b:	c9                   	leave  
  80191c:	c3                   	ret    

0080191d <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80191d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801921:	7e 37                	jle    80195a <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	53                   	push   %ebx
  801927:	83 ec 08             	sub    $0x8,%esp
  80192a:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80192c:	ff 70 04             	pushl  0x4(%eax)
  80192f:	8d 40 10             	lea    0x10(%eax),%eax
  801932:	50                   	push   %eax
  801933:	ff 33                	pushl  (%ebx)
  801935:	e8 8e fb ff ff       	call   8014c8 <write>
		if (result > 0)
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	85 c0                	test   %eax,%eax
  80193f:	7e 03                	jle    801944 <writebuf+0x27>
			b->result += result;
  801941:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801944:	3b 43 04             	cmp    0x4(%ebx),%eax
  801947:	74 0d                	je     801956 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801949:	85 c0                	test   %eax,%eax
  80194b:	ba 00 00 00 00       	mov    $0x0,%edx
  801950:	0f 4f c2             	cmovg  %edx,%eax
  801953:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801956:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801959:	c9                   	leave  
  80195a:	f3 c3                	repz ret 

0080195c <putch>:

static void
putch(int ch, void *thunk)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	53                   	push   %ebx
  801960:	83 ec 04             	sub    $0x4,%esp
  801963:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801966:	8b 53 04             	mov    0x4(%ebx),%edx
  801969:	8d 42 01             	lea    0x1(%edx),%eax
  80196c:	89 43 04             	mov    %eax,0x4(%ebx)
  80196f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801972:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801976:	3d 00 01 00 00       	cmp    $0x100,%eax
  80197b:	75 0e                	jne    80198b <putch+0x2f>
		writebuf(b);
  80197d:	89 d8                	mov    %ebx,%eax
  80197f:	e8 99 ff ff ff       	call   80191d <writebuf>
		b->idx = 0;
  801984:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80198b:	83 c4 04             	add    $0x4,%esp
  80198e:	5b                   	pop    %ebx
  80198f:	5d                   	pop    %ebp
  801990:	c3                   	ret    

00801991 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80199a:	8b 45 08             	mov    0x8(%ebp),%eax
  80199d:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019a3:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019aa:	00 00 00 
	b.result = 0;
  8019ad:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019b4:	00 00 00 
	b.error = 1;
  8019b7:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019be:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019c1:	ff 75 10             	pushl  0x10(%ebp)
  8019c4:	ff 75 0c             	pushl  0xc(%ebp)
  8019c7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019cd:	50                   	push   %eax
  8019ce:	68 5c 19 80 00       	push   $0x80195c
  8019d3:	e8 a4 eb ff ff       	call   80057c <vprintfmt>
	if (b.idx > 0)
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8019e2:	7e 0b                	jle    8019ef <vfprintf+0x5e>
		writebuf(&b);
  8019e4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019ea:	e8 2e ff ff ff       	call   80191d <writebuf>

	return (b.result ? b.result : b.error);
  8019ef:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8019fe:	c9                   	leave  
  8019ff:	c3                   	ret    

00801a00 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a06:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a09:	50                   	push   %eax
  801a0a:	ff 75 0c             	pushl  0xc(%ebp)
  801a0d:	ff 75 08             	pushl  0x8(%ebp)
  801a10:	e8 7c ff ff ff       	call   801991 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a15:	c9                   	leave  
  801a16:	c3                   	ret    

00801a17 <printf>:

int
printf(const char *fmt, ...)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a1d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a20:	50                   	push   %eax
  801a21:	ff 75 08             	pushl  0x8(%ebp)
  801a24:	6a 01                	push   $0x1
  801a26:	e8 66 ff ff ff       	call   801991 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a2b:	c9                   	leave  
  801a2c:	c3                   	ret    

00801a2d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	56                   	push   %esi
  801a31:	53                   	push   %ebx
  801a32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a35:	83 ec 0c             	sub    $0xc,%esp
  801a38:	ff 75 08             	pushl  0x8(%ebp)
  801a3b:	e8 e2 f6 ff ff       	call   801122 <fd2data>
  801a40:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a42:	83 c4 08             	add    $0x8,%esp
  801a45:	68 af 27 80 00       	push   $0x8027af
  801a4a:	53                   	push   %ebx
  801a4b:	e8 7a ef ff ff       	call   8009ca <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a50:	8b 46 04             	mov    0x4(%esi),%eax
  801a53:	2b 06                	sub    (%esi),%eax
  801a55:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a5b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a62:	00 00 00 
	stat->st_dev = &devpipe;
  801a65:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a6c:	30 80 00 
	return 0;
}
  801a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a77:	5b                   	pop    %ebx
  801a78:	5e                   	pop    %esi
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    

00801a7b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	53                   	push   %ebx
  801a7f:	83 ec 0c             	sub    $0xc,%esp
  801a82:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a85:	53                   	push   %ebx
  801a86:	6a 00                	push   $0x0
  801a88:	e8 c5 f3 ff ff       	call   800e52 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a8d:	89 1c 24             	mov    %ebx,(%esp)
  801a90:	e8 8d f6 ff ff       	call   801122 <fd2data>
  801a95:	83 c4 08             	add    $0x8,%esp
  801a98:	50                   	push   %eax
  801a99:	6a 00                	push   $0x0
  801a9b:	e8 b2 f3 ff ff       	call   800e52 <sys_page_unmap>
}
  801aa0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa3:	c9                   	leave  
  801aa4:	c3                   	ret    

00801aa5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	57                   	push   %edi
  801aa9:	56                   	push   %esi
  801aaa:	53                   	push   %ebx
  801aab:	83 ec 1c             	sub    $0x1c,%esp
  801aae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ab1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ab3:	a1 20 44 80 00       	mov    0x804420,%eax
  801ab8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801abb:	83 ec 0c             	sub    $0xc,%esp
  801abe:	ff 75 e0             	pushl  -0x20(%ebp)
  801ac1:	e8 53 05 00 00       	call   802019 <pageref>
  801ac6:	89 c3                	mov    %eax,%ebx
  801ac8:	89 3c 24             	mov    %edi,(%esp)
  801acb:	e8 49 05 00 00       	call   802019 <pageref>
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	39 c3                	cmp    %eax,%ebx
  801ad5:	0f 94 c1             	sete   %cl
  801ad8:	0f b6 c9             	movzbl %cl,%ecx
  801adb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ade:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801ae4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ae7:	39 ce                	cmp    %ecx,%esi
  801ae9:	74 1b                	je     801b06 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aeb:	39 c3                	cmp    %eax,%ebx
  801aed:	75 c4                	jne    801ab3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aef:	8b 42 58             	mov    0x58(%edx),%eax
  801af2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801af5:	50                   	push   %eax
  801af6:	56                   	push   %esi
  801af7:	68 b6 27 80 00       	push   $0x8027b6
  801afc:	e8 44 e9 ff ff       	call   800445 <cprintf>
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	eb ad                	jmp    801ab3 <_pipeisclosed+0xe>
	}
}
  801b06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0c:	5b                   	pop    %ebx
  801b0d:	5e                   	pop    %esi
  801b0e:	5f                   	pop    %edi
  801b0f:	5d                   	pop    %ebp
  801b10:	c3                   	ret    

00801b11 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	57                   	push   %edi
  801b15:	56                   	push   %esi
  801b16:	53                   	push   %ebx
  801b17:	83 ec 28             	sub    $0x28,%esp
  801b1a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b1d:	56                   	push   %esi
  801b1e:	e8 ff f5 ff ff       	call   801122 <fd2data>
  801b23:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	bf 00 00 00 00       	mov    $0x0,%edi
  801b2d:	eb 4b                	jmp    801b7a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b2f:	89 da                	mov    %ebx,%edx
  801b31:	89 f0                	mov    %esi,%eax
  801b33:	e8 6d ff ff ff       	call   801aa5 <_pipeisclosed>
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	75 48                	jne    801b84 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b3c:	e8 6d f2 ff ff       	call   800dae <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b41:	8b 43 04             	mov    0x4(%ebx),%eax
  801b44:	8b 0b                	mov    (%ebx),%ecx
  801b46:	8d 51 20             	lea    0x20(%ecx),%edx
  801b49:	39 d0                	cmp    %edx,%eax
  801b4b:	73 e2                	jae    801b2f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b50:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b54:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b57:	89 c2                	mov    %eax,%edx
  801b59:	c1 fa 1f             	sar    $0x1f,%edx
  801b5c:	89 d1                	mov    %edx,%ecx
  801b5e:	c1 e9 1b             	shr    $0x1b,%ecx
  801b61:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b64:	83 e2 1f             	and    $0x1f,%edx
  801b67:	29 ca                	sub    %ecx,%edx
  801b69:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b6d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b71:	83 c0 01             	add    $0x1,%eax
  801b74:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b77:	83 c7 01             	add    $0x1,%edi
  801b7a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b7d:	75 c2                	jne    801b41 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b7f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b82:	eb 05                	jmp    801b89 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8c:	5b                   	pop    %ebx
  801b8d:	5e                   	pop    %esi
  801b8e:	5f                   	pop    %edi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	57                   	push   %edi
  801b95:	56                   	push   %esi
  801b96:	53                   	push   %ebx
  801b97:	83 ec 18             	sub    $0x18,%esp
  801b9a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b9d:	57                   	push   %edi
  801b9e:	e8 7f f5 ff ff       	call   801122 <fd2data>
  801ba3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba5:	83 c4 10             	add    $0x10,%esp
  801ba8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bad:	eb 3d                	jmp    801bec <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801baf:	85 db                	test   %ebx,%ebx
  801bb1:	74 04                	je     801bb7 <devpipe_read+0x26>
				return i;
  801bb3:	89 d8                	mov    %ebx,%eax
  801bb5:	eb 44                	jmp    801bfb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bb7:	89 f2                	mov    %esi,%edx
  801bb9:	89 f8                	mov    %edi,%eax
  801bbb:	e8 e5 fe ff ff       	call   801aa5 <_pipeisclosed>
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	75 32                	jne    801bf6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bc4:	e8 e5 f1 ff ff       	call   800dae <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bc9:	8b 06                	mov    (%esi),%eax
  801bcb:	3b 46 04             	cmp    0x4(%esi),%eax
  801bce:	74 df                	je     801baf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bd0:	99                   	cltd   
  801bd1:	c1 ea 1b             	shr    $0x1b,%edx
  801bd4:	01 d0                	add    %edx,%eax
  801bd6:	83 e0 1f             	and    $0x1f,%eax
  801bd9:	29 d0                	sub    %edx,%eax
  801bdb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801be6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be9:	83 c3 01             	add    $0x1,%ebx
  801bec:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bef:	75 d8                	jne    801bc9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bf1:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf4:	eb 05                	jmp    801bfb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bf6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfe:	5b                   	pop    %ebx
  801bff:	5e                   	pop    %esi
  801c00:	5f                   	pop    %edi
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    

00801c03 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	56                   	push   %esi
  801c07:	53                   	push   %ebx
  801c08:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0e:	50                   	push   %eax
  801c0f:	e8 25 f5 ff ff       	call   801139 <fd_alloc>
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	89 c2                	mov    %eax,%edx
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	0f 88 2c 01 00 00    	js     801d4d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c21:	83 ec 04             	sub    $0x4,%esp
  801c24:	68 07 04 00 00       	push   $0x407
  801c29:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2c:	6a 00                	push   $0x0
  801c2e:	e8 9a f1 ff ff       	call   800dcd <sys_page_alloc>
  801c33:	83 c4 10             	add    $0x10,%esp
  801c36:	89 c2                	mov    %eax,%edx
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	0f 88 0d 01 00 00    	js     801d4d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c40:	83 ec 0c             	sub    $0xc,%esp
  801c43:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c46:	50                   	push   %eax
  801c47:	e8 ed f4 ff ff       	call   801139 <fd_alloc>
  801c4c:	89 c3                	mov    %eax,%ebx
  801c4e:	83 c4 10             	add    $0x10,%esp
  801c51:	85 c0                	test   %eax,%eax
  801c53:	0f 88 e2 00 00 00    	js     801d3b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c59:	83 ec 04             	sub    $0x4,%esp
  801c5c:	68 07 04 00 00       	push   $0x407
  801c61:	ff 75 f0             	pushl  -0x10(%ebp)
  801c64:	6a 00                	push   $0x0
  801c66:	e8 62 f1 ff ff       	call   800dcd <sys_page_alloc>
  801c6b:	89 c3                	mov    %eax,%ebx
  801c6d:	83 c4 10             	add    $0x10,%esp
  801c70:	85 c0                	test   %eax,%eax
  801c72:	0f 88 c3 00 00 00    	js     801d3b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c78:	83 ec 0c             	sub    $0xc,%esp
  801c7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7e:	e8 9f f4 ff ff       	call   801122 <fd2data>
  801c83:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c85:	83 c4 0c             	add    $0xc,%esp
  801c88:	68 07 04 00 00       	push   $0x407
  801c8d:	50                   	push   %eax
  801c8e:	6a 00                	push   $0x0
  801c90:	e8 38 f1 ff ff       	call   800dcd <sys_page_alloc>
  801c95:	89 c3                	mov    %eax,%ebx
  801c97:	83 c4 10             	add    $0x10,%esp
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	0f 88 89 00 00 00    	js     801d2b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca2:	83 ec 0c             	sub    $0xc,%esp
  801ca5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca8:	e8 75 f4 ff ff       	call   801122 <fd2data>
  801cad:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cb4:	50                   	push   %eax
  801cb5:	6a 00                	push   $0x0
  801cb7:	56                   	push   %esi
  801cb8:	6a 00                	push   $0x0
  801cba:	e8 51 f1 ff ff       	call   800e10 <sys_page_map>
  801cbf:	89 c3                	mov    %eax,%ebx
  801cc1:	83 c4 20             	add    $0x20,%esp
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	78 55                	js     801d1d <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cc8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cdd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ce3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ceb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cf2:	83 ec 0c             	sub    $0xc,%esp
  801cf5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf8:	e8 15 f4 ff ff       	call   801112 <fd2num>
  801cfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d00:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d02:	83 c4 04             	add    $0x4,%esp
  801d05:	ff 75 f0             	pushl  -0x10(%ebp)
  801d08:	e8 05 f4 ff ff       	call   801112 <fd2num>
  801d0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d10:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d13:	83 c4 10             	add    $0x10,%esp
  801d16:	ba 00 00 00 00       	mov    $0x0,%edx
  801d1b:	eb 30                	jmp    801d4d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d1d:	83 ec 08             	sub    $0x8,%esp
  801d20:	56                   	push   %esi
  801d21:	6a 00                	push   $0x0
  801d23:	e8 2a f1 ff ff       	call   800e52 <sys_page_unmap>
  801d28:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d2b:	83 ec 08             	sub    $0x8,%esp
  801d2e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d31:	6a 00                	push   $0x0
  801d33:	e8 1a f1 ff ff       	call   800e52 <sys_page_unmap>
  801d38:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d3b:	83 ec 08             	sub    $0x8,%esp
  801d3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d41:	6a 00                	push   $0x0
  801d43:	e8 0a f1 ff ff       	call   800e52 <sys_page_unmap>
  801d48:	83 c4 10             	add    $0x10,%esp
  801d4b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d4d:	89 d0                	mov    %edx,%eax
  801d4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d52:	5b                   	pop    %ebx
  801d53:	5e                   	pop    %esi
  801d54:	5d                   	pop    %ebp
  801d55:	c3                   	ret    

00801d56 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5f:	50                   	push   %eax
  801d60:	ff 75 08             	pushl  0x8(%ebp)
  801d63:	e8 20 f4 ff ff       	call   801188 <fd_lookup>
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	78 18                	js     801d87 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d6f:	83 ec 0c             	sub    $0xc,%esp
  801d72:	ff 75 f4             	pushl  -0xc(%ebp)
  801d75:	e8 a8 f3 ff ff       	call   801122 <fd2data>
	return _pipeisclosed(fd, p);
  801d7a:	89 c2                	mov    %eax,%edx
  801d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7f:	e8 21 fd ff ff       	call   801aa5 <_pipeisclosed>
  801d84:	83 c4 10             	add    $0x10,%esp
}
  801d87:	c9                   	leave  
  801d88:	c3                   	ret    

00801d89 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    

00801d93 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d99:	68 ce 27 80 00       	push   $0x8027ce
  801d9e:	ff 75 0c             	pushl  0xc(%ebp)
  801da1:	e8 24 ec ff ff       	call   8009ca <strcpy>
	return 0;
}
  801da6:	b8 00 00 00 00       	mov    $0x0,%eax
  801dab:	c9                   	leave  
  801dac:	c3                   	ret    

00801dad <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	57                   	push   %edi
  801db1:	56                   	push   %esi
  801db2:	53                   	push   %ebx
  801db3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dbe:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc4:	eb 2d                	jmp    801df3 <devcons_write+0x46>
		m = n - tot;
  801dc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dc9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dcb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dce:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dd3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dd6:	83 ec 04             	sub    $0x4,%esp
  801dd9:	53                   	push   %ebx
  801dda:	03 45 0c             	add    0xc(%ebp),%eax
  801ddd:	50                   	push   %eax
  801dde:	57                   	push   %edi
  801ddf:	e8 78 ed ff ff       	call   800b5c <memmove>
		sys_cputs(buf, m);
  801de4:	83 c4 08             	add    $0x8,%esp
  801de7:	53                   	push   %ebx
  801de8:	57                   	push   %edi
  801de9:	e8 23 ef ff ff       	call   800d11 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dee:	01 de                	add    %ebx,%esi
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	89 f0                	mov    %esi,%eax
  801df5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801df8:	72 cc                	jb     801dc6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfd:	5b                   	pop    %ebx
  801dfe:	5e                   	pop    %esi
  801dff:	5f                   	pop    %edi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 08             	sub    $0x8,%esp
  801e08:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e0d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e11:	74 2a                	je     801e3d <devcons_read+0x3b>
  801e13:	eb 05                	jmp    801e1a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e15:	e8 94 ef ff ff       	call   800dae <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e1a:	e8 10 ef ff ff       	call   800d2f <sys_cgetc>
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	74 f2                	je     801e15 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e23:	85 c0                	test   %eax,%eax
  801e25:	78 16                	js     801e3d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e27:	83 f8 04             	cmp    $0x4,%eax
  801e2a:	74 0c                	je     801e38 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e2f:	88 02                	mov    %al,(%edx)
	return 1;
  801e31:	b8 01 00 00 00       	mov    $0x1,%eax
  801e36:	eb 05                	jmp    801e3d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e38:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e3d:	c9                   	leave  
  801e3e:	c3                   	ret    

00801e3f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e45:	8b 45 08             	mov    0x8(%ebp),%eax
  801e48:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e4b:	6a 01                	push   $0x1
  801e4d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e50:	50                   	push   %eax
  801e51:	e8 bb ee ff ff       	call   800d11 <sys_cputs>
}
  801e56:	83 c4 10             	add    $0x10,%esp
  801e59:	c9                   	leave  
  801e5a:	c3                   	ret    

00801e5b <getchar>:

int
getchar(void)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e61:	6a 01                	push   $0x1
  801e63:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e66:	50                   	push   %eax
  801e67:	6a 00                	push   $0x0
  801e69:	e8 80 f5 ff ff       	call   8013ee <read>
	if (r < 0)
  801e6e:	83 c4 10             	add    $0x10,%esp
  801e71:	85 c0                	test   %eax,%eax
  801e73:	78 0f                	js     801e84 <getchar+0x29>
		return r;
	if (r < 1)
  801e75:	85 c0                	test   %eax,%eax
  801e77:	7e 06                	jle    801e7f <getchar+0x24>
		return -E_EOF;
	return c;
  801e79:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e7d:	eb 05                	jmp    801e84 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e7f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e84:	c9                   	leave  
  801e85:	c3                   	ret    

00801e86 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8f:	50                   	push   %eax
  801e90:	ff 75 08             	pushl  0x8(%ebp)
  801e93:	e8 f0 f2 ff ff       	call   801188 <fd_lookup>
  801e98:	83 c4 10             	add    $0x10,%esp
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	78 11                	js     801eb0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea8:	39 10                	cmp    %edx,(%eax)
  801eaa:	0f 94 c0             	sete   %al
  801ead:	0f b6 c0             	movzbl %al,%eax
}
  801eb0:	c9                   	leave  
  801eb1:	c3                   	ret    

00801eb2 <opencons>:

int
opencons(void)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebb:	50                   	push   %eax
  801ebc:	e8 78 f2 ff ff       	call   801139 <fd_alloc>
  801ec1:	83 c4 10             	add    $0x10,%esp
		return r;
  801ec4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ec6:	85 c0                	test   %eax,%eax
  801ec8:	78 3e                	js     801f08 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eca:	83 ec 04             	sub    $0x4,%esp
  801ecd:	68 07 04 00 00       	push   $0x407
  801ed2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed5:	6a 00                	push   $0x0
  801ed7:	e8 f1 ee ff ff       	call   800dcd <sys_page_alloc>
  801edc:	83 c4 10             	add    $0x10,%esp
		return r;
  801edf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	78 23                	js     801f08 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ee5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eee:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801efa:	83 ec 0c             	sub    $0xc,%esp
  801efd:	50                   	push   %eax
  801efe:	e8 0f f2 ff ff       	call   801112 <fd2num>
  801f03:	89 c2                	mov    %eax,%edx
  801f05:	83 c4 10             	add    $0x10,%esp
}
  801f08:	89 d0                	mov    %edx,%eax
  801f0a:	c9                   	leave  
  801f0b:	c3                   	ret    

00801f0c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	56                   	push   %esi
  801f10:	53                   	push   %ebx
  801f11:	8b 75 08             	mov    0x8(%ebp),%esi
  801f14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	75 12                	jne    801f30 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801f1e:	83 ec 0c             	sub    $0xc,%esp
  801f21:	68 00 00 c0 ee       	push   $0xeec00000
  801f26:	e8 52 f0 ff ff       	call   800f7d <sys_ipc_recv>
  801f2b:	83 c4 10             	add    $0x10,%esp
  801f2e:	eb 0c                	jmp    801f3c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801f30:	83 ec 0c             	sub    $0xc,%esp
  801f33:	50                   	push   %eax
  801f34:	e8 44 f0 ff ff       	call   800f7d <sys_ipc_recv>
  801f39:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801f3c:	85 f6                	test   %esi,%esi
  801f3e:	0f 95 c1             	setne  %cl
  801f41:	85 db                	test   %ebx,%ebx
  801f43:	0f 95 c2             	setne  %dl
  801f46:	84 d1                	test   %dl,%cl
  801f48:	74 09                	je     801f53 <ipc_recv+0x47>
  801f4a:	89 c2                	mov    %eax,%edx
  801f4c:	c1 ea 1f             	shr    $0x1f,%edx
  801f4f:	84 d2                	test   %dl,%dl
  801f51:	75 24                	jne    801f77 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801f53:	85 f6                	test   %esi,%esi
  801f55:	74 0a                	je     801f61 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801f57:	a1 20 44 80 00       	mov    0x804420,%eax
  801f5c:	8b 40 74             	mov    0x74(%eax),%eax
  801f5f:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801f61:	85 db                	test   %ebx,%ebx
  801f63:	74 0a                	je     801f6f <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801f65:	a1 20 44 80 00       	mov    0x804420,%eax
  801f6a:	8b 40 78             	mov    0x78(%eax),%eax
  801f6d:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f6f:	a1 20 44 80 00       	mov    0x804420,%eax
  801f74:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5e                   	pop    %esi
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    

00801f7e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 0c             	sub    $0xc,%esp
  801f87:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f8a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801f90:	85 db                	test   %ebx,%ebx
  801f92:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f97:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f9a:	ff 75 14             	pushl  0x14(%ebp)
  801f9d:	53                   	push   %ebx
  801f9e:	56                   	push   %esi
  801f9f:	57                   	push   %edi
  801fa0:	e8 b5 ef ff ff       	call   800f5a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801fa5:	89 c2                	mov    %eax,%edx
  801fa7:	c1 ea 1f             	shr    $0x1f,%edx
  801faa:	83 c4 10             	add    $0x10,%esp
  801fad:	84 d2                	test   %dl,%dl
  801faf:	74 17                	je     801fc8 <ipc_send+0x4a>
  801fb1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fb4:	74 12                	je     801fc8 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801fb6:	50                   	push   %eax
  801fb7:	68 da 27 80 00       	push   $0x8027da
  801fbc:	6a 47                	push   $0x47
  801fbe:	68 e8 27 80 00       	push   $0x8027e8
  801fc3:	e8 a4 e3 ff ff       	call   80036c <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801fc8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fcb:	75 07                	jne    801fd4 <ipc_send+0x56>
			sys_yield();
  801fcd:	e8 dc ed ff ff       	call   800dae <sys_yield>
  801fd2:	eb c6                	jmp    801f9a <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801fd4:	85 c0                	test   %eax,%eax
  801fd6:	75 c2                	jne    801f9a <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801fd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fdb:	5b                   	pop    %ebx
  801fdc:	5e                   	pop    %esi
  801fdd:	5f                   	pop    %edi
  801fde:	5d                   	pop    %ebp
  801fdf:	c3                   	ret    

00801fe0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fe6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801feb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fee:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ff4:	8b 52 50             	mov    0x50(%edx),%edx
  801ff7:	39 ca                	cmp    %ecx,%edx
  801ff9:	75 0d                	jne    802008 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ffb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ffe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802003:	8b 40 48             	mov    0x48(%eax),%eax
  802006:	eb 0f                	jmp    802017 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802008:	83 c0 01             	add    $0x1,%eax
  80200b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802010:	75 d9                	jne    801feb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802012:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802017:	5d                   	pop    %ebp
  802018:	c3                   	ret    

00802019 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802019:	55                   	push   %ebp
  80201a:	89 e5                	mov    %esp,%ebp
  80201c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80201f:	89 d0                	mov    %edx,%eax
  802021:	c1 e8 16             	shr    $0x16,%eax
  802024:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80202b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802030:	f6 c1 01             	test   $0x1,%cl
  802033:	74 1d                	je     802052 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802035:	c1 ea 0c             	shr    $0xc,%edx
  802038:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80203f:	f6 c2 01             	test   $0x1,%dl
  802042:	74 0e                	je     802052 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802044:	c1 ea 0c             	shr    $0xc,%edx
  802047:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80204e:	ef 
  80204f:	0f b7 c0             	movzwl %ax,%eax
}
  802052:	5d                   	pop    %ebp
  802053:	c3                   	ret    
  802054:	66 90                	xchg   %ax,%ax
  802056:	66 90                	xchg   %ax,%ax
  802058:	66 90                	xchg   %ax,%ax
  80205a:	66 90                	xchg   %ax,%ax
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__udivdi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80206b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80206f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 f6                	test   %esi,%esi
  802079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80207d:	89 ca                	mov    %ecx,%edx
  80207f:	89 f8                	mov    %edi,%eax
  802081:	75 3d                	jne    8020c0 <__udivdi3+0x60>
  802083:	39 cf                	cmp    %ecx,%edi
  802085:	0f 87 c5 00 00 00    	ja     802150 <__udivdi3+0xf0>
  80208b:	85 ff                	test   %edi,%edi
  80208d:	89 fd                	mov    %edi,%ebp
  80208f:	75 0b                	jne    80209c <__udivdi3+0x3c>
  802091:	b8 01 00 00 00       	mov    $0x1,%eax
  802096:	31 d2                	xor    %edx,%edx
  802098:	f7 f7                	div    %edi
  80209a:	89 c5                	mov    %eax,%ebp
  80209c:	89 c8                	mov    %ecx,%eax
  80209e:	31 d2                	xor    %edx,%edx
  8020a0:	f7 f5                	div    %ebp
  8020a2:	89 c1                	mov    %eax,%ecx
  8020a4:	89 d8                	mov    %ebx,%eax
  8020a6:	89 cf                	mov    %ecx,%edi
  8020a8:	f7 f5                	div    %ebp
  8020aa:	89 c3                	mov    %eax,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	39 ce                	cmp    %ecx,%esi
  8020c2:	77 74                	ja     802138 <__udivdi3+0xd8>
  8020c4:	0f bd fe             	bsr    %esi,%edi
  8020c7:	83 f7 1f             	xor    $0x1f,%edi
  8020ca:	0f 84 98 00 00 00    	je     802168 <__udivdi3+0x108>
  8020d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	89 c5                	mov    %eax,%ebp
  8020d9:	29 fb                	sub    %edi,%ebx
  8020db:	d3 e6                	shl    %cl,%esi
  8020dd:	89 d9                	mov    %ebx,%ecx
  8020df:	d3 ed                	shr    %cl,%ebp
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	d3 e0                	shl    %cl,%eax
  8020e5:	09 ee                	or     %ebp,%esi
  8020e7:	89 d9                	mov    %ebx,%ecx
  8020e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ed:	89 d5                	mov    %edx,%ebp
  8020ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020f3:	d3 ed                	shr    %cl,%ebp
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e2                	shl    %cl,%edx
  8020f9:	89 d9                	mov    %ebx,%ecx
  8020fb:	d3 e8                	shr    %cl,%eax
  8020fd:	09 c2                	or     %eax,%edx
  8020ff:	89 d0                	mov    %edx,%eax
  802101:	89 ea                	mov    %ebp,%edx
  802103:	f7 f6                	div    %esi
  802105:	89 d5                	mov    %edx,%ebp
  802107:	89 c3                	mov    %eax,%ebx
  802109:	f7 64 24 0c          	mull   0xc(%esp)
  80210d:	39 d5                	cmp    %edx,%ebp
  80210f:	72 10                	jb     802121 <__udivdi3+0xc1>
  802111:	8b 74 24 08          	mov    0x8(%esp),%esi
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e6                	shl    %cl,%esi
  802119:	39 c6                	cmp    %eax,%esi
  80211b:	73 07                	jae    802124 <__udivdi3+0xc4>
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	75 03                	jne    802124 <__udivdi3+0xc4>
  802121:	83 eb 01             	sub    $0x1,%ebx
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 d8                	mov    %ebx,%eax
  802128:	89 fa                	mov    %edi,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	31 ff                	xor    %edi,%edi
  80213a:	31 db                	xor    %ebx,%ebx
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	89 fa                	mov    %edi,%edx
  802140:	83 c4 1c             	add    $0x1c,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	90                   	nop
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	89 d8                	mov    %ebx,%eax
  802152:	f7 f7                	div    %edi
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 c3                	mov    %eax,%ebx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 fa                	mov    %edi,%edx
  80215c:	83 c4 1c             	add    $0x1c,%esp
  80215f:	5b                   	pop    %ebx
  802160:	5e                   	pop    %esi
  802161:	5f                   	pop    %edi
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    
  802164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802168:	39 ce                	cmp    %ecx,%esi
  80216a:	72 0c                	jb     802178 <__udivdi3+0x118>
  80216c:	31 db                	xor    %ebx,%ebx
  80216e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802172:	0f 87 34 ff ff ff    	ja     8020ac <__udivdi3+0x4c>
  802178:	bb 01 00 00 00       	mov    $0x1,%ebx
  80217d:	e9 2a ff ff ff       	jmp    8020ac <__udivdi3+0x4c>
  802182:	66 90                	xchg   %ax,%ax
  802184:	66 90                	xchg   %ax,%ax
  802186:	66 90                	xchg   %ax,%ax
  802188:	66 90                	xchg   %ax,%ax
  80218a:	66 90                	xchg   %ax,%ax
  80218c:	66 90                	xchg   %ax,%ax
  80218e:	66 90                	xchg   %ax,%ax

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
  802197:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80219b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80219f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a7:	85 d2                	test   %edx,%edx
  8021a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021b1:	89 f3                	mov    %esi,%ebx
  8021b3:	89 3c 24             	mov    %edi,(%esp)
  8021b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ba:	75 1c                	jne    8021d8 <__umoddi3+0x48>
  8021bc:	39 f7                	cmp    %esi,%edi
  8021be:	76 50                	jbe    802210 <__umoddi3+0x80>
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	f7 f7                	div    %edi
  8021c6:	89 d0                	mov    %edx,%eax
  8021c8:	31 d2                	xor    %edx,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	89 d0                	mov    %edx,%eax
  8021dc:	77 52                	ja     802230 <__umoddi3+0xa0>
  8021de:	0f bd ea             	bsr    %edx,%ebp
  8021e1:	83 f5 1f             	xor    $0x1f,%ebp
  8021e4:	75 5a                	jne    802240 <__umoddi3+0xb0>
  8021e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ea:	0f 82 e0 00 00 00    	jb     8022d0 <__umoddi3+0x140>
  8021f0:	39 0c 24             	cmp    %ecx,(%esp)
  8021f3:	0f 86 d7 00 00 00    	jbe    8022d0 <__umoddi3+0x140>
  8021f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802201:	83 c4 1c             	add    $0x1c,%esp
  802204:	5b                   	pop    %ebx
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	85 ff                	test   %edi,%edi
  802212:	89 fd                	mov    %edi,%ebp
  802214:	75 0b                	jne    802221 <__umoddi3+0x91>
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f7                	div    %edi
  80221f:	89 c5                	mov    %eax,%ebp
  802221:	89 f0                	mov    %esi,%eax
  802223:	31 d2                	xor    %edx,%edx
  802225:	f7 f5                	div    %ebp
  802227:	89 c8                	mov    %ecx,%eax
  802229:	f7 f5                	div    %ebp
  80222b:	89 d0                	mov    %edx,%eax
  80222d:	eb 99                	jmp    8021c8 <__umoddi3+0x38>
  80222f:	90                   	nop
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	83 c4 1c             	add    $0x1c,%esp
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	5f                   	pop    %edi
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	8b 34 24             	mov    (%esp),%esi
  802243:	bf 20 00 00 00       	mov    $0x20,%edi
  802248:	89 e9                	mov    %ebp,%ecx
  80224a:	29 ef                	sub    %ebp,%edi
  80224c:	d3 e0                	shl    %cl,%eax
  80224e:	89 f9                	mov    %edi,%ecx
  802250:	89 f2                	mov    %esi,%edx
  802252:	d3 ea                	shr    %cl,%edx
  802254:	89 e9                	mov    %ebp,%ecx
  802256:	09 c2                	or     %eax,%edx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 14 24             	mov    %edx,(%esp)
  80225d:	89 f2                	mov    %esi,%edx
  80225f:	d3 e2                	shl    %cl,%edx
  802261:	89 f9                	mov    %edi,%ecx
  802263:	89 54 24 04          	mov    %edx,0x4(%esp)
  802267:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	89 e9                	mov    %ebp,%ecx
  80226f:	89 c6                	mov    %eax,%esi
  802271:	d3 e3                	shl    %cl,%ebx
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 d0                	mov    %edx,%eax
  802277:	d3 e8                	shr    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	09 d8                	or     %ebx,%eax
  80227d:	89 d3                	mov    %edx,%ebx
  80227f:	89 f2                	mov    %esi,%edx
  802281:	f7 34 24             	divl   (%esp)
  802284:	89 d6                	mov    %edx,%esi
  802286:	d3 e3                	shl    %cl,%ebx
  802288:	f7 64 24 04          	mull   0x4(%esp)
  80228c:	39 d6                	cmp    %edx,%esi
  80228e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802292:	89 d1                	mov    %edx,%ecx
  802294:	89 c3                	mov    %eax,%ebx
  802296:	72 08                	jb     8022a0 <__umoddi3+0x110>
  802298:	75 11                	jne    8022ab <__umoddi3+0x11b>
  80229a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80229e:	73 0b                	jae    8022ab <__umoddi3+0x11b>
  8022a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022a4:	1b 14 24             	sbb    (%esp),%edx
  8022a7:	89 d1                	mov    %edx,%ecx
  8022a9:	89 c3                	mov    %eax,%ebx
  8022ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022af:	29 da                	sub    %ebx,%edx
  8022b1:	19 ce                	sbb    %ecx,%esi
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 f0                	mov    %esi,%eax
  8022b7:	d3 e0                	shl    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	d3 ea                	shr    %cl,%edx
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	d3 ee                	shr    %cl,%esi
  8022c1:	09 d0                	or     %edx,%eax
  8022c3:	89 f2                	mov    %esi,%edx
  8022c5:	83 c4 1c             	add    $0x1c,%esp
  8022c8:	5b                   	pop    %ebx
  8022c9:	5e                   	pop    %esi
  8022ca:	5f                   	pop    %edi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    
  8022cd:	8d 76 00             	lea    0x0(%esi),%esi
  8022d0:	29 f9                	sub    %edi,%ecx
  8022d2:	19 d6                	sbb    %edx,%esi
  8022d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022dc:	e9 18 ff ff ff       	jmp    8021f9 <__umoddi3+0x69>
