
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
  800042:	e8 e7 0c 00 00       	call   800d2e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 9d 13 00 00       	call   8013f6 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 2c 13 00 00       	call   801394 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 a9 12 00 00       	call   801322 <ipc_recv>
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
  80008f:	b8 00 24 80 00       	mov    $0x802400,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 0b 24 80 00       	push   $0x80240b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 25 24 80 00       	push   $0x802425
  8000b4:	e8 17 06 00 00       	call   8006d0 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 c0 25 80 00       	push   $0x8025c0
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 25 24 80 00       	push   $0x802425
  8000cc:	e8 ff 05 00 00       	call   8006d0 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 35 24 80 00       	mov    $0x802435,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 3e 24 80 00       	push   $0x80243e
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 25 24 80 00       	push   $0x802425
  8000f1:	e8 da 05 00 00       	call   8006d0 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 e4 25 80 00       	push   $0x8025e4
  800119:	6a 27                	push   $0x27
  80011b:	68 25 24 80 00       	push   $0x802425
  800120:	e8 ab 05 00 00       	call   8006d0 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 56 24 80 00       	push   $0x802456
  80012d:	e8 77 06 00 00       	call   8007a9 <cprintf>

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
  80014f:	68 6a 24 80 00       	push   $0x80246a
  800154:	6a 2b                	push   $0x2b
  800156:	68 25 24 80 00       	push   $0x802425
  80015b:	e8 70 05 00 00       	call   8006d0 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 30 80 00    	pushl  0x803000
  800169:	e8 87 0b 00 00       	call   800cf5 <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 30 80 00    	pushl  0x803000
  80017f:	e8 71 0b 00 00       	call   800cf5 <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 14 26 80 00       	push   $0x802614
  80018f:	6a 2d                	push   $0x2d
  800191:	68 25 24 80 00       	push   $0x802425
  800196:	e8 35 05 00 00       	call   8006d0 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 78 24 80 00       	push   $0x802478
  8001a3:	e8 01 06 00 00       	call   8007a9 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 b5 0c 00 00       	call   800e73 <memset>
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
  8001da:	68 8b 24 80 00       	push   $0x80248b
  8001df:	6a 32                	push   $0x32
  8001e1:	68 25 24 80 00       	push   $0x802425
  8001e6:	e8 e5 04 00 00       	call   8006d0 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 30 80 00    	pushl  0x803000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 d8 0b 00 00       	call   800dd8 <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 99 24 80 00       	push   $0x802499
  80020f:	6a 34                	push   $0x34
  800211:	68 25 24 80 00       	push   $0x802425
  800216:	e8 b5 04 00 00       	call   8006d0 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 b7 24 80 00       	push   $0x8024b7
  800223:	e8 81 05 00 00       	call   8007a9 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 30 80 00    	call   *0x803018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 ca 24 80 00       	push   $0x8024ca
  800242:	6a 38                	push   $0x38
  800244:	68 25 24 80 00       	push   $0x802425
  800249:	e8 82 04 00 00       	call   8006d0 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 d9 24 80 00       	push   $0x8024d9
  800256:	e8 4e 05 00 00       	call   8007a9 <cprintf>

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
  800285:	e8 2c 0f 00 00       	call   8011b6 <sys_page_unmap>

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
  8002ac:	68 3c 26 80 00       	push   $0x80263c
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 25 24 80 00       	push   $0x802425
  8002b8:	e8 13 04 00 00       	call   8006d0 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 ed 24 80 00       	push   $0x8024ed
  8002c5:	e8 df 04 00 00       	call   8007a9 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 03 25 80 00       	mov    $0x802503,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 0d 25 80 00       	push   $0x80250d
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 25 24 80 00       	push   $0x802425
  8002ed:	e8 de 03 00 00       	call   8006d0 <_panic>
	//////////////////////////BUG NO 1///////////////////////////////
	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 30 80 00    	pushl  0x803000
  800301:	e8 ef 09 00 00       	call   800cf5 <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 30 80 00    	pushl  0x803000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 30 80 00    	pushl  0x803000
  800322:	e8 ce 09 00 00       	call   800cf5 <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 26 25 80 00       	push   $0x802526
  800334:	6a 4b                	push   $0x4b
  800336:	68 25 24 80 00       	push   $0x802425
  80033b:	e8 90 03 00 00       	call   8006d0 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 35 25 80 00       	push   $0x802535
  800348:	e8 5c 04 00 00       	call   8007a9 <cprintf>
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
  800368:	e8 06 0b 00 00       	call   800e73 <memset>
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
  80038b:	68 74 26 80 00       	push   $0x802674
  800390:	6a 51                	push   $0x51
  800392:	68 25 24 80 00       	push   $0x802425
  800397:	e8 34 03 00 00       	call   8006d0 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 30 80 00    	pushl  0x803000
  8003a5:	e8 4b 09 00 00       	call   800cf5 <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 94 26 80 00       	push   $0x802694
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 25 24 80 00       	push   $0x802425
  8003be:	e8 0d 03 00 00       	call   8006d0 <_panic>
	if (strcmp(buf, msg) != 0) 
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 30 80 00    	pushl  0x803000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 00 0a 00 00       	call   800dd8 <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 cc 26 80 00       	push   $0x8026cc
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 25 24 80 00       	push   $0x802425
  8003ee:	e8 dd 02 00 00       	call   8006d0 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 fc 26 80 00       	push   $0x8026fc
  8003fb:	e8 a9 03 00 00       	call   8007a9 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 00 24 80 00       	push   $0x802400
  80040a:	e8 87 17 00 00       	call   801b96 <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 11 24 80 00       	push   $0x802411
  800426:	6a 5a                	push   $0x5a
  800428:	68 25 24 80 00       	push   $0x802425
  80042d:	e8 9e 02 00 00       	call   8006d0 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 49 25 80 00       	push   $0x802549
  80043e:	6a 5c                	push   $0x5c
  800440:	68 25 24 80 00       	push   $0x802425
  800445:	e8 86 02 00 00       	call   8006d0 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 35 24 80 00       	push   $0x802435
  800454:	e8 3d 17 00 00       	call   801b96 <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 44 24 80 00       	push   $0x802444
  800466:	6a 5f                	push   $0x5f
  800468:	68 25 24 80 00       	push   $0x802425
  80046d:	e8 5e 02 00 00       	call   8006d0 <_panic>
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
  800493:	68 20 27 80 00       	push   $0x802720
  800498:	6a 62                	push   $0x62
  80049a:	68 25 24 80 00       	push   $0x802425
  80049f:	e8 2c 02 00 00       	call   8006d0 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 5c 24 80 00       	push   $0x80245c
  8004ac:	e8 f8 02 00 00       	call   8007a9 <cprintf>
//////////////////////////BUG NO 2///////////////////////////////
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 64 25 80 00       	push   $0x802564
  8004be:	e8 d3 16 00 00       	call   801b96 <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 69 25 80 00       	push   $0x802569
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 25 24 80 00       	push   $0x802425
  8004d9:	e8 f2 01 00 00       	call   8006d0 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 7f 09 00 00       	call   800e73 <memset>
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
  800512:	e8 ce 12 00 00       	call   8017e5 <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 78 25 80 00       	push   $0x802578
  800528:	6a 6c                	push   $0x6c
  80052a:	68 25 24 80 00       	push   $0x802425
  80052f:	e8 9c 01 00 00       	call   8006d0 <_panic>
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
  800547:	e8 83 10 00 00       	call   8015cf <close>
	
	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 64 25 80 00       	push   $0x802564
  800556:	e8 3b 16 00 00       	call   801b96 <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 8a 25 80 00       	push   $0x80258a
  80056a:	6a 71                	push   $0x71
  80056c:	68 25 24 80 00       	push   $0x802425
  800571:	e8 5a 01 00 00       	call   8006d0 <_panic>
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
  800591:	e8 06 12 00 00       	call   80179c <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 98 25 80 00       	push   $0x802598
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 25 24 80 00       	push   $0x802425
  8005ae:	e8 1d 01 00 00       	call   8006d0 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 48 27 80 00       	push   $0x802748
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 25 24 80 00       	push   $0x802425
  8005d0:	e8 fb 00 00 00       	call   8006d0 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 74 27 80 00       	push   $0x802774
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 25 24 80 00       	push   $0x802425
  8005f0:	e8 db 00 00 00       	call   8006d0 <_panic>
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
  80060c:	e8 be 0f 00 00       	call   8015cf <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 a9 25 80 00 	movl   $0x8025a9,(%esp)
  800618:	e8 8c 01 00 00       	call   8007a9 <cprintf>
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
  80063b:	e8 b3 0a 00 00       	call   8010f3 <sys_getenvid>
  800640:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800646:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80064b:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800650:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800655:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800658:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  80065e:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800661:	39 c8                	cmp    %ecx,%eax
  800663:	0f 44 fb             	cmove  %ebx,%edi
  800666:	b9 01 00 00 00       	mov    $0x1,%ecx
  80066b:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  80066e:	83 c2 01             	add    $0x1,%edx
  800671:	83 c3 7c             	add    $0x7c,%ebx
  800674:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80067a:	75 d9                	jne    800655 <libmain+0x2d>
  80067c:	89 f0                	mov    %esi,%eax
  80067e:	84 c0                	test   %al,%al
  800680:	74 06                	je     800688 <libmain+0x60>
  800682:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800688:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80068c:	7e 0a                	jle    800698 <libmain+0x70>
		binaryname = argv[0];
  80068e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800691:	8b 00                	mov    (%eax),%eax
  800693:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	ff 75 0c             	pushl  0xc(%ebp)
  80069e:	ff 75 08             	pushl  0x8(%ebp)
  8006a1:	e8 d8 f9 ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  8006a6:	e8 0b 00 00 00       	call   8006b6 <exit>
}
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b1:	5b                   	pop    %ebx
  8006b2:	5e                   	pop    %esi
  8006b3:	5f                   	pop    %edi
  8006b4:	5d                   	pop    %ebp
  8006b5:	c3                   	ret    

008006b6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8006b6:	55                   	push   %ebp
  8006b7:	89 e5                	mov    %esp,%ebp
  8006b9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8006bc:	e8 39 0f 00 00       	call   8015fa <close_all>
	sys_env_destroy(0);
  8006c1:	83 ec 0c             	sub    $0xc,%esp
  8006c4:	6a 00                	push   $0x0
  8006c6:	e8 e7 09 00 00       	call   8010b2 <sys_env_destroy>
}
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	56                   	push   %esi
  8006d4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8006d5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8006d8:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8006de:	e8 10 0a 00 00       	call   8010f3 <sys_getenvid>
  8006e3:	83 ec 0c             	sub    $0xc,%esp
  8006e6:	ff 75 0c             	pushl  0xc(%ebp)
  8006e9:	ff 75 08             	pushl  0x8(%ebp)
  8006ec:	56                   	push   %esi
  8006ed:	50                   	push   %eax
  8006ee:	68 cc 27 80 00       	push   $0x8027cc
  8006f3:	e8 b1 00 00 00       	call   8007a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006f8:	83 c4 18             	add    $0x18,%esp
  8006fb:	53                   	push   %ebx
  8006fc:	ff 75 10             	pushl  0x10(%ebp)
  8006ff:	e8 54 00 00 00       	call   800758 <vcprintf>
	cprintf("\n");
  800704:	c7 04 24 1f 2c 80 00 	movl   $0x802c1f,(%esp)
  80070b:	e8 99 00 00 00       	call   8007a9 <cprintf>
  800710:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800713:	cc                   	int3   
  800714:	eb fd                	jmp    800713 <_panic+0x43>

00800716 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	53                   	push   %ebx
  80071a:	83 ec 04             	sub    $0x4,%esp
  80071d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800720:	8b 13                	mov    (%ebx),%edx
  800722:	8d 42 01             	lea    0x1(%edx),%eax
  800725:	89 03                	mov    %eax,(%ebx)
  800727:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80072e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800733:	75 1a                	jne    80074f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	68 ff 00 00 00       	push   $0xff
  80073d:	8d 43 08             	lea    0x8(%ebx),%eax
  800740:	50                   	push   %eax
  800741:	e8 2f 09 00 00       	call   801075 <sys_cputs>
		b->idx = 0;
  800746:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80074c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80074f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800761:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800768:	00 00 00 
	b.cnt = 0;
  80076b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800772:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800775:	ff 75 0c             	pushl  0xc(%ebp)
  800778:	ff 75 08             	pushl  0x8(%ebp)
  80077b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800781:	50                   	push   %eax
  800782:	68 16 07 80 00       	push   $0x800716
  800787:	e8 54 01 00 00       	call   8008e0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80078c:	83 c4 08             	add    $0x8,%esp
  80078f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800795:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80079b:	50                   	push   %eax
  80079c:	e8 d4 08 00 00       	call   801075 <sys_cputs>

	return b.cnt;
}
  8007a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8007a7:	c9                   	leave  
  8007a8:	c3                   	ret    

008007a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8007af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8007b2:	50                   	push   %eax
  8007b3:	ff 75 08             	pushl  0x8(%ebp)
  8007b6:	e8 9d ff ff ff       	call   800758 <vcprintf>
	va_end(ap);

	return cnt;
}
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    

008007bd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	57                   	push   %edi
  8007c1:	56                   	push   %esi
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 1c             	sub    $0x1c,%esp
  8007c6:	89 c7                	mov    %eax,%edi
  8007c8:	89 d6                	mov    %edx,%esi
  8007ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8007e1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8007e4:	39 d3                	cmp    %edx,%ebx
  8007e6:	72 05                	jb     8007ed <printnum+0x30>
  8007e8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007eb:	77 45                	ja     800832 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007ed:	83 ec 0c             	sub    $0xc,%esp
  8007f0:	ff 75 18             	pushl  0x18(%ebp)
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007f9:	53                   	push   %ebx
  8007fa:	ff 75 10             	pushl  0x10(%ebp)
  8007fd:	83 ec 08             	sub    $0x8,%esp
  800800:	ff 75 e4             	pushl  -0x1c(%ebp)
  800803:	ff 75 e0             	pushl  -0x20(%ebp)
  800806:	ff 75 dc             	pushl  -0x24(%ebp)
  800809:	ff 75 d8             	pushl  -0x28(%ebp)
  80080c:	e8 4f 19 00 00       	call   802160 <__udivdi3>
  800811:	83 c4 18             	add    $0x18,%esp
  800814:	52                   	push   %edx
  800815:	50                   	push   %eax
  800816:	89 f2                	mov    %esi,%edx
  800818:	89 f8                	mov    %edi,%eax
  80081a:	e8 9e ff ff ff       	call   8007bd <printnum>
  80081f:	83 c4 20             	add    $0x20,%esp
  800822:	eb 18                	jmp    80083c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800824:	83 ec 08             	sub    $0x8,%esp
  800827:	56                   	push   %esi
  800828:	ff 75 18             	pushl  0x18(%ebp)
  80082b:	ff d7                	call   *%edi
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	eb 03                	jmp    800835 <printnum+0x78>
  800832:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800835:	83 eb 01             	sub    $0x1,%ebx
  800838:	85 db                	test   %ebx,%ebx
  80083a:	7f e8                	jg     800824 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	56                   	push   %esi
  800840:	83 ec 04             	sub    $0x4,%esp
  800843:	ff 75 e4             	pushl  -0x1c(%ebp)
  800846:	ff 75 e0             	pushl  -0x20(%ebp)
  800849:	ff 75 dc             	pushl  -0x24(%ebp)
  80084c:	ff 75 d8             	pushl  -0x28(%ebp)
  80084f:	e8 3c 1a 00 00       	call   802290 <__umoddi3>
  800854:	83 c4 14             	add    $0x14,%esp
  800857:	0f be 80 ef 27 80 00 	movsbl 0x8027ef(%eax),%eax
  80085e:	50                   	push   %eax
  80085f:	ff d7                	call   *%edi
}
  800861:	83 c4 10             	add    $0x10,%esp
  800864:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800867:	5b                   	pop    %ebx
  800868:	5e                   	pop    %esi
  800869:	5f                   	pop    %edi
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80086f:	83 fa 01             	cmp    $0x1,%edx
  800872:	7e 0e                	jle    800882 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800874:	8b 10                	mov    (%eax),%edx
  800876:	8d 4a 08             	lea    0x8(%edx),%ecx
  800879:	89 08                	mov    %ecx,(%eax)
  80087b:	8b 02                	mov    (%edx),%eax
  80087d:	8b 52 04             	mov    0x4(%edx),%edx
  800880:	eb 22                	jmp    8008a4 <getuint+0x38>
	else if (lflag)
  800882:	85 d2                	test   %edx,%edx
  800884:	74 10                	je     800896 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800886:	8b 10                	mov    (%eax),%edx
  800888:	8d 4a 04             	lea    0x4(%edx),%ecx
  80088b:	89 08                	mov    %ecx,(%eax)
  80088d:	8b 02                	mov    (%edx),%eax
  80088f:	ba 00 00 00 00       	mov    $0x0,%edx
  800894:	eb 0e                	jmp    8008a4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800896:	8b 10                	mov    (%eax),%edx
  800898:	8d 4a 04             	lea    0x4(%edx),%ecx
  80089b:	89 08                	mov    %ecx,(%eax)
  80089d:	8b 02                	mov    (%edx),%eax
  80089f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8008ac:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8008b0:	8b 10                	mov    (%eax),%edx
  8008b2:	3b 50 04             	cmp    0x4(%eax),%edx
  8008b5:	73 0a                	jae    8008c1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8008b7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008ba:	89 08                	mov    %ecx,(%eax)
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	88 02                	mov    %al,(%edx)
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8008c9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8008cc:	50                   	push   %eax
  8008cd:	ff 75 10             	pushl  0x10(%ebp)
  8008d0:	ff 75 0c             	pushl  0xc(%ebp)
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 05 00 00 00       	call   8008e0 <vprintfmt>
	va_end(ap);
}
  8008db:	83 c4 10             	add    $0x10,%esp
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	57                   	push   %edi
  8008e4:	56                   	push   %esi
  8008e5:	53                   	push   %ebx
  8008e6:	83 ec 2c             	sub    $0x2c,%esp
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ef:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008f2:	eb 12                	jmp    800906 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008f4:	85 c0                	test   %eax,%eax
  8008f6:	0f 84 89 03 00 00    	je     800c85 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	53                   	push   %ebx
  800900:	50                   	push   %eax
  800901:	ff d6                	call   *%esi
  800903:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800906:	83 c7 01             	add    $0x1,%edi
  800909:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80090d:	83 f8 25             	cmp    $0x25,%eax
  800910:	75 e2                	jne    8008f4 <vprintfmt+0x14>
  800912:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800916:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80091d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800924:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80092b:	ba 00 00 00 00       	mov    $0x0,%edx
  800930:	eb 07                	jmp    800939 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800932:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800935:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800939:	8d 47 01             	lea    0x1(%edi),%eax
  80093c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80093f:	0f b6 07             	movzbl (%edi),%eax
  800942:	0f b6 c8             	movzbl %al,%ecx
  800945:	83 e8 23             	sub    $0x23,%eax
  800948:	3c 55                	cmp    $0x55,%al
  80094a:	0f 87 1a 03 00 00    	ja     800c6a <vprintfmt+0x38a>
  800950:	0f b6 c0             	movzbl %al,%eax
  800953:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
  80095a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80095d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800961:	eb d6                	jmp    800939 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800963:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800966:	b8 00 00 00 00       	mov    $0x0,%eax
  80096b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80096e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800971:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800975:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800978:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80097b:	83 fa 09             	cmp    $0x9,%edx
  80097e:	77 39                	ja     8009b9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800980:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800983:	eb e9                	jmp    80096e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800985:	8b 45 14             	mov    0x14(%ebp),%eax
  800988:	8d 48 04             	lea    0x4(%eax),%ecx
  80098b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80098e:	8b 00                	mov    (%eax),%eax
  800990:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800993:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800996:	eb 27                	jmp    8009bf <vprintfmt+0xdf>
  800998:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80099b:	85 c0                	test   %eax,%eax
  80099d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009a2:	0f 49 c8             	cmovns %eax,%ecx
  8009a5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009ab:	eb 8c                	jmp    800939 <vprintfmt+0x59>
  8009ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8009b0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8009b7:	eb 80                	jmp    800939 <vprintfmt+0x59>
  8009b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009bc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8009bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009c3:	0f 89 70 ff ff ff    	jns    800939 <vprintfmt+0x59>
				width = precision, precision = -1;
  8009c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009cf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009d6:	e9 5e ff ff ff       	jmp    800939 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009db:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8009e1:	e9 53 ff ff ff       	jmp    800939 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e9:	8d 50 04             	lea    0x4(%eax),%edx
  8009ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ef:	83 ec 08             	sub    $0x8,%esp
  8009f2:	53                   	push   %ebx
  8009f3:	ff 30                	pushl  (%eax)
  8009f5:	ff d6                	call   *%esi
			break;
  8009f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009fd:	e9 04 ff ff ff       	jmp    800906 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800a02:	8b 45 14             	mov    0x14(%ebp),%eax
  800a05:	8d 50 04             	lea    0x4(%eax),%edx
  800a08:	89 55 14             	mov    %edx,0x14(%ebp)
  800a0b:	8b 00                	mov    (%eax),%eax
  800a0d:	99                   	cltd   
  800a0e:	31 d0                	xor    %edx,%eax
  800a10:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a12:	83 f8 0f             	cmp    $0xf,%eax
  800a15:	7f 0b                	jg     800a22 <vprintfmt+0x142>
  800a17:	8b 14 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%edx
  800a1e:	85 d2                	test   %edx,%edx
  800a20:	75 18                	jne    800a3a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800a22:	50                   	push   %eax
  800a23:	68 07 28 80 00       	push   $0x802807
  800a28:	53                   	push   %ebx
  800a29:	56                   	push   %esi
  800a2a:	e8 94 fe ff ff       	call   8008c3 <printfmt>
  800a2f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a32:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800a35:	e9 cc fe ff ff       	jmp    800906 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800a3a:	52                   	push   %edx
  800a3b:	68 ed 2b 80 00       	push   $0x802bed
  800a40:	53                   	push   %ebx
  800a41:	56                   	push   %esi
  800a42:	e8 7c fe ff ff       	call   8008c3 <printfmt>
  800a47:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a4d:	e9 b4 fe ff ff       	jmp    800906 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a52:	8b 45 14             	mov    0x14(%ebp),%eax
  800a55:	8d 50 04             	lea    0x4(%eax),%edx
  800a58:	89 55 14             	mov    %edx,0x14(%ebp)
  800a5b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a5d:	85 ff                	test   %edi,%edi
  800a5f:	b8 00 28 80 00       	mov    $0x802800,%eax
  800a64:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a67:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a6b:	0f 8e 94 00 00 00    	jle    800b05 <vprintfmt+0x225>
  800a71:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a75:	0f 84 98 00 00 00    	je     800b13 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a7b:	83 ec 08             	sub    $0x8,%esp
  800a7e:	ff 75 d0             	pushl  -0x30(%ebp)
  800a81:	57                   	push   %edi
  800a82:	e8 86 02 00 00       	call   800d0d <strnlen>
  800a87:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a8a:	29 c1                	sub    %eax,%ecx
  800a8c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a8f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a92:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a96:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a99:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a9c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a9e:	eb 0f                	jmp    800aaf <vprintfmt+0x1cf>
					putch(padc, putdat);
  800aa0:	83 ec 08             	sub    $0x8,%esp
  800aa3:	53                   	push   %ebx
  800aa4:	ff 75 e0             	pushl  -0x20(%ebp)
  800aa7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800aa9:	83 ef 01             	sub    $0x1,%edi
  800aac:	83 c4 10             	add    $0x10,%esp
  800aaf:	85 ff                	test   %edi,%edi
  800ab1:	7f ed                	jg     800aa0 <vprintfmt+0x1c0>
  800ab3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800ab6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800ab9:	85 c9                	test   %ecx,%ecx
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac0:	0f 49 c1             	cmovns %ecx,%eax
  800ac3:	29 c1                	sub    %eax,%ecx
  800ac5:	89 75 08             	mov    %esi,0x8(%ebp)
  800ac8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800acb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ace:	89 cb                	mov    %ecx,%ebx
  800ad0:	eb 4d                	jmp    800b1f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800ad2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ad6:	74 1b                	je     800af3 <vprintfmt+0x213>
  800ad8:	0f be c0             	movsbl %al,%eax
  800adb:	83 e8 20             	sub    $0x20,%eax
  800ade:	83 f8 5e             	cmp    $0x5e,%eax
  800ae1:	76 10                	jbe    800af3 <vprintfmt+0x213>
					putch('?', putdat);
  800ae3:	83 ec 08             	sub    $0x8,%esp
  800ae6:	ff 75 0c             	pushl  0xc(%ebp)
  800ae9:	6a 3f                	push   $0x3f
  800aeb:	ff 55 08             	call   *0x8(%ebp)
  800aee:	83 c4 10             	add    $0x10,%esp
  800af1:	eb 0d                	jmp    800b00 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800af3:	83 ec 08             	sub    $0x8,%esp
  800af6:	ff 75 0c             	pushl  0xc(%ebp)
  800af9:	52                   	push   %edx
  800afa:	ff 55 08             	call   *0x8(%ebp)
  800afd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b00:	83 eb 01             	sub    $0x1,%ebx
  800b03:	eb 1a                	jmp    800b1f <vprintfmt+0x23f>
  800b05:	89 75 08             	mov    %esi,0x8(%ebp)
  800b08:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800b0b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800b0e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800b11:	eb 0c                	jmp    800b1f <vprintfmt+0x23f>
  800b13:	89 75 08             	mov    %esi,0x8(%ebp)
  800b16:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800b19:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800b1c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800b1f:	83 c7 01             	add    $0x1,%edi
  800b22:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800b26:	0f be d0             	movsbl %al,%edx
  800b29:	85 d2                	test   %edx,%edx
  800b2b:	74 23                	je     800b50 <vprintfmt+0x270>
  800b2d:	85 f6                	test   %esi,%esi
  800b2f:	78 a1                	js     800ad2 <vprintfmt+0x1f2>
  800b31:	83 ee 01             	sub    $0x1,%esi
  800b34:	79 9c                	jns    800ad2 <vprintfmt+0x1f2>
  800b36:	89 df                	mov    %ebx,%edi
  800b38:	8b 75 08             	mov    0x8(%ebp),%esi
  800b3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b3e:	eb 18                	jmp    800b58 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b40:	83 ec 08             	sub    $0x8,%esp
  800b43:	53                   	push   %ebx
  800b44:	6a 20                	push   $0x20
  800b46:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b48:	83 ef 01             	sub    $0x1,%edi
  800b4b:	83 c4 10             	add    $0x10,%esp
  800b4e:	eb 08                	jmp    800b58 <vprintfmt+0x278>
  800b50:	89 df                	mov    %ebx,%edi
  800b52:	8b 75 08             	mov    0x8(%ebp),%esi
  800b55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b58:	85 ff                	test   %edi,%edi
  800b5a:	7f e4                	jg     800b40 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b5f:	e9 a2 fd ff ff       	jmp    800906 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b64:	83 fa 01             	cmp    $0x1,%edx
  800b67:	7e 16                	jle    800b7f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800b69:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6c:	8d 50 08             	lea    0x8(%eax),%edx
  800b6f:	89 55 14             	mov    %edx,0x14(%ebp)
  800b72:	8b 50 04             	mov    0x4(%eax),%edx
  800b75:	8b 00                	mov    (%eax),%eax
  800b77:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b7a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b7d:	eb 32                	jmp    800bb1 <vprintfmt+0x2d1>
	else if (lflag)
  800b7f:	85 d2                	test   %edx,%edx
  800b81:	74 18                	je     800b9b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800b83:	8b 45 14             	mov    0x14(%ebp),%eax
  800b86:	8d 50 04             	lea    0x4(%eax),%edx
  800b89:	89 55 14             	mov    %edx,0x14(%ebp)
  800b8c:	8b 00                	mov    (%eax),%eax
  800b8e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b91:	89 c1                	mov    %eax,%ecx
  800b93:	c1 f9 1f             	sar    $0x1f,%ecx
  800b96:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b99:	eb 16                	jmp    800bb1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800b9b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b9e:	8d 50 04             	lea    0x4(%eax),%edx
  800ba1:	89 55 14             	mov    %edx,0x14(%ebp)
  800ba4:	8b 00                	mov    (%eax),%eax
  800ba6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ba9:	89 c1                	mov    %eax,%ecx
  800bab:	c1 f9 1f             	sar    $0x1f,%ecx
  800bae:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800bb1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800bb4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800bb7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800bbc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800bc0:	79 74                	jns    800c36 <vprintfmt+0x356>
				putch('-', putdat);
  800bc2:	83 ec 08             	sub    $0x8,%esp
  800bc5:	53                   	push   %ebx
  800bc6:	6a 2d                	push   $0x2d
  800bc8:	ff d6                	call   *%esi
				num = -(long long) num;
  800bca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800bcd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800bd0:	f7 d8                	neg    %eax
  800bd2:	83 d2 00             	adc    $0x0,%edx
  800bd5:	f7 da                	neg    %edx
  800bd7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800bda:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bdf:	eb 55                	jmp    800c36 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800be1:	8d 45 14             	lea    0x14(%ebp),%eax
  800be4:	e8 83 fc ff ff       	call   80086c <getuint>
			base = 10;
  800be9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800bee:	eb 46                	jmp    800c36 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800bf0:	8d 45 14             	lea    0x14(%ebp),%eax
  800bf3:	e8 74 fc ff ff       	call   80086c <getuint>
			base = 8;
  800bf8:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800bfd:	eb 37                	jmp    800c36 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800bff:	83 ec 08             	sub    $0x8,%esp
  800c02:	53                   	push   %ebx
  800c03:	6a 30                	push   $0x30
  800c05:	ff d6                	call   *%esi
			putch('x', putdat);
  800c07:	83 c4 08             	add    $0x8,%esp
  800c0a:	53                   	push   %ebx
  800c0b:	6a 78                	push   $0x78
  800c0d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c0f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c12:	8d 50 04             	lea    0x4(%eax),%edx
  800c15:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800c18:	8b 00                	mov    (%eax),%eax
  800c1a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c1f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800c22:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800c27:	eb 0d                	jmp    800c36 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c29:	8d 45 14             	lea    0x14(%ebp),%eax
  800c2c:	e8 3b fc ff ff       	call   80086c <getuint>
			base = 16;
  800c31:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800c3d:	57                   	push   %edi
  800c3e:	ff 75 e0             	pushl  -0x20(%ebp)
  800c41:	51                   	push   %ecx
  800c42:	52                   	push   %edx
  800c43:	50                   	push   %eax
  800c44:	89 da                	mov    %ebx,%edx
  800c46:	89 f0                	mov    %esi,%eax
  800c48:	e8 70 fb ff ff       	call   8007bd <printnum>
			break;
  800c4d:	83 c4 20             	add    $0x20,%esp
  800c50:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c53:	e9 ae fc ff ff       	jmp    800906 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c58:	83 ec 08             	sub    $0x8,%esp
  800c5b:	53                   	push   %ebx
  800c5c:	51                   	push   %ecx
  800c5d:	ff d6                	call   *%esi
			break;
  800c5f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c65:	e9 9c fc ff ff       	jmp    800906 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c6a:	83 ec 08             	sub    $0x8,%esp
  800c6d:	53                   	push   %ebx
  800c6e:	6a 25                	push   $0x25
  800c70:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c72:	83 c4 10             	add    $0x10,%esp
  800c75:	eb 03                	jmp    800c7a <vprintfmt+0x39a>
  800c77:	83 ef 01             	sub    $0x1,%edi
  800c7a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c7e:	75 f7                	jne    800c77 <vprintfmt+0x397>
  800c80:	e9 81 fc ff ff       	jmp    800906 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	83 ec 18             	sub    $0x18,%esp
  800c93:	8b 45 08             	mov    0x8(%ebp),%eax
  800c96:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c99:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c9c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ca0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ca3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800caa:	85 c0                	test   %eax,%eax
  800cac:	74 26                	je     800cd4 <vsnprintf+0x47>
  800cae:	85 d2                	test   %edx,%edx
  800cb0:	7e 22                	jle    800cd4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cb2:	ff 75 14             	pushl  0x14(%ebp)
  800cb5:	ff 75 10             	pushl  0x10(%ebp)
  800cb8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cbb:	50                   	push   %eax
  800cbc:	68 a6 08 80 00       	push   $0x8008a6
  800cc1:	e8 1a fc ff ff       	call   8008e0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cc9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ccf:	83 c4 10             	add    $0x10,%esp
  800cd2:	eb 05                	jmp    800cd9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cd4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cd9:	c9                   	leave  
  800cda:	c3                   	ret    

00800cdb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ce1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ce4:	50                   	push   %eax
  800ce5:	ff 75 10             	pushl  0x10(%ebp)
  800ce8:	ff 75 0c             	pushl  0xc(%ebp)
  800ceb:	ff 75 08             	pushl  0x8(%ebp)
  800cee:	e8 9a ff ff ff       	call   800c8d <vsnprintf>
	va_end(ap);

	return rc;
}
  800cf3:	c9                   	leave  
  800cf4:	c3                   	ret    

00800cf5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cfb:	b8 00 00 00 00       	mov    $0x0,%eax
  800d00:	eb 03                	jmp    800d05 <strlen+0x10>
		n++;
  800d02:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d05:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d09:	75 f7                	jne    800d02 <strlen+0xd>
		n++;
	return n;
}
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d13:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d16:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1b:	eb 03                	jmp    800d20 <strnlen+0x13>
		n++;
  800d1d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d20:	39 c2                	cmp    %eax,%edx
  800d22:	74 08                	je     800d2c <strnlen+0x1f>
  800d24:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800d28:	75 f3                	jne    800d1d <strnlen+0x10>
  800d2a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	53                   	push   %ebx
  800d32:	8b 45 08             	mov    0x8(%ebp),%eax
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d38:	89 c2                	mov    %eax,%edx
  800d3a:	83 c2 01             	add    $0x1,%edx
  800d3d:	83 c1 01             	add    $0x1,%ecx
  800d40:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d44:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d47:	84 db                	test   %bl,%bl
  800d49:	75 ef                	jne    800d3a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d4b:	5b                   	pop    %ebx
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	53                   	push   %ebx
  800d52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d55:	53                   	push   %ebx
  800d56:	e8 9a ff ff ff       	call   800cf5 <strlen>
  800d5b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d5e:	ff 75 0c             	pushl  0xc(%ebp)
  800d61:	01 d8                	add    %ebx,%eax
  800d63:	50                   	push   %eax
  800d64:	e8 c5 ff ff ff       	call   800d2e <strcpy>
	return dst;
}
  800d69:	89 d8                	mov    %ebx,%eax
  800d6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d6e:	c9                   	leave  
  800d6f:	c3                   	ret    

00800d70 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	8b 75 08             	mov    0x8(%ebp),%esi
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	89 f3                	mov    %esi,%ebx
  800d7d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d80:	89 f2                	mov    %esi,%edx
  800d82:	eb 0f                	jmp    800d93 <strncpy+0x23>
		*dst++ = *src;
  800d84:	83 c2 01             	add    $0x1,%edx
  800d87:	0f b6 01             	movzbl (%ecx),%eax
  800d8a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d8d:	80 39 01             	cmpb   $0x1,(%ecx)
  800d90:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d93:	39 da                	cmp    %ebx,%edx
  800d95:	75 ed                	jne    800d84 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d97:	89 f0                	mov    %esi,%eax
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	56                   	push   %esi
  800da1:	53                   	push   %ebx
  800da2:	8b 75 08             	mov    0x8(%ebp),%esi
  800da5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da8:	8b 55 10             	mov    0x10(%ebp),%edx
  800dab:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dad:	85 d2                	test   %edx,%edx
  800daf:	74 21                	je     800dd2 <strlcpy+0x35>
  800db1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800db5:	89 f2                	mov    %esi,%edx
  800db7:	eb 09                	jmp    800dc2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800db9:	83 c2 01             	add    $0x1,%edx
  800dbc:	83 c1 01             	add    $0x1,%ecx
  800dbf:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dc2:	39 c2                	cmp    %eax,%edx
  800dc4:	74 09                	je     800dcf <strlcpy+0x32>
  800dc6:	0f b6 19             	movzbl (%ecx),%ebx
  800dc9:	84 db                	test   %bl,%bl
  800dcb:	75 ec                	jne    800db9 <strlcpy+0x1c>
  800dcd:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800dcf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dd2:	29 f0                	sub    %esi,%eax
}
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dde:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800de1:	eb 06                	jmp    800de9 <strcmp+0x11>
		p++, q++;
  800de3:	83 c1 01             	add    $0x1,%ecx
  800de6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800de9:	0f b6 01             	movzbl (%ecx),%eax
  800dec:	84 c0                	test   %al,%al
  800dee:	74 04                	je     800df4 <strcmp+0x1c>
  800df0:	3a 02                	cmp    (%edx),%al
  800df2:	74 ef                	je     800de3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800df4:	0f b6 c0             	movzbl %al,%eax
  800df7:	0f b6 12             	movzbl (%edx),%edx
  800dfa:	29 d0                	sub    %edx,%eax
}
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	53                   	push   %ebx
  800e02:	8b 45 08             	mov    0x8(%ebp),%eax
  800e05:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e08:	89 c3                	mov    %eax,%ebx
  800e0a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e0d:	eb 06                	jmp    800e15 <strncmp+0x17>
		n--, p++, q++;
  800e0f:	83 c0 01             	add    $0x1,%eax
  800e12:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e15:	39 d8                	cmp    %ebx,%eax
  800e17:	74 15                	je     800e2e <strncmp+0x30>
  800e19:	0f b6 08             	movzbl (%eax),%ecx
  800e1c:	84 c9                	test   %cl,%cl
  800e1e:	74 04                	je     800e24 <strncmp+0x26>
  800e20:	3a 0a                	cmp    (%edx),%cl
  800e22:	74 eb                	je     800e0f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e24:	0f b6 00             	movzbl (%eax),%eax
  800e27:	0f b6 12             	movzbl (%edx),%edx
  800e2a:	29 d0                	sub    %edx,%eax
  800e2c:	eb 05                	jmp    800e33 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e2e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e33:	5b                   	pop    %ebx
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    

00800e36 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e40:	eb 07                	jmp    800e49 <strchr+0x13>
		if (*s == c)
  800e42:	38 ca                	cmp    %cl,%dl
  800e44:	74 0f                	je     800e55 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e46:	83 c0 01             	add    $0x1,%eax
  800e49:	0f b6 10             	movzbl (%eax),%edx
  800e4c:	84 d2                	test   %dl,%dl
  800e4e:	75 f2                	jne    800e42 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e61:	eb 03                	jmp    800e66 <strfind+0xf>
  800e63:	83 c0 01             	add    $0x1,%eax
  800e66:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e69:	38 ca                	cmp    %cl,%dl
  800e6b:	74 04                	je     800e71 <strfind+0x1a>
  800e6d:	84 d2                	test   %dl,%dl
  800e6f:	75 f2                	jne    800e63 <strfind+0xc>
			break;
	return (char *) s;
}
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    

00800e73 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	57                   	push   %edi
  800e77:	56                   	push   %esi
  800e78:	53                   	push   %ebx
  800e79:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e7c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e7f:	85 c9                	test   %ecx,%ecx
  800e81:	74 36                	je     800eb9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e83:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e89:	75 28                	jne    800eb3 <memset+0x40>
  800e8b:	f6 c1 03             	test   $0x3,%cl
  800e8e:	75 23                	jne    800eb3 <memset+0x40>
		c &= 0xFF;
  800e90:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e94:	89 d3                	mov    %edx,%ebx
  800e96:	c1 e3 08             	shl    $0x8,%ebx
  800e99:	89 d6                	mov    %edx,%esi
  800e9b:	c1 e6 18             	shl    $0x18,%esi
  800e9e:	89 d0                	mov    %edx,%eax
  800ea0:	c1 e0 10             	shl    $0x10,%eax
  800ea3:	09 f0                	or     %esi,%eax
  800ea5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ea7:	89 d8                	mov    %ebx,%eax
  800ea9:	09 d0                	or     %edx,%eax
  800eab:	c1 e9 02             	shr    $0x2,%ecx
  800eae:	fc                   	cld    
  800eaf:	f3 ab                	rep stos %eax,%es:(%edi)
  800eb1:	eb 06                	jmp    800eb9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb6:	fc                   	cld    
  800eb7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800eb9:	89 f8                	mov    %edi,%eax
  800ebb:	5b                   	pop    %ebx
  800ebc:	5e                   	pop    %esi
  800ebd:	5f                   	pop    %edi
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	57                   	push   %edi
  800ec4:	56                   	push   %esi
  800ec5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ecb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ece:	39 c6                	cmp    %eax,%esi
  800ed0:	73 35                	jae    800f07 <memmove+0x47>
  800ed2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ed5:	39 d0                	cmp    %edx,%eax
  800ed7:	73 2e                	jae    800f07 <memmove+0x47>
		s += n;
		d += n;
  800ed9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800edc:	89 d6                	mov    %edx,%esi
  800ede:	09 fe                	or     %edi,%esi
  800ee0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ee6:	75 13                	jne    800efb <memmove+0x3b>
  800ee8:	f6 c1 03             	test   $0x3,%cl
  800eeb:	75 0e                	jne    800efb <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800eed:	83 ef 04             	sub    $0x4,%edi
  800ef0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ef3:	c1 e9 02             	shr    $0x2,%ecx
  800ef6:	fd                   	std    
  800ef7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ef9:	eb 09                	jmp    800f04 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800efb:	83 ef 01             	sub    $0x1,%edi
  800efe:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f01:	fd                   	std    
  800f02:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f04:	fc                   	cld    
  800f05:	eb 1d                	jmp    800f24 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f07:	89 f2                	mov    %esi,%edx
  800f09:	09 c2                	or     %eax,%edx
  800f0b:	f6 c2 03             	test   $0x3,%dl
  800f0e:	75 0f                	jne    800f1f <memmove+0x5f>
  800f10:	f6 c1 03             	test   $0x3,%cl
  800f13:	75 0a                	jne    800f1f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800f15:	c1 e9 02             	shr    $0x2,%ecx
  800f18:	89 c7                	mov    %eax,%edi
  800f1a:	fc                   	cld    
  800f1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f1d:	eb 05                	jmp    800f24 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f1f:	89 c7                	mov    %eax,%edi
  800f21:	fc                   	cld    
  800f22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f2b:	ff 75 10             	pushl  0x10(%ebp)
  800f2e:	ff 75 0c             	pushl  0xc(%ebp)
  800f31:	ff 75 08             	pushl  0x8(%ebp)
  800f34:	e8 87 ff ff ff       	call   800ec0 <memmove>
}
  800f39:	c9                   	leave  
  800f3a:	c3                   	ret    

00800f3b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	56                   	push   %esi
  800f3f:	53                   	push   %ebx
  800f40:	8b 45 08             	mov    0x8(%ebp),%eax
  800f43:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f46:	89 c6                	mov    %eax,%esi
  800f48:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f4b:	eb 1a                	jmp    800f67 <memcmp+0x2c>
		if (*s1 != *s2)
  800f4d:	0f b6 08             	movzbl (%eax),%ecx
  800f50:	0f b6 1a             	movzbl (%edx),%ebx
  800f53:	38 d9                	cmp    %bl,%cl
  800f55:	74 0a                	je     800f61 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f57:	0f b6 c1             	movzbl %cl,%eax
  800f5a:	0f b6 db             	movzbl %bl,%ebx
  800f5d:	29 d8                	sub    %ebx,%eax
  800f5f:	eb 0f                	jmp    800f70 <memcmp+0x35>
		s1++, s2++;
  800f61:	83 c0 01             	add    $0x1,%eax
  800f64:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f67:	39 f0                	cmp    %esi,%eax
  800f69:	75 e2                	jne    800f4d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    

00800f74 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	53                   	push   %ebx
  800f78:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f7b:	89 c1                	mov    %eax,%ecx
  800f7d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f80:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f84:	eb 0a                	jmp    800f90 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f86:	0f b6 10             	movzbl (%eax),%edx
  800f89:	39 da                	cmp    %ebx,%edx
  800f8b:	74 07                	je     800f94 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f8d:	83 c0 01             	add    $0x1,%eax
  800f90:	39 c8                	cmp    %ecx,%eax
  800f92:	72 f2                	jb     800f86 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f94:	5b                   	pop    %ebx
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    

00800f97 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	57                   	push   %edi
  800f9b:	56                   	push   %esi
  800f9c:	53                   	push   %ebx
  800f9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fa3:	eb 03                	jmp    800fa8 <strtol+0x11>
		s++;
  800fa5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fa8:	0f b6 01             	movzbl (%ecx),%eax
  800fab:	3c 20                	cmp    $0x20,%al
  800fad:	74 f6                	je     800fa5 <strtol+0xe>
  800faf:	3c 09                	cmp    $0x9,%al
  800fb1:	74 f2                	je     800fa5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fb3:	3c 2b                	cmp    $0x2b,%al
  800fb5:	75 0a                	jne    800fc1 <strtol+0x2a>
		s++;
  800fb7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fba:	bf 00 00 00 00       	mov    $0x0,%edi
  800fbf:	eb 11                	jmp    800fd2 <strtol+0x3b>
  800fc1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fc6:	3c 2d                	cmp    $0x2d,%al
  800fc8:	75 08                	jne    800fd2 <strtol+0x3b>
		s++, neg = 1;
  800fca:	83 c1 01             	add    $0x1,%ecx
  800fcd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fd2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800fd8:	75 15                	jne    800fef <strtol+0x58>
  800fda:	80 39 30             	cmpb   $0x30,(%ecx)
  800fdd:	75 10                	jne    800fef <strtol+0x58>
  800fdf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800fe3:	75 7c                	jne    801061 <strtol+0xca>
		s += 2, base = 16;
  800fe5:	83 c1 02             	add    $0x2,%ecx
  800fe8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fed:	eb 16                	jmp    801005 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800fef:	85 db                	test   %ebx,%ebx
  800ff1:	75 12                	jne    801005 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ff3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ff8:	80 39 30             	cmpb   $0x30,(%ecx)
  800ffb:	75 08                	jne    801005 <strtol+0x6e>
		s++, base = 8;
  800ffd:	83 c1 01             	add    $0x1,%ecx
  801000:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801005:	b8 00 00 00 00       	mov    $0x0,%eax
  80100a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80100d:	0f b6 11             	movzbl (%ecx),%edx
  801010:	8d 72 d0             	lea    -0x30(%edx),%esi
  801013:	89 f3                	mov    %esi,%ebx
  801015:	80 fb 09             	cmp    $0x9,%bl
  801018:	77 08                	ja     801022 <strtol+0x8b>
			dig = *s - '0';
  80101a:	0f be d2             	movsbl %dl,%edx
  80101d:	83 ea 30             	sub    $0x30,%edx
  801020:	eb 22                	jmp    801044 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801022:	8d 72 9f             	lea    -0x61(%edx),%esi
  801025:	89 f3                	mov    %esi,%ebx
  801027:	80 fb 19             	cmp    $0x19,%bl
  80102a:	77 08                	ja     801034 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80102c:	0f be d2             	movsbl %dl,%edx
  80102f:	83 ea 57             	sub    $0x57,%edx
  801032:	eb 10                	jmp    801044 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801034:	8d 72 bf             	lea    -0x41(%edx),%esi
  801037:	89 f3                	mov    %esi,%ebx
  801039:	80 fb 19             	cmp    $0x19,%bl
  80103c:	77 16                	ja     801054 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80103e:	0f be d2             	movsbl %dl,%edx
  801041:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801044:	3b 55 10             	cmp    0x10(%ebp),%edx
  801047:	7d 0b                	jge    801054 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801049:	83 c1 01             	add    $0x1,%ecx
  80104c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801050:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801052:	eb b9                	jmp    80100d <strtol+0x76>

	if (endptr)
  801054:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801058:	74 0d                	je     801067 <strtol+0xd0>
		*endptr = (char *) s;
  80105a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80105d:	89 0e                	mov    %ecx,(%esi)
  80105f:	eb 06                	jmp    801067 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801061:	85 db                	test   %ebx,%ebx
  801063:	74 98                	je     800ffd <strtol+0x66>
  801065:	eb 9e                	jmp    801005 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801067:	89 c2                	mov    %eax,%edx
  801069:	f7 da                	neg    %edx
  80106b:	85 ff                	test   %edi,%edi
  80106d:	0f 45 c2             	cmovne %edx,%eax
}
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5f                   	pop    %edi
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	57                   	push   %edi
  801079:	56                   	push   %esi
  80107a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107b:	b8 00 00 00 00       	mov    $0x0,%eax
  801080:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801083:	8b 55 08             	mov    0x8(%ebp),%edx
  801086:	89 c3                	mov    %eax,%ebx
  801088:	89 c7                	mov    %eax,%edi
  80108a:	89 c6                	mov    %eax,%esi
  80108c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80108e:	5b                   	pop    %ebx
  80108f:	5e                   	pop    %esi
  801090:	5f                   	pop    %edi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    

00801093 <sys_cgetc>:

int
sys_cgetc(void)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	57                   	push   %edi
  801097:	56                   	push   %esi
  801098:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	ba 00 00 00 00       	mov    $0x0,%edx
  80109e:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a3:	89 d1                	mov    %edx,%ecx
  8010a5:	89 d3                	mov    %edx,%ebx
  8010a7:	89 d7                	mov    %edx,%edi
  8010a9:	89 d6                	mov    %edx,%esi
  8010ab:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5f                   	pop    %edi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	57                   	push   %edi
  8010b6:	56                   	push   %esi
  8010b7:	53                   	push   %ebx
  8010b8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8010c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c8:	89 cb                	mov    %ecx,%ebx
  8010ca:	89 cf                	mov    %ecx,%edi
  8010cc:	89 ce                	mov    %ecx,%esi
  8010ce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	7e 17                	jle    8010eb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d4:	83 ec 0c             	sub    $0xc,%esp
  8010d7:	50                   	push   %eax
  8010d8:	6a 03                	push   $0x3
  8010da:	68 ff 2a 80 00       	push   $0x802aff
  8010df:	6a 23                	push   $0x23
  8010e1:	68 1c 2b 80 00       	push   $0x802b1c
  8010e6:	e8 e5 f5 ff ff       	call   8006d0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ee:	5b                   	pop    %ebx
  8010ef:	5e                   	pop    %esi
  8010f0:	5f                   	pop    %edi
  8010f1:	5d                   	pop    %ebp
  8010f2:	c3                   	ret    

008010f3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	57                   	push   %edi
  8010f7:	56                   	push   %esi
  8010f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8010fe:	b8 02 00 00 00       	mov    $0x2,%eax
  801103:	89 d1                	mov    %edx,%ecx
  801105:	89 d3                	mov    %edx,%ebx
  801107:	89 d7                	mov    %edx,%edi
  801109:	89 d6                	mov    %edx,%esi
  80110b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80110d:	5b                   	pop    %ebx
  80110e:	5e                   	pop    %esi
  80110f:	5f                   	pop    %edi
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    

00801112 <sys_yield>:

void
sys_yield(void)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
  801115:	57                   	push   %edi
  801116:	56                   	push   %esi
  801117:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801118:	ba 00 00 00 00       	mov    $0x0,%edx
  80111d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801122:	89 d1                	mov    %edx,%ecx
  801124:	89 d3                	mov    %edx,%ebx
  801126:	89 d7                	mov    %edx,%edi
  801128:	89 d6                	mov    %edx,%esi
  80112a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80112c:	5b                   	pop    %ebx
  80112d:	5e                   	pop    %esi
  80112e:	5f                   	pop    %edi
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	57                   	push   %edi
  801135:	56                   	push   %esi
  801136:	53                   	push   %ebx
  801137:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113a:	be 00 00 00 00       	mov    $0x0,%esi
  80113f:	b8 04 00 00 00       	mov    $0x4,%eax
  801144:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801147:	8b 55 08             	mov    0x8(%ebp),%edx
  80114a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114d:	89 f7                	mov    %esi,%edi
  80114f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801151:	85 c0                	test   %eax,%eax
  801153:	7e 17                	jle    80116c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801155:	83 ec 0c             	sub    $0xc,%esp
  801158:	50                   	push   %eax
  801159:	6a 04                	push   $0x4
  80115b:	68 ff 2a 80 00       	push   $0x802aff
  801160:	6a 23                	push   $0x23
  801162:	68 1c 2b 80 00       	push   $0x802b1c
  801167:	e8 64 f5 ff ff       	call   8006d0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80116c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116f:	5b                   	pop    %ebx
  801170:	5e                   	pop    %esi
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	57                   	push   %edi
  801178:	56                   	push   %esi
  801179:	53                   	push   %ebx
  80117a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117d:	b8 05 00 00 00       	mov    $0x5,%eax
  801182:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801185:	8b 55 08             	mov    0x8(%ebp),%edx
  801188:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80118b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80118e:	8b 75 18             	mov    0x18(%ebp),%esi
  801191:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801193:	85 c0                	test   %eax,%eax
  801195:	7e 17                	jle    8011ae <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801197:	83 ec 0c             	sub    $0xc,%esp
  80119a:	50                   	push   %eax
  80119b:	6a 05                	push   $0x5
  80119d:	68 ff 2a 80 00       	push   $0x802aff
  8011a2:	6a 23                	push   $0x23
  8011a4:	68 1c 2b 80 00       	push   $0x802b1c
  8011a9:	e8 22 f5 ff ff       	call   8006d0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b1:	5b                   	pop    %ebx
  8011b2:	5e                   	pop    %esi
  8011b3:	5f                   	pop    %edi
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    

008011b6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	57                   	push   %edi
  8011ba:	56                   	push   %esi
  8011bb:	53                   	push   %ebx
  8011bc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8011c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011cf:	89 df                	mov    %ebx,%edi
  8011d1:	89 de                	mov    %ebx,%esi
  8011d3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	7e 17                	jle    8011f0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011d9:	83 ec 0c             	sub    $0xc,%esp
  8011dc:	50                   	push   %eax
  8011dd:	6a 06                	push   $0x6
  8011df:	68 ff 2a 80 00       	push   $0x802aff
  8011e4:	6a 23                	push   $0x23
  8011e6:	68 1c 2b 80 00       	push   $0x802b1c
  8011eb:	e8 e0 f4 ff ff       	call   8006d0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f3:	5b                   	pop    %ebx
  8011f4:	5e                   	pop    %esi
  8011f5:	5f                   	pop    %edi
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	57                   	push   %edi
  8011fc:	56                   	push   %esi
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801201:	bb 00 00 00 00       	mov    $0x0,%ebx
  801206:	b8 08 00 00 00       	mov    $0x8,%eax
  80120b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120e:	8b 55 08             	mov    0x8(%ebp),%edx
  801211:	89 df                	mov    %ebx,%edi
  801213:	89 de                	mov    %ebx,%esi
  801215:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801217:	85 c0                	test   %eax,%eax
  801219:	7e 17                	jle    801232 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80121b:	83 ec 0c             	sub    $0xc,%esp
  80121e:	50                   	push   %eax
  80121f:	6a 08                	push   $0x8
  801221:	68 ff 2a 80 00       	push   $0x802aff
  801226:	6a 23                	push   $0x23
  801228:	68 1c 2b 80 00       	push   $0x802b1c
  80122d:	e8 9e f4 ff ff       	call   8006d0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801232:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801235:	5b                   	pop    %ebx
  801236:	5e                   	pop    %esi
  801237:	5f                   	pop    %edi
  801238:	5d                   	pop    %ebp
  801239:	c3                   	ret    

0080123a <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	57                   	push   %edi
  80123e:	56                   	push   %esi
  80123f:	53                   	push   %ebx
  801240:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801243:	bb 00 00 00 00       	mov    $0x0,%ebx
  801248:	b8 09 00 00 00       	mov    $0x9,%eax
  80124d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801250:	8b 55 08             	mov    0x8(%ebp),%edx
  801253:	89 df                	mov    %ebx,%edi
  801255:	89 de                	mov    %ebx,%esi
  801257:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801259:	85 c0                	test   %eax,%eax
  80125b:	7e 17                	jle    801274 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125d:	83 ec 0c             	sub    $0xc,%esp
  801260:	50                   	push   %eax
  801261:	6a 09                	push   $0x9
  801263:	68 ff 2a 80 00       	push   $0x802aff
  801268:	6a 23                	push   $0x23
  80126a:	68 1c 2b 80 00       	push   $0x802b1c
  80126f:	e8 5c f4 ff ff       	call   8006d0 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801274:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801277:	5b                   	pop    %ebx
  801278:	5e                   	pop    %esi
  801279:	5f                   	pop    %edi
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	57                   	push   %edi
  801280:	56                   	push   %esi
  801281:	53                   	push   %ebx
  801282:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801285:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80128f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801292:	8b 55 08             	mov    0x8(%ebp),%edx
  801295:	89 df                	mov    %ebx,%edi
  801297:	89 de                	mov    %ebx,%esi
  801299:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80129b:	85 c0                	test   %eax,%eax
  80129d:	7e 17                	jle    8012b6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80129f:	83 ec 0c             	sub    $0xc,%esp
  8012a2:	50                   	push   %eax
  8012a3:	6a 0a                	push   $0xa
  8012a5:	68 ff 2a 80 00       	push   $0x802aff
  8012aa:	6a 23                	push   $0x23
  8012ac:	68 1c 2b 80 00       	push   $0x802b1c
  8012b1:	e8 1a f4 ff ff       	call   8006d0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b9:	5b                   	pop    %ebx
  8012ba:	5e                   	pop    %esi
  8012bb:	5f                   	pop    %edi
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    

008012be <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	57                   	push   %edi
  8012c2:	56                   	push   %esi
  8012c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012c4:	be 00 00 00 00       	mov    $0x0,%esi
  8012c9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012d7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012da:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012dc:	5b                   	pop    %ebx
  8012dd:	5e                   	pop    %esi
  8012de:	5f                   	pop    %edi
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    

008012e1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	57                   	push   %edi
  8012e5:	56                   	push   %esi
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012ef:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f7:	89 cb                	mov    %ecx,%ebx
  8012f9:	89 cf                	mov    %ecx,%edi
  8012fb:	89 ce                	mov    %ecx,%esi
  8012fd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012ff:	85 c0                	test   %eax,%eax
  801301:	7e 17                	jle    80131a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801303:	83 ec 0c             	sub    $0xc,%esp
  801306:	50                   	push   %eax
  801307:	6a 0d                	push   $0xd
  801309:	68 ff 2a 80 00       	push   $0x802aff
  80130e:	6a 23                	push   $0x23
  801310:	68 1c 2b 80 00       	push   $0x802b1c
  801315:	e8 b6 f3 ff ff       	call   8006d0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80131a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80131d:	5b                   	pop    %ebx
  80131e:	5e                   	pop    %esi
  80131f:	5f                   	pop    %edi
  801320:	5d                   	pop    %ebp
  801321:	c3                   	ret    

00801322 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	56                   	push   %esi
  801326:	53                   	push   %ebx
  801327:	8b 75 08             	mov    0x8(%ebp),%esi
  80132a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801330:	85 c0                	test   %eax,%eax
  801332:	75 12                	jne    801346 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801334:	83 ec 0c             	sub    $0xc,%esp
  801337:	68 00 00 c0 ee       	push   $0xeec00000
  80133c:	e8 a0 ff ff ff       	call   8012e1 <sys_ipc_recv>
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	eb 0c                	jmp    801352 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801346:	83 ec 0c             	sub    $0xc,%esp
  801349:	50                   	push   %eax
  80134a:	e8 92 ff ff ff       	call   8012e1 <sys_ipc_recv>
  80134f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801352:	85 f6                	test   %esi,%esi
  801354:	0f 95 c1             	setne  %cl
  801357:	85 db                	test   %ebx,%ebx
  801359:	0f 95 c2             	setne  %dl
  80135c:	84 d1                	test   %dl,%cl
  80135e:	74 09                	je     801369 <ipc_recv+0x47>
  801360:	89 c2                	mov    %eax,%edx
  801362:	c1 ea 1f             	shr    $0x1f,%edx
  801365:	84 d2                	test   %dl,%dl
  801367:	75 24                	jne    80138d <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801369:	85 f6                	test   %esi,%esi
  80136b:	74 0a                	je     801377 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  80136d:	a1 04 40 80 00       	mov    0x804004,%eax
  801372:	8b 40 74             	mov    0x74(%eax),%eax
  801375:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801377:	85 db                	test   %ebx,%ebx
  801379:	74 0a                	je     801385 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  80137b:	a1 04 40 80 00       	mov    0x804004,%eax
  801380:	8b 40 78             	mov    0x78(%eax),%eax
  801383:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801385:	a1 04 40 80 00       	mov    0x804004,%eax
  80138a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80138d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801390:	5b                   	pop    %ebx
  801391:	5e                   	pop    %esi
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    

00801394 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	57                   	push   %edi
  801398:	56                   	push   %esi
  801399:	53                   	push   %ebx
  80139a:	83 ec 0c             	sub    $0xc,%esp
  80139d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013a0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8013a6:	85 db                	test   %ebx,%ebx
  8013a8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8013ad:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8013b0:	ff 75 14             	pushl  0x14(%ebp)
  8013b3:	53                   	push   %ebx
  8013b4:	56                   	push   %esi
  8013b5:	57                   	push   %edi
  8013b6:	e8 03 ff ff ff       	call   8012be <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8013bb:	89 c2                	mov    %eax,%edx
  8013bd:	c1 ea 1f             	shr    $0x1f,%edx
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	84 d2                	test   %dl,%dl
  8013c5:	74 17                	je     8013de <ipc_send+0x4a>
  8013c7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013ca:	74 12                	je     8013de <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8013cc:	50                   	push   %eax
  8013cd:	68 2a 2b 80 00       	push   $0x802b2a
  8013d2:	6a 47                	push   $0x47
  8013d4:	68 38 2b 80 00       	push   $0x802b38
  8013d9:	e8 f2 f2 ff ff       	call   8006d0 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8013de:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013e1:	75 07                	jne    8013ea <ipc_send+0x56>
			sys_yield();
  8013e3:	e8 2a fd ff ff       	call   801112 <sys_yield>
  8013e8:	eb c6                	jmp    8013b0 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	75 c2                	jne    8013b0 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8013ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f1:	5b                   	pop    %ebx
  8013f2:	5e                   	pop    %esi
  8013f3:	5f                   	pop    %edi
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    

008013f6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013fc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801401:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801404:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80140a:	8b 52 50             	mov    0x50(%edx),%edx
  80140d:	39 ca                	cmp    %ecx,%edx
  80140f:	75 0d                	jne    80141e <ipc_find_env+0x28>
			return envs[i].env_id;
  801411:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801414:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801419:	8b 40 48             	mov    0x48(%eax),%eax
  80141c:	eb 0f                	jmp    80142d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80141e:	83 c0 01             	add    $0x1,%eax
  801421:	3d 00 04 00 00       	cmp    $0x400,%eax
  801426:	75 d9                	jne    801401 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801428:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    

0080142f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801432:	8b 45 08             	mov    0x8(%ebp),%eax
  801435:	05 00 00 00 30       	add    $0x30000000,%eax
  80143a:	c1 e8 0c             	shr    $0xc,%eax
}
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    

0080143f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801442:	8b 45 08             	mov    0x8(%ebp),%eax
  801445:	05 00 00 00 30       	add    $0x30000000,%eax
  80144a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80144f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801454:	5d                   	pop    %ebp
  801455:	c3                   	ret    

00801456 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80145c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801461:	89 c2                	mov    %eax,%edx
  801463:	c1 ea 16             	shr    $0x16,%edx
  801466:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80146d:	f6 c2 01             	test   $0x1,%dl
  801470:	74 11                	je     801483 <fd_alloc+0x2d>
  801472:	89 c2                	mov    %eax,%edx
  801474:	c1 ea 0c             	shr    $0xc,%edx
  801477:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80147e:	f6 c2 01             	test   $0x1,%dl
  801481:	75 09                	jne    80148c <fd_alloc+0x36>
			*fd_store = fd;
  801483:	89 01                	mov    %eax,(%ecx)
			return 0;
  801485:	b8 00 00 00 00       	mov    $0x0,%eax
  80148a:	eb 17                	jmp    8014a3 <fd_alloc+0x4d>
  80148c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801491:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801496:	75 c9                	jne    801461 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801498:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80149e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014a3:	5d                   	pop    %ebp
  8014a4:	c3                   	ret    

008014a5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014ab:	83 f8 1f             	cmp    $0x1f,%eax
  8014ae:	77 36                	ja     8014e6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014b0:	c1 e0 0c             	shl    $0xc,%eax
  8014b3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014b8:	89 c2                	mov    %eax,%edx
  8014ba:	c1 ea 16             	shr    $0x16,%edx
  8014bd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014c4:	f6 c2 01             	test   $0x1,%dl
  8014c7:	74 24                	je     8014ed <fd_lookup+0x48>
  8014c9:	89 c2                	mov    %eax,%edx
  8014cb:	c1 ea 0c             	shr    $0xc,%edx
  8014ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014d5:	f6 c2 01             	test   $0x1,%dl
  8014d8:	74 1a                	je     8014f4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014dd:	89 02                	mov    %eax,(%edx)
	return 0;
  8014df:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e4:	eb 13                	jmp    8014f9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014eb:	eb 0c                	jmp    8014f9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f2:	eb 05                	jmp    8014f9 <fd_lookup+0x54>
  8014f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014f9:	5d                   	pop    %ebp
  8014fa:	c3                   	ret    

008014fb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	83 ec 08             	sub    $0x8,%esp
  801501:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801504:	ba c4 2b 80 00       	mov    $0x802bc4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801509:	eb 13                	jmp    80151e <dev_lookup+0x23>
  80150b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80150e:	39 08                	cmp    %ecx,(%eax)
  801510:	75 0c                	jne    80151e <dev_lookup+0x23>
			*dev = devtab[i];
  801512:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801515:	89 01                	mov    %eax,(%ecx)
			return 0;
  801517:	b8 00 00 00 00       	mov    $0x0,%eax
  80151c:	eb 2e                	jmp    80154c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80151e:	8b 02                	mov    (%edx),%eax
  801520:	85 c0                	test   %eax,%eax
  801522:	75 e7                	jne    80150b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801524:	a1 04 40 80 00       	mov    0x804004,%eax
  801529:	8b 40 48             	mov    0x48(%eax),%eax
  80152c:	83 ec 04             	sub    $0x4,%esp
  80152f:	51                   	push   %ecx
  801530:	50                   	push   %eax
  801531:	68 44 2b 80 00       	push   $0x802b44
  801536:	e8 6e f2 ff ff       	call   8007a9 <cprintf>
	*dev = 0;
  80153b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80154c:	c9                   	leave  
  80154d:	c3                   	ret    

0080154e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	56                   	push   %esi
  801552:	53                   	push   %ebx
  801553:	83 ec 10             	sub    $0x10,%esp
  801556:	8b 75 08             	mov    0x8(%ebp),%esi
  801559:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80155c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155f:	50                   	push   %eax
  801560:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801566:	c1 e8 0c             	shr    $0xc,%eax
  801569:	50                   	push   %eax
  80156a:	e8 36 ff ff ff       	call   8014a5 <fd_lookup>
  80156f:	83 c4 08             	add    $0x8,%esp
  801572:	85 c0                	test   %eax,%eax
  801574:	78 05                	js     80157b <fd_close+0x2d>
	    || fd != fd2)
  801576:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801579:	74 0c                	je     801587 <fd_close+0x39>
		return (must_exist ? r : 0);
  80157b:	84 db                	test   %bl,%bl
  80157d:	ba 00 00 00 00       	mov    $0x0,%edx
  801582:	0f 44 c2             	cmove  %edx,%eax
  801585:	eb 41                	jmp    8015c8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	ff 36                	pushl  (%esi)
  801590:	e8 66 ff ff ff       	call   8014fb <dev_lookup>
  801595:	89 c3                	mov    %eax,%ebx
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 1a                	js     8015b8 <fd_close+0x6a>
		if (dev->dev_close)
  80159e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015a4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	74 0b                	je     8015b8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015ad:	83 ec 0c             	sub    $0xc,%esp
  8015b0:	56                   	push   %esi
  8015b1:	ff d0                	call   *%eax
  8015b3:	89 c3                	mov    %eax,%ebx
  8015b5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015b8:	83 ec 08             	sub    $0x8,%esp
  8015bb:	56                   	push   %esi
  8015bc:	6a 00                	push   $0x0
  8015be:	e8 f3 fb ff ff       	call   8011b6 <sys_page_unmap>
	return r;
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	89 d8                	mov    %ebx,%eax
}
  8015c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cb:	5b                   	pop    %ebx
  8015cc:	5e                   	pop    %esi
  8015cd:	5d                   	pop    %ebp
  8015ce:	c3                   	ret    

008015cf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	ff 75 08             	pushl  0x8(%ebp)
  8015dc:	e8 c4 fe ff ff       	call   8014a5 <fd_lookup>
  8015e1:	83 c4 08             	add    $0x8,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 10                	js     8015f8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	6a 01                	push   $0x1
  8015ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f0:	e8 59 ff ff ff       	call   80154e <fd_close>
  8015f5:	83 c4 10             	add    $0x10,%esp
}
  8015f8:	c9                   	leave  
  8015f9:	c3                   	ret    

008015fa <close_all>:

void
close_all(void)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	53                   	push   %ebx
  8015fe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801601:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801606:	83 ec 0c             	sub    $0xc,%esp
  801609:	53                   	push   %ebx
  80160a:	e8 c0 ff ff ff       	call   8015cf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80160f:	83 c3 01             	add    $0x1,%ebx
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	83 fb 20             	cmp    $0x20,%ebx
  801618:	75 ec                	jne    801606 <close_all+0xc>
		close(i);
}
  80161a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	57                   	push   %edi
  801623:	56                   	push   %esi
  801624:	53                   	push   %ebx
  801625:	83 ec 2c             	sub    $0x2c,%esp
  801628:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80162b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80162e:	50                   	push   %eax
  80162f:	ff 75 08             	pushl  0x8(%ebp)
  801632:	e8 6e fe ff ff       	call   8014a5 <fd_lookup>
  801637:	83 c4 08             	add    $0x8,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	0f 88 c1 00 00 00    	js     801703 <dup+0xe4>
		return r;
	close(newfdnum);
  801642:	83 ec 0c             	sub    $0xc,%esp
  801645:	56                   	push   %esi
  801646:	e8 84 ff ff ff       	call   8015cf <close>

	newfd = INDEX2FD(newfdnum);
  80164b:	89 f3                	mov    %esi,%ebx
  80164d:	c1 e3 0c             	shl    $0xc,%ebx
  801650:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801656:	83 c4 04             	add    $0x4,%esp
  801659:	ff 75 e4             	pushl  -0x1c(%ebp)
  80165c:	e8 de fd ff ff       	call   80143f <fd2data>
  801661:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801663:	89 1c 24             	mov    %ebx,(%esp)
  801666:	e8 d4 fd ff ff       	call   80143f <fd2data>
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801671:	89 f8                	mov    %edi,%eax
  801673:	c1 e8 16             	shr    $0x16,%eax
  801676:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80167d:	a8 01                	test   $0x1,%al
  80167f:	74 37                	je     8016b8 <dup+0x99>
  801681:	89 f8                	mov    %edi,%eax
  801683:	c1 e8 0c             	shr    $0xc,%eax
  801686:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80168d:	f6 c2 01             	test   $0x1,%dl
  801690:	74 26                	je     8016b8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801692:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801699:	83 ec 0c             	sub    $0xc,%esp
  80169c:	25 07 0e 00 00       	and    $0xe07,%eax
  8016a1:	50                   	push   %eax
  8016a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016a5:	6a 00                	push   $0x0
  8016a7:	57                   	push   %edi
  8016a8:	6a 00                	push   $0x0
  8016aa:	e8 c5 fa ff ff       	call   801174 <sys_page_map>
  8016af:	89 c7                	mov    %eax,%edi
  8016b1:	83 c4 20             	add    $0x20,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 2e                	js     8016e6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016bb:	89 d0                	mov    %edx,%eax
  8016bd:	c1 e8 0c             	shr    $0xc,%eax
  8016c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016c7:	83 ec 0c             	sub    $0xc,%esp
  8016ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8016cf:	50                   	push   %eax
  8016d0:	53                   	push   %ebx
  8016d1:	6a 00                	push   $0x0
  8016d3:	52                   	push   %edx
  8016d4:	6a 00                	push   $0x0
  8016d6:	e8 99 fa ff ff       	call   801174 <sys_page_map>
  8016db:	89 c7                	mov    %eax,%edi
  8016dd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016e0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016e2:	85 ff                	test   %edi,%edi
  8016e4:	79 1d                	jns    801703 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	53                   	push   %ebx
  8016ea:	6a 00                	push   $0x0
  8016ec:	e8 c5 fa ff ff       	call   8011b6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016f1:	83 c4 08             	add    $0x8,%esp
  8016f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016f7:	6a 00                	push   $0x0
  8016f9:	e8 b8 fa ff ff       	call   8011b6 <sys_page_unmap>
	return r;
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	89 f8                	mov    %edi,%eax
}
  801703:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801706:	5b                   	pop    %ebx
  801707:	5e                   	pop    %esi
  801708:	5f                   	pop    %edi
  801709:	5d                   	pop    %ebp
  80170a:	c3                   	ret    

0080170b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	53                   	push   %ebx
  80170f:	83 ec 14             	sub    $0x14,%esp
  801712:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801715:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801718:	50                   	push   %eax
  801719:	53                   	push   %ebx
  80171a:	e8 86 fd ff ff       	call   8014a5 <fd_lookup>
  80171f:	83 c4 08             	add    $0x8,%esp
  801722:	89 c2                	mov    %eax,%edx
  801724:	85 c0                	test   %eax,%eax
  801726:	78 6d                	js     801795 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801728:	83 ec 08             	sub    $0x8,%esp
  80172b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172e:	50                   	push   %eax
  80172f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801732:	ff 30                	pushl  (%eax)
  801734:	e8 c2 fd ff ff       	call   8014fb <dev_lookup>
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 4c                	js     80178c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801740:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801743:	8b 42 08             	mov    0x8(%edx),%eax
  801746:	83 e0 03             	and    $0x3,%eax
  801749:	83 f8 01             	cmp    $0x1,%eax
  80174c:	75 21                	jne    80176f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80174e:	a1 04 40 80 00       	mov    0x804004,%eax
  801753:	8b 40 48             	mov    0x48(%eax),%eax
  801756:	83 ec 04             	sub    $0x4,%esp
  801759:	53                   	push   %ebx
  80175a:	50                   	push   %eax
  80175b:	68 88 2b 80 00       	push   $0x802b88
  801760:	e8 44 f0 ff ff       	call   8007a9 <cprintf>
		return -E_INVAL;
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80176d:	eb 26                	jmp    801795 <read+0x8a>
	}
	if (!dev->dev_read)
  80176f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801772:	8b 40 08             	mov    0x8(%eax),%eax
  801775:	85 c0                	test   %eax,%eax
  801777:	74 17                	je     801790 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801779:	83 ec 04             	sub    $0x4,%esp
  80177c:	ff 75 10             	pushl  0x10(%ebp)
  80177f:	ff 75 0c             	pushl  0xc(%ebp)
  801782:	52                   	push   %edx
  801783:	ff d0                	call   *%eax
  801785:	89 c2                	mov    %eax,%edx
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	eb 09                	jmp    801795 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178c:	89 c2                	mov    %eax,%edx
  80178e:	eb 05                	jmp    801795 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801790:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801795:	89 d0                	mov    %edx,%eax
  801797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179a:	c9                   	leave  
  80179b:	c3                   	ret    

0080179c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	57                   	push   %edi
  8017a0:	56                   	push   %esi
  8017a1:	53                   	push   %ebx
  8017a2:	83 ec 0c             	sub    $0xc,%esp
  8017a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b0:	eb 21                	jmp    8017d3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017b2:	83 ec 04             	sub    $0x4,%esp
  8017b5:	89 f0                	mov    %esi,%eax
  8017b7:	29 d8                	sub    %ebx,%eax
  8017b9:	50                   	push   %eax
  8017ba:	89 d8                	mov    %ebx,%eax
  8017bc:	03 45 0c             	add    0xc(%ebp),%eax
  8017bf:	50                   	push   %eax
  8017c0:	57                   	push   %edi
  8017c1:	e8 45 ff ff ff       	call   80170b <read>
		if (m < 0)
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	85 c0                	test   %eax,%eax
  8017cb:	78 10                	js     8017dd <readn+0x41>
			return m;
		if (m == 0)
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	74 0a                	je     8017db <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017d1:	01 c3                	add    %eax,%ebx
  8017d3:	39 f3                	cmp    %esi,%ebx
  8017d5:	72 db                	jb     8017b2 <readn+0x16>
  8017d7:	89 d8                	mov    %ebx,%eax
  8017d9:	eb 02                	jmp    8017dd <readn+0x41>
  8017db:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e0:	5b                   	pop    %ebx
  8017e1:	5e                   	pop    %esi
  8017e2:	5f                   	pop    %edi
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	53                   	push   %ebx
  8017e9:	83 ec 14             	sub    $0x14,%esp
  8017ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f2:	50                   	push   %eax
  8017f3:	53                   	push   %ebx
  8017f4:	e8 ac fc ff ff       	call   8014a5 <fd_lookup>
  8017f9:	83 c4 08             	add    $0x8,%esp
  8017fc:	89 c2                	mov    %eax,%edx
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 68                	js     80186a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801802:	83 ec 08             	sub    $0x8,%esp
  801805:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801808:	50                   	push   %eax
  801809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180c:	ff 30                	pushl  (%eax)
  80180e:	e8 e8 fc ff ff       	call   8014fb <dev_lookup>
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	85 c0                	test   %eax,%eax
  801818:	78 47                	js     801861 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80181a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801821:	75 21                	jne    801844 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801823:	a1 04 40 80 00       	mov    0x804004,%eax
  801828:	8b 40 48             	mov    0x48(%eax),%eax
  80182b:	83 ec 04             	sub    $0x4,%esp
  80182e:	53                   	push   %ebx
  80182f:	50                   	push   %eax
  801830:	68 a4 2b 80 00       	push   $0x802ba4
  801835:	e8 6f ef ff ff       	call   8007a9 <cprintf>
		return -E_INVAL;
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801842:	eb 26                	jmp    80186a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801844:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801847:	8b 52 0c             	mov    0xc(%edx),%edx
  80184a:	85 d2                	test   %edx,%edx
  80184c:	74 17                	je     801865 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80184e:	83 ec 04             	sub    $0x4,%esp
  801851:	ff 75 10             	pushl  0x10(%ebp)
  801854:	ff 75 0c             	pushl  0xc(%ebp)
  801857:	50                   	push   %eax
  801858:	ff d2                	call   *%edx
  80185a:	89 c2                	mov    %eax,%edx
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	eb 09                	jmp    80186a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801861:	89 c2                	mov    %eax,%edx
  801863:	eb 05                	jmp    80186a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801865:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80186a:	89 d0                	mov    %edx,%eax
  80186c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186f:	c9                   	leave  
  801870:	c3                   	ret    

00801871 <seek>:

int
seek(int fdnum, off_t offset)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801877:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80187a:	50                   	push   %eax
  80187b:	ff 75 08             	pushl  0x8(%ebp)
  80187e:	e8 22 fc ff ff       	call   8014a5 <fd_lookup>
  801883:	83 c4 08             	add    $0x8,%esp
  801886:	85 c0                	test   %eax,%eax
  801888:	78 0e                	js     801898 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80188a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80188d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801890:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801893:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	53                   	push   %ebx
  80189e:	83 ec 14             	sub    $0x14,%esp
  8018a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a7:	50                   	push   %eax
  8018a8:	53                   	push   %ebx
  8018a9:	e8 f7 fb ff ff       	call   8014a5 <fd_lookup>
  8018ae:	83 c4 08             	add    $0x8,%esp
  8018b1:	89 c2                	mov    %eax,%edx
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	78 65                	js     80191c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b7:	83 ec 08             	sub    $0x8,%esp
  8018ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018bd:	50                   	push   %eax
  8018be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c1:	ff 30                	pushl  (%eax)
  8018c3:	e8 33 fc ff ff       	call   8014fb <dev_lookup>
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 44                	js     801913 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018d6:	75 21                	jne    8018f9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018d8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018dd:	8b 40 48             	mov    0x48(%eax),%eax
  8018e0:	83 ec 04             	sub    $0x4,%esp
  8018e3:	53                   	push   %ebx
  8018e4:	50                   	push   %eax
  8018e5:	68 64 2b 80 00       	push   $0x802b64
  8018ea:	e8 ba ee ff ff       	call   8007a9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018f7:	eb 23                	jmp    80191c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018fc:	8b 52 18             	mov    0x18(%edx),%edx
  8018ff:	85 d2                	test   %edx,%edx
  801901:	74 14                	je     801917 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801903:	83 ec 08             	sub    $0x8,%esp
  801906:	ff 75 0c             	pushl  0xc(%ebp)
  801909:	50                   	push   %eax
  80190a:	ff d2                	call   *%edx
  80190c:	89 c2                	mov    %eax,%edx
  80190e:	83 c4 10             	add    $0x10,%esp
  801911:	eb 09                	jmp    80191c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801913:	89 c2                	mov    %eax,%edx
  801915:	eb 05                	jmp    80191c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801917:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80191c:	89 d0                	mov    %edx,%eax
  80191e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	53                   	push   %ebx
  801927:	83 ec 14             	sub    $0x14,%esp
  80192a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80192d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801930:	50                   	push   %eax
  801931:	ff 75 08             	pushl  0x8(%ebp)
  801934:	e8 6c fb ff ff       	call   8014a5 <fd_lookup>
  801939:	83 c4 08             	add    $0x8,%esp
  80193c:	89 c2                	mov    %eax,%edx
  80193e:	85 c0                	test   %eax,%eax
  801940:	78 58                	js     80199a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801942:	83 ec 08             	sub    $0x8,%esp
  801945:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801948:	50                   	push   %eax
  801949:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194c:	ff 30                	pushl  (%eax)
  80194e:	e8 a8 fb ff ff       	call   8014fb <dev_lookup>
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	85 c0                	test   %eax,%eax
  801958:	78 37                	js     801991 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80195a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801961:	74 32                	je     801995 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801963:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801966:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80196d:	00 00 00 
	stat->st_isdir = 0;
  801970:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801977:	00 00 00 
	stat->st_dev = dev;
  80197a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801980:	83 ec 08             	sub    $0x8,%esp
  801983:	53                   	push   %ebx
  801984:	ff 75 f0             	pushl  -0x10(%ebp)
  801987:	ff 50 14             	call   *0x14(%eax)
  80198a:	89 c2                	mov    %eax,%edx
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	eb 09                	jmp    80199a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801991:	89 c2                	mov    %eax,%edx
  801993:	eb 05                	jmp    80199a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801995:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80199a:	89 d0                	mov    %edx,%eax
  80199c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199f:	c9                   	leave  
  8019a0:	c3                   	ret    

008019a1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
  8019a4:	56                   	push   %esi
  8019a5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019a6:	83 ec 08             	sub    $0x8,%esp
  8019a9:	6a 00                	push   $0x0
  8019ab:	ff 75 08             	pushl  0x8(%ebp)
  8019ae:	e8 e3 01 00 00       	call   801b96 <open>
  8019b3:	89 c3                	mov    %eax,%ebx
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	78 1b                	js     8019d7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019bc:	83 ec 08             	sub    $0x8,%esp
  8019bf:	ff 75 0c             	pushl  0xc(%ebp)
  8019c2:	50                   	push   %eax
  8019c3:	e8 5b ff ff ff       	call   801923 <fstat>
  8019c8:	89 c6                	mov    %eax,%esi
	close(fd);
  8019ca:	89 1c 24             	mov    %ebx,(%esp)
  8019cd:	e8 fd fb ff ff       	call   8015cf <close>
	return r;
  8019d2:	83 c4 10             	add    $0x10,%esp
  8019d5:	89 f0                	mov    %esi,%eax
}
  8019d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019da:	5b                   	pop    %ebx
  8019db:	5e                   	pop    %esi
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	56                   	push   %esi
  8019e2:	53                   	push   %ebx
  8019e3:	89 c6                	mov    %eax,%esi
  8019e5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019e7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019ee:	75 12                	jne    801a02 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	6a 01                	push   $0x1
  8019f5:	e8 fc f9 ff ff       	call   8013f6 <ipc_find_env>
  8019fa:	a3 00 40 80 00       	mov    %eax,0x804000
  8019ff:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a02:	6a 07                	push   $0x7
  801a04:	68 00 50 80 00       	push   $0x805000
  801a09:	56                   	push   %esi
  801a0a:	ff 35 00 40 80 00    	pushl  0x804000
  801a10:	e8 7f f9 ff ff       	call   801394 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a15:	83 c4 0c             	add    $0xc,%esp
  801a18:	6a 00                	push   $0x0
  801a1a:	53                   	push   %ebx
  801a1b:	6a 00                	push   $0x0
  801a1d:	e8 00 f9 ff ff       	call   801322 <ipc_recv>
}
  801a22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a25:	5b                   	pop    %ebx
  801a26:	5e                   	pop    %esi
  801a27:	5d                   	pop    %ebp
  801a28:	c3                   	ret    

00801a29 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a32:	8b 40 0c             	mov    0xc(%eax),%eax
  801a35:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a42:	ba 00 00 00 00       	mov    $0x0,%edx
  801a47:	b8 02 00 00 00       	mov    $0x2,%eax
  801a4c:	e8 8d ff ff ff       	call   8019de <fsipc>
}
  801a51:	c9                   	leave  
  801a52:	c3                   	ret    

00801a53 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a59:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a64:	ba 00 00 00 00       	mov    $0x0,%edx
  801a69:	b8 06 00 00 00       	mov    $0x6,%eax
  801a6e:	e8 6b ff ff ff       	call   8019de <fsipc>
}
  801a73:	c9                   	leave  
  801a74:	c3                   	ret    

00801a75 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	53                   	push   %ebx
  801a79:	83 ec 04             	sub    $0x4,%esp
  801a7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a82:	8b 40 0c             	mov    0xc(%eax),%eax
  801a85:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a8a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8f:	b8 05 00 00 00       	mov    $0x5,%eax
  801a94:	e8 45 ff ff ff       	call   8019de <fsipc>
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	78 2c                	js     801ac9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a9d:	83 ec 08             	sub    $0x8,%esp
  801aa0:	68 00 50 80 00       	push   $0x805000
  801aa5:	53                   	push   %ebx
  801aa6:	e8 83 f2 ff ff       	call   800d2e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aab:	a1 80 50 80 00       	mov    0x805080,%eax
  801ab0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ab6:	a1 84 50 80 00       	mov    0x805084,%eax
  801abb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    

00801ace <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	83 ec 0c             	sub    $0xc,%esp
  801ad4:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ad7:	8b 55 08             	mov    0x8(%ebp),%edx
  801ada:	8b 52 0c             	mov    0xc(%edx),%edx
  801add:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801ae3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ae8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801aed:	0f 47 c2             	cmova  %edx,%eax
  801af0:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801af5:	50                   	push   %eax
  801af6:	ff 75 0c             	pushl  0xc(%ebp)
  801af9:	68 08 50 80 00       	push   $0x805008
  801afe:	e8 bd f3 ff ff       	call   800ec0 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b03:	ba 00 00 00 00       	mov    $0x0,%edx
  801b08:	b8 04 00 00 00       	mov    $0x4,%eax
  801b0d:	e8 cc fe ff ff       	call   8019de <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b12:	c9                   	leave  
  801b13:	c3                   	ret    

00801b14 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	56                   	push   %esi
  801b18:	53                   	push   %ebx
  801b19:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b22:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b27:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b32:	b8 03 00 00 00       	mov    $0x3,%eax
  801b37:	e8 a2 fe ff ff       	call   8019de <fsipc>
  801b3c:	89 c3                	mov    %eax,%ebx
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 4b                	js     801b8d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b42:	39 c6                	cmp    %eax,%esi
  801b44:	73 16                	jae    801b5c <devfile_read+0x48>
  801b46:	68 d4 2b 80 00       	push   $0x802bd4
  801b4b:	68 db 2b 80 00       	push   $0x802bdb
  801b50:	6a 7c                	push   $0x7c
  801b52:	68 f0 2b 80 00       	push   $0x802bf0
  801b57:	e8 74 eb ff ff       	call   8006d0 <_panic>
	assert(r <= PGSIZE);
  801b5c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b61:	7e 16                	jle    801b79 <devfile_read+0x65>
  801b63:	68 fb 2b 80 00       	push   $0x802bfb
  801b68:	68 db 2b 80 00       	push   $0x802bdb
  801b6d:	6a 7d                	push   $0x7d
  801b6f:	68 f0 2b 80 00       	push   $0x802bf0
  801b74:	e8 57 eb ff ff       	call   8006d0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b79:	83 ec 04             	sub    $0x4,%esp
  801b7c:	50                   	push   %eax
  801b7d:	68 00 50 80 00       	push   $0x805000
  801b82:	ff 75 0c             	pushl  0xc(%ebp)
  801b85:	e8 36 f3 ff ff       	call   800ec0 <memmove>
	return r;
  801b8a:	83 c4 10             	add    $0x10,%esp
}
  801b8d:	89 d8                	mov    %ebx,%eax
  801b8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b92:	5b                   	pop    %ebx
  801b93:	5e                   	pop    %esi
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	53                   	push   %ebx
  801b9a:	83 ec 20             	sub    $0x20,%esp
  801b9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ba0:	53                   	push   %ebx
  801ba1:	e8 4f f1 ff ff       	call   800cf5 <strlen>
  801ba6:	83 c4 10             	add    $0x10,%esp
  801ba9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bae:	7f 67                	jg     801c17 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bb0:	83 ec 0c             	sub    $0xc,%esp
  801bb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb6:	50                   	push   %eax
  801bb7:	e8 9a f8 ff ff       	call   801456 <fd_alloc>
  801bbc:	83 c4 10             	add    $0x10,%esp
		return r;
  801bbf:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bc1:	85 c0                	test   %eax,%eax
  801bc3:	78 57                	js     801c1c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bc5:	83 ec 08             	sub    $0x8,%esp
  801bc8:	53                   	push   %ebx
  801bc9:	68 00 50 80 00       	push   $0x805000
  801bce:	e8 5b f1 ff ff       	call   800d2e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bdb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bde:	b8 01 00 00 00       	mov    $0x1,%eax
  801be3:	e8 f6 fd ff ff       	call   8019de <fsipc>
  801be8:	89 c3                	mov    %eax,%ebx
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	85 c0                	test   %eax,%eax
  801bef:	79 14                	jns    801c05 <open+0x6f>
		fd_close(fd, 0);
  801bf1:	83 ec 08             	sub    $0x8,%esp
  801bf4:	6a 00                	push   $0x0
  801bf6:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf9:	e8 50 f9 ff ff       	call   80154e <fd_close>
		return r;
  801bfe:	83 c4 10             	add    $0x10,%esp
  801c01:	89 da                	mov    %ebx,%edx
  801c03:	eb 17                	jmp    801c1c <open+0x86>
	}

	return fd2num(fd);
  801c05:	83 ec 0c             	sub    $0xc,%esp
  801c08:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0b:	e8 1f f8 ff ff       	call   80142f <fd2num>
  801c10:	89 c2                	mov    %eax,%edx
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	eb 05                	jmp    801c1c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c17:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c1c:	89 d0                	mov    %edx,%eax
  801c1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c21:	c9                   	leave  
  801c22:	c3                   	ret    

00801c23 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c29:	ba 00 00 00 00       	mov    $0x0,%edx
  801c2e:	b8 08 00 00 00       	mov    $0x8,%eax
  801c33:	e8 a6 fd ff ff       	call   8019de <fsipc>
}
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	56                   	push   %esi
  801c3e:	53                   	push   %ebx
  801c3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c42:	83 ec 0c             	sub    $0xc,%esp
  801c45:	ff 75 08             	pushl  0x8(%ebp)
  801c48:	e8 f2 f7 ff ff       	call   80143f <fd2data>
  801c4d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c4f:	83 c4 08             	add    $0x8,%esp
  801c52:	68 07 2c 80 00       	push   $0x802c07
  801c57:	53                   	push   %ebx
  801c58:	e8 d1 f0 ff ff       	call   800d2e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c5d:	8b 46 04             	mov    0x4(%esi),%eax
  801c60:	2b 06                	sub    (%esi),%eax
  801c62:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c68:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c6f:	00 00 00 
	stat->st_dev = &devpipe;
  801c72:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801c79:	30 80 00 
	return 0;
}
  801c7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5e                   	pop    %esi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    

00801c88 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	53                   	push   %ebx
  801c8c:	83 ec 0c             	sub    $0xc,%esp
  801c8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c92:	53                   	push   %ebx
  801c93:	6a 00                	push   $0x0
  801c95:	e8 1c f5 ff ff       	call   8011b6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c9a:	89 1c 24             	mov    %ebx,(%esp)
  801c9d:	e8 9d f7 ff ff       	call   80143f <fd2data>
  801ca2:	83 c4 08             	add    $0x8,%esp
  801ca5:	50                   	push   %eax
  801ca6:	6a 00                	push   $0x0
  801ca8:	e8 09 f5 ff ff       	call   8011b6 <sys_page_unmap>
}
  801cad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	57                   	push   %edi
  801cb6:	56                   	push   %esi
  801cb7:	53                   	push   %ebx
  801cb8:	83 ec 1c             	sub    $0x1c,%esp
  801cbb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cbe:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cc0:	a1 04 40 80 00       	mov    0x804004,%eax
  801cc5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801cc8:	83 ec 0c             	sub    $0xc,%esp
  801ccb:	ff 75 e0             	pushl  -0x20(%ebp)
  801cce:	e8 46 04 00 00       	call   802119 <pageref>
  801cd3:	89 c3                	mov    %eax,%ebx
  801cd5:	89 3c 24             	mov    %edi,(%esp)
  801cd8:	e8 3c 04 00 00       	call   802119 <pageref>
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	39 c3                	cmp    %eax,%ebx
  801ce2:	0f 94 c1             	sete   %cl
  801ce5:	0f b6 c9             	movzbl %cl,%ecx
  801ce8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ceb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cf1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cf4:	39 ce                	cmp    %ecx,%esi
  801cf6:	74 1b                	je     801d13 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801cf8:	39 c3                	cmp    %eax,%ebx
  801cfa:	75 c4                	jne    801cc0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cfc:	8b 42 58             	mov    0x58(%edx),%eax
  801cff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d02:	50                   	push   %eax
  801d03:	56                   	push   %esi
  801d04:	68 0e 2c 80 00       	push   $0x802c0e
  801d09:	e8 9b ea ff ff       	call   8007a9 <cprintf>
  801d0e:	83 c4 10             	add    $0x10,%esp
  801d11:	eb ad                	jmp    801cc0 <_pipeisclosed+0xe>
	}
}
  801d13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d19:	5b                   	pop    %ebx
  801d1a:	5e                   	pop    %esi
  801d1b:	5f                   	pop    %edi
  801d1c:	5d                   	pop    %ebp
  801d1d:	c3                   	ret    

00801d1e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 28             	sub    $0x28,%esp
  801d27:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d2a:	56                   	push   %esi
  801d2b:	e8 0f f7 ff ff       	call   80143f <fd2data>
  801d30:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d32:	83 c4 10             	add    $0x10,%esp
  801d35:	bf 00 00 00 00       	mov    $0x0,%edi
  801d3a:	eb 4b                	jmp    801d87 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d3c:	89 da                	mov    %ebx,%edx
  801d3e:	89 f0                	mov    %esi,%eax
  801d40:	e8 6d ff ff ff       	call   801cb2 <_pipeisclosed>
  801d45:	85 c0                	test   %eax,%eax
  801d47:	75 48                	jne    801d91 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d49:	e8 c4 f3 ff ff       	call   801112 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d4e:	8b 43 04             	mov    0x4(%ebx),%eax
  801d51:	8b 0b                	mov    (%ebx),%ecx
  801d53:	8d 51 20             	lea    0x20(%ecx),%edx
  801d56:	39 d0                	cmp    %edx,%eax
  801d58:	73 e2                	jae    801d3c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d5d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d61:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d64:	89 c2                	mov    %eax,%edx
  801d66:	c1 fa 1f             	sar    $0x1f,%edx
  801d69:	89 d1                	mov    %edx,%ecx
  801d6b:	c1 e9 1b             	shr    $0x1b,%ecx
  801d6e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d71:	83 e2 1f             	and    $0x1f,%edx
  801d74:	29 ca                	sub    %ecx,%edx
  801d76:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d7a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d7e:	83 c0 01             	add    $0x1,%eax
  801d81:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d84:	83 c7 01             	add    $0x1,%edi
  801d87:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d8a:	75 c2                	jne    801d4e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d8c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d8f:	eb 05                	jmp    801d96 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d91:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d99:	5b                   	pop    %ebx
  801d9a:	5e                   	pop    %esi
  801d9b:	5f                   	pop    %edi
  801d9c:	5d                   	pop    %ebp
  801d9d:	c3                   	ret    

00801d9e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	57                   	push   %edi
  801da2:	56                   	push   %esi
  801da3:	53                   	push   %ebx
  801da4:	83 ec 18             	sub    $0x18,%esp
  801da7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801daa:	57                   	push   %edi
  801dab:	e8 8f f6 ff ff       	call   80143f <fd2data>
  801db0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dba:	eb 3d                	jmp    801df9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dbc:	85 db                	test   %ebx,%ebx
  801dbe:	74 04                	je     801dc4 <devpipe_read+0x26>
				return i;
  801dc0:	89 d8                	mov    %ebx,%eax
  801dc2:	eb 44                	jmp    801e08 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801dc4:	89 f2                	mov    %esi,%edx
  801dc6:	89 f8                	mov    %edi,%eax
  801dc8:	e8 e5 fe ff ff       	call   801cb2 <_pipeisclosed>
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	75 32                	jne    801e03 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dd1:	e8 3c f3 ff ff       	call   801112 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dd6:	8b 06                	mov    (%esi),%eax
  801dd8:	3b 46 04             	cmp    0x4(%esi),%eax
  801ddb:	74 df                	je     801dbc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ddd:	99                   	cltd   
  801dde:	c1 ea 1b             	shr    $0x1b,%edx
  801de1:	01 d0                	add    %edx,%eax
  801de3:	83 e0 1f             	and    $0x1f,%eax
  801de6:	29 d0                	sub    %edx,%eax
  801de8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ded:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801df0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801df3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801df6:	83 c3 01             	add    $0x1,%ebx
  801df9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dfc:	75 d8                	jne    801dd6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dfe:	8b 45 10             	mov    0x10(%ebp),%eax
  801e01:	eb 05                	jmp    801e08 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e03:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e0b:	5b                   	pop    %ebx
  801e0c:	5e                   	pop    %esi
  801e0d:	5f                   	pop    %edi
  801e0e:	5d                   	pop    %ebp
  801e0f:	c3                   	ret    

00801e10 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	56                   	push   %esi
  801e14:	53                   	push   %ebx
  801e15:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1b:	50                   	push   %eax
  801e1c:	e8 35 f6 ff ff       	call   801456 <fd_alloc>
  801e21:	83 c4 10             	add    $0x10,%esp
  801e24:	89 c2                	mov    %eax,%edx
  801e26:	85 c0                	test   %eax,%eax
  801e28:	0f 88 2c 01 00 00    	js     801f5a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e2e:	83 ec 04             	sub    $0x4,%esp
  801e31:	68 07 04 00 00       	push   $0x407
  801e36:	ff 75 f4             	pushl  -0xc(%ebp)
  801e39:	6a 00                	push   $0x0
  801e3b:	e8 f1 f2 ff ff       	call   801131 <sys_page_alloc>
  801e40:	83 c4 10             	add    $0x10,%esp
  801e43:	89 c2                	mov    %eax,%edx
  801e45:	85 c0                	test   %eax,%eax
  801e47:	0f 88 0d 01 00 00    	js     801f5a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e4d:	83 ec 0c             	sub    $0xc,%esp
  801e50:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e53:	50                   	push   %eax
  801e54:	e8 fd f5 ff ff       	call   801456 <fd_alloc>
  801e59:	89 c3                	mov    %eax,%ebx
  801e5b:	83 c4 10             	add    $0x10,%esp
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	0f 88 e2 00 00 00    	js     801f48 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e66:	83 ec 04             	sub    $0x4,%esp
  801e69:	68 07 04 00 00       	push   $0x407
  801e6e:	ff 75 f0             	pushl  -0x10(%ebp)
  801e71:	6a 00                	push   $0x0
  801e73:	e8 b9 f2 ff ff       	call   801131 <sys_page_alloc>
  801e78:	89 c3                	mov    %eax,%ebx
  801e7a:	83 c4 10             	add    $0x10,%esp
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	0f 88 c3 00 00 00    	js     801f48 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e85:	83 ec 0c             	sub    $0xc,%esp
  801e88:	ff 75 f4             	pushl  -0xc(%ebp)
  801e8b:	e8 af f5 ff ff       	call   80143f <fd2data>
  801e90:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e92:	83 c4 0c             	add    $0xc,%esp
  801e95:	68 07 04 00 00       	push   $0x407
  801e9a:	50                   	push   %eax
  801e9b:	6a 00                	push   $0x0
  801e9d:	e8 8f f2 ff ff       	call   801131 <sys_page_alloc>
  801ea2:	89 c3                	mov    %eax,%ebx
  801ea4:	83 c4 10             	add    $0x10,%esp
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	0f 88 89 00 00 00    	js     801f38 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eaf:	83 ec 0c             	sub    $0xc,%esp
  801eb2:	ff 75 f0             	pushl  -0x10(%ebp)
  801eb5:	e8 85 f5 ff ff       	call   80143f <fd2data>
  801eba:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ec1:	50                   	push   %eax
  801ec2:	6a 00                	push   $0x0
  801ec4:	56                   	push   %esi
  801ec5:	6a 00                	push   $0x0
  801ec7:	e8 a8 f2 ff ff       	call   801174 <sys_page_map>
  801ecc:	89 c3                	mov    %eax,%ebx
  801ece:	83 c4 20             	add    $0x20,%esp
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	78 55                	js     801f2a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ed5:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ede:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eea:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ef0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ef3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ef8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801eff:	83 ec 0c             	sub    $0xc,%esp
  801f02:	ff 75 f4             	pushl  -0xc(%ebp)
  801f05:	e8 25 f5 ff ff       	call   80142f <fd2num>
  801f0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f0d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f0f:	83 c4 04             	add    $0x4,%esp
  801f12:	ff 75 f0             	pushl  -0x10(%ebp)
  801f15:	e8 15 f5 ff ff       	call   80142f <fd2num>
  801f1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f1d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	ba 00 00 00 00       	mov    $0x0,%edx
  801f28:	eb 30                	jmp    801f5a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f2a:	83 ec 08             	sub    $0x8,%esp
  801f2d:	56                   	push   %esi
  801f2e:	6a 00                	push   $0x0
  801f30:	e8 81 f2 ff ff       	call   8011b6 <sys_page_unmap>
  801f35:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f38:	83 ec 08             	sub    $0x8,%esp
  801f3b:	ff 75 f0             	pushl  -0x10(%ebp)
  801f3e:	6a 00                	push   $0x0
  801f40:	e8 71 f2 ff ff       	call   8011b6 <sys_page_unmap>
  801f45:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f48:	83 ec 08             	sub    $0x8,%esp
  801f4b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f4e:	6a 00                	push   $0x0
  801f50:	e8 61 f2 ff ff       	call   8011b6 <sys_page_unmap>
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f5a:	89 d0                	mov    %edx,%eax
  801f5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f5f:	5b                   	pop    %ebx
  801f60:	5e                   	pop    %esi
  801f61:	5d                   	pop    %ebp
  801f62:	c3                   	ret    

00801f63 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6c:	50                   	push   %eax
  801f6d:	ff 75 08             	pushl  0x8(%ebp)
  801f70:	e8 30 f5 ff ff       	call   8014a5 <fd_lookup>
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	78 18                	js     801f94 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f7c:	83 ec 0c             	sub    $0xc,%esp
  801f7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f82:	e8 b8 f4 ff ff       	call   80143f <fd2data>
	return _pipeisclosed(fd, p);
  801f87:	89 c2                	mov    %eax,%edx
  801f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8c:	e8 21 fd ff ff       	call   801cb2 <_pipeisclosed>
  801f91:	83 c4 10             	add    $0x10,%esp
}
  801f94:	c9                   	leave  
  801f95:	c3                   	ret    

00801f96 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f99:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9e:	5d                   	pop    %ebp
  801f9f:	c3                   	ret    

00801fa0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fa6:	68 26 2c 80 00       	push   $0x802c26
  801fab:	ff 75 0c             	pushl  0xc(%ebp)
  801fae:	e8 7b ed ff ff       	call   800d2e <strcpy>
	return 0;
}
  801fb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb8:	c9                   	leave  
  801fb9:	c3                   	ret    

00801fba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	57                   	push   %edi
  801fbe:	56                   	push   %esi
  801fbf:	53                   	push   %ebx
  801fc0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fcb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fd1:	eb 2d                	jmp    802000 <devcons_write+0x46>
		m = n - tot;
  801fd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fd6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fd8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fdb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fe0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fe3:	83 ec 04             	sub    $0x4,%esp
  801fe6:	53                   	push   %ebx
  801fe7:	03 45 0c             	add    0xc(%ebp),%eax
  801fea:	50                   	push   %eax
  801feb:	57                   	push   %edi
  801fec:	e8 cf ee ff ff       	call   800ec0 <memmove>
		sys_cputs(buf, m);
  801ff1:	83 c4 08             	add    $0x8,%esp
  801ff4:	53                   	push   %ebx
  801ff5:	57                   	push   %edi
  801ff6:	e8 7a f0 ff ff       	call   801075 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ffb:	01 de                	add    %ebx,%esi
  801ffd:	83 c4 10             	add    $0x10,%esp
  802000:	89 f0                	mov    %esi,%eax
  802002:	3b 75 10             	cmp    0x10(%ebp),%esi
  802005:	72 cc                	jb     801fd3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802007:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80200a:	5b                   	pop    %ebx
  80200b:	5e                   	pop    %esi
  80200c:	5f                   	pop    %edi
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    

0080200f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	83 ec 08             	sub    $0x8,%esp
  802015:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80201a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80201e:	74 2a                	je     80204a <devcons_read+0x3b>
  802020:	eb 05                	jmp    802027 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802022:	e8 eb f0 ff ff       	call   801112 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802027:	e8 67 f0 ff ff       	call   801093 <sys_cgetc>
  80202c:	85 c0                	test   %eax,%eax
  80202e:	74 f2                	je     802022 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802030:	85 c0                	test   %eax,%eax
  802032:	78 16                	js     80204a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802034:	83 f8 04             	cmp    $0x4,%eax
  802037:	74 0c                	je     802045 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802039:	8b 55 0c             	mov    0xc(%ebp),%edx
  80203c:	88 02                	mov    %al,(%edx)
	return 1;
  80203e:	b8 01 00 00 00       	mov    $0x1,%eax
  802043:	eb 05                	jmp    80204a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802045:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80204a:	c9                   	leave  
  80204b:	c3                   	ret    

0080204c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80204c:	55                   	push   %ebp
  80204d:	89 e5                	mov    %esp,%ebp
  80204f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802052:	8b 45 08             	mov    0x8(%ebp),%eax
  802055:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802058:	6a 01                	push   $0x1
  80205a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80205d:	50                   	push   %eax
  80205e:	e8 12 f0 ff ff       	call   801075 <sys_cputs>
}
  802063:	83 c4 10             	add    $0x10,%esp
  802066:	c9                   	leave  
  802067:	c3                   	ret    

00802068 <getchar>:

int
getchar(void)
{
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80206e:	6a 01                	push   $0x1
  802070:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802073:	50                   	push   %eax
  802074:	6a 00                	push   $0x0
  802076:	e8 90 f6 ff ff       	call   80170b <read>
	if (r < 0)
  80207b:	83 c4 10             	add    $0x10,%esp
  80207e:	85 c0                	test   %eax,%eax
  802080:	78 0f                	js     802091 <getchar+0x29>
		return r;
	if (r < 1)
  802082:	85 c0                	test   %eax,%eax
  802084:	7e 06                	jle    80208c <getchar+0x24>
		return -E_EOF;
	return c;
  802086:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80208a:	eb 05                	jmp    802091 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80208c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802091:	c9                   	leave  
  802092:	c3                   	ret    

00802093 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802093:	55                   	push   %ebp
  802094:	89 e5                	mov    %esp,%ebp
  802096:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802099:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209c:	50                   	push   %eax
  80209d:	ff 75 08             	pushl  0x8(%ebp)
  8020a0:	e8 00 f4 ff ff       	call   8014a5 <fd_lookup>
  8020a5:	83 c4 10             	add    $0x10,%esp
  8020a8:	85 c0                	test   %eax,%eax
  8020aa:	78 11                	js     8020bd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020af:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020b5:	39 10                	cmp    %edx,(%eax)
  8020b7:	0f 94 c0             	sete   %al
  8020ba:	0f b6 c0             	movzbl %al,%eax
}
  8020bd:	c9                   	leave  
  8020be:	c3                   	ret    

008020bf <opencons>:

int
opencons(void)
{
  8020bf:	55                   	push   %ebp
  8020c0:	89 e5                	mov    %esp,%ebp
  8020c2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c8:	50                   	push   %eax
  8020c9:	e8 88 f3 ff ff       	call   801456 <fd_alloc>
  8020ce:	83 c4 10             	add    $0x10,%esp
		return r;
  8020d1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020d3:	85 c0                	test   %eax,%eax
  8020d5:	78 3e                	js     802115 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020d7:	83 ec 04             	sub    $0x4,%esp
  8020da:	68 07 04 00 00       	push   $0x407
  8020df:	ff 75 f4             	pushl  -0xc(%ebp)
  8020e2:	6a 00                	push   $0x0
  8020e4:	e8 48 f0 ff ff       	call   801131 <sys_page_alloc>
  8020e9:	83 c4 10             	add    $0x10,%esp
		return r;
  8020ec:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020ee:	85 c0                	test   %eax,%eax
  8020f0:	78 23                	js     802115 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020f2:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802100:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802107:	83 ec 0c             	sub    $0xc,%esp
  80210a:	50                   	push   %eax
  80210b:	e8 1f f3 ff ff       	call   80142f <fd2num>
  802110:	89 c2                	mov    %eax,%edx
  802112:	83 c4 10             	add    $0x10,%esp
}
  802115:	89 d0                	mov    %edx,%eax
  802117:	c9                   	leave  
  802118:	c3                   	ret    

00802119 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802119:	55                   	push   %ebp
  80211a:	89 e5                	mov    %esp,%ebp
  80211c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80211f:	89 d0                	mov    %edx,%eax
  802121:	c1 e8 16             	shr    $0x16,%eax
  802124:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80212b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802130:	f6 c1 01             	test   $0x1,%cl
  802133:	74 1d                	je     802152 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802135:	c1 ea 0c             	shr    $0xc,%edx
  802138:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80213f:	f6 c2 01             	test   $0x1,%dl
  802142:	74 0e                	je     802152 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802144:	c1 ea 0c             	shr    $0xc,%edx
  802147:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80214e:	ef 
  80214f:	0f b7 c0             	movzwl %ax,%eax
}
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__udivdi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80216b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80216f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 f6                	test   %esi,%esi
  802179:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80217d:	89 ca                	mov    %ecx,%edx
  80217f:	89 f8                	mov    %edi,%eax
  802181:	75 3d                	jne    8021c0 <__udivdi3+0x60>
  802183:	39 cf                	cmp    %ecx,%edi
  802185:	0f 87 c5 00 00 00    	ja     802250 <__udivdi3+0xf0>
  80218b:	85 ff                	test   %edi,%edi
  80218d:	89 fd                	mov    %edi,%ebp
  80218f:	75 0b                	jne    80219c <__udivdi3+0x3c>
  802191:	b8 01 00 00 00       	mov    $0x1,%eax
  802196:	31 d2                	xor    %edx,%edx
  802198:	f7 f7                	div    %edi
  80219a:	89 c5                	mov    %eax,%ebp
  80219c:	89 c8                	mov    %ecx,%eax
  80219e:	31 d2                	xor    %edx,%edx
  8021a0:	f7 f5                	div    %ebp
  8021a2:	89 c1                	mov    %eax,%ecx
  8021a4:	89 d8                	mov    %ebx,%eax
  8021a6:	89 cf                	mov    %ecx,%edi
  8021a8:	f7 f5                	div    %ebp
  8021aa:	89 c3                	mov    %eax,%ebx
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	89 fa                	mov    %edi,%edx
  8021b0:	83 c4 1c             	add    $0x1c,%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	39 ce                	cmp    %ecx,%esi
  8021c2:	77 74                	ja     802238 <__udivdi3+0xd8>
  8021c4:	0f bd fe             	bsr    %esi,%edi
  8021c7:	83 f7 1f             	xor    $0x1f,%edi
  8021ca:	0f 84 98 00 00 00    	je     802268 <__udivdi3+0x108>
  8021d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	89 c5                	mov    %eax,%ebp
  8021d9:	29 fb                	sub    %edi,%ebx
  8021db:	d3 e6                	shl    %cl,%esi
  8021dd:	89 d9                	mov    %ebx,%ecx
  8021df:	d3 ed                	shr    %cl,%ebp
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	d3 e0                	shl    %cl,%eax
  8021e5:	09 ee                	or     %ebp,%esi
  8021e7:	89 d9                	mov    %ebx,%ecx
  8021e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ed:	89 d5                	mov    %edx,%ebp
  8021ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021f3:	d3 ed                	shr    %cl,%ebp
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	d3 e2                	shl    %cl,%edx
  8021f9:	89 d9                	mov    %ebx,%ecx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	09 c2                	or     %eax,%edx
  8021ff:	89 d0                	mov    %edx,%eax
  802201:	89 ea                	mov    %ebp,%edx
  802203:	f7 f6                	div    %esi
  802205:	89 d5                	mov    %edx,%ebp
  802207:	89 c3                	mov    %eax,%ebx
  802209:	f7 64 24 0c          	mull   0xc(%esp)
  80220d:	39 d5                	cmp    %edx,%ebp
  80220f:	72 10                	jb     802221 <__udivdi3+0xc1>
  802211:	8b 74 24 08          	mov    0x8(%esp),%esi
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e6                	shl    %cl,%esi
  802219:	39 c6                	cmp    %eax,%esi
  80221b:	73 07                	jae    802224 <__udivdi3+0xc4>
  80221d:	39 d5                	cmp    %edx,%ebp
  80221f:	75 03                	jne    802224 <__udivdi3+0xc4>
  802221:	83 eb 01             	sub    $0x1,%ebx
  802224:	31 ff                	xor    %edi,%edi
  802226:	89 d8                	mov    %ebx,%eax
  802228:	89 fa                	mov    %edi,%edx
  80222a:	83 c4 1c             	add    $0x1c,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5f                   	pop    %edi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	31 ff                	xor    %edi,%edi
  80223a:	31 db                	xor    %ebx,%ebx
  80223c:	89 d8                	mov    %ebx,%eax
  80223e:	89 fa                	mov    %edi,%edx
  802240:	83 c4 1c             	add    $0x1c,%esp
  802243:	5b                   	pop    %ebx
  802244:	5e                   	pop    %esi
  802245:	5f                   	pop    %edi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    
  802248:	90                   	nop
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	89 d8                	mov    %ebx,%eax
  802252:	f7 f7                	div    %edi
  802254:	31 ff                	xor    %edi,%edi
  802256:	89 c3                	mov    %eax,%ebx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 fa                	mov    %edi,%edx
  80225c:	83 c4 1c             	add    $0x1c,%esp
  80225f:	5b                   	pop    %ebx
  802260:	5e                   	pop    %esi
  802261:	5f                   	pop    %edi
  802262:	5d                   	pop    %ebp
  802263:	c3                   	ret    
  802264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802268:	39 ce                	cmp    %ecx,%esi
  80226a:	72 0c                	jb     802278 <__udivdi3+0x118>
  80226c:	31 db                	xor    %ebx,%ebx
  80226e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802272:	0f 87 34 ff ff ff    	ja     8021ac <__udivdi3+0x4c>
  802278:	bb 01 00 00 00       	mov    $0x1,%ebx
  80227d:	e9 2a ff ff ff       	jmp    8021ac <__udivdi3+0x4c>
  802282:	66 90                	xchg   %ax,%ax
  802284:	66 90                	xchg   %ax,%ax
  802286:	66 90                	xchg   %ax,%ax
  802288:	66 90                	xchg   %ax,%ax
  80228a:	66 90                	xchg   %ax,%ax
  80228c:	66 90                	xchg   %ax,%ax
  80228e:	66 90                	xchg   %ax,%ax

00802290 <__umoddi3>:
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	53                   	push   %ebx
  802294:	83 ec 1c             	sub    $0x1c,%esp
  802297:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80229b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80229f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022a7:	85 d2                	test   %edx,%edx
  8022a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022b1:	89 f3                	mov    %esi,%ebx
  8022b3:	89 3c 24             	mov    %edi,(%esp)
  8022b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ba:	75 1c                	jne    8022d8 <__umoddi3+0x48>
  8022bc:	39 f7                	cmp    %esi,%edi
  8022be:	76 50                	jbe    802310 <__umoddi3+0x80>
  8022c0:	89 c8                	mov    %ecx,%eax
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	f7 f7                	div    %edi
  8022c6:	89 d0                	mov    %edx,%eax
  8022c8:	31 d2                	xor    %edx,%edx
  8022ca:	83 c4 1c             	add    $0x1c,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5f                   	pop    %edi
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    
  8022d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d8:	39 f2                	cmp    %esi,%edx
  8022da:	89 d0                	mov    %edx,%eax
  8022dc:	77 52                	ja     802330 <__umoddi3+0xa0>
  8022de:	0f bd ea             	bsr    %edx,%ebp
  8022e1:	83 f5 1f             	xor    $0x1f,%ebp
  8022e4:	75 5a                	jne    802340 <__umoddi3+0xb0>
  8022e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022ea:	0f 82 e0 00 00 00    	jb     8023d0 <__umoddi3+0x140>
  8022f0:	39 0c 24             	cmp    %ecx,(%esp)
  8022f3:	0f 86 d7 00 00 00    	jbe    8023d0 <__umoddi3+0x140>
  8022f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802301:	83 c4 1c             	add    $0x1c,%esp
  802304:	5b                   	pop    %ebx
  802305:	5e                   	pop    %esi
  802306:	5f                   	pop    %edi
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	85 ff                	test   %edi,%edi
  802312:	89 fd                	mov    %edi,%ebp
  802314:	75 0b                	jne    802321 <__umoddi3+0x91>
  802316:	b8 01 00 00 00       	mov    $0x1,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	f7 f7                	div    %edi
  80231f:	89 c5                	mov    %eax,%ebp
  802321:	89 f0                	mov    %esi,%eax
  802323:	31 d2                	xor    %edx,%edx
  802325:	f7 f5                	div    %ebp
  802327:	89 c8                	mov    %ecx,%eax
  802329:	f7 f5                	div    %ebp
  80232b:	89 d0                	mov    %edx,%eax
  80232d:	eb 99                	jmp    8022c8 <__umoddi3+0x38>
  80232f:	90                   	nop
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	83 c4 1c             	add    $0x1c,%esp
  802337:	5b                   	pop    %ebx
  802338:	5e                   	pop    %esi
  802339:	5f                   	pop    %edi
  80233a:	5d                   	pop    %ebp
  80233b:	c3                   	ret    
  80233c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802340:	8b 34 24             	mov    (%esp),%esi
  802343:	bf 20 00 00 00       	mov    $0x20,%edi
  802348:	89 e9                	mov    %ebp,%ecx
  80234a:	29 ef                	sub    %ebp,%edi
  80234c:	d3 e0                	shl    %cl,%eax
  80234e:	89 f9                	mov    %edi,%ecx
  802350:	89 f2                	mov    %esi,%edx
  802352:	d3 ea                	shr    %cl,%edx
  802354:	89 e9                	mov    %ebp,%ecx
  802356:	09 c2                	or     %eax,%edx
  802358:	89 d8                	mov    %ebx,%eax
  80235a:	89 14 24             	mov    %edx,(%esp)
  80235d:	89 f2                	mov    %esi,%edx
  80235f:	d3 e2                	shl    %cl,%edx
  802361:	89 f9                	mov    %edi,%ecx
  802363:	89 54 24 04          	mov    %edx,0x4(%esp)
  802367:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80236b:	d3 e8                	shr    %cl,%eax
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	89 c6                	mov    %eax,%esi
  802371:	d3 e3                	shl    %cl,%ebx
  802373:	89 f9                	mov    %edi,%ecx
  802375:	89 d0                	mov    %edx,%eax
  802377:	d3 e8                	shr    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	09 d8                	or     %ebx,%eax
  80237d:	89 d3                	mov    %edx,%ebx
  80237f:	89 f2                	mov    %esi,%edx
  802381:	f7 34 24             	divl   (%esp)
  802384:	89 d6                	mov    %edx,%esi
  802386:	d3 e3                	shl    %cl,%ebx
  802388:	f7 64 24 04          	mull   0x4(%esp)
  80238c:	39 d6                	cmp    %edx,%esi
  80238e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802392:	89 d1                	mov    %edx,%ecx
  802394:	89 c3                	mov    %eax,%ebx
  802396:	72 08                	jb     8023a0 <__umoddi3+0x110>
  802398:	75 11                	jne    8023ab <__umoddi3+0x11b>
  80239a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80239e:	73 0b                	jae    8023ab <__umoddi3+0x11b>
  8023a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023a4:	1b 14 24             	sbb    (%esp),%edx
  8023a7:	89 d1                	mov    %edx,%ecx
  8023a9:	89 c3                	mov    %eax,%ebx
  8023ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023af:	29 da                	sub    %ebx,%edx
  8023b1:	19 ce                	sbb    %ecx,%esi
  8023b3:	89 f9                	mov    %edi,%ecx
  8023b5:	89 f0                	mov    %esi,%eax
  8023b7:	d3 e0                	shl    %cl,%eax
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	d3 ea                	shr    %cl,%edx
  8023bd:	89 e9                	mov    %ebp,%ecx
  8023bf:	d3 ee                	shr    %cl,%esi
  8023c1:	09 d0                	or     %edx,%eax
  8023c3:	89 f2                	mov    %esi,%edx
  8023c5:	83 c4 1c             	add    $0x1c,%esp
  8023c8:	5b                   	pop    %ebx
  8023c9:	5e                   	pop    %esi
  8023ca:	5f                   	pop    %edi
  8023cb:	5d                   	pop    %ebp
  8023cc:	c3                   	ret    
  8023cd:	8d 76 00             	lea    0x0(%esi),%esi
  8023d0:	29 f9                	sub    %edi,%ecx
  8023d2:	19 d6                	sbb    %edx,%esi
  8023d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023dc:	e9 18 ff ff ff       	jmp    8022f9 <__umoddi3+0x69>
