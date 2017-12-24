
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
  80005b:	68 e0 32 80 00       	push   $0x8032e0
  800060:	e8 d1 0a 00 00       	call   800b36 <cprintf>
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
  80007f:	68 ef 32 80 00       	push   $0x8032ef
  800084:	e8 ad 0a 00 00       	call   800b36 <cprintf>
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
  8000ab:	68 fd 32 80 00       	push   $0x8032fd
  8000b0:	e8 01 12 00 00       	call   8012b6 <strchr>
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
  8000d8:	68 02 33 80 00       	push   $0x803302
  8000dd:	e8 54 0a 00 00       	call   800b36 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 13 33 80 00       	push   $0x803313
  8000fb:	e8 b6 11 00 00       	call   8012b6 <strchr>
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
  800126:	68 07 33 80 00       	push   $0x803307
  80012b:	e8 06 0a 00 00       	call   800b36 <cprintf>
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
  80014c:	68 0f 33 80 00       	push   $0x80330f
  800151:	e8 60 11 00 00       	call   8012b6 <strchr>
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
  80017b:	68 1b 33 80 00       	push   $0x80331b
  800180:	e8 b1 09 00 00       	call   800b36 <cprintf>
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
  800273:	68 25 33 80 00       	push   $0x803325
  800278:	e8 b9 08 00 00       	call   800b36 <cprintf>
				exit();
  80027d:	e8 c1 07 00 00       	call   800a43 <exit>
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
  8002a7:	68 78 34 80 00       	push   $0x803478
  8002ac:	e8 85 08 00 00       	call   800b36 <cprintf>
				exit();
  8002b1:	e8 8d 07 00 00       	call   800a43 <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 54 20 00 00       	call   80231a <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
				cprintf("open %s for read: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 39 33 80 00       	push   $0x803339
  8002db:	e8 56 08 00 00       	call   800b36 <cprintf>
				exit();
  8002e0:	e8 5e 07 00 00       	call   800a43 <exit>
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
  8002f8:	e8 a6 1a 00 00       	call   801da3 <dup>
				close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 4e 1a 00 00       	call   801d53 <close>
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
  800323:	68 a0 34 80 00       	push   $0x8034a0
  800328:	e8 09 08 00 00       	call   800b36 <cprintf>
				exit();
  80032d:	e8 11 07 00 00       	call   800a43 <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 d5 1f 00 00       	call   80231a <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 4e 33 80 00       	push   $0x80334e
  80035a:	e8 d7 07 00 00       	call   800b36 <cprintf>
				exit();
  80035f:	e8 df 06 00 00       	call   800a43 <exit>
  800364:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800367:	83 ff 01             	cmp    $0x1,%edi
  80036a:	0f 84 ba fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	6a 01                	push   $0x1
  800375:	57                   	push   %edi
  800376:	e8 28 1a 00 00       	call   801da3 <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 d0 19 00 00       	call   801d53 <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 ec 28 00 00       	call   802c86 <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 64 33 80 00       	push   $0x803364
  8003aa:	e8 87 07 00 00       	call   800b36 <cprintf>
				exit();
  8003af:	e8 8f 06 00 00       	call   800a43 <exit>
  8003b4:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003be:	74 1c                	je     8003dc <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c0:	83 ec 04             	sub    $0x4,%esp
  8003c3:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003c9:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003cf:	68 6d 33 80 00       	push   $0x80336d
  8003d4:	e8 5d 07 00 00       	call   800b36 <cprintf>
  8003d9:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dc:	e8 97 14 00 00       	call   801878 <fork>
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 16                	jns    8003fd <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	50                   	push   %eax
  8003eb:	68 7a 33 80 00       	push   $0x80337a
  8003f0:	e8 41 07 00 00       	call   800b36 <cprintf>
				exit();
  8003f5:	e8 49 06 00 00       	call   800a43 <exit>
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
  800411:	e8 8d 19 00 00       	call   801da3 <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 2f 19 00 00       	call   801d53 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 1e 19 00 00       	call   801d53 <close>
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
  80044e:	e8 50 19 00 00       	call   801da3 <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 f2 18 00 00       	call   801d53 <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 e1 18 00 00       	call   801d53 <close>
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 17                	jmp    80048e <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800477:	50                   	push   %eax
  800478:	68 83 33 80 00       	push   $0x803383
  80047d:	6a 79                	push   $0x79
  80047f:	68 9f 33 80 00       	push   $0x80339f
  800484:	e8 d4 05 00 00       	call   800a5d <_panic>
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
  8004a2:	68 a9 33 80 00       	push   $0x8033a9
  8004a7:	e8 8a 06 00 00       	call   800b36 <cprintf>
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
  8004d4:	e8 d5 0c 00 00       	call   8011ae <strcpy>
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
  8004f5:	8b 40 48             	mov    0x48(%eax),%eax
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	50                   	push   %eax
  8004fc:	68 b8 33 80 00       	push   $0x8033b8
  800501:	e8 30 06 00 00       	call   800b36 <cprintf>
  800506:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 11                	jmp    80051f <runcmd+0x316>
			cprintf(" %s", argv[i]);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	50                   	push   %eax
  800512:	68 40 34 80 00       	push   $0x803440
  800517:	e8 1a 06 00 00       	call   800b36 <cprintf>
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
  80052c:	68 00 33 80 00       	push   $0x803300
  800531:	e8 00 06 00 00       	call   800b36 <cprintf>
  800536:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 a8             	pushl  -0x58(%ebp)
  800543:	e8 86 1f 00 00       	call   8024ce <spawn>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	0f 89 c3 00 00 00    	jns    800618 <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800555:	83 ec 04             	sub    $0x4,%esp
  800558:	50                   	push   %eax
  800559:	ff 75 a8             	pushl  -0x58(%ebp)
  80055c:	68 c6 33 80 00       	push   $0x8033c6
  800561:	e8 d0 05 00 00       	call   800b36 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800566:	e8 13 18 00 00       	call   801d7e <close_all>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 4c                	jmp    8005bc <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800570:	a1 24 54 80 00       	mov    0x805424,%eax
  800575:	8b 40 48             	mov    0x48(%eax),%eax
  800578:	53                   	push   %ebx
  800579:	ff 75 a8             	pushl  -0x58(%ebp)
  80057c:	50                   	push   %eax
  80057d:	68 d4 33 80 00       	push   $0x8033d4
  800582:	e8 af 05 00 00       	call   800b36 <cprintf>
  800587:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058a:	83 ec 0c             	sub    $0xc,%esp
  80058d:	53                   	push   %ebx
  80058e:	e8 79 28 00 00       	call   802e0c <wait>
		if (debug)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059d:	0f 84 8c 00 00 00    	je     80062f <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a3:	a1 24 54 80 00       	mov    0x805424,%eax
  8005a8:	8b 40 48             	mov    0x48(%eax),%eax
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	50                   	push   %eax
  8005af:	68 e9 33 80 00       	push   $0x8033e9
  8005b4:	e8 7d 05 00 00       	call   800b36 <cprintf>
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
  8005ce:	8b 40 48             	mov    0x48(%eax),%eax
  8005d1:	83 ec 04             	sub    $0x4,%esp
  8005d4:	57                   	push   %edi
  8005d5:	50                   	push   %eax
  8005d6:	68 ff 33 80 00       	push   $0x8033ff
  8005db:	e8 56 05 00 00       	call   800b36 <cprintf>
  8005e0:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	57                   	push   %edi
  8005e7:	e8 20 28 00 00       	call   802e0c <wait>
		if (debug)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f6:	74 19                	je     800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f8:	a1 24 54 80 00       	mov    0x805424,%eax
  8005fd:	8b 40 48             	mov    0x48(%eax),%eax
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	50                   	push   %eax
  800604:	68 e9 33 80 00       	push   $0x8033e9
  800609:	e8 28 05 00 00       	call   800b36 <cprintf>
  80060e:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800611:	e8 2d 04 00 00       	call   800a43 <exit>
  800616:	eb 1d                	jmp    800635 <runcmd+0x42c>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800618:	e8 61 17 00 00       	call   801d7e <close_all>
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
  800643:	68 c8 34 80 00       	push   $0x8034c8
  800648:	e8 e9 04 00 00       	call   800b36 <cprintf>
	exit();
  80064d:	e8 f1 03 00 00       	call   800a43 <exit>
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
  80066c:	e8 ee 13 00 00       	call   801a5f <argstart>
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
  8006b8:	e8 d2 13 00 00       	call   801a8f <argnext>
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
  8006da:	e8 74 16 00 00       	call   801d53 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	6a 00                	push   $0x0
  8006e4:	ff 77 04             	pushl  0x4(%edi)
  8006e7:	e8 2e 1c 00 00       	call   80231a <open>
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	79 1b                	jns    80070e <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	50                   	push   %eax
  8006f7:	ff 77 04             	pushl  0x4(%edi)
  8006fa:	68 1c 34 80 00       	push   $0x80341c
  8006ff:	68 29 01 00 00       	push   $0x129
  800704:	68 9f 33 80 00       	push   $0x80339f
  800709:	e8 4f 03 00 00       	call   800a5d <_panic>
		assert(r == 0);
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 19                	je     80072b <umain+0xd4>
  800712:	68 28 34 80 00       	push   $0x803428
  800717:	68 2f 34 80 00       	push   $0x80342f
  80071c:	68 2a 01 00 00       	push   $0x12a
  800721:	68 9f 33 80 00       	push   $0x80339f
  800726:	e8 32 03 00 00       	call   800a5d <_panic>
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
  800746:	bf 44 34 80 00       	mov    $0x803444,%edi
  80074b:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80074e:	83 ec 0c             	sub    $0xc,%esp
  800751:	57                   	push   %edi
  800752:	e8 2b 09 00 00       	call   801082 <readline>
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
  80076c:	68 47 34 80 00       	push   $0x803447
  800771:	e8 c0 03 00 00       	call   800b36 <cprintf>
  800776:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800779:	e8 c5 02 00 00       	call   800a43 <exit>
		}
		if (debug)
  80077e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800785:	74 11                	je     800798 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	68 50 34 80 00       	push   $0x803450
  800790:	e8 a1 03 00 00       	call   800b36 <cprintf>
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
  8007a7:	68 5a 34 80 00       	push   $0x80345a
  8007ac:	e8 07 1d 00 00       	call   8024b8 <printf>
  8007b1:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bb:	74 10                	je     8007cd <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	68 60 34 80 00       	push   $0x803460
  8007c5:	e8 6c 03 00 00       	call   800b36 <cprintf>
  8007ca:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cd:	e8 a6 10 00 00       	call   801878 <fork>
  8007d2:	89 c6                	mov    %eax,%esi
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	79 15                	jns    8007ed <umain+0x196>
			panic("fork: %e", r);
  8007d8:	50                   	push   %eax
  8007d9:	68 7a 33 80 00       	push   $0x80337a
  8007de:	68 41 01 00 00       	push   $0x141
  8007e3:	68 9f 33 80 00       	push   $0x80339f
  8007e8:	e8 70 02 00 00       	call   800a5d <_panic>
		if (debug)
  8007ed:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f4:	74 11                	je     800807 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	50                   	push   %eax
  8007fa:	68 6d 34 80 00       	push   $0x80346d
  8007ff:	e8 32 03 00 00       	call   800b36 <cprintf>
  800804:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800807:	85 f6                	test   %esi,%esi
  800809:	75 16                	jne    800821 <umain+0x1ca>
			runcmd(buf);
  80080b:	83 ec 0c             	sub    $0xc,%esp
  80080e:	53                   	push   %ebx
  80080f:	e8 f5 f9 ff ff       	call   800209 <runcmd>
			exit();
  800814:	e8 2a 02 00 00       	call   800a43 <exit>
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	e9 2d ff ff ff       	jmp    80074e <umain+0xf7>
		} else
			wait(r);
  800821:	83 ec 0c             	sub    $0xc,%esp
  800824:	56                   	push   %esi
  800825:	e8 e2 25 00 00       	call   802e0c <wait>
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
  800842:	68 e9 34 80 00       	push   $0x8034e9
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	e8 5f 09 00 00       	call   8011ae <strcpy>
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
  800888:	e8 b3 0a 00 00       	call   801340 <memmove>
		sys_cputs(buf, m);
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	57                   	push   %edi
  800892:	e8 5e 0c 00 00       	call   8014f5 <sys_cputs>
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
  8008be:	e8 cf 0c 00 00       	call   801592 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c3:	e8 4b 0c 00 00       	call   801513 <sys_cgetc>
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
  8008fa:	e8 f6 0b 00 00       	call   8014f5 <sys_cputs>
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
  800912:	e8 78 15 00 00       	call   801e8f <read>
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
  80093c:	e8 e8 12 00 00       	call   801c29 <fd_lookup>
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
  800965:	e8 70 12 00 00       	call   801bda <fd_alloc>
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
  800980:	e8 2c 0c 00 00       	call   8015b1 <sys_page_alloc>
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
  8009a7:	e8 07 12 00 00       	call   801bb3 <fd2num>
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
  8009c8:	e8 a6 0b 00 00       	call   801573 <sys_getenvid>
  8009cd:	8b 3d 24 54 80 00    	mov    0x805424,%edi
  8009d3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8009d8:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8009dd:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8009e2:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8009e5:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8009eb:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8009ee:	39 c8                	cmp    %ecx,%eax
  8009f0:	0f 44 fb             	cmove  %ebx,%edi
  8009f3:	b9 01 00 00 00       	mov    $0x1,%ecx
  8009f8:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8009fb:	83 c2 01             	add    $0x1,%edx
  8009fe:	83 c3 7c             	add    $0x7c,%ebx
  800a01:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800a07:	75 d9                	jne    8009e2 <libmain+0x2d>
  800a09:	89 f0                	mov    %esi,%eax
  800a0b:	84 c0                	test   %al,%al
  800a0d:	74 06                	je     800a15 <libmain+0x60>
  800a0f:	89 3d 24 54 80 00    	mov    %edi,0x805424
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800a15:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800a19:	7e 0a                	jle    800a25 <libmain+0x70>
		binaryname = argv[0];
  800a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1e:	8b 00                	mov    (%eax),%eax
  800a20:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800a25:	83 ec 08             	sub    $0x8,%esp
  800a28:	ff 75 0c             	pushl  0xc(%ebp)
  800a2b:	ff 75 08             	pushl  0x8(%ebp)
  800a2e:	e8 24 fc ff ff       	call   800657 <umain>

	// exit gracefully
	exit();
  800a33:	e8 0b 00 00 00       	call   800a43 <exit>
}
  800a38:	83 c4 10             	add    $0x10,%esp
  800a3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5f                   	pop    %edi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a49:	e8 30 13 00 00       	call   801d7e <close_all>
	sys_env_destroy(0);
  800a4e:	83 ec 0c             	sub    $0xc,%esp
  800a51:	6a 00                	push   $0x0
  800a53:	e8 da 0a 00 00       	call   801532 <sys_env_destroy>
}
  800a58:	83 c4 10             	add    $0x10,%esp
  800a5b:	c9                   	leave  
  800a5c:	c3                   	ret    

00800a5d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a62:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a65:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a6b:	e8 03 0b 00 00       	call   801573 <sys_getenvid>
  800a70:	83 ec 0c             	sub    $0xc,%esp
  800a73:	ff 75 0c             	pushl  0xc(%ebp)
  800a76:	ff 75 08             	pushl  0x8(%ebp)
  800a79:	56                   	push   %esi
  800a7a:	50                   	push   %eax
  800a7b:	68 00 35 80 00       	push   $0x803500
  800a80:	e8 b1 00 00 00       	call   800b36 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a85:	83 c4 18             	add    $0x18,%esp
  800a88:	53                   	push   %ebx
  800a89:	ff 75 10             	pushl  0x10(%ebp)
  800a8c:	e8 54 00 00 00       	call   800ae5 <vcprintf>
	cprintf("\n");
  800a91:	c7 04 24 00 33 80 00 	movl   $0x803300,(%esp)
  800a98:	e8 99 00 00 00       	call   800b36 <cprintf>
  800a9d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800aa0:	cc                   	int3   
  800aa1:	eb fd                	jmp    800aa0 <_panic+0x43>

00800aa3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	53                   	push   %ebx
  800aa7:	83 ec 04             	sub    $0x4,%esp
  800aaa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800aad:	8b 13                	mov    (%ebx),%edx
  800aaf:	8d 42 01             	lea    0x1(%edx),%eax
  800ab2:	89 03                	mov    %eax,(%ebx)
  800ab4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800abb:	3d ff 00 00 00       	cmp    $0xff,%eax
  800ac0:	75 1a                	jne    800adc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800ac2:	83 ec 08             	sub    $0x8,%esp
  800ac5:	68 ff 00 00 00       	push   $0xff
  800aca:	8d 43 08             	lea    0x8(%ebx),%eax
  800acd:	50                   	push   %eax
  800ace:	e8 22 0a 00 00       	call   8014f5 <sys_cputs>
		b->idx = 0;
  800ad3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800ad9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800adc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800ae0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae3:	c9                   	leave  
  800ae4:	c3                   	ret    

00800ae5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800aee:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800af5:	00 00 00 
	b.cnt = 0;
  800af8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800aff:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800b02:	ff 75 0c             	pushl  0xc(%ebp)
  800b05:	ff 75 08             	pushl  0x8(%ebp)
  800b08:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b0e:	50                   	push   %eax
  800b0f:	68 a3 0a 80 00       	push   $0x800aa3
  800b14:	e8 54 01 00 00       	call   800c6d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b19:	83 c4 08             	add    $0x8,%esp
  800b1c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800b22:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b28:	50                   	push   %eax
  800b29:	e8 c7 09 00 00       	call   8014f5 <sys_cputs>

	return b.cnt;
}
  800b2e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    

00800b36 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b3c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b3f:	50                   	push   %eax
  800b40:	ff 75 08             	pushl  0x8(%ebp)
  800b43:	e8 9d ff ff ff       	call   800ae5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800b48:	c9                   	leave  
  800b49:	c3                   	ret    

00800b4a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
  800b50:	83 ec 1c             	sub    $0x1c,%esp
  800b53:	89 c7                	mov    %eax,%edi
  800b55:	89 d6                	mov    %edx,%esi
  800b57:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b60:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b63:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b6b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b6e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b71:	39 d3                	cmp    %edx,%ebx
  800b73:	72 05                	jb     800b7a <printnum+0x30>
  800b75:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b78:	77 45                	ja     800bbf <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b7a:	83 ec 0c             	sub    $0xc,%esp
  800b7d:	ff 75 18             	pushl  0x18(%ebp)
  800b80:	8b 45 14             	mov    0x14(%ebp),%eax
  800b83:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b86:	53                   	push   %ebx
  800b87:	ff 75 10             	pushl  0x10(%ebp)
  800b8a:	83 ec 08             	sub    $0x8,%esp
  800b8d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b90:	ff 75 e0             	pushl  -0x20(%ebp)
  800b93:	ff 75 dc             	pushl  -0x24(%ebp)
  800b96:	ff 75 d8             	pushl  -0x28(%ebp)
  800b99:	e8 a2 24 00 00       	call   803040 <__udivdi3>
  800b9e:	83 c4 18             	add    $0x18,%esp
  800ba1:	52                   	push   %edx
  800ba2:	50                   	push   %eax
  800ba3:	89 f2                	mov    %esi,%edx
  800ba5:	89 f8                	mov    %edi,%eax
  800ba7:	e8 9e ff ff ff       	call   800b4a <printnum>
  800bac:	83 c4 20             	add    $0x20,%esp
  800baf:	eb 18                	jmp    800bc9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800bb1:	83 ec 08             	sub    $0x8,%esp
  800bb4:	56                   	push   %esi
  800bb5:	ff 75 18             	pushl  0x18(%ebp)
  800bb8:	ff d7                	call   *%edi
  800bba:	83 c4 10             	add    $0x10,%esp
  800bbd:	eb 03                	jmp    800bc2 <printnum+0x78>
  800bbf:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800bc2:	83 eb 01             	sub    $0x1,%ebx
  800bc5:	85 db                	test   %ebx,%ebx
  800bc7:	7f e8                	jg     800bb1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800bc9:	83 ec 08             	sub    $0x8,%esp
  800bcc:	56                   	push   %esi
  800bcd:	83 ec 04             	sub    $0x4,%esp
  800bd0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bd3:	ff 75 e0             	pushl  -0x20(%ebp)
  800bd6:	ff 75 dc             	pushl  -0x24(%ebp)
  800bd9:	ff 75 d8             	pushl  -0x28(%ebp)
  800bdc:	e8 8f 25 00 00       	call   803170 <__umoddi3>
  800be1:	83 c4 14             	add    $0x14,%esp
  800be4:	0f be 80 23 35 80 00 	movsbl 0x803523(%eax),%eax
  800beb:	50                   	push   %eax
  800bec:	ff d7                	call   *%edi
}
  800bee:	83 c4 10             	add    $0x10,%esp
  800bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bfc:	83 fa 01             	cmp    $0x1,%edx
  800bff:	7e 0e                	jle    800c0f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800c01:	8b 10                	mov    (%eax),%edx
  800c03:	8d 4a 08             	lea    0x8(%edx),%ecx
  800c06:	89 08                	mov    %ecx,(%eax)
  800c08:	8b 02                	mov    (%edx),%eax
  800c0a:	8b 52 04             	mov    0x4(%edx),%edx
  800c0d:	eb 22                	jmp    800c31 <getuint+0x38>
	else if (lflag)
  800c0f:	85 d2                	test   %edx,%edx
  800c11:	74 10                	je     800c23 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800c13:	8b 10                	mov    (%eax),%edx
  800c15:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c18:	89 08                	mov    %ecx,(%eax)
  800c1a:	8b 02                	mov    (%edx),%eax
  800c1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c21:	eb 0e                	jmp    800c31 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800c23:	8b 10                	mov    (%eax),%edx
  800c25:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c28:	89 08                	mov    %ecx,(%eax)
  800c2a:	8b 02                	mov    (%edx),%eax
  800c2c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c39:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800c3d:	8b 10                	mov    (%eax),%edx
  800c3f:	3b 50 04             	cmp    0x4(%eax),%edx
  800c42:	73 0a                	jae    800c4e <sprintputch+0x1b>
		*b->buf++ = ch;
  800c44:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c47:	89 08                	mov    %ecx,(%eax)
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4c:	88 02                	mov    %al,(%edx)
}
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c56:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c59:	50                   	push   %eax
  800c5a:	ff 75 10             	pushl  0x10(%ebp)
  800c5d:	ff 75 0c             	pushl  0xc(%ebp)
  800c60:	ff 75 08             	pushl  0x8(%ebp)
  800c63:	e8 05 00 00 00       	call   800c6d <vprintfmt>
	va_end(ap);
}
  800c68:	83 c4 10             	add    $0x10,%esp
  800c6b:	c9                   	leave  
  800c6c:	c3                   	ret    

00800c6d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 2c             	sub    $0x2c,%esp
  800c76:	8b 75 08             	mov    0x8(%ebp),%esi
  800c79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c7c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c7f:	eb 12                	jmp    800c93 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c81:	85 c0                	test   %eax,%eax
  800c83:	0f 84 89 03 00 00    	je     801012 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800c89:	83 ec 08             	sub    $0x8,%esp
  800c8c:	53                   	push   %ebx
  800c8d:	50                   	push   %eax
  800c8e:	ff d6                	call   *%esi
  800c90:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c93:	83 c7 01             	add    $0x1,%edi
  800c96:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c9a:	83 f8 25             	cmp    $0x25,%eax
  800c9d:	75 e2                	jne    800c81 <vprintfmt+0x14>
  800c9f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800ca3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800caa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800cb1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800cb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbd:	eb 07                	jmp    800cc6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cbf:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800cc2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cc6:	8d 47 01             	lea    0x1(%edi),%eax
  800cc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ccc:	0f b6 07             	movzbl (%edi),%eax
  800ccf:	0f b6 c8             	movzbl %al,%ecx
  800cd2:	83 e8 23             	sub    $0x23,%eax
  800cd5:	3c 55                	cmp    $0x55,%al
  800cd7:	0f 87 1a 03 00 00    	ja     800ff7 <vprintfmt+0x38a>
  800cdd:	0f b6 c0             	movzbl %al,%eax
  800ce0:	ff 24 85 60 36 80 00 	jmp    *0x803660(,%eax,4)
  800ce7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800cea:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800cee:	eb d6                	jmp    800cc6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cf0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cf3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cfb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cfe:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800d02:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800d05:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800d08:	83 fa 09             	cmp    $0x9,%edx
  800d0b:	77 39                	ja     800d46 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d0d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800d10:	eb e9                	jmp    800cfb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800d12:	8b 45 14             	mov    0x14(%ebp),%eax
  800d15:	8d 48 04             	lea    0x4(%eax),%ecx
  800d18:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800d1b:	8b 00                	mov    (%eax),%eax
  800d1d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d20:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800d23:	eb 27                	jmp    800d4c <vprintfmt+0xdf>
  800d25:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2f:	0f 49 c8             	cmovns %eax,%ecx
  800d32:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d38:	eb 8c                	jmp    800cc6 <vprintfmt+0x59>
  800d3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d3d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800d44:	eb 80                	jmp    800cc6 <vprintfmt+0x59>
  800d46:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d49:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800d4c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d50:	0f 89 70 ff ff ff    	jns    800cc6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800d56:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d59:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d5c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d63:	e9 5e ff ff ff       	jmp    800cc6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d68:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d6e:	e9 53 ff ff ff       	jmp    800cc6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d73:	8b 45 14             	mov    0x14(%ebp),%eax
  800d76:	8d 50 04             	lea    0x4(%eax),%edx
  800d79:	89 55 14             	mov    %edx,0x14(%ebp)
  800d7c:	83 ec 08             	sub    $0x8,%esp
  800d7f:	53                   	push   %ebx
  800d80:	ff 30                	pushl  (%eax)
  800d82:	ff d6                	call   *%esi
			break;
  800d84:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d8a:	e9 04 ff ff ff       	jmp    800c93 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d8f:	8b 45 14             	mov    0x14(%ebp),%eax
  800d92:	8d 50 04             	lea    0x4(%eax),%edx
  800d95:	89 55 14             	mov    %edx,0x14(%ebp)
  800d98:	8b 00                	mov    (%eax),%eax
  800d9a:	99                   	cltd   
  800d9b:	31 d0                	xor    %edx,%eax
  800d9d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d9f:	83 f8 0f             	cmp    $0xf,%eax
  800da2:	7f 0b                	jg     800daf <vprintfmt+0x142>
  800da4:	8b 14 85 c0 37 80 00 	mov    0x8037c0(,%eax,4),%edx
  800dab:	85 d2                	test   %edx,%edx
  800dad:	75 18                	jne    800dc7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800daf:	50                   	push   %eax
  800db0:	68 3b 35 80 00       	push   $0x80353b
  800db5:	53                   	push   %ebx
  800db6:	56                   	push   %esi
  800db7:	e8 94 fe ff ff       	call   800c50 <printfmt>
  800dbc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dbf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800dc2:	e9 cc fe ff ff       	jmp    800c93 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800dc7:	52                   	push   %edx
  800dc8:	68 41 34 80 00       	push   $0x803441
  800dcd:	53                   	push   %ebx
  800dce:	56                   	push   %esi
  800dcf:	e8 7c fe ff ff       	call   800c50 <printfmt>
  800dd4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800dda:	e9 b4 fe ff ff       	jmp    800c93 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800ddf:	8b 45 14             	mov    0x14(%ebp),%eax
  800de2:	8d 50 04             	lea    0x4(%eax),%edx
  800de5:	89 55 14             	mov    %edx,0x14(%ebp)
  800de8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800dea:	85 ff                	test   %edi,%edi
  800dec:	b8 34 35 80 00       	mov    $0x803534,%eax
  800df1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800df4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800df8:	0f 8e 94 00 00 00    	jle    800e92 <vprintfmt+0x225>
  800dfe:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800e02:	0f 84 98 00 00 00    	je     800ea0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e08:	83 ec 08             	sub    $0x8,%esp
  800e0b:	ff 75 d0             	pushl  -0x30(%ebp)
  800e0e:	57                   	push   %edi
  800e0f:	e8 79 03 00 00       	call   80118d <strnlen>
  800e14:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e17:	29 c1                	sub    %eax,%ecx
  800e19:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800e1c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800e1f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800e23:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e26:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e29:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e2b:	eb 0f                	jmp    800e3c <vprintfmt+0x1cf>
					putch(padc, putdat);
  800e2d:	83 ec 08             	sub    $0x8,%esp
  800e30:	53                   	push   %ebx
  800e31:	ff 75 e0             	pushl  -0x20(%ebp)
  800e34:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e36:	83 ef 01             	sub    $0x1,%edi
  800e39:	83 c4 10             	add    $0x10,%esp
  800e3c:	85 ff                	test   %edi,%edi
  800e3e:	7f ed                	jg     800e2d <vprintfmt+0x1c0>
  800e40:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800e43:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800e46:	85 c9                	test   %ecx,%ecx
  800e48:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4d:	0f 49 c1             	cmovns %ecx,%eax
  800e50:	29 c1                	sub    %eax,%ecx
  800e52:	89 75 08             	mov    %esi,0x8(%ebp)
  800e55:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e58:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e5b:	89 cb                	mov    %ecx,%ebx
  800e5d:	eb 4d                	jmp    800eac <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e5f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e63:	74 1b                	je     800e80 <vprintfmt+0x213>
  800e65:	0f be c0             	movsbl %al,%eax
  800e68:	83 e8 20             	sub    $0x20,%eax
  800e6b:	83 f8 5e             	cmp    $0x5e,%eax
  800e6e:	76 10                	jbe    800e80 <vprintfmt+0x213>
					putch('?', putdat);
  800e70:	83 ec 08             	sub    $0x8,%esp
  800e73:	ff 75 0c             	pushl  0xc(%ebp)
  800e76:	6a 3f                	push   $0x3f
  800e78:	ff 55 08             	call   *0x8(%ebp)
  800e7b:	83 c4 10             	add    $0x10,%esp
  800e7e:	eb 0d                	jmp    800e8d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800e80:	83 ec 08             	sub    $0x8,%esp
  800e83:	ff 75 0c             	pushl  0xc(%ebp)
  800e86:	52                   	push   %edx
  800e87:	ff 55 08             	call   *0x8(%ebp)
  800e8a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e8d:	83 eb 01             	sub    $0x1,%ebx
  800e90:	eb 1a                	jmp    800eac <vprintfmt+0x23f>
  800e92:	89 75 08             	mov    %esi,0x8(%ebp)
  800e95:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e98:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e9b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e9e:	eb 0c                	jmp    800eac <vprintfmt+0x23f>
  800ea0:	89 75 08             	mov    %esi,0x8(%ebp)
  800ea3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ea6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ea9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800eac:	83 c7 01             	add    $0x1,%edi
  800eaf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800eb3:	0f be d0             	movsbl %al,%edx
  800eb6:	85 d2                	test   %edx,%edx
  800eb8:	74 23                	je     800edd <vprintfmt+0x270>
  800eba:	85 f6                	test   %esi,%esi
  800ebc:	78 a1                	js     800e5f <vprintfmt+0x1f2>
  800ebe:	83 ee 01             	sub    $0x1,%esi
  800ec1:	79 9c                	jns    800e5f <vprintfmt+0x1f2>
  800ec3:	89 df                	mov    %ebx,%edi
  800ec5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ec8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ecb:	eb 18                	jmp    800ee5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ecd:	83 ec 08             	sub    $0x8,%esp
  800ed0:	53                   	push   %ebx
  800ed1:	6a 20                	push   $0x20
  800ed3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ed5:	83 ef 01             	sub    $0x1,%edi
  800ed8:	83 c4 10             	add    $0x10,%esp
  800edb:	eb 08                	jmp    800ee5 <vprintfmt+0x278>
  800edd:	89 df                	mov    %ebx,%edi
  800edf:	8b 75 08             	mov    0x8(%ebp),%esi
  800ee2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ee5:	85 ff                	test   %edi,%edi
  800ee7:	7f e4                	jg     800ecd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ee9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800eec:	e9 a2 fd ff ff       	jmp    800c93 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ef1:	83 fa 01             	cmp    $0x1,%edx
  800ef4:	7e 16                	jle    800f0c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800ef6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ef9:	8d 50 08             	lea    0x8(%eax),%edx
  800efc:	89 55 14             	mov    %edx,0x14(%ebp)
  800eff:	8b 50 04             	mov    0x4(%eax),%edx
  800f02:	8b 00                	mov    (%eax),%eax
  800f04:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f07:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800f0a:	eb 32                	jmp    800f3e <vprintfmt+0x2d1>
	else if (lflag)
  800f0c:	85 d2                	test   %edx,%edx
  800f0e:	74 18                	je     800f28 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800f10:	8b 45 14             	mov    0x14(%ebp),%eax
  800f13:	8d 50 04             	lea    0x4(%eax),%edx
  800f16:	89 55 14             	mov    %edx,0x14(%ebp)
  800f19:	8b 00                	mov    (%eax),%eax
  800f1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f1e:	89 c1                	mov    %eax,%ecx
  800f20:	c1 f9 1f             	sar    $0x1f,%ecx
  800f23:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800f26:	eb 16                	jmp    800f3e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800f28:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2b:	8d 50 04             	lea    0x4(%eax),%edx
  800f2e:	89 55 14             	mov    %edx,0x14(%ebp)
  800f31:	8b 00                	mov    (%eax),%eax
  800f33:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f36:	89 c1                	mov    %eax,%ecx
  800f38:	c1 f9 1f             	sar    $0x1f,%ecx
  800f3b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800f3e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f41:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f44:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f49:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f4d:	79 74                	jns    800fc3 <vprintfmt+0x356>
				putch('-', putdat);
  800f4f:	83 ec 08             	sub    $0x8,%esp
  800f52:	53                   	push   %ebx
  800f53:	6a 2d                	push   $0x2d
  800f55:	ff d6                	call   *%esi
				num = -(long long) num;
  800f57:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f5a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f5d:	f7 d8                	neg    %eax
  800f5f:	83 d2 00             	adc    $0x0,%edx
  800f62:	f7 da                	neg    %edx
  800f64:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f67:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f6c:	eb 55                	jmp    800fc3 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f6e:	8d 45 14             	lea    0x14(%ebp),%eax
  800f71:	e8 83 fc ff ff       	call   800bf9 <getuint>
			base = 10;
  800f76:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f7b:	eb 46                	jmp    800fc3 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800f7d:	8d 45 14             	lea    0x14(%ebp),%eax
  800f80:	e8 74 fc ff ff       	call   800bf9 <getuint>
			base = 8;
  800f85:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800f8a:	eb 37                	jmp    800fc3 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800f8c:	83 ec 08             	sub    $0x8,%esp
  800f8f:	53                   	push   %ebx
  800f90:	6a 30                	push   $0x30
  800f92:	ff d6                	call   *%esi
			putch('x', putdat);
  800f94:	83 c4 08             	add    $0x8,%esp
  800f97:	53                   	push   %ebx
  800f98:	6a 78                	push   $0x78
  800f9a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f9c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f9f:	8d 50 04             	lea    0x4(%eax),%edx
  800fa2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800fa5:	8b 00                	mov    (%eax),%eax
  800fa7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800fac:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800faf:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800fb4:	eb 0d                	jmp    800fc3 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800fb6:	8d 45 14             	lea    0x14(%ebp),%eax
  800fb9:	e8 3b fc ff ff       	call   800bf9 <getuint>
			base = 16;
  800fbe:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800fca:	57                   	push   %edi
  800fcb:	ff 75 e0             	pushl  -0x20(%ebp)
  800fce:	51                   	push   %ecx
  800fcf:	52                   	push   %edx
  800fd0:	50                   	push   %eax
  800fd1:	89 da                	mov    %ebx,%edx
  800fd3:	89 f0                	mov    %esi,%eax
  800fd5:	e8 70 fb ff ff       	call   800b4a <printnum>
			break;
  800fda:	83 c4 20             	add    $0x20,%esp
  800fdd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fe0:	e9 ae fc ff ff       	jmp    800c93 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fe5:	83 ec 08             	sub    $0x8,%esp
  800fe8:	53                   	push   %ebx
  800fe9:	51                   	push   %ecx
  800fea:	ff d6                	call   *%esi
			break;
  800fec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ff2:	e9 9c fc ff ff       	jmp    800c93 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ff7:	83 ec 08             	sub    $0x8,%esp
  800ffa:	53                   	push   %ebx
  800ffb:	6a 25                	push   $0x25
  800ffd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fff:	83 c4 10             	add    $0x10,%esp
  801002:	eb 03                	jmp    801007 <vprintfmt+0x39a>
  801004:	83 ef 01             	sub    $0x1,%edi
  801007:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80100b:	75 f7                	jne    801004 <vprintfmt+0x397>
  80100d:	e9 81 fc ff ff       	jmp    800c93 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801012:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	83 ec 18             	sub    $0x18,%esp
  801020:	8b 45 08             	mov    0x8(%ebp),%eax
  801023:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801026:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801029:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80102d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801030:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801037:	85 c0                	test   %eax,%eax
  801039:	74 26                	je     801061 <vsnprintf+0x47>
  80103b:	85 d2                	test   %edx,%edx
  80103d:	7e 22                	jle    801061 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80103f:	ff 75 14             	pushl  0x14(%ebp)
  801042:	ff 75 10             	pushl  0x10(%ebp)
  801045:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801048:	50                   	push   %eax
  801049:	68 33 0c 80 00       	push   $0x800c33
  80104e:	e8 1a fc ff ff       	call   800c6d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801053:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801056:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801059:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	eb 05                	jmp    801066 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801061:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801066:	c9                   	leave  
  801067:	c3                   	ret    

00801068 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80106e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801071:	50                   	push   %eax
  801072:	ff 75 10             	pushl  0x10(%ebp)
  801075:	ff 75 0c             	pushl  0xc(%ebp)
  801078:	ff 75 08             	pushl  0x8(%ebp)
  80107b:	e8 9a ff ff ff       	call   80101a <vsnprintf>
	va_end(ap);

	return rc;
}
  801080:	c9                   	leave  
  801081:	c3                   	ret    

00801082 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	57                   	push   %edi
  801086:	56                   	push   %esi
  801087:	53                   	push   %ebx
  801088:	83 ec 0c             	sub    $0xc,%esp
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80108e:	85 c0                	test   %eax,%eax
  801090:	74 13                	je     8010a5 <readline+0x23>
		fprintf(1, "%s", prompt);
  801092:	83 ec 04             	sub    $0x4,%esp
  801095:	50                   	push   %eax
  801096:	68 41 34 80 00       	push   $0x803441
  80109b:	6a 01                	push   $0x1
  80109d:	e8 ff 13 00 00       	call   8024a1 <fprintf>
  8010a2:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	6a 00                	push   $0x0
  8010aa:	e8 80 f8 ff ff       	call   80092f <iscons>
  8010af:	89 c7                	mov    %eax,%edi
  8010b1:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8010b4:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8010b9:	e8 46 f8 ff ff       	call   800904 <getchar>
  8010be:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	79 29                	jns    8010ed <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8010c4:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  8010c9:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8010cc:	0f 84 9b 00 00 00    	je     80116d <readline+0xeb>
				cprintf("read error: %e\n", c);
  8010d2:	83 ec 08             	sub    $0x8,%esp
  8010d5:	53                   	push   %ebx
  8010d6:	68 1f 38 80 00       	push   $0x80381f
  8010db:	e8 56 fa ff ff       	call   800b36 <cprintf>
  8010e0:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8010e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e8:	e9 80 00 00 00       	jmp    80116d <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010ed:	83 f8 08             	cmp    $0x8,%eax
  8010f0:	0f 94 c2             	sete   %dl
  8010f3:	83 f8 7f             	cmp    $0x7f,%eax
  8010f6:	0f 94 c0             	sete   %al
  8010f9:	08 c2                	or     %al,%dl
  8010fb:	74 1a                	je     801117 <readline+0x95>
  8010fd:	85 f6                	test   %esi,%esi
  8010ff:	7e 16                	jle    801117 <readline+0x95>
			if (echoing)
  801101:	85 ff                	test   %edi,%edi
  801103:	74 0d                	je     801112 <readline+0x90>
				cputchar('\b');
  801105:	83 ec 0c             	sub    $0xc,%esp
  801108:	6a 08                	push   $0x8
  80110a:	e8 d9 f7 ff ff       	call   8008e8 <cputchar>
  80110f:	83 c4 10             	add    $0x10,%esp
			i--;
  801112:	83 ee 01             	sub    $0x1,%esi
  801115:	eb a2                	jmp    8010b9 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801117:	83 fb 1f             	cmp    $0x1f,%ebx
  80111a:	7e 26                	jle    801142 <readline+0xc0>
  80111c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801122:	7f 1e                	jg     801142 <readline+0xc0>
			if (echoing)
  801124:	85 ff                	test   %edi,%edi
  801126:	74 0c                	je     801134 <readline+0xb2>
				cputchar(c);
  801128:	83 ec 0c             	sub    $0xc,%esp
  80112b:	53                   	push   %ebx
  80112c:	e8 b7 f7 ff ff       	call   8008e8 <cputchar>
  801131:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  801134:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  80113a:	8d 76 01             	lea    0x1(%esi),%esi
  80113d:	e9 77 ff ff ff       	jmp    8010b9 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  801142:	83 fb 0a             	cmp    $0xa,%ebx
  801145:	74 09                	je     801150 <readline+0xce>
  801147:	83 fb 0d             	cmp    $0xd,%ebx
  80114a:	0f 85 69 ff ff ff    	jne    8010b9 <readline+0x37>
			if (echoing)
  801150:	85 ff                	test   %edi,%edi
  801152:	74 0d                	je     801161 <readline+0xdf>
				cputchar('\n');
  801154:	83 ec 0c             	sub    $0xc,%esp
  801157:	6a 0a                	push   $0xa
  801159:	e8 8a f7 ff ff       	call   8008e8 <cputchar>
  80115e:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801161:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  801168:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  80116d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801170:	5b                   	pop    %ebx
  801171:	5e                   	pop    %esi
  801172:	5f                   	pop    %edi
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80117b:	b8 00 00 00 00       	mov    $0x0,%eax
  801180:	eb 03                	jmp    801185 <strlen+0x10>
		n++;
  801182:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801185:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801189:	75 f7                	jne    801182 <strlen+0xd>
		n++;
	return n;
}
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801193:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801196:	ba 00 00 00 00       	mov    $0x0,%edx
  80119b:	eb 03                	jmp    8011a0 <strnlen+0x13>
		n++;
  80119d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011a0:	39 c2                	cmp    %eax,%edx
  8011a2:	74 08                	je     8011ac <strnlen+0x1f>
  8011a4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8011a8:	75 f3                	jne    80119d <strnlen+0x10>
  8011aa:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	53                   	push   %ebx
  8011b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	83 c2 01             	add    $0x1,%edx
  8011bd:	83 c1 01             	add    $0x1,%ecx
  8011c0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8011c4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8011c7:	84 db                	test   %bl,%bl
  8011c9:	75 ef                	jne    8011ba <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8011cb:	5b                   	pop    %ebx
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	53                   	push   %ebx
  8011d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011d5:	53                   	push   %ebx
  8011d6:	e8 9a ff ff ff       	call   801175 <strlen>
  8011db:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8011de:	ff 75 0c             	pushl  0xc(%ebp)
  8011e1:	01 d8                	add    %ebx,%eax
  8011e3:	50                   	push   %eax
  8011e4:	e8 c5 ff ff ff       	call   8011ae <strcpy>
	return dst;
}
  8011e9:	89 d8                	mov    %ebx,%eax
  8011eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ee:	c9                   	leave  
  8011ef:	c3                   	ret    

008011f0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	56                   	push   %esi
  8011f4:	53                   	push   %ebx
  8011f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8011f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fb:	89 f3                	mov    %esi,%ebx
  8011fd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801200:	89 f2                	mov    %esi,%edx
  801202:	eb 0f                	jmp    801213 <strncpy+0x23>
		*dst++ = *src;
  801204:	83 c2 01             	add    $0x1,%edx
  801207:	0f b6 01             	movzbl (%ecx),%eax
  80120a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80120d:	80 39 01             	cmpb   $0x1,(%ecx)
  801210:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801213:	39 da                	cmp    %ebx,%edx
  801215:	75 ed                	jne    801204 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801217:	89 f0                	mov    %esi,%eax
  801219:	5b                   	pop    %ebx
  80121a:	5e                   	pop    %esi
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	56                   	push   %esi
  801221:	53                   	push   %ebx
  801222:	8b 75 08             	mov    0x8(%ebp),%esi
  801225:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801228:	8b 55 10             	mov    0x10(%ebp),%edx
  80122b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80122d:	85 d2                	test   %edx,%edx
  80122f:	74 21                	je     801252 <strlcpy+0x35>
  801231:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801235:	89 f2                	mov    %esi,%edx
  801237:	eb 09                	jmp    801242 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801239:	83 c2 01             	add    $0x1,%edx
  80123c:	83 c1 01             	add    $0x1,%ecx
  80123f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801242:	39 c2                	cmp    %eax,%edx
  801244:	74 09                	je     80124f <strlcpy+0x32>
  801246:	0f b6 19             	movzbl (%ecx),%ebx
  801249:	84 db                	test   %bl,%bl
  80124b:	75 ec                	jne    801239 <strlcpy+0x1c>
  80124d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80124f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801252:	29 f0                	sub    %esi,%eax
}
  801254:	5b                   	pop    %ebx
  801255:	5e                   	pop    %esi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801261:	eb 06                	jmp    801269 <strcmp+0x11>
		p++, q++;
  801263:	83 c1 01             	add    $0x1,%ecx
  801266:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801269:	0f b6 01             	movzbl (%ecx),%eax
  80126c:	84 c0                	test   %al,%al
  80126e:	74 04                	je     801274 <strcmp+0x1c>
  801270:	3a 02                	cmp    (%edx),%al
  801272:	74 ef                	je     801263 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801274:	0f b6 c0             	movzbl %al,%eax
  801277:	0f b6 12             	movzbl (%edx),%edx
  80127a:	29 d0                	sub    %edx,%eax
}
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    

0080127e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	53                   	push   %ebx
  801282:	8b 45 08             	mov    0x8(%ebp),%eax
  801285:	8b 55 0c             	mov    0xc(%ebp),%edx
  801288:	89 c3                	mov    %eax,%ebx
  80128a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80128d:	eb 06                	jmp    801295 <strncmp+0x17>
		n--, p++, q++;
  80128f:	83 c0 01             	add    $0x1,%eax
  801292:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801295:	39 d8                	cmp    %ebx,%eax
  801297:	74 15                	je     8012ae <strncmp+0x30>
  801299:	0f b6 08             	movzbl (%eax),%ecx
  80129c:	84 c9                	test   %cl,%cl
  80129e:	74 04                	je     8012a4 <strncmp+0x26>
  8012a0:	3a 0a                	cmp    (%edx),%cl
  8012a2:	74 eb                	je     80128f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8012a4:	0f b6 00             	movzbl (%eax),%eax
  8012a7:	0f b6 12             	movzbl (%edx),%edx
  8012aa:	29 d0                	sub    %edx,%eax
  8012ac:	eb 05                	jmp    8012b3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8012ae:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8012b3:	5b                   	pop    %ebx
  8012b4:	5d                   	pop    %ebp
  8012b5:	c3                   	ret    

008012b6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012c0:	eb 07                	jmp    8012c9 <strchr+0x13>
		if (*s == c)
  8012c2:	38 ca                	cmp    %cl,%dl
  8012c4:	74 0f                	je     8012d5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012c6:	83 c0 01             	add    $0x1,%eax
  8012c9:	0f b6 10             	movzbl (%eax),%edx
  8012cc:	84 d2                	test   %dl,%dl
  8012ce:	75 f2                	jne    8012c2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8012d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d5:	5d                   	pop    %ebp
  8012d6:	c3                   	ret    

008012d7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
  8012da:	8b 45 08             	mov    0x8(%ebp),%eax
  8012dd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012e1:	eb 03                	jmp    8012e6 <strfind+0xf>
  8012e3:	83 c0 01             	add    $0x1,%eax
  8012e6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8012e9:	38 ca                	cmp    %cl,%dl
  8012eb:	74 04                	je     8012f1 <strfind+0x1a>
  8012ed:	84 d2                	test   %dl,%dl
  8012ef:	75 f2                	jne    8012e3 <strfind+0xc>
			break;
	return (char *) s;
}
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    

008012f3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	57                   	push   %edi
  8012f7:	56                   	push   %esi
  8012f8:	53                   	push   %ebx
  8012f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012ff:	85 c9                	test   %ecx,%ecx
  801301:	74 36                	je     801339 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801303:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801309:	75 28                	jne    801333 <memset+0x40>
  80130b:	f6 c1 03             	test   $0x3,%cl
  80130e:	75 23                	jne    801333 <memset+0x40>
		c &= 0xFF;
  801310:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801314:	89 d3                	mov    %edx,%ebx
  801316:	c1 e3 08             	shl    $0x8,%ebx
  801319:	89 d6                	mov    %edx,%esi
  80131b:	c1 e6 18             	shl    $0x18,%esi
  80131e:	89 d0                	mov    %edx,%eax
  801320:	c1 e0 10             	shl    $0x10,%eax
  801323:	09 f0                	or     %esi,%eax
  801325:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801327:	89 d8                	mov    %ebx,%eax
  801329:	09 d0                	or     %edx,%eax
  80132b:	c1 e9 02             	shr    $0x2,%ecx
  80132e:	fc                   	cld    
  80132f:	f3 ab                	rep stos %eax,%es:(%edi)
  801331:	eb 06                	jmp    801339 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801333:	8b 45 0c             	mov    0xc(%ebp),%eax
  801336:	fc                   	cld    
  801337:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801339:	89 f8                	mov    %edi,%eax
  80133b:	5b                   	pop    %ebx
  80133c:	5e                   	pop    %esi
  80133d:	5f                   	pop    %edi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    

00801340 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	57                   	push   %edi
  801344:	56                   	push   %esi
  801345:	8b 45 08             	mov    0x8(%ebp),%eax
  801348:	8b 75 0c             	mov    0xc(%ebp),%esi
  80134b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80134e:	39 c6                	cmp    %eax,%esi
  801350:	73 35                	jae    801387 <memmove+0x47>
  801352:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801355:	39 d0                	cmp    %edx,%eax
  801357:	73 2e                	jae    801387 <memmove+0x47>
		s += n;
		d += n;
  801359:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80135c:	89 d6                	mov    %edx,%esi
  80135e:	09 fe                	or     %edi,%esi
  801360:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801366:	75 13                	jne    80137b <memmove+0x3b>
  801368:	f6 c1 03             	test   $0x3,%cl
  80136b:	75 0e                	jne    80137b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80136d:	83 ef 04             	sub    $0x4,%edi
  801370:	8d 72 fc             	lea    -0x4(%edx),%esi
  801373:	c1 e9 02             	shr    $0x2,%ecx
  801376:	fd                   	std    
  801377:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801379:	eb 09                	jmp    801384 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80137b:	83 ef 01             	sub    $0x1,%edi
  80137e:	8d 72 ff             	lea    -0x1(%edx),%esi
  801381:	fd                   	std    
  801382:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801384:	fc                   	cld    
  801385:	eb 1d                	jmp    8013a4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801387:	89 f2                	mov    %esi,%edx
  801389:	09 c2                	or     %eax,%edx
  80138b:	f6 c2 03             	test   $0x3,%dl
  80138e:	75 0f                	jne    80139f <memmove+0x5f>
  801390:	f6 c1 03             	test   $0x3,%cl
  801393:	75 0a                	jne    80139f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801395:	c1 e9 02             	shr    $0x2,%ecx
  801398:	89 c7                	mov    %eax,%edi
  80139a:	fc                   	cld    
  80139b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80139d:	eb 05                	jmp    8013a4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80139f:	89 c7                	mov    %eax,%edi
  8013a1:	fc                   	cld    
  8013a2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8013a4:	5e                   	pop    %esi
  8013a5:	5f                   	pop    %edi
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8013ab:	ff 75 10             	pushl  0x10(%ebp)
  8013ae:	ff 75 0c             	pushl  0xc(%ebp)
  8013b1:	ff 75 08             	pushl  0x8(%ebp)
  8013b4:	e8 87 ff ff ff       	call   801340 <memmove>
}
  8013b9:	c9                   	leave  
  8013ba:	c3                   	ret    

008013bb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	56                   	push   %esi
  8013bf:	53                   	push   %ebx
  8013c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c6:	89 c6                	mov    %eax,%esi
  8013c8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013cb:	eb 1a                	jmp    8013e7 <memcmp+0x2c>
		if (*s1 != *s2)
  8013cd:	0f b6 08             	movzbl (%eax),%ecx
  8013d0:	0f b6 1a             	movzbl (%edx),%ebx
  8013d3:	38 d9                	cmp    %bl,%cl
  8013d5:	74 0a                	je     8013e1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8013d7:	0f b6 c1             	movzbl %cl,%eax
  8013da:	0f b6 db             	movzbl %bl,%ebx
  8013dd:	29 d8                	sub    %ebx,%eax
  8013df:	eb 0f                	jmp    8013f0 <memcmp+0x35>
		s1++, s2++;
  8013e1:	83 c0 01             	add    $0x1,%eax
  8013e4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013e7:	39 f0                	cmp    %esi,%eax
  8013e9:	75 e2                	jne    8013cd <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f0:	5b                   	pop    %ebx
  8013f1:	5e                   	pop    %esi
  8013f2:	5d                   	pop    %ebp
  8013f3:	c3                   	ret    

008013f4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	53                   	push   %ebx
  8013f8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8013fb:	89 c1                	mov    %eax,%ecx
  8013fd:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801400:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801404:	eb 0a                	jmp    801410 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801406:	0f b6 10             	movzbl (%eax),%edx
  801409:	39 da                	cmp    %ebx,%edx
  80140b:	74 07                	je     801414 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80140d:	83 c0 01             	add    $0x1,%eax
  801410:	39 c8                	cmp    %ecx,%eax
  801412:	72 f2                	jb     801406 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801414:	5b                   	pop    %ebx
  801415:	5d                   	pop    %ebp
  801416:	c3                   	ret    

00801417 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	57                   	push   %edi
  80141b:	56                   	push   %esi
  80141c:	53                   	push   %ebx
  80141d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801420:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801423:	eb 03                	jmp    801428 <strtol+0x11>
		s++;
  801425:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801428:	0f b6 01             	movzbl (%ecx),%eax
  80142b:	3c 20                	cmp    $0x20,%al
  80142d:	74 f6                	je     801425 <strtol+0xe>
  80142f:	3c 09                	cmp    $0x9,%al
  801431:	74 f2                	je     801425 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801433:	3c 2b                	cmp    $0x2b,%al
  801435:	75 0a                	jne    801441 <strtol+0x2a>
		s++;
  801437:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80143a:	bf 00 00 00 00       	mov    $0x0,%edi
  80143f:	eb 11                	jmp    801452 <strtol+0x3b>
  801441:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801446:	3c 2d                	cmp    $0x2d,%al
  801448:	75 08                	jne    801452 <strtol+0x3b>
		s++, neg = 1;
  80144a:	83 c1 01             	add    $0x1,%ecx
  80144d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801452:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801458:	75 15                	jne    80146f <strtol+0x58>
  80145a:	80 39 30             	cmpb   $0x30,(%ecx)
  80145d:	75 10                	jne    80146f <strtol+0x58>
  80145f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801463:	75 7c                	jne    8014e1 <strtol+0xca>
		s += 2, base = 16;
  801465:	83 c1 02             	add    $0x2,%ecx
  801468:	bb 10 00 00 00       	mov    $0x10,%ebx
  80146d:	eb 16                	jmp    801485 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80146f:	85 db                	test   %ebx,%ebx
  801471:	75 12                	jne    801485 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801473:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801478:	80 39 30             	cmpb   $0x30,(%ecx)
  80147b:	75 08                	jne    801485 <strtol+0x6e>
		s++, base = 8;
  80147d:	83 c1 01             	add    $0x1,%ecx
  801480:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801485:	b8 00 00 00 00       	mov    $0x0,%eax
  80148a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80148d:	0f b6 11             	movzbl (%ecx),%edx
  801490:	8d 72 d0             	lea    -0x30(%edx),%esi
  801493:	89 f3                	mov    %esi,%ebx
  801495:	80 fb 09             	cmp    $0x9,%bl
  801498:	77 08                	ja     8014a2 <strtol+0x8b>
			dig = *s - '0';
  80149a:	0f be d2             	movsbl %dl,%edx
  80149d:	83 ea 30             	sub    $0x30,%edx
  8014a0:	eb 22                	jmp    8014c4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8014a2:	8d 72 9f             	lea    -0x61(%edx),%esi
  8014a5:	89 f3                	mov    %esi,%ebx
  8014a7:	80 fb 19             	cmp    $0x19,%bl
  8014aa:	77 08                	ja     8014b4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8014ac:	0f be d2             	movsbl %dl,%edx
  8014af:	83 ea 57             	sub    $0x57,%edx
  8014b2:	eb 10                	jmp    8014c4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8014b4:	8d 72 bf             	lea    -0x41(%edx),%esi
  8014b7:	89 f3                	mov    %esi,%ebx
  8014b9:	80 fb 19             	cmp    $0x19,%bl
  8014bc:	77 16                	ja     8014d4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8014be:	0f be d2             	movsbl %dl,%edx
  8014c1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8014c4:	3b 55 10             	cmp    0x10(%ebp),%edx
  8014c7:	7d 0b                	jge    8014d4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8014c9:	83 c1 01             	add    $0x1,%ecx
  8014cc:	0f af 45 10          	imul   0x10(%ebp),%eax
  8014d0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8014d2:	eb b9                	jmp    80148d <strtol+0x76>

	if (endptr)
  8014d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014d8:	74 0d                	je     8014e7 <strtol+0xd0>
		*endptr = (char *) s;
  8014da:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014dd:	89 0e                	mov    %ecx,(%esi)
  8014df:	eb 06                	jmp    8014e7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014e1:	85 db                	test   %ebx,%ebx
  8014e3:	74 98                	je     80147d <strtol+0x66>
  8014e5:	eb 9e                	jmp    801485 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8014e7:	89 c2                	mov    %eax,%edx
  8014e9:	f7 da                	neg    %edx
  8014eb:	85 ff                	test   %edi,%edi
  8014ed:	0f 45 c2             	cmovne %edx,%eax
}
  8014f0:	5b                   	pop    %ebx
  8014f1:	5e                   	pop    %esi
  8014f2:	5f                   	pop    %edi
  8014f3:	5d                   	pop    %ebp
  8014f4:	c3                   	ret    

008014f5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	57                   	push   %edi
  8014f9:	56                   	push   %esi
  8014fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801500:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801503:	8b 55 08             	mov    0x8(%ebp),%edx
  801506:	89 c3                	mov    %eax,%ebx
  801508:	89 c7                	mov    %eax,%edi
  80150a:	89 c6                	mov    %eax,%esi
  80150c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80150e:	5b                   	pop    %ebx
  80150f:	5e                   	pop    %esi
  801510:	5f                   	pop    %edi
  801511:	5d                   	pop    %ebp
  801512:	c3                   	ret    

00801513 <sys_cgetc>:

int
sys_cgetc(void)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	57                   	push   %edi
  801517:	56                   	push   %esi
  801518:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801519:	ba 00 00 00 00       	mov    $0x0,%edx
  80151e:	b8 01 00 00 00       	mov    $0x1,%eax
  801523:	89 d1                	mov    %edx,%ecx
  801525:	89 d3                	mov    %edx,%ebx
  801527:	89 d7                	mov    %edx,%edi
  801529:	89 d6                	mov    %edx,%esi
  80152b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80152d:	5b                   	pop    %ebx
  80152e:	5e                   	pop    %esi
  80152f:	5f                   	pop    %edi
  801530:	5d                   	pop    %ebp
  801531:	c3                   	ret    

00801532 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	57                   	push   %edi
  801536:	56                   	push   %esi
  801537:	53                   	push   %ebx
  801538:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80153b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801540:	b8 03 00 00 00       	mov    $0x3,%eax
  801545:	8b 55 08             	mov    0x8(%ebp),%edx
  801548:	89 cb                	mov    %ecx,%ebx
  80154a:	89 cf                	mov    %ecx,%edi
  80154c:	89 ce                	mov    %ecx,%esi
  80154e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801550:	85 c0                	test   %eax,%eax
  801552:	7e 17                	jle    80156b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801554:	83 ec 0c             	sub    $0xc,%esp
  801557:	50                   	push   %eax
  801558:	6a 03                	push   $0x3
  80155a:	68 2f 38 80 00       	push   $0x80382f
  80155f:	6a 23                	push   $0x23
  801561:	68 4c 38 80 00       	push   $0x80384c
  801566:	e8 f2 f4 ff ff       	call   800a5d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80156b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5f                   	pop    %edi
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    

00801573 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	57                   	push   %edi
  801577:	56                   	push   %esi
  801578:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801579:	ba 00 00 00 00       	mov    $0x0,%edx
  80157e:	b8 02 00 00 00       	mov    $0x2,%eax
  801583:	89 d1                	mov    %edx,%ecx
  801585:	89 d3                	mov    %edx,%ebx
  801587:	89 d7                	mov    %edx,%edi
  801589:	89 d6                	mov    %edx,%esi
  80158b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80158d:	5b                   	pop    %ebx
  80158e:	5e                   	pop    %esi
  80158f:	5f                   	pop    %edi
  801590:	5d                   	pop    %ebp
  801591:	c3                   	ret    

00801592 <sys_yield>:

void
sys_yield(void)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	57                   	push   %edi
  801596:	56                   	push   %esi
  801597:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801598:	ba 00 00 00 00       	mov    $0x0,%edx
  80159d:	b8 0b 00 00 00       	mov    $0xb,%eax
  8015a2:	89 d1                	mov    %edx,%ecx
  8015a4:	89 d3                	mov    %edx,%ebx
  8015a6:	89 d7                	mov    %edx,%edi
  8015a8:	89 d6                	mov    %edx,%esi
  8015aa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8015ac:	5b                   	pop    %ebx
  8015ad:	5e                   	pop    %esi
  8015ae:	5f                   	pop    %edi
  8015af:	5d                   	pop    %ebp
  8015b0:	c3                   	ret    

008015b1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	57                   	push   %edi
  8015b5:	56                   	push   %esi
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015ba:	be 00 00 00 00       	mov    $0x0,%esi
  8015bf:	b8 04 00 00 00       	mov    $0x4,%eax
  8015c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015cd:	89 f7                	mov    %esi,%edi
  8015cf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	7e 17                	jle    8015ec <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015d5:	83 ec 0c             	sub    $0xc,%esp
  8015d8:	50                   	push   %eax
  8015d9:	6a 04                	push   $0x4
  8015db:	68 2f 38 80 00       	push   $0x80382f
  8015e0:	6a 23                	push   $0x23
  8015e2:	68 4c 38 80 00       	push   $0x80384c
  8015e7:	e8 71 f4 ff ff       	call   800a5d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ef:	5b                   	pop    %ebx
  8015f0:	5e                   	pop    %esi
  8015f1:	5f                   	pop    %edi
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    

008015f4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	57                   	push   %edi
  8015f8:	56                   	push   %esi
  8015f9:	53                   	push   %ebx
  8015fa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015fd:	b8 05 00 00 00       	mov    $0x5,%eax
  801602:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801605:	8b 55 08             	mov    0x8(%ebp),%edx
  801608:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80160b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80160e:	8b 75 18             	mov    0x18(%ebp),%esi
  801611:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801613:	85 c0                	test   %eax,%eax
  801615:	7e 17                	jle    80162e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801617:	83 ec 0c             	sub    $0xc,%esp
  80161a:	50                   	push   %eax
  80161b:	6a 05                	push   $0x5
  80161d:	68 2f 38 80 00       	push   $0x80382f
  801622:	6a 23                	push   $0x23
  801624:	68 4c 38 80 00       	push   $0x80384c
  801629:	e8 2f f4 ff ff       	call   800a5d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80162e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801631:	5b                   	pop    %ebx
  801632:	5e                   	pop    %esi
  801633:	5f                   	pop    %edi
  801634:	5d                   	pop    %ebp
  801635:	c3                   	ret    

00801636 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	57                   	push   %edi
  80163a:	56                   	push   %esi
  80163b:	53                   	push   %ebx
  80163c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80163f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801644:	b8 06 00 00 00       	mov    $0x6,%eax
  801649:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80164c:	8b 55 08             	mov    0x8(%ebp),%edx
  80164f:	89 df                	mov    %ebx,%edi
  801651:	89 de                	mov    %ebx,%esi
  801653:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801655:	85 c0                	test   %eax,%eax
  801657:	7e 17                	jle    801670 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801659:	83 ec 0c             	sub    $0xc,%esp
  80165c:	50                   	push   %eax
  80165d:	6a 06                	push   $0x6
  80165f:	68 2f 38 80 00       	push   $0x80382f
  801664:	6a 23                	push   $0x23
  801666:	68 4c 38 80 00       	push   $0x80384c
  80166b:	e8 ed f3 ff ff       	call   800a5d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801670:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801673:	5b                   	pop    %ebx
  801674:	5e                   	pop    %esi
  801675:	5f                   	pop    %edi
  801676:	5d                   	pop    %ebp
  801677:	c3                   	ret    

00801678 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	57                   	push   %edi
  80167c:	56                   	push   %esi
  80167d:	53                   	push   %ebx
  80167e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801681:	bb 00 00 00 00       	mov    $0x0,%ebx
  801686:	b8 08 00 00 00       	mov    $0x8,%eax
  80168b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80168e:	8b 55 08             	mov    0x8(%ebp),%edx
  801691:	89 df                	mov    %ebx,%edi
  801693:	89 de                	mov    %ebx,%esi
  801695:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801697:	85 c0                	test   %eax,%eax
  801699:	7e 17                	jle    8016b2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80169b:	83 ec 0c             	sub    $0xc,%esp
  80169e:	50                   	push   %eax
  80169f:	6a 08                	push   $0x8
  8016a1:	68 2f 38 80 00       	push   $0x80382f
  8016a6:	6a 23                	push   $0x23
  8016a8:	68 4c 38 80 00       	push   $0x80384c
  8016ad:	e8 ab f3 ff ff       	call   800a5d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8016b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b5:	5b                   	pop    %ebx
  8016b6:	5e                   	pop    %esi
  8016b7:	5f                   	pop    %edi
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    

008016ba <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	57                   	push   %edi
  8016be:	56                   	push   %esi
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016c8:	b8 09 00 00 00       	mov    $0x9,%eax
  8016cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8016d3:	89 df                	mov    %ebx,%edi
  8016d5:	89 de                	mov    %ebx,%esi
  8016d7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	7e 17                	jle    8016f4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016dd:	83 ec 0c             	sub    $0xc,%esp
  8016e0:	50                   	push   %eax
  8016e1:	6a 09                	push   $0x9
  8016e3:	68 2f 38 80 00       	push   $0x80382f
  8016e8:	6a 23                	push   $0x23
  8016ea:	68 4c 38 80 00       	push   $0x80384c
  8016ef:	e8 69 f3 ff ff       	call   800a5d <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f7:	5b                   	pop    %ebx
  8016f8:	5e                   	pop    %esi
  8016f9:	5f                   	pop    %edi
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	57                   	push   %edi
  801700:	56                   	push   %esi
  801701:	53                   	push   %ebx
  801702:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801705:	bb 00 00 00 00       	mov    $0x0,%ebx
  80170a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80170f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801712:	8b 55 08             	mov    0x8(%ebp),%edx
  801715:	89 df                	mov    %ebx,%edi
  801717:	89 de                	mov    %ebx,%esi
  801719:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80171b:	85 c0                	test   %eax,%eax
  80171d:	7e 17                	jle    801736 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80171f:	83 ec 0c             	sub    $0xc,%esp
  801722:	50                   	push   %eax
  801723:	6a 0a                	push   $0xa
  801725:	68 2f 38 80 00       	push   $0x80382f
  80172a:	6a 23                	push   $0x23
  80172c:	68 4c 38 80 00       	push   $0x80384c
  801731:	e8 27 f3 ff ff       	call   800a5d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801736:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801739:	5b                   	pop    %ebx
  80173a:	5e                   	pop    %esi
  80173b:	5f                   	pop    %edi
  80173c:	5d                   	pop    %ebp
  80173d:	c3                   	ret    

0080173e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	57                   	push   %edi
  801742:	56                   	push   %esi
  801743:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801744:	be 00 00 00 00       	mov    $0x0,%esi
  801749:	b8 0c 00 00 00       	mov    $0xc,%eax
  80174e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801751:	8b 55 08             	mov    0x8(%ebp),%edx
  801754:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801757:	8b 7d 14             	mov    0x14(%ebp),%edi
  80175a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80175c:	5b                   	pop    %ebx
  80175d:	5e                   	pop    %esi
  80175e:	5f                   	pop    %edi
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    

00801761 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	57                   	push   %edi
  801765:	56                   	push   %esi
  801766:	53                   	push   %ebx
  801767:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80176a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80176f:	b8 0d 00 00 00       	mov    $0xd,%eax
  801774:	8b 55 08             	mov    0x8(%ebp),%edx
  801777:	89 cb                	mov    %ecx,%ebx
  801779:	89 cf                	mov    %ecx,%edi
  80177b:	89 ce                	mov    %ecx,%esi
  80177d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80177f:	85 c0                	test   %eax,%eax
  801781:	7e 17                	jle    80179a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801783:	83 ec 0c             	sub    $0xc,%esp
  801786:	50                   	push   %eax
  801787:	6a 0d                	push   $0xd
  801789:	68 2f 38 80 00       	push   $0x80382f
  80178e:	6a 23                	push   $0x23
  801790:	68 4c 38 80 00       	push   $0x80384c
  801795:	e8 c3 f2 ff ff       	call   800a5d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80179a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80179d:	5b                   	pop    %ebx
  80179e:	5e                   	pop    %esi
  80179f:	5f                   	pop    %edi
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    

008017a2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	53                   	push   %ebx
  8017a6:	83 ec 04             	sub    $0x4,%esp
  8017a9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8017ac:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8017ae:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8017b2:	74 11                	je     8017c5 <pgfault+0x23>
  8017b4:	89 d8                	mov    %ebx,%eax
  8017b6:	c1 e8 0c             	shr    $0xc,%eax
  8017b9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017c0:	f6 c4 08             	test   $0x8,%ah
  8017c3:	75 14                	jne    8017d9 <pgfault+0x37>
		panic("faulting access");
  8017c5:	83 ec 04             	sub    $0x4,%esp
  8017c8:	68 5a 38 80 00       	push   $0x80385a
  8017cd:	6a 1d                	push   $0x1d
  8017cf:	68 6a 38 80 00       	push   $0x80386a
  8017d4:	e8 84 f2 ff ff       	call   800a5d <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8017d9:	83 ec 04             	sub    $0x4,%esp
  8017dc:	6a 07                	push   $0x7
  8017de:	68 00 f0 7f 00       	push   $0x7ff000
  8017e3:	6a 00                	push   $0x0
  8017e5:	e8 c7 fd ff ff       	call   8015b1 <sys_page_alloc>
	if (r < 0) {
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	79 12                	jns    801803 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  8017f1:	50                   	push   %eax
  8017f2:	68 75 38 80 00       	push   $0x803875
  8017f7:	6a 2b                	push   $0x2b
  8017f9:	68 6a 38 80 00       	push   $0x80386a
  8017fe:	e8 5a f2 ff ff       	call   800a5d <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  801803:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  801809:	83 ec 04             	sub    $0x4,%esp
  80180c:	68 00 10 00 00       	push   $0x1000
  801811:	53                   	push   %ebx
  801812:	68 00 f0 7f 00       	push   $0x7ff000
  801817:	e8 8c fb ff ff       	call   8013a8 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  80181c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801823:	53                   	push   %ebx
  801824:	6a 00                	push   $0x0
  801826:	68 00 f0 7f 00       	push   $0x7ff000
  80182b:	6a 00                	push   $0x0
  80182d:	e8 c2 fd ff ff       	call   8015f4 <sys_page_map>
	if (r < 0) {
  801832:	83 c4 20             	add    $0x20,%esp
  801835:	85 c0                	test   %eax,%eax
  801837:	79 12                	jns    80184b <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  801839:	50                   	push   %eax
  80183a:	68 75 38 80 00       	push   $0x803875
  80183f:	6a 32                	push   $0x32
  801841:	68 6a 38 80 00       	push   $0x80386a
  801846:	e8 12 f2 ff ff       	call   800a5d <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  80184b:	83 ec 08             	sub    $0x8,%esp
  80184e:	68 00 f0 7f 00       	push   $0x7ff000
  801853:	6a 00                	push   $0x0
  801855:	e8 dc fd ff ff       	call   801636 <sys_page_unmap>
	if (r < 0) {
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	85 c0                	test   %eax,%eax
  80185f:	79 12                	jns    801873 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  801861:	50                   	push   %eax
  801862:	68 75 38 80 00       	push   $0x803875
  801867:	6a 36                	push   $0x36
  801869:	68 6a 38 80 00       	push   $0x80386a
  80186e:	e8 ea f1 ff ff       	call   800a5d <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  801873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801876:	c9                   	leave  
  801877:	c3                   	ret    

00801878 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	57                   	push   %edi
  80187c:	56                   	push   %esi
  80187d:	53                   	push   %ebx
  80187e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  801881:	68 a2 17 80 00       	push   $0x8017a2
  801886:	e8 d0 15 00 00       	call   802e5b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80188b:	b8 07 00 00 00       	mov    $0x7,%eax
  801890:	cd 30                	int    $0x30
  801892:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	85 c0                	test   %eax,%eax
  80189a:	79 17                	jns    8018b3 <fork+0x3b>
		panic("fork fault %e");
  80189c:	83 ec 04             	sub    $0x4,%esp
  80189f:	68 8e 38 80 00       	push   $0x80388e
  8018a4:	68 83 00 00 00       	push   $0x83
  8018a9:	68 6a 38 80 00       	push   $0x80386a
  8018ae:	e8 aa f1 ff ff       	call   800a5d <_panic>
  8018b3:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8018b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8018b9:	75 21                	jne    8018dc <fork+0x64>
		thisenv = &envs[ENVX(sys_getenvid())];
  8018bb:	e8 b3 fc ff ff       	call   801573 <sys_getenvid>
  8018c0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018c5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8018c8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018cd:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  8018d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d7:	e9 61 01 00 00       	jmp    801a3d <fork+0x1c5>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8018dc:	83 ec 04             	sub    $0x4,%esp
  8018df:	6a 07                	push   $0x7
  8018e1:	68 00 f0 bf ee       	push   $0xeebff000
  8018e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018e9:	e8 c3 fc ff ff       	call   8015b1 <sys_page_alloc>
  8018ee:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8018f1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8018f6:	89 d8                	mov    %ebx,%eax
  8018f8:	c1 e8 16             	shr    $0x16,%eax
  8018fb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801902:	a8 01                	test   $0x1,%al
  801904:	0f 84 fc 00 00 00    	je     801a06 <fork+0x18e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80190a:	89 d8                	mov    %ebx,%eax
  80190c:	c1 e8 0c             	shr    $0xc,%eax
  80190f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801916:	f6 c2 01             	test   $0x1,%dl
  801919:	0f 84 e7 00 00 00    	je     801a06 <fork+0x18e>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80191f:	89 c6                	mov    %eax,%esi
  801921:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801924:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80192b:	f6 c6 04             	test   $0x4,%dh
  80192e:	74 39                	je     801969 <fork+0xf1>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801930:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801937:	83 ec 0c             	sub    $0xc,%esp
  80193a:	25 07 0e 00 00       	and    $0xe07,%eax
  80193f:	50                   	push   %eax
  801940:	56                   	push   %esi
  801941:	57                   	push   %edi
  801942:	56                   	push   %esi
  801943:	6a 00                	push   $0x0
  801945:	e8 aa fc ff ff       	call   8015f4 <sys_page_map>
		if (r < 0) {
  80194a:	83 c4 20             	add    $0x20,%esp
  80194d:	85 c0                	test   %eax,%eax
  80194f:	0f 89 b1 00 00 00    	jns    801a06 <fork+0x18e>
		    	panic("sys page map fault %e");
  801955:	83 ec 04             	sub    $0x4,%esp
  801958:	68 9c 38 80 00       	push   $0x80389c
  80195d:	6a 53                	push   $0x53
  80195f:	68 6a 38 80 00       	push   $0x80386a
  801964:	e8 f4 f0 ff ff       	call   800a5d <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801969:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801970:	f6 c2 02             	test   $0x2,%dl
  801973:	75 0c                	jne    801981 <fork+0x109>
  801975:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80197c:	f6 c4 08             	test   $0x8,%ah
  80197f:	74 5b                	je     8019dc <fork+0x164>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801981:	83 ec 0c             	sub    $0xc,%esp
  801984:	68 05 08 00 00       	push   $0x805
  801989:	56                   	push   %esi
  80198a:	57                   	push   %edi
  80198b:	56                   	push   %esi
  80198c:	6a 00                	push   $0x0
  80198e:	e8 61 fc ff ff       	call   8015f4 <sys_page_map>
		if (r < 0) {
  801993:	83 c4 20             	add    $0x20,%esp
  801996:	85 c0                	test   %eax,%eax
  801998:	79 14                	jns    8019ae <fork+0x136>
		    	panic("sys page map fault %e");
  80199a:	83 ec 04             	sub    $0x4,%esp
  80199d:	68 9c 38 80 00       	push   $0x80389c
  8019a2:	6a 5a                	push   $0x5a
  8019a4:	68 6a 38 80 00       	push   $0x80386a
  8019a9:	e8 af f0 ff ff       	call   800a5d <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8019ae:	83 ec 0c             	sub    $0xc,%esp
  8019b1:	68 05 08 00 00       	push   $0x805
  8019b6:	56                   	push   %esi
  8019b7:	6a 00                	push   $0x0
  8019b9:	56                   	push   %esi
  8019ba:	6a 00                	push   $0x0
  8019bc:	e8 33 fc ff ff       	call   8015f4 <sys_page_map>
		if (r < 0) {
  8019c1:	83 c4 20             	add    $0x20,%esp
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	79 3e                	jns    801a06 <fork+0x18e>
		    	panic("sys page map fault %e");
  8019c8:	83 ec 04             	sub    $0x4,%esp
  8019cb:	68 9c 38 80 00       	push   $0x80389c
  8019d0:	6a 5e                	push   $0x5e
  8019d2:	68 6a 38 80 00       	push   $0x80386a
  8019d7:	e8 81 f0 ff ff       	call   800a5d <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8019dc:	83 ec 0c             	sub    $0xc,%esp
  8019df:	6a 05                	push   $0x5
  8019e1:	56                   	push   %esi
  8019e2:	57                   	push   %edi
  8019e3:	56                   	push   %esi
  8019e4:	6a 00                	push   $0x0
  8019e6:	e8 09 fc ff ff       	call   8015f4 <sys_page_map>
		if (r < 0) {
  8019eb:	83 c4 20             	add    $0x20,%esp
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	79 14                	jns    801a06 <fork+0x18e>
		    	panic("sys page map fault %e");
  8019f2:	83 ec 04             	sub    $0x4,%esp
  8019f5:	68 9c 38 80 00       	push   $0x80389c
  8019fa:	6a 63                	push   $0x63
  8019fc:	68 6a 38 80 00       	push   $0x80386a
  801a01:	e8 57 f0 ff ff       	call   800a5d <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801a06:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a0c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801a12:	0f 85 de fe ff ff    	jne    8018f6 <fork+0x7e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801a18:	a1 24 54 80 00       	mov    0x805424,%eax
  801a1d:	8b 40 64             	mov    0x64(%eax),%eax
  801a20:	83 ec 08             	sub    $0x8,%esp
  801a23:	50                   	push   %eax
  801a24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a27:	57                   	push   %edi
  801a28:	e8 cf fc ff ff       	call   8016fc <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801a2d:	83 c4 08             	add    $0x8,%esp
  801a30:	6a 02                	push   $0x2
  801a32:	57                   	push   %edi
  801a33:	e8 40 fc ff ff       	call   801678 <sys_env_set_status>
	
	return envid;
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801a3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a40:	5b                   	pop    %ebx
  801a41:	5e                   	pop    %esi
  801a42:	5f                   	pop    %edi
  801a43:	5d                   	pop    %ebp
  801a44:	c3                   	ret    

00801a45 <sfork>:

// Challenge!
int
sfork(void)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801a4b:	68 b2 38 80 00       	push   $0x8038b2
  801a50:	68 a1 00 00 00       	push   $0xa1
  801a55:	68 6a 38 80 00       	push   $0x80386a
  801a5a:	e8 fe ef ff ff       	call   800a5d <_panic>

00801a5f <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	8b 55 08             	mov    0x8(%ebp),%edx
  801a65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a68:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801a6b:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801a6d:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801a70:	83 3a 01             	cmpl   $0x1,(%edx)
  801a73:	7e 09                	jle    801a7e <argstart+0x1f>
  801a75:	ba 01 33 80 00       	mov    $0x803301,%edx
  801a7a:	85 c9                	test   %ecx,%ecx
  801a7c:	75 05                	jne    801a83 <argstart+0x24>
  801a7e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a83:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801a86:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801a8d:	5d                   	pop    %ebp
  801a8e:	c3                   	ret    

00801a8f <argnext>:

int
argnext(struct Argstate *args)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	53                   	push   %ebx
  801a93:	83 ec 04             	sub    $0x4,%esp
  801a96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801a99:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801aa0:	8b 43 08             	mov    0x8(%ebx),%eax
  801aa3:	85 c0                	test   %eax,%eax
  801aa5:	74 6f                	je     801b16 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801aa7:	80 38 00             	cmpb   $0x0,(%eax)
  801aaa:	75 4e                	jne    801afa <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801aac:	8b 0b                	mov    (%ebx),%ecx
  801aae:	83 39 01             	cmpl   $0x1,(%ecx)
  801ab1:	74 55                	je     801b08 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801ab3:	8b 53 04             	mov    0x4(%ebx),%edx
  801ab6:	8b 42 04             	mov    0x4(%edx),%eax
  801ab9:	80 38 2d             	cmpb   $0x2d,(%eax)
  801abc:	75 4a                	jne    801b08 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801abe:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801ac2:	74 44                	je     801b08 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801ac4:	83 c0 01             	add    $0x1,%eax
  801ac7:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801aca:	83 ec 04             	sub    $0x4,%esp
  801acd:	8b 01                	mov    (%ecx),%eax
  801acf:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801ad6:	50                   	push   %eax
  801ad7:	8d 42 08             	lea    0x8(%edx),%eax
  801ada:	50                   	push   %eax
  801adb:	83 c2 04             	add    $0x4,%edx
  801ade:	52                   	push   %edx
  801adf:	e8 5c f8 ff ff       	call   801340 <memmove>
		(*args->argc)--;
  801ae4:	8b 03                	mov    (%ebx),%eax
  801ae6:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801ae9:	8b 43 08             	mov    0x8(%ebx),%eax
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	80 38 2d             	cmpb   $0x2d,(%eax)
  801af2:	75 06                	jne    801afa <argnext+0x6b>
  801af4:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801af8:	74 0e                	je     801b08 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801afa:	8b 53 08             	mov    0x8(%ebx),%edx
  801afd:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b00:	83 c2 01             	add    $0x1,%edx
  801b03:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b06:	eb 13                	jmp    801b1b <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b08:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b14:	eb 05                	jmp    801b1b <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	53                   	push   %ebx
  801b24:	83 ec 04             	sub    $0x4,%esp
  801b27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b2a:	8b 43 08             	mov    0x8(%ebx),%eax
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	74 58                	je     801b89 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801b31:	80 38 00             	cmpb   $0x0,(%eax)
  801b34:	74 0c                	je     801b42 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801b36:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b39:	c7 43 08 01 33 80 00 	movl   $0x803301,0x8(%ebx)
  801b40:	eb 42                	jmp    801b84 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801b42:	8b 13                	mov    (%ebx),%edx
  801b44:	83 3a 01             	cmpl   $0x1,(%edx)
  801b47:	7e 2d                	jle    801b76 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801b49:	8b 43 04             	mov    0x4(%ebx),%eax
  801b4c:	8b 48 04             	mov    0x4(%eax),%ecx
  801b4f:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b52:	83 ec 04             	sub    $0x4,%esp
  801b55:	8b 12                	mov    (%edx),%edx
  801b57:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801b5e:	52                   	push   %edx
  801b5f:	8d 50 08             	lea    0x8(%eax),%edx
  801b62:	52                   	push   %edx
  801b63:	83 c0 04             	add    $0x4,%eax
  801b66:	50                   	push   %eax
  801b67:	e8 d4 f7 ff ff       	call   801340 <memmove>
		(*args->argc)--;
  801b6c:	8b 03                	mov    (%ebx),%eax
  801b6e:	83 28 01             	subl   $0x1,(%eax)
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	eb 0e                	jmp    801b84 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801b76:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801b7d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801b84:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b87:	eb 05                	jmp    801b8e <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801b8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	83 ec 08             	sub    $0x8,%esp
  801b99:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801b9c:	8b 51 0c             	mov    0xc(%ecx),%edx
  801b9f:	89 d0                	mov    %edx,%eax
  801ba1:	85 d2                	test   %edx,%edx
  801ba3:	75 0c                	jne    801bb1 <argvalue+0x1e>
  801ba5:	83 ec 0c             	sub    $0xc,%esp
  801ba8:	51                   	push   %ecx
  801ba9:	e8 72 ff ff ff       	call   801b20 <argnextvalue>
  801bae:	83 c4 10             	add    $0x10,%esp
}
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    

00801bb3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb9:	05 00 00 00 30       	add    $0x30000000,%eax
  801bbe:	c1 e8 0c             	shr    $0xc,%eax
}
  801bc1:	5d                   	pop    %ebp
  801bc2:	c3                   	ret    

00801bc3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc9:	05 00 00 00 30       	add    $0x30000000,%eax
  801bce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801bd3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801bd8:	5d                   	pop    %ebp
  801bd9:	c3                   	ret    

00801bda <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801be5:	89 c2                	mov    %eax,%edx
  801be7:	c1 ea 16             	shr    $0x16,%edx
  801bea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801bf1:	f6 c2 01             	test   $0x1,%dl
  801bf4:	74 11                	je     801c07 <fd_alloc+0x2d>
  801bf6:	89 c2                	mov    %eax,%edx
  801bf8:	c1 ea 0c             	shr    $0xc,%edx
  801bfb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c02:	f6 c2 01             	test   $0x1,%dl
  801c05:	75 09                	jne    801c10 <fd_alloc+0x36>
			*fd_store = fd;
  801c07:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c09:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0e:	eb 17                	jmp    801c27 <fd_alloc+0x4d>
  801c10:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c15:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c1a:	75 c9                	jne    801be5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c1c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801c22:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c2f:	83 f8 1f             	cmp    $0x1f,%eax
  801c32:	77 36                	ja     801c6a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c34:	c1 e0 0c             	shl    $0xc,%eax
  801c37:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c3c:	89 c2                	mov    %eax,%edx
  801c3e:	c1 ea 16             	shr    $0x16,%edx
  801c41:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c48:	f6 c2 01             	test   $0x1,%dl
  801c4b:	74 24                	je     801c71 <fd_lookup+0x48>
  801c4d:	89 c2                	mov    %eax,%edx
  801c4f:	c1 ea 0c             	shr    $0xc,%edx
  801c52:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c59:	f6 c2 01             	test   $0x1,%dl
  801c5c:	74 1a                	je     801c78 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c61:	89 02                	mov    %eax,(%edx)
	return 0;
  801c63:	b8 00 00 00 00       	mov    $0x0,%eax
  801c68:	eb 13                	jmp    801c7d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c6f:	eb 0c                	jmp    801c7d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c76:	eb 05                	jmp    801c7d <fd_lookup+0x54>
  801c78:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801c7d:	5d                   	pop    %ebp
  801c7e:	c3                   	ret    

00801c7f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	83 ec 08             	sub    $0x8,%esp
  801c85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c88:	ba 44 39 80 00       	mov    $0x803944,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801c8d:	eb 13                	jmp    801ca2 <dev_lookup+0x23>
  801c8f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801c92:	39 08                	cmp    %ecx,(%eax)
  801c94:	75 0c                	jne    801ca2 <dev_lookup+0x23>
			*dev = devtab[i];
  801c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c99:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca0:	eb 2e                	jmp    801cd0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ca2:	8b 02                	mov    (%edx),%eax
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	75 e7                	jne    801c8f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801ca8:	a1 24 54 80 00       	mov    0x805424,%eax
  801cad:	8b 40 48             	mov    0x48(%eax),%eax
  801cb0:	83 ec 04             	sub    $0x4,%esp
  801cb3:	51                   	push   %ecx
  801cb4:	50                   	push   %eax
  801cb5:	68 c8 38 80 00       	push   $0x8038c8
  801cba:	e8 77 ee ff ff       	call   800b36 <cprintf>
	*dev = 0;
  801cbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801cc8:	83 c4 10             	add    $0x10,%esp
  801ccb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801cd0:	c9                   	leave  
  801cd1:	c3                   	ret    

00801cd2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	56                   	push   %esi
  801cd6:	53                   	push   %ebx
  801cd7:	83 ec 10             	sub    $0x10,%esp
  801cda:	8b 75 08             	mov    0x8(%ebp),%esi
  801cdd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801ce0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce3:	50                   	push   %eax
  801ce4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801cea:	c1 e8 0c             	shr    $0xc,%eax
  801ced:	50                   	push   %eax
  801cee:	e8 36 ff ff ff       	call   801c29 <fd_lookup>
  801cf3:	83 c4 08             	add    $0x8,%esp
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	78 05                	js     801cff <fd_close+0x2d>
	    || fd != fd2)
  801cfa:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801cfd:	74 0c                	je     801d0b <fd_close+0x39>
		return (must_exist ? r : 0);
  801cff:	84 db                	test   %bl,%bl
  801d01:	ba 00 00 00 00       	mov    $0x0,%edx
  801d06:	0f 44 c2             	cmove  %edx,%eax
  801d09:	eb 41                	jmp    801d4c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d0b:	83 ec 08             	sub    $0x8,%esp
  801d0e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d11:	50                   	push   %eax
  801d12:	ff 36                	pushl  (%esi)
  801d14:	e8 66 ff ff ff       	call   801c7f <dev_lookup>
  801d19:	89 c3                	mov    %eax,%ebx
  801d1b:	83 c4 10             	add    $0x10,%esp
  801d1e:	85 c0                	test   %eax,%eax
  801d20:	78 1a                	js     801d3c <fd_close+0x6a>
		if (dev->dev_close)
  801d22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d25:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801d28:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	74 0b                	je     801d3c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801d31:	83 ec 0c             	sub    $0xc,%esp
  801d34:	56                   	push   %esi
  801d35:	ff d0                	call   *%eax
  801d37:	89 c3                	mov    %eax,%ebx
  801d39:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d3c:	83 ec 08             	sub    $0x8,%esp
  801d3f:	56                   	push   %esi
  801d40:	6a 00                	push   $0x0
  801d42:	e8 ef f8 ff ff       	call   801636 <sys_page_unmap>
	return r;
  801d47:	83 c4 10             	add    $0x10,%esp
  801d4a:	89 d8                	mov    %ebx,%eax
}
  801d4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4f:	5b                   	pop    %ebx
  801d50:	5e                   	pop    %esi
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    

00801d53 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5c:	50                   	push   %eax
  801d5d:	ff 75 08             	pushl  0x8(%ebp)
  801d60:	e8 c4 fe ff ff       	call   801c29 <fd_lookup>
  801d65:	83 c4 08             	add    $0x8,%esp
  801d68:	85 c0                	test   %eax,%eax
  801d6a:	78 10                	js     801d7c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801d6c:	83 ec 08             	sub    $0x8,%esp
  801d6f:	6a 01                	push   $0x1
  801d71:	ff 75 f4             	pushl  -0xc(%ebp)
  801d74:	e8 59 ff ff ff       	call   801cd2 <fd_close>
  801d79:	83 c4 10             	add    $0x10,%esp
}
  801d7c:	c9                   	leave  
  801d7d:	c3                   	ret    

00801d7e <close_all>:

void
close_all(void)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	53                   	push   %ebx
  801d82:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801d85:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801d8a:	83 ec 0c             	sub    $0xc,%esp
  801d8d:	53                   	push   %ebx
  801d8e:	e8 c0 ff ff ff       	call   801d53 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801d93:	83 c3 01             	add    $0x1,%ebx
  801d96:	83 c4 10             	add    $0x10,%esp
  801d99:	83 fb 20             	cmp    $0x20,%ebx
  801d9c:	75 ec                	jne    801d8a <close_all+0xc>
		close(i);
}
  801d9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da1:	c9                   	leave  
  801da2:	c3                   	ret    

00801da3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	57                   	push   %edi
  801da7:	56                   	push   %esi
  801da8:	53                   	push   %ebx
  801da9:	83 ec 2c             	sub    $0x2c,%esp
  801dac:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801daf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801db2:	50                   	push   %eax
  801db3:	ff 75 08             	pushl  0x8(%ebp)
  801db6:	e8 6e fe ff ff       	call   801c29 <fd_lookup>
  801dbb:	83 c4 08             	add    $0x8,%esp
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	0f 88 c1 00 00 00    	js     801e87 <dup+0xe4>
		return r;
	close(newfdnum);
  801dc6:	83 ec 0c             	sub    $0xc,%esp
  801dc9:	56                   	push   %esi
  801dca:	e8 84 ff ff ff       	call   801d53 <close>

	newfd = INDEX2FD(newfdnum);
  801dcf:	89 f3                	mov    %esi,%ebx
  801dd1:	c1 e3 0c             	shl    $0xc,%ebx
  801dd4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801dda:	83 c4 04             	add    $0x4,%esp
  801ddd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801de0:	e8 de fd ff ff       	call   801bc3 <fd2data>
  801de5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801de7:	89 1c 24             	mov    %ebx,(%esp)
  801dea:	e8 d4 fd ff ff       	call   801bc3 <fd2data>
  801def:	83 c4 10             	add    $0x10,%esp
  801df2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801df5:	89 f8                	mov    %edi,%eax
  801df7:	c1 e8 16             	shr    $0x16,%eax
  801dfa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e01:	a8 01                	test   $0x1,%al
  801e03:	74 37                	je     801e3c <dup+0x99>
  801e05:	89 f8                	mov    %edi,%eax
  801e07:	c1 e8 0c             	shr    $0xc,%eax
  801e0a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e11:	f6 c2 01             	test   $0x1,%dl
  801e14:	74 26                	je     801e3c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e16:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e1d:	83 ec 0c             	sub    $0xc,%esp
  801e20:	25 07 0e 00 00       	and    $0xe07,%eax
  801e25:	50                   	push   %eax
  801e26:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e29:	6a 00                	push   $0x0
  801e2b:	57                   	push   %edi
  801e2c:	6a 00                	push   $0x0
  801e2e:	e8 c1 f7 ff ff       	call   8015f4 <sys_page_map>
  801e33:	89 c7                	mov    %eax,%edi
  801e35:	83 c4 20             	add    $0x20,%esp
  801e38:	85 c0                	test   %eax,%eax
  801e3a:	78 2e                	js     801e6a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e3c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e3f:	89 d0                	mov    %edx,%eax
  801e41:	c1 e8 0c             	shr    $0xc,%eax
  801e44:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e4b:	83 ec 0c             	sub    $0xc,%esp
  801e4e:	25 07 0e 00 00       	and    $0xe07,%eax
  801e53:	50                   	push   %eax
  801e54:	53                   	push   %ebx
  801e55:	6a 00                	push   $0x0
  801e57:	52                   	push   %edx
  801e58:	6a 00                	push   $0x0
  801e5a:	e8 95 f7 ff ff       	call   8015f4 <sys_page_map>
  801e5f:	89 c7                	mov    %eax,%edi
  801e61:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801e64:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e66:	85 ff                	test   %edi,%edi
  801e68:	79 1d                	jns    801e87 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e6a:	83 ec 08             	sub    $0x8,%esp
  801e6d:	53                   	push   %ebx
  801e6e:	6a 00                	push   $0x0
  801e70:	e8 c1 f7 ff ff       	call   801636 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e75:	83 c4 08             	add    $0x8,%esp
  801e78:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e7b:	6a 00                	push   $0x0
  801e7d:	e8 b4 f7 ff ff       	call   801636 <sys_page_unmap>
	return r;
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	89 f8                	mov    %edi,%eax
}
  801e87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e8a:	5b                   	pop    %ebx
  801e8b:	5e                   	pop    %esi
  801e8c:	5f                   	pop    %edi
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    

00801e8f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	53                   	push   %ebx
  801e93:	83 ec 14             	sub    $0x14,%esp
  801e96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e99:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e9c:	50                   	push   %eax
  801e9d:	53                   	push   %ebx
  801e9e:	e8 86 fd ff ff       	call   801c29 <fd_lookup>
  801ea3:	83 c4 08             	add    $0x8,%esp
  801ea6:	89 c2                	mov    %eax,%edx
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	78 6d                	js     801f19 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801eac:	83 ec 08             	sub    $0x8,%esp
  801eaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb2:	50                   	push   %eax
  801eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eb6:	ff 30                	pushl  (%eax)
  801eb8:	e8 c2 fd ff ff       	call   801c7f <dev_lookup>
  801ebd:	83 c4 10             	add    $0x10,%esp
  801ec0:	85 c0                	test   %eax,%eax
  801ec2:	78 4c                	js     801f10 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801ec4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ec7:	8b 42 08             	mov    0x8(%edx),%eax
  801eca:	83 e0 03             	and    $0x3,%eax
  801ecd:	83 f8 01             	cmp    $0x1,%eax
  801ed0:	75 21                	jne    801ef3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801ed2:	a1 24 54 80 00       	mov    0x805424,%eax
  801ed7:	8b 40 48             	mov    0x48(%eax),%eax
  801eda:	83 ec 04             	sub    $0x4,%esp
  801edd:	53                   	push   %ebx
  801ede:	50                   	push   %eax
  801edf:	68 09 39 80 00       	push   $0x803909
  801ee4:	e8 4d ec ff ff       	call   800b36 <cprintf>
		return -E_INVAL;
  801ee9:	83 c4 10             	add    $0x10,%esp
  801eec:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801ef1:	eb 26                	jmp    801f19 <read+0x8a>
	}
	if (!dev->dev_read)
  801ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef6:	8b 40 08             	mov    0x8(%eax),%eax
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	74 17                	je     801f14 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801efd:	83 ec 04             	sub    $0x4,%esp
  801f00:	ff 75 10             	pushl  0x10(%ebp)
  801f03:	ff 75 0c             	pushl  0xc(%ebp)
  801f06:	52                   	push   %edx
  801f07:	ff d0                	call   *%eax
  801f09:	89 c2                	mov    %eax,%edx
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	eb 09                	jmp    801f19 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f10:	89 c2                	mov    %eax,%edx
  801f12:	eb 05                	jmp    801f19 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f14:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801f19:	89 d0                	mov    %edx,%eax
  801f1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f1e:	c9                   	leave  
  801f1f:	c3                   	ret    

00801f20 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	57                   	push   %edi
  801f24:	56                   	push   %esi
  801f25:	53                   	push   %ebx
  801f26:	83 ec 0c             	sub    $0xc,%esp
  801f29:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f2c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f34:	eb 21                	jmp    801f57 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f36:	83 ec 04             	sub    $0x4,%esp
  801f39:	89 f0                	mov    %esi,%eax
  801f3b:	29 d8                	sub    %ebx,%eax
  801f3d:	50                   	push   %eax
  801f3e:	89 d8                	mov    %ebx,%eax
  801f40:	03 45 0c             	add    0xc(%ebp),%eax
  801f43:	50                   	push   %eax
  801f44:	57                   	push   %edi
  801f45:	e8 45 ff ff ff       	call   801e8f <read>
		if (m < 0)
  801f4a:	83 c4 10             	add    $0x10,%esp
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	78 10                	js     801f61 <readn+0x41>
			return m;
		if (m == 0)
  801f51:	85 c0                	test   %eax,%eax
  801f53:	74 0a                	je     801f5f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f55:	01 c3                	add    %eax,%ebx
  801f57:	39 f3                	cmp    %esi,%ebx
  801f59:	72 db                	jb     801f36 <readn+0x16>
  801f5b:	89 d8                	mov    %ebx,%eax
  801f5d:	eb 02                	jmp    801f61 <readn+0x41>
  801f5f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801f61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f64:	5b                   	pop    %ebx
  801f65:	5e                   	pop    %esi
  801f66:	5f                   	pop    %edi
  801f67:	5d                   	pop    %ebp
  801f68:	c3                   	ret    

00801f69 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801f69:	55                   	push   %ebp
  801f6a:	89 e5                	mov    %esp,%ebp
  801f6c:	53                   	push   %ebx
  801f6d:	83 ec 14             	sub    $0x14,%esp
  801f70:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f73:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f76:	50                   	push   %eax
  801f77:	53                   	push   %ebx
  801f78:	e8 ac fc ff ff       	call   801c29 <fd_lookup>
  801f7d:	83 c4 08             	add    $0x8,%esp
  801f80:	89 c2                	mov    %eax,%edx
  801f82:	85 c0                	test   %eax,%eax
  801f84:	78 68                	js     801fee <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f86:	83 ec 08             	sub    $0x8,%esp
  801f89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8c:	50                   	push   %eax
  801f8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f90:	ff 30                	pushl  (%eax)
  801f92:	e8 e8 fc ff ff       	call   801c7f <dev_lookup>
  801f97:	83 c4 10             	add    $0x10,%esp
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	78 47                	js     801fe5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801fa5:	75 21                	jne    801fc8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801fa7:	a1 24 54 80 00       	mov    0x805424,%eax
  801fac:	8b 40 48             	mov    0x48(%eax),%eax
  801faf:	83 ec 04             	sub    $0x4,%esp
  801fb2:	53                   	push   %ebx
  801fb3:	50                   	push   %eax
  801fb4:	68 25 39 80 00       	push   $0x803925
  801fb9:	e8 78 eb ff ff       	call   800b36 <cprintf>
		return -E_INVAL;
  801fbe:	83 c4 10             	add    $0x10,%esp
  801fc1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801fc6:	eb 26                	jmp    801fee <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801fc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fcb:	8b 52 0c             	mov    0xc(%edx),%edx
  801fce:	85 d2                	test   %edx,%edx
  801fd0:	74 17                	je     801fe9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801fd2:	83 ec 04             	sub    $0x4,%esp
  801fd5:	ff 75 10             	pushl  0x10(%ebp)
  801fd8:	ff 75 0c             	pushl  0xc(%ebp)
  801fdb:	50                   	push   %eax
  801fdc:	ff d2                	call   *%edx
  801fde:	89 c2                	mov    %eax,%edx
  801fe0:	83 c4 10             	add    $0x10,%esp
  801fe3:	eb 09                	jmp    801fee <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fe5:	89 c2                	mov    %eax,%edx
  801fe7:	eb 05                	jmp    801fee <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801fe9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801fee:	89 d0                	mov    %edx,%eax
  801ff0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ff3:	c9                   	leave  
  801ff4:	c3                   	ret    

00801ff5 <seek>:

int
seek(int fdnum, off_t offset)
{
  801ff5:	55                   	push   %ebp
  801ff6:	89 e5                	mov    %esp,%ebp
  801ff8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ffb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801ffe:	50                   	push   %eax
  801fff:	ff 75 08             	pushl  0x8(%ebp)
  802002:	e8 22 fc ff ff       	call   801c29 <fd_lookup>
  802007:	83 c4 08             	add    $0x8,%esp
  80200a:	85 c0                	test   %eax,%eax
  80200c:	78 0e                	js     80201c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80200e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802011:	8b 55 0c             	mov    0xc(%ebp),%edx
  802014:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802017:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80201c:	c9                   	leave  
  80201d:	c3                   	ret    

0080201e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80201e:	55                   	push   %ebp
  80201f:	89 e5                	mov    %esp,%ebp
  802021:	53                   	push   %ebx
  802022:	83 ec 14             	sub    $0x14,%esp
  802025:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802028:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80202b:	50                   	push   %eax
  80202c:	53                   	push   %ebx
  80202d:	e8 f7 fb ff ff       	call   801c29 <fd_lookup>
  802032:	83 c4 08             	add    $0x8,%esp
  802035:	89 c2                	mov    %eax,%edx
  802037:	85 c0                	test   %eax,%eax
  802039:	78 65                	js     8020a0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80203b:	83 ec 08             	sub    $0x8,%esp
  80203e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802041:	50                   	push   %eax
  802042:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802045:	ff 30                	pushl  (%eax)
  802047:	e8 33 fc ff ff       	call   801c7f <dev_lookup>
  80204c:	83 c4 10             	add    $0x10,%esp
  80204f:	85 c0                	test   %eax,%eax
  802051:	78 44                	js     802097 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802053:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802056:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80205a:	75 21                	jne    80207d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80205c:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802061:	8b 40 48             	mov    0x48(%eax),%eax
  802064:	83 ec 04             	sub    $0x4,%esp
  802067:	53                   	push   %ebx
  802068:	50                   	push   %eax
  802069:	68 e8 38 80 00       	push   $0x8038e8
  80206e:	e8 c3 ea ff ff       	call   800b36 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802073:	83 c4 10             	add    $0x10,%esp
  802076:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80207b:	eb 23                	jmp    8020a0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80207d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802080:	8b 52 18             	mov    0x18(%edx),%edx
  802083:	85 d2                	test   %edx,%edx
  802085:	74 14                	je     80209b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802087:	83 ec 08             	sub    $0x8,%esp
  80208a:	ff 75 0c             	pushl  0xc(%ebp)
  80208d:	50                   	push   %eax
  80208e:	ff d2                	call   *%edx
  802090:	89 c2                	mov    %eax,%edx
  802092:	83 c4 10             	add    $0x10,%esp
  802095:	eb 09                	jmp    8020a0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802097:	89 c2                	mov    %eax,%edx
  802099:	eb 05                	jmp    8020a0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80209b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8020a0:	89 d0                	mov    %edx,%eax
  8020a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020a5:	c9                   	leave  
  8020a6:	c3                   	ret    

008020a7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8020a7:	55                   	push   %ebp
  8020a8:	89 e5                	mov    %esp,%ebp
  8020aa:	53                   	push   %ebx
  8020ab:	83 ec 14             	sub    $0x14,%esp
  8020ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020b4:	50                   	push   %eax
  8020b5:	ff 75 08             	pushl  0x8(%ebp)
  8020b8:	e8 6c fb ff ff       	call   801c29 <fd_lookup>
  8020bd:	83 c4 08             	add    $0x8,%esp
  8020c0:	89 c2                	mov    %eax,%edx
  8020c2:	85 c0                	test   %eax,%eax
  8020c4:	78 58                	js     80211e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020c6:	83 ec 08             	sub    $0x8,%esp
  8020c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020cc:	50                   	push   %eax
  8020cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020d0:	ff 30                	pushl  (%eax)
  8020d2:	e8 a8 fb ff ff       	call   801c7f <dev_lookup>
  8020d7:	83 c4 10             	add    $0x10,%esp
  8020da:	85 c0                	test   %eax,%eax
  8020dc:	78 37                	js     802115 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8020de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8020e5:	74 32                	je     802119 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8020e7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8020ea:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8020f1:	00 00 00 
	stat->st_isdir = 0;
  8020f4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020fb:	00 00 00 
	stat->st_dev = dev;
  8020fe:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802104:	83 ec 08             	sub    $0x8,%esp
  802107:	53                   	push   %ebx
  802108:	ff 75 f0             	pushl  -0x10(%ebp)
  80210b:	ff 50 14             	call   *0x14(%eax)
  80210e:	89 c2                	mov    %eax,%edx
  802110:	83 c4 10             	add    $0x10,%esp
  802113:	eb 09                	jmp    80211e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802115:	89 c2                	mov    %eax,%edx
  802117:	eb 05                	jmp    80211e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802119:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80211e:	89 d0                	mov    %edx,%eax
  802120:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802123:	c9                   	leave  
  802124:	c3                   	ret    

00802125 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802125:	55                   	push   %ebp
  802126:	89 e5                	mov    %esp,%ebp
  802128:	56                   	push   %esi
  802129:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80212a:	83 ec 08             	sub    $0x8,%esp
  80212d:	6a 00                	push   $0x0
  80212f:	ff 75 08             	pushl  0x8(%ebp)
  802132:	e8 e3 01 00 00       	call   80231a <open>
  802137:	89 c3                	mov    %eax,%ebx
  802139:	83 c4 10             	add    $0x10,%esp
  80213c:	85 c0                	test   %eax,%eax
  80213e:	78 1b                	js     80215b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802140:	83 ec 08             	sub    $0x8,%esp
  802143:	ff 75 0c             	pushl  0xc(%ebp)
  802146:	50                   	push   %eax
  802147:	e8 5b ff ff ff       	call   8020a7 <fstat>
  80214c:	89 c6                	mov    %eax,%esi
	close(fd);
  80214e:	89 1c 24             	mov    %ebx,(%esp)
  802151:	e8 fd fb ff ff       	call   801d53 <close>
	return r;
  802156:	83 c4 10             	add    $0x10,%esp
  802159:	89 f0                	mov    %esi,%eax
}
  80215b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80215e:	5b                   	pop    %ebx
  80215f:	5e                   	pop    %esi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    

00802162 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802162:	55                   	push   %ebp
  802163:	89 e5                	mov    %esp,%ebp
  802165:	56                   	push   %esi
  802166:	53                   	push   %ebx
  802167:	89 c6                	mov    %eax,%esi
  802169:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80216b:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802172:	75 12                	jne    802186 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802174:	83 ec 0c             	sub    $0xc,%esp
  802177:	6a 01                	push   $0x1
  802179:	e8 40 0e 00 00       	call   802fbe <ipc_find_env>
  80217e:	a3 20 54 80 00       	mov    %eax,0x805420
  802183:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802186:	6a 07                	push   $0x7
  802188:	68 00 60 80 00       	push   $0x806000
  80218d:	56                   	push   %esi
  80218e:	ff 35 20 54 80 00    	pushl  0x805420
  802194:	e8 c3 0d 00 00       	call   802f5c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802199:	83 c4 0c             	add    $0xc,%esp
  80219c:	6a 00                	push   $0x0
  80219e:	53                   	push   %ebx
  80219f:	6a 00                	push   $0x0
  8021a1:	e8 44 0d 00 00       	call   802eea <ipc_recv>
}
  8021a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021a9:	5b                   	pop    %ebx
  8021aa:	5e                   	pop    %esi
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    

008021ad <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8021ad:	55                   	push   %ebp
  8021ae:	89 e5                	mov    %esp,%ebp
  8021b0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8021b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8021b9:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8021be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021c1:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8021c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8021cb:	b8 02 00 00 00       	mov    $0x2,%eax
  8021d0:	e8 8d ff ff ff       	call   802162 <fsipc>
}
  8021d5:	c9                   	leave  
  8021d6:	c3                   	ret    

008021d7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8021d7:	55                   	push   %ebp
  8021d8:	89 e5                	mov    %esp,%ebp
  8021da:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8021dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8021e3:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8021e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8021ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8021f2:	e8 6b ff ff ff       	call   802162 <fsipc>
}
  8021f7:	c9                   	leave  
  8021f8:	c3                   	ret    

008021f9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8021f9:	55                   	push   %ebp
  8021fa:	89 e5                	mov    %esp,%ebp
  8021fc:	53                   	push   %ebx
  8021fd:	83 ec 04             	sub    $0x4,%esp
  802200:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802203:	8b 45 08             	mov    0x8(%ebp),%eax
  802206:	8b 40 0c             	mov    0xc(%eax),%eax
  802209:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80220e:	ba 00 00 00 00       	mov    $0x0,%edx
  802213:	b8 05 00 00 00       	mov    $0x5,%eax
  802218:	e8 45 ff ff ff       	call   802162 <fsipc>
  80221d:	85 c0                	test   %eax,%eax
  80221f:	78 2c                	js     80224d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802221:	83 ec 08             	sub    $0x8,%esp
  802224:	68 00 60 80 00       	push   $0x806000
  802229:	53                   	push   %ebx
  80222a:	e8 7f ef ff ff       	call   8011ae <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80222f:	a1 80 60 80 00       	mov    0x806080,%eax
  802234:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80223a:	a1 84 60 80 00       	mov    0x806084,%eax
  80223f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802245:	83 c4 10             	add    $0x10,%esp
  802248:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80224d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802250:	c9                   	leave  
  802251:	c3                   	ret    

00802252 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802252:	55                   	push   %ebp
  802253:	89 e5                	mov    %esp,%ebp
  802255:	83 ec 0c             	sub    $0xc,%esp
  802258:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80225b:	8b 55 08             	mov    0x8(%ebp),%edx
  80225e:	8b 52 0c             	mov    0xc(%edx),%edx
  802261:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  802267:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80226c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802271:	0f 47 c2             	cmova  %edx,%eax
  802274:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  802279:	50                   	push   %eax
  80227a:	ff 75 0c             	pushl  0xc(%ebp)
  80227d:	68 08 60 80 00       	push   $0x806008
  802282:	e8 b9 f0 ff ff       	call   801340 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  802287:	ba 00 00 00 00       	mov    $0x0,%edx
  80228c:	b8 04 00 00 00       	mov    $0x4,%eax
  802291:	e8 cc fe ff ff       	call   802162 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  802296:	c9                   	leave  
  802297:	c3                   	ret    

00802298 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802298:	55                   	push   %ebp
  802299:	89 e5                	mov    %esp,%ebp
  80229b:	56                   	push   %esi
  80229c:	53                   	push   %ebx
  80229d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8022a6:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8022ab:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8022b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8022b6:	b8 03 00 00 00       	mov    $0x3,%eax
  8022bb:	e8 a2 fe ff ff       	call   802162 <fsipc>
  8022c0:	89 c3                	mov    %eax,%ebx
  8022c2:	85 c0                	test   %eax,%eax
  8022c4:	78 4b                	js     802311 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8022c6:	39 c6                	cmp    %eax,%esi
  8022c8:	73 16                	jae    8022e0 <devfile_read+0x48>
  8022ca:	68 54 39 80 00       	push   $0x803954
  8022cf:	68 2f 34 80 00       	push   $0x80342f
  8022d4:	6a 7c                	push   $0x7c
  8022d6:	68 5b 39 80 00       	push   $0x80395b
  8022db:	e8 7d e7 ff ff       	call   800a5d <_panic>
	assert(r <= PGSIZE);
  8022e0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8022e5:	7e 16                	jle    8022fd <devfile_read+0x65>
  8022e7:	68 66 39 80 00       	push   $0x803966
  8022ec:	68 2f 34 80 00       	push   $0x80342f
  8022f1:	6a 7d                	push   $0x7d
  8022f3:	68 5b 39 80 00       	push   $0x80395b
  8022f8:	e8 60 e7 ff ff       	call   800a5d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8022fd:	83 ec 04             	sub    $0x4,%esp
  802300:	50                   	push   %eax
  802301:	68 00 60 80 00       	push   $0x806000
  802306:	ff 75 0c             	pushl  0xc(%ebp)
  802309:	e8 32 f0 ff ff       	call   801340 <memmove>
	return r;
  80230e:	83 c4 10             	add    $0x10,%esp
}
  802311:	89 d8                	mov    %ebx,%eax
  802313:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802316:	5b                   	pop    %ebx
  802317:	5e                   	pop    %esi
  802318:	5d                   	pop    %ebp
  802319:	c3                   	ret    

0080231a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80231a:	55                   	push   %ebp
  80231b:	89 e5                	mov    %esp,%ebp
  80231d:	53                   	push   %ebx
  80231e:	83 ec 20             	sub    $0x20,%esp
  802321:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802324:	53                   	push   %ebx
  802325:	e8 4b ee ff ff       	call   801175 <strlen>
  80232a:	83 c4 10             	add    $0x10,%esp
  80232d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802332:	7f 67                	jg     80239b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802334:	83 ec 0c             	sub    $0xc,%esp
  802337:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80233a:	50                   	push   %eax
  80233b:	e8 9a f8 ff ff       	call   801bda <fd_alloc>
  802340:	83 c4 10             	add    $0x10,%esp
		return r;
  802343:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802345:	85 c0                	test   %eax,%eax
  802347:	78 57                	js     8023a0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802349:	83 ec 08             	sub    $0x8,%esp
  80234c:	53                   	push   %ebx
  80234d:	68 00 60 80 00       	push   $0x806000
  802352:	e8 57 ee ff ff       	call   8011ae <strcpy>
	fsipcbuf.open.req_omode = mode;
  802357:	8b 45 0c             	mov    0xc(%ebp),%eax
  80235a:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80235f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802362:	b8 01 00 00 00       	mov    $0x1,%eax
  802367:	e8 f6 fd ff ff       	call   802162 <fsipc>
  80236c:	89 c3                	mov    %eax,%ebx
  80236e:	83 c4 10             	add    $0x10,%esp
  802371:	85 c0                	test   %eax,%eax
  802373:	79 14                	jns    802389 <open+0x6f>
		fd_close(fd, 0);
  802375:	83 ec 08             	sub    $0x8,%esp
  802378:	6a 00                	push   $0x0
  80237a:	ff 75 f4             	pushl  -0xc(%ebp)
  80237d:	e8 50 f9 ff ff       	call   801cd2 <fd_close>
		return r;
  802382:	83 c4 10             	add    $0x10,%esp
  802385:	89 da                	mov    %ebx,%edx
  802387:	eb 17                	jmp    8023a0 <open+0x86>
	}

	return fd2num(fd);
  802389:	83 ec 0c             	sub    $0xc,%esp
  80238c:	ff 75 f4             	pushl  -0xc(%ebp)
  80238f:	e8 1f f8 ff ff       	call   801bb3 <fd2num>
  802394:	89 c2                	mov    %eax,%edx
  802396:	83 c4 10             	add    $0x10,%esp
  802399:	eb 05                	jmp    8023a0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80239b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8023a0:	89 d0                	mov    %edx,%eax
  8023a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023a5:	c9                   	leave  
  8023a6:	c3                   	ret    

008023a7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8023a7:	55                   	push   %ebp
  8023a8:	89 e5                	mov    %esp,%ebp
  8023aa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8023ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8023b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8023b7:	e8 a6 fd ff ff       	call   802162 <fsipc>
}
  8023bc:	c9                   	leave  
  8023bd:	c3                   	ret    

008023be <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8023be:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8023c2:	7e 37                	jle    8023fb <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8023c4:	55                   	push   %ebp
  8023c5:	89 e5                	mov    %esp,%ebp
  8023c7:	53                   	push   %ebx
  8023c8:	83 ec 08             	sub    $0x8,%esp
  8023cb:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8023cd:	ff 70 04             	pushl  0x4(%eax)
  8023d0:	8d 40 10             	lea    0x10(%eax),%eax
  8023d3:	50                   	push   %eax
  8023d4:	ff 33                	pushl  (%ebx)
  8023d6:	e8 8e fb ff ff       	call   801f69 <write>
		if (result > 0)
  8023db:	83 c4 10             	add    $0x10,%esp
  8023de:	85 c0                	test   %eax,%eax
  8023e0:	7e 03                	jle    8023e5 <writebuf+0x27>
			b->result += result;
  8023e2:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8023e5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8023e8:	74 0d                	je     8023f7 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8023ea:	85 c0                	test   %eax,%eax
  8023ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8023f1:	0f 4f c2             	cmovg  %edx,%eax
  8023f4:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8023f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023fa:	c9                   	leave  
  8023fb:	f3 c3                	repz ret 

008023fd <putch>:

static void
putch(int ch, void *thunk)
{
  8023fd:	55                   	push   %ebp
  8023fe:	89 e5                	mov    %esp,%ebp
  802400:	53                   	push   %ebx
  802401:	83 ec 04             	sub    $0x4,%esp
  802404:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802407:	8b 53 04             	mov    0x4(%ebx),%edx
  80240a:	8d 42 01             	lea    0x1(%edx),%eax
  80240d:	89 43 04             	mov    %eax,0x4(%ebx)
  802410:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802413:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802417:	3d 00 01 00 00       	cmp    $0x100,%eax
  80241c:	75 0e                	jne    80242c <putch+0x2f>
		writebuf(b);
  80241e:	89 d8                	mov    %ebx,%eax
  802420:	e8 99 ff ff ff       	call   8023be <writebuf>
		b->idx = 0;
  802425:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80242c:	83 c4 04             	add    $0x4,%esp
  80242f:	5b                   	pop    %ebx
  802430:	5d                   	pop    %ebp
  802431:	c3                   	ret    

00802432 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802432:	55                   	push   %ebp
  802433:	89 e5                	mov    %esp,%ebp
  802435:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80243b:	8b 45 08             	mov    0x8(%ebp),%eax
  80243e:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802444:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80244b:	00 00 00 
	b.result = 0;
  80244e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802455:	00 00 00 
	b.error = 1;
  802458:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80245f:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802462:	ff 75 10             	pushl  0x10(%ebp)
  802465:	ff 75 0c             	pushl  0xc(%ebp)
  802468:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80246e:	50                   	push   %eax
  80246f:	68 fd 23 80 00       	push   $0x8023fd
  802474:	e8 f4 e7 ff ff       	call   800c6d <vprintfmt>
	if (b.idx > 0)
  802479:	83 c4 10             	add    $0x10,%esp
  80247c:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802483:	7e 0b                	jle    802490 <vfprintf+0x5e>
		writebuf(&b);
  802485:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80248b:	e8 2e ff ff ff       	call   8023be <writebuf>

	return (b.result ? b.result : b.error);
  802490:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802496:	85 c0                	test   %eax,%eax
  802498:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80249f:	c9                   	leave  
  8024a0:	c3                   	ret    

008024a1 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8024a1:	55                   	push   %ebp
  8024a2:	89 e5                	mov    %esp,%ebp
  8024a4:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024a7:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8024aa:	50                   	push   %eax
  8024ab:	ff 75 0c             	pushl  0xc(%ebp)
  8024ae:	ff 75 08             	pushl  0x8(%ebp)
  8024b1:	e8 7c ff ff ff       	call   802432 <vfprintf>
	va_end(ap);

	return cnt;
}
  8024b6:	c9                   	leave  
  8024b7:	c3                   	ret    

008024b8 <printf>:

int
printf(const char *fmt, ...)
{
  8024b8:	55                   	push   %ebp
  8024b9:	89 e5                	mov    %esp,%ebp
  8024bb:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8024c1:	50                   	push   %eax
  8024c2:	ff 75 08             	pushl  0x8(%ebp)
  8024c5:	6a 01                	push   $0x1
  8024c7:	e8 66 ff ff ff       	call   802432 <vfprintf>
	va_end(ap);

	return cnt;
}
  8024cc:	c9                   	leave  
  8024cd:	c3                   	ret    

008024ce <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8024ce:	55                   	push   %ebp
  8024cf:	89 e5                	mov    %esp,%ebp
  8024d1:	57                   	push   %edi
  8024d2:	56                   	push   %esi
  8024d3:	53                   	push   %ebx
  8024d4:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8024da:	6a 00                	push   $0x0
  8024dc:	ff 75 08             	pushl  0x8(%ebp)
  8024df:	e8 36 fe ff ff       	call   80231a <open>
  8024e4:	89 c7                	mov    %eax,%edi
  8024e6:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8024ec:	83 c4 10             	add    $0x10,%esp
  8024ef:	85 c0                	test   %eax,%eax
  8024f1:	0f 88 89 04 00 00    	js     802980 <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8024f7:	83 ec 04             	sub    $0x4,%esp
  8024fa:	68 00 02 00 00       	push   $0x200
  8024ff:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802505:	50                   	push   %eax
  802506:	57                   	push   %edi
  802507:	e8 14 fa ff ff       	call   801f20 <readn>
  80250c:	83 c4 10             	add    $0x10,%esp
  80250f:	3d 00 02 00 00       	cmp    $0x200,%eax
  802514:	75 0c                	jne    802522 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  802516:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80251d:	45 4c 46 
  802520:	74 33                	je     802555 <spawn+0x87>
		close(fd);
  802522:	83 ec 0c             	sub    $0xc,%esp
  802525:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80252b:	e8 23 f8 ff ff       	call   801d53 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802530:	83 c4 0c             	add    $0xc,%esp
  802533:	68 7f 45 4c 46       	push   $0x464c457f
  802538:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80253e:	68 72 39 80 00       	push   $0x803972
  802543:	e8 ee e5 ff ff       	call   800b36 <cprintf>
		return -E_NOT_EXEC;
  802548:	83 c4 10             	add    $0x10,%esp
  80254b:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  802550:	e9 de 04 00 00       	jmp    802a33 <spawn+0x565>
  802555:	b8 07 00 00 00       	mov    $0x7,%eax
  80255a:	cd 30                	int    $0x30
  80255c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802562:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802568:	85 c0                	test   %eax,%eax
  80256a:	0f 88 1b 04 00 00    	js     80298b <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802570:	89 c6                	mov    %eax,%esi
  802572:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802578:	6b f6 7c             	imul   $0x7c,%esi,%esi
  80257b:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802581:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802587:	b9 11 00 00 00       	mov    $0x11,%ecx
  80258c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80258e:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802594:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80259a:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80259f:	be 00 00 00 00       	mov    $0x0,%esi
  8025a4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025a7:	eb 13                	jmp    8025bc <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8025a9:	83 ec 0c             	sub    $0xc,%esp
  8025ac:	50                   	push   %eax
  8025ad:	e8 c3 eb ff ff       	call   801175 <strlen>
  8025b2:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025b6:	83 c3 01             	add    $0x1,%ebx
  8025b9:	83 c4 10             	add    $0x10,%esp
  8025bc:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8025c3:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8025c6:	85 c0                	test   %eax,%eax
  8025c8:	75 df                	jne    8025a9 <spawn+0xdb>
  8025ca:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8025d0:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8025d6:	bf 00 10 40 00       	mov    $0x401000,%edi
  8025db:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8025dd:	89 fa                	mov    %edi,%edx
  8025df:	83 e2 fc             	and    $0xfffffffc,%edx
  8025e2:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8025e9:	29 c2                	sub    %eax,%edx
  8025eb:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8025f1:	8d 42 f8             	lea    -0x8(%edx),%eax
  8025f4:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8025f9:	0f 86 a2 03 00 00    	jbe    8029a1 <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8025ff:	83 ec 04             	sub    $0x4,%esp
  802602:	6a 07                	push   $0x7
  802604:	68 00 00 40 00       	push   $0x400000
  802609:	6a 00                	push   $0x0
  80260b:	e8 a1 ef ff ff       	call   8015b1 <sys_page_alloc>
  802610:	83 c4 10             	add    $0x10,%esp
  802613:	85 c0                	test   %eax,%eax
  802615:	0f 88 90 03 00 00    	js     8029ab <spawn+0x4dd>
  80261b:	be 00 00 00 00       	mov    $0x0,%esi
  802620:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802626:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802629:	eb 30                	jmp    80265b <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80262b:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802631:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802637:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  80263a:	83 ec 08             	sub    $0x8,%esp
  80263d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802640:	57                   	push   %edi
  802641:	e8 68 eb ff ff       	call   8011ae <strcpy>
		string_store += strlen(argv[i]) + 1;
  802646:	83 c4 04             	add    $0x4,%esp
  802649:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80264c:	e8 24 eb ff ff       	call   801175 <strlen>
  802651:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802655:	83 c6 01             	add    $0x1,%esi
  802658:	83 c4 10             	add    $0x10,%esp
  80265b:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802661:	7f c8                	jg     80262b <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802663:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802669:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80266f:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802676:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80267c:	74 19                	je     802697 <spawn+0x1c9>
  80267e:	68 fc 39 80 00       	push   $0x8039fc
  802683:	68 2f 34 80 00       	push   $0x80342f
  802688:	68 f2 00 00 00       	push   $0xf2
  80268d:	68 8c 39 80 00       	push   $0x80398c
  802692:	e8 c6 e3 ff ff       	call   800a5d <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802697:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80269d:	89 f8                	mov    %edi,%eax
  80269f:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8026a4:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8026a7:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8026ad:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8026b0:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8026b6:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8026bc:	83 ec 0c             	sub    $0xc,%esp
  8026bf:	6a 07                	push   $0x7
  8026c1:	68 00 d0 bf ee       	push   $0xeebfd000
  8026c6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8026cc:	68 00 00 40 00       	push   $0x400000
  8026d1:	6a 00                	push   $0x0
  8026d3:	e8 1c ef ff ff       	call   8015f4 <sys_page_map>
  8026d8:	89 c3                	mov    %eax,%ebx
  8026da:	83 c4 20             	add    $0x20,%esp
  8026dd:	85 c0                	test   %eax,%eax
  8026df:	0f 88 3c 03 00 00    	js     802a21 <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8026e5:	83 ec 08             	sub    $0x8,%esp
  8026e8:	68 00 00 40 00       	push   $0x400000
  8026ed:	6a 00                	push   $0x0
  8026ef:	e8 42 ef ff ff       	call   801636 <sys_page_unmap>
  8026f4:	89 c3                	mov    %eax,%ebx
  8026f6:	83 c4 10             	add    $0x10,%esp
  8026f9:	85 c0                	test   %eax,%eax
  8026fb:	0f 88 20 03 00 00    	js     802a21 <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802701:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802707:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80270e:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802714:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  80271b:	00 00 00 
  80271e:	e9 88 01 00 00       	jmp    8028ab <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  802723:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802729:	83 38 01             	cmpl   $0x1,(%eax)
  80272c:	0f 85 6b 01 00 00    	jne    80289d <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802732:	89 c2                	mov    %eax,%edx
  802734:	8b 40 18             	mov    0x18(%eax),%eax
  802737:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80273d:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802740:	83 f8 01             	cmp    $0x1,%eax
  802743:	19 c0                	sbb    %eax,%eax
  802745:	83 e0 fe             	and    $0xfffffffe,%eax
  802748:	83 c0 07             	add    $0x7,%eax
  80274b:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802751:	89 d0                	mov    %edx,%eax
  802753:	8b 7a 04             	mov    0x4(%edx),%edi
  802756:	89 f9                	mov    %edi,%ecx
  802758:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  80275e:	8b 7a 10             	mov    0x10(%edx),%edi
  802761:	8b 52 14             	mov    0x14(%edx),%edx
  802764:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  80276a:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80276d:	89 f0                	mov    %esi,%eax
  80276f:	25 ff 0f 00 00       	and    $0xfff,%eax
  802774:	74 14                	je     80278a <spawn+0x2bc>
		va -= i;
  802776:	29 c6                	sub    %eax,%esi
		memsz += i;
  802778:	01 c2                	add    %eax,%edx
  80277a:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  802780:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  802782:	29 c1                	sub    %eax,%ecx
  802784:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80278a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80278f:	e9 f7 00 00 00       	jmp    80288b <spawn+0x3bd>
		if (i >= filesz) {
  802794:	39 fb                	cmp    %edi,%ebx
  802796:	72 27                	jb     8027bf <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802798:	83 ec 04             	sub    $0x4,%esp
  80279b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8027a1:	56                   	push   %esi
  8027a2:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8027a8:	e8 04 ee ff ff       	call   8015b1 <sys_page_alloc>
  8027ad:	83 c4 10             	add    $0x10,%esp
  8027b0:	85 c0                	test   %eax,%eax
  8027b2:	0f 89 c7 00 00 00    	jns    80287f <spawn+0x3b1>
  8027b8:	89 c3                	mov    %eax,%ebx
  8027ba:	e9 fd 01 00 00       	jmp    8029bc <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8027bf:	83 ec 04             	sub    $0x4,%esp
  8027c2:	6a 07                	push   $0x7
  8027c4:	68 00 00 40 00       	push   $0x400000
  8027c9:	6a 00                	push   $0x0
  8027cb:	e8 e1 ed ff ff       	call   8015b1 <sys_page_alloc>
  8027d0:	83 c4 10             	add    $0x10,%esp
  8027d3:	85 c0                	test   %eax,%eax
  8027d5:	0f 88 d7 01 00 00    	js     8029b2 <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8027db:	83 ec 08             	sub    $0x8,%esp
  8027de:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8027e4:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8027ea:	50                   	push   %eax
  8027eb:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8027f1:	e8 ff f7 ff ff       	call   801ff5 <seek>
  8027f6:	83 c4 10             	add    $0x10,%esp
  8027f9:	85 c0                	test   %eax,%eax
  8027fb:	0f 88 b5 01 00 00    	js     8029b6 <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802801:	83 ec 04             	sub    $0x4,%esp
  802804:	89 f8                	mov    %edi,%eax
  802806:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  80280c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802811:	ba 00 10 00 00       	mov    $0x1000,%edx
  802816:	0f 47 c2             	cmova  %edx,%eax
  802819:	50                   	push   %eax
  80281a:	68 00 00 40 00       	push   $0x400000
  80281f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802825:	e8 f6 f6 ff ff       	call   801f20 <readn>
  80282a:	83 c4 10             	add    $0x10,%esp
  80282d:	85 c0                	test   %eax,%eax
  80282f:	0f 88 85 01 00 00    	js     8029ba <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802835:	83 ec 0c             	sub    $0xc,%esp
  802838:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80283e:	56                   	push   %esi
  80283f:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802845:	68 00 00 40 00       	push   $0x400000
  80284a:	6a 00                	push   $0x0
  80284c:	e8 a3 ed ff ff       	call   8015f4 <sys_page_map>
  802851:	83 c4 20             	add    $0x20,%esp
  802854:	85 c0                	test   %eax,%eax
  802856:	79 15                	jns    80286d <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  802858:	50                   	push   %eax
  802859:	68 98 39 80 00       	push   $0x803998
  80285e:	68 25 01 00 00       	push   $0x125
  802863:	68 8c 39 80 00       	push   $0x80398c
  802868:	e8 f0 e1 ff ff       	call   800a5d <_panic>
			sys_page_unmap(0, UTEMP);
  80286d:	83 ec 08             	sub    $0x8,%esp
  802870:	68 00 00 40 00       	push   $0x400000
  802875:	6a 00                	push   $0x0
  802877:	e8 ba ed ff ff       	call   801636 <sys_page_unmap>
  80287c:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80287f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802885:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80288b:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802891:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  802897:	0f 82 f7 fe ff ff    	jb     802794 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80289d:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8028a4:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8028ab:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8028b2:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8028b8:	0f 8c 65 fe ff ff    	jl     802723 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8028be:	83 ec 0c             	sub    $0xc,%esp
  8028c1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028c7:	e8 87 f4 ff ff       	call   801d53 <close>
  8028cc:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  8028cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028d4:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  8028da:	89 d8                	mov    %ebx,%eax
  8028dc:	c1 e8 16             	shr    $0x16,%eax
  8028df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8028e6:	a8 01                	test   $0x1,%al
  8028e8:	74 42                	je     80292c <spawn+0x45e>
  8028ea:	89 d8                	mov    %ebx,%eax
  8028ec:	c1 e8 0c             	shr    $0xc,%eax
  8028ef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8028f6:	f6 c2 01             	test   $0x1,%dl
  8028f9:	74 31                	je     80292c <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  8028fb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  802902:	f6 c6 04             	test   $0x4,%dh
  802905:	74 25                	je     80292c <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  802907:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80290e:	83 ec 0c             	sub    $0xc,%esp
  802911:	25 07 0e 00 00       	and    $0xe07,%eax
  802916:	50                   	push   %eax
  802917:	53                   	push   %ebx
  802918:	56                   	push   %esi
  802919:	53                   	push   %ebx
  80291a:	6a 00                	push   $0x0
  80291c:	e8 d3 ec ff ff       	call   8015f4 <sys_page_map>
			if (r < 0) {
  802921:	83 c4 20             	add    $0x20,%esp
  802924:	85 c0                	test   %eax,%eax
  802926:	0f 88 b1 00 00 00    	js     8029dd <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  80292c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802932:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802938:	75 a0                	jne    8028da <spawn+0x40c>
  80293a:	e9 b3 00 00 00       	jmp    8029f2 <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  80293f:	50                   	push   %eax
  802940:	68 b5 39 80 00       	push   $0x8039b5
  802945:	68 86 00 00 00       	push   $0x86
  80294a:	68 8c 39 80 00       	push   $0x80398c
  80294f:	e8 09 e1 ff ff       	call   800a5d <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802954:	83 ec 08             	sub    $0x8,%esp
  802957:	6a 02                	push   $0x2
  802959:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80295f:	e8 14 ed ff ff       	call   801678 <sys_env_set_status>
  802964:	83 c4 10             	add    $0x10,%esp
  802967:	85 c0                	test   %eax,%eax
  802969:	79 2b                	jns    802996 <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  80296b:	50                   	push   %eax
  80296c:	68 cf 39 80 00       	push   $0x8039cf
  802971:	68 89 00 00 00       	push   $0x89
  802976:	68 8c 39 80 00       	push   $0x80398c
  80297b:	e8 dd e0 ff ff       	call   800a5d <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802980:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802986:	e9 a8 00 00 00       	jmp    802a33 <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  80298b:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802991:	e9 9d 00 00 00       	jmp    802a33 <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802996:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80299c:	e9 92 00 00 00       	jmp    802a33 <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8029a1:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8029a6:	e9 88 00 00 00       	jmp    802a33 <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8029ab:	89 c3                	mov    %eax,%ebx
  8029ad:	e9 81 00 00 00       	jmp    802a33 <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8029b2:	89 c3                	mov    %eax,%ebx
  8029b4:	eb 06                	jmp    8029bc <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8029b6:	89 c3                	mov    %eax,%ebx
  8029b8:	eb 02                	jmp    8029bc <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8029ba:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8029bc:	83 ec 0c             	sub    $0xc,%esp
  8029bf:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029c5:	e8 68 eb ff ff       	call   801532 <sys_env_destroy>
	close(fd);
  8029ca:	83 c4 04             	add    $0x4,%esp
  8029cd:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8029d3:	e8 7b f3 ff ff       	call   801d53 <close>
	return r;
  8029d8:	83 c4 10             	add    $0x10,%esp
  8029db:	eb 56                	jmp    802a33 <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  8029dd:	50                   	push   %eax
  8029de:	68 e6 39 80 00       	push   $0x8039e6
  8029e3:	68 82 00 00 00       	push   $0x82
  8029e8:	68 8c 39 80 00       	push   $0x80398c
  8029ed:	e8 6b e0 ff ff       	call   800a5d <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8029f2:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8029f9:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8029fc:	83 ec 08             	sub    $0x8,%esp
  8029ff:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a05:	50                   	push   %eax
  802a06:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a0c:	e8 a9 ec ff ff       	call   8016ba <sys_env_set_trapframe>
  802a11:	83 c4 10             	add    $0x10,%esp
  802a14:	85 c0                	test   %eax,%eax
  802a16:	0f 89 38 ff ff ff    	jns    802954 <spawn+0x486>
  802a1c:	e9 1e ff ff ff       	jmp    80293f <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802a21:	83 ec 08             	sub    $0x8,%esp
  802a24:	68 00 00 40 00       	push   $0x400000
  802a29:	6a 00                	push   $0x0
  802a2b:	e8 06 ec ff ff       	call   801636 <sys_page_unmap>
  802a30:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802a33:	89 d8                	mov    %ebx,%eax
  802a35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a38:	5b                   	pop    %ebx
  802a39:	5e                   	pop    %esi
  802a3a:	5f                   	pop    %edi
  802a3b:	5d                   	pop    %ebp
  802a3c:	c3                   	ret    

00802a3d <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802a3d:	55                   	push   %ebp
  802a3e:	89 e5                	mov    %esp,%ebp
  802a40:	56                   	push   %esi
  802a41:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a42:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802a45:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a4a:	eb 03                	jmp    802a4f <spawnl+0x12>
		argc++;
  802a4c:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a4f:	83 c2 04             	add    $0x4,%edx
  802a52:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802a56:	75 f4                	jne    802a4c <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802a58:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802a5f:	83 e2 f0             	and    $0xfffffff0,%edx
  802a62:	29 d4                	sub    %edx,%esp
  802a64:	8d 54 24 03          	lea    0x3(%esp),%edx
  802a68:	c1 ea 02             	shr    $0x2,%edx
  802a6b:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802a72:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802a74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a77:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802a7e:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802a85:	00 
  802a86:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a88:	b8 00 00 00 00       	mov    $0x0,%eax
  802a8d:	eb 0a                	jmp    802a99 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802a8f:	83 c0 01             	add    $0x1,%eax
  802a92:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802a96:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a99:	39 d0                	cmp    %edx,%eax
  802a9b:	75 f2                	jne    802a8f <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802a9d:	83 ec 08             	sub    $0x8,%esp
  802aa0:	56                   	push   %esi
  802aa1:	ff 75 08             	pushl  0x8(%ebp)
  802aa4:	e8 25 fa ff ff       	call   8024ce <spawn>
}
  802aa9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802aac:	5b                   	pop    %ebx
  802aad:	5e                   	pop    %esi
  802aae:	5d                   	pop    %ebp
  802aaf:	c3                   	ret    

00802ab0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802ab0:	55                   	push   %ebp
  802ab1:	89 e5                	mov    %esp,%ebp
  802ab3:	56                   	push   %esi
  802ab4:	53                   	push   %ebx
  802ab5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802ab8:	83 ec 0c             	sub    $0xc,%esp
  802abb:	ff 75 08             	pushl  0x8(%ebp)
  802abe:	e8 00 f1 ff ff       	call   801bc3 <fd2data>
  802ac3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802ac5:	83 c4 08             	add    $0x8,%esp
  802ac8:	68 24 3a 80 00       	push   $0x803a24
  802acd:	53                   	push   %ebx
  802ace:	e8 db e6 ff ff       	call   8011ae <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802ad3:	8b 46 04             	mov    0x4(%esi),%eax
  802ad6:	2b 06                	sub    (%esi),%eax
  802ad8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802ade:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802ae5:	00 00 00 
	stat->st_dev = &devpipe;
  802ae8:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802aef:	40 80 00 
	return 0;
}
  802af2:	b8 00 00 00 00       	mov    $0x0,%eax
  802af7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802afa:	5b                   	pop    %ebx
  802afb:	5e                   	pop    %esi
  802afc:	5d                   	pop    %ebp
  802afd:	c3                   	ret    

00802afe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802afe:	55                   	push   %ebp
  802aff:	89 e5                	mov    %esp,%ebp
  802b01:	53                   	push   %ebx
  802b02:	83 ec 0c             	sub    $0xc,%esp
  802b05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b08:	53                   	push   %ebx
  802b09:	6a 00                	push   $0x0
  802b0b:	e8 26 eb ff ff       	call   801636 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b10:	89 1c 24             	mov    %ebx,(%esp)
  802b13:	e8 ab f0 ff ff       	call   801bc3 <fd2data>
  802b18:	83 c4 08             	add    $0x8,%esp
  802b1b:	50                   	push   %eax
  802b1c:	6a 00                	push   $0x0
  802b1e:	e8 13 eb ff ff       	call   801636 <sys_page_unmap>
}
  802b23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b26:	c9                   	leave  
  802b27:	c3                   	ret    

00802b28 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b28:	55                   	push   %ebp
  802b29:	89 e5                	mov    %esp,%ebp
  802b2b:	57                   	push   %edi
  802b2c:	56                   	push   %esi
  802b2d:	53                   	push   %ebx
  802b2e:	83 ec 1c             	sub    $0x1c,%esp
  802b31:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802b34:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802b36:	a1 24 54 80 00       	mov    0x805424,%eax
  802b3b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802b3e:	83 ec 0c             	sub    $0xc,%esp
  802b41:	ff 75 e0             	pushl  -0x20(%ebp)
  802b44:	e8 ae 04 00 00       	call   802ff7 <pageref>
  802b49:	89 c3                	mov    %eax,%ebx
  802b4b:	89 3c 24             	mov    %edi,(%esp)
  802b4e:	e8 a4 04 00 00       	call   802ff7 <pageref>
  802b53:	83 c4 10             	add    $0x10,%esp
  802b56:	39 c3                	cmp    %eax,%ebx
  802b58:	0f 94 c1             	sete   %cl
  802b5b:	0f b6 c9             	movzbl %cl,%ecx
  802b5e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802b61:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802b67:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802b6a:	39 ce                	cmp    %ecx,%esi
  802b6c:	74 1b                	je     802b89 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802b6e:	39 c3                	cmp    %eax,%ebx
  802b70:	75 c4                	jne    802b36 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802b72:	8b 42 58             	mov    0x58(%edx),%eax
  802b75:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b78:	50                   	push   %eax
  802b79:	56                   	push   %esi
  802b7a:	68 2b 3a 80 00       	push   $0x803a2b
  802b7f:	e8 b2 df ff ff       	call   800b36 <cprintf>
  802b84:	83 c4 10             	add    $0x10,%esp
  802b87:	eb ad                	jmp    802b36 <_pipeisclosed+0xe>
	}
}
  802b89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802b8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b8f:	5b                   	pop    %ebx
  802b90:	5e                   	pop    %esi
  802b91:	5f                   	pop    %edi
  802b92:	5d                   	pop    %ebp
  802b93:	c3                   	ret    

00802b94 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802b94:	55                   	push   %ebp
  802b95:	89 e5                	mov    %esp,%ebp
  802b97:	57                   	push   %edi
  802b98:	56                   	push   %esi
  802b99:	53                   	push   %ebx
  802b9a:	83 ec 28             	sub    $0x28,%esp
  802b9d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802ba0:	56                   	push   %esi
  802ba1:	e8 1d f0 ff ff       	call   801bc3 <fd2data>
  802ba6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ba8:	83 c4 10             	add    $0x10,%esp
  802bab:	bf 00 00 00 00       	mov    $0x0,%edi
  802bb0:	eb 4b                	jmp    802bfd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802bb2:	89 da                	mov    %ebx,%edx
  802bb4:	89 f0                	mov    %esi,%eax
  802bb6:	e8 6d ff ff ff       	call   802b28 <_pipeisclosed>
  802bbb:	85 c0                	test   %eax,%eax
  802bbd:	75 48                	jne    802c07 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802bbf:	e8 ce e9 ff ff       	call   801592 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802bc4:	8b 43 04             	mov    0x4(%ebx),%eax
  802bc7:	8b 0b                	mov    (%ebx),%ecx
  802bc9:	8d 51 20             	lea    0x20(%ecx),%edx
  802bcc:	39 d0                	cmp    %edx,%eax
  802bce:	73 e2                	jae    802bb2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802bd3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802bd7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802bda:	89 c2                	mov    %eax,%edx
  802bdc:	c1 fa 1f             	sar    $0x1f,%edx
  802bdf:	89 d1                	mov    %edx,%ecx
  802be1:	c1 e9 1b             	shr    $0x1b,%ecx
  802be4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802be7:	83 e2 1f             	and    $0x1f,%edx
  802bea:	29 ca                	sub    %ecx,%edx
  802bec:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802bf0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802bf4:	83 c0 01             	add    $0x1,%eax
  802bf7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bfa:	83 c7 01             	add    $0x1,%edi
  802bfd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802c00:	75 c2                	jne    802bc4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c02:	8b 45 10             	mov    0x10(%ebp),%eax
  802c05:	eb 05                	jmp    802c0c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c07:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c0f:	5b                   	pop    %ebx
  802c10:	5e                   	pop    %esi
  802c11:	5f                   	pop    %edi
  802c12:	5d                   	pop    %ebp
  802c13:	c3                   	ret    

00802c14 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c14:	55                   	push   %ebp
  802c15:	89 e5                	mov    %esp,%ebp
  802c17:	57                   	push   %edi
  802c18:	56                   	push   %esi
  802c19:	53                   	push   %ebx
  802c1a:	83 ec 18             	sub    $0x18,%esp
  802c1d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c20:	57                   	push   %edi
  802c21:	e8 9d ef ff ff       	call   801bc3 <fd2data>
  802c26:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c28:	83 c4 10             	add    $0x10,%esp
  802c2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c30:	eb 3d                	jmp    802c6f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802c32:	85 db                	test   %ebx,%ebx
  802c34:	74 04                	je     802c3a <devpipe_read+0x26>
				return i;
  802c36:	89 d8                	mov    %ebx,%eax
  802c38:	eb 44                	jmp    802c7e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802c3a:	89 f2                	mov    %esi,%edx
  802c3c:	89 f8                	mov    %edi,%eax
  802c3e:	e8 e5 fe ff ff       	call   802b28 <_pipeisclosed>
  802c43:	85 c0                	test   %eax,%eax
  802c45:	75 32                	jne    802c79 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802c47:	e8 46 e9 ff ff       	call   801592 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802c4c:	8b 06                	mov    (%esi),%eax
  802c4e:	3b 46 04             	cmp    0x4(%esi),%eax
  802c51:	74 df                	je     802c32 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802c53:	99                   	cltd   
  802c54:	c1 ea 1b             	shr    $0x1b,%edx
  802c57:	01 d0                	add    %edx,%eax
  802c59:	83 e0 1f             	and    $0x1f,%eax
  802c5c:	29 d0                	sub    %edx,%eax
  802c5e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c66:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802c69:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c6c:	83 c3 01             	add    $0x1,%ebx
  802c6f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802c72:	75 d8                	jne    802c4c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802c74:	8b 45 10             	mov    0x10(%ebp),%eax
  802c77:	eb 05                	jmp    802c7e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c79:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c81:	5b                   	pop    %ebx
  802c82:	5e                   	pop    %esi
  802c83:	5f                   	pop    %edi
  802c84:	5d                   	pop    %ebp
  802c85:	c3                   	ret    

00802c86 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802c86:	55                   	push   %ebp
  802c87:	89 e5                	mov    %esp,%ebp
  802c89:	56                   	push   %esi
  802c8a:	53                   	push   %ebx
  802c8b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802c8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c91:	50                   	push   %eax
  802c92:	e8 43 ef ff ff       	call   801bda <fd_alloc>
  802c97:	83 c4 10             	add    $0x10,%esp
  802c9a:	89 c2                	mov    %eax,%edx
  802c9c:	85 c0                	test   %eax,%eax
  802c9e:	0f 88 2c 01 00 00    	js     802dd0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ca4:	83 ec 04             	sub    $0x4,%esp
  802ca7:	68 07 04 00 00       	push   $0x407
  802cac:	ff 75 f4             	pushl  -0xc(%ebp)
  802caf:	6a 00                	push   $0x0
  802cb1:	e8 fb e8 ff ff       	call   8015b1 <sys_page_alloc>
  802cb6:	83 c4 10             	add    $0x10,%esp
  802cb9:	89 c2                	mov    %eax,%edx
  802cbb:	85 c0                	test   %eax,%eax
  802cbd:	0f 88 0d 01 00 00    	js     802dd0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802cc3:	83 ec 0c             	sub    $0xc,%esp
  802cc6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cc9:	50                   	push   %eax
  802cca:	e8 0b ef ff ff       	call   801bda <fd_alloc>
  802ccf:	89 c3                	mov    %eax,%ebx
  802cd1:	83 c4 10             	add    $0x10,%esp
  802cd4:	85 c0                	test   %eax,%eax
  802cd6:	0f 88 e2 00 00 00    	js     802dbe <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cdc:	83 ec 04             	sub    $0x4,%esp
  802cdf:	68 07 04 00 00       	push   $0x407
  802ce4:	ff 75 f0             	pushl  -0x10(%ebp)
  802ce7:	6a 00                	push   $0x0
  802ce9:	e8 c3 e8 ff ff       	call   8015b1 <sys_page_alloc>
  802cee:	89 c3                	mov    %eax,%ebx
  802cf0:	83 c4 10             	add    $0x10,%esp
  802cf3:	85 c0                	test   %eax,%eax
  802cf5:	0f 88 c3 00 00 00    	js     802dbe <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802cfb:	83 ec 0c             	sub    $0xc,%esp
  802cfe:	ff 75 f4             	pushl  -0xc(%ebp)
  802d01:	e8 bd ee ff ff       	call   801bc3 <fd2data>
  802d06:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d08:	83 c4 0c             	add    $0xc,%esp
  802d0b:	68 07 04 00 00       	push   $0x407
  802d10:	50                   	push   %eax
  802d11:	6a 00                	push   $0x0
  802d13:	e8 99 e8 ff ff       	call   8015b1 <sys_page_alloc>
  802d18:	89 c3                	mov    %eax,%ebx
  802d1a:	83 c4 10             	add    $0x10,%esp
  802d1d:	85 c0                	test   %eax,%eax
  802d1f:	0f 88 89 00 00 00    	js     802dae <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d25:	83 ec 0c             	sub    $0xc,%esp
  802d28:	ff 75 f0             	pushl  -0x10(%ebp)
  802d2b:	e8 93 ee ff ff       	call   801bc3 <fd2data>
  802d30:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802d37:	50                   	push   %eax
  802d38:	6a 00                	push   $0x0
  802d3a:	56                   	push   %esi
  802d3b:	6a 00                	push   $0x0
  802d3d:	e8 b2 e8 ff ff       	call   8015f4 <sys_page_map>
  802d42:	89 c3                	mov    %eax,%ebx
  802d44:	83 c4 20             	add    $0x20,%esp
  802d47:	85 c0                	test   %eax,%eax
  802d49:	78 55                	js     802da0 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802d4b:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d54:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d59:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802d60:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d69:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802d6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d6e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802d75:	83 ec 0c             	sub    $0xc,%esp
  802d78:	ff 75 f4             	pushl  -0xc(%ebp)
  802d7b:	e8 33 ee ff ff       	call   801bb3 <fd2num>
  802d80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d83:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802d85:	83 c4 04             	add    $0x4,%esp
  802d88:	ff 75 f0             	pushl  -0x10(%ebp)
  802d8b:	e8 23 ee ff ff       	call   801bb3 <fd2num>
  802d90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d93:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802d96:	83 c4 10             	add    $0x10,%esp
  802d99:	ba 00 00 00 00       	mov    $0x0,%edx
  802d9e:	eb 30                	jmp    802dd0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802da0:	83 ec 08             	sub    $0x8,%esp
  802da3:	56                   	push   %esi
  802da4:	6a 00                	push   $0x0
  802da6:	e8 8b e8 ff ff       	call   801636 <sys_page_unmap>
  802dab:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802dae:	83 ec 08             	sub    $0x8,%esp
  802db1:	ff 75 f0             	pushl  -0x10(%ebp)
  802db4:	6a 00                	push   $0x0
  802db6:	e8 7b e8 ff ff       	call   801636 <sys_page_unmap>
  802dbb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802dbe:	83 ec 08             	sub    $0x8,%esp
  802dc1:	ff 75 f4             	pushl  -0xc(%ebp)
  802dc4:	6a 00                	push   $0x0
  802dc6:	e8 6b e8 ff ff       	call   801636 <sys_page_unmap>
  802dcb:	83 c4 10             	add    $0x10,%esp
  802dce:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802dd0:	89 d0                	mov    %edx,%eax
  802dd2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802dd5:	5b                   	pop    %ebx
  802dd6:	5e                   	pop    %esi
  802dd7:	5d                   	pop    %ebp
  802dd8:	c3                   	ret    

00802dd9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802dd9:	55                   	push   %ebp
  802dda:	89 e5                	mov    %esp,%ebp
  802ddc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802ddf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802de2:	50                   	push   %eax
  802de3:	ff 75 08             	pushl  0x8(%ebp)
  802de6:	e8 3e ee ff ff       	call   801c29 <fd_lookup>
  802deb:	83 c4 10             	add    $0x10,%esp
  802dee:	85 c0                	test   %eax,%eax
  802df0:	78 18                	js     802e0a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802df2:	83 ec 0c             	sub    $0xc,%esp
  802df5:	ff 75 f4             	pushl  -0xc(%ebp)
  802df8:	e8 c6 ed ff ff       	call   801bc3 <fd2data>
	return _pipeisclosed(fd, p);
  802dfd:	89 c2                	mov    %eax,%edx
  802dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e02:	e8 21 fd ff ff       	call   802b28 <_pipeisclosed>
  802e07:	83 c4 10             	add    $0x10,%esp
}
  802e0a:	c9                   	leave  
  802e0b:	c3                   	ret    

00802e0c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e0c:	55                   	push   %ebp
  802e0d:	89 e5                	mov    %esp,%ebp
  802e0f:	56                   	push   %esi
  802e10:	53                   	push   %ebx
  802e11:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e14:	85 f6                	test   %esi,%esi
  802e16:	75 16                	jne    802e2e <wait+0x22>
  802e18:	68 43 3a 80 00       	push   $0x803a43
  802e1d:	68 2f 34 80 00       	push   $0x80342f
  802e22:	6a 09                	push   $0x9
  802e24:	68 4e 3a 80 00       	push   $0x803a4e
  802e29:	e8 2f dc ff ff       	call   800a5d <_panic>
	e = &envs[ENVX(envid)];
  802e2e:	89 f3                	mov    %esi,%ebx
  802e30:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e36:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802e39:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802e3f:	eb 05                	jmp    802e46 <wait+0x3a>
		sys_yield();
  802e41:	e8 4c e7 ff ff       	call   801592 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e46:	8b 43 48             	mov    0x48(%ebx),%eax
  802e49:	39 c6                	cmp    %eax,%esi
  802e4b:	75 07                	jne    802e54 <wait+0x48>
  802e4d:	8b 43 54             	mov    0x54(%ebx),%eax
  802e50:	85 c0                	test   %eax,%eax
  802e52:	75 ed                	jne    802e41 <wait+0x35>
		sys_yield();
}
  802e54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e57:	5b                   	pop    %ebx
  802e58:	5e                   	pop    %esi
  802e59:	5d                   	pop    %ebp
  802e5a:	c3                   	ret    

00802e5b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802e5b:	55                   	push   %ebp
  802e5c:	89 e5                	mov    %esp,%ebp
  802e5e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802e61:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802e68:	75 2a                	jne    802e94 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802e6a:	83 ec 04             	sub    $0x4,%esp
  802e6d:	6a 07                	push   $0x7
  802e6f:	68 00 f0 bf ee       	push   $0xeebff000
  802e74:	6a 00                	push   $0x0
  802e76:	e8 36 e7 ff ff       	call   8015b1 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802e7b:	83 c4 10             	add    $0x10,%esp
  802e7e:	85 c0                	test   %eax,%eax
  802e80:	79 12                	jns    802e94 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802e82:	50                   	push   %eax
  802e83:	68 2b 38 80 00       	push   $0x80382b
  802e88:	6a 23                	push   $0x23
  802e8a:	68 59 3a 80 00       	push   $0x803a59
  802e8f:	e8 c9 db ff ff       	call   800a5d <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802e94:	8b 45 08             	mov    0x8(%ebp),%eax
  802e97:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802e9c:	83 ec 08             	sub    $0x8,%esp
  802e9f:	68 c6 2e 80 00       	push   $0x802ec6
  802ea4:	6a 00                	push   $0x0
  802ea6:	e8 51 e8 ff ff       	call   8016fc <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802eab:	83 c4 10             	add    $0x10,%esp
  802eae:	85 c0                	test   %eax,%eax
  802eb0:	79 12                	jns    802ec4 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802eb2:	50                   	push   %eax
  802eb3:	68 2b 38 80 00       	push   $0x80382b
  802eb8:	6a 2c                	push   $0x2c
  802eba:	68 59 3a 80 00       	push   $0x803a59
  802ebf:	e8 99 db ff ff       	call   800a5d <_panic>
	}
}
  802ec4:	c9                   	leave  
  802ec5:	c3                   	ret    

00802ec6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802ec6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802ec7:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802ecc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802ece:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802ed1:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802ed5:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802eda:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802ede:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802ee0:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802ee3:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802ee4:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802ee7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802ee8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802ee9:	c3                   	ret    

00802eea <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802eea:	55                   	push   %ebp
  802eeb:	89 e5                	mov    %esp,%ebp
  802eed:	56                   	push   %esi
  802eee:	53                   	push   %ebx
  802eef:	8b 75 08             	mov    0x8(%ebp),%esi
  802ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ef5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802ef8:	85 c0                	test   %eax,%eax
  802efa:	75 12                	jne    802f0e <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802efc:	83 ec 0c             	sub    $0xc,%esp
  802eff:	68 00 00 c0 ee       	push   $0xeec00000
  802f04:	e8 58 e8 ff ff       	call   801761 <sys_ipc_recv>
  802f09:	83 c4 10             	add    $0x10,%esp
  802f0c:	eb 0c                	jmp    802f1a <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802f0e:	83 ec 0c             	sub    $0xc,%esp
  802f11:	50                   	push   %eax
  802f12:	e8 4a e8 ff ff       	call   801761 <sys_ipc_recv>
  802f17:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802f1a:	85 f6                	test   %esi,%esi
  802f1c:	0f 95 c1             	setne  %cl
  802f1f:	85 db                	test   %ebx,%ebx
  802f21:	0f 95 c2             	setne  %dl
  802f24:	84 d1                	test   %dl,%cl
  802f26:	74 09                	je     802f31 <ipc_recv+0x47>
  802f28:	89 c2                	mov    %eax,%edx
  802f2a:	c1 ea 1f             	shr    $0x1f,%edx
  802f2d:	84 d2                	test   %dl,%dl
  802f2f:	75 24                	jne    802f55 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802f31:	85 f6                	test   %esi,%esi
  802f33:	74 0a                	je     802f3f <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  802f35:	a1 24 54 80 00       	mov    0x805424,%eax
  802f3a:	8b 40 74             	mov    0x74(%eax),%eax
  802f3d:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802f3f:	85 db                	test   %ebx,%ebx
  802f41:	74 0a                	je     802f4d <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  802f43:	a1 24 54 80 00       	mov    0x805424,%eax
  802f48:	8b 40 78             	mov    0x78(%eax),%eax
  802f4b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802f4d:	a1 24 54 80 00       	mov    0x805424,%eax
  802f52:	8b 40 70             	mov    0x70(%eax),%eax
}
  802f55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f58:	5b                   	pop    %ebx
  802f59:	5e                   	pop    %esi
  802f5a:	5d                   	pop    %ebp
  802f5b:	c3                   	ret    

00802f5c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802f5c:	55                   	push   %ebp
  802f5d:	89 e5                	mov    %esp,%ebp
  802f5f:	57                   	push   %edi
  802f60:	56                   	push   %esi
  802f61:	53                   	push   %ebx
  802f62:	83 ec 0c             	sub    $0xc,%esp
  802f65:	8b 7d 08             	mov    0x8(%ebp),%edi
  802f68:	8b 75 0c             	mov    0xc(%ebp),%esi
  802f6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802f6e:	85 db                	test   %ebx,%ebx
  802f70:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802f75:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802f78:	ff 75 14             	pushl  0x14(%ebp)
  802f7b:	53                   	push   %ebx
  802f7c:	56                   	push   %esi
  802f7d:	57                   	push   %edi
  802f7e:	e8 bb e7 ff ff       	call   80173e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802f83:	89 c2                	mov    %eax,%edx
  802f85:	c1 ea 1f             	shr    $0x1f,%edx
  802f88:	83 c4 10             	add    $0x10,%esp
  802f8b:	84 d2                	test   %dl,%dl
  802f8d:	74 17                	je     802fa6 <ipc_send+0x4a>
  802f8f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802f92:	74 12                	je     802fa6 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802f94:	50                   	push   %eax
  802f95:	68 67 3a 80 00       	push   $0x803a67
  802f9a:	6a 47                	push   $0x47
  802f9c:	68 75 3a 80 00       	push   $0x803a75
  802fa1:	e8 b7 da ff ff       	call   800a5d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802fa6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802fa9:	75 07                	jne    802fb2 <ipc_send+0x56>
			sys_yield();
  802fab:	e8 e2 e5 ff ff       	call   801592 <sys_yield>
  802fb0:	eb c6                	jmp    802f78 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802fb2:	85 c0                	test   %eax,%eax
  802fb4:	75 c2                	jne    802f78 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802fb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802fb9:	5b                   	pop    %ebx
  802fba:	5e                   	pop    %esi
  802fbb:	5f                   	pop    %edi
  802fbc:	5d                   	pop    %ebp
  802fbd:	c3                   	ret    

00802fbe <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802fbe:	55                   	push   %ebp
  802fbf:	89 e5                	mov    %esp,%ebp
  802fc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802fc4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802fc9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802fcc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802fd2:	8b 52 50             	mov    0x50(%edx),%edx
  802fd5:	39 ca                	cmp    %ecx,%edx
  802fd7:	75 0d                	jne    802fe6 <ipc_find_env+0x28>
			return envs[i].env_id;
  802fd9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802fdc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802fe1:	8b 40 48             	mov    0x48(%eax),%eax
  802fe4:	eb 0f                	jmp    802ff5 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802fe6:	83 c0 01             	add    $0x1,%eax
  802fe9:	3d 00 04 00 00       	cmp    $0x400,%eax
  802fee:	75 d9                	jne    802fc9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802ff0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ff5:	5d                   	pop    %ebp
  802ff6:	c3                   	ret    

00802ff7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802ff7:	55                   	push   %ebp
  802ff8:	89 e5                	mov    %esp,%ebp
  802ffa:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802ffd:	89 d0                	mov    %edx,%eax
  802fff:	c1 e8 16             	shr    $0x16,%eax
  803002:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803009:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80300e:	f6 c1 01             	test   $0x1,%cl
  803011:	74 1d                	je     803030 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803013:	c1 ea 0c             	shr    $0xc,%edx
  803016:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80301d:	f6 c2 01             	test   $0x1,%dl
  803020:	74 0e                	je     803030 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803022:	c1 ea 0c             	shr    $0xc,%edx
  803025:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80302c:	ef 
  80302d:	0f b7 c0             	movzwl %ax,%eax
}
  803030:	5d                   	pop    %ebp
  803031:	c3                   	ret    
  803032:	66 90                	xchg   %ax,%ax
  803034:	66 90                	xchg   %ax,%ax
  803036:	66 90                	xchg   %ax,%ax
  803038:	66 90                	xchg   %ax,%ax
  80303a:	66 90                	xchg   %ax,%ax
  80303c:	66 90                	xchg   %ax,%ax
  80303e:	66 90                	xchg   %ax,%ax

00803040 <__udivdi3>:
  803040:	55                   	push   %ebp
  803041:	57                   	push   %edi
  803042:	56                   	push   %esi
  803043:	53                   	push   %ebx
  803044:	83 ec 1c             	sub    $0x1c,%esp
  803047:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80304b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80304f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803053:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803057:	85 f6                	test   %esi,%esi
  803059:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80305d:	89 ca                	mov    %ecx,%edx
  80305f:	89 f8                	mov    %edi,%eax
  803061:	75 3d                	jne    8030a0 <__udivdi3+0x60>
  803063:	39 cf                	cmp    %ecx,%edi
  803065:	0f 87 c5 00 00 00    	ja     803130 <__udivdi3+0xf0>
  80306b:	85 ff                	test   %edi,%edi
  80306d:	89 fd                	mov    %edi,%ebp
  80306f:	75 0b                	jne    80307c <__udivdi3+0x3c>
  803071:	b8 01 00 00 00       	mov    $0x1,%eax
  803076:	31 d2                	xor    %edx,%edx
  803078:	f7 f7                	div    %edi
  80307a:	89 c5                	mov    %eax,%ebp
  80307c:	89 c8                	mov    %ecx,%eax
  80307e:	31 d2                	xor    %edx,%edx
  803080:	f7 f5                	div    %ebp
  803082:	89 c1                	mov    %eax,%ecx
  803084:	89 d8                	mov    %ebx,%eax
  803086:	89 cf                	mov    %ecx,%edi
  803088:	f7 f5                	div    %ebp
  80308a:	89 c3                	mov    %eax,%ebx
  80308c:	89 d8                	mov    %ebx,%eax
  80308e:	89 fa                	mov    %edi,%edx
  803090:	83 c4 1c             	add    $0x1c,%esp
  803093:	5b                   	pop    %ebx
  803094:	5e                   	pop    %esi
  803095:	5f                   	pop    %edi
  803096:	5d                   	pop    %ebp
  803097:	c3                   	ret    
  803098:	90                   	nop
  803099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8030a0:	39 ce                	cmp    %ecx,%esi
  8030a2:	77 74                	ja     803118 <__udivdi3+0xd8>
  8030a4:	0f bd fe             	bsr    %esi,%edi
  8030a7:	83 f7 1f             	xor    $0x1f,%edi
  8030aa:	0f 84 98 00 00 00    	je     803148 <__udivdi3+0x108>
  8030b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8030b5:	89 f9                	mov    %edi,%ecx
  8030b7:	89 c5                	mov    %eax,%ebp
  8030b9:	29 fb                	sub    %edi,%ebx
  8030bb:	d3 e6                	shl    %cl,%esi
  8030bd:	89 d9                	mov    %ebx,%ecx
  8030bf:	d3 ed                	shr    %cl,%ebp
  8030c1:	89 f9                	mov    %edi,%ecx
  8030c3:	d3 e0                	shl    %cl,%eax
  8030c5:	09 ee                	or     %ebp,%esi
  8030c7:	89 d9                	mov    %ebx,%ecx
  8030c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8030cd:	89 d5                	mov    %edx,%ebp
  8030cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8030d3:	d3 ed                	shr    %cl,%ebp
  8030d5:	89 f9                	mov    %edi,%ecx
  8030d7:	d3 e2                	shl    %cl,%edx
  8030d9:	89 d9                	mov    %ebx,%ecx
  8030db:	d3 e8                	shr    %cl,%eax
  8030dd:	09 c2                	or     %eax,%edx
  8030df:	89 d0                	mov    %edx,%eax
  8030e1:	89 ea                	mov    %ebp,%edx
  8030e3:	f7 f6                	div    %esi
  8030e5:	89 d5                	mov    %edx,%ebp
  8030e7:	89 c3                	mov    %eax,%ebx
  8030e9:	f7 64 24 0c          	mull   0xc(%esp)
  8030ed:	39 d5                	cmp    %edx,%ebp
  8030ef:	72 10                	jb     803101 <__udivdi3+0xc1>
  8030f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8030f5:	89 f9                	mov    %edi,%ecx
  8030f7:	d3 e6                	shl    %cl,%esi
  8030f9:	39 c6                	cmp    %eax,%esi
  8030fb:	73 07                	jae    803104 <__udivdi3+0xc4>
  8030fd:	39 d5                	cmp    %edx,%ebp
  8030ff:	75 03                	jne    803104 <__udivdi3+0xc4>
  803101:	83 eb 01             	sub    $0x1,%ebx
  803104:	31 ff                	xor    %edi,%edi
  803106:	89 d8                	mov    %ebx,%eax
  803108:	89 fa                	mov    %edi,%edx
  80310a:	83 c4 1c             	add    $0x1c,%esp
  80310d:	5b                   	pop    %ebx
  80310e:	5e                   	pop    %esi
  80310f:	5f                   	pop    %edi
  803110:	5d                   	pop    %ebp
  803111:	c3                   	ret    
  803112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803118:	31 ff                	xor    %edi,%edi
  80311a:	31 db                	xor    %ebx,%ebx
  80311c:	89 d8                	mov    %ebx,%eax
  80311e:	89 fa                	mov    %edi,%edx
  803120:	83 c4 1c             	add    $0x1c,%esp
  803123:	5b                   	pop    %ebx
  803124:	5e                   	pop    %esi
  803125:	5f                   	pop    %edi
  803126:	5d                   	pop    %ebp
  803127:	c3                   	ret    
  803128:	90                   	nop
  803129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803130:	89 d8                	mov    %ebx,%eax
  803132:	f7 f7                	div    %edi
  803134:	31 ff                	xor    %edi,%edi
  803136:	89 c3                	mov    %eax,%ebx
  803138:	89 d8                	mov    %ebx,%eax
  80313a:	89 fa                	mov    %edi,%edx
  80313c:	83 c4 1c             	add    $0x1c,%esp
  80313f:	5b                   	pop    %ebx
  803140:	5e                   	pop    %esi
  803141:	5f                   	pop    %edi
  803142:	5d                   	pop    %ebp
  803143:	c3                   	ret    
  803144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803148:	39 ce                	cmp    %ecx,%esi
  80314a:	72 0c                	jb     803158 <__udivdi3+0x118>
  80314c:	31 db                	xor    %ebx,%ebx
  80314e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803152:	0f 87 34 ff ff ff    	ja     80308c <__udivdi3+0x4c>
  803158:	bb 01 00 00 00       	mov    $0x1,%ebx
  80315d:	e9 2a ff ff ff       	jmp    80308c <__udivdi3+0x4c>
  803162:	66 90                	xchg   %ax,%ax
  803164:	66 90                	xchg   %ax,%ax
  803166:	66 90                	xchg   %ax,%ax
  803168:	66 90                	xchg   %ax,%ax
  80316a:	66 90                	xchg   %ax,%ax
  80316c:	66 90                	xchg   %ax,%ax
  80316e:	66 90                	xchg   %ax,%ax

00803170 <__umoddi3>:
  803170:	55                   	push   %ebp
  803171:	57                   	push   %edi
  803172:	56                   	push   %esi
  803173:	53                   	push   %ebx
  803174:	83 ec 1c             	sub    $0x1c,%esp
  803177:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80317b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80317f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803187:	85 d2                	test   %edx,%edx
  803189:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80318d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803191:	89 f3                	mov    %esi,%ebx
  803193:	89 3c 24             	mov    %edi,(%esp)
  803196:	89 74 24 04          	mov    %esi,0x4(%esp)
  80319a:	75 1c                	jne    8031b8 <__umoddi3+0x48>
  80319c:	39 f7                	cmp    %esi,%edi
  80319e:	76 50                	jbe    8031f0 <__umoddi3+0x80>
  8031a0:	89 c8                	mov    %ecx,%eax
  8031a2:	89 f2                	mov    %esi,%edx
  8031a4:	f7 f7                	div    %edi
  8031a6:	89 d0                	mov    %edx,%eax
  8031a8:	31 d2                	xor    %edx,%edx
  8031aa:	83 c4 1c             	add    $0x1c,%esp
  8031ad:	5b                   	pop    %ebx
  8031ae:	5e                   	pop    %esi
  8031af:	5f                   	pop    %edi
  8031b0:	5d                   	pop    %ebp
  8031b1:	c3                   	ret    
  8031b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8031b8:	39 f2                	cmp    %esi,%edx
  8031ba:	89 d0                	mov    %edx,%eax
  8031bc:	77 52                	ja     803210 <__umoddi3+0xa0>
  8031be:	0f bd ea             	bsr    %edx,%ebp
  8031c1:	83 f5 1f             	xor    $0x1f,%ebp
  8031c4:	75 5a                	jne    803220 <__umoddi3+0xb0>
  8031c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8031ca:	0f 82 e0 00 00 00    	jb     8032b0 <__umoddi3+0x140>
  8031d0:	39 0c 24             	cmp    %ecx,(%esp)
  8031d3:	0f 86 d7 00 00 00    	jbe    8032b0 <__umoddi3+0x140>
  8031d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8031dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8031e1:	83 c4 1c             	add    $0x1c,%esp
  8031e4:	5b                   	pop    %ebx
  8031e5:	5e                   	pop    %esi
  8031e6:	5f                   	pop    %edi
  8031e7:	5d                   	pop    %ebp
  8031e8:	c3                   	ret    
  8031e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8031f0:	85 ff                	test   %edi,%edi
  8031f2:	89 fd                	mov    %edi,%ebp
  8031f4:	75 0b                	jne    803201 <__umoddi3+0x91>
  8031f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8031fb:	31 d2                	xor    %edx,%edx
  8031fd:	f7 f7                	div    %edi
  8031ff:	89 c5                	mov    %eax,%ebp
  803201:	89 f0                	mov    %esi,%eax
  803203:	31 d2                	xor    %edx,%edx
  803205:	f7 f5                	div    %ebp
  803207:	89 c8                	mov    %ecx,%eax
  803209:	f7 f5                	div    %ebp
  80320b:	89 d0                	mov    %edx,%eax
  80320d:	eb 99                	jmp    8031a8 <__umoddi3+0x38>
  80320f:	90                   	nop
  803210:	89 c8                	mov    %ecx,%eax
  803212:	89 f2                	mov    %esi,%edx
  803214:	83 c4 1c             	add    $0x1c,%esp
  803217:	5b                   	pop    %ebx
  803218:	5e                   	pop    %esi
  803219:	5f                   	pop    %edi
  80321a:	5d                   	pop    %ebp
  80321b:	c3                   	ret    
  80321c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803220:	8b 34 24             	mov    (%esp),%esi
  803223:	bf 20 00 00 00       	mov    $0x20,%edi
  803228:	89 e9                	mov    %ebp,%ecx
  80322a:	29 ef                	sub    %ebp,%edi
  80322c:	d3 e0                	shl    %cl,%eax
  80322e:	89 f9                	mov    %edi,%ecx
  803230:	89 f2                	mov    %esi,%edx
  803232:	d3 ea                	shr    %cl,%edx
  803234:	89 e9                	mov    %ebp,%ecx
  803236:	09 c2                	or     %eax,%edx
  803238:	89 d8                	mov    %ebx,%eax
  80323a:	89 14 24             	mov    %edx,(%esp)
  80323d:	89 f2                	mov    %esi,%edx
  80323f:	d3 e2                	shl    %cl,%edx
  803241:	89 f9                	mov    %edi,%ecx
  803243:	89 54 24 04          	mov    %edx,0x4(%esp)
  803247:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80324b:	d3 e8                	shr    %cl,%eax
  80324d:	89 e9                	mov    %ebp,%ecx
  80324f:	89 c6                	mov    %eax,%esi
  803251:	d3 e3                	shl    %cl,%ebx
  803253:	89 f9                	mov    %edi,%ecx
  803255:	89 d0                	mov    %edx,%eax
  803257:	d3 e8                	shr    %cl,%eax
  803259:	89 e9                	mov    %ebp,%ecx
  80325b:	09 d8                	or     %ebx,%eax
  80325d:	89 d3                	mov    %edx,%ebx
  80325f:	89 f2                	mov    %esi,%edx
  803261:	f7 34 24             	divl   (%esp)
  803264:	89 d6                	mov    %edx,%esi
  803266:	d3 e3                	shl    %cl,%ebx
  803268:	f7 64 24 04          	mull   0x4(%esp)
  80326c:	39 d6                	cmp    %edx,%esi
  80326e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803272:	89 d1                	mov    %edx,%ecx
  803274:	89 c3                	mov    %eax,%ebx
  803276:	72 08                	jb     803280 <__umoddi3+0x110>
  803278:	75 11                	jne    80328b <__umoddi3+0x11b>
  80327a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80327e:	73 0b                	jae    80328b <__umoddi3+0x11b>
  803280:	2b 44 24 04          	sub    0x4(%esp),%eax
  803284:	1b 14 24             	sbb    (%esp),%edx
  803287:	89 d1                	mov    %edx,%ecx
  803289:	89 c3                	mov    %eax,%ebx
  80328b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80328f:	29 da                	sub    %ebx,%edx
  803291:	19 ce                	sbb    %ecx,%esi
  803293:	89 f9                	mov    %edi,%ecx
  803295:	89 f0                	mov    %esi,%eax
  803297:	d3 e0                	shl    %cl,%eax
  803299:	89 e9                	mov    %ebp,%ecx
  80329b:	d3 ea                	shr    %cl,%edx
  80329d:	89 e9                	mov    %ebp,%ecx
  80329f:	d3 ee                	shr    %cl,%esi
  8032a1:	09 d0                	or     %edx,%eax
  8032a3:	89 f2                	mov    %esi,%edx
  8032a5:	83 c4 1c             	add    $0x1c,%esp
  8032a8:	5b                   	pop    %ebx
  8032a9:	5e                   	pop    %esi
  8032aa:	5f                   	pop    %edi
  8032ab:	5d                   	pop    %ebp
  8032ac:	c3                   	ret    
  8032ad:	8d 76 00             	lea    0x0(%esi),%esi
  8032b0:	29 f9                	sub    %edi,%ecx
  8032b2:	19 d6                	sbb    %edx,%esi
  8032b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8032b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8032bc:	e9 18 ff ff ff       	jmp    8031d9 <__umoddi3+0x69>
