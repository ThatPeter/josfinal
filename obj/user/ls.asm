
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
  80005a:	68 02 27 80 00       	push   $0x802702
  80005f:	e8 14 1d 00 00       	call   801d78 <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 68 27 80 00       	mov    $0x802768,%eax
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
  800086:	ba 68 27 80 00       	mov    $0x802768,%edx
  80008b:	b8 00 27 80 00       	mov    $0x802700,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 0b 27 80 00       	push   $0x80270b
  80009d:	e8 d6 1c 00 00       	call   801d78 <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 11 2c 80 00       	push   $0x802c11
  8000b0:	e8 c3 1c 00 00       	call   801d78 <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 00 27 80 00       	push   $0x802700
  8000cf:	e8 a4 1c 00 00       	call   801d78 <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 67 27 80 00       	push   $0x802767
  8000df:	e8 94 1c 00 00       	call   801d78 <printf>
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
  800100:	e8 d5 1a 00 00       	call   801bda <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 10 27 80 00       	push   $0x802710
  800118:	6a 1d                	push   $0x1d
  80011a:	68 1c 27 80 00       	push   $0x80271c
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
  80015f:	e8 76 16 00 00       	call   8017da <readn>
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
  800173:	68 26 27 80 00       	push   $0x802726
  800178:	6a 22                	push   $0x22
  80017a:	68 1c 27 80 00       	push   $0x80271c
  80017f:	e8 c3 01 00 00       	call   800347 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 6c 27 80 00       	push   $0x80276c
  800192:	6a 24                	push   $0x24
  800194:	68 1c 27 80 00       	push   $0x80271c
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
  8001bb:	e8 25 18 00 00       	call   8019e5 <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 41 27 80 00       	push   $0x802741
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 1c 27 80 00       	push   $0x80271c
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
  800220:	68 4d 27 80 00       	push   $0x80274d
  800225:	e8 4e 1b 00 00       	call   801d78 <printf>
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
  800248:	e8 c6 10 00 00       	call   801313 <argstart>
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
  800277:	e8 c7 10 00 00       	call   801343 <argnext>
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
  800291:	68 68 27 80 00       	push   $0x802768
  800296:	68 00 27 80 00       	push   $0x802700
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
  8002d9:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  800333:	e8 fd 12 00 00       	call   801635 <close_all>
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
  800365:	68 98 27 80 00       	push   $0x802798
  80036a:	e8 b1 00 00 00       	call   800420 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80036f:	83 c4 18             	add    $0x18,%esp
  800372:	53                   	push   %ebx
  800373:	ff 75 10             	pushl  0x10(%ebp)
  800376:	e8 54 00 00 00       	call   8003cf <vcprintf>
	cprintf("\n");
  80037b:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
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
  800483:	e8 e8 1f 00 00       	call   802470 <__udivdi3>
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
  8004c6:	e8 d5 20 00 00       	call   8025a0 <__umoddi3>
  8004cb:	83 c4 14             	add    $0x14,%esp
  8004ce:	0f be 80 bb 27 80 00 	movsbl 0x8027bb(%eax),%eax
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
  8005ca:	ff 24 85 00 29 80 00 	jmp    *0x802900(,%eax,4)
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
  80068e:	8b 14 85 60 2a 80 00 	mov    0x802a60(,%eax,4),%edx
  800695:	85 d2                	test   %edx,%edx
  800697:	75 18                	jne    8006b1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800699:	50                   	push   %eax
  80069a:	68 d3 27 80 00       	push   $0x8027d3
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
  8006b2:	68 11 2c 80 00       	push   $0x802c11
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
  8006d6:	b8 cc 27 80 00       	mov    $0x8027cc,%eax
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
  800d51:	68 bf 2a 80 00       	push   $0x802abf
  800d56:	6a 23                	push   $0x23
  800d58:	68 dc 2a 80 00       	push   $0x802adc
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
  800dd2:	68 bf 2a 80 00       	push   $0x802abf
  800dd7:	6a 23                	push   $0x23
  800dd9:	68 dc 2a 80 00       	push   $0x802adc
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
  800e14:	68 bf 2a 80 00       	push   $0x802abf
  800e19:	6a 23                	push   $0x23
  800e1b:	68 dc 2a 80 00       	push   $0x802adc
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
  800e56:	68 bf 2a 80 00       	push   $0x802abf
  800e5b:	6a 23                	push   $0x23
  800e5d:	68 dc 2a 80 00       	push   $0x802adc
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
  800e98:	68 bf 2a 80 00       	push   $0x802abf
  800e9d:	6a 23                	push   $0x23
  800e9f:	68 dc 2a 80 00       	push   $0x802adc
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
  800eda:	68 bf 2a 80 00       	push   $0x802abf
  800edf:	6a 23                	push   $0x23
  800ee1:	68 dc 2a 80 00       	push   $0x802adc
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
  800f1c:	68 bf 2a 80 00       	push   $0x802abf
  800f21:	6a 23                	push   $0x23
  800f23:	68 dc 2a 80 00       	push   $0x802adc
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
  800f80:	68 bf 2a 80 00       	push   $0x802abf
  800f85:	6a 23                	push   $0x23
  800f87:	68 dc 2a 80 00       	push   $0x802adc
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
  80101f:	68 ea 2a 80 00       	push   $0x802aea
  801024:	6a 1e                	push   $0x1e
  801026:	68 fa 2a 80 00       	push   $0x802afa
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
  801049:	68 05 2b 80 00       	push   $0x802b05
  80104e:	6a 2c                	push   $0x2c
  801050:	68 fa 2a 80 00       	push   $0x802afa
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
  801091:	68 05 2b 80 00       	push   $0x802b05
  801096:	6a 33                	push   $0x33
  801098:	68 fa 2a 80 00       	push   $0x802afa
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
  8010b9:	68 05 2b 80 00       	push   $0x802b05
  8010be:	6a 37                	push   $0x37
  8010c0:	68 fa 2a 80 00       	push   $0x802afa
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
  8010dd:	e8 94 11 00 00       	call   802276 <set_pgfault_handler>
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
  8010f6:	68 1e 2b 80 00       	push   $0x802b1e
  8010fb:	68 84 00 00 00       	push   $0x84
  801100:	68 fa 2a 80 00       	push   $0x802afa
  801105:	e8 3d f2 ff ff       	call   800347 <_panic>
  80110a:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  80110c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801110:	75 24                	jne    801136 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  801112:	e8 53 fc ff ff       	call   800d6a <sys_getenvid>
  801117:	25 ff 03 00 00       	and    $0x3ff,%eax
  80111c:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  8011b2:	68 2c 2b 80 00       	push   $0x802b2c
  8011b7:	6a 54                	push   $0x54
  8011b9:	68 fa 2a 80 00       	push   $0x802afa
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
  8011f7:	68 2c 2b 80 00       	push   $0x802b2c
  8011fc:	6a 5b                	push   $0x5b
  8011fe:	68 fa 2a 80 00       	push   $0x802afa
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
  801225:	68 2c 2b 80 00       	push   $0x802b2c
  80122a:	6a 5f                	push   $0x5f
  80122c:	68 fa 2a 80 00       	push   $0x802afa
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
  80124f:	68 2c 2b 80 00       	push   $0x802b2c
  801254:	6a 64                	push   $0x64
  801256:	68 fa 2a 80 00       	push   $0x802afa
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
  801277:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	56                   	push   %esi
  8012b0:	53                   	push   %ebx
  8012b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8012b4:	89 1d 24 44 80 00    	mov    %ebx,0x804424
	cprintf("in fork.c thread create. func: %x\n", func);
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	53                   	push   %ebx
  8012be:	68 44 2b 80 00       	push   $0x802b44
  8012c3:	e8 58 f1 ff ff       	call   800420 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8012c8:	c7 04 24 0d 03 80 00 	movl   $0x80030d,(%esp)
  8012cf:	e8 c5 fc ff ff       	call   800f99 <sys_thread_create>
  8012d4:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8012d6:	83 c4 08             	add    $0x8,%esp
  8012d9:	53                   	push   %ebx
  8012da:	68 44 2b 80 00       	push   $0x802b44
  8012df:	e8 3c f1 ff ff       	call   800420 <cprintf>
	return id;
}
  8012e4:	89 f0                	mov    %esi,%eax
  8012e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e9:	5b                   	pop    %ebx
  8012ea:	5e                   	pop    %esi
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8012f3:	ff 75 08             	pushl  0x8(%ebp)
  8012f6:	e8 be fc ff ff       	call   800fb9 <sys_thread_free>
}
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  801306:	ff 75 08             	pushl  0x8(%ebp)
  801309:	e8 cb fc ff ff       	call   800fd9 <sys_thread_join>
}
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	c9                   	leave  
  801312:	c3                   	ret    

00801313 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	8b 55 08             	mov    0x8(%ebp),%edx
  801319:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131c:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  80131f:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801321:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801324:	83 3a 01             	cmpl   $0x1,(%edx)
  801327:	7e 09                	jle    801332 <argstart+0x1f>
  801329:	ba 68 27 80 00       	mov    $0x802768,%edx
  80132e:	85 c9                	test   %ecx,%ecx
  801330:	75 05                	jne    801337 <argstart+0x24>
  801332:	ba 00 00 00 00       	mov    $0x0,%edx
  801337:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  80133a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    

00801343 <argnext>:

int
argnext(struct Argstate *args)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	53                   	push   %ebx
  801347:	83 ec 04             	sub    $0x4,%esp
  80134a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  80134d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801354:	8b 43 08             	mov    0x8(%ebx),%eax
  801357:	85 c0                	test   %eax,%eax
  801359:	74 6f                	je     8013ca <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  80135b:	80 38 00             	cmpb   $0x0,(%eax)
  80135e:	75 4e                	jne    8013ae <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801360:	8b 0b                	mov    (%ebx),%ecx
  801362:	83 39 01             	cmpl   $0x1,(%ecx)
  801365:	74 55                	je     8013bc <argnext+0x79>
		    || args->argv[1][0] != '-'
  801367:	8b 53 04             	mov    0x4(%ebx),%edx
  80136a:	8b 42 04             	mov    0x4(%edx),%eax
  80136d:	80 38 2d             	cmpb   $0x2d,(%eax)
  801370:	75 4a                	jne    8013bc <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801372:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801376:	74 44                	je     8013bc <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801378:	83 c0 01             	add    $0x1,%eax
  80137b:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80137e:	83 ec 04             	sub    $0x4,%esp
  801381:	8b 01                	mov    (%ecx),%eax
  801383:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80138a:	50                   	push   %eax
  80138b:	8d 42 08             	lea    0x8(%edx),%eax
  80138e:	50                   	push   %eax
  80138f:	83 c2 04             	add    $0x4,%edx
  801392:	52                   	push   %edx
  801393:	e8 9f f7 ff ff       	call   800b37 <memmove>
		(*args->argc)--;
  801398:	8b 03                	mov    (%ebx),%eax
  80139a:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  80139d:	8b 43 08             	mov    0x8(%ebx),%eax
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	80 38 2d             	cmpb   $0x2d,(%eax)
  8013a6:	75 06                	jne    8013ae <argnext+0x6b>
  8013a8:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8013ac:	74 0e                	je     8013bc <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  8013ae:	8b 53 08             	mov    0x8(%ebx),%edx
  8013b1:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  8013b4:	83 c2 01             	add    $0x1,%edx
  8013b7:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  8013ba:	eb 13                	jmp    8013cf <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  8013bc:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8013c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8013c8:	eb 05                	jmp    8013cf <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  8013ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8013cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d2:	c9                   	leave  
  8013d3:	c3                   	ret    

008013d4 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	53                   	push   %ebx
  8013d8:	83 ec 04             	sub    $0x4,%esp
  8013db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8013de:	8b 43 08             	mov    0x8(%ebx),%eax
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	74 58                	je     80143d <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  8013e5:	80 38 00             	cmpb   $0x0,(%eax)
  8013e8:	74 0c                	je     8013f6 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8013ea:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8013ed:	c7 43 08 68 27 80 00 	movl   $0x802768,0x8(%ebx)
  8013f4:	eb 42                	jmp    801438 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  8013f6:	8b 13                	mov    (%ebx),%edx
  8013f8:	83 3a 01             	cmpl   $0x1,(%edx)
  8013fb:	7e 2d                	jle    80142a <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  8013fd:	8b 43 04             	mov    0x4(%ebx),%eax
  801400:	8b 48 04             	mov    0x4(%eax),%ecx
  801403:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801406:	83 ec 04             	sub    $0x4,%esp
  801409:	8b 12                	mov    (%edx),%edx
  80140b:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801412:	52                   	push   %edx
  801413:	8d 50 08             	lea    0x8(%eax),%edx
  801416:	52                   	push   %edx
  801417:	83 c0 04             	add    $0x4,%eax
  80141a:	50                   	push   %eax
  80141b:	e8 17 f7 ff ff       	call   800b37 <memmove>
		(*args->argc)--;
  801420:	8b 03                	mov    (%ebx),%eax
  801422:	83 28 01             	subl   $0x1,(%eax)
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	eb 0e                	jmp    801438 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  80142a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801431:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801438:	8b 43 0c             	mov    0xc(%ebx),%eax
  80143b:	eb 05                	jmp    801442 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  80143d:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801442:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801445:	c9                   	leave  
  801446:	c3                   	ret    

00801447 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801447:	55                   	push   %ebp
  801448:	89 e5                	mov    %esp,%ebp
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801450:	8b 51 0c             	mov    0xc(%ecx),%edx
  801453:	89 d0                	mov    %edx,%eax
  801455:	85 d2                	test   %edx,%edx
  801457:	75 0c                	jne    801465 <argvalue+0x1e>
  801459:	83 ec 0c             	sub    $0xc,%esp
  80145c:	51                   	push   %ecx
  80145d:	e8 72 ff ff ff       	call   8013d4 <argnextvalue>
  801462:	83 c4 10             	add    $0x10,%esp
}
  801465:	c9                   	leave  
  801466:	c3                   	ret    

00801467 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80146a:	8b 45 08             	mov    0x8(%ebp),%eax
  80146d:	05 00 00 00 30       	add    $0x30000000,%eax
  801472:	c1 e8 0c             	shr    $0xc,%eax
}
  801475:	5d                   	pop    %ebp
  801476:	c3                   	ret    

00801477 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80147a:	8b 45 08             	mov    0x8(%ebp),%eax
  80147d:	05 00 00 00 30       	add    $0x30000000,%eax
  801482:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801487:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80148c:	5d                   	pop    %ebp
  80148d:	c3                   	ret    

0080148e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801494:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801499:	89 c2                	mov    %eax,%edx
  80149b:	c1 ea 16             	shr    $0x16,%edx
  80149e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a5:	f6 c2 01             	test   $0x1,%dl
  8014a8:	74 11                	je     8014bb <fd_alloc+0x2d>
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	c1 ea 0c             	shr    $0xc,%edx
  8014af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b6:	f6 c2 01             	test   $0x1,%dl
  8014b9:	75 09                	jne    8014c4 <fd_alloc+0x36>
			*fd_store = fd;
  8014bb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c2:	eb 17                	jmp    8014db <fd_alloc+0x4d>
  8014c4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014c9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014ce:	75 c9                	jne    801499 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014d0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014d6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    

008014dd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014e3:	83 f8 1f             	cmp    $0x1f,%eax
  8014e6:	77 36                	ja     80151e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014e8:	c1 e0 0c             	shl    $0xc,%eax
  8014eb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014f0:	89 c2                	mov    %eax,%edx
  8014f2:	c1 ea 16             	shr    $0x16,%edx
  8014f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014fc:	f6 c2 01             	test   $0x1,%dl
  8014ff:	74 24                	je     801525 <fd_lookup+0x48>
  801501:	89 c2                	mov    %eax,%edx
  801503:	c1 ea 0c             	shr    $0xc,%edx
  801506:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80150d:	f6 c2 01             	test   $0x1,%dl
  801510:	74 1a                	je     80152c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801512:	8b 55 0c             	mov    0xc(%ebp),%edx
  801515:	89 02                	mov    %eax,(%edx)
	return 0;
  801517:	b8 00 00 00 00       	mov    $0x0,%eax
  80151c:	eb 13                	jmp    801531 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80151e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801523:	eb 0c                	jmp    801531 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801525:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152a:	eb 05                	jmp    801531 <fd_lookup+0x54>
  80152c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801531:	5d                   	pop    %ebp
  801532:	c3                   	ret    

00801533 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153c:	ba e8 2b 80 00       	mov    $0x802be8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801541:	eb 13                	jmp    801556 <dev_lookup+0x23>
  801543:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801546:	39 08                	cmp    %ecx,(%eax)
  801548:	75 0c                	jne    801556 <dev_lookup+0x23>
			*dev = devtab[i];
  80154a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80154f:	b8 00 00 00 00       	mov    $0x0,%eax
  801554:	eb 31                	jmp    801587 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801556:	8b 02                	mov    (%edx),%eax
  801558:	85 c0                	test   %eax,%eax
  80155a:	75 e7                	jne    801543 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80155c:	a1 20 44 80 00       	mov    0x804420,%eax
  801561:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	51                   	push   %ecx
  80156b:	50                   	push   %eax
  80156c:	68 68 2b 80 00       	push   $0x802b68
  801571:	e8 aa ee ff ff       	call   800420 <cprintf>
	*dev = 0;
  801576:	8b 45 0c             	mov    0xc(%ebp),%eax
  801579:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801587:	c9                   	leave  
  801588:	c3                   	ret    

00801589 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	56                   	push   %esi
  80158d:	53                   	push   %ebx
  80158e:	83 ec 10             	sub    $0x10,%esp
  801591:	8b 75 08             	mov    0x8(%ebp),%esi
  801594:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801597:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159a:	50                   	push   %eax
  80159b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015a1:	c1 e8 0c             	shr    $0xc,%eax
  8015a4:	50                   	push   %eax
  8015a5:	e8 33 ff ff ff       	call   8014dd <fd_lookup>
  8015aa:	83 c4 08             	add    $0x8,%esp
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	78 05                	js     8015b6 <fd_close+0x2d>
	    || fd != fd2)
  8015b1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015b4:	74 0c                	je     8015c2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015b6:	84 db                	test   %bl,%bl
  8015b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bd:	0f 44 c2             	cmove  %edx,%eax
  8015c0:	eb 41                	jmp    801603 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015c2:	83 ec 08             	sub    $0x8,%esp
  8015c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	ff 36                	pushl  (%esi)
  8015cb:	e8 63 ff ff ff       	call   801533 <dev_lookup>
  8015d0:	89 c3                	mov    %eax,%ebx
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 1a                	js     8015f3 <fd_close+0x6a>
		if (dev->dev_close)
  8015d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015df:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	74 0b                	je     8015f3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015e8:	83 ec 0c             	sub    $0xc,%esp
  8015eb:	56                   	push   %esi
  8015ec:	ff d0                	call   *%eax
  8015ee:	89 c3                	mov    %eax,%ebx
  8015f0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	56                   	push   %esi
  8015f7:	6a 00                	push   $0x0
  8015f9:	e8 2f f8 ff ff       	call   800e2d <sys_page_unmap>
	return r;
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	89 d8                	mov    %ebx,%eax
}
  801603:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801610:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801613:	50                   	push   %eax
  801614:	ff 75 08             	pushl  0x8(%ebp)
  801617:	e8 c1 fe ff ff       	call   8014dd <fd_lookup>
  80161c:	83 c4 08             	add    $0x8,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 10                	js     801633 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	6a 01                	push   $0x1
  801628:	ff 75 f4             	pushl  -0xc(%ebp)
  80162b:	e8 59 ff ff ff       	call   801589 <fd_close>
  801630:	83 c4 10             	add    $0x10,%esp
}
  801633:	c9                   	leave  
  801634:	c3                   	ret    

00801635 <close_all>:

void
close_all(void)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	53                   	push   %ebx
  801639:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80163c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801641:	83 ec 0c             	sub    $0xc,%esp
  801644:	53                   	push   %ebx
  801645:	e8 c0 ff ff ff       	call   80160a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80164a:	83 c3 01             	add    $0x1,%ebx
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	83 fb 20             	cmp    $0x20,%ebx
  801653:	75 ec                	jne    801641 <close_all+0xc>
		close(i);
}
  801655:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	57                   	push   %edi
  80165e:	56                   	push   %esi
  80165f:	53                   	push   %ebx
  801660:	83 ec 2c             	sub    $0x2c,%esp
  801663:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801666:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801669:	50                   	push   %eax
  80166a:	ff 75 08             	pushl  0x8(%ebp)
  80166d:	e8 6b fe ff ff       	call   8014dd <fd_lookup>
  801672:	83 c4 08             	add    $0x8,%esp
  801675:	85 c0                	test   %eax,%eax
  801677:	0f 88 c1 00 00 00    	js     80173e <dup+0xe4>
		return r;
	close(newfdnum);
  80167d:	83 ec 0c             	sub    $0xc,%esp
  801680:	56                   	push   %esi
  801681:	e8 84 ff ff ff       	call   80160a <close>

	newfd = INDEX2FD(newfdnum);
  801686:	89 f3                	mov    %esi,%ebx
  801688:	c1 e3 0c             	shl    $0xc,%ebx
  80168b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801691:	83 c4 04             	add    $0x4,%esp
  801694:	ff 75 e4             	pushl  -0x1c(%ebp)
  801697:	e8 db fd ff ff       	call   801477 <fd2data>
  80169c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80169e:	89 1c 24             	mov    %ebx,(%esp)
  8016a1:	e8 d1 fd ff ff       	call   801477 <fd2data>
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016ac:	89 f8                	mov    %edi,%eax
  8016ae:	c1 e8 16             	shr    $0x16,%eax
  8016b1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016b8:	a8 01                	test   $0x1,%al
  8016ba:	74 37                	je     8016f3 <dup+0x99>
  8016bc:	89 f8                	mov    %edi,%eax
  8016be:	c1 e8 0c             	shr    $0xc,%eax
  8016c1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016c8:	f6 c2 01             	test   $0x1,%dl
  8016cb:	74 26                	je     8016f3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016d4:	83 ec 0c             	sub    $0xc,%esp
  8016d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8016dc:	50                   	push   %eax
  8016dd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016e0:	6a 00                	push   $0x0
  8016e2:	57                   	push   %edi
  8016e3:	6a 00                	push   $0x0
  8016e5:	e8 01 f7 ff ff       	call   800deb <sys_page_map>
  8016ea:	89 c7                	mov    %eax,%edi
  8016ec:	83 c4 20             	add    $0x20,%esp
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	78 2e                	js     801721 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016f6:	89 d0                	mov    %edx,%eax
  8016f8:	c1 e8 0c             	shr    $0xc,%eax
  8016fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801702:	83 ec 0c             	sub    $0xc,%esp
  801705:	25 07 0e 00 00       	and    $0xe07,%eax
  80170a:	50                   	push   %eax
  80170b:	53                   	push   %ebx
  80170c:	6a 00                	push   $0x0
  80170e:	52                   	push   %edx
  80170f:	6a 00                	push   $0x0
  801711:	e8 d5 f6 ff ff       	call   800deb <sys_page_map>
  801716:	89 c7                	mov    %eax,%edi
  801718:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80171b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80171d:	85 ff                	test   %edi,%edi
  80171f:	79 1d                	jns    80173e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801721:	83 ec 08             	sub    $0x8,%esp
  801724:	53                   	push   %ebx
  801725:	6a 00                	push   $0x0
  801727:	e8 01 f7 ff ff       	call   800e2d <sys_page_unmap>
	sys_page_unmap(0, nva);
  80172c:	83 c4 08             	add    $0x8,%esp
  80172f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801732:	6a 00                	push   $0x0
  801734:	e8 f4 f6 ff ff       	call   800e2d <sys_page_unmap>
	return r;
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	89 f8                	mov    %edi,%eax
}
  80173e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801741:	5b                   	pop    %ebx
  801742:	5e                   	pop    %esi
  801743:	5f                   	pop    %edi
  801744:	5d                   	pop    %ebp
  801745:	c3                   	ret    

00801746 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	53                   	push   %ebx
  80174a:	83 ec 14             	sub    $0x14,%esp
  80174d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801750:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801753:	50                   	push   %eax
  801754:	53                   	push   %ebx
  801755:	e8 83 fd ff ff       	call   8014dd <fd_lookup>
  80175a:	83 c4 08             	add    $0x8,%esp
  80175d:	89 c2                	mov    %eax,%edx
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 70                	js     8017d3 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801763:	83 ec 08             	sub    $0x8,%esp
  801766:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801769:	50                   	push   %eax
  80176a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176d:	ff 30                	pushl  (%eax)
  80176f:	e8 bf fd ff ff       	call   801533 <dev_lookup>
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	85 c0                	test   %eax,%eax
  801779:	78 4f                	js     8017ca <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80177b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80177e:	8b 42 08             	mov    0x8(%edx),%eax
  801781:	83 e0 03             	and    $0x3,%eax
  801784:	83 f8 01             	cmp    $0x1,%eax
  801787:	75 24                	jne    8017ad <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801789:	a1 20 44 80 00       	mov    0x804420,%eax
  80178e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801794:	83 ec 04             	sub    $0x4,%esp
  801797:	53                   	push   %ebx
  801798:	50                   	push   %eax
  801799:	68 ac 2b 80 00       	push   $0x802bac
  80179e:	e8 7d ec ff ff       	call   800420 <cprintf>
		return -E_INVAL;
  8017a3:	83 c4 10             	add    $0x10,%esp
  8017a6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017ab:	eb 26                	jmp    8017d3 <read+0x8d>
	}
	if (!dev->dev_read)
  8017ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b0:	8b 40 08             	mov    0x8(%eax),%eax
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	74 17                	je     8017ce <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8017b7:	83 ec 04             	sub    $0x4,%esp
  8017ba:	ff 75 10             	pushl  0x10(%ebp)
  8017bd:	ff 75 0c             	pushl  0xc(%ebp)
  8017c0:	52                   	push   %edx
  8017c1:	ff d0                	call   *%eax
  8017c3:	89 c2                	mov    %eax,%edx
  8017c5:	83 c4 10             	add    $0x10,%esp
  8017c8:	eb 09                	jmp    8017d3 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ca:	89 c2                	mov    %eax,%edx
  8017cc:	eb 05                	jmp    8017d3 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8017d3:	89 d0                	mov    %edx,%eax
  8017d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d8:	c9                   	leave  
  8017d9:	c3                   	ret    

008017da <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	57                   	push   %edi
  8017de:	56                   	push   %esi
  8017df:	53                   	push   %ebx
  8017e0:	83 ec 0c             	sub    $0xc,%esp
  8017e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ee:	eb 21                	jmp    801811 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017f0:	83 ec 04             	sub    $0x4,%esp
  8017f3:	89 f0                	mov    %esi,%eax
  8017f5:	29 d8                	sub    %ebx,%eax
  8017f7:	50                   	push   %eax
  8017f8:	89 d8                	mov    %ebx,%eax
  8017fa:	03 45 0c             	add    0xc(%ebp),%eax
  8017fd:	50                   	push   %eax
  8017fe:	57                   	push   %edi
  8017ff:	e8 42 ff ff ff       	call   801746 <read>
		if (m < 0)
  801804:	83 c4 10             	add    $0x10,%esp
  801807:	85 c0                	test   %eax,%eax
  801809:	78 10                	js     80181b <readn+0x41>
			return m;
		if (m == 0)
  80180b:	85 c0                	test   %eax,%eax
  80180d:	74 0a                	je     801819 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80180f:	01 c3                	add    %eax,%ebx
  801811:	39 f3                	cmp    %esi,%ebx
  801813:	72 db                	jb     8017f0 <readn+0x16>
  801815:	89 d8                	mov    %ebx,%eax
  801817:	eb 02                	jmp    80181b <readn+0x41>
  801819:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80181b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80181e:	5b                   	pop    %ebx
  80181f:	5e                   	pop    %esi
  801820:	5f                   	pop    %edi
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	53                   	push   %ebx
  801827:	83 ec 14             	sub    $0x14,%esp
  80182a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801830:	50                   	push   %eax
  801831:	53                   	push   %ebx
  801832:	e8 a6 fc ff ff       	call   8014dd <fd_lookup>
  801837:	83 c4 08             	add    $0x8,%esp
  80183a:	89 c2                	mov    %eax,%edx
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 6b                	js     8018ab <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801846:	50                   	push   %eax
  801847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184a:	ff 30                	pushl  (%eax)
  80184c:	e8 e2 fc ff ff       	call   801533 <dev_lookup>
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	78 4a                	js     8018a2 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801858:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80185f:	75 24                	jne    801885 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801861:	a1 20 44 80 00       	mov    0x804420,%eax
  801866:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80186c:	83 ec 04             	sub    $0x4,%esp
  80186f:	53                   	push   %ebx
  801870:	50                   	push   %eax
  801871:	68 c8 2b 80 00       	push   $0x802bc8
  801876:	e8 a5 eb ff ff       	call   800420 <cprintf>
		return -E_INVAL;
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801883:	eb 26                	jmp    8018ab <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801885:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801888:	8b 52 0c             	mov    0xc(%edx),%edx
  80188b:	85 d2                	test   %edx,%edx
  80188d:	74 17                	je     8018a6 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80188f:	83 ec 04             	sub    $0x4,%esp
  801892:	ff 75 10             	pushl  0x10(%ebp)
  801895:	ff 75 0c             	pushl  0xc(%ebp)
  801898:	50                   	push   %eax
  801899:	ff d2                	call   *%edx
  80189b:	89 c2                	mov    %eax,%edx
  80189d:	83 c4 10             	add    $0x10,%esp
  8018a0:	eb 09                	jmp    8018ab <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a2:	89 c2                	mov    %eax,%edx
  8018a4:	eb 05                	jmp    8018ab <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018a6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018ab:	89 d0                	mov    %edx,%eax
  8018ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018b8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018bb:	50                   	push   %eax
  8018bc:	ff 75 08             	pushl  0x8(%ebp)
  8018bf:	e8 19 fc ff ff       	call   8014dd <fd_lookup>
  8018c4:	83 c4 08             	add    $0x8,%esp
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	78 0e                	js     8018d9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	53                   	push   %ebx
  8018df:	83 ec 14             	sub    $0x14,%esp
  8018e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e8:	50                   	push   %eax
  8018e9:	53                   	push   %ebx
  8018ea:	e8 ee fb ff ff       	call   8014dd <fd_lookup>
  8018ef:	83 c4 08             	add    $0x8,%esp
  8018f2:	89 c2                	mov    %eax,%edx
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	78 68                	js     801960 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f8:	83 ec 08             	sub    $0x8,%esp
  8018fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fe:	50                   	push   %eax
  8018ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801902:	ff 30                	pushl  (%eax)
  801904:	e8 2a fc ff ff       	call   801533 <dev_lookup>
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 47                	js     801957 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801910:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801913:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801917:	75 24                	jne    80193d <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801919:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80191e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801924:	83 ec 04             	sub    $0x4,%esp
  801927:	53                   	push   %ebx
  801928:	50                   	push   %eax
  801929:	68 88 2b 80 00       	push   $0x802b88
  80192e:	e8 ed ea ff ff       	call   800420 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80193b:	eb 23                	jmp    801960 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80193d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801940:	8b 52 18             	mov    0x18(%edx),%edx
  801943:	85 d2                	test   %edx,%edx
  801945:	74 14                	je     80195b <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801947:	83 ec 08             	sub    $0x8,%esp
  80194a:	ff 75 0c             	pushl  0xc(%ebp)
  80194d:	50                   	push   %eax
  80194e:	ff d2                	call   *%edx
  801950:	89 c2                	mov    %eax,%edx
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	eb 09                	jmp    801960 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801957:	89 c2                	mov    %eax,%edx
  801959:	eb 05                	jmp    801960 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80195b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801960:	89 d0                	mov    %edx,%eax
  801962:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	53                   	push   %ebx
  80196b:	83 ec 14             	sub    $0x14,%esp
  80196e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801971:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801974:	50                   	push   %eax
  801975:	ff 75 08             	pushl  0x8(%ebp)
  801978:	e8 60 fb ff ff       	call   8014dd <fd_lookup>
  80197d:	83 c4 08             	add    $0x8,%esp
  801980:	89 c2                	mov    %eax,%edx
  801982:	85 c0                	test   %eax,%eax
  801984:	78 58                	js     8019de <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801986:	83 ec 08             	sub    $0x8,%esp
  801989:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198c:	50                   	push   %eax
  80198d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801990:	ff 30                	pushl  (%eax)
  801992:	e8 9c fb ff ff       	call   801533 <dev_lookup>
  801997:	83 c4 10             	add    $0x10,%esp
  80199a:	85 c0                	test   %eax,%eax
  80199c:	78 37                	js     8019d5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80199e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019a5:	74 32                	je     8019d9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019a7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019aa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019b1:	00 00 00 
	stat->st_isdir = 0;
  8019b4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019bb:	00 00 00 
	stat->st_dev = dev;
  8019be:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019c4:	83 ec 08             	sub    $0x8,%esp
  8019c7:	53                   	push   %ebx
  8019c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8019cb:	ff 50 14             	call   *0x14(%eax)
  8019ce:	89 c2                	mov    %eax,%edx
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	eb 09                	jmp    8019de <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d5:	89 c2                	mov    %eax,%edx
  8019d7:	eb 05                	jmp    8019de <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019de:	89 d0                	mov    %edx,%eax
  8019e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    

008019e5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	56                   	push   %esi
  8019e9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019ea:	83 ec 08             	sub    $0x8,%esp
  8019ed:	6a 00                	push   $0x0
  8019ef:	ff 75 08             	pushl  0x8(%ebp)
  8019f2:	e8 e3 01 00 00       	call   801bda <open>
  8019f7:	89 c3                	mov    %eax,%ebx
  8019f9:	83 c4 10             	add    $0x10,%esp
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	78 1b                	js     801a1b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a00:	83 ec 08             	sub    $0x8,%esp
  801a03:	ff 75 0c             	pushl  0xc(%ebp)
  801a06:	50                   	push   %eax
  801a07:	e8 5b ff ff ff       	call   801967 <fstat>
  801a0c:	89 c6                	mov    %eax,%esi
	close(fd);
  801a0e:	89 1c 24             	mov    %ebx,(%esp)
  801a11:	e8 f4 fb ff ff       	call   80160a <close>
	return r;
  801a16:	83 c4 10             	add    $0x10,%esp
  801a19:	89 f0                	mov    %esi,%eax
}
  801a1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1e:	5b                   	pop    %ebx
  801a1f:	5e                   	pop    %esi
  801a20:	5d                   	pop    %ebp
  801a21:	c3                   	ret    

00801a22 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	56                   	push   %esi
  801a26:	53                   	push   %ebx
  801a27:	89 c6                	mov    %eax,%esi
  801a29:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a2b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a32:	75 12                	jne    801a46 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a34:	83 ec 0c             	sub    $0xc,%esp
  801a37:	6a 01                	push   $0x1
  801a39:	e8 a4 09 00 00       	call   8023e2 <ipc_find_env>
  801a3e:	a3 00 40 80 00       	mov    %eax,0x804000
  801a43:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a46:	6a 07                	push   $0x7
  801a48:	68 00 50 80 00       	push   $0x805000
  801a4d:	56                   	push   %esi
  801a4e:	ff 35 00 40 80 00    	pushl  0x804000
  801a54:	e8 27 09 00 00       	call   802380 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a59:	83 c4 0c             	add    $0xc,%esp
  801a5c:	6a 00                	push   $0x0
  801a5e:	53                   	push   %ebx
  801a5f:	6a 00                	push   $0x0
  801a61:	e8 9f 08 00 00       	call   802305 <ipc_recv>
}
  801a66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a73:	8b 45 08             	mov    0x8(%ebp),%eax
  801a76:	8b 40 0c             	mov    0xc(%eax),%eax
  801a79:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a81:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a86:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8b:	b8 02 00 00 00       	mov    $0x2,%eax
  801a90:	e8 8d ff ff ff       	call   801a22 <fsipc>
}
  801a95:	c9                   	leave  
  801a96:	c3                   	ret    

00801a97 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa0:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801aa8:	ba 00 00 00 00       	mov    $0x0,%edx
  801aad:	b8 06 00 00 00       	mov    $0x6,%eax
  801ab2:	e8 6b ff ff ff       	call   801a22 <fsipc>
}
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	53                   	push   %ebx
  801abd:	83 ec 04             	sub    $0x4,%esp
  801ac0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac6:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ace:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad3:	b8 05 00 00 00       	mov    $0x5,%eax
  801ad8:	e8 45 ff ff ff       	call   801a22 <fsipc>
  801add:	85 c0                	test   %eax,%eax
  801adf:	78 2c                	js     801b0d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ae1:	83 ec 08             	sub    $0x8,%esp
  801ae4:	68 00 50 80 00       	push   $0x805000
  801ae9:	53                   	push   %ebx
  801aea:	e8 b6 ee ff ff       	call   8009a5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aef:	a1 80 50 80 00       	mov    0x805080,%eax
  801af4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801afa:	a1 84 50 80 00       	mov    0x805084,%eax
  801aff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b05:	83 c4 10             	add    $0x10,%esp
  801b08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	83 ec 0c             	sub    $0xc,%esp
  801b18:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b1b:	8b 55 08             	mov    0x8(%ebp),%edx
  801b1e:	8b 52 0c             	mov    0xc(%edx),%edx
  801b21:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b27:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b2c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b31:	0f 47 c2             	cmova  %edx,%eax
  801b34:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b39:	50                   	push   %eax
  801b3a:	ff 75 0c             	pushl  0xc(%ebp)
  801b3d:	68 08 50 80 00       	push   $0x805008
  801b42:	e8 f0 ef ff ff       	call   800b37 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b47:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4c:	b8 04 00 00 00       	mov    $0x4,%eax
  801b51:	e8 cc fe ff ff       	call   801a22 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b56:	c9                   	leave  
  801b57:	c3                   	ret    

00801b58 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	56                   	push   %esi
  801b5c:	53                   	push   %ebx
  801b5d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b60:	8b 45 08             	mov    0x8(%ebp),%eax
  801b63:	8b 40 0c             	mov    0xc(%eax),%eax
  801b66:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b6b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b71:	ba 00 00 00 00       	mov    $0x0,%edx
  801b76:	b8 03 00 00 00       	mov    $0x3,%eax
  801b7b:	e8 a2 fe ff ff       	call   801a22 <fsipc>
  801b80:	89 c3                	mov    %eax,%ebx
  801b82:	85 c0                	test   %eax,%eax
  801b84:	78 4b                	js     801bd1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b86:	39 c6                	cmp    %eax,%esi
  801b88:	73 16                	jae    801ba0 <devfile_read+0x48>
  801b8a:	68 f8 2b 80 00       	push   $0x802bf8
  801b8f:	68 ff 2b 80 00       	push   $0x802bff
  801b94:	6a 7c                	push   $0x7c
  801b96:	68 14 2c 80 00       	push   $0x802c14
  801b9b:	e8 a7 e7 ff ff       	call   800347 <_panic>
	assert(r <= PGSIZE);
  801ba0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ba5:	7e 16                	jle    801bbd <devfile_read+0x65>
  801ba7:	68 1f 2c 80 00       	push   $0x802c1f
  801bac:	68 ff 2b 80 00       	push   $0x802bff
  801bb1:	6a 7d                	push   $0x7d
  801bb3:	68 14 2c 80 00       	push   $0x802c14
  801bb8:	e8 8a e7 ff ff       	call   800347 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bbd:	83 ec 04             	sub    $0x4,%esp
  801bc0:	50                   	push   %eax
  801bc1:	68 00 50 80 00       	push   $0x805000
  801bc6:	ff 75 0c             	pushl  0xc(%ebp)
  801bc9:	e8 69 ef ff ff       	call   800b37 <memmove>
	return r;
  801bce:	83 c4 10             	add    $0x10,%esp
}
  801bd1:	89 d8                	mov    %ebx,%eax
  801bd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd6:	5b                   	pop    %ebx
  801bd7:	5e                   	pop    %esi
  801bd8:	5d                   	pop    %ebp
  801bd9:	c3                   	ret    

00801bda <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	53                   	push   %ebx
  801bde:	83 ec 20             	sub    $0x20,%esp
  801be1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801be4:	53                   	push   %ebx
  801be5:	e8 82 ed ff ff       	call   80096c <strlen>
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bf2:	7f 67                	jg     801c5b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bf4:	83 ec 0c             	sub    $0xc,%esp
  801bf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfa:	50                   	push   %eax
  801bfb:	e8 8e f8 ff ff       	call   80148e <fd_alloc>
  801c00:	83 c4 10             	add    $0x10,%esp
		return r;
  801c03:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c05:	85 c0                	test   %eax,%eax
  801c07:	78 57                	js     801c60 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c09:	83 ec 08             	sub    $0x8,%esp
  801c0c:	53                   	push   %ebx
  801c0d:	68 00 50 80 00       	push   $0x805000
  801c12:	e8 8e ed ff ff       	call   8009a5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c1a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c22:	b8 01 00 00 00       	mov    $0x1,%eax
  801c27:	e8 f6 fd ff ff       	call   801a22 <fsipc>
  801c2c:	89 c3                	mov    %eax,%ebx
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	85 c0                	test   %eax,%eax
  801c33:	79 14                	jns    801c49 <open+0x6f>
		fd_close(fd, 0);
  801c35:	83 ec 08             	sub    $0x8,%esp
  801c38:	6a 00                	push   $0x0
  801c3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3d:	e8 47 f9 ff ff       	call   801589 <fd_close>
		return r;
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	89 da                	mov    %ebx,%edx
  801c47:	eb 17                	jmp    801c60 <open+0x86>
	}

	return fd2num(fd);
  801c49:	83 ec 0c             	sub    $0xc,%esp
  801c4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4f:	e8 13 f8 ff ff       	call   801467 <fd2num>
  801c54:	89 c2                	mov    %eax,%edx
  801c56:	83 c4 10             	add    $0x10,%esp
  801c59:	eb 05                	jmp    801c60 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c5b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c60:	89 d0                	mov    %edx,%eax
  801c62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c65:	c9                   	leave  
  801c66:	c3                   	ret    

00801c67 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c6d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c72:	b8 08 00 00 00       	mov    $0x8,%eax
  801c77:	e8 a6 fd ff ff       	call   801a22 <fsipc>
}
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801c7e:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801c82:	7e 37                	jle    801cbb <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	53                   	push   %ebx
  801c88:	83 ec 08             	sub    $0x8,%esp
  801c8b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801c8d:	ff 70 04             	pushl  0x4(%eax)
  801c90:	8d 40 10             	lea    0x10(%eax),%eax
  801c93:	50                   	push   %eax
  801c94:	ff 33                	pushl  (%ebx)
  801c96:	e8 88 fb ff ff       	call   801823 <write>
		if (result > 0)
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	7e 03                	jle    801ca5 <writebuf+0x27>
			b->result += result;
  801ca2:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801ca5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ca8:	74 0d                	je     801cb7 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801caa:	85 c0                	test   %eax,%eax
  801cac:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb1:	0f 4f c2             	cmovg  %edx,%eax
  801cb4:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801cb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cba:	c9                   	leave  
  801cbb:	f3 c3                	repz ret 

00801cbd <putch>:

static void
putch(int ch, void *thunk)
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	53                   	push   %ebx
  801cc1:	83 ec 04             	sub    $0x4,%esp
  801cc4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801cc7:	8b 53 04             	mov    0x4(%ebx),%edx
  801cca:	8d 42 01             	lea    0x1(%edx),%eax
  801ccd:	89 43 04             	mov    %eax,0x4(%ebx)
  801cd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd3:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801cd7:	3d 00 01 00 00       	cmp    $0x100,%eax
  801cdc:	75 0e                	jne    801cec <putch+0x2f>
		writebuf(b);
  801cde:	89 d8                	mov    %ebx,%eax
  801ce0:	e8 99 ff ff ff       	call   801c7e <writebuf>
		b->idx = 0;
  801ce5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801cec:	83 c4 04             	add    $0x4,%esp
  801cef:	5b                   	pop    %ebx
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    

00801cf2 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfe:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801d04:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801d0b:	00 00 00 
	b.result = 0;
  801d0e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801d15:	00 00 00 
	b.error = 1;
  801d18:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801d1f:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801d22:	ff 75 10             	pushl  0x10(%ebp)
  801d25:	ff 75 0c             	pushl  0xc(%ebp)
  801d28:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801d2e:	50                   	push   %eax
  801d2f:	68 bd 1c 80 00       	push   $0x801cbd
  801d34:	e8 1e e8 ff ff       	call   800557 <vprintfmt>
	if (b.idx > 0)
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801d43:	7e 0b                	jle    801d50 <vfprintf+0x5e>
		writebuf(&b);
  801d45:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801d4b:	e8 2e ff ff ff       	call   801c7e <writebuf>

	return (b.result ? b.result : b.error);
  801d50:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801d56:	85 c0                	test   %eax,%eax
  801d58:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801d5f:	c9                   	leave  
  801d60:	c3                   	ret    

00801d61 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d67:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801d6a:	50                   	push   %eax
  801d6b:	ff 75 0c             	pushl  0xc(%ebp)
  801d6e:	ff 75 08             	pushl  0x8(%ebp)
  801d71:	e8 7c ff ff ff       	call   801cf2 <vfprintf>
	va_end(ap);

	return cnt;
}
  801d76:	c9                   	leave  
  801d77:	c3                   	ret    

00801d78 <printf>:

int
printf(const char *fmt, ...)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d7e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801d81:	50                   	push   %eax
  801d82:	ff 75 08             	pushl  0x8(%ebp)
  801d85:	6a 01                	push   $0x1
  801d87:	e8 66 ff ff ff       	call   801cf2 <vfprintf>
	va_end(ap);

	return cnt;
}
  801d8c:	c9                   	leave  
  801d8d:	c3                   	ret    

00801d8e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	56                   	push   %esi
  801d92:	53                   	push   %ebx
  801d93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d96:	83 ec 0c             	sub    $0xc,%esp
  801d99:	ff 75 08             	pushl  0x8(%ebp)
  801d9c:	e8 d6 f6 ff ff       	call   801477 <fd2data>
  801da1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801da3:	83 c4 08             	add    $0x8,%esp
  801da6:	68 2b 2c 80 00       	push   $0x802c2b
  801dab:	53                   	push   %ebx
  801dac:	e8 f4 eb ff ff       	call   8009a5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801db1:	8b 46 04             	mov    0x4(%esi),%eax
  801db4:	2b 06                	sub    (%esi),%eax
  801db6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801dbc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801dc3:	00 00 00 
	stat->st_dev = &devpipe;
  801dc6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801dcd:	30 80 00 
	return 0;
}
  801dd0:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd8:	5b                   	pop    %ebx
  801dd9:	5e                   	pop    %esi
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    

00801ddc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	53                   	push   %ebx
  801de0:	83 ec 0c             	sub    $0xc,%esp
  801de3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801de6:	53                   	push   %ebx
  801de7:	6a 00                	push   $0x0
  801de9:	e8 3f f0 ff ff       	call   800e2d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dee:	89 1c 24             	mov    %ebx,(%esp)
  801df1:	e8 81 f6 ff ff       	call   801477 <fd2data>
  801df6:	83 c4 08             	add    $0x8,%esp
  801df9:	50                   	push   %eax
  801dfa:	6a 00                	push   $0x0
  801dfc:	e8 2c f0 ff ff       	call   800e2d <sys_page_unmap>
}
  801e01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e04:	c9                   	leave  
  801e05:	c3                   	ret    

00801e06 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	57                   	push   %edi
  801e0a:	56                   	push   %esi
  801e0b:	53                   	push   %ebx
  801e0c:	83 ec 1c             	sub    $0x1c,%esp
  801e0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e12:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e14:	a1 20 44 80 00       	mov    0x804420,%eax
  801e19:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e1f:	83 ec 0c             	sub    $0xc,%esp
  801e22:	ff 75 e0             	pushl  -0x20(%ebp)
  801e25:	e8 fd 05 00 00       	call   802427 <pageref>
  801e2a:	89 c3                	mov    %eax,%ebx
  801e2c:	89 3c 24             	mov    %edi,(%esp)
  801e2f:	e8 f3 05 00 00       	call   802427 <pageref>
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	39 c3                	cmp    %eax,%ebx
  801e39:	0f 94 c1             	sete   %cl
  801e3c:	0f b6 c9             	movzbl %cl,%ecx
  801e3f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e42:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801e48:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801e4e:	39 ce                	cmp    %ecx,%esi
  801e50:	74 1e                	je     801e70 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801e52:	39 c3                	cmp    %eax,%ebx
  801e54:	75 be                	jne    801e14 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e56:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801e5c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e5f:	50                   	push   %eax
  801e60:	56                   	push   %esi
  801e61:	68 32 2c 80 00       	push   $0x802c32
  801e66:	e8 b5 e5 ff ff       	call   800420 <cprintf>
  801e6b:	83 c4 10             	add    $0x10,%esp
  801e6e:	eb a4                	jmp    801e14 <_pipeisclosed+0xe>
	}
}
  801e70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e76:	5b                   	pop    %ebx
  801e77:	5e                   	pop    %esi
  801e78:	5f                   	pop    %edi
  801e79:	5d                   	pop    %ebp
  801e7a:	c3                   	ret    

00801e7b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	57                   	push   %edi
  801e7f:	56                   	push   %esi
  801e80:	53                   	push   %ebx
  801e81:	83 ec 28             	sub    $0x28,%esp
  801e84:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e87:	56                   	push   %esi
  801e88:	e8 ea f5 ff ff       	call   801477 <fd2data>
  801e8d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e8f:	83 c4 10             	add    $0x10,%esp
  801e92:	bf 00 00 00 00       	mov    $0x0,%edi
  801e97:	eb 4b                	jmp    801ee4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e99:	89 da                	mov    %ebx,%edx
  801e9b:	89 f0                	mov    %esi,%eax
  801e9d:	e8 64 ff ff ff       	call   801e06 <_pipeisclosed>
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	75 48                	jne    801eee <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ea6:	e8 de ee ff ff       	call   800d89 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801eab:	8b 43 04             	mov    0x4(%ebx),%eax
  801eae:	8b 0b                	mov    (%ebx),%ecx
  801eb0:	8d 51 20             	lea    0x20(%ecx),%edx
  801eb3:	39 d0                	cmp    %edx,%eax
  801eb5:	73 e2                	jae    801e99 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801eb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eba:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ebe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ec1:	89 c2                	mov    %eax,%edx
  801ec3:	c1 fa 1f             	sar    $0x1f,%edx
  801ec6:	89 d1                	mov    %edx,%ecx
  801ec8:	c1 e9 1b             	shr    $0x1b,%ecx
  801ecb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ece:	83 e2 1f             	and    $0x1f,%edx
  801ed1:	29 ca                	sub    %ecx,%edx
  801ed3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ed7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801edb:	83 c0 01             	add    $0x1,%eax
  801ede:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee1:	83 c7 01             	add    $0x1,%edi
  801ee4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ee7:	75 c2                	jne    801eab <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ee9:	8b 45 10             	mov    0x10(%ebp),%eax
  801eec:	eb 05                	jmp    801ef3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801eee:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ef3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef6:	5b                   	pop    %ebx
  801ef7:	5e                   	pop    %esi
  801ef8:	5f                   	pop    %edi
  801ef9:	5d                   	pop    %ebp
  801efa:	c3                   	ret    

00801efb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	57                   	push   %edi
  801eff:	56                   	push   %esi
  801f00:	53                   	push   %ebx
  801f01:	83 ec 18             	sub    $0x18,%esp
  801f04:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f07:	57                   	push   %edi
  801f08:	e8 6a f5 ff ff       	call   801477 <fd2data>
  801f0d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f17:	eb 3d                	jmp    801f56 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f19:	85 db                	test   %ebx,%ebx
  801f1b:	74 04                	je     801f21 <devpipe_read+0x26>
				return i;
  801f1d:	89 d8                	mov    %ebx,%eax
  801f1f:	eb 44                	jmp    801f65 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f21:	89 f2                	mov    %esi,%edx
  801f23:	89 f8                	mov    %edi,%eax
  801f25:	e8 dc fe ff ff       	call   801e06 <_pipeisclosed>
  801f2a:	85 c0                	test   %eax,%eax
  801f2c:	75 32                	jne    801f60 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f2e:	e8 56 ee ff ff       	call   800d89 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f33:	8b 06                	mov    (%esi),%eax
  801f35:	3b 46 04             	cmp    0x4(%esi),%eax
  801f38:	74 df                	je     801f19 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f3a:	99                   	cltd   
  801f3b:	c1 ea 1b             	shr    $0x1b,%edx
  801f3e:	01 d0                	add    %edx,%eax
  801f40:	83 e0 1f             	and    $0x1f,%eax
  801f43:	29 d0                	sub    %edx,%eax
  801f45:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f4d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f50:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f53:	83 c3 01             	add    $0x1,%ebx
  801f56:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f59:	75 d8                	jne    801f33 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801f5e:	eb 05                	jmp    801f65 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f60:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f68:	5b                   	pop    %ebx
  801f69:	5e                   	pop    %esi
  801f6a:	5f                   	pop    %edi
  801f6b:	5d                   	pop    %ebp
  801f6c:	c3                   	ret    

00801f6d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	56                   	push   %esi
  801f71:	53                   	push   %ebx
  801f72:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f78:	50                   	push   %eax
  801f79:	e8 10 f5 ff ff       	call   80148e <fd_alloc>
  801f7e:	83 c4 10             	add    $0x10,%esp
  801f81:	89 c2                	mov    %eax,%edx
  801f83:	85 c0                	test   %eax,%eax
  801f85:	0f 88 2c 01 00 00    	js     8020b7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f8b:	83 ec 04             	sub    $0x4,%esp
  801f8e:	68 07 04 00 00       	push   $0x407
  801f93:	ff 75 f4             	pushl  -0xc(%ebp)
  801f96:	6a 00                	push   $0x0
  801f98:	e8 0b ee ff ff       	call   800da8 <sys_page_alloc>
  801f9d:	83 c4 10             	add    $0x10,%esp
  801fa0:	89 c2                	mov    %eax,%edx
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	0f 88 0d 01 00 00    	js     8020b7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801faa:	83 ec 0c             	sub    $0xc,%esp
  801fad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fb0:	50                   	push   %eax
  801fb1:	e8 d8 f4 ff ff       	call   80148e <fd_alloc>
  801fb6:	89 c3                	mov    %eax,%ebx
  801fb8:	83 c4 10             	add    $0x10,%esp
  801fbb:	85 c0                	test   %eax,%eax
  801fbd:	0f 88 e2 00 00 00    	js     8020a5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc3:	83 ec 04             	sub    $0x4,%esp
  801fc6:	68 07 04 00 00       	push   $0x407
  801fcb:	ff 75 f0             	pushl  -0x10(%ebp)
  801fce:	6a 00                	push   $0x0
  801fd0:	e8 d3 ed ff ff       	call   800da8 <sys_page_alloc>
  801fd5:	89 c3                	mov    %eax,%ebx
  801fd7:	83 c4 10             	add    $0x10,%esp
  801fda:	85 c0                	test   %eax,%eax
  801fdc:	0f 88 c3 00 00 00    	js     8020a5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fe2:	83 ec 0c             	sub    $0xc,%esp
  801fe5:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe8:	e8 8a f4 ff ff       	call   801477 <fd2data>
  801fed:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fef:	83 c4 0c             	add    $0xc,%esp
  801ff2:	68 07 04 00 00       	push   $0x407
  801ff7:	50                   	push   %eax
  801ff8:	6a 00                	push   $0x0
  801ffa:	e8 a9 ed ff ff       	call   800da8 <sys_page_alloc>
  801fff:	89 c3                	mov    %eax,%ebx
  802001:	83 c4 10             	add    $0x10,%esp
  802004:	85 c0                	test   %eax,%eax
  802006:	0f 88 89 00 00 00    	js     802095 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80200c:	83 ec 0c             	sub    $0xc,%esp
  80200f:	ff 75 f0             	pushl  -0x10(%ebp)
  802012:	e8 60 f4 ff ff       	call   801477 <fd2data>
  802017:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80201e:	50                   	push   %eax
  80201f:	6a 00                	push   $0x0
  802021:	56                   	push   %esi
  802022:	6a 00                	push   $0x0
  802024:	e8 c2 ed ff ff       	call   800deb <sys_page_map>
  802029:	89 c3                	mov    %eax,%ebx
  80202b:	83 c4 20             	add    $0x20,%esp
  80202e:	85 c0                	test   %eax,%eax
  802030:	78 55                	js     802087 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802032:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80203d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802040:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802047:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80204d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802050:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802052:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802055:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80205c:	83 ec 0c             	sub    $0xc,%esp
  80205f:	ff 75 f4             	pushl  -0xc(%ebp)
  802062:	e8 00 f4 ff ff       	call   801467 <fd2num>
  802067:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80206a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80206c:	83 c4 04             	add    $0x4,%esp
  80206f:	ff 75 f0             	pushl  -0x10(%ebp)
  802072:	e8 f0 f3 ff ff       	call   801467 <fd2num>
  802077:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80207a:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80207d:	83 c4 10             	add    $0x10,%esp
  802080:	ba 00 00 00 00       	mov    $0x0,%edx
  802085:	eb 30                	jmp    8020b7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802087:	83 ec 08             	sub    $0x8,%esp
  80208a:	56                   	push   %esi
  80208b:	6a 00                	push   $0x0
  80208d:	e8 9b ed ff ff       	call   800e2d <sys_page_unmap>
  802092:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802095:	83 ec 08             	sub    $0x8,%esp
  802098:	ff 75 f0             	pushl  -0x10(%ebp)
  80209b:	6a 00                	push   $0x0
  80209d:	e8 8b ed ff ff       	call   800e2d <sys_page_unmap>
  8020a2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020a5:	83 ec 08             	sub    $0x8,%esp
  8020a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ab:	6a 00                	push   $0x0
  8020ad:	e8 7b ed ff ff       	call   800e2d <sys_page_unmap>
  8020b2:	83 c4 10             	add    $0x10,%esp
  8020b5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8020b7:	89 d0                	mov    %edx,%eax
  8020b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020bc:	5b                   	pop    %ebx
  8020bd:	5e                   	pop    %esi
  8020be:	5d                   	pop    %ebp
  8020bf:	c3                   	ret    

008020c0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020c0:	55                   	push   %ebp
  8020c1:	89 e5                	mov    %esp,%ebp
  8020c3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c9:	50                   	push   %eax
  8020ca:	ff 75 08             	pushl  0x8(%ebp)
  8020cd:	e8 0b f4 ff ff       	call   8014dd <fd_lookup>
  8020d2:	83 c4 10             	add    $0x10,%esp
  8020d5:	85 c0                	test   %eax,%eax
  8020d7:	78 18                	js     8020f1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020d9:	83 ec 0c             	sub    $0xc,%esp
  8020dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8020df:	e8 93 f3 ff ff       	call   801477 <fd2data>
	return _pipeisclosed(fd, p);
  8020e4:	89 c2                	mov    %eax,%edx
  8020e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e9:	e8 18 fd ff ff       	call   801e06 <_pipeisclosed>
  8020ee:	83 c4 10             	add    $0x10,%esp
}
  8020f1:	c9                   	leave  
  8020f2:	c3                   	ret    

008020f3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020f3:	55                   	push   %ebp
  8020f4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8020fb:	5d                   	pop    %ebp
  8020fc:	c3                   	ret    

008020fd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020fd:	55                   	push   %ebp
  8020fe:	89 e5                	mov    %esp,%ebp
  802100:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802103:	68 4a 2c 80 00       	push   $0x802c4a
  802108:	ff 75 0c             	pushl  0xc(%ebp)
  80210b:	e8 95 e8 ff ff       	call   8009a5 <strcpy>
	return 0;
}
  802110:	b8 00 00 00 00       	mov    $0x0,%eax
  802115:	c9                   	leave  
  802116:	c3                   	ret    

00802117 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802117:	55                   	push   %ebp
  802118:	89 e5                	mov    %esp,%ebp
  80211a:	57                   	push   %edi
  80211b:	56                   	push   %esi
  80211c:	53                   	push   %ebx
  80211d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802123:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802128:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80212e:	eb 2d                	jmp    80215d <devcons_write+0x46>
		m = n - tot;
  802130:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802133:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802135:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802138:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80213d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802140:	83 ec 04             	sub    $0x4,%esp
  802143:	53                   	push   %ebx
  802144:	03 45 0c             	add    0xc(%ebp),%eax
  802147:	50                   	push   %eax
  802148:	57                   	push   %edi
  802149:	e8 e9 e9 ff ff       	call   800b37 <memmove>
		sys_cputs(buf, m);
  80214e:	83 c4 08             	add    $0x8,%esp
  802151:	53                   	push   %ebx
  802152:	57                   	push   %edi
  802153:	e8 94 eb ff ff       	call   800cec <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802158:	01 de                	add    %ebx,%esi
  80215a:	83 c4 10             	add    $0x10,%esp
  80215d:	89 f0                	mov    %esi,%eax
  80215f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802162:	72 cc                	jb     802130 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802164:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    

0080216c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80216c:	55                   	push   %ebp
  80216d:	89 e5                	mov    %esp,%ebp
  80216f:	83 ec 08             	sub    $0x8,%esp
  802172:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802177:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80217b:	74 2a                	je     8021a7 <devcons_read+0x3b>
  80217d:	eb 05                	jmp    802184 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80217f:	e8 05 ec ff ff       	call   800d89 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802184:	e8 81 eb ff ff       	call   800d0a <sys_cgetc>
  802189:	85 c0                	test   %eax,%eax
  80218b:	74 f2                	je     80217f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80218d:	85 c0                	test   %eax,%eax
  80218f:	78 16                	js     8021a7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802191:	83 f8 04             	cmp    $0x4,%eax
  802194:	74 0c                	je     8021a2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802196:	8b 55 0c             	mov    0xc(%ebp),%edx
  802199:	88 02                	mov    %al,(%edx)
	return 1;
  80219b:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a0:	eb 05                	jmp    8021a7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021a2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021a7:	c9                   	leave  
  8021a8:	c3                   	ret    

008021a9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021a9:	55                   	push   %ebp
  8021aa:	89 e5                	mov    %esp,%ebp
  8021ac:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021af:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021b5:	6a 01                	push   $0x1
  8021b7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021ba:	50                   	push   %eax
  8021bb:	e8 2c eb ff ff       	call   800cec <sys_cputs>
}
  8021c0:	83 c4 10             	add    $0x10,%esp
  8021c3:	c9                   	leave  
  8021c4:	c3                   	ret    

008021c5 <getchar>:

int
getchar(void)
{
  8021c5:	55                   	push   %ebp
  8021c6:	89 e5                	mov    %esp,%ebp
  8021c8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021cb:	6a 01                	push   $0x1
  8021cd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021d0:	50                   	push   %eax
  8021d1:	6a 00                	push   $0x0
  8021d3:	e8 6e f5 ff ff       	call   801746 <read>
	if (r < 0)
  8021d8:	83 c4 10             	add    $0x10,%esp
  8021db:	85 c0                	test   %eax,%eax
  8021dd:	78 0f                	js     8021ee <getchar+0x29>
		return r;
	if (r < 1)
  8021df:	85 c0                	test   %eax,%eax
  8021e1:	7e 06                	jle    8021e9 <getchar+0x24>
		return -E_EOF;
	return c;
  8021e3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021e7:	eb 05                	jmp    8021ee <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021e9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021ee:	c9                   	leave  
  8021ef:	c3                   	ret    

008021f0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021f0:	55                   	push   %ebp
  8021f1:	89 e5                	mov    %esp,%ebp
  8021f3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021f9:	50                   	push   %eax
  8021fa:	ff 75 08             	pushl  0x8(%ebp)
  8021fd:	e8 db f2 ff ff       	call   8014dd <fd_lookup>
  802202:	83 c4 10             	add    $0x10,%esp
  802205:	85 c0                	test   %eax,%eax
  802207:	78 11                	js     80221a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802209:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802212:	39 10                	cmp    %edx,(%eax)
  802214:	0f 94 c0             	sete   %al
  802217:	0f b6 c0             	movzbl %al,%eax
}
  80221a:	c9                   	leave  
  80221b:	c3                   	ret    

0080221c <opencons>:

int
opencons(void)
{
  80221c:	55                   	push   %ebp
  80221d:	89 e5                	mov    %esp,%ebp
  80221f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802222:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802225:	50                   	push   %eax
  802226:	e8 63 f2 ff ff       	call   80148e <fd_alloc>
  80222b:	83 c4 10             	add    $0x10,%esp
		return r;
  80222e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802230:	85 c0                	test   %eax,%eax
  802232:	78 3e                	js     802272 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802234:	83 ec 04             	sub    $0x4,%esp
  802237:	68 07 04 00 00       	push   $0x407
  80223c:	ff 75 f4             	pushl  -0xc(%ebp)
  80223f:	6a 00                	push   $0x0
  802241:	e8 62 eb ff ff       	call   800da8 <sys_page_alloc>
  802246:	83 c4 10             	add    $0x10,%esp
		return r;
  802249:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80224b:	85 c0                	test   %eax,%eax
  80224d:	78 23                	js     802272 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80224f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802258:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80225a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802264:	83 ec 0c             	sub    $0xc,%esp
  802267:	50                   	push   %eax
  802268:	e8 fa f1 ff ff       	call   801467 <fd2num>
  80226d:	89 c2                	mov    %eax,%edx
  80226f:	83 c4 10             	add    $0x10,%esp
}
  802272:	89 d0                	mov    %edx,%eax
  802274:	c9                   	leave  
  802275:	c3                   	ret    

00802276 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802276:	55                   	push   %ebp
  802277:	89 e5                	mov    %esp,%ebp
  802279:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80227c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802283:	75 2a                	jne    8022af <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802285:	83 ec 04             	sub    $0x4,%esp
  802288:	6a 07                	push   $0x7
  80228a:	68 00 f0 bf ee       	push   $0xeebff000
  80228f:	6a 00                	push   $0x0
  802291:	e8 12 eb ff ff       	call   800da8 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802296:	83 c4 10             	add    $0x10,%esp
  802299:	85 c0                	test   %eax,%eax
  80229b:	79 12                	jns    8022af <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80229d:	50                   	push   %eax
  80229e:	68 56 2c 80 00       	push   $0x802c56
  8022a3:	6a 23                	push   $0x23
  8022a5:	68 5a 2c 80 00       	push   $0x802c5a
  8022aa:	e8 98 e0 ff ff       	call   800347 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022af:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b2:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8022b7:	83 ec 08             	sub    $0x8,%esp
  8022ba:	68 e1 22 80 00       	push   $0x8022e1
  8022bf:	6a 00                	push   $0x0
  8022c1:	e8 2d ec ff ff       	call   800ef3 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8022c6:	83 c4 10             	add    $0x10,%esp
  8022c9:	85 c0                	test   %eax,%eax
  8022cb:	79 12                	jns    8022df <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8022cd:	50                   	push   %eax
  8022ce:	68 56 2c 80 00       	push   $0x802c56
  8022d3:	6a 2c                	push   $0x2c
  8022d5:	68 5a 2c 80 00       	push   $0x802c5a
  8022da:	e8 68 e0 ff ff       	call   800347 <_panic>
	}
}
  8022df:	c9                   	leave  
  8022e0:	c3                   	ret    

008022e1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022e1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022e2:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8022e7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022e9:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8022ec:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8022f0:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8022f5:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8022f9:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8022fb:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8022fe:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8022ff:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802302:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802303:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802304:	c3                   	ret    

00802305 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802305:	55                   	push   %ebp
  802306:	89 e5                	mov    %esp,%ebp
  802308:	56                   	push   %esi
  802309:	53                   	push   %ebx
  80230a:	8b 75 08             	mov    0x8(%ebp),%esi
  80230d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802310:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802313:	85 c0                	test   %eax,%eax
  802315:	75 12                	jne    802329 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802317:	83 ec 0c             	sub    $0xc,%esp
  80231a:	68 00 00 c0 ee       	push   $0xeec00000
  80231f:	e8 34 ec ff ff       	call   800f58 <sys_ipc_recv>
  802324:	83 c4 10             	add    $0x10,%esp
  802327:	eb 0c                	jmp    802335 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802329:	83 ec 0c             	sub    $0xc,%esp
  80232c:	50                   	push   %eax
  80232d:	e8 26 ec ff ff       	call   800f58 <sys_ipc_recv>
  802332:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802335:	85 f6                	test   %esi,%esi
  802337:	0f 95 c1             	setne  %cl
  80233a:	85 db                	test   %ebx,%ebx
  80233c:	0f 95 c2             	setne  %dl
  80233f:	84 d1                	test   %dl,%cl
  802341:	74 09                	je     80234c <ipc_recv+0x47>
  802343:	89 c2                	mov    %eax,%edx
  802345:	c1 ea 1f             	shr    $0x1f,%edx
  802348:	84 d2                	test   %dl,%dl
  80234a:	75 2d                	jne    802379 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80234c:	85 f6                	test   %esi,%esi
  80234e:	74 0d                	je     80235d <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802350:	a1 20 44 80 00       	mov    0x804420,%eax
  802355:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80235b:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80235d:	85 db                	test   %ebx,%ebx
  80235f:	74 0d                	je     80236e <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802361:	a1 20 44 80 00       	mov    0x804420,%eax
  802366:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  80236c:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80236e:	a1 20 44 80 00       	mov    0x804420,%eax
  802373:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802379:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80237c:	5b                   	pop    %ebx
  80237d:	5e                   	pop    %esi
  80237e:	5d                   	pop    %ebp
  80237f:	c3                   	ret    

00802380 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	57                   	push   %edi
  802384:	56                   	push   %esi
  802385:	53                   	push   %ebx
  802386:	83 ec 0c             	sub    $0xc,%esp
  802389:	8b 7d 08             	mov    0x8(%ebp),%edi
  80238c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80238f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802392:	85 db                	test   %ebx,%ebx
  802394:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802399:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80239c:	ff 75 14             	pushl  0x14(%ebp)
  80239f:	53                   	push   %ebx
  8023a0:	56                   	push   %esi
  8023a1:	57                   	push   %edi
  8023a2:	e8 8e eb ff ff       	call   800f35 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8023a7:	89 c2                	mov    %eax,%edx
  8023a9:	c1 ea 1f             	shr    $0x1f,%edx
  8023ac:	83 c4 10             	add    $0x10,%esp
  8023af:	84 d2                	test   %dl,%dl
  8023b1:	74 17                	je     8023ca <ipc_send+0x4a>
  8023b3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023b6:	74 12                	je     8023ca <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8023b8:	50                   	push   %eax
  8023b9:	68 68 2c 80 00       	push   $0x802c68
  8023be:	6a 47                	push   $0x47
  8023c0:	68 76 2c 80 00       	push   $0x802c76
  8023c5:	e8 7d df ff ff       	call   800347 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8023ca:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023cd:	75 07                	jne    8023d6 <ipc_send+0x56>
			sys_yield();
  8023cf:	e8 b5 e9 ff ff       	call   800d89 <sys_yield>
  8023d4:	eb c6                	jmp    80239c <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8023d6:	85 c0                	test   %eax,%eax
  8023d8:	75 c2                	jne    80239c <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8023da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023dd:	5b                   	pop    %ebx
  8023de:	5e                   	pop    %esi
  8023df:	5f                   	pop    %edi
  8023e0:	5d                   	pop    %ebp
  8023e1:	c3                   	ret    

008023e2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023e2:	55                   	push   %ebp
  8023e3:	89 e5                	mov    %esp,%ebp
  8023e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023e8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023ed:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8023f3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023f9:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  8023ff:	39 ca                	cmp    %ecx,%edx
  802401:	75 13                	jne    802416 <ipc_find_env+0x34>
			return envs[i].env_id;
  802403:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802409:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80240e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802414:	eb 0f                	jmp    802425 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802416:	83 c0 01             	add    $0x1,%eax
  802419:	3d 00 04 00 00       	cmp    $0x400,%eax
  80241e:	75 cd                	jne    8023ed <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802420:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802425:	5d                   	pop    %ebp
  802426:	c3                   	ret    

00802427 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802427:	55                   	push   %ebp
  802428:	89 e5                	mov    %esp,%ebp
  80242a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80242d:	89 d0                	mov    %edx,%eax
  80242f:	c1 e8 16             	shr    $0x16,%eax
  802432:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802439:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80243e:	f6 c1 01             	test   $0x1,%cl
  802441:	74 1d                	je     802460 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802443:	c1 ea 0c             	shr    $0xc,%edx
  802446:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80244d:	f6 c2 01             	test   $0x1,%dl
  802450:	74 0e                	je     802460 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802452:	c1 ea 0c             	shr    $0xc,%edx
  802455:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80245c:	ef 
  80245d:	0f b7 c0             	movzwl %ax,%eax
}
  802460:	5d                   	pop    %ebp
  802461:	c3                   	ret    
  802462:	66 90                	xchg   %ax,%ax
  802464:	66 90                	xchg   %ax,%ax
  802466:	66 90                	xchg   %ax,%ax
  802468:	66 90                	xchg   %ax,%ax
  80246a:	66 90                	xchg   %ax,%ax
  80246c:	66 90                	xchg   %ax,%ax
  80246e:	66 90                	xchg   %ax,%ax

00802470 <__udivdi3>:
  802470:	55                   	push   %ebp
  802471:	57                   	push   %edi
  802472:	56                   	push   %esi
  802473:	53                   	push   %ebx
  802474:	83 ec 1c             	sub    $0x1c,%esp
  802477:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80247b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80247f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802483:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802487:	85 f6                	test   %esi,%esi
  802489:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80248d:	89 ca                	mov    %ecx,%edx
  80248f:	89 f8                	mov    %edi,%eax
  802491:	75 3d                	jne    8024d0 <__udivdi3+0x60>
  802493:	39 cf                	cmp    %ecx,%edi
  802495:	0f 87 c5 00 00 00    	ja     802560 <__udivdi3+0xf0>
  80249b:	85 ff                	test   %edi,%edi
  80249d:	89 fd                	mov    %edi,%ebp
  80249f:	75 0b                	jne    8024ac <__udivdi3+0x3c>
  8024a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024a6:	31 d2                	xor    %edx,%edx
  8024a8:	f7 f7                	div    %edi
  8024aa:	89 c5                	mov    %eax,%ebp
  8024ac:	89 c8                	mov    %ecx,%eax
  8024ae:	31 d2                	xor    %edx,%edx
  8024b0:	f7 f5                	div    %ebp
  8024b2:	89 c1                	mov    %eax,%ecx
  8024b4:	89 d8                	mov    %ebx,%eax
  8024b6:	89 cf                	mov    %ecx,%edi
  8024b8:	f7 f5                	div    %ebp
  8024ba:	89 c3                	mov    %eax,%ebx
  8024bc:	89 d8                	mov    %ebx,%eax
  8024be:	89 fa                	mov    %edi,%edx
  8024c0:	83 c4 1c             	add    $0x1c,%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5e                   	pop    %esi
  8024c5:	5f                   	pop    %edi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    
  8024c8:	90                   	nop
  8024c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	39 ce                	cmp    %ecx,%esi
  8024d2:	77 74                	ja     802548 <__udivdi3+0xd8>
  8024d4:	0f bd fe             	bsr    %esi,%edi
  8024d7:	83 f7 1f             	xor    $0x1f,%edi
  8024da:	0f 84 98 00 00 00    	je     802578 <__udivdi3+0x108>
  8024e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	89 c5                	mov    %eax,%ebp
  8024e9:	29 fb                	sub    %edi,%ebx
  8024eb:	d3 e6                	shl    %cl,%esi
  8024ed:	89 d9                	mov    %ebx,%ecx
  8024ef:	d3 ed                	shr    %cl,%ebp
  8024f1:	89 f9                	mov    %edi,%ecx
  8024f3:	d3 e0                	shl    %cl,%eax
  8024f5:	09 ee                	or     %ebp,%esi
  8024f7:	89 d9                	mov    %ebx,%ecx
  8024f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024fd:	89 d5                	mov    %edx,%ebp
  8024ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802503:	d3 ed                	shr    %cl,%ebp
  802505:	89 f9                	mov    %edi,%ecx
  802507:	d3 e2                	shl    %cl,%edx
  802509:	89 d9                	mov    %ebx,%ecx
  80250b:	d3 e8                	shr    %cl,%eax
  80250d:	09 c2                	or     %eax,%edx
  80250f:	89 d0                	mov    %edx,%eax
  802511:	89 ea                	mov    %ebp,%edx
  802513:	f7 f6                	div    %esi
  802515:	89 d5                	mov    %edx,%ebp
  802517:	89 c3                	mov    %eax,%ebx
  802519:	f7 64 24 0c          	mull   0xc(%esp)
  80251d:	39 d5                	cmp    %edx,%ebp
  80251f:	72 10                	jb     802531 <__udivdi3+0xc1>
  802521:	8b 74 24 08          	mov    0x8(%esp),%esi
  802525:	89 f9                	mov    %edi,%ecx
  802527:	d3 e6                	shl    %cl,%esi
  802529:	39 c6                	cmp    %eax,%esi
  80252b:	73 07                	jae    802534 <__udivdi3+0xc4>
  80252d:	39 d5                	cmp    %edx,%ebp
  80252f:	75 03                	jne    802534 <__udivdi3+0xc4>
  802531:	83 eb 01             	sub    $0x1,%ebx
  802534:	31 ff                	xor    %edi,%edi
  802536:	89 d8                	mov    %ebx,%eax
  802538:	89 fa                	mov    %edi,%edx
  80253a:	83 c4 1c             	add    $0x1c,%esp
  80253d:	5b                   	pop    %ebx
  80253e:	5e                   	pop    %esi
  80253f:	5f                   	pop    %edi
  802540:	5d                   	pop    %ebp
  802541:	c3                   	ret    
  802542:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802548:	31 ff                	xor    %edi,%edi
  80254a:	31 db                	xor    %ebx,%ebx
  80254c:	89 d8                	mov    %ebx,%eax
  80254e:	89 fa                	mov    %edi,%edx
  802550:	83 c4 1c             	add    $0x1c,%esp
  802553:	5b                   	pop    %ebx
  802554:	5e                   	pop    %esi
  802555:	5f                   	pop    %edi
  802556:	5d                   	pop    %ebp
  802557:	c3                   	ret    
  802558:	90                   	nop
  802559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802560:	89 d8                	mov    %ebx,%eax
  802562:	f7 f7                	div    %edi
  802564:	31 ff                	xor    %edi,%edi
  802566:	89 c3                	mov    %eax,%ebx
  802568:	89 d8                	mov    %ebx,%eax
  80256a:	89 fa                	mov    %edi,%edx
  80256c:	83 c4 1c             	add    $0x1c,%esp
  80256f:	5b                   	pop    %ebx
  802570:	5e                   	pop    %esi
  802571:	5f                   	pop    %edi
  802572:	5d                   	pop    %ebp
  802573:	c3                   	ret    
  802574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802578:	39 ce                	cmp    %ecx,%esi
  80257a:	72 0c                	jb     802588 <__udivdi3+0x118>
  80257c:	31 db                	xor    %ebx,%ebx
  80257e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802582:	0f 87 34 ff ff ff    	ja     8024bc <__udivdi3+0x4c>
  802588:	bb 01 00 00 00       	mov    $0x1,%ebx
  80258d:	e9 2a ff ff ff       	jmp    8024bc <__udivdi3+0x4c>
  802592:	66 90                	xchg   %ax,%ax
  802594:	66 90                	xchg   %ax,%ax
  802596:	66 90                	xchg   %ax,%ax
  802598:	66 90                	xchg   %ax,%ax
  80259a:	66 90                	xchg   %ax,%ax
  80259c:	66 90                	xchg   %ax,%ax
  80259e:	66 90                	xchg   %ax,%ax

008025a0 <__umoddi3>:
  8025a0:	55                   	push   %ebp
  8025a1:	57                   	push   %edi
  8025a2:	56                   	push   %esi
  8025a3:	53                   	push   %ebx
  8025a4:	83 ec 1c             	sub    $0x1c,%esp
  8025a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025b7:	85 d2                	test   %edx,%edx
  8025b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025c1:	89 f3                	mov    %esi,%ebx
  8025c3:	89 3c 24             	mov    %edi,(%esp)
  8025c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ca:	75 1c                	jne    8025e8 <__umoddi3+0x48>
  8025cc:	39 f7                	cmp    %esi,%edi
  8025ce:	76 50                	jbe    802620 <__umoddi3+0x80>
  8025d0:	89 c8                	mov    %ecx,%eax
  8025d2:	89 f2                	mov    %esi,%edx
  8025d4:	f7 f7                	div    %edi
  8025d6:	89 d0                	mov    %edx,%eax
  8025d8:	31 d2                	xor    %edx,%edx
  8025da:	83 c4 1c             	add    $0x1c,%esp
  8025dd:	5b                   	pop    %ebx
  8025de:	5e                   	pop    %esi
  8025df:	5f                   	pop    %edi
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    
  8025e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025e8:	39 f2                	cmp    %esi,%edx
  8025ea:	89 d0                	mov    %edx,%eax
  8025ec:	77 52                	ja     802640 <__umoddi3+0xa0>
  8025ee:	0f bd ea             	bsr    %edx,%ebp
  8025f1:	83 f5 1f             	xor    $0x1f,%ebp
  8025f4:	75 5a                	jne    802650 <__umoddi3+0xb0>
  8025f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025fa:	0f 82 e0 00 00 00    	jb     8026e0 <__umoddi3+0x140>
  802600:	39 0c 24             	cmp    %ecx,(%esp)
  802603:	0f 86 d7 00 00 00    	jbe    8026e0 <__umoddi3+0x140>
  802609:	8b 44 24 08          	mov    0x8(%esp),%eax
  80260d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802611:	83 c4 1c             	add    $0x1c,%esp
  802614:	5b                   	pop    %ebx
  802615:	5e                   	pop    %esi
  802616:	5f                   	pop    %edi
  802617:	5d                   	pop    %ebp
  802618:	c3                   	ret    
  802619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802620:	85 ff                	test   %edi,%edi
  802622:	89 fd                	mov    %edi,%ebp
  802624:	75 0b                	jne    802631 <__umoddi3+0x91>
  802626:	b8 01 00 00 00       	mov    $0x1,%eax
  80262b:	31 d2                	xor    %edx,%edx
  80262d:	f7 f7                	div    %edi
  80262f:	89 c5                	mov    %eax,%ebp
  802631:	89 f0                	mov    %esi,%eax
  802633:	31 d2                	xor    %edx,%edx
  802635:	f7 f5                	div    %ebp
  802637:	89 c8                	mov    %ecx,%eax
  802639:	f7 f5                	div    %ebp
  80263b:	89 d0                	mov    %edx,%eax
  80263d:	eb 99                	jmp    8025d8 <__umoddi3+0x38>
  80263f:	90                   	nop
  802640:	89 c8                	mov    %ecx,%eax
  802642:	89 f2                	mov    %esi,%edx
  802644:	83 c4 1c             	add    $0x1c,%esp
  802647:	5b                   	pop    %ebx
  802648:	5e                   	pop    %esi
  802649:	5f                   	pop    %edi
  80264a:	5d                   	pop    %ebp
  80264b:	c3                   	ret    
  80264c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802650:	8b 34 24             	mov    (%esp),%esi
  802653:	bf 20 00 00 00       	mov    $0x20,%edi
  802658:	89 e9                	mov    %ebp,%ecx
  80265a:	29 ef                	sub    %ebp,%edi
  80265c:	d3 e0                	shl    %cl,%eax
  80265e:	89 f9                	mov    %edi,%ecx
  802660:	89 f2                	mov    %esi,%edx
  802662:	d3 ea                	shr    %cl,%edx
  802664:	89 e9                	mov    %ebp,%ecx
  802666:	09 c2                	or     %eax,%edx
  802668:	89 d8                	mov    %ebx,%eax
  80266a:	89 14 24             	mov    %edx,(%esp)
  80266d:	89 f2                	mov    %esi,%edx
  80266f:	d3 e2                	shl    %cl,%edx
  802671:	89 f9                	mov    %edi,%ecx
  802673:	89 54 24 04          	mov    %edx,0x4(%esp)
  802677:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80267b:	d3 e8                	shr    %cl,%eax
  80267d:	89 e9                	mov    %ebp,%ecx
  80267f:	89 c6                	mov    %eax,%esi
  802681:	d3 e3                	shl    %cl,%ebx
  802683:	89 f9                	mov    %edi,%ecx
  802685:	89 d0                	mov    %edx,%eax
  802687:	d3 e8                	shr    %cl,%eax
  802689:	89 e9                	mov    %ebp,%ecx
  80268b:	09 d8                	or     %ebx,%eax
  80268d:	89 d3                	mov    %edx,%ebx
  80268f:	89 f2                	mov    %esi,%edx
  802691:	f7 34 24             	divl   (%esp)
  802694:	89 d6                	mov    %edx,%esi
  802696:	d3 e3                	shl    %cl,%ebx
  802698:	f7 64 24 04          	mull   0x4(%esp)
  80269c:	39 d6                	cmp    %edx,%esi
  80269e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026a2:	89 d1                	mov    %edx,%ecx
  8026a4:	89 c3                	mov    %eax,%ebx
  8026a6:	72 08                	jb     8026b0 <__umoddi3+0x110>
  8026a8:	75 11                	jne    8026bb <__umoddi3+0x11b>
  8026aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026ae:	73 0b                	jae    8026bb <__umoddi3+0x11b>
  8026b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026b4:	1b 14 24             	sbb    (%esp),%edx
  8026b7:	89 d1                	mov    %edx,%ecx
  8026b9:	89 c3                	mov    %eax,%ebx
  8026bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026bf:	29 da                	sub    %ebx,%edx
  8026c1:	19 ce                	sbb    %ecx,%esi
  8026c3:	89 f9                	mov    %edi,%ecx
  8026c5:	89 f0                	mov    %esi,%eax
  8026c7:	d3 e0                	shl    %cl,%eax
  8026c9:	89 e9                	mov    %ebp,%ecx
  8026cb:	d3 ea                	shr    %cl,%edx
  8026cd:	89 e9                	mov    %ebp,%ecx
  8026cf:	d3 ee                	shr    %cl,%esi
  8026d1:	09 d0                	or     %edx,%eax
  8026d3:	89 f2                	mov    %esi,%edx
  8026d5:	83 c4 1c             	add    $0x1c,%esp
  8026d8:	5b                   	pop    %ebx
  8026d9:	5e                   	pop    %esi
  8026da:	5f                   	pop    %edi
  8026db:	5d                   	pop    %ebp
  8026dc:	c3                   	ret    
  8026dd:	8d 76 00             	lea    0x0(%esi),%esi
  8026e0:	29 f9                	sub    %edi,%ecx
  8026e2:	19 d6                	sbb    %edx,%esi
  8026e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026ec:	e9 18 ff ff ff       	jmp    802609 <__umoddi3+0x69>
