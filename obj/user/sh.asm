
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
  80002c:	e8 84 09 00 00       	call   8009b5 <libmain>
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
  80005b:	68 40 33 80 00       	push   $0x803340
  800060:	e8 e9 0a 00 00       	call   800b4e <cprintf>
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
  80007f:	68 4f 33 80 00       	push   $0x80334f
  800084:	e8 c5 0a 00 00       	call   800b4e <cprintf>
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
  8000ab:	68 5d 33 80 00       	push   $0x80335d
  8000b0:	e8 19 12 00 00       	call   8012ce <strchr>
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
  8000d8:	68 62 33 80 00       	push   $0x803362
  8000dd:	e8 6c 0a 00 00       	call   800b4e <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 73 33 80 00       	push   $0x803373
  8000fb:	e8 ce 11 00 00       	call   8012ce <strchr>
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
  800126:	68 67 33 80 00       	push   $0x803367
  80012b:	e8 1e 0a 00 00       	call   800b4e <cprintf>
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
  80014c:	68 6f 33 80 00       	push   $0x80336f
  800151:	e8 78 11 00 00       	call   8012ce <strchr>
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
  80017b:	68 7b 33 80 00       	push   $0x80337b
  800180:	e8 c9 09 00 00       	call   800b4e <cprintf>
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
  800273:	68 85 33 80 00       	push   $0x803385
  800278:	e8 d1 08 00 00       	call   800b4e <cprintf>
				exit();
  80027d:	e8 d9 07 00 00       	call   800a5b <exit>
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
  8002a7:	68 d8 34 80 00       	push   $0x8034d8
  8002ac:	e8 9d 08 00 00       	call   800b4e <cprintf>
				exit();
  8002b1:	e8 a5 07 00 00       	call   800a5b <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 b7 20 00 00       	call   80237d <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
				cprintf("open %s for read: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 99 33 80 00       	push   $0x803399
  8002db:	e8 6e 08 00 00       	call   800b4e <cprintf>
				exit();
  8002e0:	e8 76 07 00 00       	call   800a5b <exit>
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
  8002f8:	e8 09 1b 00 00       	call   801e06 <dup>
				close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 b1 1a 00 00       	call   801db6 <close>
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
  800323:	68 00 35 80 00       	push   $0x803500
  800328:	e8 21 08 00 00       	call   800b4e <cprintf>
				exit();
  80032d:	e8 29 07 00 00       	call   800a5b <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 38 20 00 00       	call   80237d <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 ae 33 80 00       	push   $0x8033ae
  80035a:	e8 ef 07 00 00       	call   800b4e <cprintf>
				exit();
  80035f:	e8 f7 06 00 00       	call   800a5b <exit>
  800364:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800367:	83 ff 01             	cmp    $0x1,%edi
  80036a:	0f 84 ba fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	6a 01                	push   $0x1
  800375:	57                   	push   %edi
  800376:	e8 8b 1a 00 00       	call   801e06 <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 33 1a 00 00       	call   801db6 <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 4f 29 00 00       	call   802ce9 <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 c4 33 80 00       	push   $0x8033c4
  8003aa:	e8 9f 07 00 00       	call   800b4e <cprintf>
				exit();
  8003af:	e8 a7 06 00 00       	call   800a5b <exit>
  8003b4:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003be:	74 1c                	je     8003dc <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c0:	83 ec 04             	sub    $0x4,%esp
  8003c3:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003c9:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003cf:	68 cd 33 80 00       	push   $0x8033cd
  8003d4:	e8 75 07 00 00       	call   800b4e <cprintf>
  8003d9:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dc:	e8 cf 14 00 00       	call   8018b0 <fork>
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 16                	jns    8003fd <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	50                   	push   %eax
  8003eb:	68 da 33 80 00       	push   $0x8033da
  8003f0:	e8 59 07 00 00       	call   800b4e <cprintf>
				exit();
  8003f5:	e8 61 06 00 00       	call   800a5b <exit>
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
  800411:	e8 f0 19 00 00       	call   801e06 <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 92 19 00 00       	call   801db6 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 81 19 00 00       	call   801db6 <close>
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
  80044e:	e8 b3 19 00 00       	call   801e06 <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 55 19 00 00       	call   801db6 <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 44 19 00 00       	call   801db6 <close>
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 17                	jmp    80048e <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800477:	50                   	push   %eax
  800478:	68 e3 33 80 00       	push   $0x8033e3
  80047d:	6a 79                	push   $0x79
  80047f:	68 ff 33 80 00       	push   $0x8033ff
  800484:	e8 ec 05 00 00       	call   800a75 <_panic>
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
  800499:	0f 84 96 01 00 00    	je     800635 <runcmd+0x42c>
			cprintf("EMPTY COMMAND\n");
  80049f:	83 ec 0c             	sub    $0xc,%esp
  8004a2:	68 09 34 80 00       	push   $0x803409
  8004a7:	e8 a2 06 00 00       	call   800b4e <cprintf>
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	e9 81 01 00 00       	jmp    800635 <runcmd+0x42c>

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
  8004d4:	e8 ed 0c 00 00       	call   8011c6 <strcpy>
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
  8004ee:	74 49                	je     800539 <runcmd+0x330>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f0:	a1 24 54 80 00       	mov    0x805424,%eax
  8004f5:	8b 40 50             	mov    0x50(%eax),%eax
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	50                   	push   %eax
  8004fc:	68 18 34 80 00       	push   $0x803418
  800501:	e8 48 06 00 00       	call   800b4e <cprintf>
  800506:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 11                	jmp    80051f <runcmd+0x316>
			cprintf(" %s", argv[i]);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	50                   	push   %eax
  800512:	68 a0 34 80 00       	push   $0x8034a0
  800517:	e8 32 06 00 00       	call   800b4e <cprintf>
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800522:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800525:	85 c0                	test   %eax,%eax
  800527:	75 e5                	jne    80050e <runcmd+0x305>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	68 60 33 80 00       	push   $0x803360
  800531:	e8 18 06 00 00       	call   800b4e <cprintf>
  800536:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 a8             	pushl  -0x58(%ebp)
  800543:	e8 e9 1f 00 00       	call   802531 <spawn>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	0f 89 c3 00 00 00    	jns    800618 <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800555:	83 ec 04             	sub    $0x4,%esp
  800558:	50                   	push   %eax
  800559:	ff 75 a8             	pushl  -0x58(%ebp)
  80055c:	68 26 34 80 00       	push   $0x803426
  800561:	e8 e8 05 00 00       	call   800b4e <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800566:	e8 76 18 00 00       	call   801de1 <close_all>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 4c                	jmp    8005bc <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800570:	a1 24 54 80 00       	mov    0x805424,%eax
  800575:	8b 40 50             	mov    0x50(%eax),%eax
  800578:	53                   	push   %ebx
  800579:	ff 75 a8             	pushl  -0x58(%ebp)
  80057c:	50                   	push   %eax
  80057d:	68 34 34 80 00       	push   $0x803434
  800582:	e8 c7 05 00 00       	call   800b4e <cprintf>
  800587:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058a:	83 ec 0c             	sub    $0xc,%esp
  80058d:	53                   	push   %ebx
  80058e:	e8 dc 28 00 00       	call   802e6f <wait>
		if (debug)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059d:	0f 84 8c 00 00 00    	je     80062f <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a3:	a1 24 54 80 00       	mov    0x805424,%eax
  8005a8:	8b 40 50             	mov    0x50(%eax),%eax
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	50                   	push   %eax
  8005af:	68 49 34 80 00       	push   $0x803449
  8005b4:	e8 95 05 00 00       	call   800b4e <cprintf>
  8005b9:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005bc:	85 ff                	test   %edi,%edi
  8005be:	74 51                	je     800611 <runcmd+0x408>
		if (debug)
  8005c0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c7:	74 1a                	je     8005e3 <runcmd+0x3da>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005c9:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ce:	8b 40 50             	mov    0x50(%eax),%eax
  8005d1:	83 ec 04             	sub    $0x4,%esp
  8005d4:	57                   	push   %edi
  8005d5:	50                   	push   %eax
  8005d6:	68 5f 34 80 00       	push   $0x80345f
  8005db:	e8 6e 05 00 00       	call   800b4e <cprintf>
  8005e0:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	57                   	push   %edi
  8005e7:	e8 83 28 00 00       	call   802e6f <wait>
		if (debug)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f6:	74 19                	je     800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f8:	a1 24 54 80 00       	mov    0x805424,%eax
  8005fd:	8b 40 50             	mov    0x50(%eax),%eax
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	50                   	push   %eax
  800604:	68 49 34 80 00       	push   $0x803449
  800609:	e8 40 05 00 00       	call   800b4e <cprintf>
  80060e:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800611:	e8 45 04 00 00       	call   800a5b <exit>
  800616:	eb 1d                	jmp    800635 <runcmd+0x42c>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800618:	e8 c4 17 00 00       	call   801de1 <close_all>
	if (r >= 0) {
		if (debug)
  80061d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800624:	0f 84 60 ff ff ff    	je     80058a <runcmd+0x381>
  80062a:	e9 41 ff ff ff       	jmp    800570 <runcmd+0x367>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80062f:	85 ff                	test   %edi,%edi
  800631:	75 b0                	jne    8005e3 <runcmd+0x3da>
  800633:	eb dc                	jmp    800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800638:	5b                   	pop    %ebx
  800639:	5e                   	pop    %esi
  80063a:	5f                   	pop    %edi
  80063b:	5d                   	pop    %ebp
  80063c:	c3                   	ret    

0080063d <usage>:
}


void
usage(void)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800643:	68 28 35 80 00       	push   $0x803528
  800648:	e8 01 05 00 00       	call   800b4e <cprintf>
	exit();
  80064d:	e8 09 04 00 00       	call   800a5b <exit>
}
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <umain>:

void
umain(int argc, char **argv)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	57                   	push   %edi
  80065b:	56                   	push   %esi
  80065c:	53                   	push   %ebx
  80065d:	83 ec 30             	sub    $0x30,%esp
  800660:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800663:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	57                   	push   %edi
  800668:	8d 45 08             	lea    0x8(%ebp),%eax
  80066b:	50                   	push   %eax
  80066c:	e8 51 14 00 00       	call   801ac2 <argstart>
	while ((r = argnext(&args)) >= 0)
  800671:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800674:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80067b:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800680:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800683:	eb 2f                	jmp    8006b4 <umain+0x5d>
		switch (r) {
  800685:	83 f8 69             	cmp    $0x69,%eax
  800688:	74 25                	je     8006af <umain+0x58>
  80068a:	83 f8 78             	cmp    $0x78,%eax
  80068d:	74 07                	je     800696 <umain+0x3f>
  80068f:	83 f8 64             	cmp    $0x64,%eax
  800692:	75 14                	jne    8006a8 <umain+0x51>
  800694:	eb 09                	jmp    80069f <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800696:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  80069d:	eb 15                	jmp    8006b4 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80069f:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006a6:	eb 0c                	jmp    8006b4 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006a8:	e8 90 ff ff ff       	call   80063d <usage>
  8006ad:	eb 05                	jmp    8006b4 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006af:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	e8 35 14 00 00       	call   801af2 <argnext>
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	79 c1                	jns    800685 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006c4:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c8:	7e 05                	jle    8006cf <umain+0x78>
		usage();
  8006ca:	e8 6e ff ff ff       	call   80063d <usage>
	if (argc == 2) {
  8006cf:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d3:	75 56                	jne    80072b <umain+0xd4>
		close(0);
  8006d5:	83 ec 0c             	sub    $0xc,%esp
  8006d8:	6a 00                	push   $0x0
  8006da:	e8 d7 16 00 00       	call   801db6 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	6a 00                	push   $0x0
  8006e4:	ff 77 04             	pushl  0x4(%edi)
  8006e7:	e8 91 1c 00 00       	call   80237d <open>
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	79 1b                	jns    80070e <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	50                   	push   %eax
  8006f7:	ff 77 04             	pushl  0x4(%edi)
  8006fa:	68 7c 34 80 00       	push   $0x80347c
  8006ff:	68 29 01 00 00       	push   $0x129
  800704:	68 ff 33 80 00       	push   $0x8033ff
  800709:	e8 67 03 00 00       	call   800a75 <_panic>
		assert(r == 0);
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 19                	je     80072b <umain+0xd4>
  800712:	68 88 34 80 00       	push   $0x803488
  800717:	68 8f 34 80 00       	push   $0x80348f
  80071c:	68 2a 01 00 00       	push   $0x12a
  800721:	68 ff 33 80 00       	push   $0x8033ff
  800726:	e8 4a 03 00 00       	call   800a75 <_panic>
	}
	if (interactive == '?')
  80072b:	83 fe 3f             	cmp    $0x3f,%esi
  80072e:	75 0f                	jne    80073f <umain+0xe8>
		interactive = iscons(0);
  800730:	83 ec 0c             	sub    $0xc,%esp
  800733:	6a 00                	push   $0x0
  800735:	e8 f5 01 00 00       	call   80092f <iscons>
  80073a:	89 c6                	mov    %eax,%esi
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	85 f6                	test   %esi,%esi
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	bf a4 34 80 00       	mov    $0x8034a4,%edi
  80074b:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80074e:	83 ec 0c             	sub    $0xc,%esp
  800751:	57                   	push   %edi
  800752:	e8 43 09 00 00       	call   80109a <readline>
  800757:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 c0                	test   %eax,%eax
  80075e:	75 1e                	jne    80077e <umain+0x127>
			if (debug)
  800760:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800767:	74 10                	je     800779 <umain+0x122>
				cprintf("EXITING\n");
  800769:	83 ec 0c             	sub    $0xc,%esp
  80076c:	68 a7 34 80 00       	push   $0x8034a7
  800771:	e8 d8 03 00 00       	call   800b4e <cprintf>
  800776:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800779:	e8 dd 02 00 00       	call   800a5b <exit>
		}
		if (debug)
  80077e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800785:	74 11                	je     800798 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	68 b0 34 80 00       	push   $0x8034b0
  800790:	e8 b9 03 00 00       	call   800b4e <cprintf>
  800795:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  800798:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079b:	74 b1                	je     80074e <umain+0xf7>
			continue;
		if (echocmds)
  80079d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a1:	74 11                	je     8007b4 <umain+0x15d>
			printf("# %s\n", buf);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	68 ba 34 80 00       	push   $0x8034ba
  8007ac:	e8 6a 1d 00 00       	call   80251b <printf>
  8007b1:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bb:	74 10                	je     8007cd <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	68 c0 34 80 00       	push   $0x8034c0
  8007c5:	e8 84 03 00 00       	call   800b4e <cprintf>
  8007ca:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cd:	e8 de 10 00 00       	call   8018b0 <fork>
  8007d2:	89 c6                	mov    %eax,%esi
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	79 15                	jns    8007ed <umain+0x196>
			panic("fork: %e", r);
  8007d8:	50                   	push   %eax
  8007d9:	68 da 33 80 00       	push   $0x8033da
  8007de:	68 41 01 00 00       	push   $0x141
  8007e3:	68 ff 33 80 00       	push   $0x8033ff
  8007e8:	e8 88 02 00 00       	call   800a75 <_panic>
		if (debug)
  8007ed:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f4:	74 11                	je     800807 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	50                   	push   %eax
  8007fa:	68 cd 34 80 00       	push   $0x8034cd
  8007ff:	e8 4a 03 00 00       	call   800b4e <cprintf>
  800804:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800807:	85 f6                	test   %esi,%esi
  800809:	75 16                	jne    800821 <umain+0x1ca>
			runcmd(buf);
  80080b:	83 ec 0c             	sub    $0xc,%esp
  80080e:	53                   	push   %ebx
  80080f:	e8 f5 f9 ff ff       	call   800209 <runcmd>
			exit();
  800814:	e8 42 02 00 00       	call   800a5b <exit>
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	e9 2d ff ff ff       	jmp    80074e <umain+0xf7>
		} else
			wait(r);
  800821:	83 ec 0c             	sub    $0xc,%esp
  800824:	56                   	push   %esi
  800825:	e8 45 26 00 00       	call   802e6f <wait>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	e9 1c ff ff ff       	jmp    80074e <umain+0xf7>

00800832 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800842:	68 49 35 80 00       	push   $0x803549
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	e8 77 09 00 00       	call   8011c6 <strcpy>
	return 0;
}
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	57                   	push   %edi
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800862:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800867:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80086d:	eb 2d                	jmp    80089c <devcons_write+0x46>
		m = n - tot;
  80086f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800872:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800874:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800877:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80087c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80087f:	83 ec 04             	sub    $0x4,%esp
  800882:	53                   	push   %ebx
  800883:	03 45 0c             	add    0xc(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	57                   	push   %edi
  800888:	e8 cb 0a 00 00       	call   801358 <memmove>
		sys_cputs(buf, m);
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	57                   	push   %edi
  800892:	e8 76 0c 00 00       	call   80150d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800897:	01 de                	add    %ebx,%esi
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008a1:	72 cc                	jb     80086f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8008b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008ba:	74 2a                	je     8008e6 <devcons_read+0x3b>
  8008bc:	eb 05                	jmp    8008c3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008be:	e8 e7 0c 00 00       	call   8015aa <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c3:	e8 63 0c 00 00       	call   80152b <sys_cgetc>
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 f2                	je     8008be <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	78 16                	js     8008e6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d0:	83 f8 04             	cmp    $0x4,%eax
  8008d3:	74 0c                	je     8008e1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	88 02                	mov    %al,(%edx)
	return 1;
  8008da:	b8 01 00 00 00       	mov    $0x1,%eax
  8008df:	eb 05                	jmp    8008e6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008f4:	6a 01                	push   $0x1
  8008f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008f9:	50                   	push   %eax
  8008fa:	e8 0e 0c 00 00       	call   80150d <sys_cputs>
}
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <getchar>:

int
getchar(void)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80090a:	6a 01                	push   $0x1
  80090c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80090f:	50                   	push   %eax
  800910:	6a 00                	push   $0x0
  800912:	e8 db 15 00 00       	call   801ef2 <read>
	if (r < 0)
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 0f                	js     80092d <getchar+0x29>
		return r;
	if (r < 1)
  80091e:	85 c0                	test   %eax,%eax
  800920:	7e 06                	jle    800928 <getchar+0x24>
		return -E_EOF;
	return c;
  800922:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800926:	eb 05                	jmp    80092d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800928:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800938:	50                   	push   %eax
  800939:	ff 75 08             	pushl  0x8(%ebp)
  80093c:	e8 4b 13 00 00       	call   801c8c <fd_lookup>
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	85 c0                	test   %eax,%eax
  800946:	78 11                	js     800959 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800951:	39 10                	cmp    %edx,(%eax)
  800953:	0f 94 c0             	sete   %al
  800956:	0f b6 c0             	movzbl %al,%eax
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <opencons>:

int
opencons(void)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800964:	50                   	push   %eax
  800965:	e8 d3 12 00 00       	call   801c3d <fd_alloc>
  80096a:	83 c4 10             	add    $0x10,%esp
		return r;
  80096d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80096f:	85 c0                	test   %eax,%eax
  800971:	78 3e                	js     8009b1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800973:	83 ec 04             	sub    $0x4,%esp
  800976:	68 07 04 00 00       	push   $0x407
  80097b:	ff 75 f4             	pushl  -0xc(%ebp)
  80097e:	6a 00                	push   $0x0
  800980:	e8 44 0c 00 00       	call   8015c9 <sys_page_alloc>
  800985:	83 c4 10             	add    $0x10,%esp
		return r;
  800988:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80098a:	85 c0                	test   %eax,%eax
  80098c:	78 23                	js     8009b1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80098e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800997:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009a3:	83 ec 0c             	sub    $0xc,%esp
  8009a6:	50                   	push   %eax
  8009a7:	e8 6a 12 00 00       	call   801c16 <fd2num>
  8009ac:	89 c2                	mov    %eax,%edx
  8009ae:	83 c4 10             	add    $0x10,%esp
}
  8009b1:	89 d0                	mov    %edx,%eax
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	57                   	push   %edi
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8009be:	c7 05 24 54 80 00 00 	movl   $0x0,0x805424
  8009c5:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8009c8:	e8 be 0b 00 00       	call   80158b <sys_getenvid>
  8009cd:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8009cf:	83 ec 08             	sub    $0x8,%esp
  8009d2:	50                   	push   %eax
  8009d3:	68 58 35 80 00       	push   $0x803558
  8009d8:	e8 71 01 00 00       	call   800b4e <cprintf>
  8009dd:	8b 3d 24 54 80 00    	mov    0x805424,%edi
  8009e3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8009e8:	83 c4 10             	add    $0x10,%esp
  8009eb:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8009f5:	89 c1                	mov    %eax,%ecx
  8009f7:	c1 e1 07             	shl    $0x7,%ecx
  8009fa:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800a01:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800a04:	39 cb                	cmp    %ecx,%ebx
  800a06:	0f 44 fa             	cmove  %edx,%edi
  800a09:	b9 01 00 00 00       	mov    $0x1,%ecx
  800a0e:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800a11:	83 c0 01             	add    $0x1,%eax
  800a14:	81 c2 84 00 00 00    	add    $0x84,%edx
  800a1a:	3d 00 04 00 00       	cmp    $0x400,%eax
  800a1f:	75 d4                	jne    8009f5 <libmain+0x40>
  800a21:	89 f0                	mov    %esi,%eax
  800a23:	84 c0                	test   %al,%al
  800a25:	74 06                	je     800a2d <libmain+0x78>
  800a27:	89 3d 24 54 80 00    	mov    %edi,0x805424
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800a2d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800a31:	7e 0a                	jle    800a3d <libmain+0x88>
		binaryname = argv[0];
  800a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a36:	8b 00                	mov    (%eax),%eax
  800a38:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800a3d:	83 ec 08             	sub    $0x8,%esp
  800a40:	ff 75 0c             	pushl  0xc(%ebp)
  800a43:	ff 75 08             	pushl  0x8(%ebp)
  800a46:	e8 0c fc ff ff       	call   800657 <umain>

	// exit gracefully
	exit();
  800a4b:	e8 0b 00 00 00       	call   800a5b <exit>
}
  800a50:	83 c4 10             	add    $0x10,%esp
  800a53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a61:	e8 7b 13 00 00       	call   801de1 <close_all>
	sys_env_destroy(0);
  800a66:	83 ec 0c             	sub    $0xc,%esp
  800a69:	6a 00                	push   $0x0
  800a6b:	e8 da 0a 00 00       	call   80154a <sys_env_destroy>
}
  800a70:	83 c4 10             	add    $0x10,%esp
  800a73:	c9                   	leave  
  800a74:	c3                   	ret    

00800a75 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a7a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a7d:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a83:	e8 03 0b 00 00       	call   80158b <sys_getenvid>
  800a88:	83 ec 0c             	sub    $0xc,%esp
  800a8b:	ff 75 0c             	pushl  0xc(%ebp)
  800a8e:	ff 75 08             	pushl  0x8(%ebp)
  800a91:	56                   	push   %esi
  800a92:	50                   	push   %eax
  800a93:	68 84 35 80 00       	push   $0x803584
  800a98:	e8 b1 00 00 00       	call   800b4e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a9d:	83 c4 18             	add    $0x18,%esp
  800aa0:	53                   	push   %ebx
  800aa1:	ff 75 10             	pushl  0x10(%ebp)
  800aa4:	e8 54 00 00 00       	call   800afd <vcprintf>
	cprintf("\n");
  800aa9:	c7 04 24 60 33 80 00 	movl   $0x803360,(%esp)
  800ab0:	e8 99 00 00 00       	call   800b4e <cprintf>
  800ab5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ab8:	cc                   	int3   
  800ab9:	eb fd                	jmp    800ab8 <_panic+0x43>

00800abb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	53                   	push   %ebx
  800abf:	83 ec 04             	sub    $0x4,%esp
  800ac2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800ac5:	8b 13                	mov    (%ebx),%edx
  800ac7:	8d 42 01             	lea    0x1(%edx),%eax
  800aca:	89 03                	mov    %eax,(%ebx)
  800acc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800ad3:	3d ff 00 00 00       	cmp    $0xff,%eax
  800ad8:	75 1a                	jne    800af4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800ada:	83 ec 08             	sub    $0x8,%esp
  800add:	68 ff 00 00 00       	push   $0xff
  800ae2:	8d 43 08             	lea    0x8(%ebx),%eax
  800ae5:	50                   	push   %eax
  800ae6:	e8 22 0a 00 00       	call   80150d <sys_cputs>
		b->idx = 0;
  800aeb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800af1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800af4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800af8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800afb:	c9                   	leave  
  800afc:	c3                   	ret    

00800afd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800b06:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800b0d:	00 00 00 
	b.cnt = 0;
  800b10:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800b17:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800b1a:	ff 75 0c             	pushl  0xc(%ebp)
  800b1d:	ff 75 08             	pushl  0x8(%ebp)
  800b20:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b26:	50                   	push   %eax
  800b27:	68 bb 0a 80 00       	push   $0x800abb
  800b2c:	e8 54 01 00 00       	call   800c85 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b31:	83 c4 08             	add    $0x8,%esp
  800b34:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800b3a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b40:	50                   	push   %eax
  800b41:	e8 c7 09 00 00       	call   80150d <sys_cputs>

	return b.cnt;
}
  800b46:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b4c:	c9                   	leave  
  800b4d:	c3                   	ret    

00800b4e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b54:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b57:	50                   	push   %eax
  800b58:	ff 75 08             	pushl  0x8(%ebp)
  800b5b:	e8 9d ff ff ff       	call   800afd <vcprintf>
	va_end(ap);

	return cnt;
}
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    

00800b62 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	83 ec 1c             	sub    $0x1c,%esp
  800b6b:	89 c7                	mov    %eax,%edi
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b75:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b78:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b83:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b86:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b89:	39 d3                	cmp    %edx,%ebx
  800b8b:	72 05                	jb     800b92 <printnum+0x30>
  800b8d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b90:	77 45                	ja     800bd7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b92:	83 ec 0c             	sub    $0xc,%esp
  800b95:	ff 75 18             	pushl  0x18(%ebp)
  800b98:	8b 45 14             	mov    0x14(%ebp),%eax
  800b9b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b9e:	53                   	push   %ebx
  800b9f:	ff 75 10             	pushl  0x10(%ebp)
  800ba2:	83 ec 08             	sub    $0x8,%esp
  800ba5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ba8:	ff 75 e0             	pushl  -0x20(%ebp)
  800bab:	ff 75 dc             	pushl  -0x24(%ebp)
  800bae:	ff 75 d8             	pushl  -0x28(%ebp)
  800bb1:	e8 fa 24 00 00       	call   8030b0 <__udivdi3>
  800bb6:	83 c4 18             	add    $0x18,%esp
  800bb9:	52                   	push   %edx
  800bba:	50                   	push   %eax
  800bbb:	89 f2                	mov    %esi,%edx
  800bbd:	89 f8                	mov    %edi,%eax
  800bbf:	e8 9e ff ff ff       	call   800b62 <printnum>
  800bc4:	83 c4 20             	add    $0x20,%esp
  800bc7:	eb 18                	jmp    800be1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800bc9:	83 ec 08             	sub    $0x8,%esp
  800bcc:	56                   	push   %esi
  800bcd:	ff 75 18             	pushl  0x18(%ebp)
  800bd0:	ff d7                	call   *%edi
  800bd2:	83 c4 10             	add    $0x10,%esp
  800bd5:	eb 03                	jmp    800bda <printnum+0x78>
  800bd7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800bda:	83 eb 01             	sub    $0x1,%ebx
  800bdd:	85 db                	test   %ebx,%ebx
  800bdf:	7f e8                	jg     800bc9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800be1:	83 ec 08             	sub    $0x8,%esp
  800be4:	56                   	push   %esi
  800be5:	83 ec 04             	sub    $0x4,%esp
  800be8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800beb:	ff 75 e0             	pushl  -0x20(%ebp)
  800bee:	ff 75 dc             	pushl  -0x24(%ebp)
  800bf1:	ff 75 d8             	pushl  -0x28(%ebp)
  800bf4:	e8 e7 25 00 00       	call   8031e0 <__umoddi3>
  800bf9:	83 c4 14             	add    $0x14,%esp
  800bfc:	0f be 80 a7 35 80 00 	movsbl 0x8035a7(%eax),%eax
  800c03:	50                   	push   %eax
  800c04:	ff d7                	call   *%edi
}
  800c06:	83 c4 10             	add    $0x10,%esp
  800c09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800c14:	83 fa 01             	cmp    $0x1,%edx
  800c17:	7e 0e                	jle    800c27 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800c19:	8b 10                	mov    (%eax),%edx
  800c1b:	8d 4a 08             	lea    0x8(%edx),%ecx
  800c1e:	89 08                	mov    %ecx,(%eax)
  800c20:	8b 02                	mov    (%edx),%eax
  800c22:	8b 52 04             	mov    0x4(%edx),%edx
  800c25:	eb 22                	jmp    800c49 <getuint+0x38>
	else if (lflag)
  800c27:	85 d2                	test   %edx,%edx
  800c29:	74 10                	je     800c3b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800c2b:	8b 10                	mov    (%eax),%edx
  800c2d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c30:	89 08                	mov    %ecx,(%eax)
  800c32:	8b 02                	mov    (%edx),%eax
  800c34:	ba 00 00 00 00       	mov    $0x0,%edx
  800c39:	eb 0e                	jmp    800c49 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800c3b:	8b 10                	mov    (%eax),%edx
  800c3d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c40:	89 08                	mov    %ecx,(%eax)
  800c42:	8b 02                	mov    (%edx),%eax
  800c44:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c51:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800c55:	8b 10                	mov    (%eax),%edx
  800c57:	3b 50 04             	cmp    0x4(%eax),%edx
  800c5a:	73 0a                	jae    800c66 <sprintputch+0x1b>
		*b->buf++ = ch;
  800c5c:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c5f:	89 08                	mov    %ecx,(%eax)
  800c61:	8b 45 08             	mov    0x8(%ebp),%eax
  800c64:	88 02                	mov    %al,(%edx)
}
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c6e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c71:	50                   	push   %eax
  800c72:	ff 75 10             	pushl  0x10(%ebp)
  800c75:	ff 75 0c             	pushl  0xc(%ebp)
  800c78:	ff 75 08             	pushl  0x8(%ebp)
  800c7b:	e8 05 00 00 00       	call   800c85 <vprintfmt>
	va_end(ap);
}
  800c80:	83 c4 10             	add    $0x10,%esp
  800c83:	c9                   	leave  
  800c84:	c3                   	ret    

00800c85 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 2c             	sub    $0x2c,%esp
  800c8e:	8b 75 08             	mov    0x8(%ebp),%esi
  800c91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c94:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c97:	eb 12                	jmp    800cab <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	0f 84 89 03 00 00    	je     80102a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800ca1:	83 ec 08             	sub    $0x8,%esp
  800ca4:	53                   	push   %ebx
  800ca5:	50                   	push   %eax
  800ca6:	ff d6                	call   *%esi
  800ca8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800cab:	83 c7 01             	add    $0x1,%edi
  800cae:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800cb2:	83 f8 25             	cmp    $0x25,%eax
  800cb5:	75 e2                	jne    800c99 <vprintfmt+0x14>
  800cb7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800cbb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800cc2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800cc9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800cd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd5:	eb 07                	jmp    800cde <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800cda:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cde:	8d 47 01             	lea    0x1(%edi),%eax
  800ce1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ce4:	0f b6 07             	movzbl (%edi),%eax
  800ce7:	0f b6 c8             	movzbl %al,%ecx
  800cea:	83 e8 23             	sub    $0x23,%eax
  800ced:	3c 55                	cmp    $0x55,%al
  800cef:	0f 87 1a 03 00 00    	ja     80100f <vprintfmt+0x38a>
  800cf5:	0f b6 c0             	movzbl %al,%eax
  800cf8:	ff 24 85 e0 36 80 00 	jmp    *0x8036e0(,%eax,4)
  800cff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800d02:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800d06:	eb d6                	jmp    800cde <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d10:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800d13:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800d16:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800d1a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800d1d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800d20:	83 fa 09             	cmp    $0x9,%edx
  800d23:	77 39                	ja     800d5e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d25:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800d28:	eb e9                	jmp    800d13 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800d2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2d:	8d 48 04             	lea    0x4(%eax),%ecx
  800d30:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800d33:	8b 00                	mov    (%eax),%eax
  800d35:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800d3b:	eb 27                	jmp    800d64 <vprintfmt+0xdf>
  800d3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d40:	85 c0                	test   %eax,%eax
  800d42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d47:	0f 49 c8             	cmovns %eax,%ecx
  800d4a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d50:	eb 8c                	jmp    800cde <vprintfmt+0x59>
  800d52:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d55:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800d5c:	eb 80                	jmp    800cde <vprintfmt+0x59>
  800d5e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d61:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800d64:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d68:	0f 89 70 ff ff ff    	jns    800cde <vprintfmt+0x59>
				width = precision, precision = -1;
  800d6e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d71:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d74:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d7b:	e9 5e ff ff ff       	jmp    800cde <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d80:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d86:	e9 53 ff ff ff       	jmp    800cde <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d8b:	8b 45 14             	mov    0x14(%ebp),%eax
  800d8e:	8d 50 04             	lea    0x4(%eax),%edx
  800d91:	89 55 14             	mov    %edx,0x14(%ebp)
  800d94:	83 ec 08             	sub    $0x8,%esp
  800d97:	53                   	push   %ebx
  800d98:	ff 30                	pushl  (%eax)
  800d9a:	ff d6                	call   *%esi
			break;
  800d9c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800da2:	e9 04 ff ff ff       	jmp    800cab <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800da7:	8b 45 14             	mov    0x14(%ebp),%eax
  800daa:	8d 50 04             	lea    0x4(%eax),%edx
  800dad:	89 55 14             	mov    %edx,0x14(%ebp)
  800db0:	8b 00                	mov    (%eax),%eax
  800db2:	99                   	cltd   
  800db3:	31 d0                	xor    %edx,%eax
  800db5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800db7:	83 f8 0f             	cmp    $0xf,%eax
  800dba:	7f 0b                	jg     800dc7 <vprintfmt+0x142>
  800dbc:	8b 14 85 40 38 80 00 	mov    0x803840(,%eax,4),%edx
  800dc3:	85 d2                	test   %edx,%edx
  800dc5:	75 18                	jne    800ddf <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800dc7:	50                   	push   %eax
  800dc8:	68 bf 35 80 00       	push   $0x8035bf
  800dcd:	53                   	push   %ebx
  800dce:	56                   	push   %esi
  800dcf:	e8 94 fe ff ff       	call   800c68 <printfmt>
  800dd4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800dda:	e9 cc fe ff ff       	jmp    800cab <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800ddf:	52                   	push   %edx
  800de0:	68 a1 34 80 00       	push   $0x8034a1
  800de5:	53                   	push   %ebx
  800de6:	56                   	push   %esi
  800de7:	e8 7c fe ff ff       	call   800c68 <printfmt>
  800dec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800def:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800df2:	e9 b4 fe ff ff       	jmp    800cab <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800df7:	8b 45 14             	mov    0x14(%ebp),%eax
  800dfa:	8d 50 04             	lea    0x4(%eax),%edx
  800dfd:	89 55 14             	mov    %edx,0x14(%ebp)
  800e00:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800e02:	85 ff                	test   %edi,%edi
  800e04:	b8 b8 35 80 00       	mov    $0x8035b8,%eax
  800e09:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800e0c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800e10:	0f 8e 94 00 00 00    	jle    800eaa <vprintfmt+0x225>
  800e16:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800e1a:	0f 84 98 00 00 00    	je     800eb8 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e20:	83 ec 08             	sub    $0x8,%esp
  800e23:	ff 75 d0             	pushl  -0x30(%ebp)
  800e26:	57                   	push   %edi
  800e27:	e8 79 03 00 00       	call   8011a5 <strnlen>
  800e2c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e2f:	29 c1                	sub    %eax,%ecx
  800e31:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800e34:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800e37:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800e3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e3e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e41:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e43:	eb 0f                	jmp    800e54 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800e45:	83 ec 08             	sub    $0x8,%esp
  800e48:	53                   	push   %ebx
  800e49:	ff 75 e0             	pushl  -0x20(%ebp)
  800e4c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e4e:	83 ef 01             	sub    $0x1,%edi
  800e51:	83 c4 10             	add    $0x10,%esp
  800e54:	85 ff                	test   %edi,%edi
  800e56:	7f ed                	jg     800e45 <vprintfmt+0x1c0>
  800e58:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800e5b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800e5e:	85 c9                	test   %ecx,%ecx
  800e60:	b8 00 00 00 00       	mov    $0x0,%eax
  800e65:	0f 49 c1             	cmovns %ecx,%eax
  800e68:	29 c1                	sub    %eax,%ecx
  800e6a:	89 75 08             	mov    %esi,0x8(%ebp)
  800e6d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e70:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e73:	89 cb                	mov    %ecx,%ebx
  800e75:	eb 4d                	jmp    800ec4 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e77:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e7b:	74 1b                	je     800e98 <vprintfmt+0x213>
  800e7d:	0f be c0             	movsbl %al,%eax
  800e80:	83 e8 20             	sub    $0x20,%eax
  800e83:	83 f8 5e             	cmp    $0x5e,%eax
  800e86:	76 10                	jbe    800e98 <vprintfmt+0x213>
					putch('?', putdat);
  800e88:	83 ec 08             	sub    $0x8,%esp
  800e8b:	ff 75 0c             	pushl  0xc(%ebp)
  800e8e:	6a 3f                	push   $0x3f
  800e90:	ff 55 08             	call   *0x8(%ebp)
  800e93:	83 c4 10             	add    $0x10,%esp
  800e96:	eb 0d                	jmp    800ea5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800e98:	83 ec 08             	sub    $0x8,%esp
  800e9b:	ff 75 0c             	pushl  0xc(%ebp)
  800e9e:	52                   	push   %edx
  800e9f:	ff 55 08             	call   *0x8(%ebp)
  800ea2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ea5:	83 eb 01             	sub    $0x1,%ebx
  800ea8:	eb 1a                	jmp    800ec4 <vprintfmt+0x23f>
  800eaa:	89 75 08             	mov    %esi,0x8(%ebp)
  800ead:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800eb0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800eb3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800eb6:	eb 0c                	jmp    800ec4 <vprintfmt+0x23f>
  800eb8:	89 75 08             	mov    %esi,0x8(%ebp)
  800ebb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ebe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ec1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ec4:	83 c7 01             	add    $0x1,%edi
  800ec7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ecb:	0f be d0             	movsbl %al,%edx
  800ece:	85 d2                	test   %edx,%edx
  800ed0:	74 23                	je     800ef5 <vprintfmt+0x270>
  800ed2:	85 f6                	test   %esi,%esi
  800ed4:	78 a1                	js     800e77 <vprintfmt+0x1f2>
  800ed6:	83 ee 01             	sub    $0x1,%esi
  800ed9:	79 9c                	jns    800e77 <vprintfmt+0x1f2>
  800edb:	89 df                	mov    %ebx,%edi
  800edd:	8b 75 08             	mov    0x8(%ebp),%esi
  800ee0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ee3:	eb 18                	jmp    800efd <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ee5:	83 ec 08             	sub    $0x8,%esp
  800ee8:	53                   	push   %ebx
  800ee9:	6a 20                	push   $0x20
  800eeb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800eed:	83 ef 01             	sub    $0x1,%edi
  800ef0:	83 c4 10             	add    $0x10,%esp
  800ef3:	eb 08                	jmp    800efd <vprintfmt+0x278>
  800ef5:	89 df                	mov    %ebx,%edi
  800ef7:	8b 75 08             	mov    0x8(%ebp),%esi
  800efa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800efd:	85 ff                	test   %edi,%edi
  800eff:	7f e4                	jg     800ee5 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f04:	e9 a2 fd ff ff       	jmp    800cab <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800f09:	83 fa 01             	cmp    $0x1,%edx
  800f0c:	7e 16                	jle    800f24 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800f0e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f11:	8d 50 08             	lea    0x8(%eax),%edx
  800f14:	89 55 14             	mov    %edx,0x14(%ebp)
  800f17:	8b 50 04             	mov    0x4(%eax),%edx
  800f1a:	8b 00                	mov    (%eax),%eax
  800f1c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f1f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800f22:	eb 32                	jmp    800f56 <vprintfmt+0x2d1>
	else if (lflag)
  800f24:	85 d2                	test   %edx,%edx
  800f26:	74 18                	je     800f40 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800f28:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2b:	8d 50 04             	lea    0x4(%eax),%edx
  800f2e:	89 55 14             	mov    %edx,0x14(%ebp)
  800f31:	8b 00                	mov    (%eax),%eax
  800f33:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f36:	89 c1                	mov    %eax,%ecx
  800f38:	c1 f9 1f             	sar    $0x1f,%ecx
  800f3b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800f3e:	eb 16                	jmp    800f56 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800f40:	8b 45 14             	mov    0x14(%ebp),%eax
  800f43:	8d 50 04             	lea    0x4(%eax),%edx
  800f46:	89 55 14             	mov    %edx,0x14(%ebp)
  800f49:	8b 00                	mov    (%eax),%eax
  800f4b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f4e:	89 c1                	mov    %eax,%ecx
  800f50:	c1 f9 1f             	sar    $0x1f,%ecx
  800f53:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800f56:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f59:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f5c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f61:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f65:	79 74                	jns    800fdb <vprintfmt+0x356>
				putch('-', putdat);
  800f67:	83 ec 08             	sub    $0x8,%esp
  800f6a:	53                   	push   %ebx
  800f6b:	6a 2d                	push   $0x2d
  800f6d:	ff d6                	call   *%esi
				num = -(long long) num;
  800f6f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f72:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f75:	f7 d8                	neg    %eax
  800f77:	83 d2 00             	adc    $0x0,%edx
  800f7a:	f7 da                	neg    %edx
  800f7c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f7f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f84:	eb 55                	jmp    800fdb <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f86:	8d 45 14             	lea    0x14(%ebp),%eax
  800f89:	e8 83 fc ff ff       	call   800c11 <getuint>
			base = 10;
  800f8e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f93:	eb 46                	jmp    800fdb <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800f95:	8d 45 14             	lea    0x14(%ebp),%eax
  800f98:	e8 74 fc ff ff       	call   800c11 <getuint>
			base = 8;
  800f9d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800fa2:	eb 37                	jmp    800fdb <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800fa4:	83 ec 08             	sub    $0x8,%esp
  800fa7:	53                   	push   %ebx
  800fa8:	6a 30                	push   $0x30
  800faa:	ff d6                	call   *%esi
			putch('x', putdat);
  800fac:	83 c4 08             	add    $0x8,%esp
  800faf:	53                   	push   %ebx
  800fb0:	6a 78                	push   $0x78
  800fb2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800fb4:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb7:	8d 50 04             	lea    0x4(%eax),%edx
  800fba:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800fbd:	8b 00                	mov    (%eax),%eax
  800fbf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800fc4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800fc7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800fcc:	eb 0d                	jmp    800fdb <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800fce:	8d 45 14             	lea    0x14(%ebp),%eax
  800fd1:	e8 3b fc ff ff       	call   800c11 <getuint>
			base = 16;
  800fd6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800fdb:	83 ec 0c             	sub    $0xc,%esp
  800fde:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800fe2:	57                   	push   %edi
  800fe3:	ff 75 e0             	pushl  -0x20(%ebp)
  800fe6:	51                   	push   %ecx
  800fe7:	52                   	push   %edx
  800fe8:	50                   	push   %eax
  800fe9:	89 da                	mov    %ebx,%edx
  800feb:	89 f0                	mov    %esi,%eax
  800fed:	e8 70 fb ff ff       	call   800b62 <printnum>
			break;
  800ff2:	83 c4 20             	add    $0x20,%esp
  800ff5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ff8:	e9 ae fc ff ff       	jmp    800cab <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ffd:	83 ec 08             	sub    $0x8,%esp
  801000:	53                   	push   %ebx
  801001:	51                   	push   %ecx
  801002:	ff d6                	call   *%esi
			break;
  801004:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801007:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80100a:	e9 9c fc ff ff       	jmp    800cab <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80100f:	83 ec 08             	sub    $0x8,%esp
  801012:	53                   	push   %ebx
  801013:	6a 25                	push   $0x25
  801015:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801017:	83 c4 10             	add    $0x10,%esp
  80101a:	eb 03                	jmp    80101f <vprintfmt+0x39a>
  80101c:	83 ef 01             	sub    $0x1,%edi
  80101f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801023:	75 f7                	jne    80101c <vprintfmt+0x397>
  801025:	e9 81 fc ff ff       	jmp    800cab <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80102a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102d:	5b                   	pop    %ebx
  80102e:	5e                   	pop    %esi
  80102f:	5f                   	pop    %edi
  801030:	5d                   	pop    %ebp
  801031:	c3                   	ret    

00801032 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	83 ec 18             	sub    $0x18,%esp
  801038:	8b 45 08             	mov    0x8(%ebp),%eax
  80103b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80103e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801041:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801045:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801048:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80104f:	85 c0                	test   %eax,%eax
  801051:	74 26                	je     801079 <vsnprintf+0x47>
  801053:	85 d2                	test   %edx,%edx
  801055:	7e 22                	jle    801079 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801057:	ff 75 14             	pushl  0x14(%ebp)
  80105a:	ff 75 10             	pushl  0x10(%ebp)
  80105d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801060:	50                   	push   %eax
  801061:	68 4b 0c 80 00       	push   $0x800c4b
  801066:	e8 1a fc ff ff       	call   800c85 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80106b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80106e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801071:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	eb 05                	jmp    80107e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801079:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    

00801080 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801086:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801089:	50                   	push   %eax
  80108a:	ff 75 10             	pushl  0x10(%ebp)
  80108d:	ff 75 0c             	pushl  0xc(%ebp)
  801090:	ff 75 08             	pushl  0x8(%ebp)
  801093:	e8 9a ff ff ff       	call   801032 <vsnprintf>
	va_end(ap);

	return rc;
}
  801098:	c9                   	leave  
  801099:	c3                   	ret    

0080109a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	57                   	push   %edi
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	74 13                	je     8010bd <readline+0x23>
		fprintf(1, "%s", prompt);
  8010aa:	83 ec 04             	sub    $0x4,%esp
  8010ad:	50                   	push   %eax
  8010ae:	68 a1 34 80 00       	push   $0x8034a1
  8010b3:	6a 01                	push   $0x1
  8010b5:	e8 4a 14 00 00       	call   802504 <fprintf>
  8010ba:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	6a 00                	push   $0x0
  8010c2:	e8 68 f8 ff ff       	call   80092f <iscons>
  8010c7:	89 c7                	mov    %eax,%edi
  8010c9:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8010cc:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8010d1:	e8 2e f8 ff ff       	call   800904 <getchar>
  8010d6:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	79 29                	jns    801105 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8010dc:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  8010e1:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8010e4:	0f 84 9b 00 00 00    	je     801185 <readline+0xeb>
				cprintf("read error: %e\n", c);
  8010ea:	83 ec 08             	sub    $0x8,%esp
  8010ed:	53                   	push   %ebx
  8010ee:	68 9f 38 80 00       	push   $0x80389f
  8010f3:	e8 56 fa ff ff       	call   800b4e <cprintf>
  8010f8:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8010fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801100:	e9 80 00 00 00       	jmp    801185 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801105:	83 f8 08             	cmp    $0x8,%eax
  801108:	0f 94 c2             	sete   %dl
  80110b:	83 f8 7f             	cmp    $0x7f,%eax
  80110e:	0f 94 c0             	sete   %al
  801111:	08 c2                	or     %al,%dl
  801113:	74 1a                	je     80112f <readline+0x95>
  801115:	85 f6                	test   %esi,%esi
  801117:	7e 16                	jle    80112f <readline+0x95>
			if (echoing)
  801119:	85 ff                	test   %edi,%edi
  80111b:	74 0d                	je     80112a <readline+0x90>
				cputchar('\b');
  80111d:	83 ec 0c             	sub    $0xc,%esp
  801120:	6a 08                	push   $0x8
  801122:	e8 c1 f7 ff ff       	call   8008e8 <cputchar>
  801127:	83 c4 10             	add    $0x10,%esp
			i--;
  80112a:	83 ee 01             	sub    $0x1,%esi
  80112d:	eb a2                	jmp    8010d1 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  80112f:	83 fb 1f             	cmp    $0x1f,%ebx
  801132:	7e 26                	jle    80115a <readline+0xc0>
  801134:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  80113a:	7f 1e                	jg     80115a <readline+0xc0>
			if (echoing)
  80113c:	85 ff                	test   %edi,%edi
  80113e:	74 0c                	je     80114c <readline+0xb2>
				cputchar(c);
  801140:	83 ec 0c             	sub    $0xc,%esp
  801143:	53                   	push   %ebx
  801144:	e8 9f f7 ff ff       	call   8008e8 <cputchar>
  801149:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  80114c:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801152:	8d 76 01             	lea    0x1(%esi),%esi
  801155:	e9 77 ff ff ff       	jmp    8010d1 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  80115a:	83 fb 0a             	cmp    $0xa,%ebx
  80115d:	74 09                	je     801168 <readline+0xce>
  80115f:	83 fb 0d             	cmp    $0xd,%ebx
  801162:	0f 85 69 ff ff ff    	jne    8010d1 <readline+0x37>
			if (echoing)
  801168:	85 ff                	test   %edi,%edi
  80116a:	74 0d                	je     801179 <readline+0xdf>
				cputchar('\n');
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	6a 0a                	push   $0xa
  801171:	e8 72 f7 ff ff       	call   8008e8 <cputchar>
  801176:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801179:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  801180:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  801185:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801188:	5b                   	pop    %ebx
  801189:	5e                   	pop    %esi
  80118a:	5f                   	pop    %edi
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801193:	b8 00 00 00 00       	mov    $0x0,%eax
  801198:	eb 03                	jmp    80119d <strlen+0x10>
		n++;
  80119a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80119d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011a1:	75 f7                	jne    80119a <strlen+0xd>
		n++;
	return n;
}
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ab:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b3:	eb 03                	jmp    8011b8 <strnlen+0x13>
		n++;
  8011b5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011b8:	39 c2                	cmp    %eax,%edx
  8011ba:	74 08                	je     8011c4 <strnlen+0x1f>
  8011bc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8011c0:	75 f3                	jne    8011b5 <strnlen+0x10>
  8011c2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	53                   	push   %ebx
  8011ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011d0:	89 c2                	mov    %eax,%edx
  8011d2:	83 c2 01             	add    $0x1,%edx
  8011d5:	83 c1 01             	add    $0x1,%ecx
  8011d8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8011dc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8011df:	84 db                	test   %bl,%bl
  8011e1:	75 ef                	jne    8011d2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8011e3:	5b                   	pop    %ebx
  8011e4:	5d                   	pop    %ebp
  8011e5:	c3                   	ret    

008011e6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	53                   	push   %ebx
  8011ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011ed:	53                   	push   %ebx
  8011ee:	e8 9a ff ff ff       	call   80118d <strlen>
  8011f3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8011f6:	ff 75 0c             	pushl  0xc(%ebp)
  8011f9:	01 d8                	add    %ebx,%eax
  8011fb:	50                   	push   %eax
  8011fc:	e8 c5 ff ff ff       	call   8011c6 <strcpy>
	return dst;
}
  801201:	89 d8                	mov    %ebx,%eax
  801203:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	56                   	push   %esi
  80120c:	53                   	push   %ebx
  80120d:	8b 75 08             	mov    0x8(%ebp),%esi
  801210:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801213:	89 f3                	mov    %esi,%ebx
  801215:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801218:	89 f2                	mov    %esi,%edx
  80121a:	eb 0f                	jmp    80122b <strncpy+0x23>
		*dst++ = *src;
  80121c:	83 c2 01             	add    $0x1,%edx
  80121f:	0f b6 01             	movzbl (%ecx),%eax
  801222:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801225:	80 39 01             	cmpb   $0x1,(%ecx)
  801228:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80122b:	39 da                	cmp    %ebx,%edx
  80122d:	75 ed                	jne    80121c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80122f:	89 f0                	mov    %esi,%eax
  801231:	5b                   	pop    %ebx
  801232:	5e                   	pop    %esi
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    

00801235 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	56                   	push   %esi
  801239:	53                   	push   %ebx
  80123a:	8b 75 08             	mov    0x8(%ebp),%esi
  80123d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801240:	8b 55 10             	mov    0x10(%ebp),%edx
  801243:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801245:	85 d2                	test   %edx,%edx
  801247:	74 21                	je     80126a <strlcpy+0x35>
  801249:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80124d:	89 f2                	mov    %esi,%edx
  80124f:	eb 09                	jmp    80125a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801251:	83 c2 01             	add    $0x1,%edx
  801254:	83 c1 01             	add    $0x1,%ecx
  801257:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80125a:	39 c2                	cmp    %eax,%edx
  80125c:	74 09                	je     801267 <strlcpy+0x32>
  80125e:	0f b6 19             	movzbl (%ecx),%ebx
  801261:	84 db                	test   %bl,%bl
  801263:	75 ec                	jne    801251 <strlcpy+0x1c>
  801265:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801267:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80126a:	29 f0                	sub    %esi,%eax
}
  80126c:	5b                   	pop    %ebx
  80126d:	5e                   	pop    %esi
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    

00801270 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801276:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801279:	eb 06                	jmp    801281 <strcmp+0x11>
		p++, q++;
  80127b:	83 c1 01             	add    $0x1,%ecx
  80127e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801281:	0f b6 01             	movzbl (%ecx),%eax
  801284:	84 c0                	test   %al,%al
  801286:	74 04                	je     80128c <strcmp+0x1c>
  801288:	3a 02                	cmp    (%edx),%al
  80128a:	74 ef                	je     80127b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80128c:	0f b6 c0             	movzbl %al,%eax
  80128f:	0f b6 12             	movzbl (%edx),%edx
  801292:	29 d0                	sub    %edx,%eax
}
  801294:	5d                   	pop    %ebp
  801295:	c3                   	ret    

00801296 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	53                   	push   %ebx
  80129a:	8b 45 08             	mov    0x8(%ebp),%eax
  80129d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a0:	89 c3                	mov    %eax,%ebx
  8012a2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8012a5:	eb 06                	jmp    8012ad <strncmp+0x17>
		n--, p++, q++;
  8012a7:	83 c0 01             	add    $0x1,%eax
  8012aa:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8012ad:	39 d8                	cmp    %ebx,%eax
  8012af:	74 15                	je     8012c6 <strncmp+0x30>
  8012b1:	0f b6 08             	movzbl (%eax),%ecx
  8012b4:	84 c9                	test   %cl,%cl
  8012b6:	74 04                	je     8012bc <strncmp+0x26>
  8012b8:	3a 0a                	cmp    (%edx),%cl
  8012ba:	74 eb                	je     8012a7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8012bc:	0f b6 00             	movzbl (%eax),%eax
  8012bf:	0f b6 12             	movzbl (%edx),%edx
  8012c2:	29 d0                	sub    %edx,%eax
  8012c4:	eb 05                	jmp    8012cb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8012c6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8012cb:	5b                   	pop    %ebx
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012d8:	eb 07                	jmp    8012e1 <strchr+0x13>
		if (*s == c)
  8012da:	38 ca                	cmp    %cl,%dl
  8012dc:	74 0f                	je     8012ed <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012de:	83 c0 01             	add    $0x1,%eax
  8012e1:	0f b6 10             	movzbl (%eax),%edx
  8012e4:	84 d2                	test   %dl,%dl
  8012e6:	75 f2                	jne    8012da <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8012e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ed:	5d                   	pop    %ebp
  8012ee:	c3                   	ret    

008012ef <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012f9:	eb 03                	jmp    8012fe <strfind+0xf>
  8012fb:	83 c0 01             	add    $0x1,%eax
  8012fe:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801301:	38 ca                	cmp    %cl,%dl
  801303:	74 04                	je     801309 <strfind+0x1a>
  801305:	84 d2                	test   %dl,%dl
  801307:	75 f2                	jne    8012fb <strfind+0xc>
			break;
	return (char *) s;
}
  801309:	5d                   	pop    %ebp
  80130a:	c3                   	ret    

0080130b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	57                   	push   %edi
  80130f:	56                   	push   %esi
  801310:	53                   	push   %ebx
  801311:	8b 7d 08             	mov    0x8(%ebp),%edi
  801314:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801317:	85 c9                	test   %ecx,%ecx
  801319:	74 36                	je     801351 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80131b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801321:	75 28                	jne    80134b <memset+0x40>
  801323:	f6 c1 03             	test   $0x3,%cl
  801326:	75 23                	jne    80134b <memset+0x40>
		c &= 0xFF;
  801328:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80132c:	89 d3                	mov    %edx,%ebx
  80132e:	c1 e3 08             	shl    $0x8,%ebx
  801331:	89 d6                	mov    %edx,%esi
  801333:	c1 e6 18             	shl    $0x18,%esi
  801336:	89 d0                	mov    %edx,%eax
  801338:	c1 e0 10             	shl    $0x10,%eax
  80133b:	09 f0                	or     %esi,%eax
  80133d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80133f:	89 d8                	mov    %ebx,%eax
  801341:	09 d0                	or     %edx,%eax
  801343:	c1 e9 02             	shr    $0x2,%ecx
  801346:	fc                   	cld    
  801347:	f3 ab                	rep stos %eax,%es:(%edi)
  801349:	eb 06                	jmp    801351 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80134b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80134e:	fc                   	cld    
  80134f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801351:	89 f8                	mov    %edi,%eax
  801353:	5b                   	pop    %ebx
  801354:	5e                   	pop    %esi
  801355:	5f                   	pop    %edi
  801356:	5d                   	pop    %ebp
  801357:	c3                   	ret    

00801358 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	57                   	push   %edi
  80135c:	56                   	push   %esi
  80135d:	8b 45 08             	mov    0x8(%ebp),%eax
  801360:	8b 75 0c             	mov    0xc(%ebp),%esi
  801363:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801366:	39 c6                	cmp    %eax,%esi
  801368:	73 35                	jae    80139f <memmove+0x47>
  80136a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80136d:	39 d0                	cmp    %edx,%eax
  80136f:	73 2e                	jae    80139f <memmove+0x47>
		s += n;
		d += n;
  801371:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801374:	89 d6                	mov    %edx,%esi
  801376:	09 fe                	or     %edi,%esi
  801378:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80137e:	75 13                	jne    801393 <memmove+0x3b>
  801380:	f6 c1 03             	test   $0x3,%cl
  801383:	75 0e                	jne    801393 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801385:	83 ef 04             	sub    $0x4,%edi
  801388:	8d 72 fc             	lea    -0x4(%edx),%esi
  80138b:	c1 e9 02             	shr    $0x2,%ecx
  80138e:	fd                   	std    
  80138f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801391:	eb 09                	jmp    80139c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801393:	83 ef 01             	sub    $0x1,%edi
  801396:	8d 72 ff             	lea    -0x1(%edx),%esi
  801399:	fd                   	std    
  80139a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80139c:	fc                   	cld    
  80139d:	eb 1d                	jmp    8013bc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80139f:	89 f2                	mov    %esi,%edx
  8013a1:	09 c2                	or     %eax,%edx
  8013a3:	f6 c2 03             	test   $0x3,%dl
  8013a6:	75 0f                	jne    8013b7 <memmove+0x5f>
  8013a8:	f6 c1 03             	test   $0x3,%cl
  8013ab:	75 0a                	jne    8013b7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8013ad:	c1 e9 02             	shr    $0x2,%ecx
  8013b0:	89 c7                	mov    %eax,%edi
  8013b2:	fc                   	cld    
  8013b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013b5:	eb 05                	jmp    8013bc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8013b7:	89 c7                	mov    %eax,%edi
  8013b9:	fc                   	cld    
  8013ba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8013bc:	5e                   	pop    %esi
  8013bd:	5f                   	pop    %edi
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8013c3:	ff 75 10             	pushl  0x10(%ebp)
  8013c6:	ff 75 0c             	pushl  0xc(%ebp)
  8013c9:	ff 75 08             	pushl  0x8(%ebp)
  8013cc:	e8 87 ff ff ff       	call   801358 <memmove>
}
  8013d1:	c9                   	leave  
  8013d2:	c3                   	ret    

008013d3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
  8013d6:	56                   	push   %esi
  8013d7:	53                   	push   %ebx
  8013d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013de:	89 c6                	mov    %eax,%esi
  8013e0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013e3:	eb 1a                	jmp    8013ff <memcmp+0x2c>
		if (*s1 != *s2)
  8013e5:	0f b6 08             	movzbl (%eax),%ecx
  8013e8:	0f b6 1a             	movzbl (%edx),%ebx
  8013eb:	38 d9                	cmp    %bl,%cl
  8013ed:	74 0a                	je     8013f9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8013ef:	0f b6 c1             	movzbl %cl,%eax
  8013f2:	0f b6 db             	movzbl %bl,%ebx
  8013f5:	29 d8                	sub    %ebx,%eax
  8013f7:	eb 0f                	jmp    801408 <memcmp+0x35>
		s1++, s2++;
  8013f9:	83 c0 01             	add    $0x1,%eax
  8013fc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013ff:	39 f0                	cmp    %esi,%eax
  801401:	75 e2                	jne    8013e5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801403:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801408:	5b                   	pop    %ebx
  801409:	5e                   	pop    %esi
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    

0080140c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	53                   	push   %ebx
  801410:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801413:	89 c1                	mov    %eax,%ecx
  801415:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801418:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80141c:	eb 0a                	jmp    801428 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80141e:	0f b6 10             	movzbl (%eax),%edx
  801421:	39 da                	cmp    %ebx,%edx
  801423:	74 07                	je     80142c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801425:	83 c0 01             	add    $0x1,%eax
  801428:	39 c8                	cmp    %ecx,%eax
  80142a:	72 f2                	jb     80141e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80142c:	5b                   	pop    %ebx
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    

0080142f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	57                   	push   %edi
  801433:	56                   	push   %esi
  801434:	53                   	push   %ebx
  801435:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801438:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80143b:	eb 03                	jmp    801440 <strtol+0x11>
		s++;
  80143d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801440:	0f b6 01             	movzbl (%ecx),%eax
  801443:	3c 20                	cmp    $0x20,%al
  801445:	74 f6                	je     80143d <strtol+0xe>
  801447:	3c 09                	cmp    $0x9,%al
  801449:	74 f2                	je     80143d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80144b:	3c 2b                	cmp    $0x2b,%al
  80144d:	75 0a                	jne    801459 <strtol+0x2a>
		s++;
  80144f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801452:	bf 00 00 00 00       	mov    $0x0,%edi
  801457:	eb 11                	jmp    80146a <strtol+0x3b>
  801459:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80145e:	3c 2d                	cmp    $0x2d,%al
  801460:	75 08                	jne    80146a <strtol+0x3b>
		s++, neg = 1;
  801462:	83 c1 01             	add    $0x1,%ecx
  801465:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80146a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801470:	75 15                	jne    801487 <strtol+0x58>
  801472:	80 39 30             	cmpb   $0x30,(%ecx)
  801475:	75 10                	jne    801487 <strtol+0x58>
  801477:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80147b:	75 7c                	jne    8014f9 <strtol+0xca>
		s += 2, base = 16;
  80147d:	83 c1 02             	add    $0x2,%ecx
  801480:	bb 10 00 00 00       	mov    $0x10,%ebx
  801485:	eb 16                	jmp    80149d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801487:	85 db                	test   %ebx,%ebx
  801489:	75 12                	jne    80149d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80148b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801490:	80 39 30             	cmpb   $0x30,(%ecx)
  801493:	75 08                	jne    80149d <strtol+0x6e>
		s++, base = 8;
  801495:	83 c1 01             	add    $0x1,%ecx
  801498:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80149d:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8014a5:	0f b6 11             	movzbl (%ecx),%edx
  8014a8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8014ab:	89 f3                	mov    %esi,%ebx
  8014ad:	80 fb 09             	cmp    $0x9,%bl
  8014b0:	77 08                	ja     8014ba <strtol+0x8b>
			dig = *s - '0';
  8014b2:	0f be d2             	movsbl %dl,%edx
  8014b5:	83 ea 30             	sub    $0x30,%edx
  8014b8:	eb 22                	jmp    8014dc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8014ba:	8d 72 9f             	lea    -0x61(%edx),%esi
  8014bd:	89 f3                	mov    %esi,%ebx
  8014bf:	80 fb 19             	cmp    $0x19,%bl
  8014c2:	77 08                	ja     8014cc <strtol+0x9d>
			dig = *s - 'a' + 10;
  8014c4:	0f be d2             	movsbl %dl,%edx
  8014c7:	83 ea 57             	sub    $0x57,%edx
  8014ca:	eb 10                	jmp    8014dc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8014cc:	8d 72 bf             	lea    -0x41(%edx),%esi
  8014cf:	89 f3                	mov    %esi,%ebx
  8014d1:	80 fb 19             	cmp    $0x19,%bl
  8014d4:	77 16                	ja     8014ec <strtol+0xbd>
			dig = *s - 'A' + 10;
  8014d6:	0f be d2             	movsbl %dl,%edx
  8014d9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8014dc:	3b 55 10             	cmp    0x10(%ebp),%edx
  8014df:	7d 0b                	jge    8014ec <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8014e1:	83 c1 01             	add    $0x1,%ecx
  8014e4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8014e8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8014ea:	eb b9                	jmp    8014a5 <strtol+0x76>

	if (endptr)
  8014ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014f0:	74 0d                	je     8014ff <strtol+0xd0>
		*endptr = (char *) s;
  8014f2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014f5:	89 0e                	mov    %ecx,(%esi)
  8014f7:	eb 06                	jmp    8014ff <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014f9:	85 db                	test   %ebx,%ebx
  8014fb:	74 98                	je     801495 <strtol+0x66>
  8014fd:	eb 9e                	jmp    80149d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8014ff:	89 c2                	mov    %eax,%edx
  801501:	f7 da                	neg    %edx
  801503:	85 ff                	test   %edi,%edi
  801505:	0f 45 c2             	cmovne %edx,%eax
}
  801508:	5b                   	pop    %ebx
  801509:	5e                   	pop    %esi
  80150a:	5f                   	pop    %edi
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    

0080150d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	57                   	push   %edi
  801511:	56                   	push   %esi
  801512:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801513:	b8 00 00 00 00       	mov    $0x0,%eax
  801518:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80151b:	8b 55 08             	mov    0x8(%ebp),%edx
  80151e:	89 c3                	mov    %eax,%ebx
  801520:	89 c7                	mov    %eax,%edi
  801522:	89 c6                	mov    %eax,%esi
  801524:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5f                   	pop    %edi
  801529:	5d                   	pop    %ebp
  80152a:	c3                   	ret    

0080152b <sys_cgetc>:

int
sys_cgetc(void)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	57                   	push   %edi
  80152f:	56                   	push   %esi
  801530:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801531:	ba 00 00 00 00       	mov    $0x0,%edx
  801536:	b8 01 00 00 00       	mov    $0x1,%eax
  80153b:	89 d1                	mov    %edx,%ecx
  80153d:	89 d3                	mov    %edx,%ebx
  80153f:	89 d7                	mov    %edx,%edi
  801541:	89 d6                	mov    %edx,%esi
  801543:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801545:	5b                   	pop    %ebx
  801546:	5e                   	pop    %esi
  801547:	5f                   	pop    %edi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	57                   	push   %edi
  80154e:	56                   	push   %esi
  80154f:	53                   	push   %ebx
  801550:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801553:	b9 00 00 00 00       	mov    $0x0,%ecx
  801558:	b8 03 00 00 00       	mov    $0x3,%eax
  80155d:	8b 55 08             	mov    0x8(%ebp),%edx
  801560:	89 cb                	mov    %ecx,%ebx
  801562:	89 cf                	mov    %ecx,%edi
  801564:	89 ce                	mov    %ecx,%esi
  801566:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801568:	85 c0                	test   %eax,%eax
  80156a:	7e 17                	jle    801583 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80156c:	83 ec 0c             	sub    $0xc,%esp
  80156f:	50                   	push   %eax
  801570:	6a 03                	push   $0x3
  801572:	68 af 38 80 00       	push   $0x8038af
  801577:	6a 23                	push   $0x23
  801579:	68 cc 38 80 00       	push   $0x8038cc
  80157e:	e8 f2 f4 ff ff       	call   800a75 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801583:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801586:	5b                   	pop    %ebx
  801587:	5e                   	pop    %esi
  801588:	5f                   	pop    %edi
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    

0080158b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	57                   	push   %edi
  80158f:	56                   	push   %esi
  801590:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801591:	ba 00 00 00 00       	mov    $0x0,%edx
  801596:	b8 02 00 00 00       	mov    $0x2,%eax
  80159b:	89 d1                	mov    %edx,%ecx
  80159d:	89 d3                	mov    %edx,%ebx
  80159f:	89 d7                	mov    %edx,%edi
  8015a1:	89 d6                	mov    %edx,%esi
  8015a3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8015a5:	5b                   	pop    %ebx
  8015a6:	5e                   	pop    %esi
  8015a7:	5f                   	pop    %edi
  8015a8:	5d                   	pop    %ebp
  8015a9:	c3                   	ret    

008015aa <sys_yield>:

void
sys_yield(void)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	57                   	push   %edi
  8015ae:	56                   	push   %esi
  8015af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8015ba:	89 d1                	mov    %edx,%ecx
  8015bc:	89 d3                	mov    %edx,%ebx
  8015be:	89 d7                	mov    %edx,%edi
  8015c0:	89 d6                	mov    %edx,%esi
  8015c2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8015c4:	5b                   	pop    %ebx
  8015c5:	5e                   	pop    %esi
  8015c6:	5f                   	pop    %edi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    

008015c9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	57                   	push   %edi
  8015cd:	56                   	push   %esi
  8015ce:	53                   	push   %ebx
  8015cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015d2:	be 00 00 00 00       	mov    $0x0,%esi
  8015d7:	b8 04 00 00 00       	mov    $0x4,%eax
  8015dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015df:	8b 55 08             	mov    0x8(%ebp),%edx
  8015e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015e5:	89 f7                	mov    %esi,%edi
  8015e7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	7e 17                	jle    801604 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	50                   	push   %eax
  8015f1:	6a 04                	push   $0x4
  8015f3:	68 af 38 80 00       	push   $0x8038af
  8015f8:	6a 23                	push   $0x23
  8015fa:	68 cc 38 80 00       	push   $0x8038cc
  8015ff:	e8 71 f4 ff ff       	call   800a75 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801604:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801607:	5b                   	pop    %ebx
  801608:	5e                   	pop    %esi
  801609:	5f                   	pop    %edi
  80160a:	5d                   	pop    %ebp
  80160b:	c3                   	ret    

0080160c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	57                   	push   %edi
  801610:	56                   	push   %esi
  801611:	53                   	push   %ebx
  801612:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801615:	b8 05 00 00 00       	mov    $0x5,%eax
  80161a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80161d:	8b 55 08             	mov    0x8(%ebp),%edx
  801620:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801623:	8b 7d 14             	mov    0x14(%ebp),%edi
  801626:	8b 75 18             	mov    0x18(%ebp),%esi
  801629:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80162b:	85 c0                	test   %eax,%eax
  80162d:	7e 17                	jle    801646 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80162f:	83 ec 0c             	sub    $0xc,%esp
  801632:	50                   	push   %eax
  801633:	6a 05                	push   $0x5
  801635:	68 af 38 80 00       	push   $0x8038af
  80163a:	6a 23                	push   $0x23
  80163c:	68 cc 38 80 00       	push   $0x8038cc
  801641:	e8 2f f4 ff ff       	call   800a75 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801649:	5b                   	pop    %ebx
  80164a:	5e                   	pop    %esi
  80164b:	5f                   	pop    %edi
  80164c:	5d                   	pop    %ebp
  80164d:	c3                   	ret    

0080164e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	57                   	push   %edi
  801652:	56                   	push   %esi
  801653:	53                   	push   %ebx
  801654:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801657:	bb 00 00 00 00       	mov    $0x0,%ebx
  80165c:	b8 06 00 00 00       	mov    $0x6,%eax
  801661:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801664:	8b 55 08             	mov    0x8(%ebp),%edx
  801667:	89 df                	mov    %ebx,%edi
  801669:	89 de                	mov    %ebx,%esi
  80166b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80166d:	85 c0                	test   %eax,%eax
  80166f:	7e 17                	jle    801688 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801671:	83 ec 0c             	sub    $0xc,%esp
  801674:	50                   	push   %eax
  801675:	6a 06                	push   $0x6
  801677:	68 af 38 80 00       	push   $0x8038af
  80167c:	6a 23                	push   $0x23
  80167e:	68 cc 38 80 00       	push   $0x8038cc
  801683:	e8 ed f3 ff ff       	call   800a75 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801688:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168b:	5b                   	pop    %ebx
  80168c:	5e                   	pop    %esi
  80168d:	5f                   	pop    %edi
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	57                   	push   %edi
  801694:	56                   	push   %esi
  801695:	53                   	push   %ebx
  801696:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801699:	bb 00 00 00 00       	mov    $0x0,%ebx
  80169e:	b8 08 00 00 00       	mov    $0x8,%eax
  8016a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8016a9:	89 df                	mov    %ebx,%edi
  8016ab:	89 de                	mov    %ebx,%esi
  8016ad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	7e 17                	jle    8016ca <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016b3:	83 ec 0c             	sub    $0xc,%esp
  8016b6:	50                   	push   %eax
  8016b7:	6a 08                	push   $0x8
  8016b9:	68 af 38 80 00       	push   $0x8038af
  8016be:	6a 23                	push   $0x23
  8016c0:	68 cc 38 80 00       	push   $0x8038cc
  8016c5:	e8 ab f3 ff ff       	call   800a75 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8016ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	5f                   	pop    %edi
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    

008016d2 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	57                   	push   %edi
  8016d6:	56                   	push   %esi
  8016d7:	53                   	push   %ebx
  8016d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e0:	b8 09 00 00 00       	mov    $0x9,%eax
  8016e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8016eb:	89 df                	mov    %ebx,%edi
  8016ed:	89 de                	mov    %ebx,%esi
  8016ef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	7e 17                	jle    80170c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016f5:	83 ec 0c             	sub    $0xc,%esp
  8016f8:	50                   	push   %eax
  8016f9:	6a 09                	push   $0x9
  8016fb:	68 af 38 80 00       	push   $0x8038af
  801700:	6a 23                	push   $0x23
  801702:	68 cc 38 80 00       	push   $0x8038cc
  801707:	e8 69 f3 ff ff       	call   800a75 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80170c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170f:	5b                   	pop    %ebx
  801710:	5e                   	pop    %esi
  801711:	5f                   	pop    %edi
  801712:	5d                   	pop    %ebp
  801713:	c3                   	ret    

00801714 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	57                   	push   %edi
  801718:	56                   	push   %esi
  801719:	53                   	push   %ebx
  80171a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80171d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801722:	b8 0a 00 00 00       	mov    $0xa,%eax
  801727:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172a:	8b 55 08             	mov    0x8(%ebp),%edx
  80172d:	89 df                	mov    %ebx,%edi
  80172f:	89 de                	mov    %ebx,%esi
  801731:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801733:	85 c0                	test   %eax,%eax
  801735:	7e 17                	jle    80174e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801737:	83 ec 0c             	sub    $0xc,%esp
  80173a:	50                   	push   %eax
  80173b:	6a 0a                	push   $0xa
  80173d:	68 af 38 80 00       	push   $0x8038af
  801742:	6a 23                	push   $0x23
  801744:	68 cc 38 80 00       	push   $0x8038cc
  801749:	e8 27 f3 ff ff       	call   800a75 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80174e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801751:	5b                   	pop    %ebx
  801752:	5e                   	pop    %esi
  801753:	5f                   	pop    %edi
  801754:	5d                   	pop    %ebp
  801755:	c3                   	ret    

00801756 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	57                   	push   %edi
  80175a:	56                   	push   %esi
  80175b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80175c:	be 00 00 00 00       	mov    $0x0,%esi
  801761:	b8 0c 00 00 00       	mov    $0xc,%eax
  801766:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801769:	8b 55 08             	mov    0x8(%ebp),%edx
  80176c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80176f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801772:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801774:	5b                   	pop    %ebx
  801775:	5e                   	pop    %esi
  801776:	5f                   	pop    %edi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	57                   	push   %edi
  80177d:	56                   	push   %esi
  80177e:	53                   	push   %ebx
  80177f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801782:	b9 00 00 00 00       	mov    $0x0,%ecx
  801787:	b8 0d 00 00 00       	mov    $0xd,%eax
  80178c:	8b 55 08             	mov    0x8(%ebp),%edx
  80178f:	89 cb                	mov    %ecx,%ebx
  801791:	89 cf                	mov    %ecx,%edi
  801793:	89 ce                	mov    %ecx,%esi
  801795:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801797:	85 c0                	test   %eax,%eax
  801799:	7e 17                	jle    8017b2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80179b:	83 ec 0c             	sub    $0xc,%esp
  80179e:	50                   	push   %eax
  80179f:	6a 0d                	push   $0xd
  8017a1:	68 af 38 80 00       	push   $0x8038af
  8017a6:	6a 23                	push   $0x23
  8017a8:	68 cc 38 80 00       	push   $0x8038cc
  8017ad:	e8 c3 f2 ff ff       	call   800a75 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8017b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b5:	5b                   	pop    %ebx
  8017b6:	5e                   	pop    %esi
  8017b7:	5f                   	pop    %edi
  8017b8:	5d                   	pop    %ebp
  8017b9:	c3                   	ret    

008017ba <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	57                   	push   %edi
  8017be:	56                   	push   %esi
  8017bf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017c5:	b8 0e 00 00 00       	mov    $0xe,%eax
  8017ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8017cd:	89 cb                	mov    %ecx,%ebx
  8017cf:	89 cf                	mov    %ecx,%edi
  8017d1:	89 ce                	mov    %ecx,%esi
  8017d3:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  8017d5:	5b                   	pop    %ebx
  8017d6:	5e                   	pop    %esi
  8017d7:	5f                   	pop    %edi
  8017d8:	5d                   	pop    %ebp
  8017d9:	c3                   	ret    

008017da <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	53                   	push   %ebx
  8017de:	83 ec 04             	sub    $0x4,%esp
  8017e1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8017e4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8017e6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8017ea:	74 11                	je     8017fd <pgfault+0x23>
  8017ec:	89 d8                	mov    %ebx,%eax
  8017ee:	c1 e8 0c             	shr    $0xc,%eax
  8017f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017f8:	f6 c4 08             	test   $0x8,%ah
  8017fb:	75 14                	jne    801811 <pgfault+0x37>
		panic("faulting access");
  8017fd:	83 ec 04             	sub    $0x4,%esp
  801800:	68 da 38 80 00       	push   $0x8038da
  801805:	6a 1d                	push   $0x1d
  801807:	68 ea 38 80 00       	push   $0x8038ea
  80180c:	e8 64 f2 ff ff       	call   800a75 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  801811:	83 ec 04             	sub    $0x4,%esp
  801814:	6a 07                	push   $0x7
  801816:	68 00 f0 7f 00       	push   $0x7ff000
  80181b:	6a 00                	push   $0x0
  80181d:	e8 a7 fd ff ff       	call   8015c9 <sys_page_alloc>
	if (r < 0) {
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	85 c0                	test   %eax,%eax
  801827:	79 12                	jns    80183b <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  801829:	50                   	push   %eax
  80182a:	68 f5 38 80 00       	push   $0x8038f5
  80182f:	6a 2b                	push   $0x2b
  801831:	68 ea 38 80 00       	push   $0x8038ea
  801836:	e8 3a f2 ff ff       	call   800a75 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80183b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  801841:	83 ec 04             	sub    $0x4,%esp
  801844:	68 00 10 00 00       	push   $0x1000
  801849:	53                   	push   %ebx
  80184a:	68 00 f0 7f 00       	push   $0x7ff000
  80184f:	e8 6c fb ff ff       	call   8013c0 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801854:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80185b:	53                   	push   %ebx
  80185c:	6a 00                	push   $0x0
  80185e:	68 00 f0 7f 00       	push   $0x7ff000
  801863:	6a 00                	push   $0x0
  801865:	e8 a2 fd ff ff       	call   80160c <sys_page_map>
	if (r < 0) {
  80186a:	83 c4 20             	add    $0x20,%esp
  80186d:	85 c0                	test   %eax,%eax
  80186f:	79 12                	jns    801883 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  801871:	50                   	push   %eax
  801872:	68 f5 38 80 00       	push   $0x8038f5
  801877:	6a 32                	push   $0x32
  801879:	68 ea 38 80 00       	push   $0x8038ea
  80187e:	e8 f2 f1 ff ff       	call   800a75 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  801883:	83 ec 08             	sub    $0x8,%esp
  801886:	68 00 f0 7f 00       	push   $0x7ff000
  80188b:	6a 00                	push   $0x0
  80188d:	e8 bc fd ff ff       	call   80164e <sys_page_unmap>
	if (r < 0) {
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	85 c0                	test   %eax,%eax
  801897:	79 12                	jns    8018ab <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  801899:	50                   	push   %eax
  80189a:	68 f5 38 80 00       	push   $0x8038f5
  80189f:	6a 36                	push   $0x36
  8018a1:	68 ea 38 80 00       	push   $0x8038ea
  8018a6:	e8 ca f1 ff ff       	call   800a75 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8018ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ae:	c9                   	leave  
  8018af:	c3                   	ret    

008018b0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	57                   	push   %edi
  8018b4:	56                   	push   %esi
  8018b5:	53                   	push   %ebx
  8018b6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8018b9:	68 da 17 80 00       	push   $0x8017da
  8018be:	e8 fd 15 00 00       	call   802ec0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8018c3:	b8 07 00 00 00       	mov    $0x7,%eax
  8018c8:	cd 30                	int    $0x30
  8018ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	79 17                	jns    8018eb <fork+0x3b>
		panic("fork fault %e");
  8018d4:	83 ec 04             	sub    $0x4,%esp
  8018d7:	68 0e 39 80 00       	push   $0x80390e
  8018dc:	68 83 00 00 00       	push   $0x83
  8018e1:	68 ea 38 80 00       	push   $0x8038ea
  8018e6:	e8 8a f1 ff ff       	call   800a75 <_panic>
  8018eb:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8018ed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8018f1:	75 25                	jne    801918 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8018f3:	e8 93 fc ff ff       	call   80158b <sys_getenvid>
  8018f8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018fd:	89 c2                	mov    %eax,%edx
  8018ff:	c1 e2 07             	shl    $0x7,%edx
  801902:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801909:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  80190e:	b8 00 00 00 00       	mov    $0x0,%eax
  801913:	e9 61 01 00 00       	jmp    801a79 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801918:	83 ec 04             	sub    $0x4,%esp
  80191b:	6a 07                	push   $0x7
  80191d:	68 00 f0 bf ee       	push   $0xeebff000
  801922:	ff 75 e4             	pushl  -0x1c(%ebp)
  801925:	e8 9f fc ff ff       	call   8015c9 <sys_page_alloc>
  80192a:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80192d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801932:	89 d8                	mov    %ebx,%eax
  801934:	c1 e8 16             	shr    $0x16,%eax
  801937:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80193e:	a8 01                	test   $0x1,%al
  801940:	0f 84 fc 00 00 00    	je     801a42 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801946:	89 d8                	mov    %ebx,%eax
  801948:	c1 e8 0c             	shr    $0xc,%eax
  80194b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801952:	f6 c2 01             	test   $0x1,%dl
  801955:	0f 84 e7 00 00 00    	je     801a42 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80195b:	89 c6                	mov    %eax,%esi
  80195d:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801960:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801967:	f6 c6 04             	test   $0x4,%dh
  80196a:	74 39                	je     8019a5 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80196c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801973:	83 ec 0c             	sub    $0xc,%esp
  801976:	25 07 0e 00 00       	and    $0xe07,%eax
  80197b:	50                   	push   %eax
  80197c:	56                   	push   %esi
  80197d:	57                   	push   %edi
  80197e:	56                   	push   %esi
  80197f:	6a 00                	push   $0x0
  801981:	e8 86 fc ff ff       	call   80160c <sys_page_map>
		if (r < 0) {
  801986:	83 c4 20             	add    $0x20,%esp
  801989:	85 c0                	test   %eax,%eax
  80198b:	0f 89 b1 00 00 00    	jns    801a42 <fork+0x192>
		    	panic("sys page map fault %e");
  801991:	83 ec 04             	sub    $0x4,%esp
  801994:	68 1c 39 80 00       	push   $0x80391c
  801999:	6a 53                	push   $0x53
  80199b:	68 ea 38 80 00       	push   $0x8038ea
  8019a0:	e8 d0 f0 ff ff       	call   800a75 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8019a5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019ac:	f6 c2 02             	test   $0x2,%dl
  8019af:	75 0c                	jne    8019bd <fork+0x10d>
  8019b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019b8:	f6 c4 08             	test   $0x8,%ah
  8019bb:	74 5b                	je     801a18 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8019bd:	83 ec 0c             	sub    $0xc,%esp
  8019c0:	68 05 08 00 00       	push   $0x805
  8019c5:	56                   	push   %esi
  8019c6:	57                   	push   %edi
  8019c7:	56                   	push   %esi
  8019c8:	6a 00                	push   $0x0
  8019ca:	e8 3d fc ff ff       	call   80160c <sys_page_map>
		if (r < 0) {
  8019cf:	83 c4 20             	add    $0x20,%esp
  8019d2:	85 c0                	test   %eax,%eax
  8019d4:	79 14                	jns    8019ea <fork+0x13a>
		    	panic("sys page map fault %e");
  8019d6:	83 ec 04             	sub    $0x4,%esp
  8019d9:	68 1c 39 80 00       	push   $0x80391c
  8019de:	6a 5a                	push   $0x5a
  8019e0:	68 ea 38 80 00       	push   $0x8038ea
  8019e5:	e8 8b f0 ff ff       	call   800a75 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8019ea:	83 ec 0c             	sub    $0xc,%esp
  8019ed:	68 05 08 00 00       	push   $0x805
  8019f2:	56                   	push   %esi
  8019f3:	6a 00                	push   $0x0
  8019f5:	56                   	push   %esi
  8019f6:	6a 00                	push   $0x0
  8019f8:	e8 0f fc ff ff       	call   80160c <sys_page_map>
		if (r < 0) {
  8019fd:	83 c4 20             	add    $0x20,%esp
  801a00:	85 c0                	test   %eax,%eax
  801a02:	79 3e                	jns    801a42 <fork+0x192>
		    	panic("sys page map fault %e");
  801a04:	83 ec 04             	sub    $0x4,%esp
  801a07:	68 1c 39 80 00       	push   $0x80391c
  801a0c:	6a 5e                	push   $0x5e
  801a0e:	68 ea 38 80 00       	push   $0x8038ea
  801a13:	e8 5d f0 ff ff       	call   800a75 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	6a 05                	push   $0x5
  801a1d:	56                   	push   %esi
  801a1e:	57                   	push   %edi
  801a1f:	56                   	push   %esi
  801a20:	6a 00                	push   $0x0
  801a22:	e8 e5 fb ff ff       	call   80160c <sys_page_map>
		if (r < 0) {
  801a27:	83 c4 20             	add    $0x20,%esp
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	79 14                	jns    801a42 <fork+0x192>
		    	panic("sys page map fault %e");
  801a2e:	83 ec 04             	sub    $0x4,%esp
  801a31:	68 1c 39 80 00       	push   $0x80391c
  801a36:	6a 63                	push   $0x63
  801a38:	68 ea 38 80 00       	push   $0x8038ea
  801a3d:	e8 33 f0 ff ff       	call   800a75 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801a42:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a48:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801a4e:	0f 85 de fe ff ff    	jne    801932 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801a54:	a1 24 54 80 00       	mov    0x805424,%eax
  801a59:	8b 40 6c             	mov    0x6c(%eax),%eax
  801a5c:	83 ec 08             	sub    $0x8,%esp
  801a5f:	50                   	push   %eax
  801a60:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a63:	57                   	push   %edi
  801a64:	e8 ab fc ff ff       	call   801714 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801a69:	83 c4 08             	add    $0x8,%esp
  801a6c:	6a 02                	push   $0x2
  801a6e:	57                   	push   %edi
  801a6f:	e8 1c fc ff ff       	call   801690 <sys_env_set_status>
	
	return envid;
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801a79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7c:	5b                   	pop    %ebx
  801a7d:	5e                   	pop    %esi
  801a7e:	5f                   	pop    %edi
  801a7f:	5d                   	pop    %ebp
  801a80:	c3                   	ret    

00801a81 <sfork>:

envid_t
sfork(void)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801a84:	b8 00 00 00 00       	mov    $0x0,%eax
  801a89:	5d                   	pop    %ebp
  801a8a:	c3                   	ret    

00801a8b <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	56                   	push   %esi
  801a8f:	53                   	push   %ebx
  801a90:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("in fork.c thread create. func: %x\n", func);
  801a93:	83 ec 08             	sub    $0x8,%esp
  801a96:	53                   	push   %ebx
  801a97:	68 34 39 80 00       	push   $0x803934
  801a9c:	e8 ad f0 ff ff       	call   800b4e <cprintf>
	envid_t id = sys_thread_create((uintptr_t )func);
  801aa1:	89 1c 24             	mov    %ebx,(%esp)
  801aa4:	e8 11 fd ff ff       	call   8017ba <sys_thread_create>
  801aa9:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801aab:	83 c4 08             	add    $0x8,%esp
  801aae:	53                   	push   %ebx
  801aaf:	68 34 39 80 00       	push   $0x803934
  801ab4:	e8 95 f0 ff ff       	call   800b4e <cprintf>
	return id;
}
  801ab9:	89 f0                	mov    %esi,%eax
  801abb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abe:	5b                   	pop    %ebx
  801abf:	5e                   	pop    %esi
  801ac0:	5d                   	pop    %ebp
  801ac1:	c3                   	ret    

00801ac2 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	8b 55 08             	mov    0x8(%ebp),%edx
  801ac8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801acb:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801ace:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801ad0:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801ad3:	83 3a 01             	cmpl   $0x1,(%edx)
  801ad6:	7e 09                	jle    801ae1 <argstart+0x1f>
  801ad8:	ba 61 33 80 00       	mov    $0x803361,%edx
  801add:	85 c9                	test   %ecx,%ecx
  801adf:	75 05                	jne    801ae6 <argstart+0x24>
  801ae1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae6:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801ae9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801af0:	5d                   	pop    %ebp
  801af1:	c3                   	ret    

00801af2 <argnext>:

int
argnext(struct Argstate *args)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	53                   	push   %ebx
  801af6:	83 ec 04             	sub    $0x4,%esp
  801af9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801afc:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801b03:	8b 43 08             	mov    0x8(%ebx),%eax
  801b06:	85 c0                	test   %eax,%eax
  801b08:	74 6f                	je     801b79 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801b0a:	80 38 00             	cmpb   $0x0,(%eax)
  801b0d:	75 4e                	jne    801b5d <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b0f:	8b 0b                	mov    (%ebx),%ecx
  801b11:	83 39 01             	cmpl   $0x1,(%ecx)
  801b14:	74 55                	je     801b6b <argnext+0x79>
		    || args->argv[1][0] != '-'
  801b16:	8b 53 04             	mov    0x4(%ebx),%edx
  801b19:	8b 42 04             	mov    0x4(%edx),%eax
  801b1c:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b1f:	75 4a                	jne    801b6b <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801b21:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b25:	74 44                	je     801b6b <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b27:	83 c0 01             	add    $0x1,%eax
  801b2a:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b2d:	83 ec 04             	sub    $0x4,%esp
  801b30:	8b 01                	mov    (%ecx),%eax
  801b32:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b39:	50                   	push   %eax
  801b3a:	8d 42 08             	lea    0x8(%edx),%eax
  801b3d:	50                   	push   %eax
  801b3e:	83 c2 04             	add    $0x4,%edx
  801b41:	52                   	push   %edx
  801b42:	e8 11 f8 ff ff       	call   801358 <memmove>
		(*args->argc)--;
  801b47:	8b 03                	mov    (%ebx),%eax
  801b49:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b4c:	8b 43 08             	mov    0x8(%ebx),%eax
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b55:	75 06                	jne    801b5d <argnext+0x6b>
  801b57:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b5b:	74 0e                	je     801b6b <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b5d:	8b 53 08             	mov    0x8(%ebx),%edx
  801b60:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b63:	83 c2 01             	add    $0x1,%edx
  801b66:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b69:	eb 13                	jmp    801b7e <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b6b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b77:	eb 05                	jmp    801b7e <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b81:	c9                   	leave  
  801b82:	c3                   	ret    

00801b83 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	53                   	push   %ebx
  801b87:	83 ec 04             	sub    $0x4,%esp
  801b8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b8d:	8b 43 08             	mov    0x8(%ebx),%eax
  801b90:	85 c0                	test   %eax,%eax
  801b92:	74 58                	je     801bec <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801b94:	80 38 00             	cmpb   $0x0,(%eax)
  801b97:	74 0c                	je     801ba5 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801b99:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b9c:	c7 43 08 61 33 80 00 	movl   $0x803361,0x8(%ebx)
  801ba3:	eb 42                	jmp    801be7 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801ba5:	8b 13                	mov    (%ebx),%edx
  801ba7:	83 3a 01             	cmpl   $0x1,(%edx)
  801baa:	7e 2d                	jle    801bd9 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801bac:	8b 43 04             	mov    0x4(%ebx),%eax
  801baf:	8b 48 04             	mov    0x4(%eax),%ecx
  801bb2:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801bb5:	83 ec 04             	sub    $0x4,%esp
  801bb8:	8b 12                	mov    (%edx),%edx
  801bba:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801bc1:	52                   	push   %edx
  801bc2:	8d 50 08             	lea    0x8(%eax),%edx
  801bc5:	52                   	push   %edx
  801bc6:	83 c0 04             	add    $0x4,%eax
  801bc9:	50                   	push   %eax
  801bca:	e8 89 f7 ff ff       	call   801358 <memmove>
		(*args->argc)--;
  801bcf:	8b 03                	mov    (%ebx),%eax
  801bd1:	83 28 01             	subl   $0x1,(%eax)
  801bd4:	83 c4 10             	add    $0x10,%esp
  801bd7:	eb 0e                	jmp    801be7 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801bd9:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801be0:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801be7:	8b 43 0c             	mov    0xc(%ebx),%eax
  801bea:	eb 05                	jmp    801bf1 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801bec:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801bf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	83 ec 08             	sub    $0x8,%esp
  801bfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801bff:	8b 51 0c             	mov    0xc(%ecx),%edx
  801c02:	89 d0                	mov    %edx,%eax
  801c04:	85 d2                	test   %edx,%edx
  801c06:	75 0c                	jne    801c14 <argvalue+0x1e>
  801c08:	83 ec 0c             	sub    $0xc,%esp
  801c0b:	51                   	push   %ecx
  801c0c:	e8 72 ff ff ff       	call   801b83 <argnextvalue>
  801c11:	83 c4 10             	add    $0x10,%esp
}
  801c14:	c9                   	leave  
  801c15:	c3                   	ret    

00801c16 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c19:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1c:	05 00 00 00 30       	add    $0x30000000,%eax
  801c21:	c1 e8 0c             	shr    $0xc,%eax
}
  801c24:	5d                   	pop    %ebp
  801c25:	c3                   	ret    

00801c26 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c26:	55                   	push   %ebp
  801c27:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801c29:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2c:	05 00 00 00 30       	add    $0x30000000,%eax
  801c31:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c36:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c3b:	5d                   	pop    %ebp
  801c3c:	c3                   	ret    

00801c3d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c43:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c48:	89 c2                	mov    %eax,%edx
  801c4a:	c1 ea 16             	shr    $0x16,%edx
  801c4d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c54:	f6 c2 01             	test   $0x1,%dl
  801c57:	74 11                	je     801c6a <fd_alloc+0x2d>
  801c59:	89 c2                	mov    %eax,%edx
  801c5b:	c1 ea 0c             	shr    $0xc,%edx
  801c5e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c65:	f6 c2 01             	test   $0x1,%dl
  801c68:	75 09                	jne    801c73 <fd_alloc+0x36>
			*fd_store = fd;
  801c6a:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c71:	eb 17                	jmp    801c8a <fd_alloc+0x4d>
  801c73:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c78:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c7d:	75 c9                	jne    801c48 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c7f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801c85:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c8a:	5d                   	pop    %ebp
  801c8b:	c3                   	ret    

00801c8c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c92:	83 f8 1f             	cmp    $0x1f,%eax
  801c95:	77 36                	ja     801ccd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c97:	c1 e0 0c             	shl    $0xc,%eax
  801c9a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c9f:	89 c2                	mov    %eax,%edx
  801ca1:	c1 ea 16             	shr    $0x16,%edx
  801ca4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cab:	f6 c2 01             	test   $0x1,%dl
  801cae:	74 24                	je     801cd4 <fd_lookup+0x48>
  801cb0:	89 c2                	mov    %eax,%edx
  801cb2:	c1 ea 0c             	shr    $0xc,%edx
  801cb5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cbc:	f6 c2 01             	test   $0x1,%dl
  801cbf:	74 1a                	je     801cdb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801cc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cc4:	89 02                	mov    %eax,(%edx)
	return 0;
  801cc6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ccb:	eb 13                	jmp    801ce0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801ccd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cd2:	eb 0c                	jmp    801ce0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cd4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cd9:	eb 05                	jmp    801ce0 <fd_lookup+0x54>
  801cdb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    

00801ce2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	83 ec 08             	sub    $0x8,%esp
  801ce8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ceb:	ba d4 39 80 00       	mov    $0x8039d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801cf0:	eb 13                	jmp    801d05 <dev_lookup+0x23>
  801cf2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801cf5:	39 08                	cmp    %ecx,(%eax)
  801cf7:	75 0c                	jne    801d05 <dev_lookup+0x23>
			*dev = devtab[i];
  801cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cfc:	89 01                	mov    %eax,(%ecx)
			return 0;
  801cfe:	b8 00 00 00 00       	mov    $0x0,%eax
  801d03:	eb 2e                	jmp    801d33 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801d05:	8b 02                	mov    (%edx),%eax
  801d07:	85 c0                	test   %eax,%eax
  801d09:	75 e7                	jne    801cf2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d0b:	a1 24 54 80 00       	mov    0x805424,%eax
  801d10:	8b 40 50             	mov    0x50(%eax),%eax
  801d13:	83 ec 04             	sub    $0x4,%esp
  801d16:	51                   	push   %ecx
  801d17:	50                   	push   %eax
  801d18:	68 58 39 80 00       	push   $0x803958
  801d1d:	e8 2c ee ff ff       	call   800b4e <cprintf>
	*dev = 0;
  801d22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d25:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    

00801d35 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	56                   	push   %esi
  801d39:	53                   	push   %ebx
  801d3a:	83 ec 10             	sub    $0x10,%esp
  801d3d:	8b 75 08             	mov    0x8(%ebp),%esi
  801d40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d46:	50                   	push   %eax
  801d47:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d4d:	c1 e8 0c             	shr    $0xc,%eax
  801d50:	50                   	push   %eax
  801d51:	e8 36 ff ff ff       	call   801c8c <fd_lookup>
  801d56:	83 c4 08             	add    $0x8,%esp
  801d59:	85 c0                	test   %eax,%eax
  801d5b:	78 05                	js     801d62 <fd_close+0x2d>
	    || fd != fd2)
  801d5d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d60:	74 0c                	je     801d6e <fd_close+0x39>
		return (must_exist ? r : 0);
  801d62:	84 db                	test   %bl,%bl
  801d64:	ba 00 00 00 00       	mov    $0x0,%edx
  801d69:	0f 44 c2             	cmove  %edx,%eax
  801d6c:	eb 41                	jmp    801daf <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d6e:	83 ec 08             	sub    $0x8,%esp
  801d71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d74:	50                   	push   %eax
  801d75:	ff 36                	pushl  (%esi)
  801d77:	e8 66 ff ff ff       	call   801ce2 <dev_lookup>
  801d7c:	89 c3                	mov    %eax,%ebx
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	85 c0                	test   %eax,%eax
  801d83:	78 1a                	js     801d9f <fd_close+0x6a>
		if (dev->dev_close)
  801d85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d88:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801d8b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d90:	85 c0                	test   %eax,%eax
  801d92:	74 0b                	je     801d9f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801d94:	83 ec 0c             	sub    $0xc,%esp
  801d97:	56                   	push   %esi
  801d98:	ff d0                	call   *%eax
  801d9a:	89 c3                	mov    %eax,%ebx
  801d9c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d9f:	83 ec 08             	sub    $0x8,%esp
  801da2:	56                   	push   %esi
  801da3:	6a 00                	push   $0x0
  801da5:	e8 a4 f8 ff ff       	call   80164e <sys_page_unmap>
	return r;
  801daa:	83 c4 10             	add    $0x10,%esp
  801dad:	89 d8                	mov    %ebx,%eax
}
  801daf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db2:	5b                   	pop    %ebx
  801db3:	5e                   	pop    %esi
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    

00801db6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dbf:	50                   	push   %eax
  801dc0:	ff 75 08             	pushl  0x8(%ebp)
  801dc3:	e8 c4 fe ff ff       	call   801c8c <fd_lookup>
  801dc8:	83 c4 08             	add    $0x8,%esp
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	78 10                	js     801ddf <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801dcf:	83 ec 08             	sub    $0x8,%esp
  801dd2:	6a 01                	push   $0x1
  801dd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd7:	e8 59 ff ff ff       	call   801d35 <fd_close>
  801ddc:	83 c4 10             	add    $0x10,%esp
}
  801ddf:	c9                   	leave  
  801de0:	c3                   	ret    

00801de1 <close_all>:

void
close_all(void)
{
  801de1:	55                   	push   %ebp
  801de2:	89 e5                	mov    %esp,%ebp
  801de4:	53                   	push   %ebx
  801de5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801de8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801ded:	83 ec 0c             	sub    $0xc,%esp
  801df0:	53                   	push   %ebx
  801df1:	e8 c0 ff ff ff       	call   801db6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801df6:	83 c3 01             	add    $0x1,%ebx
  801df9:	83 c4 10             	add    $0x10,%esp
  801dfc:	83 fb 20             	cmp    $0x20,%ebx
  801dff:	75 ec                	jne    801ded <close_all+0xc>
		close(i);
}
  801e01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e04:	c9                   	leave  
  801e05:	c3                   	ret    

00801e06 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	57                   	push   %edi
  801e0a:	56                   	push   %esi
  801e0b:	53                   	push   %ebx
  801e0c:	83 ec 2c             	sub    $0x2c,%esp
  801e0f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e12:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e15:	50                   	push   %eax
  801e16:	ff 75 08             	pushl  0x8(%ebp)
  801e19:	e8 6e fe ff ff       	call   801c8c <fd_lookup>
  801e1e:	83 c4 08             	add    $0x8,%esp
  801e21:	85 c0                	test   %eax,%eax
  801e23:	0f 88 c1 00 00 00    	js     801eea <dup+0xe4>
		return r;
	close(newfdnum);
  801e29:	83 ec 0c             	sub    $0xc,%esp
  801e2c:	56                   	push   %esi
  801e2d:	e8 84 ff ff ff       	call   801db6 <close>

	newfd = INDEX2FD(newfdnum);
  801e32:	89 f3                	mov    %esi,%ebx
  801e34:	c1 e3 0c             	shl    $0xc,%ebx
  801e37:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801e3d:	83 c4 04             	add    $0x4,%esp
  801e40:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e43:	e8 de fd ff ff       	call   801c26 <fd2data>
  801e48:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801e4a:	89 1c 24             	mov    %ebx,(%esp)
  801e4d:	e8 d4 fd ff ff       	call   801c26 <fd2data>
  801e52:	83 c4 10             	add    $0x10,%esp
  801e55:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e58:	89 f8                	mov    %edi,%eax
  801e5a:	c1 e8 16             	shr    $0x16,%eax
  801e5d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e64:	a8 01                	test   $0x1,%al
  801e66:	74 37                	je     801e9f <dup+0x99>
  801e68:	89 f8                	mov    %edi,%eax
  801e6a:	c1 e8 0c             	shr    $0xc,%eax
  801e6d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e74:	f6 c2 01             	test   $0x1,%dl
  801e77:	74 26                	je     801e9f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e79:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e80:	83 ec 0c             	sub    $0xc,%esp
  801e83:	25 07 0e 00 00       	and    $0xe07,%eax
  801e88:	50                   	push   %eax
  801e89:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e8c:	6a 00                	push   $0x0
  801e8e:	57                   	push   %edi
  801e8f:	6a 00                	push   $0x0
  801e91:	e8 76 f7 ff ff       	call   80160c <sys_page_map>
  801e96:	89 c7                	mov    %eax,%edi
  801e98:	83 c4 20             	add    $0x20,%esp
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	78 2e                	js     801ecd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e9f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801ea2:	89 d0                	mov    %edx,%eax
  801ea4:	c1 e8 0c             	shr    $0xc,%eax
  801ea7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801eae:	83 ec 0c             	sub    $0xc,%esp
  801eb1:	25 07 0e 00 00       	and    $0xe07,%eax
  801eb6:	50                   	push   %eax
  801eb7:	53                   	push   %ebx
  801eb8:	6a 00                	push   $0x0
  801eba:	52                   	push   %edx
  801ebb:	6a 00                	push   $0x0
  801ebd:	e8 4a f7 ff ff       	call   80160c <sys_page_map>
  801ec2:	89 c7                	mov    %eax,%edi
  801ec4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801ec7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ec9:	85 ff                	test   %edi,%edi
  801ecb:	79 1d                	jns    801eea <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801ecd:	83 ec 08             	sub    $0x8,%esp
  801ed0:	53                   	push   %ebx
  801ed1:	6a 00                	push   $0x0
  801ed3:	e8 76 f7 ff ff       	call   80164e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ed8:	83 c4 08             	add    $0x8,%esp
  801edb:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ede:	6a 00                	push   $0x0
  801ee0:	e8 69 f7 ff ff       	call   80164e <sys_page_unmap>
	return r;
  801ee5:	83 c4 10             	add    $0x10,%esp
  801ee8:	89 f8                	mov    %edi,%eax
}
  801eea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eed:	5b                   	pop    %ebx
  801eee:	5e                   	pop    %esi
  801eef:	5f                   	pop    %edi
  801ef0:	5d                   	pop    %ebp
  801ef1:	c3                   	ret    

00801ef2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
  801ef5:	53                   	push   %ebx
  801ef6:	83 ec 14             	sub    $0x14,%esp
  801ef9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801efc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eff:	50                   	push   %eax
  801f00:	53                   	push   %ebx
  801f01:	e8 86 fd ff ff       	call   801c8c <fd_lookup>
  801f06:	83 c4 08             	add    $0x8,%esp
  801f09:	89 c2                	mov    %eax,%edx
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	78 6d                	js     801f7c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f0f:	83 ec 08             	sub    $0x8,%esp
  801f12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f15:	50                   	push   %eax
  801f16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f19:	ff 30                	pushl  (%eax)
  801f1b:	e8 c2 fd ff ff       	call   801ce2 <dev_lookup>
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	85 c0                	test   %eax,%eax
  801f25:	78 4c                	js     801f73 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f27:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f2a:	8b 42 08             	mov    0x8(%edx),%eax
  801f2d:	83 e0 03             	and    $0x3,%eax
  801f30:	83 f8 01             	cmp    $0x1,%eax
  801f33:	75 21                	jne    801f56 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f35:	a1 24 54 80 00       	mov    0x805424,%eax
  801f3a:	8b 40 50             	mov    0x50(%eax),%eax
  801f3d:	83 ec 04             	sub    $0x4,%esp
  801f40:	53                   	push   %ebx
  801f41:	50                   	push   %eax
  801f42:	68 99 39 80 00       	push   $0x803999
  801f47:	e8 02 ec ff ff       	call   800b4e <cprintf>
		return -E_INVAL;
  801f4c:	83 c4 10             	add    $0x10,%esp
  801f4f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f54:	eb 26                	jmp    801f7c <read+0x8a>
	}
	if (!dev->dev_read)
  801f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f59:	8b 40 08             	mov    0x8(%eax),%eax
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	74 17                	je     801f77 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801f60:	83 ec 04             	sub    $0x4,%esp
  801f63:	ff 75 10             	pushl  0x10(%ebp)
  801f66:	ff 75 0c             	pushl  0xc(%ebp)
  801f69:	52                   	push   %edx
  801f6a:	ff d0                	call   *%eax
  801f6c:	89 c2                	mov    %eax,%edx
  801f6e:	83 c4 10             	add    $0x10,%esp
  801f71:	eb 09                	jmp    801f7c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f73:	89 c2                	mov    %eax,%edx
  801f75:	eb 05                	jmp    801f7c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f77:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801f7c:	89 d0                	mov    %edx,%eax
  801f7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f81:	c9                   	leave  
  801f82:	c3                   	ret    

00801f83 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f83:	55                   	push   %ebp
  801f84:	89 e5                	mov    %esp,%ebp
  801f86:	57                   	push   %edi
  801f87:	56                   	push   %esi
  801f88:	53                   	push   %ebx
  801f89:	83 ec 0c             	sub    $0xc,%esp
  801f8c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f8f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f92:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f97:	eb 21                	jmp    801fba <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f99:	83 ec 04             	sub    $0x4,%esp
  801f9c:	89 f0                	mov    %esi,%eax
  801f9e:	29 d8                	sub    %ebx,%eax
  801fa0:	50                   	push   %eax
  801fa1:	89 d8                	mov    %ebx,%eax
  801fa3:	03 45 0c             	add    0xc(%ebp),%eax
  801fa6:	50                   	push   %eax
  801fa7:	57                   	push   %edi
  801fa8:	e8 45 ff ff ff       	call   801ef2 <read>
		if (m < 0)
  801fad:	83 c4 10             	add    $0x10,%esp
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	78 10                	js     801fc4 <readn+0x41>
			return m;
		if (m == 0)
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	74 0a                	je     801fc2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fb8:	01 c3                	add    %eax,%ebx
  801fba:	39 f3                	cmp    %esi,%ebx
  801fbc:	72 db                	jb     801f99 <readn+0x16>
  801fbe:	89 d8                	mov    %ebx,%eax
  801fc0:	eb 02                	jmp    801fc4 <readn+0x41>
  801fc2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801fc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc7:	5b                   	pop    %ebx
  801fc8:	5e                   	pop    %esi
  801fc9:	5f                   	pop    %edi
  801fca:	5d                   	pop    %ebp
  801fcb:	c3                   	ret    

00801fcc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	53                   	push   %ebx
  801fd0:	83 ec 14             	sub    $0x14,%esp
  801fd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fd6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fd9:	50                   	push   %eax
  801fda:	53                   	push   %ebx
  801fdb:	e8 ac fc ff ff       	call   801c8c <fd_lookup>
  801fe0:	83 c4 08             	add    $0x8,%esp
  801fe3:	89 c2                	mov    %eax,%edx
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	78 68                	js     802051 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fe9:	83 ec 08             	sub    $0x8,%esp
  801fec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fef:	50                   	push   %eax
  801ff0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ff3:	ff 30                	pushl  (%eax)
  801ff5:	e8 e8 fc ff ff       	call   801ce2 <dev_lookup>
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	78 47                	js     802048 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802001:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802004:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802008:	75 21                	jne    80202b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80200a:	a1 24 54 80 00       	mov    0x805424,%eax
  80200f:	8b 40 50             	mov    0x50(%eax),%eax
  802012:	83 ec 04             	sub    $0x4,%esp
  802015:	53                   	push   %ebx
  802016:	50                   	push   %eax
  802017:	68 b5 39 80 00       	push   $0x8039b5
  80201c:	e8 2d eb ff ff       	call   800b4e <cprintf>
		return -E_INVAL;
  802021:	83 c4 10             	add    $0x10,%esp
  802024:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802029:	eb 26                	jmp    802051 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80202b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80202e:	8b 52 0c             	mov    0xc(%edx),%edx
  802031:	85 d2                	test   %edx,%edx
  802033:	74 17                	je     80204c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802035:	83 ec 04             	sub    $0x4,%esp
  802038:	ff 75 10             	pushl  0x10(%ebp)
  80203b:	ff 75 0c             	pushl  0xc(%ebp)
  80203e:	50                   	push   %eax
  80203f:	ff d2                	call   *%edx
  802041:	89 c2                	mov    %eax,%edx
  802043:	83 c4 10             	add    $0x10,%esp
  802046:	eb 09                	jmp    802051 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802048:	89 c2                	mov    %eax,%edx
  80204a:	eb 05                	jmp    802051 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80204c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802051:	89 d0                	mov    %edx,%eax
  802053:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802056:	c9                   	leave  
  802057:	c3                   	ret    

00802058 <seek>:

int
seek(int fdnum, off_t offset)
{
  802058:	55                   	push   %ebp
  802059:	89 e5                	mov    %esp,%ebp
  80205b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80205e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802061:	50                   	push   %eax
  802062:	ff 75 08             	pushl  0x8(%ebp)
  802065:	e8 22 fc ff ff       	call   801c8c <fd_lookup>
  80206a:	83 c4 08             	add    $0x8,%esp
  80206d:	85 c0                	test   %eax,%eax
  80206f:	78 0e                	js     80207f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802071:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802074:	8b 55 0c             	mov    0xc(%ebp),%edx
  802077:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80207a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80207f:	c9                   	leave  
  802080:	c3                   	ret    

00802081 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802081:	55                   	push   %ebp
  802082:	89 e5                	mov    %esp,%ebp
  802084:	53                   	push   %ebx
  802085:	83 ec 14             	sub    $0x14,%esp
  802088:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80208b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80208e:	50                   	push   %eax
  80208f:	53                   	push   %ebx
  802090:	e8 f7 fb ff ff       	call   801c8c <fd_lookup>
  802095:	83 c4 08             	add    $0x8,%esp
  802098:	89 c2                	mov    %eax,%edx
  80209a:	85 c0                	test   %eax,%eax
  80209c:	78 65                	js     802103 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80209e:	83 ec 08             	sub    $0x8,%esp
  8020a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a4:	50                   	push   %eax
  8020a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a8:	ff 30                	pushl  (%eax)
  8020aa:	e8 33 fc ff ff       	call   801ce2 <dev_lookup>
  8020af:	83 c4 10             	add    $0x10,%esp
  8020b2:	85 c0                	test   %eax,%eax
  8020b4:	78 44                	js     8020fa <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8020b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8020bd:	75 21                	jne    8020e0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8020bf:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8020c4:	8b 40 50             	mov    0x50(%eax),%eax
  8020c7:	83 ec 04             	sub    $0x4,%esp
  8020ca:	53                   	push   %ebx
  8020cb:	50                   	push   %eax
  8020cc:	68 78 39 80 00       	push   $0x803978
  8020d1:	e8 78 ea ff ff       	call   800b4e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8020d6:	83 c4 10             	add    $0x10,%esp
  8020d9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8020de:	eb 23                	jmp    802103 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8020e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020e3:	8b 52 18             	mov    0x18(%edx),%edx
  8020e6:	85 d2                	test   %edx,%edx
  8020e8:	74 14                	je     8020fe <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8020ea:	83 ec 08             	sub    $0x8,%esp
  8020ed:	ff 75 0c             	pushl  0xc(%ebp)
  8020f0:	50                   	push   %eax
  8020f1:	ff d2                	call   *%edx
  8020f3:	89 c2                	mov    %eax,%edx
  8020f5:	83 c4 10             	add    $0x10,%esp
  8020f8:	eb 09                	jmp    802103 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020fa:	89 c2                	mov    %eax,%edx
  8020fc:	eb 05                	jmp    802103 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8020fe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802103:	89 d0                	mov    %edx,%eax
  802105:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802108:	c9                   	leave  
  802109:	c3                   	ret    

0080210a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80210a:	55                   	push   %ebp
  80210b:	89 e5                	mov    %esp,%ebp
  80210d:	53                   	push   %ebx
  80210e:	83 ec 14             	sub    $0x14,%esp
  802111:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802114:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802117:	50                   	push   %eax
  802118:	ff 75 08             	pushl  0x8(%ebp)
  80211b:	e8 6c fb ff ff       	call   801c8c <fd_lookup>
  802120:	83 c4 08             	add    $0x8,%esp
  802123:	89 c2                	mov    %eax,%edx
  802125:	85 c0                	test   %eax,%eax
  802127:	78 58                	js     802181 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802129:	83 ec 08             	sub    $0x8,%esp
  80212c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80212f:	50                   	push   %eax
  802130:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802133:	ff 30                	pushl  (%eax)
  802135:	e8 a8 fb ff ff       	call   801ce2 <dev_lookup>
  80213a:	83 c4 10             	add    $0x10,%esp
  80213d:	85 c0                	test   %eax,%eax
  80213f:	78 37                	js     802178 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802141:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802144:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802148:	74 32                	je     80217c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80214a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80214d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802154:	00 00 00 
	stat->st_isdir = 0;
  802157:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80215e:	00 00 00 
	stat->st_dev = dev;
  802161:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802167:	83 ec 08             	sub    $0x8,%esp
  80216a:	53                   	push   %ebx
  80216b:	ff 75 f0             	pushl  -0x10(%ebp)
  80216e:	ff 50 14             	call   *0x14(%eax)
  802171:	89 c2                	mov    %eax,%edx
  802173:	83 c4 10             	add    $0x10,%esp
  802176:	eb 09                	jmp    802181 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802178:	89 c2                	mov    %eax,%edx
  80217a:	eb 05                	jmp    802181 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80217c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802181:	89 d0                	mov    %edx,%eax
  802183:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802186:	c9                   	leave  
  802187:	c3                   	ret    

00802188 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802188:	55                   	push   %ebp
  802189:	89 e5                	mov    %esp,%ebp
  80218b:	56                   	push   %esi
  80218c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80218d:	83 ec 08             	sub    $0x8,%esp
  802190:	6a 00                	push   $0x0
  802192:	ff 75 08             	pushl  0x8(%ebp)
  802195:	e8 e3 01 00 00       	call   80237d <open>
  80219a:	89 c3                	mov    %eax,%ebx
  80219c:	83 c4 10             	add    $0x10,%esp
  80219f:	85 c0                	test   %eax,%eax
  8021a1:	78 1b                	js     8021be <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8021a3:	83 ec 08             	sub    $0x8,%esp
  8021a6:	ff 75 0c             	pushl  0xc(%ebp)
  8021a9:	50                   	push   %eax
  8021aa:	e8 5b ff ff ff       	call   80210a <fstat>
  8021af:	89 c6                	mov    %eax,%esi
	close(fd);
  8021b1:	89 1c 24             	mov    %ebx,(%esp)
  8021b4:	e8 fd fb ff ff       	call   801db6 <close>
	return r;
  8021b9:	83 c4 10             	add    $0x10,%esp
  8021bc:	89 f0                	mov    %esi,%eax
}
  8021be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021c1:	5b                   	pop    %ebx
  8021c2:	5e                   	pop    %esi
  8021c3:	5d                   	pop    %ebp
  8021c4:	c3                   	ret    

008021c5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8021c5:	55                   	push   %ebp
  8021c6:	89 e5                	mov    %esp,%ebp
  8021c8:	56                   	push   %esi
  8021c9:	53                   	push   %ebx
  8021ca:	89 c6                	mov    %eax,%esi
  8021cc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8021ce:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  8021d5:	75 12                	jne    8021e9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8021d7:	83 ec 0c             	sub    $0xc,%esp
  8021da:	6a 01                	push   $0x1
  8021dc:	e8 45 0e 00 00       	call   803026 <ipc_find_env>
  8021e1:	a3 20 54 80 00       	mov    %eax,0x805420
  8021e6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021e9:	6a 07                	push   $0x7
  8021eb:	68 00 60 80 00       	push   $0x806000
  8021f0:	56                   	push   %esi
  8021f1:	ff 35 20 54 80 00    	pushl  0x805420
  8021f7:	e8 c8 0d 00 00       	call   802fc4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021fc:	83 c4 0c             	add    $0xc,%esp
  8021ff:	6a 00                	push   $0x0
  802201:	53                   	push   %ebx
  802202:	6a 00                	push   $0x0
  802204:	e8 46 0d 00 00       	call   802f4f <ipc_recv>
}
  802209:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80220c:	5b                   	pop    %ebx
  80220d:	5e                   	pop    %esi
  80220e:	5d                   	pop    %ebp
  80220f:	c3                   	ret    

00802210 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802216:	8b 45 08             	mov    0x8(%ebp),%eax
  802219:	8b 40 0c             	mov    0xc(%eax),%eax
  80221c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802221:	8b 45 0c             	mov    0xc(%ebp),%eax
  802224:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802229:	ba 00 00 00 00       	mov    $0x0,%edx
  80222e:	b8 02 00 00 00       	mov    $0x2,%eax
  802233:	e8 8d ff ff ff       	call   8021c5 <fsipc>
}
  802238:	c9                   	leave  
  802239:	c3                   	ret    

0080223a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80223a:	55                   	push   %ebp
  80223b:	89 e5                	mov    %esp,%ebp
  80223d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802240:	8b 45 08             	mov    0x8(%ebp),%eax
  802243:	8b 40 0c             	mov    0xc(%eax),%eax
  802246:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80224b:	ba 00 00 00 00       	mov    $0x0,%edx
  802250:	b8 06 00 00 00       	mov    $0x6,%eax
  802255:	e8 6b ff ff ff       	call   8021c5 <fsipc>
}
  80225a:	c9                   	leave  
  80225b:	c3                   	ret    

0080225c <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80225c:	55                   	push   %ebp
  80225d:	89 e5                	mov    %esp,%ebp
  80225f:	53                   	push   %ebx
  802260:	83 ec 04             	sub    $0x4,%esp
  802263:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802266:	8b 45 08             	mov    0x8(%ebp),%eax
  802269:	8b 40 0c             	mov    0xc(%eax),%eax
  80226c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802271:	ba 00 00 00 00       	mov    $0x0,%edx
  802276:	b8 05 00 00 00       	mov    $0x5,%eax
  80227b:	e8 45 ff ff ff       	call   8021c5 <fsipc>
  802280:	85 c0                	test   %eax,%eax
  802282:	78 2c                	js     8022b0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802284:	83 ec 08             	sub    $0x8,%esp
  802287:	68 00 60 80 00       	push   $0x806000
  80228c:	53                   	push   %ebx
  80228d:	e8 34 ef ff ff       	call   8011c6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802292:	a1 80 60 80 00       	mov    0x806080,%eax
  802297:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80229d:	a1 84 60 80 00       	mov    0x806084,%eax
  8022a2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8022a8:	83 c4 10             	add    $0x10,%esp
  8022ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022b3:	c9                   	leave  
  8022b4:	c3                   	ret    

008022b5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8022b5:	55                   	push   %ebp
  8022b6:	89 e5                	mov    %esp,%ebp
  8022b8:	83 ec 0c             	sub    $0xc,%esp
  8022bb:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8022be:	8b 55 08             	mov    0x8(%ebp),%edx
  8022c1:	8b 52 0c             	mov    0xc(%edx),%edx
  8022c4:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8022ca:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8022cf:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8022d4:	0f 47 c2             	cmova  %edx,%eax
  8022d7:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8022dc:	50                   	push   %eax
  8022dd:	ff 75 0c             	pushl  0xc(%ebp)
  8022e0:	68 08 60 80 00       	push   $0x806008
  8022e5:	e8 6e f0 ff ff       	call   801358 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8022ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8022ef:	b8 04 00 00 00       	mov    $0x4,%eax
  8022f4:	e8 cc fe ff ff       	call   8021c5 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8022f9:	c9                   	leave  
  8022fa:	c3                   	ret    

008022fb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8022fb:	55                   	push   %ebp
  8022fc:	89 e5                	mov    %esp,%ebp
  8022fe:	56                   	push   %esi
  8022ff:	53                   	push   %ebx
  802300:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802303:	8b 45 08             	mov    0x8(%ebp),%eax
  802306:	8b 40 0c             	mov    0xc(%eax),%eax
  802309:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80230e:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802314:	ba 00 00 00 00       	mov    $0x0,%edx
  802319:	b8 03 00 00 00       	mov    $0x3,%eax
  80231e:	e8 a2 fe ff ff       	call   8021c5 <fsipc>
  802323:	89 c3                	mov    %eax,%ebx
  802325:	85 c0                	test   %eax,%eax
  802327:	78 4b                	js     802374 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802329:	39 c6                	cmp    %eax,%esi
  80232b:	73 16                	jae    802343 <devfile_read+0x48>
  80232d:	68 e4 39 80 00       	push   $0x8039e4
  802332:	68 8f 34 80 00       	push   $0x80348f
  802337:	6a 7c                	push   $0x7c
  802339:	68 eb 39 80 00       	push   $0x8039eb
  80233e:	e8 32 e7 ff ff       	call   800a75 <_panic>
	assert(r <= PGSIZE);
  802343:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802348:	7e 16                	jle    802360 <devfile_read+0x65>
  80234a:	68 f6 39 80 00       	push   $0x8039f6
  80234f:	68 8f 34 80 00       	push   $0x80348f
  802354:	6a 7d                	push   $0x7d
  802356:	68 eb 39 80 00       	push   $0x8039eb
  80235b:	e8 15 e7 ff ff       	call   800a75 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802360:	83 ec 04             	sub    $0x4,%esp
  802363:	50                   	push   %eax
  802364:	68 00 60 80 00       	push   $0x806000
  802369:	ff 75 0c             	pushl  0xc(%ebp)
  80236c:	e8 e7 ef ff ff       	call   801358 <memmove>
	return r;
  802371:	83 c4 10             	add    $0x10,%esp
}
  802374:	89 d8                	mov    %ebx,%eax
  802376:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802379:	5b                   	pop    %ebx
  80237a:	5e                   	pop    %esi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    

0080237d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80237d:	55                   	push   %ebp
  80237e:	89 e5                	mov    %esp,%ebp
  802380:	53                   	push   %ebx
  802381:	83 ec 20             	sub    $0x20,%esp
  802384:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802387:	53                   	push   %ebx
  802388:	e8 00 ee ff ff       	call   80118d <strlen>
  80238d:	83 c4 10             	add    $0x10,%esp
  802390:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802395:	7f 67                	jg     8023fe <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802397:	83 ec 0c             	sub    $0xc,%esp
  80239a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80239d:	50                   	push   %eax
  80239e:	e8 9a f8 ff ff       	call   801c3d <fd_alloc>
  8023a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8023a6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8023a8:	85 c0                	test   %eax,%eax
  8023aa:	78 57                	js     802403 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8023ac:	83 ec 08             	sub    $0x8,%esp
  8023af:	53                   	push   %ebx
  8023b0:	68 00 60 80 00       	push   $0x806000
  8023b5:	e8 0c ee ff ff       	call   8011c6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8023ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023bd:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8023c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ca:	e8 f6 fd ff ff       	call   8021c5 <fsipc>
  8023cf:	89 c3                	mov    %eax,%ebx
  8023d1:	83 c4 10             	add    $0x10,%esp
  8023d4:	85 c0                	test   %eax,%eax
  8023d6:	79 14                	jns    8023ec <open+0x6f>
		fd_close(fd, 0);
  8023d8:	83 ec 08             	sub    $0x8,%esp
  8023db:	6a 00                	push   $0x0
  8023dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8023e0:	e8 50 f9 ff ff       	call   801d35 <fd_close>
		return r;
  8023e5:	83 c4 10             	add    $0x10,%esp
  8023e8:	89 da                	mov    %ebx,%edx
  8023ea:	eb 17                	jmp    802403 <open+0x86>
	}

	return fd2num(fd);
  8023ec:	83 ec 0c             	sub    $0xc,%esp
  8023ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8023f2:	e8 1f f8 ff ff       	call   801c16 <fd2num>
  8023f7:	89 c2                	mov    %eax,%edx
  8023f9:	83 c4 10             	add    $0x10,%esp
  8023fc:	eb 05                	jmp    802403 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8023fe:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802403:	89 d0                	mov    %edx,%eax
  802405:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802408:	c9                   	leave  
  802409:	c3                   	ret    

0080240a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80240a:	55                   	push   %ebp
  80240b:	89 e5                	mov    %esp,%ebp
  80240d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802410:	ba 00 00 00 00       	mov    $0x0,%edx
  802415:	b8 08 00 00 00       	mov    $0x8,%eax
  80241a:	e8 a6 fd ff ff       	call   8021c5 <fsipc>
}
  80241f:	c9                   	leave  
  802420:	c3                   	ret    

00802421 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802421:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802425:	7e 37                	jle    80245e <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  802427:	55                   	push   %ebp
  802428:	89 e5                	mov    %esp,%ebp
  80242a:	53                   	push   %ebx
  80242b:	83 ec 08             	sub    $0x8,%esp
  80242e:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  802430:	ff 70 04             	pushl  0x4(%eax)
  802433:	8d 40 10             	lea    0x10(%eax),%eax
  802436:	50                   	push   %eax
  802437:	ff 33                	pushl  (%ebx)
  802439:	e8 8e fb ff ff       	call   801fcc <write>
		if (result > 0)
  80243e:	83 c4 10             	add    $0x10,%esp
  802441:	85 c0                	test   %eax,%eax
  802443:	7e 03                	jle    802448 <writebuf+0x27>
			b->result += result;
  802445:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802448:	3b 43 04             	cmp    0x4(%ebx),%eax
  80244b:	74 0d                	je     80245a <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80244d:	85 c0                	test   %eax,%eax
  80244f:	ba 00 00 00 00       	mov    $0x0,%edx
  802454:	0f 4f c2             	cmovg  %edx,%eax
  802457:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80245a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80245d:	c9                   	leave  
  80245e:	f3 c3                	repz ret 

00802460 <putch>:

static void
putch(int ch, void *thunk)
{
  802460:	55                   	push   %ebp
  802461:	89 e5                	mov    %esp,%ebp
  802463:	53                   	push   %ebx
  802464:	83 ec 04             	sub    $0x4,%esp
  802467:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80246a:	8b 53 04             	mov    0x4(%ebx),%edx
  80246d:	8d 42 01             	lea    0x1(%edx),%eax
  802470:	89 43 04             	mov    %eax,0x4(%ebx)
  802473:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802476:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80247a:	3d 00 01 00 00       	cmp    $0x100,%eax
  80247f:	75 0e                	jne    80248f <putch+0x2f>
		writebuf(b);
  802481:	89 d8                	mov    %ebx,%eax
  802483:	e8 99 ff ff ff       	call   802421 <writebuf>
		b->idx = 0;
  802488:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80248f:	83 c4 04             	add    $0x4,%esp
  802492:	5b                   	pop    %ebx
  802493:	5d                   	pop    %ebp
  802494:	c3                   	ret    

00802495 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802495:	55                   	push   %ebp
  802496:	89 e5                	mov    %esp,%ebp
  802498:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80249e:	8b 45 08             	mov    0x8(%ebp),%eax
  8024a1:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8024a7:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8024ae:	00 00 00 
	b.result = 0;
  8024b1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8024b8:	00 00 00 
	b.error = 1;
  8024bb:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8024c2:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8024c5:	ff 75 10             	pushl  0x10(%ebp)
  8024c8:	ff 75 0c             	pushl  0xc(%ebp)
  8024cb:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024d1:	50                   	push   %eax
  8024d2:	68 60 24 80 00       	push   $0x802460
  8024d7:	e8 a9 e7 ff ff       	call   800c85 <vprintfmt>
	if (b.idx > 0)
  8024dc:	83 c4 10             	add    $0x10,%esp
  8024df:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024e6:	7e 0b                	jle    8024f3 <vfprintf+0x5e>
		writebuf(&b);
  8024e8:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024ee:	e8 2e ff ff ff       	call   802421 <writebuf>

	return (b.result ? b.result : b.error);
  8024f3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8024f9:	85 c0                	test   %eax,%eax
  8024fb:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  802502:	c9                   	leave  
  802503:	c3                   	ret    

00802504 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802504:	55                   	push   %ebp
  802505:	89 e5                	mov    %esp,%ebp
  802507:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80250a:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80250d:	50                   	push   %eax
  80250e:	ff 75 0c             	pushl  0xc(%ebp)
  802511:	ff 75 08             	pushl  0x8(%ebp)
  802514:	e8 7c ff ff ff       	call   802495 <vfprintf>
	va_end(ap);

	return cnt;
}
  802519:	c9                   	leave  
  80251a:	c3                   	ret    

0080251b <printf>:

int
printf(const char *fmt, ...)
{
  80251b:	55                   	push   %ebp
  80251c:	89 e5                	mov    %esp,%ebp
  80251e:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802521:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802524:	50                   	push   %eax
  802525:	ff 75 08             	pushl  0x8(%ebp)
  802528:	6a 01                	push   $0x1
  80252a:	e8 66 ff ff ff       	call   802495 <vfprintf>
	va_end(ap);

	return cnt;
}
  80252f:	c9                   	leave  
  802530:	c3                   	ret    

00802531 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802531:	55                   	push   %ebp
  802532:	89 e5                	mov    %esp,%ebp
  802534:	57                   	push   %edi
  802535:	56                   	push   %esi
  802536:	53                   	push   %ebx
  802537:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80253d:	6a 00                	push   $0x0
  80253f:	ff 75 08             	pushl  0x8(%ebp)
  802542:	e8 36 fe ff ff       	call   80237d <open>
  802547:	89 c7                	mov    %eax,%edi
  802549:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80254f:	83 c4 10             	add    $0x10,%esp
  802552:	85 c0                	test   %eax,%eax
  802554:	0f 88 89 04 00 00    	js     8029e3 <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80255a:	83 ec 04             	sub    $0x4,%esp
  80255d:	68 00 02 00 00       	push   $0x200
  802562:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802568:	50                   	push   %eax
  802569:	57                   	push   %edi
  80256a:	e8 14 fa ff ff       	call   801f83 <readn>
  80256f:	83 c4 10             	add    $0x10,%esp
  802572:	3d 00 02 00 00       	cmp    $0x200,%eax
  802577:	75 0c                	jne    802585 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  802579:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802580:	45 4c 46 
  802583:	74 33                	je     8025b8 <spawn+0x87>
		close(fd);
  802585:	83 ec 0c             	sub    $0xc,%esp
  802588:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80258e:	e8 23 f8 ff ff       	call   801db6 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802593:	83 c4 0c             	add    $0xc,%esp
  802596:	68 7f 45 4c 46       	push   $0x464c457f
  80259b:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8025a1:	68 02 3a 80 00       	push   $0x803a02
  8025a6:	e8 a3 e5 ff ff       	call   800b4e <cprintf>
		return -E_NOT_EXEC;
  8025ab:	83 c4 10             	add    $0x10,%esp
  8025ae:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8025b3:	e9 de 04 00 00       	jmp    802a96 <spawn+0x565>
  8025b8:	b8 07 00 00 00       	mov    $0x7,%eax
  8025bd:	cd 30                	int    $0x30
  8025bf:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8025c5:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8025cb:	85 c0                	test   %eax,%eax
  8025cd:	0f 88 1b 04 00 00    	js     8029ee <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8025d3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8025d8:	89 c2                	mov    %eax,%edx
  8025da:	c1 e2 07             	shl    $0x7,%edx
  8025dd:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8025e3:	8d b4 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%esi
  8025ea:	b9 11 00 00 00       	mov    $0x11,%ecx
  8025ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8025f1:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8025f7:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025fd:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802602:	be 00 00 00 00       	mov    $0x0,%esi
  802607:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80260a:	eb 13                	jmp    80261f <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80260c:	83 ec 0c             	sub    $0xc,%esp
  80260f:	50                   	push   %eax
  802610:	e8 78 eb ff ff       	call   80118d <strlen>
  802615:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802619:	83 c3 01             	add    $0x1,%ebx
  80261c:	83 c4 10             	add    $0x10,%esp
  80261f:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802626:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802629:	85 c0                	test   %eax,%eax
  80262b:	75 df                	jne    80260c <spawn+0xdb>
  80262d:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802633:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802639:	bf 00 10 40 00       	mov    $0x401000,%edi
  80263e:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802640:	89 fa                	mov    %edi,%edx
  802642:	83 e2 fc             	and    $0xfffffffc,%edx
  802645:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80264c:	29 c2                	sub    %eax,%edx
  80264e:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802654:	8d 42 f8             	lea    -0x8(%edx),%eax
  802657:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80265c:	0f 86 a2 03 00 00    	jbe    802a04 <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802662:	83 ec 04             	sub    $0x4,%esp
  802665:	6a 07                	push   $0x7
  802667:	68 00 00 40 00       	push   $0x400000
  80266c:	6a 00                	push   $0x0
  80266e:	e8 56 ef ff ff       	call   8015c9 <sys_page_alloc>
  802673:	83 c4 10             	add    $0x10,%esp
  802676:	85 c0                	test   %eax,%eax
  802678:	0f 88 90 03 00 00    	js     802a0e <spawn+0x4dd>
  80267e:	be 00 00 00 00       	mov    $0x0,%esi
  802683:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802689:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80268c:	eb 30                	jmp    8026be <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80268e:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802694:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80269a:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  80269d:	83 ec 08             	sub    $0x8,%esp
  8026a0:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8026a3:	57                   	push   %edi
  8026a4:	e8 1d eb ff ff       	call   8011c6 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8026a9:	83 c4 04             	add    $0x4,%esp
  8026ac:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8026af:	e8 d9 ea ff ff       	call   80118d <strlen>
  8026b4:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8026b8:	83 c6 01             	add    $0x1,%esi
  8026bb:	83 c4 10             	add    $0x10,%esp
  8026be:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8026c4:	7f c8                	jg     80268e <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8026c6:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8026cc:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8026d2:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8026d9:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8026df:	74 19                	je     8026fa <spawn+0x1c9>
  8026e1:	68 8c 3a 80 00       	push   $0x803a8c
  8026e6:	68 8f 34 80 00       	push   $0x80348f
  8026eb:	68 f2 00 00 00       	push   $0xf2
  8026f0:	68 1c 3a 80 00       	push   $0x803a1c
  8026f5:	e8 7b e3 ff ff       	call   800a75 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8026fa:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  802700:	89 f8                	mov    %edi,%eax
  802702:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802707:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80270a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802710:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802713:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  802719:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80271f:	83 ec 0c             	sub    $0xc,%esp
  802722:	6a 07                	push   $0x7
  802724:	68 00 d0 bf ee       	push   $0xeebfd000
  802729:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80272f:	68 00 00 40 00       	push   $0x400000
  802734:	6a 00                	push   $0x0
  802736:	e8 d1 ee ff ff       	call   80160c <sys_page_map>
  80273b:	89 c3                	mov    %eax,%ebx
  80273d:	83 c4 20             	add    $0x20,%esp
  802740:	85 c0                	test   %eax,%eax
  802742:	0f 88 3c 03 00 00    	js     802a84 <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802748:	83 ec 08             	sub    $0x8,%esp
  80274b:	68 00 00 40 00       	push   $0x400000
  802750:	6a 00                	push   $0x0
  802752:	e8 f7 ee ff ff       	call   80164e <sys_page_unmap>
  802757:	89 c3                	mov    %eax,%ebx
  802759:	83 c4 10             	add    $0x10,%esp
  80275c:	85 c0                	test   %eax,%eax
  80275e:	0f 88 20 03 00 00    	js     802a84 <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802764:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80276a:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802771:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802777:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  80277e:	00 00 00 
  802781:	e9 88 01 00 00       	jmp    80290e <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  802786:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80278c:	83 38 01             	cmpl   $0x1,(%eax)
  80278f:	0f 85 6b 01 00 00    	jne    802900 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802795:	89 c2                	mov    %eax,%edx
  802797:	8b 40 18             	mov    0x18(%eax),%eax
  80279a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8027a0:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8027a3:	83 f8 01             	cmp    $0x1,%eax
  8027a6:	19 c0                	sbb    %eax,%eax
  8027a8:	83 e0 fe             	and    $0xfffffffe,%eax
  8027ab:	83 c0 07             	add    $0x7,%eax
  8027ae:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8027b4:	89 d0                	mov    %edx,%eax
  8027b6:	8b 7a 04             	mov    0x4(%edx),%edi
  8027b9:	89 f9                	mov    %edi,%ecx
  8027bb:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8027c1:	8b 7a 10             	mov    0x10(%edx),%edi
  8027c4:	8b 52 14             	mov    0x14(%edx),%edx
  8027c7:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  8027cd:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8027d0:	89 f0                	mov    %esi,%eax
  8027d2:	25 ff 0f 00 00       	and    $0xfff,%eax
  8027d7:	74 14                	je     8027ed <spawn+0x2bc>
		va -= i;
  8027d9:	29 c6                	sub    %eax,%esi
		memsz += i;
  8027db:	01 c2                	add    %eax,%edx
  8027dd:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8027e3:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8027e5:	29 c1                	sub    %eax,%ecx
  8027e7:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8027ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027f2:	e9 f7 00 00 00       	jmp    8028ee <spawn+0x3bd>
		if (i >= filesz) {
  8027f7:	39 fb                	cmp    %edi,%ebx
  8027f9:	72 27                	jb     802822 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8027fb:	83 ec 04             	sub    $0x4,%esp
  8027fe:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802804:	56                   	push   %esi
  802805:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80280b:	e8 b9 ed ff ff       	call   8015c9 <sys_page_alloc>
  802810:	83 c4 10             	add    $0x10,%esp
  802813:	85 c0                	test   %eax,%eax
  802815:	0f 89 c7 00 00 00    	jns    8028e2 <spawn+0x3b1>
  80281b:	89 c3                	mov    %eax,%ebx
  80281d:	e9 fd 01 00 00       	jmp    802a1f <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802822:	83 ec 04             	sub    $0x4,%esp
  802825:	6a 07                	push   $0x7
  802827:	68 00 00 40 00       	push   $0x400000
  80282c:	6a 00                	push   $0x0
  80282e:	e8 96 ed ff ff       	call   8015c9 <sys_page_alloc>
  802833:	83 c4 10             	add    $0x10,%esp
  802836:	85 c0                	test   %eax,%eax
  802838:	0f 88 d7 01 00 00    	js     802a15 <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80283e:	83 ec 08             	sub    $0x8,%esp
  802841:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802847:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80284d:	50                   	push   %eax
  80284e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802854:	e8 ff f7 ff ff       	call   802058 <seek>
  802859:	83 c4 10             	add    $0x10,%esp
  80285c:	85 c0                	test   %eax,%eax
  80285e:	0f 88 b5 01 00 00    	js     802a19 <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802864:	83 ec 04             	sub    $0x4,%esp
  802867:	89 f8                	mov    %edi,%eax
  802869:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  80286f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802874:	ba 00 10 00 00       	mov    $0x1000,%edx
  802879:	0f 47 c2             	cmova  %edx,%eax
  80287c:	50                   	push   %eax
  80287d:	68 00 00 40 00       	push   $0x400000
  802882:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802888:	e8 f6 f6 ff ff       	call   801f83 <readn>
  80288d:	83 c4 10             	add    $0x10,%esp
  802890:	85 c0                	test   %eax,%eax
  802892:	0f 88 85 01 00 00    	js     802a1d <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802898:	83 ec 0c             	sub    $0xc,%esp
  80289b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8028a1:	56                   	push   %esi
  8028a2:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8028a8:	68 00 00 40 00       	push   $0x400000
  8028ad:	6a 00                	push   $0x0
  8028af:	e8 58 ed ff ff       	call   80160c <sys_page_map>
  8028b4:	83 c4 20             	add    $0x20,%esp
  8028b7:	85 c0                	test   %eax,%eax
  8028b9:	79 15                	jns    8028d0 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  8028bb:	50                   	push   %eax
  8028bc:	68 28 3a 80 00       	push   $0x803a28
  8028c1:	68 25 01 00 00       	push   $0x125
  8028c6:	68 1c 3a 80 00       	push   $0x803a1c
  8028cb:	e8 a5 e1 ff ff       	call   800a75 <_panic>
			sys_page_unmap(0, UTEMP);
  8028d0:	83 ec 08             	sub    $0x8,%esp
  8028d3:	68 00 00 40 00       	push   $0x400000
  8028d8:	6a 00                	push   $0x0
  8028da:	e8 6f ed ff ff       	call   80164e <sys_page_unmap>
  8028df:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8028e2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8028e8:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8028ee:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8028f4:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8028fa:	0f 82 f7 fe ff ff    	jb     8027f7 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802900:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802907:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80290e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802915:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  80291b:	0f 8c 65 fe ff ff    	jl     802786 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802921:	83 ec 0c             	sub    $0xc,%esp
  802924:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80292a:	e8 87 f4 ff ff       	call   801db6 <close>
  80292f:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802932:	bb 00 00 00 00       	mov    $0x0,%ebx
  802937:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  80293d:	89 d8                	mov    %ebx,%eax
  80293f:	c1 e8 16             	shr    $0x16,%eax
  802942:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802949:	a8 01                	test   $0x1,%al
  80294b:	74 42                	je     80298f <spawn+0x45e>
  80294d:	89 d8                	mov    %ebx,%eax
  80294f:	c1 e8 0c             	shr    $0xc,%eax
  802952:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802959:	f6 c2 01             	test   $0x1,%dl
  80295c:	74 31                	je     80298f <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  80295e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  802965:	f6 c6 04             	test   $0x4,%dh
  802968:	74 25                	je     80298f <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  80296a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802971:	83 ec 0c             	sub    $0xc,%esp
  802974:	25 07 0e 00 00       	and    $0xe07,%eax
  802979:	50                   	push   %eax
  80297a:	53                   	push   %ebx
  80297b:	56                   	push   %esi
  80297c:	53                   	push   %ebx
  80297d:	6a 00                	push   $0x0
  80297f:	e8 88 ec ff ff       	call   80160c <sys_page_map>
			if (r < 0) {
  802984:	83 c4 20             	add    $0x20,%esp
  802987:	85 c0                	test   %eax,%eax
  802989:	0f 88 b1 00 00 00    	js     802a40 <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  80298f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802995:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80299b:	75 a0                	jne    80293d <spawn+0x40c>
  80299d:	e9 b3 00 00 00       	jmp    802a55 <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8029a2:	50                   	push   %eax
  8029a3:	68 45 3a 80 00       	push   $0x803a45
  8029a8:	68 86 00 00 00       	push   $0x86
  8029ad:	68 1c 3a 80 00       	push   $0x803a1c
  8029b2:	e8 be e0 ff ff       	call   800a75 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8029b7:	83 ec 08             	sub    $0x8,%esp
  8029ba:	6a 02                	push   $0x2
  8029bc:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029c2:	e8 c9 ec ff ff       	call   801690 <sys_env_set_status>
  8029c7:	83 c4 10             	add    $0x10,%esp
  8029ca:	85 c0                	test   %eax,%eax
  8029cc:	79 2b                	jns    8029f9 <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  8029ce:	50                   	push   %eax
  8029cf:	68 5f 3a 80 00       	push   $0x803a5f
  8029d4:	68 89 00 00 00       	push   $0x89
  8029d9:	68 1c 3a 80 00       	push   $0x803a1c
  8029de:	e8 92 e0 ff ff       	call   800a75 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8029e3:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8029e9:	e9 a8 00 00 00       	jmp    802a96 <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8029ee:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029f4:	e9 9d 00 00 00       	jmp    802a96 <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8029f9:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029ff:	e9 92 00 00 00       	jmp    802a96 <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802a04:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802a09:	e9 88 00 00 00       	jmp    802a96 <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802a0e:	89 c3                	mov    %eax,%ebx
  802a10:	e9 81 00 00 00       	jmp    802a96 <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802a15:	89 c3                	mov    %eax,%ebx
  802a17:	eb 06                	jmp    802a1f <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802a19:	89 c3                	mov    %eax,%ebx
  802a1b:	eb 02                	jmp    802a1f <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802a1d:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802a1f:	83 ec 0c             	sub    $0xc,%esp
  802a22:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a28:	e8 1d eb ff ff       	call   80154a <sys_env_destroy>
	close(fd);
  802a2d:	83 c4 04             	add    $0x4,%esp
  802a30:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a36:	e8 7b f3 ff ff       	call   801db6 <close>
	return r;
  802a3b:	83 c4 10             	add    $0x10,%esp
  802a3e:	eb 56                	jmp    802a96 <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802a40:	50                   	push   %eax
  802a41:	68 76 3a 80 00       	push   $0x803a76
  802a46:	68 82 00 00 00       	push   $0x82
  802a4b:	68 1c 3a 80 00       	push   $0x803a1c
  802a50:	e8 20 e0 ff ff       	call   800a75 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802a55:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802a5c:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802a5f:	83 ec 08             	sub    $0x8,%esp
  802a62:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a68:	50                   	push   %eax
  802a69:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a6f:	e8 5e ec ff ff       	call   8016d2 <sys_env_set_trapframe>
  802a74:	83 c4 10             	add    $0x10,%esp
  802a77:	85 c0                	test   %eax,%eax
  802a79:	0f 89 38 ff ff ff    	jns    8029b7 <spawn+0x486>
  802a7f:	e9 1e ff ff ff       	jmp    8029a2 <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802a84:	83 ec 08             	sub    $0x8,%esp
  802a87:	68 00 00 40 00       	push   $0x400000
  802a8c:	6a 00                	push   $0x0
  802a8e:	e8 bb eb ff ff       	call   80164e <sys_page_unmap>
  802a93:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802a96:	89 d8                	mov    %ebx,%eax
  802a98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a9b:	5b                   	pop    %ebx
  802a9c:	5e                   	pop    %esi
  802a9d:	5f                   	pop    %edi
  802a9e:	5d                   	pop    %ebp
  802a9f:	c3                   	ret    

00802aa0 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802aa0:	55                   	push   %ebp
  802aa1:	89 e5                	mov    %esp,%ebp
  802aa3:	56                   	push   %esi
  802aa4:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802aa5:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802aa8:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802aad:	eb 03                	jmp    802ab2 <spawnl+0x12>
		argc++;
  802aaf:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802ab2:	83 c2 04             	add    $0x4,%edx
  802ab5:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802ab9:	75 f4                	jne    802aaf <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802abb:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802ac2:	83 e2 f0             	and    $0xfffffff0,%edx
  802ac5:	29 d4                	sub    %edx,%esp
  802ac7:	8d 54 24 03          	lea    0x3(%esp),%edx
  802acb:	c1 ea 02             	shr    $0x2,%edx
  802ace:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802ad5:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802ada:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802ae1:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802ae8:	00 
  802ae9:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802aeb:	b8 00 00 00 00       	mov    $0x0,%eax
  802af0:	eb 0a                	jmp    802afc <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802af2:	83 c0 01             	add    $0x1,%eax
  802af5:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802af9:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802afc:	39 d0                	cmp    %edx,%eax
  802afe:	75 f2                	jne    802af2 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802b00:	83 ec 08             	sub    $0x8,%esp
  802b03:	56                   	push   %esi
  802b04:	ff 75 08             	pushl  0x8(%ebp)
  802b07:	e8 25 fa ff ff       	call   802531 <spawn>
}
  802b0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b0f:	5b                   	pop    %ebx
  802b10:	5e                   	pop    %esi
  802b11:	5d                   	pop    %ebp
  802b12:	c3                   	ret    

00802b13 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802b13:	55                   	push   %ebp
  802b14:	89 e5                	mov    %esp,%ebp
  802b16:	56                   	push   %esi
  802b17:	53                   	push   %ebx
  802b18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802b1b:	83 ec 0c             	sub    $0xc,%esp
  802b1e:	ff 75 08             	pushl  0x8(%ebp)
  802b21:	e8 00 f1 ff ff       	call   801c26 <fd2data>
  802b26:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802b28:	83 c4 08             	add    $0x8,%esp
  802b2b:	68 b4 3a 80 00       	push   $0x803ab4
  802b30:	53                   	push   %ebx
  802b31:	e8 90 e6 ff ff       	call   8011c6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802b36:	8b 46 04             	mov    0x4(%esi),%eax
  802b39:	2b 06                	sub    (%esi),%eax
  802b3b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802b41:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802b48:	00 00 00 
	stat->st_dev = &devpipe;
  802b4b:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802b52:	40 80 00 
	return 0;
}
  802b55:	b8 00 00 00 00       	mov    $0x0,%eax
  802b5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b5d:	5b                   	pop    %ebx
  802b5e:	5e                   	pop    %esi
  802b5f:	5d                   	pop    %ebp
  802b60:	c3                   	ret    

00802b61 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802b61:	55                   	push   %ebp
  802b62:	89 e5                	mov    %esp,%ebp
  802b64:	53                   	push   %ebx
  802b65:	83 ec 0c             	sub    $0xc,%esp
  802b68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b6b:	53                   	push   %ebx
  802b6c:	6a 00                	push   $0x0
  802b6e:	e8 db ea ff ff       	call   80164e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b73:	89 1c 24             	mov    %ebx,(%esp)
  802b76:	e8 ab f0 ff ff       	call   801c26 <fd2data>
  802b7b:	83 c4 08             	add    $0x8,%esp
  802b7e:	50                   	push   %eax
  802b7f:	6a 00                	push   $0x0
  802b81:	e8 c8 ea ff ff       	call   80164e <sys_page_unmap>
}
  802b86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b89:	c9                   	leave  
  802b8a:	c3                   	ret    

00802b8b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b8b:	55                   	push   %ebp
  802b8c:	89 e5                	mov    %esp,%ebp
  802b8e:	57                   	push   %edi
  802b8f:	56                   	push   %esi
  802b90:	53                   	push   %ebx
  802b91:	83 ec 1c             	sub    $0x1c,%esp
  802b94:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802b97:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802b99:	a1 24 54 80 00       	mov    0x805424,%eax
  802b9e:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802ba1:	83 ec 0c             	sub    $0xc,%esp
  802ba4:	ff 75 e0             	pushl  -0x20(%ebp)
  802ba7:	e8 ba 04 00 00       	call   803066 <pageref>
  802bac:	89 c3                	mov    %eax,%ebx
  802bae:	89 3c 24             	mov    %edi,(%esp)
  802bb1:	e8 b0 04 00 00       	call   803066 <pageref>
  802bb6:	83 c4 10             	add    $0x10,%esp
  802bb9:	39 c3                	cmp    %eax,%ebx
  802bbb:	0f 94 c1             	sete   %cl
  802bbe:	0f b6 c9             	movzbl %cl,%ecx
  802bc1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802bc4:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802bca:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  802bcd:	39 ce                	cmp    %ecx,%esi
  802bcf:	74 1b                	je     802bec <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802bd1:	39 c3                	cmp    %eax,%ebx
  802bd3:	75 c4                	jne    802b99 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802bd5:	8b 42 60             	mov    0x60(%edx),%eax
  802bd8:	ff 75 e4             	pushl  -0x1c(%ebp)
  802bdb:	50                   	push   %eax
  802bdc:	56                   	push   %esi
  802bdd:	68 bb 3a 80 00       	push   $0x803abb
  802be2:	e8 67 df ff ff       	call   800b4e <cprintf>
  802be7:	83 c4 10             	add    $0x10,%esp
  802bea:	eb ad                	jmp    802b99 <_pipeisclosed+0xe>
	}
}
  802bec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802bef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bf2:	5b                   	pop    %ebx
  802bf3:	5e                   	pop    %esi
  802bf4:	5f                   	pop    %edi
  802bf5:	5d                   	pop    %ebp
  802bf6:	c3                   	ret    

00802bf7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802bf7:	55                   	push   %ebp
  802bf8:	89 e5                	mov    %esp,%ebp
  802bfa:	57                   	push   %edi
  802bfb:	56                   	push   %esi
  802bfc:	53                   	push   %ebx
  802bfd:	83 ec 28             	sub    $0x28,%esp
  802c00:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802c03:	56                   	push   %esi
  802c04:	e8 1d f0 ff ff       	call   801c26 <fd2data>
  802c09:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c0b:	83 c4 10             	add    $0x10,%esp
  802c0e:	bf 00 00 00 00       	mov    $0x0,%edi
  802c13:	eb 4b                	jmp    802c60 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802c15:	89 da                	mov    %ebx,%edx
  802c17:	89 f0                	mov    %esi,%eax
  802c19:	e8 6d ff ff ff       	call   802b8b <_pipeisclosed>
  802c1e:	85 c0                	test   %eax,%eax
  802c20:	75 48                	jne    802c6a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802c22:	e8 83 e9 ff ff       	call   8015aa <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802c27:	8b 43 04             	mov    0x4(%ebx),%eax
  802c2a:	8b 0b                	mov    (%ebx),%ecx
  802c2c:	8d 51 20             	lea    0x20(%ecx),%edx
  802c2f:	39 d0                	cmp    %edx,%eax
  802c31:	73 e2                	jae    802c15 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c36:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802c3a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802c3d:	89 c2                	mov    %eax,%edx
  802c3f:	c1 fa 1f             	sar    $0x1f,%edx
  802c42:	89 d1                	mov    %edx,%ecx
  802c44:	c1 e9 1b             	shr    $0x1b,%ecx
  802c47:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802c4a:	83 e2 1f             	and    $0x1f,%edx
  802c4d:	29 ca                	sub    %ecx,%edx
  802c4f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802c53:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802c57:	83 c0 01             	add    $0x1,%eax
  802c5a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c5d:	83 c7 01             	add    $0x1,%edi
  802c60:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802c63:	75 c2                	jne    802c27 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c65:	8b 45 10             	mov    0x10(%ebp),%eax
  802c68:	eb 05                	jmp    802c6f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c6a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c72:	5b                   	pop    %ebx
  802c73:	5e                   	pop    %esi
  802c74:	5f                   	pop    %edi
  802c75:	5d                   	pop    %ebp
  802c76:	c3                   	ret    

00802c77 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c77:	55                   	push   %ebp
  802c78:	89 e5                	mov    %esp,%ebp
  802c7a:	57                   	push   %edi
  802c7b:	56                   	push   %esi
  802c7c:	53                   	push   %ebx
  802c7d:	83 ec 18             	sub    $0x18,%esp
  802c80:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c83:	57                   	push   %edi
  802c84:	e8 9d ef ff ff       	call   801c26 <fd2data>
  802c89:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c8b:	83 c4 10             	add    $0x10,%esp
  802c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c93:	eb 3d                	jmp    802cd2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802c95:	85 db                	test   %ebx,%ebx
  802c97:	74 04                	je     802c9d <devpipe_read+0x26>
				return i;
  802c99:	89 d8                	mov    %ebx,%eax
  802c9b:	eb 44                	jmp    802ce1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802c9d:	89 f2                	mov    %esi,%edx
  802c9f:	89 f8                	mov    %edi,%eax
  802ca1:	e8 e5 fe ff ff       	call   802b8b <_pipeisclosed>
  802ca6:	85 c0                	test   %eax,%eax
  802ca8:	75 32                	jne    802cdc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802caa:	e8 fb e8 ff ff       	call   8015aa <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802caf:	8b 06                	mov    (%esi),%eax
  802cb1:	3b 46 04             	cmp    0x4(%esi),%eax
  802cb4:	74 df                	je     802c95 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802cb6:	99                   	cltd   
  802cb7:	c1 ea 1b             	shr    $0x1b,%edx
  802cba:	01 d0                	add    %edx,%eax
  802cbc:	83 e0 1f             	and    $0x1f,%eax
  802cbf:	29 d0                	sub    %edx,%eax
  802cc1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802cc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802cc9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802ccc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ccf:	83 c3 01             	add    $0x1,%ebx
  802cd2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802cd5:	75 d8                	jne    802caf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802cd7:	8b 45 10             	mov    0x10(%ebp),%eax
  802cda:	eb 05                	jmp    802ce1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802cdc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802ce1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ce4:	5b                   	pop    %ebx
  802ce5:	5e                   	pop    %esi
  802ce6:	5f                   	pop    %edi
  802ce7:	5d                   	pop    %ebp
  802ce8:	c3                   	ret    

00802ce9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802ce9:	55                   	push   %ebp
  802cea:	89 e5                	mov    %esp,%ebp
  802cec:	56                   	push   %esi
  802ced:	53                   	push   %ebx
  802cee:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802cf1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cf4:	50                   	push   %eax
  802cf5:	e8 43 ef ff ff       	call   801c3d <fd_alloc>
  802cfa:	83 c4 10             	add    $0x10,%esp
  802cfd:	89 c2                	mov    %eax,%edx
  802cff:	85 c0                	test   %eax,%eax
  802d01:	0f 88 2c 01 00 00    	js     802e33 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d07:	83 ec 04             	sub    $0x4,%esp
  802d0a:	68 07 04 00 00       	push   $0x407
  802d0f:	ff 75 f4             	pushl  -0xc(%ebp)
  802d12:	6a 00                	push   $0x0
  802d14:	e8 b0 e8 ff ff       	call   8015c9 <sys_page_alloc>
  802d19:	83 c4 10             	add    $0x10,%esp
  802d1c:	89 c2                	mov    %eax,%edx
  802d1e:	85 c0                	test   %eax,%eax
  802d20:	0f 88 0d 01 00 00    	js     802e33 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802d26:	83 ec 0c             	sub    $0xc,%esp
  802d29:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d2c:	50                   	push   %eax
  802d2d:	e8 0b ef ff ff       	call   801c3d <fd_alloc>
  802d32:	89 c3                	mov    %eax,%ebx
  802d34:	83 c4 10             	add    $0x10,%esp
  802d37:	85 c0                	test   %eax,%eax
  802d39:	0f 88 e2 00 00 00    	js     802e21 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d3f:	83 ec 04             	sub    $0x4,%esp
  802d42:	68 07 04 00 00       	push   $0x407
  802d47:	ff 75 f0             	pushl  -0x10(%ebp)
  802d4a:	6a 00                	push   $0x0
  802d4c:	e8 78 e8 ff ff       	call   8015c9 <sys_page_alloc>
  802d51:	89 c3                	mov    %eax,%ebx
  802d53:	83 c4 10             	add    $0x10,%esp
  802d56:	85 c0                	test   %eax,%eax
  802d58:	0f 88 c3 00 00 00    	js     802e21 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802d5e:	83 ec 0c             	sub    $0xc,%esp
  802d61:	ff 75 f4             	pushl  -0xc(%ebp)
  802d64:	e8 bd ee ff ff       	call   801c26 <fd2data>
  802d69:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d6b:	83 c4 0c             	add    $0xc,%esp
  802d6e:	68 07 04 00 00       	push   $0x407
  802d73:	50                   	push   %eax
  802d74:	6a 00                	push   $0x0
  802d76:	e8 4e e8 ff ff       	call   8015c9 <sys_page_alloc>
  802d7b:	89 c3                	mov    %eax,%ebx
  802d7d:	83 c4 10             	add    $0x10,%esp
  802d80:	85 c0                	test   %eax,%eax
  802d82:	0f 88 89 00 00 00    	js     802e11 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d88:	83 ec 0c             	sub    $0xc,%esp
  802d8b:	ff 75 f0             	pushl  -0x10(%ebp)
  802d8e:	e8 93 ee ff ff       	call   801c26 <fd2data>
  802d93:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802d9a:	50                   	push   %eax
  802d9b:	6a 00                	push   $0x0
  802d9d:	56                   	push   %esi
  802d9e:	6a 00                	push   $0x0
  802da0:	e8 67 e8 ff ff       	call   80160c <sys_page_map>
  802da5:	89 c3                	mov    %eax,%ebx
  802da7:	83 c4 20             	add    $0x20,%esp
  802daa:	85 c0                	test   %eax,%eax
  802dac:	78 55                	js     802e03 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802dae:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802db7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dbc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802dc3:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dcc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802dce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dd1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802dd8:	83 ec 0c             	sub    $0xc,%esp
  802ddb:	ff 75 f4             	pushl  -0xc(%ebp)
  802dde:	e8 33 ee ff ff       	call   801c16 <fd2num>
  802de3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802de6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802de8:	83 c4 04             	add    $0x4,%esp
  802deb:	ff 75 f0             	pushl  -0x10(%ebp)
  802dee:	e8 23 ee ff ff       	call   801c16 <fd2num>
  802df3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802df6:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802df9:	83 c4 10             	add    $0x10,%esp
  802dfc:	ba 00 00 00 00       	mov    $0x0,%edx
  802e01:	eb 30                	jmp    802e33 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802e03:	83 ec 08             	sub    $0x8,%esp
  802e06:	56                   	push   %esi
  802e07:	6a 00                	push   $0x0
  802e09:	e8 40 e8 ff ff       	call   80164e <sys_page_unmap>
  802e0e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802e11:	83 ec 08             	sub    $0x8,%esp
  802e14:	ff 75 f0             	pushl  -0x10(%ebp)
  802e17:	6a 00                	push   $0x0
  802e19:	e8 30 e8 ff ff       	call   80164e <sys_page_unmap>
  802e1e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802e21:	83 ec 08             	sub    $0x8,%esp
  802e24:	ff 75 f4             	pushl  -0xc(%ebp)
  802e27:	6a 00                	push   $0x0
  802e29:	e8 20 e8 ff ff       	call   80164e <sys_page_unmap>
  802e2e:	83 c4 10             	add    $0x10,%esp
  802e31:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802e33:	89 d0                	mov    %edx,%eax
  802e35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e38:	5b                   	pop    %ebx
  802e39:	5e                   	pop    %esi
  802e3a:	5d                   	pop    %ebp
  802e3b:	c3                   	ret    

00802e3c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802e3c:	55                   	push   %ebp
  802e3d:	89 e5                	mov    %esp,%ebp
  802e3f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e45:	50                   	push   %eax
  802e46:	ff 75 08             	pushl  0x8(%ebp)
  802e49:	e8 3e ee ff ff       	call   801c8c <fd_lookup>
  802e4e:	83 c4 10             	add    $0x10,%esp
  802e51:	85 c0                	test   %eax,%eax
  802e53:	78 18                	js     802e6d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802e55:	83 ec 0c             	sub    $0xc,%esp
  802e58:	ff 75 f4             	pushl  -0xc(%ebp)
  802e5b:	e8 c6 ed ff ff       	call   801c26 <fd2data>
	return _pipeisclosed(fd, p);
  802e60:	89 c2                	mov    %eax,%edx
  802e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e65:	e8 21 fd ff ff       	call   802b8b <_pipeisclosed>
  802e6a:	83 c4 10             	add    $0x10,%esp
}
  802e6d:	c9                   	leave  
  802e6e:	c3                   	ret    

00802e6f <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e6f:	55                   	push   %ebp
  802e70:	89 e5                	mov    %esp,%ebp
  802e72:	56                   	push   %esi
  802e73:	53                   	push   %ebx
  802e74:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e77:	85 f6                	test   %esi,%esi
  802e79:	75 16                	jne    802e91 <wait+0x22>
  802e7b:	68 d3 3a 80 00       	push   $0x803ad3
  802e80:	68 8f 34 80 00       	push   $0x80348f
  802e85:	6a 09                	push   $0x9
  802e87:	68 de 3a 80 00       	push   $0x803ade
  802e8c:	e8 e4 db ff ff       	call   800a75 <_panic>
	e = &envs[ENVX(envid)];
  802e91:	89 f0                	mov    %esi,%eax
  802e93:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e98:	89 c2                	mov    %eax,%edx
  802e9a:	c1 e2 07             	shl    $0x7,%edx
  802e9d:	8d 9c 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%ebx
  802ea4:	eb 05                	jmp    802eab <wait+0x3c>
		sys_yield();
  802ea6:	e8 ff e6 ff ff       	call   8015aa <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802eab:	8b 43 50             	mov    0x50(%ebx),%eax
  802eae:	39 c6                	cmp    %eax,%esi
  802eb0:	75 07                	jne    802eb9 <wait+0x4a>
  802eb2:	8b 43 5c             	mov    0x5c(%ebx),%eax
  802eb5:	85 c0                	test   %eax,%eax
  802eb7:	75 ed                	jne    802ea6 <wait+0x37>
		sys_yield();
}
  802eb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ebc:	5b                   	pop    %ebx
  802ebd:	5e                   	pop    %esi
  802ebe:	5d                   	pop    %ebp
  802ebf:	c3                   	ret    

00802ec0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802ec0:	55                   	push   %ebp
  802ec1:	89 e5                	mov    %esp,%ebp
  802ec3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802ec6:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802ecd:	75 2a                	jne    802ef9 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802ecf:	83 ec 04             	sub    $0x4,%esp
  802ed2:	6a 07                	push   $0x7
  802ed4:	68 00 f0 bf ee       	push   $0xeebff000
  802ed9:	6a 00                	push   $0x0
  802edb:	e8 e9 e6 ff ff       	call   8015c9 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802ee0:	83 c4 10             	add    $0x10,%esp
  802ee3:	85 c0                	test   %eax,%eax
  802ee5:	79 12                	jns    802ef9 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802ee7:	50                   	push   %eax
  802ee8:	68 ab 38 80 00       	push   $0x8038ab
  802eed:	6a 23                	push   $0x23
  802eef:	68 e9 3a 80 00       	push   $0x803ae9
  802ef4:	e8 7c db ff ff       	call   800a75 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  802efc:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802f01:	83 ec 08             	sub    $0x8,%esp
  802f04:	68 2b 2f 80 00       	push   $0x802f2b
  802f09:	6a 00                	push   $0x0
  802f0b:	e8 04 e8 ff ff       	call   801714 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802f10:	83 c4 10             	add    $0x10,%esp
  802f13:	85 c0                	test   %eax,%eax
  802f15:	79 12                	jns    802f29 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802f17:	50                   	push   %eax
  802f18:	68 ab 38 80 00       	push   $0x8038ab
  802f1d:	6a 2c                	push   $0x2c
  802f1f:	68 e9 3a 80 00       	push   $0x803ae9
  802f24:	e8 4c db ff ff       	call   800a75 <_panic>
	}
}
  802f29:	c9                   	leave  
  802f2a:	c3                   	ret    

00802f2b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802f2b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802f2c:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802f31:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802f33:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802f36:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802f3a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802f3f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802f43:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802f45:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802f48:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802f49:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802f4c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802f4d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802f4e:	c3                   	ret    

00802f4f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802f4f:	55                   	push   %ebp
  802f50:	89 e5                	mov    %esp,%ebp
  802f52:	56                   	push   %esi
  802f53:	53                   	push   %ebx
  802f54:	8b 75 08             	mov    0x8(%ebp),%esi
  802f57:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802f5d:	85 c0                	test   %eax,%eax
  802f5f:	75 12                	jne    802f73 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802f61:	83 ec 0c             	sub    $0xc,%esp
  802f64:	68 00 00 c0 ee       	push   $0xeec00000
  802f69:	e8 0b e8 ff ff       	call   801779 <sys_ipc_recv>
  802f6e:	83 c4 10             	add    $0x10,%esp
  802f71:	eb 0c                	jmp    802f7f <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802f73:	83 ec 0c             	sub    $0xc,%esp
  802f76:	50                   	push   %eax
  802f77:	e8 fd e7 ff ff       	call   801779 <sys_ipc_recv>
  802f7c:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802f7f:	85 f6                	test   %esi,%esi
  802f81:	0f 95 c1             	setne  %cl
  802f84:	85 db                	test   %ebx,%ebx
  802f86:	0f 95 c2             	setne  %dl
  802f89:	84 d1                	test   %dl,%cl
  802f8b:	74 09                	je     802f96 <ipc_recv+0x47>
  802f8d:	89 c2                	mov    %eax,%edx
  802f8f:	c1 ea 1f             	shr    $0x1f,%edx
  802f92:	84 d2                	test   %dl,%dl
  802f94:	75 27                	jne    802fbd <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802f96:	85 f6                	test   %esi,%esi
  802f98:	74 0a                	je     802fa4 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  802f9a:	a1 24 54 80 00       	mov    0x805424,%eax
  802f9f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802fa2:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802fa4:	85 db                	test   %ebx,%ebx
  802fa6:	74 0d                	je     802fb5 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  802fa8:	a1 24 54 80 00       	mov    0x805424,%eax
  802fad:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  802fb3:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802fb5:	a1 24 54 80 00       	mov    0x805424,%eax
  802fba:	8b 40 78             	mov    0x78(%eax),%eax
}
  802fbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fc0:	5b                   	pop    %ebx
  802fc1:	5e                   	pop    %esi
  802fc2:	5d                   	pop    %ebp
  802fc3:	c3                   	ret    

00802fc4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802fc4:	55                   	push   %ebp
  802fc5:	89 e5                	mov    %esp,%ebp
  802fc7:	57                   	push   %edi
  802fc8:	56                   	push   %esi
  802fc9:	53                   	push   %ebx
  802fca:	83 ec 0c             	sub    $0xc,%esp
  802fcd:	8b 7d 08             	mov    0x8(%ebp),%edi
  802fd0:	8b 75 0c             	mov    0xc(%ebp),%esi
  802fd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802fd6:	85 db                	test   %ebx,%ebx
  802fd8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802fdd:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802fe0:	ff 75 14             	pushl  0x14(%ebp)
  802fe3:	53                   	push   %ebx
  802fe4:	56                   	push   %esi
  802fe5:	57                   	push   %edi
  802fe6:	e8 6b e7 ff ff       	call   801756 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802feb:	89 c2                	mov    %eax,%edx
  802fed:	c1 ea 1f             	shr    $0x1f,%edx
  802ff0:	83 c4 10             	add    $0x10,%esp
  802ff3:	84 d2                	test   %dl,%dl
  802ff5:	74 17                	je     80300e <ipc_send+0x4a>
  802ff7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802ffa:	74 12                	je     80300e <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802ffc:	50                   	push   %eax
  802ffd:	68 f7 3a 80 00       	push   $0x803af7
  803002:	6a 47                	push   $0x47
  803004:	68 05 3b 80 00       	push   $0x803b05
  803009:	e8 67 da ff ff       	call   800a75 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80300e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803011:	75 07                	jne    80301a <ipc_send+0x56>
			sys_yield();
  803013:	e8 92 e5 ff ff       	call   8015aa <sys_yield>
  803018:	eb c6                	jmp    802fe0 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80301a:	85 c0                	test   %eax,%eax
  80301c:	75 c2                	jne    802fe0 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80301e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803021:	5b                   	pop    %ebx
  803022:	5e                   	pop    %esi
  803023:	5f                   	pop    %edi
  803024:	5d                   	pop    %ebp
  803025:	c3                   	ret    

00803026 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803026:	55                   	push   %ebp
  803027:	89 e5                	mov    %esp,%ebp
  803029:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80302c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  803031:	89 c2                	mov    %eax,%edx
  803033:	c1 e2 07             	shl    $0x7,%edx
  803036:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  80303d:	8b 52 58             	mov    0x58(%edx),%edx
  803040:	39 ca                	cmp    %ecx,%edx
  803042:	75 11                	jne    803055 <ipc_find_env+0x2f>
			return envs[i].env_id;
  803044:	89 c2                	mov    %eax,%edx
  803046:	c1 e2 07             	shl    $0x7,%edx
  803049:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  803050:	8b 40 50             	mov    0x50(%eax),%eax
  803053:	eb 0f                	jmp    803064 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803055:	83 c0 01             	add    $0x1,%eax
  803058:	3d 00 04 00 00       	cmp    $0x400,%eax
  80305d:	75 d2                	jne    803031 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80305f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803064:	5d                   	pop    %ebp
  803065:	c3                   	ret    

00803066 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803066:	55                   	push   %ebp
  803067:	89 e5                	mov    %esp,%ebp
  803069:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80306c:	89 d0                	mov    %edx,%eax
  80306e:	c1 e8 16             	shr    $0x16,%eax
  803071:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803078:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80307d:	f6 c1 01             	test   $0x1,%cl
  803080:	74 1d                	je     80309f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803082:	c1 ea 0c             	shr    $0xc,%edx
  803085:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80308c:	f6 c2 01             	test   $0x1,%dl
  80308f:	74 0e                	je     80309f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803091:	c1 ea 0c             	shr    $0xc,%edx
  803094:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80309b:	ef 
  80309c:	0f b7 c0             	movzwl %ax,%eax
}
  80309f:	5d                   	pop    %ebp
  8030a0:	c3                   	ret    
  8030a1:	66 90                	xchg   %ax,%ax
  8030a3:	66 90                	xchg   %ax,%ax
  8030a5:	66 90                	xchg   %ax,%ax
  8030a7:	66 90                	xchg   %ax,%ax
  8030a9:	66 90                	xchg   %ax,%ax
  8030ab:	66 90                	xchg   %ax,%ax
  8030ad:	66 90                	xchg   %ax,%ax
  8030af:	90                   	nop

008030b0 <__udivdi3>:
  8030b0:	55                   	push   %ebp
  8030b1:	57                   	push   %edi
  8030b2:	56                   	push   %esi
  8030b3:	53                   	push   %ebx
  8030b4:	83 ec 1c             	sub    $0x1c,%esp
  8030b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8030bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8030bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8030c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8030c7:	85 f6                	test   %esi,%esi
  8030c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8030cd:	89 ca                	mov    %ecx,%edx
  8030cf:	89 f8                	mov    %edi,%eax
  8030d1:	75 3d                	jne    803110 <__udivdi3+0x60>
  8030d3:	39 cf                	cmp    %ecx,%edi
  8030d5:	0f 87 c5 00 00 00    	ja     8031a0 <__udivdi3+0xf0>
  8030db:	85 ff                	test   %edi,%edi
  8030dd:	89 fd                	mov    %edi,%ebp
  8030df:	75 0b                	jne    8030ec <__udivdi3+0x3c>
  8030e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8030e6:	31 d2                	xor    %edx,%edx
  8030e8:	f7 f7                	div    %edi
  8030ea:	89 c5                	mov    %eax,%ebp
  8030ec:	89 c8                	mov    %ecx,%eax
  8030ee:	31 d2                	xor    %edx,%edx
  8030f0:	f7 f5                	div    %ebp
  8030f2:	89 c1                	mov    %eax,%ecx
  8030f4:	89 d8                	mov    %ebx,%eax
  8030f6:	89 cf                	mov    %ecx,%edi
  8030f8:	f7 f5                	div    %ebp
  8030fa:	89 c3                	mov    %eax,%ebx
  8030fc:	89 d8                	mov    %ebx,%eax
  8030fe:	89 fa                	mov    %edi,%edx
  803100:	83 c4 1c             	add    $0x1c,%esp
  803103:	5b                   	pop    %ebx
  803104:	5e                   	pop    %esi
  803105:	5f                   	pop    %edi
  803106:	5d                   	pop    %ebp
  803107:	c3                   	ret    
  803108:	90                   	nop
  803109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803110:	39 ce                	cmp    %ecx,%esi
  803112:	77 74                	ja     803188 <__udivdi3+0xd8>
  803114:	0f bd fe             	bsr    %esi,%edi
  803117:	83 f7 1f             	xor    $0x1f,%edi
  80311a:	0f 84 98 00 00 00    	je     8031b8 <__udivdi3+0x108>
  803120:	bb 20 00 00 00       	mov    $0x20,%ebx
  803125:	89 f9                	mov    %edi,%ecx
  803127:	89 c5                	mov    %eax,%ebp
  803129:	29 fb                	sub    %edi,%ebx
  80312b:	d3 e6                	shl    %cl,%esi
  80312d:	89 d9                	mov    %ebx,%ecx
  80312f:	d3 ed                	shr    %cl,%ebp
  803131:	89 f9                	mov    %edi,%ecx
  803133:	d3 e0                	shl    %cl,%eax
  803135:	09 ee                	or     %ebp,%esi
  803137:	89 d9                	mov    %ebx,%ecx
  803139:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80313d:	89 d5                	mov    %edx,%ebp
  80313f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803143:	d3 ed                	shr    %cl,%ebp
  803145:	89 f9                	mov    %edi,%ecx
  803147:	d3 e2                	shl    %cl,%edx
  803149:	89 d9                	mov    %ebx,%ecx
  80314b:	d3 e8                	shr    %cl,%eax
  80314d:	09 c2                	or     %eax,%edx
  80314f:	89 d0                	mov    %edx,%eax
  803151:	89 ea                	mov    %ebp,%edx
  803153:	f7 f6                	div    %esi
  803155:	89 d5                	mov    %edx,%ebp
  803157:	89 c3                	mov    %eax,%ebx
  803159:	f7 64 24 0c          	mull   0xc(%esp)
  80315d:	39 d5                	cmp    %edx,%ebp
  80315f:	72 10                	jb     803171 <__udivdi3+0xc1>
  803161:	8b 74 24 08          	mov    0x8(%esp),%esi
  803165:	89 f9                	mov    %edi,%ecx
  803167:	d3 e6                	shl    %cl,%esi
  803169:	39 c6                	cmp    %eax,%esi
  80316b:	73 07                	jae    803174 <__udivdi3+0xc4>
  80316d:	39 d5                	cmp    %edx,%ebp
  80316f:	75 03                	jne    803174 <__udivdi3+0xc4>
  803171:	83 eb 01             	sub    $0x1,%ebx
  803174:	31 ff                	xor    %edi,%edi
  803176:	89 d8                	mov    %ebx,%eax
  803178:	89 fa                	mov    %edi,%edx
  80317a:	83 c4 1c             	add    $0x1c,%esp
  80317d:	5b                   	pop    %ebx
  80317e:	5e                   	pop    %esi
  80317f:	5f                   	pop    %edi
  803180:	5d                   	pop    %ebp
  803181:	c3                   	ret    
  803182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803188:	31 ff                	xor    %edi,%edi
  80318a:	31 db                	xor    %ebx,%ebx
  80318c:	89 d8                	mov    %ebx,%eax
  80318e:	89 fa                	mov    %edi,%edx
  803190:	83 c4 1c             	add    $0x1c,%esp
  803193:	5b                   	pop    %ebx
  803194:	5e                   	pop    %esi
  803195:	5f                   	pop    %edi
  803196:	5d                   	pop    %ebp
  803197:	c3                   	ret    
  803198:	90                   	nop
  803199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8031a0:	89 d8                	mov    %ebx,%eax
  8031a2:	f7 f7                	div    %edi
  8031a4:	31 ff                	xor    %edi,%edi
  8031a6:	89 c3                	mov    %eax,%ebx
  8031a8:	89 d8                	mov    %ebx,%eax
  8031aa:	89 fa                	mov    %edi,%edx
  8031ac:	83 c4 1c             	add    $0x1c,%esp
  8031af:	5b                   	pop    %ebx
  8031b0:	5e                   	pop    %esi
  8031b1:	5f                   	pop    %edi
  8031b2:	5d                   	pop    %ebp
  8031b3:	c3                   	ret    
  8031b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8031b8:	39 ce                	cmp    %ecx,%esi
  8031ba:	72 0c                	jb     8031c8 <__udivdi3+0x118>
  8031bc:	31 db                	xor    %ebx,%ebx
  8031be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8031c2:	0f 87 34 ff ff ff    	ja     8030fc <__udivdi3+0x4c>
  8031c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8031cd:	e9 2a ff ff ff       	jmp    8030fc <__udivdi3+0x4c>
  8031d2:	66 90                	xchg   %ax,%ax
  8031d4:	66 90                	xchg   %ax,%ax
  8031d6:	66 90                	xchg   %ax,%ax
  8031d8:	66 90                	xchg   %ax,%ax
  8031da:	66 90                	xchg   %ax,%ax
  8031dc:	66 90                	xchg   %ax,%ax
  8031de:	66 90                	xchg   %ax,%ax

008031e0 <__umoddi3>:
  8031e0:	55                   	push   %ebp
  8031e1:	57                   	push   %edi
  8031e2:	56                   	push   %esi
  8031e3:	53                   	push   %ebx
  8031e4:	83 ec 1c             	sub    $0x1c,%esp
  8031e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8031eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8031ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8031f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8031f7:	85 d2                	test   %edx,%edx
  8031f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8031fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803201:	89 f3                	mov    %esi,%ebx
  803203:	89 3c 24             	mov    %edi,(%esp)
  803206:	89 74 24 04          	mov    %esi,0x4(%esp)
  80320a:	75 1c                	jne    803228 <__umoddi3+0x48>
  80320c:	39 f7                	cmp    %esi,%edi
  80320e:	76 50                	jbe    803260 <__umoddi3+0x80>
  803210:	89 c8                	mov    %ecx,%eax
  803212:	89 f2                	mov    %esi,%edx
  803214:	f7 f7                	div    %edi
  803216:	89 d0                	mov    %edx,%eax
  803218:	31 d2                	xor    %edx,%edx
  80321a:	83 c4 1c             	add    $0x1c,%esp
  80321d:	5b                   	pop    %ebx
  80321e:	5e                   	pop    %esi
  80321f:	5f                   	pop    %edi
  803220:	5d                   	pop    %ebp
  803221:	c3                   	ret    
  803222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803228:	39 f2                	cmp    %esi,%edx
  80322a:	89 d0                	mov    %edx,%eax
  80322c:	77 52                	ja     803280 <__umoddi3+0xa0>
  80322e:	0f bd ea             	bsr    %edx,%ebp
  803231:	83 f5 1f             	xor    $0x1f,%ebp
  803234:	75 5a                	jne    803290 <__umoddi3+0xb0>
  803236:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80323a:	0f 82 e0 00 00 00    	jb     803320 <__umoddi3+0x140>
  803240:	39 0c 24             	cmp    %ecx,(%esp)
  803243:	0f 86 d7 00 00 00    	jbe    803320 <__umoddi3+0x140>
  803249:	8b 44 24 08          	mov    0x8(%esp),%eax
  80324d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803251:	83 c4 1c             	add    $0x1c,%esp
  803254:	5b                   	pop    %ebx
  803255:	5e                   	pop    %esi
  803256:	5f                   	pop    %edi
  803257:	5d                   	pop    %ebp
  803258:	c3                   	ret    
  803259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803260:	85 ff                	test   %edi,%edi
  803262:	89 fd                	mov    %edi,%ebp
  803264:	75 0b                	jne    803271 <__umoddi3+0x91>
  803266:	b8 01 00 00 00       	mov    $0x1,%eax
  80326b:	31 d2                	xor    %edx,%edx
  80326d:	f7 f7                	div    %edi
  80326f:	89 c5                	mov    %eax,%ebp
  803271:	89 f0                	mov    %esi,%eax
  803273:	31 d2                	xor    %edx,%edx
  803275:	f7 f5                	div    %ebp
  803277:	89 c8                	mov    %ecx,%eax
  803279:	f7 f5                	div    %ebp
  80327b:	89 d0                	mov    %edx,%eax
  80327d:	eb 99                	jmp    803218 <__umoddi3+0x38>
  80327f:	90                   	nop
  803280:	89 c8                	mov    %ecx,%eax
  803282:	89 f2                	mov    %esi,%edx
  803284:	83 c4 1c             	add    $0x1c,%esp
  803287:	5b                   	pop    %ebx
  803288:	5e                   	pop    %esi
  803289:	5f                   	pop    %edi
  80328a:	5d                   	pop    %ebp
  80328b:	c3                   	ret    
  80328c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803290:	8b 34 24             	mov    (%esp),%esi
  803293:	bf 20 00 00 00       	mov    $0x20,%edi
  803298:	89 e9                	mov    %ebp,%ecx
  80329a:	29 ef                	sub    %ebp,%edi
  80329c:	d3 e0                	shl    %cl,%eax
  80329e:	89 f9                	mov    %edi,%ecx
  8032a0:	89 f2                	mov    %esi,%edx
  8032a2:	d3 ea                	shr    %cl,%edx
  8032a4:	89 e9                	mov    %ebp,%ecx
  8032a6:	09 c2                	or     %eax,%edx
  8032a8:	89 d8                	mov    %ebx,%eax
  8032aa:	89 14 24             	mov    %edx,(%esp)
  8032ad:	89 f2                	mov    %esi,%edx
  8032af:	d3 e2                	shl    %cl,%edx
  8032b1:	89 f9                	mov    %edi,%ecx
  8032b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8032b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8032bb:	d3 e8                	shr    %cl,%eax
  8032bd:	89 e9                	mov    %ebp,%ecx
  8032bf:	89 c6                	mov    %eax,%esi
  8032c1:	d3 e3                	shl    %cl,%ebx
  8032c3:	89 f9                	mov    %edi,%ecx
  8032c5:	89 d0                	mov    %edx,%eax
  8032c7:	d3 e8                	shr    %cl,%eax
  8032c9:	89 e9                	mov    %ebp,%ecx
  8032cb:	09 d8                	or     %ebx,%eax
  8032cd:	89 d3                	mov    %edx,%ebx
  8032cf:	89 f2                	mov    %esi,%edx
  8032d1:	f7 34 24             	divl   (%esp)
  8032d4:	89 d6                	mov    %edx,%esi
  8032d6:	d3 e3                	shl    %cl,%ebx
  8032d8:	f7 64 24 04          	mull   0x4(%esp)
  8032dc:	39 d6                	cmp    %edx,%esi
  8032de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8032e2:	89 d1                	mov    %edx,%ecx
  8032e4:	89 c3                	mov    %eax,%ebx
  8032e6:	72 08                	jb     8032f0 <__umoddi3+0x110>
  8032e8:	75 11                	jne    8032fb <__umoddi3+0x11b>
  8032ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8032ee:	73 0b                	jae    8032fb <__umoddi3+0x11b>
  8032f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8032f4:	1b 14 24             	sbb    (%esp),%edx
  8032f7:	89 d1                	mov    %edx,%ecx
  8032f9:	89 c3                	mov    %eax,%ebx
  8032fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8032ff:	29 da                	sub    %ebx,%edx
  803301:	19 ce                	sbb    %ecx,%esi
  803303:	89 f9                	mov    %edi,%ecx
  803305:	89 f0                	mov    %esi,%eax
  803307:	d3 e0                	shl    %cl,%eax
  803309:	89 e9                	mov    %ebp,%ecx
  80330b:	d3 ea                	shr    %cl,%edx
  80330d:	89 e9                	mov    %ebp,%ecx
  80330f:	d3 ee                	shr    %cl,%esi
  803311:	09 d0                	or     %edx,%eax
  803313:	89 f2                	mov    %esi,%edx
  803315:	83 c4 1c             	add    $0x1c,%esp
  803318:	5b                   	pop    %ebx
  803319:	5e                   	pop    %esi
  80331a:	5f                   	pop    %edi
  80331b:	5d                   	pop    %ebp
  80331c:	c3                   	ret    
  80331d:	8d 76 00             	lea    0x0(%esi),%esi
  803320:	29 f9                	sub    %edi,%ecx
  803322:	19 d6                	sbb    %edx,%esi
  803324:	89 74 24 04          	mov    %esi,0x4(%esp)
  803328:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80332c:	e9 18 ff ff ff       	jmp    803249 <__umoddi3+0x69>
