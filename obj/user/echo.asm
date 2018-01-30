
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 ad 00 00 00       	call   8000de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	83 ec 08             	sub    $0x8,%esp
  800051:	68 a0 24 80 00       	push   $0x8024a0
  800056:	ff 76 04             	pushl  0x4(%esi)
  800059:	e8 e6 01 00 00       	call   800244 <strcmp>
  80005e:	83 c4 10             	add    $0x10,%esp
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
		nflag = 1;
		argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 38                	jmp    8000b8 <umain+0x85>
		if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 14                	jle    800099 <umain+0x66>
			write(1, " ", 1);
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 01                	push   $0x1
  80008a:	68 a3 24 80 00       	push   $0x8024a3
  80008f:	6a 01                	push   $0x1
  800091:	e8 12 10 00 00       	call   8010a8 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 bd 00 00 00       	call   800161 <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 f6 0f 00 00       	call   8010a8 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000b2:	83 c3 01             	add    $0x1,%ebx
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	39 df                	cmp    %ebx,%edi
  8000ba:	7f c4                	jg     800080 <umain+0x4d>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c0:	75 14                	jne    8000d6 <umain+0xa3>
		write(1, "\n", 1);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	6a 01                	push   $0x1
  8000c7:	68 4b 25 80 00       	push   $0x80254b
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 d5 0f 00 00       	call   8010a8 <write>
  8000d3:	83 c4 10             	add    $0x10,%esp
}
  8000d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e9:	e8 71 04 00 00       	call   80055f <sys_getenvid>
  8000ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f3:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x30>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 1b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800118:	e8 2a 00 00 00       	call   800147 <exit>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  80012d:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800132:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800134:	e8 26 04 00 00       	call   80055f <sys_getenvid>
  800139:	83 ec 0c             	sub    $0xc,%esp
  80013c:	50                   	push   %eax
  80013d:	e8 6c 06 00 00       	call   8007ae <sys_thread_free>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014d:	e8 68 0d 00 00       	call   800eba <close_all>
	sys_env_destroy(0);
  800152:	83 ec 0c             	sub    $0xc,%esp
  800155:	6a 00                	push   $0x0
  800157:	e8 c2 03 00 00       	call   80051e <sys_env_destroy>
}
  80015c:	83 c4 10             	add    $0x10,%esp
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800167:	b8 00 00 00 00       	mov    $0x0,%eax
  80016c:	eb 03                	jmp    800171 <strlen+0x10>
		n++;
  80016e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800171:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800175:	75 f7                	jne    80016e <strlen+0xd>
		n++;
	return n;
}
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800182:	ba 00 00 00 00       	mov    $0x0,%edx
  800187:	eb 03                	jmp    80018c <strnlen+0x13>
		n++;
  800189:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80018c:	39 c2                	cmp    %eax,%edx
  80018e:	74 08                	je     800198 <strnlen+0x1f>
  800190:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800194:	75 f3                	jne    800189 <strnlen+0x10>
  800196:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800198:	5d                   	pop    %ebp
  800199:	c3                   	ret    

0080019a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	53                   	push   %ebx
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8001a4:	89 c2                	mov    %eax,%edx
  8001a6:	83 c2 01             	add    $0x1,%edx
  8001a9:	83 c1 01             	add    $0x1,%ecx
  8001ac:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8001b0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8001b3:	84 db                	test   %bl,%bl
  8001b5:	75 ef                	jne    8001a6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8001b7:	5b                   	pop    %ebx
  8001b8:	5d                   	pop    %ebp
  8001b9:	c3                   	ret    

008001ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	53                   	push   %ebx
  8001be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001c1:	53                   	push   %ebx
  8001c2:	e8 9a ff ff ff       	call   800161 <strlen>
  8001c7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001ca:	ff 75 0c             	pushl  0xc(%ebp)
  8001cd:	01 d8                	add    %ebx,%eax
  8001cf:	50                   	push   %eax
  8001d0:	e8 c5 ff ff ff       	call   80019a <strcpy>
	return dst;
}
  8001d5:	89 d8                	mov    %ebx,%eax
  8001d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001da:	c9                   	leave  
  8001db:	c3                   	ret    

008001dc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8001e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e7:	89 f3                	mov    %esi,%ebx
  8001e9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001ec:	89 f2                	mov    %esi,%edx
  8001ee:	eb 0f                	jmp    8001ff <strncpy+0x23>
		*dst++ = *src;
  8001f0:	83 c2 01             	add    $0x1,%edx
  8001f3:	0f b6 01             	movzbl (%ecx),%eax
  8001f6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001f9:	80 39 01             	cmpb   $0x1,(%ecx)
  8001fc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001ff:	39 da                	cmp    %ebx,%edx
  800201:	75 ed                	jne    8001f0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800203:	89 f0                	mov    %esi,%eax
  800205:	5b                   	pop    %ebx
  800206:	5e                   	pop    %esi
  800207:	5d                   	pop    %ebp
  800208:	c3                   	ret    

00800209 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	56                   	push   %esi
  80020d:	53                   	push   %ebx
  80020e:	8b 75 08             	mov    0x8(%ebp),%esi
  800211:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800214:	8b 55 10             	mov    0x10(%ebp),%edx
  800217:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800219:	85 d2                	test   %edx,%edx
  80021b:	74 21                	je     80023e <strlcpy+0x35>
  80021d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	eb 09                	jmp    80022e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800225:	83 c2 01             	add    $0x1,%edx
  800228:	83 c1 01             	add    $0x1,%ecx
  80022b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80022e:	39 c2                	cmp    %eax,%edx
  800230:	74 09                	je     80023b <strlcpy+0x32>
  800232:	0f b6 19             	movzbl (%ecx),%ebx
  800235:	84 db                	test   %bl,%bl
  800237:	75 ec                	jne    800225 <strlcpy+0x1c>
  800239:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80023b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80023e:	29 f0                	sub    %esi,%eax
}
  800240:	5b                   	pop    %ebx
  800241:	5e                   	pop    %esi
  800242:	5d                   	pop    %ebp
  800243:	c3                   	ret    

00800244 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80024d:	eb 06                	jmp    800255 <strcmp+0x11>
		p++, q++;
  80024f:	83 c1 01             	add    $0x1,%ecx
  800252:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800255:	0f b6 01             	movzbl (%ecx),%eax
  800258:	84 c0                	test   %al,%al
  80025a:	74 04                	je     800260 <strcmp+0x1c>
  80025c:	3a 02                	cmp    (%edx),%al
  80025e:	74 ef                	je     80024f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800260:	0f b6 c0             	movzbl %al,%eax
  800263:	0f b6 12             	movzbl (%edx),%edx
  800266:	29 d0                	sub    %edx,%eax
}
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    

0080026a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	53                   	push   %ebx
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	8b 55 0c             	mov    0xc(%ebp),%edx
  800274:	89 c3                	mov    %eax,%ebx
  800276:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800279:	eb 06                	jmp    800281 <strncmp+0x17>
		n--, p++, q++;
  80027b:	83 c0 01             	add    $0x1,%eax
  80027e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800281:	39 d8                	cmp    %ebx,%eax
  800283:	74 15                	je     80029a <strncmp+0x30>
  800285:	0f b6 08             	movzbl (%eax),%ecx
  800288:	84 c9                	test   %cl,%cl
  80028a:	74 04                	je     800290 <strncmp+0x26>
  80028c:	3a 0a                	cmp    (%edx),%cl
  80028e:	74 eb                	je     80027b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800290:	0f b6 00             	movzbl (%eax),%eax
  800293:	0f b6 12             	movzbl (%edx),%edx
  800296:	29 d0                	sub    %edx,%eax
  800298:	eb 05                	jmp    80029f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80029a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80029f:	5b                   	pop    %ebx
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002ac:	eb 07                	jmp    8002b5 <strchr+0x13>
		if (*s == c)
  8002ae:	38 ca                	cmp    %cl,%dl
  8002b0:	74 0f                	je     8002c1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8002b2:	83 c0 01             	add    $0x1,%eax
  8002b5:	0f b6 10             	movzbl (%eax),%edx
  8002b8:	84 d2                	test   %dl,%dl
  8002ba:	75 f2                	jne    8002ae <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8002bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002cd:	eb 03                	jmp    8002d2 <strfind+0xf>
  8002cf:	83 c0 01             	add    $0x1,%eax
  8002d2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002d5:	38 ca                	cmp    %cl,%dl
  8002d7:	74 04                	je     8002dd <strfind+0x1a>
  8002d9:	84 d2                	test   %dl,%dl
  8002db:	75 f2                	jne    8002cf <strfind+0xc>
			break;
	return (char *) s;
}
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	57                   	push   %edi
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
  8002e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002eb:	85 c9                	test   %ecx,%ecx
  8002ed:	74 36                	je     800325 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002f5:	75 28                	jne    80031f <memset+0x40>
  8002f7:	f6 c1 03             	test   $0x3,%cl
  8002fa:	75 23                	jne    80031f <memset+0x40>
		c &= 0xFF;
  8002fc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800300:	89 d3                	mov    %edx,%ebx
  800302:	c1 e3 08             	shl    $0x8,%ebx
  800305:	89 d6                	mov    %edx,%esi
  800307:	c1 e6 18             	shl    $0x18,%esi
  80030a:	89 d0                	mov    %edx,%eax
  80030c:	c1 e0 10             	shl    $0x10,%eax
  80030f:	09 f0                	or     %esi,%eax
  800311:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800313:	89 d8                	mov    %ebx,%eax
  800315:	09 d0                	or     %edx,%eax
  800317:	c1 e9 02             	shr    $0x2,%ecx
  80031a:	fc                   	cld    
  80031b:	f3 ab                	rep stos %eax,%es:(%edi)
  80031d:	eb 06                	jmp    800325 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80031f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800322:	fc                   	cld    
  800323:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800325:	89 f8                	mov    %edi,%eax
  800327:	5b                   	pop    %ebx
  800328:	5e                   	pop    %esi
  800329:	5f                   	pop    %edi
  80032a:	5d                   	pop    %ebp
  80032b:	c3                   	ret    

0080032c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	57                   	push   %edi
  800330:	56                   	push   %esi
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	8b 75 0c             	mov    0xc(%ebp),%esi
  800337:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80033a:	39 c6                	cmp    %eax,%esi
  80033c:	73 35                	jae    800373 <memmove+0x47>
  80033e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800341:	39 d0                	cmp    %edx,%eax
  800343:	73 2e                	jae    800373 <memmove+0x47>
		s += n;
		d += n;
  800345:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800348:	89 d6                	mov    %edx,%esi
  80034a:	09 fe                	or     %edi,%esi
  80034c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800352:	75 13                	jne    800367 <memmove+0x3b>
  800354:	f6 c1 03             	test   $0x3,%cl
  800357:	75 0e                	jne    800367 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800359:	83 ef 04             	sub    $0x4,%edi
  80035c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80035f:	c1 e9 02             	shr    $0x2,%ecx
  800362:	fd                   	std    
  800363:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800365:	eb 09                	jmp    800370 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800367:	83 ef 01             	sub    $0x1,%edi
  80036a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80036d:	fd                   	std    
  80036e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800370:	fc                   	cld    
  800371:	eb 1d                	jmp    800390 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800373:	89 f2                	mov    %esi,%edx
  800375:	09 c2                	or     %eax,%edx
  800377:	f6 c2 03             	test   $0x3,%dl
  80037a:	75 0f                	jne    80038b <memmove+0x5f>
  80037c:	f6 c1 03             	test   $0x3,%cl
  80037f:	75 0a                	jne    80038b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800381:	c1 e9 02             	shr    $0x2,%ecx
  800384:	89 c7                	mov    %eax,%edi
  800386:	fc                   	cld    
  800387:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800389:	eb 05                	jmp    800390 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80038b:	89 c7                	mov    %eax,%edi
  80038d:	fc                   	cld    
  80038e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800390:	5e                   	pop    %esi
  800391:	5f                   	pop    %edi
  800392:	5d                   	pop    %ebp
  800393:	c3                   	ret    

00800394 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800397:	ff 75 10             	pushl  0x10(%ebp)
  80039a:	ff 75 0c             	pushl  0xc(%ebp)
  80039d:	ff 75 08             	pushl  0x8(%ebp)
  8003a0:	e8 87 ff ff ff       	call   80032c <memmove>
}
  8003a5:	c9                   	leave  
  8003a6:	c3                   	ret    

008003a7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	56                   	push   %esi
  8003ab:	53                   	push   %ebx
  8003ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8003af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b2:	89 c6                	mov    %eax,%esi
  8003b4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003b7:	eb 1a                	jmp    8003d3 <memcmp+0x2c>
		if (*s1 != *s2)
  8003b9:	0f b6 08             	movzbl (%eax),%ecx
  8003bc:	0f b6 1a             	movzbl (%edx),%ebx
  8003bf:	38 d9                	cmp    %bl,%cl
  8003c1:	74 0a                	je     8003cd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8003c3:	0f b6 c1             	movzbl %cl,%eax
  8003c6:	0f b6 db             	movzbl %bl,%ebx
  8003c9:	29 d8                	sub    %ebx,%eax
  8003cb:	eb 0f                	jmp    8003dc <memcmp+0x35>
		s1++, s2++;
  8003cd:	83 c0 01             	add    $0x1,%eax
  8003d0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003d3:	39 f0                	cmp    %esi,%eax
  8003d5:	75 e2                	jne    8003b9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003dc:	5b                   	pop    %ebx
  8003dd:	5e                   	pop    %esi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	53                   	push   %ebx
  8003e4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8003e7:	89 c1                	mov    %eax,%ecx
  8003e9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8003ec:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003f0:	eb 0a                	jmp    8003fc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003f2:	0f b6 10             	movzbl (%eax),%edx
  8003f5:	39 da                	cmp    %ebx,%edx
  8003f7:	74 07                	je     800400 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003f9:	83 c0 01             	add    $0x1,%eax
  8003fc:	39 c8                	cmp    %ecx,%eax
  8003fe:	72 f2                	jb     8003f2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800400:	5b                   	pop    %ebx
  800401:	5d                   	pop    %ebp
  800402:	c3                   	ret    

00800403 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	57                   	push   %edi
  800407:	56                   	push   %esi
  800408:	53                   	push   %ebx
  800409:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80040c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80040f:	eb 03                	jmp    800414 <strtol+0x11>
		s++;
  800411:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800414:	0f b6 01             	movzbl (%ecx),%eax
  800417:	3c 20                	cmp    $0x20,%al
  800419:	74 f6                	je     800411 <strtol+0xe>
  80041b:	3c 09                	cmp    $0x9,%al
  80041d:	74 f2                	je     800411 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80041f:	3c 2b                	cmp    $0x2b,%al
  800421:	75 0a                	jne    80042d <strtol+0x2a>
		s++;
  800423:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800426:	bf 00 00 00 00       	mov    $0x0,%edi
  80042b:	eb 11                	jmp    80043e <strtol+0x3b>
  80042d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800432:	3c 2d                	cmp    $0x2d,%al
  800434:	75 08                	jne    80043e <strtol+0x3b>
		s++, neg = 1;
  800436:	83 c1 01             	add    $0x1,%ecx
  800439:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80043e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800444:	75 15                	jne    80045b <strtol+0x58>
  800446:	80 39 30             	cmpb   $0x30,(%ecx)
  800449:	75 10                	jne    80045b <strtol+0x58>
  80044b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80044f:	75 7c                	jne    8004cd <strtol+0xca>
		s += 2, base = 16;
  800451:	83 c1 02             	add    $0x2,%ecx
  800454:	bb 10 00 00 00       	mov    $0x10,%ebx
  800459:	eb 16                	jmp    800471 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80045b:	85 db                	test   %ebx,%ebx
  80045d:	75 12                	jne    800471 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80045f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800464:	80 39 30             	cmpb   $0x30,(%ecx)
  800467:	75 08                	jne    800471 <strtol+0x6e>
		s++, base = 8;
  800469:	83 c1 01             	add    $0x1,%ecx
  80046c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800471:	b8 00 00 00 00       	mov    $0x0,%eax
  800476:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800479:	0f b6 11             	movzbl (%ecx),%edx
  80047c:	8d 72 d0             	lea    -0x30(%edx),%esi
  80047f:	89 f3                	mov    %esi,%ebx
  800481:	80 fb 09             	cmp    $0x9,%bl
  800484:	77 08                	ja     80048e <strtol+0x8b>
			dig = *s - '0';
  800486:	0f be d2             	movsbl %dl,%edx
  800489:	83 ea 30             	sub    $0x30,%edx
  80048c:	eb 22                	jmp    8004b0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80048e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800491:	89 f3                	mov    %esi,%ebx
  800493:	80 fb 19             	cmp    $0x19,%bl
  800496:	77 08                	ja     8004a0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800498:	0f be d2             	movsbl %dl,%edx
  80049b:	83 ea 57             	sub    $0x57,%edx
  80049e:	eb 10                	jmp    8004b0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8004a0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8004a3:	89 f3                	mov    %esi,%ebx
  8004a5:	80 fb 19             	cmp    $0x19,%bl
  8004a8:	77 16                	ja     8004c0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8004aa:	0f be d2             	movsbl %dl,%edx
  8004ad:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8004b0:	3b 55 10             	cmp    0x10(%ebp),%edx
  8004b3:	7d 0b                	jge    8004c0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8004b5:	83 c1 01             	add    $0x1,%ecx
  8004b8:	0f af 45 10          	imul   0x10(%ebp),%eax
  8004bc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8004be:	eb b9                	jmp    800479 <strtol+0x76>

	if (endptr)
  8004c0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004c4:	74 0d                	je     8004d3 <strtol+0xd0>
		*endptr = (char *) s;
  8004c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004c9:	89 0e                	mov    %ecx,(%esi)
  8004cb:	eb 06                	jmp    8004d3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8004cd:	85 db                	test   %ebx,%ebx
  8004cf:	74 98                	je     800469 <strtol+0x66>
  8004d1:	eb 9e                	jmp    800471 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8004d3:	89 c2                	mov    %eax,%edx
  8004d5:	f7 da                	neg    %edx
  8004d7:	85 ff                	test   %edi,%edi
  8004d9:	0f 45 c2             	cmovne %edx,%eax
}
  8004dc:	5b                   	pop    %ebx
  8004dd:	5e                   	pop    %esi
  8004de:	5f                   	pop    %edi
  8004df:	5d                   	pop    %ebp
  8004e0:	c3                   	ret    

008004e1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  8004e4:	57                   	push   %edi
  8004e5:	56                   	push   %esi
  8004e6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8004f2:	89 c3                	mov    %eax,%ebx
  8004f4:	89 c7                	mov    %eax,%edi
  8004f6:	89 c6                	mov    %eax,%esi
  8004f8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004fa:	5b                   	pop    %ebx
  8004fb:	5e                   	pop    %esi
  8004fc:	5f                   	pop    %edi
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    

008004ff <sys_cgetc>:

int
sys_cgetc(void)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	57                   	push   %edi
  800503:	56                   	push   %esi
  800504:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800505:	ba 00 00 00 00       	mov    $0x0,%edx
  80050a:	b8 01 00 00 00       	mov    $0x1,%eax
  80050f:	89 d1                	mov    %edx,%ecx
  800511:	89 d3                	mov    %edx,%ebx
  800513:	89 d7                	mov    %edx,%edi
  800515:	89 d6                	mov    %edx,%esi
  800517:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800519:	5b                   	pop    %ebx
  80051a:	5e                   	pop    %esi
  80051b:	5f                   	pop    %edi
  80051c:	5d                   	pop    %ebp
  80051d:	c3                   	ret    

0080051e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80051e:	55                   	push   %ebp
  80051f:	89 e5                	mov    %esp,%ebp
  800521:	57                   	push   %edi
  800522:	56                   	push   %esi
  800523:	53                   	push   %ebx
  800524:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800527:	b9 00 00 00 00       	mov    $0x0,%ecx
  80052c:	b8 03 00 00 00       	mov    $0x3,%eax
  800531:	8b 55 08             	mov    0x8(%ebp),%edx
  800534:	89 cb                	mov    %ecx,%ebx
  800536:	89 cf                	mov    %ecx,%edi
  800538:	89 ce                	mov    %ecx,%esi
  80053a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80053c:	85 c0                	test   %eax,%eax
  80053e:	7e 17                	jle    800557 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800540:	83 ec 0c             	sub    $0xc,%esp
  800543:	50                   	push   %eax
  800544:	6a 03                	push   $0x3
  800546:	68 af 24 80 00       	push   $0x8024af
  80054b:	6a 23                	push   $0x23
  80054d:	68 cc 24 80 00       	push   $0x8024cc
  800552:	e8 94 14 00 00       	call   8019eb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800557:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80055a:	5b                   	pop    %ebx
  80055b:	5e                   	pop    %esi
  80055c:	5f                   	pop    %edi
  80055d:	5d                   	pop    %ebp
  80055e:	c3                   	ret    

0080055f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80055f:	55                   	push   %ebp
  800560:	89 e5                	mov    %esp,%ebp
  800562:	57                   	push   %edi
  800563:	56                   	push   %esi
  800564:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800565:	ba 00 00 00 00       	mov    $0x0,%edx
  80056a:	b8 02 00 00 00       	mov    $0x2,%eax
  80056f:	89 d1                	mov    %edx,%ecx
  800571:	89 d3                	mov    %edx,%ebx
  800573:	89 d7                	mov    %edx,%edi
  800575:	89 d6                	mov    %edx,%esi
  800577:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800579:	5b                   	pop    %ebx
  80057a:	5e                   	pop    %esi
  80057b:	5f                   	pop    %edi
  80057c:	5d                   	pop    %ebp
  80057d:	c3                   	ret    

0080057e <sys_yield>:

void
sys_yield(void)
{
  80057e:	55                   	push   %ebp
  80057f:	89 e5                	mov    %esp,%ebp
  800581:	57                   	push   %edi
  800582:	56                   	push   %esi
  800583:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800584:	ba 00 00 00 00       	mov    $0x0,%edx
  800589:	b8 0b 00 00 00       	mov    $0xb,%eax
  80058e:	89 d1                	mov    %edx,%ecx
  800590:	89 d3                	mov    %edx,%ebx
  800592:	89 d7                	mov    %edx,%edi
  800594:	89 d6                	mov    %edx,%esi
  800596:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800598:	5b                   	pop    %ebx
  800599:	5e                   	pop    %esi
  80059a:	5f                   	pop    %edi
  80059b:	5d                   	pop    %ebp
  80059c:	c3                   	ret    

0080059d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80059d:	55                   	push   %ebp
  80059e:	89 e5                	mov    %esp,%ebp
  8005a0:	57                   	push   %edi
  8005a1:	56                   	push   %esi
  8005a2:	53                   	push   %ebx
  8005a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005a6:	be 00 00 00 00       	mov    $0x0,%esi
  8005ab:	b8 04 00 00 00       	mov    $0x4,%eax
  8005b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8005b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005b9:	89 f7                	mov    %esi,%edi
  8005bb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8005bd:	85 c0                	test   %eax,%eax
  8005bf:	7e 17                	jle    8005d8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	50                   	push   %eax
  8005c5:	6a 04                	push   $0x4
  8005c7:	68 af 24 80 00       	push   $0x8024af
  8005cc:	6a 23                	push   $0x23
  8005ce:	68 cc 24 80 00       	push   $0x8024cc
  8005d3:	e8 13 14 00 00       	call   8019eb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005db:	5b                   	pop    %ebx
  8005dc:	5e                   	pop    %esi
  8005dd:	5f                   	pop    %edi
  8005de:	5d                   	pop    %ebp
  8005df:	c3                   	ret    

008005e0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005e0:	55                   	push   %ebp
  8005e1:	89 e5                	mov    %esp,%ebp
  8005e3:	57                   	push   %edi
  8005e4:	56                   	push   %esi
  8005e5:	53                   	push   %ebx
  8005e6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8005ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005f7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005fa:	8b 75 18             	mov    0x18(%ebp),%esi
  8005fd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8005ff:	85 c0                	test   %eax,%eax
  800601:	7e 17                	jle    80061a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800603:	83 ec 0c             	sub    $0xc,%esp
  800606:	50                   	push   %eax
  800607:	6a 05                	push   $0x5
  800609:	68 af 24 80 00       	push   $0x8024af
  80060e:	6a 23                	push   $0x23
  800610:	68 cc 24 80 00       	push   $0x8024cc
  800615:	e8 d1 13 00 00       	call   8019eb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80061a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061d:	5b                   	pop    %ebx
  80061e:	5e                   	pop    %esi
  80061f:	5f                   	pop    %edi
  800620:	5d                   	pop    %ebp
  800621:	c3                   	ret    

00800622 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800622:	55                   	push   %ebp
  800623:	89 e5                	mov    %esp,%ebp
  800625:	57                   	push   %edi
  800626:	56                   	push   %esi
  800627:	53                   	push   %ebx
  800628:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80062b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800630:	b8 06 00 00 00       	mov    $0x6,%eax
  800635:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800638:	8b 55 08             	mov    0x8(%ebp),%edx
  80063b:	89 df                	mov    %ebx,%edi
  80063d:	89 de                	mov    %ebx,%esi
  80063f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800641:	85 c0                	test   %eax,%eax
  800643:	7e 17                	jle    80065c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800645:	83 ec 0c             	sub    $0xc,%esp
  800648:	50                   	push   %eax
  800649:	6a 06                	push   $0x6
  80064b:	68 af 24 80 00       	push   $0x8024af
  800650:	6a 23                	push   $0x23
  800652:	68 cc 24 80 00       	push   $0x8024cc
  800657:	e8 8f 13 00 00       	call   8019eb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80065c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065f:	5b                   	pop    %ebx
  800660:	5e                   	pop    %esi
  800661:	5f                   	pop    %edi
  800662:	5d                   	pop    %ebp
  800663:	c3                   	ret    

00800664 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800664:	55                   	push   %ebp
  800665:	89 e5                	mov    %esp,%ebp
  800667:	57                   	push   %edi
  800668:	56                   	push   %esi
  800669:	53                   	push   %ebx
  80066a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80066d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800672:	b8 08 00 00 00       	mov    $0x8,%eax
  800677:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80067a:	8b 55 08             	mov    0x8(%ebp),%edx
  80067d:	89 df                	mov    %ebx,%edi
  80067f:	89 de                	mov    %ebx,%esi
  800681:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800683:	85 c0                	test   %eax,%eax
  800685:	7e 17                	jle    80069e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800687:	83 ec 0c             	sub    $0xc,%esp
  80068a:	50                   	push   %eax
  80068b:	6a 08                	push   $0x8
  80068d:	68 af 24 80 00       	push   $0x8024af
  800692:	6a 23                	push   $0x23
  800694:	68 cc 24 80 00       	push   $0x8024cc
  800699:	e8 4d 13 00 00       	call   8019eb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80069e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a1:	5b                   	pop    %ebx
  8006a2:	5e                   	pop    %esi
  8006a3:	5f                   	pop    %edi
  8006a4:	5d                   	pop    %ebp
  8006a5:	c3                   	ret    

008006a6 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8006a6:	55                   	push   %ebp
  8006a7:	89 e5                	mov    %esp,%ebp
  8006a9:	57                   	push   %edi
  8006aa:	56                   	push   %esi
  8006ab:	53                   	push   %ebx
  8006ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b4:	b8 09 00 00 00       	mov    $0x9,%eax
  8006b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8006bf:	89 df                	mov    %ebx,%edi
  8006c1:	89 de                	mov    %ebx,%esi
  8006c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006c5:	85 c0                	test   %eax,%eax
  8006c7:	7e 17                	jle    8006e0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006c9:	83 ec 0c             	sub    $0xc,%esp
  8006cc:	50                   	push   %eax
  8006cd:	6a 09                	push   $0x9
  8006cf:	68 af 24 80 00       	push   $0x8024af
  8006d4:	6a 23                	push   $0x23
  8006d6:	68 cc 24 80 00       	push   $0x8024cc
  8006db:	e8 0b 13 00 00       	call   8019eb <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e3:	5b                   	pop    %ebx
  8006e4:	5e                   	pop    %esi
  8006e5:	5f                   	pop    %edi
  8006e6:	5d                   	pop    %ebp
  8006e7:	c3                   	ret    

008006e8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	57                   	push   %edi
  8006ec:	56                   	push   %esi
  8006ed:	53                   	push   %ebx
  8006ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800701:	89 df                	mov    %ebx,%edi
  800703:	89 de                	mov    %ebx,%esi
  800705:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800707:	85 c0                	test   %eax,%eax
  800709:	7e 17                	jle    800722 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80070b:	83 ec 0c             	sub    $0xc,%esp
  80070e:	50                   	push   %eax
  80070f:	6a 0a                	push   $0xa
  800711:	68 af 24 80 00       	push   $0x8024af
  800716:	6a 23                	push   $0x23
  800718:	68 cc 24 80 00       	push   $0x8024cc
  80071d:	e8 c9 12 00 00       	call   8019eb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800722:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5f                   	pop    %edi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	57                   	push   %edi
  80072e:	56                   	push   %esi
  80072f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800730:	be 00 00 00 00       	mov    $0x0,%esi
  800735:	b8 0c 00 00 00       	mov    $0xc,%eax
  80073a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073d:	8b 55 08             	mov    0x8(%ebp),%edx
  800740:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800743:	8b 7d 14             	mov    0x14(%ebp),%edi
  800746:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800748:	5b                   	pop    %ebx
  800749:	5e                   	pop    %esi
  80074a:	5f                   	pop    %edi
  80074b:	5d                   	pop    %ebp
  80074c:	c3                   	ret    

0080074d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	57                   	push   %edi
  800751:	56                   	push   %esi
  800752:	53                   	push   %ebx
  800753:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800756:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800760:	8b 55 08             	mov    0x8(%ebp),%edx
  800763:	89 cb                	mov    %ecx,%ebx
  800765:	89 cf                	mov    %ecx,%edi
  800767:	89 ce                	mov    %ecx,%esi
  800769:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80076b:	85 c0                	test   %eax,%eax
  80076d:	7e 17                	jle    800786 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80076f:	83 ec 0c             	sub    $0xc,%esp
  800772:	50                   	push   %eax
  800773:	6a 0d                	push   $0xd
  800775:	68 af 24 80 00       	push   $0x8024af
  80077a:	6a 23                	push   $0x23
  80077c:	68 cc 24 80 00       	push   $0x8024cc
  800781:	e8 65 12 00 00       	call   8019eb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800786:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800789:	5b                   	pop    %ebx
  80078a:	5e                   	pop    %esi
  80078b:	5f                   	pop    %edi
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	57                   	push   %edi
  800792:	56                   	push   %esi
  800793:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800794:	b9 00 00 00 00       	mov    $0x0,%ecx
  800799:	b8 0e 00 00 00       	mov    $0xe,%eax
  80079e:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a1:	89 cb                	mov    %ecx,%ebx
  8007a3:	89 cf                	mov    %ecx,%edi
  8007a5:	89 ce                	mov    %ecx,%esi
  8007a7:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  8007a9:	5b                   	pop    %ebx
  8007aa:	5e                   	pop    %esi
  8007ab:	5f                   	pop    %edi
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	57                   	push   %edi
  8007b2:	56                   	push   %esi
  8007b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b9:	b8 0f 00 00 00       	mov    $0xf,%eax
  8007be:	8b 55 08             	mov    0x8(%ebp),%edx
  8007c1:	89 cb                	mov    %ecx,%ebx
  8007c3:	89 cf                	mov    %ecx,%edi
  8007c5:	89 ce                	mov    %ecx,%esi
  8007c7:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8007c9:	5b                   	pop    %ebx
  8007ca:	5e                   	pop    %esi
  8007cb:	5f                   	pop    %edi
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	57                   	push   %edi
  8007d2:	56                   	push   %esi
  8007d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d9:	b8 10 00 00 00       	mov    $0x10,%eax
  8007de:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e1:	89 cb                	mov    %ecx,%ebx
  8007e3:	89 cf                	mov    %ecx,%edi
  8007e5:	89 ce                	mov    %ecx,%esi
  8007e7:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  8007e9:	5b                   	pop    %ebx
  8007ea:	5e                   	pop    %esi
  8007eb:	5f                   	pop    %edi
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	53                   	push   %ebx
  8007f2:	83 ec 04             	sub    $0x4,%esp
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8007f8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8007fa:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8007fe:	74 11                	je     800811 <pgfault+0x23>
  800800:	89 d8                	mov    %ebx,%eax
  800802:	c1 e8 0c             	shr    $0xc,%eax
  800805:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80080c:	f6 c4 08             	test   $0x8,%ah
  80080f:	75 14                	jne    800825 <pgfault+0x37>
		panic("faulting access");
  800811:	83 ec 04             	sub    $0x4,%esp
  800814:	68 da 24 80 00       	push   $0x8024da
  800819:	6a 1f                	push   $0x1f
  80081b:	68 ea 24 80 00       	push   $0x8024ea
  800820:	e8 c6 11 00 00       	call   8019eb <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800825:	83 ec 04             	sub    $0x4,%esp
  800828:	6a 07                	push   $0x7
  80082a:	68 00 f0 7f 00       	push   $0x7ff000
  80082f:	6a 00                	push   $0x0
  800831:	e8 67 fd ff ff       	call   80059d <sys_page_alloc>
	if (r < 0) {
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	85 c0                	test   %eax,%eax
  80083b:	79 12                	jns    80084f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  80083d:	50                   	push   %eax
  80083e:	68 f5 24 80 00       	push   $0x8024f5
  800843:	6a 2d                	push   $0x2d
  800845:	68 ea 24 80 00       	push   $0x8024ea
  80084a:	e8 9c 11 00 00       	call   8019eb <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80084f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800855:	83 ec 04             	sub    $0x4,%esp
  800858:	68 00 10 00 00       	push   $0x1000
  80085d:	53                   	push   %ebx
  80085e:	68 00 f0 7f 00       	push   $0x7ff000
  800863:	e8 2c fb ff ff       	call   800394 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800868:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80086f:	53                   	push   %ebx
  800870:	6a 00                	push   $0x0
  800872:	68 00 f0 7f 00       	push   $0x7ff000
  800877:	6a 00                	push   $0x0
  800879:	e8 62 fd ff ff       	call   8005e0 <sys_page_map>
	if (r < 0) {
  80087e:	83 c4 20             	add    $0x20,%esp
  800881:	85 c0                	test   %eax,%eax
  800883:	79 12                	jns    800897 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800885:	50                   	push   %eax
  800886:	68 f5 24 80 00       	push   $0x8024f5
  80088b:	6a 34                	push   $0x34
  80088d:	68 ea 24 80 00       	push   $0x8024ea
  800892:	e8 54 11 00 00       	call   8019eb <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	68 00 f0 7f 00       	push   $0x7ff000
  80089f:	6a 00                	push   $0x0
  8008a1:	e8 7c fd ff ff       	call   800622 <sys_page_unmap>
	if (r < 0) {
  8008a6:	83 c4 10             	add    $0x10,%esp
  8008a9:	85 c0                	test   %eax,%eax
  8008ab:	79 12                	jns    8008bf <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  8008ad:	50                   	push   %eax
  8008ae:	68 f5 24 80 00       	push   $0x8024f5
  8008b3:	6a 38                	push   $0x38
  8008b5:	68 ea 24 80 00       	push   $0x8024ea
  8008ba:	e8 2c 11 00 00       	call   8019eb <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8008bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c2:	c9                   	leave  
  8008c3:	c3                   	ret    

008008c4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	57                   	push   %edi
  8008c8:	56                   	push   %esi
  8008c9:	53                   	push   %ebx
  8008ca:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8008cd:	68 ee 07 80 00       	push   $0x8007ee
  8008d2:	e8 39 17 00 00       	call   802010 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8008d7:	b8 07 00 00 00       	mov    $0x7,%eax
  8008dc:	cd 30                	int    $0x30
  8008de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	79 17                	jns    8008ff <fork+0x3b>
		panic("fork fault %e");
  8008e8:	83 ec 04             	sub    $0x4,%esp
  8008eb:	68 0e 25 80 00       	push   $0x80250e
  8008f0:	68 85 00 00 00       	push   $0x85
  8008f5:	68 ea 24 80 00       	push   $0x8024ea
  8008fa:	e8 ec 10 00 00       	call   8019eb <_panic>
  8008ff:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800901:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800905:	75 24                	jne    80092b <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800907:	e8 53 fc ff ff       	call   80055f <sys_getenvid>
  80090c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800911:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800917:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80091c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
  800926:	e9 64 01 00 00       	jmp    800a8f <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80092b:	83 ec 04             	sub    $0x4,%esp
  80092e:	6a 07                	push   $0x7
  800930:	68 00 f0 bf ee       	push   $0xeebff000
  800935:	ff 75 e4             	pushl  -0x1c(%ebp)
  800938:	e8 60 fc ff ff       	call   80059d <sys_page_alloc>
  80093d:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800940:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800945:	89 d8                	mov    %ebx,%eax
  800947:	c1 e8 16             	shr    $0x16,%eax
  80094a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800951:	a8 01                	test   $0x1,%al
  800953:	0f 84 fc 00 00 00    	je     800a55 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800959:	89 d8                	mov    %ebx,%eax
  80095b:	c1 e8 0c             	shr    $0xc,%eax
  80095e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800965:	f6 c2 01             	test   $0x1,%dl
  800968:	0f 84 e7 00 00 00    	je     800a55 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80096e:	89 c6                	mov    %eax,%esi
  800970:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800973:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80097a:	f6 c6 04             	test   $0x4,%dh
  80097d:	74 39                	je     8009b8 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80097f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800986:	83 ec 0c             	sub    $0xc,%esp
  800989:	25 07 0e 00 00       	and    $0xe07,%eax
  80098e:	50                   	push   %eax
  80098f:	56                   	push   %esi
  800990:	57                   	push   %edi
  800991:	56                   	push   %esi
  800992:	6a 00                	push   $0x0
  800994:	e8 47 fc ff ff       	call   8005e0 <sys_page_map>
		if (r < 0) {
  800999:	83 c4 20             	add    $0x20,%esp
  80099c:	85 c0                	test   %eax,%eax
  80099e:	0f 89 b1 00 00 00    	jns    800a55 <fork+0x191>
		    	panic("sys page map fault %e");
  8009a4:	83 ec 04             	sub    $0x4,%esp
  8009a7:	68 1c 25 80 00       	push   $0x80251c
  8009ac:	6a 55                	push   $0x55
  8009ae:	68 ea 24 80 00       	push   $0x8024ea
  8009b3:	e8 33 10 00 00       	call   8019eb <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8009b8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8009bf:	f6 c2 02             	test   $0x2,%dl
  8009c2:	75 0c                	jne    8009d0 <fork+0x10c>
  8009c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009cb:	f6 c4 08             	test   $0x8,%ah
  8009ce:	74 5b                	je     800a2b <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8009d0:	83 ec 0c             	sub    $0xc,%esp
  8009d3:	68 05 08 00 00       	push   $0x805
  8009d8:	56                   	push   %esi
  8009d9:	57                   	push   %edi
  8009da:	56                   	push   %esi
  8009db:	6a 00                	push   $0x0
  8009dd:	e8 fe fb ff ff       	call   8005e0 <sys_page_map>
		if (r < 0) {
  8009e2:	83 c4 20             	add    $0x20,%esp
  8009e5:	85 c0                	test   %eax,%eax
  8009e7:	79 14                	jns    8009fd <fork+0x139>
		    	panic("sys page map fault %e");
  8009e9:	83 ec 04             	sub    $0x4,%esp
  8009ec:	68 1c 25 80 00       	push   $0x80251c
  8009f1:	6a 5c                	push   $0x5c
  8009f3:	68 ea 24 80 00       	push   $0x8024ea
  8009f8:	e8 ee 0f 00 00       	call   8019eb <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8009fd:	83 ec 0c             	sub    $0xc,%esp
  800a00:	68 05 08 00 00       	push   $0x805
  800a05:	56                   	push   %esi
  800a06:	6a 00                	push   $0x0
  800a08:	56                   	push   %esi
  800a09:	6a 00                	push   $0x0
  800a0b:	e8 d0 fb ff ff       	call   8005e0 <sys_page_map>
		if (r < 0) {
  800a10:	83 c4 20             	add    $0x20,%esp
  800a13:	85 c0                	test   %eax,%eax
  800a15:	79 3e                	jns    800a55 <fork+0x191>
		    	panic("sys page map fault %e");
  800a17:	83 ec 04             	sub    $0x4,%esp
  800a1a:	68 1c 25 80 00       	push   $0x80251c
  800a1f:	6a 60                	push   $0x60
  800a21:	68 ea 24 80 00       	push   $0x8024ea
  800a26:	e8 c0 0f 00 00       	call   8019eb <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800a2b:	83 ec 0c             	sub    $0xc,%esp
  800a2e:	6a 05                	push   $0x5
  800a30:	56                   	push   %esi
  800a31:	57                   	push   %edi
  800a32:	56                   	push   %esi
  800a33:	6a 00                	push   $0x0
  800a35:	e8 a6 fb ff ff       	call   8005e0 <sys_page_map>
		if (r < 0) {
  800a3a:	83 c4 20             	add    $0x20,%esp
  800a3d:	85 c0                	test   %eax,%eax
  800a3f:	79 14                	jns    800a55 <fork+0x191>
		    	panic("sys page map fault %e");
  800a41:	83 ec 04             	sub    $0x4,%esp
  800a44:	68 1c 25 80 00       	push   $0x80251c
  800a49:	6a 65                	push   $0x65
  800a4b:	68 ea 24 80 00       	push   $0x8024ea
  800a50:	e8 96 0f 00 00       	call   8019eb <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800a55:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800a5b:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800a61:	0f 85 de fe ff ff    	jne    800945 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800a67:	a1 04 40 80 00       	mov    0x804004,%eax
  800a6c:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  800a72:	83 ec 08             	sub    $0x8,%esp
  800a75:	50                   	push   %eax
  800a76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a79:	57                   	push   %edi
  800a7a:	e8 69 fc ff ff       	call   8006e8 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800a7f:	83 c4 08             	add    $0x8,%esp
  800a82:	6a 02                	push   $0x2
  800a84:	57                   	push   %edi
  800a85:	e8 da fb ff ff       	call   800664 <sys_env_set_status>
	
	return envid;
  800a8a:	83 c4 10             	add    $0x10,%esp
  800a8d:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800a8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5f                   	pop    %edi
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <sfork>:

envid_t
sfork(void)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800a9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800aaf:	68 27 01 80 00       	push   $0x800127
  800ab4:	e8 d5 fc ff ff       	call   80078e <sys_thread_create>

	return id;
}
  800ab9:	c9                   	leave  
  800aba:	c3                   	ret    

00800abb <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  800ac1:	ff 75 08             	pushl  0x8(%ebp)
  800ac4:	e8 e5 fc ff ff       	call   8007ae <sys_thread_free>
}
  800ac9:	83 c4 10             	add    $0x10,%esp
  800acc:	c9                   	leave  
  800acd:	c3                   	ret    

00800ace <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  800ad4:	ff 75 08             	pushl  0x8(%ebp)
  800ad7:	e8 f2 fc ff ff       	call   8007ce <sys_thread_join>
}
  800adc:	83 c4 10             	add    $0x10,%esp
  800adf:	c9                   	leave  
  800ae0:	c3                   	ret    

00800ae1 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
  800ae6:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  800aec:	83 ec 04             	sub    $0x4,%esp
  800aef:	6a 07                	push   $0x7
  800af1:	6a 00                	push   $0x0
  800af3:	56                   	push   %esi
  800af4:	e8 a4 fa ff ff       	call   80059d <sys_page_alloc>
	if (r < 0) {
  800af9:	83 c4 10             	add    $0x10,%esp
  800afc:	85 c0                	test   %eax,%eax
  800afe:	79 15                	jns    800b15 <queue_append+0x34>
		panic("%e\n", r);
  800b00:	50                   	push   %eax
  800b01:	68 62 25 80 00       	push   $0x802562
  800b06:	68 d5 00 00 00       	push   $0xd5
  800b0b:	68 ea 24 80 00       	push   $0x8024ea
  800b10:	e8 d6 0e 00 00       	call   8019eb <_panic>
	}	

	wt->envid = envid;
  800b15:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  800b1b:	83 3b 00             	cmpl   $0x0,(%ebx)
  800b1e:	75 13                	jne    800b33 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  800b20:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  800b27:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800b2e:	00 00 00 
  800b31:	eb 1b                	jmp    800b4e <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  800b33:	8b 43 04             	mov    0x4(%ebx),%eax
  800b36:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  800b3d:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800b44:	00 00 00 
		queue->last = wt;
  800b47:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  800b4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	83 ec 08             	sub    $0x8,%esp
  800b5b:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  800b5e:	8b 02                	mov    (%edx),%eax
  800b60:	85 c0                	test   %eax,%eax
  800b62:	75 17                	jne    800b7b <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  800b64:	83 ec 04             	sub    $0x4,%esp
  800b67:	68 32 25 80 00       	push   $0x802532
  800b6c:	68 ec 00 00 00       	push   $0xec
  800b71:	68 ea 24 80 00       	push   $0x8024ea
  800b76:	e8 70 0e 00 00       	call   8019eb <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  800b7b:	8b 48 04             	mov    0x4(%eax),%ecx
  800b7e:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  800b80:	8b 00                	mov    (%eax),%eax
}
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  800b8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b91:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  800b94:	85 c0                	test   %eax,%eax
  800b96:	74 4a                	je     800be2 <mutex_lock+0x5e>
  800b98:	8b 73 04             	mov    0x4(%ebx),%esi
  800b9b:	83 3e 00             	cmpl   $0x0,(%esi)
  800b9e:	75 42                	jne    800be2 <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  800ba0:	e8 ba f9 ff ff       	call   80055f <sys_getenvid>
  800ba5:	83 ec 08             	sub    $0x8,%esp
  800ba8:	56                   	push   %esi
  800ba9:	50                   	push   %eax
  800baa:	e8 32 ff ff ff       	call   800ae1 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  800baf:	e8 ab f9 ff ff       	call   80055f <sys_getenvid>
  800bb4:	83 c4 08             	add    $0x8,%esp
  800bb7:	6a 04                	push   $0x4
  800bb9:	50                   	push   %eax
  800bba:	e8 a5 fa ff ff       	call   800664 <sys_env_set_status>

		if (r < 0) {
  800bbf:	83 c4 10             	add    $0x10,%esp
  800bc2:	85 c0                	test   %eax,%eax
  800bc4:	79 15                	jns    800bdb <mutex_lock+0x57>
			panic("%e\n", r);
  800bc6:	50                   	push   %eax
  800bc7:	68 62 25 80 00       	push   $0x802562
  800bcc:	68 02 01 00 00       	push   $0x102
  800bd1:	68 ea 24 80 00       	push   $0x8024ea
  800bd6:	e8 10 0e 00 00       	call   8019eb <_panic>
		}
		sys_yield();
  800bdb:	e8 9e f9 ff ff       	call   80057e <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  800be0:	eb 08                	jmp    800bea <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  800be2:	e8 78 f9 ff ff       	call   80055f <sys_getenvid>
  800be7:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  800bea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	53                   	push   %ebx
  800bf5:	83 ec 04             	sub    $0x4,%esp
  800bf8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bfb:	b8 00 00 00 00       	mov    $0x0,%eax
  800c00:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  800c03:	8b 43 04             	mov    0x4(%ebx),%eax
  800c06:	83 38 00             	cmpl   $0x0,(%eax)
  800c09:	74 33                	je     800c3e <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	50                   	push   %eax
  800c0f:	e8 41 ff ff ff       	call   800b55 <queue_pop>
  800c14:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  800c17:	83 c4 08             	add    $0x8,%esp
  800c1a:	6a 02                	push   $0x2
  800c1c:	50                   	push   %eax
  800c1d:	e8 42 fa ff ff       	call   800664 <sys_env_set_status>
		if (r < 0) {
  800c22:	83 c4 10             	add    $0x10,%esp
  800c25:	85 c0                	test   %eax,%eax
  800c27:	79 15                	jns    800c3e <mutex_unlock+0x4d>
			panic("%e\n", r);
  800c29:	50                   	push   %eax
  800c2a:	68 62 25 80 00       	push   $0x802562
  800c2f:	68 16 01 00 00       	push   $0x116
  800c34:	68 ea 24 80 00       	push   $0x8024ea
  800c39:	e8 ad 0d 00 00       	call   8019eb <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  800c3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	53                   	push   %ebx
  800c47:	83 ec 04             	sub    $0x4,%esp
  800c4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  800c4d:	e8 0d f9 ff ff       	call   80055f <sys_getenvid>
  800c52:	83 ec 04             	sub    $0x4,%esp
  800c55:	6a 07                	push   $0x7
  800c57:	53                   	push   %ebx
  800c58:	50                   	push   %eax
  800c59:	e8 3f f9 ff ff       	call   80059d <sys_page_alloc>
  800c5e:	83 c4 10             	add    $0x10,%esp
  800c61:	85 c0                	test   %eax,%eax
  800c63:	79 15                	jns    800c7a <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  800c65:	50                   	push   %eax
  800c66:	68 4d 25 80 00       	push   $0x80254d
  800c6b:	68 22 01 00 00       	push   $0x122
  800c70:	68 ea 24 80 00       	push   $0x8024ea
  800c75:	e8 71 0d 00 00       	call   8019eb <_panic>
	}	
	mtx->locked = 0;
  800c7a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  800c80:	8b 43 04             	mov    0x4(%ebx),%eax
  800c83:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  800c89:	8b 43 04             	mov    0x4(%ebx),%eax
  800c8c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  800c93:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  800c9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c9d:	c9                   	leave  
  800c9e:	c3                   	ret    

00800c9f <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 04             	sub    $0x4,%esp
  800ca6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  800ca9:	eb 21                	jmp    800ccc <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	50                   	push   %eax
  800caf:	e8 a1 fe ff ff       	call   800b55 <queue_pop>
  800cb4:	83 c4 08             	add    $0x8,%esp
  800cb7:	6a 02                	push   $0x2
  800cb9:	50                   	push   %eax
  800cba:	e8 a5 f9 ff ff       	call   800664 <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  800cbf:	8b 43 04             	mov    0x4(%ebx),%eax
  800cc2:	8b 10                	mov    (%eax),%edx
  800cc4:	8b 52 04             	mov    0x4(%edx),%edx
  800cc7:	89 10                	mov    %edx,(%eax)
  800cc9:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  800ccc:	8b 43 04             	mov    0x4(%ebx),%eax
  800ccf:	83 38 00             	cmpl   $0x0,(%eax)
  800cd2:	75 d7                	jne    800cab <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  800cd4:	83 ec 04             	sub    $0x4,%esp
  800cd7:	68 00 10 00 00       	push   $0x1000
  800cdc:	6a 00                	push   $0x0
  800cde:	53                   	push   %ebx
  800cdf:	e8 fb f5 ff ff       	call   8002df <memset>
	mtx = NULL;
}
  800ce4:	83 c4 10             	add    $0x10,%esp
  800ce7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cea:	c9                   	leave  
  800ceb:	c3                   	ret    

00800cec <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf2:	05 00 00 00 30       	add    $0x30000000,%eax
  800cf7:	c1 e8 0c             	shr    $0xc,%eax
}
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800cff:	8b 45 08             	mov    0x8(%ebp),%eax
  800d02:	05 00 00 00 30       	add    $0x30000000,%eax
  800d07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d0c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d19:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d1e:	89 c2                	mov    %eax,%edx
  800d20:	c1 ea 16             	shr    $0x16,%edx
  800d23:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d2a:	f6 c2 01             	test   $0x1,%dl
  800d2d:	74 11                	je     800d40 <fd_alloc+0x2d>
  800d2f:	89 c2                	mov    %eax,%edx
  800d31:	c1 ea 0c             	shr    $0xc,%edx
  800d34:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d3b:	f6 c2 01             	test   $0x1,%dl
  800d3e:	75 09                	jne    800d49 <fd_alloc+0x36>
			*fd_store = fd;
  800d40:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d42:	b8 00 00 00 00       	mov    $0x0,%eax
  800d47:	eb 17                	jmp    800d60 <fd_alloc+0x4d>
  800d49:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d4e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d53:	75 c9                	jne    800d1e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d55:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d5b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d68:	83 f8 1f             	cmp    $0x1f,%eax
  800d6b:	77 36                	ja     800da3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d6d:	c1 e0 0c             	shl    $0xc,%eax
  800d70:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d75:	89 c2                	mov    %eax,%edx
  800d77:	c1 ea 16             	shr    $0x16,%edx
  800d7a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d81:	f6 c2 01             	test   $0x1,%dl
  800d84:	74 24                	je     800daa <fd_lookup+0x48>
  800d86:	89 c2                	mov    %eax,%edx
  800d88:	c1 ea 0c             	shr    $0xc,%edx
  800d8b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d92:	f6 c2 01             	test   $0x1,%dl
  800d95:	74 1a                	je     800db1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9a:	89 02                	mov    %eax,(%edx)
	return 0;
  800d9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800da1:	eb 13                	jmp    800db6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800da3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800da8:	eb 0c                	jmp    800db6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800daa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800daf:	eb 05                	jmp    800db6 <fd_lookup+0x54>
  800db1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	83 ec 08             	sub    $0x8,%esp
  800dbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc1:	ba e4 25 80 00       	mov    $0x8025e4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dc6:	eb 13                	jmp    800ddb <dev_lookup+0x23>
  800dc8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800dcb:	39 08                	cmp    %ecx,(%eax)
  800dcd:	75 0c                	jne    800ddb <dev_lookup+0x23>
			*dev = devtab[i];
  800dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd9:	eb 31                	jmp    800e0c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ddb:	8b 02                	mov    (%edx),%eax
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	75 e7                	jne    800dc8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800de1:	a1 04 40 80 00       	mov    0x804004,%eax
  800de6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800dec:	83 ec 04             	sub    $0x4,%esp
  800def:	51                   	push   %ecx
  800df0:	50                   	push   %eax
  800df1:	68 68 25 80 00       	push   $0x802568
  800df6:	e8 c9 0c 00 00       	call   801ac4 <cprintf>
	*dev = 0;
  800dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e04:	83 c4 10             	add    $0x10,%esp
  800e07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e0c:	c9                   	leave  
  800e0d:	c3                   	ret    

00800e0e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	83 ec 10             	sub    $0x10,%esp
  800e16:	8b 75 08             	mov    0x8(%ebp),%esi
  800e19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e1f:	50                   	push   %eax
  800e20:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e26:	c1 e8 0c             	shr    $0xc,%eax
  800e29:	50                   	push   %eax
  800e2a:	e8 33 ff ff ff       	call   800d62 <fd_lookup>
  800e2f:	83 c4 08             	add    $0x8,%esp
  800e32:	85 c0                	test   %eax,%eax
  800e34:	78 05                	js     800e3b <fd_close+0x2d>
	    || fd != fd2)
  800e36:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e39:	74 0c                	je     800e47 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e3b:	84 db                	test   %bl,%bl
  800e3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e42:	0f 44 c2             	cmove  %edx,%eax
  800e45:	eb 41                	jmp    800e88 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e47:	83 ec 08             	sub    $0x8,%esp
  800e4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e4d:	50                   	push   %eax
  800e4e:	ff 36                	pushl  (%esi)
  800e50:	e8 63 ff ff ff       	call   800db8 <dev_lookup>
  800e55:	89 c3                	mov    %eax,%ebx
  800e57:	83 c4 10             	add    $0x10,%esp
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	78 1a                	js     800e78 <fd_close+0x6a>
		if (dev->dev_close)
  800e5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e61:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e64:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	74 0b                	je     800e78 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e6d:	83 ec 0c             	sub    $0xc,%esp
  800e70:	56                   	push   %esi
  800e71:	ff d0                	call   *%eax
  800e73:	89 c3                	mov    %eax,%ebx
  800e75:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e78:	83 ec 08             	sub    $0x8,%esp
  800e7b:	56                   	push   %esi
  800e7c:	6a 00                	push   $0x0
  800e7e:	e8 9f f7 ff ff       	call   800622 <sys_page_unmap>
	return r;
  800e83:	83 c4 10             	add    $0x10,%esp
  800e86:	89 d8                	mov    %ebx,%eax
}
  800e88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e98:	50                   	push   %eax
  800e99:	ff 75 08             	pushl  0x8(%ebp)
  800e9c:	e8 c1 fe ff ff       	call   800d62 <fd_lookup>
  800ea1:	83 c4 08             	add    $0x8,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	78 10                	js     800eb8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	6a 01                	push   $0x1
  800ead:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb0:	e8 59 ff ff ff       	call   800e0e <fd_close>
  800eb5:	83 c4 10             	add    $0x10,%esp
}
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    

00800eba <close_all>:

void
close_all(void)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	53                   	push   %ebx
  800ebe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ec1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ec6:	83 ec 0c             	sub    $0xc,%esp
  800ec9:	53                   	push   %ebx
  800eca:	e8 c0 ff ff ff       	call   800e8f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ecf:	83 c3 01             	add    $0x1,%ebx
  800ed2:	83 c4 10             	add    $0x10,%esp
  800ed5:	83 fb 20             	cmp    $0x20,%ebx
  800ed8:	75 ec                	jne    800ec6 <close_all+0xc>
		close(i);
}
  800eda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
  800ee5:	83 ec 2c             	sub    $0x2c,%esp
  800ee8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800eeb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800eee:	50                   	push   %eax
  800eef:	ff 75 08             	pushl  0x8(%ebp)
  800ef2:	e8 6b fe ff ff       	call   800d62 <fd_lookup>
  800ef7:	83 c4 08             	add    $0x8,%esp
  800efa:	85 c0                	test   %eax,%eax
  800efc:	0f 88 c1 00 00 00    	js     800fc3 <dup+0xe4>
		return r;
	close(newfdnum);
  800f02:	83 ec 0c             	sub    $0xc,%esp
  800f05:	56                   	push   %esi
  800f06:	e8 84 ff ff ff       	call   800e8f <close>

	newfd = INDEX2FD(newfdnum);
  800f0b:	89 f3                	mov    %esi,%ebx
  800f0d:	c1 e3 0c             	shl    $0xc,%ebx
  800f10:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f16:	83 c4 04             	add    $0x4,%esp
  800f19:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f1c:	e8 db fd ff ff       	call   800cfc <fd2data>
  800f21:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f23:	89 1c 24             	mov    %ebx,(%esp)
  800f26:	e8 d1 fd ff ff       	call   800cfc <fd2data>
  800f2b:	83 c4 10             	add    $0x10,%esp
  800f2e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f31:	89 f8                	mov    %edi,%eax
  800f33:	c1 e8 16             	shr    $0x16,%eax
  800f36:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f3d:	a8 01                	test   $0x1,%al
  800f3f:	74 37                	je     800f78 <dup+0x99>
  800f41:	89 f8                	mov    %edi,%eax
  800f43:	c1 e8 0c             	shr    $0xc,%eax
  800f46:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f4d:	f6 c2 01             	test   $0x1,%dl
  800f50:	74 26                	je     800f78 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f52:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f59:	83 ec 0c             	sub    $0xc,%esp
  800f5c:	25 07 0e 00 00       	and    $0xe07,%eax
  800f61:	50                   	push   %eax
  800f62:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f65:	6a 00                	push   $0x0
  800f67:	57                   	push   %edi
  800f68:	6a 00                	push   $0x0
  800f6a:	e8 71 f6 ff ff       	call   8005e0 <sys_page_map>
  800f6f:	89 c7                	mov    %eax,%edi
  800f71:	83 c4 20             	add    $0x20,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	78 2e                	js     800fa6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f78:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f7b:	89 d0                	mov    %edx,%eax
  800f7d:	c1 e8 0c             	shr    $0xc,%eax
  800f80:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f87:	83 ec 0c             	sub    $0xc,%esp
  800f8a:	25 07 0e 00 00       	and    $0xe07,%eax
  800f8f:	50                   	push   %eax
  800f90:	53                   	push   %ebx
  800f91:	6a 00                	push   $0x0
  800f93:	52                   	push   %edx
  800f94:	6a 00                	push   $0x0
  800f96:	e8 45 f6 ff ff       	call   8005e0 <sys_page_map>
  800f9b:	89 c7                	mov    %eax,%edi
  800f9d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fa0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fa2:	85 ff                	test   %edi,%edi
  800fa4:	79 1d                	jns    800fc3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fa6:	83 ec 08             	sub    $0x8,%esp
  800fa9:	53                   	push   %ebx
  800faa:	6a 00                	push   $0x0
  800fac:	e8 71 f6 ff ff       	call   800622 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fb1:	83 c4 08             	add    $0x8,%esp
  800fb4:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 64 f6 ff ff       	call   800622 <sys_page_unmap>
	return r;
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	89 f8                	mov    %edi,%eax
}
  800fc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc6:	5b                   	pop    %ebx
  800fc7:	5e                   	pop    %esi
  800fc8:	5f                   	pop    %edi
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    

00800fcb <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	53                   	push   %ebx
  800fcf:	83 ec 14             	sub    $0x14,%esp
  800fd2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fd5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fd8:	50                   	push   %eax
  800fd9:	53                   	push   %ebx
  800fda:	e8 83 fd ff ff       	call   800d62 <fd_lookup>
  800fdf:	83 c4 08             	add    $0x8,%esp
  800fe2:	89 c2                	mov    %eax,%edx
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	78 70                	js     801058 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fe8:	83 ec 08             	sub    $0x8,%esp
  800feb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fee:	50                   	push   %eax
  800fef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ff2:	ff 30                	pushl  (%eax)
  800ff4:	e8 bf fd ff ff       	call   800db8 <dev_lookup>
  800ff9:	83 c4 10             	add    $0x10,%esp
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	78 4f                	js     80104f <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801000:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801003:	8b 42 08             	mov    0x8(%edx),%eax
  801006:	83 e0 03             	and    $0x3,%eax
  801009:	83 f8 01             	cmp    $0x1,%eax
  80100c:	75 24                	jne    801032 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80100e:	a1 04 40 80 00       	mov    0x804004,%eax
  801013:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801019:	83 ec 04             	sub    $0x4,%esp
  80101c:	53                   	push   %ebx
  80101d:	50                   	push   %eax
  80101e:	68 a9 25 80 00       	push   $0x8025a9
  801023:	e8 9c 0a 00 00       	call   801ac4 <cprintf>
		return -E_INVAL;
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801030:	eb 26                	jmp    801058 <read+0x8d>
	}
	if (!dev->dev_read)
  801032:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801035:	8b 40 08             	mov    0x8(%eax),%eax
  801038:	85 c0                	test   %eax,%eax
  80103a:	74 17                	je     801053 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80103c:	83 ec 04             	sub    $0x4,%esp
  80103f:	ff 75 10             	pushl  0x10(%ebp)
  801042:	ff 75 0c             	pushl  0xc(%ebp)
  801045:	52                   	push   %edx
  801046:	ff d0                	call   *%eax
  801048:	89 c2                	mov    %eax,%edx
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	eb 09                	jmp    801058 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80104f:	89 c2                	mov    %eax,%edx
  801051:	eb 05                	jmp    801058 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801053:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801058:	89 d0                	mov    %edx,%eax
  80105a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80105d:	c9                   	leave  
  80105e:	c3                   	ret    

0080105f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	57                   	push   %edi
  801063:	56                   	push   %esi
  801064:	53                   	push   %ebx
  801065:	83 ec 0c             	sub    $0xc,%esp
  801068:	8b 7d 08             	mov    0x8(%ebp),%edi
  80106b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80106e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801073:	eb 21                	jmp    801096 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801075:	83 ec 04             	sub    $0x4,%esp
  801078:	89 f0                	mov    %esi,%eax
  80107a:	29 d8                	sub    %ebx,%eax
  80107c:	50                   	push   %eax
  80107d:	89 d8                	mov    %ebx,%eax
  80107f:	03 45 0c             	add    0xc(%ebp),%eax
  801082:	50                   	push   %eax
  801083:	57                   	push   %edi
  801084:	e8 42 ff ff ff       	call   800fcb <read>
		if (m < 0)
  801089:	83 c4 10             	add    $0x10,%esp
  80108c:	85 c0                	test   %eax,%eax
  80108e:	78 10                	js     8010a0 <readn+0x41>
			return m;
		if (m == 0)
  801090:	85 c0                	test   %eax,%eax
  801092:	74 0a                	je     80109e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801094:	01 c3                	add    %eax,%ebx
  801096:	39 f3                	cmp    %esi,%ebx
  801098:	72 db                	jb     801075 <readn+0x16>
  80109a:	89 d8                	mov    %ebx,%eax
  80109c:	eb 02                	jmp    8010a0 <readn+0x41>
  80109e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a3:	5b                   	pop    %ebx
  8010a4:	5e                   	pop    %esi
  8010a5:	5f                   	pop    %edi
  8010a6:	5d                   	pop    %ebp
  8010a7:	c3                   	ret    

008010a8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	53                   	push   %ebx
  8010ac:	83 ec 14             	sub    $0x14,%esp
  8010af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	53                   	push   %ebx
  8010b7:	e8 a6 fc ff ff       	call   800d62 <fd_lookup>
  8010bc:	83 c4 08             	add    $0x8,%esp
  8010bf:	89 c2                	mov    %eax,%edx
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	78 6b                	js     801130 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c5:	83 ec 08             	sub    $0x8,%esp
  8010c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010cb:	50                   	push   %eax
  8010cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cf:	ff 30                	pushl  (%eax)
  8010d1:	e8 e2 fc ff ff       	call   800db8 <dev_lookup>
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	78 4a                	js     801127 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010e4:	75 24                	jne    80110a <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010e6:	a1 04 40 80 00       	mov    0x804004,%eax
  8010eb:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8010f1:	83 ec 04             	sub    $0x4,%esp
  8010f4:	53                   	push   %ebx
  8010f5:	50                   	push   %eax
  8010f6:	68 c5 25 80 00       	push   $0x8025c5
  8010fb:	e8 c4 09 00 00       	call   801ac4 <cprintf>
		return -E_INVAL;
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801108:	eb 26                	jmp    801130 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80110a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80110d:	8b 52 0c             	mov    0xc(%edx),%edx
  801110:	85 d2                	test   %edx,%edx
  801112:	74 17                	je     80112b <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801114:	83 ec 04             	sub    $0x4,%esp
  801117:	ff 75 10             	pushl  0x10(%ebp)
  80111a:	ff 75 0c             	pushl  0xc(%ebp)
  80111d:	50                   	push   %eax
  80111e:	ff d2                	call   *%edx
  801120:	89 c2                	mov    %eax,%edx
  801122:	83 c4 10             	add    $0x10,%esp
  801125:	eb 09                	jmp    801130 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801127:	89 c2                	mov    %eax,%edx
  801129:	eb 05                	jmp    801130 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80112b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801130:	89 d0                	mov    %edx,%eax
  801132:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801135:	c9                   	leave  
  801136:	c3                   	ret    

00801137 <seek>:

int
seek(int fdnum, off_t offset)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80113d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801140:	50                   	push   %eax
  801141:	ff 75 08             	pushl  0x8(%ebp)
  801144:	e8 19 fc ff ff       	call   800d62 <fd_lookup>
  801149:	83 c4 08             	add    $0x8,%esp
  80114c:	85 c0                	test   %eax,%eax
  80114e:	78 0e                	js     80115e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801150:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801153:	8b 55 0c             	mov    0xc(%ebp),%edx
  801156:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801159:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80115e:	c9                   	leave  
  80115f:	c3                   	ret    

00801160 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	53                   	push   %ebx
  801164:	83 ec 14             	sub    $0x14,%esp
  801167:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80116a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116d:	50                   	push   %eax
  80116e:	53                   	push   %ebx
  80116f:	e8 ee fb ff ff       	call   800d62 <fd_lookup>
  801174:	83 c4 08             	add    $0x8,%esp
  801177:	89 c2                	mov    %eax,%edx
  801179:	85 c0                	test   %eax,%eax
  80117b:	78 68                	js     8011e5 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117d:	83 ec 08             	sub    $0x8,%esp
  801180:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801183:	50                   	push   %eax
  801184:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801187:	ff 30                	pushl  (%eax)
  801189:	e8 2a fc ff ff       	call   800db8 <dev_lookup>
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	85 c0                	test   %eax,%eax
  801193:	78 47                	js     8011dc <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801195:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801198:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80119c:	75 24                	jne    8011c2 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80119e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011a3:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	53                   	push   %ebx
  8011ad:	50                   	push   %eax
  8011ae:	68 88 25 80 00       	push   $0x802588
  8011b3:	e8 0c 09 00 00       	call   801ac4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011c0:	eb 23                	jmp    8011e5 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8011c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011c5:	8b 52 18             	mov    0x18(%edx),%edx
  8011c8:	85 d2                	test   %edx,%edx
  8011ca:	74 14                	je     8011e0 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011cc:	83 ec 08             	sub    $0x8,%esp
  8011cf:	ff 75 0c             	pushl  0xc(%ebp)
  8011d2:	50                   	push   %eax
  8011d3:	ff d2                	call   *%edx
  8011d5:	89 c2                	mov    %eax,%edx
  8011d7:	83 c4 10             	add    $0x10,%esp
  8011da:	eb 09                	jmp    8011e5 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011dc:	89 c2                	mov    %eax,%edx
  8011de:	eb 05                	jmp    8011e5 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011e5:	89 d0                	mov    %edx,%eax
  8011e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 14             	sub    $0x14,%esp
  8011f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f9:	50                   	push   %eax
  8011fa:	ff 75 08             	pushl  0x8(%ebp)
  8011fd:	e8 60 fb ff ff       	call   800d62 <fd_lookup>
  801202:	83 c4 08             	add    $0x8,%esp
  801205:	89 c2                	mov    %eax,%edx
  801207:	85 c0                	test   %eax,%eax
  801209:	78 58                	js     801263 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120b:	83 ec 08             	sub    $0x8,%esp
  80120e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801211:	50                   	push   %eax
  801212:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801215:	ff 30                	pushl  (%eax)
  801217:	e8 9c fb ff ff       	call   800db8 <dev_lookup>
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	85 c0                	test   %eax,%eax
  801221:	78 37                	js     80125a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801223:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801226:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80122a:	74 32                	je     80125e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80122c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80122f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801236:	00 00 00 
	stat->st_isdir = 0;
  801239:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801240:	00 00 00 
	stat->st_dev = dev;
  801243:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801249:	83 ec 08             	sub    $0x8,%esp
  80124c:	53                   	push   %ebx
  80124d:	ff 75 f0             	pushl  -0x10(%ebp)
  801250:	ff 50 14             	call   *0x14(%eax)
  801253:	89 c2                	mov    %eax,%edx
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	eb 09                	jmp    801263 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	eb 05                	jmp    801263 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80125e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801263:	89 d0                	mov    %edx,%eax
  801265:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801268:	c9                   	leave  
  801269:	c3                   	ret    

0080126a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	56                   	push   %esi
  80126e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80126f:	83 ec 08             	sub    $0x8,%esp
  801272:	6a 00                	push   $0x0
  801274:	ff 75 08             	pushl  0x8(%ebp)
  801277:	e8 e3 01 00 00       	call   80145f <open>
  80127c:	89 c3                	mov    %eax,%ebx
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	78 1b                	js     8012a0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801285:	83 ec 08             	sub    $0x8,%esp
  801288:	ff 75 0c             	pushl  0xc(%ebp)
  80128b:	50                   	push   %eax
  80128c:	e8 5b ff ff ff       	call   8011ec <fstat>
  801291:	89 c6                	mov    %eax,%esi
	close(fd);
  801293:	89 1c 24             	mov    %ebx,(%esp)
  801296:	e8 f4 fb ff ff       	call   800e8f <close>
	return r;
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	89 f0                	mov    %esi,%eax
}
  8012a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a3:	5b                   	pop    %ebx
  8012a4:	5e                   	pop    %esi
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    

008012a7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	56                   	push   %esi
  8012ab:	53                   	push   %ebx
  8012ac:	89 c6                	mov    %eax,%esi
  8012ae:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012b0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012b7:	75 12                	jne    8012cb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012b9:	83 ec 0c             	sub    $0xc,%esp
  8012bc:	6a 01                	push   $0x1
  8012be:	e8 b9 0e 00 00       	call   80217c <ipc_find_env>
  8012c3:	a3 00 40 80 00       	mov    %eax,0x804000
  8012c8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012cb:	6a 07                	push   $0x7
  8012cd:	68 00 50 80 00       	push   $0x805000
  8012d2:	56                   	push   %esi
  8012d3:	ff 35 00 40 80 00    	pushl  0x804000
  8012d9:	e8 3c 0e 00 00       	call   80211a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012de:	83 c4 0c             	add    $0xc,%esp
  8012e1:	6a 00                	push   $0x0
  8012e3:	53                   	push   %ebx
  8012e4:	6a 00                	push   $0x0
  8012e6:	e8 b4 0d 00 00       	call   80209f <ipc_recv>
}
  8012eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ee:	5b                   	pop    %ebx
  8012ef:	5e                   	pop    %esi
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    

008012f2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8012fe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801303:	8b 45 0c             	mov    0xc(%ebp),%eax
  801306:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80130b:	ba 00 00 00 00       	mov    $0x0,%edx
  801310:	b8 02 00 00 00       	mov    $0x2,%eax
  801315:	e8 8d ff ff ff       	call   8012a7 <fsipc>
}
  80131a:	c9                   	leave  
  80131b:	c3                   	ret    

0080131c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801322:	8b 45 08             	mov    0x8(%ebp),%eax
  801325:	8b 40 0c             	mov    0xc(%eax),%eax
  801328:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80132d:	ba 00 00 00 00       	mov    $0x0,%edx
  801332:	b8 06 00 00 00       	mov    $0x6,%eax
  801337:	e8 6b ff ff ff       	call   8012a7 <fsipc>
}
  80133c:	c9                   	leave  
  80133d:	c3                   	ret    

0080133e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	53                   	push   %ebx
  801342:	83 ec 04             	sub    $0x4,%esp
  801345:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801348:	8b 45 08             	mov    0x8(%ebp),%eax
  80134b:	8b 40 0c             	mov    0xc(%eax),%eax
  80134e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801353:	ba 00 00 00 00       	mov    $0x0,%edx
  801358:	b8 05 00 00 00       	mov    $0x5,%eax
  80135d:	e8 45 ff ff ff       	call   8012a7 <fsipc>
  801362:	85 c0                	test   %eax,%eax
  801364:	78 2c                	js     801392 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	68 00 50 80 00       	push   $0x805000
  80136e:	53                   	push   %ebx
  80136f:	e8 26 ee ff ff       	call   80019a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801374:	a1 80 50 80 00       	mov    0x805080,%eax
  801379:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80137f:	a1 84 50 80 00       	mov    0x805084,%eax
  801384:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801392:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801395:	c9                   	leave  
  801396:	c3                   	ret    

00801397 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	83 ec 0c             	sub    $0xc,%esp
  80139d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a3:	8b 52 0c             	mov    0xc(%edx),%edx
  8013a6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8013ac:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013b1:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013b6:	0f 47 c2             	cmova  %edx,%eax
  8013b9:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8013be:	50                   	push   %eax
  8013bf:	ff 75 0c             	pushl  0xc(%ebp)
  8013c2:	68 08 50 80 00       	push   $0x805008
  8013c7:	e8 60 ef ff ff       	call   80032c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8013cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d1:	b8 04 00 00 00       	mov    $0x4,%eax
  8013d6:	e8 cc fe ff ff       	call   8012a7 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8013db:	c9                   	leave  
  8013dc:	c3                   	ret    

008013dd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	56                   	push   %esi
  8013e1:	53                   	push   %ebx
  8013e2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8013eb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013f0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fb:	b8 03 00 00 00       	mov    $0x3,%eax
  801400:	e8 a2 fe ff ff       	call   8012a7 <fsipc>
  801405:	89 c3                	mov    %eax,%ebx
  801407:	85 c0                	test   %eax,%eax
  801409:	78 4b                	js     801456 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80140b:	39 c6                	cmp    %eax,%esi
  80140d:	73 16                	jae    801425 <devfile_read+0x48>
  80140f:	68 f4 25 80 00       	push   $0x8025f4
  801414:	68 fb 25 80 00       	push   $0x8025fb
  801419:	6a 7c                	push   $0x7c
  80141b:	68 10 26 80 00       	push   $0x802610
  801420:	e8 c6 05 00 00       	call   8019eb <_panic>
	assert(r <= PGSIZE);
  801425:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80142a:	7e 16                	jle    801442 <devfile_read+0x65>
  80142c:	68 1b 26 80 00       	push   $0x80261b
  801431:	68 fb 25 80 00       	push   $0x8025fb
  801436:	6a 7d                	push   $0x7d
  801438:	68 10 26 80 00       	push   $0x802610
  80143d:	e8 a9 05 00 00       	call   8019eb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801442:	83 ec 04             	sub    $0x4,%esp
  801445:	50                   	push   %eax
  801446:	68 00 50 80 00       	push   $0x805000
  80144b:	ff 75 0c             	pushl  0xc(%ebp)
  80144e:	e8 d9 ee ff ff       	call   80032c <memmove>
	return r;
  801453:	83 c4 10             	add    $0x10,%esp
}
  801456:	89 d8                	mov    %ebx,%eax
  801458:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145b:	5b                   	pop    %ebx
  80145c:	5e                   	pop    %esi
  80145d:	5d                   	pop    %ebp
  80145e:	c3                   	ret    

0080145f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80145f:	55                   	push   %ebp
  801460:	89 e5                	mov    %esp,%ebp
  801462:	53                   	push   %ebx
  801463:	83 ec 20             	sub    $0x20,%esp
  801466:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801469:	53                   	push   %ebx
  80146a:	e8 f2 ec ff ff       	call   800161 <strlen>
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801477:	7f 67                	jg     8014e0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801479:	83 ec 0c             	sub    $0xc,%esp
  80147c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	e8 8e f8 ff ff       	call   800d13 <fd_alloc>
  801485:	83 c4 10             	add    $0x10,%esp
		return r;
  801488:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 57                	js     8014e5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80148e:	83 ec 08             	sub    $0x8,%esp
  801491:	53                   	push   %ebx
  801492:	68 00 50 80 00       	push   $0x805000
  801497:	e8 fe ec ff ff       	call   80019a <strcpy>
	fsipcbuf.open.req_omode = mode;
  80149c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ac:	e8 f6 fd ff ff       	call   8012a7 <fsipc>
  8014b1:	89 c3                	mov    %eax,%ebx
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	85 c0                	test   %eax,%eax
  8014b8:	79 14                	jns    8014ce <open+0x6f>
		fd_close(fd, 0);
  8014ba:	83 ec 08             	sub    $0x8,%esp
  8014bd:	6a 00                	push   $0x0
  8014bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c2:	e8 47 f9 ff ff       	call   800e0e <fd_close>
		return r;
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	89 da                	mov    %ebx,%edx
  8014cc:	eb 17                	jmp    8014e5 <open+0x86>
	}

	return fd2num(fd);
  8014ce:	83 ec 0c             	sub    $0xc,%esp
  8014d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d4:	e8 13 f8 ff ff       	call   800cec <fd2num>
  8014d9:	89 c2                	mov    %eax,%edx
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	eb 05                	jmp    8014e5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014e0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014e5:	89 d0                	mov    %edx,%eax
  8014e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ea:	c9                   	leave  
  8014eb:	c3                   	ret    

008014ec <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f7:	b8 08 00 00 00       	mov    $0x8,%eax
  8014fc:	e8 a6 fd ff ff       	call   8012a7 <fsipc>
}
  801501:	c9                   	leave  
  801502:	c3                   	ret    

00801503 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	56                   	push   %esi
  801507:	53                   	push   %ebx
  801508:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80150b:	83 ec 0c             	sub    $0xc,%esp
  80150e:	ff 75 08             	pushl  0x8(%ebp)
  801511:	e8 e6 f7 ff ff       	call   800cfc <fd2data>
  801516:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801518:	83 c4 08             	add    $0x8,%esp
  80151b:	68 27 26 80 00       	push   $0x802627
  801520:	53                   	push   %ebx
  801521:	e8 74 ec ff ff       	call   80019a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801526:	8b 46 04             	mov    0x4(%esi),%eax
  801529:	2b 06                	sub    (%esi),%eax
  80152b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801531:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801538:	00 00 00 
	stat->st_dev = &devpipe;
  80153b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801542:	30 80 00 
	return 0;
}
  801545:	b8 00 00 00 00       	mov    $0x0,%eax
  80154a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80154d:	5b                   	pop    %ebx
  80154e:	5e                   	pop    %esi
  80154f:	5d                   	pop    %ebp
  801550:	c3                   	ret    

00801551 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	53                   	push   %ebx
  801555:	83 ec 0c             	sub    $0xc,%esp
  801558:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80155b:	53                   	push   %ebx
  80155c:	6a 00                	push   $0x0
  80155e:	e8 bf f0 ff ff       	call   800622 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801563:	89 1c 24             	mov    %ebx,(%esp)
  801566:	e8 91 f7 ff ff       	call   800cfc <fd2data>
  80156b:	83 c4 08             	add    $0x8,%esp
  80156e:	50                   	push   %eax
  80156f:	6a 00                	push   $0x0
  801571:	e8 ac f0 ff ff       	call   800622 <sys_page_unmap>
}
  801576:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801579:	c9                   	leave  
  80157a:	c3                   	ret    

0080157b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	57                   	push   %edi
  80157f:	56                   	push   %esi
  801580:	53                   	push   %ebx
  801581:	83 ec 1c             	sub    $0x1c,%esp
  801584:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801587:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801589:	a1 04 40 80 00       	mov    0x804004,%eax
  80158e:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801594:	83 ec 0c             	sub    $0xc,%esp
  801597:	ff 75 e0             	pushl  -0x20(%ebp)
  80159a:	e8 22 0c 00 00       	call   8021c1 <pageref>
  80159f:	89 c3                	mov    %eax,%ebx
  8015a1:	89 3c 24             	mov    %edi,(%esp)
  8015a4:	e8 18 0c 00 00       	call   8021c1 <pageref>
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	39 c3                	cmp    %eax,%ebx
  8015ae:	0f 94 c1             	sete   %cl
  8015b1:	0f b6 c9             	movzbl %cl,%ecx
  8015b4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015b7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015bd:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  8015c3:	39 ce                	cmp    %ecx,%esi
  8015c5:	74 1e                	je     8015e5 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8015c7:	39 c3                	cmp    %eax,%ebx
  8015c9:	75 be                	jne    801589 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015cb:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8015d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015d4:	50                   	push   %eax
  8015d5:	56                   	push   %esi
  8015d6:	68 2e 26 80 00       	push   $0x80262e
  8015db:	e8 e4 04 00 00       	call   801ac4 <cprintf>
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	eb a4                	jmp    801589 <_pipeisclosed+0xe>
	}
}
  8015e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015eb:	5b                   	pop    %ebx
  8015ec:	5e                   	pop    %esi
  8015ed:	5f                   	pop    %edi
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    

008015f0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	57                   	push   %edi
  8015f4:	56                   	push   %esi
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 28             	sub    $0x28,%esp
  8015f9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015fc:	56                   	push   %esi
  8015fd:	e8 fa f6 ff ff       	call   800cfc <fd2data>
  801602:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	bf 00 00 00 00       	mov    $0x0,%edi
  80160c:	eb 4b                	jmp    801659 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80160e:	89 da                	mov    %ebx,%edx
  801610:	89 f0                	mov    %esi,%eax
  801612:	e8 64 ff ff ff       	call   80157b <_pipeisclosed>
  801617:	85 c0                	test   %eax,%eax
  801619:	75 48                	jne    801663 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80161b:	e8 5e ef ff ff       	call   80057e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801620:	8b 43 04             	mov    0x4(%ebx),%eax
  801623:	8b 0b                	mov    (%ebx),%ecx
  801625:	8d 51 20             	lea    0x20(%ecx),%edx
  801628:	39 d0                	cmp    %edx,%eax
  80162a:	73 e2                	jae    80160e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80162c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80162f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801633:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801636:	89 c2                	mov    %eax,%edx
  801638:	c1 fa 1f             	sar    $0x1f,%edx
  80163b:	89 d1                	mov    %edx,%ecx
  80163d:	c1 e9 1b             	shr    $0x1b,%ecx
  801640:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801643:	83 e2 1f             	and    $0x1f,%edx
  801646:	29 ca                	sub    %ecx,%edx
  801648:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80164c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801650:	83 c0 01             	add    $0x1,%eax
  801653:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801656:	83 c7 01             	add    $0x1,%edi
  801659:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80165c:	75 c2                	jne    801620 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80165e:	8b 45 10             	mov    0x10(%ebp),%eax
  801661:	eb 05                	jmp    801668 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801663:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801668:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166b:	5b                   	pop    %ebx
  80166c:	5e                   	pop    %esi
  80166d:	5f                   	pop    %edi
  80166e:	5d                   	pop    %ebp
  80166f:	c3                   	ret    

00801670 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	57                   	push   %edi
  801674:	56                   	push   %esi
  801675:	53                   	push   %ebx
  801676:	83 ec 18             	sub    $0x18,%esp
  801679:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80167c:	57                   	push   %edi
  80167d:	e8 7a f6 ff ff       	call   800cfc <fd2data>
  801682:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	bb 00 00 00 00       	mov    $0x0,%ebx
  80168c:	eb 3d                	jmp    8016cb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80168e:	85 db                	test   %ebx,%ebx
  801690:	74 04                	je     801696 <devpipe_read+0x26>
				return i;
  801692:	89 d8                	mov    %ebx,%eax
  801694:	eb 44                	jmp    8016da <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801696:	89 f2                	mov    %esi,%edx
  801698:	89 f8                	mov    %edi,%eax
  80169a:	e8 dc fe ff ff       	call   80157b <_pipeisclosed>
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	75 32                	jne    8016d5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016a3:	e8 d6 ee ff ff       	call   80057e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016a8:	8b 06                	mov    (%esi),%eax
  8016aa:	3b 46 04             	cmp    0x4(%esi),%eax
  8016ad:	74 df                	je     80168e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016af:	99                   	cltd   
  8016b0:	c1 ea 1b             	shr    $0x1b,%edx
  8016b3:	01 d0                	add    %edx,%eax
  8016b5:	83 e0 1f             	and    $0x1f,%eax
  8016b8:	29 d0                	sub    %edx,%eax
  8016ba:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016c5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016c8:	83 c3 01             	add    $0x1,%ebx
  8016cb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016ce:	75 d8                	jne    8016a8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8016d3:	eb 05                	jmp    8016da <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016d5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016dd:	5b                   	pop    %ebx
  8016de:	5e                   	pop    %esi
  8016df:	5f                   	pop    %edi
  8016e0:	5d                   	pop    %ebp
  8016e1:	c3                   	ret    

008016e2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	56                   	push   %esi
  8016e6:	53                   	push   %ebx
  8016e7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ed:	50                   	push   %eax
  8016ee:	e8 20 f6 ff ff       	call   800d13 <fd_alloc>
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	89 c2                	mov    %eax,%edx
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	0f 88 2c 01 00 00    	js     80182c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801700:	83 ec 04             	sub    $0x4,%esp
  801703:	68 07 04 00 00       	push   $0x407
  801708:	ff 75 f4             	pushl  -0xc(%ebp)
  80170b:	6a 00                	push   $0x0
  80170d:	e8 8b ee ff ff       	call   80059d <sys_page_alloc>
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	89 c2                	mov    %eax,%edx
  801717:	85 c0                	test   %eax,%eax
  801719:	0f 88 0d 01 00 00    	js     80182c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80171f:	83 ec 0c             	sub    $0xc,%esp
  801722:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801725:	50                   	push   %eax
  801726:	e8 e8 f5 ff ff       	call   800d13 <fd_alloc>
  80172b:	89 c3                	mov    %eax,%ebx
  80172d:	83 c4 10             	add    $0x10,%esp
  801730:	85 c0                	test   %eax,%eax
  801732:	0f 88 e2 00 00 00    	js     80181a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801738:	83 ec 04             	sub    $0x4,%esp
  80173b:	68 07 04 00 00       	push   $0x407
  801740:	ff 75 f0             	pushl  -0x10(%ebp)
  801743:	6a 00                	push   $0x0
  801745:	e8 53 ee ff ff       	call   80059d <sys_page_alloc>
  80174a:	89 c3                	mov    %eax,%ebx
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	85 c0                	test   %eax,%eax
  801751:	0f 88 c3 00 00 00    	js     80181a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801757:	83 ec 0c             	sub    $0xc,%esp
  80175a:	ff 75 f4             	pushl  -0xc(%ebp)
  80175d:	e8 9a f5 ff ff       	call   800cfc <fd2data>
  801762:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801764:	83 c4 0c             	add    $0xc,%esp
  801767:	68 07 04 00 00       	push   $0x407
  80176c:	50                   	push   %eax
  80176d:	6a 00                	push   $0x0
  80176f:	e8 29 ee ff ff       	call   80059d <sys_page_alloc>
  801774:	89 c3                	mov    %eax,%ebx
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	0f 88 89 00 00 00    	js     80180a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801781:	83 ec 0c             	sub    $0xc,%esp
  801784:	ff 75 f0             	pushl  -0x10(%ebp)
  801787:	e8 70 f5 ff ff       	call   800cfc <fd2data>
  80178c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801793:	50                   	push   %eax
  801794:	6a 00                	push   $0x0
  801796:	56                   	push   %esi
  801797:	6a 00                	push   $0x0
  801799:	e8 42 ee ff ff       	call   8005e0 <sys_page_map>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	83 c4 20             	add    $0x20,%esp
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 55                	js     8017fc <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017a7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017bc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ca:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017d1:	83 ec 0c             	sub    $0xc,%esp
  8017d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d7:	e8 10 f5 ff ff       	call   800cec <fd2num>
  8017dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017df:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017e1:	83 c4 04             	add    $0x4,%esp
  8017e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e7:	e8 00 f5 ff ff       	call   800cec <fd2num>
  8017ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ef:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fa:	eb 30                	jmp    80182c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017fc:	83 ec 08             	sub    $0x8,%esp
  8017ff:	56                   	push   %esi
  801800:	6a 00                	push   $0x0
  801802:	e8 1b ee ff ff       	call   800622 <sys_page_unmap>
  801807:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80180a:	83 ec 08             	sub    $0x8,%esp
  80180d:	ff 75 f0             	pushl  -0x10(%ebp)
  801810:	6a 00                	push   $0x0
  801812:	e8 0b ee ff ff       	call   800622 <sys_page_unmap>
  801817:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	ff 75 f4             	pushl  -0xc(%ebp)
  801820:	6a 00                	push   $0x0
  801822:	e8 fb ed ff ff       	call   800622 <sys_page_unmap>
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80182c:	89 d0                	mov    %edx,%eax
  80182e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801831:	5b                   	pop    %ebx
  801832:	5e                   	pop    %esi
  801833:	5d                   	pop    %ebp
  801834:	c3                   	ret    

00801835 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80183b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183e:	50                   	push   %eax
  80183f:	ff 75 08             	pushl  0x8(%ebp)
  801842:	e8 1b f5 ff ff       	call   800d62 <fd_lookup>
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	85 c0                	test   %eax,%eax
  80184c:	78 18                	js     801866 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80184e:	83 ec 0c             	sub    $0xc,%esp
  801851:	ff 75 f4             	pushl  -0xc(%ebp)
  801854:	e8 a3 f4 ff ff       	call   800cfc <fd2data>
	return _pipeisclosed(fd, p);
  801859:	89 c2                	mov    %eax,%edx
  80185b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185e:	e8 18 fd ff ff       	call   80157b <_pipeisclosed>
  801863:	83 c4 10             	add    $0x10,%esp
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80186b:	b8 00 00 00 00       	mov    $0x0,%eax
  801870:	5d                   	pop    %ebp
  801871:	c3                   	ret    

00801872 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801878:	68 46 26 80 00       	push   $0x802646
  80187d:	ff 75 0c             	pushl  0xc(%ebp)
  801880:	e8 15 e9 ff ff       	call   80019a <strcpy>
	return 0;
}
  801885:	b8 00 00 00 00       	mov    $0x0,%eax
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	57                   	push   %edi
  801890:	56                   	push   %esi
  801891:	53                   	push   %ebx
  801892:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801898:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80189d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018a3:	eb 2d                	jmp    8018d2 <devcons_write+0x46>
		m = n - tot;
  8018a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018a8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018aa:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018ad:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018b2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018b5:	83 ec 04             	sub    $0x4,%esp
  8018b8:	53                   	push   %ebx
  8018b9:	03 45 0c             	add    0xc(%ebp),%eax
  8018bc:	50                   	push   %eax
  8018bd:	57                   	push   %edi
  8018be:	e8 69 ea ff ff       	call   80032c <memmove>
		sys_cputs(buf, m);
  8018c3:	83 c4 08             	add    $0x8,%esp
  8018c6:	53                   	push   %ebx
  8018c7:	57                   	push   %edi
  8018c8:	e8 14 ec ff ff       	call   8004e1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018cd:	01 de                	add    %ebx,%esi
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	89 f0                	mov    %esi,%eax
  8018d4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018d7:	72 cc                	jb     8018a5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018dc:	5b                   	pop    %ebx
  8018dd:	5e                   	pop    %esi
  8018de:	5f                   	pop    %edi
  8018df:	5d                   	pop    %ebp
  8018e0:	c3                   	ret    

008018e1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018e1:	55                   	push   %ebp
  8018e2:	89 e5                	mov    %esp,%ebp
  8018e4:	83 ec 08             	sub    $0x8,%esp
  8018e7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8018ec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018f0:	74 2a                	je     80191c <devcons_read+0x3b>
  8018f2:	eb 05                	jmp    8018f9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018f4:	e8 85 ec ff ff       	call   80057e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018f9:	e8 01 ec ff ff       	call   8004ff <sys_cgetc>
  8018fe:	85 c0                	test   %eax,%eax
  801900:	74 f2                	je     8018f4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801902:	85 c0                	test   %eax,%eax
  801904:	78 16                	js     80191c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801906:	83 f8 04             	cmp    $0x4,%eax
  801909:	74 0c                	je     801917 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80190b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190e:	88 02                	mov    %al,(%edx)
	return 1;
  801910:	b8 01 00 00 00       	mov    $0x1,%eax
  801915:	eb 05                	jmp    80191c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801917:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801924:	8b 45 08             	mov    0x8(%ebp),%eax
  801927:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80192a:	6a 01                	push   $0x1
  80192c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80192f:	50                   	push   %eax
  801930:	e8 ac eb ff ff       	call   8004e1 <sys_cputs>
}
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	c9                   	leave  
  801939:	c3                   	ret    

0080193a <getchar>:

int
getchar(void)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801940:	6a 01                	push   $0x1
  801942:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801945:	50                   	push   %eax
  801946:	6a 00                	push   $0x0
  801948:	e8 7e f6 ff ff       	call   800fcb <read>
	if (r < 0)
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	85 c0                	test   %eax,%eax
  801952:	78 0f                	js     801963 <getchar+0x29>
		return r;
	if (r < 1)
  801954:	85 c0                	test   %eax,%eax
  801956:	7e 06                	jle    80195e <getchar+0x24>
		return -E_EOF;
	return c;
  801958:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80195c:	eb 05                	jmp    801963 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80195e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801963:	c9                   	leave  
  801964:	c3                   	ret    

00801965 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80196b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196e:	50                   	push   %eax
  80196f:	ff 75 08             	pushl  0x8(%ebp)
  801972:	e8 eb f3 ff ff       	call   800d62 <fd_lookup>
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	85 c0                	test   %eax,%eax
  80197c:	78 11                	js     80198f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801981:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801987:	39 10                	cmp    %edx,(%eax)
  801989:	0f 94 c0             	sete   %al
  80198c:	0f b6 c0             	movzbl %al,%eax
}
  80198f:	c9                   	leave  
  801990:	c3                   	ret    

00801991 <opencons>:

int
opencons(void)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801997:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199a:	50                   	push   %eax
  80199b:	e8 73 f3 ff ff       	call   800d13 <fd_alloc>
  8019a0:	83 c4 10             	add    $0x10,%esp
		return r;
  8019a3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	78 3e                	js     8019e7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019a9:	83 ec 04             	sub    $0x4,%esp
  8019ac:	68 07 04 00 00       	push   $0x407
  8019b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b4:	6a 00                	push   $0x0
  8019b6:	e8 e2 eb ff ff       	call   80059d <sys_page_alloc>
  8019bb:	83 c4 10             	add    $0x10,%esp
		return r;
  8019be:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	78 23                	js     8019e7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019c4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019d9:	83 ec 0c             	sub    $0xc,%esp
  8019dc:	50                   	push   %eax
  8019dd:	e8 0a f3 ff ff       	call   800cec <fd2num>
  8019e2:	89 c2                	mov    %eax,%edx
  8019e4:	83 c4 10             	add    $0x10,%esp
}
  8019e7:	89 d0                	mov    %edx,%eax
  8019e9:	c9                   	leave  
  8019ea:	c3                   	ret    

008019eb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	56                   	push   %esi
  8019ef:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019f0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019f3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019f9:	e8 61 eb ff ff       	call   80055f <sys_getenvid>
  8019fe:	83 ec 0c             	sub    $0xc,%esp
  801a01:	ff 75 0c             	pushl  0xc(%ebp)
  801a04:	ff 75 08             	pushl  0x8(%ebp)
  801a07:	56                   	push   %esi
  801a08:	50                   	push   %eax
  801a09:	68 54 26 80 00       	push   $0x802654
  801a0e:	e8 b1 00 00 00       	call   801ac4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a13:	83 c4 18             	add    $0x18,%esp
  801a16:	53                   	push   %ebx
  801a17:	ff 75 10             	pushl  0x10(%ebp)
  801a1a:	e8 54 00 00 00       	call   801a73 <vcprintf>
	cprintf("\n");
  801a1f:	c7 04 24 4b 25 80 00 	movl   $0x80254b,(%esp)
  801a26:	e8 99 00 00 00       	call   801ac4 <cprintf>
  801a2b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a2e:	cc                   	int3   
  801a2f:	eb fd                	jmp    801a2e <_panic+0x43>

00801a31 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	53                   	push   %ebx
  801a35:	83 ec 04             	sub    $0x4,%esp
  801a38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801a3b:	8b 13                	mov    (%ebx),%edx
  801a3d:	8d 42 01             	lea    0x1(%edx),%eax
  801a40:	89 03                	mov    %eax,(%ebx)
  801a42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a45:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801a49:	3d ff 00 00 00       	cmp    $0xff,%eax
  801a4e:	75 1a                	jne    801a6a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801a50:	83 ec 08             	sub    $0x8,%esp
  801a53:	68 ff 00 00 00       	push   $0xff
  801a58:	8d 43 08             	lea    0x8(%ebx),%eax
  801a5b:	50                   	push   %eax
  801a5c:	e8 80 ea ff ff       	call   8004e1 <sys_cputs>
		b->idx = 0;
  801a61:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a67:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801a6a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801a6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a71:	c9                   	leave  
  801a72:	c3                   	ret    

00801a73 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801a7c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a83:	00 00 00 
	b.cnt = 0;
  801a86:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801a8d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801a90:	ff 75 0c             	pushl  0xc(%ebp)
  801a93:	ff 75 08             	pushl  0x8(%ebp)
  801a96:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a9c:	50                   	push   %eax
  801a9d:	68 31 1a 80 00       	push   $0x801a31
  801aa2:	e8 54 01 00 00       	call   801bfb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801aa7:	83 c4 08             	add    $0x8,%esp
  801aaa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801ab0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801ab6:	50                   	push   %eax
  801ab7:	e8 25 ea ff ff       	call   8004e1 <sys_cputs>

	return b.cnt;
}
  801abc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801ac2:	c9                   	leave  
  801ac3:	c3                   	ret    

00801ac4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801aca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801acd:	50                   	push   %eax
  801ace:	ff 75 08             	pushl  0x8(%ebp)
  801ad1:	e8 9d ff ff ff       	call   801a73 <vcprintf>
	va_end(ap);

	return cnt;
}
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	57                   	push   %edi
  801adc:	56                   	push   %esi
  801add:	53                   	push   %ebx
  801ade:	83 ec 1c             	sub    $0x1c,%esp
  801ae1:	89 c7                	mov    %eax,%edi
  801ae3:	89 d6                	mov    %edx,%esi
  801ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aeb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aee:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801af1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801af4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801af9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801afc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801aff:	39 d3                	cmp    %edx,%ebx
  801b01:	72 05                	jb     801b08 <printnum+0x30>
  801b03:	39 45 10             	cmp    %eax,0x10(%ebp)
  801b06:	77 45                	ja     801b4d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801b08:	83 ec 0c             	sub    $0xc,%esp
  801b0b:	ff 75 18             	pushl  0x18(%ebp)
  801b0e:	8b 45 14             	mov    0x14(%ebp),%eax
  801b11:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801b14:	53                   	push   %ebx
  801b15:	ff 75 10             	pushl  0x10(%ebp)
  801b18:	83 ec 08             	sub    $0x8,%esp
  801b1b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b1e:	ff 75 e0             	pushl  -0x20(%ebp)
  801b21:	ff 75 dc             	pushl  -0x24(%ebp)
  801b24:	ff 75 d8             	pushl  -0x28(%ebp)
  801b27:	e8 d4 06 00 00       	call   802200 <__udivdi3>
  801b2c:	83 c4 18             	add    $0x18,%esp
  801b2f:	52                   	push   %edx
  801b30:	50                   	push   %eax
  801b31:	89 f2                	mov    %esi,%edx
  801b33:	89 f8                	mov    %edi,%eax
  801b35:	e8 9e ff ff ff       	call   801ad8 <printnum>
  801b3a:	83 c4 20             	add    $0x20,%esp
  801b3d:	eb 18                	jmp    801b57 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801b3f:	83 ec 08             	sub    $0x8,%esp
  801b42:	56                   	push   %esi
  801b43:	ff 75 18             	pushl  0x18(%ebp)
  801b46:	ff d7                	call   *%edi
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	eb 03                	jmp    801b50 <printnum+0x78>
  801b4d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801b50:	83 eb 01             	sub    $0x1,%ebx
  801b53:	85 db                	test   %ebx,%ebx
  801b55:	7f e8                	jg     801b3f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801b57:	83 ec 08             	sub    $0x8,%esp
  801b5a:	56                   	push   %esi
  801b5b:	83 ec 04             	sub    $0x4,%esp
  801b5e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b61:	ff 75 e0             	pushl  -0x20(%ebp)
  801b64:	ff 75 dc             	pushl  -0x24(%ebp)
  801b67:	ff 75 d8             	pushl  -0x28(%ebp)
  801b6a:	e8 c1 07 00 00       	call   802330 <__umoddi3>
  801b6f:	83 c4 14             	add    $0x14,%esp
  801b72:	0f be 80 77 26 80 00 	movsbl 0x802677(%eax),%eax
  801b79:	50                   	push   %eax
  801b7a:	ff d7                	call   *%edi
}
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5f                   	pop    %edi
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801b8a:	83 fa 01             	cmp    $0x1,%edx
  801b8d:	7e 0e                	jle    801b9d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801b8f:	8b 10                	mov    (%eax),%edx
  801b91:	8d 4a 08             	lea    0x8(%edx),%ecx
  801b94:	89 08                	mov    %ecx,(%eax)
  801b96:	8b 02                	mov    (%edx),%eax
  801b98:	8b 52 04             	mov    0x4(%edx),%edx
  801b9b:	eb 22                	jmp    801bbf <getuint+0x38>
	else if (lflag)
  801b9d:	85 d2                	test   %edx,%edx
  801b9f:	74 10                	je     801bb1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801ba1:	8b 10                	mov    (%eax),%edx
  801ba3:	8d 4a 04             	lea    0x4(%edx),%ecx
  801ba6:	89 08                	mov    %ecx,(%eax)
  801ba8:	8b 02                	mov    (%edx),%eax
  801baa:	ba 00 00 00 00       	mov    $0x0,%edx
  801baf:	eb 0e                	jmp    801bbf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801bb1:	8b 10                	mov    (%eax),%edx
  801bb3:	8d 4a 04             	lea    0x4(%edx),%ecx
  801bb6:	89 08                	mov    %ecx,(%eax)
  801bb8:	8b 02                	mov    (%edx),%eax
  801bba:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801bbf:	5d                   	pop    %ebp
  801bc0:	c3                   	ret    

00801bc1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801bc7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801bcb:	8b 10                	mov    (%eax),%edx
  801bcd:	3b 50 04             	cmp    0x4(%eax),%edx
  801bd0:	73 0a                	jae    801bdc <sprintputch+0x1b>
		*b->buf++ = ch;
  801bd2:	8d 4a 01             	lea    0x1(%edx),%ecx
  801bd5:	89 08                	mov    %ecx,(%eax)
  801bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bda:	88 02                	mov    %al,(%edx)
}
  801bdc:	5d                   	pop    %ebp
  801bdd:	c3                   	ret    

00801bde <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801be4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801be7:	50                   	push   %eax
  801be8:	ff 75 10             	pushl  0x10(%ebp)
  801beb:	ff 75 0c             	pushl  0xc(%ebp)
  801bee:	ff 75 08             	pushl  0x8(%ebp)
  801bf1:	e8 05 00 00 00       	call   801bfb <vprintfmt>
	va_end(ap);
}
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	c9                   	leave  
  801bfa:	c3                   	ret    

00801bfb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	57                   	push   %edi
  801bff:	56                   	push   %esi
  801c00:	53                   	push   %ebx
  801c01:	83 ec 2c             	sub    $0x2c,%esp
  801c04:	8b 75 08             	mov    0x8(%ebp),%esi
  801c07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c0a:	8b 7d 10             	mov    0x10(%ebp),%edi
  801c0d:	eb 12                	jmp    801c21 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	0f 84 89 03 00 00    	je     801fa0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801c17:	83 ec 08             	sub    $0x8,%esp
  801c1a:	53                   	push   %ebx
  801c1b:	50                   	push   %eax
  801c1c:	ff d6                	call   *%esi
  801c1e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801c21:	83 c7 01             	add    $0x1,%edi
  801c24:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801c28:	83 f8 25             	cmp    $0x25,%eax
  801c2b:	75 e2                	jne    801c0f <vprintfmt+0x14>
  801c2d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801c31:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801c38:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801c3f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801c46:	ba 00 00 00 00       	mov    $0x0,%edx
  801c4b:	eb 07                	jmp    801c54 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801c50:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c54:	8d 47 01             	lea    0x1(%edi),%eax
  801c57:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c5a:	0f b6 07             	movzbl (%edi),%eax
  801c5d:	0f b6 c8             	movzbl %al,%ecx
  801c60:	83 e8 23             	sub    $0x23,%eax
  801c63:	3c 55                	cmp    $0x55,%al
  801c65:	0f 87 1a 03 00 00    	ja     801f85 <vprintfmt+0x38a>
  801c6b:	0f b6 c0             	movzbl %al,%eax
  801c6e:	ff 24 85 c0 27 80 00 	jmp    *0x8027c0(,%eax,4)
  801c75:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801c78:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801c7c:	eb d6                	jmp    801c54 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c81:	b8 00 00 00 00       	mov    $0x0,%eax
  801c86:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801c89:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801c8c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801c90:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801c93:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801c96:	83 fa 09             	cmp    $0x9,%edx
  801c99:	77 39                	ja     801cd4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801c9b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801c9e:	eb e9                	jmp    801c89 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801ca0:	8b 45 14             	mov    0x14(%ebp),%eax
  801ca3:	8d 48 04             	lea    0x4(%eax),%ecx
  801ca6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801ca9:	8b 00                	mov    (%eax),%eax
  801cab:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801cb1:	eb 27                	jmp    801cda <vprintfmt+0xdf>
  801cb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  801cbd:	0f 49 c8             	cmovns %eax,%ecx
  801cc0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cc3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801cc6:	eb 8c                	jmp    801c54 <vprintfmt+0x59>
  801cc8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801ccb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801cd2:	eb 80                	jmp    801c54 <vprintfmt+0x59>
  801cd4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801cd7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801cda:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801cde:	0f 89 70 ff ff ff    	jns    801c54 <vprintfmt+0x59>
				width = precision, precision = -1;
  801ce4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801ce7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801cf1:	e9 5e ff ff ff       	jmp    801c54 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801cf6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cf9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801cfc:	e9 53 ff ff ff       	jmp    801c54 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801d01:	8b 45 14             	mov    0x14(%ebp),%eax
  801d04:	8d 50 04             	lea    0x4(%eax),%edx
  801d07:	89 55 14             	mov    %edx,0x14(%ebp)
  801d0a:	83 ec 08             	sub    $0x8,%esp
  801d0d:	53                   	push   %ebx
  801d0e:	ff 30                	pushl  (%eax)
  801d10:	ff d6                	call   *%esi
			break;
  801d12:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d15:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801d18:	e9 04 ff ff ff       	jmp    801c21 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801d1d:	8b 45 14             	mov    0x14(%ebp),%eax
  801d20:	8d 50 04             	lea    0x4(%eax),%edx
  801d23:	89 55 14             	mov    %edx,0x14(%ebp)
  801d26:	8b 00                	mov    (%eax),%eax
  801d28:	99                   	cltd   
  801d29:	31 d0                	xor    %edx,%eax
  801d2b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801d2d:	83 f8 0f             	cmp    $0xf,%eax
  801d30:	7f 0b                	jg     801d3d <vprintfmt+0x142>
  801d32:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  801d39:	85 d2                	test   %edx,%edx
  801d3b:	75 18                	jne    801d55 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801d3d:	50                   	push   %eax
  801d3e:	68 8f 26 80 00       	push   $0x80268f
  801d43:	53                   	push   %ebx
  801d44:	56                   	push   %esi
  801d45:	e8 94 fe ff ff       	call   801bde <printfmt>
  801d4a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801d50:	e9 cc fe ff ff       	jmp    801c21 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801d55:	52                   	push   %edx
  801d56:	68 0d 26 80 00       	push   $0x80260d
  801d5b:	53                   	push   %ebx
  801d5c:	56                   	push   %esi
  801d5d:	e8 7c fe ff ff       	call   801bde <printfmt>
  801d62:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d68:	e9 b4 fe ff ff       	jmp    801c21 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801d6d:	8b 45 14             	mov    0x14(%ebp),%eax
  801d70:	8d 50 04             	lea    0x4(%eax),%edx
  801d73:	89 55 14             	mov    %edx,0x14(%ebp)
  801d76:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801d78:	85 ff                	test   %edi,%edi
  801d7a:	b8 88 26 80 00       	mov    $0x802688,%eax
  801d7f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801d82:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d86:	0f 8e 94 00 00 00    	jle    801e20 <vprintfmt+0x225>
  801d8c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801d90:	0f 84 98 00 00 00    	je     801e2e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801d96:	83 ec 08             	sub    $0x8,%esp
  801d99:	ff 75 d0             	pushl  -0x30(%ebp)
  801d9c:	57                   	push   %edi
  801d9d:	e8 d7 e3 ff ff       	call   800179 <strnlen>
  801da2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801da5:	29 c1                	sub    %eax,%ecx
  801da7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801daa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801dad:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801db1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801db4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801db7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801db9:	eb 0f                	jmp    801dca <vprintfmt+0x1cf>
					putch(padc, putdat);
  801dbb:	83 ec 08             	sub    $0x8,%esp
  801dbe:	53                   	push   %ebx
  801dbf:	ff 75 e0             	pushl  -0x20(%ebp)
  801dc2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801dc4:	83 ef 01             	sub    $0x1,%edi
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	85 ff                	test   %edi,%edi
  801dcc:	7f ed                	jg     801dbb <vprintfmt+0x1c0>
  801dce:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801dd1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801dd4:	85 c9                	test   %ecx,%ecx
  801dd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ddb:	0f 49 c1             	cmovns %ecx,%eax
  801dde:	29 c1                	sub    %eax,%ecx
  801de0:	89 75 08             	mov    %esi,0x8(%ebp)
  801de3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801de6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801de9:	89 cb                	mov    %ecx,%ebx
  801deb:	eb 4d                	jmp    801e3a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801ded:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801df1:	74 1b                	je     801e0e <vprintfmt+0x213>
  801df3:	0f be c0             	movsbl %al,%eax
  801df6:	83 e8 20             	sub    $0x20,%eax
  801df9:	83 f8 5e             	cmp    $0x5e,%eax
  801dfc:	76 10                	jbe    801e0e <vprintfmt+0x213>
					putch('?', putdat);
  801dfe:	83 ec 08             	sub    $0x8,%esp
  801e01:	ff 75 0c             	pushl  0xc(%ebp)
  801e04:	6a 3f                	push   $0x3f
  801e06:	ff 55 08             	call   *0x8(%ebp)
  801e09:	83 c4 10             	add    $0x10,%esp
  801e0c:	eb 0d                	jmp    801e1b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801e0e:	83 ec 08             	sub    $0x8,%esp
  801e11:	ff 75 0c             	pushl  0xc(%ebp)
  801e14:	52                   	push   %edx
  801e15:	ff 55 08             	call   *0x8(%ebp)
  801e18:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801e1b:	83 eb 01             	sub    $0x1,%ebx
  801e1e:	eb 1a                	jmp    801e3a <vprintfmt+0x23f>
  801e20:	89 75 08             	mov    %esi,0x8(%ebp)
  801e23:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801e26:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801e29:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801e2c:	eb 0c                	jmp    801e3a <vprintfmt+0x23f>
  801e2e:	89 75 08             	mov    %esi,0x8(%ebp)
  801e31:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801e34:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801e37:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801e3a:	83 c7 01             	add    $0x1,%edi
  801e3d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801e41:	0f be d0             	movsbl %al,%edx
  801e44:	85 d2                	test   %edx,%edx
  801e46:	74 23                	je     801e6b <vprintfmt+0x270>
  801e48:	85 f6                	test   %esi,%esi
  801e4a:	78 a1                	js     801ded <vprintfmt+0x1f2>
  801e4c:	83 ee 01             	sub    $0x1,%esi
  801e4f:	79 9c                	jns    801ded <vprintfmt+0x1f2>
  801e51:	89 df                	mov    %ebx,%edi
  801e53:	8b 75 08             	mov    0x8(%ebp),%esi
  801e56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e59:	eb 18                	jmp    801e73 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801e5b:	83 ec 08             	sub    $0x8,%esp
  801e5e:	53                   	push   %ebx
  801e5f:	6a 20                	push   $0x20
  801e61:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801e63:	83 ef 01             	sub    $0x1,%edi
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	eb 08                	jmp    801e73 <vprintfmt+0x278>
  801e6b:	89 df                	mov    %ebx,%edi
  801e6d:	8b 75 08             	mov    0x8(%ebp),%esi
  801e70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e73:	85 ff                	test   %edi,%edi
  801e75:	7f e4                	jg     801e5b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e7a:	e9 a2 fd ff ff       	jmp    801c21 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e7f:	83 fa 01             	cmp    $0x1,%edx
  801e82:	7e 16                	jle    801e9a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801e84:	8b 45 14             	mov    0x14(%ebp),%eax
  801e87:	8d 50 08             	lea    0x8(%eax),%edx
  801e8a:	89 55 14             	mov    %edx,0x14(%ebp)
  801e8d:	8b 50 04             	mov    0x4(%eax),%edx
  801e90:	8b 00                	mov    (%eax),%eax
  801e92:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e95:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801e98:	eb 32                	jmp    801ecc <vprintfmt+0x2d1>
	else if (lflag)
  801e9a:	85 d2                	test   %edx,%edx
  801e9c:	74 18                	je     801eb6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801e9e:	8b 45 14             	mov    0x14(%ebp),%eax
  801ea1:	8d 50 04             	lea    0x4(%eax),%edx
  801ea4:	89 55 14             	mov    %edx,0x14(%ebp)
  801ea7:	8b 00                	mov    (%eax),%eax
  801ea9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801eac:	89 c1                	mov    %eax,%ecx
  801eae:	c1 f9 1f             	sar    $0x1f,%ecx
  801eb1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801eb4:	eb 16                	jmp    801ecc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801eb6:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb9:	8d 50 04             	lea    0x4(%eax),%edx
  801ebc:	89 55 14             	mov    %edx,0x14(%ebp)
  801ebf:	8b 00                	mov    (%eax),%eax
  801ec1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ec4:	89 c1                	mov    %eax,%ecx
  801ec6:	c1 f9 1f             	sar    $0x1f,%ecx
  801ec9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801ecc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ecf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801ed2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801ed7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801edb:	79 74                	jns    801f51 <vprintfmt+0x356>
				putch('-', putdat);
  801edd:	83 ec 08             	sub    $0x8,%esp
  801ee0:	53                   	push   %ebx
  801ee1:	6a 2d                	push   $0x2d
  801ee3:	ff d6                	call   *%esi
				num = -(long long) num;
  801ee5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ee8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801eeb:	f7 d8                	neg    %eax
  801eed:	83 d2 00             	adc    $0x0,%edx
  801ef0:	f7 da                	neg    %edx
  801ef2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ef5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801efa:	eb 55                	jmp    801f51 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801efc:	8d 45 14             	lea    0x14(%ebp),%eax
  801eff:	e8 83 fc ff ff       	call   801b87 <getuint>
			base = 10;
  801f04:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801f09:	eb 46                	jmp    801f51 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801f0b:	8d 45 14             	lea    0x14(%ebp),%eax
  801f0e:	e8 74 fc ff ff       	call   801b87 <getuint>
			base = 8;
  801f13:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801f18:	eb 37                	jmp    801f51 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801f1a:	83 ec 08             	sub    $0x8,%esp
  801f1d:	53                   	push   %ebx
  801f1e:	6a 30                	push   $0x30
  801f20:	ff d6                	call   *%esi
			putch('x', putdat);
  801f22:	83 c4 08             	add    $0x8,%esp
  801f25:	53                   	push   %ebx
  801f26:	6a 78                	push   $0x78
  801f28:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801f2a:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2d:	8d 50 04             	lea    0x4(%eax),%edx
  801f30:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801f33:	8b 00                	mov    (%eax),%eax
  801f35:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801f3a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801f3d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801f42:	eb 0d                	jmp    801f51 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801f44:	8d 45 14             	lea    0x14(%ebp),%eax
  801f47:	e8 3b fc ff ff       	call   801b87 <getuint>
			base = 16;
  801f4c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801f51:	83 ec 0c             	sub    $0xc,%esp
  801f54:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801f58:	57                   	push   %edi
  801f59:	ff 75 e0             	pushl  -0x20(%ebp)
  801f5c:	51                   	push   %ecx
  801f5d:	52                   	push   %edx
  801f5e:	50                   	push   %eax
  801f5f:	89 da                	mov    %ebx,%edx
  801f61:	89 f0                	mov    %esi,%eax
  801f63:	e8 70 fb ff ff       	call   801ad8 <printnum>
			break;
  801f68:	83 c4 20             	add    $0x20,%esp
  801f6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f6e:	e9 ae fc ff ff       	jmp    801c21 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801f73:	83 ec 08             	sub    $0x8,%esp
  801f76:	53                   	push   %ebx
  801f77:	51                   	push   %ecx
  801f78:	ff d6                	call   *%esi
			break;
  801f7a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801f80:	e9 9c fc ff ff       	jmp    801c21 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801f85:	83 ec 08             	sub    $0x8,%esp
  801f88:	53                   	push   %ebx
  801f89:	6a 25                	push   $0x25
  801f8b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801f8d:	83 c4 10             	add    $0x10,%esp
  801f90:	eb 03                	jmp    801f95 <vprintfmt+0x39a>
  801f92:	83 ef 01             	sub    $0x1,%edi
  801f95:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801f99:	75 f7                	jne    801f92 <vprintfmt+0x397>
  801f9b:	e9 81 fc ff ff       	jmp    801c21 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801fa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa3:	5b                   	pop    %ebx
  801fa4:	5e                   	pop    %esi
  801fa5:	5f                   	pop    %edi
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    

00801fa8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	83 ec 18             	sub    $0x18,%esp
  801fae:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801fb4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801fb7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801fbb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801fbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	74 26                	je     801fef <vsnprintf+0x47>
  801fc9:	85 d2                	test   %edx,%edx
  801fcb:	7e 22                	jle    801fef <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801fcd:	ff 75 14             	pushl  0x14(%ebp)
  801fd0:	ff 75 10             	pushl  0x10(%ebp)
  801fd3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801fd6:	50                   	push   %eax
  801fd7:	68 c1 1b 80 00       	push   $0x801bc1
  801fdc:	e8 1a fc ff ff       	call   801bfb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801fe1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801fe4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	eb 05                	jmp    801ff4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801fef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801ff4:	c9                   	leave  
  801ff5:	c3                   	ret    

00801ff6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ff6:	55                   	push   %ebp
  801ff7:	89 e5                	mov    %esp,%ebp
  801ff9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801ffc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801fff:	50                   	push   %eax
  802000:	ff 75 10             	pushl  0x10(%ebp)
  802003:	ff 75 0c             	pushl  0xc(%ebp)
  802006:	ff 75 08             	pushl  0x8(%ebp)
  802009:	e8 9a ff ff ff       	call   801fa8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80200e:	c9                   	leave  
  80200f:	c3                   	ret    

00802010 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
  802013:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802016:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80201d:	75 2a                	jne    802049 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80201f:	83 ec 04             	sub    $0x4,%esp
  802022:	6a 07                	push   $0x7
  802024:	68 00 f0 bf ee       	push   $0xeebff000
  802029:	6a 00                	push   $0x0
  80202b:	e8 6d e5 ff ff       	call   80059d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802030:	83 c4 10             	add    $0x10,%esp
  802033:	85 c0                	test   %eax,%eax
  802035:	79 12                	jns    802049 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802037:	50                   	push   %eax
  802038:	68 62 25 80 00       	push   $0x802562
  80203d:	6a 23                	push   $0x23
  80203f:	68 80 29 80 00       	push   $0x802980
  802044:	e8 a2 f9 ff ff       	call   8019eb <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802049:	8b 45 08             	mov    0x8(%ebp),%eax
  80204c:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802051:	83 ec 08             	sub    $0x8,%esp
  802054:	68 7b 20 80 00       	push   $0x80207b
  802059:	6a 00                	push   $0x0
  80205b:	e8 88 e6 ff ff       	call   8006e8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802060:	83 c4 10             	add    $0x10,%esp
  802063:	85 c0                	test   %eax,%eax
  802065:	79 12                	jns    802079 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802067:	50                   	push   %eax
  802068:	68 62 25 80 00       	push   $0x802562
  80206d:	6a 2c                	push   $0x2c
  80206f:	68 80 29 80 00       	push   $0x802980
  802074:	e8 72 f9 ff ff       	call   8019eb <_panic>
	}
}
  802079:	c9                   	leave  
  80207a:	c3                   	ret    

0080207b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80207b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80207c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802081:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802083:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802086:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80208a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80208f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802093:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802095:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802098:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802099:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80209c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80209d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80209e:	c3                   	ret    

0080209f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80209f:	55                   	push   %ebp
  8020a0:	89 e5                	mov    %esp,%ebp
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8020a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	75 12                	jne    8020c3 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8020b1:	83 ec 0c             	sub    $0xc,%esp
  8020b4:	68 00 00 c0 ee       	push   $0xeec00000
  8020b9:	e8 8f e6 ff ff       	call   80074d <sys_ipc_recv>
  8020be:	83 c4 10             	add    $0x10,%esp
  8020c1:	eb 0c                	jmp    8020cf <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020c3:	83 ec 0c             	sub    $0xc,%esp
  8020c6:	50                   	push   %eax
  8020c7:	e8 81 e6 ff ff       	call   80074d <sys_ipc_recv>
  8020cc:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020cf:	85 f6                	test   %esi,%esi
  8020d1:	0f 95 c1             	setne  %cl
  8020d4:	85 db                	test   %ebx,%ebx
  8020d6:	0f 95 c2             	setne  %dl
  8020d9:	84 d1                	test   %dl,%cl
  8020db:	74 09                	je     8020e6 <ipc_recv+0x47>
  8020dd:	89 c2                	mov    %eax,%edx
  8020df:	c1 ea 1f             	shr    $0x1f,%edx
  8020e2:	84 d2                	test   %dl,%dl
  8020e4:	75 2d                	jne    802113 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020e6:	85 f6                	test   %esi,%esi
  8020e8:	74 0d                	je     8020f7 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ef:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8020f5:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020f7:	85 db                	test   %ebx,%ebx
  8020f9:	74 0d                	je     802108 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020fb:	a1 04 40 80 00       	mov    0x804004,%eax
  802100:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802106:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802108:	a1 04 40 80 00       	mov    0x804004,%eax
  80210d:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802113:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802116:	5b                   	pop    %ebx
  802117:	5e                   	pop    %esi
  802118:	5d                   	pop    %ebp
  802119:	c3                   	ret    

0080211a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80211a:	55                   	push   %ebp
  80211b:	89 e5                	mov    %esp,%ebp
  80211d:	57                   	push   %edi
  80211e:	56                   	push   %esi
  80211f:	53                   	push   %ebx
  802120:	83 ec 0c             	sub    $0xc,%esp
  802123:	8b 7d 08             	mov    0x8(%ebp),%edi
  802126:	8b 75 0c             	mov    0xc(%ebp),%esi
  802129:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80212c:	85 db                	test   %ebx,%ebx
  80212e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802133:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802136:	ff 75 14             	pushl  0x14(%ebp)
  802139:	53                   	push   %ebx
  80213a:	56                   	push   %esi
  80213b:	57                   	push   %edi
  80213c:	e8 e9 e5 ff ff       	call   80072a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802141:	89 c2                	mov    %eax,%edx
  802143:	c1 ea 1f             	shr    $0x1f,%edx
  802146:	83 c4 10             	add    $0x10,%esp
  802149:	84 d2                	test   %dl,%dl
  80214b:	74 17                	je     802164 <ipc_send+0x4a>
  80214d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802150:	74 12                	je     802164 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802152:	50                   	push   %eax
  802153:	68 8e 29 80 00       	push   $0x80298e
  802158:	6a 47                	push   $0x47
  80215a:	68 9c 29 80 00       	push   $0x80299c
  80215f:	e8 87 f8 ff ff       	call   8019eb <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802164:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802167:	75 07                	jne    802170 <ipc_send+0x56>
			sys_yield();
  802169:	e8 10 e4 ff ff       	call   80057e <sys_yield>
  80216e:	eb c6                	jmp    802136 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802170:	85 c0                	test   %eax,%eax
  802172:	75 c2                	jne    802136 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802174:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802177:	5b                   	pop    %ebx
  802178:	5e                   	pop    %esi
  802179:	5f                   	pop    %edi
  80217a:	5d                   	pop    %ebp
  80217b:	c3                   	ret    

0080217c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
  80217f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802182:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802187:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  80218d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802193:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802199:	39 ca                	cmp    %ecx,%edx
  80219b:	75 13                	jne    8021b0 <ipc_find_env+0x34>
			return envs[i].env_id;
  80219d:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8021a3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021a8:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8021ae:	eb 0f                	jmp    8021bf <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021b0:	83 c0 01             	add    $0x1,%eax
  8021b3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021b8:	75 cd                	jne    802187 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021bf:	5d                   	pop    %ebp
  8021c0:	c3                   	ret    

008021c1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021c1:	55                   	push   %ebp
  8021c2:	89 e5                	mov    %esp,%ebp
  8021c4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021c7:	89 d0                	mov    %edx,%eax
  8021c9:	c1 e8 16             	shr    $0x16,%eax
  8021cc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021d3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021d8:	f6 c1 01             	test   $0x1,%cl
  8021db:	74 1d                	je     8021fa <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021dd:	c1 ea 0c             	shr    $0xc,%edx
  8021e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021e7:	f6 c2 01             	test   $0x1,%dl
  8021ea:	74 0e                	je     8021fa <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021ec:	c1 ea 0c             	shr    $0xc,%edx
  8021ef:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021f6:	ef 
  8021f7:	0f b7 c0             	movzwl %ax,%eax
}
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__udivdi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80220b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80220f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 f6                	test   %esi,%esi
  802219:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80221d:	89 ca                	mov    %ecx,%edx
  80221f:	89 f8                	mov    %edi,%eax
  802221:	75 3d                	jne    802260 <__udivdi3+0x60>
  802223:	39 cf                	cmp    %ecx,%edi
  802225:	0f 87 c5 00 00 00    	ja     8022f0 <__udivdi3+0xf0>
  80222b:	85 ff                	test   %edi,%edi
  80222d:	89 fd                	mov    %edi,%ebp
  80222f:	75 0b                	jne    80223c <__udivdi3+0x3c>
  802231:	b8 01 00 00 00       	mov    $0x1,%eax
  802236:	31 d2                	xor    %edx,%edx
  802238:	f7 f7                	div    %edi
  80223a:	89 c5                	mov    %eax,%ebp
  80223c:	89 c8                	mov    %ecx,%eax
  80223e:	31 d2                	xor    %edx,%edx
  802240:	f7 f5                	div    %ebp
  802242:	89 c1                	mov    %eax,%ecx
  802244:	89 d8                	mov    %ebx,%eax
  802246:	89 cf                	mov    %ecx,%edi
  802248:	f7 f5                	div    %ebp
  80224a:	89 c3                	mov    %eax,%ebx
  80224c:	89 d8                	mov    %ebx,%eax
  80224e:	89 fa                	mov    %edi,%edx
  802250:	83 c4 1c             	add    $0x1c,%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    
  802258:	90                   	nop
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	39 ce                	cmp    %ecx,%esi
  802262:	77 74                	ja     8022d8 <__udivdi3+0xd8>
  802264:	0f bd fe             	bsr    %esi,%edi
  802267:	83 f7 1f             	xor    $0x1f,%edi
  80226a:	0f 84 98 00 00 00    	je     802308 <__udivdi3+0x108>
  802270:	bb 20 00 00 00       	mov    $0x20,%ebx
  802275:	89 f9                	mov    %edi,%ecx
  802277:	89 c5                	mov    %eax,%ebp
  802279:	29 fb                	sub    %edi,%ebx
  80227b:	d3 e6                	shl    %cl,%esi
  80227d:	89 d9                	mov    %ebx,%ecx
  80227f:	d3 ed                	shr    %cl,%ebp
  802281:	89 f9                	mov    %edi,%ecx
  802283:	d3 e0                	shl    %cl,%eax
  802285:	09 ee                	or     %ebp,%esi
  802287:	89 d9                	mov    %ebx,%ecx
  802289:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80228d:	89 d5                	mov    %edx,%ebp
  80228f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802293:	d3 ed                	shr    %cl,%ebp
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e2                	shl    %cl,%edx
  802299:	89 d9                	mov    %ebx,%ecx
  80229b:	d3 e8                	shr    %cl,%eax
  80229d:	09 c2                	or     %eax,%edx
  80229f:	89 d0                	mov    %edx,%eax
  8022a1:	89 ea                	mov    %ebp,%edx
  8022a3:	f7 f6                	div    %esi
  8022a5:	89 d5                	mov    %edx,%ebp
  8022a7:	89 c3                	mov    %eax,%ebx
  8022a9:	f7 64 24 0c          	mull   0xc(%esp)
  8022ad:	39 d5                	cmp    %edx,%ebp
  8022af:	72 10                	jb     8022c1 <__udivdi3+0xc1>
  8022b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	d3 e6                	shl    %cl,%esi
  8022b9:	39 c6                	cmp    %eax,%esi
  8022bb:	73 07                	jae    8022c4 <__udivdi3+0xc4>
  8022bd:	39 d5                	cmp    %edx,%ebp
  8022bf:	75 03                	jne    8022c4 <__udivdi3+0xc4>
  8022c1:	83 eb 01             	sub    $0x1,%ebx
  8022c4:	31 ff                	xor    %edi,%edi
  8022c6:	89 d8                	mov    %ebx,%eax
  8022c8:	89 fa                	mov    %edi,%edx
  8022ca:	83 c4 1c             	add    $0x1c,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5f                   	pop    %edi
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    
  8022d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d8:	31 ff                	xor    %edi,%edi
  8022da:	31 db                	xor    %ebx,%ebx
  8022dc:	89 d8                	mov    %ebx,%eax
  8022de:	89 fa                	mov    %edi,%edx
  8022e0:	83 c4 1c             	add    $0x1c,%esp
  8022e3:	5b                   	pop    %ebx
  8022e4:	5e                   	pop    %esi
  8022e5:	5f                   	pop    %edi
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    
  8022e8:	90                   	nop
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	89 d8                	mov    %ebx,%eax
  8022f2:	f7 f7                	div    %edi
  8022f4:	31 ff                	xor    %edi,%edi
  8022f6:	89 c3                	mov    %eax,%ebx
  8022f8:	89 d8                	mov    %ebx,%eax
  8022fa:	89 fa                	mov    %edi,%edx
  8022fc:	83 c4 1c             	add    $0x1c,%esp
  8022ff:	5b                   	pop    %ebx
  802300:	5e                   	pop    %esi
  802301:	5f                   	pop    %edi
  802302:	5d                   	pop    %ebp
  802303:	c3                   	ret    
  802304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802308:	39 ce                	cmp    %ecx,%esi
  80230a:	72 0c                	jb     802318 <__udivdi3+0x118>
  80230c:	31 db                	xor    %ebx,%ebx
  80230e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802312:	0f 87 34 ff ff ff    	ja     80224c <__udivdi3+0x4c>
  802318:	bb 01 00 00 00       	mov    $0x1,%ebx
  80231d:	e9 2a ff ff ff       	jmp    80224c <__udivdi3+0x4c>
  802322:	66 90                	xchg   %ax,%ax
  802324:	66 90                	xchg   %ax,%ax
  802326:	66 90                	xchg   %ax,%ax
  802328:	66 90                	xchg   %ax,%ax
  80232a:	66 90                	xchg   %ax,%ax
  80232c:	66 90                	xchg   %ax,%ax
  80232e:	66 90                	xchg   %ax,%ax

00802330 <__umoddi3>:
  802330:	55                   	push   %ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	53                   	push   %ebx
  802334:	83 ec 1c             	sub    $0x1c,%esp
  802337:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80233b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80233f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802343:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802347:	85 d2                	test   %edx,%edx
  802349:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80234d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802351:	89 f3                	mov    %esi,%ebx
  802353:	89 3c 24             	mov    %edi,(%esp)
  802356:	89 74 24 04          	mov    %esi,0x4(%esp)
  80235a:	75 1c                	jne    802378 <__umoddi3+0x48>
  80235c:	39 f7                	cmp    %esi,%edi
  80235e:	76 50                	jbe    8023b0 <__umoddi3+0x80>
  802360:	89 c8                	mov    %ecx,%eax
  802362:	89 f2                	mov    %esi,%edx
  802364:	f7 f7                	div    %edi
  802366:	89 d0                	mov    %edx,%eax
  802368:	31 d2                	xor    %edx,%edx
  80236a:	83 c4 1c             	add    $0x1c,%esp
  80236d:	5b                   	pop    %ebx
  80236e:	5e                   	pop    %esi
  80236f:	5f                   	pop    %edi
  802370:	5d                   	pop    %ebp
  802371:	c3                   	ret    
  802372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802378:	39 f2                	cmp    %esi,%edx
  80237a:	89 d0                	mov    %edx,%eax
  80237c:	77 52                	ja     8023d0 <__umoddi3+0xa0>
  80237e:	0f bd ea             	bsr    %edx,%ebp
  802381:	83 f5 1f             	xor    $0x1f,%ebp
  802384:	75 5a                	jne    8023e0 <__umoddi3+0xb0>
  802386:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80238a:	0f 82 e0 00 00 00    	jb     802470 <__umoddi3+0x140>
  802390:	39 0c 24             	cmp    %ecx,(%esp)
  802393:	0f 86 d7 00 00 00    	jbe    802470 <__umoddi3+0x140>
  802399:	8b 44 24 08          	mov    0x8(%esp),%eax
  80239d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023a1:	83 c4 1c             	add    $0x1c,%esp
  8023a4:	5b                   	pop    %ebx
  8023a5:	5e                   	pop    %esi
  8023a6:	5f                   	pop    %edi
  8023a7:	5d                   	pop    %ebp
  8023a8:	c3                   	ret    
  8023a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	85 ff                	test   %edi,%edi
  8023b2:	89 fd                	mov    %edi,%ebp
  8023b4:	75 0b                	jne    8023c1 <__umoddi3+0x91>
  8023b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023bb:	31 d2                	xor    %edx,%edx
  8023bd:	f7 f7                	div    %edi
  8023bf:	89 c5                	mov    %eax,%ebp
  8023c1:	89 f0                	mov    %esi,%eax
  8023c3:	31 d2                	xor    %edx,%edx
  8023c5:	f7 f5                	div    %ebp
  8023c7:	89 c8                	mov    %ecx,%eax
  8023c9:	f7 f5                	div    %ebp
  8023cb:	89 d0                	mov    %edx,%eax
  8023cd:	eb 99                	jmp    802368 <__umoddi3+0x38>
  8023cf:	90                   	nop
  8023d0:	89 c8                	mov    %ecx,%eax
  8023d2:	89 f2                	mov    %esi,%edx
  8023d4:	83 c4 1c             	add    $0x1c,%esp
  8023d7:	5b                   	pop    %ebx
  8023d8:	5e                   	pop    %esi
  8023d9:	5f                   	pop    %edi
  8023da:	5d                   	pop    %ebp
  8023db:	c3                   	ret    
  8023dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	8b 34 24             	mov    (%esp),%esi
  8023e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023e8:	89 e9                	mov    %ebp,%ecx
  8023ea:	29 ef                	sub    %ebp,%edi
  8023ec:	d3 e0                	shl    %cl,%eax
  8023ee:	89 f9                	mov    %edi,%ecx
  8023f0:	89 f2                	mov    %esi,%edx
  8023f2:	d3 ea                	shr    %cl,%edx
  8023f4:	89 e9                	mov    %ebp,%ecx
  8023f6:	09 c2                	or     %eax,%edx
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	89 14 24             	mov    %edx,(%esp)
  8023fd:	89 f2                	mov    %esi,%edx
  8023ff:	d3 e2                	shl    %cl,%edx
  802401:	89 f9                	mov    %edi,%ecx
  802403:	89 54 24 04          	mov    %edx,0x4(%esp)
  802407:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80240b:	d3 e8                	shr    %cl,%eax
  80240d:	89 e9                	mov    %ebp,%ecx
  80240f:	89 c6                	mov    %eax,%esi
  802411:	d3 e3                	shl    %cl,%ebx
  802413:	89 f9                	mov    %edi,%ecx
  802415:	89 d0                	mov    %edx,%eax
  802417:	d3 e8                	shr    %cl,%eax
  802419:	89 e9                	mov    %ebp,%ecx
  80241b:	09 d8                	or     %ebx,%eax
  80241d:	89 d3                	mov    %edx,%ebx
  80241f:	89 f2                	mov    %esi,%edx
  802421:	f7 34 24             	divl   (%esp)
  802424:	89 d6                	mov    %edx,%esi
  802426:	d3 e3                	shl    %cl,%ebx
  802428:	f7 64 24 04          	mull   0x4(%esp)
  80242c:	39 d6                	cmp    %edx,%esi
  80242e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802432:	89 d1                	mov    %edx,%ecx
  802434:	89 c3                	mov    %eax,%ebx
  802436:	72 08                	jb     802440 <__umoddi3+0x110>
  802438:	75 11                	jne    80244b <__umoddi3+0x11b>
  80243a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80243e:	73 0b                	jae    80244b <__umoddi3+0x11b>
  802440:	2b 44 24 04          	sub    0x4(%esp),%eax
  802444:	1b 14 24             	sbb    (%esp),%edx
  802447:	89 d1                	mov    %edx,%ecx
  802449:	89 c3                	mov    %eax,%ebx
  80244b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80244f:	29 da                	sub    %ebx,%edx
  802451:	19 ce                	sbb    %ecx,%esi
  802453:	89 f9                	mov    %edi,%ecx
  802455:	89 f0                	mov    %esi,%eax
  802457:	d3 e0                	shl    %cl,%eax
  802459:	89 e9                	mov    %ebp,%ecx
  80245b:	d3 ea                	shr    %cl,%edx
  80245d:	89 e9                	mov    %ebp,%ecx
  80245f:	d3 ee                	shr    %cl,%esi
  802461:	09 d0                	or     %edx,%eax
  802463:	89 f2                	mov    %esi,%edx
  802465:	83 c4 1c             	add    $0x1c,%esp
  802468:	5b                   	pop    %ebx
  802469:	5e                   	pop    %esi
  80246a:	5f                   	pop    %edi
  80246b:	5d                   	pop    %ebp
  80246c:	c3                   	ret    
  80246d:	8d 76 00             	lea    0x0(%esi),%esi
  802470:	29 f9                	sub    %edi,%ecx
  802472:	19 d6                	sbb    %edx,%esi
  802474:	89 74 24 04          	mov    %esi,0x4(%esp)
  802478:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80247c:	e9 18 ff ff ff       	jmp    802399 <__umoddi3+0x69>
