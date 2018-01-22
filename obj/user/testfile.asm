
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
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 ff 0c 00 00       	call   800d46 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 d8 13 00 00       	call   801431 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 67 13 00 00       	call   8013cf <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 e1 12 00 00       	call   80135a <ipc_recv>
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
  80008f:	b8 40 24 80 00       	mov    $0x802440,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 4b 24 80 00       	push   $0x80244b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 65 24 80 00       	push   $0x802465
  8000b4:	e8 2f 06 00 00       	call   8006e8 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 00 26 80 00       	push   $0x802600
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 65 24 80 00       	push   $0x802465
  8000cc:	e8 17 06 00 00       	call   8006e8 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 75 24 80 00       	mov    $0x802475,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 7e 24 80 00       	push   $0x80247e
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 65 24 80 00       	push   $0x802465
  8000f1:	e8 f2 05 00 00       	call   8006e8 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 24 26 80 00       	push   $0x802624
  800119:	6a 27                	push   $0x27
  80011b:	68 65 24 80 00       	push   $0x802465
  800120:	e8 c3 05 00 00       	call   8006e8 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 96 24 80 00       	push   $0x802496
  80012d:	e8 8f 06 00 00       	call   8007c1 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 30 80 00    	call   *0x80301c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 aa 24 80 00       	push   $0x8024aa
  800154:	6a 2b                	push   $0x2b
  800156:	68 65 24 80 00       	push   $0x802465
  80015b:	e8 88 05 00 00       	call   8006e8 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 30 80 00    	pushl  0x803000
  800169:	e8 9f 0b 00 00       	call   800d0d <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 30 80 00    	pushl  0x803000
  80017f:	e8 89 0b 00 00       	call   800d0d <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 54 26 80 00       	push   $0x802654
  80018f:	6a 2d                	push   $0x2d
  800191:	68 65 24 80 00       	push   $0x802465
  800196:	e8 4d 05 00 00       	call   8006e8 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 b8 24 80 00       	push   $0x8024b8
  8001a3:	e8 19 06 00 00       	call   8007c1 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 cd 0c 00 00       	call   800e8b <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 30 80 00    	call   *0x803010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 cb 24 80 00       	push   $0x8024cb
  8001df:	6a 32                	push   $0x32
  8001e1:	68 65 24 80 00       	push   $0x802465
  8001e6:	e8 fd 04 00 00       	call   8006e8 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 30 80 00    	pushl  0x803000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 f0 0b 00 00       	call   800df0 <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 d9 24 80 00       	push   $0x8024d9
  80020f:	6a 34                	push   $0x34
  800211:	68 65 24 80 00       	push   $0x802465
  800216:	e8 cd 04 00 00       	call   8006e8 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 f7 24 80 00       	push   $0x8024f7
  800223:	e8 99 05 00 00       	call   8007c1 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 30 80 00    	call   *0x803018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 0a 25 80 00       	push   $0x80250a
  800242:	6a 38                	push   $0x38
  800244:	68 65 24 80 00       	push   $0x802465
  800249:	e8 9a 04 00 00       	call   8006e8 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 19 25 80 00       	push   $0x802519
  800256:	e8 66 05 00 00       	call   8007c1 <cprintf>

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
  800285:	e8 44 0f 00 00       	call   8011ce <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 30 80 00    	call   *0x803010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 7c 26 80 00       	push   $0x80267c
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 65 24 80 00       	push   $0x802465
  8002b8:	e8 2b 04 00 00       	call   8006e8 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 2d 25 80 00       	push   $0x80252d
  8002c5:	e8 f7 04 00 00       	call   8007c1 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 43 25 80 00       	mov    $0x802543,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 4d 25 80 00       	push   $0x80254d
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 65 24 80 00       	push   $0x802465
  8002ed:	e8 f6 03 00 00       	call   8006e8 <_panic>
	//////////////////////////BUG NO 1///////////////////////////////
	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 30 80 00    	pushl  0x803000
  800301:	e8 07 0a 00 00       	call   800d0d <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 30 80 00    	pushl  0x803000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 30 80 00    	pushl  0x803000
  800322:	e8 e6 09 00 00       	call   800d0d <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 66 25 80 00       	push   $0x802566
  800334:	6a 4b                	push   $0x4b
  800336:	68 65 24 80 00       	push   $0x802465
  80033b:	e8 a8 03 00 00       	call   8006e8 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 75 25 80 00       	push   $0x802575
  800348:	e8 74 04 00 00       	call   8007c1 <cprintf>
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
  800368:	e8 1e 0b 00 00       	call   800e8b <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 30 80 00    	call   *0x803010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 b4 26 80 00       	push   $0x8026b4
  800390:	6a 51                	push   $0x51
  800392:	68 65 24 80 00       	push   $0x802465
  800397:	e8 4c 03 00 00       	call   8006e8 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 30 80 00    	pushl  0x803000
  8003a5:	e8 63 09 00 00       	call   800d0d <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 d4 26 80 00       	push   $0x8026d4
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 65 24 80 00       	push   $0x802465
  8003be:	e8 25 03 00 00       	call   8006e8 <_panic>
	if (strcmp(buf, msg) != 0) 
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 30 80 00    	pushl  0x803000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 18 0a 00 00       	call   800df0 <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 0c 27 80 00       	push   $0x80270c
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 65 24 80 00       	push   $0x802465
  8003ee:	e8 f5 02 00 00       	call   8006e8 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 3c 27 80 00       	push   $0x80273c
  8003fb:	e8 c1 03 00 00       	call   8007c1 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 40 24 80 00       	push   $0x802440
  80040a:	e8 c9 17 00 00       	call   801bd8 <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 51 24 80 00       	push   $0x802451
  800426:	6a 5a                	push   $0x5a
  800428:	68 65 24 80 00       	push   $0x802465
  80042d:	e8 b6 02 00 00       	call   8006e8 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 89 25 80 00       	push   $0x802589
  80043e:	6a 5c                	push   $0x5c
  800440:	68 65 24 80 00       	push   $0x802465
  800445:	e8 9e 02 00 00       	call   8006e8 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 75 24 80 00       	push   $0x802475
  800454:	e8 7f 17 00 00       	call   801bd8 <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 84 24 80 00       	push   $0x802484
  800466:	6a 5f                	push   $0x5f
  800468:	68 65 24 80 00       	push   $0x802465
  80046d:	e8 76 02 00 00       	call   8006e8 <_panic>
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
  800493:	68 60 27 80 00       	push   $0x802760
  800498:	6a 62                	push   $0x62
  80049a:	68 65 24 80 00       	push   $0x802465
  80049f:	e8 44 02 00 00       	call   8006e8 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 9c 24 80 00       	push   $0x80249c
  8004ac:	e8 10 03 00 00       	call   8007c1 <cprintf>
//////////////////////////BUG NO 2///////////////////////////////
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 a4 25 80 00       	push   $0x8025a4
  8004be:	e8 15 17 00 00       	call   801bd8 <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 a9 25 80 00       	push   $0x8025a9
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 65 24 80 00       	push   $0x802465
  8004d9:	e8 0a 02 00 00       	call   8006e8 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 97 09 00 00       	call   800e8b <memset>
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
  800512:	e8 10 13 00 00       	call   801827 <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 b8 25 80 00       	push   $0x8025b8
  800528:	6a 6c                	push   $0x6c
  80052a:	68 65 24 80 00       	push   $0x802465
  80052f:	e8 b4 01 00 00       	call   8006e8 <_panic>
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
  800547:	e8 c5 10 00 00       	call   801611 <close>
	
	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 a4 25 80 00       	push   $0x8025a4
  800556:	e8 7d 16 00 00       	call   801bd8 <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 ca 25 80 00       	push   $0x8025ca
  80056a:	6a 71                	push   $0x71
  80056c:	68 65 24 80 00       	push   $0x802465
  800571:	e8 72 01 00 00       	call   8006e8 <_panic>
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
  800591:	e8 48 12 00 00       	call   8017de <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 d8 25 80 00       	push   $0x8025d8
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 65 24 80 00       	push   $0x802465
  8005ae:	e8 35 01 00 00       	call   8006e8 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 88 27 80 00       	push   $0x802788
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 65 24 80 00       	push   $0x802465
  8005d0:	e8 13 01 00 00       	call   8006e8 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 b4 27 80 00       	push   $0x8027b4
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 65 24 80 00       	push   $0x802465
  8005f0:	e8 f3 00 00 00       	call   8006e8 <_panic>
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
  80060c:	e8 00 10 00 00       	call   801611 <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 e9 25 80 00 	movl   $0x8025e9,(%esp)
  800618:	e8 a4 01 00 00       	call   8007c1 <cprintf>
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
  80062b:	57                   	push   %edi
  80062c:	56                   	push   %esi
  80062d:	53                   	push   %ebx
  80062e:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800631:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800638:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  80063b:	e8 cb 0a 00 00       	call   80110b <sys_getenvid>
  800640:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	50                   	push   %eax
  800646:	68 04 28 80 00       	push   $0x802804
  80064b:	e8 71 01 00 00       	call   8007c1 <cprintf>
  800650:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800656:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80065b:	83 c4 10             	add    $0x10,%esp
  80065e:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800663:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  800668:	89 c1                	mov    %eax,%ecx
  80066a:	c1 e1 07             	shl    $0x7,%ecx
  80066d:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800674:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800677:	39 cb                	cmp    %ecx,%ebx
  800679:	0f 44 fa             	cmove  %edx,%edi
  80067c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800681:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800684:	83 c0 01             	add    $0x1,%eax
  800687:	81 c2 84 00 00 00    	add    $0x84,%edx
  80068d:	3d 00 04 00 00       	cmp    $0x400,%eax
  800692:	75 d4                	jne    800668 <libmain+0x40>
  800694:	89 f0                	mov    %esi,%eax
  800696:	84 c0                	test   %al,%al
  800698:	74 06                	je     8006a0 <libmain+0x78>
  80069a:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8006a0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8006a4:	7e 0a                	jle    8006b0 <libmain+0x88>
		binaryname = argv[0];
  8006a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8006b0:	83 ec 08             	sub    $0x8,%esp
  8006b3:	ff 75 0c             	pushl  0xc(%ebp)
  8006b6:	ff 75 08             	pushl  0x8(%ebp)
  8006b9:	e8 c0 f9 ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  8006be:	e8 0b 00 00 00       	call   8006ce <exit>
}
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c9:	5b                   	pop    %ebx
  8006ca:	5e                   	pop    %esi
  8006cb:	5f                   	pop    %edi
  8006cc:	5d                   	pop    %ebp
  8006cd:	c3                   	ret    

008006ce <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8006d4:	e8 63 0f 00 00       	call   80163c <close_all>
	sys_env_destroy(0);
  8006d9:	83 ec 0c             	sub    $0xc,%esp
  8006dc:	6a 00                	push   $0x0
  8006de:	e8 e7 09 00 00       	call   8010ca <sys_env_destroy>
}
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	c9                   	leave  
  8006e7:	c3                   	ret    

008006e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	56                   	push   %esi
  8006ec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8006ed:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8006f0:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8006f6:	e8 10 0a 00 00       	call   80110b <sys_getenvid>
  8006fb:	83 ec 0c             	sub    $0xc,%esp
  8006fe:	ff 75 0c             	pushl  0xc(%ebp)
  800701:	ff 75 08             	pushl  0x8(%ebp)
  800704:	56                   	push   %esi
  800705:	50                   	push   %eax
  800706:	68 30 28 80 00       	push   $0x802830
  80070b:	e8 b1 00 00 00       	call   8007c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800710:	83 c4 18             	add    $0x18,%esp
  800713:	53                   	push   %ebx
  800714:	ff 75 10             	pushl  0x10(%ebp)
  800717:	e8 54 00 00 00       	call   800770 <vcprintf>
	cprintf("\n");
  80071c:	c7 04 24 7f 2c 80 00 	movl   $0x802c7f,(%esp)
  800723:	e8 99 00 00 00       	call   8007c1 <cprintf>
  800728:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80072b:	cc                   	int3   
  80072c:	eb fd                	jmp    80072b <_panic+0x43>

0080072e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80072e:	55                   	push   %ebp
  80072f:	89 e5                	mov    %esp,%ebp
  800731:	53                   	push   %ebx
  800732:	83 ec 04             	sub    $0x4,%esp
  800735:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800738:	8b 13                	mov    (%ebx),%edx
  80073a:	8d 42 01             	lea    0x1(%edx),%eax
  80073d:	89 03                	mov    %eax,(%ebx)
  80073f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800742:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800746:	3d ff 00 00 00       	cmp    $0xff,%eax
  80074b:	75 1a                	jne    800767 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	68 ff 00 00 00       	push   $0xff
  800755:	8d 43 08             	lea    0x8(%ebx),%eax
  800758:	50                   	push   %eax
  800759:	e8 2f 09 00 00       	call   80108d <sys_cputs>
		b->idx = 0;
  80075e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800764:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800767:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80076b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800779:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800780:	00 00 00 
	b.cnt = 0;
  800783:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80078a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80078d:	ff 75 0c             	pushl  0xc(%ebp)
  800790:	ff 75 08             	pushl  0x8(%ebp)
  800793:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800799:	50                   	push   %eax
  80079a:	68 2e 07 80 00       	push   $0x80072e
  80079f:	e8 54 01 00 00       	call   8008f8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8007a4:	83 c4 08             	add    $0x8,%esp
  8007a7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8007ad:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8007b3:	50                   	push   %eax
  8007b4:	e8 d4 08 00 00       	call   80108d <sys_cputs>

	return b.cnt;
}
  8007b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    

008007c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8007c7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8007ca:	50                   	push   %eax
  8007cb:	ff 75 08             	pushl  0x8(%ebp)
  8007ce:	e8 9d ff ff ff       	call   800770 <vcprintf>
	va_end(ap);

	return cnt;
}
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    

008007d5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	57                   	push   %edi
  8007d9:	56                   	push   %esi
  8007da:	53                   	push   %ebx
  8007db:	83 ec 1c             	sub    $0x1c,%esp
  8007de:	89 c7                	mov    %eax,%edi
  8007e0:	89 d6                	mov    %edx,%esi
  8007e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007eb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007f6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8007f9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8007fc:	39 d3                	cmp    %edx,%ebx
  8007fe:	72 05                	jb     800805 <printnum+0x30>
  800800:	39 45 10             	cmp    %eax,0x10(%ebp)
  800803:	77 45                	ja     80084a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800805:	83 ec 0c             	sub    $0xc,%esp
  800808:	ff 75 18             	pushl  0x18(%ebp)
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800811:	53                   	push   %ebx
  800812:	ff 75 10             	pushl  0x10(%ebp)
  800815:	83 ec 08             	sub    $0x8,%esp
  800818:	ff 75 e4             	pushl  -0x1c(%ebp)
  80081b:	ff 75 e0             	pushl  -0x20(%ebp)
  80081e:	ff 75 dc             	pushl  -0x24(%ebp)
  800821:	ff 75 d8             	pushl  -0x28(%ebp)
  800824:	e8 77 19 00 00       	call   8021a0 <__udivdi3>
  800829:	83 c4 18             	add    $0x18,%esp
  80082c:	52                   	push   %edx
  80082d:	50                   	push   %eax
  80082e:	89 f2                	mov    %esi,%edx
  800830:	89 f8                	mov    %edi,%eax
  800832:	e8 9e ff ff ff       	call   8007d5 <printnum>
  800837:	83 c4 20             	add    $0x20,%esp
  80083a:	eb 18                	jmp    800854 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	56                   	push   %esi
  800840:	ff 75 18             	pushl  0x18(%ebp)
  800843:	ff d7                	call   *%edi
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	eb 03                	jmp    80084d <printnum+0x78>
  80084a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80084d:	83 eb 01             	sub    $0x1,%ebx
  800850:	85 db                	test   %ebx,%ebx
  800852:	7f e8                	jg     80083c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800854:	83 ec 08             	sub    $0x8,%esp
  800857:	56                   	push   %esi
  800858:	83 ec 04             	sub    $0x4,%esp
  80085b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80085e:	ff 75 e0             	pushl  -0x20(%ebp)
  800861:	ff 75 dc             	pushl  -0x24(%ebp)
  800864:	ff 75 d8             	pushl  -0x28(%ebp)
  800867:	e8 64 1a 00 00       	call   8022d0 <__umoddi3>
  80086c:	83 c4 14             	add    $0x14,%esp
  80086f:	0f be 80 53 28 80 00 	movsbl 0x802853(%eax),%eax
  800876:	50                   	push   %eax
  800877:	ff d7                	call   *%edi
}
  800879:	83 c4 10             	add    $0x10,%esp
  80087c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80087f:	5b                   	pop    %ebx
  800880:	5e                   	pop    %esi
  800881:	5f                   	pop    %edi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800887:	83 fa 01             	cmp    $0x1,%edx
  80088a:	7e 0e                	jle    80089a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80088c:	8b 10                	mov    (%eax),%edx
  80088e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800891:	89 08                	mov    %ecx,(%eax)
  800893:	8b 02                	mov    (%edx),%eax
  800895:	8b 52 04             	mov    0x4(%edx),%edx
  800898:	eb 22                	jmp    8008bc <getuint+0x38>
	else if (lflag)
  80089a:	85 d2                	test   %edx,%edx
  80089c:	74 10                	je     8008ae <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80089e:	8b 10                	mov    (%eax),%edx
  8008a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008a3:	89 08                	mov    %ecx,(%eax)
  8008a5:	8b 02                	mov    (%edx),%eax
  8008a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ac:	eb 0e                	jmp    8008bc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8008ae:	8b 10                	mov    (%eax),%edx
  8008b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008b3:	89 08                	mov    %ecx,(%eax)
  8008b5:	8b 02                	mov    (%edx),%eax
  8008b7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8008c4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8008c8:	8b 10                	mov    (%eax),%edx
  8008ca:	3b 50 04             	cmp    0x4(%eax),%edx
  8008cd:	73 0a                	jae    8008d9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8008cf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008d2:	89 08                	mov    %ecx,(%eax)
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	88 02                	mov    %al,(%edx)
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8008e1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8008e4:	50                   	push   %eax
  8008e5:	ff 75 10             	pushl  0x10(%ebp)
  8008e8:	ff 75 0c             	pushl  0xc(%ebp)
  8008eb:	ff 75 08             	pushl  0x8(%ebp)
  8008ee:	e8 05 00 00 00       	call   8008f8 <vprintfmt>
	va_end(ap);
}
  8008f3:	83 c4 10             	add    $0x10,%esp
  8008f6:	c9                   	leave  
  8008f7:	c3                   	ret    

008008f8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	57                   	push   %edi
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
  8008fe:	83 ec 2c             	sub    $0x2c,%esp
  800901:	8b 75 08             	mov    0x8(%ebp),%esi
  800904:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800907:	8b 7d 10             	mov    0x10(%ebp),%edi
  80090a:	eb 12                	jmp    80091e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80090c:	85 c0                	test   %eax,%eax
  80090e:	0f 84 89 03 00 00    	je     800c9d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800914:	83 ec 08             	sub    $0x8,%esp
  800917:	53                   	push   %ebx
  800918:	50                   	push   %eax
  800919:	ff d6                	call   *%esi
  80091b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80091e:	83 c7 01             	add    $0x1,%edi
  800921:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800925:	83 f8 25             	cmp    $0x25,%eax
  800928:	75 e2                	jne    80090c <vprintfmt+0x14>
  80092a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80092e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800935:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80093c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800943:	ba 00 00 00 00       	mov    $0x0,%edx
  800948:	eb 07                	jmp    800951 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80094d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800951:	8d 47 01             	lea    0x1(%edi),%eax
  800954:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800957:	0f b6 07             	movzbl (%edi),%eax
  80095a:	0f b6 c8             	movzbl %al,%ecx
  80095d:	83 e8 23             	sub    $0x23,%eax
  800960:	3c 55                	cmp    $0x55,%al
  800962:	0f 87 1a 03 00 00    	ja     800c82 <vprintfmt+0x38a>
  800968:	0f b6 c0             	movzbl %al,%eax
  80096b:	ff 24 85 a0 29 80 00 	jmp    *0x8029a0(,%eax,4)
  800972:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800975:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800979:	eb d6                	jmp    800951 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80097e:	b8 00 00 00 00       	mov    $0x0,%eax
  800983:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800986:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800989:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80098d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800990:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800993:	83 fa 09             	cmp    $0x9,%edx
  800996:	77 39                	ja     8009d1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800998:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80099b:	eb e9                	jmp    800986 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80099d:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a0:	8d 48 04             	lea    0x4(%eax),%ecx
  8009a3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8009a6:	8b 00                	mov    (%eax),%eax
  8009a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8009ae:	eb 27                	jmp    8009d7 <vprintfmt+0xdf>
  8009b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009b3:	85 c0                	test   %eax,%eax
  8009b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009ba:	0f 49 c8             	cmovns %eax,%ecx
  8009bd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009c3:	eb 8c                	jmp    800951 <vprintfmt+0x59>
  8009c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8009c8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8009cf:	eb 80                	jmp    800951 <vprintfmt+0x59>
  8009d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009d4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8009d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009db:	0f 89 70 ff ff ff    	jns    800951 <vprintfmt+0x59>
				width = precision, precision = -1;
  8009e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009e7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009ee:	e9 5e ff ff ff       	jmp    800951 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009f3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8009f9:	e9 53 ff ff ff       	jmp    800951 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800a01:	8d 50 04             	lea    0x4(%eax),%edx
  800a04:	89 55 14             	mov    %edx,0x14(%ebp)
  800a07:	83 ec 08             	sub    $0x8,%esp
  800a0a:	53                   	push   %ebx
  800a0b:	ff 30                	pushl  (%eax)
  800a0d:	ff d6                	call   *%esi
			break;
  800a0f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800a15:	e9 04 ff ff ff       	jmp    80091e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800a1a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1d:	8d 50 04             	lea    0x4(%eax),%edx
  800a20:	89 55 14             	mov    %edx,0x14(%ebp)
  800a23:	8b 00                	mov    (%eax),%eax
  800a25:	99                   	cltd   
  800a26:	31 d0                	xor    %edx,%eax
  800a28:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a2a:	83 f8 0f             	cmp    $0xf,%eax
  800a2d:	7f 0b                	jg     800a3a <vprintfmt+0x142>
  800a2f:	8b 14 85 00 2b 80 00 	mov    0x802b00(,%eax,4),%edx
  800a36:	85 d2                	test   %edx,%edx
  800a38:	75 18                	jne    800a52 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800a3a:	50                   	push   %eax
  800a3b:	68 6b 28 80 00       	push   $0x80286b
  800a40:	53                   	push   %ebx
  800a41:	56                   	push   %esi
  800a42:	e8 94 fe ff ff       	call   8008db <printfmt>
  800a47:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800a4d:	e9 cc fe ff ff       	jmp    80091e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800a52:	52                   	push   %edx
  800a53:	68 4d 2c 80 00       	push   $0x802c4d
  800a58:	53                   	push   %ebx
  800a59:	56                   	push   %esi
  800a5a:	e8 7c fe ff ff       	call   8008db <printfmt>
  800a5f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a65:	e9 b4 fe ff ff       	jmp    80091e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a6a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6d:	8d 50 04             	lea    0x4(%eax),%edx
  800a70:	89 55 14             	mov    %edx,0x14(%ebp)
  800a73:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a75:	85 ff                	test   %edi,%edi
  800a77:	b8 64 28 80 00       	mov    $0x802864,%eax
  800a7c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a7f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a83:	0f 8e 94 00 00 00    	jle    800b1d <vprintfmt+0x225>
  800a89:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a8d:	0f 84 98 00 00 00    	je     800b2b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a93:	83 ec 08             	sub    $0x8,%esp
  800a96:	ff 75 d0             	pushl  -0x30(%ebp)
  800a99:	57                   	push   %edi
  800a9a:	e8 86 02 00 00       	call   800d25 <strnlen>
  800a9f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800aa2:	29 c1                	sub    %eax,%ecx
  800aa4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800aa7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800aaa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800aae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ab1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800ab4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ab6:	eb 0f                	jmp    800ac7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800ab8:	83 ec 08             	sub    $0x8,%esp
  800abb:	53                   	push   %ebx
  800abc:	ff 75 e0             	pushl  -0x20(%ebp)
  800abf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ac1:	83 ef 01             	sub    $0x1,%edi
  800ac4:	83 c4 10             	add    $0x10,%esp
  800ac7:	85 ff                	test   %edi,%edi
  800ac9:	7f ed                	jg     800ab8 <vprintfmt+0x1c0>
  800acb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800ace:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800ad1:	85 c9                	test   %ecx,%ecx
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad8:	0f 49 c1             	cmovns %ecx,%eax
  800adb:	29 c1                	sub    %eax,%ecx
  800add:	89 75 08             	mov    %esi,0x8(%ebp)
  800ae0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ae3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ae6:	89 cb                	mov    %ecx,%ebx
  800ae8:	eb 4d                	jmp    800b37 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800aea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800aee:	74 1b                	je     800b0b <vprintfmt+0x213>
  800af0:	0f be c0             	movsbl %al,%eax
  800af3:	83 e8 20             	sub    $0x20,%eax
  800af6:	83 f8 5e             	cmp    $0x5e,%eax
  800af9:	76 10                	jbe    800b0b <vprintfmt+0x213>
					putch('?', putdat);
  800afb:	83 ec 08             	sub    $0x8,%esp
  800afe:	ff 75 0c             	pushl  0xc(%ebp)
  800b01:	6a 3f                	push   $0x3f
  800b03:	ff 55 08             	call   *0x8(%ebp)
  800b06:	83 c4 10             	add    $0x10,%esp
  800b09:	eb 0d                	jmp    800b18 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800b0b:	83 ec 08             	sub    $0x8,%esp
  800b0e:	ff 75 0c             	pushl  0xc(%ebp)
  800b11:	52                   	push   %edx
  800b12:	ff 55 08             	call   *0x8(%ebp)
  800b15:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b18:	83 eb 01             	sub    $0x1,%ebx
  800b1b:	eb 1a                	jmp    800b37 <vprintfmt+0x23f>
  800b1d:	89 75 08             	mov    %esi,0x8(%ebp)
  800b20:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800b23:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800b26:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800b29:	eb 0c                	jmp    800b37 <vprintfmt+0x23f>
  800b2b:	89 75 08             	mov    %esi,0x8(%ebp)
  800b2e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800b31:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800b34:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800b37:	83 c7 01             	add    $0x1,%edi
  800b3a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800b3e:	0f be d0             	movsbl %al,%edx
  800b41:	85 d2                	test   %edx,%edx
  800b43:	74 23                	je     800b68 <vprintfmt+0x270>
  800b45:	85 f6                	test   %esi,%esi
  800b47:	78 a1                	js     800aea <vprintfmt+0x1f2>
  800b49:	83 ee 01             	sub    $0x1,%esi
  800b4c:	79 9c                	jns    800aea <vprintfmt+0x1f2>
  800b4e:	89 df                	mov    %ebx,%edi
  800b50:	8b 75 08             	mov    0x8(%ebp),%esi
  800b53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b56:	eb 18                	jmp    800b70 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b58:	83 ec 08             	sub    $0x8,%esp
  800b5b:	53                   	push   %ebx
  800b5c:	6a 20                	push   $0x20
  800b5e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b60:	83 ef 01             	sub    $0x1,%edi
  800b63:	83 c4 10             	add    $0x10,%esp
  800b66:	eb 08                	jmp    800b70 <vprintfmt+0x278>
  800b68:	89 df                	mov    %ebx,%edi
  800b6a:	8b 75 08             	mov    0x8(%ebp),%esi
  800b6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b70:	85 ff                	test   %edi,%edi
  800b72:	7f e4                	jg     800b58 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b74:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b77:	e9 a2 fd ff ff       	jmp    80091e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b7c:	83 fa 01             	cmp    $0x1,%edx
  800b7f:	7e 16                	jle    800b97 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800b81:	8b 45 14             	mov    0x14(%ebp),%eax
  800b84:	8d 50 08             	lea    0x8(%eax),%edx
  800b87:	89 55 14             	mov    %edx,0x14(%ebp)
  800b8a:	8b 50 04             	mov    0x4(%eax),%edx
  800b8d:	8b 00                	mov    (%eax),%eax
  800b8f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b92:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b95:	eb 32                	jmp    800bc9 <vprintfmt+0x2d1>
	else if (lflag)
  800b97:	85 d2                	test   %edx,%edx
  800b99:	74 18                	je     800bb3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800b9b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b9e:	8d 50 04             	lea    0x4(%eax),%edx
  800ba1:	89 55 14             	mov    %edx,0x14(%ebp)
  800ba4:	8b 00                	mov    (%eax),%eax
  800ba6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ba9:	89 c1                	mov    %eax,%ecx
  800bab:	c1 f9 1f             	sar    $0x1f,%ecx
  800bae:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800bb1:	eb 16                	jmp    800bc9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800bb3:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb6:	8d 50 04             	lea    0x4(%eax),%edx
  800bb9:	89 55 14             	mov    %edx,0x14(%ebp)
  800bbc:	8b 00                	mov    (%eax),%eax
  800bbe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bc1:	89 c1                	mov    %eax,%ecx
  800bc3:	c1 f9 1f             	sar    $0x1f,%ecx
  800bc6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800bc9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800bcc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800bcf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800bd4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800bd8:	79 74                	jns    800c4e <vprintfmt+0x356>
				putch('-', putdat);
  800bda:	83 ec 08             	sub    $0x8,%esp
  800bdd:	53                   	push   %ebx
  800bde:	6a 2d                	push   $0x2d
  800be0:	ff d6                	call   *%esi
				num = -(long long) num;
  800be2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800be5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800be8:	f7 d8                	neg    %eax
  800bea:	83 d2 00             	adc    $0x0,%edx
  800bed:	f7 da                	neg    %edx
  800bef:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800bf2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bf7:	eb 55                	jmp    800c4e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bf9:	8d 45 14             	lea    0x14(%ebp),%eax
  800bfc:	e8 83 fc ff ff       	call   800884 <getuint>
			base = 10;
  800c01:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800c06:	eb 46                	jmp    800c4e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800c08:	8d 45 14             	lea    0x14(%ebp),%eax
  800c0b:	e8 74 fc ff ff       	call   800884 <getuint>
			base = 8;
  800c10:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800c15:	eb 37                	jmp    800c4e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800c17:	83 ec 08             	sub    $0x8,%esp
  800c1a:	53                   	push   %ebx
  800c1b:	6a 30                	push   $0x30
  800c1d:	ff d6                	call   *%esi
			putch('x', putdat);
  800c1f:	83 c4 08             	add    $0x8,%esp
  800c22:	53                   	push   %ebx
  800c23:	6a 78                	push   $0x78
  800c25:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c27:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2a:	8d 50 04             	lea    0x4(%eax),%edx
  800c2d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800c30:	8b 00                	mov    (%eax),%eax
  800c32:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c37:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800c3a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800c3f:	eb 0d                	jmp    800c4e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c41:	8d 45 14             	lea    0x14(%ebp),%eax
  800c44:	e8 3b fc ff ff       	call   800884 <getuint>
			base = 16;
  800c49:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800c55:	57                   	push   %edi
  800c56:	ff 75 e0             	pushl  -0x20(%ebp)
  800c59:	51                   	push   %ecx
  800c5a:	52                   	push   %edx
  800c5b:	50                   	push   %eax
  800c5c:	89 da                	mov    %ebx,%edx
  800c5e:	89 f0                	mov    %esi,%eax
  800c60:	e8 70 fb ff ff       	call   8007d5 <printnum>
			break;
  800c65:	83 c4 20             	add    $0x20,%esp
  800c68:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c6b:	e9 ae fc ff ff       	jmp    80091e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c70:	83 ec 08             	sub    $0x8,%esp
  800c73:	53                   	push   %ebx
  800c74:	51                   	push   %ecx
  800c75:	ff d6                	call   *%esi
			break;
  800c77:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c7d:	e9 9c fc ff ff       	jmp    80091e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c82:	83 ec 08             	sub    $0x8,%esp
  800c85:	53                   	push   %ebx
  800c86:	6a 25                	push   $0x25
  800c88:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c8a:	83 c4 10             	add    $0x10,%esp
  800c8d:	eb 03                	jmp    800c92 <vprintfmt+0x39a>
  800c8f:	83 ef 01             	sub    $0x1,%edi
  800c92:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c96:	75 f7                	jne    800c8f <vprintfmt+0x397>
  800c98:	e9 81 fc ff ff       	jmp    80091e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	83 ec 18             	sub    $0x18,%esp
  800cab:	8b 45 08             	mov    0x8(%ebp),%eax
  800cae:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cb1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cb4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cb8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cbb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	74 26                	je     800cec <vsnprintf+0x47>
  800cc6:	85 d2                	test   %edx,%edx
  800cc8:	7e 22                	jle    800cec <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cca:	ff 75 14             	pushl  0x14(%ebp)
  800ccd:	ff 75 10             	pushl  0x10(%ebp)
  800cd0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cd3:	50                   	push   %eax
  800cd4:	68 be 08 80 00       	push   $0x8008be
  800cd9:	e8 1a fc ff ff       	call   8008f8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cde:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ce1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce7:	83 c4 10             	add    $0x10,%esp
  800cea:	eb 05                	jmp    800cf1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cf1:	c9                   	leave  
  800cf2:	c3                   	ret    

00800cf3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cf9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cfc:	50                   	push   %eax
  800cfd:	ff 75 10             	pushl  0x10(%ebp)
  800d00:	ff 75 0c             	pushl  0xc(%ebp)
  800d03:	ff 75 08             	pushl  0x8(%ebp)
  800d06:	e8 9a ff ff ff       	call   800ca5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d0b:	c9                   	leave  
  800d0c:	c3                   	ret    

00800d0d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d13:	b8 00 00 00 00       	mov    $0x0,%eax
  800d18:	eb 03                	jmp    800d1d <strlen+0x10>
		n++;
  800d1a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d1d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d21:	75 f7                	jne    800d1a <strlen+0xd>
		n++;
	return n;
}
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d33:	eb 03                	jmp    800d38 <strnlen+0x13>
		n++;
  800d35:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d38:	39 c2                	cmp    %eax,%edx
  800d3a:	74 08                	je     800d44 <strnlen+0x1f>
  800d3c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800d40:	75 f3                	jne    800d35 <strnlen+0x10>
  800d42:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	53                   	push   %ebx
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d50:	89 c2                	mov    %eax,%edx
  800d52:	83 c2 01             	add    $0x1,%edx
  800d55:	83 c1 01             	add    $0x1,%ecx
  800d58:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d5c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d5f:	84 db                	test   %bl,%bl
  800d61:	75 ef                	jne    800d52 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d63:	5b                   	pop    %ebx
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	53                   	push   %ebx
  800d6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d6d:	53                   	push   %ebx
  800d6e:	e8 9a ff ff ff       	call   800d0d <strlen>
  800d73:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d76:	ff 75 0c             	pushl  0xc(%ebp)
  800d79:	01 d8                	add    %ebx,%eax
  800d7b:	50                   	push   %eax
  800d7c:	e8 c5 ff ff ff       	call   800d46 <strcpy>
	return dst;
}
  800d81:	89 d8                	mov    %ebx,%eax
  800d83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d86:	c9                   	leave  
  800d87:	c3                   	ret    

00800d88 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
  800d8d:	8b 75 08             	mov    0x8(%ebp),%esi
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	89 f3                	mov    %esi,%ebx
  800d95:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d98:	89 f2                	mov    %esi,%edx
  800d9a:	eb 0f                	jmp    800dab <strncpy+0x23>
		*dst++ = *src;
  800d9c:	83 c2 01             	add    $0x1,%edx
  800d9f:	0f b6 01             	movzbl (%ecx),%eax
  800da2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800da5:	80 39 01             	cmpb   $0x1,(%ecx)
  800da8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dab:	39 da                	cmp    %ebx,%edx
  800dad:	75 ed                	jne    800d9c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800daf:	89 f0                	mov    %esi,%eax
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
  800dba:	8b 75 08             	mov    0x8(%ebp),%esi
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	8b 55 10             	mov    0x10(%ebp),%edx
  800dc3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dc5:	85 d2                	test   %edx,%edx
  800dc7:	74 21                	je     800dea <strlcpy+0x35>
  800dc9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800dcd:	89 f2                	mov    %esi,%edx
  800dcf:	eb 09                	jmp    800dda <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800dd1:	83 c2 01             	add    $0x1,%edx
  800dd4:	83 c1 01             	add    $0x1,%ecx
  800dd7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dda:	39 c2                	cmp    %eax,%edx
  800ddc:	74 09                	je     800de7 <strlcpy+0x32>
  800dde:	0f b6 19             	movzbl (%ecx),%ebx
  800de1:	84 db                	test   %bl,%bl
  800de3:	75 ec                	jne    800dd1 <strlcpy+0x1c>
  800de5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800de7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dea:	29 f0                	sub    %esi,%eax
}
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800df9:	eb 06                	jmp    800e01 <strcmp+0x11>
		p++, q++;
  800dfb:	83 c1 01             	add    $0x1,%ecx
  800dfe:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e01:	0f b6 01             	movzbl (%ecx),%eax
  800e04:	84 c0                	test   %al,%al
  800e06:	74 04                	je     800e0c <strcmp+0x1c>
  800e08:	3a 02                	cmp    (%edx),%al
  800e0a:	74 ef                	je     800dfb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e0c:	0f b6 c0             	movzbl %al,%eax
  800e0f:	0f b6 12             	movzbl (%edx),%edx
  800e12:	29 d0                	sub    %edx,%eax
}
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	53                   	push   %ebx
  800e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e20:	89 c3                	mov    %eax,%ebx
  800e22:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e25:	eb 06                	jmp    800e2d <strncmp+0x17>
		n--, p++, q++;
  800e27:	83 c0 01             	add    $0x1,%eax
  800e2a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e2d:	39 d8                	cmp    %ebx,%eax
  800e2f:	74 15                	je     800e46 <strncmp+0x30>
  800e31:	0f b6 08             	movzbl (%eax),%ecx
  800e34:	84 c9                	test   %cl,%cl
  800e36:	74 04                	je     800e3c <strncmp+0x26>
  800e38:	3a 0a                	cmp    (%edx),%cl
  800e3a:	74 eb                	je     800e27 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e3c:	0f b6 00             	movzbl (%eax),%eax
  800e3f:	0f b6 12             	movzbl (%edx),%edx
  800e42:	29 d0                	sub    %edx,%eax
  800e44:	eb 05                	jmp    800e4b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e46:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e4b:	5b                   	pop    %ebx
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	8b 45 08             	mov    0x8(%ebp),%eax
  800e54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e58:	eb 07                	jmp    800e61 <strchr+0x13>
		if (*s == c)
  800e5a:	38 ca                	cmp    %cl,%dl
  800e5c:	74 0f                	je     800e6d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e5e:	83 c0 01             	add    $0x1,%eax
  800e61:	0f b6 10             	movzbl (%eax),%edx
  800e64:	84 d2                	test   %dl,%dl
  800e66:	75 f2                	jne    800e5a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	8b 45 08             	mov    0x8(%ebp),%eax
  800e75:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e79:	eb 03                	jmp    800e7e <strfind+0xf>
  800e7b:	83 c0 01             	add    $0x1,%eax
  800e7e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e81:	38 ca                	cmp    %cl,%dl
  800e83:	74 04                	je     800e89 <strfind+0x1a>
  800e85:	84 d2                	test   %dl,%dl
  800e87:	75 f2                	jne    800e7b <strfind+0xc>
			break;
	return (char *) s;
}
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	57                   	push   %edi
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
  800e91:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e94:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e97:	85 c9                	test   %ecx,%ecx
  800e99:	74 36                	je     800ed1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e9b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ea1:	75 28                	jne    800ecb <memset+0x40>
  800ea3:	f6 c1 03             	test   $0x3,%cl
  800ea6:	75 23                	jne    800ecb <memset+0x40>
		c &= 0xFF;
  800ea8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800eac:	89 d3                	mov    %edx,%ebx
  800eae:	c1 e3 08             	shl    $0x8,%ebx
  800eb1:	89 d6                	mov    %edx,%esi
  800eb3:	c1 e6 18             	shl    $0x18,%esi
  800eb6:	89 d0                	mov    %edx,%eax
  800eb8:	c1 e0 10             	shl    $0x10,%eax
  800ebb:	09 f0                	or     %esi,%eax
  800ebd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ebf:	89 d8                	mov    %ebx,%eax
  800ec1:	09 d0                	or     %edx,%eax
  800ec3:	c1 e9 02             	shr    $0x2,%ecx
  800ec6:	fc                   	cld    
  800ec7:	f3 ab                	rep stos %eax,%es:(%edi)
  800ec9:	eb 06                	jmp    800ed1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ece:	fc                   	cld    
  800ecf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ed1:	89 f8                	mov    %edi,%eax
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5f                   	pop    %edi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ee3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ee6:	39 c6                	cmp    %eax,%esi
  800ee8:	73 35                	jae    800f1f <memmove+0x47>
  800eea:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800eed:	39 d0                	cmp    %edx,%eax
  800eef:	73 2e                	jae    800f1f <memmove+0x47>
		s += n;
		d += n;
  800ef1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ef4:	89 d6                	mov    %edx,%esi
  800ef6:	09 fe                	or     %edi,%esi
  800ef8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800efe:	75 13                	jne    800f13 <memmove+0x3b>
  800f00:	f6 c1 03             	test   $0x3,%cl
  800f03:	75 0e                	jne    800f13 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f05:	83 ef 04             	sub    $0x4,%edi
  800f08:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f0b:	c1 e9 02             	shr    $0x2,%ecx
  800f0e:	fd                   	std    
  800f0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f11:	eb 09                	jmp    800f1c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f13:	83 ef 01             	sub    $0x1,%edi
  800f16:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f19:	fd                   	std    
  800f1a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f1c:	fc                   	cld    
  800f1d:	eb 1d                	jmp    800f3c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f1f:	89 f2                	mov    %esi,%edx
  800f21:	09 c2                	or     %eax,%edx
  800f23:	f6 c2 03             	test   $0x3,%dl
  800f26:	75 0f                	jne    800f37 <memmove+0x5f>
  800f28:	f6 c1 03             	test   $0x3,%cl
  800f2b:	75 0a                	jne    800f37 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800f2d:	c1 e9 02             	shr    $0x2,%ecx
  800f30:	89 c7                	mov    %eax,%edi
  800f32:	fc                   	cld    
  800f33:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f35:	eb 05                	jmp    800f3c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f37:	89 c7                	mov    %eax,%edi
  800f39:	fc                   	cld    
  800f3a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f3c:	5e                   	pop    %esi
  800f3d:	5f                   	pop    %edi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f43:	ff 75 10             	pushl  0x10(%ebp)
  800f46:	ff 75 0c             	pushl  0xc(%ebp)
  800f49:	ff 75 08             	pushl  0x8(%ebp)
  800f4c:	e8 87 ff ff ff       	call   800ed8 <memmove>
}
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5e:	89 c6                	mov    %eax,%esi
  800f60:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f63:	eb 1a                	jmp    800f7f <memcmp+0x2c>
		if (*s1 != *s2)
  800f65:	0f b6 08             	movzbl (%eax),%ecx
  800f68:	0f b6 1a             	movzbl (%edx),%ebx
  800f6b:	38 d9                	cmp    %bl,%cl
  800f6d:	74 0a                	je     800f79 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f6f:	0f b6 c1             	movzbl %cl,%eax
  800f72:	0f b6 db             	movzbl %bl,%ebx
  800f75:	29 d8                	sub    %ebx,%eax
  800f77:	eb 0f                	jmp    800f88 <memcmp+0x35>
		s1++, s2++;
  800f79:	83 c0 01             	add    $0x1,%eax
  800f7c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f7f:	39 f0                	cmp    %esi,%eax
  800f81:	75 e2                	jne    800f65 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    

00800f8c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	53                   	push   %ebx
  800f90:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f93:	89 c1                	mov    %eax,%ecx
  800f95:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f98:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f9c:	eb 0a                	jmp    800fa8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f9e:	0f b6 10             	movzbl (%eax),%edx
  800fa1:	39 da                	cmp    %ebx,%edx
  800fa3:	74 07                	je     800fac <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fa5:	83 c0 01             	add    $0x1,%eax
  800fa8:	39 c8                	cmp    %ecx,%eax
  800faa:	72 f2                	jb     800f9e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fac:	5b                   	pop    %ebx
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    

00800faf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	57                   	push   %edi
  800fb3:	56                   	push   %esi
  800fb4:	53                   	push   %ebx
  800fb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fbb:	eb 03                	jmp    800fc0 <strtol+0x11>
		s++;
  800fbd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fc0:	0f b6 01             	movzbl (%ecx),%eax
  800fc3:	3c 20                	cmp    $0x20,%al
  800fc5:	74 f6                	je     800fbd <strtol+0xe>
  800fc7:	3c 09                	cmp    $0x9,%al
  800fc9:	74 f2                	je     800fbd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fcb:	3c 2b                	cmp    $0x2b,%al
  800fcd:	75 0a                	jne    800fd9 <strtol+0x2a>
		s++;
  800fcf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fd2:	bf 00 00 00 00       	mov    $0x0,%edi
  800fd7:	eb 11                	jmp    800fea <strtol+0x3b>
  800fd9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fde:	3c 2d                	cmp    $0x2d,%al
  800fe0:	75 08                	jne    800fea <strtol+0x3b>
		s++, neg = 1;
  800fe2:	83 c1 01             	add    $0x1,%ecx
  800fe5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fea:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ff0:	75 15                	jne    801007 <strtol+0x58>
  800ff2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ff5:	75 10                	jne    801007 <strtol+0x58>
  800ff7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ffb:	75 7c                	jne    801079 <strtol+0xca>
		s += 2, base = 16;
  800ffd:	83 c1 02             	add    $0x2,%ecx
  801000:	bb 10 00 00 00       	mov    $0x10,%ebx
  801005:	eb 16                	jmp    80101d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801007:	85 db                	test   %ebx,%ebx
  801009:	75 12                	jne    80101d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80100b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801010:	80 39 30             	cmpb   $0x30,(%ecx)
  801013:	75 08                	jne    80101d <strtol+0x6e>
		s++, base = 8;
  801015:	83 c1 01             	add    $0x1,%ecx
  801018:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80101d:	b8 00 00 00 00       	mov    $0x0,%eax
  801022:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801025:	0f b6 11             	movzbl (%ecx),%edx
  801028:	8d 72 d0             	lea    -0x30(%edx),%esi
  80102b:	89 f3                	mov    %esi,%ebx
  80102d:	80 fb 09             	cmp    $0x9,%bl
  801030:	77 08                	ja     80103a <strtol+0x8b>
			dig = *s - '0';
  801032:	0f be d2             	movsbl %dl,%edx
  801035:	83 ea 30             	sub    $0x30,%edx
  801038:	eb 22                	jmp    80105c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80103a:	8d 72 9f             	lea    -0x61(%edx),%esi
  80103d:	89 f3                	mov    %esi,%ebx
  80103f:	80 fb 19             	cmp    $0x19,%bl
  801042:	77 08                	ja     80104c <strtol+0x9d>
			dig = *s - 'a' + 10;
  801044:	0f be d2             	movsbl %dl,%edx
  801047:	83 ea 57             	sub    $0x57,%edx
  80104a:	eb 10                	jmp    80105c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80104c:	8d 72 bf             	lea    -0x41(%edx),%esi
  80104f:	89 f3                	mov    %esi,%ebx
  801051:	80 fb 19             	cmp    $0x19,%bl
  801054:	77 16                	ja     80106c <strtol+0xbd>
			dig = *s - 'A' + 10;
  801056:	0f be d2             	movsbl %dl,%edx
  801059:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80105c:	3b 55 10             	cmp    0x10(%ebp),%edx
  80105f:	7d 0b                	jge    80106c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801061:	83 c1 01             	add    $0x1,%ecx
  801064:	0f af 45 10          	imul   0x10(%ebp),%eax
  801068:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80106a:	eb b9                	jmp    801025 <strtol+0x76>

	if (endptr)
  80106c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801070:	74 0d                	je     80107f <strtol+0xd0>
		*endptr = (char *) s;
  801072:	8b 75 0c             	mov    0xc(%ebp),%esi
  801075:	89 0e                	mov    %ecx,(%esi)
  801077:	eb 06                	jmp    80107f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801079:	85 db                	test   %ebx,%ebx
  80107b:	74 98                	je     801015 <strtol+0x66>
  80107d:	eb 9e                	jmp    80101d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80107f:	89 c2                	mov    %eax,%edx
  801081:	f7 da                	neg    %edx
  801083:	85 ff                	test   %edi,%edi
  801085:	0f 45 c2             	cmovne %edx,%eax
}
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5f                   	pop    %edi
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    

0080108d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	57                   	push   %edi
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801093:	b8 00 00 00 00       	mov    $0x0,%eax
  801098:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109b:	8b 55 08             	mov    0x8(%ebp),%edx
  80109e:	89 c3                	mov    %eax,%ebx
  8010a0:	89 c7                	mov    %eax,%edi
  8010a2:	89 c6                	mov    %eax,%esi
  8010a4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <sys_cgetc>:

int
sys_cgetc(void)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	57                   	push   %edi
  8010af:	56                   	push   %esi
  8010b0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010bb:	89 d1                	mov    %edx,%ecx
  8010bd:	89 d3                	mov    %edx,%ebx
  8010bf:	89 d7                	mov    %edx,%edi
  8010c1:	89 d6                	mov    %edx,%esi
  8010c3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
  8010d0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010d8:	b8 03 00 00 00       	mov    $0x3,%eax
  8010dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e0:	89 cb                	mov    %ecx,%ebx
  8010e2:	89 cf                	mov    %ecx,%edi
  8010e4:	89 ce                	mov    %ecx,%esi
  8010e6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	7e 17                	jle    801103 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	50                   	push   %eax
  8010f0:	6a 03                	push   $0x3
  8010f2:	68 5f 2b 80 00       	push   $0x802b5f
  8010f7:	6a 23                	push   $0x23
  8010f9:	68 7c 2b 80 00       	push   $0x802b7c
  8010fe:	e8 e5 f5 ff ff       	call   8006e8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801103:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801106:	5b                   	pop    %ebx
  801107:	5e                   	pop    %esi
  801108:	5f                   	pop    %edi
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	57                   	push   %edi
  80110f:	56                   	push   %esi
  801110:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801111:	ba 00 00 00 00       	mov    $0x0,%edx
  801116:	b8 02 00 00 00       	mov    $0x2,%eax
  80111b:	89 d1                	mov    %edx,%ecx
  80111d:	89 d3                	mov    %edx,%ebx
  80111f:	89 d7                	mov    %edx,%edi
  801121:	89 d6                	mov    %edx,%esi
  801123:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801125:	5b                   	pop    %ebx
  801126:	5e                   	pop    %esi
  801127:	5f                   	pop    %edi
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    

0080112a <sys_yield>:

void
sys_yield(void)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	57                   	push   %edi
  80112e:	56                   	push   %esi
  80112f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801130:	ba 00 00 00 00       	mov    $0x0,%edx
  801135:	b8 0b 00 00 00       	mov    $0xb,%eax
  80113a:	89 d1                	mov    %edx,%ecx
  80113c:	89 d3                	mov    %edx,%ebx
  80113e:	89 d7                	mov    %edx,%edi
  801140:	89 d6                	mov    %edx,%esi
  801142:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801144:	5b                   	pop    %ebx
  801145:	5e                   	pop    %esi
  801146:	5f                   	pop    %edi
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    

00801149 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	57                   	push   %edi
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
  80114f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801152:	be 00 00 00 00       	mov    $0x0,%esi
  801157:	b8 04 00 00 00       	mov    $0x4,%eax
  80115c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115f:	8b 55 08             	mov    0x8(%ebp),%edx
  801162:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801165:	89 f7                	mov    %esi,%edi
  801167:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801169:	85 c0                	test   %eax,%eax
  80116b:	7e 17                	jle    801184 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	50                   	push   %eax
  801171:	6a 04                	push   $0x4
  801173:	68 5f 2b 80 00       	push   $0x802b5f
  801178:	6a 23                	push   $0x23
  80117a:	68 7c 2b 80 00       	push   $0x802b7c
  80117f:	e8 64 f5 ff ff       	call   8006e8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801184:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5f                   	pop    %edi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	57                   	push   %edi
  801190:	56                   	push   %esi
  801191:	53                   	push   %ebx
  801192:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801195:	b8 05 00 00 00       	mov    $0x5,%eax
  80119a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119d:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011a3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011a6:	8b 75 18             	mov    0x18(%ebp),%esi
  8011a9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	7e 17                	jle    8011c6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011af:	83 ec 0c             	sub    $0xc,%esp
  8011b2:	50                   	push   %eax
  8011b3:	6a 05                	push   $0x5
  8011b5:	68 5f 2b 80 00       	push   $0x802b5f
  8011ba:	6a 23                	push   $0x23
  8011bc:	68 7c 2b 80 00       	push   $0x802b7c
  8011c1:	e8 22 f5 ff ff       	call   8006e8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c9:	5b                   	pop    %ebx
  8011ca:	5e                   	pop    %esi
  8011cb:	5f                   	pop    %edi
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	57                   	push   %edi
  8011d2:	56                   	push   %esi
  8011d3:	53                   	push   %ebx
  8011d4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011dc:	b8 06 00 00 00       	mov    $0x6,%eax
  8011e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e7:	89 df                	mov    %ebx,%edi
  8011e9:	89 de                	mov    %ebx,%esi
  8011eb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	7e 17                	jle    801208 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f1:	83 ec 0c             	sub    $0xc,%esp
  8011f4:	50                   	push   %eax
  8011f5:	6a 06                	push   $0x6
  8011f7:	68 5f 2b 80 00       	push   $0x802b5f
  8011fc:	6a 23                	push   $0x23
  8011fe:	68 7c 2b 80 00       	push   $0x802b7c
  801203:	e8 e0 f4 ff ff       	call   8006e8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120b:	5b                   	pop    %ebx
  80120c:	5e                   	pop    %esi
  80120d:	5f                   	pop    %edi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	57                   	push   %edi
  801214:	56                   	push   %esi
  801215:	53                   	push   %ebx
  801216:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801219:	bb 00 00 00 00       	mov    $0x0,%ebx
  80121e:	b8 08 00 00 00       	mov    $0x8,%eax
  801223:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801226:	8b 55 08             	mov    0x8(%ebp),%edx
  801229:	89 df                	mov    %ebx,%edi
  80122b:	89 de                	mov    %ebx,%esi
  80122d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80122f:	85 c0                	test   %eax,%eax
  801231:	7e 17                	jle    80124a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801233:	83 ec 0c             	sub    $0xc,%esp
  801236:	50                   	push   %eax
  801237:	6a 08                	push   $0x8
  801239:	68 5f 2b 80 00       	push   $0x802b5f
  80123e:	6a 23                	push   $0x23
  801240:	68 7c 2b 80 00       	push   $0x802b7c
  801245:	e8 9e f4 ff ff       	call   8006e8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80124a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	57                   	push   %edi
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80125b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801260:	b8 09 00 00 00       	mov    $0x9,%eax
  801265:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801268:	8b 55 08             	mov    0x8(%ebp),%edx
  80126b:	89 df                	mov    %ebx,%edi
  80126d:	89 de                	mov    %ebx,%esi
  80126f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801271:	85 c0                	test   %eax,%eax
  801273:	7e 17                	jle    80128c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801275:	83 ec 0c             	sub    $0xc,%esp
  801278:	50                   	push   %eax
  801279:	6a 09                	push   $0x9
  80127b:	68 5f 2b 80 00       	push   $0x802b5f
  801280:	6a 23                	push   $0x23
  801282:	68 7c 2b 80 00       	push   $0x802b7c
  801287:	e8 5c f4 ff ff       	call   8006e8 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80128c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128f:	5b                   	pop    %ebx
  801290:	5e                   	pop    %esi
  801291:	5f                   	pop    %edi
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    

00801294 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	57                   	push   %edi
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
  80129a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80129d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ad:	89 df                	mov    %ebx,%edi
  8012af:	89 de                	mov    %ebx,%esi
  8012b1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	7e 17                	jle    8012ce <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b7:	83 ec 0c             	sub    $0xc,%esp
  8012ba:	50                   	push   %eax
  8012bb:	6a 0a                	push   $0xa
  8012bd:	68 5f 2b 80 00       	push   $0x802b5f
  8012c2:	6a 23                	push   $0x23
  8012c4:	68 7c 2b 80 00       	push   $0x802b7c
  8012c9:	e8 1a f4 ff ff       	call   8006e8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	5f                   	pop    %edi
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    

008012d6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	57                   	push   %edi
  8012da:	56                   	push   %esi
  8012db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012dc:	be 00 00 00 00       	mov    $0x0,%esi
  8012e1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012ef:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012f2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012f4:	5b                   	pop    %ebx
  8012f5:	5e                   	pop    %esi
  8012f6:	5f                   	pop    %edi
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	57                   	push   %edi
  8012fd:	56                   	push   %esi
  8012fe:	53                   	push   %ebx
  8012ff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801302:	b9 00 00 00 00       	mov    $0x0,%ecx
  801307:	b8 0d 00 00 00       	mov    $0xd,%eax
  80130c:	8b 55 08             	mov    0x8(%ebp),%edx
  80130f:	89 cb                	mov    %ecx,%ebx
  801311:	89 cf                	mov    %ecx,%edi
  801313:	89 ce                	mov    %ecx,%esi
  801315:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801317:	85 c0                	test   %eax,%eax
  801319:	7e 17                	jle    801332 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80131b:	83 ec 0c             	sub    $0xc,%esp
  80131e:	50                   	push   %eax
  80131f:	6a 0d                	push   $0xd
  801321:	68 5f 2b 80 00       	push   $0x802b5f
  801326:	6a 23                	push   $0x23
  801328:	68 7c 2b 80 00       	push   $0x802b7c
  80132d:	e8 b6 f3 ff ff       	call   8006e8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801332:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801335:	5b                   	pop    %ebx
  801336:	5e                   	pop    %esi
  801337:	5f                   	pop    %edi
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    

0080133a <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	57                   	push   %edi
  80133e:	56                   	push   %esi
  80133f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801340:	b9 00 00 00 00       	mov    $0x0,%ecx
  801345:	b8 0e 00 00 00       	mov    $0xe,%eax
  80134a:	8b 55 08             	mov    0x8(%ebp),%edx
  80134d:	89 cb                	mov    %ecx,%ebx
  80134f:	89 cf                	mov    %ecx,%edi
  801351:	89 ce                	mov    %ecx,%esi
  801353:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  801355:	5b                   	pop    %ebx
  801356:	5e                   	pop    %esi
  801357:	5f                   	pop    %edi
  801358:	5d                   	pop    %ebp
  801359:	c3                   	ret    

0080135a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	56                   	push   %esi
  80135e:	53                   	push   %ebx
  80135f:	8b 75 08             	mov    0x8(%ebp),%esi
  801362:	8b 45 0c             	mov    0xc(%ebp),%eax
  801365:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801368:	85 c0                	test   %eax,%eax
  80136a:	75 12                	jne    80137e <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80136c:	83 ec 0c             	sub    $0xc,%esp
  80136f:	68 00 00 c0 ee       	push   $0xeec00000
  801374:	e8 80 ff ff ff       	call   8012f9 <sys_ipc_recv>
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	eb 0c                	jmp    80138a <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80137e:	83 ec 0c             	sub    $0xc,%esp
  801381:	50                   	push   %eax
  801382:	e8 72 ff ff ff       	call   8012f9 <sys_ipc_recv>
  801387:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80138a:	85 f6                	test   %esi,%esi
  80138c:	0f 95 c1             	setne  %cl
  80138f:	85 db                	test   %ebx,%ebx
  801391:	0f 95 c2             	setne  %dl
  801394:	84 d1                	test   %dl,%cl
  801396:	74 09                	je     8013a1 <ipc_recv+0x47>
  801398:	89 c2                	mov    %eax,%edx
  80139a:	c1 ea 1f             	shr    $0x1f,%edx
  80139d:	84 d2                	test   %dl,%dl
  80139f:	75 27                	jne    8013c8 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8013a1:	85 f6                	test   %esi,%esi
  8013a3:	74 0a                	je     8013af <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  8013a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8013aa:	8b 40 7c             	mov    0x7c(%eax),%eax
  8013ad:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8013af:	85 db                	test   %ebx,%ebx
  8013b1:	74 0d                	je     8013c0 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  8013b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8013b8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8013be:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8013c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8013c5:	8b 40 78             	mov    0x78(%eax),%eax
}
  8013c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013cb:	5b                   	pop    %ebx
  8013cc:	5e                   	pop    %esi
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    

008013cf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	57                   	push   %edi
  8013d3:	56                   	push   %esi
  8013d4:	53                   	push   %ebx
  8013d5:	83 ec 0c             	sub    $0xc,%esp
  8013d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013db:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8013e1:	85 db                	test   %ebx,%ebx
  8013e3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8013e8:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8013eb:	ff 75 14             	pushl  0x14(%ebp)
  8013ee:	53                   	push   %ebx
  8013ef:	56                   	push   %esi
  8013f0:	57                   	push   %edi
  8013f1:	e8 e0 fe ff ff       	call   8012d6 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8013f6:	89 c2                	mov    %eax,%edx
  8013f8:	c1 ea 1f             	shr    $0x1f,%edx
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	84 d2                	test   %dl,%dl
  801400:	74 17                	je     801419 <ipc_send+0x4a>
  801402:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801405:	74 12                	je     801419 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801407:	50                   	push   %eax
  801408:	68 8a 2b 80 00       	push   $0x802b8a
  80140d:	6a 47                	push   $0x47
  80140f:	68 98 2b 80 00       	push   $0x802b98
  801414:	e8 cf f2 ff ff       	call   8006e8 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801419:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80141c:	75 07                	jne    801425 <ipc_send+0x56>
			sys_yield();
  80141e:	e8 07 fd ff ff       	call   80112a <sys_yield>
  801423:	eb c6                	jmp    8013eb <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801425:	85 c0                	test   %eax,%eax
  801427:	75 c2                	jne    8013eb <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801429:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142c:	5b                   	pop    %ebx
  80142d:	5e                   	pop    %esi
  80142e:	5f                   	pop    %edi
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    

00801431 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801437:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80143c:	89 c2                	mov    %eax,%edx
  80143e:	c1 e2 07             	shl    $0x7,%edx
  801441:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801448:	8b 52 58             	mov    0x58(%edx),%edx
  80144b:	39 ca                	cmp    %ecx,%edx
  80144d:	75 11                	jne    801460 <ipc_find_env+0x2f>
			return envs[i].env_id;
  80144f:	89 c2                	mov    %eax,%edx
  801451:	c1 e2 07             	shl    $0x7,%edx
  801454:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80145b:	8b 40 50             	mov    0x50(%eax),%eax
  80145e:	eb 0f                	jmp    80146f <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801460:	83 c0 01             	add    $0x1,%eax
  801463:	3d 00 04 00 00       	cmp    $0x400,%eax
  801468:	75 d2                	jne    80143c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80146a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80146f:	5d                   	pop    %ebp
  801470:	c3                   	ret    

00801471 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801474:	8b 45 08             	mov    0x8(%ebp),%eax
  801477:	05 00 00 00 30       	add    $0x30000000,%eax
  80147c:	c1 e8 0c             	shr    $0xc,%eax
}
  80147f:	5d                   	pop    %ebp
  801480:	c3                   	ret    

00801481 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801484:	8b 45 08             	mov    0x8(%ebp),%eax
  801487:	05 00 00 00 30       	add    $0x30000000,%eax
  80148c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801491:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801496:	5d                   	pop    %ebp
  801497:	c3                   	ret    

00801498 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80149e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014a3:	89 c2                	mov    %eax,%edx
  8014a5:	c1 ea 16             	shr    $0x16,%edx
  8014a8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014af:	f6 c2 01             	test   $0x1,%dl
  8014b2:	74 11                	je     8014c5 <fd_alloc+0x2d>
  8014b4:	89 c2                	mov    %eax,%edx
  8014b6:	c1 ea 0c             	shr    $0xc,%edx
  8014b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014c0:	f6 c2 01             	test   $0x1,%dl
  8014c3:	75 09                	jne    8014ce <fd_alloc+0x36>
			*fd_store = fd;
  8014c5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014cc:	eb 17                	jmp    8014e5 <fd_alloc+0x4d>
  8014ce:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014d3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014d8:	75 c9                	jne    8014a3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014da:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014e0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014e5:	5d                   	pop    %ebp
  8014e6:	c3                   	ret    

008014e7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014ed:	83 f8 1f             	cmp    $0x1f,%eax
  8014f0:	77 36                	ja     801528 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014f2:	c1 e0 0c             	shl    $0xc,%eax
  8014f5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014fa:	89 c2                	mov    %eax,%edx
  8014fc:	c1 ea 16             	shr    $0x16,%edx
  8014ff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801506:	f6 c2 01             	test   $0x1,%dl
  801509:	74 24                	je     80152f <fd_lookup+0x48>
  80150b:	89 c2                	mov    %eax,%edx
  80150d:	c1 ea 0c             	shr    $0xc,%edx
  801510:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801517:	f6 c2 01             	test   $0x1,%dl
  80151a:	74 1a                	je     801536 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80151c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80151f:	89 02                	mov    %eax,(%edx)
	return 0;
  801521:	b8 00 00 00 00       	mov    $0x0,%eax
  801526:	eb 13                	jmp    80153b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801528:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152d:	eb 0c                	jmp    80153b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80152f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801534:	eb 05                	jmp    80153b <fd_lookup+0x54>
  801536:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    

0080153d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801546:	ba 24 2c 80 00       	mov    $0x802c24,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80154b:	eb 13                	jmp    801560 <dev_lookup+0x23>
  80154d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801550:	39 08                	cmp    %ecx,(%eax)
  801552:	75 0c                	jne    801560 <dev_lookup+0x23>
			*dev = devtab[i];
  801554:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801557:	89 01                	mov    %eax,(%ecx)
			return 0;
  801559:	b8 00 00 00 00       	mov    $0x0,%eax
  80155e:	eb 2e                	jmp    80158e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801560:	8b 02                	mov    (%edx),%eax
  801562:	85 c0                	test   %eax,%eax
  801564:	75 e7                	jne    80154d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801566:	a1 04 40 80 00       	mov    0x804004,%eax
  80156b:	8b 40 50             	mov    0x50(%eax),%eax
  80156e:	83 ec 04             	sub    $0x4,%esp
  801571:	51                   	push   %ecx
  801572:	50                   	push   %eax
  801573:	68 a4 2b 80 00       	push   $0x802ba4
  801578:	e8 44 f2 ff ff       	call   8007c1 <cprintf>
	*dev = 0;
  80157d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801580:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80158e:	c9                   	leave  
  80158f:	c3                   	ret    

00801590 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	56                   	push   %esi
  801594:	53                   	push   %ebx
  801595:	83 ec 10             	sub    $0x10,%esp
  801598:	8b 75 08             	mov    0x8(%ebp),%esi
  80159b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80159e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a1:	50                   	push   %eax
  8015a2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015a8:	c1 e8 0c             	shr    $0xc,%eax
  8015ab:	50                   	push   %eax
  8015ac:	e8 36 ff ff ff       	call   8014e7 <fd_lookup>
  8015b1:	83 c4 08             	add    $0x8,%esp
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 05                	js     8015bd <fd_close+0x2d>
	    || fd != fd2)
  8015b8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015bb:	74 0c                	je     8015c9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015bd:	84 db                	test   %bl,%bl
  8015bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c4:	0f 44 c2             	cmove  %edx,%eax
  8015c7:	eb 41                	jmp    80160a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cf:	50                   	push   %eax
  8015d0:	ff 36                	pushl  (%esi)
  8015d2:	e8 66 ff ff ff       	call   80153d <dev_lookup>
  8015d7:	89 c3                	mov    %eax,%ebx
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 1a                	js     8015fa <fd_close+0x6a>
		if (dev->dev_close)
  8015e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015e6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	74 0b                	je     8015fa <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015ef:	83 ec 0c             	sub    $0xc,%esp
  8015f2:	56                   	push   %esi
  8015f3:	ff d0                	call   *%eax
  8015f5:	89 c3                	mov    %eax,%ebx
  8015f7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015fa:	83 ec 08             	sub    $0x8,%esp
  8015fd:	56                   	push   %esi
  8015fe:	6a 00                	push   $0x0
  801600:	e8 c9 fb ff ff       	call   8011ce <sys_page_unmap>
	return r;
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	89 d8                	mov    %ebx,%eax
}
  80160a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160d:	5b                   	pop    %ebx
  80160e:	5e                   	pop    %esi
  80160f:	5d                   	pop    %ebp
  801610:	c3                   	ret    

00801611 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801617:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161a:	50                   	push   %eax
  80161b:	ff 75 08             	pushl  0x8(%ebp)
  80161e:	e8 c4 fe ff ff       	call   8014e7 <fd_lookup>
  801623:	83 c4 08             	add    $0x8,%esp
  801626:	85 c0                	test   %eax,%eax
  801628:	78 10                	js     80163a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80162a:	83 ec 08             	sub    $0x8,%esp
  80162d:	6a 01                	push   $0x1
  80162f:	ff 75 f4             	pushl  -0xc(%ebp)
  801632:	e8 59 ff ff ff       	call   801590 <fd_close>
  801637:	83 c4 10             	add    $0x10,%esp
}
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <close_all>:

void
close_all(void)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	53                   	push   %ebx
  801640:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801643:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801648:	83 ec 0c             	sub    $0xc,%esp
  80164b:	53                   	push   %ebx
  80164c:	e8 c0 ff ff ff       	call   801611 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801651:	83 c3 01             	add    $0x1,%ebx
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	83 fb 20             	cmp    $0x20,%ebx
  80165a:	75 ec                	jne    801648 <close_all+0xc>
		close(i);
}
  80165c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165f:	c9                   	leave  
  801660:	c3                   	ret    

00801661 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	57                   	push   %edi
  801665:	56                   	push   %esi
  801666:	53                   	push   %ebx
  801667:	83 ec 2c             	sub    $0x2c,%esp
  80166a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80166d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801670:	50                   	push   %eax
  801671:	ff 75 08             	pushl  0x8(%ebp)
  801674:	e8 6e fe ff ff       	call   8014e7 <fd_lookup>
  801679:	83 c4 08             	add    $0x8,%esp
  80167c:	85 c0                	test   %eax,%eax
  80167e:	0f 88 c1 00 00 00    	js     801745 <dup+0xe4>
		return r;
	close(newfdnum);
  801684:	83 ec 0c             	sub    $0xc,%esp
  801687:	56                   	push   %esi
  801688:	e8 84 ff ff ff       	call   801611 <close>

	newfd = INDEX2FD(newfdnum);
  80168d:	89 f3                	mov    %esi,%ebx
  80168f:	c1 e3 0c             	shl    $0xc,%ebx
  801692:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801698:	83 c4 04             	add    $0x4,%esp
  80169b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80169e:	e8 de fd ff ff       	call   801481 <fd2data>
  8016a3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016a5:	89 1c 24             	mov    %ebx,(%esp)
  8016a8:	e8 d4 fd ff ff       	call   801481 <fd2data>
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016b3:	89 f8                	mov    %edi,%eax
  8016b5:	c1 e8 16             	shr    $0x16,%eax
  8016b8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016bf:	a8 01                	test   $0x1,%al
  8016c1:	74 37                	je     8016fa <dup+0x99>
  8016c3:	89 f8                	mov    %edi,%eax
  8016c5:	c1 e8 0c             	shr    $0xc,%eax
  8016c8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016cf:	f6 c2 01             	test   $0x1,%dl
  8016d2:	74 26                	je     8016fa <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016d4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016db:	83 ec 0c             	sub    $0xc,%esp
  8016de:	25 07 0e 00 00       	and    $0xe07,%eax
  8016e3:	50                   	push   %eax
  8016e4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016e7:	6a 00                	push   $0x0
  8016e9:	57                   	push   %edi
  8016ea:	6a 00                	push   $0x0
  8016ec:	e8 9b fa ff ff       	call   80118c <sys_page_map>
  8016f1:	89 c7                	mov    %eax,%edi
  8016f3:	83 c4 20             	add    $0x20,%esp
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 2e                	js     801728 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016fd:	89 d0                	mov    %edx,%eax
  8016ff:	c1 e8 0c             	shr    $0xc,%eax
  801702:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801709:	83 ec 0c             	sub    $0xc,%esp
  80170c:	25 07 0e 00 00       	and    $0xe07,%eax
  801711:	50                   	push   %eax
  801712:	53                   	push   %ebx
  801713:	6a 00                	push   $0x0
  801715:	52                   	push   %edx
  801716:	6a 00                	push   $0x0
  801718:	e8 6f fa ff ff       	call   80118c <sys_page_map>
  80171d:	89 c7                	mov    %eax,%edi
  80171f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801722:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801724:	85 ff                	test   %edi,%edi
  801726:	79 1d                	jns    801745 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801728:	83 ec 08             	sub    $0x8,%esp
  80172b:	53                   	push   %ebx
  80172c:	6a 00                	push   $0x0
  80172e:	e8 9b fa ff ff       	call   8011ce <sys_page_unmap>
	sys_page_unmap(0, nva);
  801733:	83 c4 08             	add    $0x8,%esp
  801736:	ff 75 d4             	pushl  -0x2c(%ebp)
  801739:	6a 00                	push   $0x0
  80173b:	e8 8e fa ff ff       	call   8011ce <sys_page_unmap>
	return r;
  801740:	83 c4 10             	add    $0x10,%esp
  801743:	89 f8                	mov    %edi,%eax
}
  801745:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801748:	5b                   	pop    %ebx
  801749:	5e                   	pop    %esi
  80174a:	5f                   	pop    %edi
  80174b:	5d                   	pop    %ebp
  80174c:	c3                   	ret    

0080174d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	53                   	push   %ebx
  801751:	83 ec 14             	sub    $0x14,%esp
  801754:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801757:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175a:	50                   	push   %eax
  80175b:	53                   	push   %ebx
  80175c:	e8 86 fd ff ff       	call   8014e7 <fd_lookup>
  801761:	83 c4 08             	add    $0x8,%esp
  801764:	89 c2                	mov    %eax,%edx
  801766:	85 c0                	test   %eax,%eax
  801768:	78 6d                	js     8017d7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176a:	83 ec 08             	sub    $0x8,%esp
  80176d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801770:	50                   	push   %eax
  801771:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801774:	ff 30                	pushl  (%eax)
  801776:	e8 c2 fd ff ff       	call   80153d <dev_lookup>
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 4c                	js     8017ce <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801782:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801785:	8b 42 08             	mov    0x8(%edx),%eax
  801788:	83 e0 03             	and    $0x3,%eax
  80178b:	83 f8 01             	cmp    $0x1,%eax
  80178e:	75 21                	jne    8017b1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801790:	a1 04 40 80 00       	mov    0x804004,%eax
  801795:	8b 40 50             	mov    0x50(%eax),%eax
  801798:	83 ec 04             	sub    $0x4,%esp
  80179b:	53                   	push   %ebx
  80179c:	50                   	push   %eax
  80179d:	68 e8 2b 80 00       	push   $0x802be8
  8017a2:	e8 1a f0 ff ff       	call   8007c1 <cprintf>
		return -E_INVAL;
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017af:	eb 26                	jmp    8017d7 <read+0x8a>
	}
	if (!dev->dev_read)
  8017b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b4:	8b 40 08             	mov    0x8(%eax),%eax
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	74 17                	je     8017d2 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8017bb:	83 ec 04             	sub    $0x4,%esp
  8017be:	ff 75 10             	pushl  0x10(%ebp)
  8017c1:	ff 75 0c             	pushl  0xc(%ebp)
  8017c4:	52                   	push   %edx
  8017c5:	ff d0                	call   *%eax
  8017c7:	89 c2                	mov    %eax,%edx
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	eb 09                	jmp    8017d7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ce:	89 c2                	mov    %eax,%edx
  8017d0:	eb 05                	jmp    8017d7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017d2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8017d7:	89 d0                	mov    %edx,%eax
  8017d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017dc:	c9                   	leave  
  8017dd:	c3                   	ret    

008017de <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	57                   	push   %edi
  8017e2:	56                   	push   %esi
  8017e3:	53                   	push   %ebx
  8017e4:	83 ec 0c             	sub    $0xc,%esp
  8017e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f2:	eb 21                	jmp    801815 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017f4:	83 ec 04             	sub    $0x4,%esp
  8017f7:	89 f0                	mov    %esi,%eax
  8017f9:	29 d8                	sub    %ebx,%eax
  8017fb:	50                   	push   %eax
  8017fc:	89 d8                	mov    %ebx,%eax
  8017fe:	03 45 0c             	add    0xc(%ebp),%eax
  801801:	50                   	push   %eax
  801802:	57                   	push   %edi
  801803:	e8 45 ff ff ff       	call   80174d <read>
		if (m < 0)
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 10                	js     80181f <readn+0x41>
			return m;
		if (m == 0)
  80180f:	85 c0                	test   %eax,%eax
  801811:	74 0a                	je     80181d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801813:	01 c3                	add    %eax,%ebx
  801815:	39 f3                	cmp    %esi,%ebx
  801817:	72 db                	jb     8017f4 <readn+0x16>
  801819:	89 d8                	mov    %ebx,%eax
  80181b:	eb 02                	jmp    80181f <readn+0x41>
  80181d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80181f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801822:	5b                   	pop    %ebx
  801823:	5e                   	pop    %esi
  801824:	5f                   	pop    %edi
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    

00801827 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	53                   	push   %ebx
  80182b:	83 ec 14             	sub    $0x14,%esp
  80182e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801831:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801834:	50                   	push   %eax
  801835:	53                   	push   %ebx
  801836:	e8 ac fc ff ff       	call   8014e7 <fd_lookup>
  80183b:	83 c4 08             	add    $0x8,%esp
  80183e:	89 c2                	mov    %eax,%edx
  801840:	85 c0                	test   %eax,%eax
  801842:	78 68                	js     8018ac <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184a:	50                   	push   %eax
  80184b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184e:	ff 30                	pushl  (%eax)
  801850:	e8 e8 fc ff ff       	call   80153d <dev_lookup>
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	85 c0                	test   %eax,%eax
  80185a:	78 47                	js     8018a3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80185c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801863:	75 21                	jne    801886 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801865:	a1 04 40 80 00       	mov    0x804004,%eax
  80186a:	8b 40 50             	mov    0x50(%eax),%eax
  80186d:	83 ec 04             	sub    $0x4,%esp
  801870:	53                   	push   %ebx
  801871:	50                   	push   %eax
  801872:	68 04 2c 80 00       	push   $0x802c04
  801877:	e8 45 ef ff ff       	call   8007c1 <cprintf>
		return -E_INVAL;
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801884:	eb 26                	jmp    8018ac <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801886:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801889:	8b 52 0c             	mov    0xc(%edx),%edx
  80188c:	85 d2                	test   %edx,%edx
  80188e:	74 17                	je     8018a7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801890:	83 ec 04             	sub    $0x4,%esp
  801893:	ff 75 10             	pushl  0x10(%ebp)
  801896:	ff 75 0c             	pushl  0xc(%ebp)
  801899:	50                   	push   %eax
  80189a:	ff d2                	call   *%edx
  80189c:	89 c2                	mov    %eax,%edx
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	eb 09                	jmp    8018ac <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a3:	89 c2                	mov    %eax,%edx
  8018a5:	eb 05                	jmp    8018ac <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018ac:	89 d0                	mov    %edx,%eax
  8018ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b1:	c9                   	leave  
  8018b2:	c3                   	ret    

008018b3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018b9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018bc:	50                   	push   %eax
  8018bd:	ff 75 08             	pushl  0x8(%ebp)
  8018c0:	e8 22 fc ff ff       	call   8014e7 <fd_lookup>
  8018c5:	83 c4 08             	add    $0x8,%esp
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	78 0e                	js     8018da <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	53                   	push   %ebx
  8018e0:	83 ec 14             	sub    $0x14,%esp
  8018e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e9:	50                   	push   %eax
  8018ea:	53                   	push   %ebx
  8018eb:	e8 f7 fb ff ff       	call   8014e7 <fd_lookup>
  8018f0:	83 c4 08             	add    $0x8,%esp
  8018f3:	89 c2                	mov    %eax,%edx
  8018f5:	85 c0                	test   %eax,%eax
  8018f7:	78 65                	js     80195e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f9:	83 ec 08             	sub    $0x8,%esp
  8018fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ff:	50                   	push   %eax
  801900:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801903:	ff 30                	pushl  (%eax)
  801905:	e8 33 fc ff ff       	call   80153d <dev_lookup>
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	85 c0                	test   %eax,%eax
  80190f:	78 44                	js     801955 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801911:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801914:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801918:	75 21                	jne    80193b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80191a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80191f:	8b 40 50             	mov    0x50(%eax),%eax
  801922:	83 ec 04             	sub    $0x4,%esp
  801925:	53                   	push   %ebx
  801926:	50                   	push   %eax
  801927:	68 c4 2b 80 00       	push   $0x802bc4
  80192c:	e8 90 ee ff ff       	call   8007c1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801939:	eb 23                	jmp    80195e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80193b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193e:	8b 52 18             	mov    0x18(%edx),%edx
  801941:	85 d2                	test   %edx,%edx
  801943:	74 14                	je     801959 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801945:	83 ec 08             	sub    $0x8,%esp
  801948:	ff 75 0c             	pushl  0xc(%ebp)
  80194b:	50                   	push   %eax
  80194c:	ff d2                	call   *%edx
  80194e:	89 c2                	mov    %eax,%edx
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	eb 09                	jmp    80195e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801955:	89 c2                	mov    %eax,%edx
  801957:	eb 05                	jmp    80195e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801959:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80195e:	89 d0                	mov    %edx,%eax
  801960:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801963:	c9                   	leave  
  801964:	c3                   	ret    

00801965 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	53                   	push   %ebx
  801969:	83 ec 14             	sub    $0x14,%esp
  80196c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80196f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801972:	50                   	push   %eax
  801973:	ff 75 08             	pushl  0x8(%ebp)
  801976:	e8 6c fb ff ff       	call   8014e7 <fd_lookup>
  80197b:	83 c4 08             	add    $0x8,%esp
  80197e:	89 c2                	mov    %eax,%edx
  801980:	85 c0                	test   %eax,%eax
  801982:	78 58                	js     8019dc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801984:	83 ec 08             	sub    $0x8,%esp
  801987:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198a:	50                   	push   %eax
  80198b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198e:	ff 30                	pushl  (%eax)
  801990:	e8 a8 fb ff ff       	call   80153d <dev_lookup>
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	85 c0                	test   %eax,%eax
  80199a:	78 37                	js     8019d3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80199c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019a3:	74 32                	je     8019d7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019a5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019a8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019af:	00 00 00 
	stat->st_isdir = 0;
  8019b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019b9:	00 00 00 
	stat->st_dev = dev;
  8019bc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019c2:	83 ec 08             	sub    $0x8,%esp
  8019c5:	53                   	push   %ebx
  8019c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8019c9:	ff 50 14             	call   *0x14(%eax)
  8019cc:	89 c2                	mov    %eax,%edx
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	eb 09                	jmp    8019dc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d3:	89 c2                	mov    %eax,%edx
  8019d5:	eb 05                	jmp    8019dc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019dc:	89 d0                	mov    %edx,%eax
  8019de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	56                   	push   %esi
  8019e7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019e8:	83 ec 08             	sub    $0x8,%esp
  8019eb:	6a 00                	push   $0x0
  8019ed:	ff 75 08             	pushl  0x8(%ebp)
  8019f0:	e8 e3 01 00 00       	call   801bd8 <open>
  8019f5:	89 c3                	mov    %eax,%ebx
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	78 1b                	js     801a19 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019fe:	83 ec 08             	sub    $0x8,%esp
  801a01:	ff 75 0c             	pushl  0xc(%ebp)
  801a04:	50                   	push   %eax
  801a05:	e8 5b ff ff ff       	call   801965 <fstat>
  801a0a:	89 c6                	mov    %eax,%esi
	close(fd);
  801a0c:	89 1c 24             	mov    %ebx,(%esp)
  801a0f:	e8 fd fb ff ff       	call   801611 <close>
	return r;
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	89 f0                	mov    %esi,%eax
}
  801a19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1c:	5b                   	pop    %ebx
  801a1d:	5e                   	pop    %esi
  801a1e:	5d                   	pop    %ebp
  801a1f:	c3                   	ret    

00801a20 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	56                   	push   %esi
  801a24:	53                   	push   %ebx
  801a25:	89 c6                	mov    %eax,%esi
  801a27:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a29:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a30:	75 12                	jne    801a44 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a32:	83 ec 0c             	sub    $0xc,%esp
  801a35:	6a 01                	push   $0x1
  801a37:	e8 f5 f9 ff ff       	call   801431 <ipc_find_env>
  801a3c:	a3 00 40 80 00       	mov    %eax,0x804000
  801a41:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a44:	6a 07                	push   $0x7
  801a46:	68 00 50 80 00       	push   $0x805000
  801a4b:	56                   	push   %esi
  801a4c:	ff 35 00 40 80 00    	pushl  0x804000
  801a52:	e8 78 f9 ff ff       	call   8013cf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a57:	83 c4 0c             	add    $0xc,%esp
  801a5a:	6a 00                	push   $0x0
  801a5c:	53                   	push   %ebx
  801a5d:	6a 00                	push   $0x0
  801a5f:	e8 f6 f8 ff ff       	call   80135a <ipc_recv>
}
  801a64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a71:	8b 45 08             	mov    0x8(%ebp),%eax
  801a74:	8b 40 0c             	mov    0xc(%eax),%eax
  801a77:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a84:	ba 00 00 00 00       	mov    $0x0,%edx
  801a89:	b8 02 00 00 00       	mov    $0x2,%eax
  801a8e:	e8 8d ff ff ff       	call   801a20 <fsipc>
}
  801a93:	c9                   	leave  
  801a94:	c3                   	ret    

00801a95 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9e:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801aa6:	ba 00 00 00 00       	mov    $0x0,%edx
  801aab:	b8 06 00 00 00       	mov    $0x6,%eax
  801ab0:	e8 6b ff ff ff       	call   801a20 <fsipc>
}
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	53                   	push   %ebx
  801abb:	83 ec 04             	sub    $0x4,%esp
  801abe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac4:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801acc:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad1:	b8 05 00 00 00       	mov    $0x5,%eax
  801ad6:	e8 45 ff ff ff       	call   801a20 <fsipc>
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 2c                	js     801b0b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801adf:	83 ec 08             	sub    $0x8,%esp
  801ae2:	68 00 50 80 00       	push   $0x805000
  801ae7:	53                   	push   %ebx
  801ae8:	e8 59 f2 ff ff       	call   800d46 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aed:	a1 80 50 80 00       	mov    0x805080,%eax
  801af2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801af8:	a1 84 50 80 00       	mov    0x805084,%eax
  801afd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 0c             	sub    $0xc,%esp
  801b16:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b19:	8b 55 08             	mov    0x8(%ebp),%edx
  801b1c:	8b 52 0c             	mov    0xc(%edx),%edx
  801b1f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b25:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b2a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b2f:	0f 47 c2             	cmova  %edx,%eax
  801b32:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b37:	50                   	push   %eax
  801b38:	ff 75 0c             	pushl  0xc(%ebp)
  801b3b:	68 08 50 80 00       	push   $0x805008
  801b40:	e8 93 f3 ff ff       	call   800ed8 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b45:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4a:	b8 04 00 00 00       	mov    $0x4,%eax
  801b4f:	e8 cc fe ff ff       	call   801a20 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b54:	c9                   	leave  
  801b55:	c3                   	ret    

00801b56 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	56                   	push   %esi
  801b5a:	53                   	push   %ebx
  801b5b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b61:	8b 40 0c             	mov    0xc(%eax),%eax
  801b64:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b69:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b74:	b8 03 00 00 00       	mov    $0x3,%eax
  801b79:	e8 a2 fe ff ff       	call   801a20 <fsipc>
  801b7e:	89 c3                	mov    %eax,%ebx
  801b80:	85 c0                	test   %eax,%eax
  801b82:	78 4b                	js     801bcf <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b84:	39 c6                	cmp    %eax,%esi
  801b86:	73 16                	jae    801b9e <devfile_read+0x48>
  801b88:	68 34 2c 80 00       	push   $0x802c34
  801b8d:	68 3b 2c 80 00       	push   $0x802c3b
  801b92:	6a 7c                	push   $0x7c
  801b94:	68 50 2c 80 00       	push   $0x802c50
  801b99:	e8 4a eb ff ff       	call   8006e8 <_panic>
	assert(r <= PGSIZE);
  801b9e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ba3:	7e 16                	jle    801bbb <devfile_read+0x65>
  801ba5:	68 5b 2c 80 00       	push   $0x802c5b
  801baa:	68 3b 2c 80 00       	push   $0x802c3b
  801baf:	6a 7d                	push   $0x7d
  801bb1:	68 50 2c 80 00       	push   $0x802c50
  801bb6:	e8 2d eb ff ff       	call   8006e8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bbb:	83 ec 04             	sub    $0x4,%esp
  801bbe:	50                   	push   %eax
  801bbf:	68 00 50 80 00       	push   $0x805000
  801bc4:	ff 75 0c             	pushl  0xc(%ebp)
  801bc7:	e8 0c f3 ff ff       	call   800ed8 <memmove>
	return r;
  801bcc:	83 c4 10             	add    $0x10,%esp
}
  801bcf:	89 d8                	mov    %ebx,%eax
  801bd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd4:	5b                   	pop    %ebx
  801bd5:	5e                   	pop    %esi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	53                   	push   %ebx
  801bdc:	83 ec 20             	sub    $0x20,%esp
  801bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801be2:	53                   	push   %ebx
  801be3:	e8 25 f1 ff ff       	call   800d0d <strlen>
  801be8:	83 c4 10             	add    $0x10,%esp
  801beb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bf0:	7f 67                	jg     801c59 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bf2:	83 ec 0c             	sub    $0xc,%esp
  801bf5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf8:	50                   	push   %eax
  801bf9:	e8 9a f8 ff ff       	call   801498 <fd_alloc>
  801bfe:	83 c4 10             	add    $0x10,%esp
		return r;
  801c01:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c03:	85 c0                	test   %eax,%eax
  801c05:	78 57                	js     801c5e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c07:	83 ec 08             	sub    $0x8,%esp
  801c0a:	53                   	push   %ebx
  801c0b:	68 00 50 80 00       	push   $0x805000
  801c10:	e8 31 f1 ff ff       	call   800d46 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c15:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c18:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c20:	b8 01 00 00 00       	mov    $0x1,%eax
  801c25:	e8 f6 fd ff ff       	call   801a20 <fsipc>
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	83 c4 10             	add    $0x10,%esp
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	79 14                	jns    801c47 <open+0x6f>
		fd_close(fd, 0);
  801c33:	83 ec 08             	sub    $0x8,%esp
  801c36:	6a 00                	push   $0x0
  801c38:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3b:	e8 50 f9 ff ff       	call   801590 <fd_close>
		return r;
  801c40:	83 c4 10             	add    $0x10,%esp
  801c43:	89 da                	mov    %ebx,%edx
  801c45:	eb 17                	jmp    801c5e <open+0x86>
	}

	return fd2num(fd);
  801c47:	83 ec 0c             	sub    $0xc,%esp
  801c4a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4d:	e8 1f f8 ff ff       	call   801471 <fd2num>
  801c52:	89 c2                	mov    %eax,%edx
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	eb 05                	jmp    801c5e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c59:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c5e:	89 d0                	mov    %edx,%eax
  801c60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c63:	c9                   	leave  
  801c64:	c3                   	ret    

00801c65 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c65:	55                   	push   %ebp
  801c66:	89 e5                	mov    %esp,%ebp
  801c68:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c6b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c70:	b8 08 00 00 00       	mov    $0x8,%eax
  801c75:	e8 a6 fd ff ff       	call   801a20 <fsipc>
}
  801c7a:	c9                   	leave  
  801c7b:	c3                   	ret    

00801c7c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	56                   	push   %esi
  801c80:	53                   	push   %ebx
  801c81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c84:	83 ec 0c             	sub    $0xc,%esp
  801c87:	ff 75 08             	pushl  0x8(%ebp)
  801c8a:	e8 f2 f7 ff ff       	call   801481 <fd2data>
  801c8f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c91:	83 c4 08             	add    $0x8,%esp
  801c94:	68 67 2c 80 00       	push   $0x802c67
  801c99:	53                   	push   %ebx
  801c9a:	e8 a7 f0 ff ff       	call   800d46 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c9f:	8b 46 04             	mov    0x4(%esi),%eax
  801ca2:	2b 06                	sub    (%esi),%eax
  801ca4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801caa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cb1:	00 00 00 
	stat->st_dev = &devpipe;
  801cb4:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801cbb:	30 80 00 
	return 0;
}
  801cbe:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc6:	5b                   	pop    %ebx
  801cc7:	5e                   	pop    %esi
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    

00801cca <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	53                   	push   %ebx
  801cce:	83 ec 0c             	sub    $0xc,%esp
  801cd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cd4:	53                   	push   %ebx
  801cd5:	6a 00                	push   $0x0
  801cd7:	e8 f2 f4 ff ff       	call   8011ce <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cdc:	89 1c 24             	mov    %ebx,(%esp)
  801cdf:	e8 9d f7 ff ff       	call   801481 <fd2data>
  801ce4:	83 c4 08             	add    $0x8,%esp
  801ce7:	50                   	push   %eax
  801ce8:	6a 00                	push   $0x0
  801cea:	e8 df f4 ff ff       	call   8011ce <sys_page_unmap>
}
  801cef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf2:	c9                   	leave  
  801cf3:	c3                   	ret    

00801cf4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	57                   	push   %edi
  801cf8:	56                   	push   %esi
  801cf9:	53                   	push   %ebx
  801cfa:	83 ec 1c             	sub    $0x1c,%esp
  801cfd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d00:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d02:	a1 04 40 80 00       	mov    0x804004,%eax
  801d07:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d0a:	83 ec 0c             	sub    $0xc,%esp
  801d0d:	ff 75 e0             	pushl  -0x20(%ebp)
  801d10:	e8 46 04 00 00       	call   80215b <pageref>
  801d15:	89 c3                	mov    %eax,%ebx
  801d17:	89 3c 24             	mov    %edi,(%esp)
  801d1a:	e8 3c 04 00 00       	call   80215b <pageref>
  801d1f:	83 c4 10             	add    $0x10,%esp
  801d22:	39 c3                	cmp    %eax,%ebx
  801d24:	0f 94 c1             	sete   %cl
  801d27:	0f b6 c9             	movzbl %cl,%ecx
  801d2a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d2d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d33:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801d36:	39 ce                	cmp    %ecx,%esi
  801d38:	74 1b                	je     801d55 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d3a:	39 c3                	cmp    %eax,%ebx
  801d3c:	75 c4                	jne    801d02 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d3e:	8b 42 60             	mov    0x60(%edx),%eax
  801d41:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d44:	50                   	push   %eax
  801d45:	56                   	push   %esi
  801d46:	68 6e 2c 80 00       	push   $0x802c6e
  801d4b:	e8 71 ea ff ff       	call   8007c1 <cprintf>
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	eb ad                	jmp    801d02 <_pipeisclosed+0xe>
	}
}
  801d55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d5b:	5b                   	pop    %ebx
  801d5c:	5e                   	pop    %esi
  801d5d:	5f                   	pop    %edi
  801d5e:	5d                   	pop    %ebp
  801d5f:	c3                   	ret    

00801d60 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	57                   	push   %edi
  801d64:	56                   	push   %esi
  801d65:	53                   	push   %ebx
  801d66:	83 ec 28             	sub    $0x28,%esp
  801d69:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d6c:	56                   	push   %esi
  801d6d:	e8 0f f7 ff ff       	call   801481 <fd2data>
  801d72:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d74:	83 c4 10             	add    $0x10,%esp
  801d77:	bf 00 00 00 00       	mov    $0x0,%edi
  801d7c:	eb 4b                	jmp    801dc9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d7e:	89 da                	mov    %ebx,%edx
  801d80:	89 f0                	mov    %esi,%eax
  801d82:	e8 6d ff ff ff       	call   801cf4 <_pipeisclosed>
  801d87:	85 c0                	test   %eax,%eax
  801d89:	75 48                	jne    801dd3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d8b:	e8 9a f3 ff ff       	call   80112a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d90:	8b 43 04             	mov    0x4(%ebx),%eax
  801d93:	8b 0b                	mov    (%ebx),%ecx
  801d95:	8d 51 20             	lea    0x20(%ecx),%edx
  801d98:	39 d0                	cmp    %edx,%eax
  801d9a:	73 e2                	jae    801d7e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d9f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801da3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801da6:	89 c2                	mov    %eax,%edx
  801da8:	c1 fa 1f             	sar    $0x1f,%edx
  801dab:	89 d1                	mov    %edx,%ecx
  801dad:	c1 e9 1b             	shr    $0x1b,%ecx
  801db0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801db3:	83 e2 1f             	and    $0x1f,%edx
  801db6:	29 ca                	sub    %ecx,%edx
  801db8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801dbc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801dc0:	83 c0 01             	add    $0x1,%eax
  801dc3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dc6:	83 c7 01             	add    $0x1,%edi
  801dc9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dcc:	75 c2                	jne    801d90 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801dce:	8b 45 10             	mov    0x10(%ebp),%eax
  801dd1:	eb 05                	jmp    801dd8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dd3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ddb:	5b                   	pop    %ebx
  801ddc:	5e                   	pop    %esi
  801ddd:	5f                   	pop    %edi
  801dde:	5d                   	pop    %ebp
  801ddf:	c3                   	ret    

00801de0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	57                   	push   %edi
  801de4:	56                   	push   %esi
  801de5:	53                   	push   %ebx
  801de6:	83 ec 18             	sub    $0x18,%esp
  801de9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dec:	57                   	push   %edi
  801ded:	e8 8f f6 ff ff       	call   801481 <fd2data>
  801df2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801df4:	83 c4 10             	add    $0x10,%esp
  801df7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dfc:	eb 3d                	jmp    801e3b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dfe:	85 db                	test   %ebx,%ebx
  801e00:	74 04                	je     801e06 <devpipe_read+0x26>
				return i;
  801e02:	89 d8                	mov    %ebx,%eax
  801e04:	eb 44                	jmp    801e4a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e06:	89 f2                	mov    %esi,%edx
  801e08:	89 f8                	mov    %edi,%eax
  801e0a:	e8 e5 fe ff ff       	call   801cf4 <_pipeisclosed>
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	75 32                	jne    801e45 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e13:	e8 12 f3 ff ff       	call   80112a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e18:	8b 06                	mov    (%esi),%eax
  801e1a:	3b 46 04             	cmp    0x4(%esi),%eax
  801e1d:	74 df                	je     801dfe <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e1f:	99                   	cltd   
  801e20:	c1 ea 1b             	shr    $0x1b,%edx
  801e23:	01 d0                	add    %edx,%eax
  801e25:	83 e0 1f             	and    $0x1f,%eax
  801e28:	29 d0                	sub    %edx,%eax
  801e2a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e32:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e35:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e38:	83 c3 01             	add    $0x1,%ebx
  801e3b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e3e:	75 d8                	jne    801e18 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e40:	8b 45 10             	mov    0x10(%ebp),%eax
  801e43:	eb 05                	jmp    801e4a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e45:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4d:	5b                   	pop    %ebx
  801e4e:	5e                   	pop    %esi
  801e4f:	5f                   	pop    %edi
  801e50:	5d                   	pop    %ebp
  801e51:	c3                   	ret    

00801e52 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	56                   	push   %esi
  801e56:	53                   	push   %ebx
  801e57:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5d:	50                   	push   %eax
  801e5e:	e8 35 f6 ff ff       	call   801498 <fd_alloc>
  801e63:	83 c4 10             	add    $0x10,%esp
  801e66:	89 c2                	mov    %eax,%edx
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	0f 88 2c 01 00 00    	js     801f9c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e70:	83 ec 04             	sub    $0x4,%esp
  801e73:	68 07 04 00 00       	push   $0x407
  801e78:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7b:	6a 00                	push   $0x0
  801e7d:	e8 c7 f2 ff ff       	call   801149 <sys_page_alloc>
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	89 c2                	mov    %eax,%edx
  801e87:	85 c0                	test   %eax,%eax
  801e89:	0f 88 0d 01 00 00    	js     801f9c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e8f:	83 ec 0c             	sub    $0xc,%esp
  801e92:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e95:	50                   	push   %eax
  801e96:	e8 fd f5 ff ff       	call   801498 <fd_alloc>
  801e9b:	89 c3                	mov    %eax,%ebx
  801e9d:	83 c4 10             	add    $0x10,%esp
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	0f 88 e2 00 00 00    	js     801f8a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea8:	83 ec 04             	sub    $0x4,%esp
  801eab:	68 07 04 00 00       	push   $0x407
  801eb0:	ff 75 f0             	pushl  -0x10(%ebp)
  801eb3:	6a 00                	push   $0x0
  801eb5:	e8 8f f2 ff ff       	call   801149 <sys_page_alloc>
  801eba:	89 c3                	mov    %eax,%ebx
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	0f 88 c3 00 00 00    	js     801f8a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ec7:	83 ec 0c             	sub    $0xc,%esp
  801eca:	ff 75 f4             	pushl  -0xc(%ebp)
  801ecd:	e8 af f5 ff ff       	call   801481 <fd2data>
  801ed2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ed4:	83 c4 0c             	add    $0xc,%esp
  801ed7:	68 07 04 00 00       	push   $0x407
  801edc:	50                   	push   %eax
  801edd:	6a 00                	push   $0x0
  801edf:	e8 65 f2 ff ff       	call   801149 <sys_page_alloc>
  801ee4:	89 c3                	mov    %eax,%ebx
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	0f 88 89 00 00 00    	js     801f7a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef1:	83 ec 0c             	sub    $0xc,%esp
  801ef4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ef7:	e8 85 f5 ff ff       	call   801481 <fd2data>
  801efc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f03:	50                   	push   %eax
  801f04:	6a 00                	push   $0x0
  801f06:	56                   	push   %esi
  801f07:	6a 00                	push   $0x0
  801f09:	e8 7e f2 ff ff       	call   80118c <sys_page_map>
  801f0e:	89 c3                	mov    %eax,%ebx
  801f10:	83 c4 20             	add    $0x20,%esp
  801f13:	85 c0                	test   %eax,%eax
  801f15:	78 55                	js     801f6c <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f17:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f20:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f25:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f2c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f35:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f3a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f41:	83 ec 0c             	sub    $0xc,%esp
  801f44:	ff 75 f4             	pushl  -0xc(%ebp)
  801f47:	e8 25 f5 ff ff       	call   801471 <fd2num>
  801f4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f4f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f51:	83 c4 04             	add    $0x4,%esp
  801f54:	ff 75 f0             	pushl  -0x10(%ebp)
  801f57:	e8 15 f5 ff ff       	call   801471 <fd2num>
  801f5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f5f:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f62:	83 c4 10             	add    $0x10,%esp
  801f65:	ba 00 00 00 00       	mov    $0x0,%edx
  801f6a:	eb 30                	jmp    801f9c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f6c:	83 ec 08             	sub    $0x8,%esp
  801f6f:	56                   	push   %esi
  801f70:	6a 00                	push   $0x0
  801f72:	e8 57 f2 ff ff       	call   8011ce <sys_page_unmap>
  801f77:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f7a:	83 ec 08             	sub    $0x8,%esp
  801f7d:	ff 75 f0             	pushl  -0x10(%ebp)
  801f80:	6a 00                	push   $0x0
  801f82:	e8 47 f2 ff ff       	call   8011ce <sys_page_unmap>
  801f87:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f8a:	83 ec 08             	sub    $0x8,%esp
  801f8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801f90:	6a 00                	push   $0x0
  801f92:	e8 37 f2 ff ff       	call   8011ce <sys_page_unmap>
  801f97:	83 c4 10             	add    $0x10,%esp
  801f9a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f9c:	89 d0                	mov    %edx,%eax
  801f9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa1:	5b                   	pop    %ebx
  801fa2:	5e                   	pop    %esi
  801fa3:	5d                   	pop    %ebp
  801fa4:	c3                   	ret    

00801fa5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fae:	50                   	push   %eax
  801faf:	ff 75 08             	pushl  0x8(%ebp)
  801fb2:	e8 30 f5 ff ff       	call   8014e7 <fd_lookup>
  801fb7:	83 c4 10             	add    $0x10,%esp
  801fba:	85 c0                	test   %eax,%eax
  801fbc:	78 18                	js     801fd6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fbe:	83 ec 0c             	sub    $0xc,%esp
  801fc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc4:	e8 b8 f4 ff ff       	call   801481 <fd2data>
	return _pipeisclosed(fd, p);
  801fc9:	89 c2                	mov    %eax,%edx
  801fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fce:	e8 21 fd ff ff       	call   801cf4 <_pipeisclosed>
  801fd3:	83 c4 10             	add    $0x10,%esp
}
  801fd6:	c9                   	leave  
  801fd7:	c3                   	ret    

00801fd8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe0:	5d                   	pop    %ebp
  801fe1:	c3                   	ret    

00801fe2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fe8:	68 86 2c 80 00       	push   $0x802c86
  801fed:	ff 75 0c             	pushl  0xc(%ebp)
  801ff0:	e8 51 ed ff ff       	call   800d46 <strcpy>
	return 0;
}
  801ff5:	b8 00 00 00 00       	mov    $0x0,%eax
  801ffa:	c9                   	leave  
  801ffb:	c3                   	ret    

00801ffc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ffc:	55                   	push   %ebp
  801ffd:	89 e5                	mov    %esp,%ebp
  801fff:	57                   	push   %edi
  802000:	56                   	push   %esi
  802001:	53                   	push   %ebx
  802002:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802008:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80200d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802013:	eb 2d                	jmp    802042 <devcons_write+0x46>
		m = n - tot;
  802015:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802018:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80201a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80201d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802022:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802025:	83 ec 04             	sub    $0x4,%esp
  802028:	53                   	push   %ebx
  802029:	03 45 0c             	add    0xc(%ebp),%eax
  80202c:	50                   	push   %eax
  80202d:	57                   	push   %edi
  80202e:	e8 a5 ee ff ff       	call   800ed8 <memmove>
		sys_cputs(buf, m);
  802033:	83 c4 08             	add    $0x8,%esp
  802036:	53                   	push   %ebx
  802037:	57                   	push   %edi
  802038:	e8 50 f0 ff ff       	call   80108d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80203d:	01 de                	add    %ebx,%esi
  80203f:	83 c4 10             	add    $0x10,%esp
  802042:	89 f0                	mov    %esi,%eax
  802044:	3b 75 10             	cmp    0x10(%ebp),%esi
  802047:	72 cc                	jb     802015 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802049:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80204c:	5b                   	pop    %ebx
  80204d:	5e                   	pop    %esi
  80204e:	5f                   	pop    %edi
  80204f:	5d                   	pop    %ebp
  802050:	c3                   	ret    

00802051 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802051:	55                   	push   %ebp
  802052:	89 e5                	mov    %esp,%ebp
  802054:	83 ec 08             	sub    $0x8,%esp
  802057:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80205c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802060:	74 2a                	je     80208c <devcons_read+0x3b>
  802062:	eb 05                	jmp    802069 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802064:	e8 c1 f0 ff ff       	call   80112a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802069:	e8 3d f0 ff ff       	call   8010ab <sys_cgetc>
  80206e:	85 c0                	test   %eax,%eax
  802070:	74 f2                	je     802064 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802072:	85 c0                	test   %eax,%eax
  802074:	78 16                	js     80208c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802076:	83 f8 04             	cmp    $0x4,%eax
  802079:	74 0c                	je     802087 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80207b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80207e:	88 02                	mov    %al,(%edx)
	return 1;
  802080:	b8 01 00 00 00       	mov    $0x1,%eax
  802085:	eb 05                	jmp    80208c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802087:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802094:	8b 45 08             	mov    0x8(%ebp),%eax
  802097:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80209a:	6a 01                	push   $0x1
  80209c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80209f:	50                   	push   %eax
  8020a0:	e8 e8 ef ff ff       	call   80108d <sys_cputs>
}
  8020a5:	83 c4 10             	add    $0x10,%esp
  8020a8:	c9                   	leave  
  8020a9:	c3                   	ret    

008020aa <getchar>:

int
getchar(void)
{
  8020aa:	55                   	push   %ebp
  8020ab:	89 e5                	mov    %esp,%ebp
  8020ad:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020b0:	6a 01                	push   $0x1
  8020b2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020b5:	50                   	push   %eax
  8020b6:	6a 00                	push   $0x0
  8020b8:	e8 90 f6 ff ff       	call   80174d <read>
	if (r < 0)
  8020bd:	83 c4 10             	add    $0x10,%esp
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	78 0f                	js     8020d3 <getchar+0x29>
		return r;
	if (r < 1)
  8020c4:	85 c0                	test   %eax,%eax
  8020c6:	7e 06                	jle    8020ce <getchar+0x24>
		return -E_EOF;
	return c;
  8020c8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020cc:	eb 05                	jmp    8020d3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020ce:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020d3:	c9                   	leave  
  8020d4:	c3                   	ret    

008020d5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020d5:	55                   	push   %ebp
  8020d6:	89 e5                	mov    %esp,%ebp
  8020d8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020de:	50                   	push   %eax
  8020df:	ff 75 08             	pushl  0x8(%ebp)
  8020e2:	e8 00 f4 ff ff       	call   8014e7 <fd_lookup>
  8020e7:	83 c4 10             	add    $0x10,%esp
  8020ea:	85 c0                	test   %eax,%eax
  8020ec:	78 11                	js     8020ff <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020f7:	39 10                	cmp    %edx,(%eax)
  8020f9:	0f 94 c0             	sete   %al
  8020fc:	0f b6 c0             	movzbl %al,%eax
}
  8020ff:	c9                   	leave  
  802100:	c3                   	ret    

00802101 <opencons>:

int
opencons(void)
{
  802101:	55                   	push   %ebp
  802102:	89 e5                	mov    %esp,%ebp
  802104:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802107:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80210a:	50                   	push   %eax
  80210b:	e8 88 f3 ff ff       	call   801498 <fd_alloc>
  802110:	83 c4 10             	add    $0x10,%esp
		return r;
  802113:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802115:	85 c0                	test   %eax,%eax
  802117:	78 3e                	js     802157 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802119:	83 ec 04             	sub    $0x4,%esp
  80211c:	68 07 04 00 00       	push   $0x407
  802121:	ff 75 f4             	pushl  -0xc(%ebp)
  802124:	6a 00                	push   $0x0
  802126:	e8 1e f0 ff ff       	call   801149 <sys_page_alloc>
  80212b:	83 c4 10             	add    $0x10,%esp
		return r;
  80212e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802130:	85 c0                	test   %eax,%eax
  802132:	78 23                	js     802157 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802134:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80213a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80213f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802142:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802149:	83 ec 0c             	sub    $0xc,%esp
  80214c:	50                   	push   %eax
  80214d:	e8 1f f3 ff ff       	call   801471 <fd2num>
  802152:	89 c2                	mov    %eax,%edx
  802154:	83 c4 10             	add    $0x10,%esp
}
  802157:	89 d0                	mov    %edx,%eax
  802159:	c9                   	leave  
  80215a:	c3                   	ret    

0080215b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80215b:	55                   	push   %ebp
  80215c:	89 e5                	mov    %esp,%ebp
  80215e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802161:	89 d0                	mov    %edx,%eax
  802163:	c1 e8 16             	shr    $0x16,%eax
  802166:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80216d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802172:	f6 c1 01             	test   $0x1,%cl
  802175:	74 1d                	je     802194 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802177:	c1 ea 0c             	shr    $0xc,%edx
  80217a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802181:	f6 c2 01             	test   $0x1,%dl
  802184:	74 0e                	je     802194 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802186:	c1 ea 0c             	shr    $0xc,%edx
  802189:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802190:	ef 
  802191:	0f b7 c0             	movzwl %ax,%eax
}
  802194:	5d                   	pop    %ebp
  802195:	c3                   	ret    
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__udivdi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 f6                	test   %esi,%esi
  8021b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021bd:	89 ca                	mov    %ecx,%edx
  8021bf:	89 f8                	mov    %edi,%eax
  8021c1:	75 3d                	jne    802200 <__udivdi3+0x60>
  8021c3:	39 cf                	cmp    %ecx,%edi
  8021c5:	0f 87 c5 00 00 00    	ja     802290 <__udivdi3+0xf0>
  8021cb:	85 ff                	test   %edi,%edi
  8021cd:	89 fd                	mov    %edi,%ebp
  8021cf:	75 0b                	jne    8021dc <__udivdi3+0x3c>
  8021d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d6:	31 d2                	xor    %edx,%edx
  8021d8:	f7 f7                	div    %edi
  8021da:	89 c5                	mov    %eax,%ebp
  8021dc:	89 c8                	mov    %ecx,%eax
  8021de:	31 d2                	xor    %edx,%edx
  8021e0:	f7 f5                	div    %ebp
  8021e2:	89 c1                	mov    %eax,%ecx
  8021e4:	89 d8                	mov    %ebx,%eax
  8021e6:	89 cf                	mov    %ecx,%edi
  8021e8:	f7 f5                	div    %ebp
  8021ea:	89 c3                	mov    %eax,%ebx
  8021ec:	89 d8                	mov    %ebx,%eax
  8021ee:	89 fa                	mov    %edi,%edx
  8021f0:	83 c4 1c             	add    $0x1c,%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    
  8021f8:	90                   	nop
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	39 ce                	cmp    %ecx,%esi
  802202:	77 74                	ja     802278 <__udivdi3+0xd8>
  802204:	0f bd fe             	bsr    %esi,%edi
  802207:	83 f7 1f             	xor    $0x1f,%edi
  80220a:	0f 84 98 00 00 00    	je     8022a8 <__udivdi3+0x108>
  802210:	bb 20 00 00 00       	mov    $0x20,%ebx
  802215:	89 f9                	mov    %edi,%ecx
  802217:	89 c5                	mov    %eax,%ebp
  802219:	29 fb                	sub    %edi,%ebx
  80221b:	d3 e6                	shl    %cl,%esi
  80221d:	89 d9                	mov    %ebx,%ecx
  80221f:	d3 ed                	shr    %cl,%ebp
  802221:	89 f9                	mov    %edi,%ecx
  802223:	d3 e0                	shl    %cl,%eax
  802225:	09 ee                	or     %ebp,%esi
  802227:	89 d9                	mov    %ebx,%ecx
  802229:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80222d:	89 d5                	mov    %edx,%ebp
  80222f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802233:	d3 ed                	shr    %cl,%ebp
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e2                	shl    %cl,%edx
  802239:	89 d9                	mov    %ebx,%ecx
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	09 c2                	or     %eax,%edx
  80223f:	89 d0                	mov    %edx,%eax
  802241:	89 ea                	mov    %ebp,%edx
  802243:	f7 f6                	div    %esi
  802245:	89 d5                	mov    %edx,%ebp
  802247:	89 c3                	mov    %eax,%ebx
  802249:	f7 64 24 0c          	mull   0xc(%esp)
  80224d:	39 d5                	cmp    %edx,%ebp
  80224f:	72 10                	jb     802261 <__udivdi3+0xc1>
  802251:	8b 74 24 08          	mov    0x8(%esp),%esi
  802255:	89 f9                	mov    %edi,%ecx
  802257:	d3 e6                	shl    %cl,%esi
  802259:	39 c6                	cmp    %eax,%esi
  80225b:	73 07                	jae    802264 <__udivdi3+0xc4>
  80225d:	39 d5                	cmp    %edx,%ebp
  80225f:	75 03                	jne    802264 <__udivdi3+0xc4>
  802261:	83 eb 01             	sub    $0x1,%ebx
  802264:	31 ff                	xor    %edi,%edi
  802266:	89 d8                	mov    %ebx,%eax
  802268:	89 fa                	mov    %edi,%edx
  80226a:	83 c4 1c             	add    $0x1c,%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5e                   	pop    %esi
  80226f:	5f                   	pop    %edi
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    
  802272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802278:	31 ff                	xor    %edi,%edi
  80227a:	31 db                	xor    %ebx,%ebx
  80227c:	89 d8                	mov    %ebx,%eax
  80227e:	89 fa                	mov    %edi,%edx
  802280:	83 c4 1c             	add    $0x1c,%esp
  802283:	5b                   	pop    %ebx
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    
  802288:	90                   	nop
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	89 d8                	mov    %ebx,%eax
  802292:	f7 f7                	div    %edi
  802294:	31 ff                	xor    %edi,%edi
  802296:	89 c3                	mov    %eax,%ebx
  802298:	89 d8                	mov    %ebx,%eax
  80229a:	89 fa                	mov    %edi,%edx
  80229c:	83 c4 1c             	add    $0x1c,%esp
  80229f:	5b                   	pop    %ebx
  8022a0:	5e                   	pop    %esi
  8022a1:	5f                   	pop    %edi
  8022a2:	5d                   	pop    %ebp
  8022a3:	c3                   	ret    
  8022a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a8:	39 ce                	cmp    %ecx,%esi
  8022aa:	72 0c                	jb     8022b8 <__udivdi3+0x118>
  8022ac:	31 db                	xor    %ebx,%ebx
  8022ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022b2:	0f 87 34 ff ff ff    	ja     8021ec <__udivdi3+0x4c>
  8022b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022bd:	e9 2a ff ff ff       	jmp    8021ec <__udivdi3+0x4c>
  8022c2:	66 90                	xchg   %ax,%ax
  8022c4:	66 90                	xchg   %ax,%ax
  8022c6:	66 90                	xchg   %ax,%ax
  8022c8:	66 90                	xchg   %ax,%ax
  8022ca:	66 90                	xchg   %ax,%ax
  8022cc:	66 90                	xchg   %ax,%ax
  8022ce:	66 90                	xchg   %ax,%ax

008022d0 <__umoddi3>:
  8022d0:	55                   	push   %ebp
  8022d1:	57                   	push   %edi
  8022d2:	56                   	push   %esi
  8022d3:	53                   	push   %ebx
  8022d4:	83 ec 1c             	sub    $0x1c,%esp
  8022d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022e7:	85 d2                	test   %edx,%edx
  8022e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022f1:	89 f3                	mov    %esi,%ebx
  8022f3:	89 3c 24             	mov    %edi,(%esp)
  8022f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022fa:	75 1c                	jne    802318 <__umoddi3+0x48>
  8022fc:	39 f7                	cmp    %esi,%edi
  8022fe:	76 50                	jbe    802350 <__umoddi3+0x80>
  802300:	89 c8                	mov    %ecx,%eax
  802302:	89 f2                	mov    %esi,%edx
  802304:	f7 f7                	div    %edi
  802306:	89 d0                	mov    %edx,%eax
  802308:	31 d2                	xor    %edx,%edx
  80230a:	83 c4 1c             	add    $0x1c,%esp
  80230d:	5b                   	pop    %ebx
  80230e:	5e                   	pop    %esi
  80230f:	5f                   	pop    %edi
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    
  802312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802318:	39 f2                	cmp    %esi,%edx
  80231a:	89 d0                	mov    %edx,%eax
  80231c:	77 52                	ja     802370 <__umoddi3+0xa0>
  80231e:	0f bd ea             	bsr    %edx,%ebp
  802321:	83 f5 1f             	xor    $0x1f,%ebp
  802324:	75 5a                	jne    802380 <__umoddi3+0xb0>
  802326:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80232a:	0f 82 e0 00 00 00    	jb     802410 <__umoddi3+0x140>
  802330:	39 0c 24             	cmp    %ecx,(%esp)
  802333:	0f 86 d7 00 00 00    	jbe    802410 <__umoddi3+0x140>
  802339:	8b 44 24 08          	mov    0x8(%esp),%eax
  80233d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802341:	83 c4 1c             	add    $0x1c,%esp
  802344:	5b                   	pop    %ebx
  802345:	5e                   	pop    %esi
  802346:	5f                   	pop    %edi
  802347:	5d                   	pop    %ebp
  802348:	c3                   	ret    
  802349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802350:	85 ff                	test   %edi,%edi
  802352:	89 fd                	mov    %edi,%ebp
  802354:	75 0b                	jne    802361 <__umoddi3+0x91>
  802356:	b8 01 00 00 00       	mov    $0x1,%eax
  80235b:	31 d2                	xor    %edx,%edx
  80235d:	f7 f7                	div    %edi
  80235f:	89 c5                	mov    %eax,%ebp
  802361:	89 f0                	mov    %esi,%eax
  802363:	31 d2                	xor    %edx,%edx
  802365:	f7 f5                	div    %ebp
  802367:	89 c8                	mov    %ecx,%eax
  802369:	f7 f5                	div    %ebp
  80236b:	89 d0                	mov    %edx,%eax
  80236d:	eb 99                	jmp    802308 <__umoddi3+0x38>
  80236f:	90                   	nop
  802370:	89 c8                	mov    %ecx,%eax
  802372:	89 f2                	mov    %esi,%edx
  802374:	83 c4 1c             	add    $0x1c,%esp
  802377:	5b                   	pop    %ebx
  802378:	5e                   	pop    %esi
  802379:	5f                   	pop    %edi
  80237a:	5d                   	pop    %ebp
  80237b:	c3                   	ret    
  80237c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802380:	8b 34 24             	mov    (%esp),%esi
  802383:	bf 20 00 00 00       	mov    $0x20,%edi
  802388:	89 e9                	mov    %ebp,%ecx
  80238a:	29 ef                	sub    %ebp,%edi
  80238c:	d3 e0                	shl    %cl,%eax
  80238e:	89 f9                	mov    %edi,%ecx
  802390:	89 f2                	mov    %esi,%edx
  802392:	d3 ea                	shr    %cl,%edx
  802394:	89 e9                	mov    %ebp,%ecx
  802396:	09 c2                	or     %eax,%edx
  802398:	89 d8                	mov    %ebx,%eax
  80239a:	89 14 24             	mov    %edx,(%esp)
  80239d:	89 f2                	mov    %esi,%edx
  80239f:	d3 e2                	shl    %cl,%edx
  8023a1:	89 f9                	mov    %edi,%ecx
  8023a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023ab:	d3 e8                	shr    %cl,%eax
  8023ad:	89 e9                	mov    %ebp,%ecx
  8023af:	89 c6                	mov    %eax,%esi
  8023b1:	d3 e3                	shl    %cl,%ebx
  8023b3:	89 f9                	mov    %edi,%ecx
  8023b5:	89 d0                	mov    %edx,%eax
  8023b7:	d3 e8                	shr    %cl,%eax
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	09 d8                	or     %ebx,%eax
  8023bd:	89 d3                	mov    %edx,%ebx
  8023bf:	89 f2                	mov    %esi,%edx
  8023c1:	f7 34 24             	divl   (%esp)
  8023c4:	89 d6                	mov    %edx,%esi
  8023c6:	d3 e3                	shl    %cl,%ebx
  8023c8:	f7 64 24 04          	mull   0x4(%esp)
  8023cc:	39 d6                	cmp    %edx,%esi
  8023ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023d2:	89 d1                	mov    %edx,%ecx
  8023d4:	89 c3                	mov    %eax,%ebx
  8023d6:	72 08                	jb     8023e0 <__umoddi3+0x110>
  8023d8:	75 11                	jne    8023eb <__umoddi3+0x11b>
  8023da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023de:	73 0b                	jae    8023eb <__umoddi3+0x11b>
  8023e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023e4:	1b 14 24             	sbb    (%esp),%edx
  8023e7:	89 d1                	mov    %edx,%ecx
  8023e9:	89 c3                	mov    %eax,%ebx
  8023eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023ef:	29 da                	sub    %ebx,%edx
  8023f1:	19 ce                	sbb    %ecx,%esi
  8023f3:	89 f9                	mov    %edi,%ecx
  8023f5:	89 f0                	mov    %esi,%eax
  8023f7:	d3 e0                	shl    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	d3 ea                	shr    %cl,%edx
  8023fd:	89 e9                	mov    %ebp,%ecx
  8023ff:	d3 ee                	shr    %cl,%esi
  802401:	09 d0                	or     %edx,%eax
  802403:	89 f2                	mov    %esi,%edx
  802405:	83 c4 1c             	add    $0x1c,%esp
  802408:	5b                   	pop    %ebx
  802409:	5e                   	pop    %esi
  80240a:	5f                   	pop    %edi
  80240b:	5d                   	pop    %ebp
  80240c:	c3                   	ret    
  80240d:	8d 76 00             	lea    0x0(%esi),%esi
  802410:	29 f9                	sub    %edi,%ecx
  802412:	19 d6                	sbb    %edx,%esi
  802414:	89 74 24 04          	mov    %esi,0x4(%esp)
  802418:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80241c:	e9 18 ff ff ff       	jmp    802339 <__umoddi3+0x69>
