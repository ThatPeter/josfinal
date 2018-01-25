
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
  80005f:	e8 c1 1c 00 00       	call   801d25 <printf>
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
  800079:	e8 ef 08 00 00       	call   80096d <strlen>
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
  80009d:	e8 83 1c 00 00       	call   801d25 <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 b1 2b 80 00       	push   $0x802bb1
  8000b0:	e8 70 1c 00 00       	call   801d25 <printf>
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
  8000cf:	e8 51 1c 00 00       	call   801d25 <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 07 27 80 00       	push   $0x802707
  8000df:	e8 41 1c 00 00       	call   801d25 <printf>
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
  800100:	e8 82 1a 00 00       	call   801b87 <open>
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
  80011f:	e8 24 02 00 00       	call   800348 <_panic>
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
  80015f:	e8 29 16 00 00       	call   80178d <readn>
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
  80017f:	e8 c4 01 00 00       	call   800348 <_panic>
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
  800199:	e8 aa 01 00 00       	call   800348 <_panic>
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
  8001bb:	e8 d2 17 00 00       	call   801992 <stat>
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
  8001d8:	e8 6b 01 00 00       	call   800348 <_panic>
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
  800225:	e8 fb 1a 00 00       	call   801d25 <printf>
	exit();
  80022a:	e8 ff 00 00 00       	call   80032e <exit>
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
  800248:	e8 7f 10 00 00       	call   8012cc <argstart>
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
  800277:	e8 80 10 00 00       	call   8012fc <argnext>
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
  8002cf:	e8 97 0a 00 00       	call   800d6b <sys_getenvid>
  8002d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d9:	89 c2                	mov    %eax,%edx
  8002db:	c1 e2 07             	shl    $0x7,%edx
  8002de:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8002e5:	a3 20 44 80 00       	mov    %eax,0x804420
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002ea:	85 db                	test   %ebx,%ebx
  8002ec:	7e 07                	jle    8002f5 <libmain+0x31>
		binaryname = argv[0];
  8002ee:	8b 06                	mov    (%esi),%eax
  8002f0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f5:	83 ec 08             	sub    $0x8,%esp
  8002f8:	56                   	push   %esi
  8002f9:	53                   	push   %ebx
  8002fa:	e8 35 ff ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  8002ff:	e8 2a 00 00 00       	call   80032e <exit>
}
  800304:	83 c4 10             	add    $0x10,%esp
  800307:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80030a:	5b                   	pop    %ebx
  80030b:	5e                   	pop    %esi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800314:	a1 24 44 80 00       	mov    0x804424,%eax
	func();
  800319:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80031b:	e8 4b 0a 00 00       	call   800d6b <sys_getenvid>
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	50                   	push   %eax
  800324:	e8 91 0c 00 00       	call   800fba <sys_thread_free>
}
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800334:	e8 b2 12 00 00       	call   8015eb <close_all>
	sys_env_destroy(0);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	6a 00                	push   $0x0
  80033e:	e8 e7 09 00 00       	call   800d2a <sys_env_destroy>
}
  800343:	83 c4 10             	add    $0x10,%esp
  800346:	c9                   	leave  
  800347:	c3                   	ret    

00800348 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	56                   	push   %esi
  80034c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80034d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800350:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800356:	e8 10 0a 00 00       	call   800d6b <sys_getenvid>
  80035b:	83 ec 0c             	sub    $0xc,%esp
  80035e:	ff 75 0c             	pushl  0xc(%ebp)
  800361:	ff 75 08             	pushl  0x8(%ebp)
  800364:	56                   	push   %esi
  800365:	50                   	push   %eax
  800366:	68 38 27 80 00       	push   $0x802738
  80036b:	e8 b1 00 00 00       	call   800421 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800370:	83 c4 18             	add    $0x18,%esp
  800373:	53                   	push   %ebx
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	e8 54 00 00 00       	call   8003d0 <vcprintf>
	cprintf("\n");
  80037c:	c7 04 24 07 27 80 00 	movl   $0x802707,(%esp)
  800383:	e8 99 00 00 00       	call   800421 <cprintf>
  800388:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80038b:	cc                   	int3   
  80038c:	eb fd                	jmp    80038b <_panic+0x43>

0080038e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	53                   	push   %ebx
  800392:	83 ec 04             	sub    $0x4,%esp
  800395:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800398:	8b 13                	mov    (%ebx),%edx
  80039a:	8d 42 01             	lea    0x1(%edx),%eax
  80039d:	89 03                	mov    %eax,(%ebx)
  80039f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ab:	75 1a                	jne    8003c7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003ad:	83 ec 08             	sub    $0x8,%esp
  8003b0:	68 ff 00 00 00       	push   $0xff
  8003b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b8:	50                   	push   %eax
  8003b9:	e8 2f 09 00 00       	call   800ced <sys_cputs>
		b->idx = 0;
  8003be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003c7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ce:	c9                   	leave  
  8003cf:	c3                   	ret    

008003d0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003e0:	00 00 00 
	b.cnt = 0;
  8003e3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ed:	ff 75 0c             	pushl  0xc(%ebp)
  8003f0:	ff 75 08             	pushl  0x8(%ebp)
  8003f3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f9:	50                   	push   %eax
  8003fa:	68 8e 03 80 00       	push   $0x80038e
  8003ff:	e8 54 01 00 00       	call   800558 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800404:	83 c4 08             	add    $0x8,%esp
  800407:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80040d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800413:	50                   	push   %eax
  800414:	e8 d4 08 00 00       	call   800ced <sys_cputs>

	return b.cnt;
}
  800419:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041f:	c9                   	leave  
  800420:	c3                   	ret    

00800421 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800427:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80042a:	50                   	push   %eax
  80042b:	ff 75 08             	pushl  0x8(%ebp)
  80042e:	e8 9d ff ff ff       	call   8003d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800433:	c9                   	leave  
  800434:	c3                   	ret    

00800435 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	57                   	push   %edi
  800439:	56                   	push   %esi
  80043a:	53                   	push   %ebx
  80043b:	83 ec 1c             	sub    $0x1c,%esp
  80043e:	89 c7                	mov    %eax,%edi
  800440:	89 d6                	mov    %edx,%esi
  800442:	8b 45 08             	mov    0x8(%ebp),%eax
  800445:	8b 55 0c             	mov    0xc(%ebp),%edx
  800448:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80044b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80044e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800451:	bb 00 00 00 00       	mov    $0x0,%ebx
  800456:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800459:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80045c:	39 d3                	cmp    %edx,%ebx
  80045e:	72 05                	jb     800465 <printnum+0x30>
  800460:	39 45 10             	cmp    %eax,0x10(%ebp)
  800463:	77 45                	ja     8004aa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800465:	83 ec 0c             	sub    $0xc,%esp
  800468:	ff 75 18             	pushl  0x18(%ebp)
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800471:	53                   	push   %ebx
  800472:	ff 75 10             	pushl  0x10(%ebp)
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047b:	ff 75 e0             	pushl  -0x20(%ebp)
  80047e:	ff 75 dc             	pushl  -0x24(%ebp)
  800481:	ff 75 d8             	pushl  -0x28(%ebp)
  800484:	e8 77 1f 00 00       	call   802400 <__udivdi3>
  800489:	83 c4 18             	add    $0x18,%esp
  80048c:	52                   	push   %edx
  80048d:	50                   	push   %eax
  80048e:	89 f2                	mov    %esi,%edx
  800490:	89 f8                	mov    %edi,%eax
  800492:	e8 9e ff ff ff       	call   800435 <printnum>
  800497:	83 c4 20             	add    $0x20,%esp
  80049a:	eb 18                	jmp    8004b4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	56                   	push   %esi
  8004a0:	ff 75 18             	pushl  0x18(%ebp)
  8004a3:	ff d7                	call   *%edi
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	eb 03                	jmp    8004ad <printnum+0x78>
  8004aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004ad:	83 eb 01             	sub    $0x1,%ebx
  8004b0:	85 db                	test   %ebx,%ebx
  8004b2:	7f e8                	jg     80049c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	56                   	push   %esi
  8004b8:	83 ec 04             	sub    $0x4,%esp
  8004bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004be:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c1:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c4:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c7:	e8 64 20 00 00       	call   802530 <__umoddi3>
  8004cc:	83 c4 14             	add    $0x14,%esp
  8004cf:	0f be 80 5b 27 80 00 	movsbl 0x80275b(%eax),%eax
  8004d6:	50                   	push   %eax
  8004d7:	ff d7                	call   *%edi
}
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004df:	5b                   	pop    %ebx
  8004e0:	5e                   	pop    %esi
  8004e1:	5f                   	pop    %edi
  8004e2:	5d                   	pop    %ebp
  8004e3:	c3                   	ret    

008004e4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004e7:	83 fa 01             	cmp    $0x1,%edx
  8004ea:	7e 0e                	jle    8004fa <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004ec:	8b 10                	mov    (%eax),%edx
  8004ee:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004f1:	89 08                	mov    %ecx,(%eax)
  8004f3:	8b 02                	mov    (%edx),%eax
  8004f5:	8b 52 04             	mov    0x4(%edx),%edx
  8004f8:	eb 22                	jmp    80051c <getuint+0x38>
	else if (lflag)
  8004fa:	85 d2                	test   %edx,%edx
  8004fc:	74 10                	je     80050e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004fe:	8b 10                	mov    (%eax),%edx
  800500:	8d 4a 04             	lea    0x4(%edx),%ecx
  800503:	89 08                	mov    %ecx,(%eax)
  800505:	8b 02                	mov    (%edx),%eax
  800507:	ba 00 00 00 00       	mov    $0x0,%edx
  80050c:	eb 0e                	jmp    80051c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80050e:	8b 10                	mov    (%eax),%edx
  800510:	8d 4a 04             	lea    0x4(%edx),%ecx
  800513:	89 08                	mov    %ecx,(%eax)
  800515:	8b 02                	mov    (%edx),%eax
  800517:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80051c:	5d                   	pop    %ebp
  80051d:	c3                   	ret    

0080051e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80051e:	55                   	push   %ebp
  80051f:	89 e5                	mov    %esp,%ebp
  800521:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800524:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800528:	8b 10                	mov    (%eax),%edx
  80052a:	3b 50 04             	cmp    0x4(%eax),%edx
  80052d:	73 0a                	jae    800539 <sprintputch+0x1b>
		*b->buf++ = ch;
  80052f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800532:	89 08                	mov    %ecx,(%eax)
  800534:	8b 45 08             	mov    0x8(%ebp),%eax
  800537:	88 02                	mov    %al,(%edx)
}
  800539:	5d                   	pop    %ebp
  80053a:	c3                   	ret    

0080053b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80053b:	55                   	push   %ebp
  80053c:	89 e5                	mov    %esp,%ebp
  80053e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800541:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800544:	50                   	push   %eax
  800545:	ff 75 10             	pushl  0x10(%ebp)
  800548:	ff 75 0c             	pushl  0xc(%ebp)
  80054b:	ff 75 08             	pushl  0x8(%ebp)
  80054e:	e8 05 00 00 00       	call   800558 <vprintfmt>
	va_end(ap);
}
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	c9                   	leave  
  800557:	c3                   	ret    

00800558 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800558:	55                   	push   %ebp
  800559:	89 e5                	mov    %esp,%ebp
  80055b:	57                   	push   %edi
  80055c:	56                   	push   %esi
  80055d:	53                   	push   %ebx
  80055e:	83 ec 2c             	sub    $0x2c,%esp
  800561:	8b 75 08             	mov    0x8(%ebp),%esi
  800564:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800567:	8b 7d 10             	mov    0x10(%ebp),%edi
  80056a:	eb 12                	jmp    80057e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80056c:	85 c0                	test   %eax,%eax
  80056e:	0f 84 89 03 00 00    	je     8008fd <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	53                   	push   %ebx
  800578:	50                   	push   %eax
  800579:	ff d6                	call   *%esi
  80057b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80057e:	83 c7 01             	add    $0x1,%edi
  800581:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800585:	83 f8 25             	cmp    $0x25,%eax
  800588:	75 e2                	jne    80056c <vprintfmt+0x14>
  80058a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80058e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800595:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a8:	eb 07                	jmp    8005b1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005ad:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b1:	8d 47 01             	lea    0x1(%edi),%eax
  8005b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005b7:	0f b6 07             	movzbl (%edi),%eax
  8005ba:	0f b6 c8             	movzbl %al,%ecx
  8005bd:	83 e8 23             	sub    $0x23,%eax
  8005c0:	3c 55                	cmp    $0x55,%al
  8005c2:	0f 87 1a 03 00 00    	ja     8008e2 <vprintfmt+0x38a>
  8005c8:	0f b6 c0             	movzbl %al,%eax
  8005cb:	ff 24 85 a0 28 80 00 	jmp    *0x8028a0(,%eax,4)
  8005d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005d5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005d9:	eb d6                	jmp    8005b1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005de:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005e6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005e9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005ed:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005f0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005f3:	83 fa 09             	cmp    $0x9,%edx
  8005f6:	77 39                	ja     800631 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005f8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005fb:	eb e9                	jmp    8005e6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 48 04             	lea    0x4(%eax),%ecx
  800603:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800606:	8b 00                	mov    (%eax),%eax
  800608:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80060e:	eb 27                	jmp    800637 <vprintfmt+0xdf>
  800610:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800613:	85 c0                	test   %eax,%eax
  800615:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061a:	0f 49 c8             	cmovns %eax,%ecx
  80061d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800623:	eb 8c                	jmp    8005b1 <vprintfmt+0x59>
  800625:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800628:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80062f:	eb 80                	jmp    8005b1 <vprintfmt+0x59>
  800631:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800634:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800637:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80063b:	0f 89 70 ff ff ff    	jns    8005b1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800641:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800644:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800647:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80064e:	e9 5e ff ff ff       	jmp    8005b1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800653:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800659:	e9 53 ff ff ff       	jmp    8005b1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	ff 30                	pushl  (%eax)
  80066d:	ff d6                	call   *%esi
			break;
  80066f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800675:	e9 04 ff ff ff       	jmp    80057e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 04             	lea    0x4(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)
  800683:	8b 00                	mov    (%eax),%eax
  800685:	99                   	cltd   
  800686:	31 d0                	xor    %edx,%eax
  800688:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80068a:	83 f8 0f             	cmp    $0xf,%eax
  80068d:	7f 0b                	jg     80069a <vprintfmt+0x142>
  80068f:	8b 14 85 00 2a 80 00 	mov    0x802a00(,%eax,4),%edx
  800696:	85 d2                	test   %edx,%edx
  800698:	75 18                	jne    8006b2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80069a:	50                   	push   %eax
  80069b:	68 73 27 80 00       	push   $0x802773
  8006a0:	53                   	push   %ebx
  8006a1:	56                   	push   %esi
  8006a2:	e8 94 fe ff ff       	call   80053b <printfmt>
  8006a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006ad:	e9 cc fe ff ff       	jmp    80057e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006b2:	52                   	push   %edx
  8006b3:	68 b1 2b 80 00       	push   $0x802bb1
  8006b8:	53                   	push   %ebx
  8006b9:	56                   	push   %esi
  8006ba:	e8 7c fe ff ff       	call   80053b <printfmt>
  8006bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c5:	e9 b4 fe ff ff       	jmp    80057e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8d 50 04             	lea    0x4(%eax),%edx
  8006d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006d5:	85 ff                	test   %edi,%edi
  8006d7:	b8 6c 27 80 00       	mov    $0x80276c,%eax
  8006dc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006e3:	0f 8e 94 00 00 00    	jle    80077d <vprintfmt+0x225>
  8006e9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006ed:	0f 84 98 00 00 00    	je     80078b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	ff 75 d0             	pushl  -0x30(%ebp)
  8006f9:	57                   	push   %edi
  8006fa:	e8 86 02 00 00       	call   800985 <strnlen>
  8006ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800702:	29 c1                	sub    %eax,%ecx
  800704:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800707:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80070a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80070e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800711:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800714:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800716:	eb 0f                	jmp    800727 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800718:	83 ec 08             	sub    $0x8,%esp
  80071b:	53                   	push   %ebx
  80071c:	ff 75 e0             	pushl  -0x20(%ebp)
  80071f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800721:	83 ef 01             	sub    $0x1,%edi
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	85 ff                	test   %edi,%edi
  800729:	7f ed                	jg     800718 <vprintfmt+0x1c0>
  80072b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80072e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800731:	85 c9                	test   %ecx,%ecx
  800733:	b8 00 00 00 00       	mov    $0x0,%eax
  800738:	0f 49 c1             	cmovns %ecx,%eax
  80073b:	29 c1                	sub    %eax,%ecx
  80073d:	89 75 08             	mov    %esi,0x8(%ebp)
  800740:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800743:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800746:	89 cb                	mov    %ecx,%ebx
  800748:	eb 4d                	jmp    800797 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80074a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80074e:	74 1b                	je     80076b <vprintfmt+0x213>
  800750:	0f be c0             	movsbl %al,%eax
  800753:	83 e8 20             	sub    $0x20,%eax
  800756:	83 f8 5e             	cmp    $0x5e,%eax
  800759:	76 10                	jbe    80076b <vprintfmt+0x213>
					putch('?', putdat);
  80075b:	83 ec 08             	sub    $0x8,%esp
  80075e:	ff 75 0c             	pushl  0xc(%ebp)
  800761:	6a 3f                	push   $0x3f
  800763:	ff 55 08             	call   *0x8(%ebp)
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	eb 0d                	jmp    800778 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	ff 75 0c             	pushl  0xc(%ebp)
  800771:	52                   	push   %edx
  800772:	ff 55 08             	call   *0x8(%ebp)
  800775:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800778:	83 eb 01             	sub    $0x1,%ebx
  80077b:	eb 1a                	jmp    800797 <vprintfmt+0x23f>
  80077d:	89 75 08             	mov    %esi,0x8(%ebp)
  800780:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800783:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800786:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800789:	eb 0c                	jmp    800797 <vprintfmt+0x23f>
  80078b:	89 75 08             	mov    %esi,0x8(%ebp)
  80078e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800791:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800794:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800797:	83 c7 01             	add    $0x1,%edi
  80079a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80079e:	0f be d0             	movsbl %al,%edx
  8007a1:	85 d2                	test   %edx,%edx
  8007a3:	74 23                	je     8007c8 <vprintfmt+0x270>
  8007a5:	85 f6                	test   %esi,%esi
  8007a7:	78 a1                	js     80074a <vprintfmt+0x1f2>
  8007a9:	83 ee 01             	sub    $0x1,%esi
  8007ac:	79 9c                	jns    80074a <vprintfmt+0x1f2>
  8007ae:	89 df                	mov    %ebx,%edi
  8007b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b6:	eb 18                	jmp    8007d0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007b8:	83 ec 08             	sub    $0x8,%esp
  8007bb:	53                   	push   %ebx
  8007bc:	6a 20                	push   $0x20
  8007be:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007c0:	83 ef 01             	sub    $0x1,%edi
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	eb 08                	jmp    8007d0 <vprintfmt+0x278>
  8007c8:	89 df                	mov    %ebx,%edi
  8007ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d0:	85 ff                	test   %edi,%edi
  8007d2:	7f e4                	jg     8007b8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007d7:	e9 a2 fd ff ff       	jmp    80057e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007dc:	83 fa 01             	cmp    $0x1,%edx
  8007df:	7e 16                	jle    8007f7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8d 50 08             	lea    0x8(%eax),%edx
  8007e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ea:	8b 50 04             	mov    0x4(%eax),%edx
  8007ed:	8b 00                	mov    (%eax),%eax
  8007ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007f5:	eb 32                	jmp    800829 <vprintfmt+0x2d1>
	else if (lflag)
  8007f7:	85 d2                	test   %edx,%edx
  8007f9:	74 18                	je     800813 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fe:	8d 50 04             	lea    0x4(%eax),%edx
  800801:	89 55 14             	mov    %edx,0x14(%ebp)
  800804:	8b 00                	mov    (%eax),%eax
  800806:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800809:	89 c1                	mov    %eax,%ecx
  80080b:	c1 f9 1f             	sar    $0x1f,%ecx
  80080e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800811:	eb 16                	jmp    800829 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800813:	8b 45 14             	mov    0x14(%ebp),%eax
  800816:	8d 50 04             	lea    0x4(%eax),%edx
  800819:	89 55 14             	mov    %edx,0x14(%ebp)
  80081c:	8b 00                	mov    (%eax),%eax
  80081e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800821:	89 c1                	mov    %eax,%ecx
  800823:	c1 f9 1f             	sar    $0x1f,%ecx
  800826:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800829:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80082c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80082f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800834:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800838:	79 74                	jns    8008ae <vprintfmt+0x356>
				putch('-', putdat);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	53                   	push   %ebx
  80083e:	6a 2d                	push   $0x2d
  800840:	ff d6                	call   *%esi
				num = -(long long) num;
  800842:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800845:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800848:	f7 d8                	neg    %eax
  80084a:	83 d2 00             	adc    $0x0,%edx
  80084d:	f7 da                	neg    %edx
  80084f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800852:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800857:	eb 55                	jmp    8008ae <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800859:	8d 45 14             	lea    0x14(%ebp),%eax
  80085c:	e8 83 fc ff ff       	call   8004e4 <getuint>
			base = 10;
  800861:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800866:	eb 46                	jmp    8008ae <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800868:	8d 45 14             	lea    0x14(%ebp),%eax
  80086b:	e8 74 fc ff ff       	call   8004e4 <getuint>
			base = 8;
  800870:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800875:	eb 37                	jmp    8008ae <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800877:	83 ec 08             	sub    $0x8,%esp
  80087a:	53                   	push   %ebx
  80087b:	6a 30                	push   $0x30
  80087d:	ff d6                	call   *%esi
			putch('x', putdat);
  80087f:	83 c4 08             	add    $0x8,%esp
  800882:	53                   	push   %ebx
  800883:	6a 78                	push   $0x78
  800885:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800887:	8b 45 14             	mov    0x14(%ebp),%eax
  80088a:	8d 50 04             	lea    0x4(%eax),%edx
  80088d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800890:	8b 00                	mov    (%eax),%eax
  800892:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800897:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80089a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80089f:	eb 0d                	jmp    8008ae <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a4:	e8 3b fc ff ff       	call   8004e4 <getuint>
			base = 16;
  8008a9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008ae:	83 ec 0c             	sub    $0xc,%esp
  8008b1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008b5:	57                   	push   %edi
  8008b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b9:	51                   	push   %ecx
  8008ba:	52                   	push   %edx
  8008bb:	50                   	push   %eax
  8008bc:	89 da                	mov    %ebx,%edx
  8008be:	89 f0                	mov    %esi,%eax
  8008c0:	e8 70 fb ff ff       	call   800435 <printnum>
			break;
  8008c5:	83 c4 20             	add    $0x20,%esp
  8008c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008cb:	e9 ae fc ff ff       	jmp    80057e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008d0:	83 ec 08             	sub    $0x8,%esp
  8008d3:	53                   	push   %ebx
  8008d4:	51                   	push   %ecx
  8008d5:	ff d6                	call   *%esi
			break;
  8008d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008dd:	e9 9c fc ff ff       	jmp    80057e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e2:	83 ec 08             	sub    $0x8,%esp
  8008e5:	53                   	push   %ebx
  8008e6:	6a 25                	push   $0x25
  8008e8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	eb 03                	jmp    8008f2 <vprintfmt+0x39a>
  8008ef:	83 ef 01             	sub    $0x1,%edi
  8008f2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008f6:	75 f7                	jne    8008ef <vprintfmt+0x397>
  8008f8:	e9 81 fc ff ff       	jmp    80057e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5f                   	pop    %edi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	83 ec 18             	sub    $0x18,%esp
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800911:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800914:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800918:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80091b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800922:	85 c0                	test   %eax,%eax
  800924:	74 26                	je     80094c <vsnprintf+0x47>
  800926:	85 d2                	test   %edx,%edx
  800928:	7e 22                	jle    80094c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80092a:	ff 75 14             	pushl  0x14(%ebp)
  80092d:	ff 75 10             	pushl  0x10(%ebp)
  800930:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800933:	50                   	push   %eax
  800934:	68 1e 05 80 00       	push   $0x80051e
  800939:	e8 1a fc ff ff       	call   800558 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80093e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800941:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800944:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800947:	83 c4 10             	add    $0x10,%esp
  80094a:	eb 05                	jmp    800951 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80094c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800959:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80095c:	50                   	push   %eax
  80095d:	ff 75 10             	pushl  0x10(%ebp)
  800960:	ff 75 0c             	pushl  0xc(%ebp)
  800963:	ff 75 08             	pushl  0x8(%ebp)
  800966:	e8 9a ff ff ff       	call   800905 <vsnprintf>
	va_end(ap);

	return rc;
}
  80096b:	c9                   	leave  
  80096c:	c3                   	ret    

0080096d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
  800978:	eb 03                	jmp    80097d <strlen+0x10>
		n++;
  80097a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80097d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800981:	75 f7                	jne    80097a <strlen+0xd>
		n++;
	return n;
}
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098e:	ba 00 00 00 00       	mov    $0x0,%edx
  800993:	eb 03                	jmp    800998 <strnlen+0x13>
		n++;
  800995:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800998:	39 c2                	cmp    %eax,%edx
  80099a:	74 08                	je     8009a4 <strnlen+0x1f>
  80099c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009a0:	75 f3                	jne    800995 <strnlen+0x10>
  8009a2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	53                   	push   %ebx
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b0:	89 c2                	mov    %eax,%edx
  8009b2:	83 c2 01             	add    $0x1,%edx
  8009b5:	83 c1 01             	add    $0x1,%ecx
  8009b8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009bc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009bf:	84 db                	test   %bl,%bl
  8009c1:	75 ef                	jne    8009b2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009c3:	5b                   	pop    %ebx
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	53                   	push   %ebx
  8009ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009cd:	53                   	push   %ebx
  8009ce:	e8 9a ff ff ff       	call   80096d <strlen>
  8009d3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009d6:	ff 75 0c             	pushl  0xc(%ebp)
  8009d9:	01 d8                	add    %ebx,%eax
  8009db:	50                   	push   %eax
  8009dc:	e8 c5 ff ff ff       	call   8009a6 <strcpy>
	return dst;
}
  8009e1:	89 d8                	mov    %ebx,%eax
  8009e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e6:	c9                   	leave  
  8009e7:	c3                   	ret    

008009e8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f3:	89 f3                	mov    %esi,%ebx
  8009f5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f8:	89 f2                	mov    %esi,%edx
  8009fa:	eb 0f                	jmp    800a0b <strncpy+0x23>
		*dst++ = *src;
  8009fc:	83 c2 01             	add    $0x1,%edx
  8009ff:	0f b6 01             	movzbl (%ecx),%eax
  800a02:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a05:	80 39 01             	cmpb   $0x1,(%ecx)
  800a08:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0b:	39 da                	cmp    %ebx,%edx
  800a0d:	75 ed                	jne    8009fc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a0f:	89 f0                	mov    %esi,%eax
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a20:	8b 55 10             	mov    0x10(%ebp),%edx
  800a23:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a25:	85 d2                	test   %edx,%edx
  800a27:	74 21                	je     800a4a <strlcpy+0x35>
  800a29:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a2d:	89 f2                	mov    %esi,%edx
  800a2f:	eb 09                	jmp    800a3a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a31:	83 c2 01             	add    $0x1,%edx
  800a34:	83 c1 01             	add    $0x1,%ecx
  800a37:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a3a:	39 c2                	cmp    %eax,%edx
  800a3c:	74 09                	je     800a47 <strlcpy+0x32>
  800a3e:	0f b6 19             	movzbl (%ecx),%ebx
  800a41:	84 db                	test   %bl,%bl
  800a43:	75 ec                	jne    800a31 <strlcpy+0x1c>
  800a45:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a47:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a4a:	29 f0                	sub    %esi,%eax
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a56:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a59:	eb 06                	jmp    800a61 <strcmp+0x11>
		p++, q++;
  800a5b:	83 c1 01             	add    $0x1,%ecx
  800a5e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a61:	0f b6 01             	movzbl (%ecx),%eax
  800a64:	84 c0                	test   %al,%al
  800a66:	74 04                	je     800a6c <strcmp+0x1c>
  800a68:	3a 02                	cmp    (%edx),%al
  800a6a:	74 ef                	je     800a5b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6c:	0f b6 c0             	movzbl %al,%eax
  800a6f:	0f b6 12             	movzbl (%edx),%edx
  800a72:	29 d0                	sub    %edx,%eax
}
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	53                   	push   %ebx
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a80:	89 c3                	mov    %eax,%ebx
  800a82:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a85:	eb 06                	jmp    800a8d <strncmp+0x17>
		n--, p++, q++;
  800a87:	83 c0 01             	add    $0x1,%eax
  800a8a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a8d:	39 d8                	cmp    %ebx,%eax
  800a8f:	74 15                	je     800aa6 <strncmp+0x30>
  800a91:	0f b6 08             	movzbl (%eax),%ecx
  800a94:	84 c9                	test   %cl,%cl
  800a96:	74 04                	je     800a9c <strncmp+0x26>
  800a98:	3a 0a                	cmp    (%edx),%cl
  800a9a:	74 eb                	je     800a87 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a9c:	0f b6 00             	movzbl (%eax),%eax
  800a9f:	0f b6 12             	movzbl (%edx),%edx
  800aa2:	29 d0                	sub    %edx,%eax
  800aa4:	eb 05                	jmp    800aab <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aab:	5b                   	pop    %ebx
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab8:	eb 07                	jmp    800ac1 <strchr+0x13>
		if (*s == c)
  800aba:	38 ca                	cmp    %cl,%dl
  800abc:	74 0f                	je     800acd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800abe:	83 c0 01             	add    $0x1,%eax
  800ac1:	0f b6 10             	movzbl (%eax),%edx
  800ac4:	84 d2                	test   %dl,%dl
  800ac6:	75 f2                	jne    800aba <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad9:	eb 03                	jmp    800ade <strfind+0xf>
  800adb:	83 c0 01             	add    $0x1,%eax
  800ade:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ae1:	38 ca                	cmp    %cl,%dl
  800ae3:	74 04                	je     800ae9 <strfind+0x1a>
  800ae5:	84 d2                	test   %dl,%dl
  800ae7:	75 f2                	jne    800adb <strfind+0xc>
			break;
	return (char *) s;
}
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	57                   	push   %edi
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
  800af1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af7:	85 c9                	test   %ecx,%ecx
  800af9:	74 36                	je     800b31 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800afb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b01:	75 28                	jne    800b2b <memset+0x40>
  800b03:	f6 c1 03             	test   $0x3,%cl
  800b06:	75 23                	jne    800b2b <memset+0x40>
		c &= 0xFF;
  800b08:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b0c:	89 d3                	mov    %edx,%ebx
  800b0e:	c1 e3 08             	shl    $0x8,%ebx
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	c1 e6 18             	shl    $0x18,%esi
  800b16:	89 d0                	mov    %edx,%eax
  800b18:	c1 e0 10             	shl    $0x10,%eax
  800b1b:	09 f0                	or     %esi,%eax
  800b1d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b1f:	89 d8                	mov    %ebx,%eax
  800b21:	09 d0                	or     %edx,%eax
  800b23:	c1 e9 02             	shr    $0x2,%ecx
  800b26:	fc                   	cld    
  800b27:	f3 ab                	rep stos %eax,%es:(%edi)
  800b29:	eb 06                	jmp    800b31 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2e:	fc                   	cld    
  800b2f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b31:	89 f8                	mov    %edi,%eax
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b43:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b46:	39 c6                	cmp    %eax,%esi
  800b48:	73 35                	jae    800b7f <memmove+0x47>
  800b4a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b4d:	39 d0                	cmp    %edx,%eax
  800b4f:	73 2e                	jae    800b7f <memmove+0x47>
		s += n;
		d += n;
  800b51:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	09 fe                	or     %edi,%esi
  800b58:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b5e:	75 13                	jne    800b73 <memmove+0x3b>
  800b60:	f6 c1 03             	test   $0x3,%cl
  800b63:	75 0e                	jne    800b73 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b65:	83 ef 04             	sub    $0x4,%edi
  800b68:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b6b:	c1 e9 02             	shr    $0x2,%ecx
  800b6e:	fd                   	std    
  800b6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b71:	eb 09                	jmp    800b7c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b73:	83 ef 01             	sub    $0x1,%edi
  800b76:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b79:	fd                   	std    
  800b7a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b7c:	fc                   	cld    
  800b7d:	eb 1d                	jmp    800b9c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7f:	89 f2                	mov    %esi,%edx
  800b81:	09 c2                	or     %eax,%edx
  800b83:	f6 c2 03             	test   $0x3,%dl
  800b86:	75 0f                	jne    800b97 <memmove+0x5f>
  800b88:	f6 c1 03             	test   $0x3,%cl
  800b8b:	75 0a                	jne    800b97 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b8d:	c1 e9 02             	shr    $0x2,%ecx
  800b90:	89 c7                	mov    %eax,%edi
  800b92:	fc                   	cld    
  800b93:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b95:	eb 05                	jmp    800b9c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b97:	89 c7                	mov    %eax,%edi
  800b99:	fc                   	cld    
  800b9a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ba3:	ff 75 10             	pushl  0x10(%ebp)
  800ba6:	ff 75 0c             	pushl  0xc(%ebp)
  800ba9:	ff 75 08             	pushl  0x8(%ebp)
  800bac:	e8 87 ff ff ff       	call   800b38 <memmove>
}
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    

00800bb3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbe:	89 c6                	mov    %eax,%esi
  800bc0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc3:	eb 1a                	jmp    800bdf <memcmp+0x2c>
		if (*s1 != *s2)
  800bc5:	0f b6 08             	movzbl (%eax),%ecx
  800bc8:	0f b6 1a             	movzbl (%edx),%ebx
  800bcb:	38 d9                	cmp    %bl,%cl
  800bcd:	74 0a                	je     800bd9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bcf:	0f b6 c1             	movzbl %cl,%eax
  800bd2:	0f b6 db             	movzbl %bl,%ebx
  800bd5:	29 d8                	sub    %ebx,%eax
  800bd7:	eb 0f                	jmp    800be8 <memcmp+0x35>
		s1++, s2++;
  800bd9:	83 c0 01             	add    $0x1,%eax
  800bdc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdf:	39 f0                	cmp    %esi,%eax
  800be1:	75 e2                	jne    800bc5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800be3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	53                   	push   %ebx
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bf3:	89 c1                	mov    %eax,%ecx
  800bf5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bfc:	eb 0a                	jmp    800c08 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bfe:	0f b6 10             	movzbl (%eax),%edx
  800c01:	39 da                	cmp    %ebx,%edx
  800c03:	74 07                	je     800c0c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c05:	83 c0 01             	add    $0x1,%eax
  800c08:	39 c8                	cmp    %ecx,%eax
  800c0a:	72 f2                	jb     800bfe <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1b:	eb 03                	jmp    800c20 <strtol+0x11>
		s++;
  800c1d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c20:	0f b6 01             	movzbl (%ecx),%eax
  800c23:	3c 20                	cmp    $0x20,%al
  800c25:	74 f6                	je     800c1d <strtol+0xe>
  800c27:	3c 09                	cmp    $0x9,%al
  800c29:	74 f2                	je     800c1d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c2b:	3c 2b                	cmp    $0x2b,%al
  800c2d:	75 0a                	jne    800c39 <strtol+0x2a>
		s++;
  800c2f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c32:	bf 00 00 00 00       	mov    $0x0,%edi
  800c37:	eb 11                	jmp    800c4a <strtol+0x3b>
  800c39:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c3e:	3c 2d                	cmp    $0x2d,%al
  800c40:	75 08                	jne    800c4a <strtol+0x3b>
		s++, neg = 1;
  800c42:	83 c1 01             	add    $0x1,%ecx
  800c45:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c4a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c50:	75 15                	jne    800c67 <strtol+0x58>
  800c52:	80 39 30             	cmpb   $0x30,(%ecx)
  800c55:	75 10                	jne    800c67 <strtol+0x58>
  800c57:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c5b:	75 7c                	jne    800cd9 <strtol+0xca>
		s += 2, base = 16;
  800c5d:	83 c1 02             	add    $0x2,%ecx
  800c60:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c65:	eb 16                	jmp    800c7d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c67:	85 db                	test   %ebx,%ebx
  800c69:	75 12                	jne    800c7d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c6b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c70:	80 39 30             	cmpb   $0x30,(%ecx)
  800c73:	75 08                	jne    800c7d <strtol+0x6e>
		s++, base = 8;
  800c75:	83 c1 01             	add    $0x1,%ecx
  800c78:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c82:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c85:	0f b6 11             	movzbl (%ecx),%edx
  800c88:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c8b:	89 f3                	mov    %esi,%ebx
  800c8d:	80 fb 09             	cmp    $0x9,%bl
  800c90:	77 08                	ja     800c9a <strtol+0x8b>
			dig = *s - '0';
  800c92:	0f be d2             	movsbl %dl,%edx
  800c95:	83 ea 30             	sub    $0x30,%edx
  800c98:	eb 22                	jmp    800cbc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c9a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c9d:	89 f3                	mov    %esi,%ebx
  800c9f:	80 fb 19             	cmp    $0x19,%bl
  800ca2:	77 08                	ja     800cac <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ca4:	0f be d2             	movsbl %dl,%edx
  800ca7:	83 ea 57             	sub    $0x57,%edx
  800caa:	eb 10                	jmp    800cbc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cac:	8d 72 bf             	lea    -0x41(%edx),%esi
  800caf:	89 f3                	mov    %esi,%ebx
  800cb1:	80 fb 19             	cmp    $0x19,%bl
  800cb4:	77 16                	ja     800ccc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cb6:	0f be d2             	movsbl %dl,%edx
  800cb9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cbc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cbf:	7d 0b                	jge    800ccc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cc1:	83 c1 01             	add    $0x1,%ecx
  800cc4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cc8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cca:	eb b9                	jmp    800c85 <strtol+0x76>

	if (endptr)
  800ccc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd0:	74 0d                	je     800cdf <strtol+0xd0>
		*endptr = (char *) s;
  800cd2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd5:	89 0e                	mov    %ecx,(%esi)
  800cd7:	eb 06                	jmp    800cdf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd9:	85 db                	test   %ebx,%ebx
  800cdb:	74 98                	je     800c75 <strtol+0x66>
  800cdd:	eb 9e                	jmp    800c7d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cdf:	89 c2                	mov    %eax,%edx
  800ce1:	f7 da                	neg    %edx
  800ce3:	85 ff                	test   %edi,%edi
  800ce5:	0f 45 c2             	cmovne %edx,%eax
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	89 c3                	mov    %eax,%ebx
  800d00:	89 c7                	mov    %eax,%edi
  800d02:	89 c6                	mov    %eax,%esi
  800d04:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_cgetc>:

int
sys_cgetc(void)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	ba 00 00 00 00       	mov    $0x0,%edx
  800d16:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1b:	89 d1                	mov    %edx,%ecx
  800d1d:	89 d3                	mov    %edx,%ebx
  800d1f:	89 d7                	mov    %edx,%edi
  800d21:	89 d6                	mov    %edx,%esi
  800d23:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d38:	b8 03 00 00 00       	mov    $0x3,%eax
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	89 cb                	mov    %ecx,%ebx
  800d42:	89 cf                	mov    %ecx,%edi
  800d44:	89 ce                	mov    %ecx,%esi
  800d46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	7e 17                	jle    800d63 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4c:	83 ec 0c             	sub    $0xc,%esp
  800d4f:	50                   	push   %eax
  800d50:	6a 03                	push   $0x3
  800d52:	68 5f 2a 80 00       	push   $0x802a5f
  800d57:	6a 23                	push   $0x23
  800d59:	68 7c 2a 80 00       	push   $0x802a7c
  800d5e:	e8 e5 f5 ff ff       	call   800348 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	ba 00 00 00 00       	mov    $0x0,%edx
  800d76:	b8 02 00 00 00       	mov    $0x2,%eax
  800d7b:	89 d1                	mov    %edx,%ecx
  800d7d:	89 d3                	mov    %edx,%ebx
  800d7f:	89 d7                	mov    %edx,%edi
  800d81:	89 d6                	mov    %edx,%esi
  800d83:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_yield>:

void
sys_yield(void)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	ba 00 00 00 00       	mov    $0x0,%edx
  800d95:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d9a:	89 d1                	mov    %edx,%ecx
  800d9c:	89 d3                	mov    %edx,%ebx
  800d9e:	89 d7                	mov    %edx,%edi
  800da0:	89 d6                	mov    %edx,%esi
  800da2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	be 00 00 00 00       	mov    $0x0,%esi
  800db7:	b8 04 00 00 00       	mov    $0x4,%eax
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc5:	89 f7                	mov    %esi,%edi
  800dc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 17                	jle    800de4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	50                   	push   %eax
  800dd1:	6a 04                	push   $0x4
  800dd3:	68 5f 2a 80 00       	push   $0x802a5f
  800dd8:	6a 23                	push   $0x23
  800dda:	68 7c 2a 80 00       	push   $0x802a7c
  800ddf:	e8 64 f5 ff ff       	call   800348 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800de4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
  800df2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df5:	b8 05 00 00 00       	mov    $0x5,%eax
  800dfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e03:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e06:	8b 75 18             	mov    0x18(%ebp),%esi
  800e09:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	7e 17                	jle    800e26 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0f:	83 ec 0c             	sub    $0xc,%esp
  800e12:	50                   	push   %eax
  800e13:	6a 05                	push   $0x5
  800e15:	68 5f 2a 80 00       	push   $0x802a5f
  800e1a:	6a 23                	push   $0x23
  800e1c:	68 7c 2a 80 00       	push   $0x802a7c
  800e21:	e8 22 f5 ff ff       	call   800348 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3c:	b8 06 00 00 00       	mov    $0x6,%eax
  800e41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	89 df                	mov    %ebx,%edi
  800e49:	89 de                	mov    %ebx,%esi
  800e4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	7e 17                	jle    800e68 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e51:	83 ec 0c             	sub    $0xc,%esp
  800e54:	50                   	push   %eax
  800e55:	6a 06                	push   $0x6
  800e57:	68 5f 2a 80 00       	push   $0x802a5f
  800e5c:	6a 23                	push   $0x23
  800e5e:	68 7c 2a 80 00       	push   $0x802a7c
  800e63:	e8 e0 f4 ff ff       	call   800348 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6b:	5b                   	pop    %ebx
  800e6c:	5e                   	pop    %esi
  800e6d:	5f                   	pop    %edi
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    

00800e70 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
  800e76:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7e:	b8 08 00 00 00       	mov    $0x8,%eax
  800e83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e86:	8b 55 08             	mov    0x8(%ebp),%edx
  800e89:	89 df                	mov    %ebx,%edi
  800e8b:	89 de                	mov    %ebx,%esi
  800e8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	7e 17                	jle    800eaa <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e93:	83 ec 0c             	sub    $0xc,%esp
  800e96:	50                   	push   %eax
  800e97:	6a 08                	push   $0x8
  800e99:	68 5f 2a 80 00       	push   $0x802a5f
  800e9e:	6a 23                	push   $0x23
  800ea0:	68 7c 2a 80 00       	push   $0x802a7c
  800ea5:	e8 9e f4 ff ff       	call   800348 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800eaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5f                   	pop    %edi
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	57                   	push   %edi
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
  800eb8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec0:	b8 09 00 00 00       	mov    $0x9,%eax
  800ec5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecb:	89 df                	mov    %ebx,%edi
  800ecd:	89 de                	mov    %ebx,%esi
  800ecf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed1:	85 c0                	test   %eax,%eax
  800ed3:	7e 17                	jle    800eec <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed5:	83 ec 0c             	sub    $0xc,%esp
  800ed8:	50                   	push   %eax
  800ed9:	6a 09                	push   $0x9
  800edb:	68 5f 2a 80 00       	push   $0x802a5f
  800ee0:	6a 23                	push   $0x23
  800ee2:	68 7c 2a 80 00       	push   $0x802a7c
  800ee7:	e8 5c f4 ff ff       	call   800348 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eef:	5b                   	pop    %ebx
  800ef0:	5e                   	pop    %esi
  800ef1:	5f                   	pop    %edi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
  800efa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f02:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0d:	89 df                	mov    %ebx,%edi
  800f0f:	89 de                	mov    %ebx,%esi
  800f11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f13:	85 c0                	test   %eax,%eax
  800f15:	7e 17                	jle    800f2e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f17:	83 ec 0c             	sub    $0xc,%esp
  800f1a:	50                   	push   %eax
  800f1b:	6a 0a                	push   $0xa
  800f1d:	68 5f 2a 80 00       	push   $0x802a5f
  800f22:	6a 23                	push   $0x23
  800f24:	68 7c 2a 80 00       	push   $0x802a7c
  800f29:	e8 1a f4 ff ff       	call   800348 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5f                   	pop    %edi
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    

00800f36 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	57                   	push   %edi
  800f3a:	56                   	push   %esi
  800f3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3c:	be 00 00 00 00       	mov    $0x0,%esi
  800f41:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f49:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f52:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	57                   	push   %edi
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx
  800f5f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f67:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6f:	89 cb                	mov    %ecx,%ebx
  800f71:	89 cf                	mov    %ecx,%edi
  800f73:	89 ce                	mov    %ecx,%esi
  800f75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f77:	85 c0                	test   %eax,%eax
  800f79:	7e 17                	jle    800f92 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7b:	83 ec 0c             	sub    $0xc,%esp
  800f7e:	50                   	push   %eax
  800f7f:	6a 0d                	push   $0xd
  800f81:	68 5f 2a 80 00       	push   $0x802a5f
  800f86:	6a 23                	push   $0x23
  800f88:	68 7c 2a 80 00       	push   $0x802a7c
  800f8d:	e8 b6 f3 ff ff       	call   800348 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	57                   	push   %edi
  800f9e:	56                   	push   %esi
  800f9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800faa:	8b 55 08             	mov    0x8(%ebp),%edx
  800fad:	89 cb                	mov    %ecx,%ebx
  800faf:	89 cf                	mov    %ecx,%edi
  800fb1:	89 ce                	mov    %ecx,%esi
  800fb3:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5f                   	pop    %edi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	57                   	push   %edi
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc5:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fca:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcd:	89 cb                	mov    %ecx,%ebx
  800fcf:	89 cf                	mov    %ecx,%edi
  800fd1:	89 ce                	mov    %ecx,%esi
  800fd3:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800fd5:	5b                   	pop    %ebx
  800fd6:	5e                   	pop    %esi
  800fd7:	5f                   	pop    %edi
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	53                   	push   %ebx
  800fde:	83 ec 04             	sub    $0x4,%esp
  800fe1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fe4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800fe6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fea:	74 11                	je     800ffd <pgfault+0x23>
  800fec:	89 d8                	mov    %ebx,%eax
  800fee:	c1 e8 0c             	shr    $0xc,%eax
  800ff1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff8:	f6 c4 08             	test   $0x8,%ah
  800ffb:	75 14                	jne    801011 <pgfault+0x37>
		panic("faulting access");
  800ffd:	83 ec 04             	sub    $0x4,%esp
  801000:	68 8a 2a 80 00       	push   $0x802a8a
  801005:	6a 1e                	push   $0x1e
  801007:	68 9a 2a 80 00       	push   $0x802a9a
  80100c:	e8 37 f3 ff ff       	call   800348 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  801011:	83 ec 04             	sub    $0x4,%esp
  801014:	6a 07                	push   $0x7
  801016:	68 00 f0 7f 00       	push   $0x7ff000
  80101b:	6a 00                	push   $0x0
  80101d:	e8 87 fd ff ff       	call   800da9 <sys_page_alloc>
	if (r < 0) {
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	85 c0                	test   %eax,%eax
  801027:	79 12                	jns    80103b <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  801029:	50                   	push   %eax
  80102a:	68 a5 2a 80 00       	push   $0x802aa5
  80102f:	6a 2c                	push   $0x2c
  801031:	68 9a 2a 80 00       	push   $0x802a9a
  801036:	e8 0d f3 ff ff       	call   800348 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80103b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  801041:	83 ec 04             	sub    $0x4,%esp
  801044:	68 00 10 00 00       	push   $0x1000
  801049:	53                   	push   %ebx
  80104a:	68 00 f0 7f 00       	push   $0x7ff000
  80104f:	e8 4c fb ff ff       	call   800ba0 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801054:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80105b:	53                   	push   %ebx
  80105c:	6a 00                	push   $0x0
  80105e:	68 00 f0 7f 00       	push   $0x7ff000
  801063:	6a 00                	push   $0x0
  801065:	e8 82 fd ff ff       	call   800dec <sys_page_map>
	if (r < 0) {
  80106a:	83 c4 20             	add    $0x20,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	79 12                	jns    801083 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  801071:	50                   	push   %eax
  801072:	68 a5 2a 80 00       	push   $0x802aa5
  801077:	6a 33                	push   $0x33
  801079:	68 9a 2a 80 00       	push   $0x802a9a
  80107e:	e8 c5 f2 ff ff       	call   800348 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  801083:	83 ec 08             	sub    $0x8,%esp
  801086:	68 00 f0 7f 00       	push   $0x7ff000
  80108b:	6a 00                	push   $0x0
  80108d:	e8 9c fd ff ff       	call   800e2e <sys_page_unmap>
	if (r < 0) {
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	85 c0                	test   %eax,%eax
  801097:	79 12                	jns    8010ab <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  801099:	50                   	push   %eax
  80109a:	68 a5 2a 80 00       	push   $0x802aa5
  80109f:	6a 37                	push   $0x37
  8010a1:	68 9a 2a 80 00       	push   $0x802a9a
  8010a6:	e8 9d f2 ff ff       	call   800348 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8010ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ae:	c9                   	leave  
  8010af:	c3                   	ret    

008010b0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	57                   	push   %edi
  8010b4:	56                   	push   %esi
  8010b5:	53                   	push   %ebx
  8010b6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8010b9:	68 da 0f 80 00       	push   $0x800fda
  8010be:	e8 57 11 00 00       	call   80221a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010c3:	b8 07 00 00 00       	mov    $0x7,%eax
  8010c8:	cd 30                	int    $0x30
  8010ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	79 17                	jns    8010eb <fork+0x3b>
		panic("fork fault %e");
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	68 be 2a 80 00       	push   $0x802abe
  8010dc:	68 84 00 00 00       	push   $0x84
  8010e1:	68 9a 2a 80 00       	push   $0x802a9a
  8010e6:	e8 5d f2 ff ff       	call   800348 <_panic>
  8010eb:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8010ed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010f1:	75 25                	jne    801118 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010f3:	e8 73 fc ff ff       	call   800d6b <sys_getenvid>
  8010f8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010fd:	89 c2                	mov    %eax,%edx
  8010ff:	c1 e2 07             	shl    $0x7,%edx
  801102:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801109:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  80110e:	b8 00 00 00 00       	mov    $0x0,%eax
  801113:	e9 61 01 00 00       	jmp    801279 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801118:	83 ec 04             	sub    $0x4,%esp
  80111b:	6a 07                	push   $0x7
  80111d:	68 00 f0 bf ee       	push   $0xeebff000
  801122:	ff 75 e4             	pushl  -0x1c(%ebp)
  801125:	e8 7f fc ff ff       	call   800da9 <sys_page_alloc>
  80112a:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80112d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801132:	89 d8                	mov    %ebx,%eax
  801134:	c1 e8 16             	shr    $0x16,%eax
  801137:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80113e:	a8 01                	test   $0x1,%al
  801140:	0f 84 fc 00 00 00    	je     801242 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801146:	89 d8                	mov    %ebx,%eax
  801148:	c1 e8 0c             	shr    $0xc,%eax
  80114b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801152:	f6 c2 01             	test   $0x1,%dl
  801155:	0f 84 e7 00 00 00    	je     801242 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80115b:	89 c6                	mov    %eax,%esi
  80115d:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801160:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801167:	f6 c6 04             	test   $0x4,%dh
  80116a:	74 39                	je     8011a5 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80116c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801173:	83 ec 0c             	sub    $0xc,%esp
  801176:	25 07 0e 00 00       	and    $0xe07,%eax
  80117b:	50                   	push   %eax
  80117c:	56                   	push   %esi
  80117d:	57                   	push   %edi
  80117e:	56                   	push   %esi
  80117f:	6a 00                	push   $0x0
  801181:	e8 66 fc ff ff       	call   800dec <sys_page_map>
		if (r < 0) {
  801186:	83 c4 20             	add    $0x20,%esp
  801189:	85 c0                	test   %eax,%eax
  80118b:	0f 89 b1 00 00 00    	jns    801242 <fork+0x192>
		    	panic("sys page map fault %e");
  801191:	83 ec 04             	sub    $0x4,%esp
  801194:	68 cc 2a 80 00       	push   $0x802acc
  801199:	6a 54                	push   $0x54
  80119b:	68 9a 2a 80 00       	push   $0x802a9a
  8011a0:	e8 a3 f1 ff ff       	call   800348 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8011a5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011ac:	f6 c2 02             	test   $0x2,%dl
  8011af:	75 0c                	jne    8011bd <fork+0x10d>
  8011b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b8:	f6 c4 08             	test   $0x8,%ah
  8011bb:	74 5b                	je     801218 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8011bd:	83 ec 0c             	sub    $0xc,%esp
  8011c0:	68 05 08 00 00       	push   $0x805
  8011c5:	56                   	push   %esi
  8011c6:	57                   	push   %edi
  8011c7:	56                   	push   %esi
  8011c8:	6a 00                	push   $0x0
  8011ca:	e8 1d fc ff ff       	call   800dec <sys_page_map>
		if (r < 0) {
  8011cf:	83 c4 20             	add    $0x20,%esp
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	79 14                	jns    8011ea <fork+0x13a>
		    	panic("sys page map fault %e");
  8011d6:	83 ec 04             	sub    $0x4,%esp
  8011d9:	68 cc 2a 80 00       	push   $0x802acc
  8011de:	6a 5b                	push   $0x5b
  8011e0:	68 9a 2a 80 00       	push   $0x802a9a
  8011e5:	e8 5e f1 ff ff       	call   800348 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8011ea:	83 ec 0c             	sub    $0xc,%esp
  8011ed:	68 05 08 00 00       	push   $0x805
  8011f2:	56                   	push   %esi
  8011f3:	6a 00                	push   $0x0
  8011f5:	56                   	push   %esi
  8011f6:	6a 00                	push   $0x0
  8011f8:	e8 ef fb ff ff       	call   800dec <sys_page_map>
		if (r < 0) {
  8011fd:	83 c4 20             	add    $0x20,%esp
  801200:	85 c0                	test   %eax,%eax
  801202:	79 3e                	jns    801242 <fork+0x192>
		    	panic("sys page map fault %e");
  801204:	83 ec 04             	sub    $0x4,%esp
  801207:	68 cc 2a 80 00       	push   $0x802acc
  80120c:	6a 5f                	push   $0x5f
  80120e:	68 9a 2a 80 00       	push   $0x802a9a
  801213:	e8 30 f1 ff ff       	call   800348 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801218:	83 ec 0c             	sub    $0xc,%esp
  80121b:	6a 05                	push   $0x5
  80121d:	56                   	push   %esi
  80121e:	57                   	push   %edi
  80121f:	56                   	push   %esi
  801220:	6a 00                	push   $0x0
  801222:	e8 c5 fb ff ff       	call   800dec <sys_page_map>
		if (r < 0) {
  801227:	83 c4 20             	add    $0x20,%esp
  80122a:	85 c0                	test   %eax,%eax
  80122c:	79 14                	jns    801242 <fork+0x192>
		    	panic("sys page map fault %e");
  80122e:	83 ec 04             	sub    $0x4,%esp
  801231:	68 cc 2a 80 00       	push   $0x802acc
  801236:	6a 64                	push   $0x64
  801238:	68 9a 2a 80 00       	push   $0x802a9a
  80123d:	e8 06 f1 ff ff       	call   800348 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801242:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801248:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80124e:	0f 85 de fe ff ff    	jne    801132 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801254:	a1 20 44 80 00       	mov    0x804420,%eax
  801259:	8b 40 70             	mov    0x70(%eax),%eax
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	50                   	push   %eax
  801260:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801263:	57                   	push   %edi
  801264:	e8 8b fc ff ff       	call   800ef4 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801269:	83 c4 08             	add    $0x8,%esp
  80126c:	6a 02                	push   $0x2
  80126e:	57                   	push   %edi
  80126f:	e8 fc fb ff ff       	call   800e70 <sys_env_set_status>
	
	return envid;
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801279:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127c:	5b                   	pop    %ebx
  80127d:	5e                   	pop    %esi
  80127e:	5f                   	pop    %edi
  80127f:	5d                   	pop    %ebp
  801280:	c3                   	ret    

00801281 <sfork>:

envid_t
sfork(void)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801284:	b8 00 00 00 00       	mov    $0x0,%eax
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	56                   	push   %esi
  80128f:	53                   	push   %ebx
  801290:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801293:	89 1d 24 44 80 00    	mov    %ebx,0x804424
	cprintf("in fork.c thread create. func: %x\n", func);
  801299:	83 ec 08             	sub    $0x8,%esp
  80129c:	53                   	push   %ebx
  80129d:	68 e4 2a 80 00       	push   $0x802ae4
  8012a2:	e8 7a f1 ff ff       	call   800421 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8012a7:	c7 04 24 0e 03 80 00 	movl   $0x80030e,(%esp)
  8012ae:	e8 e7 fc ff ff       	call   800f9a <sys_thread_create>
  8012b3:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8012b5:	83 c4 08             	add    $0x8,%esp
  8012b8:	53                   	push   %ebx
  8012b9:	68 e4 2a 80 00       	push   $0x802ae4
  8012be:	e8 5e f1 ff ff       	call   800421 <cprintf>
	return id;
	//return 0;
}
  8012c3:	89 f0                	mov    %esi,%eax
  8012c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5d                   	pop    %ebp
  8012cb:	c3                   	ret    

008012cc <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d5:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  8012d8:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  8012da:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  8012dd:	83 3a 01             	cmpl   $0x1,(%edx)
  8012e0:	7e 09                	jle    8012eb <argstart+0x1f>
  8012e2:	ba 08 27 80 00       	mov    $0x802708,%edx
  8012e7:	85 c9                	test   %ecx,%ecx
  8012e9:	75 05                	jne    8012f0 <argstart+0x24>
  8012eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f0:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  8012f3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <argnext>:

int
argnext(struct Argstate *args)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	53                   	push   %ebx
  801300:	83 ec 04             	sub    $0x4,%esp
  801303:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801306:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  80130d:	8b 43 08             	mov    0x8(%ebx),%eax
  801310:	85 c0                	test   %eax,%eax
  801312:	74 6f                	je     801383 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801314:	80 38 00             	cmpb   $0x0,(%eax)
  801317:	75 4e                	jne    801367 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801319:	8b 0b                	mov    (%ebx),%ecx
  80131b:	83 39 01             	cmpl   $0x1,(%ecx)
  80131e:	74 55                	je     801375 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801320:	8b 53 04             	mov    0x4(%ebx),%edx
  801323:	8b 42 04             	mov    0x4(%edx),%eax
  801326:	80 38 2d             	cmpb   $0x2d,(%eax)
  801329:	75 4a                	jne    801375 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  80132b:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80132f:	74 44                	je     801375 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801331:	83 c0 01             	add    $0x1,%eax
  801334:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801337:	83 ec 04             	sub    $0x4,%esp
  80133a:	8b 01                	mov    (%ecx),%eax
  80133c:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801343:	50                   	push   %eax
  801344:	8d 42 08             	lea    0x8(%edx),%eax
  801347:	50                   	push   %eax
  801348:	83 c2 04             	add    $0x4,%edx
  80134b:	52                   	push   %edx
  80134c:	e8 e7 f7 ff ff       	call   800b38 <memmove>
		(*args->argc)--;
  801351:	8b 03                	mov    (%ebx),%eax
  801353:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801356:	8b 43 08             	mov    0x8(%ebx),%eax
  801359:	83 c4 10             	add    $0x10,%esp
  80135c:	80 38 2d             	cmpb   $0x2d,(%eax)
  80135f:	75 06                	jne    801367 <argnext+0x6b>
  801361:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801365:	74 0e                	je     801375 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801367:	8b 53 08             	mov    0x8(%ebx),%edx
  80136a:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  80136d:	83 c2 01             	add    $0x1,%edx
  801370:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801373:	eb 13                	jmp    801388 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801375:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  80137c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801381:	eb 05                	jmp    801388 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801383:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801388:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    

0080138d <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	53                   	push   %ebx
  801391:	83 ec 04             	sub    $0x4,%esp
  801394:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801397:	8b 43 08             	mov    0x8(%ebx),%eax
  80139a:	85 c0                	test   %eax,%eax
  80139c:	74 58                	je     8013f6 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  80139e:	80 38 00             	cmpb   $0x0,(%eax)
  8013a1:	74 0c                	je     8013af <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8013a3:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8013a6:	c7 43 08 08 27 80 00 	movl   $0x802708,0x8(%ebx)
  8013ad:	eb 42                	jmp    8013f1 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  8013af:	8b 13                	mov    (%ebx),%edx
  8013b1:	83 3a 01             	cmpl   $0x1,(%edx)
  8013b4:	7e 2d                	jle    8013e3 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  8013b6:	8b 43 04             	mov    0x4(%ebx),%eax
  8013b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8013bc:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8013bf:	83 ec 04             	sub    $0x4,%esp
  8013c2:	8b 12                	mov    (%edx),%edx
  8013c4:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  8013cb:	52                   	push   %edx
  8013cc:	8d 50 08             	lea    0x8(%eax),%edx
  8013cf:	52                   	push   %edx
  8013d0:	83 c0 04             	add    $0x4,%eax
  8013d3:	50                   	push   %eax
  8013d4:	e8 5f f7 ff ff       	call   800b38 <memmove>
		(*args->argc)--;
  8013d9:	8b 03                	mov    (%ebx),%eax
  8013db:	83 28 01             	subl   $0x1,(%eax)
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	eb 0e                	jmp    8013f1 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  8013e3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8013ea:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8013f1:	8b 43 0c             	mov    0xc(%ebx),%eax
  8013f4:	eb 05                	jmp    8013fb <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8013f6:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8013fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fe:	c9                   	leave  
  8013ff:	c3                   	ret    

00801400 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801409:	8b 51 0c             	mov    0xc(%ecx),%edx
  80140c:	89 d0                	mov    %edx,%eax
  80140e:	85 d2                	test   %edx,%edx
  801410:	75 0c                	jne    80141e <argvalue+0x1e>
  801412:	83 ec 0c             	sub    $0xc,%esp
  801415:	51                   	push   %ecx
  801416:	e8 72 ff ff ff       	call   80138d <argnextvalue>
  80141b:	83 c4 10             	add    $0x10,%esp
}
  80141e:	c9                   	leave  
  80141f:	c3                   	ret    

00801420 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801423:	8b 45 08             	mov    0x8(%ebp),%eax
  801426:	05 00 00 00 30       	add    $0x30000000,%eax
  80142b:	c1 e8 0c             	shr    $0xc,%eax
}
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    

00801430 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801433:	8b 45 08             	mov    0x8(%ebp),%eax
  801436:	05 00 00 00 30       	add    $0x30000000,%eax
  80143b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801440:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801445:	5d                   	pop    %ebp
  801446:	c3                   	ret    

00801447 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801447:	55                   	push   %ebp
  801448:	89 e5                	mov    %esp,%ebp
  80144a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80144d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801452:	89 c2                	mov    %eax,%edx
  801454:	c1 ea 16             	shr    $0x16,%edx
  801457:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80145e:	f6 c2 01             	test   $0x1,%dl
  801461:	74 11                	je     801474 <fd_alloc+0x2d>
  801463:	89 c2                	mov    %eax,%edx
  801465:	c1 ea 0c             	shr    $0xc,%edx
  801468:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80146f:	f6 c2 01             	test   $0x1,%dl
  801472:	75 09                	jne    80147d <fd_alloc+0x36>
			*fd_store = fd;
  801474:	89 01                	mov    %eax,(%ecx)
			return 0;
  801476:	b8 00 00 00 00       	mov    $0x0,%eax
  80147b:	eb 17                	jmp    801494 <fd_alloc+0x4d>
  80147d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801482:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801487:	75 c9                	jne    801452 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801489:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80148f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801494:	5d                   	pop    %ebp
  801495:	c3                   	ret    

00801496 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80149c:	83 f8 1f             	cmp    $0x1f,%eax
  80149f:	77 36                	ja     8014d7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014a1:	c1 e0 0c             	shl    $0xc,%eax
  8014a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	c1 ea 16             	shr    $0x16,%edx
  8014ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014b5:	f6 c2 01             	test   $0x1,%dl
  8014b8:	74 24                	je     8014de <fd_lookup+0x48>
  8014ba:	89 c2                	mov    %eax,%edx
  8014bc:	c1 ea 0c             	shr    $0xc,%edx
  8014bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014c6:	f6 c2 01             	test   $0x1,%dl
  8014c9:	74 1a                	je     8014e5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ce:	89 02                	mov    %eax,(%edx)
	return 0;
  8014d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d5:	eb 13                	jmp    8014ea <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014dc:	eb 0c                	jmp    8014ea <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014e3:	eb 05                	jmp    8014ea <fd_lookup+0x54>
  8014e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014ea:	5d                   	pop    %ebp
  8014eb:	c3                   	ret    

008014ec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	83 ec 08             	sub    $0x8,%esp
  8014f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014f5:	ba 88 2b 80 00       	mov    $0x802b88,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014fa:	eb 13                	jmp    80150f <dev_lookup+0x23>
  8014fc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014ff:	39 08                	cmp    %ecx,(%eax)
  801501:	75 0c                	jne    80150f <dev_lookup+0x23>
			*dev = devtab[i];
  801503:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801506:	89 01                	mov    %eax,(%ecx)
			return 0;
  801508:	b8 00 00 00 00       	mov    $0x0,%eax
  80150d:	eb 2e                	jmp    80153d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80150f:	8b 02                	mov    (%edx),%eax
  801511:	85 c0                	test   %eax,%eax
  801513:	75 e7                	jne    8014fc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801515:	a1 20 44 80 00       	mov    0x804420,%eax
  80151a:	8b 40 54             	mov    0x54(%eax),%eax
  80151d:	83 ec 04             	sub    $0x4,%esp
  801520:	51                   	push   %ecx
  801521:	50                   	push   %eax
  801522:	68 08 2b 80 00       	push   $0x802b08
  801527:	e8 f5 ee ff ff       	call   800421 <cprintf>
	*dev = 0;
  80152c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80152f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	56                   	push   %esi
  801543:	53                   	push   %ebx
  801544:	83 ec 10             	sub    $0x10,%esp
  801547:	8b 75 08             	mov    0x8(%ebp),%esi
  80154a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80154d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801550:	50                   	push   %eax
  801551:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801557:	c1 e8 0c             	shr    $0xc,%eax
  80155a:	50                   	push   %eax
  80155b:	e8 36 ff ff ff       	call   801496 <fd_lookup>
  801560:	83 c4 08             	add    $0x8,%esp
  801563:	85 c0                	test   %eax,%eax
  801565:	78 05                	js     80156c <fd_close+0x2d>
	    || fd != fd2)
  801567:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80156a:	74 0c                	je     801578 <fd_close+0x39>
		return (must_exist ? r : 0);
  80156c:	84 db                	test   %bl,%bl
  80156e:	ba 00 00 00 00       	mov    $0x0,%edx
  801573:	0f 44 c2             	cmove  %edx,%eax
  801576:	eb 41                	jmp    8015b9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801578:	83 ec 08             	sub    $0x8,%esp
  80157b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157e:	50                   	push   %eax
  80157f:	ff 36                	pushl  (%esi)
  801581:	e8 66 ff ff ff       	call   8014ec <dev_lookup>
  801586:	89 c3                	mov    %eax,%ebx
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 1a                	js     8015a9 <fd_close+0x6a>
		if (dev->dev_close)
  80158f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801592:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801595:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80159a:	85 c0                	test   %eax,%eax
  80159c:	74 0b                	je     8015a9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80159e:	83 ec 0c             	sub    $0xc,%esp
  8015a1:	56                   	push   %esi
  8015a2:	ff d0                	call   *%eax
  8015a4:	89 c3                	mov    %eax,%ebx
  8015a6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015a9:	83 ec 08             	sub    $0x8,%esp
  8015ac:	56                   	push   %esi
  8015ad:	6a 00                	push   $0x0
  8015af:	e8 7a f8 ff ff       	call   800e2e <sys_page_unmap>
	return r;
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	89 d8                	mov    %ebx,%eax
}
  8015b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015bc:	5b                   	pop    %ebx
  8015bd:	5e                   	pop    %esi
  8015be:	5d                   	pop    %ebp
  8015bf:	c3                   	ret    

008015c0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	ff 75 08             	pushl  0x8(%ebp)
  8015cd:	e8 c4 fe ff ff       	call   801496 <fd_lookup>
  8015d2:	83 c4 08             	add    $0x8,%esp
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 10                	js     8015e9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015d9:	83 ec 08             	sub    $0x8,%esp
  8015dc:	6a 01                	push   $0x1
  8015de:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e1:	e8 59 ff ff ff       	call   80153f <fd_close>
  8015e6:	83 c4 10             	add    $0x10,%esp
}
  8015e9:	c9                   	leave  
  8015ea:	c3                   	ret    

008015eb <close_all>:

void
close_all(void)
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	53                   	push   %ebx
  8015ef:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015f2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015f7:	83 ec 0c             	sub    $0xc,%esp
  8015fa:	53                   	push   %ebx
  8015fb:	e8 c0 ff ff ff       	call   8015c0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801600:	83 c3 01             	add    $0x1,%ebx
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	83 fb 20             	cmp    $0x20,%ebx
  801609:	75 ec                	jne    8015f7 <close_all+0xc>
		close(i);
}
  80160b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    

00801610 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	57                   	push   %edi
  801614:	56                   	push   %esi
  801615:	53                   	push   %ebx
  801616:	83 ec 2c             	sub    $0x2c,%esp
  801619:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80161c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80161f:	50                   	push   %eax
  801620:	ff 75 08             	pushl  0x8(%ebp)
  801623:	e8 6e fe ff ff       	call   801496 <fd_lookup>
  801628:	83 c4 08             	add    $0x8,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	0f 88 c1 00 00 00    	js     8016f4 <dup+0xe4>
		return r;
	close(newfdnum);
  801633:	83 ec 0c             	sub    $0xc,%esp
  801636:	56                   	push   %esi
  801637:	e8 84 ff ff ff       	call   8015c0 <close>

	newfd = INDEX2FD(newfdnum);
  80163c:	89 f3                	mov    %esi,%ebx
  80163e:	c1 e3 0c             	shl    $0xc,%ebx
  801641:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801647:	83 c4 04             	add    $0x4,%esp
  80164a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80164d:	e8 de fd ff ff       	call   801430 <fd2data>
  801652:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801654:	89 1c 24             	mov    %ebx,(%esp)
  801657:	e8 d4 fd ff ff       	call   801430 <fd2data>
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801662:	89 f8                	mov    %edi,%eax
  801664:	c1 e8 16             	shr    $0x16,%eax
  801667:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80166e:	a8 01                	test   $0x1,%al
  801670:	74 37                	je     8016a9 <dup+0x99>
  801672:	89 f8                	mov    %edi,%eax
  801674:	c1 e8 0c             	shr    $0xc,%eax
  801677:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80167e:	f6 c2 01             	test   $0x1,%dl
  801681:	74 26                	je     8016a9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801683:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80168a:	83 ec 0c             	sub    $0xc,%esp
  80168d:	25 07 0e 00 00       	and    $0xe07,%eax
  801692:	50                   	push   %eax
  801693:	ff 75 d4             	pushl  -0x2c(%ebp)
  801696:	6a 00                	push   $0x0
  801698:	57                   	push   %edi
  801699:	6a 00                	push   $0x0
  80169b:	e8 4c f7 ff ff       	call   800dec <sys_page_map>
  8016a0:	89 c7                	mov    %eax,%edi
  8016a2:	83 c4 20             	add    $0x20,%esp
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	78 2e                	js     8016d7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016ac:	89 d0                	mov    %edx,%eax
  8016ae:	c1 e8 0c             	shr    $0xc,%eax
  8016b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016b8:	83 ec 0c             	sub    $0xc,%esp
  8016bb:	25 07 0e 00 00       	and    $0xe07,%eax
  8016c0:	50                   	push   %eax
  8016c1:	53                   	push   %ebx
  8016c2:	6a 00                	push   $0x0
  8016c4:	52                   	push   %edx
  8016c5:	6a 00                	push   $0x0
  8016c7:	e8 20 f7 ff ff       	call   800dec <sys_page_map>
  8016cc:	89 c7                	mov    %eax,%edi
  8016ce:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016d1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016d3:	85 ff                	test   %edi,%edi
  8016d5:	79 1d                	jns    8016f4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016d7:	83 ec 08             	sub    $0x8,%esp
  8016da:	53                   	push   %ebx
  8016db:	6a 00                	push   $0x0
  8016dd:	e8 4c f7 ff ff       	call   800e2e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016e2:	83 c4 08             	add    $0x8,%esp
  8016e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016e8:	6a 00                	push   $0x0
  8016ea:	e8 3f f7 ff ff       	call   800e2e <sys_page_unmap>
	return r;
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	89 f8                	mov    %edi,%eax
}
  8016f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f7:	5b                   	pop    %ebx
  8016f8:	5e                   	pop    %esi
  8016f9:	5f                   	pop    %edi
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	53                   	push   %ebx
  801700:	83 ec 14             	sub    $0x14,%esp
  801703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801706:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801709:	50                   	push   %eax
  80170a:	53                   	push   %ebx
  80170b:	e8 86 fd ff ff       	call   801496 <fd_lookup>
  801710:	83 c4 08             	add    $0x8,%esp
  801713:	89 c2                	mov    %eax,%edx
  801715:	85 c0                	test   %eax,%eax
  801717:	78 6d                	js     801786 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801719:	83 ec 08             	sub    $0x8,%esp
  80171c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171f:	50                   	push   %eax
  801720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801723:	ff 30                	pushl  (%eax)
  801725:	e8 c2 fd ff ff       	call   8014ec <dev_lookup>
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	85 c0                	test   %eax,%eax
  80172f:	78 4c                	js     80177d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801731:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801734:	8b 42 08             	mov    0x8(%edx),%eax
  801737:	83 e0 03             	and    $0x3,%eax
  80173a:	83 f8 01             	cmp    $0x1,%eax
  80173d:	75 21                	jne    801760 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80173f:	a1 20 44 80 00       	mov    0x804420,%eax
  801744:	8b 40 54             	mov    0x54(%eax),%eax
  801747:	83 ec 04             	sub    $0x4,%esp
  80174a:	53                   	push   %ebx
  80174b:	50                   	push   %eax
  80174c:	68 4c 2b 80 00       	push   $0x802b4c
  801751:	e8 cb ec ff ff       	call   800421 <cprintf>
		return -E_INVAL;
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80175e:	eb 26                	jmp    801786 <read+0x8a>
	}
	if (!dev->dev_read)
  801760:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801763:	8b 40 08             	mov    0x8(%eax),%eax
  801766:	85 c0                	test   %eax,%eax
  801768:	74 17                	je     801781 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80176a:	83 ec 04             	sub    $0x4,%esp
  80176d:	ff 75 10             	pushl  0x10(%ebp)
  801770:	ff 75 0c             	pushl  0xc(%ebp)
  801773:	52                   	push   %edx
  801774:	ff d0                	call   *%eax
  801776:	89 c2                	mov    %eax,%edx
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	eb 09                	jmp    801786 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177d:	89 c2                	mov    %eax,%edx
  80177f:	eb 05                	jmp    801786 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801781:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801786:	89 d0                	mov    %edx,%eax
  801788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178b:	c9                   	leave  
  80178c:	c3                   	ret    

0080178d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	57                   	push   %edi
  801791:	56                   	push   %esi
  801792:	53                   	push   %ebx
  801793:	83 ec 0c             	sub    $0xc,%esp
  801796:	8b 7d 08             	mov    0x8(%ebp),%edi
  801799:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80179c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017a1:	eb 21                	jmp    8017c4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017a3:	83 ec 04             	sub    $0x4,%esp
  8017a6:	89 f0                	mov    %esi,%eax
  8017a8:	29 d8                	sub    %ebx,%eax
  8017aa:	50                   	push   %eax
  8017ab:	89 d8                	mov    %ebx,%eax
  8017ad:	03 45 0c             	add    0xc(%ebp),%eax
  8017b0:	50                   	push   %eax
  8017b1:	57                   	push   %edi
  8017b2:	e8 45 ff ff ff       	call   8016fc <read>
		if (m < 0)
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	78 10                	js     8017ce <readn+0x41>
			return m;
		if (m == 0)
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	74 0a                	je     8017cc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017c2:	01 c3                	add    %eax,%ebx
  8017c4:	39 f3                	cmp    %esi,%ebx
  8017c6:	72 db                	jb     8017a3 <readn+0x16>
  8017c8:	89 d8                	mov    %ebx,%eax
  8017ca:	eb 02                	jmp    8017ce <readn+0x41>
  8017cc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d1:	5b                   	pop    %ebx
  8017d2:	5e                   	pop    %esi
  8017d3:	5f                   	pop    %edi
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 14             	sub    $0x14,%esp
  8017dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e3:	50                   	push   %eax
  8017e4:	53                   	push   %ebx
  8017e5:	e8 ac fc ff ff       	call   801496 <fd_lookup>
  8017ea:	83 c4 08             	add    $0x8,%esp
  8017ed:	89 c2                	mov    %eax,%edx
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	78 68                	js     80185b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f3:	83 ec 08             	sub    $0x8,%esp
  8017f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f9:	50                   	push   %eax
  8017fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fd:	ff 30                	pushl  (%eax)
  8017ff:	e8 e8 fc ff ff       	call   8014ec <dev_lookup>
  801804:	83 c4 10             	add    $0x10,%esp
  801807:	85 c0                	test   %eax,%eax
  801809:	78 47                	js     801852 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80180b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801812:	75 21                	jne    801835 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801814:	a1 20 44 80 00       	mov    0x804420,%eax
  801819:	8b 40 54             	mov    0x54(%eax),%eax
  80181c:	83 ec 04             	sub    $0x4,%esp
  80181f:	53                   	push   %ebx
  801820:	50                   	push   %eax
  801821:	68 68 2b 80 00       	push   $0x802b68
  801826:	e8 f6 eb ff ff       	call   800421 <cprintf>
		return -E_INVAL;
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801833:	eb 26                	jmp    80185b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801835:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801838:	8b 52 0c             	mov    0xc(%edx),%edx
  80183b:	85 d2                	test   %edx,%edx
  80183d:	74 17                	je     801856 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80183f:	83 ec 04             	sub    $0x4,%esp
  801842:	ff 75 10             	pushl  0x10(%ebp)
  801845:	ff 75 0c             	pushl  0xc(%ebp)
  801848:	50                   	push   %eax
  801849:	ff d2                	call   *%edx
  80184b:	89 c2                	mov    %eax,%edx
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	eb 09                	jmp    80185b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801852:	89 c2                	mov    %eax,%edx
  801854:	eb 05                	jmp    80185b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801856:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80185b:	89 d0                	mov    %edx,%eax
  80185d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <seek>:

int
seek(int fdnum, off_t offset)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801868:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80186b:	50                   	push   %eax
  80186c:	ff 75 08             	pushl  0x8(%ebp)
  80186f:	e8 22 fc ff ff       	call   801496 <fd_lookup>
  801874:	83 c4 08             	add    $0x8,%esp
  801877:	85 c0                	test   %eax,%eax
  801879:	78 0e                	js     801889 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80187b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80187e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801881:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801884:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801889:	c9                   	leave  
  80188a:	c3                   	ret    

0080188b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	53                   	push   %ebx
  80188f:	83 ec 14             	sub    $0x14,%esp
  801892:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801895:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801898:	50                   	push   %eax
  801899:	53                   	push   %ebx
  80189a:	e8 f7 fb ff ff       	call   801496 <fd_lookup>
  80189f:	83 c4 08             	add    $0x8,%esp
  8018a2:	89 c2                	mov    %eax,%edx
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	78 65                	js     80190d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a8:	83 ec 08             	sub    $0x8,%esp
  8018ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ae:	50                   	push   %eax
  8018af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b2:	ff 30                	pushl  (%eax)
  8018b4:	e8 33 fc ff ff       	call   8014ec <dev_lookup>
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	78 44                	js     801904 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018c7:	75 21                	jne    8018ea <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018c9:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018ce:	8b 40 54             	mov    0x54(%eax),%eax
  8018d1:	83 ec 04             	sub    $0x4,%esp
  8018d4:	53                   	push   %ebx
  8018d5:	50                   	push   %eax
  8018d6:	68 28 2b 80 00       	push   $0x802b28
  8018db:	e8 41 eb ff ff       	call   800421 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018e8:	eb 23                	jmp    80190d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ed:	8b 52 18             	mov    0x18(%edx),%edx
  8018f0:	85 d2                	test   %edx,%edx
  8018f2:	74 14                	je     801908 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018f4:	83 ec 08             	sub    $0x8,%esp
  8018f7:	ff 75 0c             	pushl  0xc(%ebp)
  8018fa:	50                   	push   %eax
  8018fb:	ff d2                	call   *%edx
  8018fd:	89 c2                	mov    %eax,%edx
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	eb 09                	jmp    80190d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801904:	89 c2                	mov    %eax,%edx
  801906:	eb 05                	jmp    80190d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801908:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80190d:	89 d0                	mov    %edx,%eax
  80190f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	53                   	push   %ebx
  801918:	83 ec 14             	sub    $0x14,%esp
  80191b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80191e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801921:	50                   	push   %eax
  801922:	ff 75 08             	pushl  0x8(%ebp)
  801925:	e8 6c fb ff ff       	call   801496 <fd_lookup>
  80192a:	83 c4 08             	add    $0x8,%esp
  80192d:	89 c2                	mov    %eax,%edx
  80192f:	85 c0                	test   %eax,%eax
  801931:	78 58                	js     80198b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801933:	83 ec 08             	sub    $0x8,%esp
  801936:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801939:	50                   	push   %eax
  80193a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193d:	ff 30                	pushl  (%eax)
  80193f:	e8 a8 fb ff ff       	call   8014ec <dev_lookup>
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	85 c0                	test   %eax,%eax
  801949:	78 37                	js     801982 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80194b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801952:	74 32                	je     801986 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801954:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801957:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80195e:	00 00 00 
	stat->st_isdir = 0;
  801961:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801968:	00 00 00 
	stat->st_dev = dev;
  80196b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801971:	83 ec 08             	sub    $0x8,%esp
  801974:	53                   	push   %ebx
  801975:	ff 75 f0             	pushl  -0x10(%ebp)
  801978:	ff 50 14             	call   *0x14(%eax)
  80197b:	89 c2                	mov    %eax,%edx
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	eb 09                	jmp    80198b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801982:	89 c2                	mov    %eax,%edx
  801984:	eb 05                	jmp    80198b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801986:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80198b:	89 d0                	mov    %edx,%eax
  80198d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	56                   	push   %esi
  801996:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801997:	83 ec 08             	sub    $0x8,%esp
  80199a:	6a 00                	push   $0x0
  80199c:	ff 75 08             	pushl  0x8(%ebp)
  80199f:	e8 e3 01 00 00       	call   801b87 <open>
  8019a4:	89 c3                	mov    %eax,%ebx
  8019a6:	83 c4 10             	add    $0x10,%esp
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	78 1b                	js     8019c8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019ad:	83 ec 08             	sub    $0x8,%esp
  8019b0:	ff 75 0c             	pushl  0xc(%ebp)
  8019b3:	50                   	push   %eax
  8019b4:	e8 5b ff ff ff       	call   801914 <fstat>
  8019b9:	89 c6                	mov    %eax,%esi
	close(fd);
  8019bb:	89 1c 24             	mov    %ebx,(%esp)
  8019be:	e8 fd fb ff ff       	call   8015c0 <close>
	return r;
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	89 f0                	mov    %esi,%eax
}
  8019c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019cb:	5b                   	pop    %ebx
  8019cc:	5e                   	pop    %esi
  8019cd:	5d                   	pop    %ebp
  8019ce:	c3                   	ret    

008019cf <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	56                   	push   %esi
  8019d3:	53                   	push   %ebx
  8019d4:	89 c6                	mov    %eax,%esi
  8019d6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019d8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019df:	75 12                	jne    8019f3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019e1:	83 ec 0c             	sub    $0xc,%esp
  8019e4:	6a 01                	push   $0x1
  8019e6:	e8 98 09 00 00       	call   802383 <ipc_find_env>
  8019eb:	a3 00 40 80 00       	mov    %eax,0x804000
  8019f0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019f3:	6a 07                	push   $0x7
  8019f5:	68 00 50 80 00       	push   $0x805000
  8019fa:	56                   	push   %esi
  8019fb:	ff 35 00 40 80 00    	pushl  0x804000
  801a01:	e8 1b 09 00 00       	call   802321 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a06:	83 c4 0c             	add    $0xc,%esp
  801a09:	6a 00                	push   $0x0
  801a0b:	53                   	push   %ebx
  801a0c:	6a 00                	push   $0x0
  801a0e:	e8 96 08 00 00       	call   8022a9 <ipc_recv>
}
  801a13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a16:	5b                   	pop    %ebx
  801a17:	5e                   	pop    %esi
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    

00801a1a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a20:	8b 45 08             	mov    0x8(%ebp),%eax
  801a23:	8b 40 0c             	mov    0xc(%eax),%eax
  801a26:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a33:	ba 00 00 00 00       	mov    $0x0,%edx
  801a38:	b8 02 00 00 00       	mov    $0x2,%eax
  801a3d:	e8 8d ff ff ff       	call   8019cf <fsipc>
}
  801a42:	c9                   	leave  
  801a43:	c3                   	ret    

00801a44 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a50:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a55:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5a:	b8 06 00 00 00       	mov    $0x6,%eax
  801a5f:	e8 6b ff ff ff       	call   8019cf <fsipc>
}
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	53                   	push   %ebx
  801a6a:	83 ec 04             	sub    $0x4,%esp
  801a6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a70:	8b 45 08             	mov    0x8(%ebp),%eax
  801a73:	8b 40 0c             	mov    0xc(%eax),%eax
  801a76:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a80:	b8 05 00 00 00       	mov    $0x5,%eax
  801a85:	e8 45 ff ff ff       	call   8019cf <fsipc>
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	78 2c                	js     801aba <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a8e:	83 ec 08             	sub    $0x8,%esp
  801a91:	68 00 50 80 00       	push   $0x805000
  801a96:	53                   	push   %ebx
  801a97:	e8 0a ef ff ff       	call   8009a6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a9c:	a1 80 50 80 00       	mov    0x805080,%eax
  801aa1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801aa7:	a1 84 50 80 00       	mov    0x805084,%eax
  801aac:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abd:	c9                   	leave  
  801abe:	c3                   	ret    

00801abf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	83 ec 0c             	sub    $0xc,%esp
  801ac5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ac8:	8b 55 08             	mov    0x8(%ebp),%edx
  801acb:	8b 52 0c             	mov    0xc(%edx),%edx
  801ace:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801ad4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ad9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ade:	0f 47 c2             	cmova  %edx,%eax
  801ae1:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801ae6:	50                   	push   %eax
  801ae7:	ff 75 0c             	pushl  0xc(%ebp)
  801aea:	68 08 50 80 00       	push   $0x805008
  801aef:	e8 44 f0 ff ff       	call   800b38 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801af4:	ba 00 00 00 00       	mov    $0x0,%edx
  801af9:	b8 04 00 00 00       	mov    $0x4,%eax
  801afe:	e8 cc fe ff ff       	call   8019cf <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b03:	c9                   	leave  
  801b04:	c3                   	ret    

00801b05 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	56                   	push   %esi
  801b09:	53                   	push   %ebx
  801b0a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b10:	8b 40 0c             	mov    0xc(%eax),%eax
  801b13:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b18:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b23:	b8 03 00 00 00       	mov    $0x3,%eax
  801b28:	e8 a2 fe ff ff       	call   8019cf <fsipc>
  801b2d:	89 c3                	mov    %eax,%ebx
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	78 4b                	js     801b7e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b33:	39 c6                	cmp    %eax,%esi
  801b35:	73 16                	jae    801b4d <devfile_read+0x48>
  801b37:	68 98 2b 80 00       	push   $0x802b98
  801b3c:	68 9f 2b 80 00       	push   $0x802b9f
  801b41:	6a 7c                	push   $0x7c
  801b43:	68 b4 2b 80 00       	push   $0x802bb4
  801b48:	e8 fb e7 ff ff       	call   800348 <_panic>
	assert(r <= PGSIZE);
  801b4d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b52:	7e 16                	jle    801b6a <devfile_read+0x65>
  801b54:	68 bf 2b 80 00       	push   $0x802bbf
  801b59:	68 9f 2b 80 00       	push   $0x802b9f
  801b5e:	6a 7d                	push   $0x7d
  801b60:	68 b4 2b 80 00       	push   $0x802bb4
  801b65:	e8 de e7 ff ff       	call   800348 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b6a:	83 ec 04             	sub    $0x4,%esp
  801b6d:	50                   	push   %eax
  801b6e:	68 00 50 80 00       	push   $0x805000
  801b73:	ff 75 0c             	pushl  0xc(%ebp)
  801b76:	e8 bd ef ff ff       	call   800b38 <memmove>
	return r;
  801b7b:	83 c4 10             	add    $0x10,%esp
}
  801b7e:	89 d8                	mov    %ebx,%eax
  801b80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b83:	5b                   	pop    %ebx
  801b84:	5e                   	pop    %esi
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	53                   	push   %ebx
  801b8b:	83 ec 20             	sub    $0x20,%esp
  801b8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b91:	53                   	push   %ebx
  801b92:	e8 d6 ed ff ff       	call   80096d <strlen>
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b9f:	7f 67                	jg     801c08 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ba1:	83 ec 0c             	sub    $0xc,%esp
  801ba4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba7:	50                   	push   %eax
  801ba8:	e8 9a f8 ff ff       	call   801447 <fd_alloc>
  801bad:	83 c4 10             	add    $0x10,%esp
		return r;
  801bb0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	78 57                	js     801c0d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bb6:	83 ec 08             	sub    $0x8,%esp
  801bb9:	53                   	push   %ebx
  801bba:	68 00 50 80 00       	push   $0x805000
  801bbf:	e8 e2 ed ff ff       	call   8009a6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bcc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bcf:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd4:	e8 f6 fd ff ff       	call   8019cf <fsipc>
  801bd9:	89 c3                	mov    %eax,%ebx
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	85 c0                	test   %eax,%eax
  801be0:	79 14                	jns    801bf6 <open+0x6f>
		fd_close(fd, 0);
  801be2:	83 ec 08             	sub    $0x8,%esp
  801be5:	6a 00                	push   $0x0
  801be7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bea:	e8 50 f9 ff ff       	call   80153f <fd_close>
		return r;
  801bef:	83 c4 10             	add    $0x10,%esp
  801bf2:	89 da                	mov    %ebx,%edx
  801bf4:	eb 17                	jmp    801c0d <open+0x86>
	}

	return fd2num(fd);
  801bf6:	83 ec 0c             	sub    $0xc,%esp
  801bf9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfc:	e8 1f f8 ff ff       	call   801420 <fd2num>
  801c01:	89 c2                	mov    %eax,%edx
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	eb 05                	jmp    801c0d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c08:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c0d:	89 d0                	mov    %edx,%eax
  801c0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c12:	c9                   	leave  
  801c13:	c3                   	ret    

00801c14 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c1a:	ba 00 00 00 00       	mov    $0x0,%edx
  801c1f:	b8 08 00 00 00       	mov    $0x8,%eax
  801c24:	e8 a6 fd ff ff       	call   8019cf <fsipc>
}
  801c29:	c9                   	leave  
  801c2a:	c3                   	ret    

00801c2b <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801c2b:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801c2f:	7e 37                	jle    801c68 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	53                   	push   %ebx
  801c35:	83 ec 08             	sub    $0x8,%esp
  801c38:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801c3a:	ff 70 04             	pushl  0x4(%eax)
  801c3d:	8d 40 10             	lea    0x10(%eax),%eax
  801c40:	50                   	push   %eax
  801c41:	ff 33                	pushl  (%ebx)
  801c43:	e8 8e fb ff ff       	call   8017d6 <write>
		if (result > 0)
  801c48:	83 c4 10             	add    $0x10,%esp
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	7e 03                	jle    801c52 <writebuf+0x27>
			b->result += result;
  801c4f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801c52:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c55:	74 0d                	je     801c64 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801c57:	85 c0                	test   %eax,%eax
  801c59:	ba 00 00 00 00       	mov    $0x0,%edx
  801c5e:	0f 4f c2             	cmovg  %edx,%eax
  801c61:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801c64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c67:	c9                   	leave  
  801c68:	f3 c3                	repz ret 

00801c6a <putch>:

static void
putch(int ch, void *thunk)
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	53                   	push   %ebx
  801c6e:	83 ec 04             	sub    $0x4,%esp
  801c71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801c74:	8b 53 04             	mov    0x4(%ebx),%edx
  801c77:	8d 42 01             	lea    0x1(%edx),%eax
  801c7a:	89 43 04             	mov    %eax,0x4(%ebx)
  801c7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c80:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801c84:	3d 00 01 00 00       	cmp    $0x100,%eax
  801c89:	75 0e                	jne    801c99 <putch+0x2f>
		writebuf(b);
  801c8b:	89 d8                	mov    %ebx,%eax
  801c8d:	e8 99 ff ff ff       	call   801c2b <writebuf>
		b->idx = 0;
  801c92:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801c99:	83 c4 04             	add    $0x4,%esp
  801c9c:	5b                   	pop    %ebx
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    

00801c9f <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cab:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801cb1:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801cb8:	00 00 00 
	b.result = 0;
  801cbb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801cc2:	00 00 00 
	b.error = 1;
  801cc5:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801ccc:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801ccf:	ff 75 10             	pushl  0x10(%ebp)
  801cd2:	ff 75 0c             	pushl  0xc(%ebp)
  801cd5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801cdb:	50                   	push   %eax
  801cdc:	68 6a 1c 80 00       	push   $0x801c6a
  801ce1:	e8 72 e8 ff ff       	call   800558 <vprintfmt>
	if (b.idx > 0)
  801ce6:	83 c4 10             	add    $0x10,%esp
  801ce9:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801cf0:	7e 0b                	jle    801cfd <vfprintf+0x5e>
		writebuf(&b);
  801cf2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801cf8:	e8 2e ff ff ff       	call   801c2b <writebuf>

	return (b.result ? b.result : b.error);
  801cfd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801d03:	85 c0                	test   %eax,%eax
  801d05:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d14:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801d17:	50                   	push   %eax
  801d18:	ff 75 0c             	pushl  0xc(%ebp)
  801d1b:	ff 75 08             	pushl  0x8(%ebp)
  801d1e:	e8 7c ff ff ff       	call   801c9f <vfprintf>
	va_end(ap);

	return cnt;
}
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    

00801d25 <printf>:

int
printf(const char *fmt, ...)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d2b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801d2e:	50                   	push   %eax
  801d2f:	ff 75 08             	pushl  0x8(%ebp)
  801d32:	6a 01                	push   $0x1
  801d34:	e8 66 ff ff ff       	call   801c9f <vfprintf>
	va_end(ap);

	return cnt;
}
  801d39:	c9                   	leave  
  801d3a:	c3                   	ret    

00801d3b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	56                   	push   %esi
  801d3f:	53                   	push   %ebx
  801d40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d43:	83 ec 0c             	sub    $0xc,%esp
  801d46:	ff 75 08             	pushl  0x8(%ebp)
  801d49:	e8 e2 f6 ff ff       	call   801430 <fd2data>
  801d4e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d50:	83 c4 08             	add    $0x8,%esp
  801d53:	68 cb 2b 80 00       	push   $0x802bcb
  801d58:	53                   	push   %ebx
  801d59:	e8 48 ec ff ff       	call   8009a6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d5e:	8b 46 04             	mov    0x4(%esi),%eax
  801d61:	2b 06                	sub    (%esi),%eax
  801d63:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d69:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d70:	00 00 00 
	stat->st_dev = &devpipe;
  801d73:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801d7a:	30 80 00 
	return 0;
}
  801d7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d85:	5b                   	pop    %ebx
  801d86:	5e                   	pop    %esi
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    

00801d89 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	53                   	push   %ebx
  801d8d:	83 ec 0c             	sub    $0xc,%esp
  801d90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d93:	53                   	push   %ebx
  801d94:	6a 00                	push   $0x0
  801d96:	e8 93 f0 ff ff       	call   800e2e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d9b:	89 1c 24             	mov    %ebx,(%esp)
  801d9e:	e8 8d f6 ff ff       	call   801430 <fd2data>
  801da3:	83 c4 08             	add    $0x8,%esp
  801da6:	50                   	push   %eax
  801da7:	6a 00                	push   $0x0
  801da9:	e8 80 f0 ff ff       	call   800e2e <sys_page_unmap>
}
  801dae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db1:	c9                   	leave  
  801db2:	c3                   	ret    

00801db3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	57                   	push   %edi
  801db7:	56                   	push   %esi
  801db8:	53                   	push   %ebx
  801db9:	83 ec 1c             	sub    $0x1c,%esp
  801dbc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801dbf:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801dc1:	a1 20 44 80 00       	mov    0x804420,%eax
  801dc6:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801dc9:	83 ec 0c             	sub    $0xc,%esp
  801dcc:	ff 75 e0             	pushl  -0x20(%ebp)
  801dcf:	e8 ef 05 00 00       	call   8023c3 <pageref>
  801dd4:	89 c3                	mov    %eax,%ebx
  801dd6:	89 3c 24             	mov    %edi,(%esp)
  801dd9:	e8 e5 05 00 00       	call   8023c3 <pageref>
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	39 c3                	cmp    %eax,%ebx
  801de3:	0f 94 c1             	sete   %cl
  801de6:	0f b6 c9             	movzbl %cl,%ecx
  801de9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801dec:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801df2:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801df5:	39 ce                	cmp    %ecx,%esi
  801df7:	74 1b                	je     801e14 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801df9:	39 c3                	cmp    %eax,%ebx
  801dfb:	75 c4                	jne    801dc1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dfd:	8b 42 64             	mov    0x64(%edx),%eax
  801e00:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e03:	50                   	push   %eax
  801e04:	56                   	push   %esi
  801e05:	68 d2 2b 80 00       	push   $0x802bd2
  801e0a:	e8 12 e6 ff ff       	call   800421 <cprintf>
  801e0f:	83 c4 10             	add    $0x10,%esp
  801e12:	eb ad                	jmp    801dc1 <_pipeisclosed+0xe>
	}
}
  801e14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e1a:	5b                   	pop    %ebx
  801e1b:	5e                   	pop    %esi
  801e1c:	5f                   	pop    %edi
  801e1d:	5d                   	pop    %ebp
  801e1e:	c3                   	ret    

00801e1f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	57                   	push   %edi
  801e23:	56                   	push   %esi
  801e24:	53                   	push   %ebx
  801e25:	83 ec 28             	sub    $0x28,%esp
  801e28:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e2b:	56                   	push   %esi
  801e2c:	e8 ff f5 ff ff       	call   801430 <fd2data>
  801e31:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	bf 00 00 00 00       	mov    $0x0,%edi
  801e3b:	eb 4b                	jmp    801e88 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e3d:	89 da                	mov    %ebx,%edx
  801e3f:	89 f0                	mov    %esi,%eax
  801e41:	e8 6d ff ff ff       	call   801db3 <_pipeisclosed>
  801e46:	85 c0                	test   %eax,%eax
  801e48:	75 48                	jne    801e92 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e4a:	e8 3b ef ff ff       	call   800d8a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e4f:	8b 43 04             	mov    0x4(%ebx),%eax
  801e52:	8b 0b                	mov    (%ebx),%ecx
  801e54:	8d 51 20             	lea    0x20(%ecx),%edx
  801e57:	39 d0                	cmp    %edx,%eax
  801e59:	73 e2                	jae    801e3d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e5e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e62:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e65:	89 c2                	mov    %eax,%edx
  801e67:	c1 fa 1f             	sar    $0x1f,%edx
  801e6a:	89 d1                	mov    %edx,%ecx
  801e6c:	c1 e9 1b             	shr    $0x1b,%ecx
  801e6f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e72:	83 e2 1f             	and    $0x1f,%edx
  801e75:	29 ca                	sub    %ecx,%edx
  801e77:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e7b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e7f:	83 c0 01             	add    $0x1,%eax
  801e82:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e85:	83 c7 01             	add    $0x1,%edi
  801e88:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e8b:	75 c2                	jne    801e4f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e8d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e90:	eb 05                	jmp    801e97 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e92:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9a:	5b                   	pop    %ebx
  801e9b:	5e                   	pop    %esi
  801e9c:	5f                   	pop    %edi
  801e9d:	5d                   	pop    %ebp
  801e9e:	c3                   	ret    

00801e9f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	57                   	push   %edi
  801ea3:	56                   	push   %esi
  801ea4:	53                   	push   %ebx
  801ea5:	83 ec 18             	sub    $0x18,%esp
  801ea8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801eab:	57                   	push   %edi
  801eac:	e8 7f f5 ff ff       	call   801430 <fd2data>
  801eb1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eb3:	83 c4 10             	add    $0x10,%esp
  801eb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ebb:	eb 3d                	jmp    801efa <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ebd:	85 db                	test   %ebx,%ebx
  801ebf:	74 04                	je     801ec5 <devpipe_read+0x26>
				return i;
  801ec1:	89 d8                	mov    %ebx,%eax
  801ec3:	eb 44                	jmp    801f09 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ec5:	89 f2                	mov    %esi,%edx
  801ec7:	89 f8                	mov    %edi,%eax
  801ec9:	e8 e5 fe ff ff       	call   801db3 <_pipeisclosed>
  801ece:	85 c0                	test   %eax,%eax
  801ed0:	75 32                	jne    801f04 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ed2:	e8 b3 ee ff ff       	call   800d8a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ed7:	8b 06                	mov    (%esi),%eax
  801ed9:	3b 46 04             	cmp    0x4(%esi),%eax
  801edc:	74 df                	je     801ebd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ede:	99                   	cltd   
  801edf:	c1 ea 1b             	shr    $0x1b,%edx
  801ee2:	01 d0                	add    %edx,%eax
  801ee4:	83 e0 1f             	and    $0x1f,%eax
  801ee7:	29 d0                	sub    %edx,%eax
  801ee9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801eee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ef1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ef4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ef7:	83 c3 01             	add    $0x1,%ebx
  801efa:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801efd:	75 d8                	jne    801ed7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801eff:	8b 45 10             	mov    0x10(%ebp),%eax
  801f02:	eb 05                	jmp    801f09 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f04:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0c:	5b                   	pop    %ebx
  801f0d:	5e                   	pop    %esi
  801f0e:	5f                   	pop    %edi
  801f0f:	5d                   	pop    %ebp
  801f10:	c3                   	ret    

00801f11 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f11:	55                   	push   %ebp
  801f12:	89 e5                	mov    %esp,%ebp
  801f14:	56                   	push   %esi
  801f15:	53                   	push   %ebx
  801f16:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1c:	50                   	push   %eax
  801f1d:	e8 25 f5 ff ff       	call   801447 <fd_alloc>
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	89 c2                	mov    %eax,%edx
  801f27:	85 c0                	test   %eax,%eax
  801f29:	0f 88 2c 01 00 00    	js     80205b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f2f:	83 ec 04             	sub    $0x4,%esp
  801f32:	68 07 04 00 00       	push   $0x407
  801f37:	ff 75 f4             	pushl  -0xc(%ebp)
  801f3a:	6a 00                	push   $0x0
  801f3c:	e8 68 ee ff ff       	call   800da9 <sys_page_alloc>
  801f41:	83 c4 10             	add    $0x10,%esp
  801f44:	89 c2                	mov    %eax,%edx
  801f46:	85 c0                	test   %eax,%eax
  801f48:	0f 88 0d 01 00 00    	js     80205b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f4e:	83 ec 0c             	sub    $0xc,%esp
  801f51:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f54:	50                   	push   %eax
  801f55:	e8 ed f4 ff ff       	call   801447 <fd_alloc>
  801f5a:	89 c3                	mov    %eax,%ebx
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	85 c0                	test   %eax,%eax
  801f61:	0f 88 e2 00 00 00    	js     802049 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f67:	83 ec 04             	sub    $0x4,%esp
  801f6a:	68 07 04 00 00       	push   $0x407
  801f6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801f72:	6a 00                	push   $0x0
  801f74:	e8 30 ee ff ff       	call   800da9 <sys_page_alloc>
  801f79:	89 c3                	mov    %eax,%ebx
  801f7b:	83 c4 10             	add    $0x10,%esp
  801f7e:	85 c0                	test   %eax,%eax
  801f80:	0f 88 c3 00 00 00    	js     802049 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f86:	83 ec 0c             	sub    $0xc,%esp
  801f89:	ff 75 f4             	pushl  -0xc(%ebp)
  801f8c:	e8 9f f4 ff ff       	call   801430 <fd2data>
  801f91:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f93:	83 c4 0c             	add    $0xc,%esp
  801f96:	68 07 04 00 00       	push   $0x407
  801f9b:	50                   	push   %eax
  801f9c:	6a 00                	push   $0x0
  801f9e:	e8 06 ee ff ff       	call   800da9 <sys_page_alloc>
  801fa3:	89 c3                	mov    %eax,%ebx
  801fa5:	83 c4 10             	add    $0x10,%esp
  801fa8:	85 c0                	test   %eax,%eax
  801faa:	0f 88 89 00 00 00    	js     802039 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fb0:	83 ec 0c             	sub    $0xc,%esp
  801fb3:	ff 75 f0             	pushl  -0x10(%ebp)
  801fb6:	e8 75 f4 ff ff       	call   801430 <fd2data>
  801fbb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801fc2:	50                   	push   %eax
  801fc3:	6a 00                	push   $0x0
  801fc5:	56                   	push   %esi
  801fc6:	6a 00                	push   $0x0
  801fc8:	e8 1f ee ff ff       	call   800dec <sys_page_map>
  801fcd:	89 c3                	mov    %eax,%ebx
  801fcf:	83 c4 20             	add    $0x20,%esp
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	78 55                	js     80202b <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fd6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801feb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ff1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ff4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ff6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ff9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802000:	83 ec 0c             	sub    $0xc,%esp
  802003:	ff 75 f4             	pushl  -0xc(%ebp)
  802006:	e8 15 f4 ff ff       	call   801420 <fd2num>
  80200b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80200e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802010:	83 c4 04             	add    $0x4,%esp
  802013:	ff 75 f0             	pushl  -0x10(%ebp)
  802016:	e8 05 f4 ff ff       	call   801420 <fd2num>
  80201b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80201e:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802021:	83 c4 10             	add    $0x10,%esp
  802024:	ba 00 00 00 00       	mov    $0x0,%edx
  802029:	eb 30                	jmp    80205b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80202b:	83 ec 08             	sub    $0x8,%esp
  80202e:	56                   	push   %esi
  80202f:	6a 00                	push   $0x0
  802031:	e8 f8 ed ff ff       	call   800e2e <sys_page_unmap>
  802036:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802039:	83 ec 08             	sub    $0x8,%esp
  80203c:	ff 75 f0             	pushl  -0x10(%ebp)
  80203f:	6a 00                	push   $0x0
  802041:	e8 e8 ed ff ff       	call   800e2e <sys_page_unmap>
  802046:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802049:	83 ec 08             	sub    $0x8,%esp
  80204c:	ff 75 f4             	pushl  -0xc(%ebp)
  80204f:	6a 00                	push   $0x0
  802051:	e8 d8 ed ff ff       	call   800e2e <sys_page_unmap>
  802056:	83 c4 10             	add    $0x10,%esp
  802059:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80205b:	89 d0                	mov    %edx,%eax
  80205d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802060:	5b                   	pop    %ebx
  802061:	5e                   	pop    %esi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    

00802064 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80206a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80206d:	50                   	push   %eax
  80206e:	ff 75 08             	pushl  0x8(%ebp)
  802071:	e8 20 f4 ff ff       	call   801496 <fd_lookup>
  802076:	83 c4 10             	add    $0x10,%esp
  802079:	85 c0                	test   %eax,%eax
  80207b:	78 18                	js     802095 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80207d:	83 ec 0c             	sub    $0xc,%esp
  802080:	ff 75 f4             	pushl  -0xc(%ebp)
  802083:	e8 a8 f3 ff ff       	call   801430 <fd2data>
	return _pipeisclosed(fd, p);
  802088:	89 c2                	mov    %eax,%edx
  80208a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208d:	e8 21 fd ff ff       	call   801db3 <_pipeisclosed>
  802092:	83 c4 10             	add    $0x10,%esp
}
  802095:	c9                   	leave  
  802096:	c3                   	ret    

00802097 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80209a:	b8 00 00 00 00       	mov    $0x0,%eax
  80209f:	5d                   	pop    %ebp
  8020a0:	c3                   	ret    

008020a1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020a1:	55                   	push   %ebp
  8020a2:	89 e5                	mov    %esp,%ebp
  8020a4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020a7:	68 ea 2b 80 00       	push   $0x802bea
  8020ac:	ff 75 0c             	pushl  0xc(%ebp)
  8020af:	e8 f2 e8 ff ff       	call   8009a6 <strcpy>
	return 0;
}
  8020b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b9:	c9                   	leave  
  8020ba:	c3                   	ret    

008020bb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020bb:	55                   	push   %ebp
  8020bc:	89 e5                	mov    %esp,%ebp
  8020be:	57                   	push   %edi
  8020bf:	56                   	push   %esi
  8020c0:	53                   	push   %ebx
  8020c1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020c7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020cc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020d2:	eb 2d                	jmp    802101 <devcons_write+0x46>
		m = n - tot;
  8020d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020d7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8020d9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020dc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020e1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020e4:	83 ec 04             	sub    $0x4,%esp
  8020e7:	53                   	push   %ebx
  8020e8:	03 45 0c             	add    0xc(%ebp),%eax
  8020eb:	50                   	push   %eax
  8020ec:	57                   	push   %edi
  8020ed:	e8 46 ea ff ff       	call   800b38 <memmove>
		sys_cputs(buf, m);
  8020f2:	83 c4 08             	add    $0x8,%esp
  8020f5:	53                   	push   %ebx
  8020f6:	57                   	push   %edi
  8020f7:	e8 f1 eb ff ff       	call   800ced <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020fc:	01 de                	add    %ebx,%esi
  8020fe:	83 c4 10             	add    $0x10,%esp
  802101:	89 f0                	mov    %esi,%eax
  802103:	3b 75 10             	cmp    0x10(%ebp),%esi
  802106:	72 cc                	jb     8020d4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80210b:	5b                   	pop    %ebx
  80210c:	5e                   	pop    %esi
  80210d:	5f                   	pop    %edi
  80210e:	5d                   	pop    %ebp
  80210f:	c3                   	ret    

00802110 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	83 ec 08             	sub    $0x8,%esp
  802116:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80211b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80211f:	74 2a                	je     80214b <devcons_read+0x3b>
  802121:	eb 05                	jmp    802128 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802123:	e8 62 ec ff ff       	call   800d8a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802128:	e8 de eb ff ff       	call   800d0b <sys_cgetc>
  80212d:	85 c0                	test   %eax,%eax
  80212f:	74 f2                	je     802123 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802131:	85 c0                	test   %eax,%eax
  802133:	78 16                	js     80214b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802135:	83 f8 04             	cmp    $0x4,%eax
  802138:	74 0c                	je     802146 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80213a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80213d:	88 02                	mov    %al,(%edx)
	return 1;
  80213f:	b8 01 00 00 00       	mov    $0x1,%eax
  802144:	eb 05                	jmp    80214b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802146:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80214b:	c9                   	leave  
  80214c:	c3                   	ret    

0080214d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80214d:	55                   	push   %ebp
  80214e:	89 e5                	mov    %esp,%ebp
  802150:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802153:	8b 45 08             	mov    0x8(%ebp),%eax
  802156:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802159:	6a 01                	push   $0x1
  80215b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80215e:	50                   	push   %eax
  80215f:	e8 89 eb ff ff       	call   800ced <sys_cputs>
}
  802164:	83 c4 10             	add    $0x10,%esp
  802167:	c9                   	leave  
  802168:	c3                   	ret    

00802169 <getchar>:

int
getchar(void)
{
  802169:	55                   	push   %ebp
  80216a:	89 e5                	mov    %esp,%ebp
  80216c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80216f:	6a 01                	push   $0x1
  802171:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802174:	50                   	push   %eax
  802175:	6a 00                	push   $0x0
  802177:	e8 80 f5 ff ff       	call   8016fc <read>
	if (r < 0)
  80217c:	83 c4 10             	add    $0x10,%esp
  80217f:	85 c0                	test   %eax,%eax
  802181:	78 0f                	js     802192 <getchar+0x29>
		return r;
	if (r < 1)
  802183:	85 c0                	test   %eax,%eax
  802185:	7e 06                	jle    80218d <getchar+0x24>
		return -E_EOF;
	return c;
  802187:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80218b:	eb 05                	jmp    802192 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80218d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802192:	c9                   	leave  
  802193:	c3                   	ret    

00802194 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802194:	55                   	push   %ebp
  802195:	89 e5                	mov    %esp,%ebp
  802197:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80219a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80219d:	50                   	push   %eax
  80219e:	ff 75 08             	pushl  0x8(%ebp)
  8021a1:	e8 f0 f2 ff ff       	call   801496 <fd_lookup>
  8021a6:	83 c4 10             	add    $0x10,%esp
  8021a9:	85 c0                	test   %eax,%eax
  8021ab:	78 11                	js     8021be <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021b6:	39 10                	cmp    %edx,(%eax)
  8021b8:	0f 94 c0             	sete   %al
  8021bb:	0f b6 c0             	movzbl %al,%eax
}
  8021be:	c9                   	leave  
  8021bf:	c3                   	ret    

008021c0 <opencons>:

int
opencons(void)
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c9:	50                   	push   %eax
  8021ca:	e8 78 f2 ff ff       	call   801447 <fd_alloc>
  8021cf:	83 c4 10             	add    $0x10,%esp
		return r;
  8021d2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021d4:	85 c0                	test   %eax,%eax
  8021d6:	78 3e                	js     802216 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021d8:	83 ec 04             	sub    $0x4,%esp
  8021db:	68 07 04 00 00       	push   $0x407
  8021e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e3:	6a 00                	push   $0x0
  8021e5:	e8 bf eb ff ff       	call   800da9 <sys_page_alloc>
  8021ea:	83 c4 10             	add    $0x10,%esp
		return r;
  8021ed:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021ef:	85 c0                	test   %eax,%eax
  8021f1:	78 23                	js     802216 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021f3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802201:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802208:	83 ec 0c             	sub    $0xc,%esp
  80220b:	50                   	push   %eax
  80220c:	e8 0f f2 ff ff       	call   801420 <fd2num>
  802211:	89 c2                	mov    %eax,%edx
  802213:	83 c4 10             	add    $0x10,%esp
}
  802216:	89 d0                	mov    %edx,%eax
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
  802235:	e8 6f eb ff ff       	call   800da9 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80223a:	83 c4 10             	add    $0x10,%esp
  80223d:	85 c0                	test   %eax,%eax
  80223f:	79 12                	jns    802253 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802241:	50                   	push   %eax
  802242:	68 f6 2b 80 00       	push   $0x802bf6
  802247:	6a 23                	push   $0x23
  802249:	68 fa 2b 80 00       	push   $0x802bfa
  80224e:	e8 f5 e0 ff ff       	call   800348 <_panic>
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
  802265:	e8 8a ec ff ff       	call   800ef4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80226a:	83 c4 10             	add    $0x10,%esp
  80226d:	85 c0                	test   %eax,%eax
  80226f:	79 12                	jns    802283 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802271:	50                   	push   %eax
  802272:	68 f6 2b 80 00       	push   $0x802bf6
  802277:	6a 2c                	push   $0x2c
  802279:	68 fa 2b 80 00       	push   $0x802bfa
  80227e:	e8 c5 e0 ff ff       	call   800348 <_panic>
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
  8022c3:	e8 91 ec ff ff       	call   800f59 <sys_ipc_recv>
  8022c8:	83 c4 10             	add    $0x10,%esp
  8022cb:	eb 0c                	jmp    8022d9 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8022cd:	83 ec 0c             	sub    $0xc,%esp
  8022d0:	50                   	push   %eax
  8022d1:	e8 83 ec ff ff       	call   800f59 <sys_ipc_recv>
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
  8022ee:	75 2a                	jne    80231a <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8022f0:	85 f6                	test   %esi,%esi
  8022f2:	74 0d                	je     802301 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8022f4:	a1 20 44 80 00       	mov    0x804420,%eax
  8022f9:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8022ff:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802301:	85 db                	test   %ebx,%ebx
  802303:	74 0d                	je     802312 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802305:	a1 20 44 80 00       	mov    0x804420,%eax
  80230a:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  802310:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802312:	a1 20 44 80 00       	mov    0x804420,%eax
  802317:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  80231a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80231d:	5b                   	pop    %ebx
  80231e:	5e                   	pop    %esi
  80231f:	5d                   	pop    %ebp
  802320:	c3                   	ret    

00802321 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802321:	55                   	push   %ebp
  802322:	89 e5                	mov    %esp,%ebp
  802324:	57                   	push   %edi
  802325:	56                   	push   %esi
  802326:	53                   	push   %ebx
  802327:	83 ec 0c             	sub    $0xc,%esp
  80232a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80232d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802330:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802333:	85 db                	test   %ebx,%ebx
  802335:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80233a:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80233d:	ff 75 14             	pushl  0x14(%ebp)
  802340:	53                   	push   %ebx
  802341:	56                   	push   %esi
  802342:	57                   	push   %edi
  802343:	e8 ee eb ff ff       	call   800f36 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802348:	89 c2                	mov    %eax,%edx
  80234a:	c1 ea 1f             	shr    $0x1f,%edx
  80234d:	83 c4 10             	add    $0x10,%esp
  802350:	84 d2                	test   %dl,%dl
  802352:	74 17                	je     80236b <ipc_send+0x4a>
  802354:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802357:	74 12                	je     80236b <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802359:	50                   	push   %eax
  80235a:	68 08 2c 80 00       	push   $0x802c08
  80235f:	6a 47                	push   $0x47
  802361:	68 16 2c 80 00       	push   $0x802c16
  802366:	e8 dd df ff ff       	call   800348 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80236b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80236e:	75 07                	jne    802377 <ipc_send+0x56>
			sys_yield();
  802370:	e8 15 ea ff ff       	call   800d8a <sys_yield>
  802375:	eb c6                	jmp    80233d <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802377:	85 c0                	test   %eax,%eax
  802379:	75 c2                	jne    80233d <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80237b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80237e:	5b                   	pop    %ebx
  80237f:	5e                   	pop    %esi
  802380:	5f                   	pop    %edi
  802381:	5d                   	pop    %ebp
  802382:	c3                   	ret    

00802383 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802383:	55                   	push   %ebp
  802384:	89 e5                	mov    %esp,%ebp
  802386:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802389:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80238e:	89 c2                	mov    %eax,%edx
  802390:	c1 e2 07             	shl    $0x7,%edx
  802393:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  80239a:	8b 52 5c             	mov    0x5c(%edx),%edx
  80239d:	39 ca                	cmp    %ecx,%edx
  80239f:	75 11                	jne    8023b2 <ipc_find_env+0x2f>
			return envs[i].env_id;
  8023a1:	89 c2                	mov    %eax,%edx
  8023a3:	c1 e2 07             	shl    $0x7,%edx
  8023a6:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8023ad:	8b 40 54             	mov    0x54(%eax),%eax
  8023b0:	eb 0f                	jmp    8023c1 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023b2:	83 c0 01             	add    $0x1,%eax
  8023b5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023ba:	75 d2                	jne    80238e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023c1:	5d                   	pop    %ebp
  8023c2:	c3                   	ret    

008023c3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023c3:	55                   	push   %ebp
  8023c4:	89 e5                	mov    %esp,%ebp
  8023c6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023c9:	89 d0                	mov    %edx,%eax
  8023cb:	c1 e8 16             	shr    $0x16,%eax
  8023ce:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023d5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023da:	f6 c1 01             	test   $0x1,%cl
  8023dd:	74 1d                	je     8023fc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023df:	c1 ea 0c             	shr    $0xc,%edx
  8023e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023e9:	f6 c2 01             	test   $0x1,%dl
  8023ec:	74 0e                	je     8023fc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023ee:	c1 ea 0c             	shr    $0xc,%edx
  8023f1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023f8:	ef 
  8023f9:	0f b7 c0             	movzwl %ax,%eax
}
  8023fc:	5d                   	pop    %ebp
  8023fd:	c3                   	ret    
  8023fe:	66 90                	xchg   %ax,%ax

00802400 <__udivdi3>:
  802400:	55                   	push   %ebp
  802401:	57                   	push   %edi
  802402:	56                   	push   %esi
  802403:	53                   	push   %ebx
  802404:	83 ec 1c             	sub    $0x1c,%esp
  802407:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80240b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80240f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802413:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802417:	85 f6                	test   %esi,%esi
  802419:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80241d:	89 ca                	mov    %ecx,%edx
  80241f:	89 f8                	mov    %edi,%eax
  802421:	75 3d                	jne    802460 <__udivdi3+0x60>
  802423:	39 cf                	cmp    %ecx,%edi
  802425:	0f 87 c5 00 00 00    	ja     8024f0 <__udivdi3+0xf0>
  80242b:	85 ff                	test   %edi,%edi
  80242d:	89 fd                	mov    %edi,%ebp
  80242f:	75 0b                	jne    80243c <__udivdi3+0x3c>
  802431:	b8 01 00 00 00       	mov    $0x1,%eax
  802436:	31 d2                	xor    %edx,%edx
  802438:	f7 f7                	div    %edi
  80243a:	89 c5                	mov    %eax,%ebp
  80243c:	89 c8                	mov    %ecx,%eax
  80243e:	31 d2                	xor    %edx,%edx
  802440:	f7 f5                	div    %ebp
  802442:	89 c1                	mov    %eax,%ecx
  802444:	89 d8                	mov    %ebx,%eax
  802446:	89 cf                	mov    %ecx,%edi
  802448:	f7 f5                	div    %ebp
  80244a:	89 c3                	mov    %eax,%ebx
  80244c:	89 d8                	mov    %ebx,%eax
  80244e:	89 fa                	mov    %edi,%edx
  802450:	83 c4 1c             	add    $0x1c,%esp
  802453:	5b                   	pop    %ebx
  802454:	5e                   	pop    %esi
  802455:	5f                   	pop    %edi
  802456:	5d                   	pop    %ebp
  802457:	c3                   	ret    
  802458:	90                   	nop
  802459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802460:	39 ce                	cmp    %ecx,%esi
  802462:	77 74                	ja     8024d8 <__udivdi3+0xd8>
  802464:	0f bd fe             	bsr    %esi,%edi
  802467:	83 f7 1f             	xor    $0x1f,%edi
  80246a:	0f 84 98 00 00 00    	je     802508 <__udivdi3+0x108>
  802470:	bb 20 00 00 00       	mov    $0x20,%ebx
  802475:	89 f9                	mov    %edi,%ecx
  802477:	89 c5                	mov    %eax,%ebp
  802479:	29 fb                	sub    %edi,%ebx
  80247b:	d3 e6                	shl    %cl,%esi
  80247d:	89 d9                	mov    %ebx,%ecx
  80247f:	d3 ed                	shr    %cl,%ebp
  802481:	89 f9                	mov    %edi,%ecx
  802483:	d3 e0                	shl    %cl,%eax
  802485:	09 ee                	or     %ebp,%esi
  802487:	89 d9                	mov    %ebx,%ecx
  802489:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80248d:	89 d5                	mov    %edx,%ebp
  80248f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802493:	d3 ed                	shr    %cl,%ebp
  802495:	89 f9                	mov    %edi,%ecx
  802497:	d3 e2                	shl    %cl,%edx
  802499:	89 d9                	mov    %ebx,%ecx
  80249b:	d3 e8                	shr    %cl,%eax
  80249d:	09 c2                	or     %eax,%edx
  80249f:	89 d0                	mov    %edx,%eax
  8024a1:	89 ea                	mov    %ebp,%edx
  8024a3:	f7 f6                	div    %esi
  8024a5:	89 d5                	mov    %edx,%ebp
  8024a7:	89 c3                	mov    %eax,%ebx
  8024a9:	f7 64 24 0c          	mull   0xc(%esp)
  8024ad:	39 d5                	cmp    %edx,%ebp
  8024af:	72 10                	jb     8024c1 <__udivdi3+0xc1>
  8024b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024b5:	89 f9                	mov    %edi,%ecx
  8024b7:	d3 e6                	shl    %cl,%esi
  8024b9:	39 c6                	cmp    %eax,%esi
  8024bb:	73 07                	jae    8024c4 <__udivdi3+0xc4>
  8024bd:	39 d5                	cmp    %edx,%ebp
  8024bf:	75 03                	jne    8024c4 <__udivdi3+0xc4>
  8024c1:	83 eb 01             	sub    $0x1,%ebx
  8024c4:	31 ff                	xor    %edi,%edi
  8024c6:	89 d8                	mov    %ebx,%eax
  8024c8:	89 fa                	mov    %edi,%edx
  8024ca:	83 c4 1c             	add    $0x1c,%esp
  8024cd:	5b                   	pop    %ebx
  8024ce:	5e                   	pop    %esi
  8024cf:	5f                   	pop    %edi
  8024d0:	5d                   	pop    %ebp
  8024d1:	c3                   	ret    
  8024d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024d8:	31 ff                	xor    %edi,%edi
  8024da:	31 db                	xor    %ebx,%ebx
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
  8024f0:	89 d8                	mov    %ebx,%eax
  8024f2:	f7 f7                	div    %edi
  8024f4:	31 ff                	xor    %edi,%edi
  8024f6:	89 c3                	mov    %eax,%ebx
  8024f8:	89 d8                	mov    %ebx,%eax
  8024fa:	89 fa                	mov    %edi,%edx
  8024fc:	83 c4 1c             	add    $0x1c,%esp
  8024ff:	5b                   	pop    %ebx
  802500:	5e                   	pop    %esi
  802501:	5f                   	pop    %edi
  802502:	5d                   	pop    %ebp
  802503:	c3                   	ret    
  802504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802508:	39 ce                	cmp    %ecx,%esi
  80250a:	72 0c                	jb     802518 <__udivdi3+0x118>
  80250c:	31 db                	xor    %ebx,%ebx
  80250e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802512:	0f 87 34 ff ff ff    	ja     80244c <__udivdi3+0x4c>
  802518:	bb 01 00 00 00       	mov    $0x1,%ebx
  80251d:	e9 2a ff ff ff       	jmp    80244c <__udivdi3+0x4c>
  802522:	66 90                	xchg   %ax,%ax
  802524:	66 90                	xchg   %ax,%ax
  802526:	66 90                	xchg   %ax,%ax
  802528:	66 90                	xchg   %ax,%ax
  80252a:	66 90                	xchg   %ax,%ax
  80252c:	66 90                	xchg   %ax,%ax
  80252e:	66 90                	xchg   %ax,%ax

00802530 <__umoddi3>:
  802530:	55                   	push   %ebp
  802531:	57                   	push   %edi
  802532:	56                   	push   %esi
  802533:	53                   	push   %ebx
  802534:	83 ec 1c             	sub    $0x1c,%esp
  802537:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80253b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80253f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802543:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802547:	85 d2                	test   %edx,%edx
  802549:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80254d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802551:	89 f3                	mov    %esi,%ebx
  802553:	89 3c 24             	mov    %edi,(%esp)
  802556:	89 74 24 04          	mov    %esi,0x4(%esp)
  80255a:	75 1c                	jne    802578 <__umoddi3+0x48>
  80255c:	39 f7                	cmp    %esi,%edi
  80255e:	76 50                	jbe    8025b0 <__umoddi3+0x80>
  802560:	89 c8                	mov    %ecx,%eax
  802562:	89 f2                	mov    %esi,%edx
  802564:	f7 f7                	div    %edi
  802566:	89 d0                	mov    %edx,%eax
  802568:	31 d2                	xor    %edx,%edx
  80256a:	83 c4 1c             	add    $0x1c,%esp
  80256d:	5b                   	pop    %ebx
  80256e:	5e                   	pop    %esi
  80256f:	5f                   	pop    %edi
  802570:	5d                   	pop    %ebp
  802571:	c3                   	ret    
  802572:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802578:	39 f2                	cmp    %esi,%edx
  80257a:	89 d0                	mov    %edx,%eax
  80257c:	77 52                	ja     8025d0 <__umoddi3+0xa0>
  80257e:	0f bd ea             	bsr    %edx,%ebp
  802581:	83 f5 1f             	xor    $0x1f,%ebp
  802584:	75 5a                	jne    8025e0 <__umoddi3+0xb0>
  802586:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80258a:	0f 82 e0 00 00 00    	jb     802670 <__umoddi3+0x140>
  802590:	39 0c 24             	cmp    %ecx,(%esp)
  802593:	0f 86 d7 00 00 00    	jbe    802670 <__umoddi3+0x140>
  802599:	8b 44 24 08          	mov    0x8(%esp),%eax
  80259d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025a1:	83 c4 1c             	add    $0x1c,%esp
  8025a4:	5b                   	pop    %ebx
  8025a5:	5e                   	pop    %esi
  8025a6:	5f                   	pop    %edi
  8025a7:	5d                   	pop    %ebp
  8025a8:	c3                   	ret    
  8025a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	85 ff                	test   %edi,%edi
  8025b2:	89 fd                	mov    %edi,%ebp
  8025b4:	75 0b                	jne    8025c1 <__umoddi3+0x91>
  8025b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025bb:	31 d2                	xor    %edx,%edx
  8025bd:	f7 f7                	div    %edi
  8025bf:	89 c5                	mov    %eax,%ebp
  8025c1:	89 f0                	mov    %esi,%eax
  8025c3:	31 d2                	xor    %edx,%edx
  8025c5:	f7 f5                	div    %ebp
  8025c7:	89 c8                	mov    %ecx,%eax
  8025c9:	f7 f5                	div    %ebp
  8025cb:	89 d0                	mov    %edx,%eax
  8025cd:	eb 99                	jmp    802568 <__umoddi3+0x38>
  8025cf:	90                   	nop
  8025d0:	89 c8                	mov    %ecx,%eax
  8025d2:	89 f2                	mov    %esi,%edx
  8025d4:	83 c4 1c             	add    $0x1c,%esp
  8025d7:	5b                   	pop    %ebx
  8025d8:	5e                   	pop    %esi
  8025d9:	5f                   	pop    %edi
  8025da:	5d                   	pop    %ebp
  8025db:	c3                   	ret    
  8025dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025e0:	8b 34 24             	mov    (%esp),%esi
  8025e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025e8:	89 e9                	mov    %ebp,%ecx
  8025ea:	29 ef                	sub    %ebp,%edi
  8025ec:	d3 e0                	shl    %cl,%eax
  8025ee:	89 f9                	mov    %edi,%ecx
  8025f0:	89 f2                	mov    %esi,%edx
  8025f2:	d3 ea                	shr    %cl,%edx
  8025f4:	89 e9                	mov    %ebp,%ecx
  8025f6:	09 c2                	or     %eax,%edx
  8025f8:	89 d8                	mov    %ebx,%eax
  8025fa:	89 14 24             	mov    %edx,(%esp)
  8025fd:	89 f2                	mov    %esi,%edx
  8025ff:	d3 e2                	shl    %cl,%edx
  802601:	89 f9                	mov    %edi,%ecx
  802603:	89 54 24 04          	mov    %edx,0x4(%esp)
  802607:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80260b:	d3 e8                	shr    %cl,%eax
  80260d:	89 e9                	mov    %ebp,%ecx
  80260f:	89 c6                	mov    %eax,%esi
  802611:	d3 e3                	shl    %cl,%ebx
  802613:	89 f9                	mov    %edi,%ecx
  802615:	89 d0                	mov    %edx,%eax
  802617:	d3 e8                	shr    %cl,%eax
  802619:	89 e9                	mov    %ebp,%ecx
  80261b:	09 d8                	or     %ebx,%eax
  80261d:	89 d3                	mov    %edx,%ebx
  80261f:	89 f2                	mov    %esi,%edx
  802621:	f7 34 24             	divl   (%esp)
  802624:	89 d6                	mov    %edx,%esi
  802626:	d3 e3                	shl    %cl,%ebx
  802628:	f7 64 24 04          	mull   0x4(%esp)
  80262c:	39 d6                	cmp    %edx,%esi
  80262e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802632:	89 d1                	mov    %edx,%ecx
  802634:	89 c3                	mov    %eax,%ebx
  802636:	72 08                	jb     802640 <__umoddi3+0x110>
  802638:	75 11                	jne    80264b <__umoddi3+0x11b>
  80263a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80263e:	73 0b                	jae    80264b <__umoddi3+0x11b>
  802640:	2b 44 24 04          	sub    0x4(%esp),%eax
  802644:	1b 14 24             	sbb    (%esp),%edx
  802647:	89 d1                	mov    %edx,%ecx
  802649:	89 c3                	mov    %eax,%ebx
  80264b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80264f:	29 da                	sub    %ebx,%edx
  802651:	19 ce                	sbb    %ecx,%esi
  802653:	89 f9                	mov    %edi,%ecx
  802655:	89 f0                	mov    %esi,%eax
  802657:	d3 e0                	shl    %cl,%eax
  802659:	89 e9                	mov    %ebp,%ecx
  80265b:	d3 ea                	shr    %cl,%edx
  80265d:	89 e9                	mov    %ebp,%ecx
  80265f:	d3 ee                	shr    %cl,%esi
  802661:	09 d0                	or     %edx,%eax
  802663:	89 f2                	mov    %esi,%edx
  802665:	83 c4 1c             	add    $0x1c,%esp
  802668:	5b                   	pop    %ebx
  802669:	5e                   	pop    %esi
  80266a:	5f                   	pop    %edi
  80266b:	5d                   	pop    %ebp
  80266c:	c3                   	ret    
  80266d:	8d 76 00             	lea    0x0(%esi),%esi
  802670:	29 f9                	sub    %edi,%ecx
  802672:	19 d6                	sbb    %edx,%esi
  802674:	89 74 24 04          	mov    %esi,0x4(%esp)
  802678:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80267c:	e9 18 ff ff ff       	jmp    802599 <__umoddi3+0x69>
