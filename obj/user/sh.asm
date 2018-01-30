
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
  80005b:	68 20 36 80 00       	push   $0x803620
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
  80007f:	68 2f 36 80 00       	push   $0x80362f
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
  8000ab:	68 3d 36 80 00       	push   $0x80363d
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
  8000d8:	68 42 36 80 00       	push   $0x803642
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
  8000f6:	68 53 36 80 00       	push   $0x803653
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
  800126:	68 47 36 80 00       	push   $0x803647
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
  80014c:	68 4f 36 80 00       	push   $0x80364f
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
  80017b:	68 5b 36 80 00       	push   $0x80365b
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
  800273:	68 65 36 80 00       	push   $0x803665
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
  8002a7:	68 b8 37 80 00       	push   $0x8037b8
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
  8002c1:	e8 69 23 00 00       	call   80262f <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
				cprintf("open %s for read: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 79 36 80 00       	push   $0x803679
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
  8002f8:	e8 b2 1d 00 00       	call   8020af <dup>
				close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 5a 1d 00 00       	call   80205f <close>
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
  800323:	68 e0 37 80 00       	push   $0x8037e0
  800328:	e8 f3 07 00 00       	call   800b20 <cprintf>
				exit();
  80032d:	e8 fb 06 00 00       	call   800a2d <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 ea 22 00 00       	call   80262f <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 8e 36 80 00       	push   $0x80368e
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
  800376:	e8 34 1d 00 00       	call   8020af <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 dc 1c 00 00       	call   80205f <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 0d 2c 00 00       	call   802fa7 <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 a4 36 80 00       	push   $0x8036a4
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
  8003cf:	68 ad 36 80 00       	push   $0x8036ad
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
  8003eb:	68 ba 36 80 00       	push   $0x8036ba
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
  800411:	e8 99 1c 00 00       	call   8020af <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 3b 1c 00 00       	call   80205f <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 2a 1c 00 00       	call   80205f <close>
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
  80044e:	e8 5c 1c 00 00       	call   8020af <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 fe 1b 00 00       	call   80205f <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 ed 1b 00 00       	call   80205f <close>
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 17                	jmp    80048e <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800477:	50                   	push   %eax
  800478:	68 c3 36 80 00       	push   $0x8036c3
  80047d:	6a 79                	push   $0x79
  80047f:	68 df 36 80 00       	push   $0x8036df
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
  8004a2:	68 e9 36 80 00       	push   $0x8036e9
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
  8004ff:	68 f8 36 80 00       	push   $0x8036f8
  800504:	e8 17 06 00 00       	call   800b20 <cprintf>
  800509:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	eb 11                	jmp    800522 <runcmd+0x319>
			cprintf(" %s", argv[i]);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	50                   	push   %eax
  800515:	68 80 37 80 00       	push   $0x803780
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
  80052f:	68 40 36 80 00       	push   $0x803640
  800534:	e8 e7 05 00 00       	call   800b20 <cprintf>
  800539:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800542:	50                   	push   %eax
  800543:	ff 75 a8             	pushl  -0x58(%ebp)
  800546:	e8 98 22 00 00       	call   8027e3 <spawn>
  80054b:	89 c3                	mov    %eax,%ebx
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	85 c0                	test   %eax,%eax
  800552:	0f 89 cf 00 00 00    	jns    800627 <runcmd+0x41e>
		cprintf("spawn %s: %e\n", argv[0], r);
  800558:	83 ec 04             	sub    $0x4,%esp
  80055b:	50                   	push   %eax
  80055c:	ff 75 a8             	pushl  -0x58(%ebp)
  80055f:	68 06 37 80 00       	push   $0x803706
  800564:	e8 b7 05 00 00       	call   800b20 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800569:	e8 1c 1b 00 00       	call   80208a <close_all>
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
  800583:	68 14 37 80 00       	push   $0x803714
  800588:	e8 93 05 00 00       	call   800b20 <cprintf>
  80058d:	83 c4 10             	add    $0x10,%esp
		wait(r);
  800590:	83 ec 0c             	sub    $0xc,%esp
  800593:	53                   	push   %ebx
  800594:	e8 94 2b 00 00       	call   80312d <wait>
		if (debug)
  800599:	83 c4 10             	add    $0x10,%esp
  80059c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005a3:	0f 84 95 00 00 00    	je     80063e <runcmd+0x435>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a9:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ae:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	50                   	push   %eax
  8005b8:	68 29 37 80 00       	push   $0x803729
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
  8005e2:	68 3f 37 80 00       	push   $0x80373f
  8005e7:	e8 34 05 00 00       	call   800b20 <cprintf>
  8005ec:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	57                   	push   %edi
  8005f3:	e8 35 2b 00 00       	call   80312d <wait>
		if (debug)
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800602:	74 1c                	je     800620 <runcmd+0x417>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800604:	a1 24 54 80 00       	mov    0x805424,%eax
  800609:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	50                   	push   %eax
  800613:	68 29 37 80 00       	push   $0x803729
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
  800627:	e8 5e 1a 00 00       	call   80208a <close_all>
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
  800652:	68 08 38 80 00       	push   $0x803808
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
  80067b:	e8 e8 16 00 00       	call   801d68 <argstart>
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
  8006c7:	e8 cc 16 00 00       	call   801d98 <argnext>
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
  8006e9:	e8 71 19 00 00       	call   80205f <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006ee:	83 c4 08             	add    $0x8,%esp
  8006f1:	6a 00                	push   $0x0
  8006f3:	ff 77 04             	pushl  0x4(%edi)
  8006f6:	e8 34 1f 00 00       	call   80262f <open>
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	85 c0                	test   %eax,%eax
  800700:	79 1b                	jns    80071d <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  800702:	83 ec 0c             	sub    $0xc,%esp
  800705:	50                   	push   %eax
  800706:	ff 77 04             	pushl  0x4(%edi)
  800709:	68 5c 37 80 00       	push   $0x80375c
  80070e:	68 29 01 00 00       	push   $0x129
  800713:	68 df 36 80 00       	push   $0x8036df
  800718:	e8 2a 03 00 00       	call   800a47 <_panic>
		assert(r == 0);
  80071d:	85 c0                	test   %eax,%eax
  80071f:	74 19                	je     80073a <umain+0xd4>
  800721:	68 68 37 80 00       	push   $0x803768
  800726:	68 6f 37 80 00       	push   $0x80376f
  80072b:	68 2a 01 00 00       	push   $0x12a
  800730:	68 df 36 80 00       	push   $0x8036df
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
  800755:	bf 84 37 80 00       	mov    $0x803784,%edi
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
  80077b:	68 87 37 80 00       	push   $0x803787
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
  80079a:	68 90 37 80 00       	push   $0x803790
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
  8007b6:	68 9a 37 80 00       	push   $0x80379a
  8007bb:	e8 0d 20 00 00       	call   8027cd <printf>
  8007c0:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007c3:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007ca:	74 10                	je     8007dc <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007cc:	83 ec 0c             	sub    $0xc,%esp
  8007cf:	68 a0 37 80 00       	push   $0x8037a0
  8007d4:	e8 47 03 00 00       	call   800b20 <cprintf>
  8007d9:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007dc:	e8 e1 10 00 00       	call   8018c2 <fork>
  8007e1:	89 c6                	mov    %eax,%esi
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	79 15                	jns    8007fc <umain+0x196>
			panic("fork: %e", r);
  8007e7:	50                   	push   %eax
  8007e8:	68 ba 36 80 00       	push   $0x8036ba
  8007ed:	68 41 01 00 00       	push   $0x141
  8007f2:	68 df 36 80 00       	push   $0x8036df
  8007f7:	e8 4b 02 00 00       	call   800a47 <_panic>
		if (debug)
  8007fc:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800803:	74 11                	je     800816 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  800805:	83 ec 08             	sub    $0x8,%esp
  800808:	50                   	push   %eax
  800809:	68 ad 37 80 00       	push   $0x8037ad
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
  800834:	e8 f4 28 00 00       	call   80312d <wait>
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
  800851:	68 29 38 80 00       	push   $0x803829
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
  800921:	e8 75 18 00 00       	call   80219b <read>
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
  80094b:	e8 e2 15 00 00       	call   801f32 <fd_lookup>
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
  800974:	e8 6a 15 00 00       	call   801ee3 <fd_alloc>
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
  8009b6:	e8 01 15 00 00       	call   801ebc <fd2num>
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
  800a33:	e8 52 16 00 00       	call   80208a <close_all>
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
  800a65:	68 40 38 80 00       	push   $0x803840
  800a6a:	e8 b1 00 00 00       	call   800b20 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a6f:	83 c4 18             	add    $0x18,%esp
  800a72:	53                   	push   %ebx
  800a73:	ff 75 10             	pushl  0x10(%ebp)
  800a76:	e8 54 00 00 00       	call   800acf <vcprintf>
	cprintf("\n");
  800a7b:	c7 04 24 40 36 80 00 	movl   $0x803640,(%esp)
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
  800b83:	e8 f8 27 00 00       	call   803380 <__udivdi3>
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
  800bc6:	e8 e5 28 00 00       	call   8034b0 <__umoddi3>
  800bcb:	83 c4 14             	add    $0x14,%esp
  800bce:	0f be 80 63 38 80 00 	movsbl 0x803863(%eax),%eax
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
  800cca:	ff 24 85 a0 39 80 00 	jmp    *0x8039a0(,%eax,4)
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
  800d8e:	8b 14 85 00 3b 80 00 	mov    0x803b00(,%eax,4),%edx
  800d95:	85 d2                	test   %edx,%edx
  800d97:	75 18                	jne    800db1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d99:	50                   	push   %eax
  800d9a:	68 7b 38 80 00       	push   $0x80387b
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
  800db2:	68 81 37 80 00       	push   $0x803781
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
  800dd6:	b8 74 38 80 00       	mov    $0x803874,%eax
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
  801080:	68 81 37 80 00       	push   $0x803781
  801085:	6a 01                	push   $0x1
  801087:	e8 2a 17 00 00       	call   8027b6 <fprintf>
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
  8010c0:	68 5f 3b 80 00       	push   $0x803b5f
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
  801544:	68 6f 3b 80 00       	push   $0x803b6f
  801549:	6a 23                	push   $0x23
  80154b:	68 8c 3b 80 00       	push   $0x803b8c
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
  8015c5:	68 6f 3b 80 00       	push   $0x803b6f
  8015ca:	6a 23                	push   $0x23
  8015cc:	68 8c 3b 80 00       	push   $0x803b8c
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
  801607:	68 6f 3b 80 00       	push   $0x803b6f
  80160c:	6a 23                	push   $0x23
  80160e:	68 8c 3b 80 00       	push   $0x803b8c
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
  801649:	68 6f 3b 80 00       	push   $0x803b6f
  80164e:	6a 23                	push   $0x23
  801650:	68 8c 3b 80 00       	push   $0x803b8c
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
  80168b:	68 6f 3b 80 00       	push   $0x803b6f
  801690:	6a 23                	push   $0x23
  801692:	68 8c 3b 80 00       	push   $0x803b8c
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
  8016cd:	68 6f 3b 80 00       	push   $0x803b6f
  8016d2:	6a 23                	push   $0x23
  8016d4:	68 8c 3b 80 00       	push   $0x803b8c
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
  80170f:	68 6f 3b 80 00       	push   $0x803b6f
  801714:	6a 23                	push   $0x23
  801716:	68 8c 3b 80 00       	push   $0x803b8c
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
  801773:	68 6f 3b 80 00       	push   $0x803b6f
  801778:	6a 23                	push   $0x23
  80177a:	68 8c 3b 80 00       	push   $0x803b8c
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
  801812:	68 9a 3b 80 00       	push   $0x803b9a
  801817:	6a 1f                	push   $0x1f
  801819:	68 aa 3b 80 00       	push   $0x803baa
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
  80183c:	68 b5 3b 80 00       	push   $0x803bb5
  801841:	6a 2d                	push   $0x2d
  801843:	68 aa 3b 80 00       	push   $0x803baa
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
  801884:	68 b5 3b 80 00       	push   $0x803bb5
  801889:	6a 34                	push   $0x34
  80188b:	68 aa 3b 80 00       	push   $0x803baa
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
  8018ac:	68 b5 3b 80 00       	push   $0x803bb5
  8018b1:	6a 38                	push   $0x38
  8018b3:	68 aa 3b 80 00       	push   $0x803baa
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
  8018d0:	e8 b0 18 00 00       	call   803185 <set_pgfault_handler>
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
  8018e9:	68 ce 3b 80 00       	push   $0x803bce
  8018ee:	68 85 00 00 00       	push   $0x85
  8018f3:	68 aa 3b 80 00       	push   $0x803baa
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
  8019a5:	68 dc 3b 80 00       	push   $0x803bdc
  8019aa:	6a 55                	push   $0x55
  8019ac:	68 aa 3b 80 00       	push   $0x803baa
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
  8019ea:	68 dc 3b 80 00       	push   $0x803bdc
  8019ef:	6a 5c                	push   $0x5c
  8019f1:	68 aa 3b 80 00       	push   $0x803baa
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
  801a18:	68 dc 3b 80 00       	push   $0x803bdc
  801a1d:	6a 60                	push   $0x60
  801a1f:	68 aa 3b 80 00       	push   $0x803baa
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
  801a42:	68 dc 3b 80 00       	push   $0x803bdc
  801a47:	6a 65                	push   $0x65
  801a49:	68 aa 3b 80 00       	push   $0x803baa
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
  801ab1:	68 6c 3c 80 00       	push   $0x803c6c
  801ab6:	e8 65 f0 ff ff       	call   800b20 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801abb:	c7 04 24 0d 0a 80 00 	movl   $0x800a0d,(%esp)
  801ac2:	e8 c5 fc ff ff       	call   80178c <sys_thread_create>
  801ac7:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801ac9:	83 c4 08             	add    $0x8,%esp
  801acc:	53                   	push   %ebx
  801acd:	68 6c 3c 80 00       	push   $0x803c6c
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

00801b06 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	56                   	push   %esi
  801b0a:	53                   	push   %ebx
  801b0b:	8b 75 08             	mov    0x8(%ebp),%esi
  801b0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801b11:	83 ec 04             	sub    $0x4,%esp
  801b14:	6a 07                	push   $0x7
  801b16:	6a 00                	push   $0x0
  801b18:	56                   	push   %esi
  801b19:	e8 7d fa ff ff       	call   80159b <sys_page_alloc>
	if (r < 0) {
  801b1e:	83 c4 10             	add    $0x10,%esp
  801b21:	85 c0                	test   %eax,%eax
  801b23:	79 15                	jns    801b3a <queue_append+0x34>
		panic("%e\n", r);
  801b25:	50                   	push   %eax
  801b26:	68 6b 3b 80 00       	push   $0x803b6b
  801b2b:	68 c4 00 00 00       	push   $0xc4
  801b30:	68 aa 3b 80 00       	push   $0x803baa
  801b35:	e8 0d ef ff ff       	call   800a47 <_panic>
	}	
	wt->envid = envid;
  801b3a:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801b40:	83 ec 04             	sub    $0x4,%esp
  801b43:	ff 33                	pushl  (%ebx)
  801b45:	56                   	push   %esi
  801b46:	68 90 3c 80 00       	push   $0x803c90
  801b4b:	e8 d0 ef ff ff       	call   800b20 <cprintf>
	if (queue->first == NULL) {
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	83 3b 00             	cmpl   $0x0,(%ebx)
  801b56:	75 29                	jne    801b81 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  801b58:	83 ec 0c             	sub    $0xc,%esp
  801b5b:	68 f2 3b 80 00       	push   $0x803bf2
  801b60:	e8 bb ef ff ff       	call   800b20 <cprintf>
		queue->first = wt;
  801b65:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  801b6b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801b72:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801b79:	00 00 00 
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	eb 2b                	jmp    801bac <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801b81:	83 ec 0c             	sub    $0xc,%esp
  801b84:	68 0c 3c 80 00       	push   $0x803c0c
  801b89:	e8 92 ef ff ff       	call   800b20 <cprintf>
		queue->last->next = wt;
  801b8e:	8b 43 04             	mov    0x4(%ebx),%eax
  801b91:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801b98:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801b9f:	00 00 00 
		queue->last = wt;
  801ba2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  801ba9:	83 c4 10             	add    $0x10,%esp
	}
}
  801bac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801baf:	5b                   	pop    %ebx
  801bb0:	5e                   	pop    %esi
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	53                   	push   %ebx
  801bb7:	83 ec 04             	sub    $0x4,%esp
  801bba:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  801bbd:	8b 02                	mov    (%edx),%eax
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	75 17                	jne    801bda <queue_pop+0x27>
		panic("queue empty!\n");
  801bc3:	83 ec 04             	sub    $0x4,%esp
  801bc6:	68 2a 3c 80 00       	push   $0x803c2a
  801bcb:	68 d8 00 00 00       	push   $0xd8
  801bd0:	68 aa 3b 80 00       	push   $0x803baa
  801bd5:	e8 6d ee ff ff       	call   800a47 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801bda:	8b 48 04             	mov    0x4(%eax),%ecx
  801bdd:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  801bdf:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801be1:	83 ec 08             	sub    $0x8,%esp
  801be4:	53                   	push   %ebx
  801be5:	68 38 3c 80 00       	push   $0x803c38
  801bea:	e8 31 ef ff ff       	call   800b20 <cprintf>
	return envid;
}
  801bef:	89 d8                	mov    %ebx,%eax
  801bf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	53                   	push   %ebx
  801bfa:	83 ec 04             	sub    $0x4,%esp
  801bfd:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801c00:	b8 01 00 00 00       	mov    $0x1,%eax
  801c05:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	74 5a                	je     801c66 <mutex_lock+0x70>
  801c0c:	8b 43 04             	mov    0x4(%ebx),%eax
  801c0f:	83 38 00             	cmpl   $0x0,(%eax)
  801c12:	75 52                	jne    801c66 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801c14:	83 ec 0c             	sub    $0xc,%esp
  801c17:	68 b8 3c 80 00       	push   $0x803cb8
  801c1c:	e8 ff ee ff ff       	call   800b20 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801c21:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801c24:	e8 34 f9 ff ff       	call   80155d <sys_getenvid>
  801c29:	83 c4 08             	add    $0x8,%esp
  801c2c:	53                   	push   %ebx
  801c2d:	50                   	push   %eax
  801c2e:	e8 d3 fe ff ff       	call   801b06 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801c33:	e8 25 f9 ff ff       	call   80155d <sys_getenvid>
  801c38:	83 c4 08             	add    $0x8,%esp
  801c3b:	6a 04                	push   $0x4
  801c3d:	50                   	push   %eax
  801c3e:	e8 1f fa ff ff       	call   801662 <sys_env_set_status>
		if (r < 0) {
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	85 c0                	test   %eax,%eax
  801c48:	79 15                	jns    801c5f <mutex_lock+0x69>
			panic("%e\n", r);
  801c4a:	50                   	push   %eax
  801c4b:	68 6b 3b 80 00       	push   $0x803b6b
  801c50:	68 eb 00 00 00       	push   $0xeb
  801c55:	68 aa 3b 80 00       	push   $0x803baa
  801c5a:	e8 e8 ed ff ff       	call   800a47 <_panic>
		}
		sys_yield();
  801c5f:	e8 18 f9 ff ff       	call   80157c <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801c64:	eb 18                	jmp    801c7e <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  801c66:	83 ec 0c             	sub    $0xc,%esp
  801c69:	68 d8 3c 80 00       	push   $0x803cd8
  801c6e:	e8 ad ee ff ff       	call   800b20 <cprintf>
	mtx->owner = sys_getenvid();}
  801c73:	e8 e5 f8 ff ff       	call   80155d <sys_getenvid>
  801c78:	89 43 08             	mov    %eax,0x8(%ebx)
  801c7b:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  801c7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c81:	c9                   	leave  
  801c82:	c3                   	ret    

00801c83 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	53                   	push   %ebx
  801c87:	83 ec 04             	sub    $0x4,%esp
  801c8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c92:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801c95:	8b 43 04             	mov    0x4(%ebx),%eax
  801c98:	83 38 00             	cmpl   $0x0,(%eax)
  801c9b:	74 33                	je     801cd0 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  801c9d:	83 ec 0c             	sub    $0xc,%esp
  801ca0:	50                   	push   %eax
  801ca1:	e8 0d ff ff ff       	call   801bb3 <queue_pop>
  801ca6:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801ca9:	83 c4 08             	add    $0x8,%esp
  801cac:	6a 02                	push   $0x2
  801cae:	50                   	push   %eax
  801caf:	e8 ae f9 ff ff       	call   801662 <sys_env_set_status>
		if (r < 0) {
  801cb4:	83 c4 10             	add    $0x10,%esp
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	79 15                	jns    801cd0 <mutex_unlock+0x4d>
			panic("%e\n", r);
  801cbb:	50                   	push   %eax
  801cbc:	68 6b 3b 80 00       	push   $0x803b6b
  801cc1:	68 00 01 00 00       	push   $0x100
  801cc6:	68 aa 3b 80 00       	push   $0x803baa
  801ccb:	e8 77 ed ff ff       	call   800a47 <_panic>
		}
	}

	asm volatile("pause");
  801cd0:	f3 90                	pause  
	//sys_yield();
}
  801cd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd5:	c9                   	leave  
  801cd6:	c3                   	ret    

00801cd7 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	53                   	push   %ebx
  801cdb:	83 ec 04             	sub    $0x4,%esp
  801cde:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801ce1:	e8 77 f8 ff ff       	call   80155d <sys_getenvid>
  801ce6:	83 ec 04             	sub    $0x4,%esp
  801ce9:	6a 07                	push   $0x7
  801ceb:	53                   	push   %ebx
  801cec:	50                   	push   %eax
  801ced:	e8 a9 f8 ff ff       	call   80159b <sys_page_alloc>
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	79 15                	jns    801d0e <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801cf9:	50                   	push   %eax
  801cfa:	68 53 3c 80 00       	push   $0x803c53
  801cff:	68 0d 01 00 00       	push   $0x10d
  801d04:	68 aa 3b 80 00       	push   $0x803baa
  801d09:	e8 39 ed ff ff       	call   800a47 <_panic>
	}	
	mtx->locked = 0;
  801d0e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801d14:	8b 43 04             	mov    0x4(%ebx),%eax
  801d17:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801d1d:	8b 43 04             	mov    0x4(%ebx),%eax
  801d20:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801d27:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801d2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d31:	c9                   	leave  
  801d32:	c3                   	ret    

00801d33 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  801d39:	e8 1f f8 ff ff       	call   80155d <sys_getenvid>
  801d3e:	83 ec 08             	sub    $0x8,%esp
  801d41:	ff 75 08             	pushl  0x8(%ebp)
  801d44:	50                   	push   %eax
  801d45:	e8 d6 f8 ff ff       	call   801620 <sys_page_unmap>
	if (r < 0) {
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	85 c0                	test   %eax,%eax
  801d4f:	79 15                	jns    801d66 <mutex_destroy+0x33>
		panic("%e\n", r);
  801d51:	50                   	push   %eax
  801d52:	68 6b 3b 80 00       	push   $0x803b6b
  801d57:	68 1a 01 00 00       	push   $0x11a
  801d5c:	68 aa 3b 80 00       	push   $0x803baa
  801d61:	e8 e1 ec ff ff       	call   800a47 <_panic>
	}
}
  801d66:	c9                   	leave  
  801d67:	c3                   	ret    

00801d68 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  801d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d71:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801d74:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801d76:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801d79:	83 3a 01             	cmpl   $0x1,(%edx)
  801d7c:	7e 09                	jle    801d87 <argstart+0x1f>
  801d7e:	ba 41 36 80 00       	mov    $0x803641,%edx
  801d83:	85 c9                	test   %ecx,%ecx
  801d85:	75 05                	jne    801d8c <argstart+0x24>
  801d87:	ba 00 00 00 00       	mov    $0x0,%edx
  801d8c:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801d8f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    

00801d98 <argnext>:

int
argnext(struct Argstate *args)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	53                   	push   %ebx
  801d9c:	83 ec 04             	sub    $0x4,%esp
  801d9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801da2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801da9:	8b 43 08             	mov    0x8(%ebx),%eax
  801dac:	85 c0                	test   %eax,%eax
  801dae:	74 6f                	je     801e1f <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801db0:	80 38 00             	cmpb   $0x0,(%eax)
  801db3:	75 4e                	jne    801e03 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801db5:	8b 0b                	mov    (%ebx),%ecx
  801db7:	83 39 01             	cmpl   $0x1,(%ecx)
  801dba:	74 55                	je     801e11 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801dbc:	8b 53 04             	mov    0x4(%ebx),%edx
  801dbf:	8b 42 04             	mov    0x4(%edx),%eax
  801dc2:	80 38 2d             	cmpb   $0x2d,(%eax)
  801dc5:	75 4a                	jne    801e11 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801dc7:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801dcb:	74 44                	je     801e11 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801dcd:	83 c0 01             	add    $0x1,%eax
  801dd0:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801dd3:	83 ec 04             	sub    $0x4,%esp
  801dd6:	8b 01                	mov    (%ecx),%eax
  801dd8:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801ddf:	50                   	push   %eax
  801de0:	8d 42 08             	lea    0x8(%edx),%eax
  801de3:	50                   	push   %eax
  801de4:	83 c2 04             	add    $0x4,%edx
  801de7:	52                   	push   %edx
  801de8:	e8 3d f5 ff ff       	call   80132a <memmove>
		(*args->argc)--;
  801ded:	8b 03                	mov    (%ebx),%eax
  801def:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801df2:	8b 43 08             	mov    0x8(%ebx),%eax
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	80 38 2d             	cmpb   $0x2d,(%eax)
  801dfb:	75 06                	jne    801e03 <argnext+0x6b>
  801dfd:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801e01:	74 0e                	je     801e11 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801e03:	8b 53 08             	mov    0x8(%ebx),%edx
  801e06:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801e09:	83 c2 01             	add    $0x1,%edx
  801e0c:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801e0f:	eb 13                	jmp    801e24 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801e11:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801e18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801e1d:	eb 05                	jmp    801e24 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801e1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801e24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e27:	c9                   	leave  
  801e28:	c3                   	ret    

00801e29 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	53                   	push   %ebx
  801e2d:	83 ec 04             	sub    $0x4,%esp
  801e30:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801e33:	8b 43 08             	mov    0x8(%ebx),%eax
  801e36:	85 c0                	test   %eax,%eax
  801e38:	74 58                	je     801e92 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801e3a:	80 38 00             	cmpb   $0x0,(%eax)
  801e3d:	74 0c                	je     801e4b <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801e3f:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801e42:	c7 43 08 41 36 80 00 	movl   $0x803641,0x8(%ebx)
  801e49:	eb 42                	jmp    801e8d <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801e4b:	8b 13                	mov    (%ebx),%edx
  801e4d:	83 3a 01             	cmpl   $0x1,(%edx)
  801e50:	7e 2d                	jle    801e7f <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801e52:	8b 43 04             	mov    0x4(%ebx),%eax
  801e55:	8b 48 04             	mov    0x4(%eax),%ecx
  801e58:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801e5b:	83 ec 04             	sub    $0x4,%esp
  801e5e:	8b 12                	mov    (%edx),%edx
  801e60:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801e67:	52                   	push   %edx
  801e68:	8d 50 08             	lea    0x8(%eax),%edx
  801e6b:	52                   	push   %edx
  801e6c:	83 c0 04             	add    $0x4,%eax
  801e6f:	50                   	push   %eax
  801e70:	e8 b5 f4 ff ff       	call   80132a <memmove>
		(*args->argc)--;
  801e75:	8b 03                	mov    (%ebx),%eax
  801e77:	83 28 01             	subl   $0x1,(%eax)
  801e7a:	83 c4 10             	add    $0x10,%esp
  801e7d:	eb 0e                	jmp    801e8d <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801e7f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801e86:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801e8d:	8b 43 0c             	mov    0xc(%ebx),%eax
  801e90:	eb 05                	jmp    801e97 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801e92:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801e97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e9a:	c9                   	leave  
  801e9b:	c3                   	ret    

00801e9c <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	83 ec 08             	sub    $0x8,%esp
  801ea2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801ea5:	8b 51 0c             	mov    0xc(%ecx),%edx
  801ea8:	89 d0                	mov    %edx,%eax
  801eaa:	85 d2                	test   %edx,%edx
  801eac:	75 0c                	jne    801eba <argvalue+0x1e>
  801eae:	83 ec 0c             	sub    $0xc,%esp
  801eb1:	51                   	push   %ecx
  801eb2:	e8 72 ff ff ff       	call   801e29 <argnextvalue>
  801eb7:	83 c4 10             	add    $0x10,%esp
}
  801eba:	c9                   	leave  
  801ebb:	c3                   	ret    

00801ebc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801ebf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec2:	05 00 00 00 30       	add    $0x30000000,%eax
  801ec7:	c1 e8 0c             	shr    $0xc,%eax
}
  801eca:	5d                   	pop    %ebp
  801ecb:	c3                   	ret    

00801ecc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed2:	05 00 00 00 30       	add    $0x30000000,%eax
  801ed7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801edc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801ee1:	5d                   	pop    %ebp
  801ee2:	c3                   	ret    

00801ee3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ee9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801eee:	89 c2                	mov    %eax,%edx
  801ef0:	c1 ea 16             	shr    $0x16,%edx
  801ef3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801efa:	f6 c2 01             	test   $0x1,%dl
  801efd:	74 11                	je     801f10 <fd_alloc+0x2d>
  801eff:	89 c2                	mov    %eax,%edx
  801f01:	c1 ea 0c             	shr    $0xc,%edx
  801f04:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801f0b:	f6 c2 01             	test   $0x1,%dl
  801f0e:	75 09                	jne    801f19 <fd_alloc+0x36>
			*fd_store = fd;
  801f10:	89 01                	mov    %eax,(%ecx)
			return 0;
  801f12:	b8 00 00 00 00       	mov    $0x0,%eax
  801f17:	eb 17                	jmp    801f30 <fd_alloc+0x4d>
  801f19:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801f1e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801f23:	75 c9                	jne    801eee <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801f25:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801f2b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    

00801f32 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801f38:	83 f8 1f             	cmp    $0x1f,%eax
  801f3b:	77 36                	ja     801f73 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801f3d:	c1 e0 0c             	shl    $0xc,%eax
  801f40:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801f45:	89 c2                	mov    %eax,%edx
  801f47:	c1 ea 16             	shr    $0x16,%edx
  801f4a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f51:	f6 c2 01             	test   $0x1,%dl
  801f54:	74 24                	je     801f7a <fd_lookup+0x48>
  801f56:	89 c2                	mov    %eax,%edx
  801f58:	c1 ea 0c             	shr    $0xc,%edx
  801f5b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801f62:	f6 c2 01             	test   $0x1,%dl
  801f65:	74 1a                	je     801f81 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801f67:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f6a:	89 02                	mov    %eax,(%edx)
	return 0;
  801f6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f71:	eb 13                	jmp    801f86 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801f73:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f78:	eb 0c                	jmp    801f86 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801f7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f7f:	eb 05                	jmp    801f86 <fd_lookup+0x54>
  801f81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    

00801f88 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	83 ec 08             	sub    $0x8,%esp
  801f8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f91:	ba 74 3d 80 00       	mov    $0x803d74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801f96:	eb 13                	jmp    801fab <dev_lookup+0x23>
  801f98:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801f9b:	39 08                	cmp    %ecx,(%eax)
  801f9d:	75 0c                	jne    801fab <dev_lookup+0x23>
			*dev = devtab[i];
  801f9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fa2:	89 01                	mov    %eax,(%ecx)
			return 0;
  801fa4:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa9:	eb 31                	jmp    801fdc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801fab:	8b 02                	mov    (%edx),%eax
  801fad:	85 c0                	test   %eax,%eax
  801faf:	75 e7                	jne    801f98 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801fb1:	a1 24 54 80 00       	mov    0x805424,%eax
  801fb6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801fbc:	83 ec 04             	sub    $0x4,%esp
  801fbf:	51                   	push   %ecx
  801fc0:	50                   	push   %eax
  801fc1:	68 f8 3c 80 00       	push   $0x803cf8
  801fc6:	e8 55 eb ff ff       	call   800b20 <cprintf>
	*dev = 0;
  801fcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801fd4:	83 c4 10             	add    $0x10,%esp
  801fd7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801fdc:	c9                   	leave  
  801fdd:	c3                   	ret    

00801fde <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	56                   	push   %esi
  801fe2:	53                   	push   %ebx
  801fe3:	83 ec 10             	sub    $0x10,%esp
  801fe6:	8b 75 08             	mov    0x8(%ebp),%esi
  801fe9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801fec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fef:	50                   	push   %eax
  801ff0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801ff6:	c1 e8 0c             	shr    $0xc,%eax
  801ff9:	50                   	push   %eax
  801ffa:	e8 33 ff ff ff       	call   801f32 <fd_lookup>
  801fff:	83 c4 08             	add    $0x8,%esp
  802002:	85 c0                	test   %eax,%eax
  802004:	78 05                	js     80200b <fd_close+0x2d>
	    || fd != fd2)
  802006:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802009:	74 0c                	je     802017 <fd_close+0x39>
		return (must_exist ? r : 0);
  80200b:	84 db                	test   %bl,%bl
  80200d:	ba 00 00 00 00       	mov    $0x0,%edx
  802012:	0f 44 c2             	cmove  %edx,%eax
  802015:	eb 41                	jmp    802058 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802017:	83 ec 08             	sub    $0x8,%esp
  80201a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80201d:	50                   	push   %eax
  80201e:	ff 36                	pushl  (%esi)
  802020:	e8 63 ff ff ff       	call   801f88 <dev_lookup>
  802025:	89 c3                	mov    %eax,%ebx
  802027:	83 c4 10             	add    $0x10,%esp
  80202a:	85 c0                	test   %eax,%eax
  80202c:	78 1a                	js     802048 <fd_close+0x6a>
		if (dev->dev_close)
  80202e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802031:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802034:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802039:	85 c0                	test   %eax,%eax
  80203b:	74 0b                	je     802048 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80203d:	83 ec 0c             	sub    $0xc,%esp
  802040:	56                   	push   %esi
  802041:	ff d0                	call   *%eax
  802043:	89 c3                	mov    %eax,%ebx
  802045:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802048:	83 ec 08             	sub    $0x8,%esp
  80204b:	56                   	push   %esi
  80204c:	6a 00                	push   $0x0
  80204e:	e8 cd f5 ff ff       	call   801620 <sys_page_unmap>
	return r;
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	89 d8                	mov    %ebx,%eax
}
  802058:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80205b:	5b                   	pop    %ebx
  80205c:	5e                   	pop    %esi
  80205d:	5d                   	pop    %ebp
  80205e:	c3                   	ret    

0080205f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80205f:	55                   	push   %ebp
  802060:	89 e5                	mov    %esp,%ebp
  802062:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802065:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802068:	50                   	push   %eax
  802069:	ff 75 08             	pushl  0x8(%ebp)
  80206c:	e8 c1 fe ff ff       	call   801f32 <fd_lookup>
  802071:	83 c4 08             	add    $0x8,%esp
  802074:	85 c0                	test   %eax,%eax
  802076:	78 10                	js     802088 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802078:	83 ec 08             	sub    $0x8,%esp
  80207b:	6a 01                	push   $0x1
  80207d:	ff 75 f4             	pushl  -0xc(%ebp)
  802080:	e8 59 ff ff ff       	call   801fde <fd_close>
  802085:	83 c4 10             	add    $0x10,%esp
}
  802088:	c9                   	leave  
  802089:	c3                   	ret    

0080208a <close_all>:

void
close_all(void)
{
  80208a:	55                   	push   %ebp
  80208b:	89 e5                	mov    %esp,%ebp
  80208d:	53                   	push   %ebx
  80208e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802091:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802096:	83 ec 0c             	sub    $0xc,%esp
  802099:	53                   	push   %ebx
  80209a:	e8 c0 ff ff ff       	call   80205f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80209f:	83 c3 01             	add    $0x1,%ebx
  8020a2:	83 c4 10             	add    $0x10,%esp
  8020a5:	83 fb 20             	cmp    $0x20,%ebx
  8020a8:	75 ec                	jne    802096 <close_all+0xc>
		close(i);
}
  8020aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ad:	c9                   	leave  
  8020ae:	c3                   	ret    

008020af <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	57                   	push   %edi
  8020b3:	56                   	push   %esi
  8020b4:	53                   	push   %ebx
  8020b5:	83 ec 2c             	sub    $0x2c,%esp
  8020b8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8020bb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8020be:	50                   	push   %eax
  8020bf:	ff 75 08             	pushl  0x8(%ebp)
  8020c2:	e8 6b fe ff ff       	call   801f32 <fd_lookup>
  8020c7:	83 c4 08             	add    $0x8,%esp
  8020ca:	85 c0                	test   %eax,%eax
  8020cc:	0f 88 c1 00 00 00    	js     802193 <dup+0xe4>
		return r;
	close(newfdnum);
  8020d2:	83 ec 0c             	sub    $0xc,%esp
  8020d5:	56                   	push   %esi
  8020d6:	e8 84 ff ff ff       	call   80205f <close>

	newfd = INDEX2FD(newfdnum);
  8020db:	89 f3                	mov    %esi,%ebx
  8020dd:	c1 e3 0c             	shl    $0xc,%ebx
  8020e0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8020e6:	83 c4 04             	add    $0x4,%esp
  8020e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020ec:	e8 db fd ff ff       	call   801ecc <fd2data>
  8020f1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8020f3:	89 1c 24             	mov    %ebx,(%esp)
  8020f6:	e8 d1 fd ff ff       	call   801ecc <fd2data>
  8020fb:	83 c4 10             	add    $0x10,%esp
  8020fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802101:	89 f8                	mov    %edi,%eax
  802103:	c1 e8 16             	shr    $0x16,%eax
  802106:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80210d:	a8 01                	test   $0x1,%al
  80210f:	74 37                	je     802148 <dup+0x99>
  802111:	89 f8                	mov    %edi,%eax
  802113:	c1 e8 0c             	shr    $0xc,%eax
  802116:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80211d:	f6 c2 01             	test   $0x1,%dl
  802120:	74 26                	je     802148 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802122:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802129:	83 ec 0c             	sub    $0xc,%esp
  80212c:	25 07 0e 00 00       	and    $0xe07,%eax
  802131:	50                   	push   %eax
  802132:	ff 75 d4             	pushl  -0x2c(%ebp)
  802135:	6a 00                	push   $0x0
  802137:	57                   	push   %edi
  802138:	6a 00                	push   $0x0
  80213a:	e8 9f f4 ff ff       	call   8015de <sys_page_map>
  80213f:	89 c7                	mov    %eax,%edi
  802141:	83 c4 20             	add    $0x20,%esp
  802144:	85 c0                	test   %eax,%eax
  802146:	78 2e                	js     802176 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802148:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80214b:	89 d0                	mov    %edx,%eax
  80214d:	c1 e8 0c             	shr    $0xc,%eax
  802150:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802157:	83 ec 0c             	sub    $0xc,%esp
  80215a:	25 07 0e 00 00       	and    $0xe07,%eax
  80215f:	50                   	push   %eax
  802160:	53                   	push   %ebx
  802161:	6a 00                	push   $0x0
  802163:	52                   	push   %edx
  802164:	6a 00                	push   $0x0
  802166:	e8 73 f4 ff ff       	call   8015de <sys_page_map>
  80216b:	89 c7                	mov    %eax,%edi
  80216d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802170:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802172:	85 ff                	test   %edi,%edi
  802174:	79 1d                	jns    802193 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802176:	83 ec 08             	sub    $0x8,%esp
  802179:	53                   	push   %ebx
  80217a:	6a 00                	push   $0x0
  80217c:	e8 9f f4 ff ff       	call   801620 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802181:	83 c4 08             	add    $0x8,%esp
  802184:	ff 75 d4             	pushl  -0x2c(%ebp)
  802187:	6a 00                	push   $0x0
  802189:	e8 92 f4 ff ff       	call   801620 <sys_page_unmap>
	return r;
  80218e:	83 c4 10             	add    $0x10,%esp
  802191:	89 f8                	mov    %edi,%eax
}
  802193:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802196:	5b                   	pop    %ebx
  802197:	5e                   	pop    %esi
  802198:	5f                   	pop    %edi
  802199:	5d                   	pop    %ebp
  80219a:	c3                   	ret    

0080219b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80219b:	55                   	push   %ebp
  80219c:	89 e5                	mov    %esp,%ebp
  80219e:	53                   	push   %ebx
  80219f:	83 ec 14             	sub    $0x14,%esp
  8021a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8021a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021a8:	50                   	push   %eax
  8021a9:	53                   	push   %ebx
  8021aa:	e8 83 fd ff ff       	call   801f32 <fd_lookup>
  8021af:	83 c4 08             	add    $0x8,%esp
  8021b2:	89 c2                	mov    %eax,%edx
  8021b4:	85 c0                	test   %eax,%eax
  8021b6:	78 70                	js     802228 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021b8:	83 ec 08             	sub    $0x8,%esp
  8021bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021be:	50                   	push   %eax
  8021bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021c2:	ff 30                	pushl  (%eax)
  8021c4:	e8 bf fd ff ff       	call   801f88 <dev_lookup>
  8021c9:	83 c4 10             	add    $0x10,%esp
  8021cc:	85 c0                	test   %eax,%eax
  8021ce:	78 4f                	js     80221f <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8021d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021d3:	8b 42 08             	mov    0x8(%edx),%eax
  8021d6:	83 e0 03             	and    $0x3,%eax
  8021d9:	83 f8 01             	cmp    $0x1,%eax
  8021dc:	75 24                	jne    802202 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8021de:	a1 24 54 80 00       	mov    0x805424,%eax
  8021e3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8021e9:	83 ec 04             	sub    $0x4,%esp
  8021ec:	53                   	push   %ebx
  8021ed:	50                   	push   %eax
  8021ee:	68 39 3d 80 00       	push   $0x803d39
  8021f3:	e8 28 e9 ff ff       	call   800b20 <cprintf>
		return -E_INVAL;
  8021f8:	83 c4 10             	add    $0x10,%esp
  8021fb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802200:	eb 26                	jmp    802228 <read+0x8d>
	}
	if (!dev->dev_read)
  802202:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802205:	8b 40 08             	mov    0x8(%eax),%eax
  802208:	85 c0                	test   %eax,%eax
  80220a:	74 17                	je     802223 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80220c:	83 ec 04             	sub    $0x4,%esp
  80220f:	ff 75 10             	pushl  0x10(%ebp)
  802212:	ff 75 0c             	pushl  0xc(%ebp)
  802215:	52                   	push   %edx
  802216:	ff d0                	call   *%eax
  802218:	89 c2                	mov    %eax,%edx
  80221a:	83 c4 10             	add    $0x10,%esp
  80221d:	eb 09                	jmp    802228 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80221f:	89 c2                	mov    %eax,%edx
  802221:	eb 05                	jmp    802228 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802223:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  802228:	89 d0                	mov    %edx,%eax
  80222a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80222d:	c9                   	leave  
  80222e:	c3                   	ret    

0080222f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80222f:	55                   	push   %ebp
  802230:	89 e5                	mov    %esp,%ebp
  802232:	57                   	push   %edi
  802233:	56                   	push   %esi
  802234:	53                   	push   %ebx
  802235:	83 ec 0c             	sub    $0xc,%esp
  802238:	8b 7d 08             	mov    0x8(%ebp),%edi
  80223b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80223e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802243:	eb 21                	jmp    802266 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802245:	83 ec 04             	sub    $0x4,%esp
  802248:	89 f0                	mov    %esi,%eax
  80224a:	29 d8                	sub    %ebx,%eax
  80224c:	50                   	push   %eax
  80224d:	89 d8                	mov    %ebx,%eax
  80224f:	03 45 0c             	add    0xc(%ebp),%eax
  802252:	50                   	push   %eax
  802253:	57                   	push   %edi
  802254:	e8 42 ff ff ff       	call   80219b <read>
		if (m < 0)
  802259:	83 c4 10             	add    $0x10,%esp
  80225c:	85 c0                	test   %eax,%eax
  80225e:	78 10                	js     802270 <readn+0x41>
			return m;
		if (m == 0)
  802260:	85 c0                	test   %eax,%eax
  802262:	74 0a                	je     80226e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802264:	01 c3                	add    %eax,%ebx
  802266:	39 f3                	cmp    %esi,%ebx
  802268:	72 db                	jb     802245 <readn+0x16>
  80226a:	89 d8                	mov    %ebx,%eax
  80226c:	eb 02                	jmp    802270 <readn+0x41>
  80226e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802270:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802273:	5b                   	pop    %ebx
  802274:	5e                   	pop    %esi
  802275:	5f                   	pop    %edi
  802276:	5d                   	pop    %ebp
  802277:	c3                   	ret    

00802278 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802278:	55                   	push   %ebp
  802279:	89 e5                	mov    %esp,%ebp
  80227b:	53                   	push   %ebx
  80227c:	83 ec 14             	sub    $0x14,%esp
  80227f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802282:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802285:	50                   	push   %eax
  802286:	53                   	push   %ebx
  802287:	e8 a6 fc ff ff       	call   801f32 <fd_lookup>
  80228c:	83 c4 08             	add    $0x8,%esp
  80228f:	89 c2                	mov    %eax,%edx
  802291:	85 c0                	test   %eax,%eax
  802293:	78 6b                	js     802300 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802295:	83 ec 08             	sub    $0x8,%esp
  802298:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80229b:	50                   	push   %eax
  80229c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80229f:	ff 30                	pushl  (%eax)
  8022a1:	e8 e2 fc ff ff       	call   801f88 <dev_lookup>
  8022a6:	83 c4 10             	add    $0x10,%esp
  8022a9:	85 c0                	test   %eax,%eax
  8022ab:	78 4a                	js     8022f7 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8022ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022b0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8022b4:	75 24                	jne    8022da <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8022b6:	a1 24 54 80 00       	mov    0x805424,%eax
  8022bb:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8022c1:	83 ec 04             	sub    $0x4,%esp
  8022c4:	53                   	push   %ebx
  8022c5:	50                   	push   %eax
  8022c6:	68 55 3d 80 00       	push   $0x803d55
  8022cb:	e8 50 e8 ff ff       	call   800b20 <cprintf>
		return -E_INVAL;
  8022d0:	83 c4 10             	add    $0x10,%esp
  8022d3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8022d8:	eb 26                	jmp    802300 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8022da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022dd:	8b 52 0c             	mov    0xc(%edx),%edx
  8022e0:	85 d2                	test   %edx,%edx
  8022e2:	74 17                	je     8022fb <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8022e4:	83 ec 04             	sub    $0x4,%esp
  8022e7:	ff 75 10             	pushl  0x10(%ebp)
  8022ea:	ff 75 0c             	pushl  0xc(%ebp)
  8022ed:	50                   	push   %eax
  8022ee:	ff d2                	call   *%edx
  8022f0:	89 c2                	mov    %eax,%edx
  8022f2:	83 c4 10             	add    $0x10,%esp
  8022f5:	eb 09                	jmp    802300 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8022f7:	89 c2                	mov    %eax,%edx
  8022f9:	eb 05                	jmp    802300 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8022fb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802300:	89 d0                	mov    %edx,%eax
  802302:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802305:	c9                   	leave  
  802306:	c3                   	ret    

00802307 <seek>:

int
seek(int fdnum, off_t offset)
{
  802307:	55                   	push   %ebp
  802308:	89 e5                	mov    %esp,%ebp
  80230a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80230d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802310:	50                   	push   %eax
  802311:	ff 75 08             	pushl  0x8(%ebp)
  802314:	e8 19 fc ff ff       	call   801f32 <fd_lookup>
  802319:	83 c4 08             	add    $0x8,%esp
  80231c:	85 c0                	test   %eax,%eax
  80231e:	78 0e                	js     80232e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802320:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802323:	8b 55 0c             	mov    0xc(%ebp),%edx
  802326:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802329:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80232e:	c9                   	leave  
  80232f:	c3                   	ret    

00802330 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
  802333:	53                   	push   %ebx
  802334:	83 ec 14             	sub    $0x14,%esp
  802337:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80233a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80233d:	50                   	push   %eax
  80233e:	53                   	push   %ebx
  80233f:	e8 ee fb ff ff       	call   801f32 <fd_lookup>
  802344:	83 c4 08             	add    $0x8,%esp
  802347:	89 c2                	mov    %eax,%edx
  802349:	85 c0                	test   %eax,%eax
  80234b:	78 68                	js     8023b5 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80234d:	83 ec 08             	sub    $0x8,%esp
  802350:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802353:	50                   	push   %eax
  802354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802357:	ff 30                	pushl  (%eax)
  802359:	e8 2a fc ff ff       	call   801f88 <dev_lookup>
  80235e:	83 c4 10             	add    $0x10,%esp
  802361:	85 c0                	test   %eax,%eax
  802363:	78 47                	js     8023ac <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802365:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802368:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80236c:	75 24                	jne    802392 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80236e:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802373:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802379:	83 ec 04             	sub    $0x4,%esp
  80237c:	53                   	push   %ebx
  80237d:	50                   	push   %eax
  80237e:	68 18 3d 80 00       	push   $0x803d18
  802383:	e8 98 e7 ff ff       	call   800b20 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802388:	83 c4 10             	add    $0x10,%esp
  80238b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802390:	eb 23                	jmp    8023b5 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  802392:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802395:	8b 52 18             	mov    0x18(%edx),%edx
  802398:	85 d2                	test   %edx,%edx
  80239a:	74 14                	je     8023b0 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80239c:	83 ec 08             	sub    $0x8,%esp
  80239f:	ff 75 0c             	pushl  0xc(%ebp)
  8023a2:	50                   	push   %eax
  8023a3:	ff d2                	call   *%edx
  8023a5:	89 c2                	mov    %eax,%edx
  8023a7:	83 c4 10             	add    $0x10,%esp
  8023aa:	eb 09                	jmp    8023b5 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8023ac:	89 c2                	mov    %eax,%edx
  8023ae:	eb 05                	jmp    8023b5 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8023b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8023b5:	89 d0                	mov    %edx,%eax
  8023b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023ba:	c9                   	leave  
  8023bb:	c3                   	ret    

008023bc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8023bc:	55                   	push   %ebp
  8023bd:	89 e5                	mov    %esp,%ebp
  8023bf:	53                   	push   %ebx
  8023c0:	83 ec 14             	sub    $0x14,%esp
  8023c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8023c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8023c9:	50                   	push   %eax
  8023ca:	ff 75 08             	pushl  0x8(%ebp)
  8023cd:	e8 60 fb ff ff       	call   801f32 <fd_lookup>
  8023d2:	83 c4 08             	add    $0x8,%esp
  8023d5:	89 c2                	mov    %eax,%edx
  8023d7:	85 c0                	test   %eax,%eax
  8023d9:	78 58                	js     802433 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8023db:	83 ec 08             	sub    $0x8,%esp
  8023de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023e1:	50                   	push   %eax
  8023e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023e5:	ff 30                	pushl  (%eax)
  8023e7:	e8 9c fb ff ff       	call   801f88 <dev_lookup>
  8023ec:	83 c4 10             	add    $0x10,%esp
  8023ef:	85 c0                	test   %eax,%eax
  8023f1:	78 37                	js     80242a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8023f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8023fa:	74 32                	je     80242e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8023fc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8023ff:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802406:	00 00 00 
	stat->st_isdir = 0;
  802409:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802410:	00 00 00 
	stat->st_dev = dev;
  802413:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802419:	83 ec 08             	sub    $0x8,%esp
  80241c:	53                   	push   %ebx
  80241d:	ff 75 f0             	pushl  -0x10(%ebp)
  802420:	ff 50 14             	call   *0x14(%eax)
  802423:	89 c2                	mov    %eax,%edx
  802425:	83 c4 10             	add    $0x10,%esp
  802428:	eb 09                	jmp    802433 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80242a:	89 c2                	mov    %eax,%edx
  80242c:	eb 05                	jmp    802433 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80242e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802433:	89 d0                	mov    %edx,%eax
  802435:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802438:	c9                   	leave  
  802439:	c3                   	ret    

0080243a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80243a:	55                   	push   %ebp
  80243b:	89 e5                	mov    %esp,%ebp
  80243d:	56                   	push   %esi
  80243e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80243f:	83 ec 08             	sub    $0x8,%esp
  802442:	6a 00                	push   $0x0
  802444:	ff 75 08             	pushl  0x8(%ebp)
  802447:	e8 e3 01 00 00       	call   80262f <open>
  80244c:	89 c3                	mov    %eax,%ebx
  80244e:	83 c4 10             	add    $0x10,%esp
  802451:	85 c0                	test   %eax,%eax
  802453:	78 1b                	js     802470 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802455:	83 ec 08             	sub    $0x8,%esp
  802458:	ff 75 0c             	pushl  0xc(%ebp)
  80245b:	50                   	push   %eax
  80245c:	e8 5b ff ff ff       	call   8023bc <fstat>
  802461:	89 c6                	mov    %eax,%esi
	close(fd);
  802463:	89 1c 24             	mov    %ebx,(%esp)
  802466:	e8 f4 fb ff ff       	call   80205f <close>
	return r;
  80246b:	83 c4 10             	add    $0x10,%esp
  80246e:	89 f0                	mov    %esi,%eax
}
  802470:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802473:	5b                   	pop    %ebx
  802474:	5e                   	pop    %esi
  802475:	5d                   	pop    %ebp
  802476:	c3                   	ret    

00802477 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802477:	55                   	push   %ebp
  802478:	89 e5                	mov    %esp,%ebp
  80247a:	56                   	push   %esi
  80247b:	53                   	push   %ebx
  80247c:	89 c6                	mov    %eax,%esi
  80247e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802480:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802487:	75 12                	jne    80249b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802489:	83 ec 0c             	sub    $0xc,%esp
  80248c:	6a 01                	push   $0x1
  80248e:	e8 5e 0e 00 00       	call   8032f1 <ipc_find_env>
  802493:	a3 20 54 80 00       	mov    %eax,0x805420
  802498:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80249b:	6a 07                	push   $0x7
  80249d:	68 00 60 80 00       	push   $0x806000
  8024a2:	56                   	push   %esi
  8024a3:	ff 35 20 54 80 00    	pushl  0x805420
  8024a9:	e8 e1 0d 00 00       	call   80328f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8024ae:	83 c4 0c             	add    $0xc,%esp
  8024b1:	6a 00                	push   $0x0
  8024b3:	53                   	push   %ebx
  8024b4:	6a 00                	push   $0x0
  8024b6:	e8 59 0d 00 00       	call   803214 <ipc_recv>
}
  8024bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024be:	5b                   	pop    %ebx
  8024bf:	5e                   	pop    %esi
  8024c0:	5d                   	pop    %ebp
  8024c1:	c3                   	ret    

008024c2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8024c2:	55                   	push   %ebp
  8024c3:	89 e5                	mov    %esp,%ebp
  8024c5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8024c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8024cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8024ce:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8024d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024d6:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8024db:	ba 00 00 00 00       	mov    $0x0,%edx
  8024e0:	b8 02 00 00 00       	mov    $0x2,%eax
  8024e5:	e8 8d ff ff ff       	call   802477 <fsipc>
}
  8024ea:	c9                   	leave  
  8024eb:	c3                   	ret    

008024ec <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8024ec:	55                   	push   %ebp
  8024ed:	89 e5                	mov    %esp,%ebp
  8024ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8024f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8024f8:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8024fd:	ba 00 00 00 00       	mov    $0x0,%edx
  802502:	b8 06 00 00 00       	mov    $0x6,%eax
  802507:	e8 6b ff ff ff       	call   802477 <fsipc>
}
  80250c:	c9                   	leave  
  80250d:	c3                   	ret    

0080250e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80250e:	55                   	push   %ebp
  80250f:	89 e5                	mov    %esp,%ebp
  802511:	53                   	push   %ebx
  802512:	83 ec 04             	sub    $0x4,%esp
  802515:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802518:	8b 45 08             	mov    0x8(%ebp),%eax
  80251b:	8b 40 0c             	mov    0xc(%eax),%eax
  80251e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802523:	ba 00 00 00 00       	mov    $0x0,%edx
  802528:	b8 05 00 00 00       	mov    $0x5,%eax
  80252d:	e8 45 ff ff ff       	call   802477 <fsipc>
  802532:	85 c0                	test   %eax,%eax
  802534:	78 2c                	js     802562 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802536:	83 ec 08             	sub    $0x8,%esp
  802539:	68 00 60 80 00       	push   $0x806000
  80253e:	53                   	push   %ebx
  80253f:	e8 54 ec ff ff       	call   801198 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802544:	a1 80 60 80 00       	mov    0x806080,%eax
  802549:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80254f:	a1 84 60 80 00       	mov    0x806084,%eax
  802554:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80255a:	83 c4 10             	add    $0x10,%esp
  80255d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802562:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802565:	c9                   	leave  
  802566:	c3                   	ret    

00802567 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802567:	55                   	push   %ebp
  802568:	89 e5                	mov    %esp,%ebp
  80256a:	83 ec 0c             	sub    $0xc,%esp
  80256d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802570:	8b 55 08             	mov    0x8(%ebp),%edx
  802573:	8b 52 0c             	mov    0xc(%edx),%edx
  802576:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80257c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802581:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802586:	0f 47 c2             	cmova  %edx,%eax
  802589:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80258e:	50                   	push   %eax
  80258f:	ff 75 0c             	pushl  0xc(%ebp)
  802592:	68 08 60 80 00       	push   $0x806008
  802597:	e8 8e ed ff ff       	call   80132a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80259c:	ba 00 00 00 00       	mov    $0x0,%edx
  8025a1:	b8 04 00 00 00       	mov    $0x4,%eax
  8025a6:	e8 cc fe ff ff       	call   802477 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8025ab:	c9                   	leave  
  8025ac:	c3                   	ret    

008025ad <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8025ad:	55                   	push   %ebp
  8025ae:	89 e5                	mov    %esp,%ebp
  8025b0:	56                   	push   %esi
  8025b1:	53                   	push   %ebx
  8025b2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8025b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8025b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8025bb:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8025c0:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8025c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8025cb:	b8 03 00 00 00       	mov    $0x3,%eax
  8025d0:	e8 a2 fe ff ff       	call   802477 <fsipc>
  8025d5:	89 c3                	mov    %eax,%ebx
  8025d7:	85 c0                	test   %eax,%eax
  8025d9:	78 4b                	js     802626 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8025db:	39 c6                	cmp    %eax,%esi
  8025dd:	73 16                	jae    8025f5 <devfile_read+0x48>
  8025df:	68 84 3d 80 00       	push   $0x803d84
  8025e4:	68 6f 37 80 00       	push   $0x80376f
  8025e9:	6a 7c                	push   $0x7c
  8025eb:	68 8b 3d 80 00       	push   $0x803d8b
  8025f0:	e8 52 e4 ff ff       	call   800a47 <_panic>
	assert(r <= PGSIZE);
  8025f5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8025fa:	7e 16                	jle    802612 <devfile_read+0x65>
  8025fc:	68 96 3d 80 00       	push   $0x803d96
  802601:	68 6f 37 80 00       	push   $0x80376f
  802606:	6a 7d                	push   $0x7d
  802608:	68 8b 3d 80 00       	push   $0x803d8b
  80260d:	e8 35 e4 ff ff       	call   800a47 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802612:	83 ec 04             	sub    $0x4,%esp
  802615:	50                   	push   %eax
  802616:	68 00 60 80 00       	push   $0x806000
  80261b:	ff 75 0c             	pushl  0xc(%ebp)
  80261e:	e8 07 ed ff ff       	call   80132a <memmove>
	return r;
  802623:	83 c4 10             	add    $0x10,%esp
}
  802626:	89 d8                	mov    %ebx,%eax
  802628:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80262b:	5b                   	pop    %ebx
  80262c:	5e                   	pop    %esi
  80262d:	5d                   	pop    %ebp
  80262e:	c3                   	ret    

0080262f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80262f:	55                   	push   %ebp
  802630:	89 e5                	mov    %esp,%ebp
  802632:	53                   	push   %ebx
  802633:	83 ec 20             	sub    $0x20,%esp
  802636:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802639:	53                   	push   %ebx
  80263a:	e8 20 eb ff ff       	call   80115f <strlen>
  80263f:	83 c4 10             	add    $0x10,%esp
  802642:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802647:	7f 67                	jg     8026b0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802649:	83 ec 0c             	sub    $0xc,%esp
  80264c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80264f:	50                   	push   %eax
  802650:	e8 8e f8 ff ff       	call   801ee3 <fd_alloc>
  802655:	83 c4 10             	add    $0x10,%esp
		return r;
  802658:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80265a:	85 c0                	test   %eax,%eax
  80265c:	78 57                	js     8026b5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80265e:	83 ec 08             	sub    $0x8,%esp
  802661:	53                   	push   %ebx
  802662:	68 00 60 80 00       	push   $0x806000
  802667:	e8 2c eb ff ff       	call   801198 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80266c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80266f:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802674:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802677:	b8 01 00 00 00       	mov    $0x1,%eax
  80267c:	e8 f6 fd ff ff       	call   802477 <fsipc>
  802681:	89 c3                	mov    %eax,%ebx
  802683:	83 c4 10             	add    $0x10,%esp
  802686:	85 c0                	test   %eax,%eax
  802688:	79 14                	jns    80269e <open+0x6f>
		fd_close(fd, 0);
  80268a:	83 ec 08             	sub    $0x8,%esp
  80268d:	6a 00                	push   $0x0
  80268f:	ff 75 f4             	pushl  -0xc(%ebp)
  802692:	e8 47 f9 ff ff       	call   801fde <fd_close>
		return r;
  802697:	83 c4 10             	add    $0x10,%esp
  80269a:	89 da                	mov    %ebx,%edx
  80269c:	eb 17                	jmp    8026b5 <open+0x86>
	}

	return fd2num(fd);
  80269e:	83 ec 0c             	sub    $0xc,%esp
  8026a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8026a4:	e8 13 f8 ff ff       	call   801ebc <fd2num>
  8026a9:	89 c2                	mov    %eax,%edx
  8026ab:	83 c4 10             	add    $0x10,%esp
  8026ae:	eb 05                	jmp    8026b5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8026b0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8026b5:	89 d0                	mov    %edx,%eax
  8026b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8026ba:	c9                   	leave  
  8026bb:	c3                   	ret    

008026bc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8026bc:	55                   	push   %ebp
  8026bd:	89 e5                	mov    %esp,%ebp
  8026bf:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8026c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8026c7:	b8 08 00 00 00       	mov    $0x8,%eax
  8026cc:	e8 a6 fd ff ff       	call   802477 <fsipc>
}
  8026d1:	c9                   	leave  
  8026d2:	c3                   	ret    

008026d3 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8026d3:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8026d7:	7e 37                	jle    802710 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8026d9:	55                   	push   %ebp
  8026da:	89 e5                	mov    %esp,%ebp
  8026dc:	53                   	push   %ebx
  8026dd:	83 ec 08             	sub    $0x8,%esp
  8026e0:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8026e2:	ff 70 04             	pushl  0x4(%eax)
  8026e5:	8d 40 10             	lea    0x10(%eax),%eax
  8026e8:	50                   	push   %eax
  8026e9:	ff 33                	pushl  (%ebx)
  8026eb:	e8 88 fb ff ff       	call   802278 <write>
		if (result > 0)
  8026f0:	83 c4 10             	add    $0x10,%esp
  8026f3:	85 c0                	test   %eax,%eax
  8026f5:	7e 03                	jle    8026fa <writebuf+0x27>
			b->result += result;
  8026f7:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8026fa:	3b 43 04             	cmp    0x4(%ebx),%eax
  8026fd:	74 0d                	je     80270c <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8026ff:	85 c0                	test   %eax,%eax
  802701:	ba 00 00 00 00       	mov    $0x0,%edx
  802706:	0f 4f c2             	cmovg  %edx,%eax
  802709:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80270c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80270f:	c9                   	leave  
  802710:	f3 c3                	repz ret 

00802712 <putch>:

static void
putch(int ch, void *thunk)
{
  802712:	55                   	push   %ebp
  802713:	89 e5                	mov    %esp,%ebp
  802715:	53                   	push   %ebx
  802716:	83 ec 04             	sub    $0x4,%esp
  802719:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80271c:	8b 53 04             	mov    0x4(%ebx),%edx
  80271f:	8d 42 01             	lea    0x1(%edx),%eax
  802722:	89 43 04             	mov    %eax,0x4(%ebx)
  802725:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802728:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80272c:	3d 00 01 00 00       	cmp    $0x100,%eax
  802731:	75 0e                	jne    802741 <putch+0x2f>
		writebuf(b);
  802733:	89 d8                	mov    %ebx,%eax
  802735:	e8 99 ff ff ff       	call   8026d3 <writebuf>
		b->idx = 0;
  80273a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802741:	83 c4 04             	add    $0x4,%esp
  802744:	5b                   	pop    %ebx
  802745:	5d                   	pop    %ebp
  802746:	c3                   	ret    

00802747 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802747:	55                   	push   %ebp
  802748:	89 e5                	mov    %esp,%ebp
  80274a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802750:	8b 45 08             	mov    0x8(%ebp),%eax
  802753:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802759:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802760:	00 00 00 
	b.result = 0;
  802763:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80276a:	00 00 00 
	b.error = 1;
  80276d:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802774:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802777:	ff 75 10             	pushl  0x10(%ebp)
  80277a:	ff 75 0c             	pushl  0xc(%ebp)
  80277d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802783:	50                   	push   %eax
  802784:	68 12 27 80 00       	push   $0x802712
  802789:	e8 c9 e4 ff ff       	call   800c57 <vprintfmt>
	if (b.idx > 0)
  80278e:	83 c4 10             	add    $0x10,%esp
  802791:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802798:	7e 0b                	jle    8027a5 <vfprintf+0x5e>
		writebuf(&b);
  80279a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8027a0:	e8 2e ff ff ff       	call   8026d3 <writebuf>

	return (b.result ? b.result : b.error);
  8027a5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8027ab:	85 c0                	test   %eax,%eax
  8027ad:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8027b4:	c9                   	leave  
  8027b5:	c3                   	ret    

008027b6 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8027b6:	55                   	push   %ebp
  8027b7:	89 e5                	mov    %esp,%ebp
  8027b9:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8027bc:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8027bf:	50                   	push   %eax
  8027c0:	ff 75 0c             	pushl  0xc(%ebp)
  8027c3:	ff 75 08             	pushl  0x8(%ebp)
  8027c6:	e8 7c ff ff ff       	call   802747 <vfprintf>
	va_end(ap);

	return cnt;
}
  8027cb:	c9                   	leave  
  8027cc:	c3                   	ret    

008027cd <printf>:

int
printf(const char *fmt, ...)
{
  8027cd:	55                   	push   %ebp
  8027ce:	89 e5                	mov    %esp,%ebp
  8027d0:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8027d3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8027d6:	50                   	push   %eax
  8027d7:	ff 75 08             	pushl  0x8(%ebp)
  8027da:	6a 01                	push   $0x1
  8027dc:	e8 66 ff ff ff       	call   802747 <vfprintf>
	va_end(ap);

	return cnt;
}
  8027e1:	c9                   	leave  
  8027e2:	c3                   	ret    

008027e3 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8027e3:	55                   	push   %ebp
  8027e4:	89 e5                	mov    %esp,%ebp
  8027e6:	57                   	push   %edi
  8027e7:	56                   	push   %esi
  8027e8:	53                   	push   %ebx
  8027e9:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8027ef:	6a 00                	push   $0x0
  8027f1:	ff 75 08             	pushl  0x8(%ebp)
  8027f4:	e8 36 fe ff ff       	call   80262f <open>
  8027f9:	89 c7                	mov    %eax,%edi
  8027fb:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802801:	83 c4 10             	add    $0x10,%esp
  802804:	85 c0                	test   %eax,%eax
  802806:	0f 88 8c 04 00 00    	js     802c98 <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80280c:	83 ec 04             	sub    $0x4,%esp
  80280f:	68 00 02 00 00       	push   $0x200
  802814:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80281a:	50                   	push   %eax
  80281b:	57                   	push   %edi
  80281c:	e8 0e fa ff ff       	call   80222f <readn>
  802821:	83 c4 10             	add    $0x10,%esp
  802824:	3d 00 02 00 00       	cmp    $0x200,%eax
  802829:	75 0c                	jne    802837 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80282b:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802832:	45 4c 46 
  802835:	74 33                	je     80286a <spawn+0x87>
		close(fd);
  802837:	83 ec 0c             	sub    $0xc,%esp
  80283a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802840:	e8 1a f8 ff ff       	call   80205f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802845:	83 c4 0c             	add    $0xc,%esp
  802848:	68 7f 45 4c 46       	push   $0x464c457f
  80284d:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802853:	68 a2 3d 80 00       	push   $0x803da2
  802858:	e8 c3 e2 ff ff       	call   800b20 <cprintf>
		return -E_NOT_EXEC;
  80285d:	83 c4 10             	add    $0x10,%esp
  802860:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  802865:	e9 e1 04 00 00       	jmp    802d4b <spawn+0x568>
  80286a:	b8 07 00 00 00       	mov    $0x7,%eax
  80286f:	cd 30                	int    $0x30
  802871:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802877:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80287d:	85 c0                	test   %eax,%eax
  80287f:	0f 88 1e 04 00 00    	js     802ca3 <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802885:	89 c6                	mov    %eax,%esi
  802887:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80288d:	69 f6 d8 00 00 00    	imul   $0xd8,%esi,%esi
  802893:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802899:	81 c6 59 00 c0 ee    	add    $0xeec00059,%esi
  80289f:	b9 11 00 00 00       	mov    $0x11,%ecx
  8028a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8028a6:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8028ac:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8028b2:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8028b7:	be 00 00 00 00       	mov    $0x0,%esi
  8028bc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8028bf:	eb 13                	jmp    8028d4 <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8028c1:	83 ec 0c             	sub    $0xc,%esp
  8028c4:	50                   	push   %eax
  8028c5:	e8 95 e8 ff ff       	call   80115f <strlen>
  8028ca:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8028ce:	83 c3 01             	add    $0x1,%ebx
  8028d1:	83 c4 10             	add    $0x10,%esp
  8028d4:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8028db:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8028de:	85 c0                	test   %eax,%eax
  8028e0:	75 df                	jne    8028c1 <spawn+0xde>
  8028e2:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8028e8:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8028ee:	bf 00 10 40 00       	mov    $0x401000,%edi
  8028f3:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8028f5:	89 fa                	mov    %edi,%edx
  8028f7:	83 e2 fc             	and    $0xfffffffc,%edx
  8028fa:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  802901:	29 c2                	sub    %eax,%edx
  802903:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802909:	8d 42 f8             	lea    -0x8(%edx),%eax
  80290c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802911:	0f 86 a2 03 00 00    	jbe    802cb9 <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802917:	83 ec 04             	sub    $0x4,%esp
  80291a:	6a 07                	push   $0x7
  80291c:	68 00 00 40 00       	push   $0x400000
  802921:	6a 00                	push   $0x0
  802923:	e8 73 ec ff ff       	call   80159b <sys_page_alloc>
  802928:	83 c4 10             	add    $0x10,%esp
  80292b:	85 c0                	test   %eax,%eax
  80292d:	0f 88 90 03 00 00    	js     802cc3 <spawn+0x4e0>
  802933:	be 00 00 00 00       	mov    $0x0,%esi
  802938:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80293e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802941:	eb 30                	jmp    802973 <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802943:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802949:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80294f:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  802952:	83 ec 08             	sub    $0x8,%esp
  802955:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802958:	57                   	push   %edi
  802959:	e8 3a e8 ff ff       	call   801198 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80295e:	83 c4 04             	add    $0x4,%esp
  802961:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802964:	e8 f6 e7 ff ff       	call   80115f <strlen>
  802969:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80296d:	83 c6 01             	add    $0x1,%esi
  802970:	83 c4 10             	add    $0x10,%esp
  802973:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802979:	7f c8                	jg     802943 <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80297b:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802981:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  802987:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80298e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802994:	74 19                	je     8029af <spawn+0x1cc>
  802996:	68 2c 3e 80 00       	push   $0x803e2c
  80299b:	68 6f 37 80 00       	push   $0x80376f
  8029a0:	68 f2 00 00 00       	push   $0xf2
  8029a5:	68 bc 3d 80 00       	push   $0x803dbc
  8029aa:	e8 98 e0 ff ff       	call   800a47 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8029af:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8029b5:	89 f8                	mov    %edi,%eax
  8029b7:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8029bc:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8029bf:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8029c5:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8029c8:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8029ce:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8029d4:	83 ec 0c             	sub    $0xc,%esp
  8029d7:	6a 07                	push   $0x7
  8029d9:	68 00 d0 bf ee       	push   $0xeebfd000
  8029de:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029e4:	68 00 00 40 00       	push   $0x400000
  8029e9:	6a 00                	push   $0x0
  8029eb:	e8 ee eb ff ff       	call   8015de <sys_page_map>
  8029f0:	89 c3                	mov    %eax,%ebx
  8029f2:	83 c4 20             	add    $0x20,%esp
  8029f5:	85 c0                	test   %eax,%eax
  8029f7:	0f 88 3c 03 00 00    	js     802d39 <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8029fd:	83 ec 08             	sub    $0x8,%esp
  802a00:	68 00 00 40 00       	push   $0x400000
  802a05:	6a 00                	push   $0x0
  802a07:	e8 14 ec ff ff       	call   801620 <sys_page_unmap>
  802a0c:	89 c3                	mov    %eax,%ebx
  802a0e:	83 c4 10             	add    $0x10,%esp
  802a11:	85 c0                	test   %eax,%eax
  802a13:	0f 88 20 03 00 00    	js     802d39 <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802a19:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802a1f:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802a26:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802a2c:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802a33:	00 00 00 
  802a36:	e9 88 01 00 00       	jmp    802bc3 <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  802a3b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802a41:	83 38 01             	cmpl   $0x1,(%eax)
  802a44:	0f 85 6b 01 00 00    	jne    802bb5 <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802a4a:	89 c2                	mov    %eax,%edx
  802a4c:	8b 40 18             	mov    0x18(%eax),%eax
  802a4f:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802a55:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802a58:	83 f8 01             	cmp    $0x1,%eax
  802a5b:	19 c0                	sbb    %eax,%eax
  802a5d:	83 e0 fe             	and    $0xfffffffe,%eax
  802a60:	83 c0 07             	add    $0x7,%eax
  802a63:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802a69:	89 d0                	mov    %edx,%eax
  802a6b:	8b 7a 04             	mov    0x4(%edx),%edi
  802a6e:	89 f9                	mov    %edi,%ecx
  802a70:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  802a76:	8b 7a 10             	mov    0x10(%edx),%edi
  802a79:	8b 52 14             	mov    0x14(%edx),%edx
  802a7c:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  802a82:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802a85:	89 f0                	mov    %esi,%eax
  802a87:	25 ff 0f 00 00       	and    $0xfff,%eax
  802a8c:	74 14                	je     802aa2 <spawn+0x2bf>
		va -= i;
  802a8e:	29 c6                	sub    %eax,%esi
		memsz += i;
  802a90:	01 c2                	add    %eax,%edx
  802a92:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  802a98:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  802a9a:	29 c1                	sub    %eax,%ecx
  802a9c:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802aa2:	bb 00 00 00 00       	mov    $0x0,%ebx
  802aa7:	e9 f7 00 00 00       	jmp    802ba3 <spawn+0x3c0>
		if (i >= filesz) {
  802aac:	39 fb                	cmp    %edi,%ebx
  802aae:	72 27                	jb     802ad7 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802ab0:	83 ec 04             	sub    $0x4,%esp
  802ab3:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802ab9:	56                   	push   %esi
  802aba:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802ac0:	e8 d6 ea ff ff       	call   80159b <sys_page_alloc>
  802ac5:	83 c4 10             	add    $0x10,%esp
  802ac8:	85 c0                	test   %eax,%eax
  802aca:	0f 89 c7 00 00 00    	jns    802b97 <spawn+0x3b4>
  802ad0:	89 c3                	mov    %eax,%ebx
  802ad2:	e9 fd 01 00 00       	jmp    802cd4 <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802ad7:	83 ec 04             	sub    $0x4,%esp
  802ada:	6a 07                	push   $0x7
  802adc:	68 00 00 40 00       	push   $0x400000
  802ae1:	6a 00                	push   $0x0
  802ae3:	e8 b3 ea ff ff       	call   80159b <sys_page_alloc>
  802ae8:	83 c4 10             	add    $0x10,%esp
  802aeb:	85 c0                	test   %eax,%eax
  802aed:	0f 88 d7 01 00 00    	js     802cca <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802af3:	83 ec 08             	sub    $0x8,%esp
  802af6:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802afc:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802b02:	50                   	push   %eax
  802b03:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802b09:	e8 f9 f7 ff ff       	call   802307 <seek>
  802b0e:	83 c4 10             	add    $0x10,%esp
  802b11:	85 c0                	test   %eax,%eax
  802b13:	0f 88 b5 01 00 00    	js     802cce <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802b19:	83 ec 04             	sub    $0x4,%esp
  802b1c:	89 f8                	mov    %edi,%eax
  802b1e:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  802b24:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802b29:	ba 00 10 00 00       	mov    $0x1000,%edx
  802b2e:	0f 47 c2             	cmova  %edx,%eax
  802b31:	50                   	push   %eax
  802b32:	68 00 00 40 00       	push   $0x400000
  802b37:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802b3d:	e8 ed f6 ff ff       	call   80222f <readn>
  802b42:	83 c4 10             	add    $0x10,%esp
  802b45:	85 c0                	test   %eax,%eax
  802b47:	0f 88 85 01 00 00    	js     802cd2 <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802b4d:	83 ec 0c             	sub    $0xc,%esp
  802b50:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802b56:	56                   	push   %esi
  802b57:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802b5d:	68 00 00 40 00       	push   $0x400000
  802b62:	6a 00                	push   $0x0
  802b64:	e8 75 ea ff ff       	call   8015de <sys_page_map>
  802b69:	83 c4 20             	add    $0x20,%esp
  802b6c:	85 c0                	test   %eax,%eax
  802b6e:	79 15                	jns    802b85 <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  802b70:	50                   	push   %eax
  802b71:	68 c8 3d 80 00       	push   $0x803dc8
  802b76:	68 25 01 00 00       	push   $0x125
  802b7b:	68 bc 3d 80 00       	push   $0x803dbc
  802b80:	e8 c2 de ff ff       	call   800a47 <_panic>
			sys_page_unmap(0, UTEMP);
  802b85:	83 ec 08             	sub    $0x8,%esp
  802b88:	68 00 00 40 00       	push   $0x400000
  802b8d:	6a 00                	push   $0x0
  802b8f:	e8 8c ea ff ff       	call   801620 <sys_page_unmap>
  802b94:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802b97:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802b9d:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802ba3:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802ba9:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  802baf:	0f 82 f7 fe ff ff    	jb     802aac <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802bb5:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802bbc:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802bc3:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802bca:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802bd0:	0f 8c 65 fe ff ff    	jl     802a3b <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802bd6:	83 ec 0c             	sub    $0xc,%esp
  802bd9:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802bdf:	e8 7b f4 ff ff       	call   80205f <close>
  802be4:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802be7:	bb 00 00 00 00       	mov    $0x0,%ebx
  802bec:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  802bf2:	89 d8                	mov    %ebx,%eax
  802bf4:	c1 e8 16             	shr    $0x16,%eax
  802bf7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802bfe:	a8 01                	test   $0x1,%al
  802c00:	74 42                	je     802c44 <spawn+0x461>
  802c02:	89 d8                	mov    %ebx,%eax
  802c04:	c1 e8 0c             	shr    $0xc,%eax
  802c07:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802c0e:	f6 c2 01             	test   $0x1,%dl
  802c11:	74 31                	je     802c44 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  802c13:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  802c1a:	f6 c6 04             	test   $0x4,%dh
  802c1d:	74 25                	je     802c44 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  802c1f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802c26:	83 ec 0c             	sub    $0xc,%esp
  802c29:	25 07 0e 00 00       	and    $0xe07,%eax
  802c2e:	50                   	push   %eax
  802c2f:	53                   	push   %ebx
  802c30:	56                   	push   %esi
  802c31:	53                   	push   %ebx
  802c32:	6a 00                	push   $0x0
  802c34:	e8 a5 e9 ff ff       	call   8015de <sys_page_map>
			if (r < 0) {
  802c39:	83 c4 20             	add    $0x20,%esp
  802c3c:	85 c0                	test   %eax,%eax
  802c3e:	0f 88 b1 00 00 00    	js     802cf5 <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802c44:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802c4a:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802c50:	75 a0                	jne    802bf2 <spawn+0x40f>
  802c52:	e9 b3 00 00 00       	jmp    802d0a <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802c57:	50                   	push   %eax
  802c58:	68 e5 3d 80 00       	push   $0x803de5
  802c5d:	68 86 00 00 00       	push   $0x86
  802c62:	68 bc 3d 80 00       	push   $0x803dbc
  802c67:	e8 db dd ff ff       	call   800a47 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802c6c:	83 ec 08             	sub    $0x8,%esp
  802c6f:	6a 02                	push   $0x2
  802c71:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802c77:	e8 e6 e9 ff ff       	call   801662 <sys_env_set_status>
  802c7c:	83 c4 10             	add    $0x10,%esp
  802c7f:	85 c0                	test   %eax,%eax
  802c81:	79 2b                	jns    802cae <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  802c83:	50                   	push   %eax
  802c84:	68 ff 3d 80 00       	push   $0x803dff
  802c89:	68 89 00 00 00       	push   $0x89
  802c8e:	68 bc 3d 80 00       	push   $0x803dbc
  802c93:	e8 af dd ff ff       	call   800a47 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802c98:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802c9e:	e9 a8 00 00 00       	jmp    802d4b <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802ca3:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802ca9:	e9 9d 00 00 00       	jmp    802d4b <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802cae:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802cb4:	e9 92 00 00 00       	jmp    802d4b <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802cb9:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802cbe:	e9 88 00 00 00       	jmp    802d4b <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802cc3:	89 c3                	mov    %eax,%ebx
  802cc5:	e9 81 00 00 00       	jmp    802d4b <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802cca:	89 c3                	mov    %eax,%ebx
  802ccc:	eb 06                	jmp    802cd4 <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802cce:	89 c3                	mov    %eax,%ebx
  802cd0:	eb 02                	jmp    802cd4 <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802cd2:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802cd4:	83 ec 0c             	sub    $0xc,%esp
  802cd7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802cdd:	e8 3a e8 ff ff       	call   80151c <sys_env_destroy>
	close(fd);
  802ce2:	83 c4 04             	add    $0x4,%esp
  802ce5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802ceb:	e8 6f f3 ff ff       	call   80205f <close>
	return r;
  802cf0:	83 c4 10             	add    $0x10,%esp
  802cf3:	eb 56                	jmp    802d4b <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802cf5:	50                   	push   %eax
  802cf6:	68 16 3e 80 00       	push   $0x803e16
  802cfb:	68 82 00 00 00       	push   $0x82
  802d00:	68 bc 3d 80 00       	push   $0x803dbc
  802d05:	e8 3d dd ff ff       	call   800a47 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802d0a:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802d11:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802d14:	83 ec 08             	sub    $0x8,%esp
  802d17:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802d1d:	50                   	push   %eax
  802d1e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802d24:	e8 7b e9 ff ff       	call   8016a4 <sys_env_set_trapframe>
  802d29:	83 c4 10             	add    $0x10,%esp
  802d2c:	85 c0                	test   %eax,%eax
  802d2e:	0f 89 38 ff ff ff    	jns    802c6c <spawn+0x489>
  802d34:	e9 1e ff ff ff       	jmp    802c57 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802d39:	83 ec 08             	sub    $0x8,%esp
  802d3c:	68 00 00 40 00       	push   $0x400000
  802d41:	6a 00                	push   $0x0
  802d43:	e8 d8 e8 ff ff       	call   801620 <sys_page_unmap>
  802d48:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802d4b:	89 d8                	mov    %ebx,%eax
  802d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d50:	5b                   	pop    %ebx
  802d51:	5e                   	pop    %esi
  802d52:	5f                   	pop    %edi
  802d53:	5d                   	pop    %ebp
  802d54:	c3                   	ret    

00802d55 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802d55:	55                   	push   %ebp
  802d56:	89 e5                	mov    %esp,%ebp
  802d58:	56                   	push   %esi
  802d59:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802d5a:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802d5d:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802d62:	eb 03                	jmp    802d67 <spawnl+0x12>
		argc++;
  802d64:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802d67:	83 c2 04             	add    $0x4,%edx
  802d6a:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802d6e:	75 f4                	jne    802d64 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802d70:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802d77:	83 e2 f0             	and    $0xfffffff0,%edx
  802d7a:	29 d4                	sub    %edx,%esp
  802d7c:	8d 54 24 03          	lea    0x3(%esp),%edx
  802d80:	c1 ea 02             	shr    $0x2,%edx
  802d83:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802d8a:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d8f:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802d96:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802d9d:	00 
  802d9e:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802da0:	b8 00 00 00 00       	mov    $0x0,%eax
  802da5:	eb 0a                	jmp    802db1 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802da7:	83 c0 01             	add    $0x1,%eax
  802daa:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802dae:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802db1:	39 d0                	cmp    %edx,%eax
  802db3:	75 f2                	jne    802da7 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802db5:	83 ec 08             	sub    $0x8,%esp
  802db8:	56                   	push   %esi
  802db9:	ff 75 08             	pushl  0x8(%ebp)
  802dbc:	e8 22 fa ff ff       	call   8027e3 <spawn>
}
  802dc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802dc4:	5b                   	pop    %ebx
  802dc5:	5e                   	pop    %esi
  802dc6:	5d                   	pop    %ebp
  802dc7:	c3                   	ret    

00802dc8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802dc8:	55                   	push   %ebp
  802dc9:	89 e5                	mov    %esp,%ebp
  802dcb:	56                   	push   %esi
  802dcc:	53                   	push   %ebx
  802dcd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802dd0:	83 ec 0c             	sub    $0xc,%esp
  802dd3:	ff 75 08             	pushl  0x8(%ebp)
  802dd6:	e8 f1 f0 ff ff       	call   801ecc <fd2data>
  802ddb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802ddd:	83 c4 08             	add    $0x8,%esp
  802de0:	68 54 3e 80 00       	push   $0x803e54
  802de5:	53                   	push   %ebx
  802de6:	e8 ad e3 ff ff       	call   801198 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802deb:	8b 46 04             	mov    0x4(%esi),%eax
  802dee:	2b 06                	sub    (%esi),%eax
  802df0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802df6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802dfd:	00 00 00 
	stat->st_dev = &devpipe;
  802e00:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802e07:	40 80 00 
	return 0;
}
  802e0a:	b8 00 00 00 00       	mov    $0x0,%eax
  802e0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e12:	5b                   	pop    %ebx
  802e13:	5e                   	pop    %esi
  802e14:	5d                   	pop    %ebp
  802e15:	c3                   	ret    

00802e16 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802e16:	55                   	push   %ebp
  802e17:	89 e5                	mov    %esp,%ebp
  802e19:	53                   	push   %ebx
  802e1a:	83 ec 0c             	sub    $0xc,%esp
  802e1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802e20:	53                   	push   %ebx
  802e21:	6a 00                	push   $0x0
  802e23:	e8 f8 e7 ff ff       	call   801620 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802e28:	89 1c 24             	mov    %ebx,(%esp)
  802e2b:	e8 9c f0 ff ff       	call   801ecc <fd2data>
  802e30:	83 c4 08             	add    $0x8,%esp
  802e33:	50                   	push   %eax
  802e34:	6a 00                	push   $0x0
  802e36:	e8 e5 e7 ff ff       	call   801620 <sys_page_unmap>
}
  802e3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e3e:	c9                   	leave  
  802e3f:	c3                   	ret    

00802e40 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802e40:	55                   	push   %ebp
  802e41:	89 e5                	mov    %esp,%ebp
  802e43:	57                   	push   %edi
  802e44:	56                   	push   %esi
  802e45:	53                   	push   %ebx
  802e46:	83 ec 1c             	sub    $0x1c,%esp
  802e49:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802e4c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802e4e:	a1 24 54 80 00       	mov    0x805424,%eax
  802e53:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802e59:	83 ec 0c             	sub    $0xc,%esp
  802e5c:	ff 75 e0             	pushl  -0x20(%ebp)
  802e5f:	e8 d2 04 00 00       	call   803336 <pageref>
  802e64:	89 c3                	mov    %eax,%ebx
  802e66:	89 3c 24             	mov    %edi,(%esp)
  802e69:	e8 c8 04 00 00       	call   803336 <pageref>
  802e6e:	83 c4 10             	add    $0x10,%esp
  802e71:	39 c3                	cmp    %eax,%ebx
  802e73:	0f 94 c1             	sete   %cl
  802e76:	0f b6 c9             	movzbl %cl,%ecx
  802e79:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802e7c:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802e82:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  802e88:	39 ce                	cmp    %ecx,%esi
  802e8a:	74 1e                	je     802eaa <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  802e8c:	39 c3                	cmp    %eax,%ebx
  802e8e:	75 be                	jne    802e4e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802e90:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  802e96:	ff 75 e4             	pushl  -0x1c(%ebp)
  802e99:	50                   	push   %eax
  802e9a:	56                   	push   %esi
  802e9b:	68 5b 3e 80 00       	push   $0x803e5b
  802ea0:	e8 7b dc ff ff       	call   800b20 <cprintf>
  802ea5:	83 c4 10             	add    $0x10,%esp
  802ea8:	eb a4                	jmp    802e4e <_pipeisclosed+0xe>
	}
}
  802eaa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ead:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802eb0:	5b                   	pop    %ebx
  802eb1:	5e                   	pop    %esi
  802eb2:	5f                   	pop    %edi
  802eb3:	5d                   	pop    %ebp
  802eb4:	c3                   	ret    

00802eb5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802eb5:	55                   	push   %ebp
  802eb6:	89 e5                	mov    %esp,%ebp
  802eb8:	57                   	push   %edi
  802eb9:	56                   	push   %esi
  802eba:	53                   	push   %ebx
  802ebb:	83 ec 28             	sub    $0x28,%esp
  802ebe:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802ec1:	56                   	push   %esi
  802ec2:	e8 05 f0 ff ff       	call   801ecc <fd2data>
  802ec7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ec9:	83 c4 10             	add    $0x10,%esp
  802ecc:	bf 00 00 00 00       	mov    $0x0,%edi
  802ed1:	eb 4b                	jmp    802f1e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802ed3:	89 da                	mov    %ebx,%edx
  802ed5:	89 f0                	mov    %esi,%eax
  802ed7:	e8 64 ff ff ff       	call   802e40 <_pipeisclosed>
  802edc:	85 c0                	test   %eax,%eax
  802ede:	75 48                	jne    802f28 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802ee0:	e8 97 e6 ff ff       	call   80157c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802ee5:	8b 43 04             	mov    0x4(%ebx),%eax
  802ee8:	8b 0b                	mov    (%ebx),%ecx
  802eea:	8d 51 20             	lea    0x20(%ecx),%edx
  802eed:	39 d0                	cmp    %edx,%eax
  802eef:	73 e2                	jae    802ed3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802ef1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802ef4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802ef8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802efb:	89 c2                	mov    %eax,%edx
  802efd:	c1 fa 1f             	sar    $0x1f,%edx
  802f00:	89 d1                	mov    %edx,%ecx
  802f02:	c1 e9 1b             	shr    $0x1b,%ecx
  802f05:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802f08:	83 e2 1f             	and    $0x1f,%edx
  802f0b:	29 ca                	sub    %ecx,%edx
  802f0d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802f11:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802f15:	83 c0 01             	add    $0x1,%eax
  802f18:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802f1b:	83 c7 01             	add    $0x1,%edi
  802f1e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802f21:	75 c2                	jne    802ee5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802f23:	8b 45 10             	mov    0x10(%ebp),%eax
  802f26:	eb 05                	jmp    802f2d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802f28:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802f2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f30:	5b                   	pop    %ebx
  802f31:	5e                   	pop    %esi
  802f32:	5f                   	pop    %edi
  802f33:	5d                   	pop    %ebp
  802f34:	c3                   	ret    

00802f35 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802f35:	55                   	push   %ebp
  802f36:	89 e5                	mov    %esp,%ebp
  802f38:	57                   	push   %edi
  802f39:	56                   	push   %esi
  802f3a:	53                   	push   %ebx
  802f3b:	83 ec 18             	sub    $0x18,%esp
  802f3e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802f41:	57                   	push   %edi
  802f42:	e8 85 ef ff ff       	call   801ecc <fd2data>
  802f47:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802f49:	83 c4 10             	add    $0x10,%esp
  802f4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802f51:	eb 3d                	jmp    802f90 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802f53:	85 db                	test   %ebx,%ebx
  802f55:	74 04                	je     802f5b <devpipe_read+0x26>
				return i;
  802f57:	89 d8                	mov    %ebx,%eax
  802f59:	eb 44                	jmp    802f9f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802f5b:	89 f2                	mov    %esi,%edx
  802f5d:	89 f8                	mov    %edi,%eax
  802f5f:	e8 dc fe ff ff       	call   802e40 <_pipeisclosed>
  802f64:	85 c0                	test   %eax,%eax
  802f66:	75 32                	jne    802f9a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802f68:	e8 0f e6 ff ff       	call   80157c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802f6d:	8b 06                	mov    (%esi),%eax
  802f6f:	3b 46 04             	cmp    0x4(%esi),%eax
  802f72:	74 df                	je     802f53 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802f74:	99                   	cltd   
  802f75:	c1 ea 1b             	shr    $0x1b,%edx
  802f78:	01 d0                	add    %edx,%eax
  802f7a:	83 e0 1f             	and    $0x1f,%eax
  802f7d:	29 d0                	sub    %edx,%eax
  802f7f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802f84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802f87:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802f8a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802f8d:	83 c3 01             	add    $0x1,%ebx
  802f90:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802f93:	75 d8                	jne    802f6d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802f95:	8b 45 10             	mov    0x10(%ebp),%eax
  802f98:	eb 05                	jmp    802f9f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802f9a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802f9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802fa2:	5b                   	pop    %ebx
  802fa3:	5e                   	pop    %esi
  802fa4:	5f                   	pop    %edi
  802fa5:	5d                   	pop    %ebp
  802fa6:	c3                   	ret    

00802fa7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802fa7:	55                   	push   %ebp
  802fa8:	89 e5                	mov    %esp,%ebp
  802faa:	56                   	push   %esi
  802fab:	53                   	push   %ebx
  802fac:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802faf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802fb2:	50                   	push   %eax
  802fb3:	e8 2b ef ff ff       	call   801ee3 <fd_alloc>
  802fb8:	83 c4 10             	add    $0x10,%esp
  802fbb:	89 c2                	mov    %eax,%edx
  802fbd:	85 c0                	test   %eax,%eax
  802fbf:	0f 88 2c 01 00 00    	js     8030f1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fc5:	83 ec 04             	sub    $0x4,%esp
  802fc8:	68 07 04 00 00       	push   $0x407
  802fcd:	ff 75 f4             	pushl  -0xc(%ebp)
  802fd0:	6a 00                	push   $0x0
  802fd2:	e8 c4 e5 ff ff       	call   80159b <sys_page_alloc>
  802fd7:	83 c4 10             	add    $0x10,%esp
  802fda:	89 c2                	mov    %eax,%edx
  802fdc:	85 c0                	test   %eax,%eax
  802fde:	0f 88 0d 01 00 00    	js     8030f1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802fe4:	83 ec 0c             	sub    $0xc,%esp
  802fe7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802fea:	50                   	push   %eax
  802feb:	e8 f3 ee ff ff       	call   801ee3 <fd_alloc>
  802ff0:	89 c3                	mov    %eax,%ebx
  802ff2:	83 c4 10             	add    $0x10,%esp
  802ff5:	85 c0                	test   %eax,%eax
  802ff7:	0f 88 e2 00 00 00    	js     8030df <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ffd:	83 ec 04             	sub    $0x4,%esp
  803000:	68 07 04 00 00       	push   $0x407
  803005:	ff 75 f0             	pushl  -0x10(%ebp)
  803008:	6a 00                	push   $0x0
  80300a:	e8 8c e5 ff ff       	call   80159b <sys_page_alloc>
  80300f:	89 c3                	mov    %eax,%ebx
  803011:	83 c4 10             	add    $0x10,%esp
  803014:	85 c0                	test   %eax,%eax
  803016:	0f 88 c3 00 00 00    	js     8030df <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80301c:	83 ec 0c             	sub    $0xc,%esp
  80301f:	ff 75 f4             	pushl  -0xc(%ebp)
  803022:	e8 a5 ee ff ff       	call   801ecc <fd2data>
  803027:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803029:	83 c4 0c             	add    $0xc,%esp
  80302c:	68 07 04 00 00       	push   $0x407
  803031:	50                   	push   %eax
  803032:	6a 00                	push   $0x0
  803034:	e8 62 e5 ff ff       	call   80159b <sys_page_alloc>
  803039:	89 c3                	mov    %eax,%ebx
  80303b:	83 c4 10             	add    $0x10,%esp
  80303e:	85 c0                	test   %eax,%eax
  803040:	0f 88 89 00 00 00    	js     8030cf <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803046:	83 ec 0c             	sub    $0xc,%esp
  803049:	ff 75 f0             	pushl  -0x10(%ebp)
  80304c:	e8 7b ee ff ff       	call   801ecc <fd2data>
  803051:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803058:	50                   	push   %eax
  803059:	6a 00                	push   $0x0
  80305b:	56                   	push   %esi
  80305c:	6a 00                	push   $0x0
  80305e:	e8 7b e5 ff ff       	call   8015de <sys_page_map>
  803063:	89 c3                	mov    %eax,%ebx
  803065:	83 c4 20             	add    $0x20,%esp
  803068:	85 c0                	test   %eax,%eax
  80306a:	78 55                	js     8030c1 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80306c:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  803072:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803075:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803077:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80307a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803081:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  803087:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80308a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80308c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80308f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803096:	83 ec 0c             	sub    $0xc,%esp
  803099:	ff 75 f4             	pushl  -0xc(%ebp)
  80309c:	e8 1b ee ff ff       	call   801ebc <fd2num>
  8030a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8030a4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8030a6:	83 c4 04             	add    $0x4,%esp
  8030a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8030ac:	e8 0b ee ff ff       	call   801ebc <fd2num>
  8030b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8030b4:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8030b7:	83 c4 10             	add    $0x10,%esp
  8030ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8030bf:	eb 30                	jmp    8030f1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8030c1:	83 ec 08             	sub    $0x8,%esp
  8030c4:	56                   	push   %esi
  8030c5:	6a 00                	push   $0x0
  8030c7:	e8 54 e5 ff ff       	call   801620 <sys_page_unmap>
  8030cc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8030cf:	83 ec 08             	sub    $0x8,%esp
  8030d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8030d5:	6a 00                	push   $0x0
  8030d7:	e8 44 e5 ff ff       	call   801620 <sys_page_unmap>
  8030dc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8030df:	83 ec 08             	sub    $0x8,%esp
  8030e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8030e5:	6a 00                	push   $0x0
  8030e7:	e8 34 e5 ff ff       	call   801620 <sys_page_unmap>
  8030ec:	83 c4 10             	add    $0x10,%esp
  8030ef:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8030f1:	89 d0                	mov    %edx,%eax
  8030f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8030f6:	5b                   	pop    %ebx
  8030f7:	5e                   	pop    %esi
  8030f8:	5d                   	pop    %ebp
  8030f9:	c3                   	ret    

008030fa <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8030fa:	55                   	push   %ebp
  8030fb:	89 e5                	mov    %esp,%ebp
  8030fd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803100:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803103:	50                   	push   %eax
  803104:	ff 75 08             	pushl  0x8(%ebp)
  803107:	e8 26 ee ff ff       	call   801f32 <fd_lookup>
  80310c:	83 c4 10             	add    $0x10,%esp
  80310f:	85 c0                	test   %eax,%eax
  803111:	78 18                	js     80312b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803113:	83 ec 0c             	sub    $0xc,%esp
  803116:	ff 75 f4             	pushl  -0xc(%ebp)
  803119:	e8 ae ed ff ff       	call   801ecc <fd2data>
	return _pipeisclosed(fd, p);
  80311e:	89 c2                	mov    %eax,%edx
  803120:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803123:	e8 18 fd ff ff       	call   802e40 <_pipeisclosed>
  803128:	83 c4 10             	add    $0x10,%esp
}
  80312b:	c9                   	leave  
  80312c:	c3                   	ret    

0080312d <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80312d:	55                   	push   %ebp
  80312e:	89 e5                	mov    %esp,%ebp
  803130:	56                   	push   %esi
  803131:	53                   	push   %ebx
  803132:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  803135:	85 f6                	test   %esi,%esi
  803137:	75 16                	jne    80314f <wait+0x22>
  803139:	68 73 3e 80 00       	push   $0x803e73
  80313e:	68 6f 37 80 00       	push   $0x80376f
  803143:	6a 09                	push   $0x9
  803145:	68 7e 3e 80 00       	push   $0x803e7e
  80314a:	e8 f8 d8 ff ff       	call   800a47 <_panic>
	e = &envs[ENVX(envid)];
  80314f:	89 f3                	mov    %esi,%ebx
  803151:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803157:	69 db d8 00 00 00    	imul   $0xd8,%ebx,%ebx
  80315d:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  803163:	eb 05                	jmp    80316a <wait+0x3d>
		sys_yield();
  803165:	e8 12 e4 ff ff       	call   80157c <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80316a:	8b 83 a4 00 00 00    	mov    0xa4(%ebx),%eax
  803170:	39 c6                	cmp    %eax,%esi
  803172:	75 0a                	jne    80317e <wait+0x51>
  803174:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  80317a:	85 c0                	test   %eax,%eax
  80317c:	75 e7                	jne    803165 <wait+0x38>
		sys_yield();
}
  80317e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803181:	5b                   	pop    %ebx
  803182:	5e                   	pop    %esi
  803183:	5d                   	pop    %ebp
  803184:	c3                   	ret    

00803185 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  803185:	55                   	push   %ebp
  803186:	89 e5                	mov    %esp,%ebp
  803188:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80318b:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  803192:	75 2a                	jne    8031be <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  803194:	83 ec 04             	sub    $0x4,%esp
  803197:	6a 07                	push   $0x7
  803199:	68 00 f0 bf ee       	push   $0xeebff000
  80319e:	6a 00                	push   $0x0
  8031a0:	e8 f6 e3 ff ff       	call   80159b <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8031a5:	83 c4 10             	add    $0x10,%esp
  8031a8:	85 c0                	test   %eax,%eax
  8031aa:	79 12                	jns    8031be <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8031ac:	50                   	push   %eax
  8031ad:	68 6b 3b 80 00       	push   $0x803b6b
  8031b2:	6a 23                	push   $0x23
  8031b4:	68 89 3e 80 00       	push   $0x803e89
  8031b9:	e8 89 d8 ff ff       	call   800a47 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8031be:	8b 45 08             	mov    0x8(%ebp),%eax
  8031c1:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8031c6:	83 ec 08             	sub    $0x8,%esp
  8031c9:	68 f0 31 80 00       	push   $0x8031f0
  8031ce:	6a 00                	push   $0x0
  8031d0:	e8 11 e5 ff ff       	call   8016e6 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8031d5:	83 c4 10             	add    $0x10,%esp
  8031d8:	85 c0                	test   %eax,%eax
  8031da:	79 12                	jns    8031ee <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8031dc:	50                   	push   %eax
  8031dd:	68 6b 3b 80 00       	push   $0x803b6b
  8031e2:	6a 2c                	push   $0x2c
  8031e4:	68 89 3e 80 00       	push   $0x803e89
  8031e9:	e8 59 d8 ff ff       	call   800a47 <_panic>
	}
}
  8031ee:	c9                   	leave  
  8031ef:	c3                   	ret    

008031f0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8031f0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8031f1:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8031f6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8031f8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8031fb:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8031ff:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  803204:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  803208:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80320a:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80320d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80320e:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  803211:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  803212:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  803213:	c3                   	ret    

00803214 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  803214:	55                   	push   %ebp
  803215:	89 e5                	mov    %esp,%ebp
  803217:	56                   	push   %esi
  803218:	53                   	push   %ebx
  803219:	8b 75 08             	mov    0x8(%ebp),%esi
  80321c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80321f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  803222:	85 c0                	test   %eax,%eax
  803224:	75 12                	jne    803238 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  803226:	83 ec 0c             	sub    $0xc,%esp
  803229:	68 00 00 c0 ee       	push   $0xeec00000
  80322e:	e8 18 e5 ff ff       	call   80174b <sys_ipc_recv>
  803233:	83 c4 10             	add    $0x10,%esp
  803236:	eb 0c                	jmp    803244 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  803238:	83 ec 0c             	sub    $0xc,%esp
  80323b:	50                   	push   %eax
  80323c:	e8 0a e5 ff ff       	call   80174b <sys_ipc_recv>
  803241:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  803244:	85 f6                	test   %esi,%esi
  803246:	0f 95 c1             	setne  %cl
  803249:	85 db                	test   %ebx,%ebx
  80324b:	0f 95 c2             	setne  %dl
  80324e:	84 d1                	test   %dl,%cl
  803250:	74 09                	je     80325b <ipc_recv+0x47>
  803252:	89 c2                	mov    %eax,%edx
  803254:	c1 ea 1f             	shr    $0x1f,%edx
  803257:	84 d2                	test   %dl,%dl
  803259:	75 2d                	jne    803288 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80325b:	85 f6                	test   %esi,%esi
  80325d:	74 0d                	je     80326c <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80325f:	a1 24 54 80 00       	mov    0x805424,%eax
  803264:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80326a:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80326c:	85 db                	test   %ebx,%ebx
  80326e:	74 0d                	je     80327d <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  803270:	a1 24 54 80 00       	mov    0x805424,%eax
  803275:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  80327b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80327d:	a1 24 54 80 00       	mov    0x805424,%eax
  803282:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  803288:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80328b:	5b                   	pop    %ebx
  80328c:	5e                   	pop    %esi
  80328d:	5d                   	pop    %ebp
  80328e:	c3                   	ret    

0080328f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80328f:	55                   	push   %ebp
  803290:	89 e5                	mov    %esp,%ebp
  803292:	57                   	push   %edi
  803293:	56                   	push   %esi
  803294:	53                   	push   %ebx
  803295:	83 ec 0c             	sub    $0xc,%esp
  803298:	8b 7d 08             	mov    0x8(%ebp),%edi
  80329b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80329e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8032a1:	85 db                	test   %ebx,%ebx
  8032a3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8032a8:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8032ab:	ff 75 14             	pushl  0x14(%ebp)
  8032ae:	53                   	push   %ebx
  8032af:	56                   	push   %esi
  8032b0:	57                   	push   %edi
  8032b1:	e8 72 e4 ff ff       	call   801728 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8032b6:	89 c2                	mov    %eax,%edx
  8032b8:	c1 ea 1f             	shr    $0x1f,%edx
  8032bb:	83 c4 10             	add    $0x10,%esp
  8032be:	84 d2                	test   %dl,%dl
  8032c0:	74 17                	je     8032d9 <ipc_send+0x4a>
  8032c2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8032c5:	74 12                	je     8032d9 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8032c7:	50                   	push   %eax
  8032c8:	68 97 3e 80 00       	push   $0x803e97
  8032cd:	6a 47                	push   $0x47
  8032cf:	68 a5 3e 80 00       	push   $0x803ea5
  8032d4:	e8 6e d7 ff ff       	call   800a47 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8032d9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8032dc:	75 07                	jne    8032e5 <ipc_send+0x56>
			sys_yield();
  8032de:	e8 99 e2 ff ff       	call   80157c <sys_yield>
  8032e3:	eb c6                	jmp    8032ab <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8032e5:	85 c0                	test   %eax,%eax
  8032e7:	75 c2                	jne    8032ab <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8032e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8032ec:	5b                   	pop    %ebx
  8032ed:	5e                   	pop    %esi
  8032ee:	5f                   	pop    %edi
  8032ef:	5d                   	pop    %ebp
  8032f0:	c3                   	ret    

008032f1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8032f1:	55                   	push   %ebp
  8032f2:	89 e5                	mov    %esp,%ebp
  8032f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8032f7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8032fc:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  803302:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803308:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  80330e:	39 ca                	cmp    %ecx,%edx
  803310:	75 13                	jne    803325 <ipc_find_env+0x34>
			return envs[i].env_id;
  803312:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  803318:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80331d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  803323:	eb 0f                	jmp    803334 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803325:	83 c0 01             	add    $0x1,%eax
  803328:	3d 00 04 00 00       	cmp    $0x400,%eax
  80332d:	75 cd                	jne    8032fc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80332f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803334:	5d                   	pop    %ebp
  803335:	c3                   	ret    

00803336 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803336:	55                   	push   %ebp
  803337:	89 e5                	mov    %esp,%ebp
  803339:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80333c:	89 d0                	mov    %edx,%eax
  80333e:	c1 e8 16             	shr    $0x16,%eax
  803341:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803348:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80334d:	f6 c1 01             	test   $0x1,%cl
  803350:	74 1d                	je     80336f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803352:	c1 ea 0c             	shr    $0xc,%edx
  803355:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80335c:	f6 c2 01             	test   $0x1,%dl
  80335f:	74 0e                	je     80336f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803361:	c1 ea 0c             	shr    $0xc,%edx
  803364:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80336b:	ef 
  80336c:	0f b7 c0             	movzwl %ax,%eax
}
  80336f:	5d                   	pop    %ebp
  803370:	c3                   	ret    
  803371:	66 90                	xchg   %ax,%ax
  803373:	66 90                	xchg   %ax,%ax
  803375:	66 90                	xchg   %ax,%ax
  803377:	66 90                	xchg   %ax,%ax
  803379:	66 90                	xchg   %ax,%ax
  80337b:	66 90                	xchg   %ax,%ax
  80337d:	66 90                	xchg   %ax,%ax
  80337f:	90                   	nop

00803380 <__udivdi3>:
  803380:	55                   	push   %ebp
  803381:	57                   	push   %edi
  803382:	56                   	push   %esi
  803383:	53                   	push   %ebx
  803384:	83 ec 1c             	sub    $0x1c,%esp
  803387:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80338b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80338f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803393:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803397:	85 f6                	test   %esi,%esi
  803399:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80339d:	89 ca                	mov    %ecx,%edx
  80339f:	89 f8                	mov    %edi,%eax
  8033a1:	75 3d                	jne    8033e0 <__udivdi3+0x60>
  8033a3:	39 cf                	cmp    %ecx,%edi
  8033a5:	0f 87 c5 00 00 00    	ja     803470 <__udivdi3+0xf0>
  8033ab:	85 ff                	test   %edi,%edi
  8033ad:	89 fd                	mov    %edi,%ebp
  8033af:	75 0b                	jne    8033bc <__udivdi3+0x3c>
  8033b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8033b6:	31 d2                	xor    %edx,%edx
  8033b8:	f7 f7                	div    %edi
  8033ba:	89 c5                	mov    %eax,%ebp
  8033bc:	89 c8                	mov    %ecx,%eax
  8033be:	31 d2                	xor    %edx,%edx
  8033c0:	f7 f5                	div    %ebp
  8033c2:	89 c1                	mov    %eax,%ecx
  8033c4:	89 d8                	mov    %ebx,%eax
  8033c6:	89 cf                	mov    %ecx,%edi
  8033c8:	f7 f5                	div    %ebp
  8033ca:	89 c3                	mov    %eax,%ebx
  8033cc:	89 d8                	mov    %ebx,%eax
  8033ce:	89 fa                	mov    %edi,%edx
  8033d0:	83 c4 1c             	add    $0x1c,%esp
  8033d3:	5b                   	pop    %ebx
  8033d4:	5e                   	pop    %esi
  8033d5:	5f                   	pop    %edi
  8033d6:	5d                   	pop    %ebp
  8033d7:	c3                   	ret    
  8033d8:	90                   	nop
  8033d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8033e0:	39 ce                	cmp    %ecx,%esi
  8033e2:	77 74                	ja     803458 <__udivdi3+0xd8>
  8033e4:	0f bd fe             	bsr    %esi,%edi
  8033e7:	83 f7 1f             	xor    $0x1f,%edi
  8033ea:	0f 84 98 00 00 00    	je     803488 <__udivdi3+0x108>
  8033f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8033f5:	89 f9                	mov    %edi,%ecx
  8033f7:	89 c5                	mov    %eax,%ebp
  8033f9:	29 fb                	sub    %edi,%ebx
  8033fb:	d3 e6                	shl    %cl,%esi
  8033fd:	89 d9                	mov    %ebx,%ecx
  8033ff:	d3 ed                	shr    %cl,%ebp
  803401:	89 f9                	mov    %edi,%ecx
  803403:	d3 e0                	shl    %cl,%eax
  803405:	09 ee                	or     %ebp,%esi
  803407:	89 d9                	mov    %ebx,%ecx
  803409:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80340d:	89 d5                	mov    %edx,%ebp
  80340f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803413:	d3 ed                	shr    %cl,%ebp
  803415:	89 f9                	mov    %edi,%ecx
  803417:	d3 e2                	shl    %cl,%edx
  803419:	89 d9                	mov    %ebx,%ecx
  80341b:	d3 e8                	shr    %cl,%eax
  80341d:	09 c2                	or     %eax,%edx
  80341f:	89 d0                	mov    %edx,%eax
  803421:	89 ea                	mov    %ebp,%edx
  803423:	f7 f6                	div    %esi
  803425:	89 d5                	mov    %edx,%ebp
  803427:	89 c3                	mov    %eax,%ebx
  803429:	f7 64 24 0c          	mull   0xc(%esp)
  80342d:	39 d5                	cmp    %edx,%ebp
  80342f:	72 10                	jb     803441 <__udivdi3+0xc1>
  803431:	8b 74 24 08          	mov    0x8(%esp),%esi
  803435:	89 f9                	mov    %edi,%ecx
  803437:	d3 e6                	shl    %cl,%esi
  803439:	39 c6                	cmp    %eax,%esi
  80343b:	73 07                	jae    803444 <__udivdi3+0xc4>
  80343d:	39 d5                	cmp    %edx,%ebp
  80343f:	75 03                	jne    803444 <__udivdi3+0xc4>
  803441:	83 eb 01             	sub    $0x1,%ebx
  803444:	31 ff                	xor    %edi,%edi
  803446:	89 d8                	mov    %ebx,%eax
  803448:	89 fa                	mov    %edi,%edx
  80344a:	83 c4 1c             	add    $0x1c,%esp
  80344d:	5b                   	pop    %ebx
  80344e:	5e                   	pop    %esi
  80344f:	5f                   	pop    %edi
  803450:	5d                   	pop    %ebp
  803451:	c3                   	ret    
  803452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803458:	31 ff                	xor    %edi,%edi
  80345a:	31 db                	xor    %ebx,%ebx
  80345c:	89 d8                	mov    %ebx,%eax
  80345e:	89 fa                	mov    %edi,%edx
  803460:	83 c4 1c             	add    $0x1c,%esp
  803463:	5b                   	pop    %ebx
  803464:	5e                   	pop    %esi
  803465:	5f                   	pop    %edi
  803466:	5d                   	pop    %ebp
  803467:	c3                   	ret    
  803468:	90                   	nop
  803469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803470:	89 d8                	mov    %ebx,%eax
  803472:	f7 f7                	div    %edi
  803474:	31 ff                	xor    %edi,%edi
  803476:	89 c3                	mov    %eax,%ebx
  803478:	89 d8                	mov    %ebx,%eax
  80347a:	89 fa                	mov    %edi,%edx
  80347c:	83 c4 1c             	add    $0x1c,%esp
  80347f:	5b                   	pop    %ebx
  803480:	5e                   	pop    %esi
  803481:	5f                   	pop    %edi
  803482:	5d                   	pop    %ebp
  803483:	c3                   	ret    
  803484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803488:	39 ce                	cmp    %ecx,%esi
  80348a:	72 0c                	jb     803498 <__udivdi3+0x118>
  80348c:	31 db                	xor    %ebx,%ebx
  80348e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803492:	0f 87 34 ff ff ff    	ja     8033cc <__udivdi3+0x4c>
  803498:	bb 01 00 00 00       	mov    $0x1,%ebx
  80349d:	e9 2a ff ff ff       	jmp    8033cc <__udivdi3+0x4c>
  8034a2:	66 90                	xchg   %ax,%ax
  8034a4:	66 90                	xchg   %ax,%ax
  8034a6:	66 90                	xchg   %ax,%ax
  8034a8:	66 90                	xchg   %ax,%ax
  8034aa:	66 90                	xchg   %ax,%ax
  8034ac:	66 90                	xchg   %ax,%ax
  8034ae:	66 90                	xchg   %ax,%ax

008034b0 <__umoddi3>:
  8034b0:	55                   	push   %ebp
  8034b1:	57                   	push   %edi
  8034b2:	56                   	push   %esi
  8034b3:	53                   	push   %ebx
  8034b4:	83 ec 1c             	sub    $0x1c,%esp
  8034b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8034bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8034bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8034c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8034c7:	85 d2                	test   %edx,%edx
  8034c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8034cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8034d1:	89 f3                	mov    %esi,%ebx
  8034d3:	89 3c 24             	mov    %edi,(%esp)
  8034d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8034da:	75 1c                	jne    8034f8 <__umoddi3+0x48>
  8034dc:	39 f7                	cmp    %esi,%edi
  8034de:	76 50                	jbe    803530 <__umoddi3+0x80>
  8034e0:	89 c8                	mov    %ecx,%eax
  8034e2:	89 f2                	mov    %esi,%edx
  8034e4:	f7 f7                	div    %edi
  8034e6:	89 d0                	mov    %edx,%eax
  8034e8:	31 d2                	xor    %edx,%edx
  8034ea:	83 c4 1c             	add    $0x1c,%esp
  8034ed:	5b                   	pop    %ebx
  8034ee:	5e                   	pop    %esi
  8034ef:	5f                   	pop    %edi
  8034f0:	5d                   	pop    %ebp
  8034f1:	c3                   	ret    
  8034f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8034f8:	39 f2                	cmp    %esi,%edx
  8034fa:	89 d0                	mov    %edx,%eax
  8034fc:	77 52                	ja     803550 <__umoddi3+0xa0>
  8034fe:	0f bd ea             	bsr    %edx,%ebp
  803501:	83 f5 1f             	xor    $0x1f,%ebp
  803504:	75 5a                	jne    803560 <__umoddi3+0xb0>
  803506:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80350a:	0f 82 e0 00 00 00    	jb     8035f0 <__umoddi3+0x140>
  803510:	39 0c 24             	cmp    %ecx,(%esp)
  803513:	0f 86 d7 00 00 00    	jbe    8035f0 <__umoddi3+0x140>
  803519:	8b 44 24 08          	mov    0x8(%esp),%eax
  80351d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803521:	83 c4 1c             	add    $0x1c,%esp
  803524:	5b                   	pop    %ebx
  803525:	5e                   	pop    %esi
  803526:	5f                   	pop    %edi
  803527:	5d                   	pop    %ebp
  803528:	c3                   	ret    
  803529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803530:	85 ff                	test   %edi,%edi
  803532:	89 fd                	mov    %edi,%ebp
  803534:	75 0b                	jne    803541 <__umoddi3+0x91>
  803536:	b8 01 00 00 00       	mov    $0x1,%eax
  80353b:	31 d2                	xor    %edx,%edx
  80353d:	f7 f7                	div    %edi
  80353f:	89 c5                	mov    %eax,%ebp
  803541:	89 f0                	mov    %esi,%eax
  803543:	31 d2                	xor    %edx,%edx
  803545:	f7 f5                	div    %ebp
  803547:	89 c8                	mov    %ecx,%eax
  803549:	f7 f5                	div    %ebp
  80354b:	89 d0                	mov    %edx,%eax
  80354d:	eb 99                	jmp    8034e8 <__umoddi3+0x38>
  80354f:	90                   	nop
  803550:	89 c8                	mov    %ecx,%eax
  803552:	89 f2                	mov    %esi,%edx
  803554:	83 c4 1c             	add    $0x1c,%esp
  803557:	5b                   	pop    %ebx
  803558:	5e                   	pop    %esi
  803559:	5f                   	pop    %edi
  80355a:	5d                   	pop    %ebp
  80355b:	c3                   	ret    
  80355c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803560:	8b 34 24             	mov    (%esp),%esi
  803563:	bf 20 00 00 00       	mov    $0x20,%edi
  803568:	89 e9                	mov    %ebp,%ecx
  80356a:	29 ef                	sub    %ebp,%edi
  80356c:	d3 e0                	shl    %cl,%eax
  80356e:	89 f9                	mov    %edi,%ecx
  803570:	89 f2                	mov    %esi,%edx
  803572:	d3 ea                	shr    %cl,%edx
  803574:	89 e9                	mov    %ebp,%ecx
  803576:	09 c2                	or     %eax,%edx
  803578:	89 d8                	mov    %ebx,%eax
  80357a:	89 14 24             	mov    %edx,(%esp)
  80357d:	89 f2                	mov    %esi,%edx
  80357f:	d3 e2                	shl    %cl,%edx
  803581:	89 f9                	mov    %edi,%ecx
  803583:	89 54 24 04          	mov    %edx,0x4(%esp)
  803587:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80358b:	d3 e8                	shr    %cl,%eax
  80358d:	89 e9                	mov    %ebp,%ecx
  80358f:	89 c6                	mov    %eax,%esi
  803591:	d3 e3                	shl    %cl,%ebx
  803593:	89 f9                	mov    %edi,%ecx
  803595:	89 d0                	mov    %edx,%eax
  803597:	d3 e8                	shr    %cl,%eax
  803599:	89 e9                	mov    %ebp,%ecx
  80359b:	09 d8                	or     %ebx,%eax
  80359d:	89 d3                	mov    %edx,%ebx
  80359f:	89 f2                	mov    %esi,%edx
  8035a1:	f7 34 24             	divl   (%esp)
  8035a4:	89 d6                	mov    %edx,%esi
  8035a6:	d3 e3                	shl    %cl,%ebx
  8035a8:	f7 64 24 04          	mull   0x4(%esp)
  8035ac:	39 d6                	cmp    %edx,%esi
  8035ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8035b2:	89 d1                	mov    %edx,%ecx
  8035b4:	89 c3                	mov    %eax,%ebx
  8035b6:	72 08                	jb     8035c0 <__umoddi3+0x110>
  8035b8:	75 11                	jne    8035cb <__umoddi3+0x11b>
  8035ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8035be:	73 0b                	jae    8035cb <__umoddi3+0x11b>
  8035c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8035c4:	1b 14 24             	sbb    (%esp),%edx
  8035c7:	89 d1                	mov    %edx,%ecx
  8035c9:	89 c3                	mov    %eax,%ebx
  8035cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8035cf:	29 da                	sub    %ebx,%edx
  8035d1:	19 ce                	sbb    %ecx,%esi
  8035d3:	89 f9                	mov    %edi,%ecx
  8035d5:	89 f0                	mov    %esi,%eax
  8035d7:	d3 e0                	shl    %cl,%eax
  8035d9:	89 e9                	mov    %ebp,%ecx
  8035db:	d3 ea                	shr    %cl,%edx
  8035dd:	89 e9                	mov    %ebp,%ecx
  8035df:	d3 ee                	shr    %cl,%esi
  8035e1:	09 d0                	or     %edx,%eax
  8035e3:	89 f2                	mov    %esi,%edx
  8035e5:	83 c4 1c             	add    $0x1c,%esp
  8035e8:	5b                   	pop    %ebx
  8035e9:	5e                   	pop    %esi
  8035ea:	5f                   	pop    %edi
  8035eb:	5d                   	pop    %ebp
  8035ec:	c3                   	ret    
  8035ed:	8d 76 00             	lea    0x0(%esi),%esi
  8035f0:	29 f9                	sub    %edi,%ecx
  8035f2:	19 d6                	sbb    %edx,%esi
  8035f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8035f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8035fc:	e9 18 ff ff ff       	jmp    803519 <__umoddi3+0x69>
