
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
  800051:	68 c0 22 80 00       	push   $0x8022c0
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
  80008a:	68 c3 22 80 00       	push   $0x8022c3
  80008f:	6a 01                	push   $0x1
  800091:	e8 2e 0e 00 00       	call   800ec4 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 bd 00 00 00       	call   800161 <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 12 0e 00 00       	call   800ec4 <write>
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
  8000c7:	68 4f 24 80 00       	push   $0x80244f
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 f1 0d 00 00       	call   800ec4 <write>
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
  80014d:	e8 84 0b 00 00       	call   800cd6 <close_all>
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
  800546:	68 cf 22 80 00       	push   $0x8022cf
  80054b:	6a 23                	push   $0x23
  80054d:	68 ec 22 80 00       	push   $0x8022ec
  800552:	e8 b0 12 00 00       	call   801807 <_panic>

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
  8005c7:	68 cf 22 80 00       	push   $0x8022cf
  8005cc:	6a 23                	push   $0x23
  8005ce:	68 ec 22 80 00       	push   $0x8022ec
  8005d3:	e8 2f 12 00 00       	call   801807 <_panic>

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
  800609:	68 cf 22 80 00       	push   $0x8022cf
  80060e:	6a 23                	push   $0x23
  800610:	68 ec 22 80 00       	push   $0x8022ec
  800615:	e8 ed 11 00 00       	call   801807 <_panic>

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
  80064b:	68 cf 22 80 00       	push   $0x8022cf
  800650:	6a 23                	push   $0x23
  800652:	68 ec 22 80 00       	push   $0x8022ec
  800657:	e8 ab 11 00 00       	call   801807 <_panic>

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
  80068d:	68 cf 22 80 00       	push   $0x8022cf
  800692:	6a 23                	push   $0x23
  800694:	68 ec 22 80 00       	push   $0x8022ec
  800699:	e8 69 11 00 00       	call   801807 <_panic>

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
  8006cf:	68 cf 22 80 00       	push   $0x8022cf
  8006d4:	6a 23                	push   $0x23
  8006d6:	68 ec 22 80 00       	push   $0x8022ec
  8006db:	e8 27 11 00 00       	call   801807 <_panic>
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
  800711:	68 cf 22 80 00       	push   $0x8022cf
  800716:	6a 23                	push   $0x23
  800718:	68 ec 22 80 00       	push   $0x8022ec
  80071d:	e8 e5 10 00 00       	call   801807 <_panic>

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
  800775:	68 cf 22 80 00       	push   $0x8022cf
  80077a:	6a 23                	push   $0x23
  80077c:	68 ec 22 80 00       	push   $0x8022ec
  800781:	e8 81 10 00 00       	call   801807 <_panic>

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
  800814:	68 fa 22 80 00       	push   $0x8022fa
  800819:	6a 1e                	push   $0x1e
  80081b:	68 0a 23 80 00       	push   $0x80230a
  800820:	e8 e2 0f 00 00       	call   801807 <_panic>
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
  80083e:	68 15 23 80 00       	push   $0x802315
  800843:	6a 2c                	push   $0x2c
  800845:	68 0a 23 80 00       	push   $0x80230a
  80084a:	e8 b8 0f 00 00       	call   801807 <_panic>
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
  800886:	68 15 23 80 00       	push   $0x802315
  80088b:	6a 33                	push   $0x33
  80088d:	68 0a 23 80 00       	push   $0x80230a
  800892:	e8 70 0f 00 00       	call   801807 <_panic>
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
  8008ae:	68 15 23 80 00       	push   $0x802315
  8008b3:	6a 37                	push   $0x37
  8008b5:	68 0a 23 80 00       	push   $0x80230a
  8008ba:	e8 48 0f 00 00       	call   801807 <_panic>
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
  8008d2:	e8 55 15 00 00       	call   801e2c <set_pgfault_handler>
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
  8008eb:	68 2e 23 80 00       	push   $0x80232e
  8008f0:	68 84 00 00 00       	push   $0x84
  8008f5:	68 0a 23 80 00       	push   $0x80230a
  8008fa:	e8 08 0f 00 00       	call   801807 <_panic>
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
  8009a7:	68 3c 23 80 00       	push   $0x80233c
  8009ac:	6a 54                	push   $0x54
  8009ae:	68 0a 23 80 00       	push   $0x80230a
  8009b3:	e8 4f 0e 00 00       	call   801807 <_panic>
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
  8009ec:	68 3c 23 80 00       	push   $0x80233c
  8009f1:	6a 5b                	push   $0x5b
  8009f3:	68 0a 23 80 00       	push   $0x80230a
  8009f8:	e8 0a 0e 00 00       	call   801807 <_panic>
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
  800a1a:	68 3c 23 80 00       	push   $0x80233c
  800a1f:	6a 5f                	push   $0x5f
  800a21:	68 0a 23 80 00       	push   $0x80230a
  800a26:	e8 dc 0d 00 00       	call   801807 <_panic>
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
  800a44:	68 3c 23 80 00       	push   $0x80233c
  800a49:	6a 64                	push   $0x64
  800a4b:	68 0a 23 80 00       	push   $0x80230a
  800a50:	e8 b2 0d 00 00       	call   801807 <_panic>
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
  800ab3:	68 54 23 80 00       	push   $0x802354
  800ab8:	e8 23 0e 00 00       	call   8018e0 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800abd:	c7 04 24 27 01 80 00 	movl   $0x800127,(%esp)
  800ac4:	e8 c5 fc ff ff       	call   80078e <sys_thread_create>
  800ac9:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  800acb:	83 c4 08             	add    $0x8,%esp
  800ace:	53                   	push   %ebx
  800acf:	68 54 23 80 00       	push   $0x802354
  800ad4:	e8 07 0e 00 00       	call   8018e0 <cprintf>
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

00800b08 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	05 00 00 00 30       	add    $0x30000000,%eax
  800b13:	c1 e8 0c             	shr    $0xc,%eax
}
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	05 00 00 00 30       	add    $0x30000000,%eax
  800b23:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800b28:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b35:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800b3a:	89 c2                	mov    %eax,%edx
  800b3c:	c1 ea 16             	shr    $0x16,%edx
  800b3f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800b46:	f6 c2 01             	test   $0x1,%dl
  800b49:	74 11                	je     800b5c <fd_alloc+0x2d>
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	c1 ea 0c             	shr    $0xc,%edx
  800b50:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800b57:	f6 c2 01             	test   $0x1,%dl
  800b5a:	75 09                	jne    800b65 <fd_alloc+0x36>
			*fd_store = fd;
  800b5c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b63:	eb 17                	jmp    800b7c <fd_alloc+0x4d>
  800b65:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800b6a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800b6f:	75 c9                	jne    800b3a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800b71:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800b77:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800b84:	83 f8 1f             	cmp    $0x1f,%eax
  800b87:	77 36                	ja     800bbf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800b89:	c1 e0 0c             	shl    $0xc,%eax
  800b8c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800b91:	89 c2                	mov    %eax,%edx
  800b93:	c1 ea 16             	shr    $0x16,%edx
  800b96:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800b9d:	f6 c2 01             	test   $0x1,%dl
  800ba0:	74 24                	je     800bc6 <fd_lookup+0x48>
  800ba2:	89 c2                	mov    %eax,%edx
  800ba4:	c1 ea 0c             	shr    $0xc,%edx
  800ba7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800bae:	f6 c2 01             	test   $0x1,%dl
  800bb1:	74 1a                	je     800bcd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb6:	89 02                	mov    %eax,(%edx)
	return 0;
  800bb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbd:	eb 13                	jmp    800bd2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800bbf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bc4:	eb 0c                	jmp    800bd2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800bc6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bcb:	eb 05                	jmp    800bd2 <fd_lookup+0x54>
  800bcd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	83 ec 08             	sub    $0x8,%esp
  800bda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdd:	ba f4 23 80 00       	mov    $0x8023f4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800be2:	eb 13                	jmp    800bf7 <dev_lookup+0x23>
  800be4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800be7:	39 08                	cmp    %ecx,(%eax)
  800be9:	75 0c                	jne    800bf7 <dev_lookup+0x23>
			*dev = devtab[i];
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	89 01                	mov    %eax,(%ecx)
			return 0;
  800bf0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf5:	eb 31                	jmp    800c28 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800bf7:	8b 02                	mov    (%edx),%eax
  800bf9:	85 c0                	test   %eax,%eax
  800bfb:	75 e7                	jne    800be4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800bfd:	a1 04 40 80 00       	mov    0x804004,%eax
  800c02:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800c08:	83 ec 04             	sub    $0x4,%esp
  800c0b:	51                   	push   %ecx
  800c0c:	50                   	push   %eax
  800c0d:	68 78 23 80 00       	push   $0x802378
  800c12:	e8 c9 0c 00 00       	call   8018e0 <cprintf>
	*dev = 0;
  800c17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	83 ec 10             	sub    $0x10,%esp
  800c32:	8b 75 08             	mov    0x8(%ebp),%esi
  800c35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800c38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c3b:	50                   	push   %eax
  800c3c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800c42:	c1 e8 0c             	shr    $0xc,%eax
  800c45:	50                   	push   %eax
  800c46:	e8 33 ff ff ff       	call   800b7e <fd_lookup>
  800c4b:	83 c4 08             	add    $0x8,%esp
  800c4e:	85 c0                	test   %eax,%eax
  800c50:	78 05                	js     800c57 <fd_close+0x2d>
	    || fd != fd2)
  800c52:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800c55:	74 0c                	je     800c63 <fd_close+0x39>
		return (must_exist ? r : 0);
  800c57:	84 db                	test   %bl,%bl
  800c59:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5e:	0f 44 c2             	cmove  %edx,%eax
  800c61:	eb 41                	jmp    800ca4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800c63:	83 ec 08             	sub    $0x8,%esp
  800c66:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c69:	50                   	push   %eax
  800c6a:	ff 36                	pushl  (%esi)
  800c6c:	e8 63 ff ff ff       	call   800bd4 <dev_lookup>
  800c71:	89 c3                	mov    %eax,%ebx
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	85 c0                	test   %eax,%eax
  800c78:	78 1a                	js     800c94 <fd_close+0x6a>
		if (dev->dev_close)
  800c7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c7d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800c80:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	74 0b                	je     800c94 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	56                   	push   %esi
  800c8d:	ff d0                	call   *%eax
  800c8f:	89 c3                	mov    %eax,%ebx
  800c91:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800c94:	83 ec 08             	sub    $0x8,%esp
  800c97:	56                   	push   %esi
  800c98:	6a 00                	push   $0x0
  800c9a:	e8 83 f9 ff ff       	call   800622 <sys_page_unmap>
	return r;
  800c9f:	83 c4 10             	add    $0x10,%esp
  800ca2:	89 d8                	mov    %ebx,%eax
}
  800ca4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800cb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cb4:	50                   	push   %eax
  800cb5:	ff 75 08             	pushl  0x8(%ebp)
  800cb8:	e8 c1 fe ff ff       	call   800b7e <fd_lookup>
  800cbd:	83 c4 08             	add    $0x8,%esp
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	78 10                	js     800cd4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800cc4:	83 ec 08             	sub    $0x8,%esp
  800cc7:	6a 01                	push   $0x1
  800cc9:	ff 75 f4             	pushl  -0xc(%ebp)
  800ccc:	e8 59 ff ff ff       	call   800c2a <fd_close>
  800cd1:	83 c4 10             	add    $0x10,%esp
}
  800cd4:	c9                   	leave  
  800cd5:	c3                   	ret    

00800cd6 <close_all>:

void
close_all(void)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	53                   	push   %ebx
  800cda:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800cdd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	53                   	push   %ebx
  800ce6:	e8 c0 ff ff ff       	call   800cab <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ceb:	83 c3 01             	add    $0x1,%ebx
  800cee:	83 c4 10             	add    $0x10,%esp
  800cf1:	83 fb 20             	cmp    $0x20,%ebx
  800cf4:	75 ec                	jne    800ce2 <close_all+0xc>
		close(i);
}
  800cf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cf9:	c9                   	leave  
  800cfa:	c3                   	ret    

00800cfb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 2c             	sub    $0x2c,%esp
  800d04:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800d07:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d0a:	50                   	push   %eax
  800d0b:	ff 75 08             	pushl  0x8(%ebp)
  800d0e:	e8 6b fe ff ff       	call   800b7e <fd_lookup>
  800d13:	83 c4 08             	add    $0x8,%esp
  800d16:	85 c0                	test   %eax,%eax
  800d18:	0f 88 c1 00 00 00    	js     800ddf <dup+0xe4>
		return r;
	close(newfdnum);
  800d1e:	83 ec 0c             	sub    $0xc,%esp
  800d21:	56                   	push   %esi
  800d22:	e8 84 ff ff ff       	call   800cab <close>

	newfd = INDEX2FD(newfdnum);
  800d27:	89 f3                	mov    %esi,%ebx
  800d29:	c1 e3 0c             	shl    $0xc,%ebx
  800d2c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800d32:	83 c4 04             	add    $0x4,%esp
  800d35:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d38:	e8 db fd ff ff       	call   800b18 <fd2data>
  800d3d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800d3f:	89 1c 24             	mov    %ebx,(%esp)
  800d42:	e8 d1 fd ff ff       	call   800b18 <fd2data>
  800d47:	83 c4 10             	add    $0x10,%esp
  800d4a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800d4d:	89 f8                	mov    %edi,%eax
  800d4f:	c1 e8 16             	shr    $0x16,%eax
  800d52:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d59:	a8 01                	test   $0x1,%al
  800d5b:	74 37                	je     800d94 <dup+0x99>
  800d5d:	89 f8                	mov    %edi,%eax
  800d5f:	c1 e8 0c             	shr    $0xc,%eax
  800d62:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800d69:	f6 c2 01             	test   $0x1,%dl
  800d6c:	74 26                	je     800d94 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800d6e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d75:	83 ec 0c             	sub    $0xc,%esp
  800d78:	25 07 0e 00 00       	and    $0xe07,%eax
  800d7d:	50                   	push   %eax
  800d7e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800d81:	6a 00                	push   $0x0
  800d83:	57                   	push   %edi
  800d84:	6a 00                	push   $0x0
  800d86:	e8 55 f8 ff ff       	call   8005e0 <sys_page_map>
  800d8b:	89 c7                	mov    %eax,%edi
  800d8d:	83 c4 20             	add    $0x20,%esp
  800d90:	85 c0                	test   %eax,%eax
  800d92:	78 2e                	js     800dc2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800d94:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d97:	89 d0                	mov    %edx,%eax
  800d99:	c1 e8 0c             	shr    $0xc,%eax
  800d9c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	25 07 0e 00 00       	and    $0xe07,%eax
  800dab:	50                   	push   %eax
  800dac:	53                   	push   %ebx
  800dad:	6a 00                	push   $0x0
  800daf:	52                   	push   %edx
  800db0:	6a 00                	push   $0x0
  800db2:	e8 29 f8 ff ff       	call   8005e0 <sys_page_map>
  800db7:	89 c7                	mov    %eax,%edi
  800db9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800dbc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800dbe:	85 ff                	test   %edi,%edi
  800dc0:	79 1d                	jns    800ddf <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800dc2:	83 ec 08             	sub    $0x8,%esp
  800dc5:	53                   	push   %ebx
  800dc6:	6a 00                	push   $0x0
  800dc8:	e8 55 f8 ff ff       	call   800622 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800dcd:	83 c4 08             	add    $0x8,%esp
  800dd0:	ff 75 d4             	pushl  -0x2c(%ebp)
  800dd3:	6a 00                	push   $0x0
  800dd5:	e8 48 f8 ff ff       	call   800622 <sys_page_unmap>
	return r;
  800dda:	83 c4 10             	add    $0x10,%esp
  800ddd:	89 f8                	mov    %edi,%eax
}
  800ddf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	53                   	push   %ebx
  800deb:	83 ec 14             	sub    $0x14,%esp
  800dee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800df1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800df4:	50                   	push   %eax
  800df5:	53                   	push   %ebx
  800df6:	e8 83 fd ff ff       	call   800b7e <fd_lookup>
  800dfb:	83 c4 08             	add    $0x8,%esp
  800dfe:	89 c2                	mov    %eax,%edx
  800e00:	85 c0                	test   %eax,%eax
  800e02:	78 70                	js     800e74 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e04:	83 ec 08             	sub    $0x8,%esp
  800e07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e0a:	50                   	push   %eax
  800e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0e:	ff 30                	pushl  (%eax)
  800e10:	e8 bf fd ff ff       	call   800bd4 <dev_lookup>
  800e15:	83 c4 10             	add    $0x10,%esp
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	78 4f                	js     800e6b <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800e1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e1f:	8b 42 08             	mov    0x8(%edx),%eax
  800e22:	83 e0 03             	and    $0x3,%eax
  800e25:	83 f8 01             	cmp    $0x1,%eax
  800e28:	75 24                	jne    800e4e <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800e2a:	a1 04 40 80 00       	mov    0x804004,%eax
  800e2f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800e35:	83 ec 04             	sub    $0x4,%esp
  800e38:	53                   	push   %ebx
  800e39:	50                   	push   %eax
  800e3a:	68 b9 23 80 00       	push   $0x8023b9
  800e3f:	e8 9c 0a 00 00       	call   8018e0 <cprintf>
		return -E_INVAL;
  800e44:	83 c4 10             	add    $0x10,%esp
  800e47:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800e4c:	eb 26                	jmp    800e74 <read+0x8d>
	}
	if (!dev->dev_read)
  800e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e51:	8b 40 08             	mov    0x8(%eax),%eax
  800e54:	85 c0                	test   %eax,%eax
  800e56:	74 17                	je     800e6f <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800e58:	83 ec 04             	sub    $0x4,%esp
  800e5b:	ff 75 10             	pushl  0x10(%ebp)
  800e5e:	ff 75 0c             	pushl  0xc(%ebp)
  800e61:	52                   	push   %edx
  800e62:	ff d0                	call   *%eax
  800e64:	89 c2                	mov    %eax,%edx
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	eb 09                	jmp    800e74 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e6b:	89 c2                	mov    %eax,%edx
  800e6d:	eb 05                	jmp    800e74 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800e6f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800e74:	89 d0                	mov    %edx,%eax
  800e76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e79:	c9                   	leave  
  800e7a:	c3                   	ret    

00800e7b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	57                   	push   %edi
  800e7f:	56                   	push   %esi
  800e80:	53                   	push   %ebx
  800e81:	83 ec 0c             	sub    $0xc,%esp
  800e84:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e87:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800e8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8f:	eb 21                	jmp    800eb2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800e91:	83 ec 04             	sub    $0x4,%esp
  800e94:	89 f0                	mov    %esi,%eax
  800e96:	29 d8                	sub    %ebx,%eax
  800e98:	50                   	push   %eax
  800e99:	89 d8                	mov    %ebx,%eax
  800e9b:	03 45 0c             	add    0xc(%ebp),%eax
  800e9e:	50                   	push   %eax
  800e9f:	57                   	push   %edi
  800ea0:	e8 42 ff ff ff       	call   800de7 <read>
		if (m < 0)
  800ea5:	83 c4 10             	add    $0x10,%esp
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	78 10                	js     800ebc <readn+0x41>
			return m;
		if (m == 0)
  800eac:	85 c0                	test   %eax,%eax
  800eae:	74 0a                	je     800eba <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800eb0:	01 c3                	add    %eax,%ebx
  800eb2:	39 f3                	cmp    %esi,%ebx
  800eb4:	72 db                	jb     800e91 <readn+0x16>
  800eb6:	89 d8                	mov    %ebx,%eax
  800eb8:	eb 02                	jmp    800ebc <readn+0x41>
  800eba:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800ebc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	53                   	push   %ebx
  800ec8:	83 ec 14             	sub    $0x14,%esp
  800ecb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ece:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ed1:	50                   	push   %eax
  800ed2:	53                   	push   %ebx
  800ed3:	e8 a6 fc ff ff       	call   800b7e <fd_lookup>
  800ed8:	83 c4 08             	add    $0x8,%esp
  800edb:	89 c2                	mov    %eax,%edx
  800edd:	85 c0                	test   %eax,%eax
  800edf:	78 6b                	js     800f4c <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ee1:	83 ec 08             	sub    $0x8,%esp
  800ee4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ee7:	50                   	push   %eax
  800ee8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eeb:	ff 30                	pushl  (%eax)
  800eed:	e8 e2 fc ff ff       	call   800bd4 <dev_lookup>
  800ef2:	83 c4 10             	add    $0x10,%esp
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	78 4a                	js     800f43 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800efc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800f00:	75 24                	jne    800f26 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800f02:	a1 04 40 80 00       	mov    0x804004,%eax
  800f07:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800f0d:	83 ec 04             	sub    $0x4,%esp
  800f10:	53                   	push   %ebx
  800f11:	50                   	push   %eax
  800f12:	68 d5 23 80 00       	push   $0x8023d5
  800f17:	e8 c4 09 00 00       	call   8018e0 <cprintf>
		return -E_INVAL;
  800f1c:	83 c4 10             	add    $0x10,%esp
  800f1f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800f24:	eb 26                	jmp    800f4c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800f26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f29:	8b 52 0c             	mov    0xc(%edx),%edx
  800f2c:	85 d2                	test   %edx,%edx
  800f2e:	74 17                	je     800f47 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800f30:	83 ec 04             	sub    $0x4,%esp
  800f33:	ff 75 10             	pushl  0x10(%ebp)
  800f36:	ff 75 0c             	pushl  0xc(%ebp)
  800f39:	50                   	push   %eax
  800f3a:	ff d2                	call   *%edx
  800f3c:	89 c2                	mov    %eax,%edx
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	eb 09                	jmp    800f4c <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800f43:	89 c2                	mov    %eax,%edx
  800f45:	eb 05                	jmp    800f4c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800f47:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800f4c:	89 d0                	mov    %edx,%eax
  800f4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <seek>:

int
seek(int fdnum, off_t offset)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f59:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800f5c:	50                   	push   %eax
  800f5d:	ff 75 08             	pushl  0x8(%ebp)
  800f60:	e8 19 fc ff ff       	call   800b7e <fd_lookup>
  800f65:	83 c4 08             	add    $0x8,%esp
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	78 0e                	js     800f7a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800f6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f72:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f7a:	c9                   	leave  
  800f7b:	c3                   	ret    

00800f7c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	53                   	push   %ebx
  800f80:	83 ec 14             	sub    $0x14,%esp
  800f83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800f86:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f89:	50                   	push   %eax
  800f8a:	53                   	push   %ebx
  800f8b:	e8 ee fb ff ff       	call   800b7e <fd_lookup>
  800f90:	83 c4 08             	add    $0x8,%esp
  800f93:	89 c2                	mov    %eax,%edx
  800f95:	85 c0                	test   %eax,%eax
  800f97:	78 68                	js     801001 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800f99:	83 ec 08             	sub    $0x8,%esp
  800f9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9f:	50                   	push   %eax
  800fa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa3:	ff 30                	pushl  (%eax)
  800fa5:	e8 2a fc ff ff       	call   800bd4 <dev_lookup>
  800faa:	83 c4 10             	add    $0x10,%esp
  800fad:	85 c0                	test   %eax,%eax
  800faf:	78 47                	js     800ff8 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800fb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fb4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800fb8:	75 24                	jne    800fde <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800fba:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800fbf:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800fc5:	83 ec 04             	sub    $0x4,%esp
  800fc8:	53                   	push   %ebx
  800fc9:	50                   	push   %eax
  800fca:	68 98 23 80 00       	push   $0x802398
  800fcf:	e8 0c 09 00 00       	call   8018e0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800fd4:	83 c4 10             	add    $0x10,%esp
  800fd7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800fdc:	eb 23                	jmp    801001 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800fde:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fe1:	8b 52 18             	mov    0x18(%edx),%edx
  800fe4:	85 d2                	test   %edx,%edx
  800fe6:	74 14                	je     800ffc <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800fe8:	83 ec 08             	sub    $0x8,%esp
  800feb:	ff 75 0c             	pushl  0xc(%ebp)
  800fee:	50                   	push   %eax
  800fef:	ff d2                	call   *%edx
  800ff1:	89 c2                	mov    %eax,%edx
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	eb 09                	jmp    801001 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ff8:	89 c2                	mov    %eax,%edx
  800ffa:	eb 05                	jmp    801001 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800ffc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801001:	89 d0                	mov    %edx,%eax
  801003:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801006:	c9                   	leave  
  801007:	c3                   	ret    

00801008 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	53                   	push   %ebx
  80100c:	83 ec 14             	sub    $0x14,%esp
  80100f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801012:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801015:	50                   	push   %eax
  801016:	ff 75 08             	pushl  0x8(%ebp)
  801019:	e8 60 fb ff ff       	call   800b7e <fd_lookup>
  80101e:	83 c4 08             	add    $0x8,%esp
  801021:	89 c2                	mov    %eax,%edx
  801023:	85 c0                	test   %eax,%eax
  801025:	78 58                	js     80107f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801027:	83 ec 08             	sub    $0x8,%esp
  80102a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102d:	50                   	push   %eax
  80102e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801031:	ff 30                	pushl  (%eax)
  801033:	e8 9c fb ff ff       	call   800bd4 <dev_lookup>
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	78 37                	js     801076 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80103f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801042:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801046:	74 32                	je     80107a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801048:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80104b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801052:	00 00 00 
	stat->st_isdir = 0;
  801055:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80105c:	00 00 00 
	stat->st_dev = dev;
  80105f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	53                   	push   %ebx
  801069:	ff 75 f0             	pushl  -0x10(%ebp)
  80106c:	ff 50 14             	call   *0x14(%eax)
  80106f:	89 c2                	mov    %eax,%edx
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	eb 09                	jmp    80107f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801076:	89 c2                	mov    %eax,%edx
  801078:	eb 05                	jmp    80107f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80107a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80107f:	89 d0                	mov    %edx,%eax
  801081:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	56                   	push   %esi
  80108a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80108b:	83 ec 08             	sub    $0x8,%esp
  80108e:	6a 00                	push   $0x0
  801090:	ff 75 08             	pushl  0x8(%ebp)
  801093:	e8 e3 01 00 00       	call   80127b <open>
  801098:	89 c3                	mov    %eax,%ebx
  80109a:	83 c4 10             	add    $0x10,%esp
  80109d:	85 c0                	test   %eax,%eax
  80109f:	78 1b                	js     8010bc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8010a1:	83 ec 08             	sub    $0x8,%esp
  8010a4:	ff 75 0c             	pushl  0xc(%ebp)
  8010a7:	50                   	push   %eax
  8010a8:	e8 5b ff ff ff       	call   801008 <fstat>
  8010ad:	89 c6                	mov    %eax,%esi
	close(fd);
  8010af:	89 1c 24             	mov    %ebx,(%esp)
  8010b2:	e8 f4 fb ff ff       	call   800cab <close>
	return r;
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	89 f0                	mov    %esi,%eax
}
  8010bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010bf:	5b                   	pop    %ebx
  8010c0:	5e                   	pop    %esi
  8010c1:	5d                   	pop    %ebp
  8010c2:	c3                   	ret    

008010c3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
  8010c8:	89 c6                	mov    %eax,%esi
  8010ca:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8010cc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8010d3:	75 12                	jne    8010e7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	6a 01                	push   $0x1
  8010da:	e8 b9 0e 00 00       	call   801f98 <ipc_find_env>
  8010df:	a3 00 40 80 00       	mov    %eax,0x804000
  8010e4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8010e7:	6a 07                	push   $0x7
  8010e9:	68 00 50 80 00       	push   $0x805000
  8010ee:	56                   	push   %esi
  8010ef:	ff 35 00 40 80 00    	pushl  0x804000
  8010f5:	e8 3c 0e 00 00       	call   801f36 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8010fa:	83 c4 0c             	add    $0xc,%esp
  8010fd:	6a 00                	push   $0x0
  8010ff:	53                   	push   %ebx
  801100:	6a 00                	push   $0x0
  801102:	e8 b4 0d 00 00       	call   801ebb <ipc_recv>
}
  801107:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80110a:	5b                   	pop    %ebx
  80110b:	5e                   	pop    %esi
  80110c:	5d                   	pop    %ebp
  80110d:	c3                   	ret    

0080110e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801114:	8b 45 08             	mov    0x8(%ebp),%eax
  801117:	8b 40 0c             	mov    0xc(%eax),%eax
  80111a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80111f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801122:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801127:	ba 00 00 00 00       	mov    $0x0,%edx
  80112c:	b8 02 00 00 00       	mov    $0x2,%eax
  801131:	e8 8d ff ff ff       	call   8010c3 <fsipc>
}
  801136:	c9                   	leave  
  801137:	c3                   	ret    

00801138 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80113e:	8b 45 08             	mov    0x8(%ebp),%eax
  801141:	8b 40 0c             	mov    0xc(%eax),%eax
  801144:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801149:	ba 00 00 00 00       	mov    $0x0,%edx
  80114e:	b8 06 00 00 00       	mov    $0x6,%eax
  801153:	e8 6b ff ff ff       	call   8010c3 <fsipc>
}
  801158:	c9                   	leave  
  801159:	c3                   	ret    

0080115a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	53                   	push   %ebx
  80115e:	83 ec 04             	sub    $0x4,%esp
  801161:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801164:	8b 45 08             	mov    0x8(%ebp),%eax
  801167:	8b 40 0c             	mov    0xc(%eax),%eax
  80116a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80116f:	ba 00 00 00 00       	mov    $0x0,%edx
  801174:	b8 05 00 00 00       	mov    $0x5,%eax
  801179:	e8 45 ff ff ff       	call   8010c3 <fsipc>
  80117e:	85 c0                	test   %eax,%eax
  801180:	78 2c                	js     8011ae <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801182:	83 ec 08             	sub    $0x8,%esp
  801185:	68 00 50 80 00       	push   $0x805000
  80118a:	53                   	push   %ebx
  80118b:	e8 0a f0 ff ff       	call   80019a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801190:	a1 80 50 80 00       	mov    0x805080,%eax
  801195:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80119b:	a1 84 50 80 00       	mov    0x805084,%eax
  8011a0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8011a6:	83 c4 10             	add    $0x10,%esp
  8011a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b1:	c9                   	leave  
  8011b2:	c3                   	ret    

008011b3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	83 ec 0c             	sub    $0xc,%esp
  8011b9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8011bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bf:	8b 52 0c             	mov    0xc(%edx),%edx
  8011c2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8011c8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8011cd:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8011d2:	0f 47 c2             	cmova  %edx,%eax
  8011d5:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8011da:	50                   	push   %eax
  8011db:	ff 75 0c             	pushl  0xc(%ebp)
  8011de:	68 08 50 80 00       	push   $0x805008
  8011e3:	e8 44 f1 ff ff       	call   80032c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8011e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ed:	b8 04 00 00 00       	mov    $0x4,%eax
  8011f2:	e8 cc fe ff ff       	call   8010c3 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8011f7:	c9                   	leave  
  8011f8:	c3                   	ret    

008011f9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	56                   	push   %esi
  8011fd:	53                   	push   %ebx
  8011fe:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801201:	8b 45 08             	mov    0x8(%ebp),%eax
  801204:	8b 40 0c             	mov    0xc(%eax),%eax
  801207:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80120c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801212:	ba 00 00 00 00       	mov    $0x0,%edx
  801217:	b8 03 00 00 00       	mov    $0x3,%eax
  80121c:	e8 a2 fe ff ff       	call   8010c3 <fsipc>
  801221:	89 c3                	mov    %eax,%ebx
  801223:	85 c0                	test   %eax,%eax
  801225:	78 4b                	js     801272 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801227:	39 c6                	cmp    %eax,%esi
  801229:	73 16                	jae    801241 <devfile_read+0x48>
  80122b:	68 04 24 80 00       	push   $0x802404
  801230:	68 0b 24 80 00       	push   $0x80240b
  801235:	6a 7c                	push   $0x7c
  801237:	68 20 24 80 00       	push   $0x802420
  80123c:	e8 c6 05 00 00       	call   801807 <_panic>
	assert(r <= PGSIZE);
  801241:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801246:	7e 16                	jle    80125e <devfile_read+0x65>
  801248:	68 2b 24 80 00       	push   $0x80242b
  80124d:	68 0b 24 80 00       	push   $0x80240b
  801252:	6a 7d                	push   $0x7d
  801254:	68 20 24 80 00       	push   $0x802420
  801259:	e8 a9 05 00 00       	call   801807 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	50                   	push   %eax
  801262:	68 00 50 80 00       	push   $0x805000
  801267:	ff 75 0c             	pushl  0xc(%ebp)
  80126a:	e8 bd f0 ff ff       	call   80032c <memmove>
	return r;
  80126f:	83 c4 10             	add    $0x10,%esp
}
  801272:	89 d8                	mov    %ebx,%eax
  801274:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801277:	5b                   	pop    %ebx
  801278:	5e                   	pop    %esi
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	53                   	push   %ebx
  80127f:	83 ec 20             	sub    $0x20,%esp
  801282:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801285:	53                   	push   %ebx
  801286:	e8 d6 ee ff ff       	call   800161 <strlen>
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801293:	7f 67                	jg     8012fc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801295:	83 ec 0c             	sub    $0xc,%esp
  801298:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129b:	50                   	push   %eax
  80129c:	e8 8e f8 ff ff       	call   800b2f <fd_alloc>
  8012a1:	83 c4 10             	add    $0x10,%esp
		return r;
  8012a4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 57                	js     801301 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	53                   	push   %ebx
  8012ae:	68 00 50 80 00       	push   $0x805000
  8012b3:	e8 e2 ee ff ff       	call   80019a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8012b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012bb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8012c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8012c8:	e8 f6 fd ff ff       	call   8010c3 <fsipc>
  8012cd:	89 c3                	mov    %eax,%ebx
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	79 14                	jns    8012ea <open+0x6f>
		fd_close(fd, 0);
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	6a 00                	push   $0x0
  8012db:	ff 75 f4             	pushl  -0xc(%ebp)
  8012de:	e8 47 f9 ff ff       	call   800c2a <fd_close>
		return r;
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	89 da                	mov    %ebx,%edx
  8012e8:	eb 17                	jmp    801301 <open+0x86>
	}

	return fd2num(fd);
  8012ea:	83 ec 0c             	sub    $0xc,%esp
  8012ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f0:	e8 13 f8 ff ff       	call   800b08 <fd2num>
  8012f5:	89 c2                	mov    %eax,%edx
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	eb 05                	jmp    801301 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8012fc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801301:	89 d0                	mov    %edx,%eax
  801303:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801306:	c9                   	leave  
  801307:	c3                   	ret    

00801308 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80130e:	ba 00 00 00 00       	mov    $0x0,%edx
  801313:	b8 08 00 00 00       	mov    $0x8,%eax
  801318:	e8 a6 fd ff ff       	call   8010c3 <fsipc>
}
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	56                   	push   %esi
  801323:	53                   	push   %ebx
  801324:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801327:	83 ec 0c             	sub    $0xc,%esp
  80132a:	ff 75 08             	pushl  0x8(%ebp)
  80132d:	e8 e6 f7 ff ff       	call   800b18 <fd2data>
  801332:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801334:	83 c4 08             	add    $0x8,%esp
  801337:	68 37 24 80 00       	push   $0x802437
  80133c:	53                   	push   %ebx
  80133d:	e8 58 ee ff ff       	call   80019a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801342:	8b 46 04             	mov    0x4(%esi),%eax
  801345:	2b 06                	sub    (%esi),%eax
  801347:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80134d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801354:	00 00 00 
	stat->st_dev = &devpipe;
  801357:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80135e:	30 80 00 
	return 0;
}
  801361:	b8 00 00 00 00       	mov    $0x0,%eax
  801366:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801369:	5b                   	pop    %ebx
  80136a:	5e                   	pop    %esi
  80136b:	5d                   	pop    %ebp
  80136c:	c3                   	ret    

0080136d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	53                   	push   %ebx
  801371:	83 ec 0c             	sub    $0xc,%esp
  801374:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801377:	53                   	push   %ebx
  801378:	6a 00                	push   $0x0
  80137a:	e8 a3 f2 ff ff       	call   800622 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80137f:	89 1c 24             	mov    %ebx,(%esp)
  801382:	e8 91 f7 ff ff       	call   800b18 <fd2data>
  801387:	83 c4 08             	add    $0x8,%esp
  80138a:	50                   	push   %eax
  80138b:	6a 00                	push   $0x0
  80138d:	e8 90 f2 ff ff       	call   800622 <sys_page_unmap>
}
  801392:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801395:	c9                   	leave  
  801396:	c3                   	ret    

00801397 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	57                   	push   %edi
  80139b:	56                   	push   %esi
  80139c:	53                   	push   %ebx
  80139d:	83 ec 1c             	sub    $0x1c,%esp
  8013a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013a3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8013a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8013aa:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8013b0:	83 ec 0c             	sub    $0xc,%esp
  8013b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8013b6:	e8 22 0c 00 00       	call   801fdd <pageref>
  8013bb:	89 c3                	mov    %eax,%ebx
  8013bd:	89 3c 24             	mov    %edi,(%esp)
  8013c0:	e8 18 0c 00 00       	call   801fdd <pageref>
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	39 c3                	cmp    %eax,%ebx
  8013ca:	0f 94 c1             	sete   %cl
  8013cd:	0f b6 c9             	movzbl %cl,%ecx
  8013d0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8013d3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8013d9:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  8013df:	39 ce                	cmp    %ecx,%esi
  8013e1:	74 1e                	je     801401 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8013e3:	39 c3                	cmp    %eax,%ebx
  8013e5:	75 be                	jne    8013a5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8013e7:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  8013ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013f0:	50                   	push   %eax
  8013f1:	56                   	push   %esi
  8013f2:	68 3e 24 80 00       	push   $0x80243e
  8013f7:	e8 e4 04 00 00       	call   8018e0 <cprintf>
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	eb a4                	jmp    8013a5 <_pipeisclosed+0xe>
	}
}
  801401:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801404:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801407:	5b                   	pop    %ebx
  801408:	5e                   	pop    %esi
  801409:	5f                   	pop    %edi
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    

0080140c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	57                   	push   %edi
  801410:	56                   	push   %esi
  801411:	53                   	push   %ebx
  801412:	83 ec 28             	sub    $0x28,%esp
  801415:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801418:	56                   	push   %esi
  801419:	e8 fa f6 ff ff       	call   800b18 <fd2data>
  80141e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	bf 00 00 00 00       	mov    $0x0,%edi
  801428:	eb 4b                	jmp    801475 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80142a:	89 da                	mov    %ebx,%edx
  80142c:	89 f0                	mov    %esi,%eax
  80142e:	e8 64 ff ff ff       	call   801397 <_pipeisclosed>
  801433:	85 c0                	test   %eax,%eax
  801435:	75 48                	jne    80147f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801437:	e8 42 f1 ff ff       	call   80057e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80143c:	8b 43 04             	mov    0x4(%ebx),%eax
  80143f:	8b 0b                	mov    (%ebx),%ecx
  801441:	8d 51 20             	lea    0x20(%ecx),%edx
  801444:	39 d0                	cmp    %edx,%eax
  801446:	73 e2                	jae    80142a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801448:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80144b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80144f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801452:	89 c2                	mov    %eax,%edx
  801454:	c1 fa 1f             	sar    $0x1f,%edx
  801457:	89 d1                	mov    %edx,%ecx
  801459:	c1 e9 1b             	shr    $0x1b,%ecx
  80145c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80145f:	83 e2 1f             	and    $0x1f,%edx
  801462:	29 ca                	sub    %ecx,%edx
  801464:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801468:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80146c:	83 c0 01             	add    $0x1,%eax
  80146f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801472:	83 c7 01             	add    $0x1,%edi
  801475:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801478:	75 c2                	jne    80143c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80147a:	8b 45 10             	mov    0x10(%ebp),%eax
  80147d:	eb 05                	jmp    801484 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80147f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801484:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801487:	5b                   	pop    %ebx
  801488:	5e                   	pop    %esi
  801489:	5f                   	pop    %edi
  80148a:	5d                   	pop    %ebp
  80148b:	c3                   	ret    

0080148c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	57                   	push   %edi
  801490:	56                   	push   %esi
  801491:	53                   	push   %ebx
  801492:	83 ec 18             	sub    $0x18,%esp
  801495:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801498:	57                   	push   %edi
  801499:	e8 7a f6 ff ff       	call   800b18 <fd2data>
  80149e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a8:	eb 3d                	jmp    8014e7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8014aa:	85 db                	test   %ebx,%ebx
  8014ac:	74 04                	je     8014b2 <devpipe_read+0x26>
				return i;
  8014ae:	89 d8                	mov    %ebx,%eax
  8014b0:	eb 44                	jmp    8014f6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8014b2:	89 f2                	mov    %esi,%edx
  8014b4:	89 f8                	mov    %edi,%eax
  8014b6:	e8 dc fe ff ff       	call   801397 <_pipeisclosed>
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	75 32                	jne    8014f1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8014bf:	e8 ba f0 ff ff       	call   80057e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8014c4:	8b 06                	mov    (%esi),%eax
  8014c6:	3b 46 04             	cmp    0x4(%esi),%eax
  8014c9:	74 df                	je     8014aa <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8014cb:	99                   	cltd   
  8014cc:	c1 ea 1b             	shr    $0x1b,%edx
  8014cf:	01 d0                	add    %edx,%eax
  8014d1:	83 e0 1f             	and    $0x1f,%eax
  8014d4:	29 d0                	sub    %edx,%eax
  8014d6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8014db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014de:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8014e1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8014e4:	83 c3 01             	add    $0x1,%ebx
  8014e7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8014ea:	75 d8                	jne    8014c4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8014ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8014ef:	eb 05                	jmp    8014f6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8014f1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8014f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f9:	5b                   	pop    %ebx
  8014fa:	5e                   	pop    %esi
  8014fb:	5f                   	pop    %edi
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    

008014fe <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	56                   	push   %esi
  801502:	53                   	push   %ebx
  801503:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801506:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801509:	50                   	push   %eax
  80150a:	e8 20 f6 ff ff       	call   800b2f <fd_alloc>
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	89 c2                	mov    %eax,%edx
  801514:	85 c0                	test   %eax,%eax
  801516:	0f 88 2c 01 00 00    	js     801648 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80151c:	83 ec 04             	sub    $0x4,%esp
  80151f:	68 07 04 00 00       	push   $0x407
  801524:	ff 75 f4             	pushl  -0xc(%ebp)
  801527:	6a 00                	push   $0x0
  801529:	e8 6f f0 ff ff       	call   80059d <sys_page_alloc>
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	89 c2                	mov    %eax,%edx
  801533:	85 c0                	test   %eax,%eax
  801535:	0f 88 0d 01 00 00    	js     801648 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80153b:	83 ec 0c             	sub    $0xc,%esp
  80153e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801541:	50                   	push   %eax
  801542:	e8 e8 f5 ff ff       	call   800b2f <fd_alloc>
  801547:	89 c3                	mov    %eax,%ebx
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	85 c0                	test   %eax,%eax
  80154e:	0f 88 e2 00 00 00    	js     801636 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801554:	83 ec 04             	sub    $0x4,%esp
  801557:	68 07 04 00 00       	push   $0x407
  80155c:	ff 75 f0             	pushl  -0x10(%ebp)
  80155f:	6a 00                	push   $0x0
  801561:	e8 37 f0 ff ff       	call   80059d <sys_page_alloc>
  801566:	89 c3                	mov    %eax,%ebx
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	85 c0                	test   %eax,%eax
  80156d:	0f 88 c3 00 00 00    	js     801636 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801573:	83 ec 0c             	sub    $0xc,%esp
  801576:	ff 75 f4             	pushl  -0xc(%ebp)
  801579:	e8 9a f5 ff ff       	call   800b18 <fd2data>
  80157e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801580:	83 c4 0c             	add    $0xc,%esp
  801583:	68 07 04 00 00       	push   $0x407
  801588:	50                   	push   %eax
  801589:	6a 00                	push   $0x0
  80158b:	e8 0d f0 ff ff       	call   80059d <sys_page_alloc>
  801590:	89 c3                	mov    %eax,%ebx
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	85 c0                	test   %eax,%eax
  801597:	0f 88 89 00 00 00    	js     801626 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80159d:	83 ec 0c             	sub    $0xc,%esp
  8015a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8015a3:	e8 70 f5 ff ff       	call   800b18 <fd2data>
  8015a8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8015af:	50                   	push   %eax
  8015b0:	6a 00                	push   $0x0
  8015b2:	56                   	push   %esi
  8015b3:	6a 00                	push   $0x0
  8015b5:	e8 26 f0 ff ff       	call   8005e0 <sys_page_map>
  8015ba:	89 c3                	mov    %eax,%ebx
  8015bc:	83 c4 20             	add    $0x20,%esp
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 55                	js     801618 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8015c3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8015c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015cc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8015ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8015d8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8015de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8015e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f3:	e8 10 f5 ff ff       	call   800b08 <fd2num>
  8015f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015fb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8015fd:	83 c4 04             	add    $0x4,%esp
  801600:	ff 75 f0             	pushl  -0x10(%ebp)
  801603:	e8 00 f5 ff ff       	call   800b08 <fd2num>
  801608:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80160b:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	ba 00 00 00 00       	mov    $0x0,%edx
  801616:	eb 30                	jmp    801648 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	56                   	push   %esi
  80161c:	6a 00                	push   $0x0
  80161e:	e8 ff ef ff ff       	call   800622 <sys_page_unmap>
  801623:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801626:	83 ec 08             	sub    $0x8,%esp
  801629:	ff 75 f0             	pushl  -0x10(%ebp)
  80162c:	6a 00                	push   $0x0
  80162e:	e8 ef ef ff ff       	call   800622 <sys_page_unmap>
  801633:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801636:	83 ec 08             	sub    $0x8,%esp
  801639:	ff 75 f4             	pushl  -0xc(%ebp)
  80163c:	6a 00                	push   $0x0
  80163e:	e8 df ef ff ff       	call   800622 <sys_page_unmap>
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801648:	89 d0                	mov    %edx,%eax
  80164a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164d:	5b                   	pop    %ebx
  80164e:	5e                   	pop    %esi
  80164f:	5d                   	pop    %ebp
  801650:	c3                   	ret    

00801651 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801657:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165a:	50                   	push   %eax
  80165b:	ff 75 08             	pushl  0x8(%ebp)
  80165e:	e8 1b f5 ff ff       	call   800b7e <fd_lookup>
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	85 c0                	test   %eax,%eax
  801668:	78 18                	js     801682 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80166a:	83 ec 0c             	sub    $0xc,%esp
  80166d:	ff 75 f4             	pushl  -0xc(%ebp)
  801670:	e8 a3 f4 ff ff       	call   800b18 <fd2data>
	return _pipeisclosed(fd, p);
  801675:	89 c2                	mov    %eax,%edx
  801677:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167a:	e8 18 fd ff ff       	call   801397 <_pipeisclosed>
  80167f:	83 c4 10             	add    $0x10,%esp
}
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801687:	b8 00 00 00 00       	mov    $0x0,%eax
  80168c:	5d                   	pop    %ebp
  80168d:	c3                   	ret    

0080168e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801694:	68 56 24 80 00       	push   $0x802456
  801699:	ff 75 0c             	pushl  0xc(%ebp)
  80169c:	e8 f9 ea ff ff       	call   80019a <strcpy>
	return 0;
}
  8016a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	57                   	push   %edi
  8016ac:	56                   	push   %esi
  8016ad:	53                   	push   %ebx
  8016ae:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8016b4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8016b9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8016bf:	eb 2d                	jmp    8016ee <devcons_write+0x46>
		m = n - tot;
  8016c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016c4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8016c6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8016c9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8016ce:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8016d1:	83 ec 04             	sub    $0x4,%esp
  8016d4:	53                   	push   %ebx
  8016d5:	03 45 0c             	add    0xc(%ebp),%eax
  8016d8:	50                   	push   %eax
  8016d9:	57                   	push   %edi
  8016da:	e8 4d ec ff ff       	call   80032c <memmove>
		sys_cputs(buf, m);
  8016df:	83 c4 08             	add    $0x8,%esp
  8016e2:	53                   	push   %ebx
  8016e3:	57                   	push   %edi
  8016e4:	e8 f8 ed ff ff       	call   8004e1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8016e9:	01 de                	add    %ebx,%esi
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	89 f0                	mov    %esi,%eax
  8016f0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8016f3:	72 cc                	jb     8016c1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8016f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f8:	5b                   	pop    %ebx
  8016f9:	5e                   	pop    %esi
  8016fa:	5f                   	pop    %edi
  8016fb:	5d                   	pop    %ebp
  8016fc:	c3                   	ret    

008016fd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	83 ec 08             	sub    $0x8,%esp
  801703:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801708:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80170c:	74 2a                	je     801738 <devcons_read+0x3b>
  80170e:	eb 05                	jmp    801715 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801710:	e8 69 ee ff ff       	call   80057e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801715:	e8 e5 ed ff ff       	call   8004ff <sys_cgetc>
  80171a:	85 c0                	test   %eax,%eax
  80171c:	74 f2                	je     801710 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80171e:	85 c0                	test   %eax,%eax
  801720:	78 16                	js     801738 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801722:	83 f8 04             	cmp    $0x4,%eax
  801725:	74 0c                	je     801733 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801727:	8b 55 0c             	mov    0xc(%ebp),%edx
  80172a:	88 02                	mov    %al,(%edx)
	return 1;
  80172c:	b8 01 00 00 00       	mov    $0x1,%eax
  801731:	eb 05                	jmp    801738 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801733:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801740:	8b 45 08             	mov    0x8(%ebp),%eax
  801743:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801746:	6a 01                	push   $0x1
  801748:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80174b:	50                   	push   %eax
  80174c:	e8 90 ed ff ff       	call   8004e1 <sys_cputs>
}
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	c9                   	leave  
  801755:	c3                   	ret    

00801756 <getchar>:

int
getchar(void)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80175c:	6a 01                	push   $0x1
  80175e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801761:	50                   	push   %eax
  801762:	6a 00                	push   $0x0
  801764:	e8 7e f6 ff ff       	call   800de7 <read>
	if (r < 0)
  801769:	83 c4 10             	add    $0x10,%esp
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 0f                	js     80177f <getchar+0x29>
		return r;
	if (r < 1)
  801770:	85 c0                	test   %eax,%eax
  801772:	7e 06                	jle    80177a <getchar+0x24>
		return -E_EOF;
	return c;
  801774:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801778:	eb 05                	jmp    80177f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80177a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80177f:	c9                   	leave  
  801780:	c3                   	ret    

00801781 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801787:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178a:	50                   	push   %eax
  80178b:	ff 75 08             	pushl  0x8(%ebp)
  80178e:	e8 eb f3 ff ff       	call   800b7e <fd_lookup>
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	85 c0                	test   %eax,%eax
  801798:	78 11                	js     8017ab <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80179a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8017a3:	39 10                	cmp    %edx,(%eax)
  8017a5:	0f 94 c0             	sete   %al
  8017a8:	0f b6 c0             	movzbl %al,%eax
}
  8017ab:	c9                   	leave  
  8017ac:	c3                   	ret    

008017ad <opencons>:

int
opencons(void)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8017b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b6:	50                   	push   %eax
  8017b7:	e8 73 f3 ff ff       	call   800b2f <fd_alloc>
  8017bc:	83 c4 10             	add    $0x10,%esp
		return r;
  8017bf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 3e                	js     801803 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8017c5:	83 ec 04             	sub    $0x4,%esp
  8017c8:	68 07 04 00 00       	push   $0x407
  8017cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d0:	6a 00                	push   $0x0
  8017d2:	e8 c6 ed ff ff       	call   80059d <sys_page_alloc>
  8017d7:	83 c4 10             	add    $0x10,%esp
		return r;
  8017da:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 23                	js     801803 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8017e0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8017e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8017eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ee:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8017f5:	83 ec 0c             	sub    $0xc,%esp
  8017f8:	50                   	push   %eax
  8017f9:	e8 0a f3 ff ff       	call   800b08 <fd2num>
  8017fe:	89 c2                	mov    %eax,%edx
  801800:	83 c4 10             	add    $0x10,%esp
}
  801803:	89 d0                	mov    %edx,%eax
  801805:	c9                   	leave  
  801806:	c3                   	ret    

00801807 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	56                   	push   %esi
  80180b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80180c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80180f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801815:	e8 45 ed ff ff       	call   80055f <sys_getenvid>
  80181a:	83 ec 0c             	sub    $0xc,%esp
  80181d:	ff 75 0c             	pushl  0xc(%ebp)
  801820:	ff 75 08             	pushl  0x8(%ebp)
  801823:	56                   	push   %esi
  801824:	50                   	push   %eax
  801825:	68 64 24 80 00       	push   $0x802464
  80182a:	e8 b1 00 00 00       	call   8018e0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80182f:	83 c4 18             	add    $0x18,%esp
  801832:	53                   	push   %ebx
  801833:	ff 75 10             	pushl  0x10(%ebp)
  801836:	e8 54 00 00 00       	call   80188f <vcprintf>
	cprintf("\n");
  80183b:	c7 04 24 4f 24 80 00 	movl   $0x80244f,(%esp)
  801842:	e8 99 00 00 00       	call   8018e0 <cprintf>
  801847:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80184a:	cc                   	int3   
  80184b:	eb fd                	jmp    80184a <_panic+0x43>

0080184d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	53                   	push   %ebx
  801851:	83 ec 04             	sub    $0x4,%esp
  801854:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801857:	8b 13                	mov    (%ebx),%edx
  801859:	8d 42 01             	lea    0x1(%edx),%eax
  80185c:	89 03                	mov    %eax,(%ebx)
  80185e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801861:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801865:	3d ff 00 00 00       	cmp    $0xff,%eax
  80186a:	75 1a                	jne    801886 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80186c:	83 ec 08             	sub    $0x8,%esp
  80186f:	68 ff 00 00 00       	push   $0xff
  801874:	8d 43 08             	lea    0x8(%ebx),%eax
  801877:	50                   	push   %eax
  801878:	e8 64 ec ff ff       	call   8004e1 <sys_cputs>
		b->idx = 0;
  80187d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801883:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801886:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80188a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188d:	c9                   	leave  
  80188e:	c3                   	ret    

0080188f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801898:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80189f:	00 00 00 
	b.cnt = 0;
  8018a2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8018a9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8018ac:	ff 75 0c             	pushl  0xc(%ebp)
  8018af:	ff 75 08             	pushl  0x8(%ebp)
  8018b2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8018b8:	50                   	push   %eax
  8018b9:	68 4d 18 80 00       	push   $0x80184d
  8018be:	e8 54 01 00 00       	call   801a17 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8018c3:	83 c4 08             	add    $0x8,%esp
  8018c6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8018cc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8018d2:	50                   	push   %eax
  8018d3:	e8 09 ec ff ff       	call   8004e1 <sys_cputs>

	return b.cnt;
}
  8018d8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8018de:	c9                   	leave  
  8018df:	c3                   	ret    

008018e0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018e6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8018e9:	50                   	push   %eax
  8018ea:	ff 75 08             	pushl  0x8(%ebp)
  8018ed:	e8 9d ff ff ff       	call   80188f <vcprintf>
	va_end(ap);

	return cnt;
}
  8018f2:	c9                   	leave  
  8018f3:	c3                   	ret    

008018f4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	57                   	push   %edi
  8018f8:	56                   	push   %esi
  8018f9:	53                   	push   %ebx
  8018fa:	83 ec 1c             	sub    $0x1c,%esp
  8018fd:	89 c7                	mov    %eax,%edi
  8018ff:	89 d6                	mov    %edx,%esi
  801901:	8b 45 08             	mov    0x8(%ebp),%eax
  801904:	8b 55 0c             	mov    0xc(%ebp),%edx
  801907:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80190a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80190d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801910:	bb 00 00 00 00       	mov    $0x0,%ebx
  801915:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801918:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80191b:	39 d3                	cmp    %edx,%ebx
  80191d:	72 05                	jb     801924 <printnum+0x30>
  80191f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801922:	77 45                	ja     801969 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801924:	83 ec 0c             	sub    $0xc,%esp
  801927:	ff 75 18             	pushl  0x18(%ebp)
  80192a:	8b 45 14             	mov    0x14(%ebp),%eax
  80192d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801930:	53                   	push   %ebx
  801931:	ff 75 10             	pushl  0x10(%ebp)
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	ff 75 e4             	pushl  -0x1c(%ebp)
  80193a:	ff 75 e0             	pushl  -0x20(%ebp)
  80193d:	ff 75 dc             	pushl  -0x24(%ebp)
  801940:	ff 75 d8             	pushl  -0x28(%ebp)
  801943:	e8 d8 06 00 00       	call   802020 <__udivdi3>
  801948:	83 c4 18             	add    $0x18,%esp
  80194b:	52                   	push   %edx
  80194c:	50                   	push   %eax
  80194d:	89 f2                	mov    %esi,%edx
  80194f:	89 f8                	mov    %edi,%eax
  801951:	e8 9e ff ff ff       	call   8018f4 <printnum>
  801956:	83 c4 20             	add    $0x20,%esp
  801959:	eb 18                	jmp    801973 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80195b:	83 ec 08             	sub    $0x8,%esp
  80195e:	56                   	push   %esi
  80195f:	ff 75 18             	pushl  0x18(%ebp)
  801962:	ff d7                	call   *%edi
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	eb 03                	jmp    80196c <printnum+0x78>
  801969:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80196c:	83 eb 01             	sub    $0x1,%ebx
  80196f:	85 db                	test   %ebx,%ebx
  801971:	7f e8                	jg     80195b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801973:	83 ec 08             	sub    $0x8,%esp
  801976:	56                   	push   %esi
  801977:	83 ec 04             	sub    $0x4,%esp
  80197a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80197d:	ff 75 e0             	pushl  -0x20(%ebp)
  801980:	ff 75 dc             	pushl  -0x24(%ebp)
  801983:	ff 75 d8             	pushl  -0x28(%ebp)
  801986:	e8 c5 07 00 00       	call   802150 <__umoddi3>
  80198b:	83 c4 14             	add    $0x14,%esp
  80198e:	0f be 80 87 24 80 00 	movsbl 0x802487(%eax),%eax
  801995:	50                   	push   %eax
  801996:	ff d7                	call   *%edi
}
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80199e:	5b                   	pop    %ebx
  80199f:	5e                   	pop    %esi
  8019a0:	5f                   	pop    %edi
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    

008019a3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8019a6:	83 fa 01             	cmp    $0x1,%edx
  8019a9:	7e 0e                	jle    8019b9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8019ab:	8b 10                	mov    (%eax),%edx
  8019ad:	8d 4a 08             	lea    0x8(%edx),%ecx
  8019b0:	89 08                	mov    %ecx,(%eax)
  8019b2:	8b 02                	mov    (%edx),%eax
  8019b4:	8b 52 04             	mov    0x4(%edx),%edx
  8019b7:	eb 22                	jmp    8019db <getuint+0x38>
	else if (lflag)
  8019b9:	85 d2                	test   %edx,%edx
  8019bb:	74 10                	je     8019cd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8019bd:	8b 10                	mov    (%eax),%edx
  8019bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8019c2:	89 08                	mov    %ecx,(%eax)
  8019c4:	8b 02                	mov    (%edx),%eax
  8019c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cb:	eb 0e                	jmp    8019db <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8019cd:	8b 10                	mov    (%eax),%edx
  8019cf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8019d2:	89 08                	mov    %ecx,(%eax)
  8019d4:	8b 02                	mov    (%edx),%eax
  8019d6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    

008019dd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8019e3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8019e7:	8b 10                	mov    (%eax),%edx
  8019e9:	3b 50 04             	cmp    0x4(%eax),%edx
  8019ec:	73 0a                	jae    8019f8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8019ee:	8d 4a 01             	lea    0x1(%edx),%ecx
  8019f1:	89 08                	mov    %ecx,(%eax)
  8019f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f6:	88 02                	mov    %al,(%edx)
}
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    

008019fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801a00:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801a03:	50                   	push   %eax
  801a04:	ff 75 10             	pushl  0x10(%ebp)
  801a07:	ff 75 0c             	pushl  0xc(%ebp)
  801a0a:	ff 75 08             	pushl  0x8(%ebp)
  801a0d:	e8 05 00 00 00       	call   801a17 <vprintfmt>
	va_end(ap);
}
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	c9                   	leave  
  801a16:	c3                   	ret    

00801a17 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	57                   	push   %edi
  801a1b:	56                   	push   %esi
  801a1c:	53                   	push   %ebx
  801a1d:	83 ec 2c             	sub    $0x2c,%esp
  801a20:	8b 75 08             	mov    0x8(%ebp),%esi
  801a23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a26:	8b 7d 10             	mov    0x10(%ebp),%edi
  801a29:	eb 12                	jmp    801a3d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801a2b:	85 c0                	test   %eax,%eax
  801a2d:	0f 84 89 03 00 00    	je     801dbc <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801a33:	83 ec 08             	sub    $0x8,%esp
  801a36:	53                   	push   %ebx
  801a37:	50                   	push   %eax
  801a38:	ff d6                	call   *%esi
  801a3a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a3d:	83 c7 01             	add    $0x1,%edi
  801a40:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a44:	83 f8 25             	cmp    $0x25,%eax
  801a47:	75 e2                	jne    801a2b <vprintfmt+0x14>
  801a49:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801a4d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801a54:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801a5b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801a62:	ba 00 00 00 00       	mov    $0x0,%edx
  801a67:	eb 07                	jmp    801a70 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a69:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801a6c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a70:	8d 47 01             	lea    0x1(%edi),%eax
  801a73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a76:	0f b6 07             	movzbl (%edi),%eax
  801a79:	0f b6 c8             	movzbl %al,%ecx
  801a7c:	83 e8 23             	sub    $0x23,%eax
  801a7f:	3c 55                	cmp    $0x55,%al
  801a81:	0f 87 1a 03 00 00    	ja     801da1 <vprintfmt+0x38a>
  801a87:	0f b6 c0             	movzbl %al,%eax
  801a8a:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  801a91:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801a94:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801a98:	eb d6                	jmp    801a70 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801aa5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801aa8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801aac:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801aaf:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801ab2:	83 fa 09             	cmp    $0x9,%edx
  801ab5:	77 39                	ja     801af0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801ab7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801aba:	eb e9                	jmp    801aa5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801abc:	8b 45 14             	mov    0x14(%ebp),%eax
  801abf:	8d 48 04             	lea    0x4(%eax),%ecx
  801ac2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801ac5:	8b 00                	mov    (%eax),%eax
  801ac7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801acd:	eb 27                	jmp    801af6 <vprintfmt+0xdf>
  801acf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ad9:	0f 49 c8             	cmovns %eax,%ecx
  801adc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801adf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ae2:	eb 8c                	jmp    801a70 <vprintfmt+0x59>
  801ae4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801ae7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801aee:	eb 80                	jmp    801a70 <vprintfmt+0x59>
  801af0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801af3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801af6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801afa:	0f 89 70 ff ff ff    	jns    801a70 <vprintfmt+0x59>
				width = precision, precision = -1;
  801b00:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801b03:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b06:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801b0d:	e9 5e ff ff ff       	jmp    801a70 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801b12:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b15:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801b18:	e9 53 ff ff ff       	jmp    801a70 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801b1d:	8b 45 14             	mov    0x14(%ebp),%eax
  801b20:	8d 50 04             	lea    0x4(%eax),%edx
  801b23:	89 55 14             	mov    %edx,0x14(%ebp)
  801b26:	83 ec 08             	sub    $0x8,%esp
  801b29:	53                   	push   %ebx
  801b2a:	ff 30                	pushl  (%eax)
  801b2c:	ff d6                	call   *%esi
			break;
  801b2e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b31:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801b34:	e9 04 ff ff ff       	jmp    801a3d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801b39:	8b 45 14             	mov    0x14(%ebp),%eax
  801b3c:	8d 50 04             	lea    0x4(%eax),%edx
  801b3f:	89 55 14             	mov    %edx,0x14(%ebp)
  801b42:	8b 00                	mov    (%eax),%eax
  801b44:	99                   	cltd   
  801b45:	31 d0                	xor    %edx,%eax
  801b47:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801b49:	83 f8 0f             	cmp    $0xf,%eax
  801b4c:	7f 0b                	jg     801b59 <vprintfmt+0x142>
  801b4e:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  801b55:	85 d2                	test   %edx,%edx
  801b57:	75 18                	jne    801b71 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801b59:	50                   	push   %eax
  801b5a:	68 9f 24 80 00       	push   $0x80249f
  801b5f:	53                   	push   %ebx
  801b60:	56                   	push   %esi
  801b61:	e8 94 fe ff ff       	call   8019fa <printfmt>
  801b66:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b69:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801b6c:	e9 cc fe ff ff       	jmp    801a3d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801b71:	52                   	push   %edx
  801b72:	68 1d 24 80 00       	push   $0x80241d
  801b77:	53                   	push   %ebx
  801b78:	56                   	push   %esi
  801b79:	e8 7c fe ff ff       	call   8019fa <printfmt>
  801b7e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b81:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b84:	e9 b4 fe ff ff       	jmp    801a3d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801b89:	8b 45 14             	mov    0x14(%ebp),%eax
  801b8c:	8d 50 04             	lea    0x4(%eax),%edx
  801b8f:	89 55 14             	mov    %edx,0x14(%ebp)
  801b92:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801b94:	85 ff                	test   %edi,%edi
  801b96:	b8 98 24 80 00       	mov    $0x802498,%eax
  801b9b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801b9e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801ba2:	0f 8e 94 00 00 00    	jle    801c3c <vprintfmt+0x225>
  801ba8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801bac:	0f 84 98 00 00 00    	je     801c4a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801bb2:	83 ec 08             	sub    $0x8,%esp
  801bb5:	ff 75 d0             	pushl  -0x30(%ebp)
  801bb8:	57                   	push   %edi
  801bb9:	e8 bb e5 ff ff       	call   800179 <strnlen>
  801bbe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801bc1:	29 c1                	sub    %eax,%ecx
  801bc3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801bc6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801bc9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801bcd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bd0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801bd3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801bd5:	eb 0f                	jmp    801be6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801bd7:	83 ec 08             	sub    $0x8,%esp
  801bda:	53                   	push   %ebx
  801bdb:	ff 75 e0             	pushl  -0x20(%ebp)
  801bde:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801be0:	83 ef 01             	sub    $0x1,%edi
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	85 ff                	test   %edi,%edi
  801be8:	7f ed                	jg     801bd7 <vprintfmt+0x1c0>
  801bea:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801bed:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801bf0:	85 c9                	test   %ecx,%ecx
  801bf2:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf7:	0f 49 c1             	cmovns %ecx,%eax
  801bfa:	29 c1                	sub    %eax,%ecx
  801bfc:	89 75 08             	mov    %esi,0x8(%ebp)
  801bff:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801c02:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801c05:	89 cb                	mov    %ecx,%ebx
  801c07:	eb 4d                	jmp    801c56 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801c09:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801c0d:	74 1b                	je     801c2a <vprintfmt+0x213>
  801c0f:	0f be c0             	movsbl %al,%eax
  801c12:	83 e8 20             	sub    $0x20,%eax
  801c15:	83 f8 5e             	cmp    $0x5e,%eax
  801c18:	76 10                	jbe    801c2a <vprintfmt+0x213>
					putch('?', putdat);
  801c1a:	83 ec 08             	sub    $0x8,%esp
  801c1d:	ff 75 0c             	pushl  0xc(%ebp)
  801c20:	6a 3f                	push   $0x3f
  801c22:	ff 55 08             	call   *0x8(%ebp)
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	eb 0d                	jmp    801c37 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801c2a:	83 ec 08             	sub    $0x8,%esp
  801c2d:	ff 75 0c             	pushl  0xc(%ebp)
  801c30:	52                   	push   %edx
  801c31:	ff 55 08             	call   *0x8(%ebp)
  801c34:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801c37:	83 eb 01             	sub    $0x1,%ebx
  801c3a:	eb 1a                	jmp    801c56 <vprintfmt+0x23f>
  801c3c:	89 75 08             	mov    %esi,0x8(%ebp)
  801c3f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801c42:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801c45:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801c48:	eb 0c                	jmp    801c56 <vprintfmt+0x23f>
  801c4a:	89 75 08             	mov    %esi,0x8(%ebp)
  801c4d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801c50:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801c53:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801c56:	83 c7 01             	add    $0x1,%edi
  801c59:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801c5d:	0f be d0             	movsbl %al,%edx
  801c60:	85 d2                	test   %edx,%edx
  801c62:	74 23                	je     801c87 <vprintfmt+0x270>
  801c64:	85 f6                	test   %esi,%esi
  801c66:	78 a1                	js     801c09 <vprintfmt+0x1f2>
  801c68:	83 ee 01             	sub    $0x1,%esi
  801c6b:	79 9c                	jns    801c09 <vprintfmt+0x1f2>
  801c6d:	89 df                	mov    %ebx,%edi
  801c6f:	8b 75 08             	mov    0x8(%ebp),%esi
  801c72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c75:	eb 18                	jmp    801c8f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801c77:	83 ec 08             	sub    $0x8,%esp
  801c7a:	53                   	push   %ebx
  801c7b:	6a 20                	push   $0x20
  801c7d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801c7f:	83 ef 01             	sub    $0x1,%edi
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	eb 08                	jmp    801c8f <vprintfmt+0x278>
  801c87:	89 df                	mov    %ebx,%edi
  801c89:	8b 75 08             	mov    0x8(%ebp),%esi
  801c8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c8f:	85 ff                	test   %edi,%edi
  801c91:	7f e4                	jg     801c77 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c93:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c96:	e9 a2 fd ff ff       	jmp    801a3d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801c9b:	83 fa 01             	cmp    $0x1,%edx
  801c9e:	7e 16                	jle    801cb6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801ca0:	8b 45 14             	mov    0x14(%ebp),%eax
  801ca3:	8d 50 08             	lea    0x8(%eax),%edx
  801ca6:	89 55 14             	mov    %edx,0x14(%ebp)
  801ca9:	8b 50 04             	mov    0x4(%eax),%edx
  801cac:	8b 00                	mov    (%eax),%eax
  801cae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801cb1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801cb4:	eb 32                	jmp    801ce8 <vprintfmt+0x2d1>
	else if (lflag)
  801cb6:	85 d2                	test   %edx,%edx
  801cb8:	74 18                	je     801cd2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801cba:	8b 45 14             	mov    0x14(%ebp),%eax
  801cbd:	8d 50 04             	lea    0x4(%eax),%edx
  801cc0:	89 55 14             	mov    %edx,0x14(%ebp)
  801cc3:	8b 00                	mov    (%eax),%eax
  801cc5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801cc8:	89 c1                	mov    %eax,%ecx
  801cca:	c1 f9 1f             	sar    $0x1f,%ecx
  801ccd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801cd0:	eb 16                	jmp    801ce8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801cd2:	8b 45 14             	mov    0x14(%ebp),%eax
  801cd5:	8d 50 04             	lea    0x4(%eax),%edx
  801cd8:	89 55 14             	mov    %edx,0x14(%ebp)
  801cdb:	8b 00                	mov    (%eax),%eax
  801cdd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ce0:	89 c1                	mov    %eax,%ecx
  801ce2:	c1 f9 1f             	sar    $0x1f,%ecx
  801ce5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801ce8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ceb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801cee:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801cf3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801cf7:	79 74                	jns    801d6d <vprintfmt+0x356>
				putch('-', putdat);
  801cf9:	83 ec 08             	sub    $0x8,%esp
  801cfc:	53                   	push   %ebx
  801cfd:	6a 2d                	push   $0x2d
  801cff:	ff d6                	call   *%esi
				num = -(long long) num;
  801d01:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801d04:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801d07:	f7 d8                	neg    %eax
  801d09:	83 d2 00             	adc    $0x0,%edx
  801d0c:	f7 da                	neg    %edx
  801d0e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801d11:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801d16:	eb 55                	jmp    801d6d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801d18:	8d 45 14             	lea    0x14(%ebp),%eax
  801d1b:	e8 83 fc ff ff       	call   8019a3 <getuint>
			base = 10;
  801d20:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801d25:	eb 46                	jmp    801d6d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801d27:	8d 45 14             	lea    0x14(%ebp),%eax
  801d2a:	e8 74 fc ff ff       	call   8019a3 <getuint>
			base = 8;
  801d2f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801d34:	eb 37                	jmp    801d6d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801d36:	83 ec 08             	sub    $0x8,%esp
  801d39:	53                   	push   %ebx
  801d3a:	6a 30                	push   $0x30
  801d3c:	ff d6                	call   *%esi
			putch('x', putdat);
  801d3e:	83 c4 08             	add    $0x8,%esp
  801d41:	53                   	push   %ebx
  801d42:	6a 78                	push   $0x78
  801d44:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801d46:	8b 45 14             	mov    0x14(%ebp),%eax
  801d49:	8d 50 04             	lea    0x4(%eax),%edx
  801d4c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801d4f:	8b 00                	mov    (%eax),%eax
  801d51:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801d56:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801d59:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801d5e:	eb 0d                	jmp    801d6d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801d60:	8d 45 14             	lea    0x14(%ebp),%eax
  801d63:	e8 3b fc ff ff       	call   8019a3 <getuint>
			base = 16;
  801d68:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801d6d:	83 ec 0c             	sub    $0xc,%esp
  801d70:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801d74:	57                   	push   %edi
  801d75:	ff 75 e0             	pushl  -0x20(%ebp)
  801d78:	51                   	push   %ecx
  801d79:	52                   	push   %edx
  801d7a:	50                   	push   %eax
  801d7b:	89 da                	mov    %ebx,%edx
  801d7d:	89 f0                	mov    %esi,%eax
  801d7f:	e8 70 fb ff ff       	call   8018f4 <printnum>
			break;
  801d84:	83 c4 20             	add    $0x20,%esp
  801d87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d8a:	e9 ae fc ff ff       	jmp    801a3d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801d8f:	83 ec 08             	sub    $0x8,%esp
  801d92:	53                   	push   %ebx
  801d93:	51                   	push   %ecx
  801d94:	ff d6                	call   *%esi
			break;
  801d96:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d99:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801d9c:	e9 9c fc ff ff       	jmp    801a3d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801da1:	83 ec 08             	sub    $0x8,%esp
  801da4:	53                   	push   %ebx
  801da5:	6a 25                	push   $0x25
  801da7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	eb 03                	jmp    801db1 <vprintfmt+0x39a>
  801dae:	83 ef 01             	sub    $0x1,%edi
  801db1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801db5:	75 f7                	jne    801dae <vprintfmt+0x397>
  801db7:	e9 81 fc ff ff       	jmp    801a3d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dbf:	5b                   	pop    %ebx
  801dc0:	5e                   	pop    %esi
  801dc1:	5f                   	pop    %edi
  801dc2:	5d                   	pop    %ebp
  801dc3:	c3                   	ret    

00801dc4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	83 ec 18             	sub    $0x18,%esp
  801dca:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801dd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801dd3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801dd7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801dda:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801de1:	85 c0                	test   %eax,%eax
  801de3:	74 26                	je     801e0b <vsnprintf+0x47>
  801de5:	85 d2                	test   %edx,%edx
  801de7:	7e 22                	jle    801e0b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801de9:	ff 75 14             	pushl  0x14(%ebp)
  801dec:	ff 75 10             	pushl  0x10(%ebp)
  801def:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801df2:	50                   	push   %eax
  801df3:	68 dd 19 80 00       	push   $0x8019dd
  801df8:	e8 1a fc ff ff       	call   801a17 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801dfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801e00:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e06:	83 c4 10             	add    $0x10,%esp
  801e09:	eb 05                	jmp    801e10 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801e0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801e10:	c9                   	leave  
  801e11:	c3                   	ret    

00801e12 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801e18:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801e1b:	50                   	push   %eax
  801e1c:	ff 75 10             	pushl  0x10(%ebp)
  801e1f:	ff 75 0c             	pushl  0xc(%ebp)
  801e22:	ff 75 08             	pushl  0x8(%ebp)
  801e25:	e8 9a ff ff ff       	call   801dc4 <vsnprintf>
	va_end(ap);

	return rc;
}
  801e2a:	c9                   	leave  
  801e2b:	c3                   	ret    

00801e2c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e32:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e39:	75 2a                	jne    801e65 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801e3b:	83 ec 04             	sub    $0x4,%esp
  801e3e:	6a 07                	push   $0x7
  801e40:	68 00 f0 bf ee       	push   $0xeebff000
  801e45:	6a 00                	push   $0x0
  801e47:	e8 51 e7 ff ff       	call   80059d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801e4c:	83 c4 10             	add    $0x10,%esp
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	79 12                	jns    801e65 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801e53:	50                   	push   %eax
  801e54:	68 80 27 80 00       	push   $0x802780
  801e59:	6a 23                	push   $0x23
  801e5b:	68 84 27 80 00       	push   $0x802784
  801e60:	e8 a2 f9 ff ff       	call   801807 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e65:	8b 45 08             	mov    0x8(%ebp),%eax
  801e68:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e6d:	83 ec 08             	sub    $0x8,%esp
  801e70:	68 97 1e 80 00       	push   $0x801e97
  801e75:	6a 00                	push   $0x0
  801e77:	e8 6c e8 ff ff       	call   8006e8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e7c:	83 c4 10             	add    $0x10,%esp
  801e7f:	85 c0                	test   %eax,%eax
  801e81:	79 12                	jns    801e95 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e83:	50                   	push   %eax
  801e84:	68 80 27 80 00       	push   $0x802780
  801e89:	6a 2c                	push   $0x2c
  801e8b:	68 84 27 80 00       	push   $0x802784
  801e90:	e8 72 f9 ff ff       	call   801807 <_panic>
	}
}
  801e95:	c9                   	leave  
  801e96:	c3                   	ret    

00801e97 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e97:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e98:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e9d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e9f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801ea2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801ea6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801eab:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801eaf:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801eb1:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801eb4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801eb5:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801eb8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801eb9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801eba:	c3                   	ret    

00801ebb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	56                   	push   %esi
  801ebf:	53                   	push   %ebx
  801ec0:	8b 75 08             	mov    0x8(%ebp),%esi
  801ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801ec9:	85 c0                	test   %eax,%eax
  801ecb:	75 12                	jne    801edf <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801ecd:	83 ec 0c             	sub    $0xc,%esp
  801ed0:	68 00 00 c0 ee       	push   $0xeec00000
  801ed5:	e8 73 e8 ff ff       	call   80074d <sys_ipc_recv>
  801eda:	83 c4 10             	add    $0x10,%esp
  801edd:	eb 0c                	jmp    801eeb <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801edf:	83 ec 0c             	sub    $0xc,%esp
  801ee2:	50                   	push   %eax
  801ee3:	e8 65 e8 ff ff       	call   80074d <sys_ipc_recv>
  801ee8:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801eeb:	85 f6                	test   %esi,%esi
  801eed:	0f 95 c1             	setne  %cl
  801ef0:	85 db                	test   %ebx,%ebx
  801ef2:	0f 95 c2             	setne  %dl
  801ef5:	84 d1                	test   %dl,%cl
  801ef7:	74 09                	je     801f02 <ipc_recv+0x47>
  801ef9:	89 c2                	mov    %eax,%edx
  801efb:	c1 ea 1f             	shr    $0x1f,%edx
  801efe:	84 d2                	test   %dl,%dl
  801f00:	75 2d                	jne    801f2f <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801f02:	85 f6                	test   %esi,%esi
  801f04:	74 0d                	je     801f13 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801f06:	a1 04 40 80 00       	mov    0x804004,%eax
  801f0b:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801f11:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801f13:	85 db                	test   %ebx,%ebx
  801f15:	74 0d                	je     801f24 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801f17:	a1 04 40 80 00       	mov    0x804004,%eax
  801f1c:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801f22:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f24:	a1 04 40 80 00       	mov    0x804004,%eax
  801f29:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801f2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f32:	5b                   	pop    %ebx
  801f33:	5e                   	pop    %esi
  801f34:	5d                   	pop    %ebp
  801f35:	c3                   	ret    

00801f36 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f36:	55                   	push   %ebp
  801f37:	89 e5                	mov    %esp,%ebp
  801f39:	57                   	push   %edi
  801f3a:	56                   	push   %esi
  801f3b:	53                   	push   %ebx
  801f3c:	83 ec 0c             	sub    $0xc,%esp
  801f3f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f42:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801f48:	85 db                	test   %ebx,%ebx
  801f4a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f4f:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f52:	ff 75 14             	pushl  0x14(%ebp)
  801f55:	53                   	push   %ebx
  801f56:	56                   	push   %esi
  801f57:	57                   	push   %edi
  801f58:	e8 cd e7 ff ff       	call   80072a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801f5d:	89 c2                	mov    %eax,%edx
  801f5f:	c1 ea 1f             	shr    $0x1f,%edx
  801f62:	83 c4 10             	add    $0x10,%esp
  801f65:	84 d2                	test   %dl,%dl
  801f67:	74 17                	je     801f80 <ipc_send+0x4a>
  801f69:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f6c:	74 12                	je     801f80 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f6e:	50                   	push   %eax
  801f6f:	68 92 27 80 00       	push   $0x802792
  801f74:	6a 47                	push   $0x47
  801f76:	68 a0 27 80 00       	push   $0x8027a0
  801f7b:	e8 87 f8 ff ff       	call   801807 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f80:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f83:	75 07                	jne    801f8c <ipc_send+0x56>
			sys_yield();
  801f85:	e8 f4 e5 ff ff       	call   80057e <sys_yield>
  801f8a:	eb c6                	jmp    801f52 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	75 c2                	jne    801f52 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    

00801f98 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f9e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fa3:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801fa9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801faf:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801fb5:	39 ca                	cmp    %ecx,%edx
  801fb7:	75 13                	jne    801fcc <ipc_find_env+0x34>
			return envs[i].env_id;
  801fb9:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801fbf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fc4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801fca:	eb 0f                	jmp    801fdb <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fcc:	83 c0 01             	add    $0x1,%eax
  801fcf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fd4:	75 cd                	jne    801fa3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    

00801fdd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fe3:	89 d0                	mov    %edx,%eax
  801fe5:	c1 e8 16             	shr    $0x16,%eax
  801fe8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fef:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff4:	f6 c1 01             	test   $0x1,%cl
  801ff7:	74 1d                	je     802016 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ff9:	c1 ea 0c             	shr    $0xc,%edx
  801ffc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802003:	f6 c2 01             	test   $0x1,%dl
  802006:	74 0e                	je     802016 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802008:	c1 ea 0c             	shr    $0xc,%edx
  80200b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802012:	ef 
  802013:	0f b7 c0             	movzwl %ax,%eax
}
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	66 90                	xchg   %ax,%ax
  80201a:	66 90                	xchg   %ax,%ax
  80201c:	66 90                	xchg   %ax,%ax
  80201e:	66 90                	xchg   %ax,%ax

00802020 <__udivdi3>:
  802020:	55                   	push   %ebp
  802021:	57                   	push   %edi
  802022:	56                   	push   %esi
  802023:	53                   	push   %ebx
  802024:	83 ec 1c             	sub    $0x1c,%esp
  802027:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80202b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80202f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802033:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802037:	85 f6                	test   %esi,%esi
  802039:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80203d:	89 ca                	mov    %ecx,%edx
  80203f:	89 f8                	mov    %edi,%eax
  802041:	75 3d                	jne    802080 <__udivdi3+0x60>
  802043:	39 cf                	cmp    %ecx,%edi
  802045:	0f 87 c5 00 00 00    	ja     802110 <__udivdi3+0xf0>
  80204b:	85 ff                	test   %edi,%edi
  80204d:	89 fd                	mov    %edi,%ebp
  80204f:	75 0b                	jne    80205c <__udivdi3+0x3c>
  802051:	b8 01 00 00 00       	mov    $0x1,%eax
  802056:	31 d2                	xor    %edx,%edx
  802058:	f7 f7                	div    %edi
  80205a:	89 c5                	mov    %eax,%ebp
  80205c:	89 c8                	mov    %ecx,%eax
  80205e:	31 d2                	xor    %edx,%edx
  802060:	f7 f5                	div    %ebp
  802062:	89 c1                	mov    %eax,%ecx
  802064:	89 d8                	mov    %ebx,%eax
  802066:	89 cf                	mov    %ecx,%edi
  802068:	f7 f5                	div    %ebp
  80206a:	89 c3                	mov    %eax,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	39 ce                	cmp    %ecx,%esi
  802082:	77 74                	ja     8020f8 <__udivdi3+0xd8>
  802084:	0f bd fe             	bsr    %esi,%edi
  802087:	83 f7 1f             	xor    $0x1f,%edi
  80208a:	0f 84 98 00 00 00    	je     802128 <__udivdi3+0x108>
  802090:	bb 20 00 00 00       	mov    $0x20,%ebx
  802095:	89 f9                	mov    %edi,%ecx
  802097:	89 c5                	mov    %eax,%ebp
  802099:	29 fb                	sub    %edi,%ebx
  80209b:	d3 e6                	shl    %cl,%esi
  80209d:	89 d9                	mov    %ebx,%ecx
  80209f:	d3 ed                	shr    %cl,%ebp
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	d3 e0                	shl    %cl,%eax
  8020a5:	09 ee                	or     %ebp,%esi
  8020a7:	89 d9                	mov    %ebx,%ecx
  8020a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ad:	89 d5                	mov    %edx,%ebp
  8020af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020b3:	d3 ed                	shr    %cl,%ebp
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	d3 e2                	shl    %cl,%edx
  8020b9:	89 d9                	mov    %ebx,%ecx
  8020bb:	d3 e8                	shr    %cl,%eax
  8020bd:	09 c2                	or     %eax,%edx
  8020bf:	89 d0                	mov    %edx,%eax
  8020c1:	89 ea                	mov    %ebp,%edx
  8020c3:	f7 f6                	div    %esi
  8020c5:	89 d5                	mov    %edx,%ebp
  8020c7:	89 c3                	mov    %eax,%ebx
  8020c9:	f7 64 24 0c          	mull   0xc(%esp)
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	72 10                	jb     8020e1 <__udivdi3+0xc1>
  8020d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e6                	shl    %cl,%esi
  8020d9:	39 c6                	cmp    %eax,%esi
  8020db:	73 07                	jae    8020e4 <__udivdi3+0xc4>
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	75 03                	jne    8020e4 <__udivdi3+0xc4>
  8020e1:	83 eb 01             	sub    $0x1,%ebx
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 d8                	mov    %ebx,%eax
  8020e8:	89 fa                	mov    %edi,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	31 ff                	xor    %edi,%edi
  8020fa:	31 db                	xor    %ebx,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	89 d8                	mov    %ebx,%eax
  802112:	f7 f7                	div    %edi
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 c3                	mov    %eax,%ebx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 fa                	mov    %edi,%edx
  80211c:	83 c4 1c             	add    $0x1c,%esp
  80211f:	5b                   	pop    %ebx
  802120:	5e                   	pop    %esi
  802121:	5f                   	pop    %edi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	39 ce                	cmp    %ecx,%esi
  80212a:	72 0c                	jb     802138 <__udivdi3+0x118>
  80212c:	31 db                	xor    %ebx,%ebx
  80212e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802132:	0f 87 34 ff ff ff    	ja     80206c <__udivdi3+0x4c>
  802138:	bb 01 00 00 00       	mov    $0x1,%ebx
  80213d:	e9 2a ff ff ff       	jmp    80206c <__udivdi3+0x4c>
  802142:	66 90                	xchg   %ax,%ax
  802144:	66 90                	xchg   %ax,%ax
  802146:	66 90                	xchg   %ax,%ax
  802148:	66 90                	xchg   %ax,%ax
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

00802150 <__umoddi3>:
  802150:	55                   	push   %ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	83 ec 1c             	sub    $0x1c,%esp
  802157:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80215b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80215f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802167:	85 d2                	test   %edx,%edx
  802169:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80216d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802171:	89 f3                	mov    %esi,%ebx
  802173:	89 3c 24             	mov    %edi,(%esp)
  802176:	89 74 24 04          	mov    %esi,0x4(%esp)
  80217a:	75 1c                	jne    802198 <__umoddi3+0x48>
  80217c:	39 f7                	cmp    %esi,%edi
  80217e:	76 50                	jbe    8021d0 <__umoddi3+0x80>
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	f7 f7                	div    %edi
  802186:	89 d0                	mov    %edx,%eax
  802188:	31 d2                	xor    %edx,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	39 f2                	cmp    %esi,%edx
  80219a:	89 d0                	mov    %edx,%eax
  80219c:	77 52                	ja     8021f0 <__umoddi3+0xa0>
  80219e:	0f bd ea             	bsr    %edx,%ebp
  8021a1:	83 f5 1f             	xor    $0x1f,%ebp
  8021a4:	75 5a                	jne    802200 <__umoddi3+0xb0>
  8021a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021aa:	0f 82 e0 00 00 00    	jb     802290 <__umoddi3+0x140>
  8021b0:	39 0c 24             	cmp    %ecx,(%esp)
  8021b3:	0f 86 d7 00 00 00    	jbe    802290 <__umoddi3+0x140>
  8021b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021c1:	83 c4 1c             	add    $0x1c,%esp
  8021c4:	5b                   	pop    %ebx
  8021c5:	5e                   	pop    %esi
  8021c6:	5f                   	pop    %edi
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	85 ff                	test   %edi,%edi
  8021d2:	89 fd                	mov    %edi,%ebp
  8021d4:	75 0b                	jne    8021e1 <__umoddi3+0x91>
  8021d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f7                	div    %edi
  8021df:	89 c5                	mov    %eax,%ebp
  8021e1:	89 f0                	mov    %esi,%eax
  8021e3:	31 d2                	xor    %edx,%edx
  8021e5:	f7 f5                	div    %ebp
  8021e7:	89 c8                	mov    %ecx,%eax
  8021e9:	f7 f5                	div    %ebp
  8021eb:	89 d0                	mov    %edx,%eax
  8021ed:	eb 99                	jmp    802188 <__umoddi3+0x38>
  8021ef:	90                   	nop
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	83 c4 1c             	add    $0x1c,%esp
  8021f7:	5b                   	pop    %ebx
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	8b 34 24             	mov    (%esp),%esi
  802203:	bf 20 00 00 00       	mov    $0x20,%edi
  802208:	89 e9                	mov    %ebp,%ecx
  80220a:	29 ef                	sub    %ebp,%edi
  80220c:	d3 e0                	shl    %cl,%eax
  80220e:	89 f9                	mov    %edi,%ecx
  802210:	89 f2                	mov    %esi,%edx
  802212:	d3 ea                	shr    %cl,%edx
  802214:	89 e9                	mov    %ebp,%ecx
  802216:	09 c2                	or     %eax,%edx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 14 24             	mov    %edx,(%esp)
  80221d:	89 f2                	mov    %esi,%edx
  80221f:	d3 e2                	shl    %cl,%edx
  802221:	89 f9                	mov    %edi,%ecx
  802223:	89 54 24 04          	mov    %edx,0x4(%esp)
  802227:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80222b:	d3 e8                	shr    %cl,%eax
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	89 c6                	mov    %eax,%esi
  802231:	d3 e3                	shl    %cl,%ebx
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 d0                	mov    %edx,%eax
  802237:	d3 e8                	shr    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	09 d8                	or     %ebx,%eax
  80223d:	89 d3                	mov    %edx,%ebx
  80223f:	89 f2                	mov    %esi,%edx
  802241:	f7 34 24             	divl   (%esp)
  802244:	89 d6                	mov    %edx,%esi
  802246:	d3 e3                	shl    %cl,%ebx
  802248:	f7 64 24 04          	mull   0x4(%esp)
  80224c:	39 d6                	cmp    %edx,%esi
  80224e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802252:	89 d1                	mov    %edx,%ecx
  802254:	89 c3                	mov    %eax,%ebx
  802256:	72 08                	jb     802260 <__umoddi3+0x110>
  802258:	75 11                	jne    80226b <__umoddi3+0x11b>
  80225a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80225e:	73 0b                	jae    80226b <__umoddi3+0x11b>
  802260:	2b 44 24 04          	sub    0x4(%esp),%eax
  802264:	1b 14 24             	sbb    (%esp),%edx
  802267:	89 d1                	mov    %edx,%ecx
  802269:	89 c3                	mov    %eax,%ebx
  80226b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80226f:	29 da                	sub    %ebx,%edx
  802271:	19 ce                	sbb    %ecx,%esi
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 f0                	mov    %esi,%eax
  802277:	d3 e0                	shl    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	d3 ea                	shr    %cl,%edx
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	d3 ee                	shr    %cl,%esi
  802281:	09 d0                	or     %edx,%eax
  802283:	89 f2                	mov    %esi,%edx
  802285:	83 c4 1c             	add    $0x1c,%esp
  802288:	5b                   	pop    %ebx
  802289:	5e                   	pop    %esi
  80228a:	5f                   	pop    %edi
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    
  80228d:	8d 76 00             	lea    0x0(%esi),%esi
  802290:	29 f9                	sub    %edi,%ecx
  802292:	19 d6                	sbb    %edx,%esi
  802294:	89 74 24 04          	mov    %esi,0x4(%esp)
  802298:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80229c:	e9 18 ff ff ff       	jmp    8021b9 <__umoddi3+0x69>
