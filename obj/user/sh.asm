
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 93 09 00 00       	call   8009c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 3e 01 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 a0 35 80 00       	push   $0x8035a0
  800060:	e8 bb 0a 00 00       	call   800b20 <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 24 01 00 00       	jmp    800196 <_gettoken+0x163>
	}

	if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 af 35 80 00       	push   $0x8035af
  800084:	e8 97 0a 00 00       	call   800b20 <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 bd 35 80 00       	push   $0x8035bd
  8000b0:	e8 eb 11 00 00       	call   8012a0 <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
		*s++ = 0;
	if (*s == 0) {
  8000bc:	0f b6 03             	movzbl (%ebx),%eax
  8000bf:	84 c0                	test   %al,%al
  8000c1:	75 2c                	jne    8000ef <_gettoken+0xbc>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000c8:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000cf:	0f 8e c1 00 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 c2 35 80 00       	push   $0x8035c2
  8000dd:	e8 3e 0a 00 00       	call   800b20 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 d3 35 80 00       	push   $0x8035d3
  8000fb:	e8 a0 11 00 00       	call   8012a0 <strchr>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 30                	je     800137 <_gettoken+0x104>
		t = *s;
  800107:	0f be 3b             	movsbl (%ebx),%edi
		*p1 = s;
  80010a:	89 1e                	mov    %ebx,(%esi)
		*s++ = 0;
  80010c:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  80010f:	83 c3 01             	add    $0x1,%ebx
  800112:	8b 45 10             	mov    0x10(%ebp),%eax
  800115:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800117:	89 f8                	mov    %edi,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  800119:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800120:	7e 74                	jle    800196 <_gettoken+0x163>
			cprintf("TOK %c\n", t);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	57                   	push   %edi
  800126:	68 c7 35 80 00       	push   $0x8035c7
  80012b:	e8 f0 09 00 00       	call   800b20 <cprintf>
  800130:	83 c4 10             	add    $0x10,%esp
		return t;
  800133:	89 f8                	mov    %edi,%eax
  800135:	eb 5f                	jmp    800196 <_gettoken+0x163>
	}
	*p1 = s;
  800137:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800139:	eb 03                	jmp    80013e <_gettoken+0x10b>
		s++;
  80013b:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013e:	0f b6 03             	movzbl (%ebx),%eax
  800141:	84 c0                	test   %al,%al
  800143:	74 18                	je     80015d <_gettoken+0x12a>
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	50                   	push   %eax
  80014c:	68 cf 35 80 00       	push   $0x8035cf
  800151:	e8 4a 11 00 00       	call   8012a0 <strchr>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 de                	je     80013b <_gettoken+0x108>
		s++;
	*p2 = s;
  80015d:	8b 45 10             	mov    0x10(%ebp),%eax
  800160:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800162:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800167:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80016e:	7e 26                	jle    800196 <_gettoken+0x163>
		t = **p2;
  800170:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	ff 36                	pushl  (%esi)
  80017b:	68 db 35 80 00       	push   $0x8035db
  800180:	e8 9b 09 00 00       	call   800b20 <cprintf>
		**p2 = t;
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	89 fa                	mov    %edi,%edx
  80018c:	88 10                	mov    %dl,(%eax)
  80018e:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800191:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <gettoken>:

int
gettoken(char *s, char **p1)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 22                	je     8001cd <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	68 0c 50 80 00       	push   $0x80500c
  8001b3:	68 10 50 80 00       	push   $0x805010
  8001b8:	50                   	push   %eax
  8001b9:	e8 75 fe ff ff       	call   800033 <_gettoken>
  8001be:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cb:	eb 3a                	jmp    800207 <gettoken+0x69>
	}
	c = nc;
  8001cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d2:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e0:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	68 0c 50 80 00       	push   $0x80500c
  8001ea:	68 10 50 80 00       	push   $0x805010
  8001ef:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f5:	e8 39 fe ff ff       	call   800033 <_gettoken>
  8001fa:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001ff:	a1 04 50 80 00       	mov    0x805004,%eax
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800215:	6a 00                	push   $0x0
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 7f ff ff ff       	call   80019e <gettoken>
  80021f:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800222:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800225:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	53                   	push   %ebx
  80022e:	6a 00                	push   $0x0
  800230:	e8 69 ff ff ff       	call   80019e <gettoken>
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	0f 84 cc 00 00 00    	je     80030d <runcmd+0x104>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 3b 02 00 00    	je     800489 <runcmd+0x280>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 1f 02 00 00       	jmp    800477 <runcmd+0x26e>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 25 01 00 00    	je     80038b <runcmd+0x182>
  800266:	e9 0c 02 00 00       	jmp    800477 <runcmd+0x26e>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 e5 35 80 00       	push   $0x8035e5
  800278:	e8 a3 08 00 00       	call   800b20 <cprintf>
				exit();
  80027d:	e8 ab 07 00 00       	call   800a2d <exit>
  800282:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800285:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800288:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028c:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80028f:	eb 99                	jmp    80022a <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	53                   	push   %ebx
  800295:	6a 00                	push   $0x0
  800297:	e8 02 ff ff ff       	call   80019e <gettoken>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	83 f8 77             	cmp    $0x77,%eax
  8002a2:	74 15                	je     8002b9 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 38 37 80 00       	push   $0x803738
  8002ac:	e8 6f 08 00 00       	call   800b20 <cprintf>
				exit();
  8002b1:	e8 77 07 00 00       	call   800a2d <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 eb 22 00 00       	call   8025b1 <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
				cprintf("open %s for read: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 f9 35 80 00       	push   $0x8035f9
  8002db:	e8 40 08 00 00       	call   800b20 <cprintf>
				exit();
  8002e0:	e8 48 07 00 00       	call   800a2d <exit>
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	eb 08                	jmp    8002f2 <runcmd+0xe9>
			}

			if (fd != 0) {
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	0f 84 38 ff ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 0);
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	6a 00                	push   $0x0
  8002f7:	57                   	push   %edi
  8002f8:	e8 34 1d 00 00       	call   802031 <dup>
				close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 dc 1c 00 00       	call   801fe1 <close>
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	e9 1d ff ff ff       	jmp    80022a <runcmd+0x21>
			break;
			//panic("< redirection not implemented");

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	53                   	push   %ebx
  800311:	6a 00                	push   $0x0
  800313:	e8 86 fe ff ff       	call   80019e <gettoken>
  800318:	83 c4 10             	add    $0x10,%esp
  80031b:	83 f8 77             	cmp    $0x77,%eax
  80031e:	74 15                	je     800335 <runcmd+0x12c>
				cprintf("syntax error: > not followed by word\n");
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	68 60 37 80 00       	push   $0x803760
  800328:	e8 f3 07 00 00       	call   800b20 <cprintf>
				exit();
  80032d:	e8 fb 06 00 00       	call   800a2d <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 6c 22 00 00       	call   8025b1 <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 0e 36 80 00       	push   $0x80360e
  80035a:	e8 c1 07 00 00       	call   800b20 <cprintf>
				exit();
  80035f:	e8 c9 06 00 00       	call   800a2d <exit>
  800364:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800367:	83 ff 01             	cmp    $0x1,%edi
  80036a:	0f 84 ba fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	6a 01                	push   $0x1
  800375:	57                   	push   %edi
  800376:	e8 b6 1c 00 00       	call   802031 <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 5e 1c 00 00       	call   801fe1 <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 8f 2b 00 00       	call   802f29 <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 24 36 80 00       	push   $0x803624
  8003aa:	e8 71 07 00 00       	call   800b20 <cprintf>
				exit();
  8003af:	e8 79 06 00 00       	call   800a2d <exit>
  8003b4:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003be:	74 1c                	je     8003dc <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c0:	83 ec 04             	sub    $0x4,%esp
  8003c3:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003c9:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003cf:	68 2d 36 80 00       	push   $0x80362d
  8003d4:	e8 47 07 00 00       	call   800b20 <cprintf>
  8003d9:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dc:	e8 e1 14 00 00       	call   8018c2 <fork>
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 16                	jns    8003fd <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	50                   	push   %eax
  8003eb:	68 3a 36 80 00       	push   $0x80363a
  8003f0:	e8 2b 07 00 00       	call   800b20 <cprintf>
				exit();
  8003f5:	e8 33 06 00 00       	call   800a2d <exit>
  8003fa:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003fd:	85 ff                	test   %edi,%edi
  8003ff:	75 3c                	jne    80043d <runcmd+0x234>
				if (p[0] != 0) {
  800401:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	74 1c                	je     800427 <runcmd+0x21e>
					dup(p[0], 0);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	6a 00                	push   $0x0
  800410:	50                   	push   %eax
  800411:	e8 1b 1c 00 00       	call   802031 <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 bd 1b 00 00       	call   801fe1 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 ac 1b 00 00       	call   801fe1 <close>
				goto again;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	e9 e8 fd ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80043d:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800443:	83 f8 01             	cmp    $0x1,%eax
  800446:	74 1c                	je     800464 <runcmd+0x25b>
					dup(p[1], 1);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	6a 01                	push   $0x1
  80044d:	50                   	push   %eax
  80044e:	e8 de 1b 00 00       	call   802031 <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 80 1b 00 00       	call   801fe1 <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 6f 1b 00 00       	call   801fe1 <close>
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 17                	jmp    80048e <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800477:	50                   	push   %eax
  800478:	68 43 36 80 00       	push   $0x803643
  80047d:	6a 79                	push   $0x79
  80047f:	68 5f 36 80 00       	push   $0x80365f
  800484:	e8 be 05 00 00       	call   800a47 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800489:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  80048e:	85 f6                	test   %esi,%esi
  800490:	75 22                	jne    8004b4 <runcmd+0x2ab>
		if (debug)
  800492:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800499:	0f 84 a5 01 00 00    	je     800644 <runcmd+0x43b>
			cprintf("EMPTY COMMAND\n");
  80049f:	83 ec 0c             	sub    $0xc,%esp
  8004a2:	68 69 36 80 00       	push   $0x803669
  8004a7:	e8 74 06 00 00       	call   800b20 <cprintf>
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	e9 90 01 00 00       	jmp    800644 <runcmd+0x43b>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004b4:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004b7:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004ba:	74 23                	je     8004df <runcmd+0x2d6>
		argv0buf[0] = '/';
  8004bc:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	50                   	push   %eax
  8004c7:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004cd:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004d3:	50                   	push   %eax
  8004d4:	e8 bf 0c 00 00       	call   801198 <strcpy>
		argv[0] = argv0buf;
  8004d9:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004df:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004e6:	00 

	// Print the command.
	if (debug) {
  8004e7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004ee:	74 4c                	je     80053c <runcmd+0x333>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f0:	a1 24 54 80 00       	mov    0x805424,%eax
  8004f5:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	50                   	push   %eax
  8004ff:	68 78 36 80 00       	push   $0x803678
  800504:	e8 17 06 00 00       	call   800b20 <cprintf>
  800509:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	eb 11                	jmp    800522 <runcmd+0x319>
			cprintf(" %s", argv[i]);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	50                   	push   %eax
  800515:	68 00 37 80 00       	push   $0x803700
  80051a:	e8 01 06 00 00       	call   800b20 <cprintf>
  80051f:	83 c4 10             	add    $0x10,%esp
  800522:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800525:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800528:	85 c0                	test   %eax,%eax
  80052a:	75 e5                	jne    800511 <runcmd+0x308>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  80052c:	83 ec 0c             	sub    $0xc,%esp
  80052f:	68 c0 35 80 00       	push   $0x8035c0
  800534:	e8 e7 05 00 00       	call   800b20 <cprintf>
  800539:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800542:	50                   	push   %eax
  800543:	ff 75 a8             	pushl  -0x58(%ebp)
  800546:	e8 1a 22 00 00       	call   802765 <spawn>
  80054b:	89 c3                	mov    %eax,%ebx
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	85 c0                	test   %eax,%eax
  800552:	0f 89 cf 00 00 00    	jns    800627 <runcmd+0x41e>
		cprintf("spawn %s: %e\n", argv[0], r);
  800558:	83 ec 04             	sub    $0x4,%esp
  80055b:	50                   	push   %eax
  80055c:	ff 75 a8             	pushl  -0x58(%ebp)
  80055f:	68 86 36 80 00       	push   $0x803686
  800564:	e8 b7 05 00 00       	call   800b20 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800569:	e8 9e 1a 00 00       	call   80200c <close_all>
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	eb 52                	jmp    8005c5 <runcmd+0x3bc>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800573:	a1 24 54 80 00       	mov    0x805424,%eax
  800578:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80057e:	53                   	push   %ebx
  80057f:	ff 75 a8             	pushl  -0x58(%ebp)
  800582:	50                   	push   %eax
  800583:	68 94 36 80 00       	push   $0x803694
  800588:	e8 93 05 00 00       	call   800b20 <cprintf>
  80058d:	83 c4 10             	add    $0x10,%esp
		wait(r);
  800590:	83 ec 0c             	sub    $0xc,%esp
  800593:	53                   	push   %ebx
  800594:	e8 16 2b 00 00       	call   8030af <wait>
		if (debug)
  800599:	83 c4 10             	add    $0x10,%esp
  80059c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005a3:	0f 84 95 00 00 00    	je     80063e <runcmd+0x435>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a9:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ae:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	50                   	push   %eax
  8005b8:	68 a9 36 80 00       	push   $0x8036a9
  8005bd:	e8 5e 05 00 00       	call   800b20 <cprintf>
  8005c2:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005c5:	85 ff                	test   %edi,%edi
  8005c7:	74 57                	je     800620 <runcmd+0x417>
		if (debug)
  8005c9:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005d0:	74 1d                	je     8005ef <runcmd+0x3e6>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005d2:	a1 24 54 80 00       	mov    0x805424,%eax
  8005d7:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8005dd:	83 ec 04             	sub    $0x4,%esp
  8005e0:	57                   	push   %edi
  8005e1:	50                   	push   %eax
  8005e2:	68 bf 36 80 00       	push   $0x8036bf
  8005e7:	e8 34 05 00 00       	call   800b20 <cprintf>
  8005ec:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	57                   	push   %edi
  8005f3:	e8 b7 2a 00 00       	call   8030af <wait>
		if (debug)
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800602:	74 1c                	je     800620 <runcmd+0x417>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800604:	a1 24 54 80 00       	mov    0x805424,%eax
  800609:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	50                   	push   %eax
  800613:	68 a9 36 80 00       	push   $0x8036a9
  800618:	e8 03 05 00 00       	call   800b20 <cprintf>
  80061d:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800620:	e8 08 04 00 00       	call   800a2d <exit>
  800625:	eb 1d                	jmp    800644 <runcmd+0x43b>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800627:	e8 e0 19 00 00       	call   80200c <close_all>
	if (r >= 0) {
		if (debug)
  80062c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800633:	0f 84 57 ff ff ff    	je     800590 <runcmd+0x387>
  800639:	e9 35 ff ff ff       	jmp    800573 <runcmd+0x36a>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80063e:	85 ff                	test   %edi,%edi
  800640:	75 ad                	jne    8005ef <runcmd+0x3e6>
  800642:	eb dc                	jmp    800620 <runcmd+0x417>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800644:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800647:	5b                   	pop    %ebx
  800648:	5e                   	pop    %esi
  800649:	5f                   	pop    %edi
  80064a:	5d                   	pop    %ebp
  80064b:	c3                   	ret    

0080064c <usage>:
}


void
usage(void)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800652:	68 88 37 80 00       	push   $0x803788
  800657:	e8 c4 04 00 00       	call   800b20 <cprintf>
	exit();
  80065c:	e8 cc 03 00 00       	call   800a2d <exit>
}
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	c9                   	leave  
  800665:	c3                   	ret    

00800666 <umain>:

void
umain(int argc, char **argv)
{
  800666:	55                   	push   %ebp
  800667:	89 e5                	mov    %esp,%ebp
  800669:	57                   	push   %edi
  80066a:	56                   	push   %esi
  80066b:	53                   	push   %ebx
  80066c:	83 ec 30             	sub    $0x30,%esp
  80066f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800672:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800675:	50                   	push   %eax
  800676:	57                   	push   %edi
  800677:	8d 45 08             	lea    0x8(%ebp),%eax
  80067a:	50                   	push   %eax
  80067b:	e8 6a 16 00 00       	call   801cea <argstart>
	while ((r = argnext(&args)) >= 0)
  800680:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800683:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80068a:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  80068f:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800692:	eb 2f                	jmp    8006c3 <umain+0x5d>
		switch (r) {
  800694:	83 f8 69             	cmp    $0x69,%eax
  800697:	74 25                	je     8006be <umain+0x58>
  800699:	83 f8 78             	cmp    $0x78,%eax
  80069c:	74 07                	je     8006a5 <umain+0x3f>
  80069e:	83 f8 64             	cmp    $0x64,%eax
  8006a1:	75 14                	jne    8006b7 <umain+0x51>
  8006a3:	eb 09                	jmp    8006ae <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  8006a5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  8006ac:	eb 15                	jmp    8006c3 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  8006ae:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006b5:	eb 0c                	jmp    8006c3 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006b7:	e8 90 ff ff ff       	call   80064c <usage>
  8006bc:	eb 05                	jmp    8006c3 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006be:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006c3:	83 ec 0c             	sub    $0xc,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	e8 4e 16 00 00       	call   801d1a <argnext>
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	79 c1                	jns    800694 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006d3:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d7:	7e 05                	jle    8006de <umain+0x78>
		usage();
  8006d9:	e8 6e ff ff ff       	call   80064c <usage>
	if (argc == 2) {
  8006de:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006e2:	75 56                	jne    80073a <umain+0xd4>
		close(0);
  8006e4:	83 ec 0c             	sub    $0xc,%esp
  8006e7:	6a 00                	push   $0x0
  8006e9:	e8 f3 18 00 00       	call   801fe1 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006ee:	83 c4 08             	add    $0x8,%esp
  8006f1:	6a 00                	push   $0x0
  8006f3:	ff 77 04             	pushl  0x4(%edi)
  8006f6:	e8 b6 1e 00 00       	call   8025b1 <open>
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	85 c0                	test   %eax,%eax
  800700:	79 1b                	jns    80071d <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  800702:	83 ec 0c             	sub    $0xc,%esp
  800705:	50                   	push   %eax
  800706:	ff 77 04             	pushl  0x4(%edi)
  800709:	68 dc 36 80 00       	push   $0x8036dc
  80070e:	68 29 01 00 00       	push   $0x129
  800713:	68 5f 36 80 00       	push   $0x80365f
  800718:	e8 2a 03 00 00       	call   800a47 <_panic>
		assert(r == 0);
  80071d:	85 c0                	test   %eax,%eax
  80071f:	74 19                	je     80073a <umain+0xd4>
  800721:	68 e8 36 80 00       	push   $0x8036e8
  800726:	68 ef 36 80 00       	push   $0x8036ef
  80072b:	68 2a 01 00 00       	push   $0x12a
  800730:	68 5f 36 80 00       	push   $0x80365f
  800735:	e8 0d 03 00 00       	call   800a47 <_panic>
	}
	if (interactive == '?')
  80073a:	83 fe 3f             	cmp    $0x3f,%esi
  80073d:	75 0f                	jne    80074e <umain+0xe8>
		interactive = iscons(0);
  80073f:	83 ec 0c             	sub    $0xc,%esp
  800742:	6a 00                	push   $0x0
  800744:	e8 f5 01 00 00       	call   80093e <iscons>
  800749:	89 c6                	mov    %eax,%esi
  80074b:	83 c4 10             	add    $0x10,%esp
  80074e:	85 f6                	test   %esi,%esi
  800750:	b8 00 00 00 00       	mov    $0x0,%eax
  800755:	bf 04 37 80 00       	mov    $0x803704,%edi
  80075a:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80075d:	83 ec 0c             	sub    $0xc,%esp
  800760:	57                   	push   %edi
  800761:	e8 06 09 00 00       	call   80106c <readline>
  800766:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800768:	83 c4 10             	add    $0x10,%esp
  80076b:	85 c0                	test   %eax,%eax
  80076d:	75 1e                	jne    80078d <umain+0x127>
			if (debug)
  80076f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800776:	74 10                	je     800788 <umain+0x122>
				cprintf("EXITING\n");
  800778:	83 ec 0c             	sub    $0xc,%esp
  80077b:	68 07 37 80 00       	push   $0x803707
  800780:	e8 9b 03 00 00       	call   800b20 <cprintf>
  800785:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800788:	e8 a0 02 00 00       	call   800a2d <exit>
		}
		if (debug)
  80078d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800794:	74 11                	je     8007a7 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800796:	83 ec 08             	sub    $0x8,%esp
  800799:	53                   	push   %ebx
  80079a:	68 10 37 80 00       	push   $0x803710
  80079f:	e8 7c 03 00 00       	call   800b20 <cprintf>
  8007a4:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  8007a7:	80 3b 23             	cmpb   $0x23,(%ebx)
  8007aa:	74 b1                	je     80075d <umain+0xf7>
			continue;
		if (echocmds)
  8007ac:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007b0:	74 11                	je     8007c3 <umain+0x15d>
			printf("# %s\n", buf);
  8007b2:	83 ec 08             	sub    $0x8,%esp
  8007b5:	53                   	push   %ebx
  8007b6:	68 1a 37 80 00       	push   $0x80371a
  8007bb:	e8 8f 1f 00 00       	call   80274f <printf>
  8007c0:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007c3:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007ca:	74 10                	je     8007dc <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007cc:	83 ec 0c             	sub    $0xc,%esp
  8007cf:	68 20 37 80 00       	push   $0x803720
  8007d4:	e8 47 03 00 00       	call   800b20 <cprintf>
  8007d9:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007dc:	e8 e1 10 00 00       	call   8018c2 <fork>
  8007e1:	89 c6                	mov    %eax,%esi
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	79 15                	jns    8007fc <umain+0x196>
			panic("fork: %e", r);
  8007e7:	50                   	push   %eax
  8007e8:	68 3a 36 80 00       	push   $0x80363a
  8007ed:	68 41 01 00 00       	push   $0x141
  8007f2:	68 5f 36 80 00       	push   $0x80365f
  8007f7:	e8 4b 02 00 00       	call   800a47 <_panic>
		if (debug)
  8007fc:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800803:	74 11                	je     800816 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  800805:	83 ec 08             	sub    $0x8,%esp
  800808:	50                   	push   %eax
  800809:	68 2d 37 80 00       	push   $0x80372d
  80080e:	e8 0d 03 00 00       	call   800b20 <cprintf>
  800813:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800816:	85 f6                	test   %esi,%esi
  800818:	75 16                	jne    800830 <umain+0x1ca>
			runcmd(buf);
  80081a:	83 ec 0c             	sub    $0xc,%esp
  80081d:	53                   	push   %ebx
  80081e:	e8 e6 f9 ff ff       	call   800209 <runcmd>
			exit();
  800823:	e8 05 02 00 00       	call   800a2d <exit>
  800828:	83 c4 10             	add    $0x10,%esp
  80082b:	e9 2d ff ff ff       	jmp    80075d <umain+0xf7>
		} else
			wait(r);
  800830:	83 ec 0c             	sub    $0xc,%esp
  800833:	56                   	push   %esi
  800834:	e8 76 28 00 00       	call   8030af <wait>
  800839:	83 c4 10             	add    $0x10,%esp
  80083c:	e9 1c ff ff ff       	jmp    80075d <umain+0xf7>

00800841 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800844:	b8 00 00 00 00       	mov    $0x0,%eax
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800851:	68 a9 37 80 00       	push   $0x8037a9
  800856:	ff 75 0c             	pushl  0xc(%ebp)
  800859:	e8 3a 09 00 00       	call   801198 <strcpy>
	return 0;
}
  80085e:	b8 00 00 00 00       	mov    $0x0,%eax
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	57                   	push   %edi
  800869:	56                   	push   %esi
  80086a:	53                   	push   %ebx
  80086b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800871:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800876:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80087c:	eb 2d                	jmp    8008ab <devcons_write+0x46>
		m = n - tot;
  80087e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800881:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800883:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800886:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80088b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80088e:	83 ec 04             	sub    $0x4,%esp
  800891:	53                   	push   %ebx
  800892:	03 45 0c             	add    0xc(%ebp),%eax
  800895:	50                   	push   %eax
  800896:	57                   	push   %edi
  800897:	e8 8e 0a 00 00       	call   80132a <memmove>
		sys_cputs(buf, m);
  80089c:	83 c4 08             	add    $0x8,%esp
  80089f:	53                   	push   %ebx
  8008a0:	57                   	push   %edi
  8008a1:	e8 39 0c 00 00       	call   8014df <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8008a6:	01 de                	add    %ebx,%esi
  8008a8:	83 c4 10             	add    $0x10,%esp
  8008ab:	89 f0                	mov    %esi,%eax
  8008ad:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008b0:	72 cc                	jb     80087e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008b5:	5b                   	pop    %ebx
  8008b6:	5e                   	pop    %esi
  8008b7:	5f                   	pop    %edi
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8008c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008c9:	74 2a                	je     8008f5 <devcons_read+0x3b>
  8008cb:	eb 05                	jmp    8008d2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008cd:	e8 aa 0c 00 00       	call   80157c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008d2:	e8 26 0c 00 00       	call   8014fd <sys_cgetc>
  8008d7:	85 c0                	test   %eax,%eax
  8008d9:	74 f2                	je     8008cd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008db:	85 c0                	test   %eax,%eax
  8008dd:	78 16                	js     8008f5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008df:	83 f8 04             	cmp    $0x4,%eax
  8008e2:	74 0c                	je     8008f0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e7:	88 02                	mov    %al,(%edx)
	return 1;
  8008e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8008ee:	eb 05                	jmp    8008f5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800903:	6a 01                	push   $0x1
  800905:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800908:	50                   	push   %eax
  800909:	e8 d1 0b 00 00       	call   8014df <sys_cputs>
}
  80090e:	83 c4 10             	add    $0x10,%esp
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <getchar>:

int
getchar(void)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800919:	6a 01                	push   $0x1
  80091b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80091e:	50                   	push   %eax
  80091f:	6a 00                	push   $0x0
  800921:	e8 f7 17 00 00       	call   80211d <read>
	if (r < 0)
  800926:	83 c4 10             	add    $0x10,%esp
  800929:	85 c0                	test   %eax,%eax
  80092b:	78 0f                	js     80093c <getchar+0x29>
		return r;
	if (r < 1)
  80092d:	85 c0                	test   %eax,%eax
  80092f:	7e 06                	jle    800937 <getchar+0x24>
		return -E_EOF;
	return c;
  800931:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800935:	eb 05                	jmp    80093c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800937:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80093c:	c9                   	leave  
  80093d:	c3                   	ret    

0080093e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800944:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800947:	50                   	push   %eax
  800948:	ff 75 08             	pushl  0x8(%ebp)
  80094b:	e8 64 15 00 00       	call   801eb4 <fd_lookup>
  800950:	83 c4 10             	add    $0x10,%esp
  800953:	85 c0                	test   %eax,%eax
  800955:	78 11                	js     800968 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800960:	39 10                	cmp    %edx,(%eax)
  800962:	0f 94 c0             	sete   %al
  800965:	0f b6 c0             	movzbl %al,%eax
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <opencons>:

int
opencons(void)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800970:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800973:	50                   	push   %eax
  800974:	e8 ec 14 00 00       	call   801e65 <fd_alloc>
  800979:	83 c4 10             	add    $0x10,%esp
		return r;
  80097c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80097e:	85 c0                	test   %eax,%eax
  800980:	78 3e                	js     8009c0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800982:	83 ec 04             	sub    $0x4,%esp
  800985:	68 07 04 00 00       	push   $0x407
  80098a:	ff 75 f4             	pushl  -0xc(%ebp)
  80098d:	6a 00                	push   $0x0
  80098f:	e8 07 0c 00 00       	call   80159b <sys_page_alloc>
  800994:	83 c4 10             	add    $0x10,%esp
		return r;
  800997:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800999:	85 c0                	test   %eax,%eax
  80099b:	78 23                	js     8009c0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80099d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8009a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009b2:	83 ec 0c             	sub    $0xc,%esp
  8009b5:	50                   	push   %eax
  8009b6:	e8 83 14 00 00       	call   801e3e <fd2num>
  8009bb:	89 c2                	mov    %eax,%edx
  8009bd:	83 c4 10             	add    $0x10,%esp
}
  8009c0:	89 d0                	mov    %edx,%eax
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8009cf:	e8 89 0b 00 00       	call   80155d <sys_getenvid>
  8009d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009d9:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8009df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009e4:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009e9:	85 db                	test   %ebx,%ebx
  8009eb:	7e 07                	jle    8009f4 <libmain+0x30>
		binaryname = argv[0];
  8009ed:	8b 06                	mov    (%esi),%eax
  8009ef:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009f4:	83 ec 08             	sub    $0x8,%esp
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	e8 68 fc ff ff       	call   800666 <umain>

	// exit gracefully
	exit();
  8009fe:	e8 2a 00 00 00       	call   800a2d <exit>
}
  800a03:	83 c4 10             	add    $0x10,%esp
  800a06:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a09:	5b                   	pop    %ebx
  800a0a:	5e                   	pop    %esi
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  800a13:	a1 28 54 80 00       	mov    0x805428,%eax
	func();
  800a18:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800a1a:	e8 3e 0b 00 00       	call   80155d <sys_getenvid>
  800a1f:	83 ec 0c             	sub    $0xc,%esp
  800a22:	50                   	push   %eax
  800a23:	e8 84 0d 00 00       	call   8017ac <sys_thread_free>
}
  800a28:	83 c4 10             	add    $0x10,%esp
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    

00800a2d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a33:	e8 d4 15 00 00       	call   80200c <close_all>
	sys_env_destroy(0);
  800a38:	83 ec 0c             	sub    $0xc,%esp
  800a3b:	6a 00                	push   $0x0
  800a3d:	e8 da 0a 00 00       	call   80151c <sys_env_destroy>
}
  800a42:	83 c4 10             	add    $0x10,%esp
  800a45:	c9                   	leave  
  800a46:	c3                   	ret    

00800a47 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a4c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a4f:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a55:	e8 03 0b 00 00       	call   80155d <sys_getenvid>
  800a5a:	83 ec 0c             	sub    $0xc,%esp
  800a5d:	ff 75 0c             	pushl  0xc(%ebp)
  800a60:	ff 75 08             	pushl  0x8(%ebp)
  800a63:	56                   	push   %esi
  800a64:	50                   	push   %eax
  800a65:	68 c0 37 80 00       	push   $0x8037c0
  800a6a:	e8 b1 00 00 00       	call   800b20 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a6f:	83 c4 18             	add    $0x18,%esp
  800a72:	53                   	push   %ebx
  800a73:	ff 75 10             	pushl  0x10(%ebp)
  800a76:	e8 54 00 00 00       	call   800acf <vcprintf>
	cprintf("\n");
  800a7b:	c7 04 24 c0 35 80 00 	movl   $0x8035c0,(%esp)
  800a82:	e8 99 00 00 00       	call   800b20 <cprintf>
  800a87:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a8a:	cc                   	int3   
  800a8b:	eb fd                	jmp    800a8a <_panic+0x43>

00800a8d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	53                   	push   %ebx
  800a91:	83 ec 04             	sub    $0x4,%esp
  800a94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a97:	8b 13                	mov    (%ebx),%edx
  800a99:	8d 42 01             	lea    0x1(%edx),%eax
  800a9c:	89 03                	mov    %eax,(%ebx)
  800a9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800aa5:	3d ff 00 00 00       	cmp    $0xff,%eax
  800aaa:	75 1a                	jne    800ac6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800aac:	83 ec 08             	sub    $0x8,%esp
  800aaf:	68 ff 00 00 00       	push   $0xff
  800ab4:	8d 43 08             	lea    0x8(%ebx),%eax
  800ab7:	50                   	push   %eax
  800ab8:	e8 22 0a 00 00       	call   8014df <sys_cputs>
		b->idx = 0;
  800abd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800ac3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800ac6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800aca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800ad8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800adf:	00 00 00 
	b.cnt = 0;
  800ae2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ae9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800aec:	ff 75 0c             	pushl  0xc(%ebp)
  800aef:	ff 75 08             	pushl  0x8(%ebp)
  800af2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800af8:	50                   	push   %eax
  800af9:	68 8d 0a 80 00       	push   $0x800a8d
  800afe:	e8 54 01 00 00       	call   800c57 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b03:	83 c4 08             	add    $0x8,%esp
  800b06:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800b0c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b12:	50                   	push   %eax
  800b13:	e8 c7 09 00 00       	call   8014df <sys_cputs>

	return b.cnt;
}
  800b18:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b1e:	c9                   	leave  
  800b1f:	c3                   	ret    

00800b20 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b26:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b29:	50                   	push   %eax
  800b2a:	ff 75 08             	pushl  0x8(%ebp)
  800b2d:	e8 9d ff ff ff       	call   800acf <vcprintf>
	va_end(ap);

	return cnt;
}
  800b32:	c9                   	leave  
  800b33:	c3                   	ret    

00800b34 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
  800b3a:	83 ec 1c             	sub    $0x1c,%esp
  800b3d:	89 c7                	mov    %eax,%edi
  800b3f:	89 d6                	mov    %edx,%esi
  800b41:	8b 45 08             	mov    0x8(%ebp),%eax
  800b44:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b47:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b4a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b55:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b58:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b5b:	39 d3                	cmp    %edx,%ebx
  800b5d:	72 05                	jb     800b64 <printnum+0x30>
  800b5f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b62:	77 45                	ja     800ba9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	ff 75 18             	pushl  0x18(%ebp)
  800b6a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b70:	53                   	push   %ebx
  800b71:	ff 75 10             	pushl  0x10(%ebp)
  800b74:	83 ec 08             	sub    $0x8,%esp
  800b77:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b7a:	ff 75 e0             	pushl  -0x20(%ebp)
  800b7d:	ff 75 dc             	pushl  -0x24(%ebp)
  800b80:	ff 75 d8             	pushl  -0x28(%ebp)
  800b83:	e8 78 27 00 00       	call   803300 <__udivdi3>
  800b88:	83 c4 18             	add    $0x18,%esp
  800b8b:	52                   	push   %edx
  800b8c:	50                   	push   %eax
  800b8d:	89 f2                	mov    %esi,%edx
  800b8f:	89 f8                	mov    %edi,%eax
  800b91:	e8 9e ff ff ff       	call   800b34 <printnum>
  800b96:	83 c4 20             	add    $0x20,%esp
  800b99:	eb 18                	jmp    800bb3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b9b:	83 ec 08             	sub    $0x8,%esp
  800b9e:	56                   	push   %esi
  800b9f:	ff 75 18             	pushl  0x18(%ebp)
  800ba2:	ff d7                	call   *%edi
  800ba4:	83 c4 10             	add    $0x10,%esp
  800ba7:	eb 03                	jmp    800bac <printnum+0x78>
  800ba9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800bac:	83 eb 01             	sub    $0x1,%ebx
  800baf:	85 db                	test   %ebx,%ebx
  800bb1:	7f e8                	jg     800b9b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800bb3:	83 ec 08             	sub    $0x8,%esp
  800bb6:	56                   	push   %esi
  800bb7:	83 ec 04             	sub    $0x4,%esp
  800bba:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bbd:	ff 75 e0             	pushl  -0x20(%ebp)
  800bc0:	ff 75 dc             	pushl  -0x24(%ebp)
  800bc3:	ff 75 d8             	pushl  -0x28(%ebp)
  800bc6:	e8 65 28 00 00       	call   803430 <__umoddi3>
  800bcb:	83 c4 14             	add    $0x14,%esp
  800bce:	0f be 80 e3 37 80 00 	movsbl 0x8037e3(%eax),%eax
  800bd5:	50                   	push   %eax
  800bd6:	ff d7                	call   *%edi
}
  800bd8:	83 c4 10             	add    $0x10,%esp
  800bdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800be6:	83 fa 01             	cmp    $0x1,%edx
  800be9:	7e 0e                	jle    800bf9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800beb:	8b 10                	mov    (%eax),%edx
  800bed:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bf0:	89 08                	mov    %ecx,(%eax)
  800bf2:	8b 02                	mov    (%edx),%eax
  800bf4:	8b 52 04             	mov    0x4(%edx),%edx
  800bf7:	eb 22                	jmp    800c1b <getuint+0x38>
	else if (lflag)
  800bf9:	85 d2                	test   %edx,%edx
  800bfb:	74 10                	je     800c0d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bfd:	8b 10                	mov    (%eax),%edx
  800bff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c02:	89 08                	mov    %ecx,(%eax)
  800c04:	8b 02                	mov    (%edx),%eax
  800c06:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0b:	eb 0e                	jmp    800c1b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800c0d:	8b 10                	mov    (%eax),%edx
  800c0f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c12:	89 08                	mov    %ecx,(%eax)
  800c14:	8b 02                	mov    (%edx),%eax
  800c16:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c23:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800c27:	8b 10                	mov    (%eax),%edx
  800c29:	3b 50 04             	cmp    0x4(%eax),%edx
  800c2c:	73 0a                	jae    800c38 <sprintputch+0x1b>
		*b->buf++ = ch;
  800c2e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c31:	89 08                	mov    %ecx,(%eax)
  800c33:	8b 45 08             	mov    0x8(%ebp),%eax
  800c36:	88 02                	mov    %al,(%edx)
}
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c40:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c43:	50                   	push   %eax
  800c44:	ff 75 10             	pushl  0x10(%ebp)
  800c47:	ff 75 0c             	pushl  0xc(%ebp)
  800c4a:	ff 75 08             	pushl  0x8(%ebp)
  800c4d:	e8 05 00 00 00       	call   800c57 <vprintfmt>
	va_end(ap);
}
  800c52:	83 c4 10             	add    $0x10,%esp
  800c55:	c9                   	leave  
  800c56:	c3                   	ret    

00800c57 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 2c             	sub    $0x2c,%esp
  800c60:	8b 75 08             	mov    0x8(%ebp),%esi
  800c63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c66:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c69:	eb 12                	jmp    800c7d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	0f 84 89 03 00 00    	je     800ffc <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800c73:	83 ec 08             	sub    $0x8,%esp
  800c76:	53                   	push   %ebx
  800c77:	50                   	push   %eax
  800c78:	ff d6                	call   *%esi
  800c7a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c7d:	83 c7 01             	add    $0x1,%edi
  800c80:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c84:	83 f8 25             	cmp    $0x25,%eax
  800c87:	75 e2                	jne    800c6b <vprintfmt+0x14>
  800c89:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c8d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c94:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c9b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800ca2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca7:	eb 07                	jmp    800cb0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800cac:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cb0:	8d 47 01             	lea    0x1(%edi),%eax
  800cb3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cb6:	0f b6 07             	movzbl (%edi),%eax
  800cb9:	0f b6 c8             	movzbl %al,%ecx
  800cbc:	83 e8 23             	sub    $0x23,%eax
  800cbf:	3c 55                	cmp    $0x55,%al
  800cc1:	0f 87 1a 03 00 00    	ja     800fe1 <vprintfmt+0x38a>
  800cc7:	0f b6 c0             	movzbl %al,%eax
  800cca:	ff 24 85 20 39 80 00 	jmp    *0x803920(,%eax,4)
  800cd1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800cd4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800cd8:	eb d6                	jmp    800cb0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cda:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800ce5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800ce8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800cec:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800cef:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800cf2:	83 fa 09             	cmp    $0x9,%edx
  800cf5:	77 39                	ja     800d30 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800cf7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800cfa:	eb e9                	jmp    800ce5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800cfc:	8b 45 14             	mov    0x14(%ebp),%eax
  800cff:	8d 48 04             	lea    0x4(%eax),%ecx
  800d02:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800d05:	8b 00                	mov    (%eax),%eax
  800d07:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d0a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800d0d:	eb 27                	jmp    800d36 <vprintfmt+0xdf>
  800d0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d12:	85 c0                	test   %eax,%eax
  800d14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d19:	0f 49 c8             	cmovns %eax,%ecx
  800d1c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d1f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d22:	eb 8c                	jmp    800cb0 <vprintfmt+0x59>
  800d24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d27:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800d2e:	eb 80                	jmp    800cb0 <vprintfmt+0x59>
  800d30:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d33:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800d36:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d3a:	0f 89 70 ff ff ff    	jns    800cb0 <vprintfmt+0x59>
				width = precision, precision = -1;
  800d40:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d43:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d46:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d4d:	e9 5e ff ff ff       	jmp    800cb0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d52:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d58:	e9 53 ff ff ff       	jmp    800cb0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d5d:	8b 45 14             	mov    0x14(%ebp),%eax
  800d60:	8d 50 04             	lea    0x4(%eax),%edx
  800d63:	89 55 14             	mov    %edx,0x14(%ebp)
  800d66:	83 ec 08             	sub    $0x8,%esp
  800d69:	53                   	push   %ebx
  800d6a:	ff 30                	pushl  (%eax)
  800d6c:	ff d6                	call   *%esi
			break;
  800d6e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d71:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d74:	e9 04 ff ff ff       	jmp    800c7d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d79:	8b 45 14             	mov    0x14(%ebp),%eax
  800d7c:	8d 50 04             	lea    0x4(%eax),%edx
  800d7f:	89 55 14             	mov    %edx,0x14(%ebp)
  800d82:	8b 00                	mov    (%eax),%eax
  800d84:	99                   	cltd   
  800d85:	31 d0                	xor    %edx,%eax
  800d87:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d89:	83 f8 0f             	cmp    $0xf,%eax
  800d8c:	7f 0b                	jg     800d99 <vprintfmt+0x142>
  800d8e:	8b 14 85 80 3a 80 00 	mov    0x803a80(,%eax,4),%edx
  800d95:	85 d2                	test   %edx,%edx
  800d97:	75 18                	jne    800db1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d99:	50                   	push   %eax
  800d9a:	68 fb 37 80 00       	push   $0x8037fb
  800d9f:	53                   	push   %ebx
  800da0:	56                   	push   %esi
  800da1:	e8 94 fe ff ff       	call   800c3a <printfmt>
  800da6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800da9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800dac:	e9 cc fe ff ff       	jmp    800c7d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800db1:	52                   	push   %edx
  800db2:	68 01 37 80 00       	push   $0x803701
  800db7:	53                   	push   %ebx
  800db8:	56                   	push   %esi
  800db9:	e8 7c fe ff ff       	call   800c3a <printfmt>
  800dbe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dc1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800dc4:	e9 b4 fe ff ff       	jmp    800c7d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800dc9:	8b 45 14             	mov    0x14(%ebp),%eax
  800dcc:	8d 50 04             	lea    0x4(%eax),%edx
  800dcf:	89 55 14             	mov    %edx,0x14(%ebp)
  800dd2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800dd4:	85 ff                	test   %edi,%edi
  800dd6:	b8 f4 37 80 00       	mov    $0x8037f4,%eax
  800ddb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800dde:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800de2:	0f 8e 94 00 00 00    	jle    800e7c <vprintfmt+0x225>
  800de8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800dec:	0f 84 98 00 00 00    	je     800e8a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800df2:	83 ec 08             	sub    $0x8,%esp
  800df5:	ff 75 d0             	pushl  -0x30(%ebp)
  800df8:	57                   	push   %edi
  800df9:	e8 79 03 00 00       	call   801177 <strnlen>
  800dfe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e01:	29 c1                	sub    %eax,%ecx
  800e03:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800e06:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800e09:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800e0d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e10:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e13:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e15:	eb 0f                	jmp    800e26 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800e17:	83 ec 08             	sub    $0x8,%esp
  800e1a:	53                   	push   %ebx
  800e1b:	ff 75 e0             	pushl  -0x20(%ebp)
  800e1e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e20:	83 ef 01             	sub    $0x1,%edi
  800e23:	83 c4 10             	add    $0x10,%esp
  800e26:	85 ff                	test   %edi,%edi
  800e28:	7f ed                	jg     800e17 <vprintfmt+0x1c0>
  800e2a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800e2d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800e30:	85 c9                	test   %ecx,%ecx
  800e32:	b8 00 00 00 00       	mov    $0x0,%eax
  800e37:	0f 49 c1             	cmovns %ecx,%eax
  800e3a:	29 c1                	sub    %eax,%ecx
  800e3c:	89 75 08             	mov    %esi,0x8(%ebp)
  800e3f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e42:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e45:	89 cb                	mov    %ecx,%ebx
  800e47:	eb 4d                	jmp    800e96 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e49:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e4d:	74 1b                	je     800e6a <vprintfmt+0x213>
  800e4f:	0f be c0             	movsbl %al,%eax
  800e52:	83 e8 20             	sub    $0x20,%eax
  800e55:	83 f8 5e             	cmp    $0x5e,%eax
  800e58:	76 10                	jbe    800e6a <vprintfmt+0x213>
					putch('?', putdat);
  800e5a:	83 ec 08             	sub    $0x8,%esp
  800e5d:	ff 75 0c             	pushl  0xc(%ebp)
  800e60:	6a 3f                	push   $0x3f
  800e62:	ff 55 08             	call   *0x8(%ebp)
  800e65:	83 c4 10             	add    $0x10,%esp
  800e68:	eb 0d                	jmp    800e77 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800e6a:	83 ec 08             	sub    $0x8,%esp
  800e6d:	ff 75 0c             	pushl  0xc(%ebp)
  800e70:	52                   	push   %edx
  800e71:	ff 55 08             	call   *0x8(%ebp)
  800e74:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e77:	83 eb 01             	sub    $0x1,%ebx
  800e7a:	eb 1a                	jmp    800e96 <vprintfmt+0x23f>
  800e7c:	89 75 08             	mov    %esi,0x8(%ebp)
  800e7f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e82:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e85:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e88:	eb 0c                	jmp    800e96 <vprintfmt+0x23f>
  800e8a:	89 75 08             	mov    %esi,0x8(%ebp)
  800e8d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e90:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e93:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e96:	83 c7 01             	add    $0x1,%edi
  800e99:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e9d:	0f be d0             	movsbl %al,%edx
  800ea0:	85 d2                	test   %edx,%edx
  800ea2:	74 23                	je     800ec7 <vprintfmt+0x270>
  800ea4:	85 f6                	test   %esi,%esi
  800ea6:	78 a1                	js     800e49 <vprintfmt+0x1f2>
  800ea8:	83 ee 01             	sub    $0x1,%esi
  800eab:	79 9c                	jns    800e49 <vprintfmt+0x1f2>
  800ead:	89 df                	mov    %ebx,%edi
  800eaf:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800eb5:	eb 18                	jmp    800ecf <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800eb7:	83 ec 08             	sub    $0x8,%esp
  800eba:	53                   	push   %ebx
  800ebb:	6a 20                	push   $0x20
  800ebd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ebf:	83 ef 01             	sub    $0x1,%edi
  800ec2:	83 c4 10             	add    $0x10,%esp
  800ec5:	eb 08                	jmp    800ecf <vprintfmt+0x278>
  800ec7:	89 df                	mov    %ebx,%edi
  800ec9:	8b 75 08             	mov    0x8(%ebp),%esi
  800ecc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ecf:	85 ff                	test   %edi,%edi
  800ed1:	7f e4                	jg     800eb7 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ed3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ed6:	e9 a2 fd ff ff       	jmp    800c7d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800edb:	83 fa 01             	cmp    $0x1,%edx
  800ede:	7e 16                	jle    800ef6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800ee0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ee3:	8d 50 08             	lea    0x8(%eax),%edx
  800ee6:	89 55 14             	mov    %edx,0x14(%ebp)
  800ee9:	8b 50 04             	mov    0x4(%eax),%edx
  800eec:	8b 00                	mov    (%eax),%eax
  800eee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ef1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ef4:	eb 32                	jmp    800f28 <vprintfmt+0x2d1>
	else if (lflag)
  800ef6:	85 d2                	test   %edx,%edx
  800ef8:	74 18                	je     800f12 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800efa:	8b 45 14             	mov    0x14(%ebp),%eax
  800efd:	8d 50 04             	lea    0x4(%eax),%edx
  800f00:	89 55 14             	mov    %edx,0x14(%ebp)
  800f03:	8b 00                	mov    (%eax),%eax
  800f05:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f08:	89 c1                	mov    %eax,%ecx
  800f0a:	c1 f9 1f             	sar    $0x1f,%ecx
  800f0d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800f10:	eb 16                	jmp    800f28 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800f12:	8b 45 14             	mov    0x14(%ebp),%eax
  800f15:	8d 50 04             	lea    0x4(%eax),%edx
  800f18:	89 55 14             	mov    %edx,0x14(%ebp)
  800f1b:	8b 00                	mov    (%eax),%eax
  800f1d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f20:	89 c1                	mov    %eax,%ecx
  800f22:	c1 f9 1f             	sar    $0x1f,%ecx
  800f25:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800f28:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f2b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f2e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f33:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f37:	79 74                	jns    800fad <vprintfmt+0x356>
				putch('-', putdat);
  800f39:	83 ec 08             	sub    $0x8,%esp
  800f3c:	53                   	push   %ebx
  800f3d:	6a 2d                	push   $0x2d
  800f3f:	ff d6                	call   *%esi
				num = -(long long) num;
  800f41:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f44:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f47:	f7 d8                	neg    %eax
  800f49:	83 d2 00             	adc    $0x0,%edx
  800f4c:	f7 da                	neg    %edx
  800f4e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f51:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f56:	eb 55                	jmp    800fad <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f58:	8d 45 14             	lea    0x14(%ebp),%eax
  800f5b:	e8 83 fc ff ff       	call   800be3 <getuint>
			base = 10;
  800f60:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f65:	eb 46                	jmp    800fad <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800f67:	8d 45 14             	lea    0x14(%ebp),%eax
  800f6a:	e8 74 fc ff ff       	call   800be3 <getuint>
			base = 8;
  800f6f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800f74:	eb 37                	jmp    800fad <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800f76:	83 ec 08             	sub    $0x8,%esp
  800f79:	53                   	push   %ebx
  800f7a:	6a 30                	push   $0x30
  800f7c:	ff d6                	call   *%esi
			putch('x', putdat);
  800f7e:	83 c4 08             	add    $0x8,%esp
  800f81:	53                   	push   %ebx
  800f82:	6a 78                	push   $0x78
  800f84:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f86:	8b 45 14             	mov    0x14(%ebp),%eax
  800f89:	8d 50 04             	lea    0x4(%eax),%edx
  800f8c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f8f:	8b 00                	mov    (%eax),%eax
  800f91:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f96:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f99:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f9e:	eb 0d                	jmp    800fad <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800fa0:	8d 45 14             	lea    0x14(%ebp),%eax
  800fa3:	e8 3b fc ff ff       	call   800be3 <getuint>
			base = 16;
  800fa8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800fad:	83 ec 0c             	sub    $0xc,%esp
  800fb0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800fb4:	57                   	push   %edi
  800fb5:	ff 75 e0             	pushl  -0x20(%ebp)
  800fb8:	51                   	push   %ecx
  800fb9:	52                   	push   %edx
  800fba:	50                   	push   %eax
  800fbb:	89 da                	mov    %ebx,%edx
  800fbd:	89 f0                	mov    %esi,%eax
  800fbf:	e8 70 fb ff ff       	call   800b34 <printnum>
			break;
  800fc4:	83 c4 20             	add    $0x20,%esp
  800fc7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fca:	e9 ae fc ff ff       	jmp    800c7d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fcf:	83 ec 08             	sub    $0x8,%esp
  800fd2:	53                   	push   %ebx
  800fd3:	51                   	push   %ecx
  800fd4:	ff d6                	call   *%esi
			break;
  800fd6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fd9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fdc:	e9 9c fc ff ff       	jmp    800c7d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fe1:	83 ec 08             	sub    $0x8,%esp
  800fe4:	53                   	push   %ebx
  800fe5:	6a 25                	push   $0x25
  800fe7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	eb 03                	jmp    800ff1 <vprintfmt+0x39a>
  800fee:	83 ef 01             	sub    $0x1,%edi
  800ff1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ff5:	75 f7                	jne    800fee <vprintfmt+0x397>
  800ff7:	e9 81 fc ff ff       	jmp    800c7d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800ffc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fff:	5b                   	pop    %ebx
  801000:	5e                   	pop    %esi
  801001:	5f                   	pop    %edi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	83 ec 18             	sub    $0x18,%esp
  80100a:	8b 45 08             	mov    0x8(%ebp),%eax
  80100d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801010:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801013:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801017:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80101a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801021:	85 c0                	test   %eax,%eax
  801023:	74 26                	je     80104b <vsnprintf+0x47>
  801025:	85 d2                	test   %edx,%edx
  801027:	7e 22                	jle    80104b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801029:	ff 75 14             	pushl  0x14(%ebp)
  80102c:	ff 75 10             	pushl  0x10(%ebp)
  80102f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801032:	50                   	push   %eax
  801033:	68 1d 0c 80 00       	push   $0x800c1d
  801038:	e8 1a fc ff ff       	call   800c57 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80103d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801040:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801043:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	eb 05                	jmp    801050 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80104b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801050:	c9                   	leave  
  801051:	c3                   	ret    

00801052 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801058:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80105b:	50                   	push   %eax
  80105c:	ff 75 10             	pushl  0x10(%ebp)
  80105f:	ff 75 0c             	pushl  0xc(%ebp)
  801062:	ff 75 08             	pushl  0x8(%ebp)
  801065:	e8 9a ff ff ff       	call   801004 <vsnprintf>
	va_end(ap);

	return rc;
}
  80106a:	c9                   	leave  
  80106b:	c3                   	ret    

0080106c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	57                   	push   %edi
  801070:	56                   	push   %esi
  801071:	53                   	push   %ebx
  801072:	83 ec 0c             	sub    $0xc,%esp
  801075:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801078:	85 c0                	test   %eax,%eax
  80107a:	74 13                	je     80108f <readline+0x23>
		fprintf(1, "%s", prompt);
  80107c:	83 ec 04             	sub    $0x4,%esp
  80107f:	50                   	push   %eax
  801080:	68 01 37 80 00       	push   $0x803701
  801085:	6a 01                	push   $0x1
  801087:	e8 ac 16 00 00       	call   802738 <fprintf>
  80108c:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80108f:	83 ec 0c             	sub    $0xc,%esp
  801092:	6a 00                	push   $0x0
  801094:	e8 a5 f8 ff ff       	call   80093e <iscons>
  801099:	89 c7                	mov    %eax,%edi
  80109b:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  80109e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8010a3:	e8 6b f8 ff ff       	call   800913 <getchar>
  8010a8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	79 29                	jns    8010d7 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8010ae:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  8010b3:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8010b6:	0f 84 9b 00 00 00    	je     801157 <readline+0xeb>
				cprintf("read error: %e\n", c);
  8010bc:	83 ec 08             	sub    $0x8,%esp
  8010bf:	53                   	push   %ebx
  8010c0:	68 df 3a 80 00       	push   $0x803adf
  8010c5:	e8 56 fa ff ff       	call   800b20 <cprintf>
  8010ca:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8010cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d2:	e9 80 00 00 00       	jmp    801157 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010d7:	83 f8 08             	cmp    $0x8,%eax
  8010da:	0f 94 c2             	sete   %dl
  8010dd:	83 f8 7f             	cmp    $0x7f,%eax
  8010e0:	0f 94 c0             	sete   %al
  8010e3:	08 c2                	or     %al,%dl
  8010e5:	74 1a                	je     801101 <readline+0x95>
  8010e7:	85 f6                	test   %esi,%esi
  8010e9:	7e 16                	jle    801101 <readline+0x95>
			if (echoing)
  8010eb:	85 ff                	test   %edi,%edi
  8010ed:	74 0d                	je     8010fc <readline+0x90>
				cputchar('\b');
  8010ef:	83 ec 0c             	sub    $0xc,%esp
  8010f2:	6a 08                	push   $0x8
  8010f4:	e8 fe f7 ff ff       	call   8008f7 <cputchar>
  8010f9:	83 c4 10             	add    $0x10,%esp
			i--;
  8010fc:	83 ee 01             	sub    $0x1,%esi
  8010ff:	eb a2                	jmp    8010a3 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801101:	83 fb 1f             	cmp    $0x1f,%ebx
  801104:	7e 26                	jle    80112c <readline+0xc0>
  801106:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  80110c:	7f 1e                	jg     80112c <readline+0xc0>
			if (echoing)
  80110e:	85 ff                	test   %edi,%edi
  801110:	74 0c                	je     80111e <readline+0xb2>
				cputchar(c);
  801112:	83 ec 0c             	sub    $0xc,%esp
  801115:	53                   	push   %ebx
  801116:	e8 dc f7 ff ff       	call   8008f7 <cputchar>
  80111b:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  80111e:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801124:	8d 76 01             	lea    0x1(%esi),%esi
  801127:	e9 77 ff ff ff       	jmp    8010a3 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  80112c:	83 fb 0a             	cmp    $0xa,%ebx
  80112f:	74 09                	je     80113a <readline+0xce>
  801131:	83 fb 0d             	cmp    $0xd,%ebx
  801134:	0f 85 69 ff ff ff    	jne    8010a3 <readline+0x37>
			if (echoing)
  80113a:	85 ff                	test   %edi,%edi
  80113c:	74 0d                	je     80114b <readline+0xdf>
				cputchar('\n');
  80113e:	83 ec 0c             	sub    $0xc,%esp
  801141:	6a 0a                	push   $0xa
  801143:	e8 af f7 ff ff       	call   8008f7 <cputchar>
  801148:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  80114b:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  801152:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  801157:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115a:	5b                   	pop    %ebx
  80115b:	5e                   	pop    %esi
  80115c:	5f                   	pop    %edi
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801165:	b8 00 00 00 00       	mov    $0x0,%eax
  80116a:	eb 03                	jmp    80116f <strlen+0x10>
		n++;
  80116c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80116f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801173:	75 f7                	jne    80116c <strlen+0xd>
		n++;
	return n;
}
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801180:	ba 00 00 00 00       	mov    $0x0,%edx
  801185:	eb 03                	jmp    80118a <strnlen+0x13>
		n++;
  801187:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80118a:	39 c2                	cmp    %eax,%edx
  80118c:	74 08                	je     801196 <strnlen+0x1f>
  80118e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801192:	75 f3                	jne    801187 <strnlen+0x10>
  801194:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	53                   	push   %ebx
  80119c:	8b 45 08             	mov    0x8(%ebp),%eax
  80119f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011a2:	89 c2                	mov    %eax,%edx
  8011a4:	83 c2 01             	add    $0x1,%edx
  8011a7:	83 c1 01             	add    $0x1,%ecx
  8011aa:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8011ae:	88 5a ff             	mov    %bl,-0x1(%edx)
  8011b1:	84 db                	test   %bl,%bl
  8011b3:	75 ef                	jne    8011a4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8011b5:	5b                   	pop    %ebx
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	53                   	push   %ebx
  8011bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011bf:	53                   	push   %ebx
  8011c0:	e8 9a ff ff ff       	call   80115f <strlen>
  8011c5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8011c8:	ff 75 0c             	pushl  0xc(%ebp)
  8011cb:	01 d8                	add    %ebx,%eax
  8011cd:	50                   	push   %eax
  8011ce:	e8 c5 ff ff ff       	call   801198 <strcpy>
	return dst;
}
  8011d3:	89 d8                	mov    %ebx,%eax
  8011d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d8:	c9                   	leave  
  8011d9:	c3                   	ret    

008011da <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	56                   	push   %esi
  8011de:	53                   	push   %ebx
  8011df:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e5:	89 f3                	mov    %esi,%ebx
  8011e7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011ea:	89 f2                	mov    %esi,%edx
  8011ec:	eb 0f                	jmp    8011fd <strncpy+0x23>
		*dst++ = *src;
  8011ee:	83 c2 01             	add    $0x1,%edx
  8011f1:	0f b6 01             	movzbl (%ecx),%eax
  8011f4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011f7:	80 39 01             	cmpb   $0x1,(%ecx)
  8011fa:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011fd:	39 da                	cmp    %ebx,%edx
  8011ff:	75 ed                	jne    8011ee <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801201:	89 f0                	mov    %esi,%eax
  801203:	5b                   	pop    %ebx
  801204:	5e                   	pop    %esi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	56                   	push   %esi
  80120b:	53                   	push   %ebx
  80120c:	8b 75 08             	mov    0x8(%ebp),%esi
  80120f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801212:	8b 55 10             	mov    0x10(%ebp),%edx
  801215:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801217:	85 d2                	test   %edx,%edx
  801219:	74 21                	je     80123c <strlcpy+0x35>
  80121b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80121f:	89 f2                	mov    %esi,%edx
  801221:	eb 09                	jmp    80122c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801223:	83 c2 01             	add    $0x1,%edx
  801226:	83 c1 01             	add    $0x1,%ecx
  801229:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80122c:	39 c2                	cmp    %eax,%edx
  80122e:	74 09                	je     801239 <strlcpy+0x32>
  801230:	0f b6 19             	movzbl (%ecx),%ebx
  801233:	84 db                	test   %bl,%bl
  801235:	75 ec                	jne    801223 <strlcpy+0x1c>
  801237:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801239:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80123c:	29 f0                	sub    %esi,%eax
}
  80123e:	5b                   	pop    %ebx
  80123f:	5e                   	pop    %esi
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801248:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80124b:	eb 06                	jmp    801253 <strcmp+0x11>
		p++, q++;
  80124d:	83 c1 01             	add    $0x1,%ecx
  801250:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801253:	0f b6 01             	movzbl (%ecx),%eax
  801256:	84 c0                	test   %al,%al
  801258:	74 04                	je     80125e <strcmp+0x1c>
  80125a:	3a 02                	cmp    (%edx),%al
  80125c:	74 ef                	je     80124d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80125e:	0f b6 c0             	movzbl %al,%eax
  801261:	0f b6 12             	movzbl (%edx),%edx
  801264:	29 d0                	sub    %edx,%eax
}
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	53                   	push   %ebx
  80126c:	8b 45 08             	mov    0x8(%ebp),%eax
  80126f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801272:	89 c3                	mov    %eax,%ebx
  801274:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801277:	eb 06                	jmp    80127f <strncmp+0x17>
		n--, p++, q++;
  801279:	83 c0 01             	add    $0x1,%eax
  80127c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80127f:	39 d8                	cmp    %ebx,%eax
  801281:	74 15                	je     801298 <strncmp+0x30>
  801283:	0f b6 08             	movzbl (%eax),%ecx
  801286:	84 c9                	test   %cl,%cl
  801288:	74 04                	je     80128e <strncmp+0x26>
  80128a:	3a 0a                	cmp    (%edx),%cl
  80128c:	74 eb                	je     801279 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80128e:	0f b6 00             	movzbl (%eax),%eax
  801291:	0f b6 12             	movzbl (%edx),%edx
  801294:	29 d0                	sub    %edx,%eax
  801296:	eb 05                	jmp    80129d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801298:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80129d:	5b                   	pop    %ebx
  80129e:	5d                   	pop    %ebp
  80129f:	c3                   	ret    

008012a0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012aa:	eb 07                	jmp    8012b3 <strchr+0x13>
		if (*s == c)
  8012ac:	38 ca                	cmp    %cl,%dl
  8012ae:	74 0f                	je     8012bf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012b0:	83 c0 01             	add    $0x1,%eax
  8012b3:	0f b6 10             	movzbl (%eax),%edx
  8012b6:	84 d2                	test   %dl,%dl
  8012b8:	75 f2                	jne    8012ac <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8012ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012bf:	5d                   	pop    %ebp
  8012c0:	c3                   	ret    

008012c1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012cb:	eb 03                	jmp    8012d0 <strfind+0xf>
  8012cd:	83 c0 01             	add    $0x1,%eax
  8012d0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8012d3:	38 ca                	cmp    %cl,%dl
  8012d5:	74 04                	je     8012db <strfind+0x1a>
  8012d7:	84 d2                	test   %dl,%dl
  8012d9:	75 f2                	jne    8012cd <strfind+0xc>
			break;
	return (char *) s;
}
  8012db:	5d                   	pop    %ebp
  8012dc:	c3                   	ret    

008012dd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	57                   	push   %edi
  8012e1:	56                   	push   %esi
  8012e2:	53                   	push   %ebx
  8012e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012e9:	85 c9                	test   %ecx,%ecx
  8012eb:	74 36                	je     801323 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012f3:	75 28                	jne    80131d <memset+0x40>
  8012f5:	f6 c1 03             	test   $0x3,%cl
  8012f8:	75 23                	jne    80131d <memset+0x40>
		c &= 0xFF;
  8012fa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012fe:	89 d3                	mov    %edx,%ebx
  801300:	c1 e3 08             	shl    $0x8,%ebx
  801303:	89 d6                	mov    %edx,%esi
  801305:	c1 e6 18             	shl    $0x18,%esi
  801308:	89 d0                	mov    %edx,%eax
  80130a:	c1 e0 10             	shl    $0x10,%eax
  80130d:	09 f0                	or     %esi,%eax
  80130f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801311:	89 d8                	mov    %ebx,%eax
  801313:	09 d0                	or     %edx,%eax
  801315:	c1 e9 02             	shr    $0x2,%ecx
  801318:	fc                   	cld    
  801319:	f3 ab                	rep stos %eax,%es:(%edi)
  80131b:	eb 06                	jmp    801323 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80131d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801320:	fc                   	cld    
  801321:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801323:	89 f8                	mov    %edi,%eax
  801325:	5b                   	pop    %ebx
  801326:	5e                   	pop    %esi
  801327:	5f                   	pop    %edi
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	57                   	push   %edi
  80132e:	56                   	push   %esi
  80132f:	8b 45 08             	mov    0x8(%ebp),%eax
  801332:	8b 75 0c             	mov    0xc(%ebp),%esi
  801335:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801338:	39 c6                	cmp    %eax,%esi
  80133a:	73 35                	jae    801371 <memmove+0x47>
  80133c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80133f:	39 d0                	cmp    %edx,%eax
  801341:	73 2e                	jae    801371 <memmove+0x47>
		s += n;
		d += n;
  801343:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801346:	89 d6                	mov    %edx,%esi
  801348:	09 fe                	or     %edi,%esi
  80134a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801350:	75 13                	jne    801365 <memmove+0x3b>
  801352:	f6 c1 03             	test   $0x3,%cl
  801355:	75 0e                	jne    801365 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801357:	83 ef 04             	sub    $0x4,%edi
  80135a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80135d:	c1 e9 02             	shr    $0x2,%ecx
  801360:	fd                   	std    
  801361:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801363:	eb 09                	jmp    80136e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801365:	83 ef 01             	sub    $0x1,%edi
  801368:	8d 72 ff             	lea    -0x1(%edx),%esi
  80136b:	fd                   	std    
  80136c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80136e:	fc                   	cld    
  80136f:	eb 1d                	jmp    80138e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801371:	89 f2                	mov    %esi,%edx
  801373:	09 c2                	or     %eax,%edx
  801375:	f6 c2 03             	test   $0x3,%dl
  801378:	75 0f                	jne    801389 <memmove+0x5f>
  80137a:	f6 c1 03             	test   $0x3,%cl
  80137d:	75 0a                	jne    801389 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80137f:	c1 e9 02             	shr    $0x2,%ecx
  801382:	89 c7                	mov    %eax,%edi
  801384:	fc                   	cld    
  801385:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801387:	eb 05                	jmp    80138e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801389:	89 c7                	mov    %eax,%edi
  80138b:	fc                   	cld    
  80138c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80138e:	5e                   	pop    %esi
  80138f:	5f                   	pop    %edi
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801395:	ff 75 10             	pushl  0x10(%ebp)
  801398:	ff 75 0c             	pushl  0xc(%ebp)
  80139b:	ff 75 08             	pushl  0x8(%ebp)
  80139e:	e8 87 ff ff ff       	call   80132a <memmove>
}
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	56                   	push   %esi
  8013a9:	53                   	push   %ebx
  8013aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013b0:	89 c6                	mov    %eax,%esi
  8013b2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013b5:	eb 1a                	jmp    8013d1 <memcmp+0x2c>
		if (*s1 != *s2)
  8013b7:	0f b6 08             	movzbl (%eax),%ecx
  8013ba:	0f b6 1a             	movzbl (%edx),%ebx
  8013bd:	38 d9                	cmp    %bl,%cl
  8013bf:	74 0a                	je     8013cb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8013c1:	0f b6 c1             	movzbl %cl,%eax
  8013c4:	0f b6 db             	movzbl %bl,%ebx
  8013c7:	29 d8                	sub    %ebx,%eax
  8013c9:	eb 0f                	jmp    8013da <memcmp+0x35>
		s1++, s2++;
  8013cb:	83 c0 01             	add    $0x1,%eax
  8013ce:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013d1:	39 f0                	cmp    %esi,%eax
  8013d3:	75 e2                	jne    8013b7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013da:	5b                   	pop    %ebx
  8013db:	5e                   	pop    %esi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	53                   	push   %ebx
  8013e2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8013e5:	89 c1                	mov    %eax,%ecx
  8013e7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8013ea:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013ee:	eb 0a                	jmp    8013fa <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013f0:	0f b6 10             	movzbl (%eax),%edx
  8013f3:	39 da                	cmp    %ebx,%edx
  8013f5:	74 07                	je     8013fe <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013f7:	83 c0 01             	add    $0x1,%eax
  8013fa:	39 c8                	cmp    %ecx,%eax
  8013fc:	72 f2                	jb     8013f0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013fe:	5b                   	pop    %ebx
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    

00801401 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	57                   	push   %edi
  801405:	56                   	push   %esi
  801406:	53                   	push   %ebx
  801407:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80140a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80140d:	eb 03                	jmp    801412 <strtol+0x11>
		s++;
  80140f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801412:	0f b6 01             	movzbl (%ecx),%eax
  801415:	3c 20                	cmp    $0x20,%al
  801417:	74 f6                	je     80140f <strtol+0xe>
  801419:	3c 09                	cmp    $0x9,%al
  80141b:	74 f2                	je     80140f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80141d:	3c 2b                	cmp    $0x2b,%al
  80141f:	75 0a                	jne    80142b <strtol+0x2a>
		s++;
  801421:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801424:	bf 00 00 00 00       	mov    $0x0,%edi
  801429:	eb 11                	jmp    80143c <strtol+0x3b>
  80142b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801430:	3c 2d                	cmp    $0x2d,%al
  801432:	75 08                	jne    80143c <strtol+0x3b>
		s++, neg = 1;
  801434:	83 c1 01             	add    $0x1,%ecx
  801437:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80143c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801442:	75 15                	jne    801459 <strtol+0x58>
  801444:	80 39 30             	cmpb   $0x30,(%ecx)
  801447:	75 10                	jne    801459 <strtol+0x58>
  801449:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80144d:	75 7c                	jne    8014cb <strtol+0xca>
		s += 2, base = 16;
  80144f:	83 c1 02             	add    $0x2,%ecx
  801452:	bb 10 00 00 00       	mov    $0x10,%ebx
  801457:	eb 16                	jmp    80146f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801459:	85 db                	test   %ebx,%ebx
  80145b:	75 12                	jne    80146f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80145d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801462:	80 39 30             	cmpb   $0x30,(%ecx)
  801465:	75 08                	jne    80146f <strtol+0x6e>
		s++, base = 8;
  801467:	83 c1 01             	add    $0x1,%ecx
  80146a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80146f:	b8 00 00 00 00       	mov    $0x0,%eax
  801474:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801477:	0f b6 11             	movzbl (%ecx),%edx
  80147a:	8d 72 d0             	lea    -0x30(%edx),%esi
  80147d:	89 f3                	mov    %esi,%ebx
  80147f:	80 fb 09             	cmp    $0x9,%bl
  801482:	77 08                	ja     80148c <strtol+0x8b>
			dig = *s - '0';
  801484:	0f be d2             	movsbl %dl,%edx
  801487:	83 ea 30             	sub    $0x30,%edx
  80148a:	eb 22                	jmp    8014ae <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80148c:	8d 72 9f             	lea    -0x61(%edx),%esi
  80148f:	89 f3                	mov    %esi,%ebx
  801491:	80 fb 19             	cmp    $0x19,%bl
  801494:	77 08                	ja     80149e <strtol+0x9d>
			dig = *s - 'a' + 10;
  801496:	0f be d2             	movsbl %dl,%edx
  801499:	83 ea 57             	sub    $0x57,%edx
  80149c:	eb 10                	jmp    8014ae <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80149e:	8d 72 bf             	lea    -0x41(%edx),%esi
  8014a1:	89 f3                	mov    %esi,%ebx
  8014a3:	80 fb 19             	cmp    $0x19,%bl
  8014a6:	77 16                	ja     8014be <strtol+0xbd>
			dig = *s - 'A' + 10;
  8014a8:	0f be d2             	movsbl %dl,%edx
  8014ab:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8014ae:	3b 55 10             	cmp    0x10(%ebp),%edx
  8014b1:	7d 0b                	jge    8014be <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8014b3:	83 c1 01             	add    $0x1,%ecx
  8014b6:	0f af 45 10          	imul   0x10(%ebp),%eax
  8014ba:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8014bc:	eb b9                	jmp    801477 <strtol+0x76>

	if (endptr)
  8014be:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014c2:	74 0d                	je     8014d1 <strtol+0xd0>
		*endptr = (char *) s;
  8014c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014c7:	89 0e                	mov    %ecx,(%esi)
  8014c9:	eb 06                	jmp    8014d1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014cb:	85 db                	test   %ebx,%ebx
  8014cd:	74 98                	je     801467 <strtol+0x66>
  8014cf:	eb 9e                	jmp    80146f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8014d1:	89 c2                	mov    %eax,%edx
  8014d3:	f7 da                	neg    %edx
  8014d5:	85 ff                	test   %edi,%edi
  8014d7:	0f 45 c2             	cmovne %edx,%eax
}
  8014da:	5b                   	pop    %ebx
  8014db:	5e                   	pop    %esi
  8014dc:	5f                   	pop    %edi
  8014dd:	5d                   	pop    %ebp
  8014de:	c3                   	ret    

008014df <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	57                   	push   %edi
  8014e3:	56                   	push   %esi
  8014e4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f0:	89 c3                	mov    %eax,%ebx
  8014f2:	89 c7                	mov    %eax,%edi
  8014f4:	89 c6                	mov    %eax,%esi
  8014f6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014f8:	5b                   	pop    %ebx
  8014f9:	5e                   	pop    %esi
  8014fa:	5f                   	pop    %edi
  8014fb:	5d                   	pop    %ebp
  8014fc:	c3                   	ret    

008014fd <sys_cgetc>:

int
sys_cgetc(void)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	57                   	push   %edi
  801501:	56                   	push   %esi
  801502:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801503:	ba 00 00 00 00       	mov    $0x0,%edx
  801508:	b8 01 00 00 00       	mov    $0x1,%eax
  80150d:	89 d1                	mov    %edx,%ecx
  80150f:	89 d3                	mov    %edx,%ebx
  801511:	89 d7                	mov    %edx,%edi
  801513:	89 d6                	mov    %edx,%esi
  801515:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801517:	5b                   	pop    %ebx
  801518:	5e                   	pop    %esi
  801519:	5f                   	pop    %edi
  80151a:	5d                   	pop    %ebp
  80151b:	c3                   	ret    

0080151c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	57                   	push   %edi
  801520:	56                   	push   %esi
  801521:	53                   	push   %ebx
  801522:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801525:	b9 00 00 00 00       	mov    $0x0,%ecx
  80152a:	b8 03 00 00 00       	mov    $0x3,%eax
  80152f:	8b 55 08             	mov    0x8(%ebp),%edx
  801532:	89 cb                	mov    %ecx,%ebx
  801534:	89 cf                	mov    %ecx,%edi
  801536:	89 ce                	mov    %ecx,%esi
  801538:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80153a:	85 c0                	test   %eax,%eax
  80153c:	7e 17                	jle    801555 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80153e:	83 ec 0c             	sub    $0xc,%esp
  801541:	50                   	push   %eax
  801542:	6a 03                	push   $0x3
  801544:	68 ef 3a 80 00       	push   $0x803aef
  801549:	6a 23                	push   $0x23
  80154b:	68 0c 3b 80 00       	push   $0x803b0c
  801550:	e8 f2 f4 ff ff       	call   800a47 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801555:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801558:	5b                   	pop    %ebx
  801559:	5e                   	pop    %esi
  80155a:	5f                   	pop    %edi
  80155b:	5d                   	pop    %ebp
  80155c:	c3                   	ret    

0080155d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	57                   	push   %edi
  801561:	56                   	push   %esi
  801562:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801563:	ba 00 00 00 00       	mov    $0x0,%edx
  801568:	b8 02 00 00 00       	mov    $0x2,%eax
  80156d:	89 d1                	mov    %edx,%ecx
  80156f:	89 d3                	mov    %edx,%ebx
  801571:	89 d7                	mov    %edx,%edi
  801573:	89 d6                	mov    %edx,%esi
  801575:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801577:	5b                   	pop    %ebx
  801578:	5e                   	pop    %esi
  801579:	5f                   	pop    %edi
  80157a:	5d                   	pop    %ebp
  80157b:	c3                   	ret    

0080157c <sys_yield>:

void
sys_yield(void)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	57                   	push   %edi
  801580:	56                   	push   %esi
  801581:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801582:	ba 00 00 00 00       	mov    $0x0,%edx
  801587:	b8 0b 00 00 00       	mov    $0xb,%eax
  80158c:	89 d1                	mov    %edx,%ecx
  80158e:	89 d3                	mov    %edx,%ebx
  801590:	89 d7                	mov    %edx,%edi
  801592:	89 d6                	mov    %edx,%esi
  801594:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801596:	5b                   	pop    %ebx
  801597:	5e                   	pop    %esi
  801598:	5f                   	pop    %edi
  801599:	5d                   	pop    %ebp
  80159a:	c3                   	ret    

0080159b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	57                   	push   %edi
  80159f:	56                   	push   %esi
  8015a0:	53                   	push   %ebx
  8015a1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015a4:	be 00 00 00 00       	mov    $0x0,%esi
  8015a9:	b8 04 00 00 00       	mov    $0x4,%eax
  8015ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015b7:	89 f7                	mov    %esi,%edi
  8015b9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	7e 17                	jle    8015d6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015bf:	83 ec 0c             	sub    $0xc,%esp
  8015c2:	50                   	push   %eax
  8015c3:	6a 04                	push   $0x4
  8015c5:	68 ef 3a 80 00       	push   $0x803aef
  8015ca:	6a 23                	push   $0x23
  8015cc:	68 0c 3b 80 00       	push   $0x803b0c
  8015d1:	e8 71 f4 ff ff       	call   800a47 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d9:	5b                   	pop    %ebx
  8015da:	5e                   	pop    %esi
  8015db:	5f                   	pop    %edi
  8015dc:	5d                   	pop    %ebp
  8015dd:	c3                   	ret    

008015de <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	57                   	push   %edi
  8015e2:	56                   	push   %esi
  8015e3:	53                   	push   %ebx
  8015e4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8015ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8015f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015f5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015f8:	8b 75 18             	mov    0x18(%ebp),%esi
  8015fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	7e 17                	jle    801618 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801601:	83 ec 0c             	sub    $0xc,%esp
  801604:	50                   	push   %eax
  801605:	6a 05                	push   $0x5
  801607:	68 ef 3a 80 00       	push   $0x803aef
  80160c:	6a 23                	push   $0x23
  80160e:	68 0c 3b 80 00       	push   $0x803b0c
  801613:	e8 2f f4 ff ff       	call   800a47 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801618:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5e                   	pop    %esi
  80161d:	5f                   	pop    %edi
  80161e:	5d                   	pop    %ebp
  80161f:	c3                   	ret    

00801620 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	57                   	push   %edi
  801624:	56                   	push   %esi
  801625:	53                   	push   %ebx
  801626:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801629:	bb 00 00 00 00       	mov    $0x0,%ebx
  80162e:	b8 06 00 00 00       	mov    $0x6,%eax
  801633:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801636:	8b 55 08             	mov    0x8(%ebp),%edx
  801639:	89 df                	mov    %ebx,%edi
  80163b:	89 de                	mov    %ebx,%esi
  80163d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80163f:	85 c0                	test   %eax,%eax
  801641:	7e 17                	jle    80165a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801643:	83 ec 0c             	sub    $0xc,%esp
  801646:	50                   	push   %eax
  801647:	6a 06                	push   $0x6
  801649:	68 ef 3a 80 00       	push   $0x803aef
  80164e:	6a 23                	push   $0x23
  801650:	68 0c 3b 80 00       	push   $0x803b0c
  801655:	e8 ed f3 ff ff       	call   800a47 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80165a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5f                   	pop    %edi
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    

00801662 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	57                   	push   %edi
  801666:	56                   	push   %esi
  801667:	53                   	push   %ebx
  801668:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80166b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801670:	b8 08 00 00 00       	mov    $0x8,%eax
  801675:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801678:	8b 55 08             	mov    0x8(%ebp),%edx
  80167b:	89 df                	mov    %ebx,%edi
  80167d:	89 de                	mov    %ebx,%esi
  80167f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801681:	85 c0                	test   %eax,%eax
  801683:	7e 17                	jle    80169c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801685:	83 ec 0c             	sub    $0xc,%esp
  801688:	50                   	push   %eax
  801689:	6a 08                	push   $0x8
  80168b:	68 ef 3a 80 00       	push   $0x803aef
  801690:	6a 23                	push   $0x23
  801692:	68 0c 3b 80 00       	push   $0x803b0c
  801697:	e8 ab f3 ff ff       	call   800a47 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80169c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80169f:	5b                   	pop    %ebx
  8016a0:	5e                   	pop    %esi
  8016a1:	5f                   	pop    %edi
  8016a2:	5d                   	pop    %ebp
  8016a3:	c3                   	ret    

008016a4 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	57                   	push   %edi
  8016a8:	56                   	push   %esi
  8016a9:	53                   	push   %ebx
  8016aa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b2:	b8 09 00 00 00       	mov    $0x9,%eax
  8016b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8016bd:	89 df                	mov    %ebx,%edi
  8016bf:	89 de                	mov    %ebx,%esi
  8016c1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	7e 17                	jle    8016de <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016c7:	83 ec 0c             	sub    $0xc,%esp
  8016ca:	50                   	push   %eax
  8016cb:	6a 09                	push   $0x9
  8016cd:	68 ef 3a 80 00       	push   $0x803aef
  8016d2:	6a 23                	push   $0x23
  8016d4:	68 0c 3b 80 00       	push   $0x803b0c
  8016d9:	e8 69 f3 ff ff       	call   800a47 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e1:	5b                   	pop    %ebx
  8016e2:	5e                   	pop    %esi
  8016e3:	5f                   	pop    %edi
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    

008016e6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	57                   	push   %edi
  8016ea:	56                   	push   %esi
  8016eb:	53                   	push   %ebx
  8016ec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016f4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8016ff:	89 df                	mov    %ebx,%edi
  801701:	89 de                	mov    %ebx,%esi
  801703:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801705:	85 c0                	test   %eax,%eax
  801707:	7e 17                	jle    801720 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801709:	83 ec 0c             	sub    $0xc,%esp
  80170c:	50                   	push   %eax
  80170d:	6a 0a                	push   $0xa
  80170f:	68 ef 3a 80 00       	push   $0x803aef
  801714:	6a 23                	push   $0x23
  801716:	68 0c 3b 80 00       	push   $0x803b0c
  80171b:	e8 27 f3 ff ff       	call   800a47 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801723:	5b                   	pop    %ebx
  801724:	5e                   	pop    %esi
  801725:	5f                   	pop    %edi
  801726:	5d                   	pop    %ebp
  801727:	c3                   	ret    

00801728 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	57                   	push   %edi
  80172c:	56                   	push   %esi
  80172d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80172e:	be 00 00 00 00       	mov    $0x0,%esi
  801733:	b8 0c 00 00 00       	mov    $0xc,%eax
  801738:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173b:	8b 55 08             	mov    0x8(%ebp),%edx
  80173e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801741:	8b 7d 14             	mov    0x14(%ebp),%edi
  801744:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801746:	5b                   	pop    %ebx
  801747:	5e                   	pop    %esi
  801748:	5f                   	pop    %edi
  801749:	5d                   	pop    %ebp
  80174a:	c3                   	ret    

0080174b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	57                   	push   %edi
  80174f:	56                   	push   %esi
  801750:	53                   	push   %ebx
  801751:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801754:	b9 00 00 00 00       	mov    $0x0,%ecx
  801759:	b8 0d 00 00 00       	mov    $0xd,%eax
  80175e:	8b 55 08             	mov    0x8(%ebp),%edx
  801761:	89 cb                	mov    %ecx,%ebx
  801763:	89 cf                	mov    %ecx,%edi
  801765:	89 ce                	mov    %ecx,%esi
  801767:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801769:	85 c0                	test   %eax,%eax
  80176b:	7e 17                	jle    801784 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80176d:	83 ec 0c             	sub    $0xc,%esp
  801770:	50                   	push   %eax
  801771:	6a 0d                	push   $0xd
  801773:	68 ef 3a 80 00       	push   $0x803aef
  801778:	6a 23                	push   $0x23
  80177a:	68 0c 3b 80 00       	push   $0x803b0c
  80177f:	e8 c3 f2 ff ff       	call   800a47 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801784:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801787:	5b                   	pop    %ebx
  801788:	5e                   	pop    %esi
  801789:	5f                   	pop    %edi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	57                   	push   %edi
  801790:	56                   	push   %esi
  801791:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801792:	b9 00 00 00 00       	mov    $0x0,%ecx
  801797:	b8 0e 00 00 00       	mov    $0xe,%eax
  80179c:	8b 55 08             	mov    0x8(%ebp),%edx
  80179f:	89 cb                	mov    %ecx,%ebx
  8017a1:	89 cf                	mov    %ecx,%edi
  8017a3:	89 ce                	mov    %ecx,%esi
  8017a5:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  8017a7:	5b                   	pop    %ebx
  8017a8:	5e                   	pop    %esi
  8017a9:	5f                   	pop    %edi
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	57                   	push   %edi
  8017b0:	56                   	push   %esi
  8017b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017b7:	b8 0f 00 00 00       	mov    $0xf,%eax
  8017bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8017bf:	89 cb                	mov    %ecx,%ebx
  8017c1:	89 cf                	mov    %ecx,%edi
  8017c3:	89 ce                	mov    %ecx,%esi
  8017c5:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8017c7:	5b                   	pop    %ebx
  8017c8:	5e                   	pop    %esi
  8017c9:	5f                   	pop    %edi
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	57                   	push   %edi
  8017d0:	56                   	push   %esi
  8017d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017d7:	b8 10 00 00 00       	mov    $0x10,%eax
  8017dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8017df:	89 cb                	mov    %ecx,%ebx
  8017e1:	89 cf                	mov    %ecx,%edi
  8017e3:	89 ce                	mov    %ecx,%esi
  8017e5:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  8017e7:	5b                   	pop    %ebx
  8017e8:	5e                   	pop    %esi
  8017e9:	5f                   	pop    %edi
  8017ea:	5d                   	pop    %ebp
  8017eb:	c3                   	ret    

008017ec <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	53                   	push   %ebx
  8017f0:	83 ec 04             	sub    $0x4,%esp
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8017f6:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8017f8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8017fc:	74 11                	je     80180f <pgfault+0x23>
  8017fe:	89 d8                	mov    %ebx,%eax
  801800:	c1 e8 0c             	shr    $0xc,%eax
  801803:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80180a:	f6 c4 08             	test   $0x8,%ah
  80180d:	75 14                	jne    801823 <pgfault+0x37>
		panic("faulting access");
  80180f:	83 ec 04             	sub    $0x4,%esp
  801812:	68 1a 3b 80 00       	push   $0x803b1a
  801817:	6a 1f                	push   $0x1f
  801819:	68 2a 3b 80 00       	push   $0x803b2a
  80181e:	e8 24 f2 ff ff       	call   800a47 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  801823:	83 ec 04             	sub    $0x4,%esp
  801826:	6a 07                	push   $0x7
  801828:	68 00 f0 7f 00       	push   $0x7ff000
  80182d:	6a 00                	push   $0x0
  80182f:	e8 67 fd ff ff       	call   80159b <sys_page_alloc>
	if (r < 0) {
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	85 c0                	test   %eax,%eax
  801839:	79 12                	jns    80184d <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  80183b:	50                   	push   %eax
  80183c:	68 35 3b 80 00       	push   $0x803b35
  801841:	6a 2d                	push   $0x2d
  801843:	68 2a 3b 80 00       	push   $0x803b2a
  801848:	e8 fa f1 ff ff       	call   800a47 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80184d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  801853:	83 ec 04             	sub    $0x4,%esp
  801856:	68 00 10 00 00       	push   $0x1000
  80185b:	53                   	push   %ebx
  80185c:	68 00 f0 7f 00       	push   $0x7ff000
  801861:	e8 2c fb ff ff       	call   801392 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801866:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80186d:	53                   	push   %ebx
  80186e:	6a 00                	push   $0x0
  801870:	68 00 f0 7f 00       	push   $0x7ff000
  801875:	6a 00                	push   $0x0
  801877:	e8 62 fd ff ff       	call   8015de <sys_page_map>
	if (r < 0) {
  80187c:	83 c4 20             	add    $0x20,%esp
  80187f:	85 c0                	test   %eax,%eax
  801881:	79 12                	jns    801895 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  801883:	50                   	push   %eax
  801884:	68 35 3b 80 00       	push   $0x803b35
  801889:	6a 34                	push   $0x34
  80188b:	68 2a 3b 80 00       	push   $0x803b2a
  801890:	e8 b2 f1 ff ff       	call   800a47 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  801895:	83 ec 08             	sub    $0x8,%esp
  801898:	68 00 f0 7f 00       	push   $0x7ff000
  80189d:	6a 00                	push   $0x0
  80189f:	e8 7c fd ff ff       	call   801620 <sys_page_unmap>
	if (r < 0) {
  8018a4:	83 c4 10             	add    $0x10,%esp
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	79 12                	jns    8018bd <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  8018ab:	50                   	push   %eax
  8018ac:	68 35 3b 80 00       	push   $0x803b35
  8018b1:	6a 38                	push   $0x38
  8018b3:	68 2a 3b 80 00       	push   $0x803b2a
  8018b8:	e8 8a f1 ff ff       	call   800a47 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8018bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c0:	c9                   	leave  
  8018c1:	c3                   	ret    

008018c2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	57                   	push   %edi
  8018c6:	56                   	push   %esi
  8018c7:	53                   	push   %ebx
  8018c8:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8018cb:	68 ec 17 80 00       	push   $0x8017ec
  8018d0:	e8 32 18 00 00       	call   803107 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8018d5:	b8 07 00 00 00       	mov    $0x7,%eax
  8018da:	cd 30                	int    $0x30
  8018dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	79 17                	jns    8018fd <fork+0x3b>
		panic("fork fault %e");
  8018e6:	83 ec 04             	sub    $0x4,%esp
  8018e9:	68 4e 3b 80 00       	push   $0x803b4e
  8018ee:	68 85 00 00 00       	push   $0x85
  8018f3:	68 2a 3b 80 00       	push   $0x803b2a
  8018f8:	e8 4a f1 ff ff       	call   800a47 <_panic>
  8018fd:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8018ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801903:	75 24                	jne    801929 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  801905:	e8 53 fc ff ff       	call   80155d <sys_getenvid>
  80190a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80190f:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  801915:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80191a:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  80191f:	b8 00 00 00 00       	mov    $0x0,%eax
  801924:	e9 64 01 00 00       	jmp    801a8d <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801929:	83 ec 04             	sub    $0x4,%esp
  80192c:	6a 07                	push   $0x7
  80192e:	68 00 f0 bf ee       	push   $0xeebff000
  801933:	ff 75 e4             	pushl  -0x1c(%ebp)
  801936:	e8 60 fc ff ff       	call   80159b <sys_page_alloc>
  80193b:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80193e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801943:	89 d8                	mov    %ebx,%eax
  801945:	c1 e8 16             	shr    $0x16,%eax
  801948:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80194f:	a8 01                	test   $0x1,%al
  801951:	0f 84 fc 00 00 00    	je     801a53 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801957:	89 d8                	mov    %ebx,%eax
  801959:	c1 e8 0c             	shr    $0xc,%eax
  80195c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801963:	f6 c2 01             	test   $0x1,%dl
  801966:	0f 84 e7 00 00 00    	je     801a53 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80196c:	89 c6                	mov    %eax,%esi
  80196e:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801971:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801978:	f6 c6 04             	test   $0x4,%dh
  80197b:	74 39                	je     8019b6 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80197d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801984:	83 ec 0c             	sub    $0xc,%esp
  801987:	25 07 0e 00 00       	and    $0xe07,%eax
  80198c:	50                   	push   %eax
  80198d:	56                   	push   %esi
  80198e:	57                   	push   %edi
  80198f:	56                   	push   %esi
  801990:	6a 00                	push   $0x0
  801992:	e8 47 fc ff ff       	call   8015de <sys_page_map>
		if (r < 0) {
  801997:	83 c4 20             	add    $0x20,%esp
  80199a:	85 c0                	test   %eax,%eax
  80199c:	0f 89 b1 00 00 00    	jns    801a53 <fork+0x191>
		    	panic("sys page map fault %e");
  8019a2:	83 ec 04             	sub    $0x4,%esp
  8019a5:	68 5c 3b 80 00       	push   $0x803b5c
  8019aa:	6a 55                	push   $0x55
  8019ac:	68 2a 3b 80 00       	push   $0x803b2a
  8019b1:	e8 91 f0 ff ff       	call   800a47 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8019b6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019bd:	f6 c2 02             	test   $0x2,%dl
  8019c0:	75 0c                	jne    8019ce <fork+0x10c>
  8019c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019c9:	f6 c4 08             	test   $0x8,%ah
  8019cc:	74 5b                	je     801a29 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8019ce:	83 ec 0c             	sub    $0xc,%esp
  8019d1:	68 05 08 00 00       	push   $0x805
  8019d6:	56                   	push   %esi
  8019d7:	57                   	push   %edi
  8019d8:	56                   	push   %esi
  8019d9:	6a 00                	push   $0x0
  8019db:	e8 fe fb ff ff       	call   8015de <sys_page_map>
		if (r < 0) {
  8019e0:	83 c4 20             	add    $0x20,%esp
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	79 14                	jns    8019fb <fork+0x139>
		    	panic("sys page map fault %e");
  8019e7:	83 ec 04             	sub    $0x4,%esp
  8019ea:	68 5c 3b 80 00       	push   $0x803b5c
  8019ef:	6a 5c                	push   $0x5c
  8019f1:	68 2a 3b 80 00       	push   $0x803b2a
  8019f6:	e8 4c f0 ff ff       	call   800a47 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8019fb:	83 ec 0c             	sub    $0xc,%esp
  8019fe:	68 05 08 00 00       	push   $0x805
  801a03:	56                   	push   %esi
  801a04:	6a 00                	push   $0x0
  801a06:	56                   	push   %esi
  801a07:	6a 00                	push   $0x0
  801a09:	e8 d0 fb ff ff       	call   8015de <sys_page_map>
		if (r < 0) {
  801a0e:	83 c4 20             	add    $0x20,%esp
  801a11:	85 c0                	test   %eax,%eax
  801a13:	79 3e                	jns    801a53 <fork+0x191>
		    	panic("sys page map fault %e");
  801a15:	83 ec 04             	sub    $0x4,%esp
  801a18:	68 5c 3b 80 00       	push   $0x803b5c
  801a1d:	6a 60                	push   $0x60
  801a1f:	68 2a 3b 80 00       	push   $0x803b2a
  801a24:	e8 1e f0 ff ff       	call   800a47 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801a29:	83 ec 0c             	sub    $0xc,%esp
  801a2c:	6a 05                	push   $0x5
  801a2e:	56                   	push   %esi
  801a2f:	57                   	push   %edi
  801a30:	56                   	push   %esi
  801a31:	6a 00                	push   $0x0
  801a33:	e8 a6 fb ff ff       	call   8015de <sys_page_map>
		if (r < 0) {
  801a38:	83 c4 20             	add    $0x20,%esp
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	79 14                	jns    801a53 <fork+0x191>
		    	panic("sys page map fault %e");
  801a3f:	83 ec 04             	sub    $0x4,%esp
  801a42:	68 5c 3b 80 00       	push   $0x803b5c
  801a47:	6a 65                	push   $0x65
  801a49:	68 2a 3b 80 00       	push   $0x803b2a
  801a4e:	e8 f4 ef ff ff       	call   800a47 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801a53:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a59:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801a5f:	0f 85 de fe ff ff    	jne    801943 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801a65:	a1 24 54 80 00       	mov    0x805424,%eax
  801a6a:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801a70:	83 ec 08             	sub    $0x8,%esp
  801a73:	50                   	push   %eax
  801a74:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a77:	57                   	push   %edi
  801a78:	e8 69 fc ff ff       	call   8016e6 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801a7d:	83 c4 08             	add    $0x8,%esp
  801a80:	6a 02                	push   $0x2
  801a82:	57                   	push   %edi
  801a83:	e8 da fb ff ff       	call   801662 <sys_env_set_status>
	
	return envid;
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801a8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a90:	5b                   	pop    %ebx
  801a91:	5e                   	pop    %esi
  801a92:	5f                   	pop    %edi
  801a93:	5d                   	pop    %ebp
  801a94:	c3                   	ret    

00801a95 <sfork>:

envid_t
sfork(void)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801a98:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9d:	5d                   	pop    %ebp
  801a9e:	c3                   	ret    

00801a9f <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  801aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa8:	a3 28 54 80 00       	mov    %eax,0x805428
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801aad:	68 0d 0a 80 00       	push   $0x800a0d
  801ab2:	e8 d5 fc ff ff       	call   80178c <sys_thread_create>

	return id;
}
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  801abf:	ff 75 08             	pushl  0x8(%ebp)
  801ac2:	e8 e5 fc ff ff       	call   8017ac <sys_thread_free>
}
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	c9                   	leave  
  801acb:	c3                   	ret    

00801acc <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  801ad2:	ff 75 08             	pushl  0x8(%ebp)
  801ad5:	e8 f2 fc ff ff       	call   8017cc <sys_thread_join>
}
  801ada:	83 c4 10             	add    $0x10,%esp
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ae7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801aea:	83 ec 04             	sub    $0x4,%esp
  801aed:	6a 07                	push   $0x7
  801aef:	6a 00                	push   $0x0
  801af1:	56                   	push   %esi
  801af2:	e8 a4 fa ff ff       	call   80159b <sys_page_alloc>
	if (r < 0) {
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	85 c0                	test   %eax,%eax
  801afc:	79 15                	jns    801b13 <queue_append+0x34>
		panic("%e\n", r);
  801afe:	50                   	push   %eax
  801aff:	68 eb 3a 80 00       	push   $0x803aeb
  801b04:	68 d5 00 00 00       	push   $0xd5
  801b09:	68 2a 3b 80 00       	push   $0x803b2a
  801b0e:	e8 34 ef ff ff       	call   800a47 <_panic>
	}	

	wt->envid = envid;
  801b13:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  801b19:	83 3b 00             	cmpl   $0x0,(%ebx)
  801b1c:	75 13                	jne    801b31 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  801b1e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801b25:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801b2c:	00 00 00 
  801b2f:	eb 1b                	jmp    801b4c <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801b31:	8b 43 04             	mov    0x4(%ebx),%eax
  801b34:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801b3b:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801b42:	00 00 00 
		queue->last = wt;
  801b45:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801b4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4f:	5b                   	pop    %ebx
  801b50:	5e                   	pop    %esi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	83 ec 08             	sub    $0x8,%esp
  801b59:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  801b5c:	8b 02                	mov    (%edx),%eax
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	75 17                	jne    801b79 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801b62:	83 ec 04             	sub    $0x4,%esp
  801b65:	68 72 3b 80 00       	push   $0x803b72
  801b6a:	68 ec 00 00 00       	push   $0xec
  801b6f:	68 2a 3b 80 00       	push   $0x803b2a
  801b74:	e8 ce ee ff ff       	call   800a47 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801b79:	8b 48 04             	mov    0x4(%eax),%ecx
  801b7c:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  801b7e:	8b 00                	mov    (%eax),%eax
}
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	56                   	push   %esi
  801b86:	53                   	push   %ebx
  801b87:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801b8a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b8f:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801b92:	85 c0                	test   %eax,%eax
  801b94:	74 4a                	je     801be0 <mutex_lock+0x5e>
  801b96:	8b 73 04             	mov    0x4(%ebx),%esi
  801b99:	83 3e 00             	cmpl   $0x0,(%esi)
  801b9c:	75 42                	jne    801be0 <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  801b9e:	e8 ba f9 ff ff       	call   80155d <sys_getenvid>
  801ba3:	83 ec 08             	sub    $0x8,%esp
  801ba6:	56                   	push   %esi
  801ba7:	50                   	push   %eax
  801ba8:	e8 32 ff ff ff       	call   801adf <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801bad:	e8 ab f9 ff ff       	call   80155d <sys_getenvid>
  801bb2:	83 c4 08             	add    $0x8,%esp
  801bb5:	6a 04                	push   $0x4
  801bb7:	50                   	push   %eax
  801bb8:	e8 a5 fa ff ff       	call   801662 <sys_env_set_status>

		if (r < 0) {
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	79 15                	jns    801bd9 <mutex_lock+0x57>
			panic("%e\n", r);
  801bc4:	50                   	push   %eax
  801bc5:	68 eb 3a 80 00       	push   $0x803aeb
  801bca:	68 02 01 00 00       	push   $0x102
  801bcf:	68 2a 3b 80 00       	push   $0x803b2a
  801bd4:	e8 6e ee ff ff       	call   800a47 <_panic>
		}
		sys_yield();
  801bd9:	e8 9e f9 ff ff       	call   80157c <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801bde:	eb 08                	jmp    801be8 <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  801be0:	e8 78 f9 ff ff       	call   80155d <sys_getenvid>
  801be5:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  801be8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801beb:	5b                   	pop    %ebx
  801bec:	5e                   	pop    %esi
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    

00801bef <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	53                   	push   %ebx
  801bf3:	83 ec 04             	sub    $0x4,%esp
  801bf6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801bf9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfe:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801c01:	8b 43 04             	mov    0x4(%ebx),%eax
  801c04:	83 38 00             	cmpl   $0x0,(%eax)
  801c07:	74 33                	je     801c3c <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  801c09:	83 ec 0c             	sub    $0xc,%esp
  801c0c:	50                   	push   %eax
  801c0d:	e8 41 ff ff ff       	call   801b53 <queue_pop>
  801c12:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801c15:	83 c4 08             	add    $0x8,%esp
  801c18:	6a 02                	push   $0x2
  801c1a:	50                   	push   %eax
  801c1b:	e8 42 fa ff ff       	call   801662 <sys_env_set_status>
		if (r < 0) {
  801c20:	83 c4 10             	add    $0x10,%esp
  801c23:	85 c0                	test   %eax,%eax
  801c25:	79 15                	jns    801c3c <mutex_unlock+0x4d>
			panic("%e\n", r);
  801c27:	50                   	push   %eax
  801c28:	68 eb 3a 80 00       	push   $0x803aeb
  801c2d:	68 16 01 00 00       	push   $0x116
  801c32:	68 2a 3b 80 00       	push   $0x803b2a
  801c37:	e8 0b ee ff ff       	call   800a47 <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  801c3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c3f:	c9                   	leave  
  801c40:	c3                   	ret    

00801c41 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	53                   	push   %ebx
  801c45:	83 ec 04             	sub    $0x4,%esp
  801c48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801c4b:	e8 0d f9 ff ff       	call   80155d <sys_getenvid>
  801c50:	83 ec 04             	sub    $0x4,%esp
  801c53:	6a 07                	push   $0x7
  801c55:	53                   	push   %ebx
  801c56:	50                   	push   %eax
  801c57:	e8 3f f9 ff ff       	call   80159b <sys_page_alloc>
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	79 15                	jns    801c78 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801c63:	50                   	push   %eax
  801c64:	68 8d 3b 80 00       	push   $0x803b8d
  801c69:	68 22 01 00 00       	push   $0x122
  801c6e:	68 2a 3b 80 00       	push   $0x803b2a
  801c73:	e8 cf ed ff ff       	call   800a47 <_panic>
	}	
	mtx->locked = 0;
  801c78:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801c7e:	8b 43 04             	mov    0x4(%ebx),%eax
  801c81:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801c87:	8b 43 04             	mov    0x4(%ebx),%eax
  801c8a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801c91:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801c98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c9b:	c9                   	leave  
  801c9c:	c3                   	ret    

00801c9d <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	53                   	push   %ebx
  801ca1:	83 ec 04             	sub    $0x4,%esp
  801ca4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  801ca7:	eb 21                	jmp    801cca <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  801ca9:	83 ec 0c             	sub    $0xc,%esp
  801cac:	50                   	push   %eax
  801cad:	e8 a1 fe ff ff       	call   801b53 <queue_pop>
  801cb2:	83 c4 08             	add    $0x8,%esp
  801cb5:	6a 02                	push   $0x2
  801cb7:	50                   	push   %eax
  801cb8:	e8 a5 f9 ff ff       	call   801662 <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  801cbd:	8b 43 04             	mov    0x4(%ebx),%eax
  801cc0:	8b 10                	mov    (%eax),%edx
  801cc2:	8b 52 04             	mov    0x4(%edx),%edx
  801cc5:	89 10                	mov    %edx,(%eax)
  801cc7:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  801cca:	8b 43 04             	mov    0x4(%ebx),%eax
  801ccd:	83 38 00             	cmpl   $0x0,(%eax)
  801cd0:	75 d7                	jne    801ca9 <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  801cd2:	83 ec 04             	sub    $0x4,%esp
  801cd5:	68 00 10 00 00       	push   $0x1000
  801cda:	6a 00                	push   $0x0
  801cdc:	53                   	push   %ebx
  801cdd:	e8 fb f5 ff ff       	call   8012dd <memset>
	mtx = NULL;
}
  801ce2:	83 c4 10             	add    $0x10,%esp
  801ce5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce8:	c9                   	leave  
  801ce9:	c3                   	ret    

00801cea <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	8b 55 08             	mov    0x8(%ebp),%edx
  801cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cf3:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801cf6:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801cf8:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801cfb:	83 3a 01             	cmpl   $0x1,(%edx)
  801cfe:	7e 09                	jle    801d09 <argstart+0x1f>
  801d00:	ba c1 35 80 00       	mov    $0x8035c1,%edx
  801d05:	85 c9                	test   %ecx,%ecx
  801d07:	75 05                	jne    801d0e <argstart+0x24>
  801d09:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0e:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801d11:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801d18:	5d                   	pop    %ebp
  801d19:	c3                   	ret    

00801d1a <argnext>:

int
argnext(struct Argstate *args)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	53                   	push   %ebx
  801d1e:	83 ec 04             	sub    $0x4,%esp
  801d21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801d24:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801d2b:	8b 43 08             	mov    0x8(%ebx),%eax
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	74 6f                	je     801da1 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801d32:	80 38 00             	cmpb   $0x0,(%eax)
  801d35:	75 4e                	jne    801d85 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801d37:	8b 0b                	mov    (%ebx),%ecx
  801d39:	83 39 01             	cmpl   $0x1,(%ecx)
  801d3c:	74 55                	je     801d93 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801d3e:	8b 53 04             	mov    0x4(%ebx),%edx
  801d41:	8b 42 04             	mov    0x4(%edx),%eax
  801d44:	80 38 2d             	cmpb   $0x2d,(%eax)
  801d47:	75 4a                	jne    801d93 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801d49:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801d4d:	74 44                	je     801d93 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801d4f:	83 c0 01             	add    $0x1,%eax
  801d52:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801d55:	83 ec 04             	sub    $0x4,%esp
  801d58:	8b 01                	mov    (%ecx),%eax
  801d5a:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801d61:	50                   	push   %eax
  801d62:	8d 42 08             	lea    0x8(%edx),%eax
  801d65:	50                   	push   %eax
  801d66:	83 c2 04             	add    $0x4,%edx
  801d69:	52                   	push   %edx
  801d6a:	e8 bb f5 ff ff       	call   80132a <memmove>
		(*args->argc)--;
  801d6f:	8b 03                	mov    (%ebx),%eax
  801d71:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801d74:	8b 43 08             	mov    0x8(%ebx),%eax
  801d77:	83 c4 10             	add    $0x10,%esp
  801d7a:	80 38 2d             	cmpb   $0x2d,(%eax)
  801d7d:	75 06                	jne    801d85 <argnext+0x6b>
  801d7f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801d83:	74 0e                	je     801d93 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801d85:	8b 53 08             	mov    0x8(%ebx),%edx
  801d88:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801d8b:	83 c2 01             	add    $0x1,%edx
  801d8e:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801d91:	eb 13                	jmp    801da6 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801d93:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801d9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801d9f:	eb 05                	jmp    801da6 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801da1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801da6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da9:	c9                   	leave  
  801daa:	c3                   	ret    

00801dab <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	53                   	push   %ebx
  801daf:	83 ec 04             	sub    $0x4,%esp
  801db2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801db5:	8b 43 08             	mov    0x8(%ebx),%eax
  801db8:	85 c0                	test   %eax,%eax
  801dba:	74 58                	je     801e14 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801dbc:	80 38 00             	cmpb   $0x0,(%eax)
  801dbf:	74 0c                	je     801dcd <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801dc1:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801dc4:	c7 43 08 c1 35 80 00 	movl   $0x8035c1,0x8(%ebx)
  801dcb:	eb 42                	jmp    801e0f <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801dcd:	8b 13                	mov    (%ebx),%edx
  801dcf:	83 3a 01             	cmpl   $0x1,(%edx)
  801dd2:	7e 2d                	jle    801e01 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801dd4:	8b 43 04             	mov    0x4(%ebx),%eax
  801dd7:	8b 48 04             	mov    0x4(%eax),%ecx
  801dda:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801ddd:	83 ec 04             	sub    $0x4,%esp
  801de0:	8b 12                	mov    (%edx),%edx
  801de2:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801de9:	52                   	push   %edx
  801dea:	8d 50 08             	lea    0x8(%eax),%edx
  801ded:	52                   	push   %edx
  801dee:	83 c0 04             	add    $0x4,%eax
  801df1:	50                   	push   %eax
  801df2:	e8 33 f5 ff ff       	call   80132a <memmove>
		(*args->argc)--;
  801df7:	8b 03                	mov    (%ebx),%eax
  801df9:	83 28 01             	subl   $0x1,(%eax)
  801dfc:	83 c4 10             	add    $0x10,%esp
  801dff:	eb 0e                	jmp    801e0f <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801e01:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801e08:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801e0f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801e12:	eb 05                	jmp    801e19 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801e14:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801e19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    

00801e1e <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	83 ec 08             	sub    $0x8,%esp
  801e24:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801e27:	8b 51 0c             	mov    0xc(%ecx),%edx
  801e2a:	89 d0                	mov    %edx,%eax
  801e2c:	85 d2                	test   %edx,%edx
  801e2e:	75 0c                	jne    801e3c <argvalue+0x1e>
  801e30:	83 ec 0c             	sub    $0xc,%esp
  801e33:	51                   	push   %ecx
  801e34:	e8 72 ff ff ff       	call   801dab <argnextvalue>
  801e39:	83 c4 10             	add    $0x10,%esp
}
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801e41:	8b 45 08             	mov    0x8(%ebp),%eax
  801e44:	05 00 00 00 30       	add    $0x30000000,%eax
  801e49:	c1 e8 0c             	shr    $0xc,%eax
}
  801e4c:	5d                   	pop    %ebp
  801e4d:	c3                   	ret    

00801e4e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801e4e:	55                   	push   %ebp
  801e4f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801e51:	8b 45 08             	mov    0x8(%ebp),%eax
  801e54:	05 00 00 00 30       	add    $0x30000000,%eax
  801e59:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801e5e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801e63:	5d                   	pop    %ebp
  801e64:	c3                   	ret    

00801e65 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e6b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801e70:	89 c2                	mov    %eax,%edx
  801e72:	c1 ea 16             	shr    $0x16,%edx
  801e75:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e7c:	f6 c2 01             	test   $0x1,%dl
  801e7f:	74 11                	je     801e92 <fd_alloc+0x2d>
  801e81:	89 c2                	mov    %eax,%edx
  801e83:	c1 ea 0c             	shr    $0xc,%edx
  801e86:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e8d:	f6 c2 01             	test   $0x1,%dl
  801e90:	75 09                	jne    801e9b <fd_alloc+0x36>
			*fd_store = fd;
  801e92:	89 01                	mov    %eax,(%ecx)
			return 0;
  801e94:	b8 00 00 00 00       	mov    $0x0,%eax
  801e99:	eb 17                	jmp    801eb2 <fd_alloc+0x4d>
  801e9b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801ea0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801ea5:	75 c9                	jne    801e70 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801ea7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801ead:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801eb2:	5d                   	pop    %ebp
  801eb3:	c3                   	ret    

00801eb4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801eba:	83 f8 1f             	cmp    $0x1f,%eax
  801ebd:	77 36                	ja     801ef5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801ebf:	c1 e0 0c             	shl    $0xc,%eax
  801ec2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801ec7:	89 c2                	mov    %eax,%edx
  801ec9:	c1 ea 16             	shr    $0x16,%edx
  801ecc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ed3:	f6 c2 01             	test   $0x1,%dl
  801ed6:	74 24                	je     801efc <fd_lookup+0x48>
  801ed8:	89 c2                	mov    %eax,%edx
  801eda:	c1 ea 0c             	shr    $0xc,%edx
  801edd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ee4:	f6 c2 01             	test   $0x1,%dl
  801ee7:	74 1a                	je     801f03 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801ee9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eec:	89 02                	mov    %eax,(%edx)
	return 0;
  801eee:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef3:	eb 13                	jmp    801f08 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801ef5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801efa:	eb 0c                	jmp    801f08 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801efc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f01:	eb 05                	jmp    801f08 <fd_lookup+0x54>
  801f03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801f08:	5d                   	pop    %ebp
  801f09:	c3                   	ret    

00801f0a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	83 ec 08             	sub    $0x8,%esp
  801f10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f13:	ba 24 3c 80 00       	mov    $0x803c24,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801f18:	eb 13                	jmp    801f2d <dev_lookup+0x23>
  801f1a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801f1d:	39 08                	cmp    %ecx,(%eax)
  801f1f:	75 0c                	jne    801f2d <dev_lookup+0x23>
			*dev = devtab[i];
  801f21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f24:	89 01                	mov    %eax,(%ecx)
			return 0;
  801f26:	b8 00 00 00 00       	mov    $0x0,%eax
  801f2b:	eb 31                	jmp    801f5e <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801f2d:	8b 02                	mov    (%edx),%eax
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	75 e7                	jne    801f1a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801f33:	a1 24 54 80 00       	mov    0x805424,%eax
  801f38:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801f3e:	83 ec 04             	sub    $0x4,%esp
  801f41:	51                   	push   %ecx
  801f42:	50                   	push   %eax
  801f43:	68 a8 3b 80 00       	push   $0x803ba8
  801f48:	e8 d3 eb ff ff       	call   800b20 <cprintf>
	*dev = 0;
  801f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f50:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801f5e:	c9                   	leave  
  801f5f:	c3                   	ret    

00801f60 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	56                   	push   %esi
  801f64:	53                   	push   %ebx
  801f65:	83 ec 10             	sub    $0x10,%esp
  801f68:	8b 75 08             	mov    0x8(%ebp),%esi
  801f6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801f6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f71:	50                   	push   %eax
  801f72:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801f78:	c1 e8 0c             	shr    $0xc,%eax
  801f7b:	50                   	push   %eax
  801f7c:	e8 33 ff ff ff       	call   801eb4 <fd_lookup>
  801f81:	83 c4 08             	add    $0x8,%esp
  801f84:	85 c0                	test   %eax,%eax
  801f86:	78 05                	js     801f8d <fd_close+0x2d>
	    || fd != fd2)
  801f88:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801f8b:	74 0c                	je     801f99 <fd_close+0x39>
		return (must_exist ? r : 0);
  801f8d:	84 db                	test   %bl,%bl
  801f8f:	ba 00 00 00 00       	mov    $0x0,%edx
  801f94:	0f 44 c2             	cmove  %edx,%eax
  801f97:	eb 41                	jmp    801fda <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801f99:	83 ec 08             	sub    $0x8,%esp
  801f9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f9f:	50                   	push   %eax
  801fa0:	ff 36                	pushl  (%esi)
  801fa2:	e8 63 ff ff ff       	call   801f0a <dev_lookup>
  801fa7:	89 c3                	mov    %eax,%ebx
  801fa9:	83 c4 10             	add    $0x10,%esp
  801fac:	85 c0                	test   %eax,%eax
  801fae:	78 1a                	js     801fca <fd_close+0x6a>
		if (dev->dev_close)
  801fb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fb3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801fb6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801fbb:	85 c0                	test   %eax,%eax
  801fbd:	74 0b                	je     801fca <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801fbf:	83 ec 0c             	sub    $0xc,%esp
  801fc2:	56                   	push   %esi
  801fc3:	ff d0                	call   *%eax
  801fc5:	89 c3                	mov    %eax,%ebx
  801fc7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801fca:	83 ec 08             	sub    $0x8,%esp
  801fcd:	56                   	push   %esi
  801fce:	6a 00                	push   $0x0
  801fd0:	e8 4b f6 ff ff       	call   801620 <sys_page_unmap>
	return r;
  801fd5:	83 c4 10             	add    $0x10,%esp
  801fd8:	89 d8                	mov    %ebx,%eax
}
  801fda:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fdd:	5b                   	pop    %ebx
  801fde:	5e                   	pop    %esi
  801fdf:	5d                   	pop    %ebp
  801fe0:	c3                   	ret    

00801fe1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fe7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fea:	50                   	push   %eax
  801feb:	ff 75 08             	pushl  0x8(%ebp)
  801fee:	e8 c1 fe ff ff       	call   801eb4 <fd_lookup>
  801ff3:	83 c4 08             	add    $0x8,%esp
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	78 10                	js     80200a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801ffa:	83 ec 08             	sub    $0x8,%esp
  801ffd:	6a 01                	push   $0x1
  801fff:	ff 75 f4             	pushl  -0xc(%ebp)
  802002:	e8 59 ff ff ff       	call   801f60 <fd_close>
  802007:	83 c4 10             	add    $0x10,%esp
}
  80200a:	c9                   	leave  
  80200b:	c3                   	ret    

0080200c <close_all>:

void
close_all(void)
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	53                   	push   %ebx
  802010:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802013:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802018:	83 ec 0c             	sub    $0xc,%esp
  80201b:	53                   	push   %ebx
  80201c:	e8 c0 ff ff ff       	call   801fe1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802021:	83 c3 01             	add    $0x1,%ebx
  802024:	83 c4 10             	add    $0x10,%esp
  802027:	83 fb 20             	cmp    $0x20,%ebx
  80202a:	75 ec                	jne    802018 <close_all+0xc>
		close(i);
}
  80202c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80202f:	c9                   	leave  
  802030:	c3                   	ret    

00802031 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802031:	55                   	push   %ebp
  802032:	89 e5                	mov    %esp,%ebp
  802034:	57                   	push   %edi
  802035:	56                   	push   %esi
  802036:	53                   	push   %ebx
  802037:	83 ec 2c             	sub    $0x2c,%esp
  80203a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80203d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802040:	50                   	push   %eax
  802041:	ff 75 08             	pushl  0x8(%ebp)
  802044:	e8 6b fe ff ff       	call   801eb4 <fd_lookup>
  802049:	83 c4 08             	add    $0x8,%esp
  80204c:	85 c0                	test   %eax,%eax
  80204e:	0f 88 c1 00 00 00    	js     802115 <dup+0xe4>
		return r;
	close(newfdnum);
  802054:	83 ec 0c             	sub    $0xc,%esp
  802057:	56                   	push   %esi
  802058:	e8 84 ff ff ff       	call   801fe1 <close>

	newfd = INDEX2FD(newfdnum);
  80205d:	89 f3                	mov    %esi,%ebx
  80205f:	c1 e3 0c             	shl    $0xc,%ebx
  802062:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802068:	83 c4 04             	add    $0x4,%esp
  80206b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80206e:	e8 db fd ff ff       	call   801e4e <fd2data>
  802073:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802075:	89 1c 24             	mov    %ebx,(%esp)
  802078:	e8 d1 fd ff ff       	call   801e4e <fd2data>
  80207d:	83 c4 10             	add    $0x10,%esp
  802080:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802083:	89 f8                	mov    %edi,%eax
  802085:	c1 e8 16             	shr    $0x16,%eax
  802088:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80208f:	a8 01                	test   $0x1,%al
  802091:	74 37                	je     8020ca <dup+0x99>
  802093:	89 f8                	mov    %edi,%eax
  802095:	c1 e8 0c             	shr    $0xc,%eax
  802098:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80209f:	f6 c2 01             	test   $0x1,%dl
  8020a2:	74 26                	je     8020ca <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8020a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020ab:	83 ec 0c             	sub    $0xc,%esp
  8020ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8020b3:	50                   	push   %eax
  8020b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8020b7:	6a 00                	push   $0x0
  8020b9:	57                   	push   %edi
  8020ba:	6a 00                	push   $0x0
  8020bc:	e8 1d f5 ff ff       	call   8015de <sys_page_map>
  8020c1:	89 c7                	mov    %eax,%edi
  8020c3:	83 c4 20             	add    $0x20,%esp
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	78 2e                	js     8020f8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8020ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8020cd:	89 d0                	mov    %edx,%eax
  8020cf:	c1 e8 0c             	shr    $0xc,%eax
  8020d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020d9:	83 ec 0c             	sub    $0xc,%esp
  8020dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8020e1:	50                   	push   %eax
  8020e2:	53                   	push   %ebx
  8020e3:	6a 00                	push   $0x0
  8020e5:	52                   	push   %edx
  8020e6:	6a 00                	push   $0x0
  8020e8:	e8 f1 f4 ff ff       	call   8015de <sys_page_map>
  8020ed:	89 c7                	mov    %eax,%edi
  8020ef:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8020f2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8020f4:	85 ff                	test   %edi,%edi
  8020f6:	79 1d                	jns    802115 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8020f8:	83 ec 08             	sub    $0x8,%esp
  8020fb:	53                   	push   %ebx
  8020fc:	6a 00                	push   $0x0
  8020fe:	e8 1d f5 ff ff       	call   801620 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802103:	83 c4 08             	add    $0x8,%esp
  802106:	ff 75 d4             	pushl  -0x2c(%ebp)
  802109:	6a 00                	push   $0x0
  80210b:	e8 10 f5 ff ff       	call   801620 <sys_page_unmap>
	return r;
  802110:	83 c4 10             	add    $0x10,%esp
  802113:	89 f8                	mov    %edi,%eax
}
  802115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802118:	5b                   	pop    %ebx
  802119:	5e                   	pop    %esi
  80211a:	5f                   	pop    %edi
  80211b:	5d                   	pop    %ebp
  80211c:	c3                   	ret    

0080211d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80211d:	55                   	push   %ebp
  80211e:	89 e5                	mov    %esp,%ebp
  802120:	53                   	push   %ebx
  802121:	83 ec 14             	sub    $0x14,%esp
  802124:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802127:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80212a:	50                   	push   %eax
  80212b:	53                   	push   %ebx
  80212c:	e8 83 fd ff ff       	call   801eb4 <fd_lookup>
  802131:	83 c4 08             	add    $0x8,%esp
  802134:	89 c2                	mov    %eax,%edx
  802136:	85 c0                	test   %eax,%eax
  802138:	78 70                	js     8021aa <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80213a:	83 ec 08             	sub    $0x8,%esp
  80213d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802140:	50                   	push   %eax
  802141:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802144:	ff 30                	pushl  (%eax)
  802146:	e8 bf fd ff ff       	call   801f0a <dev_lookup>
  80214b:	83 c4 10             	add    $0x10,%esp
  80214e:	85 c0                	test   %eax,%eax
  802150:	78 4f                	js     8021a1 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802152:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802155:	8b 42 08             	mov    0x8(%edx),%eax
  802158:	83 e0 03             	and    $0x3,%eax
  80215b:	83 f8 01             	cmp    $0x1,%eax
  80215e:	75 24                	jne    802184 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802160:	a1 24 54 80 00       	mov    0x805424,%eax
  802165:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80216b:	83 ec 04             	sub    $0x4,%esp
  80216e:	53                   	push   %ebx
  80216f:	50                   	push   %eax
  802170:	68 e9 3b 80 00       	push   $0x803be9
  802175:	e8 a6 e9 ff ff       	call   800b20 <cprintf>
		return -E_INVAL;
  80217a:	83 c4 10             	add    $0x10,%esp
  80217d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802182:	eb 26                	jmp    8021aa <read+0x8d>
	}
	if (!dev->dev_read)
  802184:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802187:	8b 40 08             	mov    0x8(%eax),%eax
  80218a:	85 c0                	test   %eax,%eax
  80218c:	74 17                	je     8021a5 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80218e:	83 ec 04             	sub    $0x4,%esp
  802191:	ff 75 10             	pushl  0x10(%ebp)
  802194:	ff 75 0c             	pushl  0xc(%ebp)
  802197:	52                   	push   %edx
  802198:	ff d0                	call   *%eax
  80219a:	89 c2                	mov    %eax,%edx
  80219c:	83 c4 10             	add    $0x10,%esp
  80219f:	eb 09                	jmp    8021aa <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021a1:	89 c2                	mov    %eax,%edx
  8021a3:	eb 05                	jmp    8021aa <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8021a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8021aa:	89 d0                	mov    %edx,%eax
  8021ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021af:	c9                   	leave  
  8021b0:	c3                   	ret    

008021b1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8021b1:	55                   	push   %ebp
  8021b2:	89 e5                	mov    %esp,%ebp
  8021b4:	57                   	push   %edi
  8021b5:	56                   	push   %esi
  8021b6:	53                   	push   %ebx
  8021b7:	83 ec 0c             	sub    $0xc,%esp
  8021ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021bd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8021c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021c5:	eb 21                	jmp    8021e8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8021c7:	83 ec 04             	sub    $0x4,%esp
  8021ca:	89 f0                	mov    %esi,%eax
  8021cc:	29 d8                	sub    %ebx,%eax
  8021ce:	50                   	push   %eax
  8021cf:	89 d8                	mov    %ebx,%eax
  8021d1:	03 45 0c             	add    0xc(%ebp),%eax
  8021d4:	50                   	push   %eax
  8021d5:	57                   	push   %edi
  8021d6:	e8 42 ff ff ff       	call   80211d <read>
		if (m < 0)
  8021db:	83 c4 10             	add    $0x10,%esp
  8021de:	85 c0                	test   %eax,%eax
  8021e0:	78 10                	js     8021f2 <readn+0x41>
			return m;
		if (m == 0)
  8021e2:	85 c0                	test   %eax,%eax
  8021e4:	74 0a                	je     8021f0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8021e6:	01 c3                	add    %eax,%ebx
  8021e8:	39 f3                	cmp    %esi,%ebx
  8021ea:	72 db                	jb     8021c7 <readn+0x16>
  8021ec:	89 d8                	mov    %ebx,%eax
  8021ee:	eb 02                	jmp    8021f2 <readn+0x41>
  8021f0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8021f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f5:	5b                   	pop    %ebx
  8021f6:	5e                   	pop    %esi
  8021f7:	5f                   	pop    %edi
  8021f8:	5d                   	pop    %ebp
  8021f9:	c3                   	ret    

008021fa <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8021fa:	55                   	push   %ebp
  8021fb:	89 e5                	mov    %esp,%ebp
  8021fd:	53                   	push   %ebx
  8021fe:	83 ec 14             	sub    $0x14,%esp
  802201:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802204:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802207:	50                   	push   %eax
  802208:	53                   	push   %ebx
  802209:	e8 a6 fc ff ff       	call   801eb4 <fd_lookup>
  80220e:	83 c4 08             	add    $0x8,%esp
  802211:	89 c2                	mov    %eax,%edx
  802213:	85 c0                	test   %eax,%eax
  802215:	78 6b                	js     802282 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802217:	83 ec 08             	sub    $0x8,%esp
  80221a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80221d:	50                   	push   %eax
  80221e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802221:	ff 30                	pushl  (%eax)
  802223:	e8 e2 fc ff ff       	call   801f0a <dev_lookup>
  802228:	83 c4 10             	add    $0x10,%esp
  80222b:	85 c0                	test   %eax,%eax
  80222d:	78 4a                	js     802279 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80222f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802232:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802236:	75 24                	jne    80225c <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802238:	a1 24 54 80 00       	mov    0x805424,%eax
  80223d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802243:	83 ec 04             	sub    $0x4,%esp
  802246:	53                   	push   %ebx
  802247:	50                   	push   %eax
  802248:	68 05 3c 80 00       	push   $0x803c05
  80224d:	e8 ce e8 ff ff       	call   800b20 <cprintf>
		return -E_INVAL;
  802252:	83 c4 10             	add    $0x10,%esp
  802255:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80225a:	eb 26                	jmp    802282 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80225c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80225f:	8b 52 0c             	mov    0xc(%edx),%edx
  802262:	85 d2                	test   %edx,%edx
  802264:	74 17                	je     80227d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802266:	83 ec 04             	sub    $0x4,%esp
  802269:	ff 75 10             	pushl  0x10(%ebp)
  80226c:	ff 75 0c             	pushl  0xc(%ebp)
  80226f:	50                   	push   %eax
  802270:	ff d2                	call   *%edx
  802272:	89 c2                	mov    %eax,%edx
  802274:	83 c4 10             	add    $0x10,%esp
  802277:	eb 09                	jmp    802282 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802279:	89 c2                	mov    %eax,%edx
  80227b:	eb 05                	jmp    802282 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80227d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802282:	89 d0                	mov    %edx,%eax
  802284:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802287:	c9                   	leave  
  802288:	c3                   	ret    

00802289 <seek>:

int
seek(int fdnum, off_t offset)
{
  802289:	55                   	push   %ebp
  80228a:	89 e5                	mov    %esp,%ebp
  80228c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80228f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802292:	50                   	push   %eax
  802293:	ff 75 08             	pushl  0x8(%ebp)
  802296:	e8 19 fc ff ff       	call   801eb4 <fd_lookup>
  80229b:	83 c4 08             	add    $0x8,%esp
  80229e:	85 c0                	test   %eax,%eax
  8022a0:	78 0e                	js     8022b0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8022a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8022a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022a8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8022ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022b0:	c9                   	leave  
  8022b1:	c3                   	ret    

008022b2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8022b2:	55                   	push   %ebp
  8022b3:	89 e5                	mov    %esp,%ebp
  8022b5:	53                   	push   %ebx
  8022b6:	83 ec 14             	sub    $0x14,%esp
  8022b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8022bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022bf:	50                   	push   %eax
  8022c0:	53                   	push   %ebx
  8022c1:	e8 ee fb ff ff       	call   801eb4 <fd_lookup>
  8022c6:	83 c4 08             	add    $0x8,%esp
  8022c9:	89 c2                	mov    %eax,%edx
  8022cb:	85 c0                	test   %eax,%eax
  8022cd:	78 68                	js     802337 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8022cf:	83 ec 08             	sub    $0x8,%esp
  8022d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d5:	50                   	push   %eax
  8022d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022d9:	ff 30                	pushl  (%eax)
  8022db:	e8 2a fc ff ff       	call   801f0a <dev_lookup>
  8022e0:	83 c4 10             	add    $0x10,%esp
  8022e3:	85 c0                	test   %eax,%eax
  8022e5:	78 47                	js     80232e <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8022e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8022ee:	75 24                	jne    802314 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8022f0:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8022f5:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8022fb:	83 ec 04             	sub    $0x4,%esp
  8022fe:	53                   	push   %ebx
  8022ff:	50                   	push   %eax
  802300:	68 c8 3b 80 00       	push   $0x803bc8
  802305:	e8 16 e8 ff ff       	call   800b20 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80230a:	83 c4 10             	add    $0x10,%esp
  80230d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802312:	eb 23                	jmp    802337 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  802314:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802317:	8b 52 18             	mov    0x18(%edx),%edx
  80231a:	85 d2                	test   %edx,%edx
  80231c:	74 14                	je     802332 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80231e:	83 ec 08             	sub    $0x8,%esp
  802321:	ff 75 0c             	pushl  0xc(%ebp)
  802324:	50                   	push   %eax
  802325:	ff d2                	call   *%edx
  802327:	89 c2                	mov    %eax,%edx
  802329:	83 c4 10             	add    $0x10,%esp
  80232c:	eb 09                	jmp    802337 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80232e:	89 c2                	mov    %eax,%edx
  802330:	eb 05                	jmp    802337 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802332:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802337:	89 d0                	mov    %edx,%eax
  802339:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80233c:	c9                   	leave  
  80233d:	c3                   	ret    

0080233e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80233e:	55                   	push   %ebp
  80233f:	89 e5                	mov    %esp,%ebp
  802341:	53                   	push   %ebx
  802342:	83 ec 14             	sub    $0x14,%esp
  802345:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802348:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80234b:	50                   	push   %eax
  80234c:	ff 75 08             	pushl  0x8(%ebp)
  80234f:	e8 60 fb ff ff       	call   801eb4 <fd_lookup>
  802354:	83 c4 08             	add    $0x8,%esp
  802357:	89 c2                	mov    %eax,%edx
  802359:	85 c0                	test   %eax,%eax
  80235b:	78 58                	js     8023b5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80235d:	83 ec 08             	sub    $0x8,%esp
  802360:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802363:	50                   	push   %eax
  802364:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802367:	ff 30                	pushl  (%eax)
  802369:	e8 9c fb ff ff       	call   801f0a <dev_lookup>
  80236e:	83 c4 10             	add    $0x10,%esp
  802371:	85 c0                	test   %eax,%eax
  802373:	78 37                	js     8023ac <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802375:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802378:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80237c:	74 32                	je     8023b0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80237e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802381:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802388:	00 00 00 
	stat->st_isdir = 0;
  80238b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802392:	00 00 00 
	stat->st_dev = dev;
  802395:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80239b:	83 ec 08             	sub    $0x8,%esp
  80239e:	53                   	push   %ebx
  80239f:	ff 75 f0             	pushl  -0x10(%ebp)
  8023a2:	ff 50 14             	call   *0x14(%eax)
  8023a5:	89 c2                	mov    %eax,%edx
  8023a7:	83 c4 10             	add    $0x10,%esp
  8023aa:	eb 09                	jmp    8023b5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8023ac:	89 c2                	mov    %eax,%edx
  8023ae:	eb 05                	jmp    8023b5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8023b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8023b5:	89 d0                	mov    %edx,%eax
  8023b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023ba:	c9                   	leave  
  8023bb:	c3                   	ret    

008023bc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8023bc:	55                   	push   %ebp
  8023bd:	89 e5                	mov    %esp,%ebp
  8023bf:	56                   	push   %esi
  8023c0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8023c1:	83 ec 08             	sub    $0x8,%esp
  8023c4:	6a 00                	push   $0x0
  8023c6:	ff 75 08             	pushl  0x8(%ebp)
  8023c9:	e8 e3 01 00 00       	call   8025b1 <open>
  8023ce:	89 c3                	mov    %eax,%ebx
  8023d0:	83 c4 10             	add    $0x10,%esp
  8023d3:	85 c0                	test   %eax,%eax
  8023d5:	78 1b                	js     8023f2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8023d7:	83 ec 08             	sub    $0x8,%esp
  8023da:	ff 75 0c             	pushl  0xc(%ebp)
  8023dd:	50                   	push   %eax
  8023de:	e8 5b ff ff ff       	call   80233e <fstat>
  8023e3:	89 c6                	mov    %eax,%esi
	close(fd);
  8023e5:	89 1c 24             	mov    %ebx,(%esp)
  8023e8:	e8 f4 fb ff ff       	call   801fe1 <close>
	return r;
  8023ed:	83 c4 10             	add    $0x10,%esp
  8023f0:	89 f0                	mov    %esi,%eax
}
  8023f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023f5:	5b                   	pop    %ebx
  8023f6:	5e                   	pop    %esi
  8023f7:	5d                   	pop    %ebp
  8023f8:	c3                   	ret    

008023f9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8023f9:	55                   	push   %ebp
  8023fa:	89 e5                	mov    %esp,%ebp
  8023fc:	56                   	push   %esi
  8023fd:	53                   	push   %ebx
  8023fe:	89 c6                	mov    %eax,%esi
  802400:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802402:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802409:	75 12                	jne    80241d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80240b:	83 ec 0c             	sub    $0xc,%esp
  80240e:	6a 01                	push   $0x1
  802410:	e8 5e 0e 00 00       	call   803273 <ipc_find_env>
  802415:	a3 20 54 80 00       	mov    %eax,0x805420
  80241a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80241d:	6a 07                	push   $0x7
  80241f:	68 00 60 80 00       	push   $0x806000
  802424:	56                   	push   %esi
  802425:	ff 35 20 54 80 00    	pushl  0x805420
  80242b:	e8 e1 0d 00 00       	call   803211 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802430:	83 c4 0c             	add    $0xc,%esp
  802433:	6a 00                	push   $0x0
  802435:	53                   	push   %ebx
  802436:	6a 00                	push   $0x0
  802438:	e8 59 0d 00 00       	call   803196 <ipc_recv>
}
  80243d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802440:	5b                   	pop    %ebx
  802441:	5e                   	pop    %esi
  802442:	5d                   	pop    %ebp
  802443:	c3                   	ret    

00802444 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802444:	55                   	push   %ebp
  802445:	89 e5                	mov    %esp,%ebp
  802447:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80244a:	8b 45 08             	mov    0x8(%ebp),%eax
  80244d:	8b 40 0c             	mov    0xc(%eax),%eax
  802450:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802455:	8b 45 0c             	mov    0xc(%ebp),%eax
  802458:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80245d:	ba 00 00 00 00       	mov    $0x0,%edx
  802462:	b8 02 00 00 00       	mov    $0x2,%eax
  802467:	e8 8d ff ff ff       	call   8023f9 <fsipc>
}
  80246c:	c9                   	leave  
  80246d:	c3                   	ret    

0080246e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80246e:	55                   	push   %ebp
  80246f:	89 e5                	mov    %esp,%ebp
  802471:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802474:	8b 45 08             	mov    0x8(%ebp),%eax
  802477:	8b 40 0c             	mov    0xc(%eax),%eax
  80247a:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80247f:	ba 00 00 00 00       	mov    $0x0,%edx
  802484:	b8 06 00 00 00       	mov    $0x6,%eax
  802489:	e8 6b ff ff ff       	call   8023f9 <fsipc>
}
  80248e:	c9                   	leave  
  80248f:	c3                   	ret    

00802490 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802490:	55                   	push   %ebp
  802491:	89 e5                	mov    %esp,%ebp
  802493:	53                   	push   %ebx
  802494:	83 ec 04             	sub    $0x4,%esp
  802497:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80249a:	8b 45 08             	mov    0x8(%ebp),%eax
  80249d:	8b 40 0c             	mov    0xc(%eax),%eax
  8024a0:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8024a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8024aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8024af:	e8 45 ff ff ff       	call   8023f9 <fsipc>
  8024b4:	85 c0                	test   %eax,%eax
  8024b6:	78 2c                	js     8024e4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8024b8:	83 ec 08             	sub    $0x8,%esp
  8024bb:	68 00 60 80 00       	push   $0x806000
  8024c0:	53                   	push   %ebx
  8024c1:	e8 d2 ec ff ff       	call   801198 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8024c6:	a1 80 60 80 00       	mov    0x806080,%eax
  8024cb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8024d1:	a1 84 60 80 00       	mov    0x806084,%eax
  8024d6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8024dc:	83 c4 10             	add    $0x10,%esp
  8024df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024e7:	c9                   	leave  
  8024e8:	c3                   	ret    

008024e9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8024e9:	55                   	push   %ebp
  8024ea:	89 e5                	mov    %esp,%ebp
  8024ec:	83 ec 0c             	sub    $0xc,%esp
  8024ef:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8024f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8024f5:	8b 52 0c             	mov    0xc(%edx),%edx
  8024f8:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8024fe:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802503:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802508:	0f 47 c2             	cmova  %edx,%eax
  80250b:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  802510:	50                   	push   %eax
  802511:	ff 75 0c             	pushl  0xc(%ebp)
  802514:	68 08 60 80 00       	push   $0x806008
  802519:	e8 0c ee ff ff       	call   80132a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80251e:	ba 00 00 00 00       	mov    $0x0,%edx
  802523:	b8 04 00 00 00       	mov    $0x4,%eax
  802528:	e8 cc fe ff ff       	call   8023f9 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80252d:	c9                   	leave  
  80252e:	c3                   	ret    

0080252f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80252f:	55                   	push   %ebp
  802530:	89 e5                	mov    %esp,%ebp
  802532:	56                   	push   %esi
  802533:	53                   	push   %ebx
  802534:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802537:	8b 45 08             	mov    0x8(%ebp),%eax
  80253a:	8b 40 0c             	mov    0xc(%eax),%eax
  80253d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802542:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802548:	ba 00 00 00 00       	mov    $0x0,%edx
  80254d:	b8 03 00 00 00       	mov    $0x3,%eax
  802552:	e8 a2 fe ff ff       	call   8023f9 <fsipc>
  802557:	89 c3                	mov    %eax,%ebx
  802559:	85 c0                	test   %eax,%eax
  80255b:	78 4b                	js     8025a8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80255d:	39 c6                	cmp    %eax,%esi
  80255f:	73 16                	jae    802577 <devfile_read+0x48>
  802561:	68 34 3c 80 00       	push   $0x803c34
  802566:	68 ef 36 80 00       	push   $0x8036ef
  80256b:	6a 7c                	push   $0x7c
  80256d:	68 3b 3c 80 00       	push   $0x803c3b
  802572:	e8 d0 e4 ff ff       	call   800a47 <_panic>
	assert(r <= PGSIZE);
  802577:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80257c:	7e 16                	jle    802594 <devfile_read+0x65>
  80257e:	68 46 3c 80 00       	push   $0x803c46
  802583:	68 ef 36 80 00       	push   $0x8036ef
  802588:	6a 7d                	push   $0x7d
  80258a:	68 3b 3c 80 00       	push   $0x803c3b
  80258f:	e8 b3 e4 ff ff       	call   800a47 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802594:	83 ec 04             	sub    $0x4,%esp
  802597:	50                   	push   %eax
  802598:	68 00 60 80 00       	push   $0x806000
  80259d:	ff 75 0c             	pushl  0xc(%ebp)
  8025a0:	e8 85 ed ff ff       	call   80132a <memmove>
	return r;
  8025a5:	83 c4 10             	add    $0x10,%esp
}
  8025a8:	89 d8                	mov    %ebx,%eax
  8025aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025ad:	5b                   	pop    %ebx
  8025ae:	5e                   	pop    %esi
  8025af:	5d                   	pop    %ebp
  8025b0:	c3                   	ret    

008025b1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8025b1:	55                   	push   %ebp
  8025b2:	89 e5                	mov    %esp,%ebp
  8025b4:	53                   	push   %ebx
  8025b5:	83 ec 20             	sub    $0x20,%esp
  8025b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8025bb:	53                   	push   %ebx
  8025bc:	e8 9e eb ff ff       	call   80115f <strlen>
  8025c1:	83 c4 10             	add    $0x10,%esp
  8025c4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8025c9:	7f 67                	jg     802632 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8025cb:	83 ec 0c             	sub    $0xc,%esp
  8025ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025d1:	50                   	push   %eax
  8025d2:	e8 8e f8 ff ff       	call   801e65 <fd_alloc>
  8025d7:	83 c4 10             	add    $0x10,%esp
		return r;
  8025da:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8025dc:	85 c0                	test   %eax,%eax
  8025de:	78 57                	js     802637 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8025e0:	83 ec 08             	sub    $0x8,%esp
  8025e3:	53                   	push   %ebx
  8025e4:	68 00 60 80 00       	push   $0x806000
  8025e9:	e8 aa eb ff ff       	call   801198 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8025ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025f1:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8025f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8025fe:	e8 f6 fd ff ff       	call   8023f9 <fsipc>
  802603:	89 c3                	mov    %eax,%ebx
  802605:	83 c4 10             	add    $0x10,%esp
  802608:	85 c0                	test   %eax,%eax
  80260a:	79 14                	jns    802620 <open+0x6f>
		fd_close(fd, 0);
  80260c:	83 ec 08             	sub    $0x8,%esp
  80260f:	6a 00                	push   $0x0
  802611:	ff 75 f4             	pushl  -0xc(%ebp)
  802614:	e8 47 f9 ff ff       	call   801f60 <fd_close>
		return r;
  802619:	83 c4 10             	add    $0x10,%esp
  80261c:	89 da                	mov    %ebx,%edx
  80261e:	eb 17                	jmp    802637 <open+0x86>
	}

	return fd2num(fd);
  802620:	83 ec 0c             	sub    $0xc,%esp
  802623:	ff 75 f4             	pushl  -0xc(%ebp)
  802626:	e8 13 f8 ff ff       	call   801e3e <fd2num>
  80262b:	89 c2                	mov    %eax,%edx
  80262d:	83 c4 10             	add    $0x10,%esp
  802630:	eb 05                	jmp    802637 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802632:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802637:	89 d0                	mov    %edx,%eax
  802639:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80263c:	c9                   	leave  
  80263d:	c3                   	ret    

0080263e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80263e:	55                   	push   %ebp
  80263f:	89 e5                	mov    %esp,%ebp
  802641:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802644:	ba 00 00 00 00       	mov    $0x0,%edx
  802649:	b8 08 00 00 00       	mov    $0x8,%eax
  80264e:	e8 a6 fd ff ff       	call   8023f9 <fsipc>
}
  802653:	c9                   	leave  
  802654:	c3                   	ret    

00802655 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802655:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802659:	7e 37                	jle    802692 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80265b:	55                   	push   %ebp
  80265c:	89 e5                	mov    %esp,%ebp
  80265e:	53                   	push   %ebx
  80265f:	83 ec 08             	sub    $0x8,%esp
  802662:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  802664:	ff 70 04             	pushl  0x4(%eax)
  802667:	8d 40 10             	lea    0x10(%eax),%eax
  80266a:	50                   	push   %eax
  80266b:	ff 33                	pushl  (%ebx)
  80266d:	e8 88 fb ff ff       	call   8021fa <write>
		if (result > 0)
  802672:	83 c4 10             	add    $0x10,%esp
  802675:	85 c0                	test   %eax,%eax
  802677:	7e 03                	jle    80267c <writebuf+0x27>
			b->result += result;
  802679:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80267c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80267f:	74 0d                	je     80268e <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  802681:	85 c0                	test   %eax,%eax
  802683:	ba 00 00 00 00       	mov    $0x0,%edx
  802688:	0f 4f c2             	cmovg  %edx,%eax
  80268b:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80268e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802691:	c9                   	leave  
  802692:	f3 c3                	repz ret 

00802694 <putch>:

static void
putch(int ch, void *thunk)
{
  802694:	55                   	push   %ebp
  802695:	89 e5                	mov    %esp,%ebp
  802697:	53                   	push   %ebx
  802698:	83 ec 04             	sub    $0x4,%esp
  80269b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80269e:	8b 53 04             	mov    0x4(%ebx),%edx
  8026a1:	8d 42 01             	lea    0x1(%edx),%eax
  8026a4:	89 43 04             	mov    %eax,0x4(%ebx)
  8026a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026aa:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8026ae:	3d 00 01 00 00       	cmp    $0x100,%eax
  8026b3:	75 0e                	jne    8026c3 <putch+0x2f>
		writebuf(b);
  8026b5:	89 d8                	mov    %ebx,%eax
  8026b7:	e8 99 ff ff ff       	call   802655 <writebuf>
		b->idx = 0;
  8026bc:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8026c3:	83 c4 04             	add    $0x4,%esp
  8026c6:	5b                   	pop    %ebx
  8026c7:	5d                   	pop    %ebp
  8026c8:	c3                   	ret    

008026c9 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8026c9:	55                   	push   %ebp
  8026ca:	89 e5                	mov    %esp,%ebp
  8026cc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8026d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8026d5:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8026db:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8026e2:	00 00 00 
	b.result = 0;
  8026e5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8026ec:	00 00 00 
	b.error = 1;
  8026ef:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8026f6:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8026f9:	ff 75 10             	pushl  0x10(%ebp)
  8026fc:	ff 75 0c             	pushl  0xc(%ebp)
  8026ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802705:	50                   	push   %eax
  802706:	68 94 26 80 00       	push   $0x802694
  80270b:	e8 47 e5 ff ff       	call   800c57 <vprintfmt>
	if (b.idx > 0)
  802710:	83 c4 10             	add    $0x10,%esp
  802713:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80271a:	7e 0b                	jle    802727 <vfprintf+0x5e>
		writebuf(&b);
  80271c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802722:	e8 2e ff ff ff       	call   802655 <writebuf>

	return (b.result ? b.result : b.error);
  802727:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80272d:	85 c0                	test   %eax,%eax
  80272f:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  802736:	c9                   	leave  
  802737:	c3                   	ret    

00802738 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802738:	55                   	push   %ebp
  802739:	89 e5                	mov    %esp,%ebp
  80273b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80273e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802741:	50                   	push   %eax
  802742:	ff 75 0c             	pushl  0xc(%ebp)
  802745:	ff 75 08             	pushl  0x8(%ebp)
  802748:	e8 7c ff ff ff       	call   8026c9 <vfprintf>
	va_end(ap);

	return cnt;
}
  80274d:	c9                   	leave  
  80274e:	c3                   	ret    

0080274f <printf>:

int
printf(const char *fmt, ...)
{
  80274f:	55                   	push   %ebp
  802750:	89 e5                	mov    %esp,%ebp
  802752:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802755:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802758:	50                   	push   %eax
  802759:	ff 75 08             	pushl  0x8(%ebp)
  80275c:	6a 01                	push   $0x1
  80275e:	e8 66 ff ff ff       	call   8026c9 <vfprintf>
	va_end(ap);

	return cnt;
}
  802763:	c9                   	leave  
  802764:	c3                   	ret    

00802765 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802765:	55                   	push   %ebp
  802766:	89 e5                	mov    %esp,%ebp
  802768:	57                   	push   %edi
  802769:	56                   	push   %esi
  80276a:	53                   	push   %ebx
  80276b:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  802771:	6a 00                	push   $0x0
  802773:	ff 75 08             	pushl  0x8(%ebp)
  802776:	e8 36 fe ff ff       	call   8025b1 <open>
  80277b:	89 c7                	mov    %eax,%edi
  80277d:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802783:	83 c4 10             	add    $0x10,%esp
  802786:	85 c0                	test   %eax,%eax
  802788:	0f 88 8c 04 00 00    	js     802c1a <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80278e:	83 ec 04             	sub    $0x4,%esp
  802791:	68 00 02 00 00       	push   $0x200
  802796:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80279c:	50                   	push   %eax
  80279d:	57                   	push   %edi
  80279e:	e8 0e fa ff ff       	call   8021b1 <readn>
  8027a3:	83 c4 10             	add    $0x10,%esp
  8027a6:	3d 00 02 00 00       	cmp    $0x200,%eax
  8027ab:	75 0c                	jne    8027b9 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8027ad:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8027b4:	45 4c 46 
  8027b7:	74 33                	je     8027ec <spawn+0x87>
		close(fd);
  8027b9:	83 ec 0c             	sub    $0xc,%esp
  8027bc:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8027c2:	e8 1a f8 ff ff       	call   801fe1 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8027c7:	83 c4 0c             	add    $0xc,%esp
  8027ca:	68 7f 45 4c 46       	push   $0x464c457f
  8027cf:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8027d5:	68 52 3c 80 00       	push   $0x803c52
  8027da:	e8 41 e3 ff ff       	call   800b20 <cprintf>
		return -E_NOT_EXEC;
  8027df:	83 c4 10             	add    $0x10,%esp
  8027e2:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8027e7:	e9 e1 04 00 00       	jmp    802ccd <spawn+0x568>
  8027ec:	b8 07 00 00 00       	mov    $0x7,%eax
  8027f1:	cd 30                	int    $0x30
  8027f3:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8027f9:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8027ff:	85 c0                	test   %eax,%eax
  802801:	0f 88 1e 04 00 00    	js     802c25 <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802807:	89 c6                	mov    %eax,%esi
  802809:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80280f:	69 f6 d4 00 00 00    	imul   $0xd4,%esi,%esi
  802815:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80281b:	81 c6 58 00 c0 ee    	add    $0xeec00058,%esi
  802821:	b9 11 00 00 00       	mov    $0x11,%ecx
  802826:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802828:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80282e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802834:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802839:	be 00 00 00 00       	mov    $0x0,%esi
  80283e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802841:	eb 13                	jmp    802856 <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802843:	83 ec 0c             	sub    $0xc,%esp
  802846:	50                   	push   %eax
  802847:	e8 13 e9 ff ff       	call   80115f <strlen>
  80284c:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802850:	83 c3 01             	add    $0x1,%ebx
  802853:	83 c4 10             	add    $0x10,%esp
  802856:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80285d:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802860:	85 c0                	test   %eax,%eax
  802862:	75 df                	jne    802843 <spawn+0xde>
  802864:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80286a:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802870:	bf 00 10 40 00       	mov    $0x401000,%edi
  802875:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802877:	89 fa                	mov    %edi,%edx
  802879:	83 e2 fc             	and    $0xfffffffc,%edx
  80287c:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  802883:	29 c2                	sub    %eax,%edx
  802885:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80288b:	8d 42 f8             	lea    -0x8(%edx),%eax
  80288e:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802893:	0f 86 a2 03 00 00    	jbe    802c3b <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802899:	83 ec 04             	sub    $0x4,%esp
  80289c:	6a 07                	push   $0x7
  80289e:	68 00 00 40 00       	push   $0x400000
  8028a3:	6a 00                	push   $0x0
  8028a5:	e8 f1 ec ff ff       	call   80159b <sys_page_alloc>
  8028aa:	83 c4 10             	add    $0x10,%esp
  8028ad:	85 c0                	test   %eax,%eax
  8028af:	0f 88 90 03 00 00    	js     802c45 <spawn+0x4e0>
  8028b5:	be 00 00 00 00       	mov    $0x0,%esi
  8028ba:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8028c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8028c3:	eb 30                	jmp    8028f5 <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8028c5:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8028cb:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8028d1:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8028d4:	83 ec 08             	sub    $0x8,%esp
  8028d7:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8028da:	57                   	push   %edi
  8028db:	e8 b8 e8 ff ff       	call   801198 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8028e0:	83 c4 04             	add    $0x4,%esp
  8028e3:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8028e6:	e8 74 e8 ff ff       	call   80115f <strlen>
  8028eb:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8028ef:	83 c6 01             	add    $0x1,%esi
  8028f2:	83 c4 10             	add    $0x10,%esp
  8028f5:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8028fb:	7f c8                	jg     8028c5 <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8028fd:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802903:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  802909:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802910:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802916:	74 19                	je     802931 <spawn+0x1cc>
  802918:	68 dc 3c 80 00       	push   $0x803cdc
  80291d:	68 ef 36 80 00       	push   $0x8036ef
  802922:	68 f2 00 00 00       	push   $0xf2
  802927:	68 6c 3c 80 00       	push   $0x803c6c
  80292c:	e8 16 e1 ff ff       	call   800a47 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802931:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  802937:	89 f8                	mov    %edi,%eax
  802939:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80293e:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  802941:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802947:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80294a:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  802950:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802956:	83 ec 0c             	sub    $0xc,%esp
  802959:	6a 07                	push   $0x7
  80295b:	68 00 d0 bf ee       	push   $0xeebfd000
  802960:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802966:	68 00 00 40 00       	push   $0x400000
  80296b:	6a 00                	push   $0x0
  80296d:	e8 6c ec ff ff       	call   8015de <sys_page_map>
  802972:	89 c3                	mov    %eax,%ebx
  802974:	83 c4 20             	add    $0x20,%esp
  802977:	85 c0                	test   %eax,%eax
  802979:	0f 88 3c 03 00 00    	js     802cbb <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80297f:	83 ec 08             	sub    $0x8,%esp
  802982:	68 00 00 40 00       	push   $0x400000
  802987:	6a 00                	push   $0x0
  802989:	e8 92 ec ff ff       	call   801620 <sys_page_unmap>
  80298e:	89 c3                	mov    %eax,%ebx
  802990:	83 c4 10             	add    $0x10,%esp
  802993:	85 c0                	test   %eax,%eax
  802995:	0f 88 20 03 00 00    	js     802cbb <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80299b:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8029a1:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8029a8:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8029ae:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8029b5:	00 00 00 
  8029b8:	e9 88 01 00 00       	jmp    802b45 <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  8029bd:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8029c3:	83 38 01             	cmpl   $0x1,(%eax)
  8029c6:	0f 85 6b 01 00 00    	jne    802b37 <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8029cc:	89 c2                	mov    %eax,%edx
  8029ce:	8b 40 18             	mov    0x18(%eax),%eax
  8029d1:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8029d7:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8029da:	83 f8 01             	cmp    $0x1,%eax
  8029dd:	19 c0                	sbb    %eax,%eax
  8029df:	83 e0 fe             	and    $0xfffffffe,%eax
  8029e2:	83 c0 07             	add    $0x7,%eax
  8029e5:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8029eb:	89 d0                	mov    %edx,%eax
  8029ed:	8b 7a 04             	mov    0x4(%edx),%edi
  8029f0:	89 f9                	mov    %edi,%ecx
  8029f2:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8029f8:	8b 7a 10             	mov    0x10(%edx),%edi
  8029fb:	8b 52 14             	mov    0x14(%edx),%edx
  8029fe:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  802a04:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802a07:	89 f0                	mov    %esi,%eax
  802a09:	25 ff 0f 00 00       	and    $0xfff,%eax
  802a0e:	74 14                	je     802a24 <spawn+0x2bf>
		va -= i;
  802a10:	29 c6                	sub    %eax,%esi
		memsz += i;
  802a12:	01 c2                	add    %eax,%edx
  802a14:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  802a1a:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  802a1c:	29 c1                	sub    %eax,%ecx
  802a1e:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802a24:	bb 00 00 00 00       	mov    $0x0,%ebx
  802a29:	e9 f7 00 00 00       	jmp    802b25 <spawn+0x3c0>
		if (i >= filesz) {
  802a2e:	39 fb                	cmp    %edi,%ebx
  802a30:	72 27                	jb     802a59 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802a32:	83 ec 04             	sub    $0x4,%esp
  802a35:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802a3b:	56                   	push   %esi
  802a3c:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802a42:	e8 54 eb ff ff       	call   80159b <sys_page_alloc>
  802a47:	83 c4 10             	add    $0x10,%esp
  802a4a:	85 c0                	test   %eax,%eax
  802a4c:	0f 89 c7 00 00 00    	jns    802b19 <spawn+0x3b4>
  802a52:	89 c3                	mov    %eax,%ebx
  802a54:	e9 fd 01 00 00       	jmp    802c56 <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802a59:	83 ec 04             	sub    $0x4,%esp
  802a5c:	6a 07                	push   $0x7
  802a5e:	68 00 00 40 00       	push   $0x400000
  802a63:	6a 00                	push   $0x0
  802a65:	e8 31 eb ff ff       	call   80159b <sys_page_alloc>
  802a6a:	83 c4 10             	add    $0x10,%esp
  802a6d:	85 c0                	test   %eax,%eax
  802a6f:	0f 88 d7 01 00 00    	js     802c4c <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802a75:	83 ec 08             	sub    $0x8,%esp
  802a78:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802a7e:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802a84:	50                   	push   %eax
  802a85:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a8b:	e8 f9 f7 ff ff       	call   802289 <seek>
  802a90:	83 c4 10             	add    $0x10,%esp
  802a93:	85 c0                	test   %eax,%eax
  802a95:	0f 88 b5 01 00 00    	js     802c50 <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802a9b:	83 ec 04             	sub    $0x4,%esp
  802a9e:	89 f8                	mov    %edi,%eax
  802aa0:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  802aa6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802aab:	ba 00 10 00 00       	mov    $0x1000,%edx
  802ab0:	0f 47 c2             	cmova  %edx,%eax
  802ab3:	50                   	push   %eax
  802ab4:	68 00 00 40 00       	push   $0x400000
  802ab9:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802abf:	e8 ed f6 ff ff       	call   8021b1 <readn>
  802ac4:	83 c4 10             	add    $0x10,%esp
  802ac7:	85 c0                	test   %eax,%eax
  802ac9:	0f 88 85 01 00 00    	js     802c54 <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802acf:	83 ec 0c             	sub    $0xc,%esp
  802ad2:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802ad8:	56                   	push   %esi
  802ad9:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802adf:	68 00 00 40 00       	push   $0x400000
  802ae4:	6a 00                	push   $0x0
  802ae6:	e8 f3 ea ff ff       	call   8015de <sys_page_map>
  802aeb:	83 c4 20             	add    $0x20,%esp
  802aee:	85 c0                	test   %eax,%eax
  802af0:	79 15                	jns    802b07 <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  802af2:	50                   	push   %eax
  802af3:	68 78 3c 80 00       	push   $0x803c78
  802af8:	68 25 01 00 00       	push   $0x125
  802afd:	68 6c 3c 80 00       	push   $0x803c6c
  802b02:	e8 40 df ff ff       	call   800a47 <_panic>
			sys_page_unmap(0, UTEMP);
  802b07:	83 ec 08             	sub    $0x8,%esp
  802b0a:	68 00 00 40 00       	push   $0x400000
  802b0f:	6a 00                	push   $0x0
  802b11:	e8 0a eb ff ff       	call   801620 <sys_page_unmap>
  802b16:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802b19:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802b1f:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802b25:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802b2b:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  802b31:	0f 82 f7 fe ff ff    	jb     802a2e <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802b37:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802b3e:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802b45:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802b4c:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802b52:	0f 8c 65 fe ff ff    	jl     8029bd <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802b58:	83 ec 0c             	sub    $0xc,%esp
  802b5b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802b61:	e8 7b f4 ff ff       	call   801fe1 <close>
  802b66:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802b69:	bb 00 00 00 00       	mov    $0x0,%ebx
  802b6e:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  802b74:	89 d8                	mov    %ebx,%eax
  802b76:	c1 e8 16             	shr    $0x16,%eax
  802b79:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802b80:	a8 01                	test   $0x1,%al
  802b82:	74 42                	je     802bc6 <spawn+0x461>
  802b84:	89 d8                	mov    %ebx,%eax
  802b86:	c1 e8 0c             	shr    $0xc,%eax
  802b89:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802b90:	f6 c2 01             	test   $0x1,%dl
  802b93:	74 31                	je     802bc6 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  802b95:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  802b9c:	f6 c6 04             	test   $0x4,%dh
  802b9f:	74 25                	je     802bc6 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  802ba1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802ba8:	83 ec 0c             	sub    $0xc,%esp
  802bab:	25 07 0e 00 00       	and    $0xe07,%eax
  802bb0:	50                   	push   %eax
  802bb1:	53                   	push   %ebx
  802bb2:	56                   	push   %esi
  802bb3:	53                   	push   %ebx
  802bb4:	6a 00                	push   $0x0
  802bb6:	e8 23 ea ff ff       	call   8015de <sys_page_map>
			if (r < 0) {
  802bbb:	83 c4 20             	add    $0x20,%esp
  802bbe:	85 c0                	test   %eax,%eax
  802bc0:	0f 88 b1 00 00 00    	js     802c77 <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802bc6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802bcc:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802bd2:	75 a0                	jne    802b74 <spawn+0x40f>
  802bd4:	e9 b3 00 00 00       	jmp    802c8c <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802bd9:	50                   	push   %eax
  802bda:	68 95 3c 80 00       	push   $0x803c95
  802bdf:	68 86 00 00 00       	push   $0x86
  802be4:	68 6c 3c 80 00       	push   $0x803c6c
  802be9:	e8 59 de ff ff       	call   800a47 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802bee:	83 ec 08             	sub    $0x8,%esp
  802bf1:	6a 02                	push   $0x2
  802bf3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802bf9:	e8 64 ea ff ff       	call   801662 <sys_env_set_status>
  802bfe:	83 c4 10             	add    $0x10,%esp
  802c01:	85 c0                	test   %eax,%eax
  802c03:	79 2b                	jns    802c30 <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  802c05:	50                   	push   %eax
  802c06:	68 af 3c 80 00       	push   $0x803caf
  802c0b:	68 89 00 00 00       	push   $0x89
  802c10:	68 6c 3c 80 00       	push   $0x803c6c
  802c15:	e8 2d de ff ff       	call   800a47 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802c1a:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802c20:	e9 a8 00 00 00       	jmp    802ccd <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802c25:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802c2b:	e9 9d 00 00 00       	jmp    802ccd <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802c30:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802c36:	e9 92 00 00 00       	jmp    802ccd <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802c3b:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802c40:	e9 88 00 00 00       	jmp    802ccd <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802c45:	89 c3                	mov    %eax,%ebx
  802c47:	e9 81 00 00 00       	jmp    802ccd <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802c4c:	89 c3                	mov    %eax,%ebx
  802c4e:	eb 06                	jmp    802c56 <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802c50:	89 c3                	mov    %eax,%ebx
  802c52:	eb 02                	jmp    802c56 <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802c54:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802c56:	83 ec 0c             	sub    $0xc,%esp
  802c59:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802c5f:	e8 b8 e8 ff ff       	call   80151c <sys_env_destroy>
	close(fd);
  802c64:	83 c4 04             	add    $0x4,%esp
  802c67:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802c6d:	e8 6f f3 ff ff       	call   801fe1 <close>
	return r;
  802c72:	83 c4 10             	add    $0x10,%esp
  802c75:	eb 56                	jmp    802ccd <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802c77:	50                   	push   %eax
  802c78:	68 c6 3c 80 00       	push   $0x803cc6
  802c7d:	68 82 00 00 00       	push   $0x82
  802c82:	68 6c 3c 80 00       	push   $0x803c6c
  802c87:	e8 bb dd ff ff       	call   800a47 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802c8c:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802c93:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802c96:	83 ec 08             	sub    $0x8,%esp
  802c99:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802c9f:	50                   	push   %eax
  802ca0:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802ca6:	e8 f9 e9 ff ff       	call   8016a4 <sys_env_set_trapframe>
  802cab:	83 c4 10             	add    $0x10,%esp
  802cae:	85 c0                	test   %eax,%eax
  802cb0:	0f 89 38 ff ff ff    	jns    802bee <spawn+0x489>
  802cb6:	e9 1e ff ff ff       	jmp    802bd9 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802cbb:	83 ec 08             	sub    $0x8,%esp
  802cbe:	68 00 00 40 00       	push   $0x400000
  802cc3:	6a 00                	push   $0x0
  802cc5:	e8 56 e9 ff ff       	call   801620 <sys_page_unmap>
  802cca:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802ccd:	89 d8                	mov    %ebx,%eax
  802ccf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cd2:	5b                   	pop    %ebx
  802cd3:	5e                   	pop    %esi
  802cd4:	5f                   	pop    %edi
  802cd5:	5d                   	pop    %ebp
  802cd6:	c3                   	ret    

00802cd7 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802cd7:	55                   	push   %ebp
  802cd8:	89 e5                	mov    %esp,%ebp
  802cda:	56                   	push   %esi
  802cdb:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802cdc:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802cdf:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802ce4:	eb 03                	jmp    802ce9 <spawnl+0x12>
		argc++;
  802ce6:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802ce9:	83 c2 04             	add    $0x4,%edx
  802cec:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802cf0:	75 f4                	jne    802ce6 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802cf2:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802cf9:	83 e2 f0             	and    $0xfffffff0,%edx
  802cfc:	29 d4                	sub    %edx,%esp
  802cfe:	8d 54 24 03          	lea    0x3(%esp),%edx
  802d02:	c1 ea 02             	shr    $0x2,%edx
  802d05:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802d0c:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d11:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802d18:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802d1f:	00 
  802d20:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802d22:	b8 00 00 00 00       	mov    $0x0,%eax
  802d27:	eb 0a                	jmp    802d33 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802d29:	83 c0 01             	add    $0x1,%eax
  802d2c:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802d30:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802d33:	39 d0                	cmp    %edx,%eax
  802d35:	75 f2                	jne    802d29 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802d37:	83 ec 08             	sub    $0x8,%esp
  802d3a:	56                   	push   %esi
  802d3b:	ff 75 08             	pushl  0x8(%ebp)
  802d3e:	e8 22 fa ff ff       	call   802765 <spawn>
}
  802d43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d46:	5b                   	pop    %ebx
  802d47:	5e                   	pop    %esi
  802d48:	5d                   	pop    %ebp
  802d49:	c3                   	ret    

00802d4a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802d4a:	55                   	push   %ebp
  802d4b:	89 e5                	mov    %esp,%ebp
  802d4d:	56                   	push   %esi
  802d4e:	53                   	push   %ebx
  802d4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802d52:	83 ec 0c             	sub    $0xc,%esp
  802d55:	ff 75 08             	pushl  0x8(%ebp)
  802d58:	e8 f1 f0 ff ff       	call   801e4e <fd2data>
  802d5d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802d5f:	83 c4 08             	add    $0x8,%esp
  802d62:	68 04 3d 80 00       	push   $0x803d04
  802d67:	53                   	push   %ebx
  802d68:	e8 2b e4 ff ff       	call   801198 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802d6d:	8b 46 04             	mov    0x4(%esi),%eax
  802d70:	2b 06                	sub    (%esi),%eax
  802d72:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802d78:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802d7f:	00 00 00 
	stat->st_dev = &devpipe;
  802d82:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802d89:	40 80 00 
	return 0;
}
  802d8c:	b8 00 00 00 00       	mov    $0x0,%eax
  802d91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d94:	5b                   	pop    %ebx
  802d95:	5e                   	pop    %esi
  802d96:	5d                   	pop    %ebp
  802d97:	c3                   	ret    

00802d98 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802d98:	55                   	push   %ebp
  802d99:	89 e5                	mov    %esp,%ebp
  802d9b:	53                   	push   %ebx
  802d9c:	83 ec 0c             	sub    $0xc,%esp
  802d9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802da2:	53                   	push   %ebx
  802da3:	6a 00                	push   $0x0
  802da5:	e8 76 e8 ff ff       	call   801620 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802daa:	89 1c 24             	mov    %ebx,(%esp)
  802dad:	e8 9c f0 ff ff       	call   801e4e <fd2data>
  802db2:	83 c4 08             	add    $0x8,%esp
  802db5:	50                   	push   %eax
  802db6:	6a 00                	push   $0x0
  802db8:	e8 63 e8 ff ff       	call   801620 <sys_page_unmap>
}
  802dbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802dc0:	c9                   	leave  
  802dc1:	c3                   	ret    

00802dc2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802dc2:	55                   	push   %ebp
  802dc3:	89 e5                	mov    %esp,%ebp
  802dc5:	57                   	push   %edi
  802dc6:	56                   	push   %esi
  802dc7:	53                   	push   %ebx
  802dc8:	83 ec 1c             	sub    $0x1c,%esp
  802dcb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802dce:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802dd0:	a1 24 54 80 00       	mov    0x805424,%eax
  802dd5:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802ddb:	83 ec 0c             	sub    $0xc,%esp
  802dde:	ff 75 e0             	pushl  -0x20(%ebp)
  802de1:	e8 d2 04 00 00       	call   8032b8 <pageref>
  802de6:	89 c3                	mov    %eax,%ebx
  802de8:	89 3c 24             	mov    %edi,(%esp)
  802deb:	e8 c8 04 00 00       	call   8032b8 <pageref>
  802df0:	83 c4 10             	add    $0x10,%esp
  802df3:	39 c3                	cmp    %eax,%ebx
  802df5:	0f 94 c1             	sete   %cl
  802df8:	0f b6 c9             	movzbl %cl,%ecx
  802dfb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802dfe:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802e04:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  802e0a:	39 ce                	cmp    %ecx,%esi
  802e0c:	74 1e                	je     802e2c <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  802e0e:	39 c3                	cmp    %eax,%ebx
  802e10:	75 be                	jne    802dd0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802e12:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  802e18:	ff 75 e4             	pushl  -0x1c(%ebp)
  802e1b:	50                   	push   %eax
  802e1c:	56                   	push   %esi
  802e1d:	68 0b 3d 80 00       	push   $0x803d0b
  802e22:	e8 f9 dc ff ff       	call   800b20 <cprintf>
  802e27:	83 c4 10             	add    $0x10,%esp
  802e2a:	eb a4                	jmp    802dd0 <_pipeisclosed+0xe>
	}
}
  802e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802e2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e32:	5b                   	pop    %ebx
  802e33:	5e                   	pop    %esi
  802e34:	5f                   	pop    %edi
  802e35:	5d                   	pop    %ebp
  802e36:	c3                   	ret    

00802e37 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802e37:	55                   	push   %ebp
  802e38:	89 e5                	mov    %esp,%ebp
  802e3a:	57                   	push   %edi
  802e3b:	56                   	push   %esi
  802e3c:	53                   	push   %ebx
  802e3d:	83 ec 28             	sub    $0x28,%esp
  802e40:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802e43:	56                   	push   %esi
  802e44:	e8 05 f0 ff ff       	call   801e4e <fd2data>
  802e49:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802e4b:	83 c4 10             	add    $0x10,%esp
  802e4e:	bf 00 00 00 00       	mov    $0x0,%edi
  802e53:	eb 4b                	jmp    802ea0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802e55:	89 da                	mov    %ebx,%edx
  802e57:	89 f0                	mov    %esi,%eax
  802e59:	e8 64 ff ff ff       	call   802dc2 <_pipeisclosed>
  802e5e:	85 c0                	test   %eax,%eax
  802e60:	75 48                	jne    802eaa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802e62:	e8 15 e7 ff ff       	call   80157c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802e67:	8b 43 04             	mov    0x4(%ebx),%eax
  802e6a:	8b 0b                	mov    (%ebx),%ecx
  802e6c:	8d 51 20             	lea    0x20(%ecx),%edx
  802e6f:	39 d0                	cmp    %edx,%eax
  802e71:	73 e2                	jae    802e55 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802e73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802e76:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802e7a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802e7d:	89 c2                	mov    %eax,%edx
  802e7f:	c1 fa 1f             	sar    $0x1f,%edx
  802e82:	89 d1                	mov    %edx,%ecx
  802e84:	c1 e9 1b             	shr    $0x1b,%ecx
  802e87:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802e8a:	83 e2 1f             	and    $0x1f,%edx
  802e8d:	29 ca                	sub    %ecx,%edx
  802e8f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802e93:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802e97:	83 c0 01             	add    $0x1,%eax
  802e9a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802e9d:	83 c7 01             	add    $0x1,%edi
  802ea0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802ea3:	75 c2                	jne    802e67 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802ea5:	8b 45 10             	mov    0x10(%ebp),%eax
  802ea8:	eb 05                	jmp    802eaf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802eaa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802eaf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802eb2:	5b                   	pop    %ebx
  802eb3:	5e                   	pop    %esi
  802eb4:	5f                   	pop    %edi
  802eb5:	5d                   	pop    %ebp
  802eb6:	c3                   	ret    

00802eb7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802eb7:	55                   	push   %ebp
  802eb8:	89 e5                	mov    %esp,%ebp
  802eba:	57                   	push   %edi
  802ebb:	56                   	push   %esi
  802ebc:	53                   	push   %ebx
  802ebd:	83 ec 18             	sub    $0x18,%esp
  802ec0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802ec3:	57                   	push   %edi
  802ec4:	e8 85 ef ff ff       	call   801e4e <fd2data>
  802ec9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ecb:	83 c4 10             	add    $0x10,%esp
  802ece:	bb 00 00 00 00       	mov    $0x0,%ebx
  802ed3:	eb 3d                	jmp    802f12 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802ed5:	85 db                	test   %ebx,%ebx
  802ed7:	74 04                	je     802edd <devpipe_read+0x26>
				return i;
  802ed9:	89 d8                	mov    %ebx,%eax
  802edb:	eb 44                	jmp    802f21 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802edd:	89 f2                	mov    %esi,%edx
  802edf:	89 f8                	mov    %edi,%eax
  802ee1:	e8 dc fe ff ff       	call   802dc2 <_pipeisclosed>
  802ee6:	85 c0                	test   %eax,%eax
  802ee8:	75 32                	jne    802f1c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802eea:	e8 8d e6 ff ff       	call   80157c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802eef:	8b 06                	mov    (%esi),%eax
  802ef1:	3b 46 04             	cmp    0x4(%esi),%eax
  802ef4:	74 df                	je     802ed5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802ef6:	99                   	cltd   
  802ef7:	c1 ea 1b             	shr    $0x1b,%edx
  802efa:	01 d0                	add    %edx,%eax
  802efc:	83 e0 1f             	and    $0x1f,%eax
  802eff:	29 d0                	sub    %edx,%eax
  802f01:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802f06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802f09:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802f0c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802f0f:	83 c3 01             	add    $0x1,%ebx
  802f12:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802f15:	75 d8                	jne    802eef <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802f17:	8b 45 10             	mov    0x10(%ebp),%eax
  802f1a:	eb 05                	jmp    802f21 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802f1c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802f21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f24:	5b                   	pop    %ebx
  802f25:	5e                   	pop    %esi
  802f26:	5f                   	pop    %edi
  802f27:	5d                   	pop    %ebp
  802f28:	c3                   	ret    

00802f29 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802f29:	55                   	push   %ebp
  802f2a:	89 e5                	mov    %esp,%ebp
  802f2c:	56                   	push   %esi
  802f2d:	53                   	push   %ebx
  802f2e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802f31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f34:	50                   	push   %eax
  802f35:	e8 2b ef ff ff       	call   801e65 <fd_alloc>
  802f3a:	83 c4 10             	add    $0x10,%esp
  802f3d:	89 c2                	mov    %eax,%edx
  802f3f:	85 c0                	test   %eax,%eax
  802f41:	0f 88 2c 01 00 00    	js     803073 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802f47:	83 ec 04             	sub    $0x4,%esp
  802f4a:	68 07 04 00 00       	push   $0x407
  802f4f:	ff 75 f4             	pushl  -0xc(%ebp)
  802f52:	6a 00                	push   $0x0
  802f54:	e8 42 e6 ff ff       	call   80159b <sys_page_alloc>
  802f59:	83 c4 10             	add    $0x10,%esp
  802f5c:	89 c2                	mov    %eax,%edx
  802f5e:	85 c0                	test   %eax,%eax
  802f60:	0f 88 0d 01 00 00    	js     803073 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802f66:	83 ec 0c             	sub    $0xc,%esp
  802f69:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f6c:	50                   	push   %eax
  802f6d:	e8 f3 ee ff ff       	call   801e65 <fd_alloc>
  802f72:	89 c3                	mov    %eax,%ebx
  802f74:	83 c4 10             	add    $0x10,%esp
  802f77:	85 c0                	test   %eax,%eax
  802f79:	0f 88 e2 00 00 00    	js     803061 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802f7f:	83 ec 04             	sub    $0x4,%esp
  802f82:	68 07 04 00 00       	push   $0x407
  802f87:	ff 75 f0             	pushl  -0x10(%ebp)
  802f8a:	6a 00                	push   $0x0
  802f8c:	e8 0a e6 ff ff       	call   80159b <sys_page_alloc>
  802f91:	89 c3                	mov    %eax,%ebx
  802f93:	83 c4 10             	add    $0x10,%esp
  802f96:	85 c0                	test   %eax,%eax
  802f98:	0f 88 c3 00 00 00    	js     803061 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802f9e:	83 ec 0c             	sub    $0xc,%esp
  802fa1:	ff 75 f4             	pushl  -0xc(%ebp)
  802fa4:	e8 a5 ee ff ff       	call   801e4e <fd2data>
  802fa9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fab:	83 c4 0c             	add    $0xc,%esp
  802fae:	68 07 04 00 00       	push   $0x407
  802fb3:	50                   	push   %eax
  802fb4:	6a 00                	push   $0x0
  802fb6:	e8 e0 e5 ff ff       	call   80159b <sys_page_alloc>
  802fbb:	89 c3                	mov    %eax,%ebx
  802fbd:	83 c4 10             	add    $0x10,%esp
  802fc0:	85 c0                	test   %eax,%eax
  802fc2:	0f 88 89 00 00 00    	js     803051 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fc8:	83 ec 0c             	sub    $0xc,%esp
  802fcb:	ff 75 f0             	pushl  -0x10(%ebp)
  802fce:	e8 7b ee ff ff       	call   801e4e <fd2data>
  802fd3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802fda:	50                   	push   %eax
  802fdb:	6a 00                	push   $0x0
  802fdd:	56                   	push   %esi
  802fde:	6a 00                	push   $0x0
  802fe0:	e8 f9 e5 ff ff       	call   8015de <sys_page_map>
  802fe5:	89 c3                	mov    %eax,%ebx
  802fe7:	83 c4 20             	add    $0x20,%esp
  802fea:	85 c0                	test   %eax,%eax
  802fec:	78 55                	js     803043 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802fee:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ff7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ffc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803003:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  803009:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80300c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80300e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803011:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803018:	83 ec 0c             	sub    $0xc,%esp
  80301b:	ff 75 f4             	pushl  -0xc(%ebp)
  80301e:	e8 1b ee ff ff       	call   801e3e <fd2num>
  803023:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803026:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803028:	83 c4 04             	add    $0x4,%esp
  80302b:	ff 75 f0             	pushl  -0x10(%ebp)
  80302e:	e8 0b ee ff ff       	call   801e3e <fd2num>
  803033:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803036:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  803039:	83 c4 10             	add    $0x10,%esp
  80303c:	ba 00 00 00 00       	mov    $0x0,%edx
  803041:	eb 30                	jmp    803073 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  803043:	83 ec 08             	sub    $0x8,%esp
  803046:	56                   	push   %esi
  803047:	6a 00                	push   $0x0
  803049:	e8 d2 e5 ff ff       	call   801620 <sys_page_unmap>
  80304e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  803051:	83 ec 08             	sub    $0x8,%esp
  803054:	ff 75 f0             	pushl  -0x10(%ebp)
  803057:	6a 00                	push   $0x0
  803059:	e8 c2 e5 ff ff       	call   801620 <sys_page_unmap>
  80305e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  803061:	83 ec 08             	sub    $0x8,%esp
  803064:	ff 75 f4             	pushl  -0xc(%ebp)
  803067:	6a 00                	push   $0x0
  803069:	e8 b2 e5 ff ff       	call   801620 <sys_page_unmap>
  80306e:	83 c4 10             	add    $0x10,%esp
  803071:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  803073:	89 d0                	mov    %edx,%eax
  803075:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803078:	5b                   	pop    %ebx
  803079:	5e                   	pop    %esi
  80307a:	5d                   	pop    %ebp
  80307b:	c3                   	ret    

0080307c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80307c:	55                   	push   %ebp
  80307d:	89 e5                	mov    %esp,%ebp
  80307f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803082:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803085:	50                   	push   %eax
  803086:	ff 75 08             	pushl  0x8(%ebp)
  803089:	e8 26 ee ff ff       	call   801eb4 <fd_lookup>
  80308e:	83 c4 10             	add    $0x10,%esp
  803091:	85 c0                	test   %eax,%eax
  803093:	78 18                	js     8030ad <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803095:	83 ec 0c             	sub    $0xc,%esp
  803098:	ff 75 f4             	pushl  -0xc(%ebp)
  80309b:	e8 ae ed ff ff       	call   801e4e <fd2data>
	return _pipeisclosed(fd, p);
  8030a0:	89 c2                	mov    %eax,%edx
  8030a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030a5:	e8 18 fd ff ff       	call   802dc2 <_pipeisclosed>
  8030aa:	83 c4 10             	add    $0x10,%esp
}
  8030ad:	c9                   	leave  
  8030ae:	c3                   	ret    

008030af <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8030af:	55                   	push   %ebp
  8030b0:	89 e5                	mov    %esp,%ebp
  8030b2:	56                   	push   %esi
  8030b3:	53                   	push   %ebx
  8030b4:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8030b7:	85 f6                	test   %esi,%esi
  8030b9:	75 16                	jne    8030d1 <wait+0x22>
  8030bb:	68 23 3d 80 00       	push   $0x803d23
  8030c0:	68 ef 36 80 00       	push   $0x8036ef
  8030c5:	6a 09                	push   $0x9
  8030c7:	68 2e 3d 80 00       	push   $0x803d2e
  8030cc:	e8 76 d9 ff ff       	call   800a47 <_panic>
	e = &envs[ENVX(envid)];
  8030d1:	89 f3                	mov    %esi,%ebx
  8030d3:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8030d9:	69 db d4 00 00 00    	imul   $0xd4,%ebx,%ebx
  8030df:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8030e5:	eb 05                	jmp    8030ec <wait+0x3d>
		sys_yield();
  8030e7:	e8 90 e4 ff ff       	call   80157c <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8030ec:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
  8030f2:	39 c6                	cmp    %eax,%esi
  8030f4:	75 0a                	jne    803100 <wait+0x51>
  8030f6:	8b 83 ac 00 00 00    	mov    0xac(%ebx),%eax
  8030fc:	85 c0                	test   %eax,%eax
  8030fe:	75 e7                	jne    8030e7 <wait+0x38>
		sys_yield();
}
  803100:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803103:	5b                   	pop    %ebx
  803104:	5e                   	pop    %esi
  803105:	5d                   	pop    %ebp
  803106:	c3                   	ret    

00803107 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  803107:	55                   	push   %ebp
  803108:	89 e5                	mov    %esp,%ebp
  80310a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80310d:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  803114:	75 2a                	jne    803140 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  803116:	83 ec 04             	sub    $0x4,%esp
  803119:	6a 07                	push   $0x7
  80311b:	68 00 f0 bf ee       	push   $0xeebff000
  803120:	6a 00                	push   $0x0
  803122:	e8 74 e4 ff ff       	call   80159b <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  803127:	83 c4 10             	add    $0x10,%esp
  80312a:	85 c0                	test   %eax,%eax
  80312c:	79 12                	jns    803140 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80312e:	50                   	push   %eax
  80312f:	68 eb 3a 80 00       	push   $0x803aeb
  803134:	6a 23                	push   $0x23
  803136:	68 39 3d 80 00       	push   $0x803d39
  80313b:	e8 07 d9 ff ff       	call   800a47 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  803140:	8b 45 08             	mov    0x8(%ebp),%eax
  803143:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  803148:	83 ec 08             	sub    $0x8,%esp
  80314b:	68 72 31 80 00       	push   $0x803172
  803150:	6a 00                	push   $0x0
  803152:	e8 8f e5 ff ff       	call   8016e6 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  803157:	83 c4 10             	add    $0x10,%esp
  80315a:	85 c0                	test   %eax,%eax
  80315c:	79 12                	jns    803170 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80315e:	50                   	push   %eax
  80315f:	68 eb 3a 80 00       	push   $0x803aeb
  803164:	6a 2c                	push   $0x2c
  803166:	68 39 3d 80 00       	push   $0x803d39
  80316b:	e8 d7 d8 ff ff       	call   800a47 <_panic>
	}
}
  803170:	c9                   	leave  
  803171:	c3                   	ret    

00803172 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  803172:	54                   	push   %esp
	movl _pgfault_handler, %eax
  803173:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  803178:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80317a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80317d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  803181:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  803186:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80318a:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80318c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80318f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  803190:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  803193:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  803194:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  803195:	c3                   	ret    

00803196 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  803196:	55                   	push   %ebp
  803197:	89 e5                	mov    %esp,%ebp
  803199:	56                   	push   %esi
  80319a:	53                   	push   %ebx
  80319b:	8b 75 08             	mov    0x8(%ebp),%esi
  80319e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8031a4:	85 c0                	test   %eax,%eax
  8031a6:	75 12                	jne    8031ba <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8031a8:	83 ec 0c             	sub    $0xc,%esp
  8031ab:	68 00 00 c0 ee       	push   $0xeec00000
  8031b0:	e8 96 e5 ff ff       	call   80174b <sys_ipc_recv>
  8031b5:	83 c4 10             	add    $0x10,%esp
  8031b8:	eb 0c                	jmp    8031c6 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8031ba:	83 ec 0c             	sub    $0xc,%esp
  8031bd:	50                   	push   %eax
  8031be:	e8 88 e5 ff ff       	call   80174b <sys_ipc_recv>
  8031c3:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8031c6:	85 f6                	test   %esi,%esi
  8031c8:	0f 95 c1             	setne  %cl
  8031cb:	85 db                	test   %ebx,%ebx
  8031cd:	0f 95 c2             	setne  %dl
  8031d0:	84 d1                	test   %dl,%cl
  8031d2:	74 09                	je     8031dd <ipc_recv+0x47>
  8031d4:	89 c2                	mov    %eax,%edx
  8031d6:	c1 ea 1f             	shr    $0x1f,%edx
  8031d9:	84 d2                	test   %dl,%dl
  8031db:	75 2d                	jne    80320a <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8031dd:	85 f6                	test   %esi,%esi
  8031df:	74 0d                	je     8031ee <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8031e1:	a1 24 54 80 00       	mov    0x805424,%eax
  8031e6:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8031ec:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8031ee:	85 db                	test   %ebx,%ebx
  8031f0:	74 0d                	je     8031ff <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8031f2:	a1 24 54 80 00       	mov    0x805424,%eax
  8031f7:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8031fd:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8031ff:	a1 24 54 80 00       	mov    0x805424,%eax
  803204:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80320a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80320d:	5b                   	pop    %ebx
  80320e:	5e                   	pop    %esi
  80320f:	5d                   	pop    %ebp
  803210:	c3                   	ret    

00803211 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  803211:	55                   	push   %ebp
  803212:	89 e5                	mov    %esp,%ebp
  803214:	57                   	push   %edi
  803215:	56                   	push   %esi
  803216:	53                   	push   %ebx
  803217:	83 ec 0c             	sub    $0xc,%esp
  80321a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80321d:	8b 75 0c             	mov    0xc(%ebp),%esi
  803220:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  803223:	85 db                	test   %ebx,%ebx
  803225:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80322a:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80322d:	ff 75 14             	pushl  0x14(%ebp)
  803230:	53                   	push   %ebx
  803231:	56                   	push   %esi
  803232:	57                   	push   %edi
  803233:	e8 f0 e4 ff ff       	call   801728 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  803238:	89 c2                	mov    %eax,%edx
  80323a:	c1 ea 1f             	shr    $0x1f,%edx
  80323d:	83 c4 10             	add    $0x10,%esp
  803240:	84 d2                	test   %dl,%dl
  803242:	74 17                	je     80325b <ipc_send+0x4a>
  803244:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803247:	74 12                	je     80325b <ipc_send+0x4a>
			panic("failed ipc %e", r);
  803249:	50                   	push   %eax
  80324a:	68 47 3d 80 00       	push   $0x803d47
  80324f:	6a 47                	push   $0x47
  803251:	68 55 3d 80 00       	push   $0x803d55
  803256:	e8 ec d7 ff ff       	call   800a47 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80325b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80325e:	75 07                	jne    803267 <ipc_send+0x56>
			sys_yield();
  803260:	e8 17 e3 ff ff       	call   80157c <sys_yield>
  803265:	eb c6                	jmp    80322d <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  803267:	85 c0                	test   %eax,%eax
  803269:	75 c2                	jne    80322d <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80326b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80326e:	5b                   	pop    %ebx
  80326f:	5e                   	pop    %esi
  803270:	5f                   	pop    %edi
  803271:	5d                   	pop    %ebp
  803272:	c3                   	ret    

00803273 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803273:	55                   	push   %ebp
  803274:	89 e5                	mov    %esp,%ebp
  803276:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  803279:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80327e:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  803284:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80328a:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  803290:	39 ca                	cmp    %ecx,%edx
  803292:	75 13                	jne    8032a7 <ipc_find_env+0x34>
			return envs[i].env_id;
  803294:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80329a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80329f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8032a5:	eb 0f                	jmp    8032b6 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8032a7:	83 c0 01             	add    $0x1,%eax
  8032aa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8032af:	75 cd                	jne    80327e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8032b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8032b6:	5d                   	pop    %ebp
  8032b7:	c3                   	ret    

008032b8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8032b8:	55                   	push   %ebp
  8032b9:	89 e5                	mov    %esp,%ebp
  8032bb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8032be:	89 d0                	mov    %edx,%eax
  8032c0:	c1 e8 16             	shr    $0x16,%eax
  8032c3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8032ca:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8032cf:	f6 c1 01             	test   $0x1,%cl
  8032d2:	74 1d                	je     8032f1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8032d4:	c1 ea 0c             	shr    $0xc,%edx
  8032d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8032de:	f6 c2 01             	test   $0x1,%dl
  8032e1:	74 0e                	je     8032f1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8032e3:	c1 ea 0c             	shr    $0xc,%edx
  8032e6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8032ed:	ef 
  8032ee:	0f b7 c0             	movzwl %ax,%eax
}
  8032f1:	5d                   	pop    %ebp
  8032f2:	c3                   	ret    
  8032f3:	66 90                	xchg   %ax,%ax
  8032f5:	66 90                	xchg   %ax,%ax
  8032f7:	66 90                	xchg   %ax,%ax
  8032f9:	66 90                	xchg   %ax,%ax
  8032fb:	66 90                	xchg   %ax,%ax
  8032fd:	66 90                	xchg   %ax,%ax
  8032ff:	90                   	nop

00803300 <__udivdi3>:
  803300:	55                   	push   %ebp
  803301:	57                   	push   %edi
  803302:	56                   	push   %esi
  803303:	53                   	push   %ebx
  803304:	83 ec 1c             	sub    $0x1c,%esp
  803307:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80330b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80330f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803317:	85 f6                	test   %esi,%esi
  803319:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80331d:	89 ca                	mov    %ecx,%edx
  80331f:	89 f8                	mov    %edi,%eax
  803321:	75 3d                	jne    803360 <__udivdi3+0x60>
  803323:	39 cf                	cmp    %ecx,%edi
  803325:	0f 87 c5 00 00 00    	ja     8033f0 <__udivdi3+0xf0>
  80332b:	85 ff                	test   %edi,%edi
  80332d:	89 fd                	mov    %edi,%ebp
  80332f:	75 0b                	jne    80333c <__udivdi3+0x3c>
  803331:	b8 01 00 00 00       	mov    $0x1,%eax
  803336:	31 d2                	xor    %edx,%edx
  803338:	f7 f7                	div    %edi
  80333a:	89 c5                	mov    %eax,%ebp
  80333c:	89 c8                	mov    %ecx,%eax
  80333e:	31 d2                	xor    %edx,%edx
  803340:	f7 f5                	div    %ebp
  803342:	89 c1                	mov    %eax,%ecx
  803344:	89 d8                	mov    %ebx,%eax
  803346:	89 cf                	mov    %ecx,%edi
  803348:	f7 f5                	div    %ebp
  80334a:	89 c3                	mov    %eax,%ebx
  80334c:	89 d8                	mov    %ebx,%eax
  80334e:	89 fa                	mov    %edi,%edx
  803350:	83 c4 1c             	add    $0x1c,%esp
  803353:	5b                   	pop    %ebx
  803354:	5e                   	pop    %esi
  803355:	5f                   	pop    %edi
  803356:	5d                   	pop    %ebp
  803357:	c3                   	ret    
  803358:	90                   	nop
  803359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803360:	39 ce                	cmp    %ecx,%esi
  803362:	77 74                	ja     8033d8 <__udivdi3+0xd8>
  803364:	0f bd fe             	bsr    %esi,%edi
  803367:	83 f7 1f             	xor    $0x1f,%edi
  80336a:	0f 84 98 00 00 00    	je     803408 <__udivdi3+0x108>
  803370:	bb 20 00 00 00       	mov    $0x20,%ebx
  803375:	89 f9                	mov    %edi,%ecx
  803377:	89 c5                	mov    %eax,%ebp
  803379:	29 fb                	sub    %edi,%ebx
  80337b:	d3 e6                	shl    %cl,%esi
  80337d:	89 d9                	mov    %ebx,%ecx
  80337f:	d3 ed                	shr    %cl,%ebp
  803381:	89 f9                	mov    %edi,%ecx
  803383:	d3 e0                	shl    %cl,%eax
  803385:	09 ee                	or     %ebp,%esi
  803387:	89 d9                	mov    %ebx,%ecx
  803389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80338d:	89 d5                	mov    %edx,%ebp
  80338f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803393:	d3 ed                	shr    %cl,%ebp
  803395:	89 f9                	mov    %edi,%ecx
  803397:	d3 e2                	shl    %cl,%edx
  803399:	89 d9                	mov    %ebx,%ecx
  80339b:	d3 e8                	shr    %cl,%eax
  80339d:	09 c2                	or     %eax,%edx
  80339f:	89 d0                	mov    %edx,%eax
  8033a1:	89 ea                	mov    %ebp,%edx
  8033a3:	f7 f6                	div    %esi
  8033a5:	89 d5                	mov    %edx,%ebp
  8033a7:	89 c3                	mov    %eax,%ebx
  8033a9:	f7 64 24 0c          	mull   0xc(%esp)
  8033ad:	39 d5                	cmp    %edx,%ebp
  8033af:	72 10                	jb     8033c1 <__udivdi3+0xc1>
  8033b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8033b5:	89 f9                	mov    %edi,%ecx
  8033b7:	d3 e6                	shl    %cl,%esi
  8033b9:	39 c6                	cmp    %eax,%esi
  8033bb:	73 07                	jae    8033c4 <__udivdi3+0xc4>
  8033bd:	39 d5                	cmp    %edx,%ebp
  8033bf:	75 03                	jne    8033c4 <__udivdi3+0xc4>
  8033c1:	83 eb 01             	sub    $0x1,%ebx
  8033c4:	31 ff                	xor    %edi,%edi
  8033c6:	89 d8                	mov    %ebx,%eax
  8033c8:	89 fa                	mov    %edi,%edx
  8033ca:	83 c4 1c             	add    $0x1c,%esp
  8033cd:	5b                   	pop    %ebx
  8033ce:	5e                   	pop    %esi
  8033cf:	5f                   	pop    %edi
  8033d0:	5d                   	pop    %ebp
  8033d1:	c3                   	ret    
  8033d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8033d8:	31 ff                	xor    %edi,%edi
  8033da:	31 db                	xor    %ebx,%ebx
  8033dc:	89 d8                	mov    %ebx,%eax
  8033de:	89 fa                	mov    %edi,%edx
  8033e0:	83 c4 1c             	add    $0x1c,%esp
  8033e3:	5b                   	pop    %ebx
  8033e4:	5e                   	pop    %esi
  8033e5:	5f                   	pop    %edi
  8033e6:	5d                   	pop    %ebp
  8033e7:	c3                   	ret    
  8033e8:	90                   	nop
  8033e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8033f0:	89 d8                	mov    %ebx,%eax
  8033f2:	f7 f7                	div    %edi
  8033f4:	31 ff                	xor    %edi,%edi
  8033f6:	89 c3                	mov    %eax,%ebx
  8033f8:	89 d8                	mov    %ebx,%eax
  8033fa:	89 fa                	mov    %edi,%edx
  8033fc:	83 c4 1c             	add    $0x1c,%esp
  8033ff:	5b                   	pop    %ebx
  803400:	5e                   	pop    %esi
  803401:	5f                   	pop    %edi
  803402:	5d                   	pop    %ebp
  803403:	c3                   	ret    
  803404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803408:	39 ce                	cmp    %ecx,%esi
  80340a:	72 0c                	jb     803418 <__udivdi3+0x118>
  80340c:	31 db                	xor    %ebx,%ebx
  80340e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803412:	0f 87 34 ff ff ff    	ja     80334c <__udivdi3+0x4c>
  803418:	bb 01 00 00 00       	mov    $0x1,%ebx
  80341d:	e9 2a ff ff ff       	jmp    80334c <__udivdi3+0x4c>
  803422:	66 90                	xchg   %ax,%ax
  803424:	66 90                	xchg   %ax,%ax
  803426:	66 90                	xchg   %ax,%ax
  803428:	66 90                	xchg   %ax,%ax
  80342a:	66 90                	xchg   %ax,%ax
  80342c:	66 90                	xchg   %ax,%ax
  80342e:	66 90                	xchg   %ax,%ax

00803430 <__umoddi3>:
  803430:	55                   	push   %ebp
  803431:	57                   	push   %edi
  803432:	56                   	push   %esi
  803433:	53                   	push   %ebx
  803434:	83 ec 1c             	sub    $0x1c,%esp
  803437:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80343b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80343f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803447:	85 d2                	test   %edx,%edx
  803449:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80344d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803451:	89 f3                	mov    %esi,%ebx
  803453:	89 3c 24             	mov    %edi,(%esp)
  803456:	89 74 24 04          	mov    %esi,0x4(%esp)
  80345a:	75 1c                	jne    803478 <__umoddi3+0x48>
  80345c:	39 f7                	cmp    %esi,%edi
  80345e:	76 50                	jbe    8034b0 <__umoddi3+0x80>
  803460:	89 c8                	mov    %ecx,%eax
  803462:	89 f2                	mov    %esi,%edx
  803464:	f7 f7                	div    %edi
  803466:	89 d0                	mov    %edx,%eax
  803468:	31 d2                	xor    %edx,%edx
  80346a:	83 c4 1c             	add    $0x1c,%esp
  80346d:	5b                   	pop    %ebx
  80346e:	5e                   	pop    %esi
  80346f:	5f                   	pop    %edi
  803470:	5d                   	pop    %ebp
  803471:	c3                   	ret    
  803472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803478:	39 f2                	cmp    %esi,%edx
  80347a:	89 d0                	mov    %edx,%eax
  80347c:	77 52                	ja     8034d0 <__umoddi3+0xa0>
  80347e:	0f bd ea             	bsr    %edx,%ebp
  803481:	83 f5 1f             	xor    $0x1f,%ebp
  803484:	75 5a                	jne    8034e0 <__umoddi3+0xb0>
  803486:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80348a:	0f 82 e0 00 00 00    	jb     803570 <__umoddi3+0x140>
  803490:	39 0c 24             	cmp    %ecx,(%esp)
  803493:	0f 86 d7 00 00 00    	jbe    803570 <__umoddi3+0x140>
  803499:	8b 44 24 08          	mov    0x8(%esp),%eax
  80349d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8034a1:	83 c4 1c             	add    $0x1c,%esp
  8034a4:	5b                   	pop    %ebx
  8034a5:	5e                   	pop    %esi
  8034a6:	5f                   	pop    %edi
  8034a7:	5d                   	pop    %ebp
  8034a8:	c3                   	ret    
  8034a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8034b0:	85 ff                	test   %edi,%edi
  8034b2:	89 fd                	mov    %edi,%ebp
  8034b4:	75 0b                	jne    8034c1 <__umoddi3+0x91>
  8034b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8034bb:	31 d2                	xor    %edx,%edx
  8034bd:	f7 f7                	div    %edi
  8034bf:	89 c5                	mov    %eax,%ebp
  8034c1:	89 f0                	mov    %esi,%eax
  8034c3:	31 d2                	xor    %edx,%edx
  8034c5:	f7 f5                	div    %ebp
  8034c7:	89 c8                	mov    %ecx,%eax
  8034c9:	f7 f5                	div    %ebp
  8034cb:	89 d0                	mov    %edx,%eax
  8034cd:	eb 99                	jmp    803468 <__umoddi3+0x38>
  8034cf:	90                   	nop
  8034d0:	89 c8                	mov    %ecx,%eax
  8034d2:	89 f2                	mov    %esi,%edx
  8034d4:	83 c4 1c             	add    $0x1c,%esp
  8034d7:	5b                   	pop    %ebx
  8034d8:	5e                   	pop    %esi
  8034d9:	5f                   	pop    %edi
  8034da:	5d                   	pop    %ebp
  8034db:	c3                   	ret    
  8034dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8034e0:	8b 34 24             	mov    (%esp),%esi
  8034e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8034e8:	89 e9                	mov    %ebp,%ecx
  8034ea:	29 ef                	sub    %ebp,%edi
  8034ec:	d3 e0                	shl    %cl,%eax
  8034ee:	89 f9                	mov    %edi,%ecx
  8034f0:	89 f2                	mov    %esi,%edx
  8034f2:	d3 ea                	shr    %cl,%edx
  8034f4:	89 e9                	mov    %ebp,%ecx
  8034f6:	09 c2                	or     %eax,%edx
  8034f8:	89 d8                	mov    %ebx,%eax
  8034fa:	89 14 24             	mov    %edx,(%esp)
  8034fd:	89 f2                	mov    %esi,%edx
  8034ff:	d3 e2                	shl    %cl,%edx
  803501:	89 f9                	mov    %edi,%ecx
  803503:	89 54 24 04          	mov    %edx,0x4(%esp)
  803507:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80350b:	d3 e8                	shr    %cl,%eax
  80350d:	89 e9                	mov    %ebp,%ecx
  80350f:	89 c6                	mov    %eax,%esi
  803511:	d3 e3                	shl    %cl,%ebx
  803513:	89 f9                	mov    %edi,%ecx
  803515:	89 d0                	mov    %edx,%eax
  803517:	d3 e8                	shr    %cl,%eax
  803519:	89 e9                	mov    %ebp,%ecx
  80351b:	09 d8                	or     %ebx,%eax
  80351d:	89 d3                	mov    %edx,%ebx
  80351f:	89 f2                	mov    %esi,%edx
  803521:	f7 34 24             	divl   (%esp)
  803524:	89 d6                	mov    %edx,%esi
  803526:	d3 e3                	shl    %cl,%ebx
  803528:	f7 64 24 04          	mull   0x4(%esp)
  80352c:	39 d6                	cmp    %edx,%esi
  80352e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803532:	89 d1                	mov    %edx,%ecx
  803534:	89 c3                	mov    %eax,%ebx
  803536:	72 08                	jb     803540 <__umoddi3+0x110>
  803538:	75 11                	jne    80354b <__umoddi3+0x11b>
  80353a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80353e:	73 0b                	jae    80354b <__umoddi3+0x11b>
  803540:	2b 44 24 04          	sub    0x4(%esp),%eax
  803544:	1b 14 24             	sbb    (%esp),%edx
  803547:	89 d1                	mov    %edx,%ecx
  803549:	89 c3                	mov    %eax,%ebx
  80354b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80354f:	29 da                	sub    %ebx,%edx
  803551:	19 ce                	sbb    %ecx,%esi
  803553:	89 f9                	mov    %edi,%ecx
  803555:	89 f0                	mov    %esi,%eax
  803557:	d3 e0                	shl    %cl,%eax
  803559:	89 e9                	mov    %ebp,%ecx
  80355b:	d3 ea                	shr    %cl,%edx
  80355d:	89 e9                	mov    %ebp,%ecx
  80355f:	d3 ee                	shr    %cl,%esi
  803561:	09 d0                	or     %edx,%eax
  803563:	89 f2                	mov    %esi,%edx
  803565:	83 c4 1c             	add    $0x1c,%esp
  803568:	5b                   	pop    %ebx
  803569:	5e                   	pop    %esi
  80356a:	5f                   	pop    %edi
  80356b:	5d                   	pop    %ebp
  80356c:	c3                   	ret    
  80356d:	8d 76 00             	lea    0x0(%esi),%esi
  803570:	29 f9                	sub    %edi,%ecx
  803572:	19 d6                	sbb    %edx,%esi
  803574:	89 74 24 04          	mov    %esi,0x4(%esp)
  803578:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80357c:	e9 18 ff ff ff       	jmp    803499 <__umoddi3+0x69>
