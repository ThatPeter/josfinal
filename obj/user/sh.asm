
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
  80005b:	68 a0 33 80 00       	push   $0x8033a0
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
  80007f:	68 af 33 80 00       	push   $0x8033af
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
  8000ab:	68 bd 33 80 00       	push   $0x8033bd
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
  8000d8:	68 c2 33 80 00       	push   $0x8033c2
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
  8000f6:	68 d3 33 80 00       	push   $0x8033d3
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
  800126:	68 c7 33 80 00       	push   $0x8033c7
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
  80014c:	68 cf 33 80 00       	push   $0x8033cf
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
  80017b:	68 db 33 80 00       	push   $0x8033db
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
  800273:	68 e5 33 80 00       	push   $0x8033e5
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
  8002a7:	68 38 35 80 00       	push   $0x803538
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
  8002c1:	e8 07 21 00 00       	call   8023cd <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
				cprintf("open %s for read: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 f9 33 80 00       	push   $0x8033f9
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
  8002f8:	e8 50 1b 00 00       	call   801e4d <dup>
				close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 f8 1a 00 00       	call   801dfd <close>
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
  800323:	68 60 35 80 00       	push   $0x803560
  800328:	e8 f3 07 00 00       	call   800b20 <cprintf>
				exit();
  80032d:	e8 fb 06 00 00       	call   800a2d <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 88 20 00 00       	call   8023cd <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 0e 34 80 00       	push   $0x80340e
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
  800376:	e8 d2 1a 00 00       	call   801e4d <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 7a 1a 00 00       	call   801dfd <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 ab 29 00 00       	call   802d45 <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 24 34 80 00       	push   $0x803424
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
  8003cf:	68 2d 34 80 00       	push   $0x80342d
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
  8003eb:	68 3a 34 80 00       	push   $0x80343a
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
  800411:	e8 37 1a 00 00       	call   801e4d <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 d9 19 00 00       	call   801dfd <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 c8 19 00 00       	call   801dfd <close>
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
  80044e:	e8 fa 19 00 00       	call   801e4d <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 9c 19 00 00       	call   801dfd <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 8b 19 00 00       	call   801dfd <close>
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 17                	jmp    80048e <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800477:	50                   	push   %eax
  800478:	68 43 34 80 00       	push   $0x803443
  80047d:	6a 79                	push   $0x79
  80047f:	68 5f 34 80 00       	push   $0x80345f
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
  8004a2:	68 69 34 80 00       	push   $0x803469
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
  8004f5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	50                   	push   %eax
  8004ff:	68 78 34 80 00       	push   $0x803478
  800504:	e8 17 06 00 00       	call   800b20 <cprintf>
  800509:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	eb 11                	jmp    800522 <runcmd+0x319>
			cprintf(" %s", argv[i]);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	50                   	push   %eax
  800515:	68 00 35 80 00       	push   $0x803500
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
  80052f:	68 c0 33 80 00       	push   $0x8033c0
  800534:	e8 e7 05 00 00       	call   800b20 <cprintf>
  800539:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800542:	50                   	push   %eax
  800543:	ff 75 a8             	pushl  -0x58(%ebp)
  800546:	e8 36 20 00 00       	call   802581 <spawn>
  80054b:	89 c3                	mov    %eax,%ebx
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	85 c0                	test   %eax,%eax
  800552:	0f 89 cf 00 00 00    	jns    800627 <runcmd+0x41e>
		cprintf("spawn %s: %e\n", argv[0], r);
  800558:	83 ec 04             	sub    $0x4,%esp
  80055b:	50                   	push   %eax
  80055c:	ff 75 a8             	pushl  -0x58(%ebp)
  80055f:	68 86 34 80 00       	push   $0x803486
  800564:	e8 b7 05 00 00       	call   800b20 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800569:	e8 ba 18 00 00       	call   801e28 <close_all>
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	eb 52                	jmp    8005c5 <runcmd+0x3bc>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800573:	a1 24 54 80 00       	mov    0x805424,%eax
  800578:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80057e:	53                   	push   %ebx
  80057f:	ff 75 a8             	pushl  -0x58(%ebp)
  800582:	50                   	push   %eax
  800583:	68 94 34 80 00       	push   $0x803494
  800588:	e8 93 05 00 00       	call   800b20 <cprintf>
  80058d:	83 c4 10             	add    $0x10,%esp
		wait(r);
  800590:	83 ec 0c             	sub    $0xc,%esp
  800593:	53                   	push   %ebx
  800594:	e8 32 29 00 00       	call   802ecb <wait>
		if (debug)
  800599:	83 c4 10             	add    $0x10,%esp
  80059c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005a3:	0f 84 95 00 00 00    	je     80063e <runcmd+0x435>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a9:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ae:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	50                   	push   %eax
  8005b8:	68 a9 34 80 00       	push   $0x8034a9
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
  8005d7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8005dd:	83 ec 04             	sub    $0x4,%esp
  8005e0:	57                   	push   %edi
  8005e1:	50                   	push   %eax
  8005e2:	68 bf 34 80 00       	push   $0x8034bf
  8005e7:	e8 34 05 00 00       	call   800b20 <cprintf>
  8005ec:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	57                   	push   %edi
  8005f3:	e8 d3 28 00 00       	call   802ecb <wait>
		if (debug)
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800602:	74 1c                	je     800620 <runcmd+0x417>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800604:	a1 24 54 80 00       	mov    0x805424,%eax
  800609:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	50                   	push   %eax
  800613:	68 a9 34 80 00       	push   $0x8034a9
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
  800627:	e8 fc 17 00 00       	call   801e28 <close_all>
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
  800652:	68 88 35 80 00       	push   $0x803588
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
  80067b:	e8 86 14 00 00       	call   801b06 <argstart>
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
  8006c7:	e8 6a 14 00 00       	call   801b36 <argnext>
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
  8006e9:	e8 0f 17 00 00       	call   801dfd <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006ee:	83 c4 08             	add    $0x8,%esp
  8006f1:	6a 00                	push   $0x0
  8006f3:	ff 77 04             	pushl  0x4(%edi)
  8006f6:	e8 d2 1c 00 00       	call   8023cd <open>
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	85 c0                	test   %eax,%eax
  800700:	79 1b                	jns    80071d <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  800702:	83 ec 0c             	sub    $0xc,%esp
  800705:	50                   	push   %eax
  800706:	ff 77 04             	pushl  0x4(%edi)
  800709:	68 dc 34 80 00       	push   $0x8034dc
  80070e:	68 29 01 00 00       	push   $0x129
  800713:	68 5f 34 80 00       	push   $0x80345f
  800718:	e8 2a 03 00 00       	call   800a47 <_panic>
		assert(r == 0);
  80071d:	85 c0                	test   %eax,%eax
  80071f:	74 19                	je     80073a <umain+0xd4>
  800721:	68 e8 34 80 00       	push   $0x8034e8
  800726:	68 ef 34 80 00       	push   $0x8034ef
  80072b:	68 2a 01 00 00       	push   $0x12a
  800730:	68 5f 34 80 00       	push   $0x80345f
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
  800755:	bf 04 35 80 00       	mov    $0x803504,%edi
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
  80077b:	68 07 35 80 00       	push   $0x803507
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
  80079a:	68 10 35 80 00       	push   $0x803510
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
  8007b6:	68 1a 35 80 00       	push   $0x80351a
  8007bb:	e8 ab 1d 00 00       	call   80256b <printf>
  8007c0:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007c3:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007ca:	74 10                	je     8007dc <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007cc:	83 ec 0c             	sub    $0xc,%esp
  8007cf:	68 20 35 80 00       	push   $0x803520
  8007d4:	e8 47 03 00 00       	call   800b20 <cprintf>
  8007d9:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007dc:	e8 e1 10 00 00       	call   8018c2 <fork>
  8007e1:	89 c6                	mov    %eax,%esi
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	79 15                	jns    8007fc <umain+0x196>
			panic("fork: %e", r);
  8007e7:	50                   	push   %eax
  8007e8:	68 3a 34 80 00       	push   $0x80343a
  8007ed:	68 41 01 00 00       	push   $0x141
  8007f2:	68 5f 34 80 00       	push   $0x80345f
  8007f7:	e8 4b 02 00 00       	call   800a47 <_panic>
		if (debug)
  8007fc:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800803:	74 11                	je     800816 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  800805:	83 ec 08             	sub    $0x8,%esp
  800808:	50                   	push   %eax
  800809:	68 2d 35 80 00       	push   $0x80352d
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
  800834:	e8 92 26 00 00       	call   802ecb <wait>
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
  800851:	68 a9 35 80 00       	push   $0x8035a9
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
  800921:	e8 13 16 00 00       	call   801f39 <read>
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
  80094b:	e8 80 13 00 00       	call   801cd0 <fd_lookup>
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
  800974:	e8 08 13 00 00       	call   801c81 <fd_alloc>
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
  8009b6:	e8 9f 12 00 00       	call   801c5a <fd2num>
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
  8009d9:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8009df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009e4:	a3 24 54 80 00       	mov    %eax,0x805424
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  800a33:	e8 f0 13 00 00       	call   801e28 <close_all>
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
  800a65:	68 c0 35 80 00       	push   $0x8035c0
  800a6a:	e8 b1 00 00 00       	call   800b20 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a6f:	83 c4 18             	add    $0x18,%esp
  800a72:	53                   	push   %ebx
  800a73:	ff 75 10             	pushl  0x10(%ebp)
  800a76:	e8 54 00 00 00       	call   800acf <vcprintf>
	cprintf("\n");
  800a7b:	c7 04 24 c0 33 80 00 	movl   $0x8033c0,(%esp)
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
  800b83:	e8 88 25 00 00       	call   803110 <__udivdi3>
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
  800bc6:	e8 75 26 00 00       	call   803240 <__umoddi3>
  800bcb:	83 c4 14             	add    $0x14,%esp
  800bce:	0f be 80 e3 35 80 00 	movsbl 0x8035e3(%eax),%eax
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
  800cca:	ff 24 85 20 37 80 00 	jmp    *0x803720(,%eax,4)
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
  800d8e:	8b 14 85 80 38 80 00 	mov    0x803880(,%eax,4),%edx
  800d95:	85 d2                	test   %edx,%edx
  800d97:	75 18                	jne    800db1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d99:	50                   	push   %eax
  800d9a:	68 fb 35 80 00       	push   $0x8035fb
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
  800db2:	68 01 35 80 00       	push   $0x803501
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
  800dd6:	b8 f4 35 80 00       	mov    $0x8035f4,%eax
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
  801080:	68 01 35 80 00       	push   $0x803501
  801085:	6a 01                	push   $0x1
  801087:	e8 c8 14 00 00       	call   802554 <fprintf>
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
  8010c0:	68 df 38 80 00       	push   $0x8038df
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
  801544:	68 ef 38 80 00       	push   $0x8038ef
  801549:	6a 23                	push   $0x23
  80154b:	68 0c 39 80 00       	push   $0x80390c
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
  8015c5:	68 ef 38 80 00       	push   $0x8038ef
  8015ca:	6a 23                	push   $0x23
  8015cc:	68 0c 39 80 00       	push   $0x80390c
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
  801607:	68 ef 38 80 00       	push   $0x8038ef
  80160c:	6a 23                	push   $0x23
  80160e:	68 0c 39 80 00       	push   $0x80390c
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
  801649:	68 ef 38 80 00       	push   $0x8038ef
  80164e:	6a 23                	push   $0x23
  801650:	68 0c 39 80 00       	push   $0x80390c
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
  80168b:	68 ef 38 80 00       	push   $0x8038ef
  801690:	6a 23                	push   $0x23
  801692:	68 0c 39 80 00       	push   $0x80390c
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
  8016cd:	68 ef 38 80 00       	push   $0x8038ef
  8016d2:	6a 23                	push   $0x23
  8016d4:	68 0c 39 80 00       	push   $0x80390c
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
  80170f:	68 ef 38 80 00       	push   $0x8038ef
  801714:	6a 23                	push   $0x23
  801716:	68 0c 39 80 00       	push   $0x80390c
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
  801773:	68 ef 38 80 00       	push   $0x8038ef
  801778:	6a 23                	push   $0x23
  80177a:	68 0c 39 80 00       	push   $0x80390c
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
  801812:	68 1a 39 80 00       	push   $0x80391a
  801817:	6a 1e                	push   $0x1e
  801819:	68 2a 39 80 00       	push   $0x80392a
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
  80183c:	68 35 39 80 00       	push   $0x803935
  801841:	6a 2c                	push   $0x2c
  801843:	68 2a 39 80 00       	push   $0x80392a
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
  801884:	68 35 39 80 00       	push   $0x803935
  801889:	6a 33                	push   $0x33
  80188b:	68 2a 39 80 00       	push   $0x80392a
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
  8018ac:	68 35 39 80 00       	push   $0x803935
  8018b1:	6a 37                	push   $0x37
  8018b3:	68 2a 39 80 00       	push   $0x80392a
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
  8018d0:	e8 4e 16 00 00       	call   802f23 <set_pgfault_handler>
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
  8018e9:	68 4e 39 80 00       	push   $0x80394e
  8018ee:	68 84 00 00 00       	push   $0x84
  8018f3:	68 2a 39 80 00       	push   $0x80392a
  8018f8:	e8 4a f1 ff ff       	call   800a47 <_panic>
  8018fd:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8018ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801903:	75 24                	jne    801929 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  801905:	e8 53 fc ff ff       	call   80155d <sys_getenvid>
  80190a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80190f:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  8019a5:	68 5c 39 80 00       	push   $0x80395c
  8019aa:	6a 54                	push   $0x54
  8019ac:	68 2a 39 80 00       	push   $0x80392a
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
  8019ea:	68 5c 39 80 00       	push   $0x80395c
  8019ef:	6a 5b                	push   $0x5b
  8019f1:	68 2a 39 80 00       	push   $0x80392a
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
  801a18:	68 5c 39 80 00       	push   $0x80395c
  801a1d:	6a 5f                	push   $0x5f
  801a1f:	68 2a 39 80 00       	push   $0x80392a
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
  801a42:	68 5c 39 80 00       	push   $0x80395c
  801a47:	6a 64                	push   $0x64
  801a49:	68 2a 39 80 00       	push   $0x80392a
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
  801a6a:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	56                   	push   %esi
  801aa3:	53                   	push   %ebx
  801aa4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801aa7:	89 1d 28 54 80 00    	mov    %ebx,0x805428
	cprintf("in fork.c thread create. func: %x\n", func);
  801aad:	83 ec 08             	sub    $0x8,%esp
  801ab0:	53                   	push   %ebx
  801ab1:	68 74 39 80 00       	push   $0x803974
  801ab6:	e8 65 f0 ff ff       	call   800b20 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801abb:	c7 04 24 0d 0a 80 00 	movl   $0x800a0d,(%esp)
  801ac2:	e8 c5 fc ff ff       	call   80178c <sys_thread_create>
  801ac7:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801ac9:	83 c4 08             	add    $0x8,%esp
  801acc:	53                   	push   %ebx
  801acd:	68 74 39 80 00       	push   $0x803974
  801ad2:	e8 49 f0 ff ff       	call   800b20 <cprintf>
	return id;
}
  801ad7:	89 f0                	mov    %esi,%eax
  801ad9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801adc:	5b                   	pop    %ebx
  801add:	5e                   	pop    %esi
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    

00801ae0 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  801ae6:	ff 75 08             	pushl  0x8(%ebp)
  801ae9:	e8 be fc ff ff       	call   8017ac <sys_thread_free>
}
  801aee:	83 c4 10             	add    $0x10,%esp
  801af1:	c9                   	leave  
  801af2:	c3                   	ret    

00801af3 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  801af9:	ff 75 08             	pushl  0x8(%ebp)
  801afc:	e8 cb fc ff ff       	call   8017cc <sys_thread_join>
}
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	c9                   	leave  
  801b05:	c3                   	ret    

00801b06 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	8b 55 08             	mov    0x8(%ebp),%edx
  801b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0f:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801b12:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801b14:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801b17:	83 3a 01             	cmpl   $0x1,(%edx)
  801b1a:	7e 09                	jle    801b25 <argstart+0x1f>
  801b1c:	ba c1 33 80 00       	mov    $0x8033c1,%edx
  801b21:	85 c9                	test   %ecx,%ecx
  801b23:	75 05                	jne    801b2a <argstart+0x24>
  801b25:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2a:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801b2d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801b34:	5d                   	pop    %ebp
  801b35:	c3                   	ret    

00801b36 <argnext>:

int
argnext(struct Argstate *args)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	53                   	push   %ebx
  801b3a:	83 ec 04             	sub    $0x4,%esp
  801b3d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801b40:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801b47:	8b 43 08             	mov    0x8(%ebx),%eax
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	74 6f                	je     801bbd <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801b4e:	80 38 00             	cmpb   $0x0,(%eax)
  801b51:	75 4e                	jne    801ba1 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b53:	8b 0b                	mov    (%ebx),%ecx
  801b55:	83 39 01             	cmpl   $0x1,(%ecx)
  801b58:	74 55                	je     801baf <argnext+0x79>
		    || args->argv[1][0] != '-'
  801b5a:	8b 53 04             	mov    0x4(%ebx),%edx
  801b5d:	8b 42 04             	mov    0x4(%edx),%eax
  801b60:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b63:	75 4a                	jne    801baf <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801b65:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b69:	74 44                	je     801baf <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b6b:	83 c0 01             	add    $0x1,%eax
  801b6e:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b71:	83 ec 04             	sub    $0x4,%esp
  801b74:	8b 01                	mov    (%ecx),%eax
  801b76:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b7d:	50                   	push   %eax
  801b7e:	8d 42 08             	lea    0x8(%edx),%eax
  801b81:	50                   	push   %eax
  801b82:	83 c2 04             	add    $0x4,%edx
  801b85:	52                   	push   %edx
  801b86:	e8 9f f7 ff ff       	call   80132a <memmove>
		(*args->argc)--;
  801b8b:	8b 03                	mov    (%ebx),%eax
  801b8d:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b90:	8b 43 08             	mov    0x8(%ebx),%eax
  801b93:	83 c4 10             	add    $0x10,%esp
  801b96:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b99:	75 06                	jne    801ba1 <argnext+0x6b>
  801b9b:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b9f:	74 0e                	je     801baf <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801ba1:	8b 53 08             	mov    0x8(%ebx),%edx
  801ba4:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801ba7:	83 c2 01             	add    $0x1,%edx
  801baa:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801bad:	eb 13                	jmp    801bc2 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801baf:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801bb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801bbb:	eb 05                	jmp    801bc2 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801bbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801bc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc5:	c9                   	leave  
  801bc6:	c3                   	ret    

00801bc7 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	53                   	push   %ebx
  801bcb:	83 ec 04             	sub    $0x4,%esp
  801bce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801bd1:	8b 43 08             	mov    0x8(%ebx),%eax
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	74 58                	je     801c30 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801bd8:	80 38 00             	cmpb   $0x0,(%eax)
  801bdb:	74 0c                	je     801be9 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801bdd:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801be0:	c7 43 08 c1 33 80 00 	movl   $0x8033c1,0x8(%ebx)
  801be7:	eb 42                	jmp    801c2b <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801be9:	8b 13                	mov    (%ebx),%edx
  801beb:	83 3a 01             	cmpl   $0x1,(%edx)
  801bee:	7e 2d                	jle    801c1d <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801bf0:	8b 43 04             	mov    0x4(%ebx),%eax
  801bf3:	8b 48 04             	mov    0x4(%eax),%ecx
  801bf6:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801bf9:	83 ec 04             	sub    $0x4,%esp
  801bfc:	8b 12                	mov    (%edx),%edx
  801bfe:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801c05:	52                   	push   %edx
  801c06:	8d 50 08             	lea    0x8(%eax),%edx
  801c09:	52                   	push   %edx
  801c0a:	83 c0 04             	add    $0x4,%eax
  801c0d:	50                   	push   %eax
  801c0e:	e8 17 f7 ff ff       	call   80132a <memmove>
		(*args->argc)--;
  801c13:	8b 03                	mov    (%ebx),%eax
  801c15:	83 28 01             	subl   $0x1,(%eax)
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	eb 0e                	jmp    801c2b <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801c1d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801c24:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801c2b:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c2e:	eb 05                	jmp    801c35 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801c30:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801c35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	83 ec 08             	sub    $0x8,%esp
  801c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c43:	8b 51 0c             	mov    0xc(%ecx),%edx
  801c46:	89 d0                	mov    %edx,%eax
  801c48:	85 d2                	test   %edx,%edx
  801c4a:	75 0c                	jne    801c58 <argvalue+0x1e>
  801c4c:	83 ec 0c             	sub    $0xc,%esp
  801c4f:	51                   	push   %ecx
  801c50:	e8 72 ff ff ff       	call   801bc7 <argnextvalue>
  801c55:	83 c4 10             	add    $0x10,%esp
}
  801c58:	c9                   	leave  
  801c59:	c3                   	ret    

00801c5a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c60:	05 00 00 00 30       	add    $0x30000000,%eax
  801c65:	c1 e8 0c             	shr    $0xc,%eax
}
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    

00801c6a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c70:	05 00 00 00 30       	add    $0x30000000,%eax
  801c75:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c7a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c7f:	5d                   	pop    %ebp
  801c80:	c3                   	ret    

00801c81 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c87:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c8c:	89 c2                	mov    %eax,%edx
  801c8e:	c1 ea 16             	shr    $0x16,%edx
  801c91:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c98:	f6 c2 01             	test   $0x1,%dl
  801c9b:	74 11                	je     801cae <fd_alloc+0x2d>
  801c9d:	89 c2                	mov    %eax,%edx
  801c9f:	c1 ea 0c             	shr    $0xc,%edx
  801ca2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ca9:	f6 c2 01             	test   $0x1,%dl
  801cac:	75 09                	jne    801cb7 <fd_alloc+0x36>
			*fd_store = fd;
  801cae:	89 01                	mov    %eax,(%ecx)
			return 0;
  801cb0:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb5:	eb 17                	jmp    801cce <fd_alloc+0x4d>
  801cb7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801cbc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801cc1:	75 c9                	jne    801c8c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801cc3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801cc9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    

00801cd0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801cd6:	83 f8 1f             	cmp    $0x1f,%eax
  801cd9:	77 36                	ja     801d11 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801cdb:	c1 e0 0c             	shl    $0xc,%eax
  801cde:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801ce3:	89 c2                	mov    %eax,%edx
  801ce5:	c1 ea 16             	shr    $0x16,%edx
  801ce8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cef:	f6 c2 01             	test   $0x1,%dl
  801cf2:	74 24                	je     801d18 <fd_lookup+0x48>
  801cf4:	89 c2                	mov    %eax,%edx
  801cf6:	c1 ea 0c             	shr    $0xc,%edx
  801cf9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d00:	f6 c2 01             	test   $0x1,%dl
  801d03:	74 1a                	je     801d1f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801d05:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d08:	89 02                	mov    %eax,(%edx)
	return 0;
  801d0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0f:	eb 13                	jmp    801d24 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801d11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d16:	eb 0c                	jmp    801d24 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801d18:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d1d:	eb 05                	jmp    801d24 <fd_lookup+0x54>
  801d1f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801d24:	5d                   	pop    %ebp
  801d25:	c3                   	ret    

00801d26 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	83 ec 08             	sub    $0x8,%esp
  801d2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d2f:	ba 14 3a 80 00       	mov    $0x803a14,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801d34:	eb 13                	jmp    801d49 <dev_lookup+0x23>
  801d36:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801d39:	39 08                	cmp    %ecx,(%eax)
  801d3b:	75 0c                	jne    801d49 <dev_lookup+0x23>
			*dev = devtab[i];
  801d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d40:	89 01                	mov    %eax,(%ecx)
			return 0;
  801d42:	b8 00 00 00 00       	mov    $0x0,%eax
  801d47:	eb 31                	jmp    801d7a <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801d49:	8b 02                	mov    (%edx),%eax
  801d4b:	85 c0                	test   %eax,%eax
  801d4d:	75 e7                	jne    801d36 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d4f:	a1 24 54 80 00       	mov    0x805424,%eax
  801d54:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801d5a:	83 ec 04             	sub    $0x4,%esp
  801d5d:	51                   	push   %ecx
  801d5e:	50                   	push   %eax
  801d5f:	68 98 39 80 00       	push   $0x803998
  801d64:	e8 b7 ed ff ff       	call   800b20 <cprintf>
	*dev = 0;
  801d69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801d72:	83 c4 10             	add    $0x10,%esp
  801d75:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	56                   	push   %esi
  801d80:	53                   	push   %ebx
  801d81:	83 ec 10             	sub    $0x10,%esp
  801d84:	8b 75 08             	mov    0x8(%ebp),%esi
  801d87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8d:	50                   	push   %eax
  801d8e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d94:	c1 e8 0c             	shr    $0xc,%eax
  801d97:	50                   	push   %eax
  801d98:	e8 33 ff ff ff       	call   801cd0 <fd_lookup>
  801d9d:	83 c4 08             	add    $0x8,%esp
  801da0:	85 c0                	test   %eax,%eax
  801da2:	78 05                	js     801da9 <fd_close+0x2d>
	    || fd != fd2)
  801da4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801da7:	74 0c                	je     801db5 <fd_close+0x39>
		return (must_exist ? r : 0);
  801da9:	84 db                	test   %bl,%bl
  801dab:	ba 00 00 00 00       	mov    $0x0,%edx
  801db0:	0f 44 c2             	cmove  %edx,%eax
  801db3:	eb 41                	jmp    801df6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801db5:	83 ec 08             	sub    $0x8,%esp
  801db8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dbb:	50                   	push   %eax
  801dbc:	ff 36                	pushl  (%esi)
  801dbe:	e8 63 ff ff ff       	call   801d26 <dev_lookup>
  801dc3:	89 c3                	mov    %eax,%ebx
  801dc5:	83 c4 10             	add    $0x10,%esp
  801dc8:	85 c0                	test   %eax,%eax
  801dca:	78 1a                	js     801de6 <fd_close+0x6a>
		if (dev->dev_close)
  801dcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dcf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801dd2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	74 0b                	je     801de6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801ddb:	83 ec 0c             	sub    $0xc,%esp
  801dde:	56                   	push   %esi
  801ddf:	ff d0                	call   *%eax
  801de1:	89 c3                	mov    %eax,%ebx
  801de3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801de6:	83 ec 08             	sub    $0x8,%esp
  801de9:	56                   	push   %esi
  801dea:	6a 00                	push   $0x0
  801dec:	e8 2f f8 ff ff       	call   801620 <sys_page_unmap>
	return r;
  801df1:	83 c4 10             	add    $0x10,%esp
  801df4:	89 d8                	mov    %ebx,%eax
}
  801df6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801df9:	5b                   	pop    %ebx
  801dfa:	5e                   	pop    %esi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    

00801dfd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e06:	50                   	push   %eax
  801e07:	ff 75 08             	pushl  0x8(%ebp)
  801e0a:	e8 c1 fe ff ff       	call   801cd0 <fd_lookup>
  801e0f:	83 c4 08             	add    $0x8,%esp
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 10                	js     801e26 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801e16:	83 ec 08             	sub    $0x8,%esp
  801e19:	6a 01                	push   $0x1
  801e1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1e:	e8 59 ff ff ff       	call   801d7c <fd_close>
  801e23:	83 c4 10             	add    $0x10,%esp
}
  801e26:	c9                   	leave  
  801e27:	c3                   	ret    

00801e28 <close_all>:

void
close_all(void)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
  801e2b:	53                   	push   %ebx
  801e2c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801e2f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801e34:	83 ec 0c             	sub    $0xc,%esp
  801e37:	53                   	push   %ebx
  801e38:	e8 c0 ff ff ff       	call   801dfd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801e3d:	83 c3 01             	add    $0x1,%ebx
  801e40:	83 c4 10             	add    $0x10,%esp
  801e43:	83 fb 20             	cmp    $0x20,%ebx
  801e46:	75 ec                	jne    801e34 <close_all+0xc>
		close(i);
}
  801e48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e4b:	c9                   	leave  
  801e4c:	c3                   	ret    

00801e4d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	57                   	push   %edi
  801e51:	56                   	push   %esi
  801e52:	53                   	push   %ebx
  801e53:	83 ec 2c             	sub    $0x2c,%esp
  801e56:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e59:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e5c:	50                   	push   %eax
  801e5d:	ff 75 08             	pushl  0x8(%ebp)
  801e60:	e8 6b fe ff ff       	call   801cd0 <fd_lookup>
  801e65:	83 c4 08             	add    $0x8,%esp
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	0f 88 c1 00 00 00    	js     801f31 <dup+0xe4>
		return r;
	close(newfdnum);
  801e70:	83 ec 0c             	sub    $0xc,%esp
  801e73:	56                   	push   %esi
  801e74:	e8 84 ff ff ff       	call   801dfd <close>

	newfd = INDEX2FD(newfdnum);
  801e79:	89 f3                	mov    %esi,%ebx
  801e7b:	c1 e3 0c             	shl    $0xc,%ebx
  801e7e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801e84:	83 c4 04             	add    $0x4,%esp
  801e87:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e8a:	e8 db fd ff ff       	call   801c6a <fd2data>
  801e8f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801e91:	89 1c 24             	mov    %ebx,(%esp)
  801e94:	e8 d1 fd ff ff       	call   801c6a <fd2data>
  801e99:	83 c4 10             	add    $0x10,%esp
  801e9c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e9f:	89 f8                	mov    %edi,%eax
  801ea1:	c1 e8 16             	shr    $0x16,%eax
  801ea4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801eab:	a8 01                	test   $0x1,%al
  801ead:	74 37                	je     801ee6 <dup+0x99>
  801eaf:	89 f8                	mov    %edi,%eax
  801eb1:	c1 e8 0c             	shr    $0xc,%eax
  801eb4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ebb:	f6 c2 01             	test   $0x1,%dl
  801ebe:	74 26                	je     801ee6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ec0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ec7:	83 ec 0c             	sub    $0xc,%esp
  801eca:	25 07 0e 00 00       	and    $0xe07,%eax
  801ecf:	50                   	push   %eax
  801ed0:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ed3:	6a 00                	push   $0x0
  801ed5:	57                   	push   %edi
  801ed6:	6a 00                	push   $0x0
  801ed8:	e8 01 f7 ff ff       	call   8015de <sys_page_map>
  801edd:	89 c7                	mov    %eax,%edi
  801edf:	83 c4 20             	add    $0x20,%esp
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	78 2e                	js     801f14 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ee6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801ee9:	89 d0                	mov    %edx,%eax
  801eeb:	c1 e8 0c             	shr    $0xc,%eax
  801eee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ef5:	83 ec 0c             	sub    $0xc,%esp
  801ef8:	25 07 0e 00 00       	and    $0xe07,%eax
  801efd:	50                   	push   %eax
  801efe:	53                   	push   %ebx
  801eff:	6a 00                	push   $0x0
  801f01:	52                   	push   %edx
  801f02:	6a 00                	push   $0x0
  801f04:	e8 d5 f6 ff ff       	call   8015de <sys_page_map>
  801f09:	89 c7                	mov    %eax,%edi
  801f0b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801f0e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801f10:	85 ff                	test   %edi,%edi
  801f12:	79 1d                	jns    801f31 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801f14:	83 ec 08             	sub    $0x8,%esp
  801f17:	53                   	push   %ebx
  801f18:	6a 00                	push   $0x0
  801f1a:	e8 01 f7 ff ff       	call   801620 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801f1f:	83 c4 08             	add    $0x8,%esp
  801f22:	ff 75 d4             	pushl  -0x2c(%ebp)
  801f25:	6a 00                	push   $0x0
  801f27:	e8 f4 f6 ff ff       	call   801620 <sys_page_unmap>
	return r;
  801f2c:	83 c4 10             	add    $0x10,%esp
  801f2f:	89 f8                	mov    %edi,%eax
}
  801f31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f34:	5b                   	pop    %ebx
  801f35:	5e                   	pop    %esi
  801f36:	5f                   	pop    %edi
  801f37:	5d                   	pop    %ebp
  801f38:	c3                   	ret    

00801f39 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801f39:	55                   	push   %ebp
  801f3a:	89 e5                	mov    %esp,%ebp
  801f3c:	53                   	push   %ebx
  801f3d:	83 ec 14             	sub    $0x14,%esp
  801f40:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f43:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f46:	50                   	push   %eax
  801f47:	53                   	push   %ebx
  801f48:	e8 83 fd ff ff       	call   801cd0 <fd_lookup>
  801f4d:	83 c4 08             	add    $0x8,%esp
  801f50:	89 c2                	mov    %eax,%edx
  801f52:	85 c0                	test   %eax,%eax
  801f54:	78 70                	js     801fc6 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f56:	83 ec 08             	sub    $0x8,%esp
  801f59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5c:	50                   	push   %eax
  801f5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f60:	ff 30                	pushl  (%eax)
  801f62:	e8 bf fd ff ff       	call   801d26 <dev_lookup>
  801f67:	83 c4 10             	add    $0x10,%esp
  801f6a:	85 c0                	test   %eax,%eax
  801f6c:	78 4f                	js     801fbd <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f6e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f71:	8b 42 08             	mov    0x8(%edx),%eax
  801f74:	83 e0 03             	and    $0x3,%eax
  801f77:	83 f8 01             	cmp    $0x1,%eax
  801f7a:	75 24                	jne    801fa0 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f7c:	a1 24 54 80 00       	mov    0x805424,%eax
  801f81:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801f87:	83 ec 04             	sub    $0x4,%esp
  801f8a:	53                   	push   %ebx
  801f8b:	50                   	push   %eax
  801f8c:	68 d9 39 80 00       	push   $0x8039d9
  801f91:	e8 8a eb ff ff       	call   800b20 <cprintf>
		return -E_INVAL;
  801f96:	83 c4 10             	add    $0x10,%esp
  801f99:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f9e:	eb 26                	jmp    801fc6 <read+0x8d>
	}
	if (!dev->dev_read)
  801fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa3:	8b 40 08             	mov    0x8(%eax),%eax
  801fa6:	85 c0                	test   %eax,%eax
  801fa8:	74 17                	je     801fc1 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801faa:	83 ec 04             	sub    $0x4,%esp
  801fad:	ff 75 10             	pushl  0x10(%ebp)
  801fb0:	ff 75 0c             	pushl  0xc(%ebp)
  801fb3:	52                   	push   %edx
  801fb4:	ff d0                	call   *%eax
  801fb6:	89 c2                	mov    %eax,%edx
  801fb8:	83 c4 10             	add    $0x10,%esp
  801fbb:	eb 09                	jmp    801fc6 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fbd:	89 c2                	mov    %eax,%edx
  801fbf:	eb 05                	jmp    801fc6 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801fc1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801fc6:	89 d0                	mov    %edx,%eax
  801fc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fcb:	c9                   	leave  
  801fcc:	c3                   	ret    

00801fcd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	57                   	push   %edi
  801fd1:	56                   	push   %esi
  801fd2:	53                   	push   %ebx
  801fd3:	83 ec 0c             	sub    $0xc,%esp
  801fd6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fd9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fdc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fe1:	eb 21                	jmp    802004 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801fe3:	83 ec 04             	sub    $0x4,%esp
  801fe6:	89 f0                	mov    %esi,%eax
  801fe8:	29 d8                	sub    %ebx,%eax
  801fea:	50                   	push   %eax
  801feb:	89 d8                	mov    %ebx,%eax
  801fed:	03 45 0c             	add    0xc(%ebp),%eax
  801ff0:	50                   	push   %eax
  801ff1:	57                   	push   %edi
  801ff2:	e8 42 ff ff ff       	call   801f39 <read>
		if (m < 0)
  801ff7:	83 c4 10             	add    $0x10,%esp
  801ffa:	85 c0                	test   %eax,%eax
  801ffc:	78 10                	js     80200e <readn+0x41>
			return m;
		if (m == 0)
  801ffe:	85 c0                	test   %eax,%eax
  802000:	74 0a                	je     80200c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802002:	01 c3                	add    %eax,%ebx
  802004:	39 f3                	cmp    %esi,%ebx
  802006:	72 db                	jb     801fe3 <readn+0x16>
  802008:	89 d8                	mov    %ebx,%eax
  80200a:	eb 02                	jmp    80200e <readn+0x41>
  80200c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80200e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802011:	5b                   	pop    %ebx
  802012:	5e                   	pop    %esi
  802013:	5f                   	pop    %edi
  802014:	5d                   	pop    %ebp
  802015:	c3                   	ret    

00802016 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	53                   	push   %ebx
  80201a:	83 ec 14             	sub    $0x14,%esp
  80201d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802020:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802023:	50                   	push   %eax
  802024:	53                   	push   %ebx
  802025:	e8 a6 fc ff ff       	call   801cd0 <fd_lookup>
  80202a:	83 c4 08             	add    $0x8,%esp
  80202d:	89 c2                	mov    %eax,%edx
  80202f:	85 c0                	test   %eax,%eax
  802031:	78 6b                	js     80209e <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802033:	83 ec 08             	sub    $0x8,%esp
  802036:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802039:	50                   	push   %eax
  80203a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80203d:	ff 30                	pushl  (%eax)
  80203f:	e8 e2 fc ff ff       	call   801d26 <dev_lookup>
  802044:	83 c4 10             	add    $0x10,%esp
  802047:	85 c0                	test   %eax,%eax
  802049:	78 4a                	js     802095 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80204b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80204e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802052:	75 24                	jne    802078 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802054:	a1 24 54 80 00       	mov    0x805424,%eax
  802059:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80205f:	83 ec 04             	sub    $0x4,%esp
  802062:	53                   	push   %ebx
  802063:	50                   	push   %eax
  802064:	68 f5 39 80 00       	push   $0x8039f5
  802069:	e8 b2 ea ff ff       	call   800b20 <cprintf>
		return -E_INVAL;
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802076:	eb 26                	jmp    80209e <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802078:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80207b:	8b 52 0c             	mov    0xc(%edx),%edx
  80207e:	85 d2                	test   %edx,%edx
  802080:	74 17                	je     802099 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802082:	83 ec 04             	sub    $0x4,%esp
  802085:	ff 75 10             	pushl  0x10(%ebp)
  802088:	ff 75 0c             	pushl  0xc(%ebp)
  80208b:	50                   	push   %eax
  80208c:	ff d2                	call   *%edx
  80208e:	89 c2                	mov    %eax,%edx
  802090:	83 c4 10             	add    $0x10,%esp
  802093:	eb 09                	jmp    80209e <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802095:	89 c2                	mov    %eax,%edx
  802097:	eb 05                	jmp    80209e <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802099:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80209e:	89 d0                	mov    %edx,%eax
  8020a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020a3:	c9                   	leave  
  8020a4:	c3                   	ret    

008020a5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8020a5:	55                   	push   %ebp
  8020a6:	89 e5                	mov    %esp,%ebp
  8020a8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020ab:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8020ae:	50                   	push   %eax
  8020af:	ff 75 08             	pushl  0x8(%ebp)
  8020b2:	e8 19 fc ff ff       	call   801cd0 <fd_lookup>
  8020b7:	83 c4 08             	add    $0x8,%esp
  8020ba:	85 c0                	test   %eax,%eax
  8020bc:	78 0e                	js     8020cc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8020be:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8020c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020c4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8020c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020cc:	c9                   	leave  
  8020cd:	c3                   	ret    

008020ce <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8020ce:	55                   	push   %ebp
  8020cf:	89 e5                	mov    %esp,%ebp
  8020d1:	53                   	push   %ebx
  8020d2:	83 ec 14             	sub    $0x14,%esp
  8020d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020db:	50                   	push   %eax
  8020dc:	53                   	push   %ebx
  8020dd:	e8 ee fb ff ff       	call   801cd0 <fd_lookup>
  8020e2:	83 c4 08             	add    $0x8,%esp
  8020e5:	89 c2                	mov    %eax,%edx
  8020e7:	85 c0                	test   %eax,%eax
  8020e9:	78 68                	js     802153 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020eb:	83 ec 08             	sub    $0x8,%esp
  8020ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f1:	50                   	push   %eax
  8020f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020f5:	ff 30                	pushl  (%eax)
  8020f7:	e8 2a fc ff ff       	call   801d26 <dev_lookup>
  8020fc:	83 c4 10             	add    $0x10,%esp
  8020ff:	85 c0                	test   %eax,%eax
  802101:	78 47                	js     80214a <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802103:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802106:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80210a:	75 24                	jne    802130 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80210c:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802111:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802117:	83 ec 04             	sub    $0x4,%esp
  80211a:	53                   	push   %ebx
  80211b:	50                   	push   %eax
  80211c:	68 b8 39 80 00       	push   $0x8039b8
  802121:	e8 fa e9 ff ff       	call   800b20 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802126:	83 c4 10             	add    $0x10,%esp
  802129:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80212e:	eb 23                	jmp    802153 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  802130:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802133:	8b 52 18             	mov    0x18(%edx),%edx
  802136:	85 d2                	test   %edx,%edx
  802138:	74 14                	je     80214e <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80213a:	83 ec 08             	sub    $0x8,%esp
  80213d:	ff 75 0c             	pushl  0xc(%ebp)
  802140:	50                   	push   %eax
  802141:	ff d2                	call   *%edx
  802143:	89 c2                	mov    %eax,%edx
  802145:	83 c4 10             	add    $0x10,%esp
  802148:	eb 09                	jmp    802153 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80214a:	89 c2                	mov    %eax,%edx
  80214c:	eb 05                	jmp    802153 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80214e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802153:	89 d0                	mov    %edx,%eax
  802155:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802158:	c9                   	leave  
  802159:	c3                   	ret    

0080215a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80215a:	55                   	push   %ebp
  80215b:	89 e5                	mov    %esp,%ebp
  80215d:	53                   	push   %ebx
  80215e:	83 ec 14             	sub    $0x14,%esp
  802161:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802164:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802167:	50                   	push   %eax
  802168:	ff 75 08             	pushl  0x8(%ebp)
  80216b:	e8 60 fb ff ff       	call   801cd0 <fd_lookup>
  802170:	83 c4 08             	add    $0x8,%esp
  802173:	89 c2                	mov    %eax,%edx
  802175:	85 c0                	test   %eax,%eax
  802177:	78 58                	js     8021d1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802179:	83 ec 08             	sub    $0x8,%esp
  80217c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80217f:	50                   	push   %eax
  802180:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802183:	ff 30                	pushl  (%eax)
  802185:	e8 9c fb ff ff       	call   801d26 <dev_lookup>
  80218a:	83 c4 10             	add    $0x10,%esp
  80218d:	85 c0                	test   %eax,%eax
  80218f:	78 37                	js     8021c8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802191:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802194:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802198:	74 32                	je     8021cc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80219a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80219d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8021a4:	00 00 00 
	stat->st_isdir = 0;
  8021a7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021ae:	00 00 00 
	stat->st_dev = dev;
  8021b1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8021b7:	83 ec 08             	sub    $0x8,%esp
  8021ba:	53                   	push   %ebx
  8021bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8021be:	ff 50 14             	call   *0x14(%eax)
  8021c1:	89 c2                	mov    %eax,%edx
  8021c3:	83 c4 10             	add    $0x10,%esp
  8021c6:	eb 09                	jmp    8021d1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021c8:	89 c2                	mov    %eax,%edx
  8021ca:	eb 05                	jmp    8021d1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8021cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8021d1:	89 d0                	mov    %edx,%eax
  8021d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021d6:	c9                   	leave  
  8021d7:	c3                   	ret    

008021d8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8021d8:	55                   	push   %ebp
  8021d9:	89 e5                	mov    %esp,%ebp
  8021db:	56                   	push   %esi
  8021dc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8021dd:	83 ec 08             	sub    $0x8,%esp
  8021e0:	6a 00                	push   $0x0
  8021e2:	ff 75 08             	pushl  0x8(%ebp)
  8021e5:	e8 e3 01 00 00       	call   8023cd <open>
  8021ea:	89 c3                	mov    %eax,%ebx
  8021ec:	83 c4 10             	add    $0x10,%esp
  8021ef:	85 c0                	test   %eax,%eax
  8021f1:	78 1b                	js     80220e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8021f3:	83 ec 08             	sub    $0x8,%esp
  8021f6:	ff 75 0c             	pushl  0xc(%ebp)
  8021f9:	50                   	push   %eax
  8021fa:	e8 5b ff ff ff       	call   80215a <fstat>
  8021ff:	89 c6                	mov    %eax,%esi
	close(fd);
  802201:	89 1c 24             	mov    %ebx,(%esp)
  802204:	e8 f4 fb ff ff       	call   801dfd <close>
	return r;
  802209:	83 c4 10             	add    $0x10,%esp
  80220c:	89 f0                	mov    %esi,%eax
}
  80220e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802211:	5b                   	pop    %ebx
  802212:	5e                   	pop    %esi
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    

00802215 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	56                   	push   %esi
  802219:	53                   	push   %ebx
  80221a:	89 c6                	mov    %eax,%esi
  80221c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80221e:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802225:	75 12                	jne    802239 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802227:	83 ec 0c             	sub    $0xc,%esp
  80222a:	6a 01                	push   $0x1
  80222c:	e8 5e 0e 00 00       	call   80308f <ipc_find_env>
  802231:	a3 20 54 80 00       	mov    %eax,0x805420
  802236:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802239:	6a 07                	push   $0x7
  80223b:	68 00 60 80 00       	push   $0x806000
  802240:	56                   	push   %esi
  802241:	ff 35 20 54 80 00    	pushl  0x805420
  802247:	e8 e1 0d 00 00       	call   80302d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80224c:	83 c4 0c             	add    $0xc,%esp
  80224f:	6a 00                	push   $0x0
  802251:	53                   	push   %ebx
  802252:	6a 00                	push   $0x0
  802254:	e8 59 0d 00 00       	call   802fb2 <ipc_recv>
}
  802259:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80225c:	5b                   	pop    %ebx
  80225d:	5e                   	pop    %esi
  80225e:	5d                   	pop    %ebp
  80225f:	c3                   	ret    

00802260 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802260:	55                   	push   %ebp
  802261:	89 e5                	mov    %esp,%ebp
  802263:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802266:	8b 45 08             	mov    0x8(%ebp),%eax
  802269:	8b 40 0c             	mov    0xc(%eax),%eax
  80226c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802271:	8b 45 0c             	mov    0xc(%ebp),%eax
  802274:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802279:	ba 00 00 00 00       	mov    $0x0,%edx
  80227e:	b8 02 00 00 00       	mov    $0x2,%eax
  802283:	e8 8d ff ff ff       	call   802215 <fsipc>
}
  802288:	c9                   	leave  
  802289:	c3                   	ret    

0080228a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80228a:	55                   	push   %ebp
  80228b:	89 e5                	mov    %esp,%ebp
  80228d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802290:	8b 45 08             	mov    0x8(%ebp),%eax
  802293:	8b 40 0c             	mov    0xc(%eax),%eax
  802296:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80229b:	ba 00 00 00 00       	mov    $0x0,%edx
  8022a0:	b8 06 00 00 00       	mov    $0x6,%eax
  8022a5:	e8 6b ff ff ff       	call   802215 <fsipc>
}
  8022aa:	c9                   	leave  
  8022ab:	c3                   	ret    

008022ac <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8022ac:	55                   	push   %ebp
  8022ad:	89 e5                	mov    %esp,%ebp
  8022af:	53                   	push   %ebx
  8022b0:	83 ec 04             	sub    $0x4,%esp
  8022b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8022b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8022bc:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8022c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8022c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8022cb:	e8 45 ff ff ff       	call   802215 <fsipc>
  8022d0:	85 c0                	test   %eax,%eax
  8022d2:	78 2c                	js     802300 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8022d4:	83 ec 08             	sub    $0x8,%esp
  8022d7:	68 00 60 80 00       	push   $0x806000
  8022dc:	53                   	push   %ebx
  8022dd:	e8 b6 ee ff ff       	call   801198 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8022e2:	a1 80 60 80 00       	mov    0x806080,%eax
  8022e7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8022ed:	a1 84 60 80 00       	mov    0x806084,%eax
  8022f2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8022f8:	83 c4 10             	add    $0x10,%esp
  8022fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802303:	c9                   	leave  
  802304:	c3                   	ret    

00802305 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802305:	55                   	push   %ebp
  802306:	89 e5                	mov    %esp,%ebp
  802308:	83 ec 0c             	sub    $0xc,%esp
  80230b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80230e:	8b 55 08             	mov    0x8(%ebp),%edx
  802311:	8b 52 0c             	mov    0xc(%edx),%edx
  802314:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80231a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80231f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802324:	0f 47 c2             	cmova  %edx,%eax
  802327:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80232c:	50                   	push   %eax
  80232d:	ff 75 0c             	pushl  0xc(%ebp)
  802330:	68 08 60 80 00       	push   $0x806008
  802335:	e8 f0 ef ff ff       	call   80132a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80233a:	ba 00 00 00 00       	mov    $0x0,%edx
  80233f:	b8 04 00 00 00       	mov    $0x4,%eax
  802344:	e8 cc fe ff ff       	call   802215 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  802349:	c9                   	leave  
  80234a:	c3                   	ret    

0080234b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80234b:	55                   	push   %ebp
  80234c:	89 e5                	mov    %esp,%ebp
  80234e:	56                   	push   %esi
  80234f:	53                   	push   %ebx
  802350:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802353:	8b 45 08             	mov    0x8(%ebp),%eax
  802356:	8b 40 0c             	mov    0xc(%eax),%eax
  802359:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80235e:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802364:	ba 00 00 00 00       	mov    $0x0,%edx
  802369:	b8 03 00 00 00       	mov    $0x3,%eax
  80236e:	e8 a2 fe ff ff       	call   802215 <fsipc>
  802373:	89 c3                	mov    %eax,%ebx
  802375:	85 c0                	test   %eax,%eax
  802377:	78 4b                	js     8023c4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802379:	39 c6                	cmp    %eax,%esi
  80237b:	73 16                	jae    802393 <devfile_read+0x48>
  80237d:	68 24 3a 80 00       	push   $0x803a24
  802382:	68 ef 34 80 00       	push   $0x8034ef
  802387:	6a 7c                	push   $0x7c
  802389:	68 2b 3a 80 00       	push   $0x803a2b
  80238e:	e8 b4 e6 ff ff       	call   800a47 <_panic>
	assert(r <= PGSIZE);
  802393:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802398:	7e 16                	jle    8023b0 <devfile_read+0x65>
  80239a:	68 36 3a 80 00       	push   $0x803a36
  80239f:	68 ef 34 80 00       	push   $0x8034ef
  8023a4:	6a 7d                	push   $0x7d
  8023a6:	68 2b 3a 80 00       	push   $0x803a2b
  8023ab:	e8 97 e6 ff ff       	call   800a47 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8023b0:	83 ec 04             	sub    $0x4,%esp
  8023b3:	50                   	push   %eax
  8023b4:	68 00 60 80 00       	push   $0x806000
  8023b9:	ff 75 0c             	pushl  0xc(%ebp)
  8023bc:	e8 69 ef ff ff       	call   80132a <memmove>
	return r;
  8023c1:	83 c4 10             	add    $0x10,%esp
}
  8023c4:	89 d8                	mov    %ebx,%eax
  8023c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023c9:	5b                   	pop    %ebx
  8023ca:	5e                   	pop    %esi
  8023cb:	5d                   	pop    %ebp
  8023cc:	c3                   	ret    

008023cd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8023cd:	55                   	push   %ebp
  8023ce:	89 e5                	mov    %esp,%ebp
  8023d0:	53                   	push   %ebx
  8023d1:	83 ec 20             	sub    $0x20,%esp
  8023d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8023d7:	53                   	push   %ebx
  8023d8:	e8 82 ed ff ff       	call   80115f <strlen>
  8023dd:	83 c4 10             	add    $0x10,%esp
  8023e0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8023e5:	7f 67                	jg     80244e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8023e7:	83 ec 0c             	sub    $0xc,%esp
  8023ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ed:	50                   	push   %eax
  8023ee:	e8 8e f8 ff ff       	call   801c81 <fd_alloc>
  8023f3:	83 c4 10             	add    $0x10,%esp
		return r;
  8023f6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8023f8:	85 c0                	test   %eax,%eax
  8023fa:	78 57                	js     802453 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8023fc:	83 ec 08             	sub    $0x8,%esp
  8023ff:	53                   	push   %ebx
  802400:	68 00 60 80 00       	push   $0x806000
  802405:	e8 8e ed ff ff       	call   801198 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80240a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80240d:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802412:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802415:	b8 01 00 00 00       	mov    $0x1,%eax
  80241a:	e8 f6 fd ff ff       	call   802215 <fsipc>
  80241f:	89 c3                	mov    %eax,%ebx
  802421:	83 c4 10             	add    $0x10,%esp
  802424:	85 c0                	test   %eax,%eax
  802426:	79 14                	jns    80243c <open+0x6f>
		fd_close(fd, 0);
  802428:	83 ec 08             	sub    $0x8,%esp
  80242b:	6a 00                	push   $0x0
  80242d:	ff 75 f4             	pushl  -0xc(%ebp)
  802430:	e8 47 f9 ff ff       	call   801d7c <fd_close>
		return r;
  802435:	83 c4 10             	add    $0x10,%esp
  802438:	89 da                	mov    %ebx,%edx
  80243a:	eb 17                	jmp    802453 <open+0x86>
	}

	return fd2num(fd);
  80243c:	83 ec 0c             	sub    $0xc,%esp
  80243f:	ff 75 f4             	pushl  -0xc(%ebp)
  802442:	e8 13 f8 ff ff       	call   801c5a <fd2num>
  802447:	89 c2                	mov    %eax,%edx
  802449:	83 c4 10             	add    $0x10,%esp
  80244c:	eb 05                	jmp    802453 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80244e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802453:	89 d0                	mov    %edx,%eax
  802455:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802458:	c9                   	leave  
  802459:	c3                   	ret    

0080245a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80245a:	55                   	push   %ebp
  80245b:	89 e5                	mov    %esp,%ebp
  80245d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802460:	ba 00 00 00 00       	mov    $0x0,%edx
  802465:	b8 08 00 00 00       	mov    $0x8,%eax
  80246a:	e8 a6 fd ff ff       	call   802215 <fsipc>
}
  80246f:	c9                   	leave  
  802470:	c3                   	ret    

00802471 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802471:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802475:	7e 37                	jle    8024ae <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  802477:	55                   	push   %ebp
  802478:	89 e5                	mov    %esp,%ebp
  80247a:	53                   	push   %ebx
  80247b:	83 ec 08             	sub    $0x8,%esp
  80247e:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  802480:	ff 70 04             	pushl  0x4(%eax)
  802483:	8d 40 10             	lea    0x10(%eax),%eax
  802486:	50                   	push   %eax
  802487:	ff 33                	pushl  (%ebx)
  802489:	e8 88 fb ff ff       	call   802016 <write>
		if (result > 0)
  80248e:	83 c4 10             	add    $0x10,%esp
  802491:	85 c0                	test   %eax,%eax
  802493:	7e 03                	jle    802498 <writebuf+0x27>
			b->result += result;
  802495:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802498:	3b 43 04             	cmp    0x4(%ebx),%eax
  80249b:	74 0d                	je     8024aa <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80249d:	85 c0                	test   %eax,%eax
  80249f:	ba 00 00 00 00       	mov    $0x0,%edx
  8024a4:	0f 4f c2             	cmovg  %edx,%eax
  8024a7:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8024aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024ad:	c9                   	leave  
  8024ae:	f3 c3                	repz ret 

008024b0 <putch>:

static void
putch(int ch, void *thunk)
{
  8024b0:	55                   	push   %ebp
  8024b1:	89 e5                	mov    %esp,%ebp
  8024b3:	53                   	push   %ebx
  8024b4:	83 ec 04             	sub    $0x4,%esp
  8024b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8024ba:	8b 53 04             	mov    0x4(%ebx),%edx
  8024bd:	8d 42 01             	lea    0x1(%edx),%eax
  8024c0:	89 43 04             	mov    %eax,0x4(%ebx)
  8024c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024c6:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8024ca:	3d 00 01 00 00       	cmp    $0x100,%eax
  8024cf:	75 0e                	jne    8024df <putch+0x2f>
		writebuf(b);
  8024d1:	89 d8                	mov    %ebx,%eax
  8024d3:	e8 99 ff ff ff       	call   802471 <writebuf>
		b->idx = 0;
  8024d8:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8024df:	83 c4 04             	add    $0x4,%esp
  8024e2:	5b                   	pop    %ebx
  8024e3:	5d                   	pop    %ebp
  8024e4:	c3                   	ret    

008024e5 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8024e5:	55                   	push   %ebp
  8024e6:	89 e5                	mov    %esp,%ebp
  8024e8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8024ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f1:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8024f7:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8024fe:	00 00 00 
	b.result = 0;
  802501:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802508:	00 00 00 
	b.error = 1;
  80250b:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802512:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802515:	ff 75 10             	pushl  0x10(%ebp)
  802518:	ff 75 0c             	pushl  0xc(%ebp)
  80251b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802521:	50                   	push   %eax
  802522:	68 b0 24 80 00       	push   $0x8024b0
  802527:	e8 2b e7 ff ff       	call   800c57 <vprintfmt>
	if (b.idx > 0)
  80252c:	83 c4 10             	add    $0x10,%esp
  80252f:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802536:	7e 0b                	jle    802543 <vfprintf+0x5e>
		writebuf(&b);
  802538:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80253e:	e8 2e ff ff ff       	call   802471 <writebuf>

	return (b.result ? b.result : b.error);
  802543:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802549:	85 c0                	test   %eax,%eax
  80254b:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  802552:	c9                   	leave  
  802553:	c3                   	ret    

00802554 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802554:	55                   	push   %ebp
  802555:	89 e5                	mov    %esp,%ebp
  802557:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80255a:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80255d:	50                   	push   %eax
  80255e:	ff 75 0c             	pushl  0xc(%ebp)
  802561:	ff 75 08             	pushl  0x8(%ebp)
  802564:	e8 7c ff ff ff       	call   8024e5 <vfprintf>
	va_end(ap);

	return cnt;
}
  802569:	c9                   	leave  
  80256a:	c3                   	ret    

0080256b <printf>:

int
printf(const char *fmt, ...)
{
  80256b:	55                   	push   %ebp
  80256c:	89 e5                	mov    %esp,%ebp
  80256e:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802571:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802574:	50                   	push   %eax
  802575:	ff 75 08             	pushl  0x8(%ebp)
  802578:	6a 01                	push   $0x1
  80257a:	e8 66 ff ff ff       	call   8024e5 <vfprintf>
	va_end(ap);

	return cnt;
}
  80257f:	c9                   	leave  
  802580:	c3                   	ret    

00802581 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802581:	55                   	push   %ebp
  802582:	89 e5                	mov    %esp,%ebp
  802584:	57                   	push   %edi
  802585:	56                   	push   %esi
  802586:	53                   	push   %ebx
  802587:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80258d:	6a 00                	push   $0x0
  80258f:	ff 75 08             	pushl  0x8(%ebp)
  802592:	e8 36 fe ff ff       	call   8023cd <open>
  802597:	89 c7                	mov    %eax,%edi
  802599:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80259f:	83 c4 10             	add    $0x10,%esp
  8025a2:	85 c0                	test   %eax,%eax
  8025a4:	0f 88 8c 04 00 00    	js     802a36 <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8025aa:	83 ec 04             	sub    $0x4,%esp
  8025ad:	68 00 02 00 00       	push   $0x200
  8025b2:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8025b8:	50                   	push   %eax
  8025b9:	57                   	push   %edi
  8025ba:	e8 0e fa ff ff       	call   801fcd <readn>
  8025bf:	83 c4 10             	add    $0x10,%esp
  8025c2:	3d 00 02 00 00       	cmp    $0x200,%eax
  8025c7:	75 0c                	jne    8025d5 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8025c9:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8025d0:	45 4c 46 
  8025d3:	74 33                	je     802608 <spawn+0x87>
		close(fd);
  8025d5:	83 ec 0c             	sub    $0xc,%esp
  8025d8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8025de:	e8 1a f8 ff ff       	call   801dfd <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8025e3:	83 c4 0c             	add    $0xc,%esp
  8025e6:	68 7f 45 4c 46       	push   $0x464c457f
  8025eb:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8025f1:	68 42 3a 80 00       	push   $0x803a42
  8025f6:	e8 25 e5 ff ff       	call   800b20 <cprintf>
		return -E_NOT_EXEC;
  8025fb:	83 c4 10             	add    $0x10,%esp
  8025fe:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  802603:	e9 e1 04 00 00       	jmp    802ae9 <spawn+0x568>
  802608:	b8 07 00 00 00       	mov    $0x7,%eax
  80260d:	cd 30                	int    $0x30
  80260f:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802615:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80261b:	85 c0                	test   %eax,%eax
  80261d:	0f 88 1e 04 00 00    	js     802a41 <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802623:	89 c6                	mov    %eax,%esi
  802625:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80262b:	69 f6 d8 00 00 00    	imul   $0xd8,%esi,%esi
  802631:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802637:	81 c6 59 00 c0 ee    	add    $0xeec00059,%esi
  80263d:	b9 11 00 00 00       	mov    $0x11,%ecx
  802642:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802644:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80264a:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802650:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802655:	be 00 00 00 00       	mov    $0x0,%esi
  80265a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80265d:	eb 13                	jmp    802672 <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80265f:	83 ec 0c             	sub    $0xc,%esp
  802662:	50                   	push   %eax
  802663:	e8 f7 ea ff ff       	call   80115f <strlen>
  802668:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80266c:	83 c3 01             	add    $0x1,%ebx
  80266f:	83 c4 10             	add    $0x10,%esp
  802672:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802679:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80267c:	85 c0                	test   %eax,%eax
  80267e:	75 df                	jne    80265f <spawn+0xde>
  802680:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802686:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80268c:	bf 00 10 40 00       	mov    $0x401000,%edi
  802691:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802693:	89 fa                	mov    %edi,%edx
  802695:	83 e2 fc             	and    $0xfffffffc,%edx
  802698:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80269f:	29 c2                	sub    %eax,%edx
  8026a1:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8026a7:	8d 42 f8             	lea    -0x8(%edx),%eax
  8026aa:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8026af:	0f 86 a2 03 00 00    	jbe    802a57 <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8026b5:	83 ec 04             	sub    $0x4,%esp
  8026b8:	6a 07                	push   $0x7
  8026ba:	68 00 00 40 00       	push   $0x400000
  8026bf:	6a 00                	push   $0x0
  8026c1:	e8 d5 ee ff ff       	call   80159b <sys_page_alloc>
  8026c6:	83 c4 10             	add    $0x10,%esp
  8026c9:	85 c0                	test   %eax,%eax
  8026cb:	0f 88 90 03 00 00    	js     802a61 <spawn+0x4e0>
  8026d1:	be 00 00 00 00       	mov    $0x0,%esi
  8026d6:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8026dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8026df:	eb 30                	jmp    802711 <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8026e1:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8026e7:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8026ed:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8026f0:	83 ec 08             	sub    $0x8,%esp
  8026f3:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8026f6:	57                   	push   %edi
  8026f7:	e8 9c ea ff ff       	call   801198 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8026fc:	83 c4 04             	add    $0x4,%esp
  8026ff:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802702:	e8 58 ea ff ff       	call   80115f <strlen>
  802707:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80270b:	83 c6 01             	add    $0x1,%esi
  80270e:	83 c4 10             	add    $0x10,%esp
  802711:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802717:	7f c8                	jg     8026e1 <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802719:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80271f:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  802725:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80272c:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802732:	74 19                	je     80274d <spawn+0x1cc>
  802734:	68 cc 3a 80 00       	push   $0x803acc
  802739:	68 ef 34 80 00       	push   $0x8034ef
  80273e:	68 f2 00 00 00       	push   $0xf2
  802743:	68 5c 3a 80 00       	push   $0x803a5c
  802748:	e8 fa e2 ff ff       	call   800a47 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80274d:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  802753:	89 f8                	mov    %edi,%eax
  802755:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80275a:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80275d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802763:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802766:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  80276c:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802772:	83 ec 0c             	sub    $0xc,%esp
  802775:	6a 07                	push   $0x7
  802777:	68 00 d0 bf ee       	push   $0xeebfd000
  80277c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802782:	68 00 00 40 00       	push   $0x400000
  802787:	6a 00                	push   $0x0
  802789:	e8 50 ee ff ff       	call   8015de <sys_page_map>
  80278e:	89 c3                	mov    %eax,%ebx
  802790:	83 c4 20             	add    $0x20,%esp
  802793:	85 c0                	test   %eax,%eax
  802795:	0f 88 3c 03 00 00    	js     802ad7 <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80279b:	83 ec 08             	sub    $0x8,%esp
  80279e:	68 00 00 40 00       	push   $0x400000
  8027a3:	6a 00                	push   $0x0
  8027a5:	e8 76 ee ff ff       	call   801620 <sys_page_unmap>
  8027aa:	89 c3                	mov    %eax,%ebx
  8027ac:	83 c4 10             	add    $0x10,%esp
  8027af:	85 c0                	test   %eax,%eax
  8027b1:	0f 88 20 03 00 00    	js     802ad7 <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8027b7:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8027bd:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8027c4:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8027ca:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8027d1:	00 00 00 
  8027d4:	e9 88 01 00 00       	jmp    802961 <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  8027d9:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8027df:	83 38 01             	cmpl   $0x1,(%eax)
  8027e2:	0f 85 6b 01 00 00    	jne    802953 <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8027e8:	89 c2                	mov    %eax,%edx
  8027ea:	8b 40 18             	mov    0x18(%eax),%eax
  8027ed:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8027f3:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8027f6:	83 f8 01             	cmp    $0x1,%eax
  8027f9:	19 c0                	sbb    %eax,%eax
  8027fb:	83 e0 fe             	and    $0xfffffffe,%eax
  8027fe:	83 c0 07             	add    $0x7,%eax
  802801:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802807:	89 d0                	mov    %edx,%eax
  802809:	8b 7a 04             	mov    0x4(%edx),%edi
  80280c:	89 f9                	mov    %edi,%ecx
  80280e:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  802814:	8b 7a 10             	mov    0x10(%edx),%edi
  802817:	8b 52 14             	mov    0x14(%edx),%edx
  80281a:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  802820:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802823:	89 f0                	mov    %esi,%eax
  802825:	25 ff 0f 00 00       	and    $0xfff,%eax
  80282a:	74 14                	je     802840 <spawn+0x2bf>
		va -= i;
  80282c:	29 c6                	sub    %eax,%esi
		memsz += i;
  80282e:	01 c2                	add    %eax,%edx
  802830:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  802836:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  802838:	29 c1                	sub    %eax,%ecx
  80283a:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802840:	bb 00 00 00 00       	mov    $0x0,%ebx
  802845:	e9 f7 00 00 00       	jmp    802941 <spawn+0x3c0>
		if (i >= filesz) {
  80284a:	39 fb                	cmp    %edi,%ebx
  80284c:	72 27                	jb     802875 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80284e:	83 ec 04             	sub    $0x4,%esp
  802851:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802857:	56                   	push   %esi
  802858:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80285e:	e8 38 ed ff ff       	call   80159b <sys_page_alloc>
  802863:	83 c4 10             	add    $0x10,%esp
  802866:	85 c0                	test   %eax,%eax
  802868:	0f 89 c7 00 00 00    	jns    802935 <spawn+0x3b4>
  80286e:	89 c3                	mov    %eax,%ebx
  802870:	e9 fd 01 00 00       	jmp    802a72 <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802875:	83 ec 04             	sub    $0x4,%esp
  802878:	6a 07                	push   $0x7
  80287a:	68 00 00 40 00       	push   $0x400000
  80287f:	6a 00                	push   $0x0
  802881:	e8 15 ed ff ff       	call   80159b <sys_page_alloc>
  802886:	83 c4 10             	add    $0x10,%esp
  802889:	85 c0                	test   %eax,%eax
  80288b:	0f 88 d7 01 00 00    	js     802a68 <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802891:	83 ec 08             	sub    $0x8,%esp
  802894:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80289a:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8028a0:	50                   	push   %eax
  8028a1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028a7:	e8 f9 f7 ff ff       	call   8020a5 <seek>
  8028ac:	83 c4 10             	add    $0x10,%esp
  8028af:	85 c0                	test   %eax,%eax
  8028b1:	0f 88 b5 01 00 00    	js     802a6c <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8028b7:	83 ec 04             	sub    $0x4,%esp
  8028ba:	89 f8                	mov    %edi,%eax
  8028bc:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8028c2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8028c7:	ba 00 10 00 00       	mov    $0x1000,%edx
  8028cc:	0f 47 c2             	cmova  %edx,%eax
  8028cf:	50                   	push   %eax
  8028d0:	68 00 00 40 00       	push   $0x400000
  8028d5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028db:	e8 ed f6 ff ff       	call   801fcd <readn>
  8028e0:	83 c4 10             	add    $0x10,%esp
  8028e3:	85 c0                	test   %eax,%eax
  8028e5:	0f 88 85 01 00 00    	js     802a70 <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8028eb:	83 ec 0c             	sub    $0xc,%esp
  8028ee:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8028f4:	56                   	push   %esi
  8028f5:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8028fb:	68 00 00 40 00       	push   $0x400000
  802900:	6a 00                	push   $0x0
  802902:	e8 d7 ec ff ff       	call   8015de <sys_page_map>
  802907:	83 c4 20             	add    $0x20,%esp
  80290a:	85 c0                	test   %eax,%eax
  80290c:	79 15                	jns    802923 <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  80290e:	50                   	push   %eax
  80290f:	68 68 3a 80 00       	push   $0x803a68
  802914:	68 25 01 00 00       	push   $0x125
  802919:	68 5c 3a 80 00       	push   $0x803a5c
  80291e:	e8 24 e1 ff ff       	call   800a47 <_panic>
			sys_page_unmap(0, UTEMP);
  802923:	83 ec 08             	sub    $0x8,%esp
  802926:	68 00 00 40 00       	push   $0x400000
  80292b:	6a 00                	push   $0x0
  80292d:	e8 ee ec ff ff       	call   801620 <sys_page_unmap>
  802932:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802935:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80293b:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802941:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802947:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  80294d:	0f 82 f7 fe ff ff    	jb     80284a <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802953:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  80295a:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802961:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802968:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  80296e:	0f 8c 65 fe ff ff    	jl     8027d9 <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802974:	83 ec 0c             	sub    $0xc,%esp
  802977:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80297d:	e8 7b f4 ff ff       	call   801dfd <close>
  802982:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802985:	bb 00 00 00 00       	mov    $0x0,%ebx
  80298a:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  802990:	89 d8                	mov    %ebx,%eax
  802992:	c1 e8 16             	shr    $0x16,%eax
  802995:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80299c:	a8 01                	test   $0x1,%al
  80299e:	74 42                	je     8029e2 <spawn+0x461>
  8029a0:	89 d8                	mov    %ebx,%eax
  8029a2:	c1 e8 0c             	shr    $0xc,%eax
  8029a5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8029ac:	f6 c2 01             	test   $0x1,%dl
  8029af:	74 31                	je     8029e2 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  8029b1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  8029b8:	f6 c6 04             	test   $0x4,%dh
  8029bb:	74 25                	je     8029e2 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  8029bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8029c4:	83 ec 0c             	sub    $0xc,%esp
  8029c7:	25 07 0e 00 00       	and    $0xe07,%eax
  8029cc:	50                   	push   %eax
  8029cd:	53                   	push   %ebx
  8029ce:	56                   	push   %esi
  8029cf:	53                   	push   %ebx
  8029d0:	6a 00                	push   $0x0
  8029d2:	e8 07 ec ff ff       	call   8015de <sys_page_map>
			if (r < 0) {
  8029d7:	83 c4 20             	add    $0x20,%esp
  8029da:	85 c0                	test   %eax,%eax
  8029dc:	0f 88 b1 00 00 00    	js     802a93 <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  8029e2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8029e8:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8029ee:	75 a0                	jne    802990 <spawn+0x40f>
  8029f0:	e9 b3 00 00 00       	jmp    802aa8 <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8029f5:	50                   	push   %eax
  8029f6:	68 85 3a 80 00       	push   $0x803a85
  8029fb:	68 86 00 00 00       	push   $0x86
  802a00:	68 5c 3a 80 00       	push   $0x803a5c
  802a05:	e8 3d e0 ff ff       	call   800a47 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802a0a:	83 ec 08             	sub    $0x8,%esp
  802a0d:	6a 02                	push   $0x2
  802a0f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a15:	e8 48 ec ff ff       	call   801662 <sys_env_set_status>
  802a1a:	83 c4 10             	add    $0x10,%esp
  802a1d:	85 c0                	test   %eax,%eax
  802a1f:	79 2b                	jns    802a4c <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  802a21:	50                   	push   %eax
  802a22:	68 9f 3a 80 00       	push   $0x803a9f
  802a27:	68 89 00 00 00       	push   $0x89
  802a2c:	68 5c 3a 80 00       	push   $0x803a5c
  802a31:	e8 11 e0 ff ff       	call   800a47 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802a36:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802a3c:	e9 a8 00 00 00       	jmp    802ae9 <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802a41:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802a47:	e9 9d 00 00 00       	jmp    802ae9 <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802a4c:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802a52:	e9 92 00 00 00       	jmp    802ae9 <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802a57:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802a5c:	e9 88 00 00 00       	jmp    802ae9 <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802a61:	89 c3                	mov    %eax,%ebx
  802a63:	e9 81 00 00 00       	jmp    802ae9 <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802a68:	89 c3                	mov    %eax,%ebx
  802a6a:	eb 06                	jmp    802a72 <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802a6c:	89 c3                	mov    %eax,%ebx
  802a6e:	eb 02                	jmp    802a72 <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802a70:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802a72:	83 ec 0c             	sub    $0xc,%esp
  802a75:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a7b:	e8 9c ea ff ff       	call   80151c <sys_env_destroy>
	close(fd);
  802a80:	83 c4 04             	add    $0x4,%esp
  802a83:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a89:	e8 6f f3 ff ff       	call   801dfd <close>
	return r;
  802a8e:	83 c4 10             	add    $0x10,%esp
  802a91:	eb 56                	jmp    802ae9 <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802a93:	50                   	push   %eax
  802a94:	68 b6 3a 80 00       	push   $0x803ab6
  802a99:	68 82 00 00 00       	push   $0x82
  802a9e:	68 5c 3a 80 00       	push   $0x803a5c
  802aa3:	e8 9f df ff ff       	call   800a47 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802aa8:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802aaf:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802ab2:	83 ec 08             	sub    $0x8,%esp
  802ab5:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802abb:	50                   	push   %eax
  802abc:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802ac2:	e8 dd eb ff ff       	call   8016a4 <sys_env_set_trapframe>
  802ac7:	83 c4 10             	add    $0x10,%esp
  802aca:	85 c0                	test   %eax,%eax
  802acc:	0f 89 38 ff ff ff    	jns    802a0a <spawn+0x489>
  802ad2:	e9 1e ff ff ff       	jmp    8029f5 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802ad7:	83 ec 08             	sub    $0x8,%esp
  802ada:	68 00 00 40 00       	push   $0x400000
  802adf:	6a 00                	push   $0x0
  802ae1:	e8 3a eb ff ff       	call   801620 <sys_page_unmap>
  802ae6:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802ae9:	89 d8                	mov    %ebx,%eax
  802aeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802aee:	5b                   	pop    %ebx
  802aef:	5e                   	pop    %esi
  802af0:	5f                   	pop    %edi
  802af1:	5d                   	pop    %ebp
  802af2:	c3                   	ret    

00802af3 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802af3:	55                   	push   %ebp
  802af4:	89 e5                	mov    %esp,%ebp
  802af6:	56                   	push   %esi
  802af7:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802af8:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802afb:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802b00:	eb 03                	jmp    802b05 <spawnl+0x12>
		argc++;
  802b02:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802b05:	83 c2 04             	add    $0x4,%edx
  802b08:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802b0c:	75 f4                	jne    802b02 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802b0e:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802b15:	83 e2 f0             	and    $0xfffffff0,%edx
  802b18:	29 d4                	sub    %edx,%esp
  802b1a:	8d 54 24 03          	lea    0x3(%esp),%edx
  802b1e:	c1 ea 02             	shr    $0x2,%edx
  802b21:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802b28:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b2d:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802b34:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802b3b:	00 
  802b3c:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802b3e:	b8 00 00 00 00       	mov    $0x0,%eax
  802b43:	eb 0a                	jmp    802b4f <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802b45:	83 c0 01             	add    $0x1,%eax
  802b48:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802b4c:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802b4f:	39 d0                	cmp    %edx,%eax
  802b51:	75 f2                	jne    802b45 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802b53:	83 ec 08             	sub    $0x8,%esp
  802b56:	56                   	push   %esi
  802b57:	ff 75 08             	pushl  0x8(%ebp)
  802b5a:	e8 22 fa ff ff       	call   802581 <spawn>
}
  802b5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b62:	5b                   	pop    %ebx
  802b63:	5e                   	pop    %esi
  802b64:	5d                   	pop    %ebp
  802b65:	c3                   	ret    

00802b66 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802b66:	55                   	push   %ebp
  802b67:	89 e5                	mov    %esp,%ebp
  802b69:	56                   	push   %esi
  802b6a:	53                   	push   %ebx
  802b6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802b6e:	83 ec 0c             	sub    $0xc,%esp
  802b71:	ff 75 08             	pushl  0x8(%ebp)
  802b74:	e8 f1 f0 ff ff       	call   801c6a <fd2data>
  802b79:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802b7b:	83 c4 08             	add    $0x8,%esp
  802b7e:	68 f4 3a 80 00       	push   $0x803af4
  802b83:	53                   	push   %ebx
  802b84:	e8 0f e6 ff ff       	call   801198 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802b89:	8b 46 04             	mov    0x4(%esi),%eax
  802b8c:	2b 06                	sub    (%esi),%eax
  802b8e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802b94:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802b9b:	00 00 00 
	stat->st_dev = &devpipe;
  802b9e:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802ba5:	40 80 00 
	return 0;
}
  802ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  802bad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802bb0:	5b                   	pop    %ebx
  802bb1:	5e                   	pop    %esi
  802bb2:	5d                   	pop    %ebp
  802bb3:	c3                   	ret    

00802bb4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802bb4:	55                   	push   %ebp
  802bb5:	89 e5                	mov    %esp,%ebp
  802bb7:	53                   	push   %ebx
  802bb8:	83 ec 0c             	sub    $0xc,%esp
  802bbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802bbe:	53                   	push   %ebx
  802bbf:	6a 00                	push   $0x0
  802bc1:	e8 5a ea ff ff       	call   801620 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802bc6:	89 1c 24             	mov    %ebx,(%esp)
  802bc9:	e8 9c f0 ff ff       	call   801c6a <fd2data>
  802bce:	83 c4 08             	add    $0x8,%esp
  802bd1:	50                   	push   %eax
  802bd2:	6a 00                	push   $0x0
  802bd4:	e8 47 ea ff ff       	call   801620 <sys_page_unmap>
}
  802bd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802bdc:	c9                   	leave  
  802bdd:	c3                   	ret    

00802bde <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802bde:	55                   	push   %ebp
  802bdf:	89 e5                	mov    %esp,%ebp
  802be1:	57                   	push   %edi
  802be2:	56                   	push   %esi
  802be3:	53                   	push   %ebx
  802be4:	83 ec 1c             	sub    $0x1c,%esp
  802be7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802bea:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802bec:	a1 24 54 80 00       	mov    0x805424,%eax
  802bf1:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802bf7:	83 ec 0c             	sub    $0xc,%esp
  802bfa:	ff 75 e0             	pushl  -0x20(%ebp)
  802bfd:	e8 d2 04 00 00       	call   8030d4 <pageref>
  802c02:	89 c3                	mov    %eax,%ebx
  802c04:	89 3c 24             	mov    %edi,(%esp)
  802c07:	e8 c8 04 00 00       	call   8030d4 <pageref>
  802c0c:	83 c4 10             	add    $0x10,%esp
  802c0f:	39 c3                	cmp    %eax,%ebx
  802c11:	0f 94 c1             	sete   %cl
  802c14:	0f b6 c9             	movzbl %cl,%ecx
  802c17:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802c1a:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802c20:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  802c26:	39 ce                	cmp    %ecx,%esi
  802c28:	74 1e                	je     802c48 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  802c2a:	39 c3                	cmp    %eax,%ebx
  802c2c:	75 be                	jne    802bec <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802c2e:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  802c34:	ff 75 e4             	pushl  -0x1c(%ebp)
  802c37:	50                   	push   %eax
  802c38:	56                   	push   %esi
  802c39:	68 fb 3a 80 00       	push   $0x803afb
  802c3e:	e8 dd de ff ff       	call   800b20 <cprintf>
  802c43:	83 c4 10             	add    $0x10,%esp
  802c46:	eb a4                	jmp    802bec <_pipeisclosed+0xe>
	}
}
  802c48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802c4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c4e:	5b                   	pop    %ebx
  802c4f:	5e                   	pop    %esi
  802c50:	5f                   	pop    %edi
  802c51:	5d                   	pop    %ebp
  802c52:	c3                   	ret    

00802c53 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802c53:	55                   	push   %ebp
  802c54:	89 e5                	mov    %esp,%ebp
  802c56:	57                   	push   %edi
  802c57:	56                   	push   %esi
  802c58:	53                   	push   %ebx
  802c59:	83 ec 28             	sub    $0x28,%esp
  802c5c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802c5f:	56                   	push   %esi
  802c60:	e8 05 f0 ff ff       	call   801c6a <fd2data>
  802c65:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c67:	83 c4 10             	add    $0x10,%esp
  802c6a:	bf 00 00 00 00       	mov    $0x0,%edi
  802c6f:	eb 4b                	jmp    802cbc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802c71:	89 da                	mov    %ebx,%edx
  802c73:	89 f0                	mov    %esi,%eax
  802c75:	e8 64 ff ff ff       	call   802bde <_pipeisclosed>
  802c7a:	85 c0                	test   %eax,%eax
  802c7c:	75 48                	jne    802cc6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802c7e:	e8 f9 e8 ff ff       	call   80157c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802c83:	8b 43 04             	mov    0x4(%ebx),%eax
  802c86:	8b 0b                	mov    (%ebx),%ecx
  802c88:	8d 51 20             	lea    0x20(%ecx),%edx
  802c8b:	39 d0                	cmp    %edx,%eax
  802c8d:	73 e2                	jae    802c71 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802c8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c92:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802c96:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802c99:	89 c2                	mov    %eax,%edx
  802c9b:	c1 fa 1f             	sar    $0x1f,%edx
  802c9e:	89 d1                	mov    %edx,%ecx
  802ca0:	c1 e9 1b             	shr    $0x1b,%ecx
  802ca3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802ca6:	83 e2 1f             	and    $0x1f,%edx
  802ca9:	29 ca                	sub    %ecx,%edx
  802cab:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802caf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802cb3:	83 c0 01             	add    $0x1,%eax
  802cb6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802cb9:	83 c7 01             	add    $0x1,%edi
  802cbc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802cbf:	75 c2                	jne    802c83 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802cc1:	8b 45 10             	mov    0x10(%ebp),%eax
  802cc4:	eb 05                	jmp    802ccb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802cc6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cce:	5b                   	pop    %ebx
  802ccf:	5e                   	pop    %esi
  802cd0:	5f                   	pop    %edi
  802cd1:	5d                   	pop    %ebp
  802cd2:	c3                   	ret    

00802cd3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802cd3:	55                   	push   %ebp
  802cd4:	89 e5                	mov    %esp,%ebp
  802cd6:	57                   	push   %edi
  802cd7:	56                   	push   %esi
  802cd8:	53                   	push   %ebx
  802cd9:	83 ec 18             	sub    $0x18,%esp
  802cdc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802cdf:	57                   	push   %edi
  802ce0:	e8 85 ef ff ff       	call   801c6a <fd2data>
  802ce5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ce7:	83 c4 10             	add    $0x10,%esp
  802cea:	bb 00 00 00 00       	mov    $0x0,%ebx
  802cef:	eb 3d                	jmp    802d2e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802cf1:	85 db                	test   %ebx,%ebx
  802cf3:	74 04                	je     802cf9 <devpipe_read+0x26>
				return i;
  802cf5:	89 d8                	mov    %ebx,%eax
  802cf7:	eb 44                	jmp    802d3d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802cf9:	89 f2                	mov    %esi,%edx
  802cfb:	89 f8                	mov    %edi,%eax
  802cfd:	e8 dc fe ff ff       	call   802bde <_pipeisclosed>
  802d02:	85 c0                	test   %eax,%eax
  802d04:	75 32                	jne    802d38 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802d06:	e8 71 e8 ff ff       	call   80157c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802d0b:	8b 06                	mov    (%esi),%eax
  802d0d:	3b 46 04             	cmp    0x4(%esi),%eax
  802d10:	74 df                	je     802cf1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802d12:	99                   	cltd   
  802d13:	c1 ea 1b             	shr    $0x1b,%edx
  802d16:	01 d0                	add    %edx,%eax
  802d18:	83 e0 1f             	and    $0x1f,%eax
  802d1b:	29 d0                	sub    %edx,%eax
  802d1d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d25:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802d28:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802d2b:	83 c3 01             	add    $0x1,%ebx
  802d2e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802d31:	75 d8                	jne    802d0b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802d33:	8b 45 10             	mov    0x10(%ebp),%eax
  802d36:	eb 05                	jmp    802d3d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802d38:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802d3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d40:	5b                   	pop    %ebx
  802d41:	5e                   	pop    %esi
  802d42:	5f                   	pop    %edi
  802d43:	5d                   	pop    %ebp
  802d44:	c3                   	ret    

00802d45 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802d45:	55                   	push   %ebp
  802d46:	89 e5                	mov    %esp,%ebp
  802d48:	56                   	push   %esi
  802d49:	53                   	push   %ebx
  802d4a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802d4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d50:	50                   	push   %eax
  802d51:	e8 2b ef ff ff       	call   801c81 <fd_alloc>
  802d56:	83 c4 10             	add    $0x10,%esp
  802d59:	89 c2                	mov    %eax,%edx
  802d5b:	85 c0                	test   %eax,%eax
  802d5d:	0f 88 2c 01 00 00    	js     802e8f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d63:	83 ec 04             	sub    $0x4,%esp
  802d66:	68 07 04 00 00       	push   $0x407
  802d6b:	ff 75 f4             	pushl  -0xc(%ebp)
  802d6e:	6a 00                	push   $0x0
  802d70:	e8 26 e8 ff ff       	call   80159b <sys_page_alloc>
  802d75:	83 c4 10             	add    $0x10,%esp
  802d78:	89 c2                	mov    %eax,%edx
  802d7a:	85 c0                	test   %eax,%eax
  802d7c:	0f 88 0d 01 00 00    	js     802e8f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802d82:	83 ec 0c             	sub    $0xc,%esp
  802d85:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d88:	50                   	push   %eax
  802d89:	e8 f3 ee ff ff       	call   801c81 <fd_alloc>
  802d8e:	89 c3                	mov    %eax,%ebx
  802d90:	83 c4 10             	add    $0x10,%esp
  802d93:	85 c0                	test   %eax,%eax
  802d95:	0f 88 e2 00 00 00    	js     802e7d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d9b:	83 ec 04             	sub    $0x4,%esp
  802d9e:	68 07 04 00 00       	push   $0x407
  802da3:	ff 75 f0             	pushl  -0x10(%ebp)
  802da6:	6a 00                	push   $0x0
  802da8:	e8 ee e7 ff ff       	call   80159b <sys_page_alloc>
  802dad:	89 c3                	mov    %eax,%ebx
  802daf:	83 c4 10             	add    $0x10,%esp
  802db2:	85 c0                	test   %eax,%eax
  802db4:	0f 88 c3 00 00 00    	js     802e7d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802dba:	83 ec 0c             	sub    $0xc,%esp
  802dbd:	ff 75 f4             	pushl  -0xc(%ebp)
  802dc0:	e8 a5 ee ff ff       	call   801c6a <fd2data>
  802dc5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802dc7:	83 c4 0c             	add    $0xc,%esp
  802dca:	68 07 04 00 00       	push   $0x407
  802dcf:	50                   	push   %eax
  802dd0:	6a 00                	push   $0x0
  802dd2:	e8 c4 e7 ff ff       	call   80159b <sys_page_alloc>
  802dd7:	89 c3                	mov    %eax,%ebx
  802dd9:	83 c4 10             	add    $0x10,%esp
  802ddc:	85 c0                	test   %eax,%eax
  802dde:	0f 88 89 00 00 00    	js     802e6d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802de4:	83 ec 0c             	sub    $0xc,%esp
  802de7:	ff 75 f0             	pushl  -0x10(%ebp)
  802dea:	e8 7b ee ff ff       	call   801c6a <fd2data>
  802def:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802df6:	50                   	push   %eax
  802df7:	6a 00                	push   $0x0
  802df9:	56                   	push   %esi
  802dfa:	6a 00                	push   $0x0
  802dfc:	e8 dd e7 ff ff       	call   8015de <sys_page_map>
  802e01:	89 c3                	mov    %eax,%ebx
  802e03:	83 c4 20             	add    $0x20,%esp
  802e06:	85 c0                	test   %eax,%eax
  802e08:	78 55                	js     802e5f <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802e0a:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e13:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e18:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802e1f:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802e25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e28:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802e2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e2d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802e34:	83 ec 0c             	sub    $0xc,%esp
  802e37:	ff 75 f4             	pushl  -0xc(%ebp)
  802e3a:	e8 1b ee ff ff       	call   801c5a <fd2num>
  802e3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802e42:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802e44:	83 c4 04             	add    $0x4,%esp
  802e47:	ff 75 f0             	pushl  -0x10(%ebp)
  802e4a:	e8 0b ee ff ff       	call   801c5a <fd2num>
  802e4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802e52:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802e55:	83 c4 10             	add    $0x10,%esp
  802e58:	ba 00 00 00 00       	mov    $0x0,%edx
  802e5d:	eb 30                	jmp    802e8f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802e5f:	83 ec 08             	sub    $0x8,%esp
  802e62:	56                   	push   %esi
  802e63:	6a 00                	push   $0x0
  802e65:	e8 b6 e7 ff ff       	call   801620 <sys_page_unmap>
  802e6a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802e6d:	83 ec 08             	sub    $0x8,%esp
  802e70:	ff 75 f0             	pushl  -0x10(%ebp)
  802e73:	6a 00                	push   $0x0
  802e75:	e8 a6 e7 ff ff       	call   801620 <sys_page_unmap>
  802e7a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802e7d:	83 ec 08             	sub    $0x8,%esp
  802e80:	ff 75 f4             	pushl  -0xc(%ebp)
  802e83:	6a 00                	push   $0x0
  802e85:	e8 96 e7 ff ff       	call   801620 <sys_page_unmap>
  802e8a:	83 c4 10             	add    $0x10,%esp
  802e8d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802e8f:	89 d0                	mov    %edx,%eax
  802e91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e94:	5b                   	pop    %ebx
  802e95:	5e                   	pop    %esi
  802e96:	5d                   	pop    %ebp
  802e97:	c3                   	ret    

00802e98 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802e98:	55                   	push   %ebp
  802e99:	89 e5                	mov    %esp,%ebp
  802e9b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ea1:	50                   	push   %eax
  802ea2:	ff 75 08             	pushl  0x8(%ebp)
  802ea5:	e8 26 ee ff ff       	call   801cd0 <fd_lookup>
  802eaa:	83 c4 10             	add    $0x10,%esp
  802ead:	85 c0                	test   %eax,%eax
  802eaf:	78 18                	js     802ec9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802eb1:	83 ec 0c             	sub    $0xc,%esp
  802eb4:	ff 75 f4             	pushl  -0xc(%ebp)
  802eb7:	e8 ae ed ff ff       	call   801c6a <fd2data>
	return _pipeisclosed(fd, p);
  802ebc:	89 c2                	mov    %eax,%edx
  802ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ec1:	e8 18 fd ff ff       	call   802bde <_pipeisclosed>
  802ec6:	83 c4 10             	add    $0x10,%esp
}
  802ec9:	c9                   	leave  
  802eca:	c3                   	ret    

00802ecb <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802ecb:	55                   	push   %ebp
  802ecc:	89 e5                	mov    %esp,%ebp
  802ece:	56                   	push   %esi
  802ecf:	53                   	push   %ebx
  802ed0:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802ed3:	85 f6                	test   %esi,%esi
  802ed5:	75 16                	jne    802eed <wait+0x22>
  802ed7:	68 13 3b 80 00       	push   $0x803b13
  802edc:	68 ef 34 80 00       	push   $0x8034ef
  802ee1:	6a 09                	push   $0x9
  802ee3:	68 1e 3b 80 00       	push   $0x803b1e
  802ee8:	e8 5a db ff ff       	call   800a47 <_panic>
	e = &envs[ENVX(envid)];
  802eed:	89 f3                	mov    %esi,%ebx
  802eef:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802ef5:	69 db d8 00 00 00    	imul   $0xd8,%ebx,%ebx
  802efb:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802f01:	eb 05                	jmp    802f08 <wait+0x3d>
		sys_yield();
  802f03:	e8 74 e6 ff ff       	call   80157c <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802f08:	8b 83 a4 00 00 00    	mov    0xa4(%ebx),%eax
  802f0e:	39 c6                	cmp    %eax,%esi
  802f10:	75 0a                	jne    802f1c <wait+0x51>
  802f12:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  802f18:	85 c0                	test   %eax,%eax
  802f1a:	75 e7                	jne    802f03 <wait+0x38>
		sys_yield();
}
  802f1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f1f:	5b                   	pop    %ebx
  802f20:	5e                   	pop    %esi
  802f21:	5d                   	pop    %ebp
  802f22:	c3                   	ret    

00802f23 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802f23:	55                   	push   %ebp
  802f24:	89 e5                	mov    %esp,%ebp
  802f26:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802f29:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802f30:	75 2a                	jne    802f5c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802f32:	83 ec 04             	sub    $0x4,%esp
  802f35:	6a 07                	push   $0x7
  802f37:	68 00 f0 bf ee       	push   $0xeebff000
  802f3c:	6a 00                	push   $0x0
  802f3e:	e8 58 e6 ff ff       	call   80159b <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802f43:	83 c4 10             	add    $0x10,%esp
  802f46:	85 c0                	test   %eax,%eax
  802f48:	79 12                	jns    802f5c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802f4a:	50                   	push   %eax
  802f4b:	68 eb 38 80 00       	push   $0x8038eb
  802f50:	6a 23                	push   $0x23
  802f52:	68 29 3b 80 00       	push   $0x803b29
  802f57:	e8 eb da ff ff       	call   800a47 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802f5c:	8b 45 08             	mov    0x8(%ebp),%eax
  802f5f:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802f64:	83 ec 08             	sub    $0x8,%esp
  802f67:	68 8e 2f 80 00       	push   $0x802f8e
  802f6c:	6a 00                	push   $0x0
  802f6e:	e8 73 e7 ff ff       	call   8016e6 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802f73:	83 c4 10             	add    $0x10,%esp
  802f76:	85 c0                	test   %eax,%eax
  802f78:	79 12                	jns    802f8c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802f7a:	50                   	push   %eax
  802f7b:	68 eb 38 80 00       	push   $0x8038eb
  802f80:	6a 2c                	push   $0x2c
  802f82:	68 29 3b 80 00       	push   $0x803b29
  802f87:	e8 bb da ff ff       	call   800a47 <_panic>
	}
}
  802f8c:	c9                   	leave  
  802f8d:	c3                   	ret    

00802f8e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802f8e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802f8f:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802f94:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802f96:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802f99:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802f9d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802fa2:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802fa6:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802fa8:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802fab:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802fac:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802faf:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802fb0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802fb1:	c3                   	ret    

00802fb2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802fb2:	55                   	push   %ebp
  802fb3:	89 e5                	mov    %esp,%ebp
  802fb5:	56                   	push   %esi
  802fb6:	53                   	push   %ebx
  802fb7:	8b 75 08             	mov    0x8(%ebp),%esi
  802fba:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802fc0:	85 c0                	test   %eax,%eax
  802fc2:	75 12                	jne    802fd6 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802fc4:	83 ec 0c             	sub    $0xc,%esp
  802fc7:	68 00 00 c0 ee       	push   $0xeec00000
  802fcc:	e8 7a e7 ff ff       	call   80174b <sys_ipc_recv>
  802fd1:	83 c4 10             	add    $0x10,%esp
  802fd4:	eb 0c                	jmp    802fe2 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802fd6:	83 ec 0c             	sub    $0xc,%esp
  802fd9:	50                   	push   %eax
  802fda:	e8 6c e7 ff ff       	call   80174b <sys_ipc_recv>
  802fdf:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802fe2:	85 f6                	test   %esi,%esi
  802fe4:	0f 95 c1             	setne  %cl
  802fe7:	85 db                	test   %ebx,%ebx
  802fe9:	0f 95 c2             	setne  %dl
  802fec:	84 d1                	test   %dl,%cl
  802fee:	74 09                	je     802ff9 <ipc_recv+0x47>
  802ff0:	89 c2                	mov    %eax,%edx
  802ff2:	c1 ea 1f             	shr    $0x1f,%edx
  802ff5:	84 d2                	test   %dl,%dl
  802ff7:	75 2d                	jne    803026 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802ff9:	85 f6                	test   %esi,%esi
  802ffb:	74 0d                	je     80300a <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802ffd:	a1 24 54 80 00       	mov    0x805424,%eax
  803002:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  803008:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80300a:	85 db                	test   %ebx,%ebx
  80300c:	74 0d                	je     80301b <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80300e:	a1 24 54 80 00       	mov    0x805424,%eax
  803013:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  803019:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80301b:	a1 24 54 80 00       	mov    0x805424,%eax
  803020:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  803026:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803029:	5b                   	pop    %ebx
  80302a:	5e                   	pop    %esi
  80302b:	5d                   	pop    %ebp
  80302c:	c3                   	ret    

0080302d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80302d:	55                   	push   %ebp
  80302e:	89 e5                	mov    %esp,%ebp
  803030:	57                   	push   %edi
  803031:	56                   	push   %esi
  803032:	53                   	push   %ebx
  803033:	83 ec 0c             	sub    $0xc,%esp
  803036:	8b 7d 08             	mov    0x8(%ebp),%edi
  803039:	8b 75 0c             	mov    0xc(%ebp),%esi
  80303c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80303f:	85 db                	test   %ebx,%ebx
  803041:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  803046:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  803049:	ff 75 14             	pushl  0x14(%ebp)
  80304c:	53                   	push   %ebx
  80304d:	56                   	push   %esi
  80304e:	57                   	push   %edi
  80304f:	e8 d4 e6 ff ff       	call   801728 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  803054:	89 c2                	mov    %eax,%edx
  803056:	c1 ea 1f             	shr    $0x1f,%edx
  803059:	83 c4 10             	add    $0x10,%esp
  80305c:	84 d2                	test   %dl,%dl
  80305e:	74 17                	je     803077 <ipc_send+0x4a>
  803060:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803063:	74 12                	je     803077 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  803065:	50                   	push   %eax
  803066:	68 37 3b 80 00       	push   $0x803b37
  80306b:	6a 47                	push   $0x47
  80306d:	68 45 3b 80 00       	push   $0x803b45
  803072:	e8 d0 d9 ff ff       	call   800a47 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  803077:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80307a:	75 07                	jne    803083 <ipc_send+0x56>
			sys_yield();
  80307c:	e8 fb e4 ff ff       	call   80157c <sys_yield>
  803081:	eb c6                	jmp    803049 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  803083:	85 c0                	test   %eax,%eax
  803085:	75 c2                	jne    803049 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  803087:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80308a:	5b                   	pop    %ebx
  80308b:	5e                   	pop    %esi
  80308c:	5f                   	pop    %edi
  80308d:	5d                   	pop    %ebp
  80308e:	c3                   	ret    

0080308f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80308f:	55                   	push   %ebp
  803090:	89 e5                	mov    %esp,%ebp
  803092:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  803095:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80309a:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8030a0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8030a6:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  8030ac:	39 ca                	cmp    %ecx,%edx
  8030ae:	75 13                	jne    8030c3 <ipc_find_env+0x34>
			return envs[i].env_id;
  8030b0:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8030b6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8030bb:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8030c1:	eb 0f                	jmp    8030d2 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8030c3:	83 c0 01             	add    $0x1,%eax
  8030c6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8030cb:	75 cd                	jne    80309a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8030cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8030d2:	5d                   	pop    %ebp
  8030d3:	c3                   	ret    

008030d4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8030d4:	55                   	push   %ebp
  8030d5:	89 e5                	mov    %esp,%ebp
  8030d7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8030da:	89 d0                	mov    %edx,%eax
  8030dc:	c1 e8 16             	shr    $0x16,%eax
  8030df:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8030e6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8030eb:	f6 c1 01             	test   $0x1,%cl
  8030ee:	74 1d                	je     80310d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8030f0:	c1 ea 0c             	shr    $0xc,%edx
  8030f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8030fa:	f6 c2 01             	test   $0x1,%dl
  8030fd:	74 0e                	je     80310d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8030ff:	c1 ea 0c             	shr    $0xc,%edx
  803102:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803109:	ef 
  80310a:	0f b7 c0             	movzwl %ax,%eax
}
  80310d:	5d                   	pop    %ebp
  80310e:	c3                   	ret    
  80310f:	90                   	nop

00803110 <__udivdi3>:
  803110:	55                   	push   %ebp
  803111:	57                   	push   %edi
  803112:	56                   	push   %esi
  803113:	53                   	push   %ebx
  803114:	83 ec 1c             	sub    $0x1c,%esp
  803117:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80311b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80311f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803127:	85 f6                	test   %esi,%esi
  803129:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80312d:	89 ca                	mov    %ecx,%edx
  80312f:	89 f8                	mov    %edi,%eax
  803131:	75 3d                	jne    803170 <__udivdi3+0x60>
  803133:	39 cf                	cmp    %ecx,%edi
  803135:	0f 87 c5 00 00 00    	ja     803200 <__udivdi3+0xf0>
  80313b:	85 ff                	test   %edi,%edi
  80313d:	89 fd                	mov    %edi,%ebp
  80313f:	75 0b                	jne    80314c <__udivdi3+0x3c>
  803141:	b8 01 00 00 00       	mov    $0x1,%eax
  803146:	31 d2                	xor    %edx,%edx
  803148:	f7 f7                	div    %edi
  80314a:	89 c5                	mov    %eax,%ebp
  80314c:	89 c8                	mov    %ecx,%eax
  80314e:	31 d2                	xor    %edx,%edx
  803150:	f7 f5                	div    %ebp
  803152:	89 c1                	mov    %eax,%ecx
  803154:	89 d8                	mov    %ebx,%eax
  803156:	89 cf                	mov    %ecx,%edi
  803158:	f7 f5                	div    %ebp
  80315a:	89 c3                	mov    %eax,%ebx
  80315c:	89 d8                	mov    %ebx,%eax
  80315e:	89 fa                	mov    %edi,%edx
  803160:	83 c4 1c             	add    $0x1c,%esp
  803163:	5b                   	pop    %ebx
  803164:	5e                   	pop    %esi
  803165:	5f                   	pop    %edi
  803166:	5d                   	pop    %ebp
  803167:	c3                   	ret    
  803168:	90                   	nop
  803169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803170:	39 ce                	cmp    %ecx,%esi
  803172:	77 74                	ja     8031e8 <__udivdi3+0xd8>
  803174:	0f bd fe             	bsr    %esi,%edi
  803177:	83 f7 1f             	xor    $0x1f,%edi
  80317a:	0f 84 98 00 00 00    	je     803218 <__udivdi3+0x108>
  803180:	bb 20 00 00 00       	mov    $0x20,%ebx
  803185:	89 f9                	mov    %edi,%ecx
  803187:	89 c5                	mov    %eax,%ebp
  803189:	29 fb                	sub    %edi,%ebx
  80318b:	d3 e6                	shl    %cl,%esi
  80318d:	89 d9                	mov    %ebx,%ecx
  80318f:	d3 ed                	shr    %cl,%ebp
  803191:	89 f9                	mov    %edi,%ecx
  803193:	d3 e0                	shl    %cl,%eax
  803195:	09 ee                	or     %ebp,%esi
  803197:	89 d9                	mov    %ebx,%ecx
  803199:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80319d:	89 d5                	mov    %edx,%ebp
  80319f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8031a3:	d3 ed                	shr    %cl,%ebp
  8031a5:	89 f9                	mov    %edi,%ecx
  8031a7:	d3 e2                	shl    %cl,%edx
  8031a9:	89 d9                	mov    %ebx,%ecx
  8031ab:	d3 e8                	shr    %cl,%eax
  8031ad:	09 c2                	or     %eax,%edx
  8031af:	89 d0                	mov    %edx,%eax
  8031b1:	89 ea                	mov    %ebp,%edx
  8031b3:	f7 f6                	div    %esi
  8031b5:	89 d5                	mov    %edx,%ebp
  8031b7:	89 c3                	mov    %eax,%ebx
  8031b9:	f7 64 24 0c          	mull   0xc(%esp)
  8031bd:	39 d5                	cmp    %edx,%ebp
  8031bf:	72 10                	jb     8031d1 <__udivdi3+0xc1>
  8031c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8031c5:	89 f9                	mov    %edi,%ecx
  8031c7:	d3 e6                	shl    %cl,%esi
  8031c9:	39 c6                	cmp    %eax,%esi
  8031cb:	73 07                	jae    8031d4 <__udivdi3+0xc4>
  8031cd:	39 d5                	cmp    %edx,%ebp
  8031cf:	75 03                	jne    8031d4 <__udivdi3+0xc4>
  8031d1:	83 eb 01             	sub    $0x1,%ebx
  8031d4:	31 ff                	xor    %edi,%edi
  8031d6:	89 d8                	mov    %ebx,%eax
  8031d8:	89 fa                	mov    %edi,%edx
  8031da:	83 c4 1c             	add    $0x1c,%esp
  8031dd:	5b                   	pop    %ebx
  8031de:	5e                   	pop    %esi
  8031df:	5f                   	pop    %edi
  8031e0:	5d                   	pop    %ebp
  8031e1:	c3                   	ret    
  8031e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8031e8:	31 ff                	xor    %edi,%edi
  8031ea:	31 db                	xor    %ebx,%ebx
  8031ec:	89 d8                	mov    %ebx,%eax
  8031ee:	89 fa                	mov    %edi,%edx
  8031f0:	83 c4 1c             	add    $0x1c,%esp
  8031f3:	5b                   	pop    %ebx
  8031f4:	5e                   	pop    %esi
  8031f5:	5f                   	pop    %edi
  8031f6:	5d                   	pop    %ebp
  8031f7:	c3                   	ret    
  8031f8:	90                   	nop
  8031f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803200:	89 d8                	mov    %ebx,%eax
  803202:	f7 f7                	div    %edi
  803204:	31 ff                	xor    %edi,%edi
  803206:	89 c3                	mov    %eax,%ebx
  803208:	89 d8                	mov    %ebx,%eax
  80320a:	89 fa                	mov    %edi,%edx
  80320c:	83 c4 1c             	add    $0x1c,%esp
  80320f:	5b                   	pop    %ebx
  803210:	5e                   	pop    %esi
  803211:	5f                   	pop    %edi
  803212:	5d                   	pop    %ebp
  803213:	c3                   	ret    
  803214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803218:	39 ce                	cmp    %ecx,%esi
  80321a:	72 0c                	jb     803228 <__udivdi3+0x118>
  80321c:	31 db                	xor    %ebx,%ebx
  80321e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803222:	0f 87 34 ff ff ff    	ja     80315c <__udivdi3+0x4c>
  803228:	bb 01 00 00 00       	mov    $0x1,%ebx
  80322d:	e9 2a ff ff ff       	jmp    80315c <__udivdi3+0x4c>
  803232:	66 90                	xchg   %ax,%ax
  803234:	66 90                	xchg   %ax,%ax
  803236:	66 90                	xchg   %ax,%ax
  803238:	66 90                	xchg   %ax,%ax
  80323a:	66 90                	xchg   %ax,%ax
  80323c:	66 90                	xchg   %ax,%ax
  80323e:	66 90                	xchg   %ax,%ax

00803240 <__umoddi3>:
  803240:	55                   	push   %ebp
  803241:	57                   	push   %edi
  803242:	56                   	push   %esi
  803243:	53                   	push   %ebx
  803244:	83 ec 1c             	sub    $0x1c,%esp
  803247:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80324b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80324f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803253:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803257:	85 d2                	test   %edx,%edx
  803259:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80325d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803261:	89 f3                	mov    %esi,%ebx
  803263:	89 3c 24             	mov    %edi,(%esp)
  803266:	89 74 24 04          	mov    %esi,0x4(%esp)
  80326a:	75 1c                	jne    803288 <__umoddi3+0x48>
  80326c:	39 f7                	cmp    %esi,%edi
  80326e:	76 50                	jbe    8032c0 <__umoddi3+0x80>
  803270:	89 c8                	mov    %ecx,%eax
  803272:	89 f2                	mov    %esi,%edx
  803274:	f7 f7                	div    %edi
  803276:	89 d0                	mov    %edx,%eax
  803278:	31 d2                	xor    %edx,%edx
  80327a:	83 c4 1c             	add    $0x1c,%esp
  80327d:	5b                   	pop    %ebx
  80327e:	5e                   	pop    %esi
  80327f:	5f                   	pop    %edi
  803280:	5d                   	pop    %ebp
  803281:	c3                   	ret    
  803282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803288:	39 f2                	cmp    %esi,%edx
  80328a:	89 d0                	mov    %edx,%eax
  80328c:	77 52                	ja     8032e0 <__umoddi3+0xa0>
  80328e:	0f bd ea             	bsr    %edx,%ebp
  803291:	83 f5 1f             	xor    $0x1f,%ebp
  803294:	75 5a                	jne    8032f0 <__umoddi3+0xb0>
  803296:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80329a:	0f 82 e0 00 00 00    	jb     803380 <__umoddi3+0x140>
  8032a0:	39 0c 24             	cmp    %ecx,(%esp)
  8032a3:	0f 86 d7 00 00 00    	jbe    803380 <__umoddi3+0x140>
  8032a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8032ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8032b1:	83 c4 1c             	add    $0x1c,%esp
  8032b4:	5b                   	pop    %ebx
  8032b5:	5e                   	pop    %esi
  8032b6:	5f                   	pop    %edi
  8032b7:	5d                   	pop    %ebp
  8032b8:	c3                   	ret    
  8032b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8032c0:	85 ff                	test   %edi,%edi
  8032c2:	89 fd                	mov    %edi,%ebp
  8032c4:	75 0b                	jne    8032d1 <__umoddi3+0x91>
  8032c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8032cb:	31 d2                	xor    %edx,%edx
  8032cd:	f7 f7                	div    %edi
  8032cf:	89 c5                	mov    %eax,%ebp
  8032d1:	89 f0                	mov    %esi,%eax
  8032d3:	31 d2                	xor    %edx,%edx
  8032d5:	f7 f5                	div    %ebp
  8032d7:	89 c8                	mov    %ecx,%eax
  8032d9:	f7 f5                	div    %ebp
  8032db:	89 d0                	mov    %edx,%eax
  8032dd:	eb 99                	jmp    803278 <__umoddi3+0x38>
  8032df:	90                   	nop
  8032e0:	89 c8                	mov    %ecx,%eax
  8032e2:	89 f2                	mov    %esi,%edx
  8032e4:	83 c4 1c             	add    $0x1c,%esp
  8032e7:	5b                   	pop    %ebx
  8032e8:	5e                   	pop    %esi
  8032e9:	5f                   	pop    %edi
  8032ea:	5d                   	pop    %ebp
  8032eb:	c3                   	ret    
  8032ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8032f0:	8b 34 24             	mov    (%esp),%esi
  8032f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8032f8:	89 e9                	mov    %ebp,%ecx
  8032fa:	29 ef                	sub    %ebp,%edi
  8032fc:	d3 e0                	shl    %cl,%eax
  8032fe:	89 f9                	mov    %edi,%ecx
  803300:	89 f2                	mov    %esi,%edx
  803302:	d3 ea                	shr    %cl,%edx
  803304:	89 e9                	mov    %ebp,%ecx
  803306:	09 c2                	or     %eax,%edx
  803308:	89 d8                	mov    %ebx,%eax
  80330a:	89 14 24             	mov    %edx,(%esp)
  80330d:	89 f2                	mov    %esi,%edx
  80330f:	d3 e2                	shl    %cl,%edx
  803311:	89 f9                	mov    %edi,%ecx
  803313:	89 54 24 04          	mov    %edx,0x4(%esp)
  803317:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80331b:	d3 e8                	shr    %cl,%eax
  80331d:	89 e9                	mov    %ebp,%ecx
  80331f:	89 c6                	mov    %eax,%esi
  803321:	d3 e3                	shl    %cl,%ebx
  803323:	89 f9                	mov    %edi,%ecx
  803325:	89 d0                	mov    %edx,%eax
  803327:	d3 e8                	shr    %cl,%eax
  803329:	89 e9                	mov    %ebp,%ecx
  80332b:	09 d8                	or     %ebx,%eax
  80332d:	89 d3                	mov    %edx,%ebx
  80332f:	89 f2                	mov    %esi,%edx
  803331:	f7 34 24             	divl   (%esp)
  803334:	89 d6                	mov    %edx,%esi
  803336:	d3 e3                	shl    %cl,%ebx
  803338:	f7 64 24 04          	mull   0x4(%esp)
  80333c:	39 d6                	cmp    %edx,%esi
  80333e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803342:	89 d1                	mov    %edx,%ecx
  803344:	89 c3                	mov    %eax,%ebx
  803346:	72 08                	jb     803350 <__umoddi3+0x110>
  803348:	75 11                	jne    80335b <__umoddi3+0x11b>
  80334a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80334e:	73 0b                	jae    80335b <__umoddi3+0x11b>
  803350:	2b 44 24 04          	sub    0x4(%esp),%eax
  803354:	1b 14 24             	sbb    (%esp),%edx
  803357:	89 d1                	mov    %edx,%ecx
  803359:	89 c3                	mov    %eax,%ebx
  80335b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80335f:	29 da                	sub    %ebx,%edx
  803361:	19 ce                	sbb    %ecx,%esi
  803363:	89 f9                	mov    %edi,%ecx
  803365:	89 f0                	mov    %esi,%eax
  803367:	d3 e0                	shl    %cl,%eax
  803369:	89 e9                	mov    %ebp,%ecx
  80336b:	d3 ea                	shr    %cl,%edx
  80336d:	89 e9                	mov    %ebp,%ecx
  80336f:	d3 ee                	shr    %cl,%esi
  803371:	09 d0                	or     %edx,%eax
  803373:	89 f2                	mov    %esi,%edx
  803375:	83 c4 1c             	add    $0x1c,%esp
  803378:	5b                   	pop    %ebx
  803379:	5e                   	pop    %esi
  80337a:	5f                   	pop    %edi
  80337b:	5d                   	pop    %ebp
  80337c:	c3                   	ret    
  80337d:	8d 76 00             	lea    0x0(%esi),%esi
  803380:	29 f9                	sub    %edi,%ecx
  803382:	19 d6                	sbb    %edx,%esi
  803384:	89 74 24 04          	mov    %esi,0x4(%esp)
  803388:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80338c:	e9 18 ff ff ff       	jmp    8032a9 <__umoddi3+0x69>
