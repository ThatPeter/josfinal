
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
  800042:	e8 c3 0c 00 00       	call   800d0a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 b1 16 00 00       	call   80170a <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 60 80 00       	push   $0x806000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 40 16 00 00       	call   8016a8 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 b7 15 00 00       	call   801630 <ipc_recv>
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
  80008f:	b8 a0 27 80 00       	mov    $0x8027a0,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 ab 27 80 00       	push   $0x8027ab
  8000ad:	6a 20                	push   $0x20
  8000af:	68 c5 27 80 00       	push   $0x8027c5
  8000b4:	e8 f3 05 00 00       	call   8006ac <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 60 29 80 00       	push   $0x802960
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 c5 27 80 00       	push   $0x8027c5
  8000cc:	e8 db 05 00 00       	call   8006ac <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 d5 27 80 00       	mov    $0x8027d5,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 de 27 80 00       	push   $0x8027de
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 c5 27 80 00       	push   $0x8027c5
  8000f1:	e8 b6 05 00 00       	call   8006ac <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 84 29 80 00       	push   $0x802984
  800119:	6a 27                	push   $0x27
  80011b:	68 c5 27 80 00       	push   $0x8027c5
  800120:	e8 87 05 00 00       	call   8006ac <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 f6 27 80 00       	push   $0x8027f6
  80012d:	e8 53 06 00 00       	call   800785 <cprintf>

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
  80014f:	68 0a 28 80 00       	push   $0x80280a
  800154:	6a 2b                	push   $0x2b
  800156:	68 c5 27 80 00       	push   $0x8027c5
  80015b:	e8 4c 05 00 00       	call   8006ac <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 40 80 00    	pushl  0x804000
  800169:	e8 63 0b 00 00       	call   800cd1 <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 40 80 00    	pushl  0x804000
  80017f:	e8 4d 0b 00 00       	call   800cd1 <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 b4 29 80 00       	push   $0x8029b4
  80018f:	6a 2d                	push   $0x2d
  800191:	68 c5 27 80 00       	push   $0x8027c5
  800196:	e8 11 05 00 00       	call   8006ac <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 18 28 80 00       	push   $0x802818
  8001a3:	e8 dd 05 00 00       	call   800785 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 91 0c 00 00       	call   800e4f <memset>
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
  8001da:	68 2b 28 80 00       	push   $0x80282b
  8001df:	6a 32                	push   $0x32
  8001e1:	68 c5 27 80 00       	push   $0x8027c5
  8001e6:	e8 c1 04 00 00       	call   8006ac <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 40 80 00    	pushl  0x804000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 b4 0b 00 00       	call   800db4 <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 39 28 80 00       	push   $0x802839
  80020f:	6a 34                	push   $0x34
  800211:	68 c5 27 80 00       	push   $0x8027c5
  800216:	e8 91 04 00 00       	call   8006ac <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 57 28 80 00       	push   $0x802857
  800223:	e8 5d 05 00 00       	call   800785 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 40 80 00    	call   *0x804018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 6a 28 80 00       	push   $0x80286a
  800242:	6a 38                	push   $0x38
  800244:	68 c5 27 80 00       	push   $0x8027c5
  800249:	e8 5e 04 00 00       	call   8006ac <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 79 28 80 00       	push   $0x802879
  800256:	e8 2a 05 00 00       	call   800785 <cprintf>

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
  800285:	e8 08 0f 00 00       	call   801192 <sys_page_unmap>

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
  8002ac:	68 dc 29 80 00       	push   $0x8029dc
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 c5 27 80 00       	push   $0x8027c5
  8002b8:	e8 ef 03 00 00       	call   8006ac <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 8d 28 80 00       	push   $0x80288d
  8002c5:	e8 bb 04 00 00       	call   800785 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 a3 28 80 00       	mov    $0x8028a3,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 ad 28 80 00       	push   $0x8028ad
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 c5 27 80 00       	push   $0x8027c5
  8002ed:	e8 ba 03 00 00       	call   8006ac <_panic>
	//////////////////////////BUG NO 1///////////////////////////////
	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 40 80 00    	mov    0x804014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 40 80 00    	pushl  0x804000
  800301:	e8 cb 09 00 00       	call   800cd1 <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 40 80 00    	pushl  0x804000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 40 80 00    	pushl  0x804000
  800322:	e8 aa 09 00 00       	call   800cd1 <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 c6 28 80 00       	push   $0x8028c6
  800334:	6a 4b                	push   $0x4b
  800336:	68 c5 27 80 00       	push   $0x8027c5
  80033b:	e8 6c 03 00 00       	call   8006ac <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 d5 28 80 00       	push   $0x8028d5
  800348:	e8 38 04 00 00       	call   800785 <cprintf>
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
  800368:	e8 e2 0a 00 00       	call   800e4f <memset>
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
  80038b:	68 14 2a 80 00       	push   $0x802a14
  800390:	6a 51                	push   $0x51
  800392:	68 c5 27 80 00       	push   $0x8027c5
  800397:	e8 10 03 00 00       	call   8006ac <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 40 80 00    	pushl  0x804000
  8003a5:	e8 27 09 00 00       	call   800cd1 <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 34 2a 80 00       	push   $0x802a34
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 c5 27 80 00       	push   $0x8027c5
  8003be:	e8 e9 02 00 00       	call   8006ac <_panic>
	if (strcmp(buf, msg) != 0) 
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 40 80 00    	pushl  0x804000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 dc 09 00 00       	call   800db4 <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 6c 2a 80 00       	push   $0x802a6c
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 c5 27 80 00       	push   $0x8027c5
  8003ee:	e8 b9 02 00 00       	call   8006ac <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 9c 2a 80 00       	push   $0x802a9c
  8003fb:	e8 85 03 00 00       	call   800785 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 a0 27 80 00       	push   $0x8027a0
  80040a:	e8 a2 1a 00 00       	call   801eb1 <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 b1 27 80 00       	push   $0x8027b1
  800426:	6a 5a                	push   $0x5a
  800428:	68 c5 27 80 00       	push   $0x8027c5
  80042d:	e8 7a 02 00 00       	call   8006ac <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 e9 28 80 00       	push   $0x8028e9
  80043e:	6a 5c                	push   $0x5c
  800440:	68 c5 27 80 00       	push   $0x8027c5
  800445:	e8 62 02 00 00       	call   8006ac <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 d5 27 80 00       	push   $0x8027d5
  800454:	e8 58 1a 00 00       	call   801eb1 <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 e4 27 80 00       	push   $0x8027e4
  800466:	6a 5f                	push   $0x5f
  800468:	68 c5 27 80 00       	push   $0x8027c5
  80046d:	e8 3a 02 00 00       	call   8006ac <_panic>
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
  800493:	68 c0 2a 80 00       	push   $0x802ac0
  800498:	6a 62                	push   $0x62
  80049a:	68 c5 27 80 00       	push   $0x8027c5
  80049f:	e8 08 02 00 00       	call   8006ac <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 fc 27 80 00       	push   $0x8027fc
  8004ac:	e8 d4 02 00 00       	call   800785 <cprintf>
//////////////////////////BUG NO 2///////////////////////////////
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 04 29 80 00       	push   $0x802904
  8004be:	e8 ee 19 00 00       	call   801eb1 <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 09 29 80 00       	push   $0x802909
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 c5 27 80 00       	push   $0x8027c5
  8004d9:	e8 ce 01 00 00       	call   8006ac <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 5b 09 00 00       	call   800e4f <memset>
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
  800512:	e8 e9 15 00 00       	call   801b00 <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 18 29 80 00       	push   $0x802918
  800528:	6a 6c                	push   $0x6c
  80052a:	68 c5 27 80 00       	push   $0x8027c5
  80052f:	e8 78 01 00 00       	call   8006ac <_panic>
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
  800547:	e8 9e 13 00 00       	call   8018ea <close>
	
	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 04 29 80 00       	push   $0x802904
  800556:	e8 56 19 00 00       	call   801eb1 <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 2a 29 80 00       	push   $0x80292a
  80056a:	6a 71                	push   $0x71
  80056c:	68 c5 27 80 00       	push   $0x8027c5
  800571:	e8 36 01 00 00       	call   8006ac <_panic>
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
  800591:	e8 21 15 00 00       	call   801ab7 <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 38 29 80 00       	push   $0x802938
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 c5 27 80 00       	push   $0x8027c5
  8005ae:	e8 f9 00 00 00       	call   8006ac <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 e8 2a 80 00       	push   $0x802ae8
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 c5 27 80 00       	push   $0x8027c5
  8005d0:	e8 d7 00 00 00       	call   8006ac <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 14 2b 80 00       	push   $0x802b14
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 c5 27 80 00       	push   $0x8027c5
  8005f0:	e8 b7 00 00 00       	call   8006ac <_panic>
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
  80060c:	e8 d9 12 00 00       	call   8018ea <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 49 29 80 00 	movl   $0x802949,(%esp)
  800618:	e8 68 01 00 00       	call   800785 <cprintf>
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
  800633:	e8 97 0a 00 00       	call   8010cf <sys_getenvid>
  800638:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063d:	89 c2                	mov    %eax,%edx
  80063f:	c1 e2 07             	shl    $0x7,%edx
  800642:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800649:	a3 04 50 80 00       	mov    %eax,0x805004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80064e:	85 db                	test   %ebx,%ebx
  800650:	7e 07                	jle    800659 <libmain+0x31>
		binaryname = argv[0];
  800652:	8b 06                	mov    (%esi),%eax
  800654:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	56                   	push   %esi
  80065d:	53                   	push   %ebx
  80065e:	e8 1b fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  800663:	e8 2a 00 00 00       	call   800692 <exit>
}
  800668:	83 c4 10             	add    $0x10,%esp
  80066b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80066e:	5b                   	pop    %ebx
  80066f:	5e                   	pop    %esi
  800670:	5d                   	pop    %ebp
  800671:	c3                   	ret    

00800672 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800672:	55                   	push   %ebp
  800673:	89 e5                	mov    %esp,%ebp
  800675:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800678:	a1 08 50 80 00       	mov    0x805008,%eax
	func();
  80067d:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80067f:	e8 4b 0a 00 00       	call   8010cf <sys_getenvid>
  800684:	83 ec 0c             	sub    $0xc,%esp
  800687:	50                   	push   %eax
  800688:	e8 91 0c 00 00       	call   80131e <sys_thread_free>
}
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	c9                   	leave  
  800691:	c3                   	ret    

00800692 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800692:	55                   	push   %ebp
  800693:	89 e5                	mov    %esp,%ebp
  800695:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800698:	e8 78 12 00 00       	call   801915 <close_all>
	sys_env_destroy(0);
  80069d:	83 ec 0c             	sub    $0xc,%esp
  8006a0:	6a 00                	push   $0x0
  8006a2:	e8 e7 09 00 00       	call   80108e <sys_env_destroy>
}
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	c9                   	leave  
  8006ab:	c3                   	ret    

008006ac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	56                   	push   %esi
  8006b0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8006b1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8006b4:	8b 35 04 40 80 00    	mov    0x804004,%esi
  8006ba:	e8 10 0a 00 00       	call   8010cf <sys_getenvid>
  8006bf:	83 ec 0c             	sub    $0xc,%esp
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	ff 75 08             	pushl  0x8(%ebp)
  8006c8:	56                   	push   %esi
  8006c9:	50                   	push   %eax
  8006ca:	68 6c 2b 80 00       	push   $0x802b6c
  8006cf:	e8 b1 00 00 00       	call   800785 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006d4:	83 c4 18             	add    $0x18,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	ff 75 10             	pushl  0x10(%ebp)
  8006db:	e8 54 00 00 00       	call   800734 <vcprintf>
	cprintf("\n");
  8006e0:	c7 04 24 3b 30 80 00 	movl   $0x80303b,(%esp)
  8006e7:	e8 99 00 00 00       	call   800785 <cprintf>
  8006ec:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006ef:	cc                   	int3   
  8006f0:	eb fd                	jmp    8006ef <_panic+0x43>

008006f2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	53                   	push   %ebx
  8006f6:	83 ec 04             	sub    $0x4,%esp
  8006f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006fc:	8b 13                	mov    (%ebx),%edx
  8006fe:	8d 42 01             	lea    0x1(%edx),%eax
  800701:	89 03                	mov    %eax,(%ebx)
  800703:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800706:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80070a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80070f:	75 1a                	jne    80072b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	68 ff 00 00 00       	push   $0xff
  800719:	8d 43 08             	lea    0x8(%ebx),%eax
  80071c:	50                   	push   %eax
  80071d:	e8 2f 09 00 00       	call   801051 <sys_cputs>
		b->idx = 0;
  800722:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800728:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80072b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80072f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800732:	c9                   	leave  
  800733:	c3                   	ret    

00800734 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80073d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800744:	00 00 00 
	b.cnt = 0;
  800747:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80074e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800751:	ff 75 0c             	pushl  0xc(%ebp)
  800754:	ff 75 08             	pushl  0x8(%ebp)
  800757:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80075d:	50                   	push   %eax
  80075e:	68 f2 06 80 00       	push   $0x8006f2
  800763:	e8 54 01 00 00       	call   8008bc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800768:	83 c4 08             	add    $0x8,%esp
  80076b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800771:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800777:	50                   	push   %eax
  800778:	e8 d4 08 00 00       	call   801051 <sys_cputs>

	return b.cnt;
}
  80077d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80078b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80078e:	50                   	push   %eax
  80078f:	ff 75 08             	pushl  0x8(%ebp)
  800792:	e8 9d ff ff ff       	call   800734 <vcprintf>
	va_end(ap);

	return cnt;
}
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	57                   	push   %edi
  80079d:	56                   	push   %esi
  80079e:	53                   	push   %ebx
  80079f:	83 ec 1c             	sub    $0x1c,%esp
  8007a2:	89 c7                	mov    %eax,%edi
  8007a4:	89 d6                	mov    %edx,%esi
  8007a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007af:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8007bd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8007c0:	39 d3                	cmp    %edx,%ebx
  8007c2:	72 05                	jb     8007c9 <printnum+0x30>
  8007c4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007c7:	77 45                	ja     80080e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007c9:	83 ec 0c             	sub    $0xc,%esp
  8007cc:	ff 75 18             	pushl  0x18(%ebp)
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007d5:	53                   	push   %ebx
  8007d6:	ff 75 10             	pushl  0x10(%ebp)
  8007d9:	83 ec 08             	sub    $0x8,%esp
  8007dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007df:	ff 75 e0             	pushl  -0x20(%ebp)
  8007e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8007e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8007e8:	e8 13 1d 00 00       	call   802500 <__udivdi3>
  8007ed:	83 c4 18             	add    $0x18,%esp
  8007f0:	52                   	push   %edx
  8007f1:	50                   	push   %eax
  8007f2:	89 f2                	mov    %esi,%edx
  8007f4:	89 f8                	mov    %edi,%eax
  8007f6:	e8 9e ff ff ff       	call   800799 <printnum>
  8007fb:	83 c4 20             	add    $0x20,%esp
  8007fe:	eb 18                	jmp    800818 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800800:	83 ec 08             	sub    $0x8,%esp
  800803:	56                   	push   %esi
  800804:	ff 75 18             	pushl  0x18(%ebp)
  800807:	ff d7                	call   *%edi
  800809:	83 c4 10             	add    $0x10,%esp
  80080c:	eb 03                	jmp    800811 <printnum+0x78>
  80080e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800811:	83 eb 01             	sub    $0x1,%ebx
  800814:	85 db                	test   %ebx,%ebx
  800816:	7f e8                	jg     800800 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	56                   	push   %esi
  80081c:	83 ec 04             	sub    $0x4,%esp
  80081f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800822:	ff 75 e0             	pushl  -0x20(%ebp)
  800825:	ff 75 dc             	pushl  -0x24(%ebp)
  800828:	ff 75 d8             	pushl  -0x28(%ebp)
  80082b:	e8 00 1e 00 00       	call   802630 <__umoddi3>
  800830:	83 c4 14             	add    $0x14,%esp
  800833:	0f be 80 8f 2b 80 00 	movsbl 0x802b8f(%eax),%eax
  80083a:	50                   	push   %eax
  80083b:	ff d7                	call   *%edi
}
  80083d:	83 c4 10             	add    $0x10,%esp
  800840:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800843:	5b                   	pop    %ebx
  800844:	5e                   	pop    %esi
  800845:	5f                   	pop    %edi
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80084b:	83 fa 01             	cmp    $0x1,%edx
  80084e:	7e 0e                	jle    80085e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800850:	8b 10                	mov    (%eax),%edx
  800852:	8d 4a 08             	lea    0x8(%edx),%ecx
  800855:	89 08                	mov    %ecx,(%eax)
  800857:	8b 02                	mov    (%edx),%eax
  800859:	8b 52 04             	mov    0x4(%edx),%edx
  80085c:	eb 22                	jmp    800880 <getuint+0x38>
	else if (lflag)
  80085e:	85 d2                	test   %edx,%edx
  800860:	74 10                	je     800872 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800862:	8b 10                	mov    (%eax),%edx
  800864:	8d 4a 04             	lea    0x4(%edx),%ecx
  800867:	89 08                	mov    %ecx,(%eax)
  800869:	8b 02                	mov    (%edx),%eax
  80086b:	ba 00 00 00 00       	mov    $0x0,%edx
  800870:	eb 0e                	jmp    800880 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800872:	8b 10                	mov    (%eax),%edx
  800874:	8d 4a 04             	lea    0x4(%edx),%ecx
  800877:	89 08                	mov    %ecx,(%eax)
  800879:	8b 02                	mov    (%edx),%eax
  80087b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800888:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80088c:	8b 10                	mov    (%eax),%edx
  80088e:	3b 50 04             	cmp    0x4(%eax),%edx
  800891:	73 0a                	jae    80089d <sprintputch+0x1b>
		*b->buf++ = ch;
  800893:	8d 4a 01             	lea    0x1(%edx),%ecx
  800896:	89 08                	mov    %ecx,(%eax)
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	88 02                	mov    %al,(%edx)
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8008a5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8008a8:	50                   	push   %eax
  8008a9:	ff 75 10             	pushl  0x10(%ebp)
  8008ac:	ff 75 0c             	pushl  0xc(%ebp)
  8008af:	ff 75 08             	pushl  0x8(%ebp)
  8008b2:	e8 05 00 00 00       	call   8008bc <vprintfmt>
	va_end(ap);
}
  8008b7:	83 c4 10             	add    $0x10,%esp
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    

008008bc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	57                   	push   %edi
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
  8008c2:	83 ec 2c             	sub    $0x2c,%esp
  8008c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008cb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008ce:	eb 12                	jmp    8008e2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008d0:	85 c0                	test   %eax,%eax
  8008d2:	0f 84 89 03 00 00    	je     800c61 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	53                   	push   %ebx
  8008dc:	50                   	push   %eax
  8008dd:	ff d6                	call   *%esi
  8008df:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008e2:	83 c7 01             	add    $0x1,%edi
  8008e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008e9:	83 f8 25             	cmp    $0x25,%eax
  8008ec:	75 e2                	jne    8008d0 <vprintfmt+0x14>
  8008ee:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8008f2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008f9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800900:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800907:	ba 00 00 00 00       	mov    $0x0,%edx
  80090c:	eb 07                	jmp    800915 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800911:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800915:	8d 47 01             	lea    0x1(%edi),%eax
  800918:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80091b:	0f b6 07             	movzbl (%edi),%eax
  80091e:	0f b6 c8             	movzbl %al,%ecx
  800921:	83 e8 23             	sub    $0x23,%eax
  800924:	3c 55                	cmp    $0x55,%al
  800926:	0f 87 1a 03 00 00    	ja     800c46 <vprintfmt+0x38a>
  80092c:	0f b6 c0             	movzbl %al,%eax
  80092f:	ff 24 85 e0 2c 80 00 	jmp    *0x802ce0(,%eax,4)
  800936:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800939:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80093d:	eb d6                	jmp    800915 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
  800947:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80094a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80094d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800951:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800954:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800957:	83 fa 09             	cmp    $0x9,%edx
  80095a:	77 39                	ja     800995 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80095c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80095f:	eb e9                	jmp    80094a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800961:	8b 45 14             	mov    0x14(%ebp),%eax
  800964:	8d 48 04             	lea    0x4(%eax),%ecx
  800967:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80096a:	8b 00                	mov    (%eax),%eax
  80096c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800972:	eb 27                	jmp    80099b <vprintfmt+0xdf>
  800974:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800977:	85 c0                	test   %eax,%eax
  800979:	b9 00 00 00 00       	mov    $0x0,%ecx
  80097e:	0f 49 c8             	cmovns %eax,%ecx
  800981:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800984:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800987:	eb 8c                	jmp    800915 <vprintfmt+0x59>
  800989:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80098c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800993:	eb 80                	jmp    800915 <vprintfmt+0x59>
  800995:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800998:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80099b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80099f:	0f 89 70 ff ff ff    	jns    800915 <vprintfmt+0x59>
				width = precision, precision = -1;
  8009a5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009ab:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009b2:	e9 5e ff ff ff       	jmp    800915 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009b7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8009bd:	e9 53 ff ff ff       	jmp    800915 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c5:	8d 50 04             	lea    0x4(%eax),%edx
  8009c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8009cb:	83 ec 08             	sub    $0x8,%esp
  8009ce:	53                   	push   %ebx
  8009cf:	ff 30                	pushl  (%eax)
  8009d1:	ff d6                	call   *%esi
			break;
  8009d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009d9:	e9 04 ff ff ff       	jmp    8008e2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009de:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e1:	8d 50 04             	lea    0x4(%eax),%edx
  8009e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009e7:	8b 00                	mov    (%eax),%eax
  8009e9:	99                   	cltd   
  8009ea:	31 d0                	xor    %edx,%eax
  8009ec:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009ee:	83 f8 0f             	cmp    $0xf,%eax
  8009f1:	7f 0b                	jg     8009fe <vprintfmt+0x142>
  8009f3:	8b 14 85 40 2e 80 00 	mov    0x802e40(,%eax,4),%edx
  8009fa:	85 d2                	test   %edx,%edx
  8009fc:	75 18                	jne    800a16 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8009fe:	50                   	push   %eax
  8009ff:	68 a7 2b 80 00       	push   $0x802ba7
  800a04:	53                   	push   %ebx
  800a05:	56                   	push   %esi
  800a06:	e8 94 fe ff ff       	call   80089f <printfmt>
  800a0b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800a11:	e9 cc fe ff ff       	jmp    8008e2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800a16:	52                   	push   %edx
  800a17:	68 09 30 80 00       	push   $0x803009
  800a1c:	53                   	push   %ebx
  800a1d:	56                   	push   %esi
  800a1e:	e8 7c fe ff ff       	call   80089f <printfmt>
  800a23:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a29:	e9 b4 fe ff ff       	jmp    8008e2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a31:	8d 50 04             	lea    0x4(%eax),%edx
  800a34:	89 55 14             	mov    %edx,0x14(%ebp)
  800a37:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a39:	85 ff                	test   %edi,%edi
  800a3b:	b8 a0 2b 80 00       	mov    $0x802ba0,%eax
  800a40:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a43:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a47:	0f 8e 94 00 00 00    	jle    800ae1 <vprintfmt+0x225>
  800a4d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a51:	0f 84 98 00 00 00    	je     800aef <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a57:	83 ec 08             	sub    $0x8,%esp
  800a5a:	ff 75 d0             	pushl  -0x30(%ebp)
  800a5d:	57                   	push   %edi
  800a5e:	e8 86 02 00 00       	call   800ce9 <strnlen>
  800a63:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a66:	29 c1                	sub    %eax,%ecx
  800a68:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a6b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a6e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a72:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a75:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a78:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a7a:	eb 0f                	jmp    800a8b <vprintfmt+0x1cf>
					putch(padc, putdat);
  800a7c:	83 ec 08             	sub    $0x8,%esp
  800a7f:	53                   	push   %ebx
  800a80:	ff 75 e0             	pushl  -0x20(%ebp)
  800a83:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a85:	83 ef 01             	sub    $0x1,%edi
  800a88:	83 c4 10             	add    $0x10,%esp
  800a8b:	85 ff                	test   %edi,%edi
  800a8d:	7f ed                	jg     800a7c <vprintfmt+0x1c0>
  800a8f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a92:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a95:	85 c9                	test   %ecx,%ecx
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9c:	0f 49 c1             	cmovns %ecx,%eax
  800a9f:	29 c1                	sub    %eax,%ecx
  800aa1:	89 75 08             	mov    %esi,0x8(%ebp)
  800aa4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800aa7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800aaa:	89 cb                	mov    %ecx,%ebx
  800aac:	eb 4d                	jmp    800afb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800aae:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ab2:	74 1b                	je     800acf <vprintfmt+0x213>
  800ab4:	0f be c0             	movsbl %al,%eax
  800ab7:	83 e8 20             	sub    $0x20,%eax
  800aba:	83 f8 5e             	cmp    $0x5e,%eax
  800abd:	76 10                	jbe    800acf <vprintfmt+0x213>
					putch('?', putdat);
  800abf:	83 ec 08             	sub    $0x8,%esp
  800ac2:	ff 75 0c             	pushl  0xc(%ebp)
  800ac5:	6a 3f                	push   $0x3f
  800ac7:	ff 55 08             	call   *0x8(%ebp)
  800aca:	83 c4 10             	add    $0x10,%esp
  800acd:	eb 0d                	jmp    800adc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800acf:	83 ec 08             	sub    $0x8,%esp
  800ad2:	ff 75 0c             	pushl  0xc(%ebp)
  800ad5:	52                   	push   %edx
  800ad6:	ff 55 08             	call   *0x8(%ebp)
  800ad9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800adc:	83 eb 01             	sub    $0x1,%ebx
  800adf:	eb 1a                	jmp    800afb <vprintfmt+0x23f>
  800ae1:	89 75 08             	mov    %esi,0x8(%ebp)
  800ae4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ae7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800aea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800aed:	eb 0c                	jmp    800afb <vprintfmt+0x23f>
  800aef:	89 75 08             	mov    %esi,0x8(%ebp)
  800af2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800af5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800af8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800afb:	83 c7 01             	add    $0x1,%edi
  800afe:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800b02:	0f be d0             	movsbl %al,%edx
  800b05:	85 d2                	test   %edx,%edx
  800b07:	74 23                	je     800b2c <vprintfmt+0x270>
  800b09:	85 f6                	test   %esi,%esi
  800b0b:	78 a1                	js     800aae <vprintfmt+0x1f2>
  800b0d:	83 ee 01             	sub    $0x1,%esi
  800b10:	79 9c                	jns    800aae <vprintfmt+0x1f2>
  800b12:	89 df                	mov    %ebx,%edi
  800b14:	8b 75 08             	mov    0x8(%ebp),%esi
  800b17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1a:	eb 18                	jmp    800b34 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b1c:	83 ec 08             	sub    $0x8,%esp
  800b1f:	53                   	push   %ebx
  800b20:	6a 20                	push   $0x20
  800b22:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b24:	83 ef 01             	sub    $0x1,%edi
  800b27:	83 c4 10             	add    $0x10,%esp
  800b2a:	eb 08                	jmp    800b34 <vprintfmt+0x278>
  800b2c:	89 df                	mov    %ebx,%edi
  800b2e:	8b 75 08             	mov    0x8(%ebp),%esi
  800b31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b34:	85 ff                	test   %edi,%edi
  800b36:	7f e4                	jg     800b1c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b3b:	e9 a2 fd ff ff       	jmp    8008e2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b40:	83 fa 01             	cmp    $0x1,%edx
  800b43:	7e 16                	jle    800b5b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800b45:	8b 45 14             	mov    0x14(%ebp),%eax
  800b48:	8d 50 08             	lea    0x8(%eax),%edx
  800b4b:	89 55 14             	mov    %edx,0x14(%ebp)
  800b4e:	8b 50 04             	mov    0x4(%eax),%edx
  800b51:	8b 00                	mov    (%eax),%eax
  800b53:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b56:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b59:	eb 32                	jmp    800b8d <vprintfmt+0x2d1>
	else if (lflag)
  800b5b:	85 d2                	test   %edx,%edx
  800b5d:	74 18                	je     800b77 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800b5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b62:	8d 50 04             	lea    0x4(%eax),%edx
  800b65:	89 55 14             	mov    %edx,0x14(%ebp)
  800b68:	8b 00                	mov    (%eax),%eax
  800b6a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b6d:	89 c1                	mov    %eax,%ecx
  800b6f:	c1 f9 1f             	sar    $0x1f,%ecx
  800b72:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b75:	eb 16                	jmp    800b8d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800b77:	8b 45 14             	mov    0x14(%ebp),%eax
  800b7a:	8d 50 04             	lea    0x4(%eax),%edx
  800b7d:	89 55 14             	mov    %edx,0x14(%ebp)
  800b80:	8b 00                	mov    (%eax),%eax
  800b82:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b85:	89 c1                	mov    %eax,%ecx
  800b87:	c1 f9 1f             	sar    $0x1f,%ecx
  800b8a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b8d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b90:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b93:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b98:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b9c:	79 74                	jns    800c12 <vprintfmt+0x356>
				putch('-', putdat);
  800b9e:	83 ec 08             	sub    $0x8,%esp
  800ba1:	53                   	push   %ebx
  800ba2:	6a 2d                	push   $0x2d
  800ba4:	ff d6                	call   *%esi
				num = -(long long) num;
  800ba6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ba9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800bac:	f7 d8                	neg    %eax
  800bae:	83 d2 00             	adc    $0x0,%edx
  800bb1:	f7 da                	neg    %edx
  800bb3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800bb6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bbb:	eb 55                	jmp    800c12 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bbd:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc0:	e8 83 fc ff ff       	call   800848 <getuint>
			base = 10;
  800bc5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800bca:	eb 46                	jmp    800c12 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800bcc:	8d 45 14             	lea    0x14(%ebp),%eax
  800bcf:	e8 74 fc ff ff       	call   800848 <getuint>
			base = 8;
  800bd4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800bd9:	eb 37                	jmp    800c12 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800bdb:	83 ec 08             	sub    $0x8,%esp
  800bde:	53                   	push   %ebx
  800bdf:	6a 30                	push   $0x30
  800be1:	ff d6                	call   *%esi
			putch('x', putdat);
  800be3:	83 c4 08             	add    $0x8,%esp
  800be6:	53                   	push   %ebx
  800be7:	6a 78                	push   $0x78
  800be9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800beb:	8b 45 14             	mov    0x14(%ebp),%eax
  800bee:	8d 50 04             	lea    0x4(%eax),%edx
  800bf1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bf4:	8b 00                	mov    (%eax),%eax
  800bf6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bfb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bfe:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800c03:	eb 0d                	jmp    800c12 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c05:	8d 45 14             	lea    0x14(%ebp),%eax
  800c08:	e8 3b fc ff ff       	call   800848 <getuint>
			base = 16;
  800c0d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c12:	83 ec 0c             	sub    $0xc,%esp
  800c15:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800c19:	57                   	push   %edi
  800c1a:	ff 75 e0             	pushl  -0x20(%ebp)
  800c1d:	51                   	push   %ecx
  800c1e:	52                   	push   %edx
  800c1f:	50                   	push   %eax
  800c20:	89 da                	mov    %ebx,%edx
  800c22:	89 f0                	mov    %esi,%eax
  800c24:	e8 70 fb ff ff       	call   800799 <printnum>
			break;
  800c29:	83 c4 20             	add    $0x20,%esp
  800c2c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c2f:	e9 ae fc ff ff       	jmp    8008e2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c34:	83 ec 08             	sub    $0x8,%esp
  800c37:	53                   	push   %ebx
  800c38:	51                   	push   %ecx
  800c39:	ff d6                	call   *%esi
			break;
  800c3b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c3e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c41:	e9 9c fc ff ff       	jmp    8008e2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c46:	83 ec 08             	sub    $0x8,%esp
  800c49:	53                   	push   %ebx
  800c4a:	6a 25                	push   $0x25
  800c4c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c4e:	83 c4 10             	add    $0x10,%esp
  800c51:	eb 03                	jmp    800c56 <vprintfmt+0x39a>
  800c53:	83 ef 01             	sub    $0x1,%edi
  800c56:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c5a:	75 f7                	jne    800c53 <vprintfmt+0x397>
  800c5c:	e9 81 fc ff ff       	jmp    8008e2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	83 ec 18             	sub    $0x18,%esp
  800c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c72:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c75:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c78:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c7c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	74 26                	je     800cb0 <vsnprintf+0x47>
  800c8a:	85 d2                	test   %edx,%edx
  800c8c:	7e 22                	jle    800cb0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c8e:	ff 75 14             	pushl  0x14(%ebp)
  800c91:	ff 75 10             	pushl  0x10(%ebp)
  800c94:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c97:	50                   	push   %eax
  800c98:	68 82 08 80 00       	push   $0x800882
  800c9d:	e8 1a fc ff ff       	call   8008bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ca2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ca5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cab:	83 c4 10             	add    $0x10,%esp
  800cae:	eb 05                	jmp    800cb5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cb0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cb5:	c9                   	leave  
  800cb6:	c3                   	ret    

00800cb7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cbd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cc0:	50                   	push   %eax
  800cc1:	ff 75 10             	pushl  0x10(%ebp)
  800cc4:	ff 75 0c             	pushl  0xc(%ebp)
  800cc7:	ff 75 08             	pushl  0x8(%ebp)
  800cca:	e8 9a ff ff ff       	call   800c69 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ccf:	c9                   	leave  
  800cd0:	c3                   	ret    

00800cd1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdc:	eb 03                	jmp    800ce1 <strlen+0x10>
		n++;
  800cde:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ce1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ce5:	75 f7                	jne    800cde <strlen+0xd>
		n++;
	return n;
}
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cef:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf7:	eb 03                	jmp    800cfc <strnlen+0x13>
		n++;
  800cf9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cfc:	39 c2                	cmp    %eax,%edx
  800cfe:	74 08                	je     800d08 <strnlen+0x1f>
  800d00:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800d04:	75 f3                	jne    800cf9 <strnlen+0x10>
  800d06:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	53                   	push   %ebx
  800d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d14:	89 c2                	mov    %eax,%edx
  800d16:	83 c2 01             	add    $0x1,%edx
  800d19:	83 c1 01             	add    $0x1,%ecx
  800d1c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d20:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d23:	84 db                	test   %bl,%bl
  800d25:	75 ef                	jne    800d16 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d27:	5b                   	pop    %ebx
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	53                   	push   %ebx
  800d2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d31:	53                   	push   %ebx
  800d32:	e8 9a ff ff ff       	call   800cd1 <strlen>
  800d37:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d3a:	ff 75 0c             	pushl  0xc(%ebp)
  800d3d:	01 d8                	add    %ebx,%eax
  800d3f:	50                   	push   %eax
  800d40:	e8 c5 ff ff ff       	call   800d0a <strcpy>
	return dst;
}
  800d45:	89 d8                	mov    %ebx,%eax
  800d47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d4a:	c9                   	leave  
  800d4b:	c3                   	ret    

00800d4c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
  800d51:	8b 75 08             	mov    0x8(%ebp),%esi
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	89 f3                	mov    %esi,%ebx
  800d59:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d5c:	89 f2                	mov    %esi,%edx
  800d5e:	eb 0f                	jmp    800d6f <strncpy+0x23>
		*dst++ = *src;
  800d60:	83 c2 01             	add    $0x1,%edx
  800d63:	0f b6 01             	movzbl (%ecx),%eax
  800d66:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d69:	80 39 01             	cmpb   $0x1,(%ecx)
  800d6c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d6f:	39 da                	cmp    %ebx,%edx
  800d71:	75 ed                	jne    800d60 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d73:	89 f0                	mov    %esi,%eax
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
  800d7e:	8b 75 08             	mov    0x8(%ebp),%esi
  800d81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d84:	8b 55 10             	mov    0x10(%ebp),%edx
  800d87:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d89:	85 d2                	test   %edx,%edx
  800d8b:	74 21                	je     800dae <strlcpy+0x35>
  800d8d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d91:	89 f2                	mov    %esi,%edx
  800d93:	eb 09                	jmp    800d9e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d95:	83 c2 01             	add    $0x1,%edx
  800d98:	83 c1 01             	add    $0x1,%ecx
  800d9b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d9e:	39 c2                	cmp    %eax,%edx
  800da0:	74 09                	je     800dab <strlcpy+0x32>
  800da2:	0f b6 19             	movzbl (%ecx),%ebx
  800da5:	84 db                	test   %bl,%bl
  800da7:	75 ec                	jne    800d95 <strlcpy+0x1c>
  800da9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800dab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dae:	29 f0                	sub    %esi,%eax
}
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dba:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800dbd:	eb 06                	jmp    800dc5 <strcmp+0x11>
		p++, q++;
  800dbf:	83 c1 01             	add    $0x1,%ecx
  800dc2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dc5:	0f b6 01             	movzbl (%ecx),%eax
  800dc8:	84 c0                	test   %al,%al
  800dca:	74 04                	je     800dd0 <strcmp+0x1c>
  800dcc:	3a 02                	cmp    (%edx),%al
  800dce:	74 ef                	je     800dbf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dd0:	0f b6 c0             	movzbl %al,%eax
  800dd3:	0f b6 12             	movzbl (%edx),%edx
  800dd6:	29 d0                	sub    %edx,%eax
}
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	53                   	push   %ebx
  800dde:	8b 45 08             	mov    0x8(%ebp),%eax
  800de1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de4:	89 c3                	mov    %eax,%ebx
  800de6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800de9:	eb 06                	jmp    800df1 <strncmp+0x17>
		n--, p++, q++;
  800deb:	83 c0 01             	add    $0x1,%eax
  800dee:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800df1:	39 d8                	cmp    %ebx,%eax
  800df3:	74 15                	je     800e0a <strncmp+0x30>
  800df5:	0f b6 08             	movzbl (%eax),%ecx
  800df8:	84 c9                	test   %cl,%cl
  800dfa:	74 04                	je     800e00 <strncmp+0x26>
  800dfc:	3a 0a                	cmp    (%edx),%cl
  800dfe:	74 eb                	je     800deb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e00:	0f b6 00             	movzbl (%eax),%eax
  800e03:	0f b6 12             	movzbl (%edx),%edx
  800e06:	29 d0                	sub    %edx,%eax
  800e08:	eb 05                	jmp    800e0f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e0a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e0f:	5b                   	pop    %ebx
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	8b 45 08             	mov    0x8(%ebp),%eax
  800e18:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e1c:	eb 07                	jmp    800e25 <strchr+0x13>
		if (*s == c)
  800e1e:	38 ca                	cmp    %cl,%dl
  800e20:	74 0f                	je     800e31 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e22:	83 c0 01             	add    $0x1,%eax
  800e25:	0f b6 10             	movzbl (%eax),%edx
  800e28:	84 d2                	test   %dl,%dl
  800e2a:	75 f2                	jne    800e1e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
  800e39:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e3d:	eb 03                	jmp    800e42 <strfind+0xf>
  800e3f:	83 c0 01             	add    $0x1,%eax
  800e42:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e45:	38 ca                	cmp    %cl,%dl
  800e47:	74 04                	je     800e4d <strfind+0x1a>
  800e49:	84 d2                	test   %dl,%dl
  800e4b:	75 f2                	jne    800e3f <strfind+0xc>
			break;
	return (char *) s;
}
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	57                   	push   %edi
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
  800e55:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e58:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e5b:	85 c9                	test   %ecx,%ecx
  800e5d:	74 36                	je     800e95 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e65:	75 28                	jne    800e8f <memset+0x40>
  800e67:	f6 c1 03             	test   $0x3,%cl
  800e6a:	75 23                	jne    800e8f <memset+0x40>
		c &= 0xFF;
  800e6c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e70:	89 d3                	mov    %edx,%ebx
  800e72:	c1 e3 08             	shl    $0x8,%ebx
  800e75:	89 d6                	mov    %edx,%esi
  800e77:	c1 e6 18             	shl    $0x18,%esi
  800e7a:	89 d0                	mov    %edx,%eax
  800e7c:	c1 e0 10             	shl    $0x10,%eax
  800e7f:	09 f0                	or     %esi,%eax
  800e81:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e83:	89 d8                	mov    %ebx,%eax
  800e85:	09 d0                	or     %edx,%eax
  800e87:	c1 e9 02             	shr    $0x2,%ecx
  800e8a:	fc                   	cld    
  800e8b:	f3 ab                	rep stos %eax,%es:(%edi)
  800e8d:	eb 06                	jmp    800e95 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e92:	fc                   	cld    
  800e93:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e95:	89 f8                	mov    %edi,%eax
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	57                   	push   %edi
  800ea0:	56                   	push   %esi
  800ea1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ea7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800eaa:	39 c6                	cmp    %eax,%esi
  800eac:	73 35                	jae    800ee3 <memmove+0x47>
  800eae:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800eb1:	39 d0                	cmp    %edx,%eax
  800eb3:	73 2e                	jae    800ee3 <memmove+0x47>
		s += n;
		d += n;
  800eb5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eb8:	89 d6                	mov    %edx,%esi
  800eba:	09 fe                	or     %edi,%esi
  800ebc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ec2:	75 13                	jne    800ed7 <memmove+0x3b>
  800ec4:	f6 c1 03             	test   $0x3,%cl
  800ec7:	75 0e                	jne    800ed7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ec9:	83 ef 04             	sub    $0x4,%edi
  800ecc:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ecf:	c1 e9 02             	shr    $0x2,%ecx
  800ed2:	fd                   	std    
  800ed3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ed5:	eb 09                	jmp    800ee0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ed7:	83 ef 01             	sub    $0x1,%edi
  800eda:	8d 72 ff             	lea    -0x1(%edx),%esi
  800edd:	fd                   	std    
  800ede:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ee0:	fc                   	cld    
  800ee1:	eb 1d                	jmp    800f00 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ee3:	89 f2                	mov    %esi,%edx
  800ee5:	09 c2                	or     %eax,%edx
  800ee7:	f6 c2 03             	test   $0x3,%dl
  800eea:	75 0f                	jne    800efb <memmove+0x5f>
  800eec:	f6 c1 03             	test   $0x3,%cl
  800eef:	75 0a                	jne    800efb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ef1:	c1 e9 02             	shr    $0x2,%ecx
  800ef4:	89 c7                	mov    %eax,%edi
  800ef6:	fc                   	cld    
  800ef7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ef9:	eb 05                	jmp    800f00 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800efb:	89 c7                	mov    %eax,%edi
  800efd:	fc                   	cld    
  800efe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f00:	5e                   	pop    %esi
  800f01:	5f                   	pop    %edi
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f07:	ff 75 10             	pushl  0x10(%ebp)
  800f0a:	ff 75 0c             	pushl  0xc(%ebp)
  800f0d:	ff 75 08             	pushl  0x8(%ebp)
  800f10:	e8 87 ff ff ff       	call   800e9c <memmove>
}
  800f15:	c9                   	leave  
  800f16:	c3                   	ret    

00800f17 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	56                   	push   %esi
  800f1b:	53                   	push   %ebx
  800f1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f22:	89 c6                	mov    %eax,%esi
  800f24:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f27:	eb 1a                	jmp    800f43 <memcmp+0x2c>
		if (*s1 != *s2)
  800f29:	0f b6 08             	movzbl (%eax),%ecx
  800f2c:	0f b6 1a             	movzbl (%edx),%ebx
  800f2f:	38 d9                	cmp    %bl,%cl
  800f31:	74 0a                	je     800f3d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f33:	0f b6 c1             	movzbl %cl,%eax
  800f36:	0f b6 db             	movzbl %bl,%ebx
  800f39:	29 d8                	sub    %ebx,%eax
  800f3b:	eb 0f                	jmp    800f4c <memcmp+0x35>
		s1++, s2++;
  800f3d:	83 c0 01             	add    $0x1,%eax
  800f40:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f43:	39 f0                	cmp    %esi,%eax
  800f45:	75 e2                	jne    800f29 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f4c:	5b                   	pop    %ebx
  800f4d:	5e                   	pop    %esi
  800f4e:	5d                   	pop    %ebp
  800f4f:	c3                   	ret    

00800f50 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	53                   	push   %ebx
  800f54:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f57:	89 c1                	mov    %eax,%ecx
  800f59:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f5c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f60:	eb 0a                	jmp    800f6c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f62:	0f b6 10             	movzbl (%eax),%edx
  800f65:	39 da                	cmp    %ebx,%edx
  800f67:	74 07                	je     800f70 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f69:	83 c0 01             	add    $0x1,%eax
  800f6c:	39 c8                	cmp    %ecx,%eax
  800f6e:	72 f2                	jb     800f62 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f70:	5b                   	pop    %ebx
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    

00800f73 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	57                   	push   %edi
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
  800f79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f7f:	eb 03                	jmp    800f84 <strtol+0x11>
		s++;
  800f81:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f84:	0f b6 01             	movzbl (%ecx),%eax
  800f87:	3c 20                	cmp    $0x20,%al
  800f89:	74 f6                	je     800f81 <strtol+0xe>
  800f8b:	3c 09                	cmp    $0x9,%al
  800f8d:	74 f2                	je     800f81 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f8f:	3c 2b                	cmp    $0x2b,%al
  800f91:	75 0a                	jne    800f9d <strtol+0x2a>
		s++;
  800f93:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f96:	bf 00 00 00 00       	mov    $0x0,%edi
  800f9b:	eb 11                	jmp    800fae <strtol+0x3b>
  800f9d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fa2:	3c 2d                	cmp    $0x2d,%al
  800fa4:	75 08                	jne    800fae <strtol+0x3b>
		s++, neg = 1;
  800fa6:	83 c1 01             	add    $0x1,%ecx
  800fa9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fae:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800fb4:	75 15                	jne    800fcb <strtol+0x58>
  800fb6:	80 39 30             	cmpb   $0x30,(%ecx)
  800fb9:	75 10                	jne    800fcb <strtol+0x58>
  800fbb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800fbf:	75 7c                	jne    80103d <strtol+0xca>
		s += 2, base = 16;
  800fc1:	83 c1 02             	add    $0x2,%ecx
  800fc4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fc9:	eb 16                	jmp    800fe1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800fcb:	85 db                	test   %ebx,%ebx
  800fcd:	75 12                	jne    800fe1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fcf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fd4:	80 39 30             	cmpb   $0x30,(%ecx)
  800fd7:	75 08                	jne    800fe1 <strtol+0x6e>
		s++, base = 8;
  800fd9:	83 c1 01             	add    $0x1,%ecx
  800fdc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fe1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fe9:	0f b6 11             	movzbl (%ecx),%edx
  800fec:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fef:	89 f3                	mov    %esi,%ebx
  800ff1:	80 fb 09             	cmp    $0x9,%bl
  800ff4:	77 08                	ja     800ffe <strtol+0x8b>
			dig = *s - '0';
  800ff6:	0f be d2             	movsbl %dl,%edx
  800ff9:	83 ea 30             	sub    $0x30,%edx
  800ffc:	eb 22                	jmp    801020 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ffe:	8d 72 9f             	lea    -0x61(%edx),%esi
  801001:	89 f3                	mov    %esi,%ebx
  801003:	80 fb 19             	cmp    $0x19,%bl
  801006:	77 08                	ja     801010 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801008:	0f be d2             	movsbl %dl,%edx
  80100b:	83 ea 57             	sub    $0x57,%edx
  80100e:	eb 10                	jmp    801020 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801010:	8d 72 bf             	lea    -0x41(%edx),%esi
  801013:	89 f3                	mov    %esi,%ebx
  801015:	80 fb 19             	cmp    $0x19,%bl
  801018:	77 16                	ja     801030 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80101a:	0f be d2             	movsbl %dl,%edx
  80101d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801020:	3b 55 10             	cmp    0x10(%ebp),%edx
  801023:	7d 0b                	jge    801030 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801025:	83 c1 01             	add    $0x1,%ecx
  801028:	0f af 45 10          	imul   0x10(%ebp),%eax
  80102c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80102e:	eb b9                	jmp    800fe9 <strtol+0x76>

	if (endptr)
  801030:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801034:	74 0d                	je     801043 <strtol+0xd0>
		*endptr = (char *) s;
  801036:	8b 75 0c             	mov    0xc(%ebp),%esi
  801039:	89 0e                	mov    %ecx,(%esi)
  80103b:	eb 06                	jmp    801043 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80103d:	85 db                	test   %ebx,%ebx
  80103f:	74 98                	je     800fd9 <strtol+0x66>
  801041:	eb 9e                	jmp    800fe1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801043:	89 c2                	mov    %eax,%edx
  801045:	f7 da                	neg    %edx
  801047:	85 ff                	test   %edi,%edi
  801049:	0f 45 c2             	cmovne %edx,%eax
}
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	57                   	push   %edi
  801055:	56                   	push   %esi
  801056:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801057:	b8 00 00 00 00       	mov    $0x0,%eax
  80105c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105f:	8b 55 08             	mov    0x8(%ebp),%edx
  801062:	89 c3                	mov    %eax,%ebx
  801064:	89 c7                	mov    %eax,%edi
  801066:	89 c6                	mov    %eax,%esi
  801068:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80106a:	5b                   	pop    %ebx
  80106b:	5e                   	pop    %esi
  80106c:	5f                   	pop    %edi
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    

0080106f <sys_cgetc>:

int
sys_cgetc(void)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	57                   	push   %edi
  801073:	56                   	push   %esi
  801074:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801075:	ba 00 00 00 00       	mov    $0x0,%edx
  80107a:	b8 01 00 00 00       	mov    $0x1,%eax
  80107f:	89 d1                	mov    %edx,%ecx
  801081:	89 d3                	mov    %edx,%ebx
  801083:	89 d7                	mov    %edx,%edi
  801085:	89 d6                	mov    %edx,%esi
  801087:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801089:	5b                   	pop    %ebx
  80108a:	5e                   	pop    %esi
  80108b:	5f                   	pop    %edi
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	57                   	push   %edi
  801092:	56                   	push   %esi
  801093:	53                   	push   %ebx
  801094:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801097:	b9 00 00 00 00       	mov    $0x0,%ecx
  80109c:	b8 03 00 00 00       	mov    $0x3,%eax
  8010a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a4:	89 cb                	mov    %ecx,%ebx
  8010a6:	89 cf                	mov    %ecx,%edi
  8010a8:	89 ce                	mov    %ecx,%esi
  8010aa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	7e 17                	jle    8010c7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b0:	83 ec 0c             	sub    $0xc,%esp
  8010b3:	50                   	push   %eax
  8010b4:	6a 03                	push   $0x3
  8010b6:	68 9f 2e 80 00       	push   $0x802e9f
  8010bb:	6a 23                	push   $0x23
  8010bd:	68 bc 2e 80 00       	push   $0x802ebc
  8010c2:	e8 e5 f5 ff ff       	call   8006ac <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ca:	5b                   	pop    %ebx
  8010cb:	5e                   	pop    %esi
  8010cc:	5f                   	pop    %edi
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	57                   	push   %edi
  8010d3:	56                   	push   %esi
  8010d4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8010da:	b8 02 00 00 00       	mov    $0x2,%eax
  8010df:	89 d1                	mov    %edx,%ecx
  8010e1:	89 d3                	mov    %edx,%ebx
  8010e3:	89 d7                	mov    %edx,%edi
  8010e5:	89 d6                	mov    %edx,%esi
  8010e7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010e9:	5b                   	pop    %ebx
  8010ea:	5e                   	pop    %esi
  8010eb:	5f                   	pop    %edi
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <sys_yield>:

void
sys_yield(void)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	57                   	push   %edi
  8010f2:	56                   	push   %esi
  8010f3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010fe:	89 d1                	mov    %edx,%ecx
  801100:	89 d3                	mov    %edx,%ebx
  801102:	89 d7                	mov    %edx,%edi
  801104:	89 d6                	mov    %edx,%esi
  801106:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801108:	5b                   	pop    %ebx
  801109:	5e                   	pop    %esi
  80110a:	5f                   	pop    %edi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	57                   	push   %edi
  801111:	56                   	push   %esi
  801112:	53                   	push   %ebx
  801113:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801116:	be 00 00 00 00       	mov    $0x0,%esi
  80111b:	b8 04 00 00 00       	mov    $0x4,%eax
  801120:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801123:	8b 55 08             	mov    0x8(%ebp),%edx
  801126:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801129:	89 f7                	mov    %esi,%edi
  80112b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80112d:	85 c0                	test   %eax,%eax
  80112f:	7e 17                	jle    801148 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801131:	83 ec 0c             	sub    $0xc,%esp
  801134:	50                   	push   %eax
  801135:	6a 04                	push   $0x4
  801137:	68 9f 2e 80 00       	push   $0x802e9f
  80113c:	6a 23                	push   $0x23
  80113e:	68 bc 2e 80 00       	push   $0x802ebc
  801143:	e8 64 f5 ff ff       	call   8006ac <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801148:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114b:	5b                   	pop    %ebx
  80114c:	5e                   	pop    %esi
  80114d:	5f                   	pop    %edi
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    

00801150 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	57                   	push   %edi
  801154:	56                   	push   %esi
  801155:	53                   	push   %ebx
  801156:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801159:	b8 05 00 00 00       	mov    $0x5,%eax
  80115e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801161:	8b 55 08             	mov    0x8(%ebp),%edx
  801164:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801167:	8b 7d 14             	mov    0x14(%ebp),%edi
  80116a:	8b 75 18             	mov    0x18(%ebp),%esi
  80116d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80116f:	85 c0                	test   %eax,%eax
  801171:	7e 17                	jle    80118a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801173:	83 ec 0c             	sub    $0xc,%esp
  801176:	50                   	push   %eax
  801177:	6a 05                	push   $0x5
  801179:	68 9f 2e 80 00       	push   $0x802e9f
  80117e:	6a 23                	push   $0x23
  801180:	68 bc 2e 80 00       	push   $0x802ebc
  801185:	e8 22 f5 ff ff       	call   8006ac <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80118a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118d:	5b                   	pop    %ebx
  80118e:	5e                   	pop    %esi
  80118f:	5f                   	pop    %edi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    

00801192 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	57                   	push   %edi
  801196:	56                   	push   %esi
  801197:	53                   	push   %ebx
  801198:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80119b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a0:	b8 06 00 00 00       	mov    $0x6,%eax
  8011a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ab:	89 df                	mov    %ebx,%edi
  8011ad:	89 de                	mov    %ebx,%esi
  8011af:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	7e 17                	jle    8011cc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b5:	83 ec 0c             	sub    $0xc,%esp
  8011b8:	50                   	push   %eax
  8011b9:	6a 06                	push   $0x6
  8011bb:	68 9f 2e 80 00       	push   $0x802e9f
  8011c0:	6a 23                	push   $0x23
  8011c2:	68 bc 2e 80 00       	push   $0x802ebc
  8011c7:	e8 e0 f4 ff ff       	call   8006ac <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cf:	5b                   	pop    %ebx
  8011d0:	5e                   	pop    %esi
  8011d1:	5f                   	pop    %edi
  8011d2:	5d                   	pop    %ebp
  8011d3:	c3                   	ret    

008011d4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	57                   	push   %edi
  8011d8:	56                   	push   %esi
  8011d9:	53                   	push   %ebx
  8011da:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e2:	b8 08 00 00 00       	mov    $0x8,%eax
  8011e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ed:	89 df                	mov    %ebx,%edi
  8011ef:	89 de                	mov    %ebx,%esi
  8011f1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	7e 17                	jle    80120e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f7:	83 ec 0c             	sub    $0xc,%esp
  8011fa:	50                   	push   %eax
  8011fb:	6a 08                	push   $0x8
  8011fd:	68 9f 2e 80 00       	push   $0x802e9f
  801202:	6a 23                	push   $0x23
  801204:	68 bc 2e 80 00       	push   $0x802ebc
  801209:	e8 9e f4 ff ff       	call   8006ac <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80120e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801211:	5b                   	pop    %ebx
  801212:	5e                   	pop    %esi
  801213:	5f                   	pop    %edi
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	57                   	push   %edi
  80121a:	56                   	push   %esi
  80121b:	53                   	push   %ebx
  80121c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80121f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801224:	b8 09 00 00 00       	mov    $0x9,%eax
  801229:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122c:	8b 55 08             	mov    0x8(%ebp),%edx
  80122f:	89 df                	mov    %ebx,%edi
  801231:	89 de                	mov    %ebx,%esi
  801233:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801235:	85 c0                	test   %eax,%eax
  801237:	7e 17                	jle    801250 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801239:	83 ec 0c             	sub    $0xc,%esp
  80123c:	50                   	push   %eax
  80123d:	6a 09                	push   $0x9
  80123f:	68 9f 2e 80 00       	push   $0x802e9f
  801244:	6a 23                	push   $0x23
  801246:	68 bc 2e 80 00       	push   $0x802ebc
  80124b:	e8 5c f4 ff ff       	call   8006ac <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801250:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801253:	5b                   	pop    %ebx
  801254:	5e                   	pop    %esi
  801255:	5f                   	pop    %edi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	57                   	push   %edi
  80125c:	56                   	push   %esi
  80125d:	53                   	push   %ebx
  80125e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801261:	bb 00 00 00 00       	mov    $0x0,%ebx
  801266:	b8 0a 00 00 00       	mov    $0xa,%eax
  80126b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126e:	8b 55 08             	mov    0x8(%ebp),%edx
  801271:	89 df                	mov    %ebx,%edi
  801273:	89 de                	mov    %ebx,%esi
  801275:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801277:	85 c0                	test   %eax,%eax
  801279:	7e 17                	jle    801292 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80127b:	83 ec 0c             	sub    $0xc,%esp
  80127e:	50                   	push   %eax
  80127f:	6a 0a                	push   $0xa
  801281:	68 9f 2e 80 00       	push   $0x802e9f
  801286:	6a 23                	push   $0x23
  801288:	68 bc 2e 80 00       	push   $0x802ebc
  80128d:	e8 1a f4 ff ff       	call   8006ac <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801292:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801295:	5b                   	pop    %ebx
  801296:	5e                   	pop    %esi
  801297:	5f                   	pop    %edi
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    

0080129a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	57                   	push   %edi
  80129e:	56                   	push   %esi
  80129f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a0:	be 00 00 00 00       	mov    $0x0,%esi
  8012a5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012b3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012b6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012b8:	5b                   	pop    %ebx
  8012b9:	5e                   	pop    %esi
  8012ba:	5f                   	pop    %edi
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	57                   	push   %edi
  8012c1:	56                   	push   %esi
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012cb:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d3:	89 cb                	mov    %ecx,%ebx
  8012d5:	89 cf                	mov    %ecx,%edi
  8012d7:	89 ce                	mov    %ecx,%esi
  8012d9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	7e 17                	jle    8012f6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012df:	83 ec 0c             	sub    $0xc,%esp
  8012e2:	50                   	push   %eax
  8012e3:	6a 0d                	push   $0xd
  8012e5:	68 9f 2e 80 00       	push   $0x802e9f
  8012ea:	6a 23                	push   $0x23
  8012ec:	68 bc 2e 80 00       	push   $0x802ebc
  8012f1:	e8 b6 f3 ff ff       	call   8006ac <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f9:	5b                   	pop    %ebx
  8012fa:	5e                   	pop    %esi
  8012fb:	5f                   	pop    %edi
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    

008012fe <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	57                   	push   %edi
  801302:	56                   	push   %esi
  801303:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801304:	b9 00 00 00 00       	mov    $0x0,%ecx
  801309:	b8 0e 00 00 00       	mov    $0xe,%eax
  80130e:	8b 55 08             	mov    0x8(%ebp),%edx
  801311:	89 cb                	mov    %ecx,%ebx
  801313:	89 cf                	mov    %ecx,%edi
  801315:	89 ce                	mov    %ecx,%esi
  801317:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  801319:	5b                   	pop    %ebx
  80131a:	5e                   	pop    %esi
  80131b:	5f                   	pop    %edi
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    

0080131e <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	57                   	push   %edi
  801322:	56                   	push   %esi
  801323:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801324:	b9 00 00 00 00       	mov    $0x0,%ecx
  801329:	b8 0f 00 00 00       	mov    $0xf,%eax
  80132e:	8b 55 08             	mov    0x8(%ebp),%edx
  801331:	89 cb                	mov    %ecx,%ebx
  801333:	89 cf                	mov    %ecx,%edi
  801335:	89 ce                	mov    %ecx,%esi
  801337:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  801339:	5b                   	pop    %ebx
  80133a:	5e                   	pop    %esi
  80133b:	5f                   	pop    %edi
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    

0080133e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	53                   	push   %ebx
  801342:	83 ec 04             	sub    $0x4,%esp
  801345:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801348:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  80134a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80134e:	74 11                	je     801361 <pgfault+0x23>
  801350:	89 d8                	mov    %ebx,%eax
  801352:	c1 e8 0c             	shr    $0xc,%eax
  801355:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80135c:	f6 c4 08             	test   $0x8,%ah
  80135f:	75 14                	jne    801375 <pgfault+0x37>
		panic("faulting access");
  801361:	83 ec 04             	sub    $0x4,%esp
  801364:	68 ca 2e 80 00       	push   $0x802eca
  801369:	6a 1e                	push   $0x1e
  80136b:	68 da 2e 80 00       	push   $0x802eda
  801370:	e8 37 f3 ff ff       	call   8006ac <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  801375:	83 ec 04             	sub    $0x4,%esp
  801378:	6a 07                	push   $0x7
  80137a:	68 00 f0 7f 00       	push   $0x7ff000
  80137f:	6a 00                	push   $0x0
  801381:	e8 87 fd ff ff       	call   80110d <sys_page_alloc>
	if (r < 0) {
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	85 c0                	test   %eax,%eax
  80138b:	79 12                	jns    80139f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  80138d:	50                   	push   %eax
  80138e:	68 e5 2e 80 00       	push   $0x802ee5
  801393:	6a 2c                	push   $0x2c
  801395:	68 da 2e 80 00       	push   $0x802eda
  80139a:	e8 0d f3 ff ff       	call   8006ac <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80139f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  8013a5:	83 ec 04             	sub    $0x4,%esp
  8013a8:	68 00 10 00 00       	push   $0x1000
  8013ad:	53                   	push   %ebx
  8013ae:	68 00 f0 7f 00       	push   $0x7ff000
  8013b3:	e8 4c fb ff ff       	call   800f04 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  8013b8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8013bf:	53                   	push   %ebx
  8013c0:	6a 00                	push   $0x0
  8013c2:	68 00 f0 7f 00       	push   $0x7ff000
  8013c7:	6a 00                	push   $0x0
  8013c9:	e8 82 fd ff ff       	call   801150 <sys_page_map>
	if (r < 0) {
  8013ce:	83 c4 20             	add    $0x20,%esp
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	79 12                	jns    8013e7 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  8013d5:	50                   	push   %eax
  8013d6:	68 e5 2e 80 00       	push   $0x802ee5
  8013db:	6a 33                	push   $0x33
  8013dd:	68 da 2e 80 00       	push   $0x802eda
  8013e2:	e8 c5 f2 ff ff       	call   8006ac <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	68 00 f0 7f 00       	push   $0x7ff000
  8013ef:	6a 00                	push   $0x0
  8013f1:	e8 9c fd ff ff       	call   801192 <sys_page_unmap>
	if (r < 0) {
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	79 12                	jns    80140f <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  8013fd:	50                   	push   %eax
  8013fe:	68 e5 2e 80 00       	push   $0x802ee5
  801403:	6a 37                	push   $0x37
  801405:	68 da 2e 80 00       	push   $0x802eda
  80140a:	e8 9d f2 ff ff       	call   8006ac <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80140f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801412:	c9                   	leave  
  801413:	c3                   	ret    

00801414 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	57                   	push   %edi
  801418:	56                   	push   %esi
  801419:	53                   	push   %ebx
  80141a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80141d:	68 3e 13 80 00       	push   $0x80133e
  801422:	e8 0d 10 00 00       	call   802434 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801427:	b8 07 00 00 00       	mov    $0x7,%eax
  80142c:	cd 30                	int    $0x30
  80142e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	85 c0                	test   %eax,%eax
  801436:	79 17                	jns    80144f <fork+0x3b>
		panic("fork fault %e");
  801438:	83 ec 04             	sub    $0x4,%esp
  80143b:	68 fe 2e 80 00       	push   $0x802efe
  801440:	68 84 00 00 00       	push   $0x84
  801445:	68 da 2e 80 00       	push   $0x802eda
  80144a:	e8 5d f2 ff ff       	call   8006ac <_panic>
  80144f:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801451:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801455:	75 25                	jne    80147c <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  801457:	e8 73 fc ff ff       	call   8010cf <sys_getenvid>
  80145c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801461:	89 c2                	mov    %eax,%edx
  801463:	c1 e2 07             	shl    $0x7,%edx
  801466:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80146d:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  801472:	b8 00 00 00 00       	mov    $0x0,%eax
  801477:	e9 61 01 00 00       	jmp    8015dd <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80147c:	83 ec 04             	sub    $0x4,%esp
  80147f:	6a 07                	push   $0x7
  801481:	68 00 f0 bf ee       	push   $0xeebff000
  801486:	ff 75 e4             	pushl  -0x1c(%ebp)
  801489:	e8 7f fc ff ff       	call   80110d <sys_page_alloc>
  80148e:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801491:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801496:	89 d8                	mov    %ebx,%eax
  801498:	c1 e8 16             	shr    $0x16,%eax
  80149b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014a2:	a8 01                	test   $0x1,%al
  8014a4:	0f 84 fc 00 00 00    	je     8015a6 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  8014aa:	89 d8                	mov    %ebx,%eax
  8014ac:	c1 e8 0c             	shr    $0xc,%eax
  8014af:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8014b6:	f6 c2 01             	test   $0x1,%dl
  8014b9:	0f 84 e7 00 00 00    	je     8015a6 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  8014bf:	89 c6                	mov    %eax,%esi
  8014c1:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  8014c4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014cb:	f6 c6 04             	test   $0x4,%dh
  8014ce:	74 39                	je     801509 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8014d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d7:	83 ec 0c             	sub    $0xc,%esp
  8014da:	25 07 0e 00 00       	and    $0xe07,%eax
  8014df:	50                   	push   %eax
  8014e0:	56                   	push   %esi
  8014e1:	57                   	push   %edi
  8014e2:	56                   	push   %esi
  8014e3:	6a 00                	push   $0x0
  8014e5:	e8 66 fc ff ff       	call   801150 <sys_page_map>
		if (r < 0) {
  8014ea:	83 c4 20             	add    $0x20,%esp
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	0f 89 b1 00 00 00    	jns    8015a6 <fork+0x192>
		    	panic("sys page map fault %e");
  8014f5:	83 ec 04             	sub    $0x4,%esp
  8014f8:	68 0c 2f 80 00       	push   $0x802f0c
  8014fd:	6a 54                	push   $0x54
  8014ff:	68 da 2e 80 00       	push   $0x802eda
  801504:	e8 a3 f1 ff ff       	call   8006ac <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801509:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801510:	f6 c2 02             	test   $0x2,%dl
  801513:	75 0c                	jne    801521 <fork+0x10d>
  801515:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80151c:	f6 c4 08             	test   $0x8,%ah
  80151f:	74 5b                	je     80157c <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	68 05 08 00 00       	push   $0x805
  801529:	56                   	push   %esi
  80152a:	57                   	push   %edi
  80152b:	56                   	push   %esi
  80152c:	6a 00                	push   $0x0
  80152e:	e8 1d fc ff ff       	call   801150 <sys_page_map>
		if (r < 0) {
  801533:	83 c4 20             	add    $0x20,%esp
  801536:	85 c0                	test   %eax,%eax
  801538:	79 14                	jns    80154e <fork+0x13a>
		    	panic("sys page map fault %e");
  80153a:	83 ec 04             	sub    $0x4,%esp
  80153d:	68 0c 2f 80 00       	push   $0x802f0c
  801542:	6a 5b                	push   $0x5b
  801544:	68 da 2e 80 00       	push   $0x802eda
  801549:	e8 5e f1 ff ff       	call   8006ac <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80154e:	83 ec 0c             	sub    $0xc,%esp
  801551:	68 05 08 00 00       	push   $0x805
  801556:	56                   	push   %esi
  801557:	6a 00                	push   $0x0
  801559:	56                   	push   %esi
  80155a:	6a 00                	push   $0x0
  80155c:	e8 ef fb ff ff       	call   801150 <sys_page_map>
		if (r < 0) {
  801561:	83 c4 20             	add    $0x20,%esp
  801564:	85 c0                	test   %eax,%eax
  801566:	79 3e                	jns    8015a6 <fork+0x192>
		    	panic("sys page map fault %e");
  801568:	83 ec 04             	sub    $0x4,%esp
  80156b:	68 0c 2f 80 00       	push   $0x802f0c
  801570:	6a 5f                	push   $0x5f
  801572:	68 da 2e 80 00       	push   $0x802eda
  801577:	e8 30 f1 ff ff       	call   8006ac <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80157c:	83 ec 0c             	sub    $0xc,%esp
  80157f:	6a 05                	push   $0x5
  801581:	56                   	push   %esi
  801582:	57                   	push   %edi
  801583:	56                   	push   %esi
  801584:	6a 00                	push   $0x0
  801586:	e8 c5 fb ff ff       	call   801150 <sys_page_map>
		if (r < 0) {
  80158b:	83 c4 20             	add    $0x20,%esp
  80158e:	85 c0                	test   %eax,%eax
  801590:	79 14                	jns    8015a6 <fork+0x192>
		    	panic("sys page map fault %e");
  801592:	83 ec 04             	sub    $0x4,%esp
  801595:	68 0c 2f 80 00       	push   $0x802f0c
  80159a:	6a 64                	push   $0x64
  80159c:	68 da 2e 80 00       	push   $0x802eda
  8015a1:	e8 06 f1 ff ff       	call   8006ac <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8015a6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8015ac:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8015b2:	0f 85 de fe ff ff    	jne    801496 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8015b8:	a1 04 50 80 00       	mov    0x805004,%eax
  8015bd:	8b 40 70             	mov    0x70(%eax),%eax
  8015c0:	83 ec 08             	sub    $0x8,%esp
  8015c3:	50                   	push   %eax
  8015c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015c7:	57                   	push   %edi
  8015c8:	e8 8b fc ff ff       	call   801258 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8015cd:	83 c4 08             	add    $0x8,%esp
  8015d0:	6a 02                	push   $0x2
  8015d2:	57                   	push   %edi
  8015d3:	e8 fc fb ff ff       	call   8011d4 <sys_env_set_status>
	
	return envid;
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8015dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e0:	5b                   	pop    %ebx
  8015e1:	5e                   	pop    %esi
  8015e2:	5f                   	pop    %edi
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <sfork>:

envid_t
sfork(void)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8015e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    

008015ef <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	56                   	push   %esi
  8015f3:	53                   	push   %ebx
  8015f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8015f7:	89 1d 08 50 80 00    	mov    %ebx,0x805008
	cprintf("in fork.c thread create. func: %x\n", func);
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	53                   	push   %ebx
  801601:	68 24 2f 80 00       	push   $0x802f24
  801606:	e8 7a f1 ff ff       	call   800785 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80160b:	c7 04 24 72 06 80 00 	movl   $0x800672,(%esp)
  801612:	e8 e7 fc ff ff       	call   8012fe <sys_thread_create>
  801617:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801619:	83 c4 08             	add    $0x8,%esp
  80161c:	53                   	push   %ebx
  80161d:	68 24 2f 80 00       	push   $0x802f24
  801622:	e8 5e f1 ff ff       	call   800785 <cprintf>
	return id;
	//return 0;
}
  801627:	89 f0                	mov    %esi,%eax
  801629:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162c:	5b                   	pop    %ebx
  80162d:	5e                   	pop    %esi
  80162e:	5d                   	pop    %ebp
  80162f:	c3                   	ret    

00801630 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	56                   	push   %esi
  801634:	53                   	push   %ebx
  801635:	8b 75 08             	mov    0x8(%ebp),%esi
  801638:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80163e:	85 c0                	test   %eax,%eax
  801640:	75 12                	jne    801654 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801642:	83 ec 0c             	sub    $0xc,%esp
  801645:	68 00 00 c0 ee       	push   $0xeec00000
  80164a:	e8 6e fc ff ff       	call   8012bd <sys_ipc_recv>
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	eb 0c                	jmp    801660 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801654:	83 ec 0c             	sub    $0xc,%esp
  801657:	50                   	push   %eax
  801658:	e8 60 fc ff ff       	call   8012bd <sys_ipc_recv>
  80165d:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801660:	85 f6                	test   %esi,%esi
  801662:	0f 95 c1             	setne  %cl
  801665:	85 db                	test   %ebx,%ebx
  801667:	0f 95 c2             	setne  %dl
  80166a:	84 d1                	test   %dl,%cl
  80166c:	74 09                	je     801677 <ipc_recv+0x47>
  80166e:	89 c2                	mov    %eax,%edx
  801670:	c1 ea 1f             	shr    $0x1f,%edx
  801673:	84 d2                	test   %dl,%dl
  801675:	75 2a                	jne    8016a1 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801677:	85 f6                	test   %esi,%esi
  801679:	74 0d                	je     801688 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80167b:	a1 04 50 80 00       	mov    0x805004,%eax
  801680:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801686:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801688:	85 db                	test   %ebx,%ebx
  80168a:	74 0d                	je     801699 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80168c:	a1 04 50 80 00       	mov    0x805004,%eax
  801691:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801697:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801699:	a1 04 50 80 00       	mov    0x805004,%eax
  80169e:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  8016a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a4:	5b                   	pop    %ebx
  8016a5:	5e                   	pop    %esi
  8016a6:	5d                   	pop    %ebp
  8016a7:	c3                   	ret    

008016a8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	57                   	push   %edi
  8016ac:	56                   	push   %esi
  8016ad:	53                   	push   %ebx
  8016ae:	83 ec 0c             	sub    $0xc,%esp
  8016b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8016ba:	85 db                	test   %ebx,%ebx
  8016bc:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8016c1:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8016c4:	ff 75 14             	pushl  0x14(%ebp)
  8016c7:	53                   	push   %ebx
  8016c8:	56                   	push   %esi
  8016c9:	57                   	push   %edi
  8016ca:	e8 cb fb ff ff       	call   80129a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8016cf:	89 c2                	mov    %eax,%edx
  8016d1:	c1 ea 1f             	shr    $0x1f,%edx
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	84 d2                	test   %dl,%dl
  8016d9:	74 17                	je     8016f2 <ipc_send+0x4a>
  8016db:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8016de:	74 12                	je     8016f2 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8016e0:	50                   	push   %eax
  8016e1:	68 47 2f 80 00       	push   $0x802f47
  8016e6:	6a 47                	push   $0x47
  8016e8:	68 55 2f 80 00       	push   $0x802f55
  8016ed:	e8 ba ef ff ff       	call   8006ac <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8016f2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8016f5:	75 07                	jne    8016fe <ipc_send+0x56>
			sys_yield();
  8016f7:	e8 f2 f9 ff ff       	call   8010ee <sys_yield>
  8016fc:	eb c6                	jmp    8016c4 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8016fe:	85 c0                	test   %eax,%eax
  801700:	75 c2                	jne    8016c4 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801705:	5b                   	pop    %ebx
  801706:	5e                   	pop    %esi
  801707:	5f                   	pop    %edi
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    

0080170a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801710:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801715:	89 c2                	mov    %eax,%edx
  801717:	c1 e2 07             	shl    $0x7,%edx
  80171a:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801721:	8b 52 5c             	mov    0x5c(%edx),%edx
  801724:	39 ca                	cmp    %ecx,%edx
  801726:	75 11                	jne    801739 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801728:	89 c2                	mov    %eax,%edx
  80172a:	c1 e2 07             	shl    $0x7,%edx
  80172d:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801734:	8b 40 54             	mov    0x54(%eax),%eax
  801737:	eb 0f                	jmp    801748 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801739:	83 c0 01             	add    $0x1,%eax
  80173c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801741:	75 d2                	jne    801715 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801743:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80174d:	8b 45 08             	mov    0x8(%ebp),%eax
  801750:	05 00 00 00 30       	add    $0x30000000,%eax
  801755:	c1 e8 0c             	shr    $0xc,%eax
}
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80175d:	8b 45 08             	mov    0x8(%ebp),%eax
  801760:	05 00 00 00 30       	add    $0x30000000,%eax
  801765:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80176a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80176f:	5d                   	pop    %ebp
  801770:	c3                   	ret    

00801771 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801777:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80177c:	89 c2                	mov    %eax,%edx
  80177e:	c1 ea 16             	shr    $0x16,%edx
  801781:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801788:	f6 c2 01             	test   $0x1,%dl
  80178b:	74 11                	je     80179e <fd_alloc+0x2d>
  80178d:	89 c2                	mov    %eax,%edx
  80178f:	c1 ea 0c             	shr    $0xc,%edx
  801792:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801799:	f6 c2 01             	test   $0x1,%dl
  80179c:	75 09                	jne    8017a7 <fd_alloc+0x36>
			*fd_store = fd;
  80179e:	89 01                	mov    %eax,(%ecx)
			return 0;
  8017a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a5:	eb 17                	jmp    8017be <fd_alloc+0x4d>
  8017a7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8017ac:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8017b1:	75 c9                	jne    80177c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8017b3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8017b9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    

008017c0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8017c6:	83 f8 1f             	cmp    $0x1f,%eax
  8017c9:	77 36                	ja     801801 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8017cb:	c1 e0 0c             	shl    $0xc,%eax
  8017ce:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8017d3:	89 c2                	mov    %eax,%edx
  8017d5:	c1 ea 16             	shr    $0x16,%edx
  8017d8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8017df:	f6 c2 01             	test   $0x1,%dl
  8017e2:	74 24                	je     801808 <fd_lookup+0x48>
  8017e4:	89 c2                	mov    %eax,%edx
  8017e6:	c1 ea 0c             	shr    $0xc,%edx
  8017e9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017f0:	f6 c2 01             	test   $0x1,%dl
  8017f3:	74 1a                	je     80180f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8017f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f8:	89 02                	mov    %eax,(%edx)
	return 0;
  8017fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ff:	eb 13                	jmp    801814 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801801:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801806:	eb 0c                	jmp    801814 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801808:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80180d:	eb 05                	jmp    801814 <fd_lookup+0x54>
  80180f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	83 ec 08             	sub    $0x8,%esp
  80181c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80181f:	ba e0 2f 80 00       	mov    $0x802fe0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801824:	eb 13                	jmp    801839 <dev_lookup+0x23>
  801826:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801829:	39 08                	cmp    %ecx,(%eax)
  80182b:	75 0c                	jne    801839 <dev_lookup+0x23>
			*dev = devtab[i];
  80182d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801830:	89 01                	mov    %eax,(%ecx)
			return 0;
  801832:	b8 00 00 00 00       	mov    $0x0,%eax
  801837:	eb 2e                	jmp    801867 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801839:	8b 02                	mov    (%edx),%eax
  80183b:	85 c0                	test   %eax,%eax
  80183d:	75 e7                	jne    801826 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80183f:	a1 04 50 80 00       	mov    0x805004,%eax
  801844:	8b 40 54             	mov    0x54(%eax),%eax
  801847:	83 ec 04             	sub    $0x4,%esp
  80184a:	51                   	push   %ecx
  80184b:	50                   	push   %eax
  80184c:	68 60 2f 80 00       	push   $0x802f60
  801851:	e8 2f ef ff ff       	call   800785 <cprintf>
	*dev = 0;
  801856:	8b 45 0c             	mov    0xc(%ebp),%eax
  801859:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	56                   	push   %esi
  80186d:	53                   	push   %ebx
  80186e:	83 ec 10             	sub    $0x10,%esp
  801871:	8b 75 08             	mov    0x8(%ebp),%esi
  801874:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801877:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187a:	50                   	push   %eax
  80187b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801881:	c1 e8 0c             	shr    $0xc,%eax
  801884:	50                   	push   %eax
  801885:	e8 36 ff ff ff       	call   8017c0 <fd_lookup>
  80188a:	83 c4 08             	add    $0x8,%esp
  80188d:	85 c0                	test   %eax,%eax
  80188f:	78 05                	js     801896 <fd_close+0x2d>
	    || fd != fd2)
  801891:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801894:	74 0c                	je     8018a2 <fd_close+0x39>
		return (must_exist ? r : 0);
  801896:	84 db                	test   %bl,%bl
  801898:	ba 00 00 00 00       	mov    $0x0,%edx
  80189d:	0f 44 c2             	cmove  %edx,%eax
  8018a0:	eb 41                	jmp    8018e3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8018a2:	83 ec 08             	sub    $0x8,%esp
  8018a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a8:	50                   	push   %eax
  8018a9:	ff 36                	pushl  (%esi)
  8018ab:	e8 66 ff ff ff       	call   801816 <dev_lookup>
  8018b0:	89 c3                	mov    %eax,%ebx
  8018b2:	83 c4 10             	add    $0x10,%esp
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	78 1a                	js     8018d3 <fd_close+0x6a>
		if (dev->dev_close)
  8018b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8018bf:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	74 0b                	je     8018d3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8018c8:	83 ec 0c             	sub    $0xc,%esp
  8018cb:	56                   	push   %esi
  8018cc:	ff d0                	call   *%eax
  8018ce:	89 c3                	mov    %eax,%ebx
  8018d0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8018d3:	83 ec 08             	sub    $0x8,%esp
  8018d6:	56                   	push   %esi
  8018d7:	6a 00                	push   $0x0
  8018d9:	e8 b4 f8 ff ff       	call   801192 <sys_page_unmap>
	return r;
  8018de:	83 c4 10             	add    $0x10,%esp
  8018e1:	89 d8                	mov    %ebx,%eax
}
  8018e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e6:	5b                   	pop    %ebx
  8018e7:	5e                   	pop    %esi
  8018e8:	5d                   	pop    %ebp
  8018e9:	c3                   	ret    

008018ea <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f3:	50                   	push   %eax
  8018f4:	ff 75 08             	pushl  0x8(%ebp)
  8018f7:	e8 c4 fe ff ff       	call   8017c0 <fd_lookup>
  8018fc:	83 c4 08             	add    $0x8,%esp
  8018ff:	85 c0                	test   %eax,%eax
  801901:	78 10                	js     801913 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801903:	83 ec 08             	sub    $0x8,%esp
  801906:	6a 01                	push   $0x1
  801908:	ff 75 f4             	pushl  -0xc(%ebp)
  80190b:	e8 59 ff ff ff       	call   801869 <fd_close>
  801910:	83 c4 10             	add    $0x10,%esp
}
  801913:	c9                   	leave  
  801914:	c3                   	ret    

00801915 <close_all>:

void
close_all(void)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	53                   	push   %ebx
  801919:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80191c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801921:	83 ec 0c             	sub    $0xc,%esp
  801924:	53                   	push   %ebx
  801925:	e8 c0 ff ff ff       	call   8018ea <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80192a:	83 c3 01             	add    $0x1,%ebx
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	83 fb 20             	cmp    $0x20,%ebx
  801933:	75 ec                	jne    801921 <close_all+0xc>
		close(i);
}
  801935:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801938:	c9                   	leave  
  801939:	c3                   	ret    

0080193a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	57                   	push   %edi
  80193e:	56                   	push   %esi
  80193f:	53                   	push   %ebx
  801940:	83 ec 2c             	sub    $0x2c,%esp
  801943:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801946:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801949:	50                   	push   %eax
  80194a:	ff 75 08             	pushl  0x8(%ebp)
  80194d:	e8 6e fe ff ff       	call   8017c0 <fd_lookup>
  801952:	83 c4 08             	add    $0x8,%esp
  801955:	85 c0                	test   %eax,%eax
  801957:	0f 88 c1 00 00 00    	js     801a1e <dup+0xe4>
		return r;
	close(newfdnum);
  80195d:	83 ec 0c             	sub    $0xc,%esp
  801960:	56                   	push   %esi
  801961:	e8 84 ff ff ff       	call   8018ea <close>

	newfd = INDEX2FD(newfdnum);
  801966:	89 f3                	mov    %esi,%ebx
  801968:	c1 e3 0c             	shl    $0xc,%ebx
  80196b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801971:	83 c4 04             	add    $0x4,%esp
  801974:	ff 75 e4             	pushl  -0x1c(%ebp)
  801977:	e8 de fd ff ff       	call   80175a <fd2data>
  80197c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80197e:	89 1c 24             	mov    %ebx,(%esp)
  801981:	e8 d4 fd ff ff       	call   80175a <fd2data>
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80198c:	89 f8                	mov    %edi,%eax
  80198e:	c1 e8 16             	shr    $0x16,%eax
  801991:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801998:	a8 01                	test   $0x1,%al
  80199a:	74 37                	je     8019d3 <dup+0x99>
  80199c:	89 f8                	mov    %edi,%eax
  80199e:	c1 e8 0c             	shr    $0xc,%eax
  8019a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019a8:	f6 c2 01             	test   $0x1,%dl
  8019ab:	74 26                	je     8019d3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8019ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019b4:	83 ec 0c             	sub    $0xc,%esp
  8019b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8019bc:	50                   	push   %eax
  8019bd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8019c0:	6a 00                	push   $0x0
  8019c2:	57                   	push   %edi
  8019c3:	6a 00                	push   $0x0
  8019c5:	e8 86 f7 ff ff       	call   801150 <sys_page_map>
  8019ca:	89 c7                	mov    %eax,%edi
  8019cc:	83 c4 20             	add    $0x20,%esp
  8019cf:	85 c0                	test   %eax,%eax
  8019d1:	78 2e                	js     801a01 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8019d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8019d6:	89 d0                	mov    %edx,%eax
  8019d8:	c1 e8 0c             	shr    $0xc,%eax
  8019db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019e2:	83 ec 0c             	sub    $0xc,%esp
  8019e5:	25 07 0e 00 00       	and    $0xe07,%eax
  8019ea:	50                   	push   %eax
  8019eb:	53                   	push   %ebx
  8019ec:	6a 00                	push   $0x0
  8019ee:	52                   	push   %edx
  8019ef:	6a 00                	push   $0x0
  8019f1:	e8 5a f7 ff ff       	call   801150 <sys_page_map>
  8019f6:	89 c7                	mov    %eax,%edi
  8019f8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8019fb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8019fd:	85 ff                	test   %edi,%edi
  8019ff:	79 1d                	jns    801a1e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a01:	83 ec 08             	sub    $0x8,%esp
  801a04:	53                   	push   %ebx
  801a05:	6a 00                	push   $0x0
  801a07:	e8 86 f7 ff ff       	call   801192 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a0c:	83 c4 08             	add    $0x8,%esp
  801a0f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801a12:	6a 00                	push   $0x0
  801a14:	e8 79 f7 ff ff       	call   801192 <sys_page_unmap>
	return r;
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	89 f8                	mov    %edi,%eax
}
  801a1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a21:	5b                   	pop    %ebx
  801a22:	5e                   	pop    %esi
  801a23:	5f                   	pop    %edi
  801a24:	5d                   	pop    %ebp
  801a25:	c3                   	ret    

00801a26 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	53                   	push   %ebx
  801a2a:	83 ec 14             	sub    $0x14,%esp
  801a2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a30:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a33:	50                   	push   %eax
  801a34:	53                   	push   %ebx
  801a35:	e8 86 fd ff ff       	call   8017c0 <fd_lookup>
  801a3a:	83 c4 08             	add    $0x8,%esp
  801a3d:	89 c2                	mov    %eax,%edx
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	78 6d                	js     801ab0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a43:	83 ec 08             	sub    $0x8,%esp
  801a46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a49:	50                   	push   %eax
  801a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a4d:	ff 30                	pushl  (%eax)
  801a4f:	e8 c2 fd ff ff       	call   801816 <dev_lookup>
  801a54:	83 c4 10             	add    $0x10,%esp
  801a57:	85 c0                	test   %eax,%eax
  801a59:	78 4c                	js     801aa7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a5e:	8b 42 08             	mov    0x8(%edx),%eax
  801a61:	83 e0 03             	and    $0x3,%eax
  801a64:	83 f8 01             	cmp    $0x1,%eax
  801a67:	75 21                	jne    801a8a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a69:	a1 04 50 80 00       	mov    0x805004,%eax
  801a6e:	8b 40 54             	mov    0x54(%eax),%eax
  801a71:	83 ec 04             	sub    $0x4,%esp
  801a74:	53                   	push   %ebx
  801a75:	50                   	push   %eax
  801a76:	68 a4 2f 80 00       	push   $0x802fa4
  801a7b:	e8 05 ed ff ff       	call   800785 <cprintf>
		return -E_INVAL;
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801a88:	eb 26                	jmp    801ab0 <read+0x8a>
	}
	if (!dev->dev_read)
  801a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8d:	8b 40 08             	mov    0x8(%eax),%eax
  801a90:	85 c0                	test   %eax,%eax
  801a92:	74 17                	je     801aab <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801a94:	83 ec 04             	sub    $0x4,%esp
  801a97:	ff 75 10             	pushl  0x10(%ebp)
  801a9a:	ff 75 0c             	pushl  0xc(%ebp)
  801a9d:	52                   	push   %edx
  801a9e:	ff d0                	call   *%eax
  801aa0:	89 c2                	mov    %eax,%edx
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	eb 09                	jmp    801ab0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801aa7:	89 c2                	mov    %eax,%edx
  801aa9:	eb 05                	jmp    801ab0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801aab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801ab0:	89 d0                	mov    %edx,%eax
  801ab2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	57                   	push   %edi
  801abb:	56                   	push   %esi
  801abc:	53                   	push   %ebx
  801abd:	83 ec 0c             	sub    $0xc,%esp
  801ac0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ac3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ac6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801acb:	eb 21                	jmp    801aee <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	89 f0                	mov    %esi,%eax
  801ad2:	29 d8                	sub    %ebx,%eax
  801ad4:	50                   	push   %eax
  801ad5:	89 d8                	mov    %ebx,%eax
  801ad7:	03 45 0c             	add    0xc(%ebp),%eax
  801ada:	50                   	push   %eax
  801adb:	57                   	push   %edi
  801adc:	e8 45 ff ff ff       	call   801a26 <read>
		if (m < 0)
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	78 10                	js     801af8 <readn+0x41>
			return m;
		if (m == 0)
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	74 0a                	je     801af6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801aec:	01 c3                	add    %eax,%ebx
  801aee:	39 f3                	cmp    %esi,%ebx
  801af0:	72 db                	jb     801acd <readn+0x16>
  801af2:	89 d8                	mov    %ebx,%eax
  801af4:	eb 02                	jmp    801af8 <readn+0x41>
  801af6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801af8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afb:	5b                   	pop    %ebx
  801afc:	5e                   	pop    %esi
  801afd:	5f                   	pop    %edi
  801afe:	5d                   	pop    %ebp
  801aff:	c3                   	ret    

00801b00 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	53                   	push   %ebx
  801b04:	83 ec 14             	sub    $0x14,%esp
  801b07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b0d:	50                   	push   %eax
  801b0e:	53                   	push   %ebx
  801b0f:	e8 ac fc ff ff       	call   8017c0 <fd_lookup>
  801b14:	83 c4 08             	add    $0x8,%esp
  801b17:	89 c2                	mov    %eax,%edx
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	78 68                	js     801b85 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b1d:	83 ec 08             	sub    $0x8,%esp
  801b20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b23:	50                   	push   %eax
  801b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b27:	ff 30                	pushl  (%eax)
  801b29:	e8 e8 fc ff ff       	call   801816 <dev_lookup>
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	85 c0                	test   %eax,%eax
  801b33:	78 47                	js     801b7c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b38:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b3c:	75 21                	jne    801b5f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b3e:	a1 04 50 80 00       	mov    0x805004,%eax
  801b43:	8b 40 54             	mov    0x54(%eax),%eax
  801b46:	83 ec 04             	sub    $0x4,%esp
  801b49:	53                   	push   %ebx
  801b4a:	50                   	push   %eax
  801b4b:	68 c0 2f 80 00       	push   $0x802fc0
  801b50:	e8 30 ec ff ff       	call   800785 <cprintf>
		return -E_INVAL;
  801b55:	83 c4 10             	add    $0x10,%esp
  801b58:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801b5d:	eb 26                	jmp    801b85 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b62:	8b 52 0c             	mov    0xc(%edx),%edx
  801b65:	85 d2                	test   %edx,%edx
  801b67:	74 17                	je     801b80 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b69:	83 ec 04             	sub    $0x4,%esp
  801b6c:	ff 75 10             	pushl  0x10(%ebp)
  801b6f:	ff 75 0c             	pushl  0xc(%ebp)
  801b72:	50                   	push   %eax
  801b73:	ff d2                	call   *%edx
  801b75:	89 c2                	mov    %eax,%edx
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	eb 09                	jmp    801b85 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b7c:	89 c2                	mov    %eax,%edx
  801b7e:	eb 05                	jmp    801b85 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801b80:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801b85:	89 d0                	mov    %edx,%eax
  801b87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8a:	c9                   	leave  
  801b8b:	c3                   	ret    

00801b8c <seek>:

int
seek(int fdnum, off_t offset)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b92:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b95:	50                   	push   %eax
  801b96:	ff 75 08             	pushl  0x8(%ebp)
  801b99:	e8 22 fc ff ff       	call   8017c0 <fd_lookup>
  801b9e:	83 c4 08             	add    $0x8,%esp
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	78 0e                	js     801bb3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801ba5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ba8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bab:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801bae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bb3:	c9                   	leave  
  801bb4:	c3                   	ret    

00801bb5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	53                   	push   %ebx
  801bb9:	83 ec 14             	sub    $0x14,%esp
  801bbc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bbf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bc2:	50                   	push   %eax
  801bc3:	53                   	push   %ebx
  801bc4:	e8 f7 fb ff ff       	call   8017c0 <fd_lookup>
  801bc9:	83 c4 08             	add    $0x8,%esp
  801bcc:	89 c2                	mov    %eax,%edx
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	78 65                	js     801c37 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bd2:	83 ec 08             	sub    $0x8,%esp
  801bd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd8:	50                   	push   %eax
  801bd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bdc:	ff 30                	pushl  (%eax)
  801bde:	e8 33 fc ff ff       	call   801816 <dev_lookup>
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	85 c0                	test   %eax,%eax
  801be8:	78 44                	js     801c2e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801bf1:	75 21                	jne    801c14 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801bf3:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801bf8:	8b 40 54             	mov    0x54(%eax),%eax
  801bfb:	83 ec 04             	sub    $0x4,%esp
  801bfe:	53                   	push   %ebx
  801bff:	50                   	push   %eax
  801c00:	68 80 2f 80 00       	push   $0x802f80
  801c05:	e8 7b eb ff ff       	call   800785 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801c12:	eb 23                	jmp    801c37 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801c14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c17:	8b 52 18             	mov    0x18(%edx),%edx
  801c1a:	85 d2                	test   %edx,%edx
  801c1c:	74 14                	je     801c32 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801c1e:	83 ec 08             	sub    $0x8,%esp
  801c21:	ff 75 0c             	pushl  0xc(%ebp)
  801c24:	50                   	push   %eax
  801c25:	ff d2                	call   *%edx
  801c27:	89 c2                	mov    %eax,%edx
  801c29:	83 c4 10             	add    $0x10,%esp
  801c2c:	eb 09                	jmp    801c37 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c2e:	89 c2                	mov    %eax,%edx
  801c30:	eb 05                	jmp    801c37 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801c32:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801c37:	89 d0                	mov    %edx,%eax
  801c39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c3c:	c9                   	leave  
  801c3d:	c3                   	ret    

00801c3e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	53                   	push   %ebx
  801c42:	83 ec 14             	sub    $0x14,%esp
  801c45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c48:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c4b:	50                   	push   %eax
  801c4c:	ff 75 08             	pushl  0x8(%ebp)
  801c4f:	e8 6c fb ff ff       	call   8017c0 <fd_lookup>
  801c54:	83 c4 08             	add    $0x8,%esp
  801c57:	89 c2                	mov    %eax,%edx
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	78 58                	js     801cb5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c5d:	83 ec 08             	sub    $0x8,%esp
  801c60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c63:	50                   	push   %eax
  801c64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c67:	ff 30                	pushl  (%eax)
  801c69:	e8 a8 fb ff ff       	call   801816 <dev_lookup>
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	85 c0                	test   %eax,%eax
  801c73:	78 37                	js     801cac <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c78:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801c7c:	74 32                	je     801cb0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c7e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c81:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c88:	00 00 00 
	stat->st_isdir = 0;
  801c8b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c92:	00 00 00 
	stat->st_dev = dev;
  801c95:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c9b:	83 ec 08             	sub    $0x8,%esp
  801c9e:	53                   	push   %ebx
  801c9f:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca2:	ff 50 14             	call   *0x14(%eax)
  801ca5:	89 c2                	mov    %eax,%edx
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	eb 09                	jmp    801cb5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cac:	89 c2                	mov    %eax,%edx
  801cae:	eb 05                	jmp    801cb5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801cb0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801cb5:	89 d0                	mov    %edx,%eax
  801cb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cba:	c9                   	leave  
  801cbb:	c3                   	ret    

00801cbc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	56                   	push   %esi
  801cc0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801cc1:	83 ec 08             	sub    $0x8,%esp
  801cc4:	6a 00                	push   $0x0
  801cc6:	ff 75 08             	pushl  0x8(%ebp)
  801cc9:	e8 e3 01 00 00       	call   801eb1 <open>
  801cce:	89 c3                	mov    %eax,%ebx
  801cd0:	83 c4 10             	add    $0x10,%esp
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	78 1b                	js     801cf2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801cd7:	83 ec 08             	sub    $0x8,%esp
  801cda:	ff 75 0c             	pushl  0xc(%ebp)
  801cdd:	50                   	push   %eax
  801cde:	e8 5b ff ff ff       	call   801c3e <fstat>
  801ce3:	89 c6                	mov    %eax,%esi
	close(fd);
  801ce5:	89 1c 24             	mov    %ebx,(%esp)
  801ce8:	e8 fd fb ff ff       	call   8018ea <close>
	return r;
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	89 f0                	mov    %esi,%eax
}
  801cf2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf5:	5b                   	pop    %ebx
  801cf6:	5e                   	pop    %esi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    

00801cf9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	56                   	push   %esi
  801cfd:	53                   	push   %ebx
  801cfe:	89 c6                	mov    %eax,%esi
  801d00:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801d02:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801d09:	75 12                	jne    801d1d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d0b:	83 ec 0c             	sub    $0xc,%esp
  801d0e:	6a 01                	push   $0x1
  801d10:	e8 f5 f9 ff ff       	call   80170a <ipc_find_env>
  801d15:	a3 00 50 80 00       	mov    %eax,0x805000
  801d1a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d1d:	6a 07                	push   $0x7
  801d1f:	68 00 60 80 00       	push   $0x806000
  801d24:	56                   	push   %esi
  801d25:	ff 35 00 50 80 00    	pushl  0x805000
  801d2b:	e8 78 f9 ff ff       	call   8016a8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d30:	83 c4 0c             	add    $0xc,%esp
  801d33:	6a 00                	push   $0x0
  801d35:	53                   	push   %ebx
  801d36:	6a 00                	push   $0x0
  801d38:	e8 f3 f8 ff ff       	call   801630 <ipc_recv>
}
  801d3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d40:	5b                   	pop    %ebx
  801d41:	5e                   	pop    %esi
  801d42:	5d                   	pop    %ebp
  801d43:	c3                   	ret    

00801d44 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d50:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801d55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d58:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d62:	b8 02 00 00 00       	mov    $0x2,%eax
  801d67:	e8 8d ff ff ff       	call   801cf9 <fsipc>
}
  801d6c:	c9                   	leave  
  801d6d:	c3                   	ret    

00801d6e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d74:	8b 45 08             	mov    0x8(%ebp),%eax
  801d77:	8b 40 0c             	mov    0xc(%eax),%eax
  801d7a:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801d7f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d84:	b8 06 00 00 00       	mov    $0x6,%eax
  801d89:	e8 6b ff ff ff       	call   801cf9 <fsipc>
}
  801d8e:	c9                   	leave  
  801d8f:	c3                   	ret    

00801d90 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	53                   	push   %ebx
  801d94:	83 ec 04             	sub    $0x4,%esp
  801d97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9d:	8b 40 0c             	mov    0xc(%eax),%eax
  801da0:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801da5:	ba 00 00 00 00       	mov    $0x0,%edx
  801daa:	b8 05 00 00 00       	mov    $0x5,%eax
  801daf:	e8 45 ff ff ff       	call   801cf9 <fsipc>
  801db4:	85 c0                	test   %eax,%eax
  801db6:	78 2c                	js     801de4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801db8:	83 ec 08             	sub    $0x8,%esp
  801dbb:	68 00 60 80 00       	push   $0x806000
  801dc0:	53                   	push   %ebx
  801dc1:	e8 44 ef ff ff       	call   800d0a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801dc6:	a1 80 60 80 00       	mov    0x806080,%eax
  801dcb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801dd1:	a1 84 60 80 00       	mov    0x806084,%eax
  801dd6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ddc:	83 c4 10             	add    $0x10,%esp
  801ddf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801de4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de7:	c9                   	leave  
  801de8:	c3                   	ret    

00801de9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	83 ec 0c             	sub    $0xc,%esp
  801def:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801df2:	8b 55 08             	mov    0x8(%ebp),%edx
  801df5:	8b 52 0c             	mov    0xc(%edx),%edx
  801df8:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801dfe:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801e03:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801e08:	0f 47 c2             	cmova  %edx,%eax
  801e0b:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801e10:	50                   	push   %eax
  801e11:	ff 75 0c             	pushl  0xc(%ebp)
  801e14:	68 08 60 80 00       	push   $0x806008
  801e19:	e8 7e f0 ff ff       	call   800e9c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801e1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801e23:	b8 04 00 00 00       	mov    $0x4,%eax
  801e28:	e8 cc fe ff ff       	call   801cf9 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801e2d:	c9                   	leave  
  801e2e:	c3                   	ret    

00801e2f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	56                   	push   %esi
  801e33:	53                   	push   %ebx
  801e34:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e37:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e3d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801e42:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e48:	ba 00 00 00 00       	mov    $0x0,%edx
  801e4d:	b8 03 00 00 00       	mov    $0x3,%eax
  801e52:	e8 a2 fe ff ff       	call   801cf9 <fsipc>
  801e57:	89 c3                	mov    %eax,%ebx
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	78 4b                	js     801ea8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801e5d:	39 c6                	cmp    %eax,%esi
  801e5f:	73 16                	jae    801e77 <devfile_read+0x48>
  801e61:	68 f0 2f 80 00       	push   $0x802ff0
  801e66:	68 f7 2f 80 00       	push   $0x802ff7
  801e6b:	6a 7c                	push   $0x7c
  801e6d:	68 0c 30 80 00       	push   $0x80300c
  801e72:	e8 35 e8 ff ff       	call   8006ac <_panic>
	assert(r <= PGSIZE);
  801e77:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e7c:	7e 16                	jle    801e94 <devfile_read+0x65>
  801e7e:	68 17 30 80 00       	push   $0x803017
  801e83:	68 f7 2f 80 00       	push   $0x802ff7
  801e88:	6a 7d                	push   $0x7d
  801e8a:	68 0c 30 80 00       	push   $0x80300c
  801e8f:	e8 18 e8 ff ff       	call   8006ac <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e94:	83 ec 04             	sub    $0x4,%esp
  801e97:	50                   	push   %eax
  801e98:	68 00 60 80 00       	push   $0x806000
  801e9d:	ff 75 0c             	pushl  0xc(%ebp)
  801ea0:	e8 f7 ef ff ff       	call   800e9c <memmove>
	return r;
  801ea5:	83 c4 10             	add    $0x10,%esp
}
  801ea8:	89 d8                	mov    %ebx,%eax
  801eaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ead:	5b                   	pop    %ebx
  801eae:	5e                   	pop    %esi
  801eaf:	5d                   	pop    %ebp
  801eb0:	c3                   	ret    

00801eb1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	53                   	push   %ebx
  801eb5:	83 ec 20             	sub    $0x20,%esp
  801eb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ebb:	53                   	push   %ebx
  801ebc:	e8 10 ee ff ff       	call   800cd1 <strlen>
  801ec1:	83 c4 10             	add    $0x10,%esp
  801ec4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ec9:	7f 67                	jg     801f32 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ecb:	83 ec 0c             	sub    $0xc,%esp
  801ece:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed1:	50                   	push   %eax
  801ed2:	e8 9a f8 ff ff       	call   801771 <fd_alloc>
  801ed7:	83 c4 10             	add    $0x10,%esp
		return r;
  801eda:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801edc:	85 c0                	test   %eax,%eax
  801ede:	78 57                	js     801f37 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ee0:	83 ec 08             	sub    $0x8,%esp
  801ee3:	53                   	push   %ebx
  801ee4:	68 00 60 80 00       	push   $0x806000
  801ee9:	e8 1c ee ff ff       	call   800d0a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801eee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef1:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ef6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ef9:	b8 01 00 00 00       	mov    $0x1,%eax
  801efe:	e8 f6 fd ff ff       	call   801cf9 <fsipc>
  801f03:	89 c3                	mov    %eax,%ebx
  801f05:	83 c4 10             	add    $0x10,%esp
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	79 14                	jns    801f20 <open+0x6f>
		fd_close(fd, 0);
  801f0c:	83 ec 08             	sub    $0x8,%esp
  801f0f:	6a 00                	push   $0x0
  801f11:	ff 75 f4             	pushl  -0xc(%ebp)
  801f14:	e8 50 f9 ff ff       	call   801869 <fd_close>
		return r;
  801f19:	83 c4 10             	add    $0x10,%esp
  801f1c:	89 da                	mov    %ebx,%edx
  801f1e:	eb 17                	jmp    801f37 <open+0x86>
	}

	return fd2num(fd);
  801f20:	83 ec 0c             	sub    $0xc,%esp
  801f23:	ff 75 f4             	pushl  -0xc(%ebp)
  801f26:	e8 1f f8 ff ff       	call   80174a <fd2num>
  801f2b:	89 c2                	mov    %eax,%edx
  801f2d:	83 c4 10             	add    $0x10,%esp
  801f30:	eb 05                	jmp    801f37 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801f32:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801f37:	89 d0                	mov    %edx,%eax
  801f39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f3c:	c9                   	leave  
  801f3d:	c3                   	ret    

00801f3e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f44:	ba 00 00 00 00       	mov    $0x0,%edx
  801f49:	b8 08 00 00 00       	mov    $0x8,%eax
  801f4e:	e8 a6 fd ff ff       	call   801cf9 <fsipc>
}
  801f53:	c9                   	leave  
  801f54:	c3                   	ret    

00801f55 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	56                   	push   %esi
  801f59:	53                   	push   %ebx
  801f5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f5d:	83 ec 0c             	sub    $0xc,%esp
  801f60:	ff 75 08             	pushl  0x8(%ebp)
  801f63:	e8 f2 f7 ff ff       	call   80175a <fd2data>
  801f68:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f6a:	83 c4 08             	add    $0x8,%esp
  801f6d:	68 23 30 80 00       	push   $0x803023
  801f72:	53                   	push   %ebx
  801f73:	e8 92 ed ff ff       	call   800d0a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f78:	8b 46 04             	mov    0x4(%esi),%eax
  801f7b:	2b 06                	sub    (%esi),%eax
  801f7d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f83:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f8a:	00 00 00 
	stat->st_dev = &devpipe;
  801f8d:	c7 83 88 00 00 00 24 	movl   $0x804024,0x88(%ebx)
  801f94:	40 80 00 
	return 0;
}
  801f97:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f9f:	5b                   	pop    %ebx
  801fa0:	5e                   	pop    %esi
  801fa1:	5d                   	pop    %ebp
  801fa2:	c3                   	ret    

00801fa3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	53                   	push   %ebx
  801fa7:	83 ec 0c             	sub    $0xc,%esp
  801faa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fad:	53                   	push   %ebx
  801fae:	6a 00                	push   $0x0
  801fb0:	e8 dd f1 ff ff       	call   801192 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fb5:	89 1c 24             	mov    %ebx,(%esp)
  801fb8:	e8 9d f7 ff ff       	call   80175a <fd2data>
  801fbd:	83 c4 08             	add    $0x8,%esp
  801fc0:	50                   	push   %eax
  801fc1:	6a 00                	push   $0x0
  801fc3:	e8 ca f1 ff ff       	call   801192 <sys_page_unmap>
}
  801fc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fcb:	c9                   	leave  
  801fcc:	c3                   	ret    

00801fcd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	57                   	push   %edi
  801fd1:	56                   	push   %esi
  801fd2:	53                   	push   %ebx
  801fd3:	83 ec 1c             	sub    $0x1c,%esp
  801fd6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fd9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fdb:	a1 04 50 80 00       	mov    0x805004,%eax
  801fe0:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fe3:	83 ec 0c             	sub    $0xc,%esp
  801fe6:	ff 75 e0             	pushl  -0x20(%ebp)
  801fe9:	e8 d5 04 00 00       	call   8024c3 <pageref>
  801fee:	89 c3                	mov    %eax,%ebx
  801ff0:	89 3c 24             	mov    %edi,(%esp)
  801ff3:	e8 cb 04 00 00       	call   8024c3 <pageref>
  801ff8:	83 c4 10             	add    $0x10,%esp
  801ffb:	39 c3                	cmp    %eax,%ebx
  801ffd:	0f 94 c1             	sete   %cl
  802000:	0f b6 c9             	movzbl %cl,%ecx
  802003:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802006:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80200c:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  80200f:	39 ce                	cmp    %ecx,%esi
  802011:	74 1b                	je     80202e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802013:	39 c3                	cmp    %eax,%ebx
  802015:	75 c4                	jne    801fdb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802017:	8b 42 64             	mov    0x64(%edx),%eax
  80201a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80201d:	50                   	push   %eax
  80201e:	56                   	push   %esi
  80201f:	68 2a 30 80 00       	push   $0x80302a
  802024:	e8 5c e7 ff ff       	call   800785 <cprintf>
  802029:	83 c4 10             	add    $0x10,%esp
  80202c:	eb ad                	jmp    801fdb <_pipeisclosed+0xe>
	}
}
  80202e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802031:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802034:	5b                   	pop    %ebx
  802035:	5e                   	pop    %esi
  802036:	5f                   	pop    %edi
  802037:	5d                   	pop    %ebp
  802038:	c3                   	ret    

00802039 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802039:	55                   	push   %ebp
  80203a:	89 e5                	mov    %esp,%ebp
  80203c:	57                   	push   %edi
  80203d:	56                   	push   %esi
  80203e:	53                   	push   %ebx
  80203f:	83 ec 28             	sub    $0x28,%esp
  802042:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802045:	56                   	push   %esi
  802046:	e8 0f f7 ff ff       	call   80175a <fd2data>
  80204b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80204d:	83 c4 10             	add    $0x10,%esp
  802050:	bf 00 00 00 00       	mov    $0x0,%edi
  802055:	eb 4b                	jmp    8020a2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802057:	89 da                	mov    %ebx,%edx
  802059:	89 f0                	mov    %esi,%eax
  80205b:	e8 6d ff ff ff       	call   801fcd <_pipeisclosed>
  802060:	85 c0                	test   %eax,%eax
  802062:	75 48                	jne    8020ac <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802064:	e8 85 f0 ff ff       	call   8010ee <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802069:	8b 43 04             	mov    0x4(%ebx),%eax
  80206c:	8b 0b                	mov    (%ebx),%ecx
  80206e:	8d 51 20             	lea    0x20(%ecx),%edx
  802071:	39 d0                	cmp    %edx,%eax
  802073:	73 e2                	jae    802057 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802075:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802078:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80207c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80207f:	89 c2                	mov    %eax,%edx
  802081:	c1 fa 1f             	sar    $0x1f,%edx
  802084:	89 d1                	mov    %edx,%ecx
  802086:	c1 e9 1b             	shr    $0x1b,%ecx
  802089:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80208c:	83 e2 1f             	and    $0x1f,%edx
  80208f:	29 ca                	sub    %ecx,%edx
  802091:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802095:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802099:	83 c0 01             	add    $0x1,%eax
  80209c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80209f:	83 c7 01             	add    $0x1,%edi
  8020a2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020a5:	75 c2                	jne    802069 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8020aa:	eb 05                	jmp    8020b1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020ac:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5f                   	pop    %edi
  8020b7:	5d                   	pop    %ebp
  8020b8:	c3                   	ret    

008020b9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020b9:	55                   	push   %ebp
  8020ba:	89 e5                	mov    %esp,%ebp
  8020bc:	57                   	push   %edi
  8020bd:	56                   	push   %esi
  8020be:	53                   	push   %ebx
  8020bf:	83 ec 18             	sub    $0x18,%esp
  8020c2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020c5:	57                   	push   %edi
  8020c6:	e8 8f f6 ff ff       	call   80175a <fd2data>
  8020cb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020cd:	83 c4 10             	add    $0x10,%esp
  8020d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020d5:	eb 3d                	jmp    802114 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020d7:	85 db                	test   %ebx,%ebx
  8020d9:	74 04                	je     8020df <devpipe_read+0x26>
				return i;
  8020db:	89 d8                	mov    %ebx,%eax
  8020dd:	eb 44                	jmp    802123 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020df:	89 f2                	mov    %esi,%edx
  8020e1:	89 f8                	mov    %edi,%eax
  8020e3:	e8 e5 fe ff ff       	call   801fcd <_pipeisclosed>
  8020e8:	85 c0                	test   %eax,%eax
  8020ea:	75 32                	jne    80211e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020ec:	e8 fd ef ff ff       	call   8010ee <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020f1:	8b 06                	mov    (%esi),%eax
  8020f3:	3b 46 04             	cmp    0x4(%esi),%eax
  8020f6:	74 df                	je     8020d7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020f8:	99                   	cltd   
  8020f9:	c1 ea 1b             	shr    $0x1b,%edx
  8020fc:	01 d0                	add    %edx,%eax
  8020fe:	83 e0 1f             	and    $0x1f,%eax
  802101:	29 d0                	sub    %edx,%eax
  802103:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802108:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80210b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80210e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802111:	83 c3 01             	add    $0x1,%ebx
  802114:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802117:	75 d8                	jne    8020f1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802119:	8b 45 10             	mov    0x10(%ebp),%eax
  80211c:	eb 05                	jmp    802123 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80211e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802123:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802126:	5b                   	pop    %ebx
  802127:	5e                   	pop    %esi
  802128:	5f                   	pop    %edi
  802129:	5d                   	pop    %ebp
  80212a:	c3                   	ret    

0080212b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80212b:	55                   	push   %ebp
  80212c:	89 e5                	mov    %esp,%ebp
  80212e:	56                   	push   %esi
  80212f:	53                   	push   %ebx
  802130:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802133:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802136:	50                   	push   %eax
  802137:	e8 35 f6 ff ff       	call   801771 <fd_alloc>
  80213c:	83 c4 10             	add    $0x10,%esp
  80213f:	89 c2                	mov    %eax,%edx
  802141:	85 c0                	test   %eax,%eax
  802143:	0f 88 2c 01 00 00    	js     802275 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802149:	83 ec 04             	sub    $0x4,%esp
  80214c:	68 07 04 00 00       	push   $0x407
  802151:	ff 75 f4             	pushl  -0xc(%ebp)
  802154:	6a 00                	push   $0x0
  802156:	e8 b2 ef ff ff       	call   80110d <sys_page_alloc>
  80215b:	83 c4 10             	add    $0x10,%esp
  80215e:	89 c2                	mov    %eax,%edx
  802160:	85 c0                	test   %eax,%eax
  802162:	0f 88 0d 01 00 00    	js     802275 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802168:	83 ec 0c             	sub    $0xc,%esp
  80216b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80216e:	50                   	push   %eax
  80216f:	e8 fd f5 ff ff       	call   801771 <fd_alloc>
  802174:	89 c3                	mov    %eax,%ebx
  802176:	83 c4 10             	add    $0x10,%esp
  802179:	85 c0                	test   %eax,%eax
  80217b:	0f 88 e2 00 00 00    	js     802263 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802181:	83 ec 04             	sub    $0x4,%esp
  802184:	68 07 04 00 00       	push   $0x407
  802189:	ff 75 f0             	pushl  -0x10(%ebp)
  80218c:	6a 00                	push   $0x0
  80218e:	e8 7a ef ff ff       	call   80110d <sys_page_alloc>
  802193:	89 c3                	mov    %eax,%ebx
  802195:	83 c4 10             	add    $0x10,%esp
  802198:	85 c0                	test   %eax,%eax
  80219a:	0f 88 c3 00 00 00    	js     802263 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021a0:	83 ec 0c             	sub    $0xc,%esp
  8021a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8021a6:	e8 af f5 ff ff       	call   80175a <fd2data>
  8021ab:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ad:	83 c4 0c             	add    $0xc,%esp
  8021b0:	68 07 04 00 00       	push   $0x407
  8021b5:	50                   	push   %eax
  8021b6:	6a 00                	push   $0x0
  8021b8:	e8 50 ef ff ff       	call   80110d <sys_page_alloc>
  8021bd:	89 c3                	mov    %eax,%ebx
  8021bf:	83 c4 10             	add    $0x10,%esp
  8021c2:	85 c0                	test   %eax,%eax
  8021c4:	0f 88 89 00 00 00    	js     802253 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ca:	83 ec 0c             	sub    $0xc,%esp
  8021cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8021d0:	e8 85 f5 ff ff       	call   80175a <fd2data>
  8021d5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021dc:	50                   	push   %eax
  8021dd:	6a 00                	push   $0x0
  8021df:	56                   	push   %esi
  8021e0:	6a 00                	push   $0x0
  8021e2:	e8 69 ef ff ff       	call   801150 <sys_page_map>
  8021e7:	89 c3                	mov    %eax,%ebx
  8021e9:	83 c4 20             	add    $0x20,%esp
  8021ec:	85 c0                	test   %eax,%eax
  8021ee:	78 55                	js     802245 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021f0:	8b 15 24 40 80 00    	mov    0x804024,%edx
  8021f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802205:	8b 15 24 40 80 00    	mov    0x804024,%edx
  80220b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80220e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802210:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802213:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80221a:	83 ec 0c             	sub    $0xc,%esp
  80221d:	ff 75 f4             	pushl  -0xc(%ebp)
  802220:	e8 25 f5 ff ff       	call   80174a <fd2num>
  802225:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802228:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80222a:	83 c4 04             	add    $0x4,%esp
  80222d:	ff 75 f0             	pushl  -0x10(%ebp)
  802230:	e8 15 f5 ff ff       	call   80174a <fd2num>
  802235:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802238:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80223b:	83 c4 10             	add    $0x10,%esp
  80223e:	ba 00 00 00 00       	mov    $0x0,%edx
  802243:	eb 30                	jmp    802275 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802245:	83 ec 08             	sub    $0x8,%esp
  802248:	56                   	push   %esi
  802249:	6a 00                	push   $0x0
  80224b:	e8 42 ef ff ff       	call   801192 <sys_page_unmap>
  802250:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802253:	83 ec 08             	sub    $0x8,%esp
  802256:	ff 75 f0             	pushl  -0x10(%ebp)
  802259:	6a 00                	push   $0x0
  80225b:	e8 32 ef ff ff       	call   801192 <sys_page_unmap>
  802260:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802263:	83 ec 08             	sub    $0x8,%esp
  802266:	ff 75 f4             	pushl  -0xc(%ebp)
  802269:	6a 00                	push   $0x0
  80226b:	e8 22 ef ff ff       	call   801192 <sys_page_unmap>
  802270:	83 c4 10             	add    $0x10,%esp
  802273:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802275:	89 d0                	mov    %edx,%eax
  802277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80227a:	5b                   	pop    %ebx
  80227b:	5e                   	pop    %esi
  80227c:	5d                   	pop    %ebp
  80227d:	c3                   	ret    

0080227e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80227e:	55                   	push   %ebp
  80227f:	89 e5                	mov    %esp,%ebp
  802281:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802284:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802287:	50                   	push   %eax
  802288:	ff 75 08             	pushl  0x8(%ebp)
  80228b:	e8 30 f5 ff ff       	call   8017c0 <fd_lookup>
  802290:	83 c4 10             	add    $0x10,%esp
  802293:	85 c0                	test   %eax,%eax
  802295:	78 18                	js     8022af <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802297:	83 ec 0c             	sub    $0xc,%esp
  80229a:	ff 75 f4             	pushl  -0xc(%ebp)
  80229d:	e8 b8 f4 ff ff       	call   80175a <fd2data>
	return _pipeisclosed(fd, p);
  8022a2:	89 c2                	mov    %eax,%edx
  8022a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a7:	e8 21 fd ff ff       	call   801fcd <_pipeisclosed>
  8022ac:	83 c4 10             	add    $0x10,%esp
}
  8022af:	c9                   	leave  
  8022b0:	c3                   	ret    

008022b1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022b1:	55                   	push   %ebp
  8022b2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b9:	5d                   	pop    %ebp
  8022ba:	c3                   	ret    

008022bb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022bb:	55                   	push   %ebp
  8022bc:	89 e5                	mov    %esp,%ebp
  8022be:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022c1:	68 42 30 80 00       	push   $0x803042
  8022c6:	ff 75 0c             	pushl  0xc(%ebp)
  8022c9:	e8 3c ea ff ff       	call   800d0a <strcpy>
	return 0;
}
  8022ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d3:	c9                   	leave  
  8022d4:	c3                   	ret    

008022d5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022d5:	55                   	push   %ebp
  8022d6:	89 e5                	mov    %esp,%ebp
  8022d8:	57                   	push   %edi
  8022d9:	56                   	push   %esi
  8022da:	53                   	push   %ebx
  8022db:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022e1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022e6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022ec:	eb 2d                	jmp    80231b <devcons_write+0x46>
		m = n - tot;
  8022ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022f1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022f3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022f6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022fb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022fe:	83 ec 04             	sub    $0x4,%esp
  802301:	53                   	push   %ebx
  802302:	03 45 0c             	add    0xc(%ebp),%eax
  802305:	50                   	push   %eax
  802306:	57                   	push   %edi
  802307:	e8 90 eb ff ff       	call   800e9c <memmove>
		sys_cputs(buf, m);
  80230c:	83 c4 08             	add    $0x8,%esp
  80230f:	53                   	push   %ebx
  802310:	57                   	push   %edi
  802311:	e8 3b ed ff ff       	call   801051 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802316:	01 de                	add    %ebx,%esi
  802318:	83 c4 10             	add    $0x10,%esp
  80231b:	89 f0                	mov    %esi,%eax
  80231d:	3b 75 10             	cmp    0x10(%ebp),%esi
  802320:	72 cc                	jb     8022ee <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802322:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802325:	5b                   	pop    %ebx
  802326:	5e                   	pop    %esi
  802327:	5f                   	pop    %edi
  802328:	5d                   	pop    %ebp
  802329:	c3                   	ret    

0080232a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80232a:	55                   	push   %ebp
  80232b:	89 e5                	mov    %esp,%ebp
  80232d:	83 ec 08             	sub    $0x8,%esp
  802330:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802335:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802339:	74 2a                	je     802365 <devcons_read+0x3b>
  80233b:	eb 05                	jmp    802342 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80233d:	e8 ac ed ff ff       	call   8010ee <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802342:	e8 28 ed ff ff       	call   80106f <sys_cgetc>
  802347:	85 c0                	test   %eax,%eax
  802349:	74 f2                	je     80233d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80234b:	85 c0                	test   %eax,%eax
  80234d:	78 16                	js     802365 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80234f:	83 f8 04             	cmp    $0x4,%eax
  802352:	74 0c                	je     802360 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802354:	8b 55 0c             	mov    0xc(%ebp),%edx
  802357:	88 02                	mov    %al,(%edx)
	return 1;
  802359:	b8 01 00 00 00       	mov    $0x1,%eax
  80235e:	eb 05                	jmp    802365 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802360:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802365:	c9                   	leave  
  802366:	c3                   	ret    

00802367 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802367:	55                   	push   %ebp
  802368:	89 e5                	mov    %esp,%ebp
  80236a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80236d:	8b 45 08             	mov    0x8(%ebp),%eax
  802370:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802373:	6a 01                	push   $0x1
  802375:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802378:	50                   	push   %eax
  802379:	e8 d3 ec ff ff       	call   801051 <sys_cputs>
}
  80237e:	83 c4 10             	add    $0x10,%esp
  802381:	c9                   	leave  
  802382:	c3                   	ret    

00802383 <getchar>:

int
getchar(void)
{
  802383:	55                   	push   %ebp
  802384:	89 e5                	mov    %esp,%ebp
  802386:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802389:	6a 01                	push   $0x1
  80238b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80238e:	50                   	push   %eax
  80238f:	6a 00                	push   $0x0
  802391:	e8 90 f6 ff ff       	call   801a26 <read>
	if (r < 0)
  802396:	83 c4 10             	add    $0x10,%esp
  802399:	85 c0                	test   %eax,%eax
  80239b:	78 0f                	js     8023ac <getchar+0x29>
		return r;
	if (r < 1)
  80239d:	85 c0                	test   %eax,%eax
  80239f:	7e 06                	jle    8023a7 <getchar+0x24>
		return -E_EOF;
	return c;
  8023a1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023a5:	eb 05                	jmp    8023ac <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023a7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023ac:	c9                   	leave  
  8023ad:	c3                   	ret    

008023ae <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023ae:	55                   	push   %ebp
  8023af:	89 e5                	mov    %esp,%ebp
  8023b1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023b7:	50                   	push   %eax
  8023b8:	ff 75 08             	pushl  0x8(%ebp)
  8023bb:	e8 00 f4 ff ff       	call   8017c0 <fd_lookup>
  8023c0:	83 c4 10             	add    $0x10,%esp
  8023c3:	85 c0                	test   %eax,%eax
  8023c5:	78 11                	js     8023d8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ca:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8023d0:	39 10                	cmp    %edx,(%eax)
  8023d2:	0f 94 c0             	sete   %al
  8023d5:	0f b6 c0             	movzbl %al,%eax
}
  8023d8:	c9                   	leave  
  8023d9:	c3                   	ret    

008023da <opencons>:

int
opencons(void)
{
  8023da:	55                   	push   %ebp
  8023db:	89 e5                	mov    %esp,%ebp
  8023dd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023e3:	50                   	push   %eax
  8023e4:	e8 88 f3 ff ff       	call   801771 <fd_alloc>
  8023e9:	83 c4 10             	add    $0x10,%esp
		return r;
  8023ec:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023ee:	85 c0                	test   %eax,%eax
  8023f0:	78 3e                	js     802430 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023f2:	83 ec 04             	sub    $0x4,%esp
  8023f5:	68 07 04 00 00       	push   $0x407
  8023fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8023fd:	6a 00                	push   $0x0
  8023ff:	e8 09 ed ff ff       	call   80110d <sys_page_alloc>
  802404:	83 c4 10             	add    $0x10,%esp
		return r;
  802407:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802409:	85 c0                	test   %eax,%eax
  80240b:	78 23                	js     802430 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80240d:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802413:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802416:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802418:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80241b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802422:	83 ec 0c             	sub    $0xc,%esp
  802425:	50                   	push   %eax
  802426:	e8 1f f3 ff ff       	call   80174a <fd2num>
  80242b:	89 c2                	mov    %eax,%edx
  80242d:	83 c4 10             	add    $0x10,%esp
}
  802430:	89 d0                	mov    %edx,%eax
  802432:	c9                   	leave  
  802433:	c3                   	ret    

00802434 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802434:	55                   	push   %ebp
  802435:	89 e5                	mov    %esp,%ebp
  802437:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80243a:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802441:	75 2a                	jne    80246d <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802443:	83 ec 04             	sub    $0x4,%esp
  802446:	6a 07                	push   $0x7
  802448:	68 00 f0 bf ee       	push   $0xeebff000
  80244d:	6a 00                	push   $0x0
  80244f:	e8 b9 ec ff ff       	call   80110d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802454:	83 c4 10             	add    $0x10,%esp
  802457:	85 c0                	test   %eax,%eax
  802459:	79 12                	jns    80246d <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80245b:	50                   	push   %eax
  80245c:	68 4e 30 80 00       	push   $0x80304e
  802461:	6a 23                	push   $0x23
  802463:	68 52 30 80 00       	push   $0x803052
  802468:	e8 3f e2 ff ff       	call   8006ac <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80246d:	8b 45 08             	mov    0x8(%ebp),%eax
  802470:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802475:	83 ec 08             	sub    $0x8,%esp
  802478:	68 9f 24 80 00       	push   $0x80249f
  80247d:	6a 00                	push   $0x0
  80247f:	e8 d4 ed ff ff       	call   801258 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802484:	83 c4 10             	add    $0x10,%esp
  802487:	85 c0                	test   %eax,%eax
  802489:	79 12                	jns    80249d <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80248b:	50                   	push   %eax
  80248c:	68 4e 30 80 00       	push   $0x80304e
  802491:	6a 2c                	push   $0x2c
  802493:	68 52 30 80 00       	push   $0x803052
  802498:	e8 0f e2 ff ff       	call   8006ac <_panic>
	}
}
  80249d:	c9                   	leave  
  80249e:	c3                   	ret    

0080249f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80249f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024a0:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8024a5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024a7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8024aa:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8024ae:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8024b3:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8024b7:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8024b9:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8024bc:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8024bd:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8024c0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8024c1:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8024c2:	c3                   	ret    

008024c3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024c3:	55                   	push   %ebp
  8024c4:	89 e5                	mov    %esp,%ebp
  8024c6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024c9:	89 d0                	mov    %edx,%eax
  8024cb:	c1 e8 16             	shr    $0x16,%eax
  8024ce:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8024d5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024da:	f6 c1 01             	test   $0x1,%cl
  8024dd:	74 1d                	je     8024fc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024df:	c1 ea 0c             	shr    $0xc,%edx
  8024e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8024e9:	f6 c2 01             	test   $0x1,%dl
  8024ec:	74 0e                	je     8024fc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024ee:	c1 ea 0c             	shr    $0xc,%edx
  8024f1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024f8:	ef 
  8024f9:	0f b7 c0             	movzwl %ax,%eax
}
  8024fc:	5d                   	pop    %ebp
  8024fd:	c3                   	ret    
  8024fe:	66 90                	xchg   %ax,%ax

00802500 <__udivdi3>:
  802500:	55                   	push   %ebp
  802501:	57                   	push   %edi
  802502:	56                   	push   %esi
  802503:	53                   	push   %ebx
  802504:	83 ec 1c             	sub    $0x1c,%esp
  802507:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80250b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80250f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802513:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802517:	85 f6                	test   %esi,%esi
  802519:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80251d:	89 ca                	mov    %ecx,%edx
  80251f:	89 f8                	mov    %edi,%eax
  802521:	75 3d                	jne    802560 <__udivdi3+0x60>
  802523:	39 cf                	cmp    %ecx,%edi
  802525:	0f 87 c5 00 00 00    	ja     8025f0 <__udivdi3+0xf0>
  80252b:	85 ff                	test   %edi,%edi
  80252d:	89 fd                	mov    %edi,%ebp
  80252f:	75 0b                	jne    80253c <__udivdi3+0x3c>
  802531:	b8 01 00 00 00       	mov    $0x1,%eax
  802536:	31 d2                	xor    %edx,%edx
  802538:	f7 f7                	div    %edi
  80253a:	89 c5                	mov    %eax,%ebp
  80253c:	89 c8                	mov    %ecx,%eax
  80253e:	31 d2                	xor    %edx,%edx
  802540:	f7 f5                	div    %ebp
  802542:	89 c1                	mov    %eax,%ecx
  802544:	89 d8                	mov    %ebx,%eax
  802546:	89 cf                	mov    %ecx,%edi
  802548:	f7 f5                	div    %ebp
  80254a:	89 c3                	mov    %eax,%ebx
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
  802560:	39 ce                	cmp    %ecx,%esi
  802562:	77 74                	ja     8025d8 <__udivdi3+0xd8>
  802564:	0f bd fe             	bsr    %esi,%edi
  802567:	83 f7 1f             	xor    $0x1f,%edi
  80256a:	0f 84 98 00 00 00    	je     802608 <__udivdi3+0x108>
  802570:	bb 20 00 00 00       	mov    $0x20,%ebx
  802575:	89 f9                	mov    %edi,%ecx
  802577:	89 c5                	mov    %eax,%ebp
  802579:	29 fb                	sub    %edi,%ebx
  80257b:	d3 e6                	shl    %cl,%esi
  80257d:	89 d9                	mov    %ebx,%ecx
  80257f:	d3 ed                	shr    %cl,%ebp
  802581:	89 f9                	mov    %edi,%ecx
  802583:	d3 e0                	shl    %cl,%eax
  802585:	09 ee                	or     %ebp,%esi
  802587:	89 d9                	mov    %ebx,%ecx
  802589:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80258d:	89 d5                	mov    %edx,%ebp
  80258f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802593:	d3 ed                	shr    %cl,%ebp
  802595:	89 f9                	mov    %edi,%ecx
  802597:	d3 e2                	shl    %cl,%edx
  802599:	89 d9                	mov    %ebx,%ecx
  80259b:	d3 e8                	shr    %cl,%eax
  80259d:	09 c2                	or     %eax,%edx
  80259f:	89 d0                	mov    %edx,%eax
  8025a1:	89 ea                	mov    %ebp,%edx
  8025a3:	f7 f6                	div    %esi
  8025a5:	89 d5                	mov    %edx,%ebp
  8025a7:	89 c3                	mov    %eax,%ebx
  8025a9:	f7 64 24 0c          	mull   0xc(%esp)
  8025ad:	39 d5                	cmp    %edx,%ebp
  8025af:	72 10                	jb     8025c1 <__udivdi3+0xc1>
  8025b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025b5:	89 f9                	mov    %edi,%ecx
  8025b7:	d3 e6                	shl    %cl,%esi
  8025b9:	39 c6                	cmp    %eax,%esi
  8025bb:	73 07                	jae    8025c4 <__udivdi3+0xc4>
  8025bd:	39 d5                	cmp    %edx,%ebp
  8025bf:	75 03                	jne    8025c4 <__udivdi3+0xc4>
  8025c1:	83 eb 01             	sub    $0x1,%ebx
  8025c4:	31 ff                	xor    %edi,%edi
  8025c6:	89 d8                	mov    %ebx,%eax
  8025c8:	89 fa                	mov    %edi,%edx
  8025ca:	83 c4 1c             	add    $0x1c,%esp
  8025cd:	5b                   	pop    %ebx
  8025ce:	5e                   	pop    %esi
  8025cf:	5f                   	pop    %edi
  8025d0:	5d                   	pop    %ebp
  8025d1:	c3                   	ret    
  8025d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025d8:	31 ff                	xor    %edi,%edi
  8025da:	31 db                	xor    %ebx,%ebx
  8025dc:	89 d8                	mov    %ebx,%eax
  8025de:	89 fa                	mov    %edi,%edx
  8025e0:	83 c4 1c             	add    $0x1c,%esp
  8025e3:	5b                   	pop    %ebx
  8025e4:	5e                   	pop    %esi
  8025e5:	5f                   	pop    %edi
  8025e6:	5d                   	pop    %ebp
  8025e7:	c3                   	ret    
  8025e8:	90                   	nop
  8025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	89 d8                	mov    %ebx,%eax
  8025f2:	f7 f7                	div    %edi
  8025f4:	31 ff                	xor    %edi,%edi
  8025f6:	89 c3                	mov    %eax,%ebx
  8025f8:	89 d8                	mov    %ebx,%eax
  8025fa:	89 fa                	mov    %edi,%edx
  8025fc:	83 c4 1c             	add    $0x1c,%esp
  8025ff:	5b                   	pop    %ebx
  802600:	5e                   	pop    %esi
  802601:	5f                   	pop    %edi
  802602:	5d                   	pop    %ebp
  802603:	c3                   	ret    
  802604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802608:	39 ce                	cmp    %ecx,%esi
  80260a:	72 0c                	jb     802618 <__udivdi3+0x118>
  80260c:	31 db                	xor    %ebx,%ebx
  80260e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802612:	0f 87 34 ff ff ff    	ja     80254c <__udivdi3+0x4c>
  802618:	bb 01 00 00 00       	mov    $0x1,%ebx
  80261d:	e9 2a ff ff ff       	jmp    80254c <__udivdi3+0x4c>
  802622:	66 90                	xchg   %ax,%ax
  802624:	66 90                	xchg   %ax,%ax
  802626:	66 90                	xchg   %ax,%ax
  802628:	66 90                	xchg   %ax,%ax
  80262a:	66 90                	xchg   %ax,%ax
  80262c:	66 90                	xchg   %ax,%ax
  80262e:	66 90                	xchg   %ax,%ax

00802630 <__umoddi3>:
  802630:	55                   	push   %ebp
  802631:	57                   	push   %edi
  802632:	56                   	push   %esi
  802633:	53                   	push   %ebx
  802634:	83 ec 1c             	sub    $0x1c,%esp
  802637:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80263b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80263f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802643:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802647:	85 d2                	test   %edx,%edx
  802649:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80264d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802651:	89 f3                	mov    %esi,%ebx
  802653:	89 3c 24             	mov    %edi,(%esp)
  802656:	89 74 24 04          	mov    %esi,0x4(%esp)
  80265a:	75 1c                	jne    802678 <__umoddi3+0x48>
  80265c:	39 f7                	cmp    %esi,%edi
  80265e:	76 50                	jbe    8026b0 <__umoddi3+0x80>
  802660:	89 c8                	mov    %ecx,%eax
  802662:	89 f2                	mov    %esi,%edx
  802664:	f7 f7                	div    %edi
  802666:	89 d0                	mov    %edx,%eax
  802668:	31 d2                	xor    %edx,%edx
  80266a:	83 c4 1c             	add    $0x1c,%esp
  80266d:	5b                   	pop    %ebx
  80266e:	5e                   	pop    %esi
  80266f:	5f                   	pop    %edi
  802670:	5d                   	pop    %ebp
  802671:	c3                   	ret    
  802672:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802678:	39 f2                	cmp    %esi,%edx
  80267a:	89 d0                	mov    %edx,%eax
  80267c:	77 52                	ja     8026d0 <__umoddi3+0xa0>
  80267e:	0f bd ea             	bsr    %edx,%ebp
  802681:	83 f5 1f             	xor    $0x1f,%ebp
  802684:	75 5a                	jne    8026e0 <__umoddi3+0xb0>
  802686:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80268a:	0f 82 e0 00 00 00    	jb     802770 <__umoddi3+0x140>
  802690:	39 0c 24             	cmp    %ecx,(%esp)
  802693:	0f 86 d7 00 00 00    	jbe    802770 <__umoddi3+0x140>
  802699:	8b 44 24 08          	mov    0x8(%esp),%eax
  80269d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026a1:	83 c4 1c             	add    $0x1c,%esp
  8026a4:	5b                   	pop    %ebx
  8026a5:	5e                   	pop    %esi
  8026a6:	5f                   	pop    %edi
  8026a7:	5d                   	pop    %ebp
  8026a8:	c3                   	ret    
  8026a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	85 ff                	test   %edi,%edi
  8026b2:	89 fd                	mov    %edi,%ebp
  8026b4:	75 0b                	jne    8026c1 <__umoddi3+0x91>
  8026b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026bb:	31 d2                	xor    %edx,%edx
  8026bd:	f7 f7                	div    %edi
  8026bf:	89 c5                	mov    %eax,%ebp
  8026c1:	89 f0                	mov    %esi,%eax
  8026c3:	31 d2                	xor    %edx,%edx
  8026c5:	f7 f5                	div    %ebp
  8026c7:	89 c8                	mov    %ecx,%eax
  8026c9:	f7 f5                	div    %ebp
  8026cb:	89 d0                	mov    %edx,%eax
  8026cd:	eb 99                	jmp    802668 <__umoddi3+0x38>
  8026cf:	90                   	nop
  8026d0:	89 c8                	mov    %ecx,%eax
  8026d2:	89 f2                	mov    %esi,%edx
  8026d4:	83 c4 1c             	add    $0x1c,%esp
  8026d7:	5b                   	pop    %ebx
  8026d8:	5e                   	pop    %esi
  8026d9:	5f                   	pop    %edi
  8026da:	5d                   	pop    %ebp
  8026db:	c3                   	ret    
  8026dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026e0:	8b 34 24             	mov    (%esp),%esi
  8026e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8026e8:	89 e9                	mov    %ebp,%ecx
  8026ea:	29 ef                	sub    %ebp,%edi
  8026ec:	d3 e0                	shl    %cl,%eax
  8026ee:	89 f9                	mov    %edi,%ecx
  8026f0:	89 f2                	mov    %esi,%edx
  8026f2:	d3 ea                	shr    %cl,%edx
  8026f4:	89 e9                	mov    %ebp,%ecx
  8026f6:	09 c2                	or     %eax,%edx
  8026f8:	89 d8                	mov    %ebx,%eax
  8026fa:	89 14 24             	mov    %edx,(%esp)
  8026fd:	89 f2                	mov    %esi,%edx
  8026ff:	d3 e2                	shl    %cl,%edx
  802701:	89 f9                	mov    %edi,%ecx
  802703:	89 54 24 04          	mov    %edx,0x4(%esp)
  802707:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80270b:	d3 e8                	shr    %cl,%eax
  80270d:	89 e9                	mov    %ebp,%ecx
  80270f:	89 c6                	mov    %eax,%esi
  802711:	d3 e3                	shl    %cl,%ebx
  802713:	89 f9                	mov    %edi,%ecx
  802715:	89 d0                	mov    %edx,%eax
  802717:	d3 e8                	shr    %cl,%eax
  802719:	89 e9                	mov    %ebp,%ecx
  80271b:	09 d8                	or     %ebx,%eax
  80271d:	89 d3                	mov    %edx,%ebx
  80271f:	89 f2                	mov    %esi,%edx
  802721:	f7 34 24             	divl   (%esp)
  802724:	89 d6                	mov    %edx,%esi
  802726:	d3 e3                	shl    %cl,%ebx
  802728:	f7 64 24 04          	mull   0x4(%esp)
  80272c:	39 d6                	cmp    %edx,%esi
  80272e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802732:	89 d1                	mov    %edx,%ecx
  802734:	89 c3                	mov    %eax,%ebx
  802736:	72 08                	jb     802740 <__umoddi3+0x110>
  802738:	75 11                	jne    80274b <__umoddi3+0x11b>
  80273a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80273e:	73 0b                	jae    80274b <__umoddi3+0x11b>
  802740:	2b 44 24 04          	sub    0x4(%esp),%eax
  802744:	1b 14 24             	sbb    (%esp),%edx
  802747:	89 d1                	mov    %edx,%ecx
  802749:	89 c3                	mov    %eax,%ebx
  80274b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80274f:	29 da                	sub    %ebx,%edx
  802751:	19 ce                	sbb    %ecx,%esi
  802753:	89 f9                	mov    %edi,%ecx
  802755:	89 f0                	mov    %esi,%eax
  802757:	d3 e0                	shl    %cl,%eax
  802759:	89 e9                	mov    %ebp,%ecx
  80275b:	d3 ea                	shr    %cl,%edx
  80275d:	89 e9                	mov    %ebp,%ecx
  80275f:	d3 ee                	shr    %cl,%esi
  802761:	09 d0                	or     %edx,%eax
  802763:	89 f2                	mov    %esi,%edx
  802765:	83 c4 1c             	add    $0x1c,%esp
  802768:	5b                   	pop    %ebx
  802769:	5e                   	pop    %esi
  80276a:	5f                   	pop    %edi
  80276b:	5d                   	pop    %ebp
  80276c:	c3                   	ret    
  80276d:	8d 76 00             	lea    0x0(%esi),%esi
  802770:	29 f9                	sub    %edi,%ecx
  802772:	19 d6                	sbb    %edx,%esi
  802774:	89 74 24 04          	mov    %esi,0x4(%esp)
  802778:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80277c:	e9 18 ff ff ff       	jmp    802699 <__umoddi3+0x69>
