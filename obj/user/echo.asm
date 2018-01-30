
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
  800051:	68 20 25 80 00       	push   $0x802520
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
  80008a:	68 23 25 80 00       	push   $0x802523
  80008f:	6a 01                	push   $0x1
  800091:	e8 90 10 00 00       	call   801126 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 bd 00 00 00       	call   800161 <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 74 10 00 00       	call   801126 <write>
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
  8000c7:	68 f6 25 80 00       	push   $0x8025f6
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 53 10 00 00       	call   801126 <write>
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
  8000f3:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  80014d:	e8 e6 0d 00 00       	call   800f38 <close_all>
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
  800546:	68 2f 25 80 00       	push   $0x80252f
  80054b:	6a 23                	push   $0x23
  80054d:	68 4c 25 80 00       	push   $0x80254c
  800552:	e8 12 15 00 00       	call   801a69 <_panic>

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
  8005c7:	68 2f 25 80 00       	push   $0x80252f
  8005cc:	6a 23                	push   $0x23
  8005ce:	68 4c 25 80 00       	push   $0x80254c
  8005d3:	e8 91 14 00 00       	call   801a69 <_panic>

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
  800609:	68 2f 25 80 00       	push   $0x80252f
  80060e:	6a 23                	push   $0x23
  800610:	68 4c 25 80 00       	push   $0x80254c
  800615:	e8 4f 14 00 00       	call   801a69 <_panic>

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
  80064b:	68 2f 25 80 00       	push   $0x80252f
  800650:	6a 23                	push   $0x23
  800652:	68 4c 25 80 00       	push   $0x80254c
  800657:	e8 0d 14 00 00       	call   801a69 <_panic>

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
  80068d:	68 2f 25 80 00       	push   $0x80252f
  800692:	6a 23                	push   $0x23
  800694:	68 4c 25 80 00       	push   $0x80254c
  800699:	e8 cb 13 00 00       	call   801a69 <_panic>

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
  8006cf:	68 2f 25 80 00       	push   $0x80252f
  8006d4:	6a 23                	push   $0x23
  8006d6:	68 4c 25 80 00       	push   $0x80254c
  8006db:	e8 89 13 00 00       	call   801a69 <_panic>
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
  800711:	68 2f 25 80 00       	push   $0x80252f
  800716:	6a 23                	push   $0x23
  800718:	68 4c 25 80 00       	push   $0x80254c
  80071d:	e8 47 13 00 00       	call   801a69 <_panic>

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
  800775:	68 2f 25 80 00       	push   $0x80252f
  80077a:	6a 23                	push   $0x23
  80077c:	68 4c 25 80 00       	push   $0x80254c
  800781:	e8 e3 12 00 00       	call   801a69 <_panic>

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
  800814:	68 5a 25 80 00       	push   $0x80255a
  800819:	6a 1f                	push   $0x1f
  80081b:	68 6a 25 80 00       	push   $0x80256a
  800820:	e8 44 12 00 00       	call   801a69 <_panic>
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
  80083e:	68 75 25 80 00       	push   $0x802575
  800843:	6a 2d                	push   $0x2d
  800845:	68 6a 25 80 00       	push   $0x80256a
  80084a:	e8 1a 12 00 00       	call   801a69 <_panic>
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
  800886:	68 75 25 80 00       	push   $0x802575
  80088b:	6a 34                	push   $0x34
  80088d:	68 6a 25 80 00       	push   $0x80256a
  800892:	e8 d2 11 00 00       	call   801a69 <_panic>
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
  8008ae:	68 75 25 80 00       	push   $0x802575
  8008b3:	6a 38                	push   $0x38
  8008b5:	68 6a 25 80 00       	push   $0x80256a
  8008ba:	e8 aa 11 00 00       	call   801a69 <_panic>
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
  8008d2:	e8 b7 17 00 00       	call   80208e <set_pgfault_handler>
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
  8008eb:	68 8e 25 80 00       	push   $0x80258e
  8008f0:	68 85 00 00 00       	push   $0x85
  8008f5:	68 6a 25 80 00       	push   $0x80256a
  8008fa:	e8 6a 11 00 00       	call   801a69 <_panic>
  8008ff:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800901:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800905:	75 24                	jne    80092b <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800907:	e8 53 fc ff ff       	call   80055f <sys_getenvid>
  80090c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800911:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  8009a7:	68 9c 25 80 00       	push   $0x80259c
  8009ac:	6a 55                	push   $0x55
  8009ae:	68 6a 25 80 00       	push   $0x80256a
  8009b3:	e8 b1 10 00 00       	call   801a69 <_panic>
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
  8009ec:	68 9c 25 80 00       	push   $0x80259c
  8009f1:	6a 5c                	push   $0x5c
  8009f3:	68 6a 25 80 00       	push   $0x80256a
  8009f8:	e8 6c 10 00 00       	call   801a69 <_panic>
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
  800a1a:	68 9c 25 80 00       	push   $0x80259c
  800a1f:	6a 60                	push   $0x60
  800a21:	68 6a 25 80 00       	push   $0x80256a
  800a26:	e8 3e 10 00 00       	call   801a69 <_panic>
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
  800a44:	68 9c 25 80 00       	push   $0x80259c
  800a49:	6a 65                	push   $0x65
  800a4b:	68 6a 25 80 00       	push   $0x80256a
  800a50:	e8 14 10 00 00       	call   801a69 <_panic>
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
  800a6c:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800aa9:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800aaf:	83 ec 08             	sub    $0x8,%esp
  800ab2:	53                   	push   %ebx
  800ab3:	68 2c 26 80 00       	push   $0x80262c
  800ab8:	e8 85 10 00 00       	call   801b42 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800abd:	c7 04 24 27 01 80 00 	movl   $0x800127,(%esp)
  800ac4:	e8 c5 fc ff ff       	call   80078e <sys_thread_create>
  800ac9:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  800acb:	83 c4 08             	add    $0x8,%esp
  800ace:	53                   	push   %ebx
  800acf:	68 2c 26 80 00       	push   $0x80262c
  800ad4:	e8 69 10 00 00       	call   801b42 <cprintf>
	return id;
}
  800ad9:	89 f0                	mov    %esi,%eax
  800adb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  800ae8:	ff 75 08             	pushl  0x8(%ebp)
  800aeb:	e8 be fc ff ff       	call   8007ae <sys_thread_free>
}
  800af0:	83 c4 10             	add    $0x10,%esp
  800af3:	c9                   	leave  
  800af4:	c3                   	ret    

00800af5 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  800afb:	ff 75 08             	pushl  0x8(%ebp)
  800afe:	e8 cb fc ff ff       	call   8007ce <sys_thread_join>
}
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	c9                   	leave  
  800b07:	c3                   	ret    

00800b08 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
  800b0d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b10:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  800b13:	83 ec 04             	sub    $0x4,%esp
  800b16:	6a 07                	push   $0x7
  800b18:	6a 00                	push   $0x0
  800b1a:	56                   	push   %esi
  800b1b:	e8 7d fa ff ff       	call   80059d <sys_page_alloc>
	if (r < 0) {
  800b20:	83 c4 10             	add    $0x10,%esp
  800b23:	85 c0                	test   %eax,%eax
  800b25:	79 15                	jns    800b3c <queue_append+0x34>
		panic("%e\n", r);
  800b27:	50                   	push   %eax
  800b28:	68 28 26 80 00       	push   $0x802628
  800b2d:	68 c4 00 00 00       	push   $0xc4
  800b32:	68 6a 25 80 00       	push   $0x80256a
  800b37:	e8 2d 0f 00 00       	call   801a69 <_panic>
	}	
	wt->envid = envid;
  800b3c:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  800b42:	83 ec 04             	sub    $0x4,%esp
  800b45:	ff 33                	pushl  (%ebx)
  800b47:	56                   	push   %esi
  800b48:	68 50 26 80 00       	push   $0x802650
  800b4d:	e8 f0 0f 00 00       	call   801b42 <cprintf>
	if (queue->first == NULL) {
  800b52:	83 c4 10             	add    $0x10,%esp
  800b55:	83 3b 00             	cmpl   $0x0,(%ebx)
  800b58:	75 29                	jne    800b83 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	68 b2 25 80 00       	push   $0x8025b2
  800b62:	e8 db 0f 00 00       	call   801b42 <cprintf>
		queue->first = wt;
  800b67:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  800b6d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  800b74:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800b7b:	00 00 00 
  800b7e:	83 c4 10             	add    $0x10,%esp
  800b81:	eb 2b                	jmp    800bae <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	68 cc 25 80 00       	push   $0x8025cc
  800b8b:	e8 b2 0f 00 00       	call   801b42 <cprintf>
		queue->last->next = wt;
  800b90:	8b 43 04             	mov    0x4(%ebx),%eax
  800b93:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  800b9a:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800ba1:	00 00 00 
		queue->last = wt;
  800ba4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  800bab:	83 c4 10             	add    $0x10,%esp
	}
}
  800bae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	53                   	push   %ebx
  800bb9:	83 ec 04             	sub    $0x4,%esp
  800bbc:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  800bbf:	8b 02                	mov    (%edx),%eax
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	75 17                	jne    800bdc <queue_pop+0x27>
		panic("queue empty!\n");
  800bc5:	83 ec 04             	sub    $0x4,%esp
  800bc8:	68 ea 25 80 00       	push   $0x8025ea
  800bcd:	68 d8 00 00 00       	push   $0xd8
  800bd2:	68 6a 25 80 00       	push   $0x80256a
  800bd7:	e8 8d 0e 00 00       	call   801a69 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  800bdc:	8b 48 04             	mov    0x4(%eax),%ecx
  800bdf:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  800be1:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  800be3:	83 ec 08             	sub    $0x8,%esp
  800be6:	53                   	push   %ebx
  800be7:	68 f8 25 80 00       	push   $0x8025f8
  800bec:	e8 51 0f 00 00       	call   801b42 <cprintf>
	return envid;
}
  800bf1:	89 d8                	mov    %ebx,%eax
  800bf3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	53                   	push   %ebx
  800bfc:	83 ec 04             	sub    $0x4,%esp
  800bff:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  800c02:	b8 01 00 00 00       	mov    $0x1,%eax
  800c07:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  800c0a:	85 c0                	test   %eax,%eax
  800c0c:	74 5a                	je     800c68 <mutex_lock+0x70>
  800c0e:	8b 43 04             	mov    0x4(%ebx),%eax
  800c11:	83 38 00             	cmpl   $0x0,(%eax)
  800c14:	75 52                	jne    800c68 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  800c16:	83 ec 0c             	sub    $0xc,%esp
  800c19:	68 78 26 80 00       	push   $0x802678
  800c1e:	e8 1f 0f 00 00       	call   801b42 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  800c23:	8b 5b 04             	mov    0x4(%ebx),%ebx
  800c26:	e8 34 f9 ff ff       	call   80055f <sys_getenvid>
  800c2b:	83 c4 08             	add    $0x8,%esp
  800c2e:	53                   	push   %ebx
  800c2f:	50                   	push   %eax
  800c30:	e8 d3 fe ff ff       	call   800b08 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  800c35:	e8 25 f9 ff ff       	call   80055f <sys_getenvid>
  800c3a:	83 c4 08             	add    $0x8,%esp
  800c3d:	6a 04                	push   $0x4
  800c3f:	50                   	push   %eax
  800c40:	e8 1f fa ff ff       	call   800664 <sys_env_set_status>
		if (r < 0) {
  800c45:	83 c4 10             	add    $0x10,%esp
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	79 15                	jns    800c61 <mutex_lock+0x69>
			panic("%e\n", r);
  800c4c:	50                   	push   %eax
  800c4d:	68 28 26 80 00       	push   $0x802628
  800c52:	68 eb 00 00 00       	push   $0xeb
  800c57:	68 6a 25 80 00       	push   $0x80256a
  800c5c:	e8 08 0e 00 00       	call   801a69 <_panic>
		}
		sys_yield();
  800c61:	e8 18 f9 ff ff       	call   80057e <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  800c66:	eb 18                	jmp    800c80 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	68 98 26 80 00       	push   $0x802698
  800c70:	e8 cd 0e 00 00       	call   801b42 <cprintf>
	mtx->owner = sys_getenvid();}
  800c75:	e8 e5 f8 ff ff       	call   80055f <sys_getenvid>
  800c7a:	89 43 08             	mov    %eax,0x8(%ebx)
  800c7d:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  800c80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c83:	c9                   	leave  
  800c84:	c3                   	ret    

00800c85 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	53                   	push   %ebx
  800c89:	83 ec 04             	sub    $0x4,%esp
  800c8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c94:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  800c97:	8b 43 04             	mov    0x4(%ebx),%eax
  800c9a:	83 38 00             	cmpl   $0x0,(%eax)
  800c9d:	74 33                	je     800cd2 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	50                   	push   %eax
  800ca3:	e8 0d ff ff ff       	call   800bb5 <queue_pop>
  800ca8:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  800cab:	83 c4 08             	add    $0x8,%esp
  800cae:	6a 02                	push   $0x2
  800cb0:	50                   	push   %eax
  800cb1:	e8 ae f9 ff ff       	call   800664 <sys_env_set_status>
		if (r < 0) {
  800cb6:	83 c4 10             	add    $0x10,%esp
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	79 15                	jns    800cd2 <mutex_unlock+0x4d>
			panic("%e\n", r);
  800cbd:	50                   	push   %eax
  800cbe:	68 28 26 80 00       	push   $0x802628
  800cc3:	68 00 01 00 00       	push   $0x100
  800cc8:	68 6a 25 80 00       	push   $0x80256a
  800ccd:	e8 97 0d 00 00       	call   801a69 <_panic>
		}
	}

	asm volatile("pause");
  800cd2:	f3 90                	pause  
	//sys_yield();
}
  800cd4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cd7:	c9                   	leave  
  800cd8:	c3                   	ret    

00800cd9 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 04             	sub    $0x4,%esp
  800ce0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  800ce3:	e8 77 f8 ff ff       	call   80055f <sys_getenvid>
  800ce8:	83 ec 04             	sub    $0x4,%esp
  800ceb:	6a 07                	push   $0x7
  800ced:	53                   	push   %ebx
  800cee:	50                   	push   %eax
  800cef:	e8 a9 f8 ff ff       	call   80059d <sys_page_alloc>
  800cf4:	83 c4 10             	add    $0x10,%esp
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	79 15                	jns    800d10 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  800cfb:	50                   	push   %eax
  800cfc:	68 13 26 80 00       	push   $0x802613
  800d01:	68 0d 01 00 00       	push   $0x10d
  800d06:	68 6a 25 80 00       	push   $0x80256a
  800d0b:	e8 59 0d 00 00       	call   801a69 <_panic>
	}	
	mtx->locked = 0;
  800d10:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  800d16:	8b 43 04             	mov    0x4(%ebx),%eax
  800d19:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  800d1f:	8b 43 04             	mov    0x4(%ebx),%eax
  800d22:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  800d29:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  800d30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d33:	c9                   	leave  
  800d34:	c3                   	ret    

00800d35 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  800d3b:	e8 1f f8 ff ff       	call   80055f <sys_getenvid>
  800d40:	83 ec 08             	sub    $0x8,%esp
  800d43:	ff 75 08             	pushl  0x8(%ebp)
  800d46:	50                   	push   %eax
  800d47:	e8 d6 f8 ff ff       	call   800622 <sys_page_unmap>
	if (r < 0) {
  800d4c:	83 c4 10             	add    $0x10,%esp
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	79 15                	jns    800d68 <mutex_destroy+0x33>
		panic("%e\n", r);
  800d53:	50                   	push   %eax
  800d54:	68 28 26 80 00       	push   $0x802628
  800d59:	68 1a 01 00 00       	push   $0x11a
  800d5e:	68 6a 25 80 00       	push   $0x80256a
  800d63:	e8 01 0d 00 00       	call   801a69 <_panic>
	}
}
  800d68:	c9                   	leave  
  800d69:	c3                   	ret    

00800d6a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d70:	05 00 00 00 30       	add    $0x30000000,%eax
  800d75:	c1 e8 0c             	shr    $0xc,%eax
}
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d80:	05 00 00 00 30       	add    $0x30000000,%eax
  800d85:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d8a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d97:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d9c:	89 c2                	mov    %eax,%edx
  800d9e:	c1 ea 16             	shr    $0x16,%edx
  800da1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da8:	f6 c2 01             	test   $0x1,%dl
  800dab:	74 11                	je     800dbe <fd_alloc+0x2d>
  800dad:	89 c2                	mov    %eax,%edx
  800daf:	c1 ea 0c             	shr    $0xc,%edx
  800db2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db9:	f6 c2 01             	test   $0x1,%dl
  800dbc:	75 09                	jne    800dc7 <fd_alloc+0x36>
			*fd_store = fd;
  800dbe:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc5:	eb 17                	jmp    800dde <fd_alloc+0x4d>
  800dc7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dcc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dd1:	75 c9                	jne    800d9c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dd3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dd9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800de6:	83 f8 1f             	cmp    $0x1f,%eax
  800de9:	77 36                	ja     800e21 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800deb:	c1 e0 0c             	shl    $0xc,%eax
  800dee:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800df3:	89 c2                	mov    %eax,%edx
  800df5:	c1 ea 16             	shr    $0x16,%edx
  800df8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dff:	f6 c2 01             	test   $0x1,%dl
  800e02:	74 24                	je     800e28 <fd_lookup+0x48>
  800e04:	89 c2                	mov    %eax,%edx
  800e06:	c1 ea 0c             	shr    $0xc,%edx
  800e09:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e10:	f6 c2 01             	test   $0x1,%dl
  800e13:	74 1a                	je     800e2f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e15:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e18:	89 02                	mov    %eax,(%edx)
	return 0;
  800e1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1f:	eb 13                	jmp    800e34 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e26:	eb 0c                	jmp    800e34 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e28:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e2d:	eb 05                	jmp    800e34 <fd_lookup+0x54>
  800e2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    

00800e36 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	83 ec 08             	sub    $0x8,%esp
  800e3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3f:	ba 34 27 80 00       	mov    $0x802734,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e44:	eb 13                	jmp    800e59 <dev_lookup+0x23>
  800e46:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e49:	39 08                	cmp    %ecx,(%eax)
  800e4b:	75 0c                	jne    800e59 <dev_lookup+0x23>
			*dev = devtab[i];
  800e4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e50:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e52:	b8 00 00 00 00       	mov    $0x0,%eax
  800e57:	eb 31                	jmp    800e8a <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e59:	8b 02                	mov    (%edx),%eax
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	75 e7                	jne    800e46 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e5f:	a1 04 40 80 00       	mov    0x804004,%eax
  800e64:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800e6a:	83 ec 04             	sub    $0x4,%esp
  800e6d:	51                   	push   %ecx
  800e6e:	50                   	push   %eax
  800e6f:	68 b8 26 80 00       	push   $0x8026b8
  800e74:	e8 c9 0c 00 00       	call   801b42 <cprintf>
	*dev = 0;
  800e79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e82:	83 c4 10             	add    $0x10,%esp
  800e85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e8a:	c9                   	leave  
  800e8b:	c3                   	ret    

00800e8c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
  800e91:	83 ec 10             	sub    $0x10,%esp
  800e94:	8b 75 08             	mov    0x8(%ebp),%esi
  800e97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e9d:	50                   	push   %eax
  800e9e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ea4:	c1 e8 0c             	shr    $0xc,%eax
  800ea7:	50                   	push   %eax
  800ea8:	e8 33 ff ff ff       	call   800de0 <fd_lookup>
  800ead:	83 c4 08             	add    $0x8,%esp
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	78 05                	js     800eb9 <fd_close+0x2d>
	    || fd != fd2)
  800eb4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800eb7:	74 0c                	je     800ec5 <fd_close+0x39>
		return (must_exist ? r : 0);
  800eb9:	84 db                	test   %bl,%bl
  800ebb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec0:	0f 44 c2             	cmove  %edx,%eax
  800ec3:	eb 41                	jmp    800f06 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ec5:	83 ec 08             	sub    $0x8,%esp
  800ec8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ecb:	50                   	push   %eax
  800ecc:	ff 36                	pushl  (%esi)
  800ece:	e8 63 ff ff ff       	call   800e36 <dev_lookup>
  800ed3:	89 c3                	mov    %eax,%ebx
  800ed5:	83 c4 10             	add    $0x10,%esp
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	78 1a                	js     800ef6 <fd_close+0x6a>
		if (dev->dev_close)
  800edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800edf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ee2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	74 0b                	je     800ef6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800eeb:	83 ec 0c             	sub    $0xc,%esp
  800eee:	56                   	push   %esi
  800eef:	ff d0                	call   *%eax
  800ef1:	89 c3                	mov    %eax,%ebx
  800ef3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ef6:	83 ec 08             	sub    $0x8,%esp
  800ef9:	56                   	push   %esi
  800efa:	6a 00                	push   $0x0
  800efc:	e8 21 f7 ff ff       	call   800622 <sys_page_unmap>
	return r;
  800f01:	83 c4 10             	add    $0x10,%esp
  800f04:	89 d8                	mov    %ebx,%eax
}
  800f06:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f09:	5b                   	pop    %ebx
  800f0a:	5e                   	pop    %esi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f16:	50                   	push   %eax
  800f17:	ff 75 08             	pushl  0x8(%ebp)
  800f1a:	e8 c1 fe ff ff       	call   800de0 <fd_lookup>
  800f1f:	83 c4 08             	add    $0x8,%esp
  800f22:	85 c0                	test   %eax,%eax
  800f24:	78 10                	js     800f36 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f26:	83 ec 08             	sub    $0x8,%esp
  800f29:	6a 01                	push   $0x1
  800f2b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f2e:	e8 59 ff ff ff       	call   800e8c <fd_close>
  800f33:	83 c4 10             	add    $0x10,%esp
}
  800f36:	c9                   	leave  
  800f37:	c3                   	ret    

00800f38 <close_all>:

void
close_all(void)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	53                   	push   %ebx
  800f3c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f3f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f44:	83 ec 0c             	sub    $0xc,%esp
  800f47:	53                   	push   %ebx
  800f48:	e8 c0 ff ff ff       	call   800f0d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f4d:	83 c3 01             	add    $0x1,%ebx
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	83 fb 20             	cmp    $0x20,%ebx
  800f56:	75 ec                	jne    800f44 <close_all+0xc>
		close(i);
}
  800f58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f5b:	c9                   	leave  
  800f5c:	c3                   	ret    

00800f5d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	57                   	push   %edi
  800f61:	56                   	push   %esi
  800f62:	53                   	push   %ebx
  800f63:	83 ec 2c             	sub    $0x2c,%esp
  800f66:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f69:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f6c:	50                   	push   %eax
  800f6d:	ff 75 08             	pushl  0x8(%ebp)
  800f70:	e8 6b fe ff ff       	call   800de0 <fd_lookup>
  800f75:	83 c4 08             	add    $0x8,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	0f 88 c1 00 00 00    	js     801041 <dup+0xe4>
		return r;
	close(newfdnum);
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	56                   	push   %esi
  800f84:	e8 84 ff ff ff       	call   800f0d <close>

	newfd = INDEX2FD(newfdnum);
  800f89:	89 f3                	mov    %esi,%ebx
  800f8b:	c1 e3 0c             	shl    $0xc,%ebx
  800f8e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f94:	83 c4 04             	add    $0x4,%esp
  800f97:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f9a:	e8 db fd ff ff       	call   800d7a <fd2data>
  800f9f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fa1:	89 1c 24             	mov    %ebx,(%esp)
  800fa4:	e8 d1 fd ff ff       	call   800d7a <fd2data>
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800faf:	89 f8                	mov    %edi,%eax
  800fb1:	c1 e8 16             	shr    $0x16,%eax
  800fb4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fbb:	a8 01                	test   $0x1,%al
  800fbd:	74 37                	je     800ff6 <dup+0x99>
  800fbf:	89 f8                	mov    %edi,%eax
  800fc1:	c1 e8 0c             	shr    $0xc,%eax
  800fc4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fcb:	f6 c2 01             	test   $0x1,%dl
  800fce:	74 26                	je     800ff6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fd0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	25 07 0e 00 00       	and    $0xe07,%eax
  800fdf:	50                   	push   %eax
  800fe0:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fe3:	6a 00                	push   $0x0
  800fe5:	57                   	push   %edi
  800fe6:	6a 00                	push   $0x0
  800fe8:	e8 f3 f5 ff ff       	call   8005e0 <sys_page_map>
  800fed:	89 c7                	mov    %eax,%edi
  800fef:	83 c4 20             	add    $0x20,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	78 2e                	js     801024 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ff6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ff9:	89 d0                	mov    %edx,%eax
  800ffb:	c1 e8 0c             	shr    $0xc,%eax
  800ffe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801005:	83 ec 0c             	sub    $0xc,%esp
  801008:	25 07 0e 00 00       	and    $0xe07,%eax
  80100d:	50                   	push   %eax
  80100e:	53                   	push   %ebx
  80100f:	6a 00                	push   $0x0
  801011:	52                   	push   %edx
  801012:	6a 00                	push   $0x0
  801014:	e8 c7 f5 ff ff       	call   8005e0 <sys_page_map>
  801019:	89 c7                	mov    %eax,%edi
  80101b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80101e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801020:	85 ff                	test   %edi,%edi
  801022:	79 1d                	jns    801041 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801024:	83 ec 08             	sub    $0x8,%esp
  801027:	53                   	push   %ebx
  801028:	6a 00                	push   $0x0
  80102a:	e8 f3 f5 ff ff       	call   800622 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80102f:	83 c4 08             	add    $0x8,%esp
  801032:	ff 75 d4             	pushl  -0x2c(%ebp)
  801035:	6a 00                	push   $0x0
  801037:	e8 e6 f5 ff ff       	call   800622 <sys_page_unmap>
	return r;
  80103c:	83 c4 10             	add    $0x10,%esp
  80103f:	89 f8                	mov    %edi,%eax
}
  801041:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801044:	5b                   	pop    %ebx
  801045:	5e                   	pop    %esi
  801046:	5f                   	pop    %edi
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    

00801049 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	53                   	push   %ebx
  80104d:	83 ec 14             	sub    $0x14,%esp
  801050:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801053:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801056:	50                   	push   %eax
  801057:	53                   	push   %ebx
  801058:	e8 83 fd ff ff       	call   800de0 <fd_lookup>
  80105d:	83 c4 08             	add    $0x8,%esp
  801060:	89 c2                	mov    %eax,%edx
  801062:	85 c0                	test   %eax,%eax
  801064:	78 70                	js     8010d6 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801066:	83 ec 08             	sub    $0x8,%esp
  801069:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106c:	50                   	push   %eax
  80106d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801070:	ff 30                	pushl  (%eax)
  801072:	e8 bf fd ff ff       	call   800e36 <dev_lookup>
  801077:	83 c4 10             	add    $0x10,%esp
  80107a:	85 c0                	test   %eax,%eax
  80107c:	78 4f                	js     8010cd <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80107e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801081:	8b 42 08             	mov    0x8(%edx),%eax
  801084:	83 e0 03             	and    $0x3,%eax
  801087:	83 f8 01             	cmp    $0x1,%eax
  80108a:	75 24                	jne    8010b0 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80108c:	a1 04 40 80 00       	mov    0x804004,%eax
  801091:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801097:	83 ec 04             	sub    $0x4,%esp
  80109a:	53                   	push   %ebx
  80109b:	50                   	push   %eax
  80109c:	68 f9 26 80 00       	push   $0x8026f9
  8010a1:	e8 9c 0a 00 00       	call   801b42 <cprintf>
		return -E_INVAL;
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010ae:	eb 26                	jmp    8010d6 <read+0x8d>
	}
	if (!dev->dev_read)
  8010b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b3:	8b 40 08             	mov    0x8(%eax),%eax
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	74 17                	je     8010d1 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8010ba:	83 ec 04             	sub    $0x4,%esp
  8010bd:	ff 75 10             	pushl  0x10(%ebp)
  8010c0:	ff 75 0c             	pushl  0xc(%ebp)
  8010c3:	52                   	push   %edx
  8010c4:	ff d0                	call   *%eax
  8010c6:	89 c2                	mov    %eax,%edx
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	eb 09                	jmp    8010d6 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010cd:	89 c2                	mov    %eax,%edx
  8010cf:	eb 05                	jmp    8010d6 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8010d6:	89 d0                	mov    %edx,%eax
  8010d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010db:	c9                   	leave  
  8010dc:	c3                   	ret    

008010dd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	57                   	push   %edi
  8010e1:	56                   	push   %esi
  8010e2:	53                   	push   %ebx
  8010e3:	83 ec 0c             	sub    $0xc,%esp
  8010e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f1:	eb 21                	jmp    801114 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010f3:	83 ec 04             	sub    $0x4,%esp
  8010f6:	89 f0                	mov    %esi,%eax
  8010f8:	29 d8                	sub    %ebx,%eax
  8010fa:	50                   	push   %eax
  8010fb:	89 d8                	mov    %ebx,%eax
  8010fd:	03 45 0c             	add    0xc(%ebp),%eax
  801100:	50                   	push   %eax
  801101:	57                   	push   %edi
  801102:	e8 42 ff ff ff       	call   801049 <read>
		if (m < 0)
  801107:	83 c4 10             	add    $0x10,%esp
  80110a:	85 c0                	test   %eax,%eax
  80110c:	78 10                	js     80111e <readn+0x41>
			return m;
		if (m == 0)
  80110e:	85 c0                	test   %eax,%eax
  801110:	74 0a                	je     80111c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801112:	01 c3                	add    %eax,%ebx
  801114:	39 f3                	cmp    %esi,%ebx
  801116:	72 db                	jb     8010f3 <readn+0x16>
  801118:	89 d8                	mov    %ebx,%eax
  80111a:	eb 02                	jmp    80111e <readn+0x41>
  80111c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80111e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801121:	5b                   	pop    %ebx
  801122:	5e                   	pop    %esi
  801123:	5f                   	pop    %edi
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    

00801126 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	53                   	push   %ebx
  80112a:	83 ec 14             	sub    $0x14,%esp
  80112d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801130:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801133:	50                   	push   %eax
  801134:	53                   	push   %ebx
  801135:	e8 a6 fc ff ff       	call   800de0 <fd_lookup>
  80113a:	83 c4 08             	add    $0x8,%esp
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 6b                	js     8011ae <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801143:	83 ec 08             	sub    $0x8,%esp
  801146:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801149:	50                   	push   %eax
  80114a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114d:	ff 30                	pushl  (%eax)
  80114f:	e8 e2 fc ff ff       	call   800e36 <dev_lookup>
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	78 4a                	js     8011a5 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80115b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801162:	75 24                	jne    801188 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801164:	a1 04 40 80 00       	mov    0x804004,%eax
  801169:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	53                   	push   %ebx
  801173:	50                   	push   %eax
  801174:	68 15 27 80 00       	push   $0x802715
  801179:	e8 c4 09 00 00       	call   801b42 <cprintf>
		return -E_INVAL;
  80117e:	83 c4 10             	add    $0x10,%esp
  801181:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801186:	eb 26                	jmp    8011ae <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801188:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80118b:	8b 52 0c             	mov    0xc(%edx),%edx
  80118e:	85 d2                	test   %edx,%edx
  801190:	74 17                	je     8011a9 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801192:	83 ec 04             	sub    $0x4,%esp
  801195:	ff 75 10             	pushl  0x10(%ebp)
  801198:	ff 75 0c             	pushl  0xc(%ebp)
  80119b:	50                   	push   %eax
  80119c:	ff d2                	call   *%edx
  80119e:	89 c2                	mov    %eax,%edx
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	eb 09                	jmp    8011ae <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a5:	89 c2                	mov    %eax,%edx
  8011a7:	eb 05                	jmp    8011ae <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011a9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011ae:	89 d0                	mov    %edx,%eax
  8011b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b3:	c9                   	leave  
  8011b4:	c3                   	ret    

008011b5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011be:	50                   	push   %eax
  8011bf:	ff 75 08             	pushl  0x8(%ebp)
  8011c2:	e8 19 fc ff ff       	call   800de0 <fd_lookup>
  8011c7:	83 c4 08             	add    $0x8,%esp
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 0e                	js     8011dc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011dc:	c9                   	leave  
  8011dd:	c3                   	ret    

008011de <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	53                   	push   %ebx
  8011e2:	83 ec 14             	sub    $0x14,%esp
  8011e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011eb:	50                   	push   %eax
  8011ec:	53                   	push   %ebx
  8011ed:	e8 ee fb ff ff       	call   800de0 <fd_lookup>
  8011f2:	83 c4 08             	add    $0x8,%esp
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 68                	js     801263 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fb:	83 ec 08             	sub    $0x8,%esp
  8011fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801201:	50                   	push   %eax
  801202:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801205:	ff 30                	pushl  (%eax)
  801207:	e8 2a fc ff ff       	call   800e36 <dev_lookup>
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 47                	js     80125a <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801213:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801216:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80121a:	75 24                	jne    801240 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80121c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801221:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801227:	83 ec 04             	sub    $0x4,%esp
  80122a:	53                   	push   %ebx
  80122b:	50                   	push   %eax
  80122c:	68 d8 26 80 00       	push   $0x8026d8
  801231:	e8 0c 09 00 00       	call   801b42 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80123e:	eb 23                	jmp    801263 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801240:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801243:	8b 52 18             	mov    0x18(%edx),%edx
  801246:	85 d2                	test   %edx,%edx
  801248:	74 14                	je     80125e <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	ff 75 0c             	pushl  0xc(%ebp)
  801250:	50                   	push   %eax
  801251:	ff d2                	call   *%edx
  801253:	89 c2                	mov    %eax,%edx
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	eb 09                	jmp    801263 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	eb 05                	jmp    801263 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80125e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801263:	89 d0                	mov    %edx,%eax
  801265:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801268:	c9                   	leave  
  801269:	c3                   	ret    

0080126a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	53                   	push   %ebx
  80126e:	83 ec 14             	sub    $0x14,%esp
  801271:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801274:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	ff 75 08             	pushl  0x8(%ebp)
  80127b:	e8 60 fb ff ff       	call   800de0 <fd_lookup>
  801280:	83 c4 08             	add    $0x8,%esp
  801283:	89 c2                	mov    %eax,%edx
  801285:	85 c0                	test   %eax,%eax
  801287:	78 58                	js     8012e1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801289:	83 ec 08             	sub    $0x8,%esp
  80128c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128f:	50                   	push   %eax
  801290:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801293:	ff 30                	pushl  (%eax)
  801295:	e8 9c fb ff ff       	call   800e36 <dev_lookup>
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 37                	js     8012d8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012a8:	74 32                	je     8012dc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012aa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012ad:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012b4:	00 00 00 
	stat->st_isdir = 0;
  8012b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012be:	00 00 00 
	stat->st_dev = dev;
  8012c1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	53                   	push   %ebx
  8012cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ce:	ff 50 14             	call   *0x14(%eax)
  8012d1:	89 c2                	mov    %eax,%edx
  8012d3:	83 c4 10             	add    $0x10,%esp
  8012d6:	eb 09                	jmp    8012e1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d8:	89 c2                	mov    %eax,%edx
  8012da:	eb 05                	jmp    8012e1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012e1:	89 d0                	mov    %edx,%eax
  8012e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e6:	c9                   	leave  
  8012e7:	c3                   	ret    

008012e8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	56                   	push   %esi
  8012ec:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012ed:	83 ec 08             	sub    $0x8,%esp
  8012f0:	6a 00                	push   $0x0
  8012f2:	ff 75 08             	pushl  0x8(%ebp)
  8012f5:	e8 e3 01 00 00       	call   8014dd <open>
  8012fa:	89 c3                	mov    %eax,%ebx
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 1b                	js     80131e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	ff 75 0c             	pushl  0xc(%ebp)
  801309:	50                   	push   %eax
  80130a:	e8 5b ff ff ff       	call   80126a <fstat>
  80130f:	89 c6                	mov    %eax,%esi
	close(fd);
  801311:	89 1c 24             	mov    %ebx,(%esp)
  801314:	e8 f4 fb ff ff       	call   800f0d <close>
	return r;
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	89 f0                	mov    %esi,%eax
}
  80131e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801321:	5b                   	pop    %ebx
  801322:	5e                   	pop    %esi
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	56                   	push   %esi
  801329:	53                   	push   %ebx
  80132a:	89 c6                	mov    %eax,%esi
  80132c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80132e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801335:	75 12                	jne    801349 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801337:	83 ec 0c             	sub    $0xc,%esp
  80133a:	6a 01                	push   $0x1
  80133c:	e8 b9 0e 00 00       	call   8021fa <ipc_find_env>
  801341:	a3 00 40 80 00       	mov    %eax,0x804000
  801346:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801349:	6a 07                	push   $0x7
  80134b:	68 00 50 80 00       	push   $0x805000
  801350:	56                   	push   %esi
  801351:	ff 35 00 40 80 00    	pushl  0x804000
  801357:	e8 3c 0e 00 00       	call   802198 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80135c:	83 c4 0c             	add    $0xc,%esp
  80135f:	6a 00                	push   $0x0
  801361:	53                   	push   %ebx
  801362:	6a 00                	push   $0x0
  801364:	e8 b4 0d 00 00       	call   80211d <ipc_recv>
}
  801369:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136c:	5b                   	pop    %ebx
  80136d:	5e                   	pop    %esi
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    

00801370 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801376:	8b 45 08             	mov    0x8(%ebp),%eax
  801379:	8b 40 0c             	mov    0xc(%eax),%eax
  80137c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801381:	8b 45 0c             	mov    0xc(%ebp),%eax
  801384:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801389:	ba 00 00 00 00       	mov    $0x0,%edx
  80138e:	b8 02 00 00 00       	mov    $0x2,%eax
  801393:	e8 8d ff ff ff       	call   801325 <fsipc>
}
  801398:	c9                   	leave  
  801399:	c3                   	ret    

0080139a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b0:	b8 06 00 00 00       	mov    $0x6,%eax
  8013b5:	e8 6b ff ff ff       	call   801325 <fsipc>
}
  8013ba:	c9                   	leave  
  8013bb:	c3                   	ret    

008013bc <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	53                   	push   %ebx
  8013c0:	83 ec 04             	sub    $0x4,%esp
  8013c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013cc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8013db:	e8 45 ff ff ff       	call   801325 <fsipc>
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	78 2c                	js     801410 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	68 00 50 80 00       	push   $0x805000
  8013ec:	53                   	push   %ebx
  8013ed:	e8 a8 ed ff ff       	call   80019a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8013f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013fd:	a1 84 50 80 00       	mov    0x805084,%eax
  801402:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801410:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801413:	c9                   	leave  
  801414:	c3                   	ret    

00801415 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	83 ec 0c             	sub    $0xc,%esp
  80141b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80141e:	8b 55 08             	mov    0x8(%ebp),%edx
  801421:	8b 52 0c             	mov    0xc(%edx),%edx
  801424:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80142a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80142f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801434:	0f 47 c2             	cmova  %edx,%eax
  801437:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80143c:	50                   	push   %eax
  80143d:	ff 75 0c             	pushl  0xc(%ebp)
  801440:	68 08 50 80 00       	push   $0x805008
  801445:	e8 e2 ee ff ff       	call   80032c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80144a:	ba 00 00 00 00       	mov    $0x0,%edx
  80144f:	b8 04 00 00 00       	mov    $0x4,%eax
  801454:	e8 cc fe ff ff       	call   801325 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801459:	c9                   	leave  
  80145a:	c3                   	ret    

0080145b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	56                   	push   %esi
  80145f:	53                   	push   %ebx
  801460:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801463:	8b 45 08             	mov    0x8(%ebp),%eax
  801466:	8b 40 0c             	mov    0xc(%eax),%eax
  801469:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80146e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801474:	ba 00 00 00 00       	mov    $0x0,%edx
  801479:	b8 03 00 00 00       	mov    $0x3,%eax
  80147e:	e8 a2 fe ff ff       	call   801325 <fsipc>
  801483:	89 c3                	mov    %eax,%ebx
  801485:	85 c0                	test   %eax,%eax
  801487:	78 4b                	js     8014d4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801489:	39 c6                	cmp    %eax,%esi
  80148b:	73 16                	jae    8014a3 <devfile_read+0x48>
  80148d:	68 44 27 80 00       	push   $0x802744
  801492:	68 4b 27 80 00       	push   $0x80274b
  801497:	6a 7c                	push   $0x7c
  801499:	68 60 27 80 00       	push   $0x802760
  80149e:	e8 c6 05 00 00       	call   801a69 <_panic>
	assert(r <= PGSIZE);
  8014a3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014a8:	7e 16                	jle    8014c0 <devfile_read+0x65>
  8014aa:	68 6b 27 80 00       	push   $0x80276b
  8014af:	68 4b 27 80 00       	push   $0x80274b
  8014b4:	6a 7d                	push   $0x7d
  8014b6:	68 60 27 80 00       	push   $0x802760
  8014bb:	e8 a9 05 00 00       	call   801a69 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	50                   	push   %eax
  8014c4:	68 00 50 80 00       	push   $0x805000
  8014c9:	ff 75 0c             	pushl  0xc(%ebp)
  8014cc:	e8 5b ee ff ff       	call   80032c <memmove>
	return r;
  8014d1:	83 c4 10             	add    $0x10,%esp
}
  8014d4:	89 d8                	mov    %ebx,%eax
  8014d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d9:	5b                   	pop    %ebx
  8014da:	5e                   	pop    %esi
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    

008014dd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	53                   	push   %ebx
  8014e1:	83 ec 20             	sub    $0x20,%esp
  8014e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014e7:	53                   	push   %ebx
  8014e8:	e8 74 ec ff ff       	call   800161 <strlen>
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014f5:	7f 67                	jg     80155e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014f7:	83 ec 0c             	sub    $0xc,%esp
  8014fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fd:	50                   	push   %eax
  8014fe:	e8 8e f8 ff ff       	call   800d91 <fd_alloc>
  801503:	83 c4 10             	add    $0x10,%esp
		return r;
  801506:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 57                	js     801563 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80150c:	83 ec 08             	sub    $0x8,%esp
  80150f:	53                   	push   %ebx
  801510:	68 00 50 80 00       	push   $0x805000
  801515:	e8 80 ec ff ff       	call   80019a <strcpy>
	fsipcbuf.open.req_omode = mode;
  80151a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801522:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801525:	b8 01 00 00 00       	mov    $0x1,%eax
  80152a:	e8 f6 fd ff ff       	call   801325 <fsipc>
  80152f:	89 c3                	mov    %eax,%ebx
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	79 14                	jns    80154c <open+0x6f>
		fd_close(fd, 0);
  801538:	83 ec 08             	sub    $0x8,%esp
  80153b:	6a 00                	push   $0x0
  80153d:	ff 75 f4             	pushl  -0xc(%ebp)
  801540:	e8 47 f9 ff ff       	call   800e8c <fd_close>
		return r;
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	89 da                	mov    %ebx,%edx
  80154a:	eb 17                	jmp    801563 <open+0x86>
	}

	return fd2num(fd);
  80154c:	83 ec 0c             	sub    $0xc,%esp
  80154f:	ff 75 f4             	pushl  -0xc(%ebp)
  801552:	e8 13 f8 ff ff       	call   800d6a <fd2num>
  801557:	89 c2                	mov    %eax,%edx
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	eb 05                	jmp    801563 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80155e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801563:	89 d0                	mov    %edx,%eax
  801565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801570:	ba 00 00 00 00       	mov    $0x0,%edx
  801575:	b8 08 00 00 00       	mov    $0x8,%eax
  80157a:	e8 a6 fd ff ff       	call   801325 <fsipc>
}
  80157f:	c9                   	leave  
  801580:	c3                   	ret    

00801581 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	56                   	push   %esi
  801585:	53                   	push   %ebx
  801586:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801589:	83 ec 0c             	sub    $0xc,%esp
  80158c:	ff 75 08             	pushl  0x8(%ebp)
  80158f:	e8 e6 f7 ff ff       	call   800d7a <fd2data>
  801594:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801596:	83 c4 08             	add    $0x8,%esp
  801599:	68 77 27 80 00       	push   $0x802777
  80159e:	53                   	push   %ebx
  80159f:	e8 f6 eb ff ff       	call   80019a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015a4:	8b 46 04             	mov    0x4(%esi),%eax
  8015a7:	2b 06                	sub    (%esi),%eax
  8015a9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015af:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015b6:	00 00 00 
	stat->st_dev = &devpipe;
  8015b9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015c0:	30 80 00 
	return 0;
}
  8015c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cb:	5b                   	pop    %ebx
  8015cc:	5e                   	pop    %esi
  8015cd:	5d                   	pop    %ebp
  8015ce:	c3                   	ret    

008015cf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	53                   	push   %ebx
  8015d3:	83 ec 0c             	sub    $0xc,%esp
  8015d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015d9:	53                   	push   %ebx
  8015da:	6a 00                	push   $0x0
  8015dc:	e8 41 f0 ff ff       	call   800622 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015e1:	89 1c 24             	mov    %ebx,(%esp)
  8015e4:	e8 91 f7 ff ff       	call   800d7a <fd2data>
  8015e9:	83 c4 08             	add    $0x8,%esp
  8015ec:	50                   	push   %eax
  8015ed:	6a 00                	push   $0x0
  8015ef:	e8 2e f0 ff ff       	call   800622 <sys_page_unmap>
}
  8015f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f7:	c9                   	leave  
  8015f8:	c3                   	ret    

008015f9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	57                   	push   %edi
  8015fd:	56                   	push   %esi
  8015fe:	53                   	push   %ebx
  8015ff:	83 ec 1c             	sub    $0x1c,%esp
  801602:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801605:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801607:	a1 04 40 80 00       	mov    0x804004,%eax
  80160c:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801612:	83 ec 0c             	sub    $0xc,%esp
  801615:	ff 75 e0             	pushl  -0x20(%ebp)
  801618:	e8 22 0c 00 00       	call   80223f <pageref>
  80161d:	89 c3                	mov    %eax,%ebx
  80161f:	89 3c 24             	mov    %edi,(%esp)
  801622:	e8 18 0c 00 00       	call   80223f <pageref>
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	39 c3                	cmp    %eax,%ebx
  80162c:	0f 94 c1             	sete   %cl
  80162f:	0f b6 c9             	movzbl %cl,%ecx
  801632:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801635:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80163b:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801641:	39 ce                	cmp    %ecx,%esi
  801643:	74 1e                	je     801663 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801645:	39 c3                	cmp    %eax,%ebx
  801647:	75 be                	jne    801607 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801649:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  80164f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801652:	50                   	push   %eax
  801653:	56                   	push   %esi
  801654:	68 7e 27 80 00       	push   $0x80277e
  801659:	e8 e4 04 00 00       	call   801b42 <cprintf>
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	eb a4                	jmp    801607 <_pipeisclosed+0xe>
	}
}
  801663:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801666:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801669:	5b                   	pop    %ebx
  80166a:	5e                   	pop    %esi
  80166b:	5f                   	pop    %edi
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	57                   	push   %edi
  801672:	56                   	push   %esi
  801673:	53                   	push   %ebx
  801674:	83 ec 28             	sub    $0x28,%esp
  801677:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80167a:	56                   	push   %esi
  80167b:	e8 fa f6 ff ff       	call   800d7a <fd2data>
  801680:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	bf 00 00 00 00       	mov    $0x0,%edi
  80168a:	eb 4b                	jmp    8016d7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80168c:	89 da                	mov    %ebx,%edx
  80168e:	89 f0                	mov    %esi,%eax
  801690:	e8 64 ff ff ff       	call   8015f9 <_pipeisclosed>
  801695:	85 c0                	test   %eax,%eax
  801697:	75 48                	jne    8016e1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801699:	e8 e0 ee ff ff       	call   80057e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80169e:	8b 43 04             	mov    0x4(%ebx),%eax
  8016a1:	8b 0b                	mov    (%ebx),%ecx
  8016a3:	8d 51 20             	lea    0x20(%ecx),%edx
  8016a6:	39 d0                	cmp    %edx,%eax
  8016a8:	73 e2                	jae    80168c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ad:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016b1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016b4:	89 c2                	mov    %eax,%edx
  8016b6:	c1 fa 1f             	sar    $0x1f,%edx
  8016b9:	89 d1                	mov    %edx,%ecx
  8016bb:	c1 e9 1b             	shr    $0x1b,%ecx
  8016be:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016c1:	83 e2 1f             	and    $0x1f,%edx
  8016c4:	29 ca                	sub    %ecx,%edx
  8016c6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016ce:	83 c0 01             	add    $0x1,%eax
  8016d1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d4:	83 c7 01             	add    $0x1,%edi
  8016d7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016da:	75 c2                	jne    80169e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8016df:	eb 05                	jmp    8016e6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016e1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e9:	5b                   	pop    %ebx
  8016ea:	5e                   	pop    %esi
  8016eb:	5f                   	pop    %edi
  8016ec:	5d                   	pop    %ebp
  8016ed:	c3                   	ret    

008016ee <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	57                   	push   %edi
  8016f2:	56                   	push   %esi
  8016f3:	53                   	push   %ebx
  8016f4:	83 ec 18             	sub    $0x18,%esp
  8016f7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016fa:	57                   	push   %edi
  8016fb:	e8 7a f6 ff ff       	call   800d7a <fd2data>
  801700:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801702:	83 c4 10             	add    $0x10,%esp
  801705:	bb 00 00 00 00       	mov    $0x0,%ebx
  80170a:	eb 3d                	jmp    801749 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80170c:	85 db                	test   %ebx,%ebx
  80170e:	74 04                	je     801714 <devpipe_read+0x26>
				return i;
  801710:	89 d8                	mov    %ebx,%eax
  801712:	eb 44                	jmp    801758 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801714:	89 f2                	mov    %esi,%edx
  801716:	89 f8                	mov    %edi,%eax
  801718:	e8 dc fe ff ff       	call   8015f9 <_pipeisclosed>
  80171d:	85 c0                	test   %eax,%eax
  80171f:	75 32                	jne    801753 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801721:	e8 58 ee ff ff       	call   80057e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801726:	8b 06                	mov    (%esi),%eax
  801728:	3b 46 04             	cmp    0x4(%esi),%eax
  80172b:	74 df                	je     80170c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80172d:	99                   	cltd   
  80172e:	c1 ea 1b             	shr    $0x1b,%edx
  801731:	01 d0                	add    %edx,%eax
  801733:	83 e0 1f             	and    $0x1f,%eax
  801736:	29 d0                	sub    %edx,%eax
  801738:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80173d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801740:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801743:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801746:	83 c3 01             	add    $0x1,%ebx
  801749:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80174c:	75 d8                	jne    801726 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80174e:	8b 45 10             	mov    0x10(%ebp),%eax
  801751:	eb 05                	jmp    801758 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801753:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801758:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175b:	5b                   	pop    %ebx
  80175c:	5e                   	pop    %esi
  80175d:	5f                   	pop    %edi
  80175e:	5d                   	pop    %ebp
  80175f:	c3                   	ret    

00801760 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	56                   	push   %esi
  801764:	53                   	push   %ebx
  801765:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801768:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176b:	50                   	push   %eax
  80176c:	e8 20 f6 ff ff       	call   800d91 <fd_alloc>
  801771:	83 c4 10             	add    $0x10,%esp
  801774:	89 c2                	mov    %eax,%edx
  801776:	85 c0                	test   %eax,%eax
  801778:	0f 88 2c 01 00 00    	js     8018aa <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80177e:	83 ec 04             	sub    $0x4,%esp
  801781:	68 07 04 00 00       	push   $0x407
  801786:	ff 75 f4             	pushl  -0xc(%ebp)
  801789:	6a 00                	push   $0x0
  80178b:	e8 0d ee ff ff       	call   80059d <sys_page_alloc>
  801790:	83 c4 10             	add    $0x10,%esp
  801793:	89 c2                	mov    %eax,%edx
  801795:	85 c0                	test   %eax,%eax
  801797:	0f 88 0d 01 00 00    	js     8018aa <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80179d:	83 ec 0c             	sub    $0xc,%esp
  8017a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a3:	50                   	push   %eax
  8017a4:	e8 e8 f5 ff ff       	call   800d91 <fd_alloc>
  8017a9:	89 c3                	mov    %eax,%ebx
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	0f 88 e2 00 00 00    	js     801898 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b6:	83 ec 04             	sub    $0x4,%esp
  8017b9:	68 07 04 00 00       	push   $0x407
  8017be:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c1:	6a 00                	push   $0x0
  8017c3:	e8 d5 ed ff ff       	call   80059d <sys_page_alloc>
  8017c8:	89 c3                	mov    %eax,%ebx
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	0f 88 c3 00 00 00    	js     801898 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017d5:	83 ec 0c             	sub    $0xc,%esp
  8017d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017db:	e8 9a f5 ff ff       	call   800d7a <fd2data>
  8017e0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017e2:	83 c4 0c             	add    $0xc,%esp
  8017e5:	68 07 04 00 00       	push   $0x407
  8017ea:	50                   	push   %eax
  8017eb:	6a 00                	push   $0x0
  8017ed:	e8 ab ed ff ff       	call   80059d <sys_page_alloc>
  8017f2:	89 c3                	mov    %eax,%ebx
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	0f 88 89 00 00 00    	js     801888 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ff:	83 ec 0c             	sub    $0xc,%esp
  801802:	ff 75 f0             	pushl  -0x10(%ebp)
  801805:	e8 70 f5 ff ff       	call   800d7a <fd2data>
  80180a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801811:	50                   	push   %eax
  801812:	6a 00                	push   $0x0
  801814:	56                   	push   %esi
  801815:	6a 00                	push   $0x0
  801817:	e8 c4 ed ff ff       	call   8005e0 <sys_page_map>
  80181c:	89 c3                	mov    %eax,%ebx
  80181e:	83 c4 20             	add    $0x20,%esp
  801821:	85 c0                	test   %eax,%eax
  801823:	78 55                	js     80187a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801825:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80182b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801830:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801833:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80183a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801840:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801843:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801845:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801848:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80184f:	83 ec 0c             	sub    $0xc,%esp
  801852:	ff 75 f4             	pushl  -0xc(%ebp)
  801855:	e8 10 f5 ff ff       	call   800d6a <fd2num>
  80185a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80185d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80185f:	83 c4 04             	add    $0x4,%esp
  801862:	ff 75 f0             	pushl  -0x10(%ebp)
  801865:	e8 00 f5 ff ff       	call   800d6a <fd2num>
  80186a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80186d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	ba 00 00 00 00       	mov    $0x0,%edx
  801878:	eb 30                	jmp    8018aa <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80187a:	83 ec 08             	sub    $0x8,%esp
  80187d:	56                   	push   %esi
  80187e:	6a 00                	push   $0x0
  801880:	e8 9d ed ff ff       	call   800622 <sys_page_unmap>
  801885:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	ff 75 f0             	pushl  -0x10(%ebp)
  80188e:	6a 00                	push   $0x0
  801890:	e8 8d ed ff ff       	call   800622 <sys_page_unmap>
  801895:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801898:	83 ec 08             	sub    $0x8,%esp
  80189b:	ff 75 f4             	pushl  -0xc(%ebp)
  80189e:	6a 00                	push   $0x0
  8018a0:	e8 7d ed ff ff       	call   800622 <sys_page_unmap>
  8018a5:	83 c4 10             	add    $0x10,%esp
  8018a8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018aa:	89 d0                	mov    %edx,%eax
  8018ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018af:	5b                   	pop    %ebx
  8018b0:	5e                   	pop    %esi
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018bc:	50                   	push   %eax
  8018bd:	ff 75 08             	pushl  0x8(%ebp)
  8018c0:	e8 1b f5 ff ff       	call   800de0 <fd_lookup>
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	78 18                	js     8018e4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018cc:	83 ec 0c             	sub    $0xc,%esp
  8018cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d2:	e8 a3 f4 ff ff       	call   800d7a <fd2data>
	return _pipeisclosed(fd, p);
  8018d7:	89 c2                	mov    %eax,%edx
  8018d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018dc:	e8 18 fd ff ff       	call   8015f9 <_pipeisclosed>
  8018e1:	83 c4 10             	add    $0x10,%esp
}
  8018e4:	c9                   	leave  
  8018e5:	c3                   	ret    

008018e6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ee:	5d                   	pop    %ebp
  8018ef:	c3                   	ret    

008018f0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018f6:	68 96 27 80 00       	push   $0x802796
  8018fb:	ff 75 0c             	pushl  0xc(%ebp)
  8018fe:	e8 97 e8 ff ff       	call   80019a <strcpy>
	return 0;
}
  801903:	b8 00 00 00 00       	mov    $0x0,%eax
  801908:	c9                   	leave  
  801909:	c3                   	ret    

0080190a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	57                   	push   %edi
  80190e:	56                   	push   %esi
  80190f:	53                   	push   %ebx
  801910:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801916:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80191b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801921:	eb 2d                	jmp    801950 <devcons_write+0x46>
		m = n - tot;
  801923:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801926:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801928:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80192b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801930:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801933:	83 ec 04             	sub    $0x4,%esp
  801936:	53                   	push   %ebx
  801937:	03 45 0c             	add    0xc(%ebp),%eax
  80193a:	50                   	push   %eax
  80193b:	57                   	push   %edi
  80193c:	e8 eb e9 ff ff       	call   80032c <memmove>
		sys_cputs(buf, m);
  801941:	83 c4 08             	add    $0x8,%esp
  801944:	53                   	push   %ebx
  801945:	57                   	push   %edi
  801946:	e8 96 eb ff ff       	call   8004e1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80194b:	01 de                	add    %ebx,%esi
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	89 f0                	mov    %esi,%eax
  801952:	3b 75 10             	cmp    0x10(%ebp),%esi
  801955:	72 cc                	jb     801923 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801957:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80195a:	5b                   	pop    %ebx
  80195b:	5e                   	pop    %esi
  80195c:	5f                   	pop    %edi
  80195d:	5d                   	pop    %ebp
  80195e:	c3                   	ret    

0080195f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	83 ec 08             	sub    $0x8,%esp
  801965:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80196a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80196e:	74 2a                	je     80199a <devcons_read+0x3b>
  801970:	eb 05                	jmp    801977 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801972:	e8 07 ec ff ff       	call   80057e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801977:	e8 83 eb ff ff       	call   8004ff <sys_cgetc>
  80197c:	85 c0                	test   %eax,%eax
  80197e:	74 f2                	je     801972 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801980:	85 c0                	test   %eax,%eax
  801982:	78 16                	js     80199a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801984:	83 f8 04             	cmp    $0x4,%eax
  801987:	74 0c                	je     801995 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801989:	8b 55 0c             	mov    0xc(%ebp),%edx
  80198c:	88 02                	mov    %al,(%edx)
	return 1;
  80198e:	b8 01 00 00 00       	mov    $0x1,%eax
  801993:	eb 05                	jmp    80199a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801995:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019a8:	6a 01                	push   $0x1
  8019aa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019ad:	50                   	push   %eax
  8019ae:	e8 2e eb ff ff       	call   8004e1 <sys_cputs>
}
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <getchar>:

int
getchar(void)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019be:	6a 01                	push   $0x1
  8019c0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019c3:	50                   	push   %eax
  8019c4:	6a 00                	push   $0x0
  8019c6:	e8 7e f6 ff ff       	call   801049 <read>
	if (r < 0)
  8019cb:	83 c4 10             	add    $0x10,%esp
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	78 0f                	js     8019e1 <getchar+0x29>
		return r;
	if (r < 1)
  8019d2:	85 c0                	test   %eax,%eax
  8019d4:	7e 06                	jle    8019dc <getchar+0x24>
		return -E_EOF;
	return c;
  8019d6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019da:	eb 05                	jmp    8019e1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019dc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ec:	50                   	push   %eax
  8019ed:	ff 75 08             	pushl  0x8(%ebp)
  8019f0:	e8 eb f3 ff ff       	call   800de0 <fd_lookup>
  8019f5:	83 c4 10             	add    $0x10,%esp
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	78 11                	js     801a0d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ff:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a05:	39 10                	cmp    %edx,(%eax)
  801a07:	0f 94 c0             	sete   %al
  801a0a:	0f b6 c0             	movzbl %al,%eax
}
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    

00801a0f <opencons>:

int
opencons(void)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a18:	50                   	push   %eax
  801a19:	e8 73 f3 ff ff       	call   800d91 <fd_alloc>
  801a1e:	83 c4 10             	add    $0x10,%esp
		return r;
  801a21:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a23:	85 c0                	test   %eax,%eax
  801a25:	78 3e                	js     801a65 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a27:	83 ec 04             	sub    $0x4,%esp
  801a2a:	68 07 04 00 00       	push   $0x407
  801a2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a32:	6a 00                	push   $0x0
  801a34:	e8 64 eb ff ff       	call   80059d <sys_page_alloc>
  801a39:	83 c4 10             	add    $0x10,%esp
		return r;
  801a3c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	78 23                	js     801a65 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a42:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a50:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a57:	83 ec 0c             	sub    $0xc,%esp
  801a5a:	50                   	push   %eax
  801a5b:	e8 0a f3 ff ff       	call   800d6a <fd2num>
  801a60:	89 c2                	mov    %eax,%edx
  801a62:	83 c4 10             	add    $0x10,%esp
}
  801a65:	89 d0                	mov    %edx,%eax
  801a67:	c9                   	leave  
  801a68:	c3                   	ret    

00801a69 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	56                   	push   %esi
  801a6d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a6e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a71:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a77:	e8 e3 ea ff ff       	call   80055f <sys_getenvid>
  801a7c:	83 ec 0c             	sub    $0xc,%esp
  801a7f:	ff 75 0c             	pushl  0xc(%ebp)
  801a82:	ff 75 08             	pushl  0x8(%ebp)
  801a85:	56                   	push   %esi
  801a86:	50                   	push   %eax
  801a87:	68 a4 27 80 00       	push   $0x8027a4
  801a8c:	e8 b1 00 00 00       	call   801b42 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a91:	83 c4 18             	add    $0x18,%esp
  801a94:	53                   	push   %ebx
  801a95:	ff 75 10             	pushl  0x10(%ebp)
  801a98:	e8 54 00 00 00       	call   801af1 <vcprintf>
	cprintf("\n");
  801a9d:	c7 04 24 f6 25 80 00 	movl   $0x8025f6,(%esp)
  801aa4:	e8 99 00 00 00       	call   801b42 <cprintf>
  801aa9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801aac:	cc                   	int3   
  801aad:	eb fd                	jmp    801aac <_panic+0x43>

00801aaf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	53                   	push   %ebx
  801ab3:	83 ec 04             	sub    $0x4,%esp
  801ab6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801ab9:	8b 13                	mov    (%ebx),%edx
  801abb:	8d 42 01             	lea    0x1(%edx),%eax
  801abe:	89 03                	mov    %eax,(%ebx)
  801ac0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ac3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801ac7:	3d ff 00 00 00       	cmp    $0xff,%eax
  801acc:	75 1a                	jne    801ae8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801ace:	83 ec 08             	sub    $0x8,%esp
  801ad1:	68 ff 00 00 00       	push   $0xff
  801ad6:	8d 43 08             	lea    0x8(%ebx),%eax
  801ad9:	50                   	push   %eax
  801ada:	e8 02 ea ff ff       	call   8004e1 <sys_cputs>
		b->idx = 0;
  801adf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ae5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801ae8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801aec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aef:	c9                   	leave  
  801af0:	c3                   	ret    

00801af1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801afa:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b01:	00 00 00 
	b.cnt = 0;
  801b04:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801b0b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b0e:	ff 75 0c             	pushl  0xc(%ebp)
  801b11:	ff 75 08             	pushl  0x8(%ebp)
  801b14:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801b1a:	50                   	push   %eax
  801b1b:	68 af 1a 80 00       	push   $0x801aaf
  801b20:	e8 54 01 00 00       	call   801c79 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801b25:	83 c4 08             	add    $0x8,%esp
  801b28:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801b2e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801b34:	50                   	push   %eax
  801b35:	e8 a7 e9 ff ff       	call   8004e1 <sys_cputs>

	return b.cnt;
}
  801b3a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801b40:	c9                   	leave  
  801b41:	c3                   	ret    

00801b42 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b48:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801b4b:	50                   	push   %eax
  801b4c:	ff 75 08             	pushl  0x8(%ebp)
  801b4f:	e8 9d ff ff ff       	call   801af1 <vcprintf>
	va_end(ap);

	return cnt;
}
  801b54:	c9                   	leave  
  801b55:	c3                   	ret    

00801b56 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	57                   	push   %edi
  801b5a:	56                   	push   %esi
  801b5b:	53                   	push   %ebx
  801b5c:	83 ec 1c             	sub    $0x1c,%esp
  801b5f:	89 c7                	mov    %eax,%edi
  801b61:	89 d6                	mov    %edx,%esi
  801b63:	8b 45 08             	mov    0x8(%ebp),%eax
  801b66:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b69:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b6c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801b6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b72:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b77:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801b7a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801b7d:	39 d3                	cmp    %edx,%ebx
  801b7f:	72 05                	jb     801b86 <printnum+0x30>
  801b81:	39 45 10             	cmp    %eax,0x10(%ebp)
  801b84:	77 45                	ja     801bcb <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801b86:	83 ec 0c             	sub    $0xc,%esp
  801b89:	ff 75 18             	pushl  0x18(%ebp)
  801b8c:	8b 45 14             	mov    0x14(%ebp),%eax
  801b8f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801b92:	53                   	push   %ebx
  801b93:	ff 75 10             	pushl  0x10(%ebp)
  801b96:	83 ec 08             	sub    $0x8,%esp
  801b99:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b9c:	ff 75 e0             	pushl  -0x20(%ebp)
  801b9f:	ff 75 dc             	pushl  -0x24(%ebp)
  801ba2:	ff 75 d8             	pushl  -0x28(%ebp)
  801ba5:	e8 d6 06 00 00       	call   802280 <__udivdi3>
  801baa:	83 c4 18             	add    $0x18,%esp
  801bad:	52                   	push   %edx
  801bae:	50                   	push   %eax
  801baf:	89 f2                	mov    %esi,%edx
  801bb1:	89 f8                	mov    %edi,%eax
  801bb3:	e8 9e ff ff ff       	call   801b56 <printnum>
  801bb8:	83 c4 20             	add    $0x20,%esp
  801bbb:	eb 18                	jmp    801bd5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801bbd:	83 ec 08             	sub    $0x8,%esp
  801bc0:	56                   	push   %esi
  801bc1:	ff 75 18             	pushl  0x18(%ebp)
  801bc4:	ff d7                	call   *%edi
  801bc6:	83 c4 10             	add    $0x10,%esp
  801bc9:	eb 03                	jmp    801bce <printnum+0x78>
  801bcb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801bce:	83 eb 01             	sub    $0x1,%ebx
  801bd1:	85 db                	test   %ebx,%ebx
  801bd3:	7f e8                	jg     801bbd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	56                   	push   %esi
  801bd9:	83 ec 04             	sub    $0x4,%esp
  801bdc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bdf:	ff 75 e0             	pushl  -0x20(%ebp)
  801be2:	ff 75 dc             	pushl  -0x24(%ebp)
  801be5:	ff 75 d8             	pushl  -0x28(%ebp)
  801be8:	e8 c3 07 00 00       	call   8023b0 <__umoddi3>
  801bed:	83 c4 14             	add    $0x14,%esp
  801bf0:	0f be 80 c7 27 80 00 	movsbl 0x8027c7(%eax),%eax
  801bf7:	50                   	push   %eax
  801bf8:	ff d7                	call   *%edi
}
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801c08:	83 fa 01             	cmp    $0x1,%edx
  801c0b:	7e 0e                	jle    801c1b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801c0d:	8b 10                	mov    (%eax),%edx
  801c0f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801c12:	89 08                	mov    %ecx,(%eax)
  801c14:	8b 02                	mov    (%edx),%eax
  801c16:	8b 52 04             	mov    0x4(%edx),%edx
  801c19:	eb 22                	jmp    801c3d <getuint+0x38>
	else if (lflag)
  801c1b:	85 d2                	test   %edx,%edx
  801c1d:	74 10                	je     801c2f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801c1f:	8b 10                	mov    (%eax),%edx
  801c21:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c24:	89 08                	mov    %ecx,(%eax)
  801c26:	8b 02                	mov    (%edx),%eax
  801c28:	ba 00 00 00 00       	mov    $0x0,%edx
  801c2d:	eb 0e                	jmp    801c3d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801c2f:	8b 10                	mov    (%eax),%edx
  801c31:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c34:	89 08                	mov    %ecx,(%eax)
  801c36:	8b 02                	mov    (%edx),%eax
  801c38:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801c45:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801c49:	8b 10                	mov    (%eax),%edx
  801c4b:	3b 50 04             	cmp    0x4(%eax),%edx
  801c4e:	73 0a                	jae    801c5a <sprintputch+0x1b>
		*b->buf++ = ch;
  801c50:	8d 4a 01             	lea    0x1(%edx),%ecx
  801c53:	89 08                	mov    %ecx,(%eax)
  801c55:	8b 45 08             	mov    0x8(%ebp),%eax
  801c58:	88 02                	mov    %al,(%edx)
}
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    

00801c5c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801c62:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801c65:	50                   	push   %eax
  801c66:	ff 75 10             	pushl  0x10(%ebp)
  801c69:	ff 75 0c             	pushl  0xc(%ebp)
  801c6c:	ff 75 08             	pushl  0x8(%ebp)
  801c6f:	e8 05 00 00 00       	call   801c79 <vprintfmt>
	va_end(ap);
}
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    

00801c79 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	57                   	push   %edi
  801c7d:	56                   	push   %esi
  801c7e:	53                   	push   %ebx
  801c7f:	83 ec 2c             	sub    $0x2c,%esp
  801c82:	8b 75 08             	mov    0x8(%ebp),%esi
  801c85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c88:	8b 7d 10             	mov    0x10(%ebp),%edi
  801c8b:	eb 12                	jmp    801c9f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801c8d:	85 c0                	test   %eax,%eax
  801c8f:	0f 84 89 03 00 00    	je     80201e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801c95:	83 ec 08             	sub    $0x8,%esp
  801c98:	53                   	push   %ebx
  801c99:	50                   	push   %eax
  801c9a:	ff d6                	call   *%esi
  801c9c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801c9f:	83 c7 01             	add    $0x1,%edi
  801ca2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ca6:	83 f8 25             	cmp    $0x25,%eax
  801ca9:	75 e2                	jne    801c8d <vprintfmt+0x14>
  801cab:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801caf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801cb6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801cbd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801cc4:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc9:	eb 07                	jmp    801cd2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ccb:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801cce:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cd2:	8d 47 01             	lea    0x1(%edi),%eax
  801cd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801cd8:	0f b6 07             	movzbl (%edi),%eax
  801cdb:	0f b6 c8             	movzbl %al,%ecx
  801cde:	83 e8 23             	sub    $0x23,%eax
  801ce1:	3c 55                	cmp    $0x55,%al
  801ce3:	0f 87 1a 03 00 00    	ja     802003 <vprintfmt+0x38a>
  801ce9:	0f b6 c0             	movzbl %al,%eax
  801cec:	ff 24 85 00 29 80 00 	jmp    *0x802900(,%eax,4)
  801cf3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801cf6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801cfa:	eb d6                	jmp    801cd2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cfc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801cff:	b8 00 00 00 00       	mov    $0x0,%eax
  801d04:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801d07:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801d0a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801d0e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801d11:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801d14:	83 fa 09             	cmp    $0x9,%edx
  801d17:	77 39                	ja     801d52 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801d19:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801d1c:	eb e9                	jmp    801d07 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801d1e:	8b 45 14             	mov    0x14(%ebp),%eax
  801d21:	8d 48 04             	lea    0x4(%eax),%ecx
  801d24:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801d27:	8b 00                	mov    (%eax),%eax
  801d29:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d2c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801d2f:	eb 27                	jmp    801d58 <vprintfmt+0xdf>
  801d31:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d34:	85 c0                	test   %eax,%eax
  801d36:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d3b:	0f 49 c8             	cmovns %eax,%ecx
  801d3e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d41:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d44:	eb 8c                	jmp    801cd2 <vprintfmt+0x59>
  801d46:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801d49:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801d50:	eb 80                	jmp    801cd2 <vprintfmt+0x59>
  801d52:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d55:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801d58:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d5c:	0f 89 70 ff ff ff    	jns    801cd2 <vprintfmt+0x59>
				width = precision, precision = -1;
  801d62:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801d65:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d68:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801d6f:	e9 5e ff ff ff       	jmp    801cd2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801d74:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801d7a:	e9 53 ff ff ff       	jmp    801cd2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801d7f:	8b 45 14             	mov    0x14(%ebp),%eax
  801d82:	8d 50 04             	lea    0x4(%eax),%edx
  801d85:	89 55 14             	mov    %edx,0x14(%ebp)
  801d88:	83 ec 08             	sub    $0x8,%esp
  801d8b:	53                   	push   %ebx
  801d8c:	ff 30                	pushl  (%eax)
  801d8e:	ff d6                	call   *%esi
			break;
  801d90:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d93:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801d96:	e9 04 ff ff ff       	jmp    801c9f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801d9b:	8b 45 14             	mov    0x14(%ebp),%eax
  801d9e:	8d 50 04             	lea    0x4(%eax),%edx
  801da1:	89 55 14             	mov    %edx,0x14(%ebp)
  801da4:	8b 00                	mov    (%eax),%eax
  801da6:	99                   	cltd   
  801da7:	31 d0                	xor    %edx,%eax
  801da9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801dab:	83 f8 0f             	cmp    $0xf,%eax
  801dae:	7f 0b                	jg     801dbb <vprintfmt+0x142>
  801db0:	8b 14 85 60 2a 80 00 	mov    0x802a60(,%eax,4),%edx
  801db7:	85 d2                	test   %edx,%edx
  801db9:	75 18                	jne    801dd3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801dbb:	50                   	push   %eax
  801dbc:	68 df 27 80 00       	push   $0x8027df
  801dc1:	53                   	push   %ebx
  801dc2:	56                   	push   %esi
  801dc3:	e8 94 fe ff ff       	call   801c5c <printfmt>
  801dc8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dcb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801dce:	e9 cc fe ff ff       	jmp    801c9f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801dd3:	52                   	push   %edx
  801dd4:	68 5d 27 80 00       	push   $0x80275d
  801dd9:	53                   	push   %ebx
  801dda:	56                   	push   %esi
  801ddb:	e8 7c fe ff ff       	call   801c5c <printfmt>
  801de0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801de3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801de6:	e9 b4 fe ff ff       	jmp    801c9f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801deb:	8b 45 14             	mov    0x14(%ebp),%eax
  801dee:	8d 50 04             	lea    0x4(%eax),%edx
  801df1:	89 55 14             	mov    %edx,0x14(%ebp)
  801df4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801df6:	85 ff                	test   %edi,%edi
  801df8:	b8 d8 27 80 00       	mov    $0x8027d8,%eax
  801dfd:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801e00:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e04:	0f 8e 94 00 00 00    	jle    801e9e <vprintfmt+0x225>
  801e0a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801e0e:	0f 84 98 00 00 00    	je     801eac <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e14:	83 ec 08             	sub    $0x8,%esp
  801e17:	ff 75 d0             	pushl  -0x30(%ebp)
  801e1a:	57                   	push   %edi
  801e1b:	e8 59 e3 ff ff       	call   800179 <strnlen>
  801e20:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e23:	29 c1                	sub    %eax,%ecx
  801e25:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801e28:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801e2b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801e2f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e32:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801e35:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e37:	eb 0f                	jmp    801e48 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801e39:	83 ec 08             	sub    $0x8,%esp
  801e3c:	53                   	push   %ebx
  801e3d:	ff 75 e0             	pushl  -0x20(%ebp)
  801e40:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e42:	83 ef 01             	sub    $0x1,%edi
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	85 ff                	test   %edi,%edi
  801e4a:	7f ed                	jg     801e39 <vprintfmt+0x1c0>
  801e4c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801e4f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801e52:	85 c9                	test   %ecx,%ecx
  801e54:	b8 00 00 00 00       	mov    $0x0,%eax
  801e59:	0f 49 c1             	cmovns %ecx,%eax
  801e5c:	29 c1                	sub    %eax,%ecx
  801e5e:	89 75 08             	mov    %esi,0x8(%ebp)
  801e61:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801e64:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801e67:	89 cb                	mov    %ecx,%ebx
  801e69:	eb 4d                	jmp    801eb8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801e6b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801e6f:	74 1b                	je     801e8c <vprintfmt+0x213>
  801e71:	0f be c0             	movsbl %al,%eax
  801e74:	83 e8 20             	sub    $0x20,%eax
  801e77:	83 f8 5e             	cmp    $0x5e,%eax
  801e7a:	76 10                	jbe    801e8c <vprintfmt+0x213>
					putch('?', putdat);
  801e7c:	83 ec 08             	sub    $0x8,%esp
  801e7f:	ff 75 0c             	pushl  0xc(%ebp)
  801e82:	6a 3f                	push   $0x3f
  801e84:	ff 55 08             	call   *0x8(%ebp)
  801e87:	83 c4 10             	add    $0x10,%esp
  801e8a:	eb 0d                	jmp    801e99 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801e8c:	83 ec 08             	sub    $0x8,%esp
  801e8f:	ff 75 0c             	pushl  0xc(%ebp)
  801e92:	52                   	push   %edx
  801e93:	ff 55 08             	call   *0x8(%ebp)
  801e96:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801e99:	83 eb 01             	sub    $0x1,%ebx
  801e9c:	eb 1a                	jmp    801eb8 <vprintfmt+0x23f>
  801e9e:	89 75 08             	mov    %esi,0x8(%ebp)
  801ea1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ea4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ea7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801eaa:	eb 0c                	jmp    801eb8 <vprintfmt+0x23f>
  801eac:	89 75 08             	mov    %esi,0x8(%ebp)
  801eaf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801eb2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801eb5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801eb8:	83 c7 01             	add    $0x1,%edi
  801ebb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ebf:	0f be d0             	movsbl %al,%edx
  801ec2:	85 d2                	test   %edx,%edx
  801ec4:	74 23                	je     801ee9 <vprintfmt+0x270>
  801ec6:	85 f6                	test   %esi,%esi
  801ec8:	78 a1                	js     801e6b <vprintfmt+0x1f2>
  801eca:	83 ee 01             	sub    $0x1,%esi
  801ecd:	79 9c                	jns    801e6b <vprintfmt+0x1f2>
  801ecf:	89 df                	mov    %ebx,%edi
  801ed1:	8b 75 08             	mov    0x8(%ebp),%esi
  801ed4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ed7:	eb 18                	jmp    801ef1 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801ed9:	83 ec 08             	sub    $0x8,%esp
  801edc:	53                   	push   %ebx
  801edd:	6a 20                	push   $0x20
  801edf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801ee1:	83 ef 01             	sub    $0x1,%edi
  801ee4:	83 c4 10             	add    $0x10,%esp
  801ee7:	eb 08                	jmp    801ef1 <vprintfmt+0x278>
  801ee9:	89 df                	mov    %ebx,%edi
  801eeb:	8b 75 08             	mov    0x8(%ebp),%esi
  801eee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ef1:	85 ff                	test   %edi,%edi
  801ef3:	7f e4                	jg     801ed9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ef5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ef8:	e9 a2 fd ff ff       	jmp    801c9f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801efd:	83 fa 01             	cmp    $0x1,%edx
  801f00:	7e 16                	jle    801f18 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801f02:	8b 45 14             	mov    0x14(%ebp),%eax
  801f05:	8d 50 08             	lea    0x8(%eax),%edx
  801f08:	89 55 14             	mov    %edx,0x14(%ebp)
  801f0b:	8b 50 04             	mov    0x4(%eax),%edx
  801f0e:	8b 00                	mov    (%eax),%eax
  801f10:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f13:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f16:	eb 32                	jmp    801f4a <vprintfmt+0x2d1>
	else if (lflag)
  801f18:	85 d2                	test   %edx,%edx
  801f1a:	74 18                	je     801f34 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801f1c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f1f:	8d 50 04             	lea    0x4(%eax),%edx
  801f22:	89 55 14             	mov    %edx,0x14(%ebp)
  801f25:	8b 00                	mov    (%eax),%eax
  801f27:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f2a:	89 c1                	mov    %eax,%ecx
  801f2c:	c1 f9 1f             	sar    $0x1f,%ecx
  801f2f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801f32:	eb 16                	jmp    801f4a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801f34:	8b 45 14             	mov    0x14(%ebp),%eax
  801f37:	8d 50 04             	lea    0x4(%eax),%edx
  801f3a:	89 55 14             	mov    %edx,0x14(%ebp)
  801f3d:	8b 00                	mov    (%eax),%eax
  801f3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f42:	89 c1                	mov    %eax,%ecx
  801f44:	c1 f9 1f             	sar    $0x1f,%ecx
  801f47:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801f4a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801f4d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801f50:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801f55:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801f59:	79 74                	jns    801fcf <vprintfmt+0x356>
				putch('-', putdat);
  801f5b:	83 ec 08             	sub    $0x8,%esp
  801f5e:	53                   	push   %ebx
  801f5f:	6a 2d                	push   $0x2d
  801f61:	ff d6                	call   *%esi
				num = -(long long) num;
  801f63:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801f66:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801f69:	f7 d8                	neg    %eax
  801f6b:	83 d2 00             	adc    $0x0,%edx
  801f6e:	f7 da                	neg    %edx
  801f70:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801f73:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801f78:	eb 55                	jmp    801fcf <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801f7a:	8d 45 14             	lea    0x14(%ebp),%eax
  801f7d:	e8 83 fc ff ff       	call   801c05 <getuint>
			base = 10;
  801f82:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801f87:	eb 46                	jmp    801fcf <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801f89:	8d 45 14             	lea    0x14(%ebp),%eax
  801f8c:	e8 74 fc ff ff       	call   801c05 <getuint>
			base = 8;
  801f91:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801f96:	eb 37                	jmp    801fcf <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801f98:	83 ec 08             	sub    $0x8,%esp
  801f9b:	53                   	push   %ebx
  801f9c:	6a 30                	push   $0x30
  801f9e:	ff d6                	call   *%esi
			putch('x', putdat);
  801fa0:	83 c4 08             	add    $0x8,%esp
  801fa3:	53                   	push   %ebx
  801fa4:	6a 78                	push   $0x78
  801fa6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801fa8:	8b 45 14             	mov    0x14(%ebp),%eax
  801fab:	8d 50 04             	lea    0x4(%eax),%edx
  801fae:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801fb1:	8b 00                	mov    (%eax),%eax
  801fb3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801fb8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801fbb:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801fc0:	eb 0d                	jmp    801fcf <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801fc2:	8d 45 14             	lea    0x14(%ebp),%eax
  801fc5:	e8 3b fc ff ff       	call   801c05 <getuint>
			base = 16;
  801fca:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801fcf:	83 ec 0c             	sub    $0xc,%esp
  801fd2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801fd6:	57                   	push   %edi
  801fd7:	ff 75 e0             	pushl  -0x20(%ebp)
  801fda:	51                   	push   %ecx
  801fdb:	52                   	push   %edx
  801fdc:	50                   	push   %eax
  801fdd:	89 da                	mov    %ebx,%edx
  801fdf:	89 f0                	mov    %esi,%eax
  801fe1:	e8 70 fb ff ff       	call   801b56 <printnum>
			break;
  801fe6:	83 c4 20             	add    $0x20,%esp
  801fe9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801fec:	e9 ae fc ff ff       	jmp    801c9f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ff1:	83 ec 08             	sub    $0x8,%esp
  801ff4:	53                   	push   %ebx
  801ff5:	51                   	push   %ecx
  801ff6:	ff d6                	call   *%esi
			break;
  801ff8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ffb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ffe:	e9 9c fc ff ff       	jmp    801c9f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  802003:	83 ec 08             	sub    $0x8,%esp
  802006:	53                   	push   %ebx
  802007:	6a 25                	push   $0x25
  802009:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80200b:	83 c4 10             	add    $0x10,%esp
  80200e:	eb 03                	jmp    802013 <vprintfmt+0x39a>
  802010:	83 ef 01             	sub    $0x1,%edi
  802013:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  802017:	75 f7                	jne    802010 <vprintfmt+0x397>
  802019:	e9 81 fc ff ff       	jmp    801c9f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80201e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802021:	5b                   	pop    %ebx
  802022:	5e                   	pop    %esi
  802023:	5f                   	pop    %edi
  802024:	5d                   	pop    %ebp
  802025:	c3                   	ret    

00802026 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	83 ec 18             	sub    $0x18,%esp
  80202c:	8b 45 08             	mov    0x8(%ebp),%eax
  80202f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802032:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802035:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802039:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80203c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802043:	85 c0                	test   %eax,%eax
  802045:	74 26                	je     80206d <vsnprintf+0x47>
  802047:	85 d2                	test   %edx,%edx
  802049:	7e 22                	jle    80206d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80204b:	ff 75 14             	pushl  0x14(%ebp)
  80204e:	ff 75 10             	pushl  0x10(%ebp)
  802051:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802054:	50                   	push   %eax
  802055:	68 3f 1c 80 00       	push   $0x801c3f
  80205a:	e8 1a fc ff ff       	call   801c79 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80205f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802062:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802068:	83 c4 10             	add    $0x10,%esp
  80206b:	eb 05                	jmp    802072 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80206d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  802072:	c9                   	leave  
  802073:	c3                   	ret    

00802074 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80207a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80207d:	50                   	push   %eax
  80207e:	ff 75 10             	pushl  0x10(%ebp)
  802081:	ff 75 0c             	pushl  0xc(%ebp)
  802084:	ff 75 08             	pushl  0x8(%ebp)
  802087:	e8 9a ff ff ff       	call   802026 <vsnprintf>
	va_end(ap);

	return rc;
}
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802094:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80209b:	75 2a                	jne    8020c7 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80209d:	83 ec 04             	sub    $0x4,%esp
  8020a0:	6a 07                	push   $0x7
  8020a2:	68 00 f0 bf ee       	push   $0xeebff000
  8020a7:	6a 00                	push   $0x0
  8020a9:	e8 ef e4 ff ff       	call   80059d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8020ae:	83 c4 10             	add    $0x10,%esp
  8020b1:	85 c0                	test   %eax,%eax
  8020b3:	79 12                	jns    8020c7 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8020b5:	50                   	push   %eax
  8020b6:	68 28 26 80 00       	push   $0x802628
  8020bb:	6a 23                	push   $0x23
  8020bd:	68 c0 2a 80 00       	push   $0x802ac0
  8020c2:	e8 a2 f9 ff ff       	call   801a69 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ca:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8020cf:	83 ec 08             	sub    $0x8,%esp
  8020d2:	68 f9 20 80 00       	push   $0x8020f9
  8020d7:	6a 00                	push   $0x0
  8020d9:	e8 0a e6 ff ff       	call   8006e8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8020de:	83 c4 10             	add    $0x10,%esp
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	79 12                	jns    8020f7 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8020e5:	50                   	push   %eax
  8020e6:	68 28 26 80 00       	push   $0x802628
  8020eb:	6a 2c                	push   $0x2c
  8020ed:	68 c0 2a 80 00       	push   $0x802ac0
  8020f2:	e8 72 f9 ff ff       	call   801a69 <_panic>
	}
}
  8020f7:	c9                   	leave  
  8020f8:	c3                   	ret    

008020f9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020f9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020fa:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020ff:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802101:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802104:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802108:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80210d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802111:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802113:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802116:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802117:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80211a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80211b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80211c:	c3                   	ret    

0080211d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80211d:	55                   	push   %ebp
  80211e:	89 e5                	mov    %esp,%ebp
  802120:	56                   	push   %esi
  802121:	53                   	push   %ebx
  802122:	8b 75 08             	mov    0x8(%ebp),%esi
  802125:	8b 45 0c             	mov    0xc(%ebp),%eax
  802128:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80212b:	85 c0                	test   %eax,%eax
  80212d:	75 12                	jne    802141 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80212f:	83 ec 0c             	sub    $0xc,%esp
  802132:	68 00 00 c0 ee       	push   $0xeec00000
  802137:	e8 11 e6 ff ff       	call   80074d <sys_ipc_recv>
  80213c:	83 c4 10             	add    $0x10,%esp
  80213f:	eb 0c                	jmp    80214d <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802141:	83 ec 0c             	sub    $0xc,%esp
  802144:	50                   	push   %eax
  802145:	e8 03 e6 ff ff       	call   80074d <sys_ipc_recv>
  80214a:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80214d:	85 f6                	test   %esi,%esi
  80214f:	0f 95 c1             	setne  %cl
  802152:	85 db                	test   %ebx,%ebx
  802154:	0f 95 c2             	setne  %dl
  802157:	84 d1                	test   %dl,%cl
  802159:	74 09                	je     802164 <ipc_recv+0x47>
  80215b:	89 c2                	mov    %eax,%edx
  80215d:	c1 ea 1f             	shr    $0x1f,%edx
  802160:	84 d2                	test   %dl,%dl
  802162:	75 2d                	jne    802191 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802164:	85 f6                	test   %esi,%esi
  802166:	74 0d                	je     802175 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802168:	a1 04 40 80 00       	mov    0x804004,%eax
  80216d:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802173:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802175:	85 db                	test   %ebx,%ebx
  802177:	74 0d                	je     802186 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802179:	a1 04 40 80 00       	mov    0x804004,%eax
  80217e:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  802184:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802186:	a1 04 40 80 00       	mov    0x804004,%eax
  80218b:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802191:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    

00802198 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	57                   	push   %edi
  80219c:	56                   	push   %esi
  80219d:	53                   	push   %ebx
  80219e:	83 ec 0c             	sub    $0xc,%esp
  8021a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8021aa:	85 db                	test   %ebx,%ebx
  8021ac:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021b1:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8021b4:	ff 75 14             	pushl  0x14(%ebp)
  8021b7:	53                   	push   %ebx
  8021b8:	56                   	push   %esi
  8021b9:	57                   	push   %edi
  8021ba:	e8 6b e5 ff ff       	call   80072a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8021bf:	89 c2                	mov    %eax,%edx
  8021c1:	c1 ea 1f             	shr    $0x1f,%edx
  8021c4:	83 c4 10             	add    $0x10,%esp
  8021c7:	84 d2                	test   %dl,%dl
  8021c9:	74 17                	je     8021e2 <ipc_send+0x4a>
  8021cb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021ce:	74 12                	je     8021e2 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8021d0:	50                   	push   %eax
  8021d1:	68 ce 2a 80 00       	push   $0x802ace
  8021d6:	6a 47                	push   $0x47
  8021d8:	68 dc 2a 80 00       	push   $0x802adc
  8021dd:	e8 87 f8 ff ff       	call   801a69 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8021e2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021e5:	75 07                	jne    8021ee <ipc_send+0x56>
			sys_yield();
  8021e7:	e8 92 e3 ff ff       	call   80057e <sys_yield>
  8021ec:	eb c6                	jmp    8021b4 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8021ee:	85 c0                	test   %eax,%eax
  8021f0:	75 c2                	jne    8021b4 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8021f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f5:	5b                   	pop    %ebx
  8021f6:	5e                   	pop    %esi
  8021f7:	5f                   	pop    %edi
  8021f8:	5d                   	pop    %ebp
  8021f9:	c3                   	ret    

008021fa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021fa:	55                   	push   %ebp
  8021fb:	89 e5                	mov    %esp,%ebp
  8021fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802200:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802205:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80220b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802211:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802217:	39 ca                	cmp    %ecx,%edx
  802219:	75 13                	jne    80222e <ipc_find_env+0x34>
			return envs[i].env_id;
  80221b:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802221:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802226:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80222c:	eb 0f                	jmp    80223d <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80222e:	83 c0 01             	add    $0x1,%eax
  802231:	3d 00 04 00 00       	cmp    $0x400,%eax
  802236:	75 cd                	jne    802205 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802238:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80223d:	5d                   	pop    %ebp
  80223e:	c3                   	ret    

0080223f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80223f:	55                   	push   %ebp
  802240:	89 e5                	mov    %esp,%ebp
  802242:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802245:	89 d0                	mov    %edx,%eax
  802247:	c1 e8 16             	shr    $0x16,%eax
  80224a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802251:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802256:	f6 c1 01             	test   $0x1,%cl
  802259:	74 1d                	je     802278 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80225b:	c1 ea 0c             	shr    $0xc,%edx
  80225e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802265:	f6 c2 01             	test   $0x1,%dl
  802268:	74 0e                	je     802278 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80226a:	c1 ea 0c             	shr    $0xc,%edx
  80226d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802274:	ef 
  802275:	0f b7 c0             	movzwl %ax,%eax
}
  802278:	5d                   	pop    %ebp
  802279:	c3                   	ret    
  80227a:	66 90                	xchg   %ax,%ax
  80227c:	66 90                	xchg   %ax,%ax
  80227e:	66 90                	xchg   %ax,%ax

00802280 <__udivdi3>:
  802280:	55                   	push   %ebp
  802281:	57                   	push   %edi
  802282:	56                   	push   %esi
  802283:	53                   	push   %ebx
  802284:	83 ec 1c             	sub    $0x1c,%esp
  802287:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80228b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80228f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802293:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802297:	85 f6                	test   %esi,%esi
  802299:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80229d:	89 ca                	mov    %ecx,%edx
  80229f:	89 f8                	mov    %edi,%eax
  8022a1:	75 3d                	jne    8022e0 <__udivdi3+0x60>
  8022a3:	39 cf                	cmp    %ecx,%edi
  8022a5:	0f 87 c5 00 00 00    	ja     802370 <__udivdi3+0xf0>
  8022ab:	85 ff                	test   %edi,%edi
  8022ad:	89 fd                	mov    %edi,%ebp
  8022af:	75 0b                	jne    8022bc <__udivdi3+0x3c>
  8022b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b6:	31 d2                	xor    %edx,%edx
  8022b8:	f7 f7                	div    %edi
  8022ba:	89 c5                	mov    %eax,%ebp
  8022bc:	89 c8                	mov    %ecx,%eax
  8022be:	31 d2                	xor    %edx,%edx
  8022c0:	f7 f5                	div    %ebp
  8022c2:	89 c1                	mov    %eax,%ecx
  8022c4:	89 d8                	mov    %ebx,%eax
  8022c6:	89 cf                	mov    %ecx,%edi
  8022c8:	f7 f5                	div    %ebp
  8022ca:	89 c3                	mov    %eax,%ebx
  8022cc:	89 d8                	mov    %ebx,%eax
  8022ce:	89 fa                	mov    %edi,%edx
  8022d0:	83 c4 1c             	add    $0x1c,%esp
  8022d3:	5b                   	pop    %ebx
  8022d4:	5e                   	pop    %esi
  8022d5:	5f                   	pop    %edi
  8022d6:	5d                   	pop    %ebp
  8022d7:	c3                   	ret    
  8022d8:	90                   	nop
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	39 ce                	cmp    %ecx,%esi
  8022e2:	77 74                	ja     802358 <__udivdi3+0xd8>
  8022e4:	0f bd fe             	bsr    %esi,%edi
  8022e7:	83 f7 1f             	xor    $0x1f,%edi
  8022ea:	0f 84 98 00 00 00    	je     802388 <__udivdi3+0x108>
  8022f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	89 c5                	mov    %eax,%ebp
  8022f9:	29 fb                	sub    %edi,%ebx
  8022fb:	d3 e6                	shl    %cl,%esi
  8022fd:	89 d9                	mov    %ebx,%ecx
  8022ff:	d3 ed                	shr    %cl,%ebp
  802301:	89 f9                	mov    %edi,%ecx
  802303:	d3 e0                	shl    %cl,%eax
  802305:	09 ee                	or     %ebp,%esi
  802307:	89 d9                	mov    %ebx,%ecx
  802309:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80230d:	89 d5                	mov    %edx,%ebp
  80230f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802313:	d3 ed                	shr    %cl,%ebp
  802315:	89 f9                	mov    %edi,%ecx
  802317:	d3 e2                	shl    %cl,%edx
  802319:	89 d9                	mov    %ebx,%ecx
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	09 c2                	or     %eax,%edx
  80231f:	89 d0                	mov    %edx,%eax
  802321:	89 ea                	mov    %ebp,%edx
  802323:	f7 f6                	div    %esi
  802325:	89 d5                	mov    %edx,%ebp
  802327:	89 c3                	mov    %eax,%ebx
  802329:	f7 64 24 0c          	mull   0xc(%esp)
  80232d:	39 d5                	cmp    %edx,%ebp
  80232f:	72 10                	jb     802341 <__udivdi3+0xc1>
  802331:	8b 74 24 08          	mov    0x8(%esp),%esi
  802335:	89 f9                	mov    %edi,%ecx
  802337:	d3 e6                	shl    %cl,%esi
  802339:	39 c6                	cmp    %eax,%esi
  80233b:	73 07                	jae    802344 <__udivdi3+0xc4>
  80233d:	39 d5                	cmp    %edx,%ebp
  80233f:	75 03                	jne    802344 <__udivdi3+0xc4>
  802341:	83 eb 01             	sub    $0x1,%ebx
  802344:	31 ff                	xor    %edi,%edi
  802346:	89 d8                	mov    %ebx,%eax
  802348:	89 fa                	mov    %edi,%edx
  80234a:	83 c4 1c             	add    $0x1c,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802358:	31 ff                	xor    %edi,%edi
  80235a:	31 db                	xor    %ebx,%ebx
  80235c:	89 d8                	mov    %ebx,%eax
  80235e:	89 fa                	mov    %edi,%edx
  802360:	83 c4 1c             	add    $0x1c,%esp
  802363:	5b                   	pop    %ebx
  802364:	5e                   	pop    %esi
  802365:	5f                   	pop    %edi
  802366:	5d                   	pop    %ebp
  802367:	c3                   	ret    
  802368:	90                   	nop
  802369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802370:	89 d8                	mov    %ebx,%eax
  802372:	f7 f7                	div    %edi
  802374:	31 ff                	xor    %edi,%edi
  802376:	89 c3                	mov    %eax,%ebx
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	89 fa                	mov    %edi,%edx
  80237c:	83 c4 1c             	add    $0x1c,%esp
  80237f:	5b                   	pop    %ebx
  802380:	5e                   	pop    %esi
  802381:	5f                   	pop    %edi
  802382:	5d                   	pop    %ebp
  802383:	c3                   	ret    
  802384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802388:	39 ce                	cmp    %ecx,%esi
  80238a:	72 0c                	jb     802398 <__udivdi3+0x118>
  80238c:	31 db                	xor    %ebx,%ebx
  80238e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802392:	0f 87 34 ff ff ff    	ja     8022cc <__udivdi3+0x4c>
  802398:	bb 01 00 00 00       	mov    $0x1,%ebx
  80239d:	e9 2a ff ff ff       	jmp    8022cc <__udivdi3+0x4c>
  8023a2:	66 90                	xchg   %ax,%ax
  8023a4:	66 90                	xchg   %ax,%ax
  8023a6:	66 90                	xchg   %ax,%ax
  8023a8:	66 90                	xchg   %ax,%ax
  8023aa:	66 90                	xchg   %ax,%ax
  8023ac:	66 90                	xchg   %ax,%ax
  8023ae:	66 90                	xchg   %ax,%ax

008023b0 <__umoddi3>:
  8023b0:	55                   	push   %ebp
  8023b1:	57                   	push   %edi
  8023b2:	56                   	push   %esi
  8023b3:	53                   	push   %ebx
  8023b4:	83 ec 1c             	sub    $0x1c,%esp
  8023b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023c7:	85 d2                	test   %edx,%edx
  8023c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023d1:	89 f3                	mov    %esi,%ebx
  8023d3:	89 3c 24             	mov    %edi,(%esp)
  8023d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023da:	75 1c                	jne    8023f8 <__umoddi3+0x48>
  8023dc:	39 f7                	cmp    %esi,%edi
  8023de:	76 50                	jbe    802430 <__umoddi3+0x80>
  8023e0:	89 c8                	mov    %ecx,%eax
  8023e2:	89 f2                	mov    %esi,%edx
  8023e4:	f7 f7                	div    %edi
  8023e6:	89 d0                	mov    %edx,%eax
  8023e8:	31 d2                	xor    %edx,%edx
  8023ea:	83 c4 1c             	add    $0x1c,%esp
  8023ed:	5b                   	pop    %ebx
  8023ee:	5e                   	pop    %esi
  8023ef:	5f                   	pop    %edi
  8023f0:	5d                   	pop    %ebp
  8023f1:	c3                   	ret    
  8023f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023f8:	39 f2                	cmp    %esi,%edx
  8023fa:	89 d0                	mov    %edx,%eax
  8023fc:	77 52                	ja     802450 <__umoddi3+0xa0>
  8023fe:	0f bd ea             	bsr    %edx,%ebp
  802401:	83 f5 1f             	xor    $0x1f,%ebp
  802404:	75 5a                	jne    802460 <__umoddi3+0xb0>
  802406:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80240a:	0f 82 e0 00 00 00    	jb     8024f0 <__umoddi3+0x140>
  802410:	39 0c 24             	cmp    %ecx,(%esp)
  802413:	0f 86 d7 00 00 00    	jbe    8024f0 <__umoddi3+0x140>
  802419:	8b 44 24 08          	mov    0x8(%esp),%eax
  80241d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802421:	83 c4 1c             	add    $0x1c,%esp
  802424:	5b                   	pop    %ebx
  802425:	5e                   	pop    %esi
  802426:	5f                   	pop    %edi
  802427:	5d                   	pop    %ebp
  802428:	c3                   	ret    
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	85 ff                	test   %edi,%edi
  802432:	89 fd                	mov    %edi,%ebp
  802434:	75 0b                	jne    802441 <__umoddi3+0x91>
  802436:	b8 01 00 00 00       	mov    $0x1,%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	f7 f7                	div    %edi
  80243f:	89 c5                	mov    %eax,%ebp
  802441:	89 f0                	mov    %esi,%eax
  802443:	31 d2                	xor    %edx,%edx
  802445:	f7 f5                	div    %ebp
  802447:	89 c8                	mov    %ecx,%eax
  802449:	f7 f5                	div    %ebp
  80244b:	89 d0                	mov    %edx,%eax
  80244d:	eb 99                	jmp    8023e8 <__umoddi3+0x38>
  80244f:	90                   	nop
  802450:	89 c8                	mov    %ecx,%eax
  802452:	89 f2                	mov    %esi,%edx
  802454:	83 c4 1c             	add    $0x1c,%esp
  802457:	5b                   	pop    %ebx
  802458:	5e                   	pop    %esi
  802459:	5f                   	pop    %edi
  80245a:	5d                   	pop    %ebp
  80245b:	c3                   	ret    
  80245c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802460:	8b 34 24             	mov    (%esp),%esi
  802463:	bf 20 00 00 00       	mov    $0x20,%edi
  802468:	89 e9                	mov    %ebp,%ecx
  80246a:	29 ef                	sub    %ebp,%edi
  80246c:	d3 e0                	shl    %cl,%eax
  80246e:	89 f9                	mov    %edi,%ecx
  802470:	89 f2                	mov    %esi,%edx
  802472:	d3 ea                	shr    %cl,%edx
  802474:	89 e9                	mov    %ebp,%ecx
  802476:	09 c2                	or     %eax,%edx
  802478:	89 d8                	mov    %ebx,%eax
  80247a:	89 14 24             	mov    %edx,(%esp)
  80247d:	89 f2                	mov    %esi,%edx
  80247f:	d3 e2                	shl    %cl,%edx
  802481:	89 f9                	mov    %edi,%ecx
  802483:	89 54 24 04          	mov    %edx,0x4(%esp)
  802487:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80248b:	d3 e8                	shr    %cl,%eax
  80248d:	89 e9                	mov    %ebp,%ecx
  80248f:	89 c6                	mov    %eax,%esi
  802491:	d3 e3                	shl    %cl,%ebx
  802493:	89 f9                	mov    %edi,%ecx
  802495:	89 d0                	mov    %edx,%eax
  802497:	d3 e8                	shr    %cl,%eax
  802499:	89 e9                	mov    %ebp,%ecx
  80249b:	09 d8                	or     %ebx,%eax
  80249d:	89 d3                	mov    %edx,%ebx
  80249f:	89 f2                	mov    %esi,%edx
  8024a1:	f7 34 24             	divl   (%esp)
  8024a4:	89 d6                	mov    %edx,%esi
  8024a6:	d3 e3                	shl    %cl,%ebx
  8024a8:	f7 64 24 04          	mull   0x4(%esp)
  8024ac:	39 d6                	cmp    %edx,%esi
  8024ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024b2:	89 d1                	mov    %edx,%ecx
  8024b4:	89 c3                	mov    %eax,%ebx
  8024b6:	72 08                	jb     8024c0 <__umoddi3+0x110>
  8024b8:	75 11                	jne    8024cb <__umoddi3+0x11b>
  8024ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024be:	73 0b                	jae    8024cb <__umoddi3+0x11b>
  8024c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024c4:	1b 14 24             	sbb    (%esp),%edx
  8024c7:	89 d1                	mov    %edx,%ecx
  8024c9:	89 c3                	mov    %eax,%ebx
  8024cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024cf:	29 da                	sub    %ebx,%edx
  8024d1:	19 ce                	sbb    %ecx,%esi
  8024d3:	89 f9                	mov    %edi,%ecx
  8024d5:	89 f0                	mov    %esi,%eax
  8024d7:	d3 e0                	shl    %cl,%eax
  8024d9:	89 e9                	mov    %ebp,%ecx
  8024db:	d3 ea                	shr    %cl,%edx
  8024dd:	89 e9                	mov    %ebp,%ecx
  8024df:	d3 ee                	shr    %cl,%esi
  8024e1:	09 d0                	or     %edx,%eax
  8024e3:	89 f2                	mov    %esi,%edx
  8024e5:	83 c4 1c             	add    $0x1c,%esp
  8024e8:	5b                   	pop    %ebx
  8024e9:	5e                   	pop    %esi
  8024ea:	5f                   	pop    %edi
  8024eb:	5d                   	pop    %ebp
  8024ec:	c3                   	ret    
  8024ed:	8d 76 00             	lea    0x0(%esi),%esi
  8024f0:	29 f9                	sub    %edi,%ecx
  8024f2:	19 d6                	sbb    %edx,%esi
  8024f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024fc:	e9 18 ff ff ff       	jmp    802419 <__umoddi3+0x69>
