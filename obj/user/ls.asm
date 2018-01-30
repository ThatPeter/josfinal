
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
  80005a:	68 62 29 80 00       	push   $0x802962
  80005f:	e8 76 1f 00 00       	call   801fda <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 e7 2d 80 00       	mov    $0x802de7,%eax
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
  800086:	ba e7 2d 80 00       	mov    $0x802de7,%edx
  80008b:	b8 60 29 80 00       	mov    $0x802960,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 6b 29 80 00       	push   $0x80296b
  80009d:	e8 38 1f 00 00       	call   801fda <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 51 2f 80 00       	push   $0x802f51
  8000b0:	e8 25 1f 00 00       	call   801fda <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 60 29 80 00       	push   $0x802960
  8000cf:	e8 06 1f 00 00       	call   801fda <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 e6 2d 80 00       	push   $0x802de6
  8000df:	e8 f6 1e 00 00       	call   801fda <printf>
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
  800100:	e8 37 1d 00 00       	call   801e3c <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 70 29 80 00       	push   $0x802970
  800118:	6a 1d                	push   $0x1d
  80011a:	68 7c 29 80 00       	push   $0x80297c
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
  80015f:	e8 d8 18 00 00       	call   801a3c <readn>
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
  800173:	68 86 29 80 00       	push   $0x802986
  800178:	6a 22                	push   $0x22
  80017a:	68 7c 29 80 00       	push   $0x80297c
  80017f:	e8 c3 01 00 00       	call   800347 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 cc 29 80 00       	push   $0x8029cc
  800192:	6a 24                	push   $0x24
  800194:	68 7c 29 80 00       	push   $0x80297c
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
  8001bb:	e8 87 1a 00 00       	call   801c47 <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 a1 29 80 00       	push   $0x8029a1
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 7c 29 80 00       	push   $0x80297c
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
  800220:	68 ad 29 80 00       	push   $0x8029ad
  800225:	e8 b0 1d 00 00       	call   801fda <printf>
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
  800248:	e8 28 13 00 00       	call   801575 <argstart>
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
  800277:	e8 29 13 00 00       	call   8015a5 <argnext>
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
  800291:	68 e7 2d 80 00       	push   $0x802de7
  800296:	68 60 29 80 00       	push   $0x802960
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
  800333:	e8 5f 15 00 00       	call   801897 <close_all>
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
  800365:	68 f8 29 80 00       	push   $0x8029f8
  80036a:	e8 b1 00 00 00       	call   800420 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80036f:	83 c4 18             	add    $0x18,%esp
  800372:	53                   	push   %ebx
  800373:	ff 75 10             	pushl  0x10(%ebp)
  800376:	e8 54 00 00 00       	call   8003cf <vcprintf>
	cprintf("\n");
  80037b:	c7 04 24 e6 2d 80 00 	movl   $0x802de6,(%esp)
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
  800483:	e8 48 22 00 00       	call   8026d0 <__udivdi3>
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
  8004c6:	e8 35 23 00 00       	call   802800 <__umoddi3>
  8004cb:	83 c4 14             	add    $0x14,%esp
  8004ce:	0f be 80 1b 2a 80 00 	movsbl 0x802a1b(%eax),%eax
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
  8005ca:	ff 24 85 60 2b 80 00 	jmp    *0x802b60(,%eax,4)
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
  80068e:	8b 14 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%edx
  800695:	85 d2                	test   %edx,%edx
  800697:	75 18                	jne    8006b1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800699:	50                   	push   %eax
  80069a:	68 33 2a 80 00       	push   $0x802a33
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
  8006b2:	68 51 2f 80 00       	push   $0x802f51
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
  8006d6:	b8 2c 2a 80 00       	mov    $0x802a2c,%eax
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
  800d51:	68 1f 2d 80 00       	push   $0x802d1f
  800d56:	6a 23                	push   $0x23
  800d58:	68 3c 2d 80 00       	push   $0x802d3c
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
  800dd2:	68 1f 2d 80 00       	push   $0x802d1f
  800dd7:	6a 23                	push   $0x23
  800dd9:	68 3c 2d 80 00       	push   $0x802d3c
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
  800e14:	68 1f 2d 80 00       	push   $0x802d1f
  800e19:	6a 23                	push   $0x23
  800e1b:	68 3c 2d 80 00       	push   $0x802d3c
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
  800e56:	68 1f 2d 80 00       	push   $0x802d1f
  800e5b:	6a 23                	push   $0x23
  800e5d:	68 3c 2d 80 00       	push   $0x802d3c
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
  800e98:	68 1f 2d 80 00       	push   $0x802d1f
  800e9d:	6a 23                	push   $0x23
  800e9f:	68 3c 2d 80 00       	push   $0x802d3c
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
  800eda:	68 1f 2d 80 00       	push   $0x802d1f
  800edf:	6a 23                	push   $0x23
  800ee1:	68 3c 2d 80 00       	push   $0x802d3c
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
  800f1c:	68 1f 2d 80 00       	push   $0x802d1f
  800f21:	6a 23                	push   $0x23
  800f23:	68 3c 2d 80 00       	push   $0x802d3c
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
  800f80:	68 1f 2d 80 00       	push   $0x802d1f
  800f85:	6a 23                	push   $0x23
  800f87:	68 3c 2d 80 00       	push   $0x802d3c
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
  80101f:	68 4a 2d 80 00       	push   $0x802d4a
  801024:	6a 1f                	push   $0x1f
  801026:	68 5a 2d 80 00       	push   $0x802d5a
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
  801049:	68 65 2d 80 00       	push   $0x802d65
  80104e:	6a 2d                	push   $0x2d
  801050:	68 5a 2d 80 00       	push   $0x802d5a
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
  801091:	68 65 2d 80 00       	push   $0x802d65
  801096:	6a 34                	push   $0x34
  801098:	68 5a 2d 80 00       	push   $0x802d5a
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
  8010b9:	68 65 2d 80 00       	push   $0x802d65
  8010be:	6a 38                	push   $0x38
  8010c0:	68 5a 2d 80 00       	push   $0x802d5a
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
  8010dd:	e8 f6 13 00 00       	call   8024d8 <set_pgfault_handler>
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
  8010f6:	68 7e 2d 80 00       	push   $0x802d7e
  8010fb:	68 85 00 00 00       	push   $0x85
  801100:	68 5a 2d 80 00       	push   $0x802d5a
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
  8011b2:	68 8c 2d 80 00       	push   $0x802d8c
  8011b7:	6a 55                	push   $0x55
  8011b9:	68 5a 2d 80 00       	push   $0x802d5a
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
  8011f7:	68 8c 2d 80 00       	push   $0x802d8c
  8011fc:	6a 5c                	push   $0x5c
  8011fe:	68 5a 2d 80 00       	push   $0x802d5a
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
  801225:	68 8c 2d 80 00       	push   $0x802d8c
  80122a:	6a 60                	push   $0x60
  80122c:	68 5a 2d 80 00       	push   $0x802d5a
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
  80124f:	68 8c 2d 80 00       	push   $0x802d8c
  801254:	6a 65                	push   $0x65
  801256:	68 5a 2d 80 00       	push   $0x802d5a
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
  8012be:	68 1c 2e 80 00       	push   $0x802e1c
  8012c3:	e8 58 f1 ff ff       	call   800420 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8012c8:	c7 04 24 0d 03 80 00 	movl   $0x80030d,(%esp)
  8012cf:	e8 c5 fc ff ff       	call   800f99 <sys_thread_create>
  8012d4:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8012d6:	83 c4 08             	add    $0x8,%esp
  8012d9:	53                   	push   %ebx
  8012da:	68 1c 2e 80 00       	push   $0x802e1c
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

00801313 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	56                   	push   %esi
  801317:	53                   	push   %ebx
  801318:	8b 75 08             	mov    0x8(%ebp),%esi
  80131b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  80131e:	83 ec 04             	sub    $0x4,%esp
  801321:	6a 07                	push   $0x7
  801323:	6a 00                	push   $0x0
  801325:	56                   	push   %esi
  801326:	e8 7d fa ff ff       	call   800da8 <sys_page_alloc>
	if (r < 0) {
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	85 c0                	test   %eax,%eax
  801330:	79 15                	jns    801347 <queue_append+0x34>
		panic("%e\n", r);
  801332:	50                   	push   %eax
  801333:	68 18 2e 80 00       	push   $0x802e18
  801338:	68 c4 00 00 00       	push   $0xc4
  80133d:	68 5a 2d 80 00       	push   $0x802d5a
  801342:	e8 00 f0 ff ff       	call   800347 <_panic>
	}	
	wt->envid = envid;
  801347:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  80134d:	83 ec 04             	sub    $0x4,%esp
  801350:	ff 33                	pushl  (%ebx)
  801352:	56                   	push   %esi
  801353:	68 40 2e 80 00       	push   $0x802e40
  801358:	e8 c3 f0 ff ff       	call   800420 <cprintf>
	if (queue->first == NULL) {
  80135d:	83 c4 10             	add    $0x10,%esp
  801360:	83 3b 00             	cmpl   $0x0,(%ebx)
  801363:	75 29                	jne    80138e <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  801365:	83 ec 0c             	sub    $0xc,%esp
  801368:	68 a2 2d 80 00       	push   $0x802da2
  80136d:	e8 ae f0 ff ff       	call   800420 <cprintf>
		queue->first = wt;
  801372:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  801378:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80137f:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801386:	00 00 00 
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	eb 2b                	jmp    8013b9 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  80138e:	83 ec 0c             	sub    $0xc,%esp
  801391:	68 bc 2d 80 00       	push   $0x802dbc
  801396:	e8 85 f0 ff ff       	call   800420 <cprintf>
		queue->last->next = wt;
  80139b:	8b 43 04             	mov    0x4(%ebx),%eax
  80139e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8013a5:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8013ac:	00 00 00 
		queue->last = wt;
  8013af:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  8013b6:	83 c4 10             	add    $0x10,%esp
	}
}
  8013b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bc:	5b                   	pop    %ebx
  8013bd:	5e                   	pop    %esi
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	53                   	push   %ebx
  8013c4:	83 ec 04             	sub    $0x4,%esp
  8013c7:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8013ca:	8b 02                	mov    (%edx),%eax
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	75 17                	jne    8013e7 <queue_pop+0x27>
		panic("queue empty!\n");
  8013d0:	83 ec 04             	sub    $0x4,%esp
  8013d3:	68 da 2d 80 00       	push   $0x802dda
  8013d8:	68 d8 00 00 00       	push   $0xd8
  8013dd:	68 5a 2d 80 00       	push   $0x802d5a
  8013e2:	e8 60 ef ff ff       	call   800347 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8013e7:	8b 48 04             	mov    0x4(%eax),%ecx
  8013ea:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8013ec:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8013ee:	83 ec 08             	sub    $0x8,%esp
  8013f1:	53                   	push   %ebx
  8013f2:	68 e8 2d 80 00       	push   $0x802de8
  8013f7:	e8 24 f0 ff ff       	call   800420 <cprintf>
	return envid;
}
  8013fc:	89 d8                	mov    %ebx,%eax
  8013fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801401:	c9                   	leave  
  801402:	c3                   	ret    

00801403 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	53                   	push   %ebx
  801407:	83 ec 04             	sub    $0x4,%esp
  80140a:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80140d:	b8 01 00 00 00       	mov    $0x1,%eax
  801412:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801415:	85 c0                	test   %eax,%eax
  801417:	74 5a                	je     801473 <mutex_lock+0x70>
  801419:	8b 43 04             	mov    0x4(%ebx),%eax
  80141c:	83 38 00             	cmpl   $0x0,(%eax)
  80141f:	75 52                	jne    801473 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801421:	83 ec 0c             	sub    $0xc,%esp
  801424:	68 68 2e 80 00       	push   $0x802e68
  801429:	e8 f2 ef ff ff       	call   800420 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  80142e:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801431:	e8 34 f9 ff ff       	call   800d6a <sys_getenvid>
  801436:	83 c4 08             	add    $0x8,%esp
  801439:	53                   	push   %ebx
  80143a:	50                   	push   %eax
  80143b:	e8 d3 fe ff ff       	call   801313 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801440:	e8 25 f9 ff ff       	call   800d6a <sys_getenvid>
  801445:	83 c4 08             	add    $0x8,%esp
  801448:	6a 04                	push   $0x4
  80144a:	50                   	push   %eax
  80144b:	e8 1f fa ff ff       	call   800e6f <sys_env_set_status>
		if (r < 0) {
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	79 15                	jns    80146c <mutex_lock+0x69>
			panic("%e\n", r);
  801457:	50                   	push   %eax
  801458:	68 18 2e 80 00       	push   $0x802e18
  80145d:	68 eb 00 00 00       	push   $0xeb
  801462:	68 5a 2d 80 00       	push   $0x802d5a
  801467:	e8 db ee ff ff       	call   800347 <_panic>
		}
		sys_yield();
  80146c:	e8 18 f9 ff ff       	call   800d89 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801471:	eb 18                	jmp    80148b <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  801473:	83 ec 0c             	sub    $0xc,%esp
  801476:	68 88 2e 80 00       	push   $0x802e88
  80147b:	e8 a0 ef ff ff       	call   800420 <cprintf>
	mtx->owner = sys_getenvid();}
  801480:	e8 e5 f8 ff ff       	call   800d6a <sys_getenvid>
  801485:	89 43 08             	mov    %eax,0x8(%ebx)
  801488:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  80148b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148e:	c9                   	leave  
  80148f:	c3                   	ret    

00801490 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	53                   	push   %ebx
  801494:	83 ec 04             	sub    $0x4,%esp
  801497:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80149a:	b8 00 00 00 00       	mov    $0x0,%eax
  80149f:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8014a2:	8b 43 04             	mov    0x4(%ebx),%eax
  8014a5:	83 38 00             	cmpl   $0x0,(%eax)
  8014a8:	74 33                	je     8014dd <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8014aa:	83 ec 0c             	sub    $0xc,%esp
  8014ad:	50                   	push   %eax
  8014ae:	e8 0d ff ff ff       	call   8013c0 <queue_pop>
  8014b3:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8014b6:	83 c4 08             	add    $0x8,%esp
  8014b9:	6a 02                	push   $0x2
  8014bb:	50                   	push   %eax
  8014bc:	e8 ae f9 ff ff       	call   800e6f <sys_env_set_status>
		if (r < 0) {
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	79 15                	jns    8014dd <mutex_unlock+0x4d>
			panic("%e\n", r);
  8014c8:	50                   	push   %eax
  8014c9:	68 18 2e 80 00       	push   $0x802e18
  8014ce:	68 00 01 00 00       	push   $0x100
  8014d3:	68 5a 2d 80 00       	push   $0x802d5a
  8014d8:	e8 6a ee ff ff       	call   800347 <_panic>
		}
	}

	asm volatile("pause");
  8014dd:	f3 90                	pause  
	//sys_yield();
}
  8014df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    

008014e4 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	53                   	push   %ebx
  8014e8:	83 ec 04             	sub    $0x4,%esp
  8014eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8014ee:	e8 77 f8 ff ff       	call   800d6a <sys_getenvid>
  8014f3:	83 ec 04             	sub    $0x4,%esp
  8014f6:	6a 07                	push   $0x7
  8014f8:	53                   	push   %ebx
  8014f9:	50                   	push   %eax
  8014fa:	e8 a9 f8 ff ff       	call   800da8 <sys_page_alloc>
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	85 c0                	test   %eax,%eax
  801504:	79 15                	jns    80151b <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801506:	50                   	push   %eax
  801507:	68 03 2e 80 00       	push   $0x802e03
  80150c:	68 0d 01 00 00       	push   $0x10d
  801511:	68 5a 2d 80 00       	push   $0x802d5a
  801516:	e8 2c ee ff ff       	call   800347 <_panic>
	}	
	mtx->locked = 0;
  80151b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801521:	8b 43 04             	mov    0x4(%ebx),%eax
  801524:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80152a:	8b 43 04             	mov    0x4(%ebx),%eax
  80152d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801534:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80153b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153e:	c9                   	leave  
  80153f:	c3                   	ret    

00801540 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  801546:	e8 1f f8 ff ff       	call   800d6a <sys_getenvid>
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	ff 75 08             	pushl  0x8(%ebp)
  801551:	50                   	push   %eax
  801552:	e8 d6 f8 ff ff       	call   800e2d <sys_page_unmap>
	if (r < 0) {
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	85 c0                	test   %eax,%eax
  80155c:	79 15                	jns    801573 <mutex_destroy+0x33>
		panic("%e\n", r);
  80155e:	50                   	push   %eax
  80155f:	68 18 2e 80 00       	push   $0x802e18
  801564:	68 1a 01 00 00       	push   $0x11a
  801569:	68 5a 2d 80 00       	push   $0x802d5a
  80156e:	e8 d4 ed ff ff       	call   800347 <_panic>
	}
}
  801573:	c9                   	leave  
  801574:	c3                   	ret    

00801575 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	8b 55 08             	mov    0x8(%ebp),%edx
  80157b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80157e:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801581:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801583:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801586:	83 3a 01             	cmpl   $0x1,(%edx)
  801589:	7e 09                	jle    801594 <argstart+0x1f>
  80158b:	ba e7 2d 80 00       	mov    $0x802de7,%edx
  801590:	85 c9                	test   %ecx,%ecx
  801592:	75 05                	jne    801599 <argstart+0x24>
  801594:	ba 00 00 00 00       	mov    $0x0,%edx
  801599:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  80159c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    

008015a5 <argnext>:

int
argnext(struct Argstate *args)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 04             	sub    $0x4,%esp
  8015ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  8015af:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  8015b6:	8b 43 08             	mov    0x8(%ebx),%eax
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	74 6f                	je     80162c <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  8015bd:	80 38 00             	cmpb   $0x0,(%eax)
  8015c0:	75 4e                	jne    801610 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  8015c2:	8b 0b                	mov    (%ebx),%ecx
  8015c4:	83 39 01             	cmpl   $0x1,(%ecx)
  8015c7:	74 55                	je     80161e <argnext+0x79>
		    || args->argv[1][0] != '-'
  8015c9:	8b 53 04             	mov    0x4(%ebx),%edx
  8015cc:	8b 42 04             	mov    0x4(%edx),%eax
  8015cf:	80 38 2d             	cmpb   $0x2d,(%eax)
  8015d2:	75 4a                	jne    80161e <argnext+0x79>
		    || args->argv[1][1] == '\0')
  8015d4:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8015d8:	74 44                	je     80161e <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  8015da:	83 c0 01             	add    $0x1,%eax
  8015dd:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8015e0:	83 ec 04             	sub    $0x4,%esp
  8015e3:	8b 01                	mov    (%ecx),%eax
  8015e5:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8015ec:	50                   	push   %eax
  8015ed:	8d 42 08             	lea    0x8(%edx),%eax
  8015f0:	50                   	push   %eax
  8015f1:	83 c2 04             	add    $0x4,%edx
  8015f4:	52                   	push   %edx
  8015f5:	e8 3d f5 ff ff       	call   800b37 <memmove>
		(*args->argc)--;
  8015fa:	8b 03                	mov    (%ebx),%eax
  8015fc:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8015ff:	8b 43 08             	mov    0x8(%ebx),%eax
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	80 38 2d             	cmpb   $0x2d,(%eax)
  801608:	75 06                	jne    801610 <argnext+0x6b>
  80160a:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80160e:	74 0e                	je     80161e <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801610:	8b 53 08             	mov    0x8(%ebx),%edx
  801613:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801616:	83 c2 01             	add    $0x1,%edx
  801619:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  80161c:	eb 13                	jmp    801631 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  80161e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801625:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80162a:	eb 05                	jmp    801631 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  80162c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801631:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801634:	c9                   	leave  
  801635:	c3                   	ret    

00801636 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	53                   	push   %ebx
  80163a:	83 ec 04             	sub    $0x4,%esp
  80163d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801640:	8b 43 08             	mov    0x8(%ebx),%eax
  801643:	85 c0                	test   %eax,%eax
  801645:	74 58                	je     80169f <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801647:	80 38 00             	cmpb   $0x0,(%eax)
  80164a:	74 0c                	je     801658 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  80164c:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  80164f:	c7 43 08 e7 2d 80 00 	movl   $0x802de7,0x8(%ebx)
  801656:	eb 42                	jmp    80169a <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801658:	8b 13                	mov    (%ebx),%edx
  80165a:	83 3a 01             	cmpl   $0x1,(%edx)
  80165d:	7e 2d                	jle    80168c <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  80165f:	8b 43 04             	mov    0x4(%ebx),%eax
  801662:	8b 48 04             	mov    0x4(%eax),%ecx
  801665:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801668:	83 ec 04             	sub    $0x4,%esp
  80166b:	8b 12                	mov    (%edx),%edx
  80166d:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801674:	52                   	push   %edx
  801675:	8d 50 08             	lea    0x8(%eax),%edx
  801678:	52                   	push   %edx
  801679:	83 c0 04             	add    $0x4,%eax
  80167c:	50                   	push   %eax
  80167d:	e8 b5 f4 ff ff       	call   800b37 <memmove>
		(*args->argc)--;
  801682:	8b 03                	mov    (%ebx),%eax
  801684:	83 28 01             	subl   $0x1,(%eax)
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	eb 0e                	jmp    80169a <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  80168c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801693:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  80169a:	8b 43 0c             	mov    0xc(%ebx),%eax
  80169d:	eb 05                	jmp    8016a4 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  80169f:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8016a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a7:	c9                   	leave  
  8016a8:	c3                   	ret    

008016a9 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	83 ec 08             	sub    $0x8,%esp
  8016af:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8016b2:	8b 51 0c             	mov    0xc(%ecx),%edx
  8016b5:	89 d0                	mov    %edx,%eax
  8016b7:	85 d2                	test   %edx,%edx
  8016b9:	75 0c                	jne    8016c7 <argvalue+0x1e>
  8016bb:	83 ec 0c             	sub    $0xc,%esp
  8016be:	51                   	push   %ecx
  8016bf:	e8 72 ff ff ff       	call   801636 <argnextvalue>
  8016c4:	83 c4 10             	add    $0x10,%esp
}
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8016cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cf:	05 00 00 00 30       	add    $0x30000000,%eax
  8016d4:	c1 e8 0c             	shr    $0xc,%eax
}
  8016d7:	5d                   	pop    %ebp
  8016d8:	c3                   	ret    

008016d9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8016dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016df:	05 00 00 00 30       	add    $0x30000000,%eax
  8016e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8016e9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    

008016f0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8016fb:	89 c2                	mov    %eax,%edx
  8016fd:	c1 ea 16             	shr    $0x16,%edx
  801700:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801707:	f6 c2 01             	test   $0x1,%dl
  80170a:	74 11                	je     80171d <fd_alloc+0x2d>
  80170c:	89 c2                	mov    %eax,%edx
  80170e:	c1 ea 0c             	shr    $0xc,%edx
  801711:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801718:	f6 c2 01             	test   $0x1,%dl
  80171b:	75 09                	jne    801726 <fd_alloc+0x36>
			*fd_store = fd;
  80171d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80171f:	b8 00 00 00 00       	mov    $0x0,%eax
  801724:	eb 17                	jmp    80173d <fd_alloc+0x4d>
  801726:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80172b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801730:	75 c9                	jne    8016fb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801732:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801738:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80173d:	5d                   	pop    %ebp
  80173e:	c3                   	ret    

0080173f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801745:	83 f8 1f             	cmp    $0x1f,%eax
  801748:	77 36                	ja     801780 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80174a:	c1 e0 0c             	shl    $0xc,%eax
  80174d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801752:	89 c2                	mov    %eax,%edx
  801754:	c1 ea 16             	shr    $0x16,%edx
  801757:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80175e:	f6 c2 01             	test   $0x1,%dl
  801761:	74 24                	je     801787 <fd_lookup+0x48>
  801763:	89 c2                	mov    %eax,%edx
  801765:	c1 ea 0c             	shr    $0xc,%edx
  801768:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80176f:	f6 c2 01             	test   $0x1,%dl
  801772:	74 1a                	je     80178e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801774:	8b 55 0c             	mov    0xc(%ebp),%edx
  801777:	89 02                	mov    %eax,(%edx)
	return 0;
  801779:	b8 00 00 00 00       	mov    $0x0,%eax
  80177e:	eb 13                	jmp    801793 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801780:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801785:	eb 0c                	jmp    801793 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801787:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80178c:	eb 05                	jmp    801793 <fd_lookup+0x54>
  80178e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	83 ec 08             	sub    $0x8,%esp
  80179b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179e:	ba 28 2f 80 00       	mov    $0x802f28,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8017a3:	eb 13                	jmp    8017b8 <dev_lookup+0x23>
  8017a5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8017a8:	39 08                	cmp    %ecx,(%eax)
  8017aa:	75 0c                	jne    8017b8 <dev_lookup+0x23>
			*dev = devtab[i];
  8017ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8017b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b6:	eb 31                	jmp    8017e9 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017b8:	8b 02                	mov    (%edx),%eax
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	75 e7                	jne    8017a5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017be:	a1 20 44 80 00       	mov    0x804420,%eax
  8017c3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8017c9:	83 ec 04             	sub    $0x4,%esp
  8017cc:	51                   	push   %ecx
  8017cd:	50                   	push   %eax
  8017ce:	68 a8 2e 80 00       	push   $0x802ea8
  8017d3:	e8 48 ec ff ff       	call   800420 <cprintf>
	*dev = 0;
  8017d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017db:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017e9:	c9                   	leave  
  8017ea:	c3                   	ret    

008017eb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	56                   	push   %esi
  8017ef:	53                   	push   %ebx
  8017f0:	83 ec 10             	sub    $0x10,%esp
  8017f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8017f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8017f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fc:	50                   	push   %eax
  8017fd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801803:	c1 e8 0c             	shr    $0xc,%eax
  801806:	50                   	push   %eax
  801807:	e8 33 ff ff ff       	call   80173f <fd_lookup>
  80180c:	83 c4 08             	add    $0x8,%esp
  80180f:	85 c0                	test   %eax,%eax
  801811:	78 05                	js     801818 <fd_close+0x2d>
	    || fd != fd2)
  801813:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801816:	74 0c                	je     801824 <fd_close+0x39>
		return (must_exist ? r : 0);
  801818:	84 db                	test   %bl,%bl
  80181a:	ba 00 00 00 00       	mov    $0x0,%edx
  80181f:	0f 44 c2             	cmove  %edx,%eax
  801822:	eb 41                	jmp    801865 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801824:	83 ec 08             	sub    $0x8,%esp
  801827:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182a:	50                   	push   %eax
  80182b:	ff 36                	pushl  (%esi)
  80182d:	e8 63 ff ff ff       	call   801795 <dev_lookup>
  801832:	89 c3                	mov    %eax,%ebx
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	85 c0                	test   %eax,%eax
  801839:	78 1a                	js     801855 <fd_close+0x6a>
		if (dev->dev_close)
  80183b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801841:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801846:	85 c0                	test   %eax,%eax
  801848:	74 0b                	je     801855 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80184a:	83 ec 0c             	sub    $0xc,%esp
  80184d:	56                   	push   %esi
  80184e:	ff d0                	call   *%eax
  801850:	89 c3                	mov    %eax,%ebx
  801852:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801855:	83 ec 08             	sub    $0x8,%esp
  801858:	56                   	push   %esi
  801859:	6a 00                	push   $0x0
  80185b:	e8 cd f5 ff ff       	call   800e2d <sys_page_unmap>
	return r;
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	89 d8                	mov    %ebx,%eax
}
  801865:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801868:	5b                   	pop    %ebx
  801869:	5e                   	pop    %esi
  80186a:	5d                   	pop    %ebp
  80186b:	c3                   	ret    

0080186c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801872:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801875:	50                   	push   %eax
  801876:	ff 75 08             	pushl  0x8(%ebp)
  801879:	e8 c1 fe ff ff       	call   80173f <fd_lookup>
  80187e:	83 c4 08             	add    $0x8,%esp
  801881:	85 c0                	test   %eax,%eax
  801883:	78 10                	js     801895 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801885:	83 ec 08             	sub    $0x8,%esp
  801888:	6a 01                	push   $0x1
  80188a:	ff 75 f4             	pushl  -0xc(%ebp)
  80188d:	e8 59 ff ff ff       	call   8017eb <fd_close>
  801892:	83 c4 10             	add    $0x10,%esp
}
  801895:	c9                   	leave  
  801896:	c3                   	ret    

00801897 <close_all>:

void
close_all(void)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	53                   	push   %ebx
  80189b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80189e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8018a3:	83 ec 0c             	sub    $0xc,%esp
  8018a6:	53                   	push   %ebx
  8018a7:	e8 c0 ff ff ff       	call   80186c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8018ac:	83 c3 01             	add    $0x1,%ebx
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	83 fb 20             	cmp    $0x20,%ebx
  8018b5:	75 ec                	jne    8018a3 <close_all+0xc>
		close(i);
}
  8018b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	57                   	push   %edi
  8018c0:	56                   	push   %esi
  8018c1:	53                   	push   %ebx
  8018c2:	83 ec 2c             	sub    $0x2c,%esp
  8018c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8018c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018cb:	50                   	push   %eax
  8018cc:	ff 75 08             	pushl  0x8(%ebp)
  8018cf:	e8 6b fe ff ff       	call   80173f <fd_lookup>
  8018d4:	83 c4 08             	add    $0x8,%esp
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	0f 88 c1 00 00 00    	js     8019a0 <dup+0xe4>
		return r;
	close(newfdnum);
  8018df:	83 ec 0c             	sub    $0xc,%esp
  8018e2:	56                   	push   %esi
  8018e3:	e8 84 ff ff ff       	call   80186c <close>

	newfd = INDEX2FD(newfdnum);
  8018e8:	89 f3                	mov    %esi,%ebx
  8018ea:	c1 e3 0c             	shl    $0xc,%ebx
  8018ed:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8018f3:	83 c4 04             	add    $0x4,%esp
  8018f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018f9:	e8 db fd ff ff       	call   8016d9 <fd2data>
  8018fe:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801900:	89 1c 24             	mov    %ebx,(%esp)
  801903:	e8 d1 fd ff ff       	call   8016d9 <fd2data>
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80190e:	89 f8                	mov    %edi,%eax
  801910:	c1 e8 16             	shr    $0x16,%eax
  801913:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80191a:	a8 01                	test   $0x1,%al
  80191c:	74 37                	je     801955 <dup+0x99>
  80191e:	89 f8                	mov    %edi,%eax
  801920:	c1 e8 0c             	shr    $0xc,%eax
  801923:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80192a:	f6 c2 01             	test   $0x1,%dl
  80192d:	74 26                	je     801955 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80192f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801936:	83 ec 0c             	sub    $0xc,%esp
  801939:	25 07 0e 00 00       	and    $0xe07,%eax
  80193e:	50                   	push   %eax
  80193f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801942:	6a 00                	push   $0x0
  801944:	57                   	push   %edi
  801945:	6a 00                	push   $0x0
  801947:	e8 9f f4 ff ff       	call   800deb <sys_page_map>
  80194c:	89 c7                	mov    %eax,%edi
  80194e:	83 c4 20             	add    $0x20,%esp
  801951:	85 c0                	test   %eax,%eax
  801953:	78 2e                	js     801983 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801955:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801958:	89 d0                	mov    %edx,%eax
  80195a:	c1 e8 0c             	shr    $0xc,%eax
  80195d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801964:	83 ec 0c             	sub    $0xc,%esp
  801967:	25 07 0e 00 00       	and    $0xe07,%eax
  80196c:	50                   	push   %eax
  80196d:	53                   	push   %ebx
  80196e:	6a 00                	push   $0x0
  801970:	52                   	push   %edx
  801971:	6a 00                	push   $0x0
  801973:	e8 73 f4 ff ff       	call   800deb <sys_page_map>
  801978:	89 c7                	mov    %eax,%edi
  80197a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80197d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80197f:	85 ff                	test   %edi,%edi
  801981:	79 1d                	jns    8019a0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801983:	83 ec 08             	sub    $0x8,%esp
  801986:	53                   	push   %ebx
  801987:	6a 00                	push   $0x0
  801989:	e8 9f f4 ff ff       	call   800e2d <sys_page_unmap>
	sys_page_unmap(0, nva);
  80198e:	83 c4 08             	add    $0x8,%esp
  801991:	ff 75 d4             	pushl  -0x2c(%ebp)
  801994:	6a 00                	push   $0x0
  801996:	e8 92 f4 ff ff       	call   800e2d <sys_page_unmap>
	return r;
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	89 f8                	mov    %edi,%eax
}
  8019a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a3:	5b                   	pop    %ebx
  8019a4:	5e                   	pop    %esi
  8019a5:	5f                   	pop    %edi
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    

008019a8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	53                   	push   %ebx
  8019ac:	83 ec 14             	sub    $0x14,%esp
  8019af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b5:	50                   	push   %eax
  8019b6:	53                   	push   %ebx
  8019b7:	e8 83 fd ff ff       	call   80173f <fd_lookup>
  8019bc:	83 c4 08             	add    $0x8,%esp
  8019bf:	89 c2                	mov    %eax,%edx
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	78 70                	js     801a35 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c5:	83 ec 08             	sub    $0x8,%esp
  8019c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019cb:	50                   	push   %eax
  8019cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019cf:	ff 30                	pushl  (%eax)
  8019d1:	e8 bf fd ff ff       	call   801795 <dev_lookup>
  8019d6:	83 c4 10             	add    $0x10,%esp
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	78 4f                	js     801a2c <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019e0:	8b 42 08             	mov    0x8(%edx),%eax
  8019e3:	83 e0 03             	and    $0x3,%eax
  8019e6:	83 f8 01             	cmp    $0x1,%eax
  8019e9:	75 24                	jne    801a0f <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019eb:	a1 20 44 80 00       	mov    0x804420,%eax
  8019f0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8019f6:	83 ec 04             	sub    $0x4,%esp
  8019f9:	53                   	push   %ebx
  8019fa:	50                   	push   %eax
  8019fb:	68 ec 2e 80 00       	push   $0x802eec
  801a00:	e8 1b ea ff ff       	call   800420 <cprintf>
		return -E_INVAL;
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801a0d:	eb 26                	jmp    801a35 <read+0x8d>
	}
	if (!dev->dev_read)
  801a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a12:	8b 40 08             	mov    0x8(%eax),%eax
  801a15:	85 c0                	test   %eax,%eax
  801a17:	74 17                	je     801a30 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801a19:	83 ec 04             	sub    $0x4,%esp
  801a1c:	ff 75 10             	pushl  0x10(%ebp)
  801a1f:	ff 75 0c             	pushl  0xc(%ebp)
  801a22:	52                   	push   %edx
  801a23:	ff d0                	call   *%eax
  801a25:	89 c2                	mov    %eax,%edx
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	eb 09                	jmp    801a35 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a2c:	89 c2                	mov    %eax,%edx
  801a2e:	eb 05                	jmp    801a35 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801a30:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801a35:	89 d0                	mov    %edx,%eax
  801a37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    

00801a3c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	57                   	push   %edi
  801a40:	56                   	push   %esi
  801a41:	53                   	push   %ebx
  801a42:	83 ec 0c             	sub    $0xc,%esp
  801a45:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a48:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a50:	eb 21                	jmp    801a73 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a52:	83 ec 04             	sub    $0x4,%esp
  801a55:	89 f0                	mov    %esi,%eax
  801a57:	29 d8                	sub    %ebx,%eax
  801a59:	50                   	push   %eax
  801a5a:	89 d8                	mov    %ebx,%eax
  801a5c:	03 45 0c             	add    0xc(%ebp),%eax
  801a5f:	50                   	push   %eax
  801a60:	57                   	push   %edi
  801a61:	e8 42 ff ff ff       	call   8019a8 <read>
		if (m < 0)
  801a66:	83 c4 10             	add    $0x10,%esp
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 10                	js     801a7d <readn+0x41>
			return m;
		if (m == 0)
  801a6d:	85 c0                	test   %eax,%eax
  801a6f:	74 0a                	je     801a7b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a71:	01 c3                	add    %eax,%ebx
  801a73:	39 f3                	cmp    %esi,%ebx
  801a75:	72 db                	jb     801a52 <readn+0x16>
  801a77:	89 d8                	mov    %ebx,%eax
  801a79:	eb 02                	jmp    801a7d <readn+0x41>
  801a7b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a80:	5b                   	pop    %ebx
  801a81:	5e                   	pop    %esi
  801a82:	5f                   	pop    %edi
  801a83:	5d                   	pop    %ebp
  801a84:	c3                   	ret    

00801a85 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	53                   	push   %ebx
  801a89:	83 ec 14             	sub    $0x14,%esp
  801a8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a8f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a92:	50                   	push   %eax
  801a93:	53                   	push   %ebx
  801a94:	e8 a6 fc ff ff       	call   80173f <fd_lookup>
  801a99:	83 c4 08             	add    $0x8,%esp
  801a9c:	89 c2                	mov    %eax,%edx
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	78 6b                	js     801b0d <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801aa2:	83 ec 08             	sub    $0x8,%esp
  801aa5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa8:	50                   	push   %eax
  801aa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aac:	ff 30                	pushl  (%eax)
  801aae:	e8 e2 fc ff ff       	call   801795 <dev_lookup>
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	78 4a                	js     801b04 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801abd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ac1:	75 24                	jne    801ae7 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801ac3:	a1 20 44 80 00       	mov    0x804420,%eax
  801ac8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801ace:	83 ec 04             	sub    $0x4,%esp
  801ad1:	53                   	push   %ebx
  801ad2:	50                   	push   %eax
  801ad3:	68 08 2f 80 00       	push   $0x802f08
  801ad8:	e8 43 e9 ff ff       	call   800420 <cprintf>
		return -E_INVAL;
  801add:	83 c4 10             	add    $0x10,%esp
  801ae0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801ae5:	eb 26                	jmp    801b0d <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801ae7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aea:	8b 52 0c             	mov    0xc(%edx),%edx
  801aed:	85 d2                	test   %edx,%edx
  801aef:	74 17                	je     801b08 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801af1:	83 ec 04             	sub    $0x4,%esp
  801af4:	ff 75 10             	pushl  0x10(%ebp)
  801af7:	ff 75 0c             	pushl  0xc(%ebp)
  801afa:	50                   	push   %eax
  801afb:	ff d2                	call   *%edx
  801afd:	89 c2                	mov    %eax,%edx
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	eb 09                	jmp    801b0d <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b04:	89 c2                	mov    %eax,%edx
  801b06:	eb 05                	jmp    801b0d <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801b08:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801b0d:	89 d0                	mov    %edx,%eax
  801b0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b12:	c9                   	leave  
  801b13:	c3                   	ret    

00801b14 <seek>:

int
seek(int fdnum, off_t offset)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b1a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b1d:	50                   	push   %eax
  801b1e:	ff 75 08             	pushl  0x8(%ebp)
  801b21:	e8 19 fc ff ff       	call   80173f <fd_lookup>
  801b26:	83 c4 08             	add    $0x8,%esp
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	78 0e                	js     801b3b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801b2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b30:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b33:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801b36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	53                   	push   %ebx
  801b41:	83 ec 14             	sub    $0x14,%esp
  801b44:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b47:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b4a:	50                   	push   %eax
  801b4b:	53                   	push   %ebx
  801b4c:	e8 ee fb ff ff       	call   80173f <fd_lookup>
  801b51:	83 c4 08             	add    $0x8,%esp
  801b54:	89 c2                	mov    %eax,%edx
  801b56:	85 c0                	test   %eax,%eax
  801b58:	78 68                	js     801bc2 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b5a:	83 ec 08             	sub    $0x8,%esp
  801b5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b60:	50                   	push   %eax
  801b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b64:	ff 30                	pushl  (%eax)
  801b66:	e8 2a fc ff ff       	call   801795 <dev_lookup>
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	78 47                	js     801bb9 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b75:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b79:	75 24                	jne    801b9f <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b7b:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b80:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801b86:	83 ec 04             	sub    $0x4,%esp
  801b89:	53                   	push   %ebx
  801b8a:	50                   	push   %eax
  801b8b:	68 c8 2e 80 00       	push   $0x802ec8
  801b90:	e8 8b e8 ff ff       	call   800420 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801b9d:	eb 23                	jmp    801bc2 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801b9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ba2:	8b 52 18             	mov    0x18(%edx),%edx
  801ba5:	85 d2                	test   %edx,%edx
  801ba7:	74 14                	je     801bbd <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801ba9:	83 ec 08             	sub    $0x8,%esp
  801bac:	ff 75 0c             	pushl  0xc(%ebp)
  801baf:	50                   	push   %eax
  801bb0:	ff d2                	call   *%edx
  801bb2:	89 c2                	mov    %eax,%edx
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	eb 09                	jmp    801bc2 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bb9:	89 c2                	mov    %eax,%edx
  801bbb:	eb 05                	jmp    801bc2 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801bbd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801bc2:	89 d0                	mov    %edx,%eax
  801bc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc7:	c9                   	leave  
  801bc8:	c3                   	ret    

00801bc9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	53                   	push   %ebx
  801bcd:	83 ec 14             	sub    $0x14,%esp
  801bd0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bd3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bd6:	50                   	push   %eax
  801bd7:	ff 75 08             	pushl  0x8(%ebp)
  801bda:	e8 60 fb ff ff       	call   80173f <fd_lookup>
  801bdf:	83 c4 08             	add    $0x8,%esp
  801be2:	89 c2                	mov    %eax,%edx
  801be4:	85 c0                	test   %eax,%eax
  801be6:	78 58                	js     801c40 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801be8:	83 ec 08             	sub    $0x8,%esp
  801beb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bee:	50                   	push   %eax
  801bef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bf2:	ff 30                	pushl  (%eax)
  801bf4:	e8 9c fb ff ff       	call   801795 <dev_lookup>
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	78 37                	js     801c37 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c03:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801c07:	74 32                	je     801c3b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c09:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c0c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c13:	00 00 00 
	stat->st_isdir = 0;
  801c16:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c1d:	00 00 00 
	stat->st_dev = dev;
  801c20:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c26:	83 ec 08             	sub    $0x8,%esp
  801c29:	53                   	push   %ebx
  801c2a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c2d:	ff 50 14             	call   *0x14(%eax)
  801c30:	89 c2                	mov    %eax,%edx
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	eb 09                	jmp    801c40 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c37:	89 c2                	mov    %eax,%edx
  801c39:	eb 05                	jmp    801c40 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801c3b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801c40:	89 d0                	mov    %edx,%eax
  801c42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c45:	c9                   	leave  
  801c46:	c3                   	ret    

00801c47 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	56                   	push   %esi
  801c4b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c4c:	83 ec 08             	sub    $0x8,%esp
  801c4f:	6a 00                	push   $0x0
  801c51:	ff 75 08             	pushl  0x8(%ebp)
  801c54:	e8 e3 01 00 00       	call   801e3c <open>
  801c59:	89 c3                	mov    %eax,%ebx
  801c5b:	83 c4 10             	add    $0x10,%esp
  801c5e:	85 c0                	test   %eax,%eax
  801c60:	78 1b                	js     801c7d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801c62:	83 ec 08             	sub    $0x8,%esp
  801c65:	ff 75 0c             	pushl  0xc(%ebp)
  801c68:	50                   	push   %eax
  801c69:	e8 5b ff ff ff       	call   801bc9 <fstat>
  801c6e:	89 c6                	mov    %eax,%esi
	close(fd);
  801c70:	89 1c 24             	mov    %ebx,(%esp)
  801c73:	e8 f4 fb ff ff       	call   80186c <close>
	return r;
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	89 f0                	mov    %esi,%eax
}
  801c7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c80:	5b                   	pop    %ebx
  801c81:	5e                   	pop    %esi
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    

00801c84 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	56                   	push   %esi
  801c88:	53                   	push   %ebx
  801c89:	89 c6                	mov    %eax,%esi
  801c8b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801c8d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801c94:	75 12                	jne    801ca8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c96:	83 ec 0c             	sub    $0xc,%esp
  801c99:	6a 01                	push   $0x1
  801c9b:	e8 a4 09 00 00       	call   802644 <ipc_find_env>
  801ca0:	a3 00 40 80 00       	mov    %eax,0x804000
  801ca5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ca8:	6a 07                	push   $0x7
  801caa:	68 00 50 80 00       	push   $0x805000
  801caf:	56                   	push   %esi
  801cb0:	ff 35 00 40 80 00    	pushl  0x804000
  801cb6:	e8 27 09 00 00       	call   8025e2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801cbb:	83 c4 0c             	add    $0xc,%esp
  801cbe:	6a 00                	push   $0x0
  801cc0:	53                   	push   %ebx
  801cc1:	6a 00                	push   $0x0
  801cc3:	e8 9f 08 00 00       	call   802567 <ipc_recv>
}
  801cc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ccb:	5b                   	pop    %ebx
  801ccc:	5e                   	pop    %esi
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd8:	8b 40 0c             	mov    0xc(%eax),%eax
  801cdb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ce8:	ba 00 00 00 00       	mov    $0x0,%edx
  801ced:	b8 02 00 00 00       	mov    $0x2,%eax
  801cf2:	e8 8d ff ff ff       	call   801c84 <fsipc>
}
  801cf7:	c9                   	leave  
  801cf8:	c3                   	ret    

00801cf9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801cff:	8b 45 08             	mov    0x8(%ebp),%eax
  801d02:	8b 40 0c             	mov    0xc(%eax),%eax
  801d05:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d0a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0f:	b8 06 00 00 00       	mov    $0x6,%eax
  801d14:	e8 6b ff ff ff       	call   801c84 <fsipc>
}
  801d19:	c9                   	leave  
  801d1a:	c3                   	ret    

00801d1b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	53                   	push   %ebx
  801d1f:	83 ec 04             	sub    $0x4,%esp
  801d22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d25:	8b 45 08             	mov    0x8(%ebp),%eax
  801d28:	8b 40 0c             	mov    0xc(%eax),%eax
  801d2b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d30:	ba 00 00 00 00       	mov    $0x0,%edx
  801d35:	b8 05 00 00 00       	mov    $0x5,%eax
  801d3a:	e8 45 ff ff ff       	call   801c84 <fsipc>
  801d3f:	85 c0                	test   %eax,%eax
  801d41:	78 2c                	js     801d6f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d43:	83 ec 08             	sub    $0x8,%esp
  801d46:	68 00 50 80 00       	push   $0x805000
  801d4b:	53                   	push   %ebx
  801d4c:	e8 54 ec ff ff       	call   8009a5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d51:	a1 80 50 80 00       	mov    0x805080,%eax
  801d56:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d5c:	a1 84 50 80 00       	mov    0x805084,%eax
  801d61:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d67:	83 c4 10             	add    $0x10,%esp
  801d6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    

00801d74 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	83 ec 0c             	sub    $0xc,%esp
  801d7a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  801d80:	8b 52 0c             	mov    0xc(%edx),%edx
  801d83:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801d89:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801d8e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801d93:	0f 47 c2             	cmova  %edx,%eax
  801d96:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801d9b:	50                   	push   %eax
  801d9c:	ff 75 0c             	pushl  0xc(%ebp)
  801d9f:	68 08 50 80 00       	push   $0x805008
  801da4:	e8 8e ed ff ff       	call   800b37 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801da9:	ba 00 00 00 00       	mov    $0x0,%edx
  801dae:	b8 04 00 00 00       	mov    $0x4,%eax
  801db3:	e8 cc fe ff ff       	call   801c84 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801db8:	c9                   	leave  
  801db9:	c3                   	ret    

00801dba <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	56                   	push   %esi
  801dbe:	53                   	push   %ebx
  801dbf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc5:	8b 40 0c             	mov    0xc(%eax),%eax
  801dc8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801dcd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801dd3:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd8:	b8 03 00 00 00       	mov    $0x3,%eax
  801ddd:	e8 a2 fe ff ff       	call   801c84 <fsipc>
  801de2:	89 c3                	mov    %eax,%ebx
  801de4:	85 c0                	test   %eax,%eax
  801de6:	78 4b                	js     801e33 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801de8:	39 c6                	cmp    %eax,%esi
  801dea:	73 16                	jae    801e02 <devfile_read+0x48>
  801dec:	68 38 2f 80 00       	push   $0x802f38
  801df1:	68 3f 2f 80 00       	push   $0x802f3f
  801df6:	6a 7c                	push   $0x7c
  801df8:	68 54 2f 80 00       	push   $0x802f54
  801dfd:	e8 45 e5 ff ff       	call   800347 <_panic>
	assert(r <= PGSIZE);
  801e02:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e07:	7e 16                	jle    801e1f <devfile_read+0x65>
  801e09:	68 5f 2f 80 00       	push   $0x802f5f
  801e0e:	68 3f 2f 80 00       	push   $0x802f3f
  801e13:	6a 7d                	push   $0x7d
  801e15:	68 54 2f 80 00       	push   $0x802f54
  801e1a:	e8 28 e5 ff ff       	call   800347 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e1f:	83 ec 04             	sub    $0x4,%esp
  801e22:	50                   	push   %eax
  801e23:	68 00 50 80 00       	push   $0x805000
  801e28:	ff 75 0c             	pushl  0xc(%ebp)
  801e2b:	e8 07 ed ff ff       	call   800b37 <memmove>
	return r;
  801e30:	83 c4 10             	add    $0x10,%esp
}
  801e33:	89 d8                	mov    %ebx,%eax
  801e35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e38:	5b                   	pop    %ebx
  801e39:	5e                   	pop    %esi
  801e3a:	5d                   	pop    %ebp
  801e3b:	c3                   	ret    

00801e3c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	53                   	push   %ebx
  801e40:	83 ec 20             	sub    $0x20,%esp
  801e43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e46:	53                   	push   %ebx
  801e47:	e8 20 eb ff ff       	call   80096c <strlen>
  801e4c:	83 c4 10             	add    $0x10,%esp
  801e4f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e54:	7f 67                	jg     801ebd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e56:	83 ec 0c             	sub    $0xc,%esp
  801e59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5c:	50                   	push   %eax
  801e5d:	e8 8e f8 ff ff       	call   8016f0 <fd_alloc>
  801e62:	83 c4 10             	add    $0x10,%esp
		return r;
  801e65:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e67:	85 c0                	test   %eax,%eax
  801e69:	78 57                	js     801ec2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e6b:	83 ec 08             	sub    $0x8,%esp
  801e6e:	53                   	push   %ebx
  801e6f:	68 00 50 80 00       	push   $0x805000
  801e74:	e8 2c eb ff ff       	call   8009a5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e79:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e81:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e84:	b8 01 00 00 00       	mov    $0x1,%eax
  801e89:	e8 f6 fd ff ff       	call   801c84 <fsipc>
  801e8e:	89 c3                	mov    %eax,%ebx
  801e90:	83 c4 10             	add    $0x10,%esp
  801e93:	85 c0                	test   %eax,%eax
  801e95:	79 14                	jns    801eab <open+0x6f>
		fd_close(fd, 0);
  801e97:	83 ec 08             	sub    $0x8,%esp
  801e9a:	6a 00                	push   $0x0
  801e9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9f:	e8 47 f9 ff ff       	call   8017eb <fd_close>
		return r;
  801ea4:	83 c4 10             	add    $0x10,%esp
  801ea7:	89 da                	mov    %ebx,%edx
  801ea9:	eb 17                	jmp    801ec2 <open+0x86>
	}

	return fd2num(fd);
  801eab:	83 ec 0c             	sub    $0xc,%esp
  801eae:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb1:	e8 13 f8 ff ff       	call   8016c9 <fd2num>
  801eb6:	89 c2                	mov    %eax,%edx
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	eb 05                	jmp    801ec2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ebd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ec2:	89 d0                	mov    %edx,%eax
  801ec4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec7:	c9                   	leave  
  801ec8:	c3                   	ret    

00801ec9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ecf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed4:	b8 08 00 00 00       	mov    $0x8,%eax
  801ed9:	e8 a6 fd ff ff       	call   801c84 <fsipc>
}
  801ede:	c9                   	leave  
  801edf:	c3                   	ret    

00801ee0 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801ee0:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801ee4:	7e 37                	jle    801f1d <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	53                   	push   %ebx
  801eea:	83 ec 08             	sub    $0x8,%esp
  801eed:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801eef:	ff 70 04             	pushl  0x4(%eax)
  801ef2:	8d 40 10             	lea    0x10(%eax),%eax
  801ef5:	50                   	push   %eax
  801ef6:	ff 33                	pushl  (%ebx)
  801ef8:	e8 88 fb ff ff       	call   801a85 <write>
		if (result > 0)
  801efd:	83 c4 10             	add    $0x10,%esp
  801f00:	85 c0                	test   %eax,%eax
  801f02:	7e 03                	jle    801f07 <writebuf+0x27>
			b->result += result;
  801f04:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801f07:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f0a:	74 0d                	je     801f19 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	ba 00 00 00 00       	mov    $0x0,%edx
  801f13:	0f 4f c2             	cmovg  %edx,%eax
  801f16:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801f19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f1c:	c9                   	leave  
  801f1d:	f3 c3                	repz ret 

00801f1f <putch>:

static void
putch(int ch, void *thunk)
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
  801f22:	53                   	push   %ebx
  801f23:	83 ec 04             	sub    $0x4,%esp
  801f26:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801f29:	8b 53 04             	mov    0x4(%ebx),%edx
  801f2c:	8d 42 01             	lea    0x1(%edx),%eax
  801f2f:	89 43 04             	mov    %eax,0x4(%ebx)
  801f32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f35:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801f39:	3d 00 01 00 00       	cmp    $0x100,%eax
  801f3e:	75 0e                	jne    801f4e <putch+0x2f>
		writebuf(b);
  801f40:	89 d8                	mov    %ebx,%eax
  801f42:	e8 99 ff ff ff       	call   801ee0 <writebuf>
		b->idx = 0;
  801f47:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801f4e:	83 c4 04             	add    $0x4,%esp
  801f51:	5b                   	pop    %ebx
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    

00801f54 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801f5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f60:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801f66:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801f6d:	00 00 00 
	b.result = 0;
  801f70:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801f77:	00 00 00 
	b.error = 1;
  801f7a:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801f81:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801f84:	ff 75 10             	pushl  0x10(%ebp)
  801f87:	ff 75 0c             	pushl  0xc(%ebp)
  801f8a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801f90:	50                   	push   %eax
  801f91:	68 1f 1f 80 00       	push   $0x801f1f
  801f96:	e8 bc e5 ff ff       	call   800557 <vprintfmt>
	if (b.idx > 0)
  801f9b:	83 c4 10             	add    $0x10,%esp
  801f9e:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801fa5:	7e 0b                	jle    801fb2 <vfprintf+0x5e>
		writebuf(&b);
  801fa7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801fad:	e8 2e ff ff ff       	call   801ee0 <writebuf>

	return (b.result ? b.result : b.error);
  801fb2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801fb8:	85 c0                	test   %eax,%eax
  801fba:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801fc1:	c9                   	leave  
  801fc2:	c3                   	ret    

00801fc3 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801fc9:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801fcc:	50                   	push   %eax
  801fcd:	ff 75 0c             	pushl  0xc(%ebp)
  801fd0:	ff 75 08             	pushl  0x8(%ebp)
  801fd3:	e8 7c ff ff ff       	call   801f54 <vfprintf>
	va_end(ap);

	return cnt;
}
  801fd8:	c9                   	leave  
  801fd9:	c3                   	ret    

00801fda <printf>:

int
printf(const char *fmt, ...)
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801fe0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801fe3:	50                   	push   %eax
  801fe4:	ff 75 08             	pushl  0x8(%ebp)
  801fe7:	6a 01                	push   $0x1
  801fe9:	e8 66 ff ff ff       	call   801f54 <vfprintf>
	va_end(ap);

	return cnt;
}
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	56                   	push   %esi
  801ff4:	53                   	push   %ebx
  801ff5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ff8:	83 ec 0c             	sub    $0xc,%esp
  801ffb:	ff 75 08             	pushl  0x8(%ebp)
  801ffe:	e8 d6 f6 ff ff       	call   8016d9 <fd2data>
  802003:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802005:	83 c4 08             	add    $0x8,%esp
  802008:	68 6b 2f 80 00       	push   $0x802f6b
  80200d:	53                   	push   %ebx
  80200e:	e8 92 e9 ff ff       	call   8009a5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802013:	8b 46 04             	mov    0x4(%esi),%eax
  802016:	2b 06                	sub    (%esi),%eax
  802018:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80201e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802025:	00 00 00 
	stat->st_dev = &devpipe;
  802028:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80202f:	30 80 00 
	return 0;
}
  802032:	b8 00 00 00 00       	mov    $0x0,%eax
  802037:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80203a:	5b                   	pop    %ebx
  80203b:	5e                   	pop    %esi
  80203c:	5d                   	pop    %ebp
  80203d:	c3                   	ret    

0080203e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	53                   	push   %ebx
  802042:	83 ec 0c             	sub    $0xc,%esp
  802045:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802048:	53                   	push   %ebx
  802049:	6a 00                	push   $0x0
  80204b:	e8 dd ed ff ff       	call   800e2d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802050:	89 1c 24             	mov    %ebx,(%esp)
  802053:	e8 81 f6 ff ff       	call   8016d9 <fd2data>
  802058:	83 c4 08             	add    $0x8,%esp
  80205b:	50                   	push   %eax
  80205c:	6a 00                	push   $0x0
  80205e:	e8 ca ed ff ff       	call   800e2d <sys_page_unmap>
}
  802063:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802066:	c9                   	leave  
  802067:	c3                   	ret    

00802068 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	57                   	push   %edi
  80206c:	56                   	push   %esi
  80206d:	53                   	push   %ebx
  80206e:	83 ec 1c             	sub    $0x1c,%esp
  802071:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802074:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802076:	a1 20 44 80 00       	mov    0x804420,%eax
  80207b:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802081:	83 ec 0c             	sub    $0xc,%esp
  802084:	ff 75 e0             	pushl  -0x20(%ebp)
  802087:	e8 fd 05 00 00       	call   802689 <pageref>
  80208c:	89 c3                	mov    %eax,%ebx
  80208e:	89 3c 24             	mov    %edi,(%esp)
  802091:	e8 f3 05 00 00       	call   802689 <pageref>
  802096:	83 c4 10             	add    $0x10,%esp
  802099:	39 c3                	cmp    %eax,%ebx
  80209b:	0f 94 c1             	sete   %cl
  80209e:	0f b6 c9             	movzbl %cl,%ecx
  8020a1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8020a4:	8b 15 20 44 80 00    	mov    0x804420,%edx
  8020aa:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  8020b0:	39 ce                	cmp    %ecx,%esi
  8020b2:	74 1e                	je     8020d2 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8020b4:	39 c3                	cmp    %eax,%ebx
  8020b6:	75 be                	jne    802076 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020b8:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  8020be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020c1:	50                   	push   %eax
  8020c2:	56                   	push   %esi
  8020c3:	68 72 2f 80 00       	push   $0x802f72
  8020c8:	e8 53 e3 ff ff       	call   800420 <cprintf>
  8020cd:	83 c4 10             	add    $0x10,%esp
  8020d0:	eb a4                	jmp    802076 <_pipeisclosed+0xe>
	}
}
  8020d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d8:	5b                   	pop    %ebx
  8020d9:	5e                   	pop    %esi
  8020da:	5f                   	pop    %edi
  8020db:	5d                   	pop    %ebp
  8020dc:	c3                   	ret    

008020dd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020dd:	55                   	push   %ebp
  8020de:	89 e5                	mov    %esp,%ebp
  8020e0:	57                   	push   %edi
  8020e1:	56                   	push   %esi
  8020e2:	53                   	push   %ebx
  8020e3:	83 ec 28             	sub    $0x28,%esp
  8020e6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8020e9:	56                   	push   %esi
  8020ea:	e8 ea f5 ff ff       	call   8016d9 <fd2data>
  8020ef:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020f1:	83 c4 10             	add    $0x10,%esp
  8020f4:	bf 00 00 00 00       	mov    $0x0,%edi
  8020f9:	eb 4b                	jmp    802146 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8020fb:	89 da                	mov    %ebx,%edx
  8020fd:	89 f0                	mov    %esi,%eax
  8020ff:	e8 64 ff ff ff       	call   802068 <_pipeisclosed>
  802104:	85 c0                	test   %eax,%eax
  802106:	75 48                	jne    802150 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802108:	e8 7c ec ff ff       	call   800d89 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80210d:	8b 43 04             	mov    0x4(%ebx),%eax
  802110:	8b 0b                	mov    (%ebx),%ecx
  802112:	8d 51 20             	lea    0x20(%ecx),%edx
  802115:	39 d0                	cmp    %edx,%eax
  802117:	73 e2                	jae    8020fb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802119:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80211c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802120:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802123:	89 c2                	mov    %eax,%edx
  802125:	c1 fa 1f             	sar    $0x1f,%edx
  802128:	89 d1                	mov    %edx,%ecx
  80212a:	c1 e9 1b             	shr    $0x1b,%ecx
  80212d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802130:	83 e2 1f             	and    $0x1f,%edx
  802133:	29 ca                	sub    %ecx,%edx
  802135:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802139:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80213d:	83 c0 01             	add    $0x1,%eax
  802140:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802143:	83 c7 01             	add    $0x1,%edi
  802146:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802149:	75 c2                	jne    80210d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80214b:	8b 45 10             	mov    0x10(%ebp),%eax
  80214e:	eb 05                	jmp    802155 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802150:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802155:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802158:	5b                   	pop    %ebx
  802159:	5e                   	pop    %esi
  80215a:	5f                   	pop    %edi
  80215b:	5d                   	pop    %ebp
  80215c:	c3                   	ret    

0080215d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80215d:	55                   	push   %ebp
  80215e:	89 e5                	mov    %esp,%ebp
  802160:	57                   	push   %edi
  802161:	56                   	push   %esi
  802162:	53                   	push   %ebx
  802163:	83 ec 18             	sub    $0x18,%esp
  802166:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802169:	57                   	push   %edi
  80216a:	e8 6a f5 ff ff       	call   8016d9 <fd2data>
  80216f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802171:	83 c4 10             	add    $0x10,%esp
  802174:	bb 00 00 00 00       	mov    $0x0,%ebx
  802179:	eb 3d                	jmp    8021b8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80217b:	85 db                	test   %ebx,%ebx
  80217d:	74 04                	je     802183 <devpipe_read+0x26>
				return i;
  80217f:	89 d8                	mov    %ebx,%eax
  802181:	eb 44                	jmp    8021c7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802183:	89 f2                	mov    %esi,%edx
  802185:	89 f8                	mov    %edi,%eax
  802187:	e8 dc fe ff ff       	call   802068 <_pipeisclosed>
  80218c:	85 c0                	test   %eax,%eax
  80218e:	75 32                	jne    8021c2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802190:	e8 f4 eb ff ff       	call   800d89 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802195:	8b 06                	mov    (%esi),%eax
  802197:	3b 46 04             	cmp    0x4(%esi),%eax
  80219a:	74 df                	je     80217b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80219c:	99                   	cltd   
  80219d:	c1 ea 1b             	shr    $0x1b,%edx
  8021a0:	01 d0                	add    %edx,%eax
  8021a2:	83 e0 1f             	and    $0x1f,%eax
  8021a5:	29 d0                	sub    %edx,%eax
  8021a7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8021ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021af:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8021b2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021b5:	83 c3 01             	add    $0x1,%ebx
  8021b8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021bb:	75 d8                	jne    802195 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8021bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8021c0:	eb 05                	jmp    8021c7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021c2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8021c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021ca:	5b                   	pop    %ebx
  8021cb:	5e                   	pop    %esi
  8021cc:	5f                   	pop    %edi
  8021cd:	5d                   	pop    %ebp
  8021ce:	c3                   	ret    

008021cf <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8021cf:	55                   	push   %ebp
  8021d0:	89 e5                	mov    %esp,%ebp
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8021d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021da:	50                   	push   %eax
  8021db:	e8 10 f5 ff ff       	call   8016f0 <fd_alloc>
  8021e0:	83 c4 10             	add    $0x10,%esp
  8021e3:	89 c2                	mov    %eax,%edx
  8021e5:	85 c0                	test   %eax,%eax
  8021e7:	0f 88 2c 01 00 00    	js     802319 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ed:	83 ec 04             	sub    $0x4,%esp
  8021f0:	68 07 04 00 00       	push   $0x407
  8021f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8021f8:	6a 00                	push   $0x0
  8021fa:	e8 a9 eb ff ff       	call   800da8 <sys_page_alloc>
  8021ff:	83 c4 10             	add    $0x10,%esp
  802202:	89 c2                	mov    %eax,%edx
  802204:	85 c0                	test   %eax,%eax
  802206:	0f 88 0d 01 00 00    	js     802319 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80220c:	83 ec 0c             	sub    $0xc,%esp
  80220f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802212:	50                   	push   %eax
  802213:	e8 d8 f4 ff ff       	call   8016f0 <fd_alloc>
  802218:	89 c3                	mov    %eax,%ebx
  80221a:	83 c4 10             	add    $0x10,%esp
  80221d:	85 c0                	test   %eax,%eax
  80221f:	0f 88 e2 00 00 00    	js     802307 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802225:	83 ec 04             	sub    $0x4,%esp
  802228:	68 07 04 00 00       	push   $0x407
  80222d:	ff 75 f0             	pushl  -0x10(%ebp)
  802230:	6a 00                	push   $0x0
  802232:	e8 71 eb ff ff       	call   800da8 <sys_page_alloc>
  802237:	89 c3                	mov    %eax,%ebx
  802239:	83 c4 10             	add    $0x10,%esp
  80223c:	85 c0                	test   %eax,%eax
  80223e:	0f 88 c3 00 00 00    	js     802307 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802244:	83 ec 0c             	sub    $0xc,%esp
  802247:	ff 75 f4             	pushl  -0xc(%ebp)
  80224a:	e8 8a f4 ff ff       	call   8016d9 <fd2data>
  80224f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802251:	83 c4 0c             	add    $0xc,%esp
  802254:	68 07 04 00 00       	push   $0x407
  802259:	50                   	push   %eax
  80225a:	6a 00                	push   $0x0
  80225c:	e8 47 eb ff ff       	call   800da8 <sys_page_alloc>
  802261:	89 c3                	mov    %eax,%ebx
  802263:	83 c4 10             	add    $0x10,%esp
  802266:	85 c0                	test   %eax,%eax
  802268:	0f 88 89 00 00 00    	js     8022f7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80226e:	83 ec 0c             	sub    $0xc,%esp
  802271:	ff 75 f0             	pushl  -0x10(%ebp)
  802274:	e8 60 f4 ff ff       	call   8016d9 <fd2data>
  802279:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802280:	50                   	push   %eax
  802281:	6a 00                	push   $0x0
  802283:	56                   	push   %esi
  802284:	6a 00                	push   $0x0
  802286:	e8 60 eb ff ff       	call   800deb <sys_page_map>
  80228b:	89 c3                	mov    %eax,%ebx
  80228d:	83 c4 20             	add    $0x20,%esp
  802290:	85 c0                	test   %eax,%eax
  802292:	78 55                	js     8022e9 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802294:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80229a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80229f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8022a9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8022af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022b2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8022b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022b7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8022be:	83 ec 0c             	sub    $0xc,%esp
  8022c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8022c4:	e8 00 f4 ff ff       	call   8016c9 <fd2num>
  8022c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022cc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022ce:	83 c4 04             	add    $0x4,%esp
  8022d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8022d4:	e8 f0 f3 ff ff       	call   8016c9 <fd2num>
  8022d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022dc:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8022df:	83 c4 10             	add    $0x10,%esp
  8022e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8022e7:	eb 30                	jmp    802319 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8022e9:	83 ec 08             	sub    $0x8,%esp
  8022ec:	56                   	push   %esi
  8022ed:	6a 00                	push   $0x0
  8022ef:	e8 39 eb ff ff       	call   800e2d <sys_page_unmap>
  8022f4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8022f7:	83 ec 08             	sub    $0x8,%esp
  8022fa:	ff 75 f0             	pushl  -0x10(%ebp)
  8022fd:	6a 00                	push   $0x0
  8022ff:	e8 29 eb ff ff       	call   800e2d <sys_page_unmap>
  802304:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802307:	83 ec 08             	sub    $0x8,%esp
  80230a:	ff 75 f4             	pushl  -0xc(%ebp)
  80230d:	6a 00                	push   $0x0
  80230f:	e8 19 eb ff ff       	call   800e2d <sys_page_unmap>
  802314:	83 c4 10             	add    $0x10,%esp
  802317:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802319:	89 d0                	mov    %edx,%eax
  80231b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80231e:	5b                   	pop    %ebx
  80231f:	5e                   	pop    %esi
  802320:	5d                   	pop    %ebp
  802321:	c3                   	ret    

00802322 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802322:	55                   	push   %ebp
  802323:	89 e5                	mov    %esp,%ebp
  802325:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802328:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80232b:	50                   	push   %eax
  80232c:	ff 75 08             	pushl  0x8(%ebp)
  80232f:	e8 0b f4 ff ff       	call   80173f <fd_lookup>
  802334:	83 c4 10             	add    $0x10,%esp
  802337:	85 c0                	test   %eax,%eax
  802339:	78 18                	js     802353 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80233b:	83 ec 0c             	sub    $0xc,%esp
  80233e:	ff 75 f4             	pushl  -0xc(%ebp)
  802341:	e8 93 f3 ff ff       	call   8016d9 <fd2data>
	return _pipeisclosed(fd, p);
  802346:	89 c2                	mov    %eax,%edx
  802348:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234b:	e8 18 fd ff ff       	call   802068 <_pipeisclosed>
  802350:	83 c4 10             	add    $0x10,%esp
}
  802353:	c9                   	leave  
  802354:	c3                   	ret    

00802355 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802355:	55                   	push   %ebp
  802356:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802358:	b8 00 00 00 00       	mov    $0x0,%eax
  80235d:	5d                   	pop    %ebp
  80235e:	c3                   	ret    

0080235f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80235f:	55                   	push   %ebp
  802360:	89 e5                	mov    %esp,%ebp
  802362:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802365:	68 8a 2f 80 00       	push   $0x802f8a
  80236a:	ff 75 0c             	pushl  0xc(%ebp)
  80236d:	e8 33 e6 ff ff       	call   8009a5 <strcpy>
	return 0;
}
  802372:	b8 00 00 00 00       	mov    $0x0,%eax
  802377:	c9                   	leave  
  802378:	c3                   	ret    

00802379 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802379:	55                   	push   %ebp
  80237a:	89 e5                	mov    %esp,%ebp
  80237c:	57                   	push   %edi
  80237d:	56                   	push   %esi
  80237e:	53                   	push   %ebx
  80237f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802385:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80238a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802390:	eb 2d                	jmp    8023bf <devcons_write+0x46>
		m = n - tot;
  802392:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802395:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802397:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80239a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80239f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023a2:	83 ec 04             	sub    $0x4,%esp
  8023a5:	53                   	push   %ebx
  8023a6:	03 45 0c             	add    0xc(%ebp),%eax
  8023a9:	50                   	push   %eax
  8023aa:	57                   	push   %edi
  8023ab:	e8 87 e7 ff ff       	call   800b37 <memmove>
		sys_cputs(buf, m);
  8023b0:	83 c4 08             	add    $0x8,%esp
  8023b3:	53                   	push   %ebx
  8023b4:	57                   	push   %edi
  8023b5:	e8 32 e9 ff ff       	call   800cec <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023ba:	01 de                	add    %ebx,%esi
  8023bc:	83 c4 10             	add    $0x10,%esp
  8023bf:	89 f0                	mov    %esi,%eax
  8023c1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023c4:	72 cc                	jb     802392 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023c9:	5b                   	pop    %ebx
  8023ca:	5e                   	pop    %esi
  8023cb:	5f                   	pop    %edi
  8023cc:	5d                   	pop    %ebp
  8023cd:	c3                   	ret    

008023ce <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023ce:	55                   	push   %ebp
  8023cf:	89 e5                	mov    %esp,%ebp
  8023d1:	83 ec 08             	sub    $0x8,%esp
  8023d4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8023d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023dd:	74 2a                	je     802409 <devcons_read+0x3b>
  8023df:	eb 05                	jmp    8023e6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023e1:	e8 a3 e9 ff ff       	call   800d89 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023e6:	e8 1f e9 ff ff       	call   800d0a <sys_cgetc>
  8023eb:	85 c0                	test   %eax,%eax
  8023ed:	74 f2                	je     8023e1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023ef:	85 c0                	test   %eax,%eax
  8023f1:	78 16                	js     802409 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023f3:	83 f8 04             	cmp    $0x4,%eax
  8023f6:	74 0c                	je     802404 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8023f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023fb:	88 02                	mov    %al,(%edx)
	return 1;
  8023fd:	b8 01 00 00 00       	mov    $0x1,%eax
  802402:	eb 05                	jmp    802409 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802404:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802409:	c9                   	leave  
  80240a:	c3                   	ret    

0080240b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80240b:	55                   	push   %ebp
  80240c:	89 e5                	mov    %esp,%ebp
  80240e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802411:	8b 45 08             	mov    0x8(%ebp),%eax
  802414:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802417:	6a 01                	push   $0x1
  802419:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80241c:	50                   	push   %eax
  80241d:	e8 ca e8 ff ff       	call   800cec <sys_cputs>
}
  802422:	83 c4 10             	add    $0x10,%esp
  802425:	c9                   	leave  
  802426:	c3                   	ret    

00802427 <getchar>:

int
getchar(void)
{
  802427:	55                   	push   %ebp
  802428:	89 e5                	mov    %esp,%ebp
  80242a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80242d:	6a 01                	push   $0x1
  80242f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802432:	50                   	push   %eax
  802433:	6a 00                	push   $0x0
  802435:	e8 6e f5 ff ff       	call   8019a8 <read>
	if (r < 0)
  80243a:	83 c4 10             	add    $0x10,%esp
  80243d:	85 c0                	test   %eax,%eax
  80243f:	78 0f                	js     802450 <getchar+0x29>
		return r;
	if (r < 1)
  802441:	85 c0                	test   %eax,%eax
  802443:	7e 06                	jle    80244b <getchar+0x24>
		return -E_EOF;
	return c;
  802445:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802449:	eb 05                	jmp    802450 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80244b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802450:	c9                   	leave  
  802451:	c3                   	ret    

00802452 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802452:	55                   	push   %ebp
  802453:	89 e5                	mov    %esp,%ebp
  802455:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802458:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80245b:	50                   	push   %eax
  80245c:	ff 75 08             	pushl  0x8(%ebp)
  80245f:	e8 db f2 ff ff       	call   80173f <fd_lookup>
  802464:	83 c4 10             	add    $0x10,%esp
  802467:	85 c0                	test   %eax,%eax
  802469:	78 11                	js     80247c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80246b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80246e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802474:	39 10                	cmp    %edx,(%eax)
  802476:	0f 94 c0             	sete   %al
  802479:	0f b6 c0             	movzbl %al,%eax
}
  80247c:	c9                   	leave  
  80247d:	c3                   	ret    

0080247e <opencons>:

int
opencons(void)
{
  80247e:	55                   	push   %ebp
  80247f:	89 e5                	mov    %esp,%ebp
  802481:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802487:	50                   	push   %eax
  802488:	e8 63 f2 ff ff       	call   8016f0 <fd_alloc>
  80248d:	83 c4 10             	add    $0x10,%esp
		return r;
  802490:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802492:	85 c0                	test   %eax,%eax
  802494:	78 3e                	js     8024d4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802496:	83 ec 04             	sub    $0x4,%esp
  802499:	68 07 04 00 00       	push   $0x407
  80249e:	ff 75 f4             	pushl  -0xc(%ebp)
  8024a1:	6a 00                	push   $0x0
  8024a3:	e8 00 e9 ff ff       	call   800da8 <sys_page_alloc>
  8024a8:	83 c4 10             	add    $0x10,%esp
		return r;
  8024ab:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024ad:	85 c0                	test   %eax,%eax
  8024af:	78 23                	js     8024d4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024b1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8024b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ba:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024bf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024c6:	83 ec 0c             	sub    $0xc,%esp
  8024c9:	50                   	push   %eax
  8024ca:	e8 fa f1 ff ff       	call   8016c9 <fd2num>
  8024cf:	89 c2                	mov    %eax,%edx
  8024d1:	83 c4 10             	add    $0x10,%esp
}
  8024d4:	89 d0                	mov    %edx,%eax
  8024d6:	c9                   	leave  
  8024d7:	c3                   	ret    

008024d8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024d8:	55                   	push   %ebp
  8024d9:	89 e5                	mov    %esp,%ebp
  8024db:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024de:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8024e5:	75 2a                	jne    802511 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8024e7:	83 ec 04             	sub    $0x4,%esp
  8024ea:	6a 07                	push   $0x7
  8024ec:	68 00 f0 bf ee       	push   $0xeebff000
  8024f1:	6a 00                	push   $0x0
  8024f3:	e8 b0 e8 ff ff       	call   800da8 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8024f8:	83 c4 10             	add    $0x10,%esp
  8024fb:	85 c0                	test   %eax,%eax
  8024fd:	79 12                	jns    802511 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8024ff:	50                   	push   %eax
  802500:	68 18 2e 80 00       	push   $0x802e18
  802505:	6a 23                	push   $0x23
  802507:	68 96 2f 80 00       	push   $0x802f96
  80250c:	e8 36 de ff ff       	call   800347 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802511:	8b 45 08             	mov    0x8(%ebp),%eax
  802514:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802519:	83 ec 08             	sub    $0x8,%esp
  80251c:	68 43 25 80 00       	push   $0x802543
  802521:	6a 00                	push   $0x0
  802523:	e8 cb e9 ff ff       	call   800ef3 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802528:	83 c4 10             	add    $0x10,%esp
  80252b:	85 c0                	test   %eax,%eax
  80252d:	79 12                	jns    802541 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80252f:	50                   	push   %eax
  802530:	68 18 2e 80 00       	push   $0x802e18
  802535:	6a 2c                	push   $0x2c
  802537:	68 96 2f 80 00       	push   $0x802f96
  80253c:	e8 06 de ff ff       	call   800347 <_panic>
	}
}
  802541:	c9                   	leave  
  802542:	c3                   	ret    

00802543 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802543:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802544:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802549:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80254b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80254e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802552:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802557:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80255b:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80255d:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802560:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802561:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802564:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802565:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802566:	c3                   	ret    

00802567 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802567:	55                   	push   %ebp
  802568:	89 e5                	mov    %esp,%ebp
  80256a:	56                   	push   %esi
  80256b:	53                   	push   %ebx
  80256c:	8b 75 08             	mov    0x8(%ebp),%esi
  80256f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802572:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802575:	85 c0                	test   %eax,%eax
  802577:	75 12                	jne    80258b <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802579:	83 ec 0c             	sub    $0xc,%esp
  80257c:	68 00 00 c0 ee       	push   $0xeec00000
  802581:	e8 d2 e9 ff ff       	call   800f58 <sys_ipc_recv>
  802586:	83 c4 10             	add    $0x10,%esp
  802589:	eb 0c                	jmp    802597 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80258b:	83 ec 0c             	sub    $0xc,%esp
  80258e:	50                   	push   %eax
  80258f:	e8 c4 e9 ff ff       	call   800f58 <sys_ipc_recv>
  802594:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802597:	85 f6                	test   %esi,%esi
  802599:	0f 95 c1             	setne  %cl
  80259c:	85 db                	test   %ebx,%ebx
  80259e:	0f 95 c2             	setne  %dl
  8025a1:	84 d1                	test   %dl,%cl
  8025a3:	74 09                	je     8025ae <ipc_recv+0x47>
  8025a5:	89 c2                	mov    %eax,%edx
  8025a7:	c1 ea 1f             	shr    $0x1f,%edx
  8025aa:	84 d2                	test   %dl,%dl
  8025ac:	75 2d                	jne    8025db <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8025ae:	85 f6                	test   %esi,%esi
  8025b0:	74 0d                	je     8025bf <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8025b2:	a1 20 44 80 00       	mov    0x804420,%eax
  8025b7:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8025bd:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8025bf:	85 db                	test   %ebx,%ebx
  8025c1:	74 0d                	je     8025d0 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8025c3:	a1 20 44 80 00       	mov    0x804420,%eax
  8025c8:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8025ce:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8025d0:	a1 20 44 80 00       	mov    0x804420,%eax
  8025d5:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8025db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025de:	5b                   	pop    %ebx
  8025df:	5e                   	pop    %esi
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    

008025e2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025e2:	55                   	push   %ebp
  8025e3:	89 e5                	mov    %esp,%ebp
  8025e5:	57                   	push   %edi
  8025e6:	56                   	push   %esi
  8025e7:	53                   	push   %ebx
  8025e8:	83 ec 0c             	sub    $0xc,%esp
  8025eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8025f4:	85 db                	test   %ebx,%ebx
  8025f6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8025fb:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8025fe:	ff 75 14             	pushl  0x14(%ebp)
  802601:	53                   	push   %ebx
  802602:	56                   	push   %esi
  802603:	57                   	push   %edi
  802604:	e8 2c e9 ff ff       	call   800f35 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802609:	89 c2                	mov    %eax,%edx
  80260b:	c1 ea 1f             	shr    $0x1f,%edx
  80260e:	83 c4 10             	add    $0x10,%esp
  802611:	84 d2                	test   %dl,%dl
  802613:	74 17                	je     80262c <ipc_send+0x4a>
  802615:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802618:	74 12                	je     80262c <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80261a:	50                   	push   %eax
  80261b:	68 a4 2f 80 00       	push   $0x802fa4
  802620:	6a 47                	push   $0x47
  802622:	68 b2 2f 80 00       	push   $0x802fb2
  802627:	e8 1b dd ff ff       	call   800347 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80262c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80262f:	75 07                	jne    802638 <ipc_send+0x56>
			sys_yield();
  802631:	e8 53 e7 ff ff       	call   800d89 <sys_yield>
  802636:	eb c6                	jmp    8025fe <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802638:	85 c0                	test   %eax,%eax
  80263a:	75 c2                	jne    8025fe <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80263c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80263f:	5b                   	pop    %ebx
  802640:	5e                   	pop    %esi
  802641:	5f                   	pop    %edi
  802642:	5d                   	pop    %ebp
  802643:	c3                   	ret    

00802644 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802644:	55                   	push   %ebp
  802645:	89 e5                	mov    %esp,%ebp
  802647:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80264a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80264f:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802655:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80265b:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802661:	39 ca                	cmp    %ecx,%edx
  802663:	75 13                	jne    802678 <ipc_find_env+0x34>
			return envs[i].env_id;
  802665:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80266b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802670:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802676:	eb 0f                	jmp    802687 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802678:	83 c0 01             	add    $0x1,%eax
  80267b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802680:	75 cd                	jne    80264f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802682:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802687:	5d                   	pop    %ebp
  802688:	c3                   	ret    

00802689 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802689:	55                   	push   %ebp
  80268a:	89 e5                	mov    %esp,%ebp
  80268c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80268f:	89 d0                	mov    %edx,%eax
  802691:	c1 e8 16             	shr    $0x16,%eax
  802694:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80269b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026a0:	f6 c1 01             	test   $0x1,%cl
  8026a3:	74 1d                	je     8026c2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026a5:	c1 ea 0c             	shr    $0xc,%edx
  8026a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8026af:	f6 c2 01             	test   $0x1,%dl
  8026b2:	74 0e                	je     8026c2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026b4:	c1 ea 0c             	shr    $0xc,%edx
  8026b7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8026be:	ef 
  8026bf:	0f b7 c0             	movzwl %ax,%eax
}
  8026c2:	5d                   	pop    %ebp
  8026c3:	c3                   	ret    
  8026c4:	66 90                	xchg   %ax,%ax
  8026c6:	66 90                	xchg   %ax,%ax
  8026c8:	66 90                	xchg   %ax,%ax
  8026ca:	66 90                	xchg   %ax,%ax
  8026cc:	66 90                	xchg   %ax,%ax
  8026ce:	66 90                	xchg   %ax,%ax

008026d0 <__udivdi3>:
  8026d0:	55                   	push   %ebp
  8026d1:	57                   	push   %edi
  8026d2:	56                   	push   %esi
  8026d3:	53                   	push   %ebx
  8026d4:	83 ec 1c             	sub    $0x1c,%esp
  8026d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8026db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8026df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8026e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026e7:	85 f6                	test   %esi,%esi
  8026e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026ed:	89 ca                	mov    %ecx,%edx
  8026ef:	89 f8                	mov    %edi,%eax
  8026f1:	75 3d                	jne    802730 <__udivdi3+0x60>
  8026f3:	39 cf                	cmp    %ecx,%edi
  8026f5:	0f 87 c5 00 00 00    	ja     8027c0 <__udivdi3+0xf0>
  8026fb:	85 ff                	test   %edi,%edi
  8026fd:	89 fd                	mov    %edi,%ebp
  8026ff:	75 0b                	jne    80270c <__udivdi3+0x3c>
  802701:	b8 01 00 00 00       	mov    $0x1,%eax
  802706:	31 d2                	xor    %edx,%edx
  802708:	f7 f7                	div    %edi
  80270a:	89 c5                	mov    %eax,%ebp
  80270c:	89 c8                	mov    %ecx,%eax
  80270e:	31 d2                	xor    %edx,%edx
  802710:	f7 f5                	div    %ebp
  802712:	89 c1                	mov    %eax,%ecx
  802714:	89 d8                	mov    %ebx,%eax
  802716:	89 cf                	mov    %ecx,%edi
  802718:	f7 f5                	div    %ebp
  80271a:	89 c3                	mov    %eax,%ebx
  80271c:	89 d8                	mov    %ebx,%eax
  80271e:	89 fa                	mov    %edi,%edx
  802720:	83 c4 1c             	add    $0x1c,%esp
  802723:	5b                   	pop    %ebx
  802724:	5e                   	pop    %esi
  802725:	5f                   	pop    %edi
  802726:	5d                   	pop    %ebp
  802727:	c3                   	ret    
  802728:	90                   	nop
  802729:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802730:	39 ce                	cmp    %ecx,%esi
  802732:	77 74                	ja     8027a8 <__udivdi3+0xd8>
  802734:	0f bd fe             	bsr    %esi,%edi
  802737:	83 f7 1f             	xor    $0x1f,%edi
  80273a:	0f 84 98 00 00 00    	je     8027d8 <__udivdi3+0x108>
  802740:	bb 20 00 00 00       	mov    $0x20,%ebx
  802745:	89 f9                	mov    %edi,%ecx
  802747:	89 c5                	mov    %eax,%ebp
  802749:	29 fb                	sub    %edi,%ebx
  80274b:	d3 e6                	shl    %cl,%esi
  80274d:	89 d9                	mov    %ebx,%ecx
  80274f:	d3 ed                	shr    %cl,%ebp
  802751:	89 f9                	mov    %edi,%ecx
  802753:	d3 e0                	shl    %cl,%eax
  802755:	09 ee                	or     %ebp,%esi
  802757:	89 d9                	mov    %ebx,%ecx
  802759:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80275d:	89 d5                	mov    %edx,%ebp
  80275f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802763:	d3 ed                	shr    %cl,%ebp
  802765:	89 f9                	mov    %edi,%ecx
  802767:	d3 e2                	shl    %cl,%edx
  802769:	89 d9                	mov    %ebx,%ecx
  80276b:	d3 e8                	shr    %cl,%eax
  80276d:	09 c2                	or     %eax,%edx
  80276f:	89 d0                	mov    %edx,%eax
  802771:	89 ea                	mov    %ebp,%edx
  802773:	f7 f6                	div    %esi
  802775:	89 d5                	mov    %edx,%ebp
  802777:	89 c3                	mov    %eax,%ebx
  802779:	f7 64 24 0c          	mull   0xc(%esp)
  80277d:	39 d5                	cmp    %edx,%ebp
  80277f:	72 10                	jb     802791 <__udivdi3+0xc1>
  802781:	8b 74 24 08          	mov    0x8(%esp),%esi
  802785:	89 f9                	mov    %edi,%ecx
  802787:	d3 e6                	shl    %cl,%esi
  802789:	39 c6                	cmp    %eax,%esi
  80278b:	73 07                	jae    802794 <__udivdi3+0xc4>
  80278d:	39 d5                	cmp    %edx,%ebp
  80278f:	75 03                	jne    802794 <__udivdi3+0xc4>
  802791:	83 eb 01             	sub    $0x1,%ebx
  802794:	31 ff                	xor    %edi,%edi
  802796:	89 d8                	mov    %ebx,%eax
  802798:	89 fa                	mov    %edi,%edx
  80279a:	83 c4 1c             	add    $0x1c,%esp
  80279d:	5b                   	pop    %ebx
  80279e:	5e                   	pop    %esi
  80279f:	5f                   	pop    %edi
  8027a0:	5d                   	pop    %ebp
  8027a1:	c3                   	ret    
  8027a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027a8:	31 ff                	xor    %edi,%edi
  8027aa:	31 db                	xor    %ebx,%ebx
  8027ac:	89 d8                	mov    %ebx,%eax
  8027ae:	89 fa                	mov    %edi,%edx
  8027b0:	83 c4 1c             	add    $0x1c,%esp
  8027b3:	5b                   	pop    %ebx
  8027b4:	5e                   	pop    %esi
  8027b5:	5f                   	pop    %edi
  8027b6:	5d                   	pop    %ebp
  8027b7:	c3                   	ret    
  8027b8:	90                   	nop
  8027b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027c0:	89 d8                	mov    %ebx,%eax
  8027c2:	f7 f7                	div    %edi
  8027c4:	31 ff                	xor    %edi,%edi
  8027c6:	89 c3                	mov    %eax,%ebx
  8027c8:	89 d8                	mov    %ebx,%eax
  8027ca:	89 fa                	mov    %edi,%edx
  8027cc:	83 c4 1c             	add    $0x1c,%esp
  8027cf:	5b                   	pop    %ebx
  8027d0:	5e                   	pop    %esi
  8027d1:	5f                   	pop    %edi
  8027d2:	5d                   	pop    %ebp
  8027d3:	c3                   	ret    
  8027d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027d8:	39 ce                	cmp    %ecx,%esi
  8027da:	72 0c                	jb     8027e8 <__udivdi3+0x118>
  8027dc:	31 db                	xor    %ebx,%ebx
  8027de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8027e2:	0f 87 34 ff ff ff    	ja     80271c <__udivdi3+0x4c>
  8027e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8027ed:	e9 2a ff ff ff       	jmp    80271c <__udivdi3+0x4c>
  8027f2:	66 90                	xchg   %ax,%ax
  8027f4:	66 90                	xchg   %ax,%ax
  8027f6:	66 90                	xchg   %ax,%ax
  8027f8:	66 90                	xchg   %ax,%ax
  8027fa:	66 90                	xchg   %ax,%ax
  8027fc:	66 90                	xchg   %ax,%ax
  8027fe:	66 90                	xchg   %ax,%ax

00802800 <__umoddi3>:
  802800:	55                   	push   %ebp
  802801:	57                   	push   %edi
  802802:	56                   	push   %esi
  802803:	53                   	push   %ebx
  802804:	83 ec 1c             	sub    $0x1c,%esp
  802807:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80280b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80280f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802813:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802817:	85 d2                	test   %edx,%edx
  802819:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80281d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802821:	89 f3                	mov    %esi,%ebx
  802823:	89 3c 24             	mov    %edi,(%esp)
  802826:	89 74 24 04          	mov    %esi,0x4(%esp)
  80282a:	75 1c                	jne    802848 <__umoddi3+0x48>
  80282c:	39 f7                	cmp    %esi,%edi
  80282e:	76 50                	jbe    802880 <__umoddi3+0x80>
  802830:	89 c8                	mov    %ecx,%eax
  802832:	89 f2                	mov    %esi,%edx
  802834:	f7 f7                	div    %edi
  802836:	89 d0                	mov    %edx,%eax
  802838:	31 d2                	xor    %edx,%edx
  80283a:	83 c4 1c             	add    $0x1c,%esp
  80283d:	5b                   	pop    %ebx
  80283e:	5e                   	pop    %esi
  80283f:	5f                   	pop    %edi
  802840:	5d                   	pop    %ebp
  802841:	c3                   	ret    
  802842:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802848:	39 f2                	cmp    %esi,%edx
  80284a:	89 d0                	mov    %edx,%eax
  80284c:	77 52                	ja     8028a0 <__umoddi3+0xa0>
  80284e:	0f bd ea             	bsr    %edx,%ebp
  802851:	83 f5 1f             	xor    $0x1f,%ebp
  802854:	75 5a                	jne    8028b0 <__umoddi3+0xb0>
  802856:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80285a:	0f 82 e0 00 00 00    	jb     802940 <__umoddi3+0x140>
  802860:	39 0c 24             	cmp    %ecx,(%esp)
  802863:	0f 86 d7 00 00 00    	jbe    802940 <__umoddi3+0x140>
  802869:	8b 44 24 08          	mov    0x8(%esp),%eax
  80286d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802871:	83 c4 1c             	add    $0x1c,%esp
  802874:	5b                   	pop    %ebx
  802875:	5e                   	pop    %esi
  802876:	5f                   	pop    %edi
  802877:	5d                   	pop    %ebp
  802878:	c3                   	ret    
  802879:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802880:	85 ff                	test   %edi,%edi
  802882:	89 fd                	mov    %edi,%ebp
  802884:	75 0b                	jne    802891 <__umoddi3+0x91>
  802886:	b8 01 00 00 00       	mov    $0x1,%eax
  80288b:	31 d2                	xor    %edx,%edx
  80288d:	f7 f7                	div    %edi
  80288f:	89 c5                	mov    %eax,%ebp
  802891:	89 f0                	mov    %esi,%eax
  802893:	31 d2                	xor    %edx,%edx
  802895:	f7 f5                	div    %ebp
  802897:	89 c8                	mov    %ecx,%eax
  802899:	f7 f5                	div    %ebp
  80289b:	89 d0                	mov    %edx,%eax
  80289d:	eb 99                	jmp    802838 <__umoddi3+0x38>
  80289f:	90                   	nop
  8028a0:	89 c8                	mov    %ecx,%eax
  8028a2:	89 f2                	mov    %esi,%edx
  8028a4:	83 c4 1c             	add    $0x1c,%esp
  8028a7:	5b                   	pop    %ebx
  8028a8:	5e                   	pop    %esi
  8028a9:	5f                   	pop    %edi
  8028aa:	5d                   	pop    %ebp
  8028ab:	c3                   	ret    
  8028ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028b0:	8b 34 24             	mov    (%esp),%esi
  8028b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8028b8:	89 e9                	mov    %ebp,%ecx
  8028ba:	29 ef                	sub    %ebp,%edi
  8028bc:	d3 e0                	shl    %cl,%eax
  8028be:	89 f9                	mov    %edi,%ecx
  8028c0:	89 f2                	mov    %esi,%edx
  8028c2:	d3 ea                	shr    %cl,%edx
  8028c4:	89 e9                	mov    %ebp,%ecx
  8028c6:	09 c2                	or     %eax,%edx
  8028c8:	89 d8                	mov    %ebx,%eax
  8028ca:	89 14 24             	mov    %edx,(%esp)
  8028cd:	89 f2                	mov    %esi,%edx
  8028cf:	d3 e2                	shl    %cl,%edx
  8028d1:	89 f9                	mov    %edi,%ecx
  8028d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8028d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8028db:	d3 e8                	shr    %cl,%eax
  8028dd:	89 e9                	mov    %ebp,%ecx
  8028df:	89 c6                	mov    %eax,%esi
  8028e1:	d3 e3                	shl    %cl,%ebx
  8028e3:	89 f9                	mov    %edi,%ecx
  8028e5:	89 d0                	mov    %edx,%eax
  8028e7:	d3 e8                	shr    %cl,%eax
  8028e9:	89 e9                	mov    %ebp,%ecx
  8028eb:	09 d8                	or     %ebx,%eax
  8028ed:	89 d3                	mov    %edx,%ebx
  8028ef:	89 f2                	mov    %esi,%edx
  8028f1:	f7 34 24             	divl   (%esp)
  8028f4:	89 d6                	mov    %edx,%esi
  8028f6:	d3 e3                	shl    %cl,%ebx
  8028f8:	f7 64 24 04          	mull   0x4(%esp)
  8028fc:	39 d6                	cmp    %edx,%esi
  8028fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802902:	89 d1                	mov    %edx,%ecx
  802904:	89 c3                	mov    %eax,%ebx
  802906:	72 08                	jb     802910 <__umoddi3+0x110>
  802908:	75 11                	jne    80291b <__umoddi3+0x11b>
  80290a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80290e:	73 0b                	jae    80291b <__umoddi3+0x11b>
  802910:	2b 44 24 04          	sub    0x4(%esp),%eax
  802914:	1b 14 24             	sbb    (%esp),%edx
  802917:	89 d1                	mov    %edx,%ecx
  802919:	89 c3                	mov    %eax,%ebx
  80291b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80291f:	29 da                	sub    %ebx,%edx
  802921:	19 ce                	sbb    %ecx,%esi
  802923:	89 f9                	mov    %edi,%ecx
  802925:	89 f0                	mov    %esi,%eax
  802927:	d3 e0                	shl    %cl,%eax
  802929:	89 e9                	mov    %ebp,%ecx
  80292b:	d3 ea                	shr    %cl,%edx
  80292d:	89 e9                	mov    %ebp,%ecx
  80292f:	d3 ee                	shr    %cl,%esi
  802931:	09 d0                	or     %edx,%eax
  802933:	89 f2                	mov    %esi,%edx
  802935:	83 c4 1c             	add    $0x1c,%esp
  802938:	5b                   	pop    %ebx
  802939:	5e                   	pop    %esi
  80293a:	5f                   	pop    %edi
  80293b:	5d                   	pop    %ebp
  80293c:	c3                   	ret    
  80293d:	8d 76 00             	lea    0x0(%esi),%esi
  802940:	29 f9                	sub    %edi,%ecx
  802942:	19 d6                	sbb    %edx,%esi
  802944:	89 74 24 04          	mov    %esi,0x4(%esp)
  802948:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80294c:	e9 18 ff ff ff       	jmp    802869 <__umoddi3+0x69>
