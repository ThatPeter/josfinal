
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 f7 05 00 00       	call   800628 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 60 80 00       	push   $0x806000
  800042:	e8 c2 0c 00 00       	call   800d09 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 5d 19 00 00       	call   8019b6 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 60 80 00       	push   $0x806000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 ec 18 00 00       	call   801954 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 60 18 00 00       	call   8018d9 <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 60 2a 80 00       	mov    $0x802a60,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 6b 2a 80 00       	push   $0x802a6b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 85 2a 80 00       	push   $0x802a85
  8000b4:	e8 f2 05 00 00       	call   8006ab <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 20 2c 80 00       	push   $0x802c20
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 85 2a 80 00       	push   $0x802a85
  8000cc:	e8 da 05 00 00       	call   8006ab <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 95 2a 80 00       	mov    $0x802a95,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 9e 2a 80 00       	push   $0x802a9e
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 85 2a 80 00       	push   $0x802a85
  8000f1:	e8 b5 05 00 00       	call   8006ab <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 44 2c 80 00       	push   $0x802c44
  800119:	6a 27                	push   $0x27
  80011b:	68 85 2a 80 00       	push   $0x802a85
  800120:	e8 86 05 00 00       	call   8006ab <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 b6 2a 80 00       	push   $0x802ab6
  80012d:	e8 52 06 00 00       	call   800784 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 40 80 00    	call   *0x80401c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 ca 2a 80 00       	push   $0x802aca
  800154:	6a 2b                	push   $0x2b
  800156:	68 85 2a 80 00       	push   $0x802a85
  80015b:	e8 4b 05 00 00       	call   8006ab <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 40 80 00    	pushl  0x804000
  800169:	e8 62 0b 00 00       	call   800cd0 <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 40 80 00    	pushl  0x804000
  80017f:	e8 4c 0b 00 00       	call   800cd0 <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 74 2c 80 00       	push   $0x802c74
  80018f:	6a 2d                	push   $0x2d
  800191:	68 85 2a 80 00       	push   $0x802a85
  800196:	e8 10 05 00 00       	call   8006ab <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 d8 2a 80 00       	push   $0x802ad8
  8001a3:	e8 dc 05 00 00       	call   800784 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 90 0c 00 00       	call   800e4e <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 40 80 00    	call   *0x804010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 eb 2a 80 00       	push   $0x802aeb
  8001df:	6a 32                	push   $0x32
  8001e1:	68 85 2a 80 00       	push   $0x802a85
  8001e6:	e8 c0 04 00 00       	call   8006ab <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 40 80 00    	pushl  0x804000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 b3 0b 00 00       	call   800db3 <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 f9 2a 80 00       	push   $0x802af9
  80020f:	6a 34                	push   $0x34
  800211:	68 85 2a 80 00       	push   $0x802a85
  800216:	e8 90 04 00 00       	call   8006ab <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 17 2b 80 00       	push   $0x802b17
  800223:	e8 5c 05 00 00       	call   800784 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 40 80 00    	call   *0x804018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 2a 2b 80 00       	push   $0x802b2a
  800242:	6a 38                	push   $0x38
  800244:	68 85 2a 80 00       	push   $0x802a85
  800249:	e8 5d 04 00 00       	call   8006ab <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 39 2b 80 00       	push   $0x802b39
  800256:	e8 29 05 00 00       	call   800784 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 07 0f 00 00       	call   801191 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 40 80 00    	call   *0x804010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 9c 2c 80 00       	push   $0x802c9c
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 85 2a 80 00       	push   $0x802a85
  8002b8:	e8 ee 03 00 00       	call   8006ab <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 4d 2b 80 00       	push   $0x802b4d
  8002c5:	e8 ba 04 00 00       	call   800784 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 63 2b 80 00       	mov    $0x802b63,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 6d 2b 80 00       	push   $0x802b6d
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 85 2a 80 00       	push   $0x802a85
  8002ed:	e8 b9 03 00 00       	call   8006ab <_panic>
	//////////////////////////BUG NO 1///////////////////////////////
	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 40 80 00    	mov    0x804014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 40 80 00    	pushl  0x804000
  800301:	e8 ca 09 00 00       	call   800cd0 <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 40 80 00    	pushl  0x804000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 40 80 00    	pushl  0x804000
  800322:	e8 a9 09 00 00       	call   800cd0 <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 86 2b 80 00       	push   $0x802b86
  800334:	6a 4b                	push   $0x4b
  800336:	68 85 2a 80 00       	push   $0x802a85
  80033b:	e8 6b 03 00 00       	call   8006ab <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 95 2b 80 00       	push   $0x802b95
  800348:	e8 37 04 00 00       	call   800784 <cprintf>
	//////////////////////////BUG NO 1///////////////////////////////
	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 e1 0a 00 00       	call   800e4e <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 40 80 00    	call   *0x804010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 d4 2c 80 00       	push   $0x802cd4
  800390:	6a 51                	push   $0x51
  800392:	68 85 2a 80 00       	push   $0x802a85
  800397:	e8 0f 03 00 00       	call   8006ab <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 40 80 00    	pushl  0x804000
  8003a5:	e8 26 09 00 00       	call   800cd0 <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 f4 2c 80 00       	push   $0x802cf4
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 85 2a 80 00       	push   $0x802a85
  8003be:	e8 e8 02 00 00       	call   8006ab <_panic>
	if (strcmp(buf, msg) != 0) 
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 40 80 00    	pushl  0x804000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 db 09 00 00       	call   800db3 <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 2c 2d 80 00       	push   $0x802d2c
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 85 2a 80 00       	push   $0x802a85
  8003ee:	e8 b8 02 00 00       	call   8006ab <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 5c 2d 80 00       	push   $0x802d5c
  8003fb:	e8 84 03 00 00       	call   800784 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 60 2a 80 00       	push   $0x802a60
  80040a:	e8 5f 1d 00 00       	call   80216e <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 71 2a 80 00       	push   $0x802a71
  800426:	6a 5a                	push   $0x5a
  800428:	68 85 2a 80 00       	push   $0x802a85
  80042d:	e8 79 02 00 00       	call   8006ab <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 a9 2b 80 00       	push   $0x802ba9
  80043e:	6a 5c                	push   $0x5c
  800440:	68 85 2a 80 00       	push   $0x802a85
  800445:	e8 61 02 00 00       	call   8006ab <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 95 2a 80 00       	push   $0x802a95
  800454:	e8 15 1d 00 00       	call   80216e <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 a4 2a 80 00       	push   $0x802aa4
  800466:	6a 5f                	push   $0x5f
  800468:	68 85 2a 80 00       	push   $0x802a85
  80046d:	e8 39 02 00 00       	call   8006ab <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 80 2d 80 00       	push   $0x802d80
  800498:	6a 62                	push   $0x62
  80049a:	68 85 2a 80 00       	push   $0x802a85
  80049f:	e8 07 02 00 00       	call   8006ab <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 bc 2a 80 00       	push   $0x802abc
  8004ac:	e8 d3 02 00 00       	call   800784 <cprintf>
//////////////////////////BUG NO 2///////////////////////////////
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 c4 2b 80 00       	push   $0x802bc4
  8004be:	e8 ab 1c 00 00       	call   80216e <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 c9 2b 80 00       	push   $0x802bc9
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 85 2a 80 00       	push   $0x802a85
  8004d9:	e8 cd 01 00 00       	call   8006ab <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 5a 09 00 00       	call   800e4e <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 a0 18 00 00       	call   801db7 <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 d8 2b 80 00       	push   $0x802bd8
  800528:	6a 6c                	push   $0x6c
  80052a:	68 85 2a 80 00       	push   $0x802a85
  80052f:	e8 77 01 00 00       	call   8006ab <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx
//////////////////////////BUG NO 2///////////////////////////////
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 52 16 00 00       	call   801b9e <close>
	
	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 c4 2b 80 00       	push   $0x802bc4
  800556:	e8 13 1c 00 00       	call   80216e <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 ea 2b 80 00       	push   $0x802bea
  80056a:	6a 71                	push   $0x71
  80056c:	68 85 2a 80 00       	push   $0x802a85
  800571:	e8 35 01 00 00       	call   8006ab <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);
	
	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 d8 17 00 00       	call   801d6e <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 f8 2b 80 00       	push   $0x802bf8
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 85 2a 80 00       	push   $0x802a85
  8005ae:	e8 f8 00 00 00       	call   8006ab <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 a8 2d 80 00       	push   $0x802da8
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 85 2a 80 00       	push   $0x802a85
  8005d0:	e8 d6 00 00 00       	call   8006ab <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 d4 2d 80 00       	push   $0x802dd4
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 85 2a 80 00       	push   $0x802a85
  8005f0:	e8 b6 00 00 00       	call   8006ab <_panic>
  8005f5:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  8005fb:	89 c3                	mov    %eax,%ebx
	}
	close(f);
	
	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005fd:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800602:	0f 85 79 ff ff ff    	jne    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	56                   	push   %esi
  80060c:	e8 8d 15 00 00       	call   801b9e <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 09 2c 80 00 	movl   $0x802c09,(%esp)
  800618:	e8 67 01 00 00       	call   800784 <cprintf>
//////////////////////////BUG NO 2///////////////////////////////
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5f                   	pop    %edi
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	56                   	push   %esi
  80062c:	53                   	push   %ebx
  80062d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800630:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800633:	e8 96 0a 00 00       	call   8010ce <sys_getenvid>
  800638:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063d:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800643:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800648:	a3 04 50 80 00       	mov    %eax,0x805004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80064d:	85 db                	test   %ebx,%ebx
  80064f:	7e 07                	jle    800658 <libmain+0x30>
		binaryname = argv[0];
  800651:	8b 06                	mov    (%esi),%eax
  800653:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	56                   	push   %esi
  80065c:	53                   	push   %ebx
  80065d:	e8 1c fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  800662:	e8 2a 00 00 00       	call   800691 <exit>
}
  800667:	83 c4 10             	add    $0x10,%esp
  80066a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80066d:	5b                   	pop    %ebx
  80066e:	5e                   	pop    %esi
  80066f:	5d                   	pop    %ebp
  800670:	c3                   	ret    

00800671 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800677:	a1 08 50 80 00       	mov    0x805008,%eax
	func();
  80067c:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80067e:	e8 4b 0a 00 00       	call   8010ce <sys_getenvid>
  800683:	83 ec 0c             	sub    $0xc,%esp
  800686:	50                   	push   %eax
  800687:	e8 91 0c 00 00       	call   80131d <sys_thread_free>
}
  80068c:	83 c4 10             	add    $0x10,%esp
  80068f:	c9                   	leave  
  800690:	c3                   	ret    

00800691 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800697:	e8 2d 15 00 00       	call   801bc9 <close_all>
	sys_env_destroy(0);
  80069c:	83 ec 0c             	sub    $0xc,%esp
  80069f:	6a 00                	push   $0x0
  8006a1:	e8 e7 09 00 00       	call   80108d <sys_env_destroy>
}
  8006a6:	83 c4 10             	add    $0x10,%esp
  8006a9:	c9                   	leave  
  8006aa:	c3                   	ret    

008006ab <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	56                   	push   %esi
  8006af:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8006b0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8006b3:	8b 35 04 40 80 00    	mov    0x804004,%esi
  8006b9:	e8 10 0a 00 00       	call   8010ce <sys_getenvid>
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	ff 75 0c             	pushl  0xc(%ebp)
  8006c4:	ff 75 08             	pushl  0x8(%ebp)
  8006c7:	56                   	push   %esi
  8006c8:	50                   	push   %eax
  8006c9:	68 2c 2e 80 00       	push   $0x802e2c
  8006ce:	e8 b1 00 00 00       	call   800784 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006d3:	83 c4 18             	add    $0x18,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	ff 75 10             	pushl  0x10(%ebp)
  8006da:	e8 54 00 00 00       	call   800733 <vcprintf>
	cprintf("\n");
  8006df:	c7 04 24 26 32 80 00 	movl   $0x803226,(%esp)
  8006e6:	e8 99 00 00 00       	call   800784 <cprintf>
  8006eb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006ee:	cc                   	int3   
  8006ef:	eb fd                	jmp    8006ee <_panic+0x43>

008006f1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	53                   	push   %ebx
  8006f5:	83 ec 04             	sub    $0x4,%esp
  8006f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006fb:	8b 13                	mov    (%ebx),%edx
  8006fd:	8d 42 01             	lea    0x1(%edx),%eax
  800700:	89 03                	mov    %eax,(%ebx)
  800702:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800705:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800709:	3d ff 00 00 00       	cmp    $0xff,%eax
  80070e:	75 1a                	jne    80072a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	68 ff 00 00 00       	push   $0xff
  800718:	8d 43 08             	lea    0x8(%ebx),%eax
  80071b:	50                   	push   %eax
  80071c:	e8 2f 09 00 00       	call   801050 <sys_cputs>
		b->idx = 0;
  800721:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800727:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80072a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80072e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800731:	c9                   	leave  
  800732:	c3                   	ret    

00800733 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80073c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800743:	00 00 00 
	b.cnt = 0;
  800746:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80074d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	ff 75 08             	pushl  0x8(%ebp)
  800756:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80075c:	50                   	push   %eax
  80075d:	68 f1 06 80 00       	push   $0x8006f1
  800762:	e8 54 01 00 00       	call   8008bb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800767:	83 c4 08             	add    $0x8,%esp
  80076a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800770:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800776:	50                   	push   %eax
  800777:	e8 d4 08 00 00       	call   801050 <sys_cputs>

	return b.cnt;
}
  80077c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800782:	c9                   	leave  
  800783:	c3                   	ret    

00800784 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80078a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80078d:	50                   	push   %eax
  80078e:	ff 75 08             	pushl  0x8(%ebp)
  800791:	e8 9d ff ff ff       	call   800733 <vcprintf>
	va_end(ap);

	return cnt;
}
  800796:	c9                   	leave  
  800797:	c3                   	ret    

00800798 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	57                   	push   %edi
  80079c:	56                   	push   %esi
  80079d:	53                   	push   %ebx
  80079e:	83 ec 1c             	sub    $0x1c,%esp
  8007a1:	89 c7                	mov    %eax,%edi
  8007a3:	89 d6                	mov    %edx,%esi
  8007a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8007bc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8007bf:	39 d3                	cmp    %edx,%ebx
  8007c1:	72 05                	jb     8007c8 <printnum+0x30>
  8007c3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007c6:	77 45                	ja     80080d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007c8:	83 ec 0c             	sub    $0xc,%esp
  8007cb:	ff 75 18             	pushl  0x18(%ebp)
  8007ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007d4:	53                   	push   %ebx
  8007d5:	ff 75 10             	pushl  0x10(%ebp)
  8007d8:	83 ec 08             	sub    $0x8,%esp
  8007db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007de:	ff 75 e0             	pushl  -0x20(%ebp)
  8007e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8007e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8007e7:	e8 e4 1f 00 00       	call   8027d0 <__udivdi3>
  8007ec:	83 c4 18             	add    $0x18,%esp
  8007ef:	52                   	push   %edx
  8007f0:	50                   	push   %eax
  8007f1:	89 f2                	mov    %esi,%edx
  8007f3:	89 f8                	mov    %edi,%eax
  8007f5:	e8 9e ff ff ff       	call   800798 <printnum>
  8007fa:	83 c4 20             	add    $0x20,%esp
  8007fd:	eb 18                	jmp    800817 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007ff:	83 ec 08             	sub    $0x8,%esp
  800802:	56                   	push   %esi
  800803:	ff 75 18             	pushl  0x18(%ebp)
  800806:	ff d7                	call   *%edi
  800808:	83 c4 10             	add    $0x10,%esp
  80080b:	eb 03                	jmp    800810 <printnum+0x78>
  80080d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800810:	83 eb 01             	sub    $0x1,%ebx
  800813:	85 db                	test   %ebx,%ebx
  800815:	7f e8                	jg     8007ff <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800817:	83 ec 08             	sub    $0x8,%esp
  80081a:	56                   	push   %esi
  80081b:	83 ec 04             	sub    $0x4,%esp
  80081e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800821:	ff 75 e0             	pushl  -0x20(%ebp)
  800824:	ff 75 dc             	pushl  -0x24(%ebp)
  800827:	ff 75 d8             	pushl  -0x28(%ebp)
  80082a:	e8 d1 20 00 00       	call   802900 <__umoddi3>
  80082f:	83 c4 14             	add    $0x14,%esp
  800832:	0f be 80 4f 2e 80 00 	movsbl 0x802e4f(%eax),%eax
  800839:	50                   	push   %eax
  80083a:	ff d7                	call   *%edi
}
  80083c:	83 c4 10             	add    $0x10,%esp
  80083f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5f                   	pop    %edi
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80084a:	83 fa 01             	cmp    $0x1,%edx
  80084d:	7e 0e                	jle    80085d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80084f:	8b 10                	mov    (%eax),%edx
  800851:	8d 4a 08             	lea    0x8(%edx),%ecx
  800854:	89 08                	mov    %ecx,(%eax)
  800856:	8b 02                	mov    (%edx),%eax
  800858:	8b 52 04             	mov    0x4(%edx),%edx
  80085b:	eb 22                	jmp    80087f <getuint+0x38>
	else if (lflag)
  80085d:	85 d2                	test   %edx,%edx
  80085f:	74 10                	je     800871 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800861:	8b 10                	mov    (%eax),%edx
  800863:	8d 4a 04             	lea    0x4(%edx),%ecx
  800866:	89 08                	mov    %ecx,(%eax)
  800868:	8b 02                	mov    (%edx),%eax
  80086a:	ba 00 00 00 00       	mov    $0x0,%edx
  80086f:	eb 0e                	jmp    80087f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800871:	8b 10                	mov    (%eax),%edx
  800873:	8d 4a 04             	lea    0x4(%edx),%ecx
  800876:	89 08                	mov    %ecx,(%eax)
  800878:	8b 02                	mov    (%edx),%eax
  80087a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800887:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80088b:	8b 10                	mov    (%eax),%edx
  80088d:	3b 50 04             	cmp    0x4(%eax),%edx
  800890:	73 0a                	jae    80089c <sprintputch+0x1b>
		*b->buf++ = ch;
  800892:	8d 4a 01             	lea    0x1(%edx),%ecx
  800895:	89 08                	mov    %ecx,(%eax)
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	88 02                	mov    %al,(%edx)
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8008a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8008a7:	50                   	push   %eax
  8008a8:	ff 75 10             	pushl  0x10(%ebp)
  8008ab:	ff 75 0c             	pushl  0xc(%ebp)
  8008ae:	ff 75 08             	pushl  0x8(%ebp)
  8008b1:	e8 05 00 00 00       	call   8008bb <vprintfmt>
	va_end(ap);
}
  8008b6:	83 c4 10             	add    $0x10,%esp
  8008b9:	c9                   	leave  
  8008ba:	c3                   	ret    

008008bb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	57                   	push   %edi
  8008bf:	56                   	push   %esi
  8008c0:	53                   	push   %ebx
  8008c1:	83 ec 2c             	sub    $0x2c,%esp
  8008c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ca:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008cd:	eb 12                	jmp    8008e1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	0f 84 89 03 00 00    	je     800c60 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8008d7:	83 ec 08             	sub    $0x8,%esp
  8008da:	53                   	push   %ebx
  8008db:	50                   	push   %eax
  8008dc:	ff d6                	call   *%esi
  8008de:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008e1:	83 c7 01             	add    $0x1,%edi
  8008e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008e8:	83 f8 25             	cmp    $0x25,%eax
  8008eb:	75 e2                	jne    8008cf <vprintfmt+0x14>
  8008ed:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8008f1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008f8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008ff:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800906:	ba 00 00 00 00       	mov    $0x0,%edx
  80090b:	eb 07                	jmp    800914 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800910:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800914:	8d 47 01             	lea    0x1(%edi),%eax
  800917:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80091a:	0f b6 07             	movzbl (%edi),%eax
  80091d:	0f b6 c8             	movzbl %al,%ecx
  800920:	83 e8 23             	sub    $0x23,%eax
  800923:	3c 55                	cmp    $0x55,%al
  800925:	0f 87 1a 03 00 00    	ja     800c45 <vprintfmt+0x38a>
  80092b:	0f b6 c0             	movzbl %al,%eax
  80092e:	ff 24 85 a0 2f 80 00 	jmp    *0x802fa0(,%eax,4)
  800935:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800938:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80093c:	eb d6                	jmp    800914 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800941:	b8 00 00 00 00       	mov    $0x0,%eax
  800946:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800949:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80094c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800950:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800953:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800956:	83 fa 09             	cmp    $0x9,%edx
  800959:	77 39                	ja     800994 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80095b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80095e:	eb e9                	jmp    800949 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800960:	8b 45 14             	mov    0x14(%ebp),%eax
  800963:	8d 48 04             	lea    0x4(%eax),%ecx
  800966:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800969:	8b 00                	mov    (%eax),%eax
  80096b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800971:	eb 27                	jmp    80099a <vprintfmt+0xdf>
  800973:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800976:	85 c0                	test   %eax,%eax
  800978:	b9 00 00 00 00       	mov    $0x0,%ecx
  80097d:	0f 49 c8             	cmovns %eax,%ecx
  800980:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800983:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800986:	eb 8c                	jmp    800914 <vprintfmt+0x59>
  800988:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80098b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800992:	eb 80                	jmp    800914 <vprintfmt+0x59>
  800994:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800997:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80099a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80099e:	0f 89 70 ff ff ff    	jns    800914 <vprintfmt+0x59>
				width = precision, precision = -1;
  8009a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009aa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009b1:	e9 5e ff ff ff       	jmp    800914 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009b6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8009bc:	e9 53 ff ff ff       	jmp    800914 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c4:	8d 50 04             	lea    0x4(%eax),%edx
  8009c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ca:	83 ec 08             	sub    $0x8,%esp
  8009cd:	53                   	push   %ebx
  8009ce:	ff 30                	pushl  (%eax)
  8009d0:	ff d6                	call   *%esi
			break;
  8009d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009d8:	e9 04 ff ff ff       	jmp    8008e1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e0:	8d 50 04             	lea    0x4(%eax),%edx
  8009e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8009e6:	8b 00                	mov    (%eax),%eax
  8009e8:	99                   	cltd   
  8009e9:	31 d0                	xor    %edx,%eax
  8009eb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009ed:	83 f8 0f             	cmp    $0xf,%eax
  8009f0:	7f 0b                	jg     8009fd <vprintfmt+0x142>
  8009f2:	8b 14 85 00 31 80 00 	mov    0x803100(,%eax,4),%edx
  8009f9:	85 d2                	test   %edx,%edx
  8009fb:	75 18                	jne    800a15 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8009fd:	50                   	push   %eax
  8009fe:	68 67 2e 80 00       	push   $0x802e67
  800a03:	53                   	push   %ebx
  800a04:	56                   	push   %esi
  800a05:	e8 94 fe ff ff       	call   80089e <printfmt>
  800a0a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800a10:	e9 cc fe ff ff       	jmp    8008e1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800a15:	52                   	push   %edx
  800a16:	68 a9 33 80 00       	push   $0x8033a9
  800a1b:	53                   	push   %ebx
  800a1c:	56                   	push   %esi
  800a1d:	e8 7c fe ff ff       	call   80089e <printfmt>
  800a22:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a28:	e9 b4 fe ff ff       	jmp    8008e1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a2d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a30:	8d 50 04             	lea    0x4(%eax),%edx
  800a33:	89 55 14             	mov    %edx,0x14(%ebp)
  800a36:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a38:	85 ff                	test   %edi,%edi
  800a3a:	b8 60 2e 80 00       	mov    $0x802e60,%eax
  800a3f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a42:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a46:	0f 8e 94 00 00 00    	jle    800ae0 <vprintfmt+0x225>
  800a4c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a50:	0f 84 98 00 00 00    	je     800aee <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a56:	83 ec 08             	sub    $0x8,%esp
  800a59:	ff 75 d0             	pushl  -0x30(%ebp)
  800a5c:	57                   	push   %edi
  800a5d:	e8 86 02 00 00       	call   800ce8 <strnlen>
  800a62:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a65:	29 c1                	sub    %eax,%ecx
  800a67:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a6a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a6d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a71:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a74:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a77:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a79:	eb 0f                	jmp    800a8a <vprintfmt+0x1cf>
					putch(padc, putdat);
  800a7b:	83 ec 08             	sub    $0x8,%esp
  800a7e:	53                   	push   %ebx
  800a7f:	ff 75 e0             	pushl  -0x20(%ebp)
  800a82:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a84:	83 ef 01             	sub    $0x1,%edi
  800a87:	83 c4 10             	add    $0x10,%esp
  800a8a:	85 ff                	test   %edi,%edi
  800a8c:	7f ed                	jg     800a7b <vprintfmt+0x1c0>
  800a8e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a91:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a94:	85 c9                	test   %ecx,%ecx
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	0f 49 c1             	cmovns %ecx,%eax
  800a9e:	29 c1                	sub    %eax,%ecx
  800aa0:	89 75 08             	mov    %esi,0x8(%ebp)
  800aa3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800aa6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800aa9:	89 cb                	mov    %ecx,%ebx
  800aab:	eb 4d                	jmp    800afa <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800aad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ab1:	74 1b                	je     800ace <vprintfmt+0x213>
  800ab3:	0f be c0             	movsbl %al,%eax
  800ab6:	83 e8 20             	sub    $0x20,%eax
  800ab9:	83 f8 5e             	cmp    $0x5e,%eax
  800abc:	76 10                	jbe    800ace <vprintfmt+0x213>
					putch('?', putdat);
  800abe:	83 ec 08             	sub    $0x8,%esp
  800ac1:	ff 75 0c             	pushl  0xc(%ebp)
  800ac4:	6a 3f                	push   $0x3f
  800ac6:	ff 55 08             	call   *0x8(%ebp)
  800ac9:	83 c4 10             	add    $0x10,%esp
  800acc:	eb 0d                	jmp    800adb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800ace:	83 ec 08             	sub    $0x8,%esp
  800ad1:	ff 75 0c             	pushl  0xc(%ebp)
  800ad4:	52                   	push   %edx
  800ad5:	ff 55 08             	call   *0x8(%ebp)
  800ad8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800adb:	83 eb 01             	sub    $0x1,%ebx
  800ade:	eb 1a                	jmp    800afa <vprintfmt+0x23f>
  800ae0:	89 75 08             	mov    %esi,0x8(%ebp)
  800ae3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ae6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ae9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800aec:	eb 0c                	jmp    800afa <vprintfmt+0x23f>
  800aee:	89 75 08             	mov    %esi,0x8(%ebp)
  800af1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800af4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800af7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800afa:	83 c7 01             	add    $0x1,%edi
  800afd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800b01:	0f be d0             	movsbl %al,%edx
  800b04:	85 d2                	test   %edx,%edx
  800b06:	74 23                	je     800b2b <vprintfmt+0x270>
  800b08:	85 f6                	test   %esi,%esi
  800b0a:	78 a1                	js     800aad <vprintfmt+0x1f2>
  800b0c:	83 ee 01             	sub    $0x1,%esi
  800b0f:	79 9c                	jns    800aad <vprintfmt+0x1f2>
  800b11:	89 df                	mov    %ebx,%edi
  800b13:	8b 75 08             	mov    0x8(%ebp),%esi
  800b16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b19:	eb 18                	jmp    800b33 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b1b:	83 ec 08             	sub    $0x8,%esp
  800b1e:	53                   	push   %ebx
  800b1f:	6a 20                	push   $0x20
  800b21:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b23:	83 ef 01             	sub    $0x1,%edi
  800b26:	83 c4 10             	add    $0x10,%esp
  800b29:	eb 08                	jmp    800b33 <vprintfmt+0x278>
  800b2b:	89 df                	mov    %ebx,%edi
  800b2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b33:	85 ff                	test   %edi,%edi
  800b35:	7f e4                	jg     800b1b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b3a:	e9 a2 fd ff ff       	jmp    8008e1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b3f:	83 fa 01             	cmp    $0x1,%edx
  800b42:	7e 16                	jle    800b5a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800b44:	8b 45 14             	mov    0x14(%ebp),%eax
  800b47:	8d 50 08             	lea    0x8(%eax),%edx
  800b4a:	89 55 14             	mov    %edx,0x14(%ebp)
  800b4d:	8b 50 04             	mov    0x4(%eax),%edx
  800b50:	8b 00                	mov    (%eax),%eax
  800b52:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b55:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b58:	eb 32                	jmp    800b8c <vprintfmt+0x2d1>
	else if (lflag)
  800b5a:	85 d2                	test   %edx,%edx
  800b5c:	74 18                	je     800b76 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800b5e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b61:	8d 50 04             	lea    0x4(%eax),%edx
  800b64:	89 55 14             	mov    %edx,0x14(%ebp)
  800b67:	8b 00                	mov    (%eax),%eax
  800b69:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b6c:	89 c1                	mov    %eax,%ecx
  800b6e:	c1 f9 1f             	sar    $0x1f,%ecx
  800b71:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b74:	eb 16                	jmp    800b8c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800b76:	8b 45 14             	mov    0x14(%ebp),%eax
  800b79:	8d 50 04             	lea    0x4(%eax),%edx
  800b7c:	89 55 14             	mov    %edx,0x14(%ebp)
  800b7f:	8b 00                	mov    (%eax),%eax
  800b81:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b84:	89 c1                	mov    %eax,%ecx
  800b86:	c1 f9 1f             	sar    $0x1f,%ecx
  800b89:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b8c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b8f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b92:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b97:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b9b:	79 74                	jns    800c11 <vprintfmt+0x356>
				putch('-', putdat);
  800b9d:	83 ec 08             	sub    $0x8,%esp
  800ba0:	53                   	push   %ebx
  800ba1:	6a 2d                	push   $0x2d
  800ba3:	ff d6                	call   *%esi
				num = -(long long) num;
  800ba5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ba8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800bab:	f7 d8                	neg    %eax
  800bad:	83 d2 00             	adc    $0x0,%edx
  800bb0:	f7 da                	neg    %edx
  800bb2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800bb5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bba:	eb 55                	jmp    800c11 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bbc:	8d 45 14             	lea    0x14(%ebp),%eax
  800bbf:	e8 83 fc ff ff       	call   800847 <getuint>
			base = 10;
  800bc4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800bc9:	eb 46                	jmp    800c11 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800bcb:	8d 45 14             	lea    0x14(%ebp),%eax
  800bce:	e8 74 fc ff ff       	call   800847 <getuint>
			base = 8;
  800bd3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800bd8:	eb 37                	jmp    800c11 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800bda:	83 ec 08             	sub    $0x8,%esp
  800bdd:	53                   	push   %ebx
  800bde:	6a 30                	push   $0x30
  800be0:	ff d6                	call   *%esi
			putch('x', putdat);
  800be2:	83 c4 08             	add    $0x8,%esp
  800be5:	53                   	push   %ebx
  800be6:	6a 78                	push   $0x78
  800be8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bea:	8b 45 14             	mov    0x14(%ebp),%eax
  800bed:	8d 50 04             	lea    0x4(%eax),%edx
  800bf0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bf3:	8b 00                	mov    (%eax),%eax
  800bf5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bfa:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bfd:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800c02:	eb 0d                	jmp    800c11 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c04:	8d 45 14             	lea    0x14(%ebp),%eax
  800c07:	e8 3b fc ff ff       	call   800847 <getuint>
			base = 16;
  800c0c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c11:	83 ec 0c             	sub    $0xc,%esp
  800c14:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800c18:	57                   	push   %edi
  800c19:	ff 75 e0             	pushl  -0x20(%ebp)
  800c1c:	51                   	push   %ecx
  800c1d:	52                   	push   %edx
  800c1e:	50                   	push   %eax
  800c1f:	89 da                	mov    %ebx,%edx
  800c21:	89 f0                	mov    %esi,%eax
  800c23:	e8 70 fb ff ff       	call   800798 <printnum>
			break;
  800c28:	83 c4 20             	add    $0x20,%esp
  800c2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c2e:	e9 ae fc ff ff       	jmp    8008e1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c33:	83 ec 08             	sub    $0x8,%esp
  800c36:	53                   	push   %ebx
  800c37:	51                   	push   %ecx
  800c38:	ff d6                	call   *%esi
			break;
  800c3a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c40:	e9 9c fc ff ff       	jmp    8008e1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c45:	83 ec 08             	sub    $0x8,%esp
  800c48:	53                   	push   %ebx
  800c49:	6a 25                	push   $0x25
  800c4b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c4d:	83 c4 10             	add    $0x10,%esp
  800c50:	eb 03                	jmp    800c55 <vprintfmt+0x39a>
  800c52:	83 ef 01             	sub    $0x1,%edi
  800c55:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c59:	75 f7                	jne    800c52 <vprintfmt+0x397>
  800c5b:	e9 81 fc ff ff       	jmp    8008e1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 18             	sub    $0x18,%esp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c74:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c77:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c7b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	74 26                	je     800caf <vsnprintf+0x47>
  800c89:	85 d2                	test   %edx,%edx
  800c8b:	7e 22                	jle    800caf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c8d:	ff 75 14             	pushl  0x14(%ebp)
  800c90:	ff 75 10             	pushl  0x10(%ebp)
  800c93:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c96:	50                   	push   %eax
  800c97:	68 81 08 80 00       	push   $0x800881
  800c9c:	e8 1a fc ff ff       	call   8008bb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ca1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ca4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800caa:	83 c4 10             	add    $0x10,%esp
  800cad:	eb 05                	jmp    800cb4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800caf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cb4:	c9                   	leave  
  800cb5:	c3                   	ret    

00800cb6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cbc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cbf:	50                   	push   %eax
  800cc0:	ff 75 10             	pushl  0x10(%ebp)
  800cc3:	ff 75 0c             	pushl  0xc(%ebp)
  800cc6:	ff 75 08             	pushl  0x8(%ebp)
  800cc9:	e8 9a ff ff ff       	call   800c68 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cce:	c9                   	leave  
  800ccf:	c3                   	ret    

00800cd0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdb:	eb 03                	jmp    800ce0 <strlen+0x10>
		n++;
  800cdd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ce0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ce4:	75 f7                	jne    800cdd <strlen+0xd>
		n++;
	return n;
}
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cee:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cf1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf6:	eb 03                	jmp    800cfb <strnlen+0x13>
		n++;
  800cf8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cfb:	39 c2                	cmp    %eax,%edx
  800cfd:	74 08                	je     800d07 <strnlen+0x1f>
  800cff:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800d03:	75 f3                	jne    800cf8 <strnlen+0x10>
  800d05:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	53                   	push   %ebx
  800d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d13:	89 c2                	mov    %eax,%edx
  800d15:	83 c2 01             	add    $0x1,%edx
  800d18:	83 c1 01             	add    $0x1,%ecx
  800d1b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d1f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d22:	84 db                	test   %bl,%bl
  800d24:	75 ef                	jne    800d15 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d26:	5b                   	pop    %ebx
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	53                   	push   %ebx
  800d2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d30:	53                   	push   %ebx
  800d31:	e8 9a ff ff ff       	call   800cd0 <strlen>
  800d36:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d39:	ff 75 0c             	pushl  0xc(%ebp)
  800d3c:	01 d8                	add    %ebx,%eax
  800d3e:	50                   	push   %eax
  800d3f:	e8 c5 ff ff ff       	call   800d09 <strcpy>
	return dst;
}
  800d44:	89 d8                	mov    %ebx,%eax
  800d46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d49:	c9                   	leave  
  800d4a:	c3                   	ret    

00800d4b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	8b 75 08             	mov    0x8(%ebp),%esi
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	89 f3                	mov    %esi,%ebx
  800d58:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d5b:	89 f2                	mov    %esi,%edx
  800d5d:	eb 0f                	jmp    800d6e <strncpy+0x23>
		*dst++ = *src;
  800d5f:	83 c2 01             	add    $0x1,%edx
  800d62:	0f b6 01             	movzbl (%ecx),%eax
  800d65:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d68:	80 39 01             	cmpb   $0x1,(%ecx)
  800d6b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d6e:	39 da                	cmp    %ebx,%edx
  800d70:	75 ed                	jne    800d5f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d72:	89 f0                	mov    %esi,%eax
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
  800d7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d83:	8b 55 10             	mov    0x10(%ebp),%edx
  800d86:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d88:	85 d2                	test   %edx,%edx
  800d8a:	74 21                	je     800dad <strlcpy+0x35>
  800d8c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d90:	89 f2                	mov    %esi,%edx
  800d92:	eb 09                	jmp    800d9d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d94:	83 c2 01             	add    $0x1,%edx
  800d97:	83 c1 01             	add    $0x1,%ecx
  800d9a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d9d:	39 c2                	cmp    %eax,%edx
  800d9f:	74 09                	je     800daa <strlcpy+0x32>
  800da1:	0f b6 19             	movzbl (%ecx),%ebx
  800da4:	84 db                	test   %bl,%bl
  800da6:	75 ec                	jne    800d94 <strlcpy+0x1c>
  800da8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800daa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dad:	29 f0                	sub    %esi,%eax
}
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800dbc:	eb 06                	jmp    800dc4 <strcmp+0x11>
		p++, q++;
  800dbe:	83 c1 01             	add    $0x1,%ecx
  800dc1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dc4:	0f b6 01             	movzbl (%ecx),%eax
  800dc7:	84 c0                	test   %al,%al
  800dc9:	74 04                	je     800dcf <strcmp+0x1c>
  800dcb:	3a 02                	cmp    (%edx),%al
  800dcd:	74 ef                	je     800dbe <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dcf:	0f b6 c0             	movzbl %al,%eax
  800dd2:	0f b6 12             	movzbl (%edx),%edx
  800dd5:	29 d0                	sub    %edx,%eax
}
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	53                   	push   %ebx
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  800de0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de3:	89 c3                	mov    %eax,%ebx
  800de5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800de8:	eb 06                	jmp    800df0 <strncmp+0x17>
		n--, p++, q++;
  800dea:	83 c0 01             	add    $0x1,%eax
  800ded:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800df0:	39 d8                	cmp    %ebx,%eax
  800df2:	74 15                	je     800e09 <strncmp+0x30>
  800df4:	0f b6 08             	movzbl (%eax),%ecx
  800df7:	84 c9                	test   %cl,%cl
  800df9:	74 04                	je     800dff <strncmp+0x26>
  800dfb:	3a 0a                	cmp    (%edx),%cl
  800dfd:	74 eb                	je     800dea <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dff:	0f b6 00             	movzbl (%eax),%eax
  800e02:	0f b6 12             	movzbl (%edx),%edx
  800e05:	29 d0                	sub    %edx,%eax
  800e07:	eb 05                	jmp    800e0e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e09:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e0e:	5b                   	pop    %ebx
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	8b 45 08             	mov    0x8(%ebp),%eax
  800e17:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e1b:	eb 07                	jmp    800e24 <strchr+0x13>
		if (*s == c)
  800e1d:	38 ca                	cmp    %cl,%dl
  800e1f:	74 0f                	je     800e30 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e21:	83 c0 01             	add    $0x1,%eax
  800e24:	0f b6 10             	movzbl (%eax),%edx
  800e27:	84 d2                	test   %dl,%dl
  800e29:	75 f2                	jne    800e1d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
  800e38:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e3c:	eb 03                	jmp    800e41 <strfind+0xf>
  800e3e:	83 c0 01             	add    $0x1,%eax
  800e41:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e44:	38 ca                	cmp    %cl,%dl
  800e46:	74 04                	je     800e4c <strfind+0x1a>
  800e48:	84 d2                	test   %dl,%dl
  800e4a:	75 f2                	jne    800e3e <strfind+0xc>
			break;
	return (char *) s;
}
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e5a:	85 c9                	test   %ecx,%ecx
  800e5c:	74 36                	je     800e94 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e5e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e64:	75 28                	jne    800e8e <memset+0x40>
  800e66:	f6 c1 03             	test   $0x3,%cl
  800e69:	75 23                	jne    800e8e <memset+0x40>
		c &= 0xFF;
  800e6b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e6f:	89 d3                	mov    %edx,%ebx
  800e71:	c1 e3 08             	shl    $0x8,%ebx
  800e74:	89 d6                	mov    %edx,%esi
  800e76:	c1 e6 18             	shl    $0x18,%esi
  800e79:	89 d0                	mov    %edx,%eax
  800e7b:	c1 e0 10             	shl    $0x10,%eax
  800e7e:	09 f0                	or     %esi,%eax
  800e80:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e82:	89 d8                	mov    %ebx,%eax
  800e84:	09 d0                	or     %edx,%eax
  800e86:	c1 e9 02             	shr    $0x2,%ecx
  800e89:	fc                   	cld    
  800e8a:	f3 ab                	rep stos %eax,%es:(%edi)
  800e8c:	eb 06                	jmp    800e94 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e91:	fc                   	cld    
  800e92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e94:	89 f8                	mov    %edi,%eax
  800e96:	5b                   	pop    %ebx
  800e97:	5e                   	pop    %esi
  800e98:	5f                   	pop    %edi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	57                   	push   %edi
  800e9f:	56                   	push   %esi
  800ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ea6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ea9:	39 c6                	cmp    %eax,%esi
  800eab:	73 35                	jae    800ee2 <memmove+0x47>
  800ead:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800eb0:	39 d0                	cmp    %edx,%eax
  800eb2:	73 2e                	jae    800ee2 <memmove+0x47>
		s += n;
		d += n;
  800eb4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eb7:	89 d6                	mov    %edx,%esi
  800eb9:	09 fe                	or     %edi,%esi
  800ebb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ec1:	75 13                	jne    800ed6 <memmove+0x3b>
  800ec3:	f6 c1 03             	test   $0x3,%cl
  800ec6:	75 0e                	jne    800ed6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ec8:	83 ef 04             	sub    $0x4,%edi
  800ecb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ece:	c1 e9 02             	shr    $0x2,%ecx
  800ed1:	fd                   	std    
  800ed2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ed4:	eb 09                	jmp    800edf <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ed6:	83 ef 01             	sub    $0x1,%edi
  800ed9:	8d 72 ff             	lea    -0x1(%edx),%esi
  800edc:	fd                   	std    
  800edd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800edf:	fc                   	cld    
  800ee0:	eb 1d                	jmp    800eff <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ee2:	89 f2                	mov    %esi,%edx
  800ee4:	09 c2                	or     %eax,%edx
  800ee6:	f6 c2 03             	test   $0x3,%dl
  800ee9:	75 0f                	jne    800efa <memmove+0x5f>
  800eeb:	f6 c1 03             	test   $0x3,%cl
  800eee:	75 0a                	jne    800efa <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ef0:	c1 e9 02             	shr    $0x2,%ecx
  800ef3:	89 c7                	mov    %eax,%edi
  800ef5:	fc                   	cld    
  800ef6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ef8:	eb 05                	jmp    800eff <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800efa:	89 c7                	mov    %eax,%edi
  800efc:	fc                   	cld    
  800efd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f06:	ff 75 10             	pushl  0x10(%ebp)
  800f09:	ff 75 0c             	pushl  0xc(%ebp)
  800f0c:	ff 75 08             	pushl  0x8(%ebp)
  800f0f:	e8 87 ff ff ff       	call   800e9b <memmove>
}
  800f14:	c9                   	leave  
  800f15:	c3                   	ret    

00800f16 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	56                   	push   %esi
  800f1a:	53                   	push   %ebx
  800f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f21:	89 c6                	mov    %eax,%esi
  800f23:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f26:	eb 1a                	jmp    800f42 <memcmp+0x2c>
		if (*s1 != *s2)
  800f28:	0f b6 08             	movzbl (%eax),%ecx
  800f2b:	0f b6 1a             	movzbl (%edx),%ebx
  800f2e:	38 d9                	cmp    %bl,%cl
  800f30:	74 0a                	je     800f3c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f32:	0f b6 c1             	movzbl %cl,%eax
  800f35:	0f b6 db             	movzbl %bl,%ebx
  800f38:	29 d8                	sub    %ebx,%eax
  800f3a:	eb 0f                	jmp    800f4b <memcmp+0x35>
		s1++, s2++;
  800f3c:	83 c0 01             	add    $0x1,%eax
  800f3f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f42:	39 f0                	cmp    %esi,%eax
  800f44:	75 e2                	jne    800f28 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f4b:	5b                   	pop    %ebx
  800f4c:	5e                   	pop    %esi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	53                   	push   %ebx
  800f53:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f56:	89 c1                	mov    %eax,%ecx
  800f58:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f5b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f5f:	eb 0a                	jmp    800f6b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f61:	0f b6 10             	movzbl (%eax),%edx
  800f64:	39 da                	cmp    %ebx,%edx
  800f66:	74 07                	je     800f6f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f68:	83 c0 01             	add    $0x1,%eax
  800f6b:	39 c8                	cmp    %ecx,%eax
  800f6d:	72 f2                	jb     800f61 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f6f:	5b                   	pop    %ebx
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	57                   	push   %edi
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f7e:	eb 03                	jmp    800f83 <strtol+0x11>
		s++;
  800f80:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f83:	0f b6 01             	movzbl (%ecx),%eax
  800f86:	3c 20                	cmp    $0x20,%al
  800f88:	74 f6                	je     800f80 <strtol+0xe>
  800f8a:	3c 09                	cmp    $0x9,%al
  800f8c:	74 f2                	je     800f80 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f8e:	3c 2b                	cmp    $0x2b,%al
  800f90:	75 0a                	jne    800f9c <strtol+0x2a>
		s++;
  800f92:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f95:	bf 00 00 00 00       	mov    $0x0,%edi
  800f9a:	eb 11                	jmp    800fad <strtol+0x3b>
  800f9c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fa1:	3c 2d                	cmp    $0x2d,%al
  800fa3:	75 08                	jne    800fad <strtol+0x3b>
		s++, neg = 1;
  800fa5:	83 c1 01             	add    $0x1,%ecx
  800fa8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fad:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800fb3:	75 15                	jne    800fca <strtol+0x58>
  800fb5:	80 39 30             	cmpb   $0x30,(%ecx)
  800fb8:	75 10                	jne    800fca <strtol+0x58>
  800fba:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800fbe:	75 7c                	jne    80103c <strtol+0xca>
		s += 2, base = 16;
  800fc0:	83 c1 02             	add    $0x2,%ecx
  800fc3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fc8:	eb 16                	jmp    800fe0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800fca:	85 db                	test   %ebx,%ebx
  800fcc:	75 12                	jne    800fe0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fce:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fd3:	80 39 30             	cmpb   $0x30,(%ecx)
  800fd6:	75 08                	jne    800fe0 <strtol+0x6e>
		s++, base = 8;
  800fd8:	83 c1 01             	add    $0x1,%ecx
  800fdb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fe8:	0f b6 11             	movzbl (%ecx),%edx
  800feb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fee:	89 f3                	mov    %esi,%ebx
  800ff0:	80 fb 09             	cmp    $0x9,%bl
  800ff3:	77 08                	ja     800ffd <strtol+0x8b>
			dig = *s - '0';
  800ff5:	0f be d2             	movsbl %dl,%edx
  800ff8:	83 ea 30             	sub    $0x30,%edx
  800ffb:	eb 22                	jmp    80101f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ffd:	8d 72 9f             	lea    -0x61(%edx),%esi
  801000:	89 f3                	mov    %esi,%ebx
  801002:	80 fb 19             	cmp    $0x19,%bl
  801005:	77 08                	ja     80100f <strtol+0x9d>
			dig = *s - 'a' + 10;
  801007:	0f be d2             	movsbl %dl,%edx
  80100a:	83 ea 57             	sub    $0x57,%edx
  80100d:	eb 10                	jmp    80101f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80100f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801012:	89 f3                	mov    %esi,%ebx
  801014:	80 fb 19             	cmp    $0x19,%bl
  801017:	77 16                	ja     80102f <strtol+0xbd>
			dig = *s - 'A' + 10;
  801019:	0f be d2             	movsbl %dl,%edx
  80101c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80101f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801022:	7d 0b                	jge    80102f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801024:	83 c1 01             	add    $0x1,%ecx
  801027:	0f af 45 10          	imul   0x10(%ebp),%eax
  80102b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80102d:	eb b9                	jmp    800fe8 <strtol+0x76>

	if (endptr)
  80102f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801033:	74 0d                	je     801042 <strtol+0xd0>
		*endptr = (char *) s;
  801035:	8b 75 0c             	mov    0xc(%ebp),%esi
  801038:	89 0e                	mov    %ecx,(%esi)
  80103a:	eb 06                	jmp    801042 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80103c:	85 db                	test   %ebx,%ebx
  80103e:	74 98                	je     800fd8 <strtol+0x66>
  801040:	eb 9e                	jmp    800fe0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801042:	89 c2                	mov    %eax,%edx
  801044:	f7 da                	neg    %edx
  801046:	85 ff                	test   %edi,%edi
  801048:	0f 45 c2             	cmovne %edx,%eax
}
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801056:	b8 00 00 00 00       	mov    $0x0,%eax
  80105b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105e:	8b 55 08             	mov    0x8(%ebp),%edx
  801061:	89 c3                	mov    %eax,%ebx
  801063:	89 c7                	mov    %eax,%edi
  801065:	89 c6                	mov    %eax,%esi
  801067:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801069:	5b                   	pop    %ebx
  80106a:	5e                   	pop    %esi
  80106b:	5f                   	pop    %edi
  80106c:	5d                   	pop    %ebp
  80106d:	c3                   	ret    

0080106e <sys_cgetc>:

int
sys_cgetc(void)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	57                   	push   %edi
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801074:	ba 00 00 00 00       	mov    $0x0,%edx
  801079:	b8 01 00 00 00       	mov    $0x1,%eax
  80107e:	89 d1                	mov    %edx,%ecx
  801080:	89 d3                	mov    %edx,%ebx
  801082:	89 d7                	mov    %edx,%edi
  801084:	89 d6                	mov    %edx,%esi
  801086:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5f                   	pop    %edi
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    

0080108d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	57                   	push   %edi
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
  801093:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801096:	b9 00 00 00 00       	mov    $0x0,%ecx
  80109b:	b8 03 00 00 00       	mov    $0x3,%eax
  8010a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a3:	89 cb                	mov    %ecx,%ebx
  8010a5:	89 cf                	mov    %ecx,%edi
  8010a7:	89 ce                	mov    %ecx,%esi
  8010a9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	7e 17                	jle    8010c6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010af:	83 ec 0c             	sub    $0xc,%esp
  8010b2:	50                   	push   %eax
  8010b3:	6a 03                	push   $0x3
  8010b5:	68 5f 31 80 00       	push   $0x80315f
  8010ba:	6a 23                	push   $0x23
  8010bc:	68 7c 31 80 00       	push   $0x80317c
  8010c1:	e8 e5 f5 ff ff       	call   8006ab <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c9:	5b                   	pop    %ebx
  8010ca:	5e                   	pop    %esi
  8010cb:	5f                   	pop    %edi
  8010cc:	5d                   	pop    %ebp
  8010cd:	c3                   	ret    

008010ce <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	57                   	push   %edi
  8010d2:	56                   	push   %esi
  8010d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d9:	b8 02 00 00 00       	mov    $0x2,%eax
  8010de:	89 d1                	mov    %edx,%ecx
  8010e0:	89 d3                	mov    %edx,%ebx
  8010e2:	89 d7                	mov    %edx,%edi
  8010e4:	89 d6                	mov    %edx,%esi
  8010e6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5f                   	pop    %edi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <sys_yield>:

void
sys_yield(void)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	57                   	push   %edi
  8010f1:	56                   	push   %esi
  8010f2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010fd:	89 d1                	mov    %edx,%ecx
  8010ff:	89 d3                	mov    %edx,%ebx
  801101:	89 d7                	mov    %edx,%edi
  801103:	89 d6                	mov    %edx,%esi
  801105:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801107:	5b                   	pop    %ebx
  801108:	5e                   	pop    %esi
  801109:	5f                   	pop    %edi
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    

0080110c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	57                   	push   %edi
  801110:	56                   	push   %esi
  801111:	53                   	push   %ebx
  801112:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801115:	be 00 00 00 00       	mov    $0x0,%esi
  80111a:	b8 04 00 00 00       	mov    $0x4,%eax
  80111f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801122:	8b 55 08             	mov    0x8(%ebp),%edx
  801125:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801128:	89 f7                	mov    %esi,%edi
  80112a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80112c:	85 c0                	test   %eax,%eax
  80112e:	7e 17                	jle    801147 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	50                   	push   %eax
  801134:	6a 04                	push   $0x4
  801136:	68 5f 31 80 00       	push   $0x80315f
  80113b:	6a 23                	push   $0x23
  80113d:	68 7c 31 80 00       	push   $0x80317c
  801142:	e8 64 f5 ff ff       	call   8006ab <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801147:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114a:	5b                   	pop    %ebx
  80114b:	5e                   	pop    %esi
  80114c:	5f                   	pop    %edi
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    

0080114f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	57                   	push   %edi
  801153:	56                   	push   %esi
  801154:	53                   	push   %ebx
  801155:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801158:	b8 05 00 00 00       	mov    $0x5,%eax
  80115d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801160:	8b 55 08             	mov    0x8(%ebp),%edx
  801163:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801166:	8b 7d 14             	mov    0x14(%ebp),%edi
  801169:	8b 75 18             	mov    0x18(%ebp),%esi
  80116c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80116e:	85 c0                	test   %eax,%eax
  801170:	7e 17                	jle    801189 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801172:	83 ec 0c             	sub    $0xc,%esp
  801175:	50                   	push   %eax
  801176:	6a 05                	push   $0x5
  801178:	68 5f 31 80 00       	push   $0x80315f
  80117d:	6a 23                	push   $0x23
  80117f:	68 7c 31 80 00       	push   $0x80317c
  801184:	e8 22 f5 ff ff       	call   8006ab <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801189:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118c:	5b                   	pop    %ebx
  80118d:	5e                   	pop    %esi
  80118e:	5f                   	pop    %edi
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	57                   	push   %edi
  801195:	56                   	push   %esi
  801196:	53                   	push   %ebx
  801197:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80119a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119f:	b8 06 00 00 00       	mov    $0x6,%eax
  8011a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8011aa:	89 df                	mov    %ebx,%edi
  8011ac:	89 de                	mov    %ebx,%esi
  8011ae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	7e 17                	jle    8011cb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b4:	83 ec 0c             	sub    $0xc,%esp
  8011b7:	50                   	push   %eax
  8011b8:	6a 06                	push   $0x6
  8011ba:	68 5f 31 80 00       	push   $0x80315f
  8011bf:	6a 23                	push   $0x23
  8011c1:	68 7c 31 80 00       	push   $0x80317c
  8011c6:	e8 e0 f4 ff ff       	call   8006ab <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ce:	5b                   	pop    %ebx
  8011cf:	5e                   	pop    %esi
  8011d0:	5f                   	pop    %edi
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	57                   	push   %edi
  8011d7:	56                   	push   %esi
  8011d8:	53                   	push   %ebx
  8011d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8011e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ec:	89 df                	mov    %ebx,%edi
  8011ee:	89 de                	mov    %ebx,%esi
  8011f0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	7e 17                	jle    80120d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f6:	83 ec 0c             	sub    $0xc,%esp
  8011f9:	50                   	push   %eax
  8011fa:	6a 08                	push   $0x8
  8011fc:	68 5f 31 80 00       	push   $0x80315f
  801201:	6a 23                	push   $0x23
  801203:	68 7c 31 80 00       	push   $0x80317c
  801208:	e8 9e f4 ff ff       	call   8006ab <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80120d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5f                   	pop    %edi
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	57                   	push   %edi
  801219:	56                   	push   %esi
  80121a:	53                   	push   %ebx
  80121b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80121e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801223:	b8 09 00 00 00       	mov    $0x9,%eax
  801228:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122b:	8b 55 08             	mov    0x8(%ebp),%edx
  80122e:	89 df                	mov    %ebx,%edi
  801230:	89 de                	mov    %ebx,%esi
  801232:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801234:	85 c0                	test   %eax,%eax
  801236:	7e 17                	jle    80124f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801238:	83 ec 0c             	sub    $0xc,%esp
  80123b:	50                   	push   %eax
  80123c:	6a 09                	push   $0x9
  80123e:	68 5f 31 80 00       	push   $0x80315f
  801243:	6a 23                	push   $0x23
  801245:	68 7c 31 80 00       	push   $0x80317c
  80124a:	e8 5c f4 ff ff       	call   8006ab <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80124f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801252:	5b                   	pop    %ebx
  801253:	5e                   	pop    %esi
  801254:	5f                   	pop    %edi
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	57                   	push   %edi
  80125b:	56                   	push   %esi
  80125c:	53                   	push   %ebx
  80125d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801260:	bb 00 00 00 00       	mov    $0x0,%ebx
  801265:	b8 0a 00 00 00       	mov    $0xa,%eax
  80126a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126d:	8b 55 08             	mov    0x8(%ebp),%edx
  801270:	89 df                	mov    %ebx,%edi
  801272:	89 de                	mov    %ebx,%esi
  801274:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801276:	85 c0                	test   %eax,%eax
  801278:	7e 17                	jle    801291 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80127a:	83 ec 0c             	sub    $0xc,%esp
  80127d:	50                   	push   %eax
  80127e:	6a 0a                	push   $0xa
  801280:	68 5f 31 80 00       	push   $0x80315f
  801285:	6a 23                	push   $0x23
  801287:	68 7c 31 80 00       	push   $0x80317c
  80128c:	e8 1a f4 ff ff       	call   8006ab <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801291:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801294:	5b                   	pop    %ebx
  801295:	5e                   	pop    %esi
  801296:	5f                   	pop    %edi
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	57                   	push   %edi
  80129d:	56                   	push   %esi
  80129e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80129f:	be 00 00 00 00       	mov    $0x0,%esi
  8012a4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8012af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012b5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012b7:	5b                   	pop    %ebx
  8012b8:	5e                   	pop    %esi
  8012b9:	5f                   	pop    %edi
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    

008012bc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	57                   	push   %edi
  8012c0:	56                   	push   %esi
  8012c1:	53                   	push   %ebx
  8012c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012ca:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d2:	89 cb                	mov    %ecx,%ebx
  8012d4:	89 cf                	mov    %ecx,%edi
  8012d6:	89 ce                	mov    %ecx,%esi
  8012d8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	7e 17                	jle    8012f5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012de:	83 ec 0c             	sub    $0xc,%esp
  8012e1:	50                   	push   %eax
  8012e2:	6a 0d                	push   $0xd
  8012e4:	68 5f 31 80 00       	push   $0x80315f
  8012e9:	6a 23                	push   $0x23
  8012eb:	68 7c 31 80 00       	push   $0x80317c
  8012f0:	e8 b6 f3 ff ff       	call   8006ab <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f8:	5b                   	pop    %ebx
  8012f9:	5e                   	pop    %esi
  8012fa:	5f                   	pop    %edi
  8012fb:	5d                   	pop    %ebp
  8012fc:	c3                   	ret    

008012fd <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	57                   	push   %edi
  801301:	56                   	push   %esi
  801302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801303:	b9 00 00 00 00       	mov    $0x0,%ecx
  801308:	b8 0e 00 00 00       	mov    $0xe,%eax
  80130d:	8b 55 08             	mov    0x8(%ebp),%edx
  801310:	89 cb                	mov    %ecx,%ebx
  801312:	89 cf                	mov    %ecx,%edi
  801314:	89 ce                	mov    %ecx,%esi
  801316:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  801318:	5b                   	pop    %ebx
  801319:	5e                   	pop    %esi
  80131a:	5f                   	pop    %edi
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	57                   	push   %edi
  801321:	56                   	push   %esi
  801322:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801323:	b9 00 00 00 00       	mov    $0x0,%ecx
  801328:	b8 0f 00 00 00       	mov    $0xf,%eax
  80132d:	8b 55 08             	mov    0x8(%ebp),%edx
  801330:	89 cb                	mov    %ecx,%ebx
  801332:	89 cf                	mov    %ecx,%edi
  801334:	89 ce                	mov    %ecx,%esi
  801336:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  801338:	5b                   	pop    %ebx
  801339:	5e                   	pop    %esi
  80133a:	5f                   	pop    %edi
  80133b:	5d                   	pop    %ebp
  80133c:	c3                   	ret    

0080133d <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	57                   	push   %edi
  801341:	56                   	push   %esi
  801342:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801343:	b9 00 00 00 00       	mov    $0x0,%ecx
  801348:	b8 10 00 00 00       	mov    $0x10,%eax
  80134d:	8b 55 08             	mov    0x8(%ebp),%edx
  801350:	89 cb                	mov    %ecx,%ebx
  801352:	89 cf                	mov    %ecx,%edi
  801354:	89 ce                	mov    %ecx,%esi
  801356:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  801358:	5b                   	pop    %ebx
  801359:	5e                   	pop    %esi
  80135a:	5f                   	pop    %edi
  80135b:	5d                   	pop    %ebp
  80135c:	c3                   	ret    

0080135d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	53                   	push   %ebx
  801361:	83 ec 04             	sub    $0x4,%esp
  801364:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801367:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  801369:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80136d:	74 11                	je     801380 <pgfault+0x23>
  80136f:	89 d8                	mov    %ebx,%eax
  801371:	c1 e8 0c             	shr    $0xc,%eax
  801374:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80137b:	f6 c4 08             	test   $0x8,%ah
  80137e:	75 14                	jne    801394 <pgfault+0x37>
		panic("faulting access");
  801380:	83 ec 04             	sub    $0x4,%esp
  801383:	68 8a 31 80 00       	push   $0x80318a
  801388:	6a 1f                	push   $0x1f
  80138a:	68 9a 31 80 00       	push   $0x80319a
  80138f:	e8 17 f3 ff ff       	call   8006ab <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  801394:	83 ec 04             	sub    $0x4,%esp
  801397:	6a 07                	push   $0x7
  801399:	68 00 f0 7f 00       	push   $0x7ff000
  80139e:	6a 00                	push   $0x0
  8013a0:	e8 67 fd ff ff       	call   80110c <sys_page_alloc>
	if (r < 0) {
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	79 12                	jns    8013be <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  8013ac:	50                   	push   %eax
  8013ad:	68 a5 31 80 00       	push   $0x8031a5
  8013b2:	6a 2d                	push   $0x2d
  8013b4:	68 9a 31 80 00       	push   $0x80319a
  8013b9:	e8 ed f2 ff ff       	call   8006ab <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  8013be:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  8013c4:	83 ec 04             	sub    $0x4,%esp
  8013c7:	68 00 10 00 00       	push   $0x1000
  8013cc:	53                   	push   %ebx
  8013cd:	68 00 f0 7f 00       	push   $0x7ff000
  8013d2:	e8 2c fb ff ff       	call   800f03 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  8013d7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8013de:	53                   	push   %ebx
  8013df:	6a 00                	push   $0x0
  8013e1:	68 00 f0 7f 00       	push   $0x7ff000
  8013e6:	6a 00                	push   $0x0
  8013e8:	e8 62 fd ff ff       	call   80114f <sys_page_map>
	if (r < 0) {
  8013ed:	83 c4 20             	add    $0x20,%esp
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	79 12                	jns    801406 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  8013f4:	50                   	push   %eax
  8013f5:	68 a5 31 80 00       	push   $0x8031a5
  8013fa:	6a 34                	push   $0x34
  8013fc:	68 9a 31 80 00       	push   $0x80319a
  801401:	e8 a5 f2 ff ff       	call   8006ab <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  801406:	83 ec 08             	sub    $0x8,%esp
  801409:	68 00 f0 7f 00       	push   $0x7ff000
  80140e:	6a 00                	push   $0x0
  801410:	e8 7c fd ff ff       	call   801191 <sys_page_unmap>
	if (r < 0) {
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	85 c0                	test   %eax,%eax
  80141a:	79 12                	jns    80142e <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80141c:	50                   	push   %eax
  80141d:	68 a5 31 80 00       	push   $0x8031a5
  801422:	6a 38                	push   $0x38
  801424:	68 9a 31 80 00       	push   $0x80319a
  801429:	e8 7d f2 ff ff       	call   8006ab <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80142e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801431:	c9                   	leave  
  801432:	c3                   	ret    

00801433 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	57                   	push   %edi
  801437:	56                   	push   %esi
  801438:	53                   	push   %ebx
  801439:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80143c:	68 5d 13 80 00       	push   $0x80135d
  801441:	e8 b4 12 00 00       	call   8026fa <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801446:	b8 07 00 00 00       	mov    $0x7,%eax
  80144b:	cd 30                	int    $0x30
  80144d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	79 17                	jns    80146e <fork+0x3b>
		panic("fork fault %e");
  801457:	83 ec 04             	sub    $0x4,%esp
  80145a:	68 be 31 80 00       	push   $0x8031be
  80145f:	68 85 00 00 00       	push   $0x85
  801464:	68 9a 31 80 00       	push   $0x80319a
  801469:	e8 3d f2 ff ff       	call   8006ab <_panic>
  80146e:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801470:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801474:	75 24                	jne    80149a <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  801476:	e8 53 fc ff ff       	call   8010ce <sys_getenvid>
  80147b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801480:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801486:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80148b:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  801490:	b8 00 00 00 00       	mov    $0x0,%eax
  801495:	e9 64 01 00 00       	jmp    8015fe <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80149a:	83 ec 04             	sub    $0x4,%esp
  80149d:	6a 07                	push   $0x7
  80149f:	68 00 f0 bf ee       	push   $0xeebff000
  8014a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014a7:	e8 60 fc ff ff       	call   80110c <sys_page_alloc>
  8014ac:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8014af:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8014b4:	89 d8                	mov    %ebx,%eax
  8014b6:	c1 e8 16             	shr    $0x16,%eax
  8014b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014c0:	a8 01                	test   $0x1,%al
  8014c2:	0f 84 fc 00 00 00    	je     8015c4 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  8014c8:	89 d8                	mov    %ebx,%eax
  8014ca:	c1 e8 0c             	shr    $0xc,%eax
  8014cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8014d4:	f6 c2 01             	test   $0x1,%dl
  8014d7:	0f 84 e7 00 00 00    	je     8015c4 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  8014dd:	89 c6                	mov    %eax,%esi
  8014df:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  8014e2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014e9:	f6 c6 04             	test   $0x4,%dh
  8014ec:	74 39                	je     801527 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8014ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f5:	83 ec 0c             	sub    $0xc,%esp
  8014f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8014fd:	50                   	push   %eax
  8014fe:	56                   	push   %esi
  8014ff:	57                   	push   %edi
  801500:	56                   	push   %esi
  801501:	6a 00                	push   $0x0
  801503:	e8 47 fc ff ff       	call   80114f <sys_page_map>
		if (r < 0) {
  801508:	83 c4 20             	add    $0x20,%esp
  80150b:	85 c0                	test   %eax,%eax
  80150d:	0f 89 b1 00 00 00    	jns    8015c4 <fork+0x191>
		    	panic("sys page map fault %e");
  801513:	83 ec 04             	sub    $0x4,%esp
  801516:	68 cc 31 80 00       	push   $0x8031cc
  80151b:	6a 55                	push   $0x55
  80151d:	68 9a 31 80 00       	push   $0x80319a
  801522:	e8 84 f1 ff ff       	call   8006ab <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801527:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80152e:	f6 c2 02             	test   $0x2,%dl
  801531:	75 0c                	jne    80153f <fork+0x10c>
  801533:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80153a:	f6 c4 08             	test   $0x8,%ah
  80153d:	74 5b                	je     80159a <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80153f:	83 ec 0c             	sub    $0xc,%esp
  801542:	68 05 08 00 00       	push   $0x805
  801547:	56                   	push   %esi
  801548:	57                   	push   %edi
  801549:	56                   	push   %esi
  80154a:	6a 00                	push   $0x0
  80154c:	e8 fe fb ff ff       	call   80114f <sys_page_map>
		if (r < 0) {
  801551:	83 c4 20             	add    $0x20,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	79 14                	jns    80156c <fork+0x139>
		    	panic("sys page map fault %e");
  801558:	83 ec 04             	sub    $0x4,%esp
  80155b:	68 cc 31 80 00       	push   $0x8031cc
  801560:	6a 5c                	push   $0x5c
  801562:	68 9a 31 80 00       	push   $0x80319a
  801567:	e8 3f f1 ff ff       	call   8006ab <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80156c:	83 ec 0c             	sub    $0xc,%esp
  80156f:	68 05 08 00 00       	push   $0x805
  801574:	56                   	push   %esi
  801575:	6a 00                	push   $0x0
  801577:	56                   	push   %esi
  801578:	6a 00                	push   $0x0
  80157a:	e8 d0 fb ff ff       	call   80114f <sys_page_map>
		if (r < 0) {
  80157f:	83 c4 20             	add    $0x20,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	79 3e                	jns    8015c4 <fork+0x191>
		    	panic("sys page map fault %e");
  801586:	83 ec 04             	sub    $0x4,%esp
  801589:	68 cc 31 80 00       	push   $0x8031cc
  80158e:	6a 60                	push   $0x60
  801590:	68 9a 31 80 00       	push   $0x80319a
  801595:	e8 11 f1 ff ff       	call   8006ab <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80159a:	83 ec 0c             	sub    $0xc,%esp
  80159d:	6a 05                	push   $0x5
  80159f:	56                   	push   %esi
  8015a0:	57                   	push   %edi
  8015a1:	56                   	push   %esi
  8015a2:	6a 00                	push   $0x0
  8015a4:	e8 a6 fb ff ff       	call   80114f <sys_page_map>
		if (r < 0) {
  8015a9:	83 c4 20             	add    $0x20,%esp
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	79 14                	jns    8015c4 <fork+0x191>
		    	panic("sys page map fault %e");
  8015b0:	83 ec 04             	sub    $0x4,%esp
  8015b3:	68 cc 31 80 00       	push   $0x8031cc
  8015b8:	6a 65                	push   $0x65
  8015ba:	68 9a 31 80 00       	push   $0x80319a
  8015bf:	e8 e7 f0 ff ff       	call   8006ab <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8015c4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8015ca:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8015d0:	0f 85 de fe ff ff    	jne    8014b4 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8015d6:	a1 04 50 80 00       	mov    0x805004,%eax
  8015db:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  8015e1:	83 ec 08             	sub    $0x8,%esp
  8015e4:	50                   	push   %eax
  8015e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015e8:	57                   	push   %edi
  8015e9:	e8 69 fc ff ff       	call   801257 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8015ee:	83 c4 08             	add    $0x8,%esp
  8015f1:	6a 02                	push   $0x2
  8015f3:	57                   	push   %edi
  8015f4:	e8 da fb ff ff       	call   8011d3 <sys_env_set_status>
	
	return envid;
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8015fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801601:	5b                   	pop    %ebx
  801602:	5e                   	pop    %esi
  801603:	5f                   	pop    %edi
  801604:	5d                   	pop    %ebp
  801605:	c3                   	ret    

00801606 <sfork>:

envid_t
sfork(void)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801609:	b8 00 00 00 00       	mov    $0x0,%eax
  80160e:	5d                   	pop    %ebp
  80160f:	c3                   	ret    

00801610 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	56                   	push   %esi
  801614:	53                   	push   %ebx
  801615:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801618:	89 1d 08 50 80 00    	mov    %ebx,0x805008
	cprintf("in fork.c thread create. func: %x\n", func);
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	53                   	push   %ebx
  801622:	68 5c 32 80 00       	push   $0x80325c
  801627:	e8 58 f1 ff ff       	call   800784 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80162c:	c7 04 24 71 06 80 00 	movl   $0x800671,(%esp)
  801633:	e8 c5 fc ff ff       	call   8012fd <sys_thread_create>
  801638:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80163a:	83 c4 08             	add    $0x8,%esp
  80163d:	53                   	push   %ebx
  80163e:	68 5c 32 80 00       	push   $0x80325c
  801643:	e8 3c f1 ff ff       	call   800784 <cprintf>
	return id;
}
  801648:	89 f0                	mov    %esi,%eax
  80164a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164d:	5b                   	pop    %ebx
  80164e:	5e                   	pop    %esi
  80164f:	5d                   	pop    %ebp
  801650:	c3                   	ret    

00801651 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  801657:	ff 75 08             	pushl  0x8(%ebp)
  80165a:	e8 be fc ff ff       	call   80131d <sys_thread_free>
}
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	c9                   	leave  
  801663:	c3                   	ret    

00801664 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  80166a:	ff 75 08             	pushl  0x8(%ebp)
  80166d:	e8 cb fc ff ff       	call   80133d <sys_thread_join>
}
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	56                   	push   %esi
  80167b:	53                   	push   %ebx
  80167c:	8b 75 08             	mov    0x8(%ebp),%esi
  80167f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801682:	83 ec 04             	sub    $0x4,%esp
  801685:	6a 07                	push   $0x7
  801687:	6a 00                	push   $0x0
  801689:	56                   	push   %esi
  80168a:	e8 7d fa ff ff       	call   80110c <sys_page_alloc>
	if (r < 0) {
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	79 15                	jns    8016ab <queue_append+0x34>
		panic("%e\n", r);
  801696:	50                   	push   %eax
  801697:	68 58 32 80 00       	push   $0x803258
  80169c:	68 c4 00 00 00       	push   $0xc4
  8016a1:	68 9a 31 80 00       	push   $0x80319a
  8016a6:	e8 00 f0 ff ff       	call   8006ab <_panic>
	}	
	wt->envid = envid;
  8016ab:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  8016b1:	83 ec 04             	sub    $0x4,%esp
  8016b4:	ff 33                	pushl  (%ebx)
  8016b6:	56                   	push   %esi
  8016b7:	68 80 32 80 00       	push   $0x803280
  8016bc:	e8 c3 f0 ff ff       	call   800784 <cprintf>
	if (queue->first == NULL) {
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	83 3b 00             	cmpl   $0x0,(%ebx)
  8016c7:	75 29                	jne    8016f2 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  8016c9:	83 ec 0c             	sub    $0xc,%esp
  8016cc:	68 e2 31 80 00       	push   $0x8031e2
  8016d1:	e8 ae f0 ff ff       	call   800784 <cprintf>
		queue->first = wt;
  8016d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  8016dc:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8016e3:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8016ea:	00 00 00 
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	eb 2b                	jmp    80171d <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  8016f2:	83 ec 0c             	sub    $0xc,%esp
  8016f5:	68 fc 31 80 00       	push   $0x8031fc
  8016fa:	e8 85 f0 ff ff       	call   800784 <cprintf>
		queue->last->next = wt;
  8016ff:	8b 43 04             	mov    0x4(%ebx),%eax
  801702:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801709:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801710:	00 00 00 
		queue->last = wt;
  801713:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  80171a:	83 c4 10             	add    $0x10,%esp
	}
}
  80171d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801720:	5b                   	pop    %ebx
  801721:	5e                   	pop    %esi
  801722:	5d                   	pop    %ebp
  801723:	c3                   	ret    

00801724 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	53                   	push   %ebx
  801728:	83 ec 04             	sub    $0x4,%esp
  80172b:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  80172e:	8b 02                	mov    (%edx),%eax
  801730:	85 c0                	test   %eax,%eax
  801732:	75 17                	jne    80174b <queue_pop+0x27>
		panic("queue empty!\n");
  801734:	83 ec 04             	sub    $0x4,%esp
  801737:	68 1a 32 80 00       	push   $0x80321a
  80173c:	68 d8 00 00 00       	push   $0xd8
  801741:	68 9a 31 80 00       	push   $0x80319a
  801746:	e8 60 ef ff ff       	call   8006ab <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80174b:	8b 48 04             	mov    0x4(%eax),%ecx
  80174e:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  801750:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801752:	83 ec 08             	sub    $0x8,%esp
  801755:	53                   	push   %ebx
  801756:	68 28 32 80 00       	push   $0x803228
  80175b:	e8 24 f0 ff ff       	call   800784 <cprintf>
	return envid;
}
  801760:	89 d8                	mov    %ebx,%eax
  801762:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801765:	c9                   	leave  
  801766:	c3                   	ret    

00801767 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	53                   	push   %ebx
  80176b:	83 ec 04             	sub    $0x4,%esp
  80176e:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801771:	b8 01 00 00 00       	mov    $0x1,%eax
  801776:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801779:	85 c0                	test   %eax,%eax
  80177b:	74 5a                	je     8017d7 <mutex_lock+0x70>
  80177d:	8b 43 04             	mov    0x4(%ebx),%eax
  801780:	83 38 00             	cmpl   $0x0,(%eax)
  801783:	75 52                	jne    8017d7 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801785:	83 ec 0c             	sub    $0xc,%esp
  801788:	68 a8 32 80 00       	push   $0x8032a8
  80178d:	e8 f2 ef ff ff       	call   800784 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801792:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801795:	e8 34 f9 ff ff       	call   8010ce <sys_getenvid>
  80179a:	83 c4 08             	add    $0x8,%esp
  80179d:	53                   	push   %ebx
  80179e:	50                   	push   %eax
  80179f:	e8 d3 fe ff ff       	call   801677 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8017a4:	e8 25 f9 ff ff       	call   8010ce <sys_getenvid>
  8017a9:	83 c4 08             	add    $0x8,%esp
  8017ac:	6a 04                	push   $0x4
  8017ae:	50                   	push   %eax
  8017af:	e8 1f fa ff ff       	call   8011d3 <sys_env_set_status>
		if (r < 0) {
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	79 15                	jns    8017d0 <mutex_lock+0x69>
			panic("%e\n", r);
  8017bb:	50                   	push   %eax
  8017bc:	68 58 32 80 00       	push   $0x803258
  8017c1:	68 eb 00 00 00       	push   $0xeb
  8017c6:	68 9a 31 80 00       	push   $0x80319a
  8017cb:	e8 db ee ff ff       	call   8006ab <_panic>
		}
		sys_yield();
  8017d0:	e8 18 f9 ff ff       	call   8010ed <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8017d5:	eb 18                	jmp    8017ef <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  8017d7:	83 ec 0c             	sub    $0xc,%esp
  8017da:	68 c8 32 80 00       	push   $0x8032c8
  8017df:	e8 a0 ef ff ff       	call   800784 <cprintf>
	mtx->owner = sys_getenvid();}
  8017e4:	e8 e5 f8 ff ff       	call   8010ce <sys_getenvid>
  8017e9:	89 43 08             	mov    %eax,0x8(%ebx)
  8017ec:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  8017ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f2:	c9                   	leave  
  8017f3:	c3                   	ret    

008017f4 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	53                   	push   %ebx
  8017f8:	83 ec 04             	sub    $0x4,%esp
  8017fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8017fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801803:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801806:	8b 43 04             	mov    0x4(%ebx),%eax
  801809:	83 38 00             	cmpl   $0x0,(%eax)
  80180c:	74 33                	je     801841 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80180e:	83 ec 0c             	sub    $0xc,%esp
  801811:	50                   	push   %eax
  801812:	e8 0d ff ff ff       	call   801724 <queue_pop>
  801817:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80181a:	83 c4 08             	add    $0x8,%esp
  80181d:	6a 02                	push   $0x2
  80181f:	50                   	push   %eax
  801820:	e8 ae f9 ff ff       	call   8011d3 <sys_env_set_status>
		if (r < 0) {
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	85 c0                	test   %eax,%eax
  80182a:	79 15                	jns    801841 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80182c:	50                   	push   %eax
  80182d:	68 58 32 80 00       	push   $0x803258
  801832:	68 00 01 00 00       	push   $0x100
  801837:	68 9a 31 80 00       	push   $0x80319a
  80183c:	e8 6a ee ff ff       	call   8006ab <_panic>
		}
	}

	asm volatile("pause");
  801841:	f3 90                	pause  
	//sys_yield();
}
  801843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801846:	c9                   	leave  
  801847:	c3                   	ret    

00801848 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	53                   	push   %ebx
  80184c:	83 ec 04             	sub    $0x4,%esp
  80184f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801852:	e8 77 f8 ff ff       	call   8010ce <sys_getenvid>
  801857:	83 ec 04             	sub    $0x4,%esp
  80185a:	6a 07                	push   $0x7
  80185c:	53                   	push   %ebx
  80185d:	50                   	push   %eax
  80185e:	e8 a9 f8 ff ff       	call   80110c <sys_page_alloc>
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	85 c0                	test   %eax,%eax
  801868:	79 15                	jns    80187f <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80186a:	50                   	push   %eax
  80186b:	68 43 32 80 00       	push   $0x803243
  801870:	68 0d 01 00 00       	push   $0x10d
  801875:	68 9a 31 80 00       	push   $0x80319a
  80187a:	e8 2c ee ff ff       	call   8006ab <_panic>
	}	
	mtx->locked = 0;
  80187f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801885:	8b 43 04             	mov    0x4(%ebx),%eax
  801888:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80188e:	8b 43 04             	mov    0x4(%ebx),%eax
  801891:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801898:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80189f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a2:	c9                   	leave  
  8018a3:	c3                   	ret    

008018a4 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  8018aa:	e8 1f f8 ff ff       	call   8010ce <sys_getenvid>
  8018af:	83 ec 08             	sub    $0x8,%esp
  8018b2:	ff 75 08             	pushl  0x8(%ebp)
  8018b5:	50                   	push   %eax
  8018b6:	e8 d6 f8 ff ff       	call   801191 <sys_page_unmap>
	if (r < 0) {
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	79 15                	jns    8018d7 <mutex_destroy+0x33>
		panic("%e\n", r);
  8018c2:	50                   	push   %eax
  8018c3:	68 58 32 80 00       	push   $0x803258
  8018c8:	68 1a 01 00 00       	push   $0x11a
  8018cd:	68 9a 31 80 00       	push   $0x80319a
  8018d2:	e8 d4 ed ff ff       	call   8006ab <_panic>
	}
}
  8018d7:	c9                   	leave  
  8018d8:	c3                   	ret    

008018d9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	56                   	push   %esi
  8018dd:	53                   	push   %ebx
  8018de:	8b 75 08             	mov    0x8(%ebp),%esi
  8018e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	75 12                	jne    8018fd <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8018eb:	83 ec 0c             	sub    $0xc,%esp
  8018ee:	68 00 00 c0 ee       	push   $0xeec00000
  8018f3:	e8 c4 f9 ff ff       	call   8012bc <sys_ipc_recv>
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	eb 0c                	jmp    801909 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8018fd:	83 ec 0c             	sub    $0xc,%esp
  801900:	50                   	push   %eax
  801901:	e8 b6 f9 ff ff       	call   8012bc <sys_ipc_recv>
  801906:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801909:	85 f6                	test   %esi,%esi
  80190b:	0f 95 c1             	setne  %cl
  80190e:	85 db                	test   %ebx,%ebx
  801910:	0f 95 c2             	setne  %dl
  801913:	84 d1                	test   %dl,%cl
  801915:	74 09                	je     801920 <ipc_recv+0x47>
  801917:	89 c2                	mov    %eax,%edx
  801919:	c1 ea 1f             	shr    $0x1f,%edx
  80191c:	84 d2                	test   %dl,%dl
  80191e:	75 2d                	jne    80194d <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801920:	85 f6                	test   %esi,%esi
  801922:	74 0d                	je     801931 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801924:	a1 04 50 80 00       	mov    0x805004,%eax
  801929:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80192f:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801931:	85 db                	test   %ebx,%ebx
  801933:	74 0d                	je     801942 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801935:	a1 04 50 80 00       	mov    0x805004,%eax
  80193a:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801940:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801942:	a1 04 50 80 00       	mov    0x805004,%eax
  801947:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  80194d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801950:	5b                   	pop    %ebx
  801951:	5e                   	pop    %esi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	57                   	push   %edi
  801958:	56                   	push   %esi
  801959:	53                   	push   %ebx
  80195a:	83 ec 0c             	sub    $0xc,%esp
  80195d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801960:	8b 75 0c             	mov    0xc(%ebp),%esi
  801963:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801966:	85 db                	test   %ebx,%ebx
  801968:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80196d:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801970:	ff 75 14             	pushl  0x14(%ebp)
  801973:	53                   	push   %ebx
  801974:	56                   	push   %esi
  801975:	57                   	push   %edi
  801976:	e8 1e f9 ff ff       	call   801299 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80197b:	89 c2                	mov    %eax,%edx
  80197d:	c1 ea 1f             	shr    $0x1f,%edx
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	84 d2                	test   %dl,%dl
  801985:	74 17                	je     80199e <ipc_send+0x4a>
  801987:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80198a:	74 12                	je     80199e <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80198c:	50                   	push   %eax
  80198d:	68 e8 32 80 00       	push   $0x8032e8
  801992:	6a 47                	push   $0x47
  801994:	68 f6 32 80 00       	push   $0x8032f6
  801999:	e8 0d ed ff ff       	call   8006ab <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80199e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8019a1:	75 07                	jne    8019aa <ipc_send+0x56>
			sys_yield();
  8019a3:	e8 45 f7 ff ff       	call   8010ed <sys_yield>
  8019a8:	eb c6                	jmp    801970 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	75 c2                	jne    801970 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8019ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b1:	5b                   	pop    %ebx
  8019b2:	5e                   	pop    %esi
  8019b3:	5f                   	pop    %edi
  8019b4:	5d                   	pop    %ebp
  8019b5:	c3                   	ret    

008019b6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8019bc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8019c1:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8019c7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8019cd:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  8019d3:	39 ca                	cmp    %ecx,%edx
  8019d5:	75 13                	jne    8019ea <ipc_find_env+0x34>
			return envs[i].env_id;
  8019d7:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8019dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8019e2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8019e8:	eb 0f                	jmp    8019f9 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8019ea:	83 c0 01             	add    $0x1,%eax
  8019ed:	3d 00 04 00 00       	cmp    $0x400,%eax
  8019f2:	75 cd                	jne    8019c1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8019f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019f9:	5d                   	pop    %ebp
  8019fa:	c3                   	ret    

008019fb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	05 00 00 00 30       	add    $0x30000000,%eax
  801a06:	c1 e8 0c             	shr    $0xc,%eax
}
  801a09:	5d                   	pop    %ebp
  801a0a:	c3                   	ret    

00801a0b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a11:	05 00 00 00 30       	add    $0x30000000,%eax
  801a16:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801a1b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801a20:	5d                   	pop    %ebp
  801a21:	c3                   	ret    

00801a22 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a28:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801a2d:	89 c2                	mov    %eax,%edx
  801a2f:	c1 ea 16             	shr    $0x16,%edx
  801a32:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801a39:	f6 c2 01             	test   $0x1,%dl
  801a3c:	74 11                	je     801a4f <fd_alloc+0x2d>
  801a3e:	89 c2                	mov    %eax,%edx
  801a40:	c1 ea 0c             	shr    $0xc,%edx
  801a43:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a4a:	f6 c2 01             	test   $0x1,%dl
  801a4d:	75 09                	jne    801a58 <fd_alloc+0x36>
			*fd_store = fd;
  801a4f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801a51:	b8 00 00 00 00       	mov    $0x0,%eax
  801a56:	eb 17                	jmp    801a6f <fd_alloc+0x4d>
  801a58:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801a5d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801a62:	75 c9                	jne    801a2d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801a64:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801a6a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801a6f:	5d                   	pop    %ebp
  801a70:	c3                   	ret    

00801a71 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801a77:	83 f8 1f             	cmp    $0x1f,%eax
  801a7a:	77 36                	ja     801ab2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801a7c:	c1 e0 0c             	shl    $0xc,%eax
  801a7f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801a84:	89 c2                	mov    %eax,%edx
  801a86:	c1 ea 16             	shr    $0x16,%edx
  801a89:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801a90:	f6 c2 01             	test   $0x1,%dl
  801a93:	74 24                	je     801ab9 <fd_lookup+0x48>
  801a95:	89 c2                	mov    %eax,%edx
  801a97:	c1 ea 0c             	shr    $0xc,%edx
  801a9a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801aa1:	f6 c2 01             	test   $0x1,%dl
  801aa4:	74 1a                	je     801ac0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801aa6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aa9:	89 02                	mov    %eax,(%edx)
	return 0;
  801aab:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab0:	eb 13                	jmp    801ac5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801ab2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ab7:	eb 0c                	jmp    801ac5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801ab9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801abe:	eb 05                	jmp    801ac5 <fd_lookup+0x54>
  801ac0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801ac5:	5d                   	pop    %ebp
  801ac6:	c3                   	ret    

00801ac7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	83 ec 08             	sub    $0x8,%esp
  801acd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ad0:	ba 80 33 80 00       	mov    $0x803380,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801ad5:	eb 13                	jmp    801aea <dev_lookup+0x23>
  801ad7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801ada:	39 08                	cmp    %ecx,(%eax)
  801adc:	75 0c                	jne    801aea <dev_lookup+0x23>
			*dev = devtab[i];
  801ade:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae1:	89 01                	mov    %eax,(%ecx)
			return 0;
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae8:	eb 31                	jmp    801b1b <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801aea:	8b 02                	mov    (%edx),%eax
  801aec:	85 c0                	test   %eax,%eax
  801aee:	75 e7                	jne    801ad7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801af0:	a1 04 50 80 00       	mov    0x805004,%eax
  801af5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801afb:	83 ec 04             	sub    $0x4,%esp
  801afe:	51                   	push   %ecx
  801aff:	50                   	push   %eax
  801b00:	68 00 33 80 00       	push   $0x803300
  801b05:	e8 7a ec ff ff       	call   800784 <cprintf>
	*dev = 0;
  801b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801b1b:	c9                   	leave  
  801b1c:	c3                   	ret    

00801b1d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	56                   	push   %esi
  801b21:	53                   	push   %ebx
  801b22:	83 ec 10             	sub    $0x10,%esp
  801b25:	8b 75 08             	mov    0x8(%ebp),%esi
  801b28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801b2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2e:	50                   	push   %eax
  801b2f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801b35:	c1 e8 0c             	shr    $0xc,%eax
  801b38:	50                   	push   %eax
  801b39:	e8 33 ff ff ff       	call   801a71 <fd_lookup>
  801b3e:	83 c4 08             	add    $0x8,%esp
  801b41:	85 c0                	test   %eax,%eax
  801b43:	78 05                	js     801b4a <fd_close+0x2d>
	    || fd != fd2)
  801b45:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801b48:	74 0c                	je     801b56 <fd_close+0x39>
		return (must_exist ? r : 0);
  801b4a:	84 db                	test   %bl,%bl
  801b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b51:	0f 44 c2             	cmove  %edx,%eax
  801b54:	eb 41                	jmp    801b97 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801b56:	83 ec 08             	sub    $0x8,%esp
  801b59:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b5c:	50                   	push   %eax
  801b5d:	ff 36                	pushl  (%esi)
  801b5f:	e8 63 ff ff ff       	call   801ac7 <dev_lookup>
  801b64:	89 c3                	mov    %eax,%ebx
  801b66:	83 c4 10             	add    $0x10,%esp
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 1a                	js     801b87 <fd_close+0x6a>
		if (dev->dev_close)
  801b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b70:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801b73:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	74 0b                	je     801b87 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801b7c:	83 ec 0c             	sub    $0xc,%esp
  801b7f:	56                   	push   %esi
  801b80:	ff d0                	call   *%eax
  801b82:	89 c3                	mov    %eax,%ebx
  801b84:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801b87:	83 ec 08             	sub    $0x8,%esp
  801b8a:	56                   	push   %esi
  801b8b:	6a 00                	push   $0x0
  801b8d:	e8 ff f5 ff ff       	call   801191 <sys_page_unmap>
	return r;
  801b92:	83 c4 10             	add    $0x10,%esp
  801b95:	89 d8                	mov    %ebx,%eax
}
  801b97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9a:	5b                   	pop    %ebx
  801b9b:	5e                   	pop    %esi
  801b9c:	5d                   	pop    %ebp
  801b9d:	c3                   	ret    

00801b9e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ba4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba7:	50                   	push   %eax
  801ba8:	ff 75 08             	pushl  0x8(%ebp)
  801bab:	e8 c1 fe ff ff       	call   801a71 <fd_lookup>
  801bb0:	83 c4 08             	add    $0x8,%esp
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	78 10                	js     801bc7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801bb7:	83 ec 08             	sub    $0x8,%esp
  801bba:	6a 01                	push   $0x1
  801bbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbf:	e8 59 ff ff ff       	call   801b1d <fd_close>
  801bc4:	83 c4 10             	add    $0x10,%esp
}
  801bc7:	c9                   	leave  
  801bc8:	c3                   	ret    

00801bc9 <close_all>:

void
close_all(void)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	53                   	push   %ebx
  801bcd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801bd0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801bd5:	83 ec 0c             	sub    $0xc,%esp
  801bd8:	53                   	push   %ebx
  801bd9:	e8 c0 ff ff ff       	call   801b9e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801bde:	83 c3 01             	add    $0x1,%ebx
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	83 fb 20             	cmp    $0x20,%ebx
  801be7:	75 ec                	jne    801bd5 <close_all+0xc>
		close(i);
}
  801be9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bec:	c9                   	leave  
  801bed:	c3                   	ret    

00801bee <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 2c             	sub    $0x2c,%esp
  801bf7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801bfa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bfd:	50                   	push   %eax
  801bfe:	ff 75 08             	pushl  0x8(%ebp)
  801c01:	e8 6b fe ff ff       	call   801a71 <fd_lookup>
  801c06:	83 c4 08             	add    $0x8,%esp
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	0f 88 c1 00 00 00    	js     801cd2 <dup+0xe4>
		return r;
	close(newfdnum);
  801c11:	83 ec 0c             	sub    $0xc,%esp
  801c14:	56                   	push   %esi
  801c15:	e8 84 ff ff ff       	call   801b9e <close>

	newfd = INDEX2FD(newfdnum);
  801c1a:	89 f3                	mov    %esi,%ebx
  801c1c:	c1 e3 0c             	shl    $0xc,%ebx
  801c1f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801c25:	83 c4 04             	add    $0x4,%esp
  801c28:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c2b:	e8 db fd ff ff       	call   801a0b <fd2data>
  801c30:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801c32:	89 1c 24             	mov    %ebx,(%esp)
  801c35:	e8 d1 fd ff ff       	call   801a0b <fd2data>
  801c3a:	83 c4 10             	add    $0x10,%esp
  801c3d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801c40:	89 f8                	mov    %edi,%eax
  801c42:	c1 e8 16             	shr    $0x16,%eax
  801c45:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c4c:	a8 01                	test   $0x1,%al
  801c4e:	74 37                	je     801c87 <dup+0x99>
  801c50:	89 f8                	mov    %edi,%eax
  801c52:	c1 e8 0c             	shr    $0xc,%eax
  801c55:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801c5c:	f6 c2 01             	test   $0x1,%dl
  801c5f:	74 26                	je     801c87 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801c61:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c68:	83 ec 0c             	sub    $0xc,%esp
  801c6b:	25 07 0e 00 00       	and    $0xe07,%eax
  801c70:	50                   	push   %eax
  801c71:	ff 75 d4             	pushl  -0x2c(%ebp)
  801c74:	6a 00                	push   $0x0
  801c76:	57                   	push   %edi
  801c77:	6a 00                	push   $0x0
  801c79:	e8 d1 f4 ff ff       	call   80114f <sys_page_map>
  801c7e:	89 c7                	mov    %eax,%edi
  801c80:	83 c4 20             	add    $0x20,%esp
  801c83:	85 c0                	test   %eax,%eax
  801c85:	78 2e                	js     801cb5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c87:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c8a:	89 d0                	mov    %edx,%eax
  801c8c:	c1 e8 0c             	shr    $0xc,%eax
  801c8f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c96:	83 ec 0c             	sub    $0xc,%esp
  801c99:	25 07 0e 00 00       	and    $0xe07,%eax
  801c9e:	50                   	push   %eax
  801c9f:	53                   	push   %ebx
  801ca0:	6a 00                	push   $0x0
  801ca2:	52                   	push   %edx
  801ca3:	6a 00                	push   $0x0
  801ca5:	e8 a5 f4 ff ff       	call   80114f <sys_page_map>
  801caa:	89 c7                	mov    %eax,%edi
  801cac:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801caf:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801cb1:	85 ff                	test   %edi,%edi
  801cb3:	79 1d                	jns    801cd2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801cb5:	83 ec 08             	sub    $0x8,%esp
  801cb8:	53                   	push   %ebx
  801cb9:	6a 00                	push   $0x0
  801cbb:	e8 d1 f4 ff ff       	call   801191 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801cc0:	83 c4 08             	add    $0x8,%esp
  801cc3:	ff 75 d4             	pushl  -0x2c(%ebp)
  801cc6:	6a 00                	push   $0x0
  801cc8:	e8 c4 f4 ff ff       	call   801191 <sys_page_unmap>
	return r;
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	89 f8                	mov    %edi,%eax
}
  801cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cd5:	5b                   	pop    %ebx
  801cd6:	5e                   	pop    %esi
  801cd7:	5f                   	pop    %edi
  801cd8:	5d                   	pop    %ebp
  801cd9:	c3                   	ret    

00801cda <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
  801cdd:	53                   	push   %ebx
  801cde:	83 ec 14             	sub    $0x14,%esp
  801ce1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ce4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ce7:	50                   	push   %eax
  801ce8:	53                   	push   %ebx
  801ce9:	e8 83 fd ff ff       	call   801a71 <fd_lookup>
  801cee:	83 c4 08             	add    $0x8,%esp
  801cf1:	89 c2                	mov    %eax,%edx
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	78 70                	js     801d67 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cf7:	83 ec 08             	sub    $0x8,%esp
  801cfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfd:	50                   	push   %eax
  801cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d01:	ff 30                	pushl  (%eax)
  801d03:	e8 bf fd ff ff       	call   801ac7 <dev_lookup>
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	78 4f                	js     801d5e <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801d0f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d12:	8b 42 08             	mov    0x8(%edx),%eax
  801d15:	83 e0 03             	and    $0x3,%eax
  801d18:	83 f8 01             	cmp    $0x1,%eax
  801d1b:	75 24                	jne    801d41 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801d1d:	a1 04 50 80 00       	mov    0x805004,%eax
  801d22:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801d28:	83 ec 04             	sub    $0x4,%esp
  801d2b:	53                   	push   %ebx
  801d2c:	50                   	push   %eax
  801d2d:	68 44 33 80 00       	push   $0x803344
  801d32:	e8 4d ea ff ff       	call   800784 <cprintf>
		return -E_INVAL;
  801d37:	83 c4 10             	add    $0x10,%esp
  801d3a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801d3f:	eb 26                	jmp    801d67 <read+0x8d>
	}
	if (!dev->dev_read)
  801d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d44:	8b 40 08             	mov    0x8(%eax),%eax
  801d47:	85 c0                	test   %eax,%eax
  801d49:	74 17                	je     801d62 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801d4b:	83 ec 04             	sub    $0x4,%esp
  801d4e:	ff 75 10             	pushl  0x10(%ebp)
  801d51:	ff 75 0c             	pushl  0xc(%ebp)
  801d54:	52                   	push   %edx
  801d55:	ff d0                	call   *%eax
  801d57:	89 c2                	mov    %eax,%edx
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	eb 09                	jmp    801d67 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d5e:	89 c2                	mov    %eax,%edx
  801d60:	eb 05                	jmp    801d67 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801d62:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801d67:	89 d0                	mov    %edx,%eax
  801d69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d6c:	c9                   	leave  
  801d6d:	c3                   	ret    

00801d6e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	57                   	push   %edi
  801d72:	56                   	push   %esi
  801d73:	53                   	push   %ebx
  801d74:	83 ec 0c             	sub    $0xc,%esp
  801d77:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d7a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801d7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d82:	eb 21                	jmp    801da5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801d84:	83 ec 04             	sub    $0x4,%esp
  801d87:	89 f0                	mov    %esi,%eax
  801d89:	29 d8                	sub    %ebx,%eax
  801d8b:	50                   	push   %eax
  801d8c:	89 d8                	mov    %ebx,%eax
  801d8e:	03 45 0c             	add    0xc(%ebp),%eax
  801d91:	50                   	push   %eax
  801d92:	57                   	push   %edi
  801d93:	e8 42 ff ff ff       	call   801cda <read>
		if (m < 0)
  801d98:	83 c4 10             	add    $0x10,%esp
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	78 10                	js     801daf <readn+0x41>
			return m;
		if (m == 0)
  801d9f:	85 c0                	test   %eax,%eax
  801da1:	74 0a                	je     801dad <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801da3:	01 c3                	add    %eax,%ebx
  801da5:	39 f3                	cmp    %esi,%ebx
  801da7:	72 db                	jb     801d84 <readn+0x16>
  801da9:	89 d8                	mov    %ebx,%eax
  801dab:	eb 02                	jmp    801daf <readn+0x41>
  801dad:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801daf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db2:	5b                   	pop    %ebx
  801db3:	5e                   	pop    %esi
  801db4:	5f                   	pop    %edi
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    

00801db7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	53                   	push   %ebx
  801dbb:	83 ec 14             	sub    $0x14,%esp
  801dbe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801dc1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dc4:	50                   	push   %eax
  801dc5:	53                   	push   %ebx
  801dc6:	e8 a6 fc ff ff       	call   801a71 <fd_lookup>
  801dcb:	83 c4 08             	add    $0x8,%esp
  801dce:	89 c2                	mov    %eax,%edx
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	78 6b                	js     801e3f <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801dd4:	83 ec 08             	sub    $0x8,%esp
  801dd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dda:	50                   	push   %eax
  801ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dde:	ff 30                	pushl  (%eax)
  801de0:	e8 e2 fc ff ff       	call   801ac7 <dev_lookup>
  801de5:	83 c4 10             	add    $0x10,%esp
  801de8:	85 c0                	test   %eax,%eax
  801dea:	78 4a                	js     801e36 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801def:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801df3:	75 24                	jne    801e19 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801df5:	a1 04 50 80 00       	mov    0x805004,%eax
  801dfa:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801e00:	83 ec 04             	sub    $0x4,%esp
  801e03:	53                   	push   %ebx
  801e04:	50                   	push   %eax
  801e05:	68 60 33 80 00       	push   $0x803360
  801e0a:	e8 75 e9 ff ff       	call   800784 <cprintf>
		return -E_INVAL;
  801e0f:	83 c4 10             	add    $0x10,%esp
  801e12:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801e17:	eb 26                	jmp    801e3f <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801e19:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e1c:	8b 52 0c             	mov    0xc(%edx),%edx
  801e1f:	85 d2                	test   %edx,%edx
  801e21:	74 17                	je     801e3a <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801e23:	83 ec 04             	sub    $0x4,%esp
  801e26:	ff 75 10             	pushl  0x10(%ebp)
  801e29:	ff 75 0c             	pushl  0xc(%ebp)
  801e2c:	50                   	push   %eax
  801e2d:	ff d2                	call   *%edx
  801e2f:	89 c2                	mov    %eax,%edx
  801e31:	83 c4 10             	add    $0x10,%esp
  801e34:	eb 09                	jmp    801e3f <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e36:	89 c2                	mov    %eax,%edx
  801e38:	eb 05                	jmp    801e3f <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801e3a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801e3f:	89 d0                	mov    %edx,%eax
  801e41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <seek>:

int
seek(int fdnum, off_t offset)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e4c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801e4f:	50                   	push   %eax
  801e50:	ff 75 08             	pushl  0x8(%ebp)
  801e53:	e8 19 fc ff ff       	call   801a71 <fd_lookup>
  801e58:	83 c4 08             	add    $0x8,%esp
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	78 0e                	js     801e6d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801e5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801e62:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e65:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801e68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e6d:	c9                   	leave  
  801e6e:	c3                   	ret    

00801e6f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	53                   	push   %ebx
  801e73:	83 ec 14             	sub    $0x14,%esp
  801e76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e79:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e7c:	50                   	push   %eax
  801e7d:	53                   	push   %ebx
  801e7e:	e8 ee fb ff ff       	call   801a71 <fd_lookup>
  801e83:	83 c4 08             	add    $0x8,%esp
  801e86:	89 c2                	mov    %eax,%edx
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	78 68                	js     801ef4 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e8c:	83 ec 08             	sub    $0x8,%esp
  801e8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e92:	50                   	push   %eax
  801e93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e96:	ff 30                	pushl  (%eax)
  801e98:	e8 2a fc ff ff       	call   801ac7 <dev_lookup>
  801e9d:	83 c4 10             	add    $0x10,%esp
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	78 47                	js     801eeb <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ea4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801eab:	75 24                	jne    801ed1 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801ead:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801eb2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801eb8:	83 ec 04             	sub    $0x4,%esp
  801ebb:	53                   	push   %ebx
  801ebc:	50                   	push   %eax
  801ebd:	68 20 33 80 00       	push   $0x803320
  801ec2:	e8 bd e8 ff ff       	call   800784 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801ec7:	83 c4 10             	add    $0x10,%esp
  801eca:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801ecf:	eb 23                	jmp    801ef4 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801ed1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ed4:	8b 52 18             	mov    0x18(%edx),%edx
  801ed7:	85 d2                	test   %edx,%edx
  801ed9:	74 14                	je     801eef <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801edb:	83 ec 08             	sub    $0x8,%esp
  801ede:	ff 75 0c             	pushl  0xc(%ebp)
  801ee1:	50                   	push   %eax
  801ee2:	ff d2                	call   *%edx
  801ee4:	89 c2                	mov    %eax,%edx
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	eb 09                	jmp    801ef4 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801eeb:	89 c2                	mov    %eax,%edx
  801eed:	eb 05                	jmp    801ef4 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801eef:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801ef4:	89 d0                	mov    %edx,%eax
  801ef6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    

00801efb <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	53                   	push   %ebx
  801eff:	83 ec 14             	sub    $0x14,%esp
  801f02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f05:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f08:	50                   	push   %eax
  801f09:	ff 75 08             	pushl  0x8(%ebp)
  801f0c:	e8 60 fb ff ff       	call   801a71 <fd_lookup>
  801f11:	83 c4 08             	add    $0x8,%esp
  801f14:	89 c2                	mov    %eax,%edx
  801f16:	85 c0                	test   %eax,%eax
  801f18:	78 58                	js     801f72 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f1a:	83 ec 08             	sub    $0x8,%esp
  801f1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f20:	50                   	push   %eax
  801f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f24:	ff 30                	pushl  (%eax)
  801f26:	e8 9c fb ff ff       	call   801ac7 <dev_lookup>
  801f2b:	83 c4 10             	add    $0x10,%esp
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	78 37                	js     801f69 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f35:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801f39:	74 32                	je     801f6d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801f3b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801f3e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801f45:	00 00 00 
	stat->st_isdir = 0;
  801f48:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f4f:	00 00 00 
	stat->st_dev = dev;
  801f52:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801f58:	83 ec 08             	sub    $0x8,%esp
  801f5b:	53                   	push   %ebx
  801f5c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f5f:	ff 50 14             	call   *0x14(%eax)
  801f62:	89 c2                	mov    %eax,%edx
  801f64:	83 c4 10             	add    $0x10,%esp
  801f67:	eb 09                	jmp    801f72 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f69:	89 c2                	mov    %eax,%edx
  801f6b:	eb 05                	jmp    801f72 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801f6d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801f72:	89 d0                	mov    %edx,%eax
  801f74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f77:	c9                   	leave  
  801f78:	c3                   	ret    

00801f79 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	56                   	push   %esi
  801f7d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801f7e:	83 ec 08             	sub    $0x8,%esp
  801f81:	6a 00                	push   $0x0
  801f83:	ff 75 08             	pushl  0x8(%ebp)
  801f86:	e8 e3 01 00 00       	call   80216e <open>
  801f8b:	89 c3                	mov    %eax,%ebx
  801f8d:	83 c4 10             	add    $0x10,%esp
  801f90:	85 c0                	test   %eax,%eax
  801f92:	78 1b                	js     801faf <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801f94:	83 ec 08             	sub    $0x8,%esp
  801f97:	ff 75 0c             	pushl  0xc(%ebp)
  801f9a:	50                   	push   %eax
  801f9b:	e8 5b ff ff ff       	call   801efb <fstat>
  801fa0:	89 c6                	mov    %eax,%esi
	close(fd);
  801fa2:	89 1c 24             	mov    %ebx,(%esp)
  801fa5:	e8 f4 fb ff ff       	call   801b9e <close>
	return r;
  801faa:	83 c4 10             	add    $0x10,%esp
  801fad:	89 f0                	mov    %esi,%eax
}
  801faf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb2:	5b                   	pop    %ebx
  801fb3:	5e                   	pop    %esi
  801fb4:	5d                   	pop    %ebp
  801fb5:	c3                   	ret    

00801fb6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801fb6:	55                   	push   %ebp
  801fb7:	89 e5                	mov    %esp,%ebp
  801fb9:	56                   	push   %esi
  801fba:	53                   	push   %ebx
  801fbb:	89 c6                	mov    %eax,%esi
  801fbd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801fbf:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801fc6:	75 12                	jne    801fda <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801fc8:	83 ec 0c             	sub    $0xc,%esp
  801fcb:	6a 01                	push   $0x1
  801fcd:	e8 e4 f9 ff ff       	call   8019b6 <ipc_find_env>
  801fd2:	a3 00 50 80 00       	mov    %eax,0x805000
  801fd7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801fda:	6a 07                	push   $0x7
  801fdc:	68 00 60 80 00       	push   $0x806000
  801fe1:	56                   	push   %esi
  801fe2:	ff 35 00 50 80 00    	pushl  0x805000
  801fe8:	e8 67 f9 ff ff       	call   801954 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801fed:	83 c4 0c             	add    $0xc,%esp
  801ff0:	6a 00                	push   $0x0
  801ff2:	53                   	push   %ebx
  801ff3:	6a 00                	push   $0x0
  801ff5:	e8 df f8 ff ff       	call   8018d9 <ipc_recv>
}
  801ffa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5d                   	pop    %ebp
  802000:	c3                   	ret    

00802001 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802007:	8b 45 08             	mov    0x8(%ebp),%eax
  80200a:	8b 40 0c             	mov    0xc(%eax),%eax
  80200d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802012:	8b 45 0c             	mov    0xc(%ebp),%eax
  802015:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80201a:	ba 00 00 00 00       	mov    $0x0,%edx
  80201f:	b8 02 00 00 00       	mov    $0x2,%eax
  802024:	e8 8d ff ff ff       	call   801fb6 <fsipc>
}
  802029:	c9                   	leave  
  80202a:	c3                   	ret    

0080202b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802031:	8b 45 08             	mov    0x8(%ebp),%eax
  802034:	8b 40 0c             	mov    0xc(%eax),%eax
  802037:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80203c:	ba 00 00 00 00       	mov    $0x0,%edx
  802041:	b8 06 00 00 00       	mov    $0x6,%eax
  802046:	e8 6b ff ff ff       	call   801fb6 <fsipc>
}
  80204b:	c9                   	leave  
  80204c:	c3                   	ret    

0080204d <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	53                   	push   %ebx
  802051:	83 ec 04             	sub    $0x4,%esp
  802054:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802057:	8b 45 08             	mov    0x8(%ebp),%eax
  80205a:	8b 40 0c             	mov    0xc(%eax),%eax
  80205d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802062:	ba 00 00 00 00       	mov    $0x0,%edx
  802067:	b8 05 00 00 00       	mov    $0x5,%eax
  80206c:	e8 45 ff ff ff       	call   801fb6 <fsipc>
  802071:	85 c0                	test   %eax,%eax
  802073:	78 2c                	js     8020a1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802075:	83 ec 08             	sub    $0x8,%esp
  802078:	68 00 60 80 00       	push   $0x806000
  80207d:	53                   	push   %ebx
  80207e:	e8 86 ec ff ff       	call   800d09 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802083:	a1 80 60 80 00       	mov    0x806080,%eax
  802088:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80208e:	a1 84 60 80 00       	mov    0x806084,%eax
  802093:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802099:	83 c4 10             	add    $0x10,%esp
  80209c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020a4:	c9                   	leave  
  8020a5:	c3                   	ret    

008020a6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	83 ec 0c             	sub    $0xc,%esp
  8020ac:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8020af:	8b 55 08             	mov    0x8(%ebp),%edx
  8020b2:	8b 52 0c             	mov    0xc(%edx),%edx
  8020b5:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8020bb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8020c0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8020c5:	0f 47 c2             	cmova  %edx,%eax
  8020c8:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8020cd:	50                   	push   %eax
  8020ce:	ff 75 0c             	pushl  0xc(%ebp)
  8020d1:	68 08 60 80 00       	push   $0x806008
  8020d6:	e8 c0 ed ff ff       	call   800e9b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8020db:	ba 00 00 00 00       	mov    $0x0,%edx
  8020e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8020e5:	e8 cc fe ff ff       	call   801fb6 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8020ea:	c9                   	leave  
  8020eb:	c3                   	ret    

008020ec <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	56                   	push   %esi
  8020f0:	53                   	push   %ebx
  8020f1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8020f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8020fa:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8020ff:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802105:	ba 00 00 00 00       	mov    $0x0,%edx
  80210a:	b8 03 00 00 00       	mov    $0x3,%eax
  80210f:	e8 a2 fe ff ff       	call   801fb6 <fsipc>
  802114:	89 c3                	mov    %eax,%ebx
  802116:	85 c0                	test   %eax,%eax
  802118:	78 4b                	js     802165 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80211a:	39 c6                	cmp    %eax,%esi
  80211c:	73 16                	jae    802134 <devfile_read+0x48>
  80211e:	68 90 33 80 00       	push   $0x803390
  802123:	68 97 33 80 00       	push   $0x803397
  802128:	6a 7c                	push   $0x7c
  80212a:	68 ac 33 80 00       	push   $0x8033ac
  80212f:	e8 77 e5 ff ff       	call   8006ab <_panic>
	assert(r <= PGSIZE);
  802134:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802139:	7e 16                	jle    802151 <devfile_read+0x65>
  80213b:	68 b7 33 80 00       	push   $0x8033b7
  802140:	68 97 33 80 00       	push   $0x803397
  802145:	6a 7d                	push   $0x7d
  802147:	68 ac 33 80 00       	push   $0x8033ac
  80214c:	e8 5a e5 ff ff       	call   8006ab <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802151:	83 ec 04             	sub    $0x4,%esp
  802154:	50                   	push   %eax
  802155:	68 00 60 80 00       	push   $0x806000
  80215a:	ff 75 0c             	pushl  0xc(%ebp)
  80215d:	e8 39 ed ff ff       	call   800e9b <memmove>
	return r;
  802162:	83 c4 10             	add    $0x10,%esp
}
  802165:	89 d8                	mov    %ebx,%eax
  802167:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80216a:	5b                   	pop    %ebx
  80216b:	5e                   	pop    %esi
  80216c:	5d                   	pop    %ebp
  80216d:	c3                   	ret    

0080216e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80216e:	55                   	push   %ebp
  80216f:	89 e5                	mov    %esp,%ebp
  802171:	53                   	push   %ebx
  802172:	83 ec 20             	sub    $0x20,%esp
  802175:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802178:	53                   	push   %ebx
  802179:	e8 52 eb ff ff       	call   800cd0 <strlen>
  80217e:	83 c4 10             	add    $0x10,%esp
  802181:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802186:	7f 67                	jg     8021ef <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802188:	83 ec 0c             	sub    $0xc,%esp
  80218b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80218e:	50                   	push   %eax
  80218f:	e8 8e f8 ff ff       	call   801a22 <fd_alloc>
  802194:	83 c4 10             	add    $0x10,%esp
		return r;
  802197:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802199:	85 c0                	test   %eax,%eax
  80219b:	78 57                	js     8021f4 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80219d:	83 ec 08             	sub    $0x8,%esp
  8021a0:	53                   	push   %ebx
  8021a1:	68 00 60 80 00       	push   $0x806000
  8021a6:	e8 5e eb ff ff       	call   800d09 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8021ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ae:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8021b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021bb:	e8 f6 fd ff ff       	call   801fb6 <fsipc>
  8021c0:	89 c3                	mov    %eax,%ebx
  8021c2:	83 c4 10             	add    $0x10,%esp
  8021c5:	85 c0                	test   %eax,%eax
  8021c7:	79 14                	jns    8021dd <open+0x6f>
		fd_close(fd, 0);
  8021c9:	83 ec 08             	sub    $0x8,%esp
  8021cc:	6a 00                	push   $0x0
  8021ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8021d1:	e8 47 f9 ff ff       	call   801b1d <fd_close>
		return r;
  8021d6:	83 c4 10             	add    $0x10,%esp
  8021d9:	89 da                	mov    %ebx,%edx
  8021db:	eb 17                	jmp    8021f4 <open+0x86>
	}

	return fd2num(fd);
  8021dd:	83 ec 0c             	sub    $0xc,%esp
  8021e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e3:	e8 13 f8 ff ff       	call   8019fb <fd2num>
  8021e8:	89 c2                	mov    %eax,%edx
  8021ea:	83 c4 10             	add    $0x10,%esp
  8021ed:	eb 05                	jmp    8021f4 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8021ef:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8021f4:	89 d0                	mov    %edx,%eax
  8021f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021f9:	c9                   	leave  
  8021fa:	c3                   	ret    

008021fb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8021fb:	55                   	push   %ebp
  8021fc:	89 e5                	mov    %esp,%ebp
  8021fe:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802201:	ba 00 00 00 00       	mov    $0x0,%edx
  802206:	b8 08 00 00 00       	mov    $0x8,%eax
  80220b:	e8 a6 fd ff ff       	call   801fb6 <fsipc>
}
  802210:	c9                   	leave  
  802211:	c3                   	ret    

00802212 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802212:	55                   	push   %ebp
  802213:	89 e5                	mov    %esp,%ebp
  802215:	56                   	push   %esi
  802216:	53                   	push   %ebx
  802217:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80221a:	83 ec 0c             	sub    $0xc,%esp
  80221d:	ff 75 08             	pushl  0x8(%ebp)
  802220:	e8 e6 f7 ff ff       	call   801a0b <fd2data>
  802225:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802227:	83 c4 08             	add    $0x8,%esp
  80222a:	68 c3 33 80 00       	push   $0x8033c3
  80222f:	53                   	push   %ebx
  802230:	e8 d4 ea ff ff       	call   800d09 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802235:	8b 46 04             	mov    0x4(%esi),%eax
  802238:	2b 06                	sub    (%esi),%eax
  80223a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802240:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802247:	00 00 00 
	stat->st_dev = &devpipe;
  80224a:	c7 83 88 00 00 00 24 	movl   $0x804024,0x88(%ebx)
  802251:	40 80 00 
	return 0;
}
  802254:	b8 00 00 00 00       	mov    $0x0,%eax
  802259:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80225c:	5b                   	pop    %ebx
  80225d:	5e                   	pop    %esi
  80225e:	5d                   	pop    %ebp
  80225f:	c3                   	ret    

00802260 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802260:	55                   	push   %ebp
  802261:	89 e5                	mov    %esp,%ebp
  802263:	53                   	push   %ebx
  802264:	83 ec 0c             	sub    $0xc,%esp
  802267:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80226a:	53                   	push   %ebx
  80226b:	6a 00                	push   $0x0
  80226d:	e8 1f ef ff ff       	call   801191 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802272:	89 1c 24             	mov    %ebx,(%esp)
  802275:	e8 91 f7 ff ff       	call   801a0b <fd2data>
  80227a:	83 c4 08             	add    $0x8,%esp
  80227d:	50                   	push   %eax
  80227e:	6a 00                	push   $0x0
  802280:	e8 0c ef ff ff       	call   801191 <sys_page_unmap>
}
  802285:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802288:	c9                   	leave  
  802289:	c3                   	ret    

0080228a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80228a:	55                   	push   %ebp
  80228b:	89 e5                	mov    %esp,%ebp
  80228d:	57                   	push   %edi
  80228e:	56                   	push   %esi
  80228f:	53                   	push   %ebx
  802290:	83 ec 1c             	sub    $0x1c,%esp
  802293:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802296:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802298:	a1 04 50 80 00       	mov    0x805004,%eax
  80229d:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8022a3:	83 ec 0c             	sub    $0xc,%esp
  8022a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8022a9:	e8 db 04 00 00       	call   802789 <pageref>
  8022ae:	89 c3                	mov    %eax,%ebx
  8022b0:	89 3c 24             	mov    %edi,(%esp)
  8022b3:	e8 d1 04 00 00       	call   802789 <pageref>
  8022b8:	83 c4 10             	add    $0x10,%esp
  8022bb:	39 c3                	cmp    %eax,%ebx
  8022bd:	0f 94 c1             	sete   %cl
  8022c0:	0f b6 c9             	movzbl %cl,%ecx
  8022c3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8022c6:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8022cc:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  8022d2:	39 ce                	cmp    %ecx,%esi
  8022d4:	74 1e                	je     8022f4 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8022d6:	39 c3                	cmp    %eax,%ebx
  8022d8:	75 be                	jne    802298 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022da:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  8022e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8022e3:	50                   	push   %eax
  8022e4:	56                   	push   %esi
  8022e5:	68 ca 33 80 00       	push   $0x8033ca
  8022ea:	e8 95 e4 ff ff       	call   800784 <cprintf>
  8022ef:	83 c4 10             	add    $0x10,%esp
  8022f2:	eb a4                	jmp    802298 <_pipeisclosed+0xe>
	}
}
  8022f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022fa:	5b                   	pop    %ebx
  8022fb:	5e                   	pop    %esi
  8022fc:	5f                   	pop    %edi
  8022fd:	5d                   	pop    %ebp
  8022fe:	c3                   	ret    

008022ff <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022ff:	55                   	push   %ebp
  802300:	89 e5                	mov    %esp,%ebp
  802302:	57                   	push   %edi
  802303:	56                   	push   %esi
  802304:	53                   	push   %ebx
  802305:	83 ec 28             	sub    $0x28,%esp
  802308:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80230b:	56                   	push   %esi
  80230c:	e8 fa f6 ff ff       	call   801a0b <fd2data>
  802311:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802313:	83 c4 10             	add    $0x10,%esp
  802316:	bf 00 00 00 00       	mov    $0x0,%edi
  80231b:	eb 4b                	jmp    802368 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80231d:	89 da                	mov    %ebx,%edx
  80231f:	89 f0                	mov    %esi,%eax
  802321:	e8 64 ff ff ff       	call   80228a <_pipeisclosed>
  802326:	85 c0                	test   %eax,%eax
  802328:	75 48                	jne    802372 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80232a:	e8 be ed ff ff       	call   8010ed <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80232f:	8b 43 04             	mov    0x4(%ebx),%eax
  802332:	8b 0b                	mov    (%ebx),%ecx
  802334:	8d 51 20             	lea    0x20(%ecx),%edx
  802337:	39 d0                	cmp    %edx,%eax
  802339:	73 e2                	jae    80231d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80233b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80233e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802342:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802345:	89 c2                	mov    %eax,%edx
  802347:	c1 fa 1f             	sar    $0x1f,%edx
  80234a:	89 d1                	mov    %edx,%ecx
  80234c:	c1 e9 1b             	shr    $0x1b,%ecx
  80234f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802352:	83 e2 1f             	and    $0x1f,%edx
  802355:	29 ca                	sub    %ecx,%edx
  802357:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80235b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80235f:	83 c0 01             	add    $0x1,%eax
  802362:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802365:	83 c7 01             	add    $0x1,%edi
  802368:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80236b:	75 c2                	jne    80232f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80236d:	8b 45 10             	mov    0x10(%ebp),%eax
  802370:	eb 05                	jmp    802377 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802372:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802377:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80237a:	5b                   	pop    %ebx
  80237b:	5e                   	pop    %esi
  80237c:	5f                   	pop    %edi
  80237d:	5d                   	pop    %ebp
  80237e:	c3                   	ret    

0080237f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80237f:	55                   	push   %ebp
  802380:	89 e5                	mov    %esp,%ebp
  802382:	57                   	push   %edi
  802383:	56                   	push   %esi
  802384:	53                   	push   %ebx
  802385:	83 ec 18             	sub    $0x18,%esp
  802388:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80238b:	57                   	push   %edi
  80238c:	e8 7a f6 ff ff       	call   801a0b <fd2data>
  802391:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802393:	83 c4 10             	add    $0x10,%esp
  802396:	bb 00 00 00 00       	mov    $0x0,%ebx
  80239b:	eb 3d                	jmp    8023da <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80239d:	85 db                	test   %ebx,%ebx
  80239f:	74 04                	je     8023a5 <devpipe_read+0x26>
				return i;
  8023a1:	89 d8                	mov    %ebx,%eax
  8023a3:	eb 44                	jmp    8023e9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023a5:	89 f2                	mov    %esi,%edx
  8023a7:	89 f8                	mov    %edi,%eax
  8023a9:	e8 dc fe ff ff       	call   80228a <_pipeisclosed>
  8023ae:	85 c0                	test   %eax,%eax
  8023b0:	75 32                	jne    8023e4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023b2:	e8 36 ed ff ff       	call   8010ed <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023b7:	8b 06                	mov    (%esi),%eax
  8023b9:	3b 46 04             	cmp    0x4(%esi),%eax
  8023bc:	74 df                	je     80239d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023be:	99                   	cltd   
  8023bf:	c1 ea 1b             	shr    $0x1b,%edx
  8023c2:	01 d0                	add    %edx,%eax
  8023c4:	83 e0 1f             	and    $0x1f,%eax
  8023c7:	29 d0                	sub    %edx,%eax
  8023c9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8023ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023d1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8023d4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023d7:	83 c3 01             	add    $0x1,%ebx
  8023da:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023dd:	75 d8                	jne    8023b7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023df:	8b 45 10             	mov    0x10(%ebp),%eax
  8023e2:	eb 05                	jmp    8023e9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023e4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ec:	5b                   	pop    %ebx
  8023ed:	5e                   	pop    %esi
  8023ee:	5f                   	pop    %edi
  8023ef:	5d                   	pop    %ebp
  8023f0:	c3                   	ret    

008023f1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023f1:	55                   	push   %ebp
  8023f2:	89 e5                	mov    %esp,%ebp
  8023f4:	56                   	push   %esi
  8023f5:	53                   	push   %ebx
  8023f6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023fc:	50                   	push   %eax
  8023fd:	e8 20 f6 ff ff       	call   801a22 <fd_alloc>
  802402:	83 c4 10             	add    $0x10,%esp
  802405:	89 c2                	mov    %eax,%edx
  802407:	85 c0                	test   %eax,%eax
  802409:	0f 88 2c 01 00 00    	js     80253b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80240f:	83 ec 04             	sub    $0x4,%esp
  802412:	68 07 04 00 00       	push   $0x407
  802417:	ff 75 f4             	pushl  -0xc(%ebp)
  80241a:	6a 00                	push   $0x0
  80241c:	e8 eb ec ff ff       	call   80110c <sys_page_alloc>
  802421:	83 c4 10             	add    $0x10,%esp
  802424:	89 c2                	mov    %eax,%edx
  802426:	85 c0                	test   %eax,%eax
  802428:	0f 88 0d 01 00 00    	js     80253b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80242e:	83 ec 0c             	sub    $0xc,%esp
  802431:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802434:	50                   	push   %eax
  802435:	e8 e8 f5 ff ff       	call   801a22 <fd_alloc>
  80243a:	89 c3                	mov    %eax,%ebx
  80243c:	83 c4 10             	add    $0x10,%esp
  80243f:	85 c0                	test   %eax,%eax
  802441:	0f 88 e2 00 00 00    	js     802529 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802447:	83 ec 04             	sub    $0x4,%esp
  80244a:	68 07 04 00 00       	push   $0x407
  80244f:	ff 75 f0             	pushl  -0x10(%ebp)
  802452:	6a 00                	push   $0x0
  802454:	e8 b3 ec ff ff       	call   80110c <sys_page_alloc>
  802459:	89 c3                	mov    %eax,%ebx
  80245b:	83 c4 10             	add    $0x10,%esp
  80245e:	85 c0                	test   %eax,%eax
  802460:	0f 88 c3 00 00 00    	js     802529 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802466:	83 ec 0c             	sub    $0xc,%esp
  802469:	ff 75 f4             	pushl  -0xc(%ebp)
  80246c:	e8 9a f5 ff ff       	call   801a0b <fd2data>
  802471:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802473:	83 c4 0c             	add    $0xc,%esp
  802476:	68 07 04 00 00       	push   $0x407
  80247b:	50                   	push   %eax
  80247c:	6a 00                	push   $0x0
  80247e:	e8 89 ec ff ff       	call   80110c <sys_page_alloc>
  802483:	89 c3                	mov    %eax,%ebx
  802485:	83 c4 10             	add    $0x10,%esp
  802488:	85 c0                	test   %eax,%eax
  80248a:	0f 88 89 00 00 00    	js     802519 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802490:	83 ec 0c             	sub    $0xc,%esp
  802493:	ff 75 f0             	pushl  -0x10(%ebp)
  802496:	e8 70 f5 ff ff       	call   801a0b <fd2data>
  80249b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8024a2:	50                   	push   %eax
  8024a3:	6a 00                	push   $0x0
  8024a5:	56                   	push   %esi
  8024a6:	6a 00                	push   $0x0
  8024a8:	e8 a2 ec ff ff       	call   80114f <sys_page_map>
  8024ad:	89 c3                	mov    %eax,%ebx
  8024af:	83 c4 20             	add    $0x20,%esp
  8024b2:	85 c0                	test   %eax,%eax
  8024b4:	78 55                	js     80250b <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024b6:	8b 15 24 40 80 00    	mov    0x804024,%edx
  8024bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024bf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024cb:	8b 15 24 40 80 00    	mov    0x804024,%edx
  8024d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024d4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024d9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024e0:	83 ec 0c             	sub    $0xc,%esp
  8024e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8024e6:	e8 10 f5 ff ff       	call   8019fb <fd2num>
  8024eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024ee:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8024f0:	83 c4 04             	add    $0x4,%esp
  8024f3:	ff 75 f0             	pushl  -0x10(%ebp)
  8024f6:	e8 00 f5 ff ff       	call   8019fb <fd2num>
  8024fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024fe:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802501:	83 c4 10             	add    $0x10,%esp
  802504:	ba 00 00 00 00       	mov    $0x0,%edx
  802509:	eb 30                	jmp    80253b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80250b:	83 ec 08             	sub    $0x8,%esp
  80250e:	56                   	push   %esi
  80250f:	6a 00                	push   $0x0
  802511:	e8 7b ec ff ff       	call   801191 <sys_page_unmap>
  802516:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802519:	83 ec 08             	sub    $0x8,%esp
  80251c:	ff 75 f0             	pushl  -0x10(%ebp)
  80251f:	6a 00                	push   $0x0
  802521:	e8 6b ec ff ff       	call   801191 <sys_page_unmap>
  802526:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802529:	83 ec 08             	sub    $0x8,%esp
  80252c:	ff 75 f4             	pushl  -0xc(%ebp)
  80252f:	6a 00                	push   $0x0
  802531:	e8 5b ec ff ff       	call   801191 <sys_page_unmap>
  802536:	83 c4 10             	add    $0x10,%esp
  802539:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80253b:	89 d0                	mov    %edx,%eax
  80253d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802540:	5b                   	pop    %ebx
  802541:	5e                   	pop    %esi
  802542:	5d                   	pop    %ebp
  802543:	c3                   	ret    

00802544 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802544:	55                   	push   %ebp
  802545:	89 e5                	mov    %esp,%ebp
  802547:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80254a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80254d:	50                   	push   %eax
  80254e:	ff 75 08             	pushl  0x8(%ebp)
  802551:	e8 1b f5 ff ff       	call   801a71 <fd_lookup>
  802556:	83 c4 10             	add    $0x10,%esp
  802559:	85 c0                	test   %eax,%eax
  80255b:	78 18                	js     802575 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80255d:	83 ec 0c             	sub    $0xc,%esp
  802560:	ff 75 f4             	pushl  -0xc(%ebp)
  802563:	e8 a3 f4 ff ff       	call   801a0b <fd2data>
	return _pipeisclosed(fd, p);
  802568:	89 c2                	mov    %eax,%edx
  80256a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80256d:	e8 18 fd ff ff       	call   80228a <_pipeisclosed>
  802572:	83 c4 10             	add    $0x10,%esp
}
  802575:	c9                   	leave  
  802576:	c3                   	ret    

00802577 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802577:	55                   	push   %ebp
  802578:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80257a:	b8 00 00 00 00       	mov    $0x0,%eax
  80257f:	5d                   	pop    %ebp
  802580:	c3                   	ret    

00802581 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802581:	55                   	push   %ebp
  802582:	89 e5                	mov    %esp,%ebp
  802584:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802587:	68 e2 33 80 00       	push   $0x8033e2
  80258c:	ff 75 0c             	pushl  0xc(%ebp)
  80258f:	e8 75 e7 ff ff       	call   800d09 <strcpy>
	return 0;
}
  802594:	b8 00 00 00 00       	mov    $0x0,%eax
  802599:	c9                   	leave  
  80259a:	c3                   	ret    

0080259b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80259b:	55                   	push   %ebp
  80259c:	89 e5                	mov    %esp,%ebp
  80259e:	57                   	push   %edi
  80259f:	56                   	push   %esi
  8025a0:	53                   	push   %ebx
  8025a1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025a7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025ac:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025b2:	eb 2d                	jmp    8025e1 <devcons_write+0x46>
		m = n - tot;
  8025b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025b7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8025b9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8025bc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8025c1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025c4:	83 ec 04             	sub    $0x4,%esp
  8025c7:	53                   	push   %ebx
  8025c8:	03 45 0c             	add    0xc(%ebp),%eax
  8025cb:	50                   	push   %eax
  8025cc:	57                   	push   %edi
  8025cd:	e8 c9 e8 ff ff       	call   800e9b <memmove>
		sys_cputs(buf, m);
  8025d2:	83 c4 08             	add    $0x8,%esp
  8025d5:	53                   	push   %ebx
  8025d6:	57                   	push   %edi
  8025d7:	e8 74 ea ff ff       	call   801050 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025dc:	01 de                	add    %ebx,%esi
  8025de:	83 c4 10             	add    $0x10,%esp
  8025e1:	89 f0                	mov    %esi,%eax
  8025e3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8025e6:	72 cc                	jb     8025b4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8025e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025eb:	5b                   	pop    %ebx
  8025ec:	5e                   	pop    %esi
  8025ed:	5f                   	pop    %edi
  8025ee:	5d                   	pop    %ebp
  8025ef:	c3                   	ret    

008025f0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025f0:	55                   	push   %ebp
  8025f1:	89 e5                	mov    %esp,%ebp
  8025f3:	83 ec 08             	sub    $0x8,%esp
  8025f6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8025fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025ff:	74 2a                	je     80262b <devcons_read+0x3b>
  802601:	eb 05                	jmp    802608 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802603:	e8 e5 ea ff ff       	call   8010ed <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802608:	e8 61 ea ff ff       	call   80106e <sys_cgetc>
  80260d:	85 c0                	test   %eax,%eax
  80260f:	74 f2                	je     802603 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802611:	85 c0                	test   %eax,%eax
  802613:	78 16                	js     80262b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802615:	83 f8 04             	cmp    $0x4,%eax
  802618:	74 0c                	je     802626 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80261a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80261d:	88 02                	mov    %al,(%edx)
	return 1;
  80261f:	b8 01 00 00 00       	mov    $0x1,%eax
  802624:	eb 05                	jmp    80262b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802626:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80262b:	c9                   	leave  
  80262c:	c3                   	ret    

0080262d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80262d:	55                   	push   %ebp
  80262e:	89 e5                	mov    %esp,%ebp
  802630:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802633:	8b 45 08             	mov    0x8(%ebp),%eax
  802636:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802639:	6a 01                	push   $0x1
  80263b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80263e:	50                   	push   %eax
  80263f:	e8 0c ea ff ff       	call   801050 <sys_cputs>
}
  802644:	83 c4 10             	add    $0x10,%esp
  802647:	c9                   	leave  
  802648:	c3                   	ret    

00802649 <getchar>:

int
getchar(void)
{
  802649:	55                   	push   %ebp
  80264a:	89 e5                	mov    %esp,%ebp
  80264c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80264f:	6a 01                	push   $0x1
  802651:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802654:	50                   	push   %eax
  802655:	6a 00                	push   $0x0
  802657:	e8 7e f6 ff ff       	call   801cda <read>
	if (r < 0)
  80265c:	83 c4 10             	add    $0x10,%esp
  80265f:	85 c0                	test   %eax,%eax
  802661:	78 0f                	js     802672 <getchar+0x29>
		return r;
	if (r < 1)
  802663:	85 c0                	test   %eax,%eax
  802665:	7e 06                	jle    80266d <getchar+0x24>
		return -E_EOF;
	return c;
  802667:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80266b:	eb 05                	jmp    802672 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80266d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802672:	c9                   	leave  
  802673:	c3                   	ret    

00802674 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802674:	55                   	push   %ebp
  802675:	89 e5                	mov    %esp,%ebp
  802677:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80267a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80267d:	50                   	push   %eax
  80267e:	ff 75 08             	pushl  0x8(%ebp)
  802681:	e8 eb f3 ff ff       	call   801a71 <fd_lookup>
  802686:	83 c4 10             	add    $0x10,%esp
  802689:	85 c0                	test   %eax,%eax
  80268b:	78 11                	js     80269e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80268d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802690:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802696:	39 10                	cmp    %edx,(%eax)
  802698:	0f 94 c0             	sete   %al
  80269b:	0f b6 c0             	movzbl %al,%eax
}
  80269e:	c9                   	leave  
  80269f:	c3                   	ret    

008026a0 <opencons>:

int
opencons(void)
{
  8026a0:	55                   	push   %ebp
  8026a1:	89 e5                	mov    %esp,%ebp
  8026a3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026a9:	50                   	push   %eax
  8026aa:	e8 73 f3 ff ff       	call   801a22 <fd_alloc>
  8026af:	83 c4 10             	add    $0x10,%esp
		return r;
  8026b2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026b4:	85 c0                	test   %eax,%eax
  8026b6:	78 3e                	js     8026f6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026b8:	83 ec 04             	sub    $0x4,%esp
  8026bb:	68 07 04 00 00       	push   $0x407
  8026c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8026c3:	6a 00                	push   $0x0
  8026c5:	e8 42 ea ff ff       	call   80110c <sys_page_alloc>
  8026ca:	83 c4 10             	add    $0x10,%esp
		return r;
  8026cd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026cf:	85 c0                	test   %eax,%eax
  8026d1:	78 23                	js     8026f6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8026d3:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8026d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026dc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026e1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026e8:	83 ec 0c             	sub    $0xc,%esp
  8026eb:	50                   	push   %eax
  8026ec:	e8 0a f3 ff ff       	call   8019fb <fd2num>
  8026f1:	89 c2                	mov    %eax,%edx
  8026f3:	83 c4 10             	add    $0x10,%esp
}
  8026f6:	89 d0                	mov    %edx,%eax
  8026f8:	c9                   	leave  
  8026f9:	c3                   	ret    

008026fa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026fa:	55                   	push   %ebp
  8026fb:	89 e5                	mov    %esp,%ebp
  8026fd:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802700:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802707:	75 2a                	jne    802733 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802709:	83 ec 04             	sub    $0x4,%esp
  80270c:	6a 07                	push   $0x7
  80270e:	68 00 f0 bf ee       	push   $0xeebff000
  802713:	6a 00                	push   $0x0
  802715:	e8 f2 e9 ff ff       	call   80110c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80271a:	83 c4 10             	add    $0x10,%esp
  80271d:	85 c0                	test   %eax,%eax
  80271f:	79 12                	jns    802733 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802721:	50                   	push   %eax
  802722:	68 58 32 80 00       	push   $0x803258
  802727:	6a 23                	push   $0x23
  802729:	68 ee 33 80 00       	push   $0x8033ee
  80272e:	e8 78 df ff ff       	call   8006ab <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802733:	8b 45 08             	mov    0x8(%ebp),%eax
  802736:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80273b:	83 ec 08             	sub    $0x8,%esp
  80273e:	68 65 27 80 00       	push   $0x802765
  802743:	6a 00                	push   $0x0
  802745:	e8 0d eb ff ff       	call   801257 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80274a:	83 c4 10             	add    $0x10,%esp
  80274d:	85 c0                	test   %eax,%eax
  80274f:	79 12                	jns    802763 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802751:	50                   	push   %eax
  802752:	68 58 32 80 00       	push   $0x803258
  802757:	6a 2c                	push   $0x2c
  802759:	68 ee 33 80 00       	push   $0x8033ee
  80275e:	e8 48 df ff ff       	call   8006ab <_panic>
	}
}
  802763:	c9                   	leave  
  802764:	c3                   	ret    

00802765 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802765:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802766:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80276b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80276d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802770:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802774:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802779:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80277d:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80277f:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802782:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802783:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802786:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802787:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802788:	c3                   	ret    

00802789 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802789:	55                   	push   %ebp
  80278a:	89 e5                	mov    %esp,%ebp
  80278c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80278f:	89 d0                	mov    %edx,%eax
  802791:	c1 e8 16             	shr    $0x16,%eax
  802794:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80279b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027a0:	f6 c1 01             	test   $0x1,%cl
  8027a3:	74 1d                	je     8027c2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8027a5:	c1 ea 0c             	shr    $0xc,%edx
  8027a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8027af:	f6 c2 01             	test   $0x1,%dl
  8027b2:	74 0e                	je     8027c2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8027b4:	c1 ea 0c             	shr    $0xc,%edx
  8027b7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8027be:	ef 
  8027bf:	0f b7 c0             	movzwl %ax,%eax
}
  8027c2:	5d                   	pop    %ebp
  8027c3:	c3                   	ret    
  8027c4:	66 90                	xchg   %ax,%ax
  8027c6:	66 90                	xchg   %ax,%ax
  8027c8:	66 90                	xchg   %ax,%ax
  8027ca:	66 90                	xchg   %ax,%ax
  8027cc:	66 90                	xchg   %ax,%ax
  8027ce:	66 90                	xchg   %ax,%ax

008027d0 <__udivdi3>:
  8027d0:	55                   	push   %ebp
  8027d1:	57                   	push   %edi
  8027d2:	56                   	push   %esi
  8027d3:	53                   	push   %ebx
  8027d4:	83 ec 1c             	sub    $0x1c,%esp
  8027d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8027db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8027df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8027e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027e7:	85 f6                	test   %esi,%esi
  8027e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027ed:	89 ca                	mov    %ecx,%edx
  8027ef:	89 f8                	mov    %edi,%eax
  8027f1:	75 3d                	jne    802830 <__udivdi3+0x60>
  8027f3:	39 cf                	cmp    %ecx,%edi
  8027f5:	0f 87 c5 00 00 00    	ja     8028c0 <__udivdi3+0xf0>
  8027fb:	85 ff                	test   %edi,%edi
  8027fd:	89 fd                	mov    %edi,%ebp
  8027ff:	75 0b                	jne    80280c <__udivdi3+0x3c>
  802801:	b8 01 00 00 00       	mov    $0x1,%eax
  802806:	31 d2                	xor    %edx,%edx
  802808:	f7 f7                	div    %edi
  80280a:	89 c5                	mov    %eax,%ebp
  80280c:	89 c8                	mov    %ecx,%eax
  80280e:	31 d2                	xor    %edx,%edx
  802810:	f7 f5                	div    %ebp
  802812:	89 c1                	mov    %eax,%ecx
  802814:	89 d8                	mov    %ebx,%eax
  802816:	89 cf                	mov    %ecx,%edi
  802818:	f7 f5                	div    %ebp
  80281a:	89 c3                	mov    %eax,%ebx
  80281c:	89 d8                	mov    %ebx,%eax
  80281e:	89 fa                	mov    %edi,%edx
  802820:	83 c4 1c             	add    $0x1c,%esp
  802823:	5b                   	pop    %ebx
  802824:	5e                   	pop    %esi
  802825:	5f                   	pop    %edi
  802826:	5d                   	pop    %ebp
  802827:	c3                   	ret    
  802828:	90                   	nop
  802829:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802830:	39 ce                	cmp    %ecx,%esi
  802832:	77 74                	ja     8028a8 <__udivdi3+0xd8>
  802834:	0f bd fe             	bsr    %esi,%edi
  802837:	83 f7 1f             	xor    $0x1f,%edi
  80283a:	0f 84 98 00 00 00    	je     8028d8 <__udivdi3+0x108>
  802840:	bb 20 00 00 00       	mov    $0x20,%ebx
  802845:	89 f9                	mov    %edi,%ecx
  802847:	89 c5                	mov    %eax,%ebp
  802849:	29 fb                	sub    %edi,%ebx
  80284b:	d3 e6                	shl    %cl,%esi
  80284d:	89 d9                	mov    %ebx,%ecx
  80284f:	d3 ed                	shr    %cl,%ebp
  802851:	89 f9                	mov    %edi,%ecx
  802853:	d3 e0                	shl    %cl,%eax
  802855:	09 ee                	or     %ebp,%esi
  802857:	89 d9                	mov    %ebx,%ecx
  802859:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80285d:	89 d5                	mov    %edx,%ebp
  80285f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802863:	d3 ed                	shr    %cl,%ebp
  802865:	89 f9                	mov    %edi,%ecx
  802867:	d3 e2                	shl    %cl,%edx
  802869:	89 d9                	mov    %ebx,%ecx
  80286b:	d3 e8                	shr    %cl,%eax
  80286d:	09 c2                	or     %eax,%edx
  80286f:	89 d0                	mov    %edx,%eax
  802871:	89 ea                	mov    %ebp,%edx
  802873:	f7 f6                	div    %esi
  802875:	89 d5                	mov    %edx,%ebp
  802877:	89 c3                	mov    %eax,%ebx
  802879:	f7 64 24 0c          	mull   0xc(%esp)
  80287d:	39 d5                	cmp    %edx,%ebp
  80287f:	72 10                	jb     802891 <__udivdi3+0xc1>
  802881:	8b 74 24 08          	mov    0x8(%esp),%esi
  802885:	89 f9                	mov    %edi,%ecx
  802887:	d3 e6                	shl    %cl,%esi
  802889:	39 c6                	cmp    %eax,%esi
  80288b:	73 07                	jae    802894 <__udivdi3+0xc4>
  80288d:	39 d5                	cmp    %edx,%ebp
  80288f:	75 03                	jne    802894 <__udivdi3+0xc4>
  802891:	83 eb 01             	sub    $0x1,%ebx
  802894:	31 ff                	xor    %edi,%edi
  802896:	89 d8                	mov    %ebx,%eax
  802898:	89 fa                	mov    %edi,%edx
  80289a:	83 c4 1c             	add    $0x1c,%esp
  80289d:	5b                   	pop    %ebx
  80289e:	5e                   	pop    %esi
  80289f:	5f                   	pop    %edi
  8028a0:	5d                   	pop    %ebp
  8028a1:	c3                   	ret    
  8028a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028a8:	31 ff                	xor    %edi,%edi
  8028aa:	31 db                	xor    %ebx,%ebx
  8028ac:	89 d8                	mov    %ebx,%eax
  8028ae:	89 fa                	mov    %edi,%edx
  8028b0:	83 c4 1c             	add    $0x1c,%esp
  8028b3:	5b                   	pop    %ebx
  8028b4:	5e                   	pop    %esi
  8028b5:	5f                   	pop    %edi
  8028b6:	5d                   	pop    %ebp
  8028b7:	c3                   	ret    
  8028b8:	90                   	nop
  8028b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028c0:	89 d8                	mov    %ebx,%eax
  8028c2:	f7 f7                	div    %edi
  8028c4:	31 ff                	xor    %edi,%edi
  8028c6:	89 c3                	mov    %eax,%ebx
  8028c8:	89 d8                	mov    %ebx,%eax
  8028ca:	89 fa                	mov    %edi,%edx
  8028cc:	83 c4 1c             	add    $0x1c,%esp
  8028cf:	5b                   	pop    %ebx
  8028d0:	5e                   	pop    %esi
  8028d1:	5f                   	pop    %edi
  8028d2:	5d                   	pop    %ebp
  8028d3:	c3                   	ret    
  8028d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028d8:	39 ce                	cmp    %ecx,%esi
  8028da:	72 0c                	jb     8028e8 <__udivdi3+0x118>
  8028dc:	31 db                	xor    %ebx,%ebx
  8028de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8028e2:	0f 87 34 ff ff ff    	ja     80281c <__udivdi3+0x4c>
  8028e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8028ed:	e9 2a ff ff ff       	jmp    80281c <__udivdi3+0x4c>
  8028f2:	66 90                	xchg   %ax,%ax
  8028f4:	66 90                	xchg   %ax,%ax
  8028f6:	66 90                	xchg   %ax,%ax
  8028f8:	66 90                	xchg   %ax,%ax
  8028fa:	66 90                	xchg   %ax,%ax
  8028fc:	66 90                	xchg   %ax,%ax
  8028fe:	66 90                	xchg   %ax,%ax

00802900 <__umoddi3>:
  802900:	55                   	push   %ebp
  802901:	57                   	push   %edi
  802902:	56                   	push   %esi
  802903:	53                   	push   %ebx
  802904:	83 ec 1c             	sub    $0x1c,%esp
  802907:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80290b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80290f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802913:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802917:	85 d2                	test   %edx,%edx
  802919:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80291d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802921:	89 f3                	mov    %esi,%ebx
  802923:	89 3c 24             	mov    %edi,(%esp)
  802926:	89 74 24 04          	mov    %esi,0x4(%esp)
  80292a:	75 1c                	jne    802948 <__umoddi3+0x48>
  80292c:	39 f7                	cmp    %esi,%edi
  80292e:	76 50                	jbe    802980 <__umoddi3+0x80>
  802930:	89 c8                	mov    %ecx,%eax
  802932:	89 f2                	mov    %esi,%edx
  802934:	f7 f7                	div    %edi
  802936:	89 d0                	mov    %edx,%eax
  802938:	31 d2                	xor    %edx,%edx
  80293a:	83 c4 1c             	add    $0x1c,%esp
  80293d:	5b                   	pop    %ebx
  80293e:	5e                   	pop    %esi
  80293f:	5f                   	pop    %edi
  802940:	5d                   	pop    %ebp
  802941:	c3                   	ret    
  802942:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802948:	39 f2                	cmp    %esi,%edx
  80294a:	89 d0                	mov    %edx,%eax
  80294c:	77 52                	ja     8029a0 <__umoddi3+0xa0>
  80294e:	0f bd ea             	bsr    %edx,%ebp
  802951:	83 f5 1f             	xor    $0x1f,%ebp
  802954:	75 5a                	jne    8029b0 <__umoddi3+0xb0>
  802956:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80295a:	0f 82 e0 00 00 00    	jb     802a40 <__umoddi3+0x140>
  802960:	39 0c 24             	cmp    %ecx,(%esp)
  802963:	0f 86 d7 00 00 00    	jbe    802a40 <__umoddi3+0x140>
  802969:	8b 44 24 08          	mov    0x8(%esp),%eax
  80296d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802971:	83 c4 1c             	add    $0x1c,%esp
  802974:	5b                   	pop    %ebx
  802975:	5e                   	pop    %esi
  802976:	5f                   	pop    %edi
  802977:	5d                   	pop    %ebp
  802978:	c3                   	ret    
  802979:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802980:	85 ff                	test   %edi,%edi
  802982:	89 fd                	mov    %edi,%ebp
  802984:	75 0b                	jne    802991 <__umoddi3+0x91>
  802986:	b8 01 00 00 00       	mov    $0x1,%eax
  80298b:	31 d2                	xor    %edx,%edx
  80298d:	f7 f7                	div    %edi
  80298f:	89 c5                	mov    %eax,%ebp
  802991:	89 f0                	mov    %esi,%eax
  802993:	31 d2                	xor    %edx,%edx
  802995:	f7 f5                	div    %ebp
  802997:	89 c8                	mov    %ecx,%eax
  802999:	f7 f5                	div    %ebp
  80299b:	89 d0                	mov    %edx,%eax
  80299d:	eb 99                	jmp    802938 <__umoddi3+0x38>
  80299f:	90                   	nop
  8029a0:	89 c8                	mov    %ecx,%eax
  8029a2:	89 f2                	mov    %esi,%edx
  8029a4:	83 c4 1c             	add    $0x1c,%esp
  8029a7:	5b                   	pop    %ebx
  8029a8:	5e                   	pop    %esi
  8029a9:	5f                   	pop    %edi
  8029aa:	5d                   	pop    %ebp
  8029ab:	c3                   	ret    
  8029ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029b0:	8b 34 24             	mov    (%esp),%esi
  8029b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8029b8:	89 e9                	mov    %ebp,%ecx
  8029ba:	29 ef                	sub    %ebp,%edi
  8029bc:	d3 e0                	shl    %cl,%eax
  8029be:	89 f9                	mov    %edi,%ecx
  8029c0:	89 f2                	mov    %esi,%edx
  8029c2:	d3 ea                	shr    %cl,%edx
  8029c4:	89 e9                	mov    %ebp,%ecx
  8029c6:	09 c2                	or     %eax,%edx
  8029c8:	89 d8                	mov    %ebx,%eax
  8029ca:	89 14 24             	mov    %edx,(%esp)
  8029cd:	89 f2                	mov    %esi,%edx
  8029cf:	d3 e2                	shl    %cl,%edx
  8029d1:	89 f9                	mov    %edi,%ecx
  8029d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029db:	d3 e8                	shr    %cl,%eax
  8029dd:	89 e9                	mov    %ebp,%ecx
  8029df:	89 c6                	mov    %eax,%esi
  8029e1:	d3 e3                	shl    %cl,%ebx
  8029e3:	89 f9                	mov    %edi,%ecx
  8029e5:	89 d0                	mov    %edx,%eax
  8029e7:	d3 e8                	shr    %cl,%eax
  8029e9:	89 e9                	mov    %ebp,%ecx
  8029eb:	09 d8                	or     %ebx,%eax
  8029ed:	89 d3                	mov    %edx,%ebx
  8029ef:	89 f2                	mov    %esi,%edx
  8029f1:	f7 34 24             	divl   (%esp)
  8029f4:	89 d6                	mov    %edx,%esi
  8029f6:	d3 e3                	shl    %cl,%ebx
  8029f8:	f7 64 24 04          	mull   0x4(%esp)
  8029fc:	39 d6                	cmp    %edx,%esi
  8029fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a02:	89 d1                	mov    %edx,%ecx
  802a04:	89 c3                	mov    %eax,%ebx
  802a06:	72 08                	jb     802a10 <__umoddi3+0x110>
  802a08:	75 11                	jne    802a1b <__umoddi3+0x11b>
  802a0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802a0e:	73 0b                	jae    802a1b <__umoddi3+0x11b>
  802a10:	2b 44 24 04          	sub    0x4(%esp),%eax
  802a14:	1b 14 24             	sbb    (%esp),%edx
  802a17:	89 d1                	mov    %edx,%ecx
  802a19:	89 c3                	mov    %eax,%ebx
  802a1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802a1f:	29 da                	sub    %ebx,%edx
  802a21:	19 ce                	sbb    %ecx,%esi
  802a23:	89 f9                	mov    %edi,%ecx
  802a25:	89 f0                	mov    %esi,%eax
  802a27:	d3 e0                	shl    %cl,%eax
  802a29:	89 e9                	mov    %ebp,%ecx
  802a2b:	d3 ea                	shr    %cl,%edx
  802a2d:	89 e9                	mov    %ebp,%ecx
  802a2f:	d3 ee                	shr    %cl,%esi
  802a31:	09 d0                	or     %edx,%eax
  802a33:	89 f2                	mov    %esi,%edx
  802a35:	83 c4 1c             	add    $0x1c,%esp
  802a38:	5b                   	pop    %ebx
  802a39:	5e                   	pop    %esi
  802a3a:	5f                   	pop    %edi
  802a3b:	5d                   	pop    %ebp
  802a3c:	c3                   	ret    
  802a3d:	8d 76 00             	lea    0x0(%esi),%esi
  802a40:	29 f9                	sub    %edi,%ecx
  802a42:	19 d6                	sbb    %edx,%esi
  802a44:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a4c:	e9 18 ff ff ff       	jmp    802969 <__umoddi3+0x69>
