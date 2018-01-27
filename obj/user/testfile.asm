
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
  800054:	e8 fb 16 00 00       	call   801754 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 60 80 00       	push   $0x806000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 8a 16 00 00       	call   8016f2 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 fe 15 00 00       	call   801677 <ipc_recv>
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
  80008f:	b8 00 28 80 00       	mov    $0x802800,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 0b 28 80 00       	push   $0x80280b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 25 28 80 00       	push   $0x802825
  8000b4:	e8 f2 05 00 00       	call   8006ab <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 c0 29 80 00       	push   $0x8029c0
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 25 28 80 00       	push   $0x802825
  8000cc:	e8 da 05 00 00       	call   8006ab <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 35 28 80 00       	mov    $0x802835,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 3e 28 80 00       	push   $0x80283e
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 25 28 80 00       	push   $0x802825
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
  800114:	68 e4 29 80 00       	push   $0x8029e4
  800119:	6a 27                	push   $0x27
  80011b:	68 25 28 80 00       	push   $0x802825
  800120:	e8 86 05 00 00       	call   8006ab <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 56 28 80 00       	push   $0x802856
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
  80014f:	68 6a 28 80 00       	push   $0x80286a
  800154:	6a 2b                	push   $0x2b
  800156:	68 25 28 80 00       	push   $0x802825
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
  80018a:	68 14 2a 80 00       	push   $0x802a14
  80018f:	6a 2d                	push   $0x2d
  800191:	68 25 28 80 00       	push   $0x802825
  800196:	e8 10 05 00 00       	call   8006ab <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 78 28 80 00       	push   $0x802878
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
  8001da:	68 8b 28 80 00       	push   $0x80288b
  8001df:	6a 32                	push   $0x32
  8001e1:	68 25 28 80 00       	push   $0x802825
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
  80020a:	68 99 28 80 00       	push   $0x802899
  80020f:	6a 34                	push   $0x34
  800211:	68 25 28 80 00       	push   $0x802825
  800216:	e8 90 04 00 00       	call   8006ab <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 b7 28 80 00       	push   $0x8028b7
  800223:	e8 5c 05 00 00       	call   800784 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 40 80 00    	call   *0x804018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 ca 28 80 00       	push   $0x8028ca
  800242:	6a 38                	push   $0x38
  800244:	68 25 28 80 00       	push   $0x802825
  800249:	e8 5d 04 00 00       	call   8006ab <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 d9 28 80 00       	push   $0x8028d9
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
  8002ac:	68 3c 2a 80 00       	push   $0x802a3c
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 25 28 80 00       	push   $0x802825
  8002b8:	e8 ee 03 00 00       	call   8006ab <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 ed 28 80 00       	push   $0x8028ed
  8002c5:	e8 ba 04 00 00       	call   800784 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 03 29 80 00       	mov    $0x802903,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 0d 29 80 00       	push   $0x80290d
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 25 28 80 00       	push   $0x802825
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
  80032f:	68 26 29 80 00       	push   $0x802926
  800334:	6a 4b                	push   $0x4b
  800336:	68 25 28 80 00       	push   $0x802825
  80033b:	e8 6b 03 00 00       	call   8006ab <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 35 29 80 00       	push   $0x802935
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
  80038b:	68 74 2a 80 00       	push   $0x802a74
  800390:	6a 51                	push   $0x51
  800392:	68 25 28 80 00       	push   $0x802825
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
  8003b2:	68 94 2a 80 00       	push   $0x802a94
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 25 28 80 00       	push   $0x802825
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
  8003e2:	68 cc 2a 80 00       	push   $0x802acc
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 25 28 80 00       	push   $0x802825
  8003ee:	e8 b8 02 00 00       	call   8006ab <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 fc 2a 80 00       	push   $0x802afc
  8003fb:	e8 84 03 00 00       	call   800784 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 00 28 80 00       	push   $0x802800
  80040a:	e8 fd 1a 00 00       	call   801f0c <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 11 28 80 00       	push   $0x802811
  800426:	6a 5a                	push   $0x5a
  800428:	68 25 28 80 00       	push   $0x802825
  80042d:	e8 79 02 00 00       	call   8006ab <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 49 29 80 00       	push   $0x802949
  80043e:	6a 5c                	push   $0x5c
  800440:	68 25 28 80 00       	push   $0x802825
  800445:	e8 61 02 00 00       	call   8006ab <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 35 28 80 00       	push   $0x802835
  800454:	e8 b3 1a 00 00       	call   801f0c <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 44 28 80 00       	push   $0x802844
  800466:	6a 5f                	push   $0x5f
  800468:	68 25 28 80 00       	push   $0x802825
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
  800493:	68 20 2b 80 00       	push   $0x802b20
  800498:	6a 62                	push   $0x62
  80049a:	68 25 28 80 00       	push   $0x802825
  80049f:	e8 07 02 00 00       	call   8006ab <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 5c 28 80 00       	push   $0x80285c
  8004ac:	e8 d3 02 00 00       	call   800784 <cprintf>
//////////////////////////BUG NO 2///////////////////////////////
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 64 29 80 00       	push   $0x802964
  8004be:	e8 49 1a 00 00       	call   801f0c <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 69 29 80 00       	push   $0x802969
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 25 28 80 00       	push   $0x802825
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
  800512:	e8 3e 16 00 00       	call   801b55 <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 78 29 80 00       	push   $0x802978
  800528:	6a 6c                	push   $0x6c
  80052a:	68 25 28 80 00       	push   $0x802825
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
  800547:	e8 f0 13 00 00       	call   80193c <close>
	
	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 64 29 80 00       	push   $0x802964
  800556:	e8 b1 19 00 00       	call   801f0c <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 8a 29 80 00       	push   $0x80298a
  80056a:	6a 71                	push   $0x71
  80056c:	68 25 28 80 00       	push   $0x802825
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
  800591:	e8 76 15 00 00       	call   801b0c <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 98 29 80 00       	push   $0x802998
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 25 28 80 00       	push   $0x802825
  8005ae:	e8 f8 00 00 00       	call   8006ab <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 48 2b 80 00       	push   $0x802b48
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 25 28 80 00       	push   $0x802825
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
  8005e4:	68 74 2b 80 00       	push   $0x802b74
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 25 28 80 00       	push   $0x802825
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
  80060c:	e8 2b 13 00 00       	call   80193c <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 a9 29 80 00 	movl   $0x8029a9,(%esp)
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
  800697:	e8 cb 12 00 00       	call   801967 <close_all>
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
  8006c9:	68 cc 2b 80 00       	push   $0x802bcc
  8006ce:	e8 b1 00 00 00       	call   800784 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006d3:	83 c4 18             	add    $0x18,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	ff 75 10             	pushl  0x10(%ebp)
  8006da:	e8 54 00 00 00       	call   800733 <vcprintf>
	cprintf("\n");
  8006df:	c7 04 24 9b 30 80 00 	movl   $0x80309b,(%esp)
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
  8007e7:	e8 84 1d 00 00       	call   802570 <__udivdi3>
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
  80082a:	e8 71 1e 00 00       	call   8026a0 <__umoddi3>
  80082f:	83 c4 14             	add    $0x14,%esp
  800832:	0f be 80 ef 2b 80 00 	movsbl 0x802bef(%eax),%eax
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
  80092e:	ff 24 85 40 2d 80 00 	jmp    *0x802d40(,%eax,4)
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
  8009f2:	8b 14 85 a0 2e 80 00 	mov    0x802ea0(,%eax,4),%edx
  8009f9:	85 d2                	test   %edx,%edx
  8009fb:	75 18                	jne    800a15 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8009fd:	50                   	push   %eax
  8009fe:	68 07 2c 80 00       	push   $0x802c07
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
  800a16:	68 69 30 80 00       	push   $0x803069
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
  800a3a:	b8 00 2c 80 00       	mov    $0x802c00,%eax
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
  8010b5:	68 ff 2e 80 00       	push   $0x802eff
  8010ba:	6a 23                	push   $0x23
  8010bc:	68 1c 2f 80 00       	push   $0x802f1c
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
  801136:	68 ff 2e 80 00       	push   $0x802eff
  80113b:	6a 23                	push   $0x23
  80113d:	68 1c 2f 80 00       	push   $0x802f1c
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
  801178:	68 ff 2e 80 00       	push   $0x802eff
  80117d:	6a 23                	push   $0x23
  80117f:	68 1c 2f 80 00       	push   $0x802f1c
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
  8011ba:	68 ff 2e 80 00       	push   $0x802eff
  8011bf:	6a 23                	push   $0x23
  8011c1:	68 1c 2f 80 00       	push   $0x802f1c
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
  8011fc:	68 ff 2e 80 00       	push   $0x802eff
  801201:	6a 23                	push   $0x23
  801203:	68 1c 2f 80 00       	push   $0x802f1c
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
  80123e:	68 ff 2e 80 00       	push   $0x802eff
  801243:	6a 23                	push   $0x23
  801245:	68 1c 2f 80 00       	push   $0x802f1c
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
  801280:	68 ff 2e 80 00       	push   $0x802eff
  801285:	6a 23                	push   $0x23
  801287:	68 1c 2f 80 00       	push   $0x802f1c
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
  8012e4:	68 ff 2e 80 00       	push   $0x802eff
  8012e9:	6a 23                	push   $0x23
  8012eb:	68 1c 2f 80 00       	push   $0x802f1c
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
  801383:	68 2a 2f 80 00       	push   $0x802f2a
  801388:	6a 1e                	push   $0x1e
  80138a:	68 3a 2f 80 00       	push   $0x802f3a
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
  8013ad:	68 45 2f 80 00       	push   $0x802f45
  8013b2:	6a 2c                	push   $0x2c
  8013b4:	68 3a 2f 80 00       	push   $0x802f3a
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
  8013f5:	68 45 2f 80 00       	push   $0x802f45
  8013fa:	6a 33                	push   $0x33
  8013fc:	68 3a 2f 80 00       	push   $0x802f3a
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
  80141d:	68 45 2f 80 00       	push   $0x802f45
  801422:	6a 37                	push   $0x37
  801424:	68 3a 2f 80 00       	push   $0x802f3a
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
  801441:	e8 52 10 00 00       	call   802498 <set_pgfault_handler>
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
  80145a:	68 5e 2f 80 00       	push   $0x802f5e
  80145f:	68 84 00 00 00       	push   $0x84
  801464:	68 3a 2f 80 00       	push   $0x802f3a
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
  801516:	68 6c 2f 80 00       	push   $0x802f6c
  80151b:	6a 54                	push   $0x54
  80151d:	68 3a 2f 80 00       	push   $0x802f3a
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
  80155b:	68 6c 2f 80 00       	push   $0x802f6c
  801560:	6a 5b                	push   $0x5b
  801562:	68 3a 2f 80 00       	push   $0x802f3a
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
  801589:	68 6c 2f 80 00       	push   $0x802f6c
  80158e:	6a 5f                	push   $0x5f
  801590:	68 3a 2f 80 00       	push   $0x802f3a
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
  8015b3:	68 6c 2f 80 00       	push   $0x802f6c
  8015b8:	6a 64                	push   $0x64
  8015ba:	68 3a 2f 80 00       	push   $0x802f3a
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
  801622:	68 84 2f 80 00       	push   $0x802f84
  801627:	e8 58 f1 ff ff       	call   800784 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80162c:	c7 04 24 71 06 80 00 	movl   $0x800671,(%esp)
  801633:	e8 c5 fc ff ff       	call   8012fd <sys_thread_create>
  801638:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80163a:	83 c4 08             	add    $0x8,%esp
  80163d:	53                   	push   %ebx
  80163e:	68 84 2f 80 00       	push   $0x802f84
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

00801677 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	56                   	push   %esi
  80167b:	53                   	push   %ebx
  80167c:	8b 75 08             	mov    0x8(%ebp),%esi
  80167f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801682:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801685:	85 c0                	test   %eax,%eax
  801687:	75 12                	jne    80169b <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801689:	83 ec 0c             	sub    $0xc,%esp
  80168c:	68 00 00 c0 ee       	push   $0xeec00000
  801691:	e8 26 fc ff ff       	call   8012bc <sys_ipc_recv>
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	eb 0c                	jmp    8016a7 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80169b:	83 ec 0c             	sub    $0xc,%esp
  80169e:	50                   	push   %eax
  80169f:	e8 18 fc ff ff       	call   8012bc <sys_ipc_recv>
  8016a4:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8016a7:	85 f6                	test   %esi,%esi
  8016a9:	0f 95 c1             	setne  %cl
  8016ac:	85 db                	test   %ebx,%ebx
  8016ae:	0f 95 c2             	setne  %dl
  8016b1:	84 d1                	test   %dl,%cl
  8016b3:	74 09                	je     8016be <ipc_recv+0x47>
  8016b5:	89 c2                	mov    %eax,%edx
  8016b7:	c1 ea 1f             	shr    $0x1f,%edx
  8016ba:	84 d2                	test   %dl,%dl
  8016bc:	75 2d                	jne    8016eb <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8016be:	85 f6                	test   %esi,%esi
  8016c0:	74 0d                	je     8016cf <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8016c2:	a1 04 50 80 00       	mov    0x805004,%eax
  8016c7:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8016cd:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8016cf:	85 db                	test   %ebx,%ebx
  8016d1:	74 0d                	je     8016e0 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8016d3:	a1 04 50 80 00       	mov    0x805004,%eax
  8016d8:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8016de:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8016e0:	a1 04 50 80 00       	mov    0x805004,%eax
  8016e5:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8016eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ee:	5b                   	pop    %ebx
  8016ef:	5e                   	pop    %esi
  8016f0:	5d                   	pop    %ebp
  8016f1:	c3                   	ret    

008016f2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	57                   	push   %edi
  8016f6:	56                   	push   %esi
  8016f7:	53                   	push   %ebx
  8016f8:	83 ec 0c             	sub    $0xc,%esp
  8016fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  801701:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801704:	85 db                	test   %ebx,%ebx
  801706:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80170b:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80170e:	ff 75 14             	pushl  0x14(%ebp)
  801711:	53                   	push   %ebx
  801712:	56                   	push   %esi
  801713:	57                   	push   %edi
  801714:	e8 80 fb ff ff       	call   801299 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801719:	89 c2                	mov    %eax,%edx
  80171b:	c1 ea 1f             	shr    $0x1f,%edx
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	84 d2                	test   %dl,%dl
  801723:	74 17                	je     80173c <ipc_send+0x4a>
  801725:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801728:	74 12                	je     80173c <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80172a:	50                   	push   %eax
  80172b:	68 a7 2f 80 00       	push   $0x802fa7
  801730:	6a 47                	push   $0x47
  801732:	68 b5 2f 80 00       	push   $0x802fb5
  801737:	e8 6f ef ff ff       	call   8006ab <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80173c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80173f:	75 07                	jne    801748 <ipc_send+0x56>
			sys_yield();
  801741:	e8 a7 f9 ff ff       	call   8010ed <sys_yield>
  801746:	eb c6                	jmp    80170e <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801748:	85 c0                	test   %eax,%eax
  80174a:	75 c2                	jne    80170e <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80174c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80174f:	5b                   	pop    %ebx
  801750:	5e                   	pop    %esi
  801751:	5f                   	pop    %edi
  801752:	5d                   	pop    %ebp
  801753:	c3                   	ret    

00801754 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80175a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80175f:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801765:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80176b:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801771:	39 ca                	cmp    %ecx,%edx
  801773:	75 13                	jne    801788 <ipc_find_env+0x34>
			return envs[i].env_id;
  801775:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80177b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801780:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801786:	eb 0f                	jmp    801797 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801788:	83 c0 01             	add    $0x1,%eax
  80178b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801790:	75 cd                	jne    80175f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801792:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801797:	5d                   	pop    %ebp
  801798:	c3                   	ret    

00801799 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80179c:	8b 45 08             	mov    0x8(%ebp),%eax
  80179f:	05 00 00 00 30       	add    $0x30000000,%eax
  8017a4:	c1 e8 0c             	shr    $0xc,%eax
}
  8017a7:	5d                   	pop    %ebp
  8017a8:	c3                   	ret    

008017a9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	05 00 00 00 30       	add    $0x30000000,%eax
  8017b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8017b9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    

008017c0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8017cb:	89 c2                	mov    %eax,%edx
  8017cd:	c1 ea 16             	shr    $0x16,%edx
  8017d0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8017d7:	f6 c2 01             	test   $0x1,%dl
  8017da:	74 11                	je     8017ed <fd_alloc+0x2d>
  8017dc:	89 c2                	mov    %eax,%edx
  8017de:	c1 ea 0c             	shr    $0xc,%edx
  8017e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017e8:	f6 c2 01             	test   $0x1,%dl
  8017eb:	75 09                	jne    8017f6 <fd_alloc+0x36>
			*fd_store = fd;
  8017ed:	89 01                	mov    %eax,(%ecx)
			return 0;
  8017ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f4:	eb 17                	jmp    80180d <fd_alloc+0x4d>
  8017f6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8017fb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801800:	75 c9                	jne    8017cb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801802:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801808:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80180d:	5d                   	pop    %ebp
  80180e:	c3                   	ret    

0080180f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801815:	83 f8 1f             	cmp    $0x1f,%eax
  801818:	77 36                	ja     801850 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80181a:	c1 e0 0c             	shl    $0xc,%eax
  80181d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801822:	89 c2                	mov    %eax,%edx
  801824:	c1 ea 16             	shr    $0x16,%edx
  801827:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80182e:	f6 c2 01             	test   $0x1,%dl
  801831:	74 24                	je     801857 <fd_lookup+0x48>
  801833:	89 c2                	mov    %eax,%edx
  801835:	c1 ea 0c             	shr    $0xc,%edx
  801838:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80183f:	f6 c2 01             	test   $0x1,%dl
  801842:	74 1a                	je     80185e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801844:	8b 55 0c             	mov    0xc(%ebp),%edx
  801847:	89 02                	mov    %eax,(%edx)
	return 0;
  801849:	b8 00 00 00 00       	mov    $0x0,%eax
  80184e:	eb 13                	jmp    801863 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801850:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801855:	eb 0c                	jmp    801863 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801857:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80185c:	eb 05                	jmp    801863 <fd_lookup+0x54>
  80185e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801863:	5d                   	pop    %ebp
  801864:	c3                   	ret    

00801865 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	83 ec 08             	sub    $0x8,%esp
  80186b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80186e:	ba 40 30 80 00       	mov    $0x803040,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801873:	eb 13                	jmp    801888 <dev_lookup+0x23>
  801875:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801878:	39 08                	cmp    %ecx,(%eax)
  80187a:	75 0c                	jne    801888 <dev_lookup+0x23>
			*dev = devtab[i];
  80187c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80187f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801881:	b8 00 00 00 00       	mov    $0x0,%eax
  801886:	eb 31                	jmp    8018b9 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801888:	8b 02                	mov    (%edx),%eax
  80188a:	85 c0                	test   %eax,%eax
  80188c:	75 e7                	jne    801875 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80188e:	a1 04 50 80 00       	mov    0x805004,%eax
  801893:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801899:	83 ec 04             	sub    $0x4,%esp
  80189c:	51                   	push   %ecx
  80189d:	50                   	push   %eax
  80189e:	68 c0 2f 80 00       	push   $0x802fc0
  8018a3:	e8 dc ee ff ff       	call   800784 <cprintf>
	*dev = 0;
  8018a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	56                   	push   %esi
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 10             	sub    $0x10,%esp
  8018c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8018c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8018c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cc:	50                   	push   %eax
  8018cd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8018d3:	c1 e8 0c             	shr    $0xc,%eax
  8018d6:	50                   	push   %eax
  8018d7:	e8 33 ff ff ff       	call   80180f <fd_lookup>
  8018dc:	83 c4 08             	add    $0x8,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 05                	js     8018e8 <fd_close+0x2d>
	    || fd != fd2)
  8018e3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8018e6:	74 0c                	je     8018f4 <fd_close+0x39>
		return (must_exist ? r : 0);
  8018e8:	84 db                	test   %bl,%bl
  8018ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ef:	0f 44 c2             	cmove  %edx,%eax
  8018f2:	eb 41                	jmp    801935 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8018f4:	83 ec 08             	sub    $0x8,%esp
  8018f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018fa:	50                   	push   %eax
  8018fb:	ff 36                	pushl  (%esi)
  8018fd:	e8 63 ff ff ff       	call   801865 <dev_lookup>
  801902:	89 c3                	mov    %eax,%ebx
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	85 c0                	test   %eax,%eax
  801909:	78 1a                	js     801925 <fd_close+0x6a>
		if (dev->dev_close)
  80190b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801911:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801916:	85 c0                	test   %eax,%eax
  801918:	74 0b                	je     801925 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80191a:	83 ec 0c             	sub    $0xc,%esp
  80191d:	56                   	push   %esi
  80191e:	ff d0                	call   *%eax
  801920:	89 c3                	mov    %eax,%ebx
  801922:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801925:	83 ec 08             	sub    $0x8,%esp
  801928:	56                   	push   %esi
  801929:	6a 00                	push   $0x0
  80192b:	e8 61 f8 ff ff       	call   801191 <sys_page_unmap>
	return r;
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	89 d8                	mov    %ebx,%eax
}
  801935:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801938:	5b                   	pop    %ebx
  801939:	5e                   	pop    %esi
  80193a:	5d                   	pop    %ebp
  80193b:	c3                   	ret    

0080193c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801942:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801945:	50                   	push   %eax
  801946:	ff 75 08             	pushl  0x8(%ebp)
  801949:	e8 c1 fe ff ff       	call   80180f <fd_lookup>
  80194e:	83 c4 08             	add    $0x8,%esp
  801951:	85 c0                	test   %eax,%eax
  801953:	78 10                	js     801965 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801955:	83 ec 08             	sub    $0x8,%esp
  801958:	6a 01                	push   $0x1
  80195a:	ff 75 f4             	pushl  -0xc(%ebp)
  80195d:	e8 59 ff ff ff       	call   8018bb <fd_close>
  801962:	83 c4 10             	add    $0x10,%esp
}
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <close_all>:

void
close_all(void)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	53                   	push   %ebx
  80196b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80196e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801973:	83 ec 0c             	sub    $0xc,%esp
  801976:	53                   	push   %ebx
  801977:	e8 c0 ff ff ff       	call   80193c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80197c:	83 c3 01             	add    $0x1,%ebx
  80197f:	83 c4 10             	add    $0x10,%esp
  801982:	83 fb 20             	cmp    $0x20,%ebx
  801985:	75 ec                	jne    801973 <close_all+0xc>
		close(i);
}
  801987:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	57                   	push   %edi
  801990:	56                   	push   %esi
  801991:	53                   	push   %ebx
  801992:	83 ec 2c             	sub    $0x2c,%esp
  801995:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801998:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80199b:	50                   	push   %eax
  80199c:	ff 75 08             	pushl  0x8(%ebp)
  80199f:	e8 6b fe ff ff       	call   80180f <fd_lookup>
  8019a4:	83 c4 08             	add    $0x8,%esp
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	0f 88 c1 00 00 00    	js     801a70 <dup+0xe4>
		return r;
	close(newfdnum);
  8019af:	83 ec 0c             	sub    $0xc,%esp
  8019b2:	56                   	push   %esi
  8019b3:	e8 84 ff ff ff       	call   80193c <close>

	newfd = INDEX2FD(newfdnum);
  8019b8:	89 f3                	mov    %esi,%ebx
  8019ba:	c1 e3 0c             	shl    $0xc,%ebx
  8019bd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8019c3:	83 c4 04             	add    $0x4,%esp
  8019c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019c9:	e8 db fd ff ff       	call   8017a9 <fd2data>
  8019ce:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8019d0:	89 1c 24             	mov    %ebx,(%esp)
  8019d3:	e8 d1 fd ff ff       	call   8017a9 <fd2data>
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8019de:	89 f8                	mov    %edi,%eax
  8019e0:	c1 e8 16             	shr    $0x16,%eax
  8019e3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019ea:	a8 01                	test   $0x1,%al
  8019ec:	74 37                	je     801a25 <dup+0x99>
  8019ee:	89 f8                	mov    %edi,%eax
  8019f0:	c1 e8 0c             	shr    $0xc,%eax
  8019f3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019fa:	f6 c2 01             	test   $0x1,%dl
  8019fd:	74 26                	je     801a25 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8019ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a06:	83 ec 0c             	sub    $0xc,%esp
  801a09:	25 07 0e 00 00       	and    $0xe07,%eax
  801a0e:	50                   	push   %eax
  801a0f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801a12:	6a 00                	push   $0x0
  801a14:	57                   	push   %edi
  801a15:	6a 00                	push   $0x0
  801a17:	e8 33 f7 ff ff       	call   80114f <sys_page_map>
  801a1c:	89 c7                	mov    %eax,%edi
  801a1e:	83 c4 20             	add    $0x20,%esp
  801a21:	85 c0                	test   %eax,%eax
  801a23:	78 2e                	js     801a53 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a25:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801a28:	89 d0                	mov    %edx,%eax
  801a2a:	c1 e8 0c             	shr    $0xc,%eax
  801a2d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a34:	83 ec 0c             	sub    $0xc,%esp
  801a37:	25 07 0e 00 00       	and    $0xe07,%eax
  801a3c:	50                   	push   %eax
  801a3d:	53                   	push   %ebx
  801a3e:	6a 00                	push   $0x0
  801a40:	52                   	push   %edx
  801a41:	6a 00                	push   $0x0
  801a43:	e8 07 f7 ff ff       	call   80114f <sys_page_map>
  801a48:	89 c7                	mov    %eax,%edi
  801a4a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801a4d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a4f:	85 ff                	test   %edi,%edi
  801a51:	79 1d                	jns    801a70 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a53:	83 ec 08             	sub    $0x8,%esp
  801a56:	53                   	push   %ebx
  801a57:	6a 00                	push   $0x0
  801a59:	e8 33 f7 ff ff       	call   801191 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a5e:	83 c4 08             	add    $0x8,%esp
  801a61:	ff 75 d4             	pushl  -0x2c(%ebp)
  801a64:	6a 00                	push   $0x0
  801a66:	e8 26 f7 ff ff       	call   801191 <sys_page_unmap>
	return r;
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	89 f8                	mov    %edi,%eax
}
  801a70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a73:	5b                   	pop    %ebx
  801a74:	5e                   	pop    %esi
  801a75:	5f                   	pop    %edi
  801a76:	5d                   	pop    %ebp
  801a77:	c3                   	ret    

00801a78 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	53                   	push   %ebx
  801a7c:	83 ec 14             	sub    $0x14,%esp
  801a7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a82:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a85:	50                   	push   %eax
  801a86:	53                   	push   %ebx
  801a87:	e8 83 fd ff ff       	call   80180f <fd_lookup>
  801a8c:	83 c4 08             	add    $0x8,%esp
  801a8f:	89 c2                	mov    %eax,%edx
  801a91:	85 c0                	test   %eax,%eax
  801a93:	78 70                	js     801b05 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a95:	83 ec 08             	sub    $0x8,%esp
  801a98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9b:	50                   	push   %eax
  801a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a9f:	ff 30                	pushl  (%eax)
  801aa1:	e8 bf fd ff ff       	call   801865 <dev_lookup>
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	78 4f                	js     801afc <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801aad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ab0:	8b 42 08             	mov    0x8(%edx),%eax
  801ab3:	83 e0 03             	and    $0x3,%eax
  801ab6:	83 f8 01             	cmp    $0x1,%eax
  801ab9:	75 24                	jne    801adf <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801abb:	a1 04 50 80 00       	mov    0x805004,%eax
  801ac0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801ac6:	83 ec 04             	sub    $0x4,%esp
  801ac9:	53                   	push   %ebx
  801aca:	50                   	push   %eax
  801acb:	68 04 30 80 00       	push   $0x803004
  801ad0:	e8 af ec ff ff       	call   800784 <cprintf>
		return -E_INVAL;
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801add:	eb 26                	jmp    801b05 <read+0x8d>
	}
	if (!dev->dev_read)
  801adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae2:	8b 40 08             	mov    0x8(%eax),%eax
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	74 17                	je     801b00 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801ae9:	83 ec 04             	sub    $0x4,%esp
  801aec:	ff 75 10             	pushl  0x10(%ebp)
  801aef:	ff 75 0c             	pushl  0xc(%ebp)
  801af2:	52                   	push   %edx
  801af3:	ff d0                	call   *%eax
  801af5:	89 c2                	mov    %eax,%edx
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	eb 09                	jmp    801b05 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801afc:	89 c2                	mov    %eax,%edx
  801afe:	eb 05                	jmp    801b05 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801b00:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801b05:	89 d0                	mov    %edx,%eax
  801b07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	57                   	push   %edi
  801b10:	56                   	push   %esi
  801b11:	53                   	push   %ebx
  801b12:	83 ec 0c             	sub    $0xc,%esp
  801b15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b18:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b20:	eb 21                	jmp    801b43 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801b22:	83 ec 04             	sub    $0x4,%esp
  801b25:	89 f0                	mov    %esi,%eax
  801b27:	29 d8                	sub    %ebx,%eax
  801b29:	50                   	push   %eax
  801b2a:	89 d8                	mov    %ebx,%eax
  801b2c:	03 45 0c             	add    0xc(%ebp),%eax
  801b2f:	50                   	push   %eax
  801b30:	57                   	push   %edi
  801b31:	e8 42 ff ff ff       	call   801a78 <read>
		if (m < 0)
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	78 10                	js     801b4d <readn+0x41>
			return m;
		if (m == 0)
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	74 0a                	je     801b4b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b41:	01 c3                	add    %eax,%ebx
  801b43:	39 f3                	cmp    %esi,%ebx
  801b45:	72 db                	jb     801b22 <readn+0x16>
  801b47:	89 d8                	mov    %ebx,%eax
  801b49:	eb 02                	jmp    801b4d <readn+0x41>
  801b4b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801b4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b50:	5b                   	pop    %ebx
  801b51:	5e                   	pop    %esi
  801b52:	5f                   	pop    %edi
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    

00801b55 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	53                   	push   %ebx
  801b59:	83 ec 14             	sub    $0x14,%esp
  801b5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b5f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b62:	50                   	push   %eax
  801b63:	53                   	push   %ebx
  801b64:	e8 a6 fc ff ff       	call   80180f <fd_lookup>
  801b69:	83 c4 08             	add    $0x8,%esp
  801b6c:	89 c2                	mov    %eax,%edx
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	78 6b                	js     801bdd <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b72:	83 ec 08             	sub    $0x8,%esp
  801b75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b78:	50                   	push   %eax
  801b79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b7c:	ff 30                	pushl  (%eax)
  801b7e:	e8 e2 fc ff ff       	call   801865 <dev_lookup>
  801b83:	83 c4 10             	add    $0x10,%esp
  801b86:	85 c0                	test   %eax,%eax
  801b88:	78 4a                	js     801bd4 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b8d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b91:	75 24                	jne    801bb7 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b93:	a1 04 50 80 00       	mov    0x805004,%eax
  801b98:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801b9e:	83 ec 04             	sub    $0x4,%esp
  801ba1:	53                   	push   %ebx
  801ba2:	50                   	push   %eax
  801ba3:	68 20 30 80 00       	push   $0x803020
  801ba8:	e8 d7 eb ff ff       	call   800784 <cprintf>
		return -E_INVAL;
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801bb5:	eb 26                	jmp    801bdd <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801bb7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bba:	8b 52 0c             	mov    0xc(%edx),%edx
  801bbd:	85 d2                	test   %edx,%edx
  801bbf:	74 17                	je     801bd8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801bc1:	83 ec 04             	sub    $0x4,%esp
  801bc4:	ff 75 10             	pushl  0x10(%ebp)
  801bc7:	ff 75 0c             	pushl  0xc(%ebp)
  801bca:	50                   	push   %eax
  801bcb:	ff d2                	call   *%edx
  801bcd:	89 c2                	mov    %eax,%edx
  801bcf:	83 c4 10             	add    $0x10,%esp
  801bd2:	eb 09                	jmp    801bdd <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bd4:	89 c2                	mov    %eax,%edx
  801bd6:	eb 05                	jmp    801bdd <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801bd8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801bdd:	89 d0                	mov    %edx,%eax
  801bdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be2:	c9                   	leave  
  801be3:	c3                   	ret    

00801be4 <seek>:

int
seek(int fdnum, off_t offset)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bea:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801bed:	50                   	push   %eax
  801bee:	ff 75 08             	pushl  0x8(%ebp)
  801bf1:	e8 19 fc ff ff       	call   80180f <fd_lookup>
  801bf6:	83 c4 08             	add    $0x8,%esp
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	78 0e                	js     801c0b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801bfd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c00:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c03:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801c06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c0b:	c9                   	leave  
  801c0c:	c3                   	ret    

00801c0d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	53                   	push   %ebx
  801c11:	83 ec 14             	sub    $0x14,%esp
  801c14:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c17:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c1a:	50                   	push   %eax
  801c1b:	53                   	push   %ebx
  801c1c:	e8 ee fb ff ff       	call   80180f <fd_lookup>
  801c21:	83 c4 08             	add    $0x8,%esp
  801c24:	89 c2                	mov    %eax,%edx
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 68                	js     801c92 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c2a:	83 ec 08             	sub    $0x8,%esp
  801c2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c30:	50                   	push   %eax
  801c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c34:	ff 30                	pushl  (%eax)
  801c36:	e8 2a fc ff ff       	call   801865 <dev_lookup>
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	78 47                	js     801c89 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c45:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c49:	75 24                	jne    801c6f <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801c4b:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c50:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801c56:	83 ec 04             	sub    $0x4,%esp
  801c59:	53                   	push   %ebx
  801c5a:	50                   	push   %eax
  801c5b:	68 e0 2f 80 00       	push   $0x802fe0
  801c60:	e8 1f eb ff ff       	call   800784 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801c65:	83 c4 10             	add    $0x10,%esp
  801c68:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801c6d:	eb 23                	jmp    801c92 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801c6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c72:	8b 52 18             	mov    0x18(%edx),%edx
  801c75:	85 d2                	test   %edx,%edx
  801c77:	74 14                	je     801c8d <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801c79:	83 ec 08             	sub    $0x8,%esp
  801c7c:	ff 75 0c             	pushl  0xc(%ebp)
  801c7f:	50                   	push   %eax
  801c80:	ff d2                	call   *%edx
  801c82:	89 c2                	mov    %eax,%edx
  801c84:	83 c4 10             	add    $0x10,%esp
  801c87:	eb 09                	jmp    801c92 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c89:	89 c2                	mov    %eax,%edx
  801c8b:	eb 05                	jmp    801c92 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801c8d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801c92:	89 d0                	mov    %edx,%eax
  801c94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c97:	c9                   	leave  
  801c98:	c3                   	ret    

00801c99 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	53                   	push   %ebx
  801c9d:	83 ec 14             	sub    $0x14,%esp
  801ca0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ca3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ca6:	50                   	push   %eax
  801ca7:	ff 75 08             	pushl  0x8(%ebp)
  801caa:	e8 60 fb ff ff       	call   80180f <fd_lookup>
  801caf:	83 c4 08             	add    $0x8,%esp
  801cb2:	89 c2                	mov    %eax,%edx
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	78 58                	js     801d10 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cb8:	83 ec 08             	sub    $0x8,%esp
  801cbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbe:	50                   	push   %eax
  801cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc2:	ff 30                	pushl  (%eax)
  801cc4:	e8 9c fb ff ff       	call   801865 <dev_lookup>
  801cc9:	83 c4 10             	add    $0x10,%esp
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	78 37                	js     801d07 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801cd7:	74 32                	je     801d0b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801cd9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801cdc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801ce3:	00 00 00 
	stat->st_isdir = 0;
  801ce6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ced:	00 00 00 
	stat->st_dev = dev;
  801cf0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801cf6:	83 ec 08             	sub    $0x8,%esp
  801cf9:	53                   	push   %ebx
  801cfa:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfd:	ff 50 14             	call   *0x14(%eax)
  801d00:	89 c2                	mov    %eax,%edx
  801d02:	83 c4 10             	add    $0x10,%esp
  801d05:	eb 09                	jmp    801d10 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d07:	89 c2                	mov    %eax,%edx
  801d09:	eb 05                	jmp    801d10 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801d0b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801d10:	89 d0                	mov    %edx,%eax
  801d12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d15:	c9                   	leave  
  801d16:	c3                   	ret    

00801d17 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	56                   	push   %esi
  801d1b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801d1c:	83 ec 08             	sub    $0x8,%esp
  801d1f:	6a 00                	push   $0x0
  801d21:	ff 75 08             	pushl  0x8(%ebp)
  801d24:	e8 e3 01 00 00       	call   801f0c <open>
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 1b                	js     801d4d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801d32:	83 ec 08             	sub    $0x8,%esp
  801d35:	ff 75 0c             	pushl  0xc(%ebp)
  801d38:	50                   	push   %eax
  801d39:	e8 5b ff ff ff       	call   801c99 <fstat>
  801d3e:	89 c6                	mov    %eax,%esi
	close(fd);
  801d40:	89 1c 24             	mov    %ebx,(%esp)
  801d43:	e8 f4 fb ff ff       	call   80193c <close>
	return r;
  801d48:	83 c4 10             	add    $0x10,%esp
  801d4b:	89 f0                	mov    %esi,%eax
}
  801d4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d50:	5b                   	pop    %ebx
  801d51:	5e                   	pop    %esi
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    

00801d54 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	56                   	push   %esi
  801d58:	53                   	push   %ebx
  801d59:	89 c6                	mov    %eax,%esi
  801d5b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801d5d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801d64:	75 12                	jne    801d78 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d66:	83 ec 0c             	sub    $0xc,%esp
  801d69:	6a 01                	push   $0x1
  801d6b:	e8 e4 f9 ff ff       	call   801754 <ipc_find_env>
  801d70:	a3 00 50 80 00       	mov    %eax,0x805000
  801d75:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d78:	6a 07                	push   $0x7
  801d7a:	68 00 60 80 00       	push   $0x806000
  801d7f:	56                   	push   %esi
  801d80:	ff 35 00 50 80 00    	pushl  0x805000
  801d86:	e8 67 f9 ff ff       	call   8016f2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d8b:	83 c4 0c             	add    $0xc,%esp
  801d8e:	6a 00                	push   $0x0
  801d90:	53                   	push   %ebx
  801d91:	6a 00                	push   $0x0
  801d93:	e8 df f8 ff ff       	call   801677 <ipc_recv>
}
  801d98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d9b:	5b                   	pop    %ebx
  801d9c:	5e                   	pop    %esi
  801d9d:	5d                   	pop    %ebp
  801d9e:	c3                   	ret    

00801d9f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801da5:	8b 45 08             	mov    0x8(%ebp),%eax
  801da8:	8b 40 0c             	mov    0xc(%eax),%eax
  801dab:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801db0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db3:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801db8:	ba 00 00 00 00       	mov    $0x0,%edx
  801dbd:	b8 02 00 00 00       	mov    $0x2,%eax
  801dc2:	e8 8d ff ff ff       	call   801d54 <fsipc>
}
  801dc7:	c9                   	leave  
  801dc8:	c3                   	ret    

00801dc9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd2:	8b 40 0c             	mov    0xc(%eax),%eax
  801dd5:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801dda:	ba 00 00 00 00       	mov    $0x0,%edx
  801ddf:	b8 06 00 00 00       	mov    $0x6,%eax
  801de4:	e8 6b ff ff ff       	call   801d54 <fsipc>
}
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	53                   	push   %ebx
  801def:	83 ec 04             	sub    $0x4,%esp
  801df2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801df5:	8b 45 08             	mov    0x8(%ebp),%eax
  801df8:	8b 40 0c             	mov    0xc(%eax),%eax
  801dfb:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e00:	ba 00 00 00 00       	mov    $0x0,%edx
  801e05:	b8 05 00 00 00       	mov    $0x5,%eax
  801e0a:	e8 45 ff ff ff       	call   801d54 <fsipc>
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	78 2c                	js     801e3f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e13:	83 ec 08             	sub    $0x8,%esp
  801e16:	68 00 60 80 00       	push   $0x806000
  801e1b:	53                   	push   %ebx
  801e1c:	e8 e8 ee ff ff       	call   800d09 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e21:	a1 80 60 80 00       	mov    0x806080,%eax
  801e26:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e2c:	a1 84 60 80 00       	mov    0x806084,%eax
  801e31:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801e37:	83 c4 10             	add    $0x10,%esp
  801e3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e42:	c9                   	leave  
  801e43:	c3                   	ret    

00801e44 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	83 ec 0c             	sub    $0xc,%esp
  801e4a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801e4d:	8b 55 08             	mov    0x8(%ebp),%edx
  801e50:	8b 52 0c             	mov    0xc(%edx),%edx
  801e53:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801e59:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801e5e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801e63:	0f 47 c2             	cmova  %edx,%eax
  801e66:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801e6b:	50                   	push   %eax
  801e6c:	ff 75 0c             	pushl  0xc(%ebp)
  801e6f:	68 08 60 80 00       	push   $0x806008
  801e74:	e8 22 f0 ff ff       	call   800e9b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801e79:	ba 00 00 00 00       	mov    $0x0,%edx
  801e7e:	b8 04 00 00 00       	mov    $0x4,%eax
  801e83:	e8 cc fe ff ff       	call   801d54 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801e88:	c9                   	leave  
  801e89:	c3                   	ret    

00801e8a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	56                   	push   %esi
  801e8e:	53                   	push   %ebx
  801e8f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e92:	8b 45 08             	mov    0x8(%ebp),%eax
  801e95:	8b 40 0c             	mov    0xc(%eax),%eax
  801e98:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801e9d:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ea3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea8:	b8 03 00 00 00       	mov    $0x3,%eax
  801ead:	e8 a2 fe ff ff       	call   801d54 <fsipc>
  801eb2:	89 c3                	mov    %eax,%ebx
  801eb4:	85 c0                	test   %eax,%eax
  801eb6:	78 4b                	js     801f03 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801eb8:	39 c6                	cmp    %eax,%esi
  801eba:	73 16                	jae    801ed2 <devfile_read+0x48>
  801ebc:	68 50 30 80 00       	push   $0x803050
  801ec1:	68 57 30 80 00       	push   $0x803057
  801ec6:	6a 7c                	push   $0x7c
  801ec8:	68 6c 30 80 00       	push   $0x80306c
  801ecd:	e8 d9 e7 ff ff       	call   8006ab <_panic>
	assert(r <= PGSIZE);
  801ed2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ed7:	7e 16                	jle    801eef <devfile_read+0x65>
  801ed9:	68 77 30 80 00       	push   $0x803077
  801ede:	68 57 30 80 00       	push   $0x803057
  801ee3:	6a 7d                	push   $0x7d
  801ee5:	68 6c 30 80 00       	push   $0x80306c
  801eea:	e8 bc e7 ff ff       	call   8006ab <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801eef:	83 ec 04             	sub    $0x4,%esp
  801ef2:	50                   	push   %eax
  801ef3:	68 00 60 80 00       	push   $0x806000
  801ef8:	ff 75 0c             	pushl  0xc(%ebp)
  801efb:	e8 9b ef ff ff       	call   800e9b <memmove>
	return r;
  801f00:	83 c4 10             	add    $0x10,%esp
}
  801f03:	89 d8                	mov    %ebx,%eax
  801f05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f08:	5b                   	pop    %ebx
  801f09:	5e                   	pop    %esi
  801f0a:	5d                   	pop    %ebp
  801f0b:	c3                   	ret    

00801f0c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	53                   	push   %ebx
  801f10:	83 ec 20             	sub    $0x20,%esp
  801f13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801f16:	53                   	push   %ebx
  801f17:	e8 b4 ed ff ff       	call   800cd0 <strlen>
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f24:	7f 67                	jg     801f8d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801f26:	83 ec 0c             	sub    $0xc,%esp
  801f29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f2c:	50                   	push   %eax
  801f2d:	e8 8e f8 ff ff       	call   8017c0 <fd_alloc>
  801f32:	83 c4 10             	add    $0x10,%esp
		return r;
  801f35:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801f37:	85 c0                	test   %eax,%eax
  801f39:	78 57                	js     801f92 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801f3b:	83 ec 08             	sub    $0x8,%esp
  801f3e:	53                   	push   %ebx
  801f3f:	68 00 60 80 00       	push   $0x806000
  801f44:	e8 c0 ed ff ff       	call   800d09 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801f49:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4c:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801f51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f54:	b8 01 00 00 00       	mov    $0x1,%eax
  801f59:	e8 f6 fd ff ff       	call   801d54 <fsipc>
  801f5e:	89 c3                	mov    %eax,%ebx
  801f60:	83 c4 10             	add    $0x10,%esp
  801f63:	85 c0                	test   %eax,%eax
  801f65:	79 14                	jns    801f7b <open+0x6f>
		fd_close(fd, 0);
  801f67:	83 ec 08             	sub    $0x8,%esp
  801f6a:	6a 00                	push   $0x0
  801f6c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f6f:	e8 47 f9 ff ff       	call   8018bb <fd_close>
		return r;
  801f74:	83 c4 10             	add    $0x10,%esp
  801f77:	89 da                	mov    %ebx,%edx
  801f79:	eb 17                	jmp    801f92 <open+0x86>
	}

	return fd2num(fd);
  801f7b:	83 ec 0c             	sub    $0xc,%esp
  801f7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f81:	e8 13 f8 ff ff       	call   801799 <fd2num>
  801f86:	89 c2                	mov    %eax,%edx
  801f88:	83 c4 10             	add    $0x10,%esp
  801f8b:	eb 05                	jmp    801f92 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801f8d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801f92:	89 d0                	mov    %edx,%eax
  801f94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f97:	c9                   	leave  
  801f98:	c3                   	ret    

00801f99 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801fa4:	b8 08 00 00 00       	mov    $0x8,%eax
  801fa9:	e8 a6 fd ff ff       	call   801d54 <fsipc>
}
  801fae:	c9                   	leave  
  801faf:	c3                   	ret    

00801fb0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	56                   	push   %esi
  801fb4:	53                   	push   %ebx
  801fb5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fb8:	83 ec 0c             	sub    $0xc,%esp
  801fbb:	ff 75 08             	pushl  0x8(%ebp)
  801fbe:	e8 e6 f7 ff ff       	call   8017a9 <fd2data>
  801fc3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fc5:	83 c4 08             	add    $0x8,%esp
  801fc8:	68 83 30 80 00       	push   $0x803083
  801fcd:	53                   	push   %ebx
  801fce:	e8 36 ed ff ff       	call   800d09 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fd3:	8b 46 04             	mov    0x4(%esi),%eax
  801fd6:	2b 06                	sub    (%esi),%eax
  801fd8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801fde:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fe5:	00 00 00 
	stat->st_dev = &devpipe;
  801fe8:	c7 83 88 00 00 00 24 	movl   $0x804024,0x88(%ebx)
  801fef:	40 80 00 
	return 0;
}
  801ff2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ffa:	5b                   	pop    %ebx
  801ffb:	5e                   	pop    %esi
  801ffc:	5d                   	pop    %ebp
  801ffd:	c3                   	ret    

00801ffe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ffe:	55                   	push   %ebp
  801fff:	89 e5                	mov    %esp,%ebp
  802001:	53                   	push   %ebx
  802002:	83 ec 0c             	sub    $0xc,%esp
  802005:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802008:	53                   	push   %ebx
  802009:	6a 00                	push   $0x0
  80200b:	e8 81 f1 ff ff       	call   801191 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802010:	89 1c 24             	mov    %ebx,(%esp)
  802013:	e8 91 f7 ff ff       	call   8017a9 <fd2data>
  802018:	83 c4 08             	add    $0x8,%esp
  80201b:	50                   	push   %eax
  80201c:	6a 00                	push   $0x0
  80201e:	e8 6e f1 ff ff       	call   801191 <sys_page_unmap>
}
  802023:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802026:	c9                   	leave  
  802027:	c3                   	ret    

00802028 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802028:	55                   	push   %ebp
  802029:	89 e5                	mov    %esp,%ebp
  80202b:	57                   	push   %edi
  80202c:	56                   	push   %esi
  80202d:	53                   	push   %ebx
  80202e:	83 ec 1c             	sub    $0x1c,%esp
  802031:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802034:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802036:	a1 04 50 80 00       	mov    0x805004,%eax
  80203b:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802041:	83 ec 0c             	sub    $0xc,%esp
  802044:	ff 75 e0             	pushl  -0x20(%ebp)
  802047:	e8 db 04 00 00       	call   802527 <pageref>
  80204c:	89 c3                	mov    %eax,%ebx
  80204e:	89 3c 24             	mov    %edi,(%esp)
  802051:	e8 d1 04 00 00       	call   802527 <pageref>
  802056:	83 c4 10             	add    $0x10,%esp
  802059:	39 c3                	cmp    %eax,%ebx
  80205b:	0f 94 c1             	sete   %cl
  80205e:	0f b6 c9             	movzbl %cl,%ecx
  802061:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802064:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80206a:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  802070:	39 ce                	cmp    %ecx,%esi
  802072:	74 1e                	je     802092 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  802074:	39 c3                	cmp    %eax,%ebx
  802076:	75 be                	jne    802036 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802078:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  80207e:	ff 75 e4             	pushl  -0x1c(%ebp)
  802081:	50                   	push   %eax
  802082:	56                   	push   %esi
  802083:	68 8a 30 80 00       	push   $0x80308a
  802088:	e8 f7 e6 ff ff       	call   800784 <cprintf>
  80208d:	83 c4 10             	add    $0x10,%esp
  802090:	eb a4                	jmp    802036 <_pipeisclosed+0xe>
	}
}
  802092:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802095:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802098:	5b                   	pop    %ebx
  802099:	5e                   	pop    %esi
  80209a:	5f                   	pop    %edi
  80209b:	5d                   	pop    %ebp
  80209c:	c3                   	ret    

0080209d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80209d:	55                   	push   %ebp
  80209e:	89 e5                	mov    %esp,%ebp
  8020a0:	57                   	push   %edi
  8020a1:	56                   	push   %esi
  8020a2:	53                   	push   %ebx
  8020a3:	83 ec 28             	sub    $0x28,%esp
  8020a6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8020a9:	56                   	push   %esi
  8020aa:	e8 fa f6 ff ff       	call   8017a9 <fd2data>
  8020af:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020b1:	83 c4 10             	add    $0x10,%esp
  8020b4:	bf 00 00 00 00       	mov    $0x0,%edi
  8020b9:	eb 4b                	jmp    802106 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8020bb:	89 da                	mov    %ebx,%edx
  8020bd:	89 f0                	mov    %esi,%eax
  8020bf:	e8 64 ff ff ff       	call   802028 <_pipeisclosed>
  8020c4:	85 c0                	test   %eax,%eax
  8020c6:	75 48                	jne    802110 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020c8:	e8 20 f0 ff ff       	call   8010ed <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020cd:	8b 43 04             	mov    0x4(%ebx),%eax
  8020d0:	8b 0b                	mov    (%ebx),%ecx
  8020d2:	8d 51 20             	lea    0x20(%ecx),%edx
  8020d5:	39 d0                	cmp    %edx,%eax
  8020d7:	73 e2                	jae    8020bb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020dc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020e0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020e3:	89 c2                	mov    %eax,%edx
  8020e5:	c1 fa 1f             	sar    $0x1f,%edx
  8020e8:	89 d1                	mov    %edx,%ecx
  8020ea:	c1 e9 1b             	shr    $0x1b,%ecx
  8020ed:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020f0:	83 e2 1f             	and    $0x1f,%edx
  8020f3:	29 ca                	sub    %ecx,%edx
  8020f5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020f9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020fd:	83 c0 01             	add    $0x1,%eax
  802100:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802103:	83 c7 01             	add    $0x1,%edi
  802106:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802109:	75 c2                	jne    8020cd <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80210b:	8b 45 10             	mov    0x10(%ebp),%eax
  80210e:	eb 05                	jmp    802115 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802110:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802118:	5b                   	pop    %ebx
  802119:	5e                   	pop    %esi
  80211a:	5f                   	pop    %edi
  80211b:	5d                   	pop    %ebp
  80211c:	c3                   	ret    

0080211d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80211d:	55                   	push   %ebp
  80211e:	89 e5                	mov    %esp,%ebp
  802120:	57                   	push   %edi
  802121:	56                   	push   %esi
  802122:	53                   	push   %ebx
  802123:	83 ec 18             	sub    $0x18,%esp
  802126:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802129:	57                   	push   %edi
  80212a:	e8 7a f6 ff ff       	call   8017a9 <fd2data>
  80212f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802131:	83 c4 10             	add    $0x10,%esp
  802134:	bb 00 00 00 00       	mov    $0x0,%ebx
  802139:	eb 3d                	jmp    802178 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80213b:	85 db                	test   %ebx,%ebx
  80213d:	74 04                	je     802143 <devpipe_read+0x26>
				return i;
  80213f:	89 d8                	mov    %ebx,%eax
  802141:	eb 44                	jmp    802187 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802143:	89 f2                	mov    %esi,%edx
  802145:	89 f8                	mov    %edi,%eax
  802147:	e8 dc fe ff ff       	call   802028 <_pipeisclosed>
  80214c:	85 c0                	test   %eax,%eax
  80214e:	75 32                	jne    802182 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802150:	e8 98 ef ff ff       	call   8010ed <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802155:	8b 06                	mov    (%esi),%eax
  802157:	3b 46 04             	cmp    0x4(%esi),%eax
  80215a:	74 df                	je     80213b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80215c:	99                   	cltd   
  80215d:	c1 ea 1b             	shr    $0x1b,%edx
  802160:	01 d0                	add    %edx,%eax
  802162:	83 e0 1f             	and    $0x1f,%eax
  802165:	29 d0                	sub    %edx,%eax
  802167:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80216c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80216f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802172:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802175:	83 c3 01             	add    $0x1,%ebx
  802178:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80217b:	75 d8                	jne    802155 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80217d:	8b 45 10             	mov    0x10(%ebp),%eax
  802180:	eb 05                	jmp    802187 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802182:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802187:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80218a:	5b                   	pop    %ebx
  80218b:	5e                   	pop    %esi
  80218c:	5f                   	pop    %edi
  80218d:	5d                   	pop    %ebp
  80218e:	c3                   	ret    

0080218f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80218f:	55                   	push   %ebp
  802190:	89 e5                	mov    %esp,%ebp
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802197:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80219a:	50                   	push   %eax
  80219b:	e8 20 f6 ff ff       	call   8017c0 <fd_alloc>
  8021a0:	83 c4 10             	add    $0x10,%esp
  8021a3:	89 c2                	mov    %eax,%edx
  8021a5:	85 c0                	test   %eax,%eax
  8021a7:	0f 88 2c 01 00 00    	js     8022d9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ad:	83 ec 04             	sub    $0x4,%esp
  8021b0:	68 07 04 00 00       	push   $0x407
  8021b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b8:	6a 00                	push   $0x0
  8021ba:	e8 4d ef ff ff       	call   80110c <sys_page_alloc>
  8021bf:	83 c4 10             	add    $0x10,%esp
  8021c2:	89 c2                	mov    %eax,%edx
  8021c4:	85 c0                	test   %eax,%eax
  8021c6:	0f 88 0d 01 00 00    	js     8022d9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021cc:	83 ec 0c             	sub    $0xc,%esp
  8021cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021d2:	50                   	push   %eax
  8021d3:	e8 e8 f5 ff ff       	call   8017c0 <fd_alloc>
  8021d8:	89 c3                	mov    %eax,%ebx
  8021da:	83 c4 10             	add    $0x10,%esp
  8021dd:	85 c0                	test   %eax,%eax
  8021df:	0f 88 e2 00 00 00    	js     8022c7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021e5:	83 ec 04             	sub    $0x4,%esp
  8021e8:	68 07 04 00 00       	push   $0x407
  8021ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8021f0:	6a 00                	push   $0x0
  8021f2:	e8 15 ef ff ff       	call   80110c <sys_page_alloc>
  8021f7:	89 c3                	mov    %eax,%ebx
  8021f9:	83 c4 10             	add    $0x10,%esp
  8021fc:	85 c0                	test   %eax,%eax
  8021fe:	0f 88 c3 00 00 00    	js     8022c7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802204:	83 ec 0c             	sub    $0xc,%esp
  802207:	ff 75 f4             	pushl  -0xc(%ebp)
  80220a:	e8 9a f5 ff ff       	call   8017a9 <fd2data>
  80220f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802211:	83 c4 0c             	add    $0xc,%esp
  802214:	68 07 04 00 00       	push   $0x407
  802219:	50                   	push   %eax
  80221a:	6a 00                	push   $0x0
  80221c:	e8 eb ee ff ff       	call   80110c <sys_page_alloc>
  802221:	89 c3                	mov    %eax,%ebx
  802223:	83 c4 10             	add    $0x10,%esp
  802226:	85 c0                	test   %eax,%eax
  802228:	0f 88 89 00 00 00    	js     8022b7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80222e:	83 ec 0c             	sub    $0xc,%esp
  802231:	ff 75 f0             	pushl  -0x10(%ebp)
  802234:	e8 70 f5 ff ff       	call   8017a9 <fd2data>
  802239:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802240:	50                   	push   %eax
  802241:	6a 00                	push   $0x0
  802243:	56                   	push   %esi
  802244:	6a 00                	push   $0x0
  802246:	e8 04 ef ff ff       	call   80114f <sys_page_map>
  80224b:	89 c3                	mov    %eax,%ebx
  80224d:	83 c4 20             	add    $0x20,%esp
  802250:	85 c0                	test   %eax,%eax
  802252:	78 55                	js     8022a9 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802254:	8b 15 24 40 80 00    	mov    0x804024,%edx
  80225a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80225f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802262:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802269:	8b 15 24 40 80 00    	mov    0x804024,%edx
  80226f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802272:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802274:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802277:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80227e:	83 ec 0c             	sub    $0xc,%esp
  802281:	ff 75 f4             	pushl  -0xc(%ebp)
  802284:	e8 10 f5 ff ff       	call   801799 <fd2num>
  802289:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80228c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80228e:	83 c4 04             	add    $0x4,%esp
  802291:	ff 75 f0             	pushl  -0x10(%ebp)
  802294:	e8 00 f5 ff ff       	call   801799 <fd2num>
  802299:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80229c:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80229f:	83 c4 10             	add    $0x10,%esp
  8022a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8022a7:	eb 30                	jmp    8022d9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8022a9:	83 ec 08             	sub    $0x8,%esp
  8022ac:	56                   	push   %esi
  8022ad:	6a 00                	push   $0x0
  8022af:	e8 dd ee ff ff       	call   801191 <sys_page_unmap>
  8022b4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8022b7:	83 ec 08             	sub    $0x8,%esp
  8022ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8022bd:	6a 00                	push   $0x0
  8022bf:	e8 cd ee ff ff       	call   801191 <sys_page_unmap>
  8022c4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8022c7:	83 ec 08             	sub    $0x8,%esp
  8022ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8022cd:	6a 00                	push   $0x0
  8022cf:	e8 bd ee ff ff       	call   801191 <sys_page_unmap>
  8022d4:	83 c4 10             	add    $0x10,%esp
  8022d7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8022d9:	89 d0                	mov    %edx,%eax
  8022db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022de:	5b                   	pop    %ebx
  8022df:	5e                   	pop    %esi
  8022e0:	5d                   	pop    %ebp
  8022e1:	c3                   	ret    

008022e2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022e2:	55                   	push   %ebp
  8022e3:	89 e5                	mov    %esp,%ebp
  8022e5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022eb:	50                   	push   %eax
  8022ec:	ff 75 08             	pushl  0x8(%ebp)
  8022ef:	e8 1b f5 ff ff       	call   80180f <fd_lookup>
  8022f4:	83 c4 10             	add    $0x10,%esp
  8022f7:	85 c0                	test   %eax,%eax
  8022f9:	78 18                	js     802313 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022fb:	83 ec 0c             	sub    $0xc,%esp
  8022fe:	ff 75 f4             	pushl  -0xc(%ebp)
  802301:	e8 a3 f4 ff ff       	call   8017a9 <fd2data>
	return _pipeisclosed(fd, p);
  802306:	89 c2                	mov    %eax,%edx
  802308:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80230b:	e8 18 fd ff ff       	call   802028 <_pipeisclosed>
  802310:	83 c4 10             	add    $0x10,%esp
}
  802313:	c9                   	leave  
  802314:	c3                   	ret    

00802315 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802315:	55                   	push   %ebp
  802316:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802318:	b8 00 00 00 00       	mov    $0x0,%eax
  80231d:	5d                   	pop    %ebp
  80231e:	c3                   	ret    

0080231f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80231f:	55                   	push   %ebp
  802320:	89 e5                	mov    %esp,%ebp
  802322:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802325:	68 a2 30 80 00       	push   $0x8030a2
  80232a:	ff 75 0c             	pushl  0xc(%ebp)
  80232d:	e8 d7 e9 ff ff       	call   800d09 <strcpy>
	return 0;
}
  802332:	b8 00 00 00 00       	mov    $0x0,%eax
  802337:	c9                   	leave  
  802338:	c3                   	ret    

00802339 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802339:	55                   	push   %ebp
  80233a:	89 e5                	mov    %esp,%ebp
  80233c:	57                   	push   %edi
  80233d:	56                   	push   %esi
  80233e:	53                   	push   %ebx
  80233f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802345:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80234a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802350:	eb 2d                	jmp    80237f <devcons_write+0x46>
		m = n - tot;
  802352:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802355:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802357:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80235a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80235f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802362:	83 ec 04             	sub    $0x4,%esp
  802365:	53                   	push   %ebx
  802366:	03 45 0c             	add    0xc(%ebp),%eax
  802369:	50                   	push   %eax
  80236a:	57                   	push   %edi
  80236b:	e8 2b eb ff ff       	call   800e9b <memmove>
		sys_cputs(buf, m);
  802370:	83 c4 08             	add    $0x8,%esp
  802373:	53                   	push   %ebx
  802374:	57                   	push   %edi
  802375:	e8 d6 ec ff ff       	call   801050 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80237a:	01 de                	add    %ebx,%esi
  80237c:	83 c4 10             	add    $0x10,%esp
  80237f:	89 f0                	mov    %esi,%eax
  802381:	3b 75 10             	cmp    0x10(%ebp),%esi
  802384:	72 cc                	jb     802352 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802386:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802389:	5b                   	pop    %ebx
  80238a:	5e                   	pop    %esi
  80238b:	5f                   	pop    %edi
  80238c:	5d                   	pop    %ebp
  80238d:	c3                   	ret    

0080238e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80238e:	55                   	push   %ebp
  80238f:	89 e5                	mov    %esp,%ebp
  802391:	83 ec 08             	sub    $0x8,%esp
  802394:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802399:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80239d:	74 2a                	je     8023c9 <devcons_read+0x3b>
  80239f:	eb 05                	jmp    8023a6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023a1:	e8 47 ed ff ff       	call   8010ed <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023a6:	e8 c3 ec ff ff       	call   80106e <sys_cgetc>
  8023ab:	85 c0                	test   %eax,%eax
  8023ad:	74 f2                	je     8023a1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023af:	85 c0                	test   %eax,%eax
  8023b1:	78 16                	js     8023c9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023b3:	83 f8 04             	cmp    $0x4,%eax
  8023b6:	74 0c                	je     8023c4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8023b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023bb:	88 02                	mov    %al,(%edx)
	return 1;
  8023bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8023c2:	eb 05                	jmp    8023c9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023c4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023c9:	c9                   	leave  
  8023ca:	c3                   	ret    

008023cb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023cb:	55                   	push   %ebp
  8023cc:	89 e5                	mov    %esp,%ebp
  8023ce:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023d7:	6a 01                	push   $0x1
  8023d9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023dc:	50                   	push   %eax
  8023dd:	e8 6e ec ff ff       	call   801050 <sys_cputs>
}
  8023e2:	83 c4 10             	add    $0x10,%esp
  8023e5:	c9                   	leave  
  8023e6:	c3                   	ret    

008023e7 <getchar>:

int
getchar(void)
{
  8023e7:	55                   	push   %ebp
  8023e8:	89 e5                	mov    %esp,%ebp
  8023ea:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023ed:	6a 01                	push   $0x1
  8023ef:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023f2:	50                   	push   %eax
  8023f3:	6a 00                	push   $0x0
  8023f5:	e8 7e f6 ff ff       	call   801a78 <read>
	if (r < 0)
  8023fa:	83 c4 10             	add    $0x10,%esp
  8023fd:	85 c0                	test   %eax,%eax
  8023ff:	78 0f                	js     802410 <getchar+0x29>
		return r;
	if (r < 1)
  802401:	85 c0                	test   %eax,%eax
  802403:	7e 06                	jle    80240b <getchar+0x24>
		return -E_EOF;
	return c;
  802405:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802409:	eb 05                	jmp    802410 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80240b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802410:	c9                   	leave  
  802411:	c3                   	ret    

00802412 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802412:	55                   	push   %ebp
  802413:	89 e5                	mov    %esp,%ebp
  802415:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802418:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80241b:	50                   	push   %eax
  80241c:	ff 75 08             	pushl  0x8(%ebp)
  80241f:	e8 eb f3 ff ff       	call   80180f <fd_lookup>
  802424:	83 c4 10             	add    $0x10,%esp
  802427:	85 c0                	test   %eax,%eax
  802429:	78 11                	js     80243c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80242b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80242e:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802434:	39 10                	cmp    %edx,(%eax)
  802436:	0f 94 c0             	sete   %al
  802439:	0f b6 c0             	movzbl %al,%eax
}
  80243c:	c9                   	leave  
  80243d:	c3                   	ret    

0080243e <opencons>:

int
opencons(void)
{
  80243e:	55                   	push   %ebp
  80243f:	89 e5                	mov    %esp,%ebp
  802441:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802444:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802447:	50                   	push   %eax
  802448:	e8 73 f3 ff ff       	call   8017c0 <fd_alloc>
  80244d:	83 c4 10             	add    $0x10,%esp
		return r;
  802450:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802452:	85 c0                	test   %eax,%eax
  802454:	78 3e                	js     802494 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802456:	83 ec 04             	sub    $0x4,%esp
  802459:	68 07 04 00 00       	push   $0x407
  80245e:	ff 75 f4             	pushl  -0xc(%ebp)
  802461:	6a 00                	push   $0x0
  802463:	e8 a4 ec ff ff       	call   80110c <sys_page_alloc>
  802468:	83 c4 10             	add    $0x10,%esp
		return r;
  80246b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80246d:	85 c0                	test   %eax,%eax
  80246f:	78 23                	js     802494 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802471:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802477:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80247a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80247c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80247f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802486:	83 ec 0c             	sub    $0xc,%esp
  802489:	50                   	push   %eax
  80248a:	e8 0a f3 ff ff       	call   801799 <fd2num>
  80248f:	89 c2                	mov    %eax,%edx
  802491:	83 c4 10             	add    $0x10,%esp
}
  802494:	89 d0                	mov    %edx,%eax
  802496:	c9                   	leave  
  802497:	c3                   	ret    

00802498 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802498:	55                   	push   %ebp
  802499:	89 e5                	mov    %esp,%ebp
  80249b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80249e:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8024a5:	75 2a                	jne    8024d1 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8024a7:	83 ec 04             	sub    $0x4,%esp
  8024aa:	6a 07                	push   $0x7
  8024ac:	68 00 f0 bf ee       	push   $0xeebff000
  8024b1:	6a 00                	push   $0x0
  8024b3:	e8 54 ec ff ff       	call   80110c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8024b8:	83 c4 10             	add    $0x10,%esp
  8024bb:	85 c0                	test   %eax,%eax
  8024bd:	79 12                	jns    8024d1 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8024bf:	50                   	push   %eax
  8024c0:	68 ae 30 80 00       	push   $0x8030ae
  8024c5:	6a 23                	push   $0x23
  8024c7:	68 b2 30 80 00       	push   $0x8030b2
  8024cc:	e8 da e1 ff ff       	call   8006ab <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d4:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8024d9:	83 ec 08             	sub    $0x8,%esp
  8024dc:	68 03 25 80 00       	push   $0x802503
  8024e1:	6a 00                	push   $0x0
  8024e3:	e8 6f ed ff ff       	call   801257 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8024e8:	83 c4 10             	add    $0x10,%esp
  8024eb:	85 c0                	test   %eax,%eax
  8024ed:	79 12                	jns    802501 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8024ef:	50                   	push   %eax
  8024f0:	68 ae 30 80 00       	push   $0x8030ae
  8024f5:	6a 2c                	push   $0x2c
  8024f7:	68 b2 30 80 00       	push   $0x8030b2
  8024fc:	e8 aa e1 ff ff       	call   8006ab <_panic>
	}
}
  802501:	c9                   	leave  
  802502:	c3                   	ret    

00802503 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802503:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802504:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802509:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80250b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80250e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802512:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802517:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80251b:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80251d:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802520:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802521:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802524:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802525:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802526:	c3                   	ret    

00802527 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802527:	55                   	push   %ebp
  802528:	89 e5                	mov    %esp,%ebp
  80252a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80252d:	89 d0                	mov    %edx,%eax
  80252f:	c1 e8 16             	shr    $0x16,%eax
  802532:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802539:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80253e:	f6 c1 01             	test   $0x1,%cl
  802541:	74 1d                	je     802560 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802543:	c1 ea 0c             	shr    $0xc,%edx
  802546:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80254d:	f6 c2 01             	test   $0x1,%dl
  802550:	74 0e                	je     802560 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802552:	c1 ea 0c             	shr    $0xc,%edx
  802555:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80255c:	ef 
  80255d:	0f b7 c0             	movzwl %ax,%eax
}
  802560:	5d                   	pop    %ebp
  802561:	c3                   	ret    
  802562:	66 90                	xchg   %ax,%ax
  802564:	66 90                	xchg   %ax,%ax
  802566:	66 90                	xchg   %ax,%ax
  802568:	66 90                	xchg   %ax,%ax
  80256a:	66 90                	xchg   %ax,%ax
  80256c:	66 90                	xchg   %ax,%ax
  80256e:	66 90                	xchg   %ax,%ax

00802570 <__udivdi3>:
  802570:	55                   	push   %ebp
  802571:	57                   	push   %edi
  802572:	56                   	push   %esi
  802573:	53                   	push   %ebx
  802574:	83 ec 1c             	sub    $0x1c,%esp
  802577:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80257b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80257f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802583:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802587:	85 f6                	test   %esi,%esi
  802589:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80258d:	89 ca                	mov    %ecx,%edx
  80258f:	89 f8                	mov    %edi,%eax
  802591:	75 3d                	jne    8025d0 <__udivdi3+0x60>
  802593:	39 cf                	cmp    %ecx,%edi
  802595:	0f 87 c5 00 00 00    	ja     802660 <__udivdi3+0xf0>
  80259b:	85 ff                	test   %edi,%edi
  80259d:	89 fd                	mov    %edi,%ebp
  80259f:	75 0b                	jne    8025ac <__udivdi3+0x3c>
  8025a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025a6:	31 d2                	xor    %edx,%edx
  8025a8:	f7 f7                	div    %edi
  8025aa:	89 c5                	mov    %eax,%ebp
  8025ac:	89 c8                	mov    %ecx,%eax
  8025ae:	31 d2                	xor    %edx,%edx
  8025b0:	f7 f5                	div    %ebp
  8025b2:	89 c1                	mov    %eax,%ecx
  8025b4:	89 d8                	mov    %ebx,%eax
  8025b6:	89 cf                	mov    %ecx,%edi
  8025b8:	f7 f5                	div    %ebp
  8025ba:	89 c3                	mov    %eax,%ebx
  8025bc:	89 d8                	mov    %ebx,%eax
  8025be:	89 fa                	mov    %edi,%edx
  8025c0:	83 c4 1c             	add    $0x1c,%esp
  8025c3:	5b                   	pop    %ebx
  8025c4:	5e                   	pop    %esi
  8025c5:	5f                   	pop    %edi
  8025c6:	5d                   	pop    %ebp
  8025c7:	c3                   	ret    
  8025c8:	90                   	nop
  8025c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	39 ce                	cmp    %ecx,%esi
  8025d2:	77 74                	ja     802648 <__udivdi3+0xd8>
  8025d4:	0f bd fe             	bsr    %esi,%edi
  8025d7:	83 f7 1f             	xor    $0x1f,%edi
  8025da:	0f 84 98 00 00 00    	je     802678 <__udivdi3+0x108>
  8025e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025e5:	89 f9                	mov    %edi,%ecx
  8025e7:	89 c5                	mov    %eax,%ebp
  8025e9:	29 fb                	sub    %edi,%ebx
  8025eb:	d3 e6                	shl    %cl,%esi
  8025ed:	89 d9                	mov    %ebx,%ecx
  8025ef:	d3 ed                	shr    %cl,%ebp
  8025f1:	89 f9                	mov    %edi,%ecx
  8025f3:	d3 e0                	shl    %cl,%eax
  8025f5:	09 ee                	or     %ebp,%esi
  8025f7:	89 d9                	mov    %ebx,%ecx
  8025f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025fd:	89 d5                	mov    %edx,%ebp
  8025ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802603:	d3 ed                	shr    %cl,%ebp
  802605:	89 f9                	mov    %edi,%ecx
  802607:	d3 e2                	shl    %cl,%edx
  802609:	89 d9                	mov    %ebx,%ecx
  80260b:	d3 e8                	shr    %cl,%eax
  80260d:	09 c2                	or     %eax,%edx
  80260f:	89 d0                	mov    %edx,%eax
  802611:	89 ea                	mov    %ebp,%edx
  802613:	f7 f6                	div    %esi
  802615:	89 d5                	mov    %edx,%ebp
  802617:	89 c3                	mov    %eax,%ebx
  802619:	f7 64 24 0c          	mull   0xc(%esp)
  80261d:	39 d5                	cmp    %edx,%ebp
  80261f:	72 10                	jb     802631 <__udivdi3+0xc1>
  802621:	8b 74 24 08          	mov    0x8(%esp),%esi
  802625:	89 f9                	mov    %edi,%ecx
  802627:	d3 e6                	shl    %cl,%esi
  802629:	39 c6                	cmp    %eax,%esi
  80262b:	73 07                	jae    802634 <__udivdi3+0xc4>
  80262d:	39 d5                	cmp    %edx,%ebp
  80262f:	75 03                	jne    802634 <__udivdi3+0xc4>
  802631:	83 eb 01             	sub    $0x1,%ebx
  802634:	31 ff                	xor    %edi,%edi
  802636:	89 d8                	mov    %ebx,%eax
  802638:	89 fa                	mov    %edi,%edx
  80263a:	83 c4 1c             	add    $0x1c,%esp
  80263d:	5b                   	pop    %ebx
  80263e:	5e                   	pop    %esi
  80263f:	5f                   	pop    %edi
  802640:	5d                   	pop    %ebp
  802641:	c3                   	ret    
  802642:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802648:	31 ff                	xor    %edi,%edi
  80264a:	31 db                	xor    %ebx,%ebx
  80264c:	89 d8                	mov    %ebx,%eax
  80264e:	89 fa                	mov    %edi,%edx
  802650:	83 c4 1c             	add    $0x1c,%esp
  802653:	5b                   	pop    %ebx
  802654:	5e                   	pop    %esi
  802655:	5f                   	pop    %edi
  802656:	5d                   	pop    %ebp
  802657:	c3                   	ret    
  802658:	90                   	nop
  802659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802660:	89 d8                	mov    %ebx,%eax
  802662:	f7 f7                	div    %edi
  802664:	31 ff                	xor    %edi,%edi
  802666:	89 c3                	mov    %eax,%ebx
  802668:	89 d8                	mov    %ebx,%eax
  80266a:	89 fa                	mov    %edi,%edx
  80266c:	83 c4 1c             	add    $0x1c,%esp
  80266f:	5b                   	pop    %ebx
  802670:	5e                   	pop    %esi
  802671:	5f                   	pop    %edi
  802672:	5d                   	pop    %ebp
  802673:	c3                   	ret    
  802674:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802678:	39 ce                	cmp    %ecx,%esi
  80267a:	72 0c                	jb     802688 <__udivdi3+0x118>
  80267c:	31 db                	xor    %ebx,%ebx
  80267e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802682:	0f 87 34 ff ff ff    	ja     8025bc <__udivdi3+0x4c>
  802688:	bb 01 00 00 00       	mov    $0x1,%ebx
  80268d:	e9 2a ff ff ff       	jmp    8025bc <__udivdi3+0x4c>
  802692:	66 90                	xchg   %ax,%ax
  802694:	66 90                	xchg   %ax,%ax
  802696:	66 90                	xchg   %ax,%ax
  802698:	66 90                	xchg   %ax,%ax
  80269a:	66 90                	xchg   %ax,%ax
  80269c:	66 90                	xchg   %ax,%ax
  80269e:	66 90                	xchg   %ax,%ax

008026a0 <__umoddi3>:
  8026a0:	55                   	push   %ebp
  8026a1:	57                   	push   %edi
  8026a2:	56                   	push   %esi
  8026a3:	53                   	push   %ebx
  8026a4:	83 ec 1c             	sub    $0x1c,%esp
  8026a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026b7:	85 d2                	test   %edx,%edx
  8026b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026c1:	89 f3                	mov    %esi,%ebx
  8026c3:	89 3c 24             	mov    %edi,(%esp)
  8026c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026ca:	75 1c                	jne    8026e8 <__umoddi3+0x48>
  8026cc:	39 f7                	cmp    %esi,%edi
  8026ce:	76 50                	jbe    802720 <__umoddi3+0x80>
  8026d0:	89 c8                	mov    %ecx,%eax
  8026d2:	89 f2                	mov    %esi,%edx
  8026d4:	f7 f7                	div    %edi
  8026d6:	89 d0                	mov    %edx,%eax
  8026d8:	31 d2                	xor    %edx,%edx
  8026da:	83 c4 1c             	add    $0x1c,%esp
  8026dd:	5b                   	pop    %ebx
  8026de:	5e                   	pop    %esi
  8026df:	5f                   	pop    %edi
  8026e0:	5d                   	pop    %ebp
  8026e1:	c3                   	ret    
  8026e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026e8:	39 f2                	cmp    %esi,%edx
  8026ea:	89 d0                	mov    %edx,%eax
  8026ec:	77 52                	ja     802740 <__umoddi3+0xa0>
  8026ee:	0f bd ea             	bsr    %edx,%ebp
  8026f1:	83 f5 1f             	xor    $0x1f,%ebp
  8026f4:	75 5a                	jne    802750 <__umoddi3+0xb0>
  8026f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026fa:	0f 82 e0 00 00 00    	jb     8027e0 <__umoddi3+0x140>
  802700:	39 0c 24             	cmp    %ecx,(%esp)
  802703:	0f 86 d7 00 00 00    	jbe    8027e0 <__umoddi3+0x140>
  802709:	8b 44 24 08          	mov    0x8(%esp),%eax
  80270d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802711:	83 c4 1c             	add    $0x1c,%esp
  802714:	5b                   	pop    %ebx
  802715:	5e                   	pop    %esi
  802716:	5f                   	pop    %edi
  802717:	5d                   	pop    %ebp
  802718:	c3                   	ret    
  802719:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802720:	85 ff                	test   %edi,%edi
  802722:	89 fd                	mov    %edi,%ebp
  802724:	75 0b                	jne    802731 <__umoddi3+0x91>
  802726:	b8 01 00 00 00       	mov    $0x1,%eax
  80272b:	31 d2                	xor    %edx,%edx
  80272d:	f7 f7                	div    %edi
  80272f:	89 c5                	mov    %eax,%ebp
  802731:	89 f0                	mov    %esi,%eax
  802733:	31 d2                	xor    %edx,%edx
  802735:	f7 f5                	div    %ebp
  802737:	89 c8                	mov    %ecx,%eax
  802739:	f7 f5                	div    %ebp
  80273b:	89 d0                	mov    %edx,%eax
  80273d:	eb 99                	jmp    8026d8 <__umoddi3+0x38>
  80273f:	90                   	nop
  802740:	89 c8                	mov    %ecx,%eax
  802742:	89 f2                	mov    %esi,%edx
  802744:	83 c4 1c             	add    $0x1c,%esp
  802747:	5b                   	pop    %ebx
  802748:	5e                   	pop    %esi
  802749:	5f                   	pop    %edi
  80274a:	5d                   	pop    %ebp
  80274b:	c3                   	ret    
  80274c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802750:	8b 34 24             	mov    (%esp),%esi
  802753:	bf 20 00 00 00       	mov    $0x20,%edi
  802758:	89 e9                	mov    %ebp,%ecx
  80275a:	29 ef                	sub    %ebp,%edi
  80275c:	d3 e0                	shl    %cl,%eax
  80275e:	89 f9                	mov    %edi,%ecx
  802760:	89 f2                	mov    %esi,%edx
  802762:	d3 ea                	shr    %cl,%edx
  802764:	89 e9                	mov    %ebp,%ecx
  802766:	09 c2                	or     %eax,%edx
  802768:	89 d8                	mov    %ebx,%eax
  80276a:	89 14 24             	mov    %edx,(%esp)
  80276d:	89 f2                	mov    %esi,%edx
  80276f:	d3 e2                	shl    %cl,%edx
  802771:	89 f9                	mov    %edi,%ecx
  802773:	89 54 24 04          	mov    %edx,0x4(%esp)
  802777:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80277b:	d3 e8                	shr    %cl,%eax
  80277d:	89 e9                	mov    %ebp,%ecx
  80277f:	89 c6                	mov    %eax,%esi
  802781:	d3 e3                	shl    %cl,%ebx
  802783:	89 f9                	mov    %edi,%ecx
  802785:	89 d0                	mov    %edx,%eax
  802787:	d3 e8                	shr    %cl,%eax
  802789:	89 e9                	mov    %ebp,%ecx
  80278b:	09 d8                	or     %ebx,%eax
  80278d:	89 d3                	mov    %edx,%ebx
  80278f:	89 f2                	mov    %esi,%edx
  802791:	f7 34 24             	divl   (%esp)
  802794:	89 d6                	mov    %edx,%esi
  802796:	d3 e3                	shl    %cl,%ebx
  802798:	f7 64 24 04          	mull   0x4(%esp)
  80279c:	39 d6                	cmp    %edx,%esi
  80279e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027a2:	89 d1                	mov    %edx,%ecx
  8027a4:	89 c3                	mov    %eax,%ebx
  8027a6:	72 08                	jb     8027b0 <__umoddi3+0x110>
  8027a8:	75 11                	jne    8027bb <__umoddi3+0x11b>
  8027aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027ae:	73 0b                	jae    8027bb <__umoddi3+0x11b>
  8027b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027b4:	1b 14 24             	sbb    (%esp),%edx
  8027b7:	89 d1                	mov    %edx,%ecx
  8027b9:	89 c3                	mov    %eax,%ebx
  8027bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027bf:	29 da                	sub    %ebx,%edx
  8027c1:	19 ce                	sbb    %ecx,%esi
  8027c3:	89 f9                	mov    %edi,%ecx
  8027c5:	89 f0                	mov    %esi,%eax
  8027c7:	d3 e0                	shl    %cl,%eax
  8027c9:	89 e9                	mov    %ebp,%ecx
  8027cb:	d3 ea                	shr    %cl,%edx
  8027cd:	89 e9                	mov    %ebp,%ecx
  8027cf:	d3 ee                	shr    %cl,%esi
  8027d1:	09 d0                	or     %edx,%eax
  8027d3:	89 f2                	mov    %esi,%edx
  8027d5:	83 c4 1c             	add    $0x1c,%esp
  8027d8:	5b                   	pop    %ebx
  8027d9:	5e                   	pop    %esi
  8027da:	5f                   	pop    %edi
  8027db:	5d                   	pop    %ebp
  8027dc:	c3                   	ret    
  8027dd:	8d 76 00             	lea    0x0(%esi),%esi
  8027e0:	29 f9                	sub    %edi,%ecx
  8027e2:	19 d6                	sbb    %edx,%esi
  8027e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027ec:	e9 18 ff ff ff       	jmp    802709 <__umoddi3+0x69>
