
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
  800060:	e8 ac 0a 00 00       	call   800b11 <cprintf>
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
  800084:	e8 88 0a 00 00       	call   800b11 <cprintf>
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
  8000b0:	e8 dc 11 00 00       	call   801291 <strchr>
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
  8000dd:	e8 2f 0a 00 00       	call   800b11 <cprintf>
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
  8000fb:	e8 91 11 00 00       	call   801291 <strchr>
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
  80012b:	e8 e1 09 00 00       	call   800b11 <cprintf>
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
  800151:	e8 3b 11 00 00       	call   801291 <strchr>
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
  800180:	e8 8c 09 00 00       	call   800b11 <cprintf>
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
  800278:	e8 94 08 00 00       	call   800b11 <cprintf>
				exit();
  80027d:	e8 9c 07 00 00       	call   800a1e <exit>
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
  8002ac:	e8 60 08 00 00       	call   800b11 <cprintf>
				exit();
  8002b1:	e8 68 07 00 00       	call   800a1e <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 a6 20 00 00       	call   80236c <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
				cprintf("open %s for read: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 99 33 80 00       	push   $0x803399
  8002db:	e8 31 08 00 00       	call   800b11 <cprintf>
				exit();
  8002e0:	e8 39 07 00 00       	call   800a1e <exit>
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
  8002f8:	e8 f8 1a 00 00       	call   801df5 <dup>
				close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 a0 1a 00 00       	call   801da5 <close>
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
  800328:	e8 e4 07 00 00       	call   800b11 <cprintf>
				exit();
  80032d:	e8 ec 06 00 00       	call   800a1e <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 27 20 00 00       	call   80236c <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 ae 33 80 00       	push   $0x8033ae
  80035a:	e8 b2 07 00 00       	call   800b11 <cprintf>
				exit();
  80035f:	e8 ba 06 00 00       	call   800a1e <exit>
  800364:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800367:	83 ff 01             	cmp    $0x1,%edi
  80036a:	0f 84 ba fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	6a 01                	push   $0x1
  800375:	57                   	push   %edi
  800376:	e8 7a 1a 00 00       	call   801df5 <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 22 1a 00 00       	call   801da5 <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 4a 29 00 00       	call   802ce4 <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 c4 33 80 00       	push   $0x8033c4
  8003aa:	e8 62 07 00 00       	call   800b11 <cprintf>
				exit();
  8003af:	e8 6a 06 00 00       	call   800a1e <exit>
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
  8003d4:	e8 38 07 00 00       	call   800b11 <cprintf>
  8003d9:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dc:	e8 b2 14 00 00       	call   801893 <fork>
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 16                	jns    8003fd <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	50                   	push   %eax
  8003eb:	68 da 33 80 00       	push   $0x8033da
  8003f0:	e8 1c 07 00 00       	call   800b11 <cprintf>
				exit();
  8003f5:	e8 24 06 00 00       	call   800a1e <exit>
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
  800411:	e8 df 19 00 00       	call   801df5 <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 81 19 00 00       	call   801da5 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 70 19 00 00       	call   801da5 <close>
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
  80044e:	e8 a2 19 00 00       	call   801df5 <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 44 19 00 00       	call   801da5 <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 33 19 00 00       	call   801da5 <close>
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
  800484:	e8 af 05 00 00       	call   800a38 <_panic>
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
  8004a7:	e8 65 06 00 00       	call   800b11 <cprintf>
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
  8004d4:	e8 b0 0c 00 00       	call   801189 <strcpy>
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
  8004f5:	8b 40 7c             	mov    0x7c(%eax),%eax
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	50                   	push   %eax
  8004fc:	68 18 34 80 00       	push   $0x803418
  800501:	e8 0b 06 00 00       	call   800b11 <cprintf>
  800506:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 11                	jmp    80051f <runcmd+0x316>
			cprintf(" %s", argv[i]);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	50                   	push   %eax
  800512:	68 a0 34 80 00       	push   $0x8034a0
  800517:	e8 f5 05 00 00       	call   800b11 <cprintf>
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
  800531:	e8 db 05 00 00       	call   800b11 <cprintf>
  800536:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 a8             	pushl  -0x58(%ebp)
  800543:	e8 d8 1f 00 00       	call   802520 <spawn>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	0f 89 c3 00 00 00    	jns    800618 <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800555:	83 ec 04             	sub    $0x4,%esp
  800558:	50                   	push   %eax
  800559:	ff 75 a8             	pushl  -0x58(%ebp)
  80055c:	68 26 34 80 00       	push   $0x803426
  800561:	e8 ab 05 00 00       	call   800b11 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800566:	e8 65 18 00 00       	call   801dd0 <close_all>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 4c                	jmp    8005bc <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800570:	a1 24 54 80 00       	mov    0x805424,%eax
  800575:	8b 40 7c             	mov    0x7c(%eax),%eax
  800578:	53                   	push   %ebx
  800579:	ff 75 a8             	pushl  -0x58(%ebp)
  80057c:	50                   	push   %eax
  80057d:	68 34 34 80 00       	push   $0x803434
  800582:	e8 8a 05 00 00       	call   800b11 <cprintf>
  800587:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058a:	83 ec 0c             	sub    $0xc,%esp
  80058d:	53                   	push   %ebx
  80058e:	e8 d7 28 00 00       	call   802e6a <wait>
		if (debug)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059d:	0f 84 8c 00 00 00    	je     80062f <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a3:	a1 24 54 80 00       	mov    0x805424,%eax
  8005a8:	8b 40 7c             	mov    0x7c(%eax),%eax
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	50                   	push   %eax
  8005af:	68 49 34 80 00       	push   $0x803449
  8005b4:	e8 58 05 00 00       	call   800b11 <cprintf>
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
  8005ce:	8b 40 7c             	mov    0x7c(%eax),%eax
  8005d1:	83 ec 04             	sub    $0x4,%esp
  8005d4:	57                   	push   %edi
  8005d5:	50                   	push   %eax
  8005d6:	68 5f 34 80 00       	push   $0x80345f
  8005db:	e8 31 05 00 00       	call   800b11 <cprintf>
  8005e0:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	57                   	push   %edi
  8005e7:	e8 7e 28 00 00       	call   802e6a <wait>
		if (debug)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f6:	74 19                	je     800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f8:	a1 24 54 80 00       	mov    0x805424,%eax
  8005fd:	8b 40 7c             	mov    0x7c(%eax),%eax
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	50                   	push   %eax
  800604:	68 49 34 80 00       	push   $0x803449
  800609:	e8 03 05 00 00       	call   800b11 <cprintf>
  80060e:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800611:	e8 08 04 00 00       	call   800a1e <exit>
  800616:	eb 1d                	jmp    800635 <runcmd+0x42c>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800618:	e8 b3 17 00 00       	call   801dd0 <close_all>
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
  800648:	e8 c4 04 00 00       	call   800b11 <cprintf>
	exit();
  80064d:	e8 cc 03 00 00       	call   800a1e <exit>
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
  80066c:	e8 40 14 00 00       	call   801ab1 <argstart>
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
  8006b8:	e8 24 14 00 00       	call   801ae1 <argnext>
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
  8006da:	e8 c6 16 00 00       	call   801da5 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	6a 00                	push   $0x0
  8006e4:	ff 77 04             	pushl  0x4(%edi)
  8006e7:	e8 80 1c 00 00       	call   80236c <open>
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
  800709:	e8 2a 03 00 00       	call   800a38 <_panic>
		assert(r == 0);
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 19                	je     80072b <umain+0xd4>
  800712:	68 88 34 80 00       	push   $0x803488
  800717:	68 8f 34 80 00       	push   $0x80348f
  80071c:	68 2a 01 00 00       	push   $0x12a
  800721:	68 ff 33 80 00       	push   $0x8033ff
  800726:	e8 0d 03 00 00       	call   800a38 <_panic>
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
  800752:	e8 06 09 00 00       	call   80105d <readline>
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
  800771:	e8 9b 03 00 00       	call   800b11 <cprintf>
  800776:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800779:	e8 a0 02 00 00       	call   800a1e <exit>
		}
		if (debug)
  80077e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800785:	74 11                	je     800798 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	68 b0 34 80 00       	push   $0x8034b0
  800790:	e8 7c 03 00 00       	call   800b11 <cprintf>
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
  8007ac:	e8 59 1d 00 00       	call   80250a <printf>
  8007b1:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bb:	74 10                	je     8007cd <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	68 c0 34 80 00       	push   $0x8034c0
  8007c5:	e8 47 03 00 00       	call   800b11 <cprintf>
  8007ca:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cd:	e8 c1 10 00 00       	call   801893 <fork>
  8007d2:	89 c6                	mov    %eax,%esi
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	79 15                	jns    8007ed <umain+0x196>
			panic("fork: %e", r);
  8007d8:	50                   	push   %eax
  8007d9:	68 da 33 80 00       	push   $0x8033da
  8007de:	68 41 01 00 00       	push   $0x141
  8007e3:	68 ff 33 80 00       	push   $0x8033ff
  8007e8:	e8 4b 02 00 00       	call   800a38 <_panic>
		if (debug)
  8007ed:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f4:	74 11                	je     800807 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	50                   	push   %eax
  8007fa:	68 cd 34 80 00       	push   $0x8034cd
  8007ff:	e8 0d 03 00 00       	call   800b11 <cprintf>
  800804:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800807:	85 f6                	test   %esi,%esi
  800809:	75 16                	jne    800821 <umain+0x1ca>
			runcmd(buf);
  80080b:	83 ec 0c             	sub    $0xc,%esp
  80080e:	53                   	push   %ebx
  80080f:	e8 f5 f9 ff ff       	call   800209 <runcmd>
			exit();
  800814:	e8 05 02 00 00       	call   800a1e <exit>
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	e9 2d ff ff ff       	jmp    80074e <umain+0xf7>
		} else
			wait(r);
  800821:	83 ec 0c             	sub    $0xc,%esp
  800824:	56                   	push   %esi
  800825:	e8 40 26 00 00       	call   802e6a <wait>
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
  80084a:	e8 3a 09 00 00       	call   801189 <strcpy>
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
  800888:	e8 8e 0a 00 00       	call   80131b <memmove>
		sys_cputs(buf, m);
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	57                   	push   %edi
  800892:	e8 39 0c 00 00       	call   8014d0 <sys_cputs>
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
  8008be:	e8 aa 0c 00 00       	call   80156d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c3:	e8 26 0c 00 00       	call   8014ee <sys_cgetc>
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
  8008fa:	e8 d1 0b 00 00       	call   8014d0 <sys_cputs>
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
  800912:	e8 ca 15 00 00       	call   801ee1 <read>
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
  80093c:	e8 3a 13 00 00       	call   801c7b <fd_lookup>
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
  800965:	e8 c2 12 00 00       	call   801c2c <fd_alloc>
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
  800980:	e8 07 0c 00 00       	call   80158c <sys_page_alloc>
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
  8009a7:	e8 59 12 00 00       	call   801c05 <fd2num>
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
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8009c0:	e8 89 0b 00 00       	call   80154e <sys_getenvid>
  8009c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009ca:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8009d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009d5:	a3 24 54 80 00       	mov    %eax,0x805424
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009da:	85 db                	test   %ebx,%ebx
  8009dc:	7e 07                	jle    8009e5 <libmain+0x30>
		binaryname = argv[0];
  8009de:	8b 06                	mov    (%esi),%eax
  8009e0:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009e5:	83 ec 08             	sub    $0x8,%esp
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	e8 68 fc ff ff       	call   800657 <umain>

	// exit gracefully
	exit();
  8009ef:	e8 2a 00 00 00       	call   800a1e <exit>
}
  8009f4:	83 c4 10             	add    $0x10,%esp
  8009f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800a04:	a1 28 54 80 00       	mov    0x805428,%eax
	func();
  800a09:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800a0b:	e8 3e 0b 00 00       	call   80154e <sys_getenvid>
  800a10:	83 ec 0c             	sub    $0xc,%esp
  800a13:	50                   	push   %eax
  800a14:	e8 84 0d 00 00       	call   80179d <sys_thread_free>
}
  800a19:	83 c4 10             	add    $0x10,%esp
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a24:	e8 a7 13 00 00       	call   801dd0 <close_all>
	sys_env_destroy(0);
  800a29:	83 ec 0c             	sub    $0xc,%esp
  800a2c:	6a 00                	push   $0x0
  800a2e:	e8 da 0a 00 00       	call   80150d <sys_env_destroy>
}
  800a33:	83 c4 10             	add    $0x10,%esp
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a3d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a40:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a46:	e8 03 0b 00 00       	call   80154e <sys_getenvid>
  800a4b:	83 ec 0c             	sub    $0xc,%esp
  800a4e:	ff 75 0c             	pushl  0xc(%ebp)
  800a51:	ff 75 08             	pushl  0x8(%ebp)
  800a54:	56                   	push   %esi
  800a55:	50                   	push   %eax
  800a56:	68 60 35 80 00       	push   $0x803560
  800a5b:	e8 b1 00 00 00       	call   800b11 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a60:	83 c4 18             	add    $0x18,%esp
  800a63:	53                   	push   %ebx
  800a64:	ff 75 10             	pushl  0x10(%ebp)
  800a67:	e8 54 00 00 00       	call   800ac0 <vcprintf>
	cprintf("\n");
  800a6c:	c7 04 24 60 33 80 00 	movl   $0x803360,(%esp)
  800a73:	e8 99 00 00 00       	call   800b11 <cprintf>
  800a78:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a7b:	cc                   	int3   
  800a7c:	eb fd                	jmp    800a7b <_panic+0x43>

00800a7e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	53                   	push   %ebx
  800a82:	83 ec 04             	sub    $0x4,%esp
  800a85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a88:	8b 13                	mov    (%ebx),%edx
  800a8a:	8d 42 01             	lea    0x1(%edx),%eax
  800a8d:	89 03                	mov    %eax,(%ebx)
  800a8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a92:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a96:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a9b:	75 1a                	jne    800ab7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a9d:	83 ec 08             	sub    $0x8,%esp
  800aa0:	68 ff 00 00 00       	push   $0xff
  800aa5:	8d 43 08             	lea    0x8(%ebx),%eax
  800aa8:	50                   	push   %eax
  800aa9:	e8 22 0a 00 00       	call   8014d0 <sys_cputs>
		b->idx = 0;
  800aae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800ab4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800ab7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800abb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800abe:	c9                   	leave  
  800abf:	c3                   	ret    

00800ac0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800ac9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800ad0:	00 00 00 
	b.cnt = 0;
  800ad3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ada:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800add:	ff 75 0c             	pushl  0xc(%ebp)
  800ae0:	ff 75 08             	pushl  0x8(%ebp)
  800ae3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ae9:	50                   	push   %eax
  800aea:	68 7e 0a 80 00       	push   $0x800a7e
  800aef:	e8 54 01 00 00       	call   800c48 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800af4:	83 c4 08             	add    $0x8,%esp
  800af7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800afd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b03:	50                   	push   %eax
  800b04:	e8 c7 09 00 00       	call   8014d0 <sys_cputs>

	return b.cnt;
}
  800b09:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b0f:	c9                   	leave  
  800b10:	c3                   	ret    

00800b11 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b17:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b1a:	50                   	push   %eax
  800b1b:	ff 75 08             	pushl  0x8(%ebp)
  800b1e:	e8 9d ff ff ff       	call   800ac0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800b23:	c9                   	leave  
  800b24:	c3                   	ret    

00800b25 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	83 ec 1c             	sub    $0x1c,%esp
  800b2e:	89 c7                	mov    %eax,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	8b 45 08             	mov    0x8(%ebp),%eax
  800b35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b38:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b3b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b46:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b49:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b4c:	39 d3                	cmp    %edx,%ebx
  800b4e:	72 05                	jb     800b55 <printnum+0x30>
  800b50:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b53:	77 45                	ja     800b9a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b55:	83 ec 0c             	sub    $0xc,%esp
  800b58:	ff 75 18             	pushl  0x18(%ebp)
  800b5b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b61:	53                   	push   %ebx
  800b62:	ff 75 10             	pushl  0x10(%ebp)
  800b65:	83 ec 08             	sub    $0x8,%esp
  800b68:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b6b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b6e:	ff 75 dc             	pushl  -0x24(%ebp)
  800b71:	ff 75 d8             	pushl  -0x28(%ebp)
  800b74:	e8 37 25 00 00       	call   8030b0 <__udivdi3>
  800b79:	83 c4 18             	add    $0x18,%esp
  800b7c:	52                   	push   %edx
  800b7d:	50                   	push   %eax
  800b7e:	89 f2                	mov    %esi,%edx
  800b80:	89 f8                	mov    %edi,%eax
  800b82:	e8 9e ff ff ff       	call   800b25 <printnum>
  800b87:	83 c4 20             	add    $0x20,%esp
  800b8a:	eb 18                	jmp    800ba4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b8c:	83 ec 08             	sub    $0x8,%esp
  800b8f:	56                   	push   %esi
  800b90:	ff 75 18             	pushl  0x18(%ebp)
  800b93:	ff d7                	call   *%edi
  800b95:	83 c4 10             	add    $0x10,%esp
  800b98:	eb 03                	jmp    800b9d <printnum+0x78>
  800b9a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b9d:	83 eb 01             	sub    $0x1,%ebx
  800ba0:	85 db                	test   %ebx,%ebx
  800ba2:	7f e8                	jg     800b8c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800ba4:	83 ec 08             	sub    $0x8,%esp
  800ba7:	56                   	push   %esi
  800ba8:	83 ec 04             	sub    $0x4,%esp
  800bab:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bae:	ff 75 e0             	pushl  -0x20(%ebp)
  800bb1:	ff 75 dc             	pushl  -0x24(%ebp)
  800bb4:	ff 75 d8             	pushl  -0x28(%ebp)
  800bb7:	e8 24 26 00 00       	call   8031e0 <__umoddi3>
  800bbc:	83 c4 14             	add    $0x14,%esp
  800bbf:	0f be 80 83 35 80 00 	movsbl 0x803583(%eax),%eax
  800bc6:	50                   	push   %eax
  800bc7:	ff d7                	call   *%edi
}
  800bc9:	83 c4 10             	add    $0x10,%esp
  800bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bd7:	83 fa 01             	cmp    $0x1,%edx
  800bda:	7e 0e                	jle    800bea <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bdc:	8b 10                	mov    (%eax),%edx
  800bde:	8d 4a 08             	lea    0x8(%edx),%ecx
  800be1:	89 08                	mov    %ecx,(%eax)
  800be3:	8b 02                	mov    (%edx),%eax
  800be5:	8b 52 04             	mov    0x4(%edx),%edx
  800be8:	eb 22                	jmp    800c0c <getuint+0x38>
	else if (lflag)
  800bea:	85 d2                	test   %edx,%edx
  800bec:	74 10                	je     800bfe <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bee:	8b 10                	mov    (%eax),%edx
  800bf0:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bf3:	89 08                	mov    %ecx,(%eax)
  800bf5:	8b 02                	mov    (%edx),%eax
  800bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfc:	eb 0e                	jmp    800c0c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bfe:	8b 10                	mov    (%eax),%edx
  800c00:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c03:	89 08                	mov    %ecx,(%eax)
  800c05:	8b 02                	mov    (%edx),%eax
  800c07:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c14:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800c18:	8b 10                	mov    (%eax),%edx
  800c1a:	3b 50 04             	cmp    0x4(%eax),%edx
  800c1d:	73 0a                	jae    800c29 <sprintputch+0x1b>
		*b->buf++ = ch;
  800c1f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c22:	89 08                	mov    %ecx,(%eax)
  800c24:	8b 45 08             	mov    0x8(%ebp),%eax
  800c27:	88 02                	mov    %al,(%edx)
}
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c31:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c34:	50                   	push   %eax
  800c35:	ff 75 10             	pushl  0x10(%ebp)
  800c38:	ff 75 0c             	pushl  0xc(%ebp)
  800c3b:	ff 75 08             	pushl  0x8(%ebp)
  800c3e:	e8 05 00 00 00       	call   800c48 <vprintfmt>
	va_end(ap);
}
  800c43:	83 c4 10             	add    $0x10,%esp
  800c46:	c9                   	leave  
  800c47:	c3                   	ret    

00800c48 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 2c             	sub    $0x2c,%esp
  800c51:	8b 75 08             	mov    0x8(%ebp),%esi
  800c54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c57:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c5a:	eb 12                	jmp    800c6e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	0f 84 89 03 00 00    	je     800fed <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800c64:	83 ec 08             	sub    $0x8,%esp
  800c67:	53                   	push   %ebx
  800c68:	50                   	push   %eax
  800c69:	ff d6                	call   *%esi
  800c6b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c6e:	83 c7 01             	add    $0x1,%edi
  800c71:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c75:	83 f8 25             	cmp    $0x25,%eax
  800c78:	75 e2                	jne    800c5c <vprintfmt+0x14>
  800c7a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c7e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c85:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c8c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c93:	ba 00 00 00 00       	mov    $0x0,%edx
  800c98:	eb 07                	jmp    800ca1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c9d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca1:	8d 47 01             	lea    0x1(%edi),%eax
  800ca4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ca7:	0f b6 07             	movzbl (%edi),%eax
  800caa:	0f b6 c8             	movzbl %al,%ecx
  800cad:	83 e8 23             	sub    $0x23,%eax
  800cb0:	3c 55                	cmp    $0x55,%al
  800cb2:	0f 87 1a 03 00 00    	ja     800fd2 <vprintfmt+0x38a>
  800cb8:	0f b6 c0             	movzbl %al,%eax
  800cbb:	ff 24 85 c0 36 80 00 	jmp    *0x8036c0(,%eax,4)
  800cc2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800cc5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800cc9:	eb d6                	jmp    800ca1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ccb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cce:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cd6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cd9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800cdd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800ce0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800ce3:	83 fa 09             	cmp    $0x9,%edx
  800ce6:	77 39                	ja     800d21 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800ce8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800ceb:	eb e9                	jmp    800cd6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800ced:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf0:	8d 48 04             	lea    0x4(%eax),%ecx
  800cf3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800cf6:	8b 00                	mov    (%eax),%eax
  800cf8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cfb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800cfe:	eb 27                	jmp    800d27 <vprintfmt+0xdf>
  800d00:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d03:	85 c0                	test   %eax,%eax
  800d05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d0a:	0f 49 c8             	cmovns %eax,%ecx
  800d0d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d10:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d13:	eb 8c                	jmp    800ca1 <vprintfmt+0x59>
  800d15:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d18:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800d1f:	eb 80                	jmp    800ca1 <vprintfmt+0x59>
  800d21:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d24:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800d27:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d2b:	0f 89 70 ff ff ff    	jns    800ca1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800d31:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d34:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d37:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d3e:	e9 5e ff ff ff       	jmp    800ca1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d43:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d46:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d49:	e9 53 ff ff ff       	jmp    800ca1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d4e:	8b 45 14             	mov    0x14(%ebp),%eax
  800d51:	8d 50 04             	lea    0x4(%eax),%edx
  800d54:	89 55 14             	mov    %edx,0x14(%ebp)
  800d57:	83 ec 08             	sub    $0x8,%esp
  800d5a:	53                   	push   %ebx
  800d5b:	ff 30                	pushl  (%eax)
  800d5d:	ff d6                	call   *%esi
			break;
  800d5f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d65:	e9 04 ff ff ff       	jmp    800c6e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d6a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d6d:	8d 50 04             	lea    0x4(%eax),%edx
  800d70:	89 55 14             	mov    %edx,0x14(%ebp)
  800d73:	8b 00                	mov    (%eax),%eax
  800d75:	99                   	cltd   
  800d76:	31 d0                	xor    %edx,%eax
  800d78:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d7a:	83 f8 0f             	cmp    $0xf,%eax
  800d7d:	7f 0b                	jg     800d8a <vprintfmt+0x142>
  800d7f:	8b 14 85 20 38 80 00 	mov    0x803820(,%eax,4),%edx
  800d86:	85 d2                	test   %edx,%edx
  800d88:	75 18                	jne    800da2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d8a:	50                   	push   %eax
  800d8b:	68 9b 35 80 00       	push   $0x80359b
  800d90:	53                   	push   %ebx
  800d91:	56                   	push   %esi
  800d92:	e8 94 fe ff ff       	call   800c2b <printfmt>
  800d97:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d9d:	e9 cc fe ff ff       	jmp    800c6e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800da2:	52                   	push   %edx
  800da3:	68 a1 34 80 00       	push   $0x8034a1
  800da8:	53                   	push   %ebx
  800da9:	56                   	push   %esi
  800daa:	e8 7c fe ff ff       	call   800c2b <printfmt>
  800daf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800db2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800db5:	e9 b4 fe ff ff       	jmp    800c6e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800dba:	8b 45 14             	mov    0x14(%ebp),%eax
  800dbd:	8d 50 04             	lea    0x4(%eax),%edx
  800dc0:	89 55 14             	mov    %edx,0x14(%ebp)
  800dc3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800dc5:	85 ff                	test   %edi,%edi
  800dc7:	b8 94 35 80 00       	mov    $0x803594,%eax
  800dcc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800dcf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dd3:	0f 8e 94 00 00 00    	jle    800e6d <vprintfmt+0x225>
  800dd9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800ddd:	0f 84 98 00 00 00    	je     800e7b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800de3:	83 ec 08             	sub    $0x8,%esp
  800de6:	ff 75 d0             	pushl  -0x30(%ebp)
  800de9:	57                   	push   %edi
  800dea:	e8 79 03 00 00       	call   801168 <strnlen>
  800def:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800df2:	29 c1                	sub    %eax,%ecx
  800df4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800df7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800dfa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800dfe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e01:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e04:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e06:	eb 0f                	jmp    800e17 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800e08:	83 ec 08             	sub    $0x8,%esp
  800e0b:	53                   	push   %ebx
  800e0c:	ff 75 e0             	pushl  -0x20(%ebp)
  800e0f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e11:	83 ef 01             	sub    $0x1,%edi
  800e14:	83 c4 10             	add    $0x10,%esp
  800e17:	85 ff                	test   %edi,%edi
  800e19:	7f ed                	jg     800e08 <vprintfmt+0x1c0>
  800e1b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800e1e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800e21:	85 c9                	test   %ecx,%ecx
  800e23:	b8 00 00 00 00       	mov    $0x0,%eax
  800e28:	0f 49 c1             	cmovns %ecx,%eax
  800e2b:	29 c1                	sub    %eax,%ecx
  800e2d:	89 75 08             	mov    %esi,0x8(%ebp)
  800e30:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e33:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e36:	89 cb                	mov    %ecx,%ebx
  800e38:	eb 4d                	jmp    800e87 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e3a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e3e:	74 1b                	je     800e5b <vprintfmt+0x213>
  800e40:	0f be c0             	movsbl %al,%eax
  800e43:	83 e8 20             	sub    $0x20,%eax
  800e46:	83 f8 5e             	cmp    $0x5e,%eax
  800e49:	76 10                	jbe    800e5b <vprintfmt+0x213>
					putch('?', putdat);
  800e4b:	83 ec 08             	sub    $0x8,%esp
  800e4e:	ff 75 0c             	pushl  0xc(%ebp)
  800e51:	6a 3f                	push   $0x3f
  800e53:	ff 55 08             	call   *0x8(%ebp)
  800e56:	83 c4 10             	add    $0x10,%esp
  800e59:	eb 0d                	jmp    800e68 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800e5b:	83 ec 08             	sub    $0x8,%esp
  800e5e:	ff 75 0c             	pushl  0xc(%ebp)
  800e61:	52                   	push   %edx
  800e62:	ff 55 08             	call   *0x8(%ebp)
  800e65:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e68:	83 eb 01             	sub    $0x1,%ebx
  800e6b:	eb 1a                	jmp    800e87 <vprintfmt+0x23f>
  800e6d:	89 75 08             	mov    %esi,0x8(%ebp)
  800e70:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e73:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e76:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e79:	eb 0c                	jmp    800e87 <vprintfmt+0x23f>
  800e7b:	89 75 08             	mov    %esi,0x8(%ebp)
  800e7e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e81:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e84:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e87:	83 c7 01             	add    $0x1,%edi
  800e8a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e8e:	0f be d0             	movsbl %al,%edx
  800e91:	85 d2                	test   %edx,%edx
  800e93:	74 23                	je     800eb8 <vprintfmt+0x270>
  800e95:	85 f6                	test   %esi,%esi
  800e97:	78 a1                	js     800e3a <vprintfmt+0x1f2>
  800e99:	83 ee 01             	sub    $0x1,%esi
  800e9c:	79 9c                	jns    800e3a <vprintfmt+0x1f2>
  800e9e:	89 df                	mov    %ebx,%edi
  800ea0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ea6:	eb 18                	jmp    800ec0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	53                   	push   %ebx
  800eac:	6a 20                	push   $0x20
  800eae:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800eb0:	83 ef 01             	sub    $0x1,%edi
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	eb 08                	jmp    800ec0 <vprintfmt+0x278>
  800eb8:	89 df                	mov    %ebx,%edi
  800eba:	8b 75 08             	mov    0x8(%ebp),%esi
  800ebd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ec0:	85 ff                	test   %edi,%edi
  800ec2:	7f e4                	jg     800ea8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ec4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ec7:	e9 a2 fd ff ff       	jmp    800c6e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ecc:	83 fa 01             	cmp    $0x1,%edx
  800ecf:	7e 16                	jle    800ee7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800ed1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ed4:	8d 50 08             	lea    0x8(%eax),%edx
  800ed7:	89 55 14             	mov    %edx,0x14(%ebp)
  800eda:	8b 50 04             	mov    0x4(%eax),%edx
  800edd:	8b 00                	mov    (%eax),%eax
  800edf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ee2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ee5:	eb 32                	jmp    800f19 <vprintfmt+0x2d1>
	else if (lflag)
  800ee7:	85 d2                	test   %edx,%edx
  800ee9:	74 18                	je     800f03 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800eeb:	8b 45 14             	mov    0x14(%ebp),%eax
  800eee:	8d 50 04             	lea    0x4(%eax),%edx
  800ef1:	89 55 14             	mov    %edx,0x14(%ebp)
  800ef4:	8b 00                	mov    (%eax),%eax
  800ef6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ef9:	89 c1                	mov    %eax,%ecx
  800efb:	c1 f9 1f             	sar    $0x1f,%ecx
  800efe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800f01:	eb 16                	jmp    800f19 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800f03:	8b 45 14             	mov    0x14(%ebp),%eax
  800f06:	8d 50 04             	lea    0x4(%eax),%edx
  800f09:	89 55 14             	mov    %edx,0x14(%ebp)
  800f0c:	8b 00                	mov    (%eax),%eax
  800f0e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f11:	89 c1                	mov    %eax,%ecx
  800f13:	c1 f9 1f             	sar    $0x1f,%ecx
  800f16:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800f19:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f1c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f1f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f24:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f28:	79 74                	jns    800f9e <vprintfmt+0x356>
				putch('-', putdat);
  800f2a:	83 ec 08             	sub    $0x8,%esp
  800f2d:	53                   	push   %ebx
  800f2e:	6a 2d                	push   $0x2d
  800f30:	ff d6                	call   *%esi
				num = -(long long) num;
  800f32:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f35:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f38:	f7 d8                	neg    %eax
  800f3a:	83 d2 00             	adc    $0x0,%edx
  800f3d:	f7 da                	neg    %edx
  800f3f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f42:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f47:	eb 55                	jmp    800f9e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f49:	8d 45 14             	lea    0x14(%ebp),%eax
  800f4c:	e8 83 fc ff ff       	call   800bd4 <getuint>
			base = 10;
  800f51:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f56:	eb 46                	jmp    800f9e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800f58:	8d 45 14             	lea    0x14(%ebp),%eax
  800f5b:	e8 74 fc ff ff       	call   800bd4 <getuint>
			base = 8;
  800f60:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800f65:	eb 37                	jmp    800f9e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800f67:	83 ec 08             	sub    $0x8,%esp
  800f6a:	53                   	push   %ebx
  800f6b:	6a 30                	push   $0x30
  800f6d:	ff d6                	call   *%esi
			putch('x', putdat);
  800f6f:	83 c4 08             	add    $0x8,%esp
  800f72:	53                   	push   %ebx
  800f73:	6a 78                	push   $0x78
  800f75:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f77:	8b 45 14             	mov    0x14(%ebp),%eax
  800f7a:	8d 50 04             	lea    0x4(%eax),%edx
  800f7d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f80:	8b 00                	mov    (%eax),%eax
  800f82:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f87:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f8a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f8f:	eb 0d                	jmp    800f9e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f91:	8d 45 14             	lea    0x14(%ebp),%eax
  800f94:	e8 3b fc ff ff       	call   800bd4 <getuint>
			base = 16;
  800f99:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f9e:	83 ec 0c             	sub    $0xc,%esp
  800fa1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800fa5:	57                   	push   %edi
  800fa6:	ff 75 e0             	pushl  -0x20(%ebp)
  800fa9:	51                   	push   %ecx
  800faa:	52                   	push   %edx
  800fab:	50                   	push   %eax
  800fac:	89 da                	mov    %ebx,%edx
  800fae:	89 f0                	mov    %esi,%eax
  800fb0:	e8 70 fb ff ff       	call   800b25 <printnum>
			break;
  800fb5:	83 c4 20             	add    $0x20,%esp
  800fb8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fbb:	e9 ae fc ff ff       	jmp    800c6e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fc0:	83 ec 08             	sub    $0x8,%esp
  800fc3:	53                   	push   %ebx
  800fc4:	51                   	push   %ecx
  800fc5:	ff d6                	call   *%esi
			break;
  800fc7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fcd:	e9 9c fc ff ff       	jmp    800c6e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fd2:	83 ec 08             	sub    $0x8,%esp
  800fd5:	53                   	push   %ebx
  800fd6:	6a 25                	push   $0x25
  800fd8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fda:	83 c4 10             	add    $0x10,%esp
  800fdd:	eb 03                	jmp    800fe2 <vprintfmt+0x39a>
  800fdf:	83 ef 01             	sub    $0x1,%edi
  800fe2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800fe6:	75 f7                	jne    800fdf <vprintfmt+0x397>
  800fe8:	e9 81 fc ff ff       	jmp    800c6e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800fed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 18             	sub    $0x18,%esp
  800ffb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801001:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801004:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801008:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80100b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801012:	85 c0                	test   %eax,%eax
  801014:	74 26                	je     80103c <vsnprintf+0x47>
  801016:	85 d2                	test   %edx,%edx
  801018:	7e 22                	jle    80103c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80101a:	ff 75 14             	pushl  0x14(%ebp)
  80101d:	ff 75 10             	pushl  0x10(%ebp)
  801020:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801023:	50                   	push   %eax
  801024:	68 0e 0c 80 00       	push   $0x800c0e
  801029:	e8 1a fc ff ff       	call   800c48 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80102e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801031:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801034:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	eb 05                	jmp    801041 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80103c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801041:	c9                   	leave  
  801042:	c3                   	ret    

00801043 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801049:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80104c:	50                   	push   %eax
  80104d:	ff 75 10             	pushl  0x10(%ebp)
  801050:	ff 75 0c             	pushl  0xc(%ebp)
  801053:	ff 75 08             	pushl  0x8(%ebp)
  801056:	e8 9a ff ff ff       	call   800ff5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80105b:	c9                   	leave  
  80105c:	c3                   	ret    

0080105d <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	57                   	push   %edi
  801061:	56                   	push   %esi
  801062:	53                   	push   %ebx
  801063:	83 ec 0c             	sub    $0xc,%esp
  801066:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801069:	85 c0                	test   %eax,%eax
  80106b:	74 13                	je     801080 <readline+0x23>
		fprintf(1, "%s", prompt);
  80106d:	83 ec 04             	sub    $0x4,%esp
  801070:	50                   	push   %eax
  801071:	68 a1 34 80 00       	push   $0x8034a1
  801076:	6a 01                	push   $0x1
  801078:	e8 76 14 00 00       	call   8024f3 <fprintf>
  80107d:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  801080:	83 ec 0c             	sub    $0xc,%esp
  801083:	6a 00                	push   $0x0
  801085:	e8 a5 f8 ff ff       	call   80092f <iscons>
  80108a:	89 c7                	mov    %eax,%edi
  80108c:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  80108f:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  801094:	e8 6b f8 ff ff       	call   800904 <getchar>
  801099:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80109b:	85 c0                	test   %eax,%eax
  80109d:	79 29                	jns    8010c8 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80109f:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  8010a4:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8010a7:	0f 84 9b 00 00 00    	je     801148 <readline+0xeb>
				cprintf("read error: %e\n", c);
  8010ad:	83 ec 08             	sub    $0x8,%esp
  8010b0:	53                   	push   %ebx
  8010b1:	68 7f 38 80 00       	push   $0x80387f
  8010b6:	e8 56 fa ff ff       	call   800b11 <cprintf>
  8010bb:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8010be:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c3:	e9 80 00 00 00       	jmp    801148 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010c8:	83 f8 08             	cmp    $0x8,%eax
  8010cb:	0f 94 c2             	sete   %dl
  8010ce:	83 f8 7f             	cmp    $0x7f,%eax
  8010d1:	0f 94 c0             	sete   %al
  8010d4:	08 c2                	or     %al,%dl
  8010d6:	74 1a                	je     8010f2 <readline+0x95>
  8010d8:	85 f6                	test   %esi,%esi
  8010da:	7e 16                	jle    8010f2 <readline+0x95>
			if (echoing)
  8010dc:	85 ff                	test   %edi,%edi
  8010de:	74 0d                	je     8010ed <readline+0x90>
				cputchar('\b');
  8010e0:	83 ec 0c             	sub    $0xc,%esp
  8010e3:	6a 08                	push   $0x8
  8010e5:	e8 fe f7 ff ff       	call   8008e8 <cputchar>
  8010ea:	83 c4 10             	add    $0x10,%esp
			i--;
  8010ed:	83 ee 01             	sub    $0x1,%esi
  8010f0:	eb a2                	jmp    801094 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010f2:	83 fb 1f             	cmp    $0x1f,%ebx
  8010f5:	7e 26                	jle    80111d <readline+0xc0>
  8010f7:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010fd:	7f 1e                	jg     80111d <readline+0xc0>
			if (echoing)
  8010ff:	85 ff                	test   %edi,%edi
  801101:	74 0c                	je     80110f <readline+0xb2>
				cputchar(c);
  801103:	83 ec 0c             	sub    $0xc,%esp
  801106:	53                   	push   %ebx
  801107:	e8 dc f7 ff ff       	call   8008e8 <cputchar>
  80110c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  80110f:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801115:	8d 76 01             	lea    0x1(%esi),%esi
  801118:	e9 77 ff ff ff       	jmp    801094 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  80111d:	83 fb 0a             	cmp    $0xa,%ebx
  801120:	74 09                	je     80112b <readline+0xce>
  801122:	83 fb 0d             	cmp    $0xd,%ebx
  801125:	0f 85 69 ff ff ff    	jne    801094 <readline+0x37>
			if (echoing)
  80112b:	85 ff                	test   %edi,%edi
  80112d:	74 0d                	je     80113c <readline+0xdf>
				cputchar('\n');
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	6a 0a                	push   $0xa
  801134:	e8 af f7 ff ff       	call   8008e8 <cputchar>
  801139:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  80113c:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  801143:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  801148:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114b:	5b                   	pop    %ebx
  80114c:	5e                   	pop    %esi
  80114d:	5f                   	pop    %edi
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    

00801150 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801156:	b8 00 00 00 00       	mov    $0x0,%eax
  80115b:	eb 03                	jmp    801160 <strlen+0x10>
		n++;
  80115d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801160:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801164:	75 f7                	jne    80115d <strlen+0xd>
		n++;
	return n;
}
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801171:	ba 00 00 00 00       	mov    $0x0,%edx
  801176:	eb 03                	jmp    80117b <strnlen+0x13>
		n++;
  801178:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80117b:	39 c2                	cmp    %eax,%edx
  80117d:	74 08                	je     801187 <strnlen+0x1f>
  80117f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801183:	75 f3                	jne    801178 <strnlen+0x10>
  801185:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    

00801189 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	53                   	push   %ebx
  80118d:	8b 45 08             	mov    0x8(%ebp),%eax
  801190:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801193:	89 c2                	mov    %eax,%edx
  801195:	83 c2 01             	add    $0x1,%edx
  801198:	83 c1 01             	add    $0x1,%ecx
  80119b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80119f:	88 5a ff             	mov    %bl,-0x1(%edx)
  8011a2:	84 db                	test   %bl,%bl
  8011a4:	75 ef                	jne    801195 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8011a6:	5b                   	pop    %ebx
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	53                   	push   %ebx
  8011ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011b0:	53                   	push   %ebx
  8011b1:	e8 9a ff ff ff       	call   801150 <strlen>
  8011b6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8011b9:	ff 75 0c             	pushl  0xc(%ebp)
  8011bc:	01 d8                	add    %ebx,%eax
  8011be:	50                   	push   %eax
  8011bf:	e8 c5 ff ff ff       	call   801189 <strcpy>
	return dst;
}
  8011c4:	89 d8                	mov    %ebx,%eax
  8011c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c9:	c9                   	leave  
  8011ca:	c3                   	ret    

008011cb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	56                   	push   %esi
  8011cf:	53                   	push   %ebx
  8011d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d6:	89 f3                	mov    %esi,%ebx
  8011d8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011db:	89 f2                	mov    %esi,%edx
  8011dd:	eb 0f                	jmp    8011ee <strncpy+0x23>
		*dst++ = *src;
  8011df:	83 c2 01             	add    $0x1,%edx
  8011e2:	0f b6 01             	movzbl (%ecx),%eax
  8011e5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011e8:	80 39 01             	cmpb   $0x1,(%ecx)
  8011eb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011ee:	39 da                	cmp    %ebx,%edx
  8011f0:	75 ed                	jne    8011df <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011f2:	89 f0                	mov    %esi,%eax
  8011f4:	5b                   	pop    %ebx
  8011f5:	5e                   	pop    %esi
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	56                   	push   %esi
  8011fc:	53                   	push   %ebx
  8011fd:	8b 75 08             	mov    0x8(%ebp),%esi
  801200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801203:	8b 55 10             	mov    0x10(%ebp),%edx
  801206:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801208:	85 d2                	test   %edx,%edx
  80120a:	74 21                	je     80122d <strlcpy+0x35>
  80120c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801210:	89 f2                	mov    %esi,%edx
  801212:	eb 09                	jmp    80121d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801214:	83 c2 01             	add    $0x1,%edx
  801217:	83 c1 01             	add    $0x1,%ecx
  80121a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80121d:	39 c2                	cmp    %eax,%edx
  80121f:	74 09                	je     80122a <strlcpy+0x32>
  801221:	0f b6 19             	movzbl (%ecx),%ebx
  801224:	84 db                	test   %bl,%bl
  801226:	75 ec                	jne    801214 <strlcpy+0x1c>
  801228:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80122a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80122d:	29 f0                	sub    %esi,%eax
}
  80122f:	5b                   	pop    %ebx
  801230:	5e                   	pop    %esi
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    

00801233 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801239:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80123c:	eb 06                	jmp    801244 <strcmp+0x11>
		p++, q++;
  80123e:	83 c1 01             	add    $0x1,%ecx
  801241:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801244:	0f b6 01             	movzbl (%ecx),%eax
  801247:	84 c0                	test   %al,%al
  801249:	74 04                	je     80124f <strcmp+0x1c>
  80124b:	3a 02                	cmp    (%edx),%al
  80124d:	74 ef                	je     80123e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80124f:	0f b6 c0             	movzbl %al,%eax
  801252:	0f b6 12             	movzbl (%edx),%edx
  801255:	29 d0                	sub    %edx,%eax
}
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    

00801259 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	53                   	push   %ebx
  80125d:	8b 45 08             	mov    0x8(%ebp),%eax
  801260:	8b 55 0c             	mov    0xc(%ebp),%edx
  801263:	89 c3                	mov    %eax,%ebx
  801265:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801268:	eb 06                	jmp    801270 <strncmp+0x17>
		n--, p++, q++;
  80126a:	83 c0 01             	add    $0x1,%eax
  80126d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801270:	39 d8                	cmp    %ebx,%eax
  801272:	74 15                	je     801289 <strncmp+0x30>
  801274:	0f b6 08             	movzbl (%eax),%ecx
  801277:	84 c9                	test   %cl,%cl
  801279:	74 04                	je     80127f <strncmp+0x26>
  80127b:	3a 0a                	cmp    (%edx),%cl
  80127d:	74 eb                	je     80126a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80127f:	0f b6 00             	movzbl (%eax),%eax
  801282:	0f b6 12             	movzbl (%edx),%edx
  801285:	29 d0                	sub    %edx,%eax
  801287:	eb 05                	jmp    80128e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801289:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80128e:	5b                   	pop    %ebx
  80128f:	5d                   	pop    %ebp
  801290:	c3                   	ret    

00801291 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	8b 45 08             	mov    0x8(%ebp),%eax
  801297:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80129b:	eb 07                	jmp    8012a4 <strchr+0x13>
		if (*s == c)
  80129d:	38 ca                	cmp    %cl,%dl
  80129f:	74 0f                	je     8012b0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012a1:	83 c0 01             	add    $0x1,%eax
  8012a4:	0f b6 10             	movzbl (%eax),%edx
  8012a7:	84 d2                	test   %dl,%dl
  8012a9:	75 f2                	jne    80129d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8012ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012bc:	eb 03                	jmp    8012c1 <strfind+0xf>
  8012be:	83 c0 01             	add    $0x1,%eax
  8012c1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8012c4:	38 ca                	cmp    %cl,%dl
  8012c6:	74 04                	je     8012cc <strfind+0x1a>
  8012c8:	84 d2                	test   %dl,%dl
  8012ca:	75 f2                	jne    8012be <strfind+0xc>
			break;
	return (char *) s;
}
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	53                   	push   %ebx
  8012d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012da:	85 c9                	test   %ecx,%ecx
  8012dc:	74 36                	je     801314 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012de:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012e4:	75 28                	jne    80130e <memset+0x40>
  8012e6:	f6 c1 03             	test   $0x3,%cl
  8012e9:	75 23                	jne    80130e <memset+0x40>
		c &= 0xFF;
  8012eb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012ef:	89 d3                	mov    %edx,%ebx
  8012f1:	c1 e3 08             	shl    $0x8,%ebx
  8012f4:	89 d6                	mov    %edx,%esi
  8012f6:	c1 e6 18             	shl    $0x18,%esi
  8012f9:	89 d0                	mov    %edx,%eax
  8012fb:	c1 e0 10             	shl    $0x10,%eax
  8012fe:	09 f0                	or     %esi,%eax
  801300:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801302:	89 d8                	mov    %ebx,%eax
  801304:	09 d0                	or     %edx,%eax
  801306:	c1 e9 02             	shr    $0x2,%ecx
  801309:	fc                   	cld    
  80130a:	f3 ab                	rep stos %eax,%es:(%edi)
  80130c:	eb 06                	jmp    801314 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80130e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801311:	fc                   	cld    
  801312:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801314:	89 f8                	mov    %edi,%eax
  801316:	5b                   	pop    %ebx
  801317:	5e                   	pop    %esi
  801318:	5f                   	pop    %edi
  801319:	5d                   	pop    %ebp
  80131a:	c3                   	ret    

0080131b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	57                   	push   %edi
  80131f:	56                   	push   %esi
  801320:	8b 45 08             	mov    0x8(%ebp),%eax
  801323:	8b 75 0c             	mov    0xc(%ebp),%esi
  801326:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801329:	39 c6                	cmp    %eax,%esi
  80132b:	73 35                	jae    801362 <memmove+0x47>
  80132d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801330:	39 d0                	cmp    %edx,%eax
  801332:	73 2e                	jae    801362 <memmove+0x47>
		s += n;
		d += n;
  801334:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801337:	89 d6                	mov    %edx,%esi
  801339:	09 fe                	or     %edi,%esi
  80133b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801341:	75 13                	jne    801356 <memmove+0x3b>
  801343:	f6 c1 03             	test   $0x3,%cl
  801346:	75 0e                	jne    801356 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801348:	83 ef 04             	sub    $0x4,%edi
  80134b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80134e:	c1 e9 02             	shr    $0x2,%ecx
  801351:	fd                   	std    
  801352:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801354:	eb 09                	jmp    80135f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801356:	83 ef 01             	sub    $0x1,%edi
  801359:	8d 72 ff             	lea    -0x1(%edx),%esi
  80135c:	fd                   	std    
  80135d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80135f:	fc                   	cld    
  801360:	eb 1d                	jmp    80137f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801362:	89 f2                	mov    %esi,%edx
  801364:	09 c2                	or     %eax,%edx
  801366:	f6 c2 03             	test   $0x3,%dl
  801369:	75 0f                	jne    80137a <memmove+0x5f>
  80136b:	f6 c1 03             	test   $0x3,%cl
  80136e:	75 0a                	jne    80137a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801370:	c1 e9 02             	shr    $0x2,%ecx
  801373:	89 c7                	mov    %eax,%edi
  801375:	fc                   	cld    
  801376:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801378:	eb 05                	jmp    80137f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80137a:	89 c7                	mov    %eax,%edi
  80137c:	fc                   	cld    
  80137d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80137f:	5e                   	pop    %esi
  801380:	5f                   	pop    %edi
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    

00801383 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801386:	ff 75 10             	pushl  0x10(%ebp)
  801389:	ff 75 0c             	pushl  0xc(%ebp)
  80138c:	ff 75 08             	pushl  0x8(%ebp)
  80138f:	e8 87 ff ff ff       	call   80131b <memmove>
}
  801394:	c9                   	leave  
  801395:	c3                   	ret    

00801396 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	56                   	push   %esi
  80139a:	53                   	push   %ebx
  80139b:	8b 45 08             	mov    0x8(%ebp),%eax
  80139e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a1:	89 c6                	mov    %eax,%esi
  8013a3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013a6:	eb 1a                	jmp    8013c2 <memcmp+0x2c>
		if (*s1 != *s2)
  8013a8:	0f b6 08             	movzbl (%eax),%ecx
  8013ab:	0f b6 1a             	movzbl (%edx),%ebx
  8013ae:	38 d9                	cmp    %bl,%cl
  8013b0:	74 0a                	je     8013bc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8013b2:	0f b6 c1             	movzbl %cl,%eax
  8013b5:	0f b6 db             	movzbl %bl,%ebx
  8013b8:	29 d8                	sub    %ebx,%eax
  8013ba:	eb 0f                	jmp    8013cb <memcmp+0x35>
		s1++, s2++;
  8013bc:	83 c0 01             	add    $0x1,%eax
  8013bf:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013c2:	39 f0                	cmp    %esi,%eax
  8013c4:	75 e2                	jne    8013a8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013cb:	5b                   	pop    %ebx
  8013cc:	5e                   	pop    %esi
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    

008013cf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	53                   	push   %ebx
  8013d3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8013d6:	89 c1                	mov    %eax,%ecx
  8013d8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8013db:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013df:	eb 0a                	jmp    8013eb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013e1:	0f b6 10             	movzbl (%eax),%edx
  8013e4:	39 da                	cmp    %ebx,%edx
  8013e6:	74 07                	je     8013ef <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013e8:	83 c0 01             	add    $0x1,%eax
  8013eb:	39 c8                	cmp    %ecx,%eax
  8013ed:	72 f2                	jb     8013e1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013ef:	5b                   	pop    %ebx
  8013f0:	5d                   	pop    %ebp
  8013f1:	c3                   	ret    

008013f2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	57                   	push   %edi
  8013f6:	56                   	push   %esi
  8013f7:	53                   	push   %ebx
  8013f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013fe:	eb 03                	jmp    801403 <strtol+0x11>
		s++;
  801400:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801403:	0f b6 01             	movzbl (%ecx),%eax
  801406:	3c 20                	cmp    $0x20,%al
  801408:	74 f6                	je     801400 <strtol+0xe>
  80140a:	3c 09                	cmp    $0x9,%al
  80140c:	74 f2                	je     801400 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80140e:	3c 2b                	cmp    $0x2b,%al
  801410:	75 0a                	jne    80141c <strtol+0x2a>
		s++;
  801412:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801415:	bf 00 00 00 00       	mov    $0x0,%edi
  80141a:	eb 11                	jmp    80142d <strtol+0x3b>
  80141c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801421:	3c 2d                	cmp    $0x2d,%al
  801423:	75 08                	jne    80142d <strtol+0x3b>
		s++, neg = 1;
  801425:	83 c1 01             	add    $0x1,%ecx
  801428:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80142d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801433:	75 15                	jne    80144a <strtol+0x58>
  801435:	80 39 30             	cmpb   $0x30,(%ecx)
  801438:	75 10                	jne    80144a <strtol+0x58>
  80143a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80143e:	75 7c                	jne    8014bc <strtol+0xca>
		s += 2, base = 16;
  801440:	83 c1 02             	add    $0x2,%ecx
  801443:	bb 10 00 00 00       	mov    $0x10,%ebx
  801448:	eb 16                	jmp    801460 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80144a:	85 db                	test   %ebx,%ebx
  80144c:	75 12                	jne    801460 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80144e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801453:	80 39 30             	cmpb   $0x30,(%ecx)
  801456:	75 08                	jne    801460 <strtol+0x6e>
		s++, base = 8;
  801458:	83 c1 01             	add    $0x1,%ecx
  80145b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801460:	b8 00 00 00 00       	mov    $0x0,%eax
  801465:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801468:	0f b6 11             	movzbl (%ecx),%edx
  80146b:	8d 72 d0             	lea    -0x30(%edx),%esi
  80146e:	89 f3                	mov    %esi,%ebx
  801470:	80 fb 09             	cmp    $0x9,%bl
  801473:	77 08                	ja     80147d <strtol+0x8b>
			dig = *s - '0';
  801475:	0f be d2             	movsbl %dl,%edx
  801478:	83 ea 30             	sub    $0x30,%edx
  80147b:	eb 22                	jmp    80149f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80147d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801480:	89 f3                	mov    %esi,%ebx
  801482:	80 fb 19             	cmp    $0x19,%bl
  801485:	77 08                	ja     80148f <strtol+0x9d>
			dig = *s - 'a' + 10;
  801487:	0f be d2             	movsbl %dl,%edx
  80148a:	83 ea 57             	sub    $0x57,%edx
  80148d:	eb 10                	jmp    80149f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80148f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801492:	89 f3                	mov    %esi,%ebx
  801494:	80 fb 19             	cmp    $0x19,%bl
  801497:	77 16                	ja     8014af <strtol+0xbd>
			dig = *s - 'A' + 10;
  801499:	0f be d2             	movsbl %dl,%edx
  80149c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80149f:	3b 55 10             	cmp    0x10(%ebp),%edx
  8014a2:	7d 0b                	jge    8014af <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8014a4:	83 c1 01             	add    $0x1,%ecx
  8014a7:	0f af 45 10          	imul   0x10(%ebp),%eax
  8014ab:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8014ad:	eb b9                	jmp    801468 <strtol+0x76>

	if (endptr)
  8014af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014b3:	74 0d                	je     8014c2 <strtol+0xd0>
		*endptr = (char *) s;
  8014b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014b8:	89 0e                	mov    %ecx,(%esi)
  8014ba:	eb 06                	jmp    8014c2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014bc:	85 db                	test   %ebx,%ebx
  8014be:	74 98                	je     801458 <strtol+0x66>
  8014c0:	eb 9e                	jmp    801460 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8014c2:	89 c2                	mov    %eax,%edx
  8014c4:	f7 da                	neg    %edx
  8014c6:	85 ff                	test   %edi,%edi
  8014c8:	0f 45 c2             	cmovne %edx,%eax
}
  8014cb:	5b                   	pop    %ebx
  8014cc:	5e                   	pop    %esi
  8014cd:	5f                   	pop    %edi
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    

008014d0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	57                   	push   %edi
  8014d4:	56                   	push   %esi
  8014d5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014de:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e1:	89 c3                	mov    %eax,%ebx
  8014e3:	89 c7                	mov    %eax,%edi
  8014e5:	89 c6                	mov    %eax,%esi
  8014e7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014e9:	5b                   	pop    %ebx
  8014ea:	5e                   	pop    %esi
  8014eb:	5f                   	pop    %edi
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    

008014ee <sys_cgetc>:

int
sys_cgetc(void)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	57                   	push   %edi
  8014f2:	56                   	push   %esi
  8014f3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8014fe:	89 d1                	mov    %edx,%ecx
  801500:	89 d3                	mov    %edx,%ebx
  801502:	89 d7                	mov    %edx,%edi
  801504:	89 d6                	mov    %edx,%esi
  801506:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801508:	5b                   	pop    %ebx
  801509:	5e                   	pop    %esi
  80150a:	5f                   	pop    %edi
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    

0080150d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	57                   	push   %edi
  801511:	56                   	push   %esi
  801512:	53                   	push   %ebx
  801513:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801516:	b9 00 00 00 00       	mov    $0x0,%ecx
  80151b:	b8 03 00 00 00       	mov    $0x3,%eax
  801520:	8b 55 08             	mov    0x8(%ebp),%edx
  801523:	89 cb                	mov    %ecx,%ebx
  801525:	89 cf                	mov    %ecx,%edi
  801527:	89 ce                	mov    %ecx,%esi
  801529:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80152b:	85 c0                	test   %eax,%eax
  80152d:	7e 17                	jle    801546 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80152f:	83 ec 0c             	sub    $0xc,%esp
  801532:	50                   	push   %eax
  801533:	6a 03                	push   $0x3
  801535:	68 8f 38 80 00       	push   $0x80388f
  80153a:	6a 23                	push   $0x23
  80153c:	68 ac 38 80 00       	push   $0x8038ac
  801541:	e8 f2 f4 ff ff       	call   800a38 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801546:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801549:	5b                   	pop    %ebx
  80154a:	5e                   	pop    %esi
  80154b:	5f                   	pop    %edi
  80154c:	5d                   	pop    %ebp
  80154d:	c3                   	ret    

0080154e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	57                   	push   %edi
  801552:	56                   	push   %esi
  801553:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801554:	ba 00 00 00 00       	mov    $0x0,%edx
  801559:	b8 02 00 00 00       	mov    $0x2,%eax
  80155e:	89 d1                	mov    %edx,%ecx
  801560:	89 d3                	mov    %edx,%ebx
  801562:	89 d7                	mov    %edx,%edi
  801564:	89 d6                	mov    %edx,%esi
  801566:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801568:	5b                   	pop    %ebx
  801569:	5e                   	pop    %esi
  80156a:	5f                   	pop    %edi
  80156b:	5d                   	pop    %ebp
  80156c:	c3                   	ret    

0080156d <sys_yield>:

void
sys_yield(void)
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	57                   	push   %edi
  801571:	56                   	push   %esi
  801572:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801573:	ba 00 00 00 00       	mov    $0x0,%edx
  801578:	b8 0b 00 00 00       	mov    $0xb,%eax
  80157d:	89 d1                	mov    %edx,%ecx
  80157f:	89 d3                	mov    %edx,%ebx
  801581:	89 d7                	mov    %edx,%edi
  801583:	89 d6                	mov    %edx,%esi
  801585:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801587:	5b                   	pop    %ebx
  801588:	5e                   	pop    %esi
  801589:	5f                   	pop    %edi
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    

0080158c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	57                   	push   %edi
  801590:	56                   	push   %esi
  801591:	53                   	push   %ebx
  801592:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801595:	be 00 00 00 00       	mov    $0x0,%esi
  80159a:	b8 04 00 00 00       	mov    $0x4,%eax
  80159f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8015a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015a8:	89 f7                	mov    %esi,%edi
  8015aa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	7e 17                	jle    8015c7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015b0:	83 ec 0c             	sub    $0xc,%esp
  8015b3:	50                   	push   %eax
  8015b4:	6a 04                	push   $0x4
  8015b6:	68 8f 38 80 00       	push   $0x80388f
  8015bb:	6a 23                	push   $0x23
  8015bd:	68 ac 38 80 00       	push   $0x8038ac
  8015c2:	e8 71 f4 ff ff       	call   800a38 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ca:	5b                   	pop    %ebx
  8015cb:	5e                   	pop    %esi
  8015cc:	5f                   	pop    %edi
  8015cd:	5d                   	pop    %ebp
  8015ce:	c3                   	ret    

008015cf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	57                   	push   %edi
  8015d3:	56                   	push   %esi
  8015d4:	53                   	push   %ebx
  8015d5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015d8:	b8 05 00 00 00       	mov    $0x5,%eax
  8015dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8015e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015e6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015e9:	8b 75 18             	mov    0x18(%ebp),%esi
  8015ec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	7e 17                	jle    801609 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015f2:	83 ec 0c             	sub    $0xc,%esp
  8015f5:	50                   	push   %eax
  8015f6:	6a 05                	push   $0x5
  8015f8:	68 8f 38 80 00       	push   $0x80388f
  8015fd:	6a 23                	push   $0x23
  8015ff:	68 ac 38 80 00       	push   $0x8038ac
  801604:	e8 2f f4 ff ff       	call   800a38 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801609:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160c:	5b                   	pop    %ebx
  80160d:	5e                   	pop    %esi
  80160e:	5f                   	pop    %edi
  80160f:	5d                   	pop    %ebp
  801610:	c3                   	ret    

00801611 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	57                   	push   %edi
  801615:	56                   	push   %esi
  801616:	53                   	push   %ebx
  801617:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80161a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80161f:	b8 06 00 00 00       	mov    $0x6,%eax
  801624:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801627:	8b 55 08             	mov    0x8(%ebp),%edx
  80162a:	89 df                	mov    %ebx,%edi
  80162c:	89 de                	mov    %ebx,%esi
  80162e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801630:	85 c0                	test   %eax,%eax
  801632:	7e 17                	jle    80164b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801634:	83 ec 0c             	sub    $0xc,%esp
  801637:	50                   	push   %eax
  801638:	6a 06                	push   $0x6
  80163a:	68 8f 38 80 00       	push   $0x80388f
  80163f:	6a 23                	push   $0x23
  801641:	68 ac 38 80 00       	push   $0x8038ac
  801646:	e8 ed f3 ff ff       	call   800a38 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80164b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164e:	5b                   	pop    %ebx
  80164f:	5e                   	pop    %esi
  801650:	5f                   	pop    %edi
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    

00801653 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	57                   	push   %edi
  801657:	56                   	push   %esi
  801658:	53                   	push   %ebx
  801659:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80165c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801661:	b8 08 00 00 00       	mov    $0x8,%eax
  801666:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801669:	8b 55 08             	mov    0x8(%ebp),%edx
  80166c:	89 df                	mov    %ebx,%edi
  80166e:	89 de                	mov    %ebx,%esi
  801670:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801672:	85 c0                	test   %eax,%eax
  801674:	7e 17                	jle    80168d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801676:	83 ec 0c             	sub    $0xc,%esp
  801679:	50                   	push   %eax
  80167a:	6a 08                	push   $0x8
  80167c:	68 8f 38 80 00       	push   $0x80388f
  801681:	6a 23                	push   $0x23
  801683:	68 ac 38 80 00       	push   $0x8038ac
  801688:	e8 ab f3 ff ff       	call   800a38 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80168d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801690:	5b                   	pop    %ebx
  801691:	5e                   	pop    %esi
  801692:	5f                   	pop    %edi
  801693:	5d                   	pop    %ebp
  801694:	c3                   	ret    

00801695 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	57                   	push   %edi
  801699:	56                   	push   %esi
  80169a:	53                   	push   %ebx
  80169b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80169e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a3:	b8 09 00 00 00       	mov    $0x9,%eax
  8016a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8016ae:	89 df                	mov    %ebx,%edi
  8016b0:	89 de                	mov    %ebx,%esi
  8016b2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	7e 17                	jle    8016cf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016b8:	83 ec 0c             	sub    $0xc,%esp
  8016bb:	50                   	push   %eax
  8016bc:	6a 09                	push   $0x9
  8016be:	68 8f 38 80 00       	push   $0x80388f
  8016c3:	6a 23                	push   $0x23
  8016c5:	68 ac 38 80 00       	push   $0x8038ac
  8016ca:	e8 69 f3 ff ff       	call   800a38 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d2:	5b                   	pop    %ebx
  8016d3:	5e                   	pop    %esi
  8016d4:	5f                   	pop    %edi
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    

008016d7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	57                   	push   %edi
  8016db:	56                   	push   %esi
  8016dc:	53                   	push   %ebx
  8016dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f0:	89 df                	mov    %ebx,%edi
  8016f2:	89 de                	mov    %ebx,%esi
  8016f4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	7e 17                	jle    801711 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016fa:	83 ec 0c             	sub    $0xc,%esp
  8016fd:	50                   	push   %eax
  8016fe:	6a 0a                	push   $0xa
  801700:	68 8f 38 80 00       	push   $0x80388f
  801705:	6a 23                	push   $0x23
  801707:	68 ac 38 80 00       	push   $0x8038ac
  80170c:	e8 27 f3 ff ff       	call   800a38 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801711:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801714:	5b                   	pop    %ebx
  801715:	5e                   	pop    %esi
  801716:	5f                   	pop    %edi
  801717:	5d                   	pop    %ebp
  801718:	c3                   	ret    

00801719 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	57                   	push   %edi
  80171d:	56                   	push   %esi
  80171e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80171f:	be 00 00 00 00       	mov    $0x0,%esi
  801724:	b8 0c 00 00 00       	mov    $0xc,%eax
  801729:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172c:	8b 55 08             	mov    0x8(%ebp),%edx
  80172f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801732:	8b 7d 14             	mov    0x14(%ebp),%edi
  801735:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801737:	5b                   	pop    %ebx
  801738:	5e                   	pop    %esi
  801739:	5f                   	pop    %edi
  80173a:	5d                   	pop    %ebp
  80173b:	c3                   	ret    

0080173c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	57                   	push   %edi
  801740:	56                   	push   %esi
  801741:	53                   	push   %ebx
  801742:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801745:	b9 00 00 00 00       	mov    $0x0,%ecx
  80174a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80174f:	8b 55 08             	mov    0x8(%ebp),%edx
  801752:	89 cb                	mov    %ecx,%ebx
  801754:	89 cf                	mov    %ecx,%edi
  801756:	89 ce                	mov    %ecx,%esi
  801758:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80175a:	85 c0                	test   %eax,%eax
  80175c:	7e 17                	jle    801775 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80175e:	83 ec 0c             	sub    $0xc,%esp
  801761:	50                   	push   %eax
  801762:	6a 0d                	push   $0xd
  801764:	68 8f 38 80 00       	push   $0x80388f
  801769:	6a 23                	push   $0x23
  80176b:	68 ac 38 80 00       	push   $0x8038ac
  801770:	e8 c3 f2 ff ff       	call   800a38 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801775:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801778:	5b                   	pop    %ebx
  801779:	5e                   	pop    %esi
  80177a:	5f                   	pop    %edi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	57                   	push   %edi
  801781:	56                   	push   %esi
  801782:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801783:	b9 00 00 00 00       	mov    $0x0,%ecx
  801788:	b8 0e 00 00 00       	mov    $0xe,%eax
  80178d:	8b 55 08             	mov    0x8(%ebp),%edx
  801790:	89 cb                	mov    %ecx,%ebx
  801792:	89 cf                	mov    %ecx,%edi
  801794:	89 ce                	mov    %ecx,%esi
  801796:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  801798:	5b                   	pop    %ebx
  801799:	5e                   	pop    %esi
  80179a:	5f                   	pop    %edi
  80179b:	5d                   	pop    %ebp
  80179c:	c3                   	ret    

0080179d <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	57                   	push   %edi
  8017a1:	56                   	push   %esi
  8017a2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017a8:	b8 0f 00 00 00       	mov    $0xf,%eax
  8017ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b0:	89 cb                	mov    %ecx,%ebx
  8017b2:	89 cf                	mov    %ecx,%edi
  8017b4:	89 ce                	mov    %ecx,%esi
  8017b6:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8017b8:	5b                   	pop    %ebx
  8017b9:	5e                   	pop    %esi
  8017ba:	5f                   	pop    %edi
  8017bb:	5d                   	pop    %ebp
  8017bc:	c3                   	ret    

008017bd <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	53                   	push   %ebx
  8017c1:	83 ec 04             	sub    $0x4,%esp
  8017c4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8017c7:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8017c9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8017cd:	74 11                	je     8017e0 <pgfault+0x23>
  8017cf:	89 d8                	mov    %ebx,%eax
  8017d1:	c1 e8 0c             	shr    $0xc,%eax
  8017d4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017db:	f6 c4 08             	test   $0x8,%ah
  8017de:	75 14                	jne    8017f4 <pgfault+0x37>
		panic("faulting access");
  8017e0:	83 ec 04             	sub    $0x4,%esp
  8017e3:	68 ba 38 80 00       	push   $0x8038ba
  8017e8:	6a 1e                	push   $0x1e
  8017ea:	68 ca 38 80 00       	push   $0x8038ca
  8017ef:	e8 44 f2 ff ff       	call   800a38 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8017f4:	83 ec 04             	sub    $0x4,%esp
  8017f7:	6a 07                	push   $0x7
  8017f9:	68 00 f0 7f 00       	push   $0x7ff000
  8017fe:	6a 00                	push   $0x0
  801800:	e8 87 fd ff ff       	call   80158c <sys_page_alloc>
	if (r < 0) {
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	85 c0                	test   %eax,%eax
  80180a:	79 12                	jns    80181e <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  80180c:	50                   	push   %eax
  80180d:	68 d5 38 80 00       	push   $0x8038d5
  801812:	6a 2c                	push   $0x2c
  801814:	68 ca 38 80 00       	push   $0x8038ca
  801819:	e8 1a f2 ff ff       	call   800a38 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80181e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  801824:	83 ec 04             	sub    $0x4,%esp
  801827:	68 00 10 00 00       	push   $0x1000
  80182c:	53                   	push   %ebx
  80182d:	68 00 f0 7f 00       	push   $0x7ff000
  801832:	e8 4c fb ff ff       	call   801383 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801837:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80183e:	53                   	push   %ebx
  80183f:	6a 00                	push   $0x0
  801841:	68 00 f0 7f 00       	push   $0x7ff000
  801846:	6a 00                	push   $0x0
  801848:	e8 82 fd ff ff       	call   8015cf <sys_page_map>
	if (r < 0) {
  80184d:	83 c4 20             	add    $0x20,%esp
  801850:	85 c0                	test   %eax,%eax
  801852:	79 12                	jns    801866 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  801854:	50                   	push   %eax
  801855:	68 d5 38 80 00       	push   $0x8038d5
  80185a:	6a 33                	push   $0x33
  80185c:	68 ca 38 80 00       	push   $0x8038ca
  801861:	e8 d2 f1 ff ff       	call   800a38 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	68 00 f0 7f 00       	push   $0x7ff000
  80186e:	6a 00                	push   $0x0
  801870:	e8 9c fd ff ff       	call   801611 <sys_page_unmap>
	if (r < 0) {
  801875:	83 c4 10             	add    $0x10,%esp
  801878:	85 c0                	test   %eax,%eax
  80187a:	79 12                	jns    80188e <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80187c:	50                   	push   %eax
  80187d:	68 d5 38 80 00       	push   $0x8038d5
  801882:	6a 37                	push   $0x37
  801884:	68 ca 38 80 00       	push   $0x8038ca
  801889:	e8 aa f1 ff ff       	call   800a38 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80188e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	57                   	push   %edi
  801897:	56                   	push   %esi
  801898:	53                   	push   %ebx
  801899:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80189c:	68 bd 17 80 00       	push   $0x8017bd
  8018a1:	e8 19 16 00 00       	call   802ebf <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8018a6:	b8 07 00 00 00       	mov    $0x7,%eax
  8018ab:	cd 30                	int    $0x30
  8018ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	79 17                	jns    8018ce <fork+0x3b>
		panic("fork fault %e");
  8018b7:	83 ec 04             	sub    $0x4,%esp
  8018ba:	68 ee 38 80 00       	push   $0x8038ee
  8018bf:	68 84 00 00 00       	push   $0x84
  8018c4:	68 ca 38 80 00       	push   $0x8038ca
  8018c9:	e8 6a f1 ff ff       	call   800a38 <_panic>
  8018ce:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8018d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8018d4:	75 24                	jne    8018fa <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8018d6:	e8 73 fc ff ff       	call   80154e <sys_getenvid>
  8018db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018e0:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8018e6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018eb:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  8018f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f5:	e9 64 01 00 00       	jmp    801a5e <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8018fa:	83 ec 04             	sub    $0x4,%esp
  8018fd:	6a 07                	push   $0x7
  8018ff:	68 00 f0 bf ee       	push   $0xeebff000
  801904:	ff 75 e4             	pushl  -0x1c(%ebp)
  801907:	e8 80 fc ff ff       	call   80158c <sys_page_alloc>
  80190c:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80190f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801914:	89 d8                	mov    %ebx,%eax
  801916:	c1 e8 16             	shr    $0x16,%eax
  801919:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801920:	a8 01                	test   $0x1,%al
  801922:	0f 84 fc 00 00 00    	je     801a24 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801928:	89 d8                	mov    %ebx,%eax
  80192a:	c1 e8 0c             	shr    $0xc,%eax
  80192d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801934:	f6 c2 01             	test   $0x1,%dl
  801937:	0f 84 e7 00 00 00    	je     801a24 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80193d:	89 c6                	mov    %eax,%esi
  80193f:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801942:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801949:	f6 c6 04             	test   $0x4,%dh
  80194c:	74 39                	je     801987 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80194e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801955:	83 ec 0c             	sub    $0xc,%esp
  801958:	25 07 0e 00 00       	and    $0xe07,%eax
  80195d:	50                   	push   %eax
  80195e:	56                   	push   %esi
  80195f:	57                   	push   %edi
  801960:	56                   	push   %esi
  801961:	6a 00                	push   $0x0
  801963:	e8 67 fc ff ff       	call   8015cf <sys_page_map>
		if (r < 0) {
  801968:	83 c4 20             	add    $0x20,%esp
  80196b:	85 c0                	test   %eax,%eax
  80196d:	0f 89 b1 00 00 00    	jns    801a24 <fork+0x191>
		    	panic("sys page map fault %e");
  801973:	83 ec 04             	sub    $0x4,%esp
  801976:	68 fc 38 80 00       	push   $0x8038fc
  80197b:	6a 54                	push   $0x54
  80197d:	68 ca 38 80 00       	push   $0x8038ca
  801982:	e8 b1 f0 ff ff       	call   800a38 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801987:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80198e:	f6 c2 02             	test   $0x2,%dl
  801991:	75 0c                	jne    80199f <fork+0x10c>
  801993:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80199a:	f6 c4 08             	test   $0x8,%ah
  80199d:	74 5b                	je     8019fa <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80199f:	83 ec 0c             	sub    $0xc,%esp
  8019a2:	68 05 08 00 00       	push   $0x805
  8019a7:	56                   	push   %esi
  8019a8:	57                   	push   %edi
  8019a9:	56                   	push   %esi
  8019aa:	6a 00                	push   $0x0
  8019ac:	e8 1e fc ff ff       	call   8015cf <sys_page_map>
		if (r < 0) {
  8019b1:	83 c4 20             	add    $0x20,%esp
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	79 14                	jns    8019cc <fork+0x139>
		    	panic("sys page map fault %e");
  8019b8:	83 ec 04             	sub    $0x4,%esp
  8019bb:	68 fc 38 80 00       	push   $0x8038fc
  8019c0:	6a 5b                	push   $0x5b
  8019c2:	68 ca 38 80 00       	push   $0x8038ca
  8019c7:	e8 6c f0 ff ff       	call   800a38 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8019cc:	83 ec 0c             	sub    $0xc,%esp
  8019cf:	68 05 08 00 00       	push   $0x805
  8019d4:	56                   	push   %esi
  8019d5:	6a 00                	push   $0x0
  8019d7:	56                   	push   %esi
  8019d8:	6a 00                	push   $0x0
  8019da:	e8 f0 fb ff ff       	call   8015cf <sys_page_map>
		if (r < 0) {
  8019df:	83 c4 20             	add    $0x20,%esp
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	79 3e                	jns    801a24 <fork+0x191>
		    	panic("sys page map fault %e");
  8019e6:	83 ec 04             	sub    $0x4,%esp
  8019e9:	68 fc 38 80 00       	push   $0x8038fc
  8019ee:	6a 5f                	push   $0x5f
  8019f0:	68 ca 38 80 00       	push   $0x8038ca
  8019f5:	e8 3e f0 ff ff       	call   800a38 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	6a 05                	push   $0x5
  8019ff:	56                   	push   %esi
  801a00:	57                   	push   %edi
  801a01:	56                   	push   %esi
  801a02:	6a 00                	push   $0x0
  801a04:	e8 c6 fb ff ff       	call   8015cf <sys_page_map>
		if (r < 0) {
  801a09:	83 c4 20             	add    $0x20,%esp
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	79 14                	jns    801a24 <fork+0x191>
		    	panic("sys page map fault %e");
  801a10:	83 ec 04             	sub    $0x4,%esp
  801a13:	68 fc 38 80 00       	push   $0x8038fc
  801a18:	6a 64                	push   $0x64
  801a1a:	68 ca 38 80 00       	push   $0x8038ca
  801a1f:	e8 14 f0 ff ff       	call   800a38 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801a24:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a2a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801a30:	0f 85 de fe ff ff    	jne    801914 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801a36:	a1 24 54 80 00       	mov    0x805424,%eax
  801a3b:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  801a41:	83 ec 08             	sub    $0x8,%esp
  801a44:	50                   	push   %eax
  801a45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a48:	57                   	push   %edi
  801a49:	e8 89 fc ff ff       	call   8016d7 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801a4e:	83 c4 08             	add    $0x8,%esp
  801a51:	6a 02                	push   $0x2
  801a53:	57                   	push   %edi
  801a54:	e8 fa fb ff ff       	call   801653 <sys_env_set_status>
	
	return envid;
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801a5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a61:	5b                   	pop    %ebx
  801a62:	5e                   	pop    %esi
  801a63:	5f                   	pop    %edi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    

00801a66 <sfork>:

envid_t
sfork(void)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801a69:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    

00801a70 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	56                   	push   %esi
  801a74:	53                   	push   %ebx
  801a75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801a78:	89 1d 28 54 80 00    	mov    %ebx,0x805428
	cprintf("in fork.c thread create. func: %x\n", func);
  801a7e:	83 ec 08             	sub    $0x8,%esp
  801a81:	53                   	push   %ebx
  801a82:	68 14 39 80 00       	push   $0x803914
  801a87:	e8 85 f0 ff ff       	call   800b11 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801a8c:	c7 04 24 fe 09 80 00 	movl   $0x8009fe,(%esp)
  801a93:	e8 e5 fc ff ff       	call   80177d <sys_thread_create>
  801a98:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801a9a:	83 c4 08             	add    $0x8,%esp
  801a9d:	53                   	push   %ebx
  801a9e:	68 14 39 80 00       	push   $0x803914
  801aa3:	e8 69 f0 ff ff       	call   800b11 <cprintf>
	return id;
}
  801aa8:	89 f0                	mov    %esi,%eax
  801aaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aad:	5b                   	pop    %ebx
  801aae:	5e                   	pop    %esi
  801aaf:	5d                   	pop    %ebp
  801ab0:	c3                   	ret    

00801ab1 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  801ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aba:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801abd:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801abf:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801ac2:	83 3a 01             	cmpl   $0x1,(%edx)
  801ac5:	7e 09                	jle    801ad0 <argstart+0x1f>
  801ac7:	ba 61 33 80 00       	mov    $0x803361,%edx
  801acc:	85 c9                	test   %ecx,%ecx
  801ace:	75 05                	jne    801ad5 <argstart+0x24>
  801ad0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad5:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801ad8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <argnext>:

int
argnext(struct Argstate *args)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	53                   	push   %ebx
  801ae5:	83 ec 04             	sub    $0x4,%esp
  801ae8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801aeb:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801af2:	8b 43 08             	mov    0x8(%ebx),%eax
  801af5:	85 c0                	test   %eax,%eax
  801af7:	74 6f                	je     801b68 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801af9:	80 38 00             	cmpb   $0x0,(%eax)
  801afc:	75 4e                	jne    801b4c <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801afe:	8b 0b                	mov    (%ebx),%ecx
  801b00:	83 39 01             	cmpl   $0x1,(%ecx)
  801b03:	74 55                	je     801b5a <argnext+0x79>
		    || args->argv[1][0] != '-'
  801b05:	8b 53 04             	mov    0x4(%ebx),%edx
  801b08:	8b 42 04             	mov    0x4(%edx),%eax
  801b0b:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b0e:	75 4a                	jne    801b5a <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801b10:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b14:	74 44                	je     801b5a <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b16:	83 c0 01             	add    $0x1,%eax
  801b19:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b1c:	83 ec 04             	sub    $0x4,%esp
  801b1f:	8b 01                	mov    (%ecx),%eax
  801b21:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b28:	50                   	push   %eax
  801b29:	8d 42 08             	lea    0x8(%edx),%eax
  801b2c:	50                   	push   %eax
  801b2d:	83 c2 04             	add    $0x4,%edx
  801b30:	52                   	push   %edx
  801b31:	e8 e5 f7 ff ff       	call   80131b <memmove>
		(*args->argc)--;
  801b36:	8b 03                	mov    (%ebx),%eax
  801b38:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b3b:	8b 43 08             	mov    0x8(%ebx),%eax
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b44:	75 06                	jne    801b4c <argnext+0x6b>
  801b46:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b4a:	74 0e                	je     801b5a <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b4c:	8b 53 08             	mov    0x8(%ebx),%edx
  801b4f:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b52:	83 c2 01             	add    $0x1,%edx
  801b55:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b58:	eb 13                	jmp    801b6d <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b5a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b66:	eb 05                	jmp    801b6d <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b70:	c9                   	leave  
  801b71:	c3                   	ret    

00801b72 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	53                   	push   %ebx
  801b76:	83 ec 04             	sub    $0x4,%esp
  801b79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b7c:	8b 43 08             	mov    0x8(%ebx),%eax
  801b7f:	85 c0                	test   %eax,%eax
  801b81:	74 58                	je     801bdb <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801b83:	80 38 00             	cmpb   $0x0,(%eax)
  801b86:	74 0c                	je     801b94 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801b88:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b8b:	c7 43 08 61 33 80 00 	movl   $0x803361,0x8(%ebx)
  801b92:	eb 42                	jmp    801bd6 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801b94:	8b 13                	mov    (%ebx),%edx
  801b96:	83 3a 01             	cmpl   $0x1,(%edx)
  801b99:	7e 2d                	jle    801bc8 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801b9b:	8b 43 04             	mov    0x4(%ebx),%eax
  801b9e:	8b 48 04             	mov    0x4(%eax),%ecx
  801ba1:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801ba4:	83 ec 04             	sub    $0x4,%esp
  801ba7:	8b 12                	mov    (%edx),%edx
  801ba9:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801bb0:	52                   	push   %edx
  801bb1:	8d 50 08             	lea    0x8(%eax),%edx
  801bb4:	52                   	push   %edx
  801bb5:	83 c0 04             	add    $0x4,%eax
  801bb8:	50                   	push   %eax
  801bb9:	e8 5d f7 ff ff       	call   80131b <memmove>
		(*args->argc)--;
  801bbe:	8b 03                	mov    (%ebx),%eax
  801bc0:	83 28 01             	subl   $0x1,(%eax)
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	eb 0e                	jmp    801bd6 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801bc8:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801bcf:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801bd6:	8b 43 0c             	mov    0xc(%ebx),%eax
  801bd9:	eb 05                	jmp    801be0 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801bdb:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801be0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be3:	c9                   	leave  
  801be4:	c3                   	ret    

00801be5 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	83 ec 08             	sub    $0x8,%esp
  801beb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801bee:	8b 51 0c             	mov    0xc(%ecx),%edx
  801bf1:	89 d0                	mov    %edx,%eax
  801bf3:	85 d2                	test   %edx,%edx
  801bf5:	75 0c                	jne    801c03 <argvalue+0x1e>
  801bf7:	83 ec 0c             	sub    $0xc,%esp
  801bfa:	51                   	push   %ecx
  801bfb:	e8 72 ff ff ff       	call   801b72 <argnextvalue>
  801c00:	83 c4 10             	add    $0x10,%esp
}
  801c03:	c9                   	leave  
  801c04:	c3                   	ret    

00801c05 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c08:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0b:	05 00 00 00 30       	add    $0x30000000,%eax
  801c10:	c1 e8 0c             	shr    $0xc,%eax
}
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    

00801c15 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801c18:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1b:	05 00 00 00 30       	add    $0x30000000,%eax
  801c20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c25:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c2a:	5d                   	pop    %ebp
  801c2b:	c3                   	ret    

00801c2c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c32:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c37:	89 c2                	mov    %eax,%edx
  801c39:	c1 ea 16             	shr    $0x16,%edx
  801c3c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c43:	f6 c2 01             	test   $0x1,%dl
  801c46:	74 11                	je     801c59 <fd_alloc+0x2d>
  801c48:	89 c2                	mov    %eax,%edx
  801c4a:	c1 ea 0c             	shr    $0xc,%edx
  801c4d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c54:	f6 c2 01             	test   $0x1,%dl
  801c57:	75 09                	jne    801c62 <fd_alloc+0x36>
			*fd_store = fd;
  801c59:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c60:	eb 17                	jmp    801c79 <fd_alloc+0x4d>
  801c62:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c67:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c6c:	75 c9                	jne    801c37 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c6e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801c74:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c79:	5d                   	pop    %ebp
  801c7a:	c3                   	ret    

00801c7b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c81:	83 f8 1f             	cmp    $0x1f,%eax
  801c84:	77 36                	ja     801cbc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c86:	c1 e0 0c             	shl    $0xc,%eax
  801c89:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c8e:	89 c2                	mov    %eax,%edx
  801c90:	c1 ea 16             	shr    $0x16,%edx
  801c93:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c9a:	f6 c2 01             	test   $0x1,%dl
  801c9d:	74 24                	je     801cc3 <fd_lookup+0x48>
  801c9f:	89 c2                	mov    %eax,%edx
  801ca1:	c1 ea 0c             	shr    $0xc,%edx
  801ca4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cab:	f6 c2 01             	test   $0x1,%dl
  801cae:	74 1a                	je     801cca <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801cb0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb3:	89 02                	mov    %eax,(%edx)
	return 0;
  801cb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cba:	eb 13                	jmp    801ccf <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cbc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cc1:	eb 0c                	jmp    801ccf <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cc3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cc8:	eb 05                	jmp    801ccf <fd_lookup+0x54>
  801cca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801ccf:	5d                   	pop    %ebp
  801cd0:	c3                   	ret    

00801cd1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	83 ec 08             	sub    $0x8,%esp
  801cd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cda:	ba b4 39 80 00       	mov    $0x8039b4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801cdf:	eb 13                	jmp    801cf4 <dev_lookup+0x23>
  801ce1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801ce4:	39 08                	cmp    %ecx,(%eax)
  801ce6:	75 0c                	jne    801cf4 <dev_lookup+0x23>
			*dev = devtab[i];
  801ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ceb:	89 01                	mov    %eax,(%ecx)
			return 0;
  801ced:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf2:	eb 2e                	jmp    801d22 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801cf4:	8b 02                	mov    (%edx),%eax
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	75 e7                	jne    801ce1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801cfa:	a1 24 54 80 00       	mov    0x805424,%eax
  801cff:	8b 40 7c             	mov    0x7c(%eax),%eax
  801d02:	83 ec 04             	sub    $0x4,%esp
  801d05:	51                   	push   %ecx
  801d06:	50                   	push   %eax
  801d07:	68 38 39 80 00       	push   $0x803938
  801d0c:	e8 00 ee ff ff       	call   800b11 <cprintf>
	*dev = 0;
  801d11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d14:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d22:	c9                   	leave  
  801d23:	c3                   	ret    

00801d24 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	56                   	push   %esi
  801d28:	53                   	push   %ebx
  801d29:	83 ec 10             	sub    $0x10,%esp
  801d2c:	8b 75 08             	mov    0x8(%ebp),%esi
  801d2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d35:	50                   	push   %eax
  801d36:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d3c:	c1 e8 0c             	shr    $0xc,%eax
  801d3f:	50                   	push   %eax
  801d40:	e8 36 ff ff ff       	call   801c7b <fd_lookup>
  801d45:	83 c4 08             	add    $0x8,%esp
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	78 05                	js     801d51 <fd_close+0x2d>
	    || fd != fd2)
  801d4c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d4f:	74 0c                	je     801d5d <fd_close+0x39>
		return (must_exist ? r : 0);
  801d51:	84 db                	test   %bl,%bl
  801d53:	ba 00 00 00 00       	mov    $0x0,%edx
  801d58:	0f 44 c2             	cmove  %edx,%eax
  801d5b:	eb 41                	jmp    801d9e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d5d:	83 ec 08             	sub    $0x8,%esp
  801d60:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d63:	50                   	push   %eax
  801d64:	ff 36                	pushl  (%esi)
  801d66:	e8 66 ff ff ff       	call   801cd1 <dev_lookup>
  801d6b:	89 c3                	mov    %eax,%ebx
  801d6d:	83 c4 10             	add    $0x10,%esp
  801d70:	85 c0                	test   %eax,%eax
  801d72:	78 1a                	js     801d8e <fd_close+0x6a>
		if (dev->dev_close)
  801d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d77:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801d7a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	74 0b                	je     801d8e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801d83:	83 ec 0c             	sub    $0xc,%esp
  801d86:	56                   	push   %esi
  801d87:	ff d0                	call   *%eax
  801d89:	89 c3                	mov    %eax,%ebx
  801d8b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d8e:	83 ec 08             	sub    $0x8,%esp
  801d91:	56                   	push   %esi
  801d92:	6a 00                	push   $0x0
  801d94:	e8 78 f8 ff ff       	call   801611 <sys_page_unmap>
	return r;
  801d99:	83 c4 10             	add    $0x10,%esp
  801d9c:	89 d8                	mov    %ebx,%eax
}
  801d9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da1:	5b                   	pop    %ebx
  801da2:	5e                   	pop    %esi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    

00801da5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dae:	50                   	push   %eax
  801daf:	ff 75 08             	pushl  0x8(%ebp)
  801db2:	e8 c4 fe ff ff       	call   801c7b <fd_lookup>
  801db7:	83 c4 08             	add    $0x8,%esp
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	78 10                	js     801dce <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801dbe:	83 ec 08             	sub    $0x8,%esp
  801dc1:	6a 01                	push   $0x1
  801dc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc6:	e8 59 ff ff ff       	call   801d24 <fd_close>
  801dcb:	83 c4 10             	add    $0x10,%esp
}
  801dce:	c9                   	leave  
  801dcf:	c3                   	ret    

00801dd0 <close_all>:

void
close_all(void)
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	53                   	push   %ebx
  801dd4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801dd7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801ddc:	83 ec 0c             	sub    $0xc,%esp
  801ddf:	53                   	push   %ebx
  801de0:	e8 c0 ff ff ff       	call   801da5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801de5:	83 c3 01             	add    $0x1,%ebx
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	83 fb 20             	cmp    $0x20,%ebx
  801dee:	75 ec                	jne    801ddc <close_all+0xc>
		close(i);
}
  801df0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801df3:	c9                   	leave  
  801df4:	c3                   	ret    

00801df5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	57                   	push   %edi
  801df9:	56                   	push   %esi
  801dfa:	53                   	push   %ebx
  801dfb:	83 ec 2c             	sub    $0x2c,%esp
  801dfe:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e01:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e04:	50                   	push   %eax
  801e05:	ff 75 08             	pushl  0x8(%ebp)
  801e08:	e8 6e fe ff ff       	call   801c7b <fd_lookup>
  801e0d:	83 c4 08             	add    $0x8,%esp
  801e10:	85 c0                	test   %eax,%eax
  801e12:	0f 88 c1 00 00 00    	js     801ed9 <dup+0xe4>
		return r;
	close(newfdnum);
  801e18:	83 ec 0c             	sub    $0xc,%esp
  801e1b:	56                   	push   %esi
  801e1c:	e8 84 ff ff ff       	call   801da5 <close>

	newfd = INDEX2FD(newfdnum);
  801e21:	89 f3                	mov    %esi,%ebx
  801e23:	c1 e3 0c             	shl    $0xc,%ebx
  801e26:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801e2c:	83 c4 04             	add    $0x4,%esp
  801e2f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e32:	e8 de fd ff ff       	call   801c15 <fd2data>
  801e37:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801e39:	89 1c 24             	mov    %ebx,(%esp)
  801e3c:	e8 d4 fd ff ff       	call   801c15 <fd2data>
  801e41:	83 c4 10             	add    $0x10,%esp
  801e44:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e47:	89 f8                	mov    %edi,%eax
  801e49:	c1 e8 16             	shr    $0x16,%eax
  801e4c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e53:	a8 01                	test   $0x1,%al
  801e55:	74 37                	je     801e8e <dup+0x99>
  801e57:	89 f8                	mov    %edi,%eax
  801e59:	c1 e8 0c             	shr    $0xc,%eax
  801e5c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e63:	f6 c2 01             	test   $0x1,%dl
  801e66:	74 26                	je     801e8e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e68:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e6f:	83 ec 0c             	sub    $0xc,%esp
  801e72:	25 07 0e 00 00       	and    $0xe07,%eax
  801e77:	50                   	push   %eax
  801e78:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e7b:	6a 00                	push   $0x0
  801e7d:	57                   	push   %edi
  801e7e:	6a 00                	push   $0x0
  801e80:	e8 4a f7 ff ff       	call   8015cf <sys_page_map>
  801e85:	89 c7                	mov    %eax,%edi
  801e87:	83 c4 20             	add    $0x20,%esp
  801e8a:	85 c0                	test   %eax,%eax
  801e8c:	78 2e                	js     801ebc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e8e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e91:	89 d0                	mov    %edx,%eax
  801e93:	c1 e8 0c             	shr    $0xc,%eax
  801e96:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e9d:	83 ec 0c             	sub    $0xc,%esp
  801ea0:	25 07 0e 00 00       	and    $0xe07,%eax
  801ea5:	50                   	push   %eax
  801ea6:	53                   	push   %ebx
  801ea7:	6a 00                	push   $0x0
  801ea9:	52                   	push   %edx
  801eaa:	6a 00                	push   $0x0
  801eac:	e8 1e f7 ff ff       	call   8015cf <sys_page_map>
  801eb1:	89 c7                	mov    %eax,%edi
  801eb3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801eb6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801eb8:	85 ff                	test   %edi,%edi
  801eba:	79 1d                	jns    801ed9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801ebc:	83 ec 08             	sub    $0x8,%esp
  801ebf:	53                   	push   %ebx
  801ec0:	6a 00                	push   $0x0
  801ec2:	e8 4a f7 ff ff       	call   801611 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ec7:	83 c4 08             	add    $0x8,%esp
  801eca:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ecd:	6a 00                	push   $0x0
  801ecf:	e8 3d f7 ff ff       	call   801611 <sys_page_unmap>
	return r;
  801ed4:	83 c4 10             	add    $0x10,%esp
  801ed7:	89 f8                	mov    %edi,%eax
}
  801ed9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801edc:	5b                   	pop    %ebx
  801edd:	5e                   	pop    %esi
  801ede:	5f                   	pop    %edi
  801edf:	5d                   	pop    %ebp
  801ee0:	c3                   	ret    

00801ee1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	53                   	push   %ebx
  801ee5:	83 ec 14             	sub    $0x14,%esp
  801ee8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801eeb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eee:	50                   	push   %eax
  801eef:	53                   	push   %ebx
  801ef0:	e8 86 fd ff ff       	call   801c7b <fd_lookup>
  801ef5:	83 c4 08             	add    $0x8,%esp
  801ef8:	89 c2                	mov    %eax,%edx
  801efa:	85 c0                	test   %eax,%eax
  801efc:	78 6d                	js     801f6b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801efe:	83 ec 08             	sub    $0x8,%esp
  801f01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f04:	50                   	push   %eax
  801f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f08:	ff 30                	pushl  (%eax)
  801f0a:	e8 c2 fd ff ff       	call   801cd1 <dev_lookup>
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	85 c0                	test   %eax,%eax
  801f14:	78 4c                	js     801f62 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f16:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f19:	8b 42 08             	mov    0x8(%edx),%eax
  801f1c:	83 e0 03             	and    $0x3,%eax
  801f1f:	83 f8 01             	cmp    $0x1,%eax
  801f22:	75 21                	jne    801f45 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f24:	a1 24 54 80 00       	mov    0x805424,%eax
  801f29:	8b 40 7c             	mov    0x7c(%eax),%eax
  801f2c:	83 ec 04             	sub    $0x4,%esp
  801f2f:	53                   	push   %ebx
  801f30:	50                   	push   %eax
  801f31:	68 79 39 80 00       	push   $0x803979
  801f36:	e8 d6 eb ff ff       	call   800b11 <cprintf>
		return -E_INVAL;
  801f3b:	83 c4 10             	add    $0x10,%esp
  801f3e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f43:	eb 26                	jmp    801f6b <read+0x8a>
	}
	if (!dev->dev_read)
  801f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f48:	8b 40 08             	mov    0x8(%eax),%eax
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	74 17                	je     801f66 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801f4f:	83 ec 04             	sub    $0x4,%esp
  801f52:	ff 75 10             	pushl  0x10(%ebp)
  801f55:	ff 75 0c             	pushl  0xc(%ebp)
  801f58:	52                   	push   %edx
  801f59:	ff d0                	call   *%eax
  801f5b:	89 c2                	mov    %eax,%edx
  801f5d:	83 c4 10             	add    $0x10,%esp
  801f60:	eb 09                	jmp    801f6b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f62:	89 c2                	mov    %eax,%edx
  801f64:	eb 05                	jmp    801f6b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f66:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801f6b:	89 d0                	mov    %edx,%eax
  801f6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f70:	c9                   	leave  
  801f71:	c3                   	ret    

00801f72 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	57                   	push   %edi
  801f76:	56                   	push   %esi
  801f77:	53                   	push   %ebx
  801f78:	83 ec 0c             	sub    $0xc,%esp
  801f7b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f7e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f81:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f86:	eb 21                	jmp    801fa9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f88:	83 ec 04             	sub    $0x4,%esp
  801f8b:	89 f0                	mov    %esi,%eax
  801f8d:	29 d8                	sub    %ebx,%eax
  801f8f:	50                   	push   %eax
  801f90:	89 d8                	mov    %ebx,%eax
  801f92:	03 45 0c             	add    0xc(%ebp),%eax
  801f95:	50                   	push   %eax
  801f96:	57                   	push   %edi
  801f97:	e8 45 ff ff ff       	call   801ee1 <read>
		if (m < 0)
  801f9c:	83 c4 10             	add    $0x10,%esp
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	78 10                	js     801fb3 <readn+0x41>
			return m;
		if (m == 0)
  801fa3:	85 c0                	test   %eax,%eax
  801fa5:	74 0a                	je     801fb1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fa7:	01 c3                	add    %eax,%ebx
  801fa9:	39 f3                	cmp    %esi,%ebx
  801fab:	72 db                	jb     801f88 <readn+0x16>
  801fad:	89 d8                	mov    %ebx,%eax
  801faf:	eb 02                	jmp    801fb3 <readn+0x41>
  801fb1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801fb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb6:	5b                   	pop    %ebx
  801fb7:	5e                   	pop    %esi
  801fb8:	5f                   	pop    %edi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    

00801fbb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	53                   	push   %ebx
  801fbf:	83 ec 14             	sub    $0x14,%esp
  801fc2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fc5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fc8:	50                   	push   %eax
  801fc9:	53                   	push   %ebx
  801fca:	e8 ac fc ff ff       	call   801c7b <fd_lookup>
  801fcf:	83 c4 08             	add    $0x8,%esp
  801fd2:	89 c2                	mov    %eax,%edx
  801fd4:	85 c0                	test   %eax,%eax
  801fd6:	78 68                	js     802040 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fd8:	83 ec 08             	sub    $0x8,%esp
  801fdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fde:	50                   	push   %eax
  801fdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fe2:	ff 30                	pushl  (%eax)
  801fe4:	e8 e8 fc ff ff       	call   801cd1 <dev_lookup>
  801fe9:	83 c4 10             	add    $0x10,%esp
  801fec:	85 c0                	test   %eax,%eax
  801fee:	78 47                	js     802037 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ff0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ff3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ff7:	75 21                	jne    80201a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801ff9:	a1 24 54 80 00       	mov    0x805424,%eax
  801ffe:	8b 40 7c             	mov    0x7c(%eax),%eax
  802001:	83 ec 04             	sub    $0x4,%esp
  802004:	53                   	push   %ebx
  802005:	50                   	push   %eax
  802006:	68 95 39 80 00       	push   $0x803995
  80200b:	e8 01 eb ff ff       	call   800b11 <cprintf>
		return -E_INVAL;
  802010:	83 c4 10             	add    $0x10,%esp
  802013:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802018:	eb 26                	jmp    802040 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80201a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80201d:	8b 52 0c             	mov    0xc(%edx),%edx
  802020:	85 d2                	test   %edx,%edx
  802022:	74 17                	je     80203b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802024:	83 ec 04             	sub    $0x4,%esp
  802027:	ff 75 10             	pushl  0x10(%ebp)
  80202a:	ff 75 0c             	pushl  0xc(%ebp)
  80202d:	50                   	push   %eax
  80202e:	ff d2                	call   *%edx
  802030:	89 c2                	mov    %eax,%edx
  802032:	83 c4 10             	add    $0x10,%esp
  802035:	eb 09                	jmp    802040 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802037:	89 c2                	mov    %eax,%edx
  802039:	eb 05                	jmp    802040 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80203b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802040:	89 d0                	mov    %edx,%eax
  802042:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802045:	c9                   	leave  
  802046:	c3                   	ret    

00802047 <seek>:

int
seek(int fdnum, off_t offset)
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80204d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802050:	50                   	push   %eax
  802051:	ff 75 08             	pushl  0x8(%ebp)
  802054:	e8 22 fc ff ff       	call   801c7b <fd_lookup>
  802059:	83 c4 08             	add    $0x8,%esp
  80205c:	85 c0                	test   %eax,%eax
  80205e:	78 0e                	js     80206e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802060:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802063:	8b 55 0c             	mov    0xc(%ebp),%edx
  802066:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802069:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80206e:	c9                   	leave  
  80206f:	c3                   	ret    

00802070 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	53                   	push   %ebx
  802074:	83 ec 14             	sub    $0x14,%esp
  802077:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80207a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80207d:	50                   	push   %eax
  80207e:	53                   	push   %ebx
  80207f:	e8 f7 fb ff ff       	call   801c7b <fd_lookup>
  802084:	83 c4 08             	add    $0x8,%esp
  802087:	89 c2                	mov    %eax,%edx
  802089:	85 c0                	test   %eax,%eax
  80208b:	78 65                	js     8020f2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80208d:	83 ec 08             	sub    $0x8,%esp
  802090:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802093:	50                   	push   %eax
  802094:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802097:	ff 30                	pushl  (%eax)
  802099:	e8 33 fc ff ff       	call   801cd1 <dev_lookup>
  80209e:	83 c4 10             	add    $0x10,%esp
  8020a1:	85 c0                	test   %eax,%eax
  8020a3:	78 44                	js     8020e9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8020a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8020ac:	75 21                	jne    8020cf <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8020ae:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8020b3:	8b 40 7c             	mov    0x7c(%eax),%eax
  8020b6:	83 ec 04             	sub    $0x4,%esp
  8020b9:	53                   	push   %ebx
  8020ba:	50                   	push   %eax
  8020bb:	68 58 39 80 00       	push   $0x803958
  8020c0:	e8 4c ea ff ff       	call   800b11 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8020c5:	83 c4 10             	add    $0x10,%esp
  8020c8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8020cd:	eb 23                	jmp    8020f2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8020cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020d2:	8b 52 18             	mov    0x18(%edx),%edx
  8020d5:	85 d2                	test   %edx,%edx
  8020d7:	74 14                	je     8020ed <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8020d9:	83 ec 08             	sub    $0x8,%esp
  8020dc:	ff 75 0c             	pushl  0xc(%ebp)
  8020df:	50                   	push   %eax
  8020e0:	ff d2                	call   *%edx
  8020e2:	89 c2                	mov    %eax,%edx
  8020e4:	83 c4 10             	add    $0x10,%esp
  8020e7:	eb 09                	jmp    8020f2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020e9:	89 c2                	mov    %eax,%edx
  8020eb:	eb 05                	jmp    8020f2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8020ed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8020f2:	89 d0                	mov    %edx,%eax
  8020f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020f7:	c9                   	leave  
  8020f8:	c3                   	ret    

008020f9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8020f9:	55                   	push   %ebp
  8020fa:	89 e5                	mov    %esp,%ebp
  8020fc:	53                   	push   %ebx
  8020fd:	83 ec 14             	sub    $0x14,%esp
  802100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802103:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802106:	50                   	push   %eax
  802107:	ff 75 08             	pushl  0x8(%ebp)
  80210a:	e8 6c fb ff ff       	call   801c7b <fd_lookup>
  80210f:	83 c4 08             	add    $0x8,%esp
  802112:	89 c2                	mov    %eax,%edx
  802114:	85 c0                	test   %eax,%eax
  802116:	78 58                	js     802170 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802118:	83 ec 08             	sub    $0x8,%esp
  80211b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211e:	50                   	push   %eax
  80211f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802122:	ff 30                	pushl  (%eax)
  802124:	e8 a8 fb ff ff       	call   801cd1 <dev_lookup>
  802129:	83 c4 10             	add    $0x10,%esp
  80212c:	85 c0                	test   %eax,%eax
  80212e:	78 37                	js     802167 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802130:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802133:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802137:	74 32                	je     80216b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802139:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80213c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802143:	00 00 00 
	stat->st_isdir = 0;
  802146:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80214d:	00 00 00 
	stat->st_dev = dev;
  802150:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802156:	83 ec 08             	sub    $0x8,%esp
  802159:	53                   	push   %ebx
  80215a:	ff 75 f0             	pushl  -0x10(%ebp)
  80215d:	ff 50 14             	call   *0x14(%eax)
  802160:	89 c2                	mov    %eax,%edx
  802162:	83 c4 10             	add    $0x10,%esp
  802165:	eb 09                	jmp    802170 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802167:	89 c2                	mov    %eax,%edx
  802169:	eb 05                	jmp    802170 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80216b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802170:	89 d0                	mov    %edx,%eax
  802172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802175:	c9                   	leave  
  802176:	c3                   	ret    

00802177 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802177:	55                   	push   %ebp
  802178:	89 e5                	mov    %esp,%ebp
  80217a:	56                   	push   %esi
  80217b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80217c:	83 ec 08             	sub    $0x8,%esp
  80217f:	6a 00                	push   $0x0
  802181:	ff 75 08             	pushl  0x8(%ebp)
  802184:	e8 e3 01 00 00       	call   80236c <open>
  802189:	89 c3                	mov    %eax,%ebx
  80218b:	83 c4 10             	add    $0x10,%esp
  80218e:	85 c0                	test   %eax,%eax
  802190:	78 1b                	js     8021ad <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802192:	83 ec 08             	sub    $0x8,%esp
  802195:	ff 75 0c             	pushl  0xc(%ebp)
  802198:	50                   	push   %eax
  802199:	e8 5b ff ff ff       	call   8020f9 <fstat>
  80219e:	89 c6                	mov    %eax,%esi
	close(fd);
  8021a0:	89 1c 24             	mov    %ebx,(%esp)
  8021a3:	e8 fd fb ff ff       	call   801da5 <close>
	return r;
  8021a8:	83 c4 10             	add    $0x10,%esp
  8021ab:	89 f0                	mov    %esi,%eax
}
  8021ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021b0:	5b                   	pop    %ebx
  8021b1:	5e                   	pop    %esi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    

008021b4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8021b4:	55                   	push   %ebp
  8021b5:	89 e5                	mov    %esp,%ebp
  8021b7:	56                   	push   %esi
  8021b8:	53                   	push   %ebx
  8021b9:	89 c6                	mov    %eax,%esi
  8021bb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8021bd:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  8021c4:	75 12                	jne    8021d8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8021c6:	83 ec 0c             	sub    $0xc,%esp
  8021c9:	6a 01                	push   $0x1
  8021cb:	e8 5b 0e 00 00       	call   80302b <ipc_find_env>
  8021d0:	a3 20 54 80 00       	mov    %eax,0x805420
  8021d5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021d8:	6a 07                	push   $0x7
  8021da:	68 00 60 80 00       	push   $0x806000
  8021df:	56                   	push   %esi
  8021e0:	ff 35 20 54 80 00    	pushl  0x805420
  8021e6:	e8 de 0d 00 00       	call   802fc9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021eb:	83 c4 0c             	add    $0xc,%esp
  8021ee:	6a 00                	push   $0x0
  8021f0:	53                   	push   %ebx
  8021f1:	6a 00                	push   $0x0
  8021f3:	e8 56 0d 00 00       	call   802f4e <ipc_recv>
}
  8021f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021fb:	5b                   	pop    %ebx
  8021fc:	5e                   	pop    %esi
  8021fd:	5d                   	pop    %ebp
  8021fe:	c3                   	ret    

008021ff <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8021ff:	55                   	push   %ebp
  802200:	89 e5                	mov    %esp,%ebp
  802202:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802205:	8b 45 08             	mov    0x8(%ebp),%eax
  802208:	8b 40 0c             	mov    0xc(%eax),%eax
  80220b:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802210:	8b 45 0c             	mov    0xc(%ebp),%eax
  802213:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802218:	ba 00 00 00 00       	mov    $0x0,%edx
  80221d:	b8 02 00 00 00       	mov    $0x2,%eax
  802222:	e8 8d ff ff ff       	call   8021b4 <fsipc>
}
  802227:	c9                   	leave  
  802228:	c3                   	ret    

00802229 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802229:	55                   	push   %ebp
  80222a:	89 e5                	mov    %esp,%ebp
  80222c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80222f:	8b 45 08             	mov    0x8(%ebp),%eax
  802232:	8b 40 0c             	mov    0xc(%eax),%eax
  802235:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80223a:	ba 00 00 00 00       	mov    $0x0,%edx
  80223f:	b8 06 00 00 00       	mov    $0x6,%eax
  802244:	e8 6b ff ff ff       	call   8021b4 <fsipc>
}
  802249:	c9                   	leave  
  80224a:	c3                   	ret    

0080224b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80224b:	55                   	push   %ebp
  80224c:	89 e5                	mov    %esp,%ebp
  80224e:	53                   	push   %ebx
  80224f:	83 ec 04             	sub    $0x4,%esp
  802252:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802255:	8b 45 08             	mov    0x8(%ebp),%eax
  802258:	8b 40 0c             	mov    0xc(%eax),%eax
  80225b:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802260:	ba 00 00 00 00       	mov    $0x0,%edx
  802265:	b8 05 00 00 00       	mov    $0x5,%eax
  80226a:	e8 45 ff ff ff       	call   8021b4 <fsipc>
  80226f:	85 c0                	test   %eax,%eax
  802271:	78 2c                	js     80229f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802273:	83 ec 08             	sub    $0x8,%esp
  802276:	68 00 60 80 00       	push   $0x806000
  80227b:	53                   	push   %ebx
  80227c:	e8 08 ef ff ff       	call   801189 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802281:	a1 80 60 80 00       	mov    0x806080,%eax
  802286:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80228c:	a1 84 60 80 00       	mov    0x806084,%eax
  802291:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802297:	83 c4 10             	add    $0x10,%esp
  80229a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80229f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022a2:	c9                   	leave  
  8022a3:	c3                   	ret    

008022a4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8022a4:	55                   	push   %ebp
  8022a5:	89 e5                	mov    %esp,%ebp
  8022a7:	83 ec 0c             	sub    $0xc,%esp
  8022aa:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8022ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8022b0:	8b 52 0c             	mov    0xc(%edx),%edx
  8022b3:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8022b9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8022be:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8022c3:	0f 47 c2             	cmova  %edx,%eax
  8022c6:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8022cb:	50                   	push   %eax
  8022cc:	ff 75 0c             	pushl  0xc(%ebp)
  8022cf:	68 08 60 80 00       	push   $0x806008
  8022d4:	e8 42 f0 ff ff       	call   80131b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8022d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8022de:	b8 04 00 00 00       	mov    $0x4,%eax
  8022e3:	e8 cc fe ff ff       	call   8021b4 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8022e8:	c9                   	leave  
  8022e9:	c3                   	ret    

008022ea <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
  8022ed:	56                   	push   %esi
  8022ee:	53                   	push   %ebx
  8022ef:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8022f8:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8022fd:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802303:	ba 00 00 00 00       	mov    $0x0,%edx
  802308:	b8 03 00 00 00       	mov    $0x3,%eax
  80230d:	e8 a2 fe ff ff       	call   8021b4 <fsipc>
  802312:	89 c3                	mov    %eax,%ebx
  802314:	85 c0                	test   %eax,%eax
  802316:	78 4b                	js     802363 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802318:	39 c6                	cmp    %eax,%esi
  80231a:	73 16                	jae    802332 <devfile_read+0x48>
  80231c:	68 c4 39 80 00       	push   $0x8039c4
  802321:	68 8f 34 80 00       	push   $0x80348f
  802326:	6a 7c                	push   $0x7c
  802328:	68 cb 39 80 00       	push   $0x8039cb
  80232d:	e8 06 e7 ff ff       	call   800a38 <_panic>
	assert(r <= PGSIZE);
  802332:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802337:	7e 16                	jle    80234f <devfile_read+0x65>
  802339:	68 d6 39 80 00       	push   $0x8039d6
  80233e:	68 8f 34 80 00       	push   $0x80348f
  802343:	6a 7d                	push   $0x7d
  802345:	68 cb 39 80 00       	push   $0x8039cb
  80234a:	e8 e9 e6 ff ff       	call   800a38 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80234f:	83 ec 04             	sub    $0x4,%esp
  802352:	50                   	push   %eax
  802353:	68 00 60 80 00       	push   $0x806000
  802358:	ff 75 0c             	pushl  0xc(%ebp)
  80235b:	e8 bb ef ff ff       	call   80131b <memmove>
	return r;
  802360:	83 c4 10             	add    $0x10,%esp
}
  802363:	89 d8                	mov    %ebx,%eax
  802365:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802368:	5b                   	pop    %ebx
  802369:	5e                   	pop    %esi
  80236a:	5d                   	pop    %ebp
  80236b:	c3                   	ret    

0080236c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80236c:	55                   	push   %ebp
  80236d:	89 e5                	mov    %esp,%ebp
  80236f:	53                   	push   %ebx
  802370:	83 ec 20             	sub    $0x20,%esp
  802373:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802376:	53                   	push   %ebx
  802377:	e8 d4 ed ff ff       	call   801150 <strlen>
  80237c:	83 c4 10             	add    $0x10,%esp
  80237f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802384:	7f 67                	jg     8023ed <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802386:	83 ec 0c             	sub    $0xc,%esp
  802389:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80238c:	50                   	push   %eax
  80238d:	e8 9a f8 ff ff       	call   801c2c <fd_alloc>
  802392:	83 c4 10             	add    $0x10,%esp
		return r;
  802395:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802397:	85 c0                	test   %eax,%eax
  802399:	78 57                	js     8023f2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80239b:	83 ec 08             	sub    $0x8,%esp
  80239e:	53                   	push   %ebx
  80239f:	68 00 60 80 00       	push   $0x806000
  8023a4:	e8 e0 ed ff ff       	call   801189 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8023a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023ac:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8023b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b9:	e8 f6 fd ff ff       	call   8021b4 <fsipc>
  8023be:	89 c3                	mov    %eax,%ebx
  8023c0:	83 c4 10             	add    $0x10,%esp
  8023c3:	85 c0                	test   %eax,%eax
  8023c5:	79 14                	jns    8023db <open+0x6f>
		fd_close(fd, 0);
  8023c7:	83 ec 08             	sub    $0x8,%esp
  8023ca:	6a 00                	push   $0x0
  8023cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8023cf:	e8 50 f9 ff ff       	call   801d24 <fd_close>
		return r;
  8023d4:	83 c4 10             	add    $0x10,%esp
  8023d7:	89 da                	mov    %ebx,%edx
  8023d9:	eb 17                	jmp    8023f2 <open+0x86>
	}

	return fd2num(fd);
  8023db:	83 ec 0c             	sub    $0xc,%esp
  8023de:	ff 75 f4             	pushl  -0xc(%ebp)
  8023e1:	e8 1f f8 ff ff       	call   801c05 <fd2num>
  8023e6:	89 c2                	mov    %eax,%edx
  8023e8:	83 c4 10             	add    $0x10,%esp
  8023eb:	eb 05                	jmp    8023f2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8023ed:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8023f2:	89 d0                	mov    %edx,%eax
  8023f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023f7:	c9                   	leave  
  8023f8:	c3                   	ret    

008023f9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8023f9:	55                   	push   %ebp
  8023fa:	89 e5                	mov    %esp,%ebp
  8023fc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8023ff:	ba 00 00 00 00       	mov    $0x0,%edx
  802404:	b8 08 00 00 00       	mov    $0x8,%eax
  802409:	e8 a6 fd ff ff       	call   8021b4 <fsipc>
}
  80240e:	c9                   	leave  
  80240f:	c3                   	ret    

00802410 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802410:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802414:	7e 37                	jle    80244d <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  802416:	55                   	push   %ebp
  802417:	89 e5                	mov    %esp,%ebp
  802419:	53                   	push   %ebx
  80241a:	83 ec 08             	sub    $0x8,%esp
  80241d:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80241f:	ff 70 04             	pushl  0x4(%eax)
  802422:	8d 40 10             	lea    0x10(%eax),%eax
  802425:	50                   	push   %eax
  802426:	ff 33                	pushl  (%ebx)
  802428:	e8 8e fb ff ff       	call   801fbb <write>
		if (result > 0)
  80242d:	83 c4 10             	add    $0x10,%esp
  802430:	85 c0                	test   %eax,%eax
  802432:	7e 03                	jle    802437 <writebuf+0x27>
			b->result += result;
  802434:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802437:	3b 43 04             	cmp    0x4(%ebx),%eax
  80243a:	74 0d                	je     802449 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80243c:	85 c0                	test   %eax,%eax
  80243e:	ba 00 00 00 00       	mov    $0x0,%edx
  802443:	0f 4f c2             	cmovg  %edx,%eax
  802446:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802449:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80244c:	c9                   	leave  
  80244d:	f3 c3                	repz ret 

0080244f <putch>:

static void
putch(int ch, void *thunk)
{
  80244f:	55                   	push   %ebp
  802450:	89 e5                	mov    %esp,%ebp
  802452:	53                   	push   %ebx
  802453:	83 ec 04             	sub    $0x4,%esp
  802456:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802459:	8b 53 04             	mov    0x4(%ebx),%edx
  80245c:	8d 42 01             	lea    0x1(%edx),%eax
  80245f:	89 43 04             	mov    %eax,0x4(%ebx)
  802462:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802465:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802469:	3d 00 01 00 00       	cmp    $0x100,%eax
  80246e:	75 0e                	jne    80247e <putch+0x2f>
		writebuf(b);
  802470:	89 d8                	mov    %ebx,%eax
  802472:	e8 99 ff ff ff       	call   802410 <writebuf>
		b->idx = 0;
  802477:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80247e:	83 c4 04             	add    $0x4,%esp
  802481:	5b                   	pop    %ebx
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    

00802484 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802484:	55                   	push   %ebp
  802485:	89 e5                	mov    %esp,%ebp
  802487:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80248d:	8b 45 08             	mov    0x8(%ebp),%eax
  802490:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802496:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80249d:	00 00 00 
	b.result = 0;
  8024a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8024a7:	00 00 00 
	b.error = 1;
  8024aa:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8024b1:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8024b4:	ff 75 10             	pushl  0x10(%ebp)
  8024b7:	ff 75 0c             	pushl  0xc(%ebp)
  8024ba:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024c0:	50                   	push   %eax
  8024c1:	68 4f 24 80 00       	push   $0x80244f
  8024c6:	e8 7d e7 ff ff       	call   800c48 <vprintfmt>
	if (b.idx > 0)
  8024cb:	83 c4 10             	add    $0x10,%esp
  8024ce:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024d5:	7e 0b                	jle    8024e2 <vfprintf+0x5e>
		writebuf(&b);
  8024d7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024dd:	e8 2e ff ff ff       	call   802410 <writebuf>

	return (b.result ? b.result : b.error);
  8024e2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8024e8:	85 c0                	test   %eax,%eax
  8024ea:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8024f1:	c9                   	leave  
  8024f2:	c3                   	ret    

008024f3 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8024f3:	55                   	push   %ebp
  8024f4:	89 e5                	mov    %esp,%ebp
  8024f6:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024f9:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8024fc:	50                   	push   %eax
  8024fd:	ff 75 0c             	pushl  0xc(%ebp)
  802500:	ff 75 08             	pushl  0x8(%ebp)
  802503:	e8 7c ff ff ff       	call   802484 <vfprintf>
	va_end(ap);

	return cnt;
}
  802508:	c9                   	leave  
  802509:	c3                   	ret    

0080250a <printf>:

int
printf(const char *fmt, ...)
{
  80250a:	55                   	push   %ebp
  80250b:	89 e5                	mov    %esp,%ebp
  80250d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802510:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802513:	50                   	push   %eax
  802514:	ff 75 08             	pushl  0x8(%ebp)
  802517:	6a 01                	push   $0x1
  802519:	e8 66 ff ff ff       	call   802484 <vfprintf>
	va_end(ap);

	return cnt;
}
  80251e:	c9                   	leave  
  80251f:	c3                   	ret    

00802520 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802520:	55                   	push   %ebp
  802521:	89 e5                	mov    %esp,%ebp
  802523:	57                   	push   %edi
  802524:	56                   	push   %esi
  802525:	53                   	push   %ebx
  802526:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80252c:	6a 00                	push   $0x0
  80252e:	ff 75 08             	pushl  0x8(%ebp)
  802531:	e8 36 fe ff ff       	call   80236c <open>
  802536:	89 c7                	mov    %eax,%edi
  802538:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80253e:	83 c4 10             	add    $0x10,%esp
  802541:	85 c0                	test   %eax,%eax
  802543:	0f 88 8c 04 00 00    	js     8029d5 <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802549:	83 ec 04             	sub    $0x4,%esp
  80254c:	68 00 02 00 00       	push   $0x200
  802551:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802557:	50                   	push   %eax
  802558:	57                   	push   %edi
  802559:	e8 14 fa ff ff       	call   801f72 <readn>
  80255e:	83 c4 10             	add    $0x10,%esp
  802561:	3d 00 02 00 00       	cmp    $0x200,%eax
  802566:	75 0c                	jne    802574 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  802568:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80256f:	45 4c 46 
  802572:	74 33                	je     8025a7 <spawn+0x87>
		close(fd);
  802574:	83 ec 0c             	sub    $0xc,%esp
  802577:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80257d:	e8 23 f8 ff ff       	call   801da5 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802582:	83 c4 0c             	add    $0xc,%esp
  802585:	68 7f 45 4c 46       	push   $0x464c457f
  80258a:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802590:	68 e2 39 80 00       	push   $0x8039e2
  802595:	e8 77 e5 ff ff       	call   800b11 <cprintf>
		return -E_NOT_EXEC;
  80259a:	83 c4 10             	add    $0x10,%esp
  80259d:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8025a2:	e9 e1 04 00 00       	jmp    802a88 <spawn+0x568>
  8025a7:	b8 07 00 00 00       	mov    $0x7,%eax
  8025ac:	cd 30                	int    $0x30
  8025ae:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8025b4:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8025ba:	85 c0                	test   %eax,%eax
  8025bc:	0f 88 1e 04 00 00    	js     8029e0 <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8025c2:	89 c6                	mov    %eax,%esi
  8025c4:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8025ca:	69 f6 b0 00 00 00    	imul   $0xb0,%esi,%esi
  8025d0:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8025d6:	81 c6 34 00 c0 ee    	add    $0xeec00034,%esi
  8025dc:	b9 11 00 00 00       	mov    $0x11,%ecx
  8025e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8025e3:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8025e9:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025ef:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8025f4:	be 00 00 00 00       	mov    $0x0,%esi
  8025f9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025fc:	eb 13                	jmp    802611 <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8025fe:	83 ec 0c             	sub    $0xc,%esp
  802601:	50                   	push   %eax
  802602:	e8 49 eb ff ff       	call   801150 <strlen>
  802607:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80260b:	83 c3 01             	add    $0x1,%ebx
  80260e:	83 c4 10             	add    $0x10,%esp
  802611:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802618:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80261b:	85 c0                	test   %eax,%eax
  80261d:	75 df                	jne    8025fe <spawn+0xde>
  80261f:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802625:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80262b:	bf 00 10 40 00       	mov    $0x401000,%edi
  802630:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802632:	89 fa                	mov    %edi,%edx
  802634:	83 e2 fc             	and    $0xfffffffc,%edx
  802637:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80263e:	29 c2                	sub    %eax,%edx
  802640:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802646:	8d 42 f8             	lea    -0x8(%edx),%eax
  802649:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80264e:	0f 86 a2 03 00 00    	jbe    8029f6 <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802654:	83 ec 04             	sub    $0x4,%esp
  802657:	6a 07                	push   $0x7
  802659:	68 00 00 40 00       	push   $0x400000
  80265e:	6a 00                	push   $0x0
  802660:	e8 27 ef ff ff       	call   80158c <sys_page_alloc>
  802665:	83 c4 10             	add    $0x10,%esp
  802668:	85 c0                	test   %eax,%eax
  80266a:	0f 88 90 03 00 00    	js     802a00 <spawn+0x4e0>
  802670:	be 00 00 00 00       	mov    $0x0,%esi
  802675:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80267b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80267e:	eb 30                	jmp    8026b0 <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802680:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802686:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80268c:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  80268f:	83 ec 08             	sub    $0x8,%esp
  802692:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802695:	57                   	push   %edi
  802696:	e8 ee ea ff ff       	call   801189 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80269b:	83 c4 04             	add    $0x4,%esp
  80269e:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8026a1:	e8 aa ea ff ff       	call   801150 <strlen>
  8026a6:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8026aa:	83 c6 01             	add    $0x1,%esi
  8026ad:	83 c4 10             	add    $0x10,%esp
  8026b0:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8026b6:	7f c8                	jg     802680 <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8026b8:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8026be:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8026c4:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8026cb:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8026d1:	74 19                	je     8026ec <spawn+0x1cc>
  8026d3:	68 6c 3a 80 00       	push   $0x803a6c
  8026d8:	68 8f 34 80 00       	push   $0x80348f
  8026dd:	68 f2 00 00 00       	push   $0xf2
  8026e2:	68 fc 39 80 00       	push   $0x8039fc
  8026e7:	e8 4c e3 ff ff       	call   800a38 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8026ec:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8026f2:	89 f8                	mov    %edi,%eax
  8026f4:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8026f9:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8026fc:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802702:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802705:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  80270b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802711:	83 ec 0c             	sub    $0xc,%esp
  802714:	6a 07                	push   $0x7
  802716:	68 00 d0 bf ee       	push   $0xeebfd000
  80271b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802721:	68 00 00 40 00       	push   $0x400000
  802726:	6a 00                	push   $0x0
  802728:	e8 a2 ee ff ff       	call   8015cf <sys_page_map>
  80272d:	89 c3                	mov    %eax,%ebx
  80272f:	83 c4 20             	add    $0x20,%esp
  802732:	85 c0                	test   %eax,%eax
  802734:	0f 88 3c 03 00 00    	js     802a76 <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80273a:	83 ec 08             	sub    $0x8,%esp
  80273d:	68 00 00 40 00       	push   $0x400000
  802742:	6a 00                	push   $0x0
  802744:	e8 c8 ee ff ff       	call   801611 <sys_page_unmap>
  802749:	89 c3                	mov    %eax,%ebx
  80274b:	83 c4 10             	add    $0x10,%esp
  80274e:	85 c0                	test   %eax,%eax
  802750:	0f 88 20 03 00 00    	js     802a76 <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802756:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80275c:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802763:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802769:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802770:	00 00 00 
  802773:	e9 88 01 00 00       	jmp    802900 <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  802778:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80277e:	83 38 01             	cmpl   $0x1,(%eax)
  802781:	0f 85 6b 01 00 00    	jne    8028f2 <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802787:	89 c2                	mov    %eax,%edx
  802789:	8b 40 18             	mov    0x18(%eax),%eax
  80278c:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802792:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802795:	83 f8 01             	cmp    $0x1,%eax
  802798:	19 c0                	sbb    %eax,%eax
  80279a:	83 e0 fe             	and    $0xfffffffe,%eax
  80279d:	83 c0 07             	add    $0x7,%eax
  8027a0:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8027a6:	89 d0                	mov    %edx,%eax
  8027a8:	8b 7a 04             	mov    0x4(%edx),%edi
  8027ab:	89 f9                	mov    %edi,%ecx
  8027ad:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8027b3:	8b 7a 10             	mov    0x10(%edx),%edi
  8027b6:	8b 52 14             	mov    0x14(%edx),%edx
  8027b9:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  8027bf:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8027c2:	89 f0                	mov    %esi,%eax
  8027c4:	25 ff 0f 00 00       	and    $0xfff,%eax
  8027c9:	74 14                	je     8027df <spawn+0x2bf>
		va -= i;
  8027cb:	29 c6                	sub    %eax,%esi
		memsz += i;
  8027cd:	01 c2                	add    %eax,%edx
  8027cf:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8027d5:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8027d7:	29 c1                	sub    %eax,%ecx
  8027d9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8027df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027e4:	e9 f7 00 00 00       	jmp    8028e0 <spawn+0x3c0>
		if (i >= filesz) {
  8027e9:	39 fb                	cmp    %edi,%ebx
  8027eb:	72 27                	jb     802814 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8027ed:	83 ec 04             	sub    $0x4,%esp
  8027f0:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8027f6:	56                   	push   %esi
  8027f7:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8027fd:	e8 8a ed ff ff       	call   80158c <sys_page_alloc>
  802802:	83 c4 10             	add    $0x10,%esp
  802805:	85 c0                	test   %eax,%eax
  802807:	0f 89 c7 00 00 00    	jns    8028d4 <spawn+0x3b4>
  80280d:	89 c3                	mov    %eax,%ebx
  80280f:	e9 fd 01 00 00       	jmp    802a11 <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802814:	83 ec 04             	sub    $0x4,%esp
  802817:	6a 07                	push   $0x7
  802819:	68 00 00 40 00       	push   $0x400000
  80281e:	6a 00                	push   $0x0
  802820:	e8 67 ed ff ff       	call   80158c <sys_page_alloc>
  802825:	83 c4 10             	add    $0x10,%esp
  802828:	85 c0                	test   %eax,%eax
  80282a:	0f 88 d7 01 00 00    	js     802a07 <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802830:	83 ec 08             	sub    $0x8,%esp
  802833:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802839:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80283f:	50                   	push   %eax
  802840:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802846:	e8 fc f7 ff ff       	call   802047 <seek>
  80284b:	83 c4 10             	add    $0x10,%esp
  80284e:	85 c0                	test   %eax,%eax
  802850:	0f 88 b5 01 00 00    	js     802a0b <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802856:	83 ec 04             	sub    $0x4,%esp
  802859:	89 f8                	mov    %edi,%eax
  80285b:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  802861:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802866:	ba 00 10 00 00       	mov    $0x1000,%edx
  80286b:	0f 47 c2             	cmova  %edx,%eax
  80286e:	50                   	push   %eax
  80286f:	68 00 00 40 00       	push   $0x400000
  802874:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80287a:	e8 f3 f6 ff ff       	call   801f72 <readn>
  80287f:	83 c4 10             	add    $0x10,%esp
  802882:	85 c0                	test   %eax,%eax
  802884:	0f 88 85 01 00 00    	js     802a0f <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80288a:	83 ec 0c             	sub    $0xc,%esp
  80288d:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802893:	56                   	push   %esi
  802894:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80289a:	68 00 00 40 00       	push   $0x400000
  80289f:	6a 00                	push   $0x0
  8028a1:	e8 29 ed ff ff       	call   8015cf <sys_page_map>
  8028a6:	83 c4 20             	add    $0x20,%esp
  8028a9:	85 c0                	test   %eax,%eax
  8028ab:	79 15                	jns    8028c2 <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  8028ad:	50                   	push   %eax
  8028ae:	68 08 3a 80 00       	push   $0x803a08
  8028b3:	68 25 01 00 00       	push   $0x125
  8028b8:	68 fc 39 80 00       	push   $0x8039fc
  8028bd:	e8 76 e1 ff ff       	call   800a38 <_panic>
			sys_page_unmap(0, UTEMP);
  8028c2:	83 ec 08             	sub    $0x8,%esp
  8028c5:	68 00 00 40 00       	push   $0x400000
  8028ca:	6a 00                	push   $0x0
  8028cc:	e8 40 ed ff ff       	call   801611 <sys_page_unmap>
  8028d1:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8028d4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8028da:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8028e0:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8028e6:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8028ec:	0f 82 f7 fe ff ff    	jb     8027e9 <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028f2:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8028f9:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802900:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802907:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  80290d:	0f 8c 65 fe ff ff    	jl     802778 <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802913:	83 ec 0c             	sub    $0xc,%esp
  802916:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80291c:	e8 84 f4 ff ff       	call   801da5 <close>
  802921:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802924:	bb 00 00 00 00       	mov    $0x0,%ebx
  802929:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  80292f:	89 d8                	mov    %ebx,%eax
  802931:	c1 e8 16             	shr    $0x16,%eax
  802934:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80293b:	a8 01                	test   $0x1,%al
  80293d:	74 42                	je     802981 <spawn+0x461>
  80293f:	89 d8                	mov    %ebx,%eax
  802941:	c1 e8 0c             	shr    $0xc,%eax
  802944:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80294b:	f6 c2 01             	test   $0x1,%dl
  80294e:	74 31                	je     802981 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  802950:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  802957:	f6 c6 04             	test   $0x4,%dh
  80295a:	74 25                	je     802981 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  80295c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802963:	83 ec 0c             	sub    $0xc,%esp
  802966:	25 07 0e 00 00       	and    $0xe07,%eax
  80296b:	50                   	push   %eax
  80296c:	53                   	push   %ebx
  80296d:	56                   	push   %esi
  80296e:	53                   	push   %ebx
  80296f:	6a 00                	push   $0x0
  802971:	e8 59 ec ff ff       	call   8015cf <sys_page_map>
			if (r < 0) {
  802976:	83 c4 20             	add    $0x20,%esp
  802979:	85 c0                	test   %eax,%eax
  80297b:	0f 88 b1 00 00 00    	js     802a32 <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802981:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802987:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80298d:	75 a0                	jne    80292f <spawn+0x40f>
  80298f:	e9 b3 00 00 00       	jmp    802a47 <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802994:	50                   	push   %eax
  802995:	68 25 3a 80 00       	push   $0x803a25
  80299a:	68 86 00 00 00       	push   $0x86
  80299f:	68 fc 39 80 00       	push   $0x8039fc
  8029a4:	e8 8f e0 ff ff       	call   800a38 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8029a9:	83 ec 08             	sub    $0x8,%esp
  8029ac:	6a 02                	push   $0x2
  8029ae:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029b4:	e8 9a ec ff ff       	call   801653 <sys_env_set_status>
  8029b9:	83 c4 10             	add    $0x10,%esp
  8029bc:	85 c0                	test   %eax,%eax
  8029be:	79 2b                	jns    8029eb <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  8029c0:	50                   	push   %eax
  8029c1:	68 3f 3a 80 00       	push   $0x803a3f
  8029c6:	68 89 00 00 00       	push   $0x89
  8029cb:	68 fc 39 80 00       	push   $0x8039fc
  8029d0:	e8 63 e0 ff ff       	call   800a38 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8029d5:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8029db:	e9 a8 00 00 00       	jmp    802a88 <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8029e0:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029e6:	e9 9d 00 00 00       	jmp    802a88 <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8029eb:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029f1:	e9 92 00 00 00       	jmp    802a88 <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8029f6:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8029fb:	e9 88 00 00 00       	jmp    802a88 <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802a00:	89 c3                	mov    %eax,%ebx
  802a02:	e9 81 00 00 00       	jmp    802a88 <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802a07:	89 c3                	mov    %eax,%ebx
  802a09:	eb 06                	jmp    802a11 <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802a0b:	89 c3                	mov    %eax,%ebx
  802a0d:	eb 02                	jmp    802a11 <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802a0f:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802a11:	83 ec 0c             	sub    $0xc,%esp
  802a14:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a1a:	e8 ee ea ff ff       	call   80150d <sys_env_destroy>
	close(fd);
  802a1f:	83 c4 04             	add    $0x4,%esp
  802a22:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a28:	e8 78 f3 ff ff       	call   801da5 <close>
	return r;
  802a2d:	83 c4 10             	add    $0x10,%esp
  802a30:	eb 56                	jmp    802a88 <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802a32:	50                   	push   %eax
  802a33:	68 56 3a 80 00       	push   $0x803a56
  802a38:	68 82 00 00 00       	push   $0x82
  802a3d:	68 fc 39 80 00       	push   $0x8039fc
  802a42:	e8 f1 df ff ff       	call   800a38 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802a47:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802a4e:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802a51:	83 ec 08             	sub    $0x8,%esp
  802a54:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a5a:	50                   	push   %eax
  802a5b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a61:	e8 2f ec ff ff       	call   801695 <sys_env_set_trapframe>
  802a66:	83 c4 10             	add    $0x10,%esp
  802a69:	85 c0                	test   %eax,%eax
  802a6b:	0f 89 38 ff ff ff    	jns    8029a9 <spawn+0x489>
  802a71:	e9 1e ff ff ff       	jmp    802994 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802a76:	83 ec 08             	sub    $0x8,%esp
  802a79:	68 00 00 40 00       	push   $0x400000
  802a7e:	6a 00                	push   $0x0
  802a80:	e8 8c eb ff ff       	call   801611 <sys_page_unmap>
  802a85:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802a88:	89 d8                	mov    %ebx,%eax
  802a8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a8d:	5b                   	pop    %ebx
  802a8e:	5e                   	pop    %esi
  802a8f:	5f                   	pop    %edi
  802a90:	5d                   	pop    %ebp
  802a91:	c3                   	ret    

00802a92 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802a92:	55                   	push   %ebp
  802a93:	89 e5                	mov    %esp,%ebp
  802a95:	56                   	push   %esi
  802a96:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a97:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802a9a:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a9f:	eb 03                	jmp    802aa4 <spawnl+0x12>
		argc++;
  802aa1:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802aa4:	83 c2 04             	add    $0x4,%edx
  802aa7:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802aab:	75 f4                	jne    802aa1 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802aad:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802ab4:	83 e2 f0             	and    $0xfffffff0,%edx
  802ab7:	29 d4                	sub    %edx,%esp
  802ab9:	8d 54 24 03          	lea    0x3(%esp),%edx
  802abd:	c1 ea 02             	shr    $0x2,%edx
  802ac0:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802ac7:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802ac9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802acc:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802ad3:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802ada:	00 
  802adb:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802add:	b8 00 00 00 00       	mov    $0x0,%eax
  802ae2:	eb 0a                	jmp    802aee <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802ae4:	83 c0 01             	add    $0x1,%eax
  802ae7:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802aeb:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802aee:	39 d0                	cmp    %edx,%eax
  802af0:	75 f2                	jne    802ae4 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802af2:	83 ec 08             	sub    $0x8,%esp
  802af5:	56                   	push   %esi
  802af6:	ff 75 08             	pushl  0x8(%ebp)
  802af9:	e8 22 fa ff ff       	call   802520 <spawn>
}
  802afe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b01:	5b                   	pop    %ebx
  802b02:	5e                   	pop    %esi
  802b03:	5d                   	pop    %ebp
  802b04:	c3                   	ret    

00802b05 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802b05:	55                   	push   %ebp
  802b06:	89 e5                	mov    %esp,%ebp
  802b08:	56                   	push   %esi
  802b09:	53                   	push   %ebx
  802b0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802b0d:	83 ec 0c             	sub    $0xc,%esp
  802b10:	ff 75 08             	pushl  0x8(%ebp)
  802b13:	e8 fd f0 ff ff       	call   801c15 <fd2data>
  802b18:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802b1a:	83 c4 08             	add    $0x8,%esp
  802b1d:	68 94 3a 80 00       	push   $0x803a94
  802b22:	53                   	push   %ebx
  802b23:	e8 61 e6 ff ff       	call   801189 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802b28:	8b 46 04             	mov    0x4(%esi),%eax
  802b2b:	2b 06                	sub    (%esi),%eax
  802b2d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802b33:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802b3a:	00 00 00 
	stat->st_dev = &devpipe;
  802b3d:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802b44:	40 80 00 
	return 0;
}
  802b47:	b8 00 00 00 00       	mov    $0x0,%eax
  802b4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b4f:	5b                   	pop    %ebx
  802b50:	5e                   	pop    %esi
  802b51:	5d                   	pop    %ebp
  802b52:	c3                   	ret    

00802b53 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802b53:	55                   	push   %ebp
  802b54:	89 e5                	mov    %esp,%ebp
  802b56:	53                   	push   %ebx
  802b57:	83 ec 0c             	sub    $0xc,%esp
  802b5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b5d:	53                   	push   %ebx
  802b5e:	6a 00                	push   $0x0
  802b60:	e8 ac ea ff ff       	call   801611 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b65:	89 1c 24             	mov    %ebx,(%esp)
  802b68:	e8 a8 f0 ff ff       	call   801c15 <fd2data>
  802b6d:	83 c4 08             	add    $0x8,%esp
  802b70:	50                   	push   %eax
  802b71:	6a 00                	push   $0x0
  802b73:	e8 99 ea ff ff       	call   801611 <sys_page_unmap>
}
  802b78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b7b:	c9                   	leave  
  802b7c:	c3                   	ret    

00802b7d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b7d:	55                   	push   %ebp
  802b7e:	89 e5                	mov    %esp,%ebp
  802b80:	57                   	push   %edi
  802b81:	56                   	push   %esi
  802b82:	53                   	push   %ebx
  802b83:	83 ec 1c             	sub    $0x1c,%esp
  802b86:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802b89:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802b8b:	a1 24 54 80 00       	mov    0x805424,%eax
  802b90:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802b96:	83 ec 0c             	sub    $0xc,%esp
  802b99:	ff 75 e0             	pushl  -0x20(%ebp)
  802b9c:	e8 cc 04 00 00       	call   80306d <pageref>
  802ba1:	89 c3                	mov    %eax,%ebx
  802ba3:	89 3c 24             	mov    %edi,(%esp)
  802ba6:	e8 c2 04 00 00       	call   80306d <pageref>
  802bab:	83 c4 10             	add    $0x10,%esp
  802bae:	39 c3                	cmp    %eax,%ebx
  802bb0:	0f 94 c1             	sete   %cl
  802bb3:	0f b6 c9             	movzbl %cl,%ecx
  802bb6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802bb9:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802bbf:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  802bc5:	39 ce                	cmp    %ecx,%esi
  802bc7:	74 1e                	je     802be7 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  802bc9:	39 c3                	cmp    %eax,%ebx
  802bcb:	75 be                	jne    802b8b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802bcd:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  802bd3:	ff 75 e4             	pushl  -0x1c(%ebp)
  802bd6:	50                   	push   %eax
  802bd7:	56                   	push   %esi
  802bd8:	68 9b 3a 80 00       	push   $0x803a9b
  802bdd:	e8 2f df ff ff       	call   800b11 <cprintf>
  802be2:	83 c4 10             	add    $0x10,%esp
  802be5:	eb a4                	jmp    802b8b <_pipeisclosed+0xe>
	}
}
  802be7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bed:	5b                   	pop    %ebx
  802bee:	5e                   	pop    %esi
  802bef:	5f                   	pop    %edi
  802bf0:	5d                   	pop    %ebp
  802bf1:	c3                   	ret    

00802bf2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802bf2:	55                   	push   %ebp
  802bf3:	89 e5                	mov    %esp,%ebp
  802bf5:	57                   	push   %edi
  802bf6:	56                   	push   %esi
  802bf7:	53                   	push   %ebx
  802bf8:	83 ec 28             	sub    $0x28,%esp
  802bfb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802bfe:	56                   	push   %esi
  802bff:	e8 11 f0 ff ff       	call   801c15 <fd2data>
  802c04:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c06:	83 c4 10             	add    $0x10,%esp
  802c09:	bf 00 00 00 00       	mov    $0x0,%edi
  802c0e:	eb 4b                	jmp    802c5b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802c10:	89 da                	mov    %ebx,%edx
  802c12:	89 f0                	mov    %esi,%eax
  802c14:	e8 64 ff ff ff       	call   802b7d <_pipeisclosed>
  802c19:	85 c0                	test   %eax,%eax
  802c1b:	75 48                	jne    802c65 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802c1d:	e8 4b e9 ff ff       	call   80156d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802c22:	8b 43 04             	mov    0x4(%ebx),%eax
  802c25:	8b 0b                	mov    (%ebx),%ecx
  802c27:	8d 51 20             	lea    0x20(%ecx),%edx
  802c2a:	39 d0                	cmp    %edx,%eax
  802c2c:	73 e2                	jae    802c10 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c31:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802c35:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802c38:	89 c2                	mov    %eax,%edx
  802c3a:	c1 fa 1f             	sar    $0x1f,%edx
  802c3d:	89 d1                	mov    %edx,%ecx
  802c3f:	c1 e9 1b             	shr    $0x1b,%ecx
  802c42:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802c45:	83 e2 1f             	and    $0x1f,%edx
  802c48:	29 ca                	sub    %ecx,%edx
  802c4a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802c4e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802c52:	83 c0 01             	add    $0x1,%eax
  802c55:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c58:	83 c7 01             	add    $0x1,%edi
  802c5b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802c5e:	75 c2                	jne    802c22 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c60:	8b 45 10             	mov    0x10(%ebp),%eax
  802c63:	eb 05                	jmp    802c6a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c65:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c6d:	5b                   	pop    %ebx
  802c6e:	5e                   	pop    %esi
  802c6f:	5f                   	pop    %edi
  802c70:	5d                   	pop    %ebp
  802c71:	c3                   	ret    

00802c72 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c72:	55                   	push   %ebp
  802c73:	89 e5                	mov    %esp,%ebp
  802c75:	57                   	push   %edi
  802c76:	56                   	push   %esi
  802c77:	53                   	push   %ebx
  802c78:	83 ec 18             	sub    $0x18,%esp
  802c7b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c7e:	57                   	push   %edi
  802c7f:	e8 91 ef ff ff       	call   801c15 <fd2data>
  802c84:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c86:	83 c4 10             	add    $0x10,%esp
  802c89:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c8e:	eb 3d                	jmp    802ccd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802c90:	85 db                	test   %ebx,%ebx
  802c92:	74 04                	je     802c98 <devpipe_read+0x26>
				return i;
  802c94:	89 d8                	mov    %ebx,%eax
  802c96:	eb 44                	jmp    802cdc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802c98:	89 f2                	mov    %esi,%edx
  802c9a:	89 f8                	mov    %edi,%eax
  802c9c:	e8 dc fe ff ff       	call   802b7d <_pipeisclosed>
  802ca1:	85 c0                	test   %eax,%eax
  802ca3:	75 32                	jne    802cd7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802ca5:	e8 c3 e8 ff ff       	call   80156d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802caa:	8b 06                	mov    (%esi),%eax
  802cac:	3b 46 04             	cmp    0x4(%esi),%eax
  802caf:	74 df                	je     802c90 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802cb1:	99                   	cltd   
  802cb2:	c1 ea 1b             	shr    $0x1b,%edx
  802cb5:	01 d0                	add    %edx,%eax
  802cb7:	83 e0 1f             	and    $0x1f,%eax
  802cba:	29 d0                	sub    %edx,%eax
  802cbc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802cc4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802cc7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802cca:	83 c3 01             	add    $0x1,%ebx
  802ccd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802cd0:	75 d8                	jne    802caa <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802cd2:	8b 45 10             	mov    0x10(%ebp),%eax
  802cd5:	eb 05                	jmp    802cdc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802cd7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cdf:	5b                   	pop    %ebx
  802ce0:	5e                   	pop    %esi
  802ce1:	5f                   	pop    %edi
  802ce2:	5d                   	pop    %ebp
  802ce3:	c3                   	ret    

00802ce4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802ce4:	55                   	push   %ebp
  802ce5:	89 e5                	mov    %esp,%ebp
  802ce7:	56                   	push   %esi
  802ce8:	53                   	push   %ebx
  802ce9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802cec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cef:	50                   	push   %eax
  802cf0:	e8 37 ef ff ff       	call   801c2c <fd_alloc>
  802cf5:	83 c4 10             	add    $0x10,%esp
  802cf8:	89 c2                	mov    %eax,%edx
  802cfa:	85 c0                	test   %eax,%eax
  802cfc:	0f 88 2c 01 00 00    	js     802e2e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d02:	83 ec 04             	sub    $0x4,%esp
  802d05:	68 07 04 00 00       	push   $0x407
  802d0a:	ff 75 f4             	pushl  -0xc(%ebp)
  802d0d:	6a 00                	push   $0x0
  802d0f:	e8 78 e8 ff ff       	call   80158c <sys_page_alloc>
  802d14:	83 c4 10             	add    $0x10,%esp
  802d17:	89 c2                	mov    %eax,%edx
  802d19:	85 c0                	test   %eax,%eax
  802d1b:	0f 88 0d 01 00 00    	js     802e2e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802d21:	83 ec 0c             	sub    $0xc,%esp
  802d24:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d27:	50                   	push   %eax
  802d28:	e8 ff ee ff ff       	call   801c2c <fd_alloc>
  802d2d:	89 c3                	mov    %eax,%ebx
  802d2f:	83 c4 10             	add    $0x10,%esp
  802d32:	85 c0                	test   %eax,%eax
  802d34:	0f 88 e2 00 00 00    	js     802e1c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d3a:	83 ec 04             	sub    $0x4,%esp
  802d3d:	68 07 04 00 00       	push   $0x407
  802d42:	ff 75 f0             	pushl  -0x10(%ebp)
  802d45:	6a 00                	push   $0x0
  802d47:	e8 40 e8 ff ff       	call   80158c <sys_page_alloc>
  802d4c:	89 c3                	mov    %eax,%ebx
  802d4e:	83 c4 10             	add    $0x10,%esp
  802d51:	85 c0                	test   %eax,%eax
  802d53:	0f 88 c3 00 00 00    	js     802e1c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802d59:	83 ec 0c             	sub    $0xc,%esp
  802d5c:	ff 75 f4             	pushl  -0xc(%ebp)
  802d5f:	e8 b1 ee ff ff       	call   801c15 <fd2data>
  802d64:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d66:	83 c4 0c             	add    $0xc,%esp
  802d69:	68 07 04 00 00       	push   $0x407
  802d6e:	50                   	push   %eax
  802d6f:	6a 00                	push   $0x0
  802d71:	e8 16 e8 ff ff       	call   80158c <sys_page_alloc>
  802d76:	89 c3                	mov    %eax,%ebx
  802d78:	83 c4 10             	add    $0x10,%esp
  802d7b:	85 c0                	test   %eax,%eax
  802d7d:	0f 88 89 00 00 00    	js     802e0c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d83:	83 ec 0c             	sub    $0xc,%esp
  802d86:	ff 75 f0             	pushl  -0x10(%ebp)
  802d89:	e8 87 ee ff ff       	call   801c15 <fd2data>
  802d8e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802d95:	50                   	push   %eax
  802d96:	6a 00                	push   $0x0
  802d98:	56                   	push   %esi
  802d99:	6a 00                	push   $0x0
  802d9b:	e8 2f e8 ff ff       	call   8015cf <sys_page_map>
  802da0:	89 c3                	mov    %eax,%ebx
  802da2:	83 c4 20             	add    $0x20,%esp
  802da5:	85 c0                	test   %eax,%eax
  802da7:	78 55                	js     802dfe <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802da9:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802db2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802db7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802dbe:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802dc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dc7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dcc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802dd3:	83 ec 0c             	sub    $0xc,%esp
  802dd6:	ff 75 f4             	pushl  -0xc(%ebp)
  802dd9:	e8 27 ee ff ff       	call   801c05 <fd2num>
  802dde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802de1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802de3:	83 c4 04             	add    $0x4,%esp
  802de6:	ff 75 f0             	pushl  -0x10(%ebp)
  802de9:	e8 17 ee ff ff       	call   801c05 <fd2num>
  802dee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802df1:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802df4:	83 c4 10             	add    $0x10,%esp
  802df7:	ba 00 00 00 00       	mov    $0x0,%edx
  802dfc:	eb 30                	jmp    802e2e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802dfe:	83 ec 08             	sub    $0x8,%esp
  802e01:	56                   	push   %esi
  802e02:	6a 00                	push   $0x0
  802e04:	e8 08 e8 ff ff       	call   801611 <sys_page_unmap>
  802e09:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802e0c:	83 ec 08             	sub    $0x8,%esp
  802e0f:	ff 75 f0             	pushl  -0x10(%ebp)
  802e12:	6a 00                	push   $0x0
  802e14:	e8 f8 e7 ff ff       	call   801611 <sys_page_unmap>
  802e19:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802e1c:	83 ec 08             	sub    $0x8,%esp
  802e1f:	ff 75 f4             	pushl  -0xc(%ebp)
  802e22:	6a 00                	push   $0x0
  802e24:	e8 e8 e7 ff ff       	call   801611 <sys_page_unmap>
  802e29:	83 c4 10             	add    $0x10,%esp
  802e2c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802e2e:	89 d0                	mov    %edx,%eax
  802e30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e33:	5b                   	pop    %ebx
  802e34:	5e                   	pop    %esi
  802e35:	5d                   	pop    %ebp
  802e36:	c3                   	ret    

00802e37 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802e37:	55                   	push   %ebp
  802e38:	89 e5                	mov    %esp,%ebp
  802e3a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e40:	50                   	push   %eax
  802e41:	ff 75 08             	pushl  0x8(%ebp)
  802e44:	e8 32 ee ff ff       	call   801c7b <fd_lookup>
  802e49:	83 c4 10             	add    $0x10,%esp
  802e4c:	85 c0                	test   %eax,%eax
  802e4e:	78 18                	js     802e68 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802e50:	83 ec 0c             	sub    $0xc,%esp
  802e53:	ff 75 f4             	pushl  -0xc(%ebp)
  802e56:	e8 ba ed ff ff       	call   801c15 <fd2data>
	return _pipeisclosed(fd, p);
  802e5b:	89 c2                	mov    %eax,%edx
  802e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e60:	e8 18 fd ff ff       	call   802b7d <_pipeisclosed>
  802e65:	83 c4 10             	add    $0x10,%esp
}
  802e68:	c9                   	leave  
  802e69:	c3                   	ret    

00802e6a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e6a:	55                   	push   %ebp
  802e6b:	89 e5                	mov    %esp,%ebp
  802e6d:	56                   	push   %esi
  802e6e:	53                   	push   %ebx
  802e6f:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e72:	85 f6                	test   %esi,%esi
  802e74:	75 16                	jne    802e8c <wait+0x22>
  802e76:	68 b3 3a 80 00       	push   $0x803ab3
  802e7b:	68 8f 34 80 00       	push   $0x80348f
  802e80:	6a 09                	push   $0x9
  802e82:	68 be 3a 80 00       	push   $0x803abe
  802e87:	e8 ac db ff ff       	call   800a38 <_panic>
	e = &envs[ENVX(envid)];
  802e8c:	89 f3                	mov    %esi,%ebx
  802e8e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e94:	69 db b0 00 00 00    	imul   $0xb0,%ebx,%ebx
  802e9a:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802ea0:	eb 05                	jmp    802ea7 <wait+0x3d>
		sys_yield();
  802ea2:	e8 c6 e6 ff ff       	call   80156d <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802ea7:	8b 43 7c             	mov    0x7c(%ebx),%eax
  802eaa:	39 c6                	cmp    %eax,%esi
  802eac:	75 0a                	jne    802eb8 <wait+0x4e>
  802eae:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
  802eb4:	85 c0                	test   %eax,%eax
  802eb6:	75 ea                	jne    802ea2 <wait+0x38>
		sys_yield();
}
  802eb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ebb:	5b                   	pop    %ebx
  802ebc:	5e                   	pop    %esi
  802ebd:	5d                   	pop    %ebp
  802ebe:	c3                   	ret    

00802ebf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802ebf:	55                   	push   %ebp
  802ec0:	89 e5                	mov    %esp,%ebp
  802ec2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802ec5:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802ecc:	75 2a                	jne    802ef8 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802ece:	83 ec 04             	sub    $0x4,%esp
  802ed1:	6a 07                	push   $0x7
  802ed3:	68 00 f0 bf ee       	push   $0xeebff000
  802ed8:	6a 00                	push   $0x0
  802eda:	e8 ad e6 ff ff       	call   80158c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802edf:	83 c4 10             	add    $0x10,%esp
  802ee2:	85 c0                	test   %eax,%eax
  802ee4:	79 12                	jns    802ef8 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802ee6:	50                   	push   %eax
  802ee7:	68 8b 38 80 00       	push   $0x80388b
  802eec:	6a 23                	push   $0x23
  802eee:	68 c9 3a 80 00       	push   $0x803ac9
  802ef3:	e8 40 db ff ff       	call   800a38 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  802efb:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802f00:	83 ec 08             	sub    $0x8,%esp
  802f03:	68 2a 2f 80 00       	push   $0x802f2a
  802f08:	6a 00                	push   $0x0
  802f0a:	e8 c8 e7 ff ff       	call   8016d7 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802f0f:	83 c4 10             	add    $0x10,%esp
  802f12:	85 c0                	test   %eax,%eax
  802f14:	79 12                	jns    802f28 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802f16:	50                   	push   %eax
  802f17:	68 8b 38 80 00       	push   $0x80388b
  802f1c:	6a 2c                	push   $0x2c
  802f1e:	68 c9 3a 80 00       	push   $0x803ac9
  802f23:	e8 10 db ff ff       	call   800a38 <_panic>
	}
}
  802f28:	c9                   	leave  
  802f29:	c3                   	ret    

00802f2a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802f2a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802f2b:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802f30:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802f32:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802f35:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802f39:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802f3e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802f42:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802f44:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802f47:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802f48:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802f4b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802f4c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802f4d:	c3                   	ret    

00802f4e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802f4e:	55                   	push   %ebp
  802f4f:	89 e5                	mov    %esp,%ebp
  802f51:	56                   	push   %esi
  802f52:	53                   	push   %ebx
  802f53:	8b 75 08             	mov    0x8(%ebp),%esi
  802f56:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802f5c:	85 c0                	test   %eax,%eax
  802f5e:	75 12                	jne    802f72 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802f60:	83 ec 0c             	sub    $0xc,%esp
  802f63:	68 00 00 c0 ee       	push   $0xeec00000
  802f68:	e8 cf e7 ff ff       	call   80173c <sys_ipc_recv>
  802f6d:	83 c4 10             	add    $0x10,%esp
  802f70:	eb 0c                	jmp    802f7e <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802f72:	83 ec 0c             	sub    $0xc,%esp
  802f75:	50                   	push   %eax
  802f76:	e8 c1 e7 ff ff       	call   80173c <sys_ipc_recv>
  802f7b:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802f7e:	85 f6                	test   %esi,%esi
  802f80:	0f 95 c1             	setne  %cl
  802f83:	85 db                	test   %ebx,%ebx
  802f85:	0f 95 c2             	setne  %dl
  802f88:	84 d1                	test   %dl,%cl
  802f8a:	74 09                	je     802f95 <ipc_recv+0x47>
  802f8c:	89 c2                	mov    %eax,%edx
  802f8e:	c1 ea 1f             	shr    $0x1f,%edx
  802f91:	84 d2                	test   %dl,%dl
  802f93:	75 2d                	jne    802fc2 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802f95:	85 f6                	test   %esi,%esi
  802f97:	74 0d                	je     802fa6 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802f99:	a1 24 54 80 00       	mov    0x805424,%eax
  802f9e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  802fa4:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802fa6:	85 db                	test   %ebx,%ebx
  802fa8:	74 0d                	je     802fb7 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802faa:	a1 24 54 80 00       	mov    0x805424,%eax
  802faf:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  802fb5:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802fb7:	a1 24 54 80 00       	mov    0x805424,%eax
  802fbc:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  802fc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fc5:	5b                   	pop    %ebx
  802fc6:	5e                   	pop    %esi
  802fc7:	5d                   	pop    %ebp
  802fc8:	c3                   	ret    

00802fc9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802fc9:	55                   	push   %ebp
  802fca:	89 e5                	mov    %esp,%ebp
  802fcc:	57                   	push   %edi
  802fcd:	56                   	push   %esi
  802fce:	53                   	push   %ebx
  802fcf:	83 ec 0c             	sub    $0xc,%esp
  802fd2:	8b 7d 08             	mov    0x8(%ebp),%edi
  802fd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  802fd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802fdb:	85 db                	test   %ebx,%ebx
  802fdd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802fe2:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802fe5:	ff 75 14             	pushl  0x14(%ebp)
  802fe8:	53                   	push   %ebx
  802fe9:	56                   	push   %esi
  802fea:	57                   	push   %edi
  802feb:	e8 29 e7 ff ff       	call   801719 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802ff0:	89 c2                	mov    %eax,%edx
  802ff2:	c1 ea 1f             	shr    $0x1f,%edx
  802ff5:	83 c4 10             	add    $0x10,%esp
  802ff8:	84 d2                	test   %dl,%dl
  802ffa:	74 17                	je     803013 <ipc_send+0x4a>
  802ffc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802fff:	74 12                	je     803013 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  803001:	50                   	push   %eax
  803002:	68 d7 3a 80 00       	push   $0x803ad7
  803007:	6a 47                	push   $0x47
  803009:	68 e5 3a 80 00       	push   $0x803ae5
  80300e:	e8 25 da ff ff       	call   800a38 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  803013:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803016:	75 07                	jne    80301f <ipc_send+0x56>
			sys_yield();
  803018:	e8 50 e5 ff ff       	call   80156d <sys_yield>
  80301d:	eb c6                	jmp    802fe5 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80301f:	85 c0                	test   %eax,%eax
  803021:	75 c2                	jne    802fe5 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  803023:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803026:	5b                   	pop    %ebx
  803027:	5e                   	pop    %esi
  803028:	5f                   	pop    %edi
  803029:	5d                   	pop    %ebp
  80302a:	c3                   	ret    

0080302b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80302b:	55                   	push   %ebp
  80302c:	89 e5                	mov    %esp,%ebp
  80302e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  803031:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  803036:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  80303c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803042:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  803048:	39 ca                	cmp    %ecx,%edx
  80304a:	75 10                	jne    80305c <ipc_find_env+0x31>
			return envs[i].env_id;
  80304c:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  803052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  803057:	8b 40 7c             	mov    0x7c(%eax),%eax
  80305a:	eb 0f                	jmp    80306b <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80305c:	83 c0 01             	add    $0x1,%eax
  80305f:	3d 00 04 00 00       	cmp    $0x400,%eax
  803064:	75 d0                	jne    803036 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  803066:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80306b:	5d                   	pop    %ebp
  80306c:	c3                   	ret    

0080306d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80306d:	55                   	push   %ebp
  80306e:	89 e5                	mov    %esp,%ebp
  803070:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803073:	89 d0                	mov    %edx,%eax
  803075:	c1 e8 16             	shr    $0x16,%eax
  803078:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80307f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803084:	f6 c1 01             	test   $0x1,%cl
  803087:	74 1d                	je     8030a6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803089:	c1 ea 0c             	shr    $0xc,%edx
  80308c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803093:	f6 c2 01             	test   $0x1,%dl
  803096:	74 0e                	je     8030a6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803098:	c1 ea 0c             	shr    $0xc,%edx
  80309b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8030a2:	ef 
  8030a3:	0f b7 c0             	movzwl %ax,%eax
}
  8030a6:	5d                   	pop    %ebp
  8030a7:	c3                   	ret    
  8030a8:	66 90                	xchg   %ax,%ax
  8030aa:	66 90                	xchg   %ax,%ax
  8030ac:	66 90                	xchg   %ax,%ax
  8030ae:	66 90                	xchg   %ax,%ax

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
