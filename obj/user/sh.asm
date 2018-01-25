
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
  800060:	e8 ad 0a 00 00       	call   800b12 <cprintf>
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
  800084:	e8 89 0a 00 00       	call   800b12 <cprintf>
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
  8000b0:	e8 dd 11 00 00       	call   801292 <strchr>
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
  8000dd:	e8 30 0a 00 00       	call   800b12 <cprintf>
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
  8000fb:	e8 92 11 00 00       	call   801292 <strchr>
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
  80012b:	e8 e2 09 00 00       	call   800b12 <cprintf>
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
  800151:	e8 3c 11 00 00       	call   801292 <strchr>
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
  800180:	e8 8d 09 00 00       	call   800b12 <cprintf>
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
  800278:	e8 95 08 00 00       	call   800b12 <cprintf>
				exit();
  80027d:	e8 9d 07 00 00       	call   800a1f <exit>
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
  8002ac:	e8 61 08 00 00       	call   800b12 <cprintf>
				exit();
  8002b1:	e8 69 07 00 00       	call   800a1f <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 a5 20 00 00       	call   80236b <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
				cprintf("open %s for read: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 99 33 80 00       	push   $0x803399
  8002db:	e8 32 08 00 00       	call   800b12 <cprintf>
				exit();
  8002e0:	e8 3a 07 00 00       	call   800a1f <exit>
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
  8002f8:	e8 f7 1a 00 00       	call   801df4 <dup>
				close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 9f 1a 00 00       	call   801da4 <close>
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
  800328:	e8 e5 07 00 00       	call   800b12 <cprintf>
				exit();
  80032d:	e8 ed 06 00 00       	call   800a1f <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 26 20 00 00       	call   80236b <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 ae 33 80 00       	push   $0x8033ae
  80035a:	e8 b3 07 00 00       	call   800b12 <cprintf>
				exit();
  80035f:	e8 bb 06 00 00       	call   800a1f <exit>
  800364:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800367:	83 ff 01             	cmp    $0x1,%edi
  80036a:	0f 84 ba fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	6a 01                	push   $0x1
  800375:	57                   	push   %edi
  800376:	e8 79 1a 00 00       	call   801df4 <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 21 1a 00 00       	call   801da4 <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 3d 29 00 00       	call   802cd7 <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 c4 33 80 00       	push   $0x8033c4
  8003aa:	e8 63 07 00 00       	call   800b12 <cprintf>
				exit();
  8003af:	e8 6b 06 00 00       	call   800a1f <exit>
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
  8003d4:	e8 39 07 00 00       	call   800b12 <cprintf>
  8003d9:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dc:	e8 b3 14 00 00       	call   801894 <fork>
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 16                	jns    8003fd <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	50                   	push   %eax
  8003eb:	68 da 33 80 00       	push   $0x8033da
  8003f0:	e8 1d 07 00 00       	call   800b12 <cprintf>
				exit();
  8003f5:	e8 25 06 00 00       	call   800a1f <exit>
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
  800411:	e8 de 19 00 00       	call   801df4 <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 80 19 00 00       	call   801da4 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 6f 19 00 00       	call   801da4 <close>
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
  80044e:	e8 a1 19 00 00       	call   801df4 <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 43 19 00 00       	call   801da4 <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 32 19 00 00       	call   801da4 <close>
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
  800484:	e8 b0 05 00 00       	call   800a39 <_panic>
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
  8004a7:	e8 66 06 00 00       	call   800b12 <cprintf>
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
  8004d4:	e8 b1 0c 00 00       	call   80118a <strcpy>
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
  8004f5:	8b 40 54             	mov    0x54(%eax),%eax
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	50                   	push   %eax
  8004fc:	68 18 34 80 00       	push   $0x803418
  800501:	e8 0c 06 00 00       	call   800b12 <cprintf>
  800506:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 11                	jmp    80051f <runcmd+0x316>
			cprintf(" %s", argv[i]);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	50                   	push   %eax
  800512:	68 a0 34 80 00       	push   $0x8034a0
  800517:	e8 f6 05 00 00       	call   800b12 <cprintf>
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
  800531:	e8 dc 05 00 00       	call   800b12 <cprintf>
  800536:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 a8             	pushl  -0x58(%ebp)
  800543:	e8 d7 1f 00 00       	call   80251f <spawn>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	0f 89 c3 00 00 00    	jns    800618 <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800555:	83 ec 04             	sub    $0x4,%esp
  800558:	50                   	push   %eax
  800559:	ff 75 a8             	pushl  -0x58(%ebp)
  80055c:	68 26 34 80 00       	push   $0x803426
  800561:	e8 ac 05 00 00       	call   800b12 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800566:	e8 64 18 00 00       	call   801dcf <close_all>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 4c                	jmp    8005bc <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800570:	a1 24 54 80 00       	mov    0x805424,%eax
  800575:	8b 40 54             	mov    0x54(%eax),%eax
  800578:	53                   	push   %ebx
  800579:	ff 75 a8             	pushl  -0x58(%ebp)
  80057c:	50                   	push   %eax
  80057d:	68 34 34 80 00       	push   $0x803434
  800582:	e8 8b 05 00 00       	call   800b12 <cprintf>
  800587:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058a:	83 ec 0c             	sub    $0xc,%esp
  80058d:	53                   	push   %ebx
  80058e:	e8 ca 28 00 00       	call   802e5d <wait>
		if (debug)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059d:	0f 84 8c 00 00 00    	je     80062f <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a3:	a1 24 54 80 00       	mov    0x805424,%eax
  8005a8:	8b 40 54             	mov    0x54(%eax),%eax
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	50                   	push   %eax
  8005af:	68 49 34 80 00       	push   $0x803449
  8005b4:	e8 59 05 00 00       	call   800b12 <cprintf>
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
  8005ce:	8b 40 54             	mov    0x54(%eax),%eax
  8005d1:	83 ec 04             	sub    $0x4,%esp
  8005d4:	57                   	push   %edi
  8005d5:	50                   	push   %eax
  8005d6:	68 5f 34 80 00       	push   $0x80345f
  8005db:	e8 32 05 00 00       	call   800b12 <cprintf>
  8005e0:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	57                   	push   %edi
  8005e7:	e8 71 28 00 00       	call   802e5d <wait>
		if (debug)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f6:	74 19                	je     800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f8:	a1 24 54 80 00       	mov    0x805424,%eax
  8005fd:	8b 40 54             	mov    0x54(%eax),%eax
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	50                   	push   %eax
  800604:	68 49 34 80 00       	push   $0x803449
  800609:	e8 04 05 00 00       	call   800b12 <cprintf>
  80060e:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800611:	e8 09 04 00 00       	call   800a1f <exit>
  800616:	eb 1d                	jmp    800635 <runcmd+0x42c>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800618:	e8 b2 17 00 00       	call   801dcf <close_all>
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
  800648:	e8 c5 04 00 00       	call   800b12 <cprintf>
	exit();
  80064d:	e8 cd 03 00 00       	call   800a1f <exit>
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
  80066c:	e8 3f 14 00 00       	call   801ab0 <argstart>
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
  8006b8:	e8 23 14 00 00       	call   801ae0 <argnext>
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
  8006da:	e8 c5 16 00 00       	call   801da4 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	6a 00                	push   $0x0
  8006e4:	ff 77 04             	pushl  0x4(%edi)
  8006e7:	e8 7f 1c 00 00       	call   80236b <open>
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
  800709:	e8 2b 03 00 00       	call   800a39 <_panic>
		assert(r == 0);
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 19                	je     80072b <umain+0xd4>
  800712:	68 88 34 80 00       	push   $0x803488
  800717:	68 8f 34 80 00       	push   $0x80348f
  80071c:	68 2a 01 00 00       	push   $0x12a
  800721:	68 ff 33 80 00       	push   $0x8033ff
  800726:	e8 0e 03 00 00       	call   800a39 <_panic>
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
  800752:	e8 07 09 00 00       	call   80105e <readline>
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
  800771:	e8 9c 03 00 00       	call   800b12 <cprintf>
  800776:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800779:	e8 a1 02 00 00       	call   800a1f <exit>
		}
		if (debug)
  80077e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800785:	74 11                	je     800798 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	68 b0 34 80 00       	push   $0x8034b0
  800790:	e8 7d 03 00 00       	call   800b12 <cprintf>
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
  8007ac:	e8 58 1d 00 00       	call   802509 <printf>
  8007b1:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bb:	74 10                	je     8007cd <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	68 c0 34 80 00       	push   $0x8034c0
  8007c5:	e8 48 03 00 00       	call   800b12 <cprintf>
  8007ca:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cd:	e8 c2 10 00 00       	call   801894 <fork>
  8007d2:	89 c6                	mov    %eax,%esi
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	79 15                	jns    8007ed <umain+0x196>
			panic("fork: %e", r);
  8007d8:	50                   	push   %eax
  8007d9:	68 da 33 80 00       	push   $0x8033da
  8007de:	68 41 01 00 00       	push   $0x141
  8007e3:	68 ff 33 80 00       	push   $0x8033ff
  8007e8:	e8 4c 02 00 00       	call   800a39 <_panic>
		if (debug)
  8007ed:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f4:	74 11                	je     800807 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	50                   	push   %eax
  8007fa:	68 cd 34 80 00       	push   $0x8034cd
  8007ff:	e8 0e 03 00 00       	call   800b12 <cprintf>
  800804:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800807:	85 f6                	test   %esi,%esi
  800809:	75 16                	jne    800821 <umain+0x1ca>
			runcmd(buf);
  80080b:	83 ec 0c             	sub    $0xc,%esp
  80080e:	53                   	push   %ebx
  80080f:	e8 f5 f9 ff ff       	call   800209 <runcmd>
			exit();
  800814:	e8 06 02 00 00       	call   800a1f <exit>
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	e9 2d ff ff ff       	jmp    80074e <umain+0xf7>
		} else
			wait(r);
  800821:	83 ec 0c             	sub    $0xc,%esp
  800824:	56                   	push   %esi
  800825:	e8 33 26 00 00       	call   802e5d <wait>
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
  80084a:	e8 3b 09 00 00       	call   80118a <strcpy>
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
  800888:	e8 8f 0a 00 00       	call   80131c <memmove>
		sys_cputs(buf, m);
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	57                   	push   %edi
  800892:	e8 3a 0c 00 00       	call   8014d1 <sys_cputs>
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
  8008be:	e8 ab 0c 00 00       	call   80156e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c3:	e8 27 0c 00 00       	call   8014ef <sys_cgetc>
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
  8008fa:	e8 d2 0b 00 00       	call   8014d1 <sys_cputs>
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
  800912:	e8 c9 15 00 00       	call   801ee0 <read>
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
  80093c:	e8 39 13 00 00       	call   801c7a <fd_lookup>
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
  800965:	e8 c1 12 00 00       	call   801c2b <fd_alloc>
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
  800980:	e8 08 0c 00 00       	call   80158d <sys_page_alloc>
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
  8009a7:	e8 58 12 00 00       	call   801c04 <fd2num>
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
  8009c0:	e8 8a 0b 00 00       	call   80154f <sys_getenvid>
  8009c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009ca:	89 c2                	mov    %eax,%edx
  8009cc:	c1 e2 07             	shl    $0x7,%edx
  8009cf:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8009d6:	a3 24 54 80 00       	mov    %eax,0x805424
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009db:	85 db                	test   %ebx,%ebx
  8009dd:	7e 07                	jle    8009e6 <libmain+0x31>
		binaryname = argv[0];
  8009df:	8b 06                	mov    (%esi),%eax
  8009e1:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009e6:	83 ec 08             	sub    $0x8,%esp
  8009e9:	56                   	push   %esi
  8009ea:	53                   	push   %ebx
  8009eb:	e8 67 fc ff ff       	call   800657 <umain>

	// exit gracefully
	exit();
  8009f0:	e8 2a 00 00 00       	call   800a1f <exit>
}
  8009f5:	83 c4 10             	add    $0x10,%esp
  8009f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800a05:	a1 28 54 80 00       	mov    0x805428,%eax
	func();
  800a0a:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800a0c:	e8 3e 0b 00 00       	call   80154f <sys_getenvid>
  800a11:	83 ec 0c             	sub    $0xc,%esp
  800a14:	50                   	push   %eax
  800a15:	e8 84 0d 00 00       	call   80179e <sys_thread_free>
}
  800a1a:	83 c4 10             	add    $0x10,%esp
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a25:	e8 a5 13 00 00       	call   801dcf <close_all>
	sys_env_destroy(0);
  800a2a:	83 ec 0c             	sub    $0xc,%esp
  800a2d:	6a 00                	push   $0x0
  800a2f:	e8 da 0a 00 00       	call   80150e <sys_env_destroy>
}
  800a34:	83 c4 10             	add    $0x10,%esp
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    

00800a39 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a3e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a41:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a47:	e8 03 0b 00 00       	call   80154f <sys_getenvid>
  800a4c:	83 ec 0c             	sub    $0xc,%esp
  800a4f:	ff 75 0c             	pushl  0xc(%ebp)
  800a52:	ff 75 08             	pushl  0x8(%ebp)
  800a55:	56                   	push   %esi
  800a56:	50                   	push   %eax
  800a57:	68 60 35 80 00       	push   $0x803560
  800a5c:	e8 b1 00 00 00       	call   800b12 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a61:	83 c4 18             	add    $0x18,%esp
  800a64:	53                   	push   %ebx
  800a65:	ff 75 10             	pushl  0x10(%ebp)
  800a68:	e8 54 00 00 00       	call   800ac1 <vcprintf>
	cprintf("\n");
  800a6d:	c7 04 24 60 33 80 00 	movl   $0x803360,(%esp)
  800a74:	e8 99 00 00 00       	call   800b12 <cprintf>
  800a79:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a7c:	cc                   	int3   
  800a7d:	eb fd                	jmp    800a7c <_panic+0x43>

00800a7f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	53                   	push   %ebx
  800a83:	83 ec 04             	sub    $0x4,%esp
  800a86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a89:	8b 13                	mov    (%ebx),%edx
  800a8b:	8d 42 01             	lea    0x1(%edx),%eax
  800a8e:	89 03                	mov    %eax,(%ebx)
  800a90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a93:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a97:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a9c:	75 1a                	jne    800ab8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a9e:	83 ec 08             	sub    $0x8,%esp
  800aa1:	68 ff 00 00 00       	push   $0xff
  800aa6:	8d 43 08             	lea    0x8(%ebx),%eax
  800aa9:	50                   	push   %eax
  800aaa:	e8 22 0a 00 00       	call   8014d1 <sys_cputs>
		b->idx = 0;
  800aaf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800ab5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800ab8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800abc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800abf:	c9                   	leave  
  800ac0:	c3                   	ret    

00800ac1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800aca:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800ad1:	00 00 00 
	b.cnt = 0;
  800ad4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800adb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800ade:	ff 75 0c             	pushl  0xc(%ebp)
  800ae1:	ff 75 08             	pushl  0x8(%ebp)
  800ae4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800aea:	50                   	push   %eax
  800aeb:	68 7f 0a 80 00       	push   $0x800a7f
  800af0:	e8 54 01 00 00       	call   800c49 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800af5:	83 c4 08             	add    $0x8,%esp
  800af8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800afe:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b04:	50                   	push   %eax
  800b05:	e8 c7 09 00 00       	call   8014d1 <sys_cputs>

	return b.cnt;
}
  800b0a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b10:	c9                   	leave  
  800b11:	c3                   	ret    

00800b12 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b18:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b1b:	50                   	push   %eax
  800b1c:	ff 75 08             	pushl  0x8(%ebp)
  800b1f:	e8 9d ff ff ff       	call   800ac1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800b24:	c9                   	leave  
  800b25:	c3                   	ret    

00800b26 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
  800b2c:	83 ec 1c             	sub    $0x1c,%esp
  800b2f:	89 c7                	mov    %eax,%edi
  800b31:	89 d6                	mov    %edx,%esi
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b39:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b3c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b47:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b4a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b4d:	39 d3                	cmp    %edx,%ebx
  800b4f:	72 05                	jb     800b56 <printnum+0x30>
  800b51:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b54:	77 45                	ja     800b9b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b56:	83 ec 0c             	sub    $0xc,%esp
  800b59:	ff 75 18             	pushl  0x18(%ebp)
  800b5c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b62:	53                   	push   %ebx
  800b63:	ff 75 10             	pushl  0x10(%ebp)
  800b66:	83 ec 08             	sub    $0x8,%esp
  800b69:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b6c:	ff 75 e0             	pushl  -0x20(%ebp)
  800b6f:	ff 75 dc             	pushl  -0x24(%ebp)
  800b72:	ff 75 d8             	pushl  -0x28(%ebp)
  800b75:	e8 26 25 00 00       	call   8030a0 <__udivdi3>
  800b7a:	83 c4 18             	add    $0x18,%esp
  800b7d:	52                   	push   %edx
  800b7e:	50                   	push   %eax
  800b7f:	89 f2                	mov    %esi,%edx
  800b81:	89 f8                	mov    %edi,%eax
  800b83:	e8 9e ff ff ff       	call   800b26 <printnum>
  800b88:	83 c4 20             	add    $0x20,%esp
  800b8b:	eb 18                	jmp    800ba5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b8d:	83 ec 08             	sub    $0x8,%esp
  800b90:	56                   	push   %esi
  800b91:	ff 75 18             	pushl  0x18(%ebp)
  800b94:	ff d7                	call   *%edi
  800b96:	83 c4 10             	add    $0x10,%esp
  800b99:	eb 03                	jmp    800b9e <printnum+0x78>
  800b9b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b9e:	83 eb 01             	sub    $0x1,%ebx
  800ba1:	85 db                	test   %ebx,%ebx
  800ba3:	7f e8                	jg     800b8d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800ba5:	83 ec 08             	sub    $0x8,%esp
  800ba8:	56                   	push   %esi
  800ba9:	83 ec 04             	sub    $0x4,%esp
  800bac:	ff 75 e4             	pushl  -0x1c(%ebp)
  800baf:	ff 75 e0             	pushl  -0x20(%ebp)
  800bb2:	ff 75 dc             	pushl  -0x24(%ebp)
  800bb5:	ff 75 d8             	pushl  -0x28(%ebp)
  800bb8:	e8 13 26 00 00       	call   8031d0 <__umoddi3>
  800bbd:	83 c4 14             	add    $0x14,%esp
  800bc0:	0f be 80 83 35 80 00 	movsbl 0x803583(%eax),%eax
  800bc7:	50                   	push   %eax
  800bc8:	ff d7                	call   *%edi
}
  800bca:	83 c4 10             	add    $0x10,%esp
  800bcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bd8:	83 fa 01             	cmp    $0x1,%edx
  800bdb:	7e 0e                	jle    800beb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bdd:	8b 10                	mov    (%eax),%edx
  800bdf:	8d 4a 08             	lea    0x8(%edx),%ecx
  800be2:	89 08                	mov    %ecx,(%eax)
  800be4:	8b 02                	mov    (%edx),%eax
  800be6:	8b 52 04             	mov    0x4(%edx),%edx
  800be9:	eb 22                	jmp    800c0d <getuint+0x38>
	else if (lflag)
  800beb:	85 d2                	test   %edx,%edx
  800bed:	74 10                	je     800bff <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bef:	8b 10                	mov    (%eax),%edx
  800bf1:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bf4:	89 08                	mov    %ecx,(%eax)
  800bf6:	8b 02                	mov    (%edx),%eax
  800bf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfd:	eb 0e                	jmp    800c0d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bff:	8b 10                	mov    (%eax),%edx
  800c01:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c04:	89 08                	mov    %ecx,(%eax)
  800c06:	8b 02                	mov    (%edx),%eax
  800c08:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c15:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800c19:	8b 10                	mov    (%eax),%edx
  800c1b:	3b 50 04             	cmp    0x4(%eax),%edx
  800c1e:	73 0a                	jae    800c2a <sprintputch+0x1b>
		*b->buf++ = ch;
  800c20:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c23:	89 08                	mov    %ecx,(%eax)
  800c25:	8b 45 08             	mov    0x8(%ebp),%eax
  800c28:	88 02                	mov    %al,(%edx)
}
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c32:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c35:	50                   	push   %eax
  800c36:	ff 75 10             	pushl  0x10(%ebp)
  800c39:	ff 75 0c             	pushl  0xc(%ebp)
  800c3c:	ff 75 08             	pushl  0x8(%ebp)
  800c3f:	e8 05 00 00 00       	call   800c49 <vprintfmt>
	va_end(ap);
}
  800c44:	83 c4 10             	add    $0x10,%esp
  800c47:	c9                   	leave  
  800c48:	c3                   	ret    

00800c49 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 2c             	sub    $0x2c,%esp
  800c52:	8b 75 08             	mov    0x8(%ebp),%esi
  800c55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c58:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c5b:	eb 12                	jmp    800c6f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	0f 84 89 03 00 00    	je     800fee <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800c65:	83 ec 08             	sub    $0x8,%esp
  800c68:	53                   	push   %ebx
  800c69:	50                   	push   %eax
  800c6a:	ff d6                	call   *%esi
  800c6c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c6f:	83 c7 01             	add    $0x1,%edi
  800c72:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c76:	83 f8 25             	cmp    $0x25,%eax
  800c79:	75 e2                	jne    800c5d <vprintfmt+0x14>
  800c7b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c7f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c86:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c8d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c94:	ba 00 00 00 00       	mov    $0x0,%edx
  800c99:	eb 07                	jmp    800ca2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c9e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca2:	8d 47 01             	lea    0x1(%edi),%eax
  800ca5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ca8:	0f b6 07             	movzbl (%edi),%eax
  800cab:	0f b6 c8             	movzbl %al,%ecx
  800cae:	83 e8 23             	sub    $0x23,%eax
  800cb1:	3c 55                	cmp    $0x55,%al
  800cb3:	0f 87 1a 03 00 00    	ja     800fd3 <vprintfmt+0x38a>
  800cb9:	0f b6 c0             	movzbl %al,%eax
  800cbc:	ff 24 85 c0 36 80 00 	jmp    *0x8036c0(,%eax,4)
  800cc3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800cc6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800cca:	eb d6                	jmp    800ca2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ccc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cd7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cda:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800cde:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800ce1:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800ce4:	83 fa 09             	cmp    $0x9,%edx
  800ce7:	77 39                	ja     800d22 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800ce9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800cec:	eb e9                	jmp    800cd7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800cee:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf1:	8d 48 04             	lea    0x4(%eax),%ecx
  800cf4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800cf7:	8b 00                	mov    (%eax),%eax
  800cf9:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cfc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800cff:	eb 27                	jmp    800d28 <vprintfmt+0xdf>
  800d01:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d04:	85 c0                	test   %eax,%eax
  800d06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d0b:	0f 49 c8             	cmovns %eax,%ecx
  800d0e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d14:	eb 8c                	jmp    800ca2 <vprintfmt+0x59>
  800d16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d19:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800d20:	eb 80                	jmp    800ca2 <vprintfmt+0x59>
  800d22:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d25:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800d28:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d2c:	0f 89 70 ff ff ff    	jns    800ca2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800d32:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d35:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d38:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d3f:	e9 5e ff ff ff       	jmp    800ca2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d44:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d4a:	e9 53 ff ff ff       	jmp    800ca2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d4f:	8b 45 14             	mov    0x14(%ebp),%eax
  800d52:	8d 50 04             	lea    0x4(%eax),%edx
  800d55:	89 55 14             	mov    %edx,0x14(%ebp)
  800d58:	83 ec 08             	sub    $0x8,%esp
  800d5b:	53                   	push   %ebx
  800d5c:	ff 30                	pushl  (%eax)
  800d5e:	ff d6                	call   *%esi
			break;
  800d60:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d63:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d66:	e9 04 ff ff ff       	jmp    800c6f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d6b:	8b 45 14             	mov    0x14(%ebp),%eax
  800d6e:	8d 50 04             	lea    0x4(%eax),%edx
  800d71:	89 55 14             	mov    %edx,0x14(%ebp)
  800d74:	8b 00                	mov    (%eax),%eax
  800d76:	99                   	cltd   
  800d77:	31 d0                	xor    %edx,%eax
  800d79:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d7b:	83 f8 0f             	cmp    $0xf,%eax
  800d7e:	7f 0b                	jg     800d8b <vprintfmt+0x142>
  800d80:	8b 14 85 20 38 80 00 	mov    0x803820(,%eax,4),%edx
  800d87:	85 d2                	test   %edx,%edx
  800d89:	75 18                	jne    800da3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d8b:	50                   	push   %eax
  800d8c:	68 9b 35 80 00       	push   $0x80359b
  800d91:	53                   	push   %ebx
  800d92:	56                   	push   %esi
  800d93:	e8 94 fe ff ff       	call   800c2c <printfmt>
  800d98:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d9e:	e9 cc fe ff ff       	jmp    800c6f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800da3:	52                   	push   %edx
  800da4:	68 a1 34 80 00       	push   $0x8034a1
  800da9:	53                   	push   %ebx
  800daa:	56                   	push   %esi
  800dab:	e8 7c fe ff ff       	call   800c2c <printfmt>
  800db0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800db3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800db6:	e9 b4 fe ff ff       	jmp    800c6f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800dbb:	8b 45 14             	mov    0x14(%ebp),%eax
  800dbe:	8d 50 04             	lea    0x4(%eax),%edx
  800dc1:	89 55 14             	mov    %edx,0x14(%ebp)
  800dc4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800dc6:	85 ff                	test   %edi,%edi
  800dc8:	b8 94 35 80 00       	mov    $0x803594,%eax
  800dcd:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800dd0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dd4:	0f 8e 94 00 00 00    	jle    800e6e <vprintfmt+0x225>
  800dda:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800dde:	0f 84 98 00 00 00    	je     800e7c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800de4:	83 ec 08             	sub    $0x8,%esp
  800de7:	ff 75 d0             	pushl  -0x30(%ebp)
  800dea:	57                   	push   %edi
  800deb:	e8 79 03 00 00       	call   801169 <strnlen>
  800df0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800df3:	29 c1                	sub    %eax,%ecx
  800df5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800df8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800dfb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800dff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e02:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e05:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e07:	eb 0f                	jmp    800e18 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800e09:	83 ec 08             	sub    $0x8,%esp
  800e0c:	53                   	push   %ebx
  800e0d:	ff 75 e0             	pushl  -0x20(%ebp)
  800e10:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e12:	83 ef 01             	sub    $0x1,%edi
  800e15:	83 c4 10             	add    $0x10,%esp
  800e18:	85 ff                	test   %edi,%edi
  800e1a:	7f ed                	jg     800e09 <vprintfmt+0x1c0>
  800e1c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800e1f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800e22:	85 c9                	test   %ecx,%ecx
  800e24:	b8 00 00 00 00       	mov    $0x0,%eax
  800e29:	0f 49 c1             	cmovns %ecx,%eax
  800e2c:	29 c1                	sub    %eax,%ecx
  800e2e:	89 75 08             	mov    %esi,0x8(%ebp)
  800e31:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e34:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e37:	89 cb                	mov    %ecx,%ebx
  800e39:	eb 4d                	jmp    800e88 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e3b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e3f:	74 1b                	je     800e5c <vprintfmt+0x213>
  800e41:	0f be c0             	movsbl %al,%eax
  800e44:	83 e8 20             	sub    $0x20,%eax
  800e47:	83 f8 5e             	cmp    $0x5e,%eax
  800e4a:	76 10                	jbe    800e5c <vprintfmt+0x213>
					putch('?', putdat);
  800e4c:	83 ec 08             	sub    $0x8,%esp
  800e4f:	ff 75 0c             	pushl  0xc(%ebp)
  800e52:	6a 3f                	push   $0x3f
  800e54:	ff 55 08             	call   *0x8(%ebp)
  800e57:	83 c4 10             	add    $0x10,%esp
  800e5a:	eb 0d                	jmp    800e69 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800e5c:	83 ec 08             	sub    $0x8,%esp
  800e5f:	ff 75 0c             	pushl  0xc(%ebp)
  800e62:	52                   	push   %edx
  800e63:	ff 55 08             	call   *0x8(%ebp)
  800e66:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e69:	83 eb 01             	sub    $0x1,%ebx
  800e6c:	eb 1a                	jmp    800e88 <vprintfmt+0x23f>
  800e6e:	89 75 08             	mov    %esi,0x8(%ebp)
  800e71:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e74:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e77:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e7a:	eb 0c                	jmp    800e88 <vprintfmt+0x23f>
  800e7c:	89 75 08             	mov    %esi,0x8(%ebp)
  800e7f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e82:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e85:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e88:	83 c7 01             	add    $0x1,%edi
  800e8b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e8f:	0f be d0             	movsbl %al,%edx
  800e92:	85 d2                	test   %edx,%edx
  800e94:	74 23                	je     800eb9 <vprintfmt+0x270>
  800e96:	85 f6                	test   %esi,%esi
  800e98:	78 a1                	js     800e3b <vprintfmt+0x1f2>
  800e9a:	83 ee 01             	sub    $0x1,%esi
  800e9d:	79 9c                	jns    800e3b <vprintfmt+0x1f2>
  800e9f:	89 df                	mov    %ebx,%edi
  800ea1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ea7:	eb 18                	jmp    800ec1 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ea9:	83 ec 08             	sub    $0x8,%esp
  800eac:	53                   	push   %ebx
  800ead:	6a 20                	push   $0x20
  800eaf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800eb1:	83 ef 01             	sub    $0x1,%edi
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	eb 08                	jmp    800ec1 <vprintfmt+0x278>
  800eb9:	89 df                	mov    %ebx,%edi
  800ebb:	8b 75 08             	mov    0x8(%ebp),%esi
  800ebe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ec1:	85 ff                	test   %edi,%edi
  800ec3:	7f e4                	jg     800ea9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ec5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ec8:	e9 a2 fd ff ff       	jmp    800c6f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ecd:	83 fa 01             	cmp    $0x1,%edx
  800ed0:	7e 16                	jle    800ee8 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800ed2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ed5:	8d 50 08             	lea    0x8(%eax),%edx
  800ed8:	89 55 14             	mov    %edx,0x14(%ebp)
  800edb:	8b 50 04             	mov    0x4(%eax),%edx
  800ede:	8b 00                	mov    (%eax),%eax
  800ee0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ee3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ee6:	eb 32                	jmp    800f1a <vprintfmt+0x2d1>
	else if (lflag)
  800ee8:	85 d2                	test   %edx,%edx
  800eea:	74 18                	je     800f04 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800eec:	8b 45 14             	mov    0x14(%ebp),%eax
  800eef:	8d 50 04             	lea    0x4(%eax),%edx
  800ef2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ef5:	8b 00                	mov    (%eax),%eax
  800ef7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800efa:	89 c1                	mov    %eax,%ecx
  800efc:	c1 f9 1f             	sar    $0x1f,%ecx
  800eff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800f02:	eb 16                	jmp    800f1a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800f04:	8b 45 14             	mov    0x14(%ebp),%eax
  800f07:	8d 50 04             	lea    0x4(%eax),%edx
  800f0a:	89 55 14             	mov    %edx,0x14(%ebp)
  800f0d:	8b 00                	mov    (%eax),%eax
  800f0f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f12:	89 c1                	mov    %eax,%ecx
  800f14:	c1 f9 1f             	sar    $0x1f,%ecx
  800f17:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800f1a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f1d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f20:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f25:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f29:	79 74                	jns    800f9f <vprintfmt+0x356>
				putch('-', putdat);
  800f2b:	83 ec 08             	sub    $0x8,%esp
  800f2e:	53                   	push   %ebx
  800f2f:	6a 2d                	push   $0x2d
  800f31:	ff d6                	call   *%esi
				num = -(long long) num;
  800f33:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f36:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f39:	f7 d8                	neg    %eax
  800f3b:	83 d2 00             	adc    $0x0,%edx
  800f3e:	f7 da                	neg    %edx
  800f40:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f43:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f48:	eb 55                	jmp    800f9f <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f4a:	8d 45 14             	lea    0x14(%ebp),%eax
  800f4d:	e8 83 fc ff ff       	call   800bd5 <getuint>
			base = 10;
  800f52:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f57:	eb 46                	jmp    800f9f <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800f59:	8d 45 14             	lea    0x14(%ebp),%eax
  800f5c:	e8 74 fc ff ff       	call   800bd5 <getuint>
			base = 8;
  800f61:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800f66:	eb 37                	jmp    800f9f <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800f68:	83 ec 08             	sub    $0x8,%esp
  800f6b:	53                   	push   %ebx
  800f6c:	6a 30                	push   $0x30
  800f6e:	ff d6                	call   *%esi
			putch('x', putdat);
  800f70:	83 c4 08             	add    $0x8,%esp
  800f73:	53                   	push   %ebx
  800f74:	6a 78                	push   $0x78
  800f76:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f78:	8b 45 14             	mov    0x14(%ebp),%eax
  800f7b:	8d 50 04             	lea    0x4(%eax),%edx
  800f7e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f81:	8b 00                	mov    (%eax),%eax
  800f83:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f88:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f8b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f90:	eb 0d                	jmp    800f9f <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f92:	8d 45 14             	lea    0x14(%ebp),%eax
  800f95:	e8 3b fc ff ff       	call   800bd5 <getuint>
			base = 16;
  800f9a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f9f:	83 ec 0c             	sub    $0xc,%esp
  800fa2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800fa6:	57                   	push   %edi
  800fa7:	ff 75 e0             	pushl  -0x20(%ebp)
  800faa:	51                   	push   %ecx
  800fab:	52                   	push   %edx
  800fac:	50                   	push   %eax
  800fad:	89 da                	mov    %ebx,%edx
  800faf:	89 f0                	mov    %esi,%eax
  800fb1:	e8 70 fb ff ff       	call   800b26 <printnum>
			break;
  800fb6:	83 c4 20             	add    $0x20,%esp
  800fb9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fbc:	e9 ae fc ff ff       	jmp    800c6f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fc1:	83 ec 08             	sub    $0x8,%esp
  800fc4:	53                   	push   %ebx
  800fc5:	51                   	push   %ecx
  800fc6:	ff d6                	call   *%esi
			break;
  800fc8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fcb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fce:	e9 9c fc ff ff       	jmp    800c6f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fd3:	83 ec 08             	sub    $0x8,%esp
  800fd6:	53                   	push   %ebx
  800fd7:	6a 25                	push   $0x25
  800fd9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	eb 03                	jmp    800fe3 <vprintfmt+0x39a>
  800fe0:	83 ef 01             	sub    $0x1,%edi
  800fe3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800fe7:	75 f7                	jne    800fe0 <vprintfmt+0x397>
  800fe9:	e9 81 fc ff ff       	jmp    800c6f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800fee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	83 ec 18             	sub    $0x18,%esp
  800ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801002:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801005:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801009:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80100c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801013:	85 c0                	test   %eax,%eax
  801015:	74 26                	je     80103d <vsnprintf+0x47>
  801017:	85 d2                	test   %edx,%edx
  801019:	7e 22                	jle    80103d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80101b:	ff 75 14             	pushl  0x14(%ebp)
  80101e:	ff 75 10             	pushl  0x10(%ebp)
  801021:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801024:	50                   	push   %eax
  801025:	68 0f 0c 80 00       	push   $0x800c0f
  80102a:	e8 1a fc ff ff       	call   800c49 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80102f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801032:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801035:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	eb 05                	jmp    801042 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80103d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801042:	c9                   	leave  
  801043:	c3                   	ret    

00801044 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80104a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80104d:	50                   	push   %eax
  80104e:	ff 75 10             	pushl  0x10(%ebp)
  801051:	ff 75 0c             	pushl  0xc(%ebp)
  801054:	ff 75 08             	pushl  0x8(%ebp)
  801057:	e8 9a ff ff ff       	call   800ff6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80105c:	c9                   	leave  
  80105d:	c3                   	ret    

0080105e <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80105e:	55                   	push   %ebp
  80105f:	89 e5                	mov    %esp,%ebp
  801061:	57                   	push   %edi
  801062:	56                   	push   %esi
  801063:	53                   	push   %ebx
  801064:	83 ec 0c             	sub    $0xc,%esp
  801067:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80106a:	85 c0                	test   %eax,%eax
  80106c:	74 13                	je     801081 <readline+0x23>
		fprintf(1, "%s", prompt);
  80106e:	83 ec 04             	sub    $0x4,%esp
  801071:	50                   	push   %eax
  801072:	68 a1 34 80 00       	push   $0x8034a1
  801077:	6a 01                	push   $0x1
  801079:	e8 74 14 00 00       	call   8024f2 <fprintf>
  80107e:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  801081:	83 ec 0c             	sub    $0xc,%esp
  801084:	6a 00                	push   $0x0
  801086:	e8 a4 f8 ff ff       	call   80092f <iscons>
  80108b:	89 c7                	mov    %eax,%edi
  80108d:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  801090:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  801095:	e8 6a f8 ff ff       	call   800904 <getchar>
  80109a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80109c:	85 c0                	test   %eax,%eax
  80109e:	79 29                	jns    8010c9 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8010a0:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  8010a5:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8010a8:	0f 84 9b 00 00 00    	je     801149 <readline+0xeb>
				cprintf("read error: %e\n", c);
  8010ae:	83 ec 08             	sub    $0x8,%esp
  8010b1:	53                   	push   %ebx
  8010b2:	68 7f 38 80 00       	push   $0x80387f
  8010b7:	e8 56 fa ff ff       	call   800b12 <cprintf>
  8010bc:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8010bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c4:	e9 80 00 00 00       	jmp    801149 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010c9:	83 f8 08             	cmp    $0x8,%eax
  8010cc:	0f 94 c2             	sete   %dl
  8010cf:	83 f8 7f             	cmp    $0x7f,%eax
  8010d2:	0f 94 c0             	sete   %al
  8010d5:	08 c2                	or     %al,%dl
  8010d7:	74 1a                	je     8010f3 <readline+0x95>
  8010d9:	85 f6                	test   %esi,%esi
  8010db:	7e 16                	jle    8010f3 <readline+0x95>
			if (echoing)
  8010dd:	85 ff                	test   %edi,%edi
  8010df:	74 0d                	je     8010ee <readline+0x90>
				cputchar('\b');
  8010e1:	83 ec 0c             	sub    $0xc,%esp
  8010e4:	6a 08                	push   $0x8
  8010e6:	e8 fd f7 ff ff       	call   8008e8 <cputchar>
  8010eb:	83 c4 10             	add    $0x10,%esp
			i--;
  8010ee:	83 ee 01             	sub    $0x1,%esi
  8010f1:	eb a2                	jmp    801095 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010f3:	83 fb 1f             	cmp    $0x1f,%ebx
  8010f6:	7e 26                	jle    80111e <readline+0xc0>
  8010f8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010fe:	7f 1e                	jg     80111e <readline+0xc0>
			if (echoing)
  801100:	85 ff                	test   %edi,%edi
  801102:	74 0c                	je     801110 <readline+0xb2>
				cputchar(c);
  801104:	83 ec 0c             	sub    $0xc,%esp
  801107:	53                   	push   %ebx
  801108:	e8 db f7 ff ff       	call   8008e8 <cputchar>
  80110d:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  801110:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801116:	8d 76 01             	lea    0x1(%esi),%esi
  801119:	e9 77 ff ff ff       	jmp    801095 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  80111e:	83 fb 0a             	cmp    $0xa,%ebx
  801121:	74 09                	je     80112c <readline+0xce>
  801123:	83 fb 0d             	cmp    $0xd,%ebx
  801126:	0f 85 69 ff ff ff    	jne    801095 <readline+0x37>
			if (echoing)
  80112c:	85 ff                	test   %edi,%edi
  80112e:	74 0d                	je     80113d <readline+0xdf>
				cputchar('\n');
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	6a 0a                	push   $0xa
  801135:	e8 ae f7 ff ff       	call   8008e8 <cputchar>
  80113a:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  80113d:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  801144:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  801149:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801157:	b8 00 00 00 00       	mov    $0x0,%eax
  80115c:	eb 03                	jmp    801161 <strlen+0x10>
		n++;
  80115e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801161:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801165:	75 f7                	jne    80115e <strlen+0xd>
		n++;
	return n;
}
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    

00801169 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801172:	ba 00 00 00 00       	mov    $0x0,%edx
  801177:	eb 03                	jmp    80117c <strnlen+0x13>
		n++;
  801179:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80117c:	39 c2                	cmp    %eax,%edx
  80117e:	74 08                	je     801188 <strnlen+0x1f>
  801180:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801184:	75 f3                	jne    801179 <strnlen+0x10>
  801186:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    

0080118a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	53                   	push   %ebx
  80118e:	8b 45 08             	mov    0x8(%ebp),%eax
  801191:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801194:	89 c2                	mov    %eax,%edx
  801196:	83 c2 01             	add    $0x1,%edx
  801199:	83 c1 01             	add    $0x1,%ecx
  80119c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8011a0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8011a3:	84 db                	test   %bl,%bl
  8011a5:	75 ef                	jne    801196 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8011a7:	5b                   	pop    %ebx
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	53                   	push   %ebx
  8011ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011b1:	53                   	push   %ebx
  8011b2:	e8 9a ff ff ff       	call   801151 <strlen>
  8011b7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8011ba:	ff 75 0c             	pushl  0xc(%ebp)
  8011bd:	01 d8                	add    %ebx,%eax
  8011bf:	50                   	push   %eax
  8011c0:	e8 c5 ff ff ff       	call   80118a <strcpy>
	return dst;
}
  8011c5:	89 d8                	mov    %ebx,%eax
  8011c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ca:	c9                   	leave  
  8011cb:	c3                   	ret    

008011cc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	56                   	push   %esi
  8011d0:	53                   	push   %ebx
  8011d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d7:	89 f3                	mov    %esi,%ebx
  8011d9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011dc:	89 f2                	mov    %esi,%edx
  8011de:	eb 0f                	jmp    8011ef <strncpy+0x23>
		*dst++ = *src;
  8011e0:	83 c2 01             	add    $0x1,%edx
  8011e3:	0f b6 01             	movzbl (%ecx),%eax
  8011e6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011e9:	80 39 01             	cmpb   $0x1,(%ecx)
  8011ec:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011ef:	39 da                	cmp    %ebx,%edx
  8011f1:	75 ed                	jne    8011e0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011f3:	89 f0                	mov    %esi,%eax
  8011f5:	5b                   	pop    %ebx
  8011f6:	5e                   	pop    %esi
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	56                   	push   %esi
  8011fd:	53                   	push   %ebx
  8011fe:	8b 75 08             	mov    0x8(%ebp),%esi
  801201:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801204:	8b 55 10             	mov    0x10(%ebp),%edx
  801207:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801209:	85 d2                	test   %edx,%edx
  80120b:	74 21                	je     80122e <strlcpy+0x35>
  80120d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801211:	89 f2                	mov    %esi,%edx
  801213:	eb 09                	jmp    80121e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801215:	83 c2 01             	add    $0x1,%edx
  801218:	83 c1 01             	add    $0x1,%ecx
  80121b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80121e:	39 c2                	cmp    %eax,%edx
  801220:	74 09                	je     80122b <strlcpy+0x32>
  801222:	0f b6 19             	movzbl (%ecx),%ebx
  801225:	84 db                	test   %bl,%bl
  801227:	75 ec                	jne    801215 <strlcpy+0x1c>
  801229:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80122b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80122e:	29 f0                	sub    %esi,%eax
}
  801230:	5b                   	pop    %ebx
  801231:	5e                   	pop    %esi
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80123a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80123d:	eb 06                	jmp    801245 <strcmp+0x11>
		p++, q++;
  80123f:	83 c1 01             	add    $0x1,%ecx
  801242:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801245:	0f b6 01             	movzbl (%ecx),%eax
  801248:	84 c0                	test   %al,%al
  80124a:	74 04                	je     801250 <strcmp+0x1c>
  80124c:	3a 02                	cmp    (%edx),%al
  80124e:	74 ef                	je     80123f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801250:	0f b6 c0             	movzbl %al,%eax
  801253:	0f b6 12             	movzbl (%edx),%edx
  801256:	29 d0                	sub    %edx,%eax
}
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	53                   	push   %ebx
  80125e:	8b 45 08             	mov    0x8(%ebp),%eax
  801261:	8b 55 0c             	mov    0xc(%ebp),%edx
  801264:	89 c3                	mov    %eax,%ebx
  801266:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801269:	eb 06                	jmp    801271 <strncmp+0x17>
		n--, p++, q++;
  80126b:	83 c0 01             	add    $0x1,%eax
  80126e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801271:	39 d8                	cmp    %ebx,%eax
  801273:	74 15                	je     80128a <strncmp+0x30>
  801275:	0f b6 08             	movzbl (%eax),%ecx
  801278:	84 c9                	test   %cl,%cl
  80127a:	74 04                	je     801280 <strncmp+0x26>
  80127c:	3a 0a                	cmp    (%edx),%cl
  80127e:	74 eb                	je     80126b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801280:	0f b6 00             	movzbl (%eax),%eax
  801283:	0f b6 12             	movzbl (%edx),%edx
  801286:	29 d0                	sub    %edx,%eax
  801288:	eb 05                	jmp    80128f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80128a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80128f:	5b                   	pop    %ebx
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    

00801292 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	8b 45 08             	mov    0x8(%ebp),%eax
  801298:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80129c:	eb 07                	jmp    8012a5 <strchr+0x13>
		if (*s == c)
  80129e:	38 ca                	cmp    %cl,%dl
  8012a0:	74 0f                	je     8012b1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012a2:	83 c0 01             	add    $0x1,%eax
  8012a5:	0f b6 10             	movzbl (%eax),%edx
  8012a8:	84 d2                	test   %dl,%dl
  8012aa:	75 f2                	jne    80129e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8012ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    

008012b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012bd:	eb 03                	jmp    8012c2 <strfind+0xf>
  8012bf:	83 c0 01             	add    $0x1,%eax
  8012c2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8012c5:	38 ca                	cmp    %cl,%dl
  8012c7:	74 04                	je     8012cd <strfind+0x1a>
  8012c9:	84 d2                	test   %dl,%dl
  8012cb:	75 f2                	jne    8012bf <strfind+0xc>
			break;
	return (char *) s;
}
  8012cd:	5d                   	pop    %ebp
  8012ce:	c3                   	ret    

008012cf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	57                   	push   %edi
  8012d3:	56                   	push   %esi
  8012d4:	53                   	push   %ebx
  8012d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012db:	85 c9                	test   %ecx,%ecx
  8012dd:	74 36                	je     801315 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012df:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012e5:	75 28                	jne    80130f <memset+0x40>
  8012e7:	f6 c1 03             	test   $0x3,%cl
  8012ea:	75 23                	jne    80130f <memset+0x40>
		c &= 0xFF;
  8012ec:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012f0:	89 d3                	mov    %edx,%ebx
  8012f2:	c1 e3 08             	shl    $0x8,%ebx
  8012f5:	89 d6                	mov    %edx,%esi
  8012f7:	c1 e6 18             	shl    $0x18,%esi
  8012fa:	89 d0                	mov    %edx,%eax
  8012fc:	c1 e0 10             	shl    $0x10,%eax
  8012ff:	09 f0                	or     %esi,%eax
  801301:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801303:	89 d8                	mov    %ebx,%eax
  801305:	09 d0                	or     %edx,%eax
  801307:	c1 e9 02             	shr    $0x2,%ecx
  80130a:	fc                   	cld    
  80130b:	f3 ab                	rep stos %eax,%es:(%edi)
  80130d:	eb 06                	jmp    801315 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80130f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801312:	fc                   	cld    
  801313:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801315:	89 f8                	mov    %edi,%eax
  801317:	5b                   	pop    %ebx
  801318:	5e                   	pop    %esi
  801319:	5f                   	pop    %edi
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	57                   	push   %edi
  801320:	56                   	push   %esi
  801321:	8b 45 08             	mov    0x8(%ebp),%eax
  801324:	8b 75 0c             	mov    0xc(%ebp),%esi
  801327:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80132a:	39 c6                	cmp    %eax,%esi
  80132c:	73 35                	jae    801363 <memmove+0x47>
  80132e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801331:	39 d0                	cmp    %edx,%eax
  801333:	73 2e                	jae    801363 <memmove+0x47>
		s += n;
		d += n;
  801335:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801338:	89 d6                	mov    %edx,%esi
  80133a:	09 fe                	or     %edi,%esi
  80133c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801342:	75 13                	jne    801357 <memmove+0x3b>
  801344:	f6 c1 03             	test   $0x3,%cl
  801347:	75 0e                	jne    801357 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801349:	83 ef 04             	sub    $0x4,%edi
  80134c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80134f:	c1 e9 02             	shr    $0x2,%ecx
  801352:	fd                   	std    
  801353:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801355:	eb 09                	jmp    801360 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801357:	83 ef 01             	sub    $0x1,%edi
  80135a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80135d:	fd                   	std    
  80135e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801360:	fc                   	cld    
  801361:	eb 1d                	jmp    801380 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801363:	89 f2                	mov    %esi,%edx
  801365:	09 c2                	or     %eax,%edx
  801367:	f6 c2 03             	test   $0x3,%dl
  80136a:	75 0f                	jne    80137b <memmove+0x5f>
  80136c:	f6 c1 03             	test   $0x3,%cl
  80136f:	75 0a                	jne    80137b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801371:	c1 e9 02             	shr    $0x2,%ecx
  801374:	89 c7                	mov    %eax,%edi
  801376:	fc                   	cld    
  801377:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801379:	eb 05                	jmp    801380 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80137b:	89 c7                	mov    %eax,%edi
  80137d:	fc                   	cld    
  80137e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801380:	5e                   	pop    %esi
  801381:	5f                   	pop    %edi
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    

00801384 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801387:	ff 75 10             	pushl  0x10(%ebp)
  80138a:	ff 75 0c             	pushl  0xc(%ebp)
  80138d:	ff 75 08             	pushl  0x8(%ebp)
  801390:	e8 87 ff ff ff       	call   80131c <memmove>
}
  801395:	c9                   	leave  
  801396:	c3                   	ret    

00801397 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	56                   	push   %esi
  80139b:	53                   	push   %ebx
  80139c:	8b 45 08             	mov    0x8(%ebp),%eax
  80139f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a2:	89 c6                	mov    %eax,%esi
  8013a4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013a7:	eb 1a                	jmp    8013c3 <memcmp+0x2c>
		if (*s1 != *s2)
  8013a9:	0f b6 08             	movzbl (%eax),%ecx
  8013ac:	0f b6 1a             	movzbl (%edx),%ebx
  8013af:	38 d9                	cmp    %bl,%cl
  8013b1:	74 0a                	je     8013bd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8013b3:	0f b6 c1             	movzbl %cl,%eax
  8013b6:	0f b6 db             	movzbl %bl,%ebx
  8013b9:	29 d8                	sub    %ebx,%eax
  8013bb:	eb 0f                	jmp    8013cc <memcmp+0x35>
		s1++, s2++;
  8013bd:	83 c0 01             	add    $0x1,%eax
  8013c0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013c3:	39 f0                	cmp    %esi,%eax
  8013c5:	75 e2                	jne    8013a9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013cc:	5b                   	pop    %ebx
  8013cd:	5e                   	pop    %esi
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    

008013d0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	53                   	push   %ebx
  8013d4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8013d7:	89 c1                	mov    %eax,%ecx
  8013d9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8013dc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013e0:	eb 0a                	jmp    8013ec <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013e2:	0f b6 10             	movzbl (%eax),%edx
  8013e5:	39 da                	cmp    %ebx,%edx
  8013e7:	74 07                	je     8013f0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013e9:	83 c0 01             	add    $0x1,%eax
  8013ec:	39 c8                	cmp    %ecx,%eax
  8013ee:	72 f2                	jb     8013e2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013f0:	5b                   	pop    %ebx
  8013f1:	5d                   	pop    %ebp
  8013f2:	c3                   	ret    

008013f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	57                   	push   %edi
  8013f7:	56                   	push   %esi
  8013f8:	53                   	push   %ebx
  8013f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013ff:	eb 03                	jmp    801404 <strtol+0x11>
		s++;
  801401:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801404:	0f b6 01             	movzbl (%ecx),%eax
  801407:	3c 20                	cmp    $0x20,%al
  801409:	74 f6                	je     801401 <strtol+0xe>
  80140b:	3c 09                	cmp    $0x9,%al
  80140d:	74 f2                	je     801401 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80140f:	3c 2b                	cmp    $0x2b,%al
  801411:	75 0a                	jne    80141d <strtol+0x2a>
		s++;
  801413:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801416:	bf 00 00 00 00       	mov    $0x0,%edi
  80141b:	eb 11                	jmp    80142e <strtol+0x3b>
  80141d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801422:	3c 2d                	cmp    $0x2d,%al
  801424:	75 08                	jne    80142e <strtol+0x3b>
		s++, neg = 1;
  801426:	83 c1 01             	add    $0x1,%ecx
  801429:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80142e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801434:	75 15                	jne    80144b <strtol+0x58>
  801436:	80 39 30             	cmpb   $0x30,(%ecx)
  801439:	75 10                	jne    80144b <strtol+0x58>
  80143b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80143f:	75 7c                	jne    8014bd <strtol+0xca>
		s += 2, base = 16;
  801441:	83 c1 02             	add    $0x2,%ecx
  801444:	bb 10 00 00 00       	mov    $0x10,%ebx
  801449:	eb 16                	jmp    801461 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80144b:	85 db                	test   %ebx,%ebx
  80144d:	75 12                	jne    801461 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80144f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801454:	80 39 30             	cmpb   $0x30,(%ecx)
  801457:	75 08                	jne    801461 <strtol+0x6e>
		s++, base = 8;
  801459:	83 c1 01             	add    $0x1,%ecx
  80145c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801461:	b8 00 00 00 00       	mov    $0x0,%eax
  801466:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801469:	0f b6 11             	movzbl (%ecx),%edx
  80146c:	8d 72 d0             	lea    -0x30(%edx),%esi
  80146f:	89 f3                	mov    %esi,%ebx
  801471:	80 fb 09             	cmp    $0x9,%bl
  801474:	77 08                	ja     80147e <strtol+0x8b>
			dig = *s - '0';
  801476:	0f be d2             	movsbl %dl,%edx
  801479:	83 ea 30             	sub    $0x30,%edx
  80147c:	eb 22                	jmp    8014a0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80147e:	8d 72 9f             	lea    -0x61(%edx),%esi
  801481:	89 f3                	mov    %esi,%ebx
  801483:	80 fb 19             	cmp    $0x19,%bl
  801486:	77 08                	ja     801490 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801488:	0f be d2             	movsbl %dl,%edx
  80148b:	83 ea 57             	sub    $0x57,%edx
  80148e:	eb 10                	jmp    8014a0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801490:	8d 72 bf             	lea    -0x41(%edx),%esi
  801493:	89 f3                	mov    %esi,%ebx
  801495:	80 fb 19             	cmp    $0x19,%bl
  801498:	77 16                	ja     8014b0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80149a:	0f be d2             	movsbl %dl,%edx
  80149d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8014a0:	3b 55 10             	cmp    0x10(%ebp),%edx
  8014a3:	7d 0b                	jge    8014b0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8014a5:	83 c1 01             	add    $0x1,%ecx
  8014a8:	0f af 45 10          	imul   0x10(%ebp),%eax
  8014ac:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8014ae:	eb b9                	jmp    801469 <strtol+0x76>

	if (endptr)
  8014b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014b4:	74 0d                	je     8014c3 <strtol+0xd0>
		*endptr = (char *) s;
  8014b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014b9:	89 0e                	mov    %ecx,(%esi)
  8014bb:	eb 06                	jmp    8014c3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014bd:	85 db                	test   %ebx,%ebx
  8014bf:	74 98                	je     801459 <strtol+0x66>
  8014c1:	eb 9e                	jmp    801461 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8014c3:	89 c2                	mov    %eax,%edx
  8014c5:	f7 da                	neg    %edx
  8014c7:	85 ff                	test   %edi,%edi
  8014c9:	0f 45 c2             	cmovne %edx,%eax
}
  8014cc:	5b                   	pop    %ebx
  8014cd:	5e                   	pop    %esi
  8014ce:	5f                   	pop    %edi
  8014cf:	5d                   	pop    %ebp
  8014d0:	c3                   	ret    

008014d1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	57                   	push   %edi
  8014d5:	56                   	push   %esi
  8014d6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014df:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e2:	89 c3                	mov    %eax,%ebx
  8014e4:	89 c7                	mov    %eax,%edi
  8014e6:	89 c6                	mov    %eax,%esi
  8014e8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014ea:	5b                   	pop    %ebx
  8014eb:	5e                   	pop    %esi
  8014ec:	5f                   	pop    %edi
  8014ed:	5d                   	pop    %ebp
  8014ee:	c3                   	ret    

008014ef <sys_cgetc>:

int
sys_cgetc(void)
{
  8014ef:	55                   	push   %ebp
  8014f0:	89 e5                	mov    %esp,%ebp
  8014f2:	57                   	push   %edi
  8014f3:	56                   	push   %esi
  8014f4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ff:	89 d1                	mov    %edx,%ecx
  801501:	89 d3                	mov    %edx,%ebx
  801503:	89 d7                	mov    %edx,%edi
  801505:	89 d6                	mov    %edx,%esi
  801507:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801509:	5b                   	pop    %ebx
  80150a:	5e                   	pop    %esi
  80150b:	5f                   	pop    %edi
  80150c:	5d                   	pop    %ebp
  80150d:	c3                   	ret    

0080150e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	57                   	push   %edi
  801512:	56                   	push   %esi
  801513:	53                   	push   %ebx
  801514:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801517:	b9 00 00 00 00       	mov    $0x0,%ecx
  80151c:	b8 03 00 00 00       	mov    $0x3,%eax
  801521:	8b 55 08             	mov    0x8(%ebp),%edx
  801524:	89 cb                	mov    %ecx,%ebx
  801526:	89 cf                	mov    %ecx,%edi
  801528:	89 ce                	mov    %ecx,%esi
  80152a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80152c:	85 c0                	test   %eax,%eax
  80152e:	7e 17                	jle    801547 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801530:	83 ec 0c             	sub    $0xc,%esp
  801533:	50                   	push   %eax
  801534:	6a 03                	push   $0x3
  801536:	68 8f 38 80 00       	push   $0x80388f
  80153b:	6a 23                	push   $0x23
  80153d:	68 ac 38 80 00       	push   $0x8038ac
  801542:	e8 f2 f4 ff ff       	call   800a39 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801547:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80154a:	5b                   	pop    %ebx
  80154b:	5e                   	pop    %esi
  80154c:	5f                   	pop    %edi
  80154d:	5d                   	pop    %ebp
  80154e:	c3                   	ret    

0080154f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	57                   	push   %edi
  801553:	56                   	push   %esi
  801554:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801555:	ba 00 00 00 00       	mov    $0x0,%edx
  80155a:	b8 02 00 00 00       	mov    $0x2,%eax
  80155f:	89 d1                	mov    %edx,%ecx
  801561:	89 d3                	mov    %edx,%ebx
  801563:	89 d7                	mov    %edx,%edi
  801565:	89 d6                	mov    %edx,%esi
  801567:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801569:	5b                   	pop    %ebx
  80156a:	5e                   	pop    %esi
  80156b:	5f                   	pop    %edi
  80156c:	5d                   	pop    %ebp
  80156d:	c3                   	ret    

0080156e <sys_yield>:

void
sys_yield(void)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	57                   	push   %edi
  801572:	56                   	push   %esi
  801573:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801574:	ba 00 00 00 00       	mov    $0x0,%edx
  801579:	b8 0b 00 00 00       	mov    $0xb,%eax
  80157e:	89 d1                	mov    %edx,%ecx
  801580:	89 d3                	mov    %edx,%ebx
  801582:	89 d7                	mov    %edx,%edi
  801584:	89 d6                	mov    %edx,%esi
  801586:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801588:	5b                   	pop    %ebx
  801589:	5e                   	pop    %esi
  80158a:	5f                   	pop    %edi
  80158b:	5d                   	pop    %ebp
  80158c:	c3                   	ret    

0080158d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80158d:	55                   	push   %ebp
  80158e:	89 e5                	mov    %esp,%ebp
  801590:	57                   	push   %edi
  801591:	56                   	push   %esi
  801592:	53                   	push   %ebx
  801593:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801596:	be 00 00 00 00       	mov    $0x0,%esi
  80159b:	b8 04 00 00 00       	mov    $0x4,%eax
  8015a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8015a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015a9:	89 f7                	mov    %esi,%edi
  8015ab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	7e 17                	jle    8015c8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015b1:	83 ec 0c             	sub    $0xc,%esp
  8015b4:	50                   	push   %eax
  8015b5:	6a 04                	push   $0x4
  8015b7:	68 8f 38 80 00       	push   $0x80388f
  8015bc:	6a 23                	push   $0x23
  8015be:	68 ac 38 80 00       	push   $0x8038ac
  8015c3:	e8 71 f4 ff ff       	call   800a39 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015cb:	5b                   	pop    %ebx
  8015cc:	5e                   	pop    %esi
  8015cd:	5f                   	pop    %edi
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	57                   	push   %edi
  8015d4:	56                   	push   %esi
  8015d5:	53                   	push   %ebx
  8015d6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8015de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8015e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015e7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015ea:	8b 75 18             	mov    0x18(%ebp),%esi
  8015ed:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	7e 17                	jle    80160a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015f3:	83 ec 0c             	sub    $0xc,%esp
  8015f6:	50                   	push   %eax
  8015f7:	6a 05                	push   $0x5
  8015f9:	68 8f 38 80 00       	push   $0x80388f
  8015fe:	6a 23                	push   $0x23
  801600:	68 ac 38 80 00       	push   $0x8038ac
  801605:	e8 2f f4 ff ff       	call   800a39 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80160a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160d:	5b                   	pop    %ebx
  80160e:	5e                   	pop    %esi
  80160f:	5f                   	pop    %edi
  801610:	5d                   	pop    %ebp
  801611:	c3                   	ret    

00801612 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	57                   	push   %edi
  801616:	56                   	push   %esi
  801617:	53                   	push   %ebx
  801618:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80161b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801620:	b8 06 00 00 00       	mov    $0x6,%eax
  801625:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801628:	8b 55 08             	mov    0x8(%ebp),%edx
  80162b:	89 df                	mov    %ebx,%edi
  80162d:	89 de                	mov    %ebx,%esi
  80162f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801631:	85 c0                	test   %eax,%eax
  801633:	7e 17                	jle    80164c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801635:	83 ec 0c             	sub    $0xc,%esp
  801638:	50                   	push   %eax
  801639:	6a 06                	push   $0x6
  80163b:	68 8f 38 80 00       	push   $0x80388f
  801640:	6a 23                	push   $0x23
  801642:	68 ac 38 80 00       	push   $0x8038ac
  801647:	e8 ed f3 ff ff       	call   800a39 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80164c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164f:	5b                   	pop    %ebx
  801650:	5e                   	pop    %esi
  801651:	5f                   	pop    %edi
  801652:	5d                   	pop    %ebp
  801653:	c3                   	ret    

00801654 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	57                   	push   %edi
  801658:	56                   	push   %esi
  801659:	53                   	push   %ebx
  80165a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80165d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801662:	b8 08 00 00 00       	mov    $0x8,%eax
  801667:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80166a:	8b 55 08             	mov    0x8(%ebp),%edx
  80166d:	89 df                	mov    %ebx,%edi
  80166f:	89 de                	mov    %ebx,%esi
  801671:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801673:	85 c0                	test   %eax,%eax
  801675:	7e 17                	jle    80168e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801677:	83 ec 0c             	sub    $0xc,%esp
  80167a:	50                   	push   %eax
  80167b:	6a 08                	push   $0x8
  80167d:	68 8f 38 80 00       	push   $0x80388f
  801682:	6a 23                	push   $0x23
  801684:	68 ac 38 80 00       	push   $0x8038ac
  801689:	e8 ab f3 ff ff       	call   800a39 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80168e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801691:	5b                   	pop    %ebx
  801692:	5e                   	pop    %esi
  801693:	5f                   	pop    %edi
  801694:	5d                   	pop    %ebp
  801695:	c3                   	ret    

00801696 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	57                   	push   %edi
  80169a:	56                   	push   %esi
  80169b:	53                   	push   %ebx
  80169c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80169f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a4:	b8 09 00 00 00       	mov    $0x9,%eax
  8016a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8016af:	89 df                	mov    %ebx,%edi
  8016b1:	89 de                	mov    %ebx,%esi
  8016b3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	7e 17                	jle    8016d0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016b9:	83 ec 0c             	sub    $0xc,%esp
  8016bc:	50                   	push   %eax
  8016bd:	6a 09                	push   $0x9
  8016bf:	68 8f 38 80 00       	push   $0x80388f
  8016c4:	6a 23                	push   $0x23
  8016c6:	68 ac 38 80 00       	push   $0x8038ac
  8016cb:	e8 69 f3 ff ff       	call   800a39 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d3:	5b                   	pop    %ebx
  8016d4:	5e                   	pop    %esi
  8016d5:	5f                   	pop    %edi
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    

008016d8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	57                   	push   %edi
  8016dc:	56                   	push   %esi
  8016dd:	53                   	push   %ebx
  8016de:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f1:	89 df                	mov    %ebx,%edi
  8016f3:	89 de                	mov    %ebx,%esi
  8016f5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	7e 17                	jle    801712 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016fb:	83 ec 0c             	sub    $0xc,%esp
  8016fe:	50                   	push   %eax
  8016ff:	6a 0a                	push   $0xa
  801701:	68 8f 38 80 00       	push   $0x80388f
  801706:	6a 23                	push   $0x23
  801708:	68 ac 38 80 00       	push   $0x8038ac
  80170d:	e8 27 f3 ff ff       	call   800a39 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801712:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801715:	5b                   	pop    %ebx
  801716:	5e                   	pop    %esi
  801717:	5f                   	pop    %edi
  801718:	5d                   	pop    %ebp
  801719:	c3                   	ret    

0080171a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	57                   	push   %edi
  80171e:	56                   	push   %esi
  80171f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801720:	be 00 00 00 00       	mov    $0x0,%esi
  801725:	b8 0c 00 00 00       	mov    $0xc,%eax
  80172a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172d:	8b 55 08             	mov    0x8(%ebp),%edx
  801730:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801733:	8b 7d 14             	mov    0x14(%ebp),%edi
  801736:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801738:	5b                   	pop    %ebx
  801739:	5e                   	pop    %esi
  80173a:	5f                   	pop    %edi
  80173b:	5d                   	pop    %ebp
  80173c:	c3                   	ret    

0080173d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	57                   	push   %edi
  801741:	56                   	push   %esi
  801742:	53                   	push   %ebx
  801743:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801746:	b9 00 00 00 00       	mov    $0x0,%ecx
  80174b:	b8 0d 00 00 00       	mov    $0xd,%eax
  801750:	8b 55 08             	mov    0x8(%ebp),%edx
  801753:	89 cb                	mov    %ecx,%ebx
  801755:	89 cf                	mov    %ecx,%edi
  801757:	89 ce                	mov    %ecx,%esi
  801759:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80175b:	85 c0                	test   %eax,%eax
  80175d:	7e 17                	jle    801776 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80175f:	83 ec 0c             	sub    $0xc,%esp
  801762:	50                   	push   %eax
  801763:	6a 0d                	push   $0xd
  801765:	68 8f 38 80 00       	push   $0x80388f
  80176a:	6a 23                	push   $0x23
  80176c:	68 ac 38 80 00       	push   $0x8038ac
  801771:	e8 c3 f2 ff ff       	call   800a39 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801776:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801779:	5b                   	pop    %ebx
  80177a:	5e                   	pop    %esi
  80177b:	5f                   	pop    %edi
  80177c:	5d                   	pop    %ebp
  80177d:	c3                   	ret    

0080177e <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	57                   	push   %edi
  801782:	56                   	push   %esi
  801783:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801784:	b9 00 00 00 00       	mov    $0x0,%ecx
  801789:	b8 0e 00 00 00       	mov    $0xe,%eax
  80178e:	8b 55 08             	mov    0x8(%ebp),%edx
  801791:	89 cb                	mov    %ecx,%ebx
  801793:	89 cf                	mov    %ecx,%edi
  801795:	89 ce                	mov    %ecx,%esi
  801797:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  801799:	5b                   	pop    %ebx
  80179a:	5e                   	pop    %esi
  80179b:	5f                   	pop    %edi
  80179c:	5d                   	pop    %ebp
  80179d:	c3                   	ret    

0080179e <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	57                   	push   %edi
  8017a2:	56                   	push   %esi
  8017a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017a9:	b8 0f 00 00 00       	mov    $0xf,%eax
  8017ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b1:	89 cb                	mov    %ecx,%ebx
  8017b3:	89 cf                	mov    %ecx,%edi
  8017b5:	89 ce                	mov    %ecx,%esi
  8017b7:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8017b9:	5b                   	pop    %ebx
  8017ba:	5e                   	pop    %esi
  8017bb:	5f                   	pop    %edi
  8017bc:	5d                   	pop    %ebp
  8017bd:	c3                   	ret    

008017be <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	53                   	push   %ebx
  8017c2:	83 ec 04             	sub    $0x4,%esp
  8017c5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8017c8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8017ca:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8017ce:	74 11                	je     8017e1 <pgfault+0x23>
  8017d0:	89 d8                	mov    %ebx,%eax
  8017d2:	c1 e8 0c             	shr    $0xc,%eax
  8017d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017dc:	f6 c4 08             	test   $0x8,%ah
  8017df:	75 14                	jne    8017f5 <pgfault+0x37>
		panic("faulting access");
  8017e1:	83 ec 04             	sub    $0x4,%esp
  8017e4:	68 ba 38 80 00       	push   $0x8038ba
  8017e9:	6a 1e                	push   $0x1e
  8017eb:	68 ca 38 80 00       	push   $0x8038ca
  8017f0:	e8 44 f2 ff ff       	call   800a39 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8017f5:	83 ec 04             	sub    $0x4,%esp
  8017f8:	6a 07                	push   $0x7
  8017fa:	68 00 f0 7f 00       	push   $0x7ff000
  8017ff:	6a 00                	push   $0x0
  801801:	e8 87 fd ff ff       	call   80158d <sys_page_alloc>
	if (r < 0) {
  801806:	83 c4 10             	add    $0x10,%esp
  801809:	85 c0                	test   %eax,%eax
  80180b:	79 12                	jns    80181f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  80180d:	50                   	push   %eax
  80180e:	68 d5 38 80 00       	push   $0x8038d5
  801813:	6a 2c                	push   $0x2c
  801815:	68 ca 38 80 00       	push   $0x8038ca
  80181a:	e8 1a f2 ff ff       	call   800a39 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80181f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  801825:	83 ec 04             	sub    $0x4,%esp
  801828:	68 00 10 00 00       	push   $0x1000
  80182d:	53                   	push   %ebx
  80182e:	68 00 f0 7f 00       	push   $0x7ff000
  801833:	e8 4c fb ff ff       	call   801384 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801838:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80183f:	53                   	push   %ebx
  801840:	6a 00                	push   $0x0
  801842:	68 00 f0 7f 00       	push   $0x7ff000
  801847:	6a 00                	push   $0x0
  801849:	e8 82 fd ff ff       	call   8015d0 <sys_page_map>
	if (r < 0) {
  80184e:	83 c4 20             	add    $0x20,%esp
  801851:	85 c0                	test   %eax,%eax
  801853:	79 12                	jns    801867 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  801855:	50                   	push   %eax
  801856:	68 d5 38 80 00       	push   $0x8038d5
  80185b:	6a 33                	push   $0x33
  80185d:	68 ca 38 80 00       	push   $0x8038ca
  801862:	e8 d2 f1 ff ff       	call   800a39 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	68 00 f0 7f 00       	push   $0x7ff000
  80186f:	6a 00                	push   $0x0
  801871:	e8 9c fd ff ff       	call   801612 <sys_page_unmap>
	if (r < 0) {
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	85 c0                	test   %eax,%eax
  80187b:	79 12                	jns    80188f <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80187d:	50                   	push   %eax
  80187e:	68 d5 38 80 00       	push   $0x8038d5
  801883:	6a 37                	push   $0x37
  801885:	68 ca 38 80 00       	push   $0x8038ca
  80188a:	e8 aa f1 ff ff       	call   800a39 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80188f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801892:	c9                   	leave  
  801893:	c3                   	ret    

00801894 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	57                   	push   %edi
  801898:	56                   	push   %esi
  801899:	53                   	push   %ebx
  80189a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80189d:	68 be 17 80 00       	push   $0x8017be
  8018a2:	e8 07 16 00 00       	call   802eae <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8018a7:	b8 07 00 00 00       	mov    $0x7,%eax
  8018ac:	cd 30                	int    $0x30
  8018ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	79 17                	jns    8018cf <fork+0x3b>
		panic("fork fault %e");
  8018b8:	83 ec 04             	sub    $0x4,%esp
  8018bb:	68 ee 38 80 00       	push   $0x8038ee
  8018c0:	68 84 00 00 00       	push   $0x84
  8018c5:	68 ca 38 80 00       	push   $0x8038ca
  8018ca:	e8 6a f1 ff ff       	call   800a39 <_panic>
  8018cf:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8018d1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8018d5:	75 25                	jne    8018fc <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8018d7:	e8 73 fc ff ff       	call   80154f <sys_getenvid>
  8018dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018e1:	89 c2                	mov    %eax,%edx
  8018e3:	c1 e2 07             	shl    $0x7,%edx
  8018e6:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8018ed:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  8018f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f7:	e9 61 01 00 00       	jmp    801a5d <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8018fc:	83 ec 04             	sub    $0x4,%esp
  8018ff:	6a 07                	push   $0x7
  801901:	68 00 f0 bf ee       	push   $0xeebff000
  801906:	ff 75 e4             	pushl  -0x1c(%ebp)
  801909:	e8 7f fc ff ff       	call   80158d <sys_page_alloc>
  80190e:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801911:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801916:	89 d8                	mov    %ebx,%eax
  801918:	c1 e8 16             	shr    $0x16,%eax
  80191b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801922:	a8 01                	test   $0x1,%al
  801924:	0f 84 fc 00 00 00    	je     801a26 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80192a:	89 d8                	mov    %ebx,%eax
  80192c:	c1 e8 0c             	shr    $0xc,%eax
  80192f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801936:	f6 c2 01             	test   $0x1,%dl
  801939:	0f 84 e7 00 00 00    	je     801a26 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80193f:	89 c6                	mov    %eax,%esi
  801941:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801944:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80194b:	f6 c6 04             	test   $0x4,%dh
  80194e:	74 39                	je     801989 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801950:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801957:	83 ec 0c             	sub    $0xc,%esp
  80195a:	25 07 0e 00 00       	and    $0xe07,%eax
  80195f:	50                   	push   %eax
  801960:	56                   	push   %esi
  801961:	57                   	push   %edi
  801962:	56                   	push   %esi
  801963:	6a 00                	push   $0x0
  801965:	e8 66 fc ff ff       	call   8015d0 <sys_page_map>
		if (r < 0) {
  80196a:	83 c4 20             	add    $0x20,%esp
  80196d:	85 c0                	test   %eax,%eax
  80196f:	0f 89 b1 00 00 00    	jns    801a26 <fork+0x192>
		    	panic("sys page map fault %e");
  801975:	83 ec 04             	sub    $0x4,%esp
  801978:	68 fc 38 80 00       	push   $0x8038fc
  80197d:	6a 54                	push   $0x54
  80197f:	68 ca 38 80 00       	push   $0x8038ca
  801984:	e8 b0 f0 ff ff       	call   800a39 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801989:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801990:	f6 c2 02             	test   $0x2,%dl
  801993:	75 0c                	jne    8019a1 <fork+0x10d>
  801995:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80199c:	f6 c4 08             	test   $0x8,%ah
  80199f:	74 5b                	je     8019fc <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8019a1:	83 ec 0c             	sub    $0xc,%esp
  8019a4:	68 05 08 00 00       	push   $0x805
  8019a9:	56                   	push   %esi
  8019aa:	57                   	push   %edi
  8019ab:	56                   	push   %esi
  8019ac:	6a 00                	push   $0x0
  8019ae:	e8 1d fc ff ff       	call   8015d0 <sys_page_map>
		if (r < 0) {
  8019b3:	83 c4 20             	add    $0x20,%esp
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	79 14                	jns    8019ce <fork+0x13a>
		    	panic("sys page map fault %e");
  8019ba:	83 ec 04             	sub    $0x4,%esp
  8019bd:	68 fc 38 80 00       	push   $0x8038fc
  8019c2:	6a 5b                	push   $0x5b
  8019c4:	68 ca 38 80 00       	push   $0x8038ca
  8019c9:	e8 6b f0 ff ff       	call   800a39 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8019ce:	83 ec 0c             	sub    $0xc,%esp
  8019d1:	68 05 08 00 00       	push   $0x805
  8019d6:	56                   	push   %esi
  8019d7:	6a 00                	push   $0x0
  8019d9:	56                   	push   %esi
  8019da:	6a 00                	push   $0x0
  8019dc:	e8 ef fb ff ff       	call   8015d0 <sys_page_map>
		if (r < 0) {
  8019e1:	83 c4 20             	add    $0x20,%esp
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	79 3e                	jns    801a26 <fork+0x192>
		    	panic("sys page map fault %e");
  8019e8:	83 ec 04             	sub    $0x4,%esp
  8019eb:	68 fc 38 80 00       	push   $0x8038fc
  8019f0:	6a 5f                	push   $0x5f
  8019f2:	68 ca 38 80 00       	push   $0x8038ca
  8019f7:	e8 3d f0 ff ff       	call   800a39 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8019fc:	83 ec 0c             	sub    $0xc,%esp
  8019ff:	6a 05                	push   $0x5
  801a01:	56                   	push   %esi
  801a02:	57                   	push   %edi
  801a03:	56                   	push   %esi
  801a04:	6a 00                	push   $0x0
  801a06:	e8 c5 fb ff ff       	call   8015d0 <sys_page_map>
		if (r < 0) {
  801a0b:	83 c4 20             	add    $0x20,%esp
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	79 14                	jns    801a26 <fork+0x192>
		    	panic("sys page map fault %e");
  801a12:	83 ec 04             	sub    $0x4,%esp
  801a15:	68 fc 38 80 00       	push   $0x8038fc
  801a1a:	6a 64                	push   $0x64
  801a1c:	68 ca 38 80 00       	push   $0x8038ca
  801a21:	e8 13 f0 ff ff       	call   800a39 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801a26:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a2c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801a32:	0f 85 de fe ff ff    	jne    801916 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801a38:	a1 24 54 80 00       	mov    0x805424,%eax
  801a3d:	8b 40 70             	mov    0x70(%eax),%eax
  801a40:	83 ec 08             	sub    $0x8,%esp
  801a43:	50                   	push   %eax
  801a44:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a47:	57                   	push   %edi
  801a48:	e8 8b fc ff ff       	call   8016d8 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801a4d:	83 c4 08             	add    $0x8,%esp
  801a50:	6a 02                	push   $0x2
  801a52:	57                   	push   %edi
  801a53:	e8 fc fb ff ff       	call   801654 <sys_env_set_status>
	
	return envid;
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801a5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a60:	5b                   	pop    %ebx
  801a61:	5e                   	pop    %esi
  801a62:	5f                   	pop    %edi
  801a63:	5d                   	pop    %ebp
  801a64:	c3                   	ret    

00801a65 <sfork>:

envid_t
sfork(void)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801a68:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	56                   	push   %esi
  801a73:	53                   	push   %ebx
  801a74:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801a77:	89 1d 28 54 80 00    	mov    %ebx,0x805428
	cprintf("in fork.c thread create. func: %x\n", func);
  801a7d:	83 ec 08             	sub    $0x8,%esp
  801a80:	53                   	push   %ebx
  801a81:	68 14 39 80 00       	push   $0x803914
  801a86:	e8 87 f0 ff ff       	call   800b12 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801a8b:	c7 04 24 ff 09 80 00 	movl   $0x8009ff,(%esp)
  801a92:	e8 e7 fc ff ff       	call   80177e <sys_thread_create>
  801a97:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801a99:	83 c4 08             	add    $0x8,%esp
  801a9c:	53                   	push   %ebx
  801a9d:	68 14 39 80 00       	push   $0x803914
  801aa2:	e8 6b f0 ff ff       	call   800b12 <cprintf>
	return id;
	//return 0;
}
  801aa7:	89 f0                	mov    %esi,%eax
  801aa9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5e                   	pop    %esi
  801aae:	5d                   	pop    %ebp
  801aaf:	c3                   	ret    

00801ab0 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	8b 55 08             	mov    0x8(%ebp),%edx
  801ab6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab9:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801abc:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801abe:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801ac1:	83 3a 01             	cmpl   $0x1,(%edx)
  801ac4:	7e 09                	jle    801acf <argstart+0x1f>
  801ac6:	ba 61 33 80 00       	mov    $0x803361,%edx
  801acb:	85 c9                	test   %ecx,%ecx
  801acd:	75 05                	jne    801ad4 <argstart+0x24>
  801acf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad4:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801ad7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    

00801ae0 <argnext>:

int
argnext(struct Argstate *args)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 04             	sub    $0x4,%esp
  801ae7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801aea:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801af1:	8b 43 08             	mov    0x8(%ebx),%eax
  801af4:	85 c0                	test   %eax,%eax
  801af6:	74 6f                	je     801b67 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801af8:	80 38 00             	cmpb   $0x0,(%eax)
  801afb:	75 4e                	jne    801b4b <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801afd:	8b 0b                	mov    (%ebx),%ecx
  801aff:	83 39 01             	cmpl   $0x1,(%ecx)
  801b02:	74 55                	je     801b59 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801b04:	8b 53 04             	mov    0x4(%ebx),%edx
  801b07:	8b 42 04             	mov    0x4(%edx),%eax
  801b0a:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b0d:	75 4a                	jne    801b59 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801b0f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b13:	74 44                	je     801b59 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b15:	83 c0 01             	add    $0x1,%eax
  801b18:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b1b:	83 ec 04             	sub    $0x4,%esp
  801b1e:	8b 01                	mov    (%ecx),%eax
  801b20:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b27:	50                   	push   %eax
  801b28:	8d 42 08             	lea    0x8(%edx),%eax
  801b2b:	50                   	push   %eax
  801b2c:	83 c2 04             	add    $0x4,%edx
  801b2f:	52                   	push   %edx
  801b30:	e8 e7 f7 ff ff       	call   80131c <memmove>
		(*args->argc)--;
  801b35:	8b 03                	mov    (%ebx),%eax
  801b37:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b3a:	8b 43 08             	mov    0x8(%ebx),%eax
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b43:	75 06                	jne    801b4b <argnext+0x6b>
  801b45:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b49:	74 0e                	je     801b59 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b4b:	8b 53 08             	mov    0x8(%ebx),%edx
  801b4e:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b51:	83 c2 01             	add    $0x1,%edx
  801b54:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b57:	eb 13                	jmp    801b6c <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b59:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b65:	eb 05                	jmp    801b6c <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b6f:	c9                   	leave  
  801b70:	c3                   	ret    

00801b71 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	53                   	push   %ebx
  801b75:	83 ec 04             	sub    $0x4,%esp
  801b78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b7b:	8b 43 08             	mov    0x8(%ebx),%eax
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	74 58                	je     801bda <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801b82:	80 38 00             	cmpb   $0x0,(%eax)
  801b85:	74 0c                	je     801b93 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801b87:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b8a:	c7 43 08 61 33 80 00 	movl   $0x803361,0x8(%ebx)
  801b91:	eb 42                	jmp    801bd5 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801b93:	8b 13                	mov    (%ebx),%edx
  801b95:	83 3a 01             	cmpl   $0x1,(%edx)
  801b98:	7e 2d                	jle    801bc7 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801b9a:	8b 43 04             	mov    0x4(%ebx),%eax
  801b9d:	8b 48 04             	mov    0x4(%eax),%ecx
  801ba0:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801ba3:	83 ec 04             	sub    $0x4,%esp
  801ba6:	8b 12                	mov    (%edx),%edx
  801ba8:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801baf:	52                   	push   %edx
  801bb0:	8d 50 08             	lea    0x8(%eax),%edx
  801bb3:	52                   	push   %edx
  801bb4:	83 c0 04             	add    $0x4,%eax
  801bb7:	50                   	push   %eax
  801bb8:	e8 5f f7 ff ff       	call   80131c <memmove>
		(*args->argc)--;
  801bbd:	8b 03                	mov    (%ebx),%eax
  801bbf:	83 28 01             	subl   $0x1,(%eax)
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	eb 0e                	jmp    801bd5 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801bc7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801bce:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801bd5:	8b 43 0c             	mov    0xc(%ebx),%eax
  801bd8:	eb 05                	jmp    801bdf <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801bda:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801bdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be2:	c9                   	leave  
  801be3:	c3                   	ret    

00801be4 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	83 ec 08             	sub    $0x8,%esp
  801bea:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801bed:	8b 51 0c             	mov    0xc(%ecx),%edx
  801bf0:	89 d0                	mov    %edx,%eax
  801bf2:	85 d2                	test   %edx,%edx
  801bf4:	75 0c                	jne    801c02 <argvalue+0x1e>
  801bf6:	83 ec 0c             	sub    $0xc,%esp
  801bf9:	51                   	push   %ecx
  801bfa:	e8 72 ff ff ff       	call   801b71 <argnextvalue>
  801bff:	83 c4 10             	add    $0x10,%esp
}
  801c02:	c9                   	leave  
  801c03:	c3                   	ret    

00801c04 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c07:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0a:	05 00 00 00 30       	add    $0x30000000,%eax
  801c0f:	c1 e8 0c             	shr    $0xc,%eax
}
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    

00801c14 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801c17:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1a:	05 00 00 00 30       	add    $0x30000000,%eax
  801c1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c24:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c31:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c36:	89 c2                	mov    %eax,%edx
  801c38:	c1 ea 16             	shr    $0x16,%edx
  801c3b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c42:	f6 c2 01             	test   $0x1,%dl
  801c45:	74 11                	je     801c58 <fd_alloc+0x2d>
  801c47:	89 c2                	mov    %eax,%edx
  801c49:	c1 ea 0c             	shr    $0xc,%edx
  801c4c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c53:	f6 c2 01             	test   $0x1,%dl
  801c56:	75 09                	jne    801c61 <fd_alloc+0x36>
			*fd_store = fd;
  801c58:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5f:	eb 17                	jmp    801c78 <fd_alloc+0x4d>
  801c61:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c66:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c6b:	75 c9                	jne    801c36 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c6d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801c73:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    

00801c7a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c80:	83 f8 1f             	cmp    $0x1f,%eax
  801c83:	77 36                	ja     801cbb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c85:	c1 e0 0c             	shl    $0xc,%eax
  801c88:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c8d:	89 c2                	mov    %eax,%edx
  801c8f:	c1 ea 16             	shr    $0x16,%edx
  801c92:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c99:	f6 c2 01             	test   $0x1,%dl
  801c9c:	74 24                	je     801cc2 <fd_lookup+0x48>
  801c9e:	89 c2                	mov    %eax,%edx
  801ca0:	c1 ea 0c             	shr    $0xc,%edx
  801ca3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801caa:	f6 c2 01             	test   $0x1,%dl
  801cad:	74 1a                	je     801cc9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801caf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb2:	89 02                	mov    %eax,(%edx)
	return 0;
  801cb4:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb9:	eb 13                	jmp    801cce <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cbb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cc0:	eb 0c                	jmp    801cce <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cc2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cc7:	eb 05                	jmp    801cce <fd_lookup+0x54>
  801cc9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    

00801cd0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	83 ec 08             	sub    $0x8,%esp
  801cd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd9:	ba b4 39 80 00       	mov    $0x8039b4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801cde:	eb 13                	jmp    801cf3 <dev_lookup+0x23>
  801ce0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801ce3:	39 08                	cmp    %ecx,(%eax)
  801ce5:	75 0c                	jne    801cf3 <dev_lookup+0x23>
			*dev = devtab[i];
  801ce7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cea:	89 01                	mov    %eax,(%ecx)
			return 0;
  801cec:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf1:	eb 2e                	jmp    801d21 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801cf3:	8b 02                	mov    (%edx),%eax
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	75 e7                	jne    801ce0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801cf9:	a1 24 54 80 00       	mov    0x805424,%eax
  801cfe:	8b 40 54             	mov    0x54(%eax),%eax
  801d01:	83 ec 04             	sub    $0x4,%esp
  801d04:	51                   	push   %ecx
  801d05:	50                   	push   %eax
  801d06:	68 38 39 80 00       	push   $0x803938
  801d0b:	e8 02 ee ff ff       	call   800b12 <cprintf>
	*dev = 0;
  801d10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d13:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d21:	c9                   	leave  
  801d22:	c3                   	ret    

00801d23 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	56                   	push   %esi
  801d27:	53                   	push   %ebx
  801d28:	83 ec 10             	sub    $0x10,%esp
  801d2b:	8b 75 08             	mov    0x8(%ebp),%esi
  801d2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d34:	50                   	push   %eax
  801d35:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d3b:	c1 e8 0c             	shr    $0xc,%eax
  801d3e:	50                   	push   %eax
  801d3f:	e8 36 ff ff ff       	call   801c7a <fd_lookup>
  801d44:	83 c4 08             	add    $0x8,%esp
  801d47:	85 c0                	test   %eax,%eax
  801d49:	78 05                	js     801d50 <fd_close+0x2d>
	    || fd != fd2)
  801d4b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d4e:	74 0c                	je     801d5c <fd_close+0x39>
		return (must_exist ? r : 0);
  801d50:	84 db                	test   %bl,%bl
  801d52:	ba 00 00 00 00       	mov    $0x0,%edx
  801d57:	0f 44 c2             	cmove  %edx,%eax
  801d5a:	eb 41                	jmp    801d9d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d5c:	83 ec 08             	sub    $0x8,%esp
  801d5f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d62:	50                   	push   %eax
  801d63:	ff 36                	pushl  (%esi)
  801d65:	e8 66 ff ff ff       	call   801cd0 <dev_lookup>
  801d6a:	89 c3                	mov    %eax,%ebx
  801d6c:	83 c4 10             	add    $0x10,%esp
  801d6f:	85 c0                	test   %eax,%eax
  801d71:	78 1a                	js     801d8d <fd_close+0x6a>
		if (dev->dev_close)
  801d73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d76:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801d79:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	74 0b                	je     801d8d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801d82:	83 ec 0c             	sub    $0xc,%esp
  801d85:	56                   	push   %esi
  801d86:	ff d0                	call   *%eax
  801d88:	89 c3                	mov    %eax,%ebx
  801d8a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d8d:	83 ec 08             	sub    $0x8,%esp
  801d90:	56                   	push   %esi
  801d91:	6a 00                	push   $0x0
  801d93:	e8 7a f8 ff ff       	call   801612 <sys_page_unmap>
	return r;
  801d98:	83 c4 10             	add    $0x10,%esp
  801d9b:	89 d8                	mov    %ebx,%eax
}
  801d9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da0:	5b                   	pop    %ebx
  801da1:	5e                   	pop    %esi
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    

00801da4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801daa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dad:	50                   	push   %eax
  801dae:	ff 75 08             	pushl  0x8(%ebp)
  801db1:	e8 c4 fe ff ff       	call   801c7a <fd_lookup>
  801db6:	83 c4 08             	add    $0x8,%esp
  801db9:	85 c0                	test   %eax,%eax
  801dbb:	78 10                	js     801dcd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801dbd:	83 ec 08             	sub    $0x8,%esp
  801dc0:	6a 01                	push   $0x1
  801dc2:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc5:	e8 59 ff ff ff       	call   801d23 <fd_close>
  801dca:	83 c4 10             	add    $0x10,%esp
}
  801dcd:	c9                   	leave  
  801dce:	c3                   	ret    

00801dcf <close_all>:

void
close_all(void)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	53                   	push   %ebx
  801dd3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801dd6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801ddb:	83 ec 0c             	sub    $0xc,%esp
  801dde:	53                   	push   %ebx
  801ddf:	e8 c0 ff ff ff       	call   801da4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801de4:	83 c3 01             	add    $0x1,%ebx
  801de7:	83 c4 10             	add    $0x10,%esp
  801dea:	83 fb 20             	cmp    $0x20,%ebx
  801ded:	75 ec                	jne    801ddb <close_all+0xc>
		close(i);
}
  801def:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801df2:	c9                   	leave  
  801df3:	c3                   	ret    

00801df4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	57                   	push   %edi
  801df8:	56                   	push   %esi
  801df9:	53                   	push   %ebx
  801dfa:	83 ec 2c             	sub    $0x2c,%esp
  801dfd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e00:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e03:	50                   	push   %eax
  801e04:	ff 75 08             	pushl  0x8(%ebp)
  801e07:	e8 6e fe ff ff       	call   801c7a <fd_lookup>
  801e0c:	83 c4 08             	add    $0x8,%esp
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	0f 88 c1 00 00 00    	js     801ed8 <dup+0xe4>
		return r;
	close(newfdnum);
  801e17:	83 ec 0c             	sub    $0xc,%esp
  801e1a:	56                   	push   %esi
  801e1b:	e8 84 ff ff ff       	call   801da4 <close>

	newfd = INDEX2FD(newfdnum);
  801e20:	89 f3                	mov    %esi,%ebx
  801e22:	c1 e3 0c             	shl    $0xc,%ebx
  801e25:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801e2b:	83 c4 04             	add    $0x4,%esp
  801e2e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e31:	e8 de fd ff ff       	call   801c14 <fd2data>
  801e36:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801e38:	89 1c 24             	mov    %ebx,(%esp)
  801e3b:	e8 d4 fd ff ff       	call   801c14 <fd2data>
  801e40:	83 c4 10             	add    $0x10,%esp
  801e43:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e46:	89 f8                	mov    %edi,%eax
  801e48:	c1 e8 16             	shr    $0x16,%eax
  801e4b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e52:	a8 01                	test   $0x1,%al
  801e54:	74 37                	je     801e8d <dup+0x99>
  801e56:	89 f8                	mov    %edi,%eax
  801e58:	c1 e8 0c             	shr    $0xc,%eax
  801e5b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e62:	f6 c2 01             	test   $0x1,%dl
  801e65:	74 26                	je     801e8d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e67:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e6e:	83 ec 0c             	sub    $0xc,%esp
  801e71:	25 07 0e 00 00       	and    $0xe07,%eax
  801e76:	50                   	push   %eax
  801e77:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e7a:	6a 00                	push   $0x0
  801e7c:	57                   	push   %edi
  801e7d:	6a 00                	push   $0x0
  801e7f:	e8 4c f7 ff ff       	call   8015d0 <sys_page_map>
  801e84:	89 c7                	mov    %eax,%edi
  801e86:	83 c4 20             	add    $0x20,%esp
  801e89:	85 c0                	test   %eax,%eax
  801e8b:	78 2e                	js     801ebb <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e90:	89 d0                	mov    %edx,%eax
  801e92:	c1 e8 0c             	shr    $0xc,%eax
  801e95:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e9c:	83 ec 0c             	sub    $0xc,%esp
  801e9f:	25 07 0e 00 00       	and    $0xe07,%eax
  801ea4:	50                   	push   %eax
  801ea5:	53                   	push   %ebx
  801ea6:	6a 00                	push   $0x0
  801ea8:	52                   	push   %edx
  801ea9:	6a 00                	push   $0x0
  801eab:	e8 20 f7 ff ff       	call   8015d0 <sys_page_map>
  801eb0:	89 c7                	mov    %eax,%edi
  801eb2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801eb5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801eb7:	85 ff                	test   %edi,%edi
  801eb9:	79 1d                	jns    801ed8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801ebb:	83 ec 08             	sub    $0x8,%esp
  801ebe:	53                   	push   %ebx
  801ebf:	6a 00                	push   $0x0
  801ec1:	e8 4c f7 ff ff       	call   801612 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ec6:	83 c4 08             	add    $0x8,%esp
  801ec9:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ecc:	6a 00                	push   $0x0
  801ece:	e8 3f f7 ff ff       	call   801612 <sys_page_unmap>
	return r;
  801ed3:	83 c4 10             	add    $0x10,%esp
  801ed6:	89 f8                	mov    %edi,%eax
}
  801ed8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801edb:	5b                   	pop    %ebx
  801edc:	5e                   	pop    %esi
  801edd:	5f                   	pop    %edi
  801ede:	5d                   	pop    %ebp
  801edf:	c3                   	ret    

00801ee0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 14             	sub    $0x14,%esp
  801ee7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801eea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eed:	50                   	push   %eax
  801eee:	53                   	push   %ebx
  801eef:	e8 86 fd ff ff       	call   801c7a <fd_lookup>
  801ef4:	83 c4 08             	add    $0x8,%esp
  801ef7:	89 c2                	mov    %eax,%edx
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	78 6d                	js     801f6a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801efd:	83 ec 08             	sub    $0x8,%esp
  801f00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f03:	50                   	push   %eax
  801f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f07:	ff 30                	pushl  (%eax)
  801f09:	e8 c2 fd ff ff       	call   801cd0 <dev_lookup>
  801f0e:	83 c4 10             	add    $0x10,%esp
  801f11:	85 c0                	test   %eax,%eax
  801f13:	78 4c                	js     801f61 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f15:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f18:	8b 42 08             	mov    0x8(%edx),%eax
  801f1b:	83 e0 03             	and    $0x3,%eax
  801f1e:	83 f8 01             	cmp    $0x1,%eax
  801f21:	75 21                	jne    801f44 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f23:	a1 24 54 80 00       	mov    0x805424,%eax
  801f28:	8b 40 54             	mov    0x54(%eax),%eax
  801f2b:	83 ec 04             	sub    $0x4,%esp
  801f2e:	53                   	push   %ebx
  801f2f:	50                   	push   %eax
  801f30:	68 79 39 80 00       	push   $0x803979
  801f35:	e8 d8 eb ff ff       	call   800b12 <cprintf>
		return -E_INVAL;
  801f3a:	83 c4 10             	add    $0x10,%esp
  801f3d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f42:	eb 26                	jmp    801f6a <read+0x8a>
	}
	if (!dev->dev_read)
  801f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f47:	8b 40 08             	mov    0x8(%eax),%eax
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	74 17                	je     801f65 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801f4e:	83 ec 04             	sub    $0x4,%esp
  801f51:	ff 75 10             	pushl  0x10(%ebp)
  801f54:	ff 75 0c             	pushl  0xc(%ebp)
  801f57:	52                   	push   %edx
  801f58:	ff d0                	call   *%eax
  801f5a:	89 c2                	mov    %eax,%edx
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	eb 09                	jmp    801f6a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f61:	89 c2                	mov    %eax,%edx
  801f63:	eb 05                	jmp    801f6a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f65:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801f6a:	89 d0                	mov    %edx,%eax
  801f6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f6f:	c9                   	leave  
  801f70:	c3                   	ret    

00801f71 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
  801f74:	57                   	push   %edi
  801f75:	56                   	push   %esi
  801f76:	53                   	push   %ebx
  801f77:	83 ec 0c             	sub    $0xc,%esp
  801f7a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f7d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f80:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f85:	eb 21                	jmp    801fa8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f87:	83 ec 04             	sub    $0x4,%esp
  801f8a:	89 f0                	mov    %esi,%eax
  801f8c:	29 d8                	sub    %ebx,%eax
  801f8e:	50                   	push   %eax
  801f8f:	89 d8                	mov    %ebx,%eax
  801f91:	03 45 0c             	add    0xc(%ebp),%eax
  801f94:	50                   	push   %eax
  801f95:	57                   	push   %edi
  801f96:	e8 45 ff ff ff       	call   801ee0 <read>
		if (m < 0)
  801f9b:	83 c4 10             	add    $0x10,%esp
  801f9e:	85 c0                	test   %eax,%eax
  801fa0:	78 10                	js     801fb2 <readn+0x41>
			return m;
		if (m == 0)
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	74 0a                	je     801fb0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fa6:	01 c3                	add    %eax,%ebx
  801fa8:	39 f3                	cmp    %esi,%ebx
  801faa:	72 db                	jb     801f87 <readn+0x16>
  801fac:	89 d8                	mov    %ebx,%eax
  801fae:	eb 02                	jmp    801fb2 <readn+0x41>
  801fb0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801fb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb5:	5b                   	pop    %ebx
  801fb6:	5e                   	pop    %esi
  801fb7:	5f                   	pop    %edi
  801fb8:	5d                   	pop    %ebp
  801fb9:	c3                   	ret    

00801fba <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	53                   	push   %ebx
  801fbe:	83 ec 14             	sub    $0x14,%esp
  801fc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fc4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fc7:	50                   	push   %eax
  801fc8:	53                   	push   %ebx
  801fc9:	e8 ac fc ff ff       	call   801c7a <fd_lookup>
  801fce:	83 c4 08             	add    $0x8,%esp
  801fd1:	89 c2                	mov    %eax,%edx
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	78 68                	js     80203f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fd7:	83 ec 08             	sub    $0x8,%esp
  801fda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fdd:	50                   	push   %eax
  801fde:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fe1:	ff 30                	pushl  (%eax)
  801fe3:	e8 e8 fc ff ff       	call   801cd0 <dev_lookup>
  801fe8:	83 c4 10             	add    $0x10,%esp
  801feb:	85 c0                	test   %eax,%eax
  801fed:	78 47                	js     802036 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801fef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ff2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ff6:	75 21                	jne    802019 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801ff8:	a1 24 54 80 00       	mov    0x805424,%eax
  801ffd:	8b 40 54             	mov    0x54(%eax),%eax
  802000:	83 ec 04             	sub    $0x4,%esp
  802003:	53                   	push   %ebx
  802004:	50                   	push   %eax
  802005:	68 95 39 80 00       	push   $0x803995
  80200a:	e8 03 eb ff ff       	call   800b12 <cprintf>
		return -E_INVAL;
  80200f:	83 c4 10             	add    $0x10,%esp
  802012:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802017:	eb 26                	jmp    80203f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802019:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80201c:	8b 52 0c             	mov    0xc(%edx),%edx
  80201f:	85 d2                	test   %edx,%edx
  802021:	74 17                	je     80203a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802023:	83 ec 04             	sub    $0x4,%esp
  802026:	ff 75 10             	pushl  0x10(%ebp)
  802029:	ff 75 0c             	pushl  0xc(%ebp)
  80202c:	50                   	push   %eax
  80202d:	ff d2                	call   *%edx
  80202f:	89 c2                	mov    %eax,%edx
  802031:	83 c4 10             	add    $0x10,%esp
  802034:	eb 09                	jmp    80203f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802036:	89 c2                	mov    %eax,%edx
  802038:	eb 05                	jmp    80203f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80203a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80203f:	89 d0                	mov    %edx,%eax
  802041:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802044:	c9                   	leave  
  802045:	c3                   	ret    

00802046 <seek>:

int
seek(int fdnum, off_t offset)
{
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80204c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80204f:	50                   	push   %eax
  802050:	ff 75 08             	pushl  0x8(%ebp)
  802053:	e8 22 fc ff ff       	call   801c7a <fd_lookup>
  802058:	83 c4 08             	add    $0x8,%esp
  80205b:	85 c0                	test   %eax,%eax
  80205d:	78 0e                	js     80206d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80205f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802062:	8b 55 0c             	mov    0xc(%ebp),%edx
  802065:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802068:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80206d:	c9                   	leave  
  80206e:	c3                   	ret    

0080206f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80206f:	55                   	push   %ebp
  802070:	89 e5                	mov    %esp,%ebp
  802072:	53                   	push   %ebx
  802073:	83 ec 14             	sub    $0x14,%esp
  802076:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802079:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80207c:	50                   	push   %eax
  80207d:	53                   	push   %ebx
  80207e:	e8 f7 fb ff ff       	call   801c7a <fd_lookup>
  802083:	83 c4 08             	add    $0x8,%esp
  802086:	89 c2                	mov    %eax,%edx
  802088:	85 c0                	test   %eax,%eax
  80208a:	78 65                	js     8020f1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80208c:	83 ec 08             	sub    $0x8,%esp
  80208f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802092:	50                   	push   %eax
  802093:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802096:	ff 30                	pushl  (%eax)
  802098:	e8 33 fc ff ff       	call   801cd0 <dev_lookup>
  80209d:	83 c4 10             	add    $0x10,%esp
  8020a0:	85 c0                	test   %eax,%eax
  8020a2:	78 44                	js     8020e8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8020a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8020ab:	75 21                	jne    8020ce <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8020ad:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8020b2:	8b 40 54             	mov    0x54(%eax),%eax
  8020b5:	83 ec 04             	sub    $0x4,%esp
  8020b8:	53                   	push   %ebx
  8020b9:	50                   	push   %eax
  8020ba:	68 58 39 80 00       	push   $0x803958
  8020bf:	e8 4e ea ff ff       	call   800b12 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8020c4:	83 c4 10             	add    $0x10,%esp
  8020c7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8020cc:	eb 23                	jmp    8020f1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8020ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020d1:	8b 52 18             	mov    0x18(%edx),%edx
  8020d4:	85 d2                	test   %edx,%edx
  8020d6:	74 14                	je     8020ec <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8020d8:	83 ec 08             	sub    $0x8,%esp
  8020db:	ff 75 0c             	pushl  0xc(%ebp)
  8020de:	50                   	push   %eax
  8020df:	ff d2                	call   *%edx
  8020e1:	89 c2                	mov    %eax,%edx
  8020e3:	83 c4 10             	add    $0x10,%esp
  8020e6:	eb 09                	jmp    8020f1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020e8:	89 c2                	mov    %eax,%edx
  8020ea:	eb 05                	jmp    8020f1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8020ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8020f1:	89 d0                	mov    %edx,%eax
  8020f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020f6:	c9                   	leave  
  8020f7:	c3                   	ret    

008020f8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	53                   	push   %ebx
  8020fc:	83 ec 14             	sub    $0x14,%esp
  8020ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802102:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802105:	50                   	push   %eax
  802106:	ff 75 08             	pushl  0x8(%ebp)
  802109:	e8 6c fb ff ff       	call   801c7a <fd_lookup>
  80210e:	83 c4 08             	add    $0x8,%esp
  802111:	89 c2                	mov    %eax,%edx
  802113:	85 c0                	test   %eax,%eax
  802115:	78 58                	js     80216f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802117:	83 ec 08             	sub    $0x8,%esp
  80211a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211d:	50                   	push   %eax
  80211e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802121:	ff 30                	pushl  (%eax)
  802123:	e8 a8 fb ff ff       	call   801cd0 <dev_lookup>
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	85 c0                	test   %eax,%eax
  80212d:	78 37                	js     802166 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80212f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802132:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802136:	74 32                	je     80216a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802138:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80213b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802142:	00 00 00 
	stat->st_isdir = 0;
  802145:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80214c:	00 00 00 
	stat->st_dev = dev;
  80214f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802155:	83 ec 08             	sub    $0x8,%esp
  802158:	53                   	push   %ebx
  802159:	ff 75 f0             	pushl  -0x10(%ebp)
  80215c:	ff 50 14             	call   *0x14(%eax)
  80215f:	89 c2                	mov    %eax,%edx
  802161:	83 c4 10             	add    $0x10,%esp
  802164:	eb 09                	jmp    80216f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802166:	89 c2                	mov    %eax,%edx
  802168:	eb 05                	jmp    80216f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80216a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80216f:	89 d0                	mov    %edx,%eax
  802171:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802174:	c9                   	leave  
  802175:	c3                   	ret    

00802176 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802176:	55                   	push   %ebp
  802177:	89 e5                	mov    %esp,%ebp
  802179:	56                   	push   %esi
  80217a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80217b:	83 ec 08             	sub    $0x8,%esp
  80217e:	6a 00                	push   $0x0
  802180:	ff 75 08             	pushl  0x8(%ebp)
  802183:	e8 e3 01 00 00       	call   80236b <open>
  802188:	89 c3                	mov    %eax,%ebx
  80218a:	83 c4 10             	add    $0x10,%esp
  80218d:	85 c0                	test   %eax,%eax
  80218f:	78 1b                	js     8021ac <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802191:	83 ec 08             	sub    $0x8,%esp
  802194:	ff 75 0c             	pushl  0xc(%ebp)
  802197:	50                   	push   %eax
  802198:	e8 5b ff ff ff       	call   8020f8 <fstat>
  80219d:	89 c6                	mov    %eax,%esi
	close(fd);
  80219f:	89 1c 24             	mov    %ebx,(%esp)
  8021a2:	e8 fd fb ff ff       	call   801da4 <close>
	return r;
  8021a7:	83 c4 10             	add    $0x10,%esp
  8021aa:	89 f0                	mov    %esi,%eax
}
  8021ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5e                   	pop    %esi
  8021b1:	5d                   	pop    %ebp
  8021b2:	c3                   	ret    

008021b3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8021b3:	55                   	push   %ebp
  8021b4:	89 e5                	mov    %esp,%ebp
  8021b6:	56                   	push   %esi
  8021b7:	53                   	push   %ebx
  8021b8:	89 c6                	mov    %eax,%esi
  8021ba:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8021bc:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  8021c3:	75 12                	jne    8021d7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8021c5:	83 ec 0c             	sub    $0xc,%esp
  8021c8:	6a 01                	push   $0x1
  8021ca:	e8 48 0e 00 00       	call   803017 <ipc_find_env>
  8021cf:	a3 20 54 80 00       	mov    %eax,0x805420
  8021d4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021d7:	6a 07                	push   $0x7
  8021d9:	68 00 60 80 00       	push   $0x806000
  8021de:	56                   	push   %esi
  8021df:	ff 35 20 54 80 00    	pushl  0x805420
  8021e5:	e8 cb 0d 00 00       	call   802fb5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021ea:	83 c4 0c             	add    $0xc,%esp
  8021ed:	6a 00                	push   $0x0
  8021ef:	53                   	push   %ebx
  8021f0:	6a 00                	push   $0x0
  8021f2:	e8 46 0d 00 00       	call   802f3d <ipc_recv>
}
  8021f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021fa:	5b                   	pop    %ebx
  8021fb:	5e                   	pop    %esi
  8021fc:	5d                   	pop    %ebp
  8021fd:	c3                   	ret    

008021fe <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8021fe:	55                   	push   %ebp
  8021ff:	89 e5                	mov    %esp,%ebp
  802201:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802204:	8b 45 08             	mov    0x8(%ebp),%eax
  802207:	8b 40 0c             	mov    0xc(%eax),%eax
  80220a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80220f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802212:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802217:	ba 00 00 00 00       	mov    $0x0,%edx
  80221c:	b8 02 00 00 00       	mov    $0x2,%eax
  802221:	e8 8d ff ff ff       	call   8021b3 <fsipc>
}
  802226:	c9                   	leave  
  802227:	c3                   	ret    

00802228 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802228:	55                   	push   %ebp
  802229:	89 e5                	mov    %esp,%ebp
  80222b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80222e:	8b 45 08             	mov    0x8(%ebp),%eax
  802231:	8b 40 0c             	mov    0xc(%eax),%eax
  802234:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802239:	ba 00 00 00 00       	mov    $0x0,%edx
  80223e:	b8 06 00 00 00       	mov    $0x6,%eax
  802243:	e8 6b ff ff ff       	call   8021b3 <fsipc>
}
  802248:	c9                   	leave  
  802249:	c3                   	ret    

0080224a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	53                   	push   %ebx
  80224e:	83 ec 04             	sub    $0x4,%esp
  802251:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802254:	8b 45 08             	mov    0x8(%ebp),%eax
  802257:	8b 40 0c             	mov    0xc(%eax),%eax
  80225a:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80225f:	ba 00 00 00 00       	mov    $0x0,%edx
  802264:	b8 05 00 00 00       	mov    $0x5,%eax
  802269:	e8 45 ff ff ff       	call   8021b3 <fsipc>
  80226e:	85 c0                	test   %eax,%eax
  802270:	78 2c                	js     80229e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802272:	83 ec 08             	sub    $0x8,%esp
  802275:	68 00 60 80 00       	push   $0x806000
  80227a:	53                   	push   %ebx
  80227b:	e8 0a ef ff ff       	call   80118a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802280:	a1 80 60 80 00       	mov    0x806080,%eax
  802285:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80228b:	a1 84 60 80 00       	mov    0x806084,%eax
  802290:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802296:	83 c4 10             	add    $0x10,%esp
  802299:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80229e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022a1:	c9                   	leave  
  8022a2:	c3                   	ret    

008022a3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8022a3:	55                   	push   %ebp
  8022a4:	89 e5                	mov    %esp,%ebp
  8022a6:	83 ec 0c             	sub    $0xc,%esp
  8022a9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8022ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8022af:	8b 52 0c             	mov    0xc(%edx),%edx
  8022b2:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8022b8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8022bd:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8022c2:	0f 47 c2             	cmova  %edx,%eax
  8022c5:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8022ca:	50                   	push   %eax
  8022cb:	ff 75 0c             	pushl  0xc(%ebp)
  8022ce:	68 08 60 80 00       	push   $0x806008
  8022d3:	e8 44 f0 ff ff       	call   80131c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8022d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8022dd:	b8 04 00 00 00       	mov    $0x4,%eax
  8022e2:	e8 cc fe ff ff       	call   8021b3 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8022e7:	c9                   	leave  
  8022e8:	c3                   	ret    

008022e9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8022e9:	55                   	push   %ebp
  8022ea:	89 e5                	mov    %esp,%ebp
  8022ec:	56                   	push   %esi
  8022ed:	53                   	push   %ebx
  8022ee:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8022f7:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8022fc:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802302:	ba 00 00 00 00       	mov    $0x0,%edx
  802307:	b8 03 00 00 00       	mov    $0x3,%eax
  80230c:	e8 a2 fe ff ff       	call   8021b3 <fsipc>
  802311:	89 c3                	mov    %eax,%ebx
  802313:	85 c0                	test   %eax,%eax
  802315:	78 4b                	js     802362 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802317:	39 c6                	cmp    %eax,%esi
  802319:	73 16                	jae    802331 <devfile_read+0x48>
  80231b:	68 c4 39 80 00       	push   $0x8039c4
  802320:	68 8f 34 80 00       	push   $0x80348f
  802325:	6a 7c                	push   $0x7c
  802327:	68 cb 39 80 00       	push   $0x8039cb
  80232c:	e8 08 e7 ff ff       	call   800a39 <_panic>
	assert(r <= PGSIZE);
  802331:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802336:	7e 16                	jle    80234e <devfile_read+0x65>
  802338:	68 d6 39 80 00       	push   $0x8039d6
  80233d:	68 8f 34 80 00       	push   $0x80348f
  802342:	6a 7d                	push   $0x7d
  802344:	68 cb 39 80 00       	push   $0x8039cb
  802349:	e8 eb e6 ff ff       	call   800a39 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80234e:	83 ec 04             	sub    $0x4,%esp
  802351:	50                   	push   %eax
  802352:	68 00 60 80 00       	push   $0x806000
  802357:	ff 75 0c             	pushl  0xc(%ebp)
  80235a:	e8 bd ef ff ff       	call   80131c <memmove>
	return r;
  80235f:	83 c4 10             	add    $0x10,%esp
}
  802362:	89 d8                	mov    %ebx,%eax
  802364:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802367:	5b                   	pop    %ebx
  802368:	5e                   	pop    %esi
  802369:	5d                   	pop    %ebp
  80236a:	c3                   	ret    

0080236b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80236b:	55                   	push   %ebp
  80236c:	89 e5                	mov    %esp,%ebp
  80236e:	53                   	push   %ebx
  80236f:	83 ec 20             	sub    $0x20,%esp
  802372:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802375:	53                   	push   %ebx
  802376:	e8 d6 ed ff ff       	call   801151 <strlen>
  80237b:	83 c4 10             	add    $0x10,%esp
  80237e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802383:	7f 67                	jg     8023ec <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802385:	83 ec 0c             	sub    $0xc,%esp
  802388:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80238b:	50                   	push   %eax
  80238c:	e8 9a f8 ff ff       	call   801c2b <fd_alloc>
  802391:	83 c4 10             	add    $0x10,%esp
		return r;
  802394:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802396:	85 c0                	test   %eax,%eax
  802398:	78 57                	js     8023f1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80239a:	83 ec 08             	sub    $0x8,%esp
  80239d:	53                   	push   %ebx
  80239e:	68 00 60 80 00       	push   $0x806000
  8023a3:	e8 e2 ed ff ff       	call   80118a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8023a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023ab:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8023b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b8:	e8 f6 fd ff ff       	call   8021b3 <fsipc>
  8023bd:	89 c3                	mov    %eax,%ebx
  8023bf:	83 c4 10             	add    $0x10,%esp
  8023c2:	85 c0                	test   %eax,%eax
  8023c4:	79 14                	jns    8023da <open+0x6f>
		fd_close(fd, 0);
  8023c6:	83 ec 08             	sub    $0x8,%esp
  8023c9:	6a 00                	push   $0x0
  8023cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8023ce:	e8 50 f9 ff ff       	call   801d23 <fd_close>
		return r;
  8023d3:	83 c4 10             	add    $0x10,%esp
  8023d6:	89 da                	mov    %ebx,%edx
  8023d8:	eb 17                	jmp    8023f1 <open+0x86>
	}

	return fd2num(fd);
  8023da:	83 ec 0c             	sub    $0xc,%esp
  8023dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8023e0:	e8 1f f8 ff ff       	call   801c04 <fd2num>
  8023e5:	89 c2                	mov    %eax,%edx
  8023e7:	83 c4 10             	add    $0x10,%esp
  8023ea:	eb 05                	jmp    8023f1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8023ec:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8023f1:	89 d0                	mov    %edx,%eax
  8023f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023f6:	c9                   	leave  
  8023f7:	c3                   	ret    

008023f8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8023f8:	55                   	push   %ebp
  8023f9:	89 e5                	mov    %esp,%ebp
  8023fb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8023fe:	ba 00 00 00 00       	mov    $0x0,%edx
  802403:	b8 08 00 00 00       	mov    $0x8,%eax
  802408:	e8 a6 fd ff ff       	call   8021b3 <fsipc>
}
  80240d:	c9                   	leave  
  80240e:	c3                   	ret    

0080240f <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80240f:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802413:	7e 37                	jle    80244c <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  802415:	55                   	push   %ebp
  802416:	89 e5                	mov    %esp,%ebp
  802418:	53                   	push   %ebx
  802419:	83 ec 08             	sub    $0x8,%esp
  80241c:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80241e:	ff 70 04             	pushl  0x4(%eax)
  802421:	8d 40 10             	lea    0x10(%eax),%eax
  802424:	50                   	push   %eax
  802425:	ff 33                	pushl  (%ebx)
  802427:	e8 8e fb ff ff       	call   801fba <write>
		if (result > 0)
  80242c:	83 c4 10             	add    $0x10,%esp
  80242f:	85 c0                	test   %eax,%eax
  802431:	7e 03                	jle    802436 <writebuf+0x27>
			b->result += result;
  802433:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802436:	3b 43 04             	cmp    0x4(%ebx),%eax
  802439:	74 0d                	je     802448 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80243b:	85 c0                	test   %eax,%eax
  80243d:	ba 00 00 00 00       	mov    $0x0,%edx
  802442:	0f 4f c2             	cmovg  %edx,%eax
  802445:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802448:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80244b:	c9                   	leave  
  80244c:	f3 c3                	repz ret 

0080244e <putch>:

static void
putch(int ch, void *thunk)
{
  80244e:	55                   	push   %ebp
  80244f:	89 e5                	mov    %esp,%ebp
  802451:	53                   	push   %ebx
  802452:	83 ec 04             	sub    $0x4,%esp
  802455:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802458:	8b 53 04             	mov    0x4(%ebx),%edx
  80245b:	8d 42 01             	lea    0x1(%edx),%eax
  80245e:	89 43 04             	mov    %eax,0x4(%ebx)
  802461:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802464:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802468:	3d 00 01 00 00       	cmp    $0x100,%eax
  80246d:	75 0e                	jne    80247d <putch+0x2f>
		writebuf(b);
  80246f:	89 d8                	mov    %ebx,%eax
  802471:	e8 99 ff ff ff       	call   80240f <writebuf>
		b->idx = 0;
  802476:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80247d:	83 c4 04             	add    $0x4,%esp
  802480:	5b                   	pop    %ebx
  802481:	5d                   	pop    %ebp
  802482:	c3                   	ret    

00802483 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802483:	55                   	push   %ebp
  802484:	89 e5                	mov    %esp,%ebp
  802486:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80248c:	8b 45 08             	mov    0x8(%ebp),%eax
  80248f:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802495:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80249c:	00 00 00 
	b.result = 0;
  80249f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8024a6:	00 00 00 
	b.error = 1;
  8024a9:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8024b0:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8024b3:	ff 75 10             	pushl  0x10(%ebp)
  8024b6:	ff 75 0c             	pushl  0xc(%ebp)
  8024b9:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024bf:	50                   	push   %eax
  8024c0:	68 4e 24 80 00       	push   $0x80244e
  8024c5:	e8 7f e7 ff ff       	call   800c49 <vprintfmt>
	if (b.idx > 0)
  8024ca:	83 c4 10             	add    $0x10,%esp
  8024cd:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024d4:	7e 0b                	jle    8024e1 <vfprintf+0x5e>
		writebuf(&b);
  8024d6:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024dc:	e8 2e ff ff ff       	call   80240f <writebuf>

	return (b.result ? b.result : b.error);
  8024e1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8024e7:	85 c0                	test   %eax,%eax
  8024e9:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8024f0:	c9                   	leave  
  8024f1:	c3                   	ret    

008024f2 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8024f2:	55                   	push   %ebp
  8024f3:	89 e5                	mov    %esp,%ebp
  8024f5:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024f8:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8024fb:	50                   	push   %eax
  8024fc:	ff 75 0c             	pushl  0xc(%ebp)
  8024ff:	ff 75 08             	pushl  0x8(%ebp)
  802502:	e8 7c ff ff ff       	call   802483 <vfprintf>
	va_end(ap);

	return cnt;
}
  802507:	c9                   	leave  
  802508:	c3                   	ret    

00802509 <printf>:

int
printf(const char *fmt, ...)
{
  802509:	55                   	push   %ebp
  80250a:	89 e5                	mov    %esp,%ebp
  80250c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80250f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802512:	50                   	push   %eax
  802513:	ff 75 08             	pushl  0x8(%ebp)
  802516:	6a 01                	push   $0x1
  802518:	e8 66 ff ff ff       	call   802483 <vfprintf>
	va_end(ap);

	return cnt;
}
  80251d:	c9                   	leave  
  80251e:	c3                   	ret    

0080251f <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80251f:	55                   	push   %ebp
  802520:	89 e5                	mov    %esp,%ebp
  802522:	57                   	push   %edi
  802523:	56                   	push   %esi
  802524:	53                   	push   %ebx
  802525:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80252b:	6a 00                	push   $0x0
  80252d:	ff 75 08             	pushl  0x8(%ebp)
  802530:	e8 36 fe ff ff       	call   80236b <open>
  802535:	89 c7                	mov    %eax,%edi
  802537:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80253d:	83 c4 10             	add    $0x10,%esp
  802540:	85 c0                	test   %eax,%eax
  802542:	0f 88 89 04 00 00    	js     8029d1 <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802548:	83 ec 04             	sub    $0x4,%esp
  80254b:	68 00 02 00 00       	push   $0x200
  802550:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802556:	50                   	push   %eax
  802557:	57                   	push   %edi
  802558:	e8 14 fa ff ff       	call   801f71 <readn>
  80255d:	83 c4 10             	add    $0x10,%esp
  802560:	3d 00 02 00 00       	cmp    $0x200,%eax
  802565:	75 0c                	jne    802573 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  802567:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80256e:	45 4c 46 
  802571:	74 33                	je     8025a6 <spawn+0x87>
		close(fd);
  802573:	83 ec 0c             	sub    $0xc,%esp
  802576:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80257c:	e8 23 f8 ff ff       	call   801da4 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802581:	83 c4 0c             	add    $0xc,%esp
  802584:	68 7f 45 4c 46       	push   $0x464c457f
  802589:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80258f:	68 e2 39 80 00       	push   $0x8039e2
  802594:	e8 79 e5 ff ff       	call   800b12 <cprintf>
		return -E_NOT_EXEC;
  802599:	83 c4 10             	add    $0x10,%esp
  80259c:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8025a1:	e9 de 04 00 00       	jmp    802a84 <spawn+0x565>
  8025a6:	b8 07 00 00 00       	mov    $0x7,%eax
  8025ab:	cd 30                	int    $0x30
  8025ad:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8025b3:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8025b9:	85 c0                	test   %eax,%eax
  8025bb:	0f 88 1b 04 00 00    	js     8029dc <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8025c1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8025c6:	89 c2                	mov    %eax,%edx
  8025c8:	c1 e2 07             	shl    $0x7,%edx
  8025cb:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8025d1:	8d b4 c2 0c 00 c0 ee 	lea    -0x113ffff4(%edx,%eax,8),%esi
  8025d8:	b9 11 00 00 00       	mov    $0x11,%ecx
  8025dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8025df:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8025e5:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025eb:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8025f0:	be 00 00 00 00       	mov    $0x0,%esi
  8025f5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025f8:	eb 13                	jmp    80260d <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8025fa:	83 ec 0c             	sub    $0xc,%esp
  8025fd:	50                   	push   %eax
  8025fe:	e8 4e eb ff ff       	call   801151 <strlen>
  802603:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802607:	83 c3 01             	add    $0x1,%ebx
  80260a:	83 c4 10             	add    $0x10,%esp
  80260d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802614:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802617:	85 c0                	test   %eax,%eax
  802619:	75 df                	jne    8025fa <spawn+0xdb>
  80261b:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802621:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802627:	bf 00 10 40 00       	mov    $0x401000,%edi
  80262c:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80262e:	89 fa                	mov    %edi,%edx
  802630:	83 e2 fc             	and    $0xfffffffc,%edx
  802633:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80263a:	29 c2                	sub    %eax,%edx
  80263c:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802642:	8d 42 f8             	lea    -0x8(%edx),%eax
  802645:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80264a:	0f 86 a2 03 00 00    	jbe    8029f2 <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802650:	83 ec 04             	sub    $0x4,%esp
  802653:	6a 07                	push   $0x7
  802655:	68 00 00 40 00       	push   $0x400000
  80265a:	6a 00                	push   $0x0
  80265c:	e8 2c ef ff ff       	call   80158d <sys_page_alloc>
  802661:	83 c4 10             	add    $0x10,%esp
  802664:	85 c0                	test   %eax,%eax
  802666:	0f 88 90 03 00 00    	js     8029fc <spawn+0x4dd>
  80266c:	be 00 00 00 00       	mov    $0x0,%esi
  802671:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802677:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80267a:	eb 30                	jmp    8026ac <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80267c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802682:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802688:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  80268b:	83 ec 08             	sub    $0x8,%esp
  80268e:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802691:	57                   	push   %edi
  802692:	e8 f3 ea ff ff       	call   80118a <strcpy>
		string_store += strlen(argv[i]) + 1;
  802697:	83 c4 04             	add    $0x4,%esp
  80269a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80269d:	e8 af ea ff ff       	call   801151 <strlen>
  8026a2:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8026a6:	83 c6 01             	add    $0x1,%esi
  8026a9:	83 c4 10             	add    $0x10,%esp
  8026ac:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8026b2:	7f c8                	jg     80267c <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8026b4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8026ba:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8026c0:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8026c7:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8026cd:	74 19                	je     8026e8 <spawn+0x1c9>
  8026cf:	68 6c 3a 80 00       	push   $0x803a6c
  8026d4:	68 8f 34 80 00       	push   $0x80348f
  8026d9:	68 f2 00 00 00       	push   $0xf2
  8026de:	68 fc 39 80 00       	push   $0x8039fc
  8026e3:	e8 51 e3 ff ff       	call   800a39 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8026e8:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8026ee:	89 f8                	mov    %edi,%eax
  8026f0:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8026f5:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8026f8:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8026fe:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802701:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  802707:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80270d:	83 ec 0c             	sub    $0xc,%esp
  802710:	6a 07                	push   $0x7
  802712:	68 00 d0 bf ee       	push   $0xeebfd000
  802717:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80271d:	68 00 00 40 00       	push   $0x400000
  802722:	6a 00                	push   $0x0
  802724:	e8 a7 ee ff ff       	call   8015d0 <sys_page_map>
  802729:	89 c3                	mov    %eax,%ebx
  80272b:	83 c4 20             	add    $0x20,%esp
  80272e:	85 c0                	test   %eax,%eax
  802730:	0f 88 3c 03 00 00    	js     802a72 <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802736:	83 ec 08             	sub    $0x8,%esp
  802739:	68 00 00 40 00       	push   $0x400000
  80273e:	6a 00                	push   $0x0
  802740:	e8 cd ee ff ff       	call   801612 <sys_page_unmap>
  802745:	89 c3                	mov    %eax,%ebx
  802747:	83 c4 10             	add    $0x10,%esp
  80274a:	85 c0                	test   %eax,%eax
  80274c:	0f 88 20 03 00 00    	js     802a72 <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802752:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802758:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80275f:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802765:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  80276c:	00 00 00 
  80276f:	e9 88 01 00 00       	jmp    8028fc <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  802774:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80277a:	83 38 01             	cmpl   $0x1,(%eax)
  80277d:	0f 85 6b 01 00 00    	jne    8028ee <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802783:	89 c2                	mov    %eax,%edx
  802785:	8b 40 18             	mov    0x18(%eax),%eax
  802788:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80278e:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802791:	83 f8 01             	cmp    $0x1,%eax
  802794:	19 c0                	sbb    %eax,%eax
  802796:	83 e0 fe             	and    $0xfffffffe,%eax
  802799:	83 c0 07             	add    $0x7,%eax
  80279c:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8027a2:	89 d0                	mov    %edx,%eax
  8027a4:	8b 7a 04             	mov    0x4(%edx),%edi
  8027a7:	89 f9                	mov    %edi,%ecx
  8027a9:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8027af:	8b 7a 10             	mov    0x10(%edx),%edi
  8027b2:	8b 52 14             	mov    0x14(%edx),%edx
  8027b5:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  8027bb:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8027be:	89 f0                	mov    %esi,%eax
  8027c0:	25 ff 0f 00 00       	and    $0xfff,%eax
  8027c5:	74 14                	je     8027db <spawn+0x2bc>
		va -= i;
  8027c7:	29 c6                	sub    %eax,%esi
		memsz += i;
  8027c9:	01 c2                	add    %eax,%edx
  8027cb:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8027d1:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8027d3:	29 c1                	sub    %eax,%ecx
  8027d5:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8027db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027e0:	e9 f7 00 00 00       	jmp    8028dc <spawn+0x3bd>
		if (i >= filesz) {
  8027e5:	39 fb                	cmp    %edi,%ebx
  8027e7:	72 27                	jb     802810 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8027e9:	83 ec 04             	sub    $0x4,%esp
  8027ec:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8027f2:	56                   	push   %esi
  8027f3:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8027f9:	e8 8f ed ff ff       	call   80158d <sys_page_alloc>
  8027fe:	83 c4 10             	add    $0x10,%esp
  802801:	85 c0                	test   %eax,%eax
  802803:	0f 89 c7 00 00 00    	jns    8028d0 <spawn+0x3b1>
  802809:	89 c3                	mov    %eax,%ebx
  80280b:	e9 fd 01 00 00       	jmp    802a0d <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802810:	83 ec 04             	sub    $0x4,%esp
  802813:	6a 07                	push   $0x7
  802815:	68 00 00 40 00       	push   $0x400000
  80281a:	6a 00                	push   $0x0
  80281c:	e8 6c ed ff ff       	call   80158d <sys_page_alloc>
  802821:	83 c4 10             	add    $0x10,%esp
  802824:	85 c0                	test   %eax,%eax
  802826:	0f 88 d7 01 00 00    	js     802a03 <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80282c:	83 ec 08             	sub    $0x8,%esp
  80282f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802835:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80283b:	50                   	push   %eax
  80283c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802842:	e8 ff f7 ff ff       	call   802046 <seek>
  802847:	83 c4 10             	add    $0x10,%esp
  80284a:	85 c0                	test   %eax,%eax
  80284c:	0f 88 b5 01 00 00    	js     802a07 <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802852:	83 ec 04             	sub    $0x4,%esp
  802855:	89 f8                	mov    %edi,%eax
  802857:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  80285d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802862:	ba 00 10 00 00       	mov    $0x1000,%edx
  802867:	0f 47 c2             	cmova  %edx,%eax
  80286a:	50                   	push   %eax
  80286b:	68 00 00 40 00       	push   $0x400000
  802870:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802876:	e8 f6 f6 ff ff       	call   801f71 <readn>
  80287b:	83 c4 10             	add    $0x10,%esp
  80287e:	85 c0                	test   %eax,%eax
  802880:	0f 88 85 01 00 00    	js     802a0b <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802886:	83 ec 0c             	sub    $0xc,%esp
  802889:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80288f:	56                   	push   %esi
  802890:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802896:	68 00 00 40 00       	push   $0x400000
  80289b:	6a 00                	push   $0x0
  80289d:	e8 2e ed ff ff       	call   8015d0 <sys_page_map>
  8028a2:	83 c4 20             	add    $0x20,%esp
  8028a5:	85 c0                	test   %eax,%eax
  8028a7:	79 15                	jns    8028be <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  8028a9:	50                   	push   %eax
  8028aa:	68 08 3a 80 00       	push   $0x803a08
  8028af:	68 25 01 00 00       	push   $0x125
  8028b4:	68 fc 39 80 00       	push   $0x8039fc
  8028b9:	e8 7b e1 ff ff       	call   800a39 <_panic>
			sys_page_unmap(0, UTEMP);
  8028be:	83 ec 08             	sub    $0x8,%esp
  8028c1:	68 00 00 40 00       	push   $0x400000
  8028c6:	6a 00                	push   $0x0
  8028c8:	e8 45 ed ff ff       	call   801612 <sys_page_unmap>
  8028cd:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8028d0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8028d6:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8028dc:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8028e2:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8028e8:	0f 82 f7 fe ff ff    	jb     8027e5 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028ee:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8028f5:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8028fc:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802903:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802909:	0f 8c 65 fe ff ff    	jl     802774 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80290f:	83 ec 0c             	sub    $0xc,%esp
  802912:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802918:	e8 87 f4 ff ff       	call   801da4 <close>
  80291d:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802920:	bb 00 00 00 00       	mov    $0x0,%ebx
  802925:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  80292b:	89 d8                	mov    %ebx,%eax
  80292d:	c1 e8 16             	shr    $0x16,%eax
  802930:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802937:	a8 01                	test   $0x1,%al
  802939:	74 42                	je     80297d <spawn+0x45e>
  80293b:	89 d8                	mov    %ebx,%eax
  80293d:	c1 e8 0c             	shr    $0xc,%eax
  802940:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802947:	f6 c2 01             	test   $0x1,%dl
  80294a:	74 31                	je     80297d <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  80294c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  802953:	f6 c6 04             	test   $0x4,%dh
  802956:	74 25                	je     80297d <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  802958:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80295f:	83 ec 0c             	sub    $0xc,%esp
  802962:	25 07 0e 00 00       	and    $0xe07,%eax
  802967:	50                   	push   %eax
  802968:	53                   	push   %ebx
  802969:	56                   	push   %esi
  80296a:	53                   	push   %ebx
  80296b:	6a 00                	push   $0x0
  80296d:	e8 5e ec ff ff       	call   8015d0 <sys_page_map>
			if (r < 0) {
  802972:	83 c4 20             	add    $0x20,%esp
  802975:	85 c0                	test   %eax,%eax
  802977:	0f 88 b1 00 00 00    	js     802a2e <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  80297d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802983:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802989:	75 a0                	jne    80292b <spawn+0x40c>
  80298b:	e9 b3 00 00 00       	jmp    802a43 <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802990:	50                   	push   %eax
  802991:	68 25 3a 80 00       	push   $0x803a25
  802996:	68 86 00 00 00       	push   $0x86
  80299b:	68 fc 39 80 00       	push   $0x8039fc
  8029a0:	e8 94 e0 ff ff       	call   800a39 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8029a5:	83 ec 08             	sub    $0x8,%esp
  8029a8:	6a 02                	push   $0x2
  8029aa:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029b0:	e8 9f ec ff ff       	call   801654 <sys_env_set_status>
  8029b5:	83 c4 10             	add    $0x10,%esp
  8029b8:	85 c0                	test   %eax,%eax
  8029ba:	79 2b                	jns    8029e7 <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  8029bc:	50                   	push   %eax
  8029bd:	68 3f 3a 80 00       	push   $0x803a3f
  8029c2:	68 89 00 00 00       	push   $0x89
  8029c7:	68 fc 39 80 00       	push   $0x8039fc
  8029cc:	e8 68 e0 ff ff       	call   800a39 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8029d1:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8029d7:	e9 a8 00 00 00       	jmp    802a84 <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8029dc:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029e2:	e9 9d 00 00 00       	jmp    802a84 <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8029e7:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029ed:	e9 92 00 00 00       	jmp    802a84 <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8029f2:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8029f7:	e9 88 00 00 00       	jmp    802a84 <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8029fc:	89 c3                	mov    %eax,%ebx
  8029fe:	e9 81 00 00 00       	jmp    802a84 <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802a03:	89 c3                	mov    %eax,%ebx
  802a05:	eb 06                	jmp    802a0d <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802a07:	89 c3                	mov    %eax,%ebx
  802a09:	eb 02                	jmp    802a0d <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802a0b:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802a0d:	83 ec 0c             	sub    $0xc,%esp
  802a10:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a16:	e8 f3 ea ff ff       	call   80150e <sys_env_destroy>
	close(fd);
  802a1b:	83 c4 04             	add    $0x4,%esp
  802a1e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a24:	e8 7b f3 ff ff       	call   801da4 <close>
	return r;
  802a29:	83 c4 10             	add    $0x10,%esp
  802a2c:	eb 56                	jmp    802a84 <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802a2e:	50                   	push   %eax
  802a2f:	68 56 3a 80 00       	push   $0x803a56
  802a34:	68 82 00 00 00       	push   $0x82
  802a39:	68 fc 39 80 00       	push   $0x8039fc
  802a3e:	e8 f6 df ff ff       	call   800a39 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802a43:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802a4a:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802a4d:	83 ec 08             	sub    $0x8,%esp
  802a50:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a56:	50                   	push   %eax
  802a57:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a5d:	e8 34 ec ff ff       	call   801696 <sys_env_set_trapframe>
  802a62:	83 c4 10             	add    $0x10,%esp
  802a65:	85 c0                	test   %eax,%eax
  802a67:	0f 89 38 ff ff ff    	jns    8029a5 <spawn+0x486>
  802a6d:	e9 1e ff ff ff       	jmp    802990 <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802a72:	83 ec 08             	sub    $0x8,%esp
  802a75:	68 00 00 40 00       	push   $0x400000
  802a7a:	6a 00                	push   $0x0
  802a7c:	e8 91 eb ff ff       	call   801612 <sys_page_unmap>
  802a81:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802a84:	89 d8                	mov    %ebx,%eax
  802a86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a89:	5b                   	pop    %ebx
  802a8a:	5e                   	pop    %esi
  802a8b:	5f                   	pop    %edi
  802a8c:	5d                   	pop    %ebp
  802a8d:	c3                   	ret    

00802a8e <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802a8e:	55                   	push   %ebp
  802a8f:	89 e5                	mov    %esp,%ebp
  802a91:	56                   	push   %esi
  802a92:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a93:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802a96:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a9b:	eb 03                	jmp    802aa0 <spawnl+0x12>
		argc++;
  802a9d:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802aa0:	83 c2 04             	add    $0x4,%edx
  802aa3:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802aa7:	75 f4                	jne    802a9d <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802aa9:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802ab0:	83 e2 f0             	and    $0xfffffff0,%edx
  802ab3:	29 d4                	sub    %edx,%esp
  802ab5:	8d 54 24 03          	lea    0x3(%esp),%edx
  802ab9:	c1 ea 02             	shr    $0x2,%edx
  802abc:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802ac3:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802ac8:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802acf:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802ad6:	00 
  802ad7:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  802ade:	eb 0a                	jmp    802aea <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802ae0:	83 c0 01             	add    $0x1,%eax
  802ae3:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802ae7:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802aea:	39 d0                	cmp    %edx,%eax
  802aec:	75 f2                	jne    802ae0 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802aee:	83 ec 08             	sub    $0x8,%esp
  802af1:	56                   	push   %esi
  802af2:	ff 75 08             	pushl  0x8(%ebp)
  802af5:	e8 25 fa ff ff       	call   80251f <spawn>
}
  802afa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802afd:	5b                   	pop    %ebx
  802afe:	5e                   	pop    %esi
  802aff:	5d                   	pop    %ebp
  802b00:	c3                   	ret    

00802b01 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802b01:	55                   	push   %ebp
  802b02:	89 e5                	mov    %esp,%ebp
  802b04:	56                   	push   %esi
  802b05:	53                   	push   %ebx
  802b06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802b09:	83 ec 0c             	sub    $0xc,%esp
  802b0c:	ff 75 08             	pushl  0x8(%ebp)
  802b0f:	e8 00 f1 ff ff       	call   801c14 <fd2data>
  802b14:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802b16:	83 c4 08             	add    $0x8,%esp
  802b19:	68 94 3a 80 00       	push   $0x803a94
  802b1e:	53                   	push   %ebx
  802b1f:	e8 66 e6 ff ff       	call   80118a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802b24:	8b 46 04             	mov    0x4(%esi),%eax
  802b27:	2b 06                	sub    (%esi),%eax
  802b29:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802b2f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802b36:	00 00 00 
	stat->st_dev = &devpipe;
  802b39:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802b40:	40 80 00 
	return 0;
}
  802b43:	b8 00 00 00 00       	mov    $0x0,%eax
  802b48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b4b:	5b                   	pop    %ebx
  802b4c:	5e                   	pop    %esi
  802b4d:	5d                   	pop    %ebp
  802b4e:	c3                   	ret    

00802b4f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802b4f:	55                   	push   %ebp
  802b50:	89 e5                	mov    %esp,%ebp
  802b52:	53                   	push   %ebx
  802b53:	83 ec 0c             	sub    $0xc,%esp
  802b56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b59:	53                   	push   %ebx
  802b5a:	6a 00                	push   $0x0
  802b5c:	e8 b1 ea ff ff       	call   801612 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b61:	89 1c 24             	mov    %ebx,(%esp)
  802b64:	e8 ab f0 ff ff       	call   801c14 <fd2data>
  802b69:	83 c4 08             	add    $0x8,%esp
  802b6c:	50                   	push   %eax
  802b6d:	6a 00                	push   $0x0
  802b6f:	e8 9e ea ff ff       	call   801612 <sys_page_unmap>
}
  802b74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b77:	c9                   	leave  
  802b78:	c3                   	ret    

00802b79 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b79:	55                   	push   %ebp
  802b7a:	89 e5                	mov    %esp,%ebp
  802b7c:	57                   	push   %edi
  802b7d:	56                   	push   %esi
  802b7e:	53                   	push   %ebx
  802b7f:	83 ec 1c             	sub    $0x1c,%esp
  802b82:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802b85:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802b87:	a1 24 54 80 00       	mov    0x805424,%eax
  802b8c:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802b8f:	83 ec 0c             	sub    $0xc,%esp
  802b92:	ff 75 e0             	pushl  -0x20(%ebp)
  802b95:	e8 bd 04 00 00       	call   803057 <pageref>
  802b9a:	89 c3                	mov    %eax,%ebx
  802b9c:	89 3c 24             	mov    %edi,(%esp)
  802b9f:	e8 b3 04 00 00       	call   803057 <pageref>
  802ba4:	83 c4 10             	add    $0x10,%esp
  802ba7:	39 c3                	cmp    %eax,%ebx
  802ba9:	0f 94 c1             	sete   %cl
  802bac:	0f b6 c9             	movzbl %cl,%ecx
  802baf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802bb2:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802bb8:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  802bbb:	39 ce                	cmp    %ecx,%esi
  802bbd:	74 1b                	je     802bda <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802bbf:	39 c3                	cmp    %eax,%ebx
  802bc1:	75 c4                	jne    802b87 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802bc3:	8b 42 64             	mov    0x64(%edx),%eax
  802bc6:	ff 75 e4             	pushl  -0x1c(%ebp)
  802bc9:	50                   	push   %eax
  802bca:	56                   	push   %esi
  802bcb:	68 9b 3a 80 00       	push   $0x803a9b
  802bd0:	e8 3d df ff ff       	call   800b12 <cprintf>
  802bd5:	83 c4 10             	add    $0x10,%esp
  802bd8:	eb ad                	jmp    802b87 <_pipeisclosed+0xe>
	}
}
  802bda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802bdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802be0:	5b                   	pop    %ebx
  802be1:	5e                   	pop    %esi
  802be2:	5f                   	pop    %edi
  802be3:	5d                   	pop    %ebp
  802be4:	c3                   	ret    

00802be5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802be5:	55                   	push   %ebp
  802be6:	89 e5                	mov    %esp,%ebp
  802be8:	57                   	push   %edi
  802be9:	56                   	push   %esi
  802bea:	53                   	push   %ebx
  802beb:	83 ec 28             	sub    $0x28,%esp
  802bee:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802bf1:	56                   	push   %esi
  802bf2:	e8 1d f0 ff ff       	call   801c14 <fd2data>
  802bf7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bf9:	83 c4 10             	add    $0x10,%esp
  802bfc:	bf 00 00 00 00       	mov    $0x0,%edi
  802c01:	eb 4b                	jmp    802c4e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802c03:	89 da                	mov    %ebx,%edx
  802c05:	89 f0                	mov    %esi,%eax
  802c07:	e8 6d ff ff ff       	call   802b79 <_pipeisclosed>
  802c0c:	85 c0                	test   %eax,%eax
  802c0e:	75 48                	jne    802c58 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802c10:	e8 59 e9 ff ff       	call   80156e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802c15:	8b 43 04             	mov    0x4(%ebx),%eax
  802c18:	8b 0b                	mov    (%ebx),%ecx
  802c1a:	8d 51 20             	lea    0x20(%ecx),%edx
  802c1d:	39 d0                	cmp    %edx,%eax
  802c1f:	73 e2                	jae    802c03 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c24:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802c28:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802c2b:	89 c2                	mov    %eax,%edx
  802c2d:	c1 fa 1f             	sar    $0x1f,%edx
  802c30:	89 d1                	mov    %edx,%ecx
  802c32:	c1 e9 1b             	shr    $0x1b,%ecx
  802c35:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802c38:	83 e2 1f             	and    $0x1f,%edx
  802c3b:	29 ca                	sub    %ecx,%edx
  802c3d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802c41:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802c45:	83 c0 01             	add    $0x1,%eax
  802c48:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c4b:	83 c7 01             	add    $0x1,%edi
  802c4e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802c51:	75 c2                	jne    802c15 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c53:	8b 45 10             	mov    0x10(%ebp),%eax
  802c56:	eb 05                	jmp    802c5d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c58:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c60:	5b                   	pop    %ebx
  802c61:	5e                   	pop    %esi
  802c62:	5f                   	pop    %edi
  802c63:	5d                   	pop    %ebp
  802c64:	c3                   	ret    

00802c65 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c65:	55                   	push   %ebp
  802c66:	89 e5                	mov    %esp,%ebp
  802c68:	57                   	push   %edi
  802c69:	56                   	push   %esi
  802c6a:	53                   	push   %ebx
  802c6b:	83 ec 18             	sub    $0x18,%esp
  802c6e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c71:	57                   	push   %edi
  802c72:	e8 9d ef ff ff       	call   801c14 <fd2data>
  802c77:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c79:	83 c4 10             	add    $0x10,%esp
  802c7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c81:	eb 3d                	jmp    802cc0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802c83:	85 db                	test   %ebx,%ebx
  802c85:	74 04                	je     802c8b <devpipe_read+0x26>
				return i;
  802c87:	89 d8                	mov    %ebx,%eax
  802c89:	eb 44                	jmp    802ccf <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802c8b:	89 f2                	mov    %esi,%edx
  802c8d:	89 f8                	mov    %edi,%eax
  802c8f:	e8 e5 fe ff ff       	call   802b79 <_pipeisclosed>
  802c94:	85 c0                	test   %eax,%eax
  802c96:	75 32                	jne    802cca <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802c98:	e8 d1 e8 ff ff       	call   80156e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802c9d:	8b 06                	mov    (%esi),%eax
  802c9f:	3b 46 04             	cmp    0x4(%esi),%eax
  802ca2:	74 df                	je     802c83 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802ca4:	99                   	cltd   
  802ca5:	c1 ea 1b             	shr    $0x1b,%edx
  802ca8:	01 d0                	add    %edx,%eax
  802caa:	83 e0 1f             	and    $0x1f,%eax
  802cad:	29 d0                	sub    %edx,%eax
  802caf:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802cb7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802cba:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802cbd:	83 c3 01             	add    $0x1,%ebx
  802cc0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802cc3:	75 d8                	jne    802c9d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802cc5:	8b 45 10             	mov    0x10(%ebp),%eax
  802cc8:	eb 05                	jmp    802ccf <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802cca:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802ccf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cd2:	5b                   	pop    %ebx
  802cd3:	5e                   	pop    %esi
  802cd4:	5f                   	pop    %edi
  802cd5:	5d                   	pop    %ebp
  802cd6:	c3                   	ret    

00802cd7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802cd7:	55                   	push   %ebp
  802cd8:	89 e5                	mov    %esp,%ebp
  802cda:	56                   	push   %esi
  802cdb:	53                   	push   %ebx
  802cdc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802cdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ce2:	50                   	push   %eax
  802ce3:	e8 43 ef ff ff       	call   801c2b <fd_alloc>
  802ce8:	83 c4 10             	add    $0x10,%esp
  802ceb:	89 c2                	mov    %eax,%edx
  802ced:	85 c0                	test   %eax,%eax
  802cef:	0f 88 2c 01 00 00    	js     802e21 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cf5:	83 ec 04             	sub    $0x4,%esp
  802cf8:	68 07 04 00 00       	push   $0x407
  802cfd:	ff 75 f4             	pushl  -0xc(%ebp)
  802d00:	6a 00                	push   $0x0
  802d02:	e8 86 e8 ff ff       	call   80158d <sys_page_alloc>
  802d07:	83 c4 10             	add    $0x10,%esp
  802d0a:	89 c2                	mov    %eax,%edx
  802d0c:	85 c0                	test   %eax,%eax
  802d0e:	0f 88 0d 01 00 00    	js     802e21 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802d14:	83 ec 0c             	sub    $0xc,%esp
  802d17:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d1a:	50                   	push   %eax
  802d1b:	e8 0b ef ff ff       	call   801c2b <fd_alloc>
  802d20:	89 c3                	mov    %eax,%ebx
  802d22:	83 c4 10             	add    $0x10,%esp
  802d25:	85 c0                	test   %eax,%eax
  802d27:	0f 88 e2 00 00 00    	js     802e0f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d2d:	83 ec 04             	sub    $0x4,%esp
  802d30:	68 07 04 00 00       	push   $0x407
  802d35:	ff 75 f0             	pushl  -0x10(%ebp)
  802d38:	6a 00                	push   $0x0
  802d3a:	e8 4e e8 ff ff       	call   80158d <sys_page_alloc>
  802d3f:	89 c3                	mov    %eax,%ebx
  802d41:	83 c4 10             	add    $0x10,%esp
  802d44:	85 c0                	test   %eax,%eax
  802d46:	0f 88 c3 00 00 00    	js     802e0f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802d4c:	83 ec 0c             	sub    $0xc,%esp
  802d4f:	ff 75 f4             	pushl  -0xc(%ebp)
  802d52:	e8 bd ee ff ff       	call   801c14 <fd2data>
  802d57:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d59:	83 c4 0c             	add    $0xc,%esp
  802d5c:	68 07 04 00 00       	push   $0x407
  802d61:	50                   	push   %eax
  802d62:	6a 00                	push   $0x0
  802d64:	e8 24 e8 ff ff       	call   80158d <sys_page_alloc>
  802d69:	89 c3                	mov    %eax,%ebx
  802d6b:	83 c4 10             	add    $0x10,%esp
  802d6e:	85 c0                	test   %eax,%eax
  802d70:	0f 88 89 00 00 00    	js     802dff <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d76:	83 ec 0c             	sub    $0xc,%esp
  802d79:	ff 75 f0             	pushl  -0x10(%ebp)
  802d7c:	e8 93 ee ff ff       	call   801c14 <fd2data>
  802d81:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802d88:	50                   	push   %eax
  802d89:	6a 00                	push   $0x0
  802d8b:	56                   	push   %esi
  802d8c:	6a 00                	push   $0x0
  802d8e:	e8 3d e8 ff ff       	call   8015d0 <sys_page_map>
  802d93:	89 c3                	mov    %eax,%ebx
  802d95:	83 c4 20             	add    $0x20,%esp
  802d98:	85 c0                	test   %eax,%eax
  802d9a:	78 55                	js     802df1 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802d9c:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802da5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802daa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802db1:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dba:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802dbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dbf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802dc6:	83 ec 0c             	sub    $0xc,%esp
  802dc9:	ff 75 f4             	pushl  -0xc(%ebp)
  802dcc:	e8 33 ee ff ff       	call   801c04 <fd2num>
  802dd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802dd4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802dd6:	83 c4 04             	add    $0x4,%esp
  802dd9:	ff 75 f0             	pushl  -0x10(%ebp)
  802ddc:	e8 23 ee ff ff       	call   801c04 <fd2num>
  802de1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802de4:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802de7:	83 c4 10             	add    $0x10,%esp
  802dea:	ba 00 00 00 00       	mov    $0x0,%edx
  802def:	eb 30                	jmp    802e21 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802df1:	83 ec 08             	sub    $0x8,%esp
  802df4:	56                   	push   %esi
  802df5:	6a 00                	push   $0x0
  802df7:	e8 16 e8 ff ff       	call   801612 <sys_page_unmap>
  802dfc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802dff:	83 ec 08             	sub    $0x8,%esp
  802e02:	ff 75 f0             	pushl  -0x10(%ebp)
  802e05:	6a 00                	push   $0x0
  802e07:	e8 06 e8 ff ff       	call   801612 <sys_page_unmap>
  802e0c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802e0f:	83 ec 08             	sub    $0x8,%esp
  802e12:	ff 75 f4             	pushl  -0xc(%ebp)
  802e15:	6a 00                	push   $0x0
  802e17:	e8 f6 e7 ff ff       	call   801612 <sys_page_unmap>
  802e1c:	83 c4 10             	add    $0x10,%esp
  802e1f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802e21:	89 d0                	mov    %edx,%eax
  802e23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e26:	5b                   	pop    %ebx
  802e27:	5e                   	pop    %esi
  802e28:	5d                   	pop    %ebp
  802e29:	c3                   	ret    

00802e2a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802e2a:	55                   	push   %ebp
  802e2b:	89 e5                	mov    %esp,%ebp
  802e2d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e33:	50                   	push   %eax
  802e34:	ff 75 08             	pushl  0x8(%ebp)
  802e37:	e8 3e ee ff ff       	call   801c7a <fd_lookup>
  802e3c:	83 c4 10             	add    $0x10,%esp
  802e3f:	85 c0                	test   %eax,%eax
  802e41:	78 18                	js     802e5b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802e43:	83 ec 0c             	sub    $0xc,%esp
  802e46:	ff 75 f4             	pushl  -0xc(%ebp)
  802e49:	e8 c6 ed ff ff       	call   801c14 <fd2data>
	return _pipeisclosed(fd, p);
  802e4e:	89 c2                	mov    %eax,%edx
  802e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e53:	e8 21 fd ff ff       	call   802b79 <_pipeisclosed>
  802e58:	83 c4 10             	add    $0x10,%esp
}
  802e5b:	c9                   	leave  
  802e5c:	c3                   	ret    

00802e5d <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e5d:	55                   	push   %ebp
  802e5e:	89 e5                	mov    %esp,%ebp
  802e60:	56                   	push   %esi
  802e61:	53                   	push   %ebx
  802e62:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e65:	85 f6                	test   %esi,%esi
  802e67:	75 16                	jne    802e7f <wait+0x22>
  802e69:	68 b3 3a 80 00       	push   $0x803ab3
  802e6e:	68 8f 34 80 00       	push   $0x80348f
  802e73:	6a 09                	push   $0x9
  802e75:	68 be 3a 80 00       	push   $0x803abe
  802e7a:	e8 ba db ff ff       	call   800a39 <_panic>
	e = &envs[ENVX(envid)];
  802e7f:	89 f0                	mov    %esi,%eax
  802e81:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e86:	89 c2                	mov    %eax,%edx
  802e88:	c1 e2 07             	shl    $0x7,%edx
  802e8b:	8d 9c c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%ebx
  802e92:	eb 05                	jmp    802e99 <wait+0x3c>
		sys_yield();
  802e94:	e8 d5 e6 ff ff       	call   80156e <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e99:	8b 43 54             	mov    0x54(%ebx),%eax
  802e9c:	39 c6                	cmp    %eax,%esi
  802e9e:	75 07                	jne    802ea7 <wait+0x4a>
  802ea0:	8b 43 60             	mov    0x60(%ebx),%eax
  802ea3:	85 c0                	test   %eax,%eax
  802ea5:	75 ed                	jne    802e94 <wait+0x37>
		sys_yield();
}
  802ea7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802eaa:	5b                   	pop    %ebx
  802eab:	5e                   	pop    %esi
  802eac:	5d                   	pop    %ebp
  802ead:	c3                   	ret    

00802eae <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802eae:	55                   	push   %ebp
  802eaf:	89 e5                	mov    %esp,%ebp
  802eb1:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802eb4:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802ebb:	75 2a                	jne    802ee7 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802ebd:	83 ec 04             	sub    $0x4,%esp
  802ec0:	6a 07                	push   $0x7
  802ec2:	68 00 f0 bf ee       	push   $0xeebff000
  802ec7:	6a 00                	push   $0x0
  802ec9:	e8 bf e6 ff ff       	call   80158d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802ece:	83 c4 10             	add    $0x10,%esp
  802ed1:	85 c0                	test   %eax,%eax
  802ed3:	79 12                	jns    802ee7 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802ed5:	50                   	push   %eax
  802ed6:	68 8b 38 80 00       	push   $0x80388b
  802edb:	6a 23                	push   $0x23
  802edd:	68 c9 3a 80 00       	push   $0x803ac9
  802ee2:	e8 52 db ff ff       	call   800a39 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  802eea:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802eef:	83 ec 08             	sub    $0x8,%esp
  802ef2:	68 19 2f 80 00       	push   $0x802f19
  802ef7:	6a 00                	push   $0x0
  802ef9:	e8 da e7 ff ff       	call   8016d8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802efe:	83 c4 10             	add    $0x10,%esp
  802f01:	85 c0                	test   %eax,%eax
  802f03:	79 12                	jns    802f17 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802f05:	50                   	push   %eax
  802f06:	68 8b 38 80 00       	push   $0x80388b
  802f0b:	6a 2c                	push   $0x2c
  802f0d:	68 c9 3a 80 00       	push   $0x803ac9
  802f12:	e8 22 db ff ff       	call   800a39 <_panic>
	}
}
  802f17:	c9                   	leave  
  802f18:	c3                   	ret    

00802f19 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802f19:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802f1a:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802f1f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802f21:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802f24:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802f28:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802f2d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802f31:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802f33:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802f36:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802f37:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802f3a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802f3b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802f3c:	c3                   	ret    

00802f3d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802f3d:	55                   	push   %ebp
  802f3e:	89 e5                	mov    %esp,%ebp
  802f40:	56                   	push   %esi
  802f41:	53                   	push   %ebx
  802f42:	8b 75 08             	mov    0x8(%ebp),%esi
  802f45:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802f4b:	85 c0                	test   %eax,%eax
  802f4d:	75 12                	jne    802f61 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802f4f:	83 ec 0c             	sub    $0xc,%esp
  802f52:	68 00 00 c0 ee       	push   $0xeec00000
  802f57:	e8 e1 e7 ff ff       	call   80173d <sys_ipc_recv>
  802f5c:	83 c4 10             	add    $0x10,%esp
  802f5f:	eb 0c                	jmp    802f6d <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802f61:	83 ec 0c             	sub    $0xc,%esp
  802f64:	50                   	push   %eax
  802f65:	e8 d3 e7 ff ff       	call   80173d <sys_ipc_recv>
  802f6a:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802f6d:	85 f6                	test   %esi,%esi
  802f6f:	0f 95 c1             	setne  %cl
  802f72:	85 db                	test   %ebx,%ebx
  802f74:	0f 95 c2             	setne  %dl
  802f77:	84 d1                	test   %dl,%cl
  802f79:	74 09                	je     802f84 <ipc_recv+0x47>
  802f7b:	89 c2                	mov    %eax,%edx
  802f7d:	c1 ea 1f             	shr    $0x1f,%edx
  802f80:	84 d2                	test   %dl,%dl
  802f82:	75 2a                	jne    802fae <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802f84:	85 f6                	test   %esi,%esi
  802f86:	74 0d                	je     802f95 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802f88:	a1 24 54 80 00       	mov    0x805424,%eax
  802f8d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  802f93:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802f95:	85 db                	test   %ebx,%ebx
  802f97:	74 0d                	je     802fa6 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802f99:	a1 24 54 80 00       	mov    0x805424,%eax
  802f9e:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  802fa4:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802fa6:	a1 24 54 80 00       	mov    0x805424,%eax
  802fab:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  802fae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fb1:	5b                   	pop    %ebx
  802fb2:	5e                   	pop    %esi
  802fb3:	5d                   	pop    %ebp
  802fb4:	c3                   	ret    

00802fb5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802fb5:	55                   	push   %ebp
  802fb6:	89 e5                	mov    %esp,%ebp
  802fb8:	57                   	push   %edi
  802fb9:	56                   	push   %esi
  802fba:	53                   	push   %ebx
  802fbb:	83 ec 0c             	sub    $0xc,%esp
  802fbe:	8b 7d 08             	mov    0x8(%ebp),%edi
  802fc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  802fc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802fc7:	85 db                	test   %ebx,%ebx
  802fc9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802fce:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802fd1:	ff 75 14             	pushl  0x14(%ebp)
  802fd4:	53                   	push   %ebx
  802fd5:	56                   	push   %esi
  802fd6:	57                   	push   %edi
  802fd7:	e8 3e e7 ff ff       	call   80171a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802fdc:	89 c2                	mov    %eax,%edx
  802fde:	c1 ea 1f             	shr    $0x1f,%edx
  802fe1:	83 c4 10             	add    $0x10,%esp
  802fe4:	84 d2                	test   %dl,%dl
  802fe6:	74 17                	je     802fff <ipc_send+0x4a>
  802fe8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802feb:	74 12                	je     802fff <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802fed:	50                   	push   %eax
  802fee:	68 d7 3a 80 00       	push   $0x803ad7
  802ff3:	6a 47                	push   $0x47
  802ff5:	68 e5 3a 80 00       	push   $0x803ae5
  802ffa:	e8 3a da ff ff       	call   800a39 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802fff:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803002:	75 07                	jne    80300b <ipc_send+0x56>
			sys_yield();
  803004:	e8 65 e5 ff ff       	call   80156e <sys_yield>
  803009:	eb c6                	jmp    802fd1 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80300b:	85 c0                	test   %eax,%eax
  80300d:	75 c2                	jne    802fd1 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80300f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803012:	5b                   	pop    %ebx
  803013:	5e                   	pop    %esi
  803014:	5f                   	pop    %edi
  803015:	5d                   	pop    %ebp
  803016:	c3                   	ret    

00803017 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803017:	55                   	push   %ebp
  803018:	89 e5                	mov    %esp,%ebp
  80301a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80301d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  803022:	89 c2                	mov    %eax,%edx
  803024:	c1 e2 07             	shl    $0x7,%edx
  803027:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  80302e:	8b 52 5c             	mov    0x5c(%edx),%edx
  803031:	39 ca                	cmp    %ecx,%edx
  803033:	75 11                	jne    803046 <ipc_find_env+0x2f>
			return envs[i].env_id;
  803035:	89 c2                	mov    %eax,%edx
  803037:	c1 e2 07             	shl    $0x7,%edx
  80303a:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  803041:	8b 40 54             	mov    0x54(%eax),%eax
  803044:	eb 0f                	jmp    803055 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803046:	83 c0 01             	add    $0x1,%eax
  803049:	3d 00 04 00 00       	cmp    $0x400,%eax
  80304e:	75 d2                	jne    803022 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  803050:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803055:	5d                   	pop    %ebp
  803056:	c3                   	ret    

00803057 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803057:	55                   	push   %ebp
  803058:	89 e5                	mov    %esp,%ebp
  80305a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80305d:	89 d0                	mov    %edx,%eax
  80305f:	c1 e8 16             	shr    $0x16,%eax
  803062:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803069:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80306e:	f6 c1 01             	test   $0x1,%cl
  803071:	74 1d                	je     803090 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803073:	c1 ea 0c             	shr    $0xc,%edx
  803076:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80307d:	f6 c2 01             	test   $0x1,%dl
  803080:	74 0e                	je     803090 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803082:	c1 ea 0c             	shr    $0xc,%edx
  803085:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80308c:	ef 
  80308d:	0f b7 c0             	movzwl %ax,%eax
}
  803090:	5d                   	pop    %ebp
  803091:	c3                   	ret    
  803092:	66 90                	xchg   %ax,%ax
  803094:	66 90                	xchg   %ax,%ax
  803096:	66 90                	xchg   %ax,%ax
  803098:	66 90                	xchg   %ax,%ax
  80309a:	66 90                	xchg   %ax,%ax
  80309c:	66 90                	xchg   %ax,%ax
  80309e:	66 90                	xchg   %ax,%ax

008030a0 <__udivdi3>:
  8030a0:	55                   	push   %ebp
  8030a1:	57                   	push   %edi
  8030a2:	56                   	push   %esi
  8030a3:	53                   	push   %ebx
  8030a4:	83 ec 1c             	sub    $0x1c,%esp
  8030a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8030ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8030af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8030b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8030b7:	85 f6                	test   %esi,%esi
  8030b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8030bd:	89 ca                	mov    %ecx,%edx
  8030bf:	89 f8                	mov    %edi,%eax
  8030c1:	75 3d                	jne    803100 <__udivdi3+0x60>
  8030c3:	39 cf                	cmp    %ecx,%edi
  8030c5:	0f 87 c5 00 00 00    	ja     803190 <__udivdi3+0xf0>
  8030cb:	85 ff                	test   %edi,%edi
  8030cd:	89 fd                	mov    %edi,%ebp
  8030cf:	75 0b                	jne    8030dc <__udivdi3+0x3c>
  8030d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8030d6:	31 d2                	xor    %edx,%edx
  8030d8:	f7 f7                	div    %edi
  8030da:	89 c5                	mov    %eax,%ebp
  8030dc:	89 c8                	mov    %ecx,%eax
  8030de:	31 d2                	xor    %edx,%edx
  8030e0:	f7 f5                	div    %ebp
  8030e2:	89 c1                	mov    %eax,%ecx
  8030e4:	89 d8                	mov    %ebx,%eax
  8030e6:	89 cf                	mov    %ecx,%edi
  8030e8:	f7 f5                	div    %ebp
  8030ea:	89 c3                	mov    %eax,%ebx
  8030ec:	89 d8                	mov    %ebx,%eax
  8030ee:	89 fa                	mov    %edi,%edx
  8030f0:	83 c4 1c             	add    $0x1c,%esp
  8030f3:	5b                   	pop    %ebx
  8030f4:	5e                   	pop    %esi
  8030f5:	5f                   	pop    %edi
  8030f6:	5d                   	pop    %ebp
  8030f7:	c3                   	ret    
  8030f8:	90                   	nop
  8030f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803100:	39 ce                	cmp    %ecx,%esi
  803102:	77 74                	ja     803178 <__udivdi3+0xd8>
  803104:	0f bd fe             	bsr    %esi,%edi
  803107:	83 f7 1f             	xor    $0x1f,%edi
  80310a:	0f 84 98 00 00 00    	je     8031a8 <__udivdi3+0x108>
  803110:	bb 20 00 00 00       	mov    $0x20,%ebx
  803115:	89 f9                	mov    %edi,%ecx
  803117:	89 c5                	mov    %eax,%ebp
  803119:	29 fb                	sub    %edi,%ebx
  80311b:	d3 e6                	shl    %cl,%esi
  80311d:	89 d9                	mov    %ebx,%ecx
  80311f:	d3 ed                	shr    %cl,%ebp
  803121:	89 f9                	mov    %edi,%ecx
  803123:	d3 e0                	shl    %cl,%eax
  803125:	09 ee                	or     %ebp,%esi
  803127:	89 d9                	mov    %ebx,%ecx
  803129:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80312d:	89 d5                	mov    %edx,%ebp
  80312f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803133:	d3 ed                	shr    %cl,%ebp
  803135:	89 f9                	mov    %edi,%ecx
  803137:	d3 e2                	shl    %cl,%edx
  803139:	89 d9                	mov    %ebx,%ecx
  80313b:	d3 e8                	shr    %cl,%eax
  80313d:	09 c2                	or     %eax,%edx
  80313f:	89 d0                	mov    %edx,%eax
  803141:	89 ea                	mov    %ebp,%edx
  803143:	f7 f6                	div    %esi
  803145:	89 d5                	mov    %edx,%ebp
  803147:	89 c3                	mov    %eax,%ebx
  803149:	f7 64 24 0c          	mull   0xc(%esp)
  80314d:	39 d5                	cmp    %edx,%ebp
  80314f:	72 10                	jb     803161 <__udivdi3+0xc1>
  803151:	8b 74 24 08          	mov    0x8(%esp),%esi
  803155:	89 f9                	mov    %edi,%ecx
  803157:	d3 e6                	shl    %cl,%esi
  803159:	39 c6                	cmp    %eax,%esi
  80315b:	73 07                	jae    803164 <__udivdi3+0xc4>
  80315d:	39 d5                	cmp    %edx,%ebp
  80315f:	75 03                	jne    803164 <__udivdi3+0xc4>
  803161:	83 eb 01             	sub    $0x1,%ebx
  803164:	31 ff                	xor    %edi,%edi
  803166:	89 d8                	mov    %ebx,%eax
  803168:	89 fa                	mov    %edi,%edx
  80316a:	83 c4 1c             	add    $0x1c,%esp
  80316d:	5b                   	pop    %ebx
  80316e:	5e                   	pop    %esi
  80316f:	5f                   	pop    %edi
  803170:	5d                   	pop    %ebp
  803171:	c3                   	ret    
  803172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803178:	31 ff                	xor    %edi,%edi
  80317a:	31 db                	xor    %ebx,%ebx
  80317c:	89 d8                	mov    %ebx,%eax
  80317e:	89 fa                	mov    %edi,%edx
  803180:	83 c4 1c             	add    $0x1c,%esp
  803183:	5b                   	pop    %ebx
  803184:	5e                   	pop    %esi
  803185:	5f                   	pop    %edi
  803186:	5d                   	pop    %ebp
  803187:	c3                   	ret    
  803188:	90                   	nop
  803189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803190:	89 d8                	mov    %ebx,%eax
  803192:	f7 f7                	div    %edi
  803194:	31 ff                	xor    %edi,%edi
  803196:	89 c3                	mov    %eax,%ebx
  803198:	89 d8                	mov    %ebx,%eax
  80319a:	89 fa                	mov    %edi,%edx
  80319c:	83 c4 1c             	add    $0x1c,%esp
  80319f:	5b                   	pop    %ebx
  8031a0:	5e                   	pop    %esi
  8031a1:	5f                   	pop    %edi
  8031a2:	5d                   	pop    %ebp
  8031a3:	c3                   	ret    
  8031a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8031a8:	39 ce                	cmp    %ecx,%esi
  8031aa:	72 0c                	jb     8031b8 <__udivdi3+0x118>
  8031ac:	31 db                	xor    %ebx,%ebx
  8031ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8031b2:	0f 87 34 ff ff ff    	ja     8030ec <__udivdi3+0x4c>
  8031b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8031bd:	e9 2a ff ff ff       	jmp    8030ec <__udivdi3+0x4c>
  8031c2:	66 90                	xchg   %ax,%ax
  8031c4:	66 90                	xchg   %ax,%ax
  8031c6:	66 90                	xchg   %ax,%ax
  8031c8:	66 90                	xchg   %ax,%ax
  8031ca:	66 90                	xchg   %ax,%ax
  8031cc:	66 90                	xchg   %ax,%ax
  8031ce:	66 90                	xchg   %ax,%ax

008031d0 <__umoddi3>:
  8031d0:	55                   	push   %ebp
  8031d1:	57                   	push   %edi
  8031d2:	56                   	push   %esi
  8031d3:	53                   	push   %ebx
  8031d4:	83 ec 1c             	sub    $0x1c,%esp
  8031d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8031db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8031df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8031e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8031e7:	85 d2                	test   %edx,%edx
  8031e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8031ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8031f1:	89 f3                	mov    %esi,%ebx
  8031f3:	89 3c 24             	mov    %edi,(%esp)
  8031f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8031fa:	75 1c                	jne    803218 <__umoddi3+0x48>
  8031fc:	39 f7                	cmp    %esi,%edi
  8031fe:	76 50                	jbe    803250 <__umoddi3+0x80>
  803200:	89 c8                	mov    %ecx,%eax
  803202:	89 f2                	mov    %esi,%edx
  803204:	f7 f7                	div    %edi
  803206:	89 d0                	mov    %edx,%eax
  803208:	31 d2                	xor    %edx,%edx
  80320a:	83 c4 1c             	add    $0x1c,%esp
  80320d:	5b                   	pop    %ebx
  80320e:	5e                   	pop    %esi
  80320f:	5f                   	pop    %edi
  803210:	5d                   	pop    %ebp
  803211:	c3                   	ret    
  803212:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803218:	39 f2                	cmp    %esi,%edx
  80321a:	89 d0                	mov    %edx,%eax
  80321c:	77 52                	ja     803270 <__umoddi3+0xa0>
  80321e:	0f bd ea             	bsr    %edx,%ebp
  803221:	83 f5 1f             	xor    $0x1f,%ebp
  803224:	75 5a                	jne    803280 <__umoddi3+0xb0>
  803226:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80322a:	0f 82 e0 00 00 00    	jb     803310 <__umoddi3+0x140>
  803230:	39 0c 24             	cmp    %ecx,(%esp)
  803233:	0f 86 d7 00 00 00    	jbe    803310 <__umoddi3+0x140>
  803239:	8b 44 24 08          	mov    0x8(%esp),%eax
  80323d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803241:	83 c4 1c             	add    $0x1c,%esp
  803244:	5b                   	pop    %ebx
  803245:	5e                   	pop    %esi
  803246:	5f                   	pop    %edi
  803247:	5d                   	pop    %ebp
  803248:	c3                   	ret    
  803249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803250:	85 ff                	test   %edi,%edi
  803252:	89 fd                	mov    %edi,%ebp
  803254:	75 0b                	jne    803261 <__umoddi3+0x91>
  803256:	b8 01 00 00 00       	mov    $0x1,%eax
  80325b:	31 d2                	xor    %edx,%edx
  80325d:	f7 f7                	div    %edi
  80325f:	89 c5                	mov    %eax,%ebp
  803261:	89 f0                	mov    %esi,%eax
  803263:	31 d2                	xor    %edx,%edx
  803265:	f7 f5                	div    %ebp
  803267:	89 c8                	mov    %ecx,%eax
  803269:	f7 f5                	div    %ebp
  80326b:	89 d0                	mov    %edx,%eax
  80326d:	eb 99                	jmp    803208 <__umoddi3+0x38>
  80326f:	90                   	nop
  803270:	89 c8                	mov    %ecx,%eax
  803272:	89 f2                	mov    %esi,%edx
  803274:	83 c4 1c             	add    $0x1c,%esp
  803277:	5b                   	pop    %ebx
  803278:	5e                   	pop    %esi
  803279:	5f                   	pop    %edi
  80327a:	5d                   	pop    %ebp
  80327b:	c3                   	ret    
  80327c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803280:	8b 34 24             	mov    (%esp),%esi
  803283:	bf 20 00 00 00       	mov    $0x20,%edi
  803288:	89 e9                	mov    %ebp,%ecx
  80328a:	29 ef                	sub    %ebp,%edi
  80328c:	d3 e0                	shl    %cl,%eax
  80328e:	89 f9                	mov    %edi,%ecx
  803290:	89 f2                	mov    %esi,%edx
  803292:	d3 ea                	shr    %cl,%edx
  803294:	89 e9                	mov    %ebp,%ecx
  803296:	09 c2                	or     %eax,%edx
  803298:	89 d8                	mov    %ebx,%eax
  80329a:	89 14 24             	mov    %edx,(%esp)
  80329d:	89 f2                	mov    %esi,%edx
  80329f:	d3 e2                	shl    %cl,%edx
  8032a1:	89 f9                	mov    %edi,%ecx
  8032a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8032a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8032ab:	d3 e8                	shr    %cl,%eax
  8032ad:	89 e9                	mov    %ebp,%ecx
  8032af:	89 c6                	mov    %eax,%esi
  8032b1:	d3 e3                	shl    %cl,%ebx
  8032b3:	89 f9                	mov    %edi,%ecx
  8032b5:	89 d0                	mov    %edx,%eax
  8032b7:	d3 e8                	shr    %cl,%eax
  8032b9:	89 e9                	mov    %ebp,%ecx
  8032bb:	09 d8                	or     %ebx,%eax
  8032bd:	89 d3                	mov    %edx,%ebx
  8032bf:	89 f2                	mov    %esi,%edx
  8032c1:	f7 34 24             	divl   (%esp)
  8032c4:	89 d6                	mov    %edx,%esi
  8032c6:	d3 e3                	shl    %cl,%ebx
  8032c8:	f7 64 24 04          	mull   0x4(%esp)
  8032cc:	39 d6                	cmp    %edx,%esi
  8032ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8032d2:	89 d1                	mov    %edx,%ecx
  8032d4:	89 c3                	mov    %eax,%ebx
  8032d6:	72 08                	jb     8032e0 <__umoddi3+0x110>
  8032d8:	75 11                	jne    8032eb <__umoddi3+0x11b>
  8032da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8032de:	73 0b                	jae    8032eb <__umoddi3+0x11b>
  8032e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8032e4:	1b 14 24             	sbb    (%esp),%edx
  8032e7:	89 d1                	mov    %edx,%ecx
  8032e9:	89 c3                	mov    %eax,%ebx
  8032eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8032ef:	29 da                	sub    %ebx,%edx
  8032f1:	19 ce                	sbb    %ecx,%esi
  8032f3:	89 f9                	mov    %edi,%ecx
  8032f5:	89 f0                	mov    %esi,%eax
  8032f7:	d3 e0                	shl    %cl,%eax
  8032f9:	89 e9                	mov    %ebp,%ecx
  8032fb:	d3 ea                	shr    %cl,%edx
  8032fd:	89 e9                	mov    %ebp,%ecx
  8032ff:	d3 ee                	shr    %cl,%esi
  803301:	09 d0                	or     %edx,%eax
  803303:	89 f2                	mov    %esi,%edx
  803305:	83 c4 1c             	add    $0x1c,%esp
  803308:	5b                   	pop    %ebx
  803309:	5e                   	pop    %esi
  80330a:	5f                   	pop    %edi
  80330b:	5d                   	pop    %ebp
  80330c:	c3                   	ret    
  80330d:	8d 76 00             	lea    0x0(%esi),%esi
  803310:	29 f9                	sub    %edi,%ecx
  803312:	19 d6                	sbb    %edx,%esi
  803314:	89 74 24 04          	mov    %esi,0x4(%esp)
  803318:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80331c:	e9 18 ff ff ff       	jmp    803239 <__umoddi3+0x69>
